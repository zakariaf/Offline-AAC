// See the note in speak_outcome.dart: `meta` is transitive via the Flutter SDK
// and pubspec.yaml is not this file's to edit, but `@useResult` exists nowhere
// else — `package:flutter/foundation.dart` re-exports `@immutable` and not
// `@useResult` — and it is the annotation that makes a discarded outcome
// visible to the analyzer instead of compiling clean.
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:offline_aac/model/speak_outcome.dart';

/// Android's feature flag for a voice whose data has not finished downloading.
///
/// Lives beside [Voice] rather than beside the parser because [Voice.notInstalled]
/// needs it, and a voice must be able to answer that question without the
/// filter being in scope.
const String kFeatureNotInstalled = 'notInstalled';

/// A TTS voice the engine offered us.
///
/// Constructed only by the voice filter, from an untyped platform-channel
/// payload. Nothing here is trusted; every field was parsed defensively.
@immutable
final class Voice {
  const Voice({
    required this.name,
    required this.locale,
    required this.networkRequired,
    required this.features,
  });

  /// The engine's id for this voice. What `setVoice` is keyed on.
  final String name;

  /// e.g. `en-US`.
  final String locale;

  /// True when synthesis needs the network. Reed has no INTERNET permission,
  /// so such a voice can only ever produce silence.
  final bool networkRequired;

  /// The raw feature flags, already split off the wire.
  final Set<String> features;

  /// The voice data is still downloading, or was garbage-collected.
  ///
  /// `setVoice` returns 1 (success) for these, so a caller that only checks
  /// return codes cannot see this. Check the flag.
  bool get notInstalled => features.contains(kFeatureNotInstalled);
}

/// The one seam in `data/` that cannot run in `flutter test`.
///
/// `abstract interface class`, not `abstract class`: it says "implement me,
/// don't extend me", which is exactly the contract a fake needs — nobody can
/// inherit a partial default and end up quietly calling the real engine.
///
/// It earns its existence for exactly two reasons, and this is not precedent
/// for a third:
///
/// 1. It cannot execute in a test. Everything else in `data/` can, and
///    everything else in `data/` is therefore concrete.
/// 2. The TTS plugin behind it is effectively single-maintainer and MIT. Only
///    four of its methods are ever used through this seam — `speak`, `stop`,
///    `getVoices`, `setVoice` — which makes vendoring it a one-file change on
///    the day that matters. Keep the surface that small.
abstract interface class SpeechService {
  /// Never throws for an expected failure. Returns a [SpeakFailure] instead.
  ///
  /// Barge-in is the caller's policy: a re-tap means "say it again" / "I need
  /// this NOW", and it must never be swallowed. Stop any in-flight utterance
  /// before calling this; never drop the second tap on the floor.
  ///
  /// `@useResult` is load-bearing: without it, `await speak(text);` discards
  /// the outcome and compiles clean, and the user gets nothing while every
  /// check upstream stays green.
  @useResult
  Future<SpeakOutcome> speak(String text);

  Future<void> stop();

  /// Already filtered: network_required and notInstalled voices never appear.
  Future<List<Voice>> voices();

  /// Audition [voice] at [pitch]/[rate] by speaking [text] — the voice picker's
  /// preview. Goes through the SAME setVoice / notInstalled / timeout machinery
  /// as [speak], so a voice that reports success and produces nothing is caught
  /// here, at selection time, rather than at the next shutdown. It does NOT
  /// persist the voice as current — the caller commits it on a [SpokeAloud].
  /// Barge-in is the caller's policy, exactly as with [speak].
  @useResult
  Future<SpeakOutcome> preview(
    String text, {
    required Voice voice,
    required double pitch,
    required double rate,
  });
}

/// The pitch range the synthesizer accepts. `1.0` is the natural pitch.
///
/// These bounds live here, beside the thing that consumes them, so no other
/// file invents its own range. Settings clamps a stored pitch to this window
/// rather than trusting a value read off disk — a corrupt or future-version
/// value must land somewhere sane, never at a pitch the engine will reject or a
/// speed no one can follow.
const double kMinPitch = 0.5;
const double kMaxPitch = 2;
const double kDefaultPitch = 1;

/// The speech-rate range, as a plain multiplier: `1.0` is normal speed, `2.0`
/// double, `0.25` a quarter. This is the human-facing model the slider speaks in;
/// [ttsSpeechRate] converts it to what the engine expects.
const double kMinRate = 0.25;
const double kMaxRate = 2;
const double kDefaultRate = 1;

/// Convert Reed's rate multiplier to the value `flutter_tts` expects.
///
/// `flutter_tts` normalises speech rate so that **0.5 is normal on every
/// platform**: its Android code multiplies the value by 2 before handing it to
/// `TextToSpeech.setSpeechRate` (whose own 1.0 is normal), and its iOS side maps
/// 0.5 to `AVSpeechUtteranceDefaultSpeechRate`. Reed's [kDefaultRate] of 1.0 is a
/// multiplier where 1.0 is normal, so it must be HALVED on the way to the engine
/// or every utterance plays at double speed — the reason a voice preview at the
/// default rate was too fast to follow. Reed 1.0 -> engine 0.5 -> normal;
/// Reed 2.0 -> engine 1.0 -> double; Reed 0.25 -> engine 0.125 -> quarter.
double ttsSpeechRate(double reedRate) => reedRate / 2;

/// What a tile tap produces.
///
/// The member set is owned here because output is a speech concept. `speak`
/// synthesises aloud; show puts the words on the poster; both does each.
/// Settings persists these by their `name`, and parses by name, never index.
enum OutputMode { speak, show, both }
