import 'dart:async';

import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/speak_outcome.dart';

/// Every way the world breaks for the speak path, as a value.
///
/// The interesting risk in this app is *state* — "what happens when the stored
/// voice vanished, or `setVoice` returned 0" — not "was a method called". A
/// field models state directly; a mock would need `when` plus side-effect
/// gymnastics. And this enum is the contract's documentation: whoever inherits
/// the repo reads it to learn every way speech can fail a user.
enum SpeechEnv {
  /// No text-to-speech engine on the device at all. `voices()` is empty.
  noEngineInstalled,

  /// An engine, but it offers nothing. `voices()` is empty.
  zeroVoices,

  /// Every voice needs the network. The filter has already dropped them by the
  /// time voices reach the service, so this presents as no usable voice.
  onlyNetworkVoices,

  /// Every voice is still downloading. Same: filtered out, so no usable voice.
  onlyNotInstalledVoices,

  /// Voice selection returns 0. Nothing in the type system detects this; it is
  /// a hand-written `== 1` check at the wire.
  setVoiceReturnsZero,

  /// The stored voice was present last launch and has since been garbage
  /// collected — the most probable real-world silent failure.
  storedVoiceUninstalled,

  /// The engine rejects the utterance: `speak` returns a non-success code.
  speakReturnsZero,

  /// The engine call times out — accepted, then never reported.
  engineTimedOut,

  /// The platform channel throws instead of returning a code.
  enginePlatformException,

  /// The engine reports success and emits no sound. The fake believes it spoke,
  /// and it did not.
  ///
  /// This value exists to be EXCLUDED. No automated test can catch it — there
  /// is no hook to capture whether audio actually left the speaker — and that
  /// exclusion is the single line that justifies the manual pre-release device
  /// pass with the ringer switch off. Do not delete it to make [detectable]
  /// tidier; its presence is the honesty.
  reportedSuccessButSilent;

  /// The environments a test can actually detect: everything except the silent
  /// success, which by definition looks identical to a real success.
  static Iterable<SpeechEnv> get detectable =>
      values.where((e) => e != SpeechEnv.reportedSuccessButSilent);
}

/// A hand-written fake, not a mock.
///
/// Bare `implements SpeechService` — no `extends Fake`, no `noSuchMethod` — so
/// adding a method to the interface is a compile error here, not a runtime
/// surprise in one test. [speak] switches on [env] with no `default:`, so a new
/// [SpeechEnv] value cannot be added without deciding what it means.
class FakeSpeechService implements SpeechService {
  FakeSpeechService({
    this.env = SpeechEnv.reportedSuccessButSilent,
    this.warmUpCompletes = true,
    this.hangSpeak = false,
    this.voicesOverride,
  });

  /// The world this fake presents. Mutable so a single test can change it.
  SpeechEnv env;

  /// When set, [voices] returns this exact list instead of the env-derived one.
  /// Lets the voice-picker tests present specific voice NAMES (a long id to
  /// prove the row wraps at 200%) that the env's single 'v' cannot.
  final List<Voice>? voicesOverride;

  /// When true, [speak] records the call and returns a Future that never
  /// completes — an engine that accepts an utterance and never reports it done.
  /// The lit latch's guard timer exists exactly for this; nothing else clears it.
  final bool hangSpeak;

  /// When false, [warmUp] never completes. Lets a test prove the launch path
  /// does not wait on the engine.
  final bool warmUpCompletes;

  /// Every call to [stop] and [speak], in order. The barge-in test asserts this
  /// is exactly `['stop', 'speak', 'stop', 'speak']` across two taps.
  final List<String> calls = [];

  /// Every text passed to [speak], to prove the engine received the sentence,
  /// not the tile's shorter label.
  final List<String> spoken = [];

  int stopCount = 0;
  bool warmUpCalled = false;

  final Completer<void> _warmUp = Completer<void>();

  /// Not part of [SpeechService]; the concrete impl has it and the startup path
  /// warms the engine through it. Kept here so a launch-path test can hold a
  /// warm-up that never resolves.
  Future<void> warmUp() {
    warmUpCalled = true;
    if (warmUpCompletes && !_warmUp.isCompleted) _warmUp.complete();
    return _warmUp.future;
  }

  @override
  Future<SpeakOutcome> speak(String text) async {
    calls.add('speak');
    spoken.add(text);
    if (hangSpeak) return Completer<SpeakOutcome>().future;
    // No `default:`. A new SpeechEnv value is a compile error until this switch
    // decides what the engine does in that world.
    return switch (env) {
      SpeechEnv.noEngineInstalled ||
      SpeechEnv.zeroVoices ||
      SpeechEnv.onlyNetworkVoices ||
      SpeechEnv.onlyNotInstalledVoices => NoVoiceSelected(text),
      SpeechEnv.setVoiceReturnsZero => VoiceUnavailable(text, voiceName: 'v'),
      SpeechEnv.storedVoiceUninstalled => VoiceNotInstalled(
        text,
        voiceName: 'gone',
      ),
      SpeechEnv.speakReturnsZero => EngineRejected(text, code: 0),
      SpeechEnv.engineTimedOut => EngineTimedOut(
        text,
        waited: const Duration(seconds: 8),
      ),
      SpeechEnv.enginePlatformException => EngineRejected(
        text,
        code: 'platform',
      ),
      SpeechEnv.reportedSuccessButSilent => const SpokeAloud(),
    };
  }

  /// The preview shares the speak path: the outcome is env-driven (so
  /// setVoiceReturnsZero yields VoiceUnavailable here too), and it records
  /// 'speak' so the barge-in ordering `['stop', 'speak']` holds for the picker.
  /// The voice/pitch/rate are ignored — the env, not the arguments, decides.
  @override
  Future<SpeakOutcome> preview(
    String text, {
    required Voice voice,
    required double pitch,
    required double rate,
  }) => speak(text);

  @override
  Future<void> stop() async {
    calls.add('stop');
    stopCount++;
  }

  @override
  Future<List<Voice>> voices() async {
    if (voicesOverride != null) return voicesOverride!;
    // The filter has already run by the time voices reach the service, so the
    // network-only and half-downloaded worlds correctly present as "no usable
    // voice" — the state the UI must handle.
    return switch (env) {
      SpeechEnv.noEngineInstalled ||
      SpeechEnv.zeroVoices ||
      SpeechEnv.onlyNetworkVoices ||
      SpeechEnv.onlyNotInstalledVoices ||
      SpeechEnv.storedVoiceUninstalled => const <Voice>[],
      _ => const <Voice>[
        Voice(
          name: 'v',
          locale: 'en-US',
          networkRequired: false,
          features: <String>{},
        ),
      ],
    };
  }
}
