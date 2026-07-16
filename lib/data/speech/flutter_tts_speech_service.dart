import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_tts/flutter_tts.dart';
// `meta` is transitive via the Flutter SDK and pubspec.yaml is not this file's
// to edit, but `@useResult` exists nowhere else — foundation.dart re-exports
// `@immutable` and not `@useResult` — and it is what keeps a discarded outcome
// from compiling clean.
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/data/speech/voice_filter.dart';
import 'package:offline_aac/model/speak_outcome.dart';

/// The one real [SpeechService]. Deliberately the thinnest file in the app.
///
/// This class cannot run in `flutter test` — that is the entire reason the
/// interface exists — so every line here is a line no test can reach. It does
/// exactly one thing: call the plugin and check what came back. Anything with
/// logic in it (parsing, voice choice, retry, caching, the fallback) belongs
/// one layer up, where a plain Dart test can execute it. If you are writing an
/// `if` here that is not a return-code check or a guard, it is in the wrong
/// file.
final class FlutterTtsSpeechService implements SpeechService {
  FlutterTtsSpeechService(this._currentVoice, {FlutterTts? tts})
    : _tts = tts ?? FlutterTts();

  /// The voice to speak with, asked for at speak time and never captured.
  /// Android garbage-collects voice data between launches, so the answer
  /// changes under us; a [Voice] cached at construction is a voice that may no
  /// longer exist by the time someone taps.
  final Voice? Function() _currentVoice;

  final FlutterTts _tts;

  static const _ttsSuccess = 1;
  static const _speakTimeout = Duration(seconds: 8);

  @override
  @useResult
  Future<SpeakOutcome> speak(String text) async {
    final voice = _currentVoice();
    if (voice == null) return NoVoiceSelected(text);

    // setVoice returns 1 (success) for a notInstalled voice, so the return
    // check below cannot see this. Guard before it, or synthesis silently
    // substitutes another voice — or says nothing at all. Move this guard below
    // the check and it becomes dead code while the case it exists for ships.
    if (voice.notInstalled) {
      return VoiceNotInstalled(text, voiceName: voice.name);
    }

    // THE bug this app exists to prevent. flutter_tts's Kotlin does:
    //   Log.d(tag, "Voice name not found: $voice"); result.success(0)
    // That is result.success, NOT result.error — it never throws. Unchecked,
    // this is a user in crisis tapping a tile and getting silence, with only a
    // Log.d on a device we will never see. It reads as paranoia. It is the
    // documented behaviour of the plugin. Never `assert` it either: asserts are
    // stripped in release, so the check would be green in every test and absent
    // on the phone.
    final Object? set = await _tts.setVoice(<String, String>{
      'name': voice.name,
      'locale': voice.locale,
    });
    if (set != _ttsSuccess) {
      return VoiceUnavailable(text, voiceName: voice.name);
    }

    final Object? spoke;
    try {
      spoke = await _tts.speak(text).timeout(_speakTimeout);
    } on TimeoutException {
      return EngineTimedOut(text, waited: _speakTimeout);
    } on PlatformException catch (e) {
      return EngineRejected(text, code: e.code);
    }
    if (spoke != _ttsSuccess) return EngineRejected(text, code: spoke);
    return const SpokeAloud();
  }

  /// The preview: the same guards and timeout as [speak], applied to a voice the
  /// caller names rather than the stored one, at a caller-chosen pitch and rate.
  /// The notInstalled guard sits BEFORE the setVoice check for the same reason it
  /// does in [speak] — setVoice returns 1 for a notInstalled voice.
  @override
  @useResult
  Future<SpeakOutcome> preview(
    String text, {
    required Voice voice,
    required double pitch,
    required double rate,
  }) async {
    if (voice.notInstalled) {
      return VoiceNotInstalled(text, voiceName: voice.name);
    }
    final Object? set = await _tts.setVoice(<String, String>{
      'name': voice.name,
      'locale': voice.locale,
    });
    if (set != _ttsSuccess) {
      return VoiceUnavailable(text, voiceName: voice.name);
    }
    await _tts.setPitch(pitch);
    // Mapped, not raw: flutter_tts treats 0.5 as normal speed (it doubles the
    // value on Android), so Reed's 1.0-is-normal multiplier must be converted or
    // the preview plays at double speed.
    await _tts.setSpeechRate(ttsSpeechRate(rate));

    final Object? spoke;
    try {
      spoke = await _tts.speak(text).timeout(_speakTimeout);
    } on TimeoutException {
      return EngineTimedOut(text, waited: _speakTimeout);
    } on PlatformException catch (e) {
      return EngineRejected(text, code: e.code);
    }
    if (spoke != _ttsSuccess) return EngineRejected(text, code: spoke);
    return const SpokeAloud();
  }

  /// Barge-in is the caller's policy — the controller stops before every speak.
  /// This just stops.
  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  /// The raw payload goes straight to the filter with no cast and no null check
  /// of its own. `getVoices` can return null (the plugin catches a
  /// NullPointerException and calls result.success(null)) and otherwise hands
  /// back `List<Object?>` of `Map<Object?, Object?>`, so casting the payload to
  /// any typed list of typed maps compiles, passes review, and throws a
  /// TypeError on a real device. offlineSafeVoices already handles both and
  /// spells that trap out in full; do not "help" it on the way in.
  @override
  Future<List<Voice>> voices() async {
    final Object? raw = await _tts.getVoices;
    return offlineSafeVoices(raw);
  }

  /// Best-effort. Call after the first frame, from addPostFrameCallback, and
  /// never await it on the pre-first-frame path: the engine binding runs binder
  /// IPC and voice deserialization synchronously on the main thread inside
  /// OnInitListener, which is an ANR on cold start. The grid must already be
  /// visible and tappable while this cost is paid.
  ///
  /// Warm-up fails SILENTLY; speak() fails LOUDLY. Two opposite error policies
  /// on one service, deliberately: nothing about a failed warm-up is actionable
  /// by the user, and the consequences are surfaced audibly later by the
  /// stored-voice re-resolve and by speak() itself. Do not consistency-fix this
  /// into returning an outcome, and do not make speak() quiet to match it.
  Future<void> warmUp() async {
    try {
      // getVoices is what forces the engine to bind. Its result is discarded on
      // purpose: voices() is the call that asks the question for real.
      await _tts.getVoices;
    } on Exception {
      // INTENTIONAL. A warm-up that fails costs a slower first tap, nothing
      // more — the paths that matter re-ask and report loudly.
    }
  }
}
