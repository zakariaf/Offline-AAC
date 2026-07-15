# E04-T01 — SpeechService interface and the sealed outcome

| | |
|---|---|
| **Epic** | E04 — Speech |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E01-T01 |
| **Blocks** | E04-T02 |

**Skills:** `reed-speech-service` · `reed-error-model` · `reed-dart3-idioms` · `reed-layering-rules`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A user mid-shutdown taps a tile. Either words come out of the speaker, or the words go on the screen. There is no third outcome, and nobody will ever tell us there was — there is no telemetry and a person who cannot speak does not file a bug report. This task builds the type that makes "show the words instead" a **total function** of the failure: every failure variant carries the text that was to be spoken, so no caller can be handed a failure it has no way to recover from. Everything else in E04 hangs off this file; get the variant set wrong here and the compiler stops being able to help.

## Scope

Three files, no plugin import, no platform code. This task defines the closed set and the seam. It does **not** implement either.

### 1. `lib/data/speech/speak_outcome.dart` — the sealed hierarchy

Hand-written. `sealed` requires every subtype in the same library — that is the point: **the file is the closed set and the compiler enforces it.** No `freezed`, no `equatable`, no generic `Result<T>`, no `Either`.

```dart
import 'package:meta/meta.dart';

/// The result of attempting to vocalize a phrase.
///
/// Every failure variant carries [SpeakFailure.spokenText] so the caller can
/// ALWAYS fall back to showing the phrase on screen. A user who taps a tile
/// must never get nothing. That is the whole product.
@immutable
sealed class SpeakOutcome {
  const SpeakOutcome();
}

/// The engine reported that it finished speaking the phrase aloud.
final class SpokeAloud extends SpeakOutcome {
  const SpokeAloud();
}

/// The phrase was NOT spoken. The caller MUST show [spokenText] instead.
@immutable
sealed class SpeakFailure extends SpeakOutcome {
  const SpeakFailure(this.spokenText);

  /// The text that was supposed to be spoken. The on-screen fallback.
  final String spokenText;

  /// One line for the on-device crash log. Never shown to the user.
  String get logLine;
}
```

The five failure variants, exactly these, with exactly these payloads and `logLine` strings:

```dart
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
```

**`VoiceNotInstalled` is the variant that looks redundant and is not.** Android returns **1 (success)** from `setVoice` for a voice carrying the `notInstalled` feature flag, and synthesis then either reports `ERROR_NOT_INSTALLED_YET` or silently substitutes a different voice. The `setVoice == 1` check cannot see it. Drop this variant and the exhaustive switch still compiles green while never handling the case — a silent failure hiding inside the mechanism built to make silent failures impossible. If a reviewer proposes folding it into `VoiceUnavailable`, the answer is the return code: 1, not 0. The doc comment above must stay on the class; it is the whole defence.

Shape rules, all from the skills:

- Variants are `final class` + `const` constructor + `final` fields. No `==`, no `hashCode` — you switch on the type, you never compare instances.
- `SpeakFailure` is an **intermediate sealed type** and that is deliberate: `case SpeakFailure(:final spokenText, :final logLine)` is exhaustive on its own, so adding a sixth failure variant later does not break call sites that resolve every failure identically. That is correct here — every failure ends at the words on screen.
- `logLine` must contain **only engine facts and voice names**. It must never interpolate `spokenText`. The crash log is user-exportable; that is the entire reason `logLine` exists as a member separate from `spokenText`.

### 2. `lib/data/speech/voice.dart` — the value type the interface returns

`voices()` returns `List<Voice>`, so `Voice` must exist for the seam to compile. Minimal, hand-written, `@immutable` + `const` ctor + `final` fields:

- `String name`, `String locale`, `bool networkRequired`, `Set<String> features`
- `bool get notInstalled => features.contains(kFeatureNotInstalled);` where `const String kFeatureNotInstalled = 'notInstalled';`

`Voice` is a Map key nowhere and is compared in tests by field, so hand-write `==` + `Object.hash(...)` only if a test actually needs it — not preemptively, and never via `equatable`.

### 3. `lib/data/speech/speech_service.dart` — the seam

```dart
abstract interface class SpeechService {
  /// Never throws for an expected failure. Returns a [SpeakFailure] instead.
  ///
  /// Barge-in: stops any in-flight utterance first. A re-tap means "say it
  /// again" / "I need this NOW" — never swallow it.
  ///
  /// `@useResult` is load-bearing: without it, `await speak(text);` discards
  /// the outcome and compiles clean.
  @useResult
  Future<SpeakOutcome> speak(String text);

  Future<void> stop();

  /// Already filtered: network_required and notInstalled voices never appear.
  Future<List<Voice>> voices();
}
```

`abstract interface class`, not `abstract class` — it says "implement me, don't extend me", which is exactly the contract the fake needs, and it prevents a fake inheriting a partial default that quietly calls the real engine.

This interface earns its existence for **exactly two reasons**; do not add a third and do not use it as precedent:

1. It cannot run in `flutter test`. Everything else in `data/` can.
2. `flutter_tts` is effectively single-maintainer and MIT — this interface makes vendoring a one-file change.

Only four plugin methods are ever used behind it — `speak`, `stop`, `getVoices`, `setVoice` — plus the iOS audio category. Keep the surface at three methods. Do not add `warmUp` to the interface in this task; E04-T02 decides where it lives.

### Out of scope

- `FlutterTtsSpeechService` (E04-T02) — no `package:flutter_tts` import may appear in any file this task creates.
- `voice_filter.dart` and the wire-format parsing (`network_required` as the string `'1'`/`'0'`, tab-separated `features`, `getVoices` returning null).
- `SpeechController` / `speakNow` and the call-site switch (E04-T03).
- The fake, `SpeechEnv`, the audio session, the manifest `TTS_SERVICE` query.
- Any `assert` on a platform return code — banned outright; `assert` is stripped in release, so it is green in every test and absent on the device.

## Acceptance criteria

- [ ] `dart analyze` is clean with zero diagnostics on the three new files.
- [ ] `unused_result: error` is active in `analysis_options.yaml`, and a scratch file containing `await service.speak('x');` (result discarded) fails analysis with `unused_result`. Delete the scratch after confirming. Without the promotion, `@useResult` is a yellow squiggle a solo dev scrolls past.
- [ ] A test asserts every `SpeakFailure` variant exposes the `spokenText` it was constructed with: construct all five with `'I need a minute'` and assert `f.spokenText == 'I need a minute'` for each.
- [ ] A test asserts **no** variant leaks the phrase into the log: construct all five with a distinctive phrase and assert `logLine` does not contain it. This is the redaction guarantee that lets `CrashLog.record` be exported by a user.
- [ ] A test proves the intermediate sealed type resolves every failure uniformly: a helper `String fallbackFor(SpeakOutcome o)` written as a switch with `case SpokeAloud()` and `case SpeakFailure(:final spokenText)` — **no `default:`, no `case _:`** — returns the phrase for all five failures.
- [ ] `grep -rn "default:\|case _:" lib/data/speech/` returns nothing.
- [ ] `grep -rn "flutter_tts" lib/data/speech/speak_outcome.dart lib/data/speech/speech_service.dart lib/data/speech/voice.dart` returns nothing.
- [ ] `VoiceNotInstalled` exists as its own variant, distinct from `VoiceUnavailable`, and its doc comment states that `setVoice` returns 1 for it.
- [ ] `flutter test` passes, and the project **builds** (`flutter build apk --debug`) — not just analyzes. `non_exhaustive_switch_statement` can be silenced in `analysis_options.yaml` while `dart compile` still fails, so the build is the real check.

## Traps

- **Folding `VoiceNotInstalled` into `VoiceUnavailable`.** It reads as duplication: two variants, both about a bad voice. It is not. `VoiceUnavailable` is `setVoice != 1`; `VoiceNotInstalled` is `setVoice == 1` and silence anyway. Merge them and the exhaustive switch compiles green forever while the case is never detected — the failure mode the sealed type exists to make impossible, hiding inside the sealed type.
- **A variant that carries no `spokenText`.** Someone adds `EngineBusy()` with no payload because "the caller knows the text". The caller does not — `speakNow` may be several frames away and the phrase is resolved at tap time from `(row, col)`. A variant that says only "it broke" buys nothing over a `bool`, and it breaks the totality of the fallback.
- **Interpolating `spokenText` into `logLine`.** `'failed to speak "$spokenText"'` looks like the most useful log line in the file. The crash log is user-exportable; that line emails "I'm not able to talk right now" to a maintainer. Every new variant's `logLine` must be checked against this rule.
- **`Result<T>` creeping in.** Flutter's published generic sealed `Result<T>` types its error arm as `Exception`, so matching it tells you nothing about which failure occurred — zero exhaustiveness, which is the entire property being bought. It also names a variant `Error`, shadowing `dart:core.Error` in every importing file. One hand-rolled sealed type, zero dependencies.
- **Adding `@useResult` and stopping there.** Default severity is a *warning*. Without `unused_result: error` in `analysis_options.yaml` and CI blocking on it, a discarded outcome ships.
- **`abstract class` instead of `abstract interface class`.** Bare `abstract class` permits `extends`, and an inherited default on a service interface is how a fake ends up quietly calling the real engine.
- **Writing `==`/`hashCode` or reaching for `freezed`/`equatable` on the variants.** Nothing compares outcome instances; you switch on the type. drift's generator already exists in this repo — a second generator on hand-written sealed types buys nothing.
- **`if (outcome case SpeakFailure(...))` instead of a switch.** An if-case on a sealed type silently reintroduces exactly the non-exhaustive hole the switch would catch.
- **Believing the type system detects anything.** It does not. It guarantees a failure *propagates once detected*. `flutter_tts` calls `result.success(0)` after only a `Log.d` — it never throws. Detection is hand work at the wire, in E04-T02. Do not let the elegance of this file lower the paranoia in that one.
- **Placing these files under `lib/speech/`.** The data layer is `lib/data/speech/`, organised by type, two directory levels maximum. Use `package:` imports throughout — never relative.

## Files

Creates:
- `lib/data/speech/speak_outcome.dart`
- `lib/data/speech/voice.dart`
- `lib/data/speech/speech_service.dart`
- `test/data/speech/speak_outcome_test.dart`

Changes:
- `analysis_options.yaml` — only if `unused_result: error` is not already promoted.

## Done when

The five failure variants exist in one sealed file, `dart analyze` and `flutter test` are green, the build compiles, and a switch over `SpeakOutcome` with no `default:` can produce the on-screen fallback text for every possible failure.
