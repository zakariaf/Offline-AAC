// `meta` is a transitive dependency here (the Flutter SDK pins it) rather than a
// direct one, and pubspec.yaml is not this file's to edit. The import stays
// because `package:flutter/foundation.dart` re-exports `@immutable` but NOT
// `@useResult`, and `@useResult` on the seam is the only thing that stops
// `await speak(text);` from discarding the outcome and compiling clean.
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

/// The result of attempting to vocalize a phrase.
///
/// Every failure variant carries [SpeakFailure.spokenText] so the caller can
/// ALWAYS fall back to showing the phrase on screen. A user who taps a tile
/// must never get nothing. That is the whole product.
///
/// `sealed` requires every subtype in the same library, and that is the point:
/// this file IS the closed set and the compiler enforces it. A switch over
/// [SpeakOutcome] that drops a branch is `non_exhaustive_switch_statement` —
/// a compile error, not a lint. It is the only compiler-grade safety net in an
/// app that has no telemetry and no way to learn that it went quiet.
@immutable
sealed class SpeakOutcome {
  const SpeakOutcome();
}

/// The engine reported that it finished speaking the phrase aloud.
final class SpokeAloud extends SpeakOutcome {
  const SpokeAloud();
}

/// The phrase was NOT spoken. The caller MUST show [spokenText] instead.
///
/// The intermediate sealed layer is deliberate. `case SpeakFailure(:final
/// spokenText, :final logLine)` is exhaustive on its own, so adding a sixth
/// variant later does not break call sites that resolve every failure
/// identically — which is correct, because every failure ends the same way:
/// the words go on the screen.
@immutable
sealed class SpeakFailure extends SpeakOutcome {
  const SpeakFailure(this.spokenText);

  /// The text that was supposed to be spoken. The on-screen fallback.
  final String spokenText;

  /// One line for the on-device crash log. Never shown to the user.
  ///
  /// Only engine facts and voice names may appear here. NEVER interpolate
  /// [spokenText] into it: the log is user-exportable, and such a line would
  /// email a stranger the sentence its author could not say out loud.
  /// Keeping this member separate from [spokenText] is the whole reason it
  /// exists, and every variant added later must be checked against this.
  String get logLine;
}

/// Settings hold no voice, or the stored voice id no longer resolves.
/// Android garbage-collects TTS voice data: the single most likely real-world
/// silent failure, and it happens between launches.
final class NoVoiceSelected extends SpeakFailure {
  const NoVoiceSelected(super.spokenText);

  @override
  String get logLine => 'no usable voice selected';
}

/// `setVoice` did not return 1.
final class VoiceUnavailable extends SpeakFailure {
  const VoiceUnavailable(super.spokenText, {required this.voiceName});

  final String voiceName;

  @override
  String get logLine => 'setVoice rejected "$voiceName"';
}

/// The voice carries Android's `notInstalled` feature flag. setVoice returns
/// **1 (success)** for these and synthesis still reports ERROR_NOT_INSTALLED_YET
/// *or silently substitutes a different voice*. Checking setVoice does NOT
/// catch this.
///
/// This variant reads as a duplicate of [VoiceUnavailable] and is not:
/// [VoiceUnavailable] is `setVoice != 1`; this is `setVoice == 1` and silence
/// anyway. Fold the two together and the exhaustive switch compiles green
/// forever while the case is never detected — a silent failure hiding inside
/// the mechanism built to make silent failures impossible.
final class VoiceNotInstalled extends SpeakFailure {
  const VoiceNotInstalled(super.spokenText, {required this.voiceName});

  final String voiceName;

  @override
  String get logLine => 'voice "$voiceName" is flagged notInstalled';
}

/// `speak` returned a non-success code.
final class EngineRejected extends SpeakFailure {
  const EngineRejected(super.spokenText, {required this.code});

  final Object? code;

  @override
  String get logLine => 'engine rejected speak(), code=$code';
}

/// `speak` never completed. The engine is wedged.
final class EngineTimedOut extends SpeakFailure {
  const EngineTimedOut(super.spokenText, {required this.waited});

  final Duration waited;

  @override
  String get logLine => 'engine timed out after ${waited.inMilliseconds}ms';
}
