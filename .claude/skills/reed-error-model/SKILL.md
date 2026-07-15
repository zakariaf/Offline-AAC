---
name: reed-error-model
description: Reed's error model — throw vs assert vs sealed outcome, SpeakOutcome/SpeakFailure variants, exhaustive switches, FlutterError.onError and PlatformDispatcher.instance.onError, CrashLog.record redaction, no runZonedGuarded. Use when writing a function that can fail, adding a SpeakFailure variant, writing try/catch or rethrow, reviewing a wildcard `case _` on a sealed type, or editing main()'s error handlers. Not for auditing a diff for swallowed errors, not for the flutter_tts implementation behind the seam, and not for the user-facing wording of an error message.
---

# Reed's error model

Reed is an offline AAC app: someone mid-shutdown taps a tile and must get words. A silent failure is the worst possible outcome and it is the *default* behaviour of an unhandled error path. Nobody will ever tell you it happened — there is no telemetry, and a user who cannot speak does not file bug reports. The type system and the test suite are the entire feedback loop.

## 1. Pick the mechanism

| Kind | Means | Use it for |
|---|---|---|
| `Error` subclass | **A bug in this code.** Never catch it | Programmer errors only |
| `assert` | A bug an invariant catches, **debug only** | Grid bounds, non-empty vocalization |
| `Exception` | Something the environment did | drift/SQLite failures |
| **Sealed outcome** | An **expected, individually actionable** failure carrying a payload | `speak()` |

The line that decides it: **`assert` is stripped in release.** `assert(setVoiceResult == 1)` is green in every test and *absent on the device* — the perfect silent-failure bug. Asserts cover ground *this code* owns. Sealed outcomes cover ground the environment owns.

```dart
// RIGHT — a bug we could make.
GridSlot({required this.row, required this.col})
    : assert(row >= 0 && col >= 0, 'negative coordinate is a bug');

// WRONG — the device violates this at runtime, in release, where the assert
// does not exist. Voice availability is a fact, not our bug.
Future<void> speak(String t) async {
  assert(await _tts.setVoice(v) == 1); // vanishes in release. Total silence.
}
```

Never `assert` on a platform return value. Never catch an `Error`. Never `throw e` inside a catch — that resets the stack to the rethrow line, and with no crash reporting the trace in the on-device log is the *entire* forensic record. Use `rethrow`.

## 2. One sealed outcome. No generic `Result<T>`.

Do not adopt Flutter's published generic sealed `Result<T>`. Its error arm is typed `Exception`, so matching it tells you *nothing about which failure* — zero exhaustiveness, which is the entire property wanted here. It also names a variant `Error`, shadowing `dart:core.Error` in every importing file. Carrying both `Result<T>` and `SpeakOutcome` means two error vocabularies for one app. drift throws `SqliteException`; catch that with an `on` clause at the three call sites that read the DB. Everything else is one hand-rolled sealed type, zero dependencies.

`sealed` requires every subtype in the *same library*. That is the point: the file is the closed set and the compiler enforces it.

```dart
// lib/speech/speak_outcome.dart
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

Sealed variants are `final class` + `const` ctor + `final` fields. Do not write `==`/`hashCode` — you switch on the type, you never compare instances. Do not reach for freezed or equatable for these.

The seam:

```dart
// lib/speech/speech_service.dart
abstract interface class SpeechService {
  /// Never throws for an expected failure. Returns a [SpeakFailure] instead.
  ///
  /// `@useResult` is load-bearing: without it, `await speak(text);` discards
  /// the outcome and compiles clean.
  @useResult
  Future<SpeakOutcome> speak(String text);

  Future<void> stop();
  Future<List<Voice>> voices();
}
```

`@useResult` only bites because `unused_result: error` is set — its default severity is a *warning*, a yellow squiggle a solo dev scrolls past.

## 3. The type system detects nothing. Write the detection.

`flutter_tts` calls `result.success(0)` after only a `Log.d` — **it never throws.** The sealed type guarantees a failure *propagates once detected*; detecting it is hand work at the wire.

```dart
final class FlutterTtsSpeechService implements SpeechService {
  static const _ttsSuccess = 1;
  static const _speakTimeout = Duration(seconds: 8);

  @override
  @useResult
  Future<SpeakOutcome> speak(String text) async {
    final voice = _settings.voice;
    if (voice == null) return NoVoiceSelected(text);
    if (voice.notInstalled) return VoiceNotInstalled(text, voiceName: voice.name);

    // THE bug this app exists to prevent. Unchecked, this is a user in crisis
    // tapping a tile and getting silence, with only a Log.d on a device we
    // will never see.
    final set = await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
    if (set != _ttsSuccess) return VoiceUnavailable(text, voiceName: voice.name);

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
}
```

Every catch carries an `on` clause — the crash log below is the sole exception. Never parse a platform-channel payload with a cast — everything crossing a channel is `Map<Object?, Object?>`; use `tryParse` and null checks.

## 4. The call site: exhaustive switch, no `default:`

```dart
// No `default:`. No `case _:`. Ever.
Future<void> _speakAndShow(String vocalization) async {
  final outcome = await _speech.speak(vocalization);
  switch (outcome) {
    case SpokeAloud():
      return;
    // Matching the intermediate sealed type IS exhaustive. Adding a new
    // SpeakFailure variant does not break this switch, which is correct: every
    // failure resolves the same way. The user sees the words.
    case SpeakFailure(:final spokenText, :final logLine):
      _log.record('speak failed: $logLine', StackTrace.current);
      _showText(spokenText);
  }
}
```

Dropping a branch is `non_exhaustive_switch_statement`, reported by `dart analyze` **and** by `dart compile` (`Error: AOT compilation failed`). A `default:` or `case _:` makes the switch compile forever and disables the only compiler-grade safety net here — that is why it is banned. Note `analyzer: errors: non_exhaustive_switch_statement: ignore` silences `dart analyze` while `dart compile` still fails, so CI must actually **build**, not just analyze.

## 5. The lint hole no rule sees, and the structural fix

With `discarded_futures`, `unawaited_futures` **and** `unused_result` all promoted to `error`:

| Code | Diagnostics |
|---|---|
| `onTap: () => s.speak('A')` | **NONE. Zero. All three miss it.** |
| `onTap: () { s.speak('B'); }` | `discarded_futures` + `unused_result` |
| `onTap: () async { s.speak('C'); }` | `unawaited_futures` + `unused_result` |
| `onTap: () => c.speakNow('D')` | clean — the fix |

The arrow closure *returns* the Future, so every rule considers it used; the target type is `VoidCallback`, so Dart's void-compatibility silently discards it — the Future and its error both vanish. This is the most idiomatic way to wire a Flutter tile and it is exactly this app's silence bug.

**The fix is structural, not disciplinary: a callback must never touch a Future.**

```dart
// lib/speech/speech_controller.dart
final class SpeechController {
  /// VOID-RETURNING ON PURPOSE. Do not "improve" this to return a Future.
  ///
  /// `onTap: () => c.speakNow(p)` is safe precisely because there is no Future
  /// to drop. `onTap: () => speech.speak(p)` is caught by NO lint — not
  /// discarded_futures, not unawaited_futures, not @useResult. This method
  /// makes that hole unreachable by construction.
  void speakNow(String vocalization) {
    unawaited(
      _speakAndShow(vocalization).catchError((Object e, StackTrace s) {
        // _speakAndShow should not throw — speak() returns outcomes. Landing
        // here means the crash log or the fallback UI threw. Show the words
        // anyway; that is the product.
        _log.record('speak path threw: $e', s);
        _showText(vocalization);
      }),
    );
  }
}
```

`unawaited` is the explicit, greppable escape hatch: it documents that discarding is intended, and `catchError` guarantees the failure still surfaces. Never call `speak` from `build()` — rebuilds are triggered by things outside your control (a11y flags, voice availability), producing duplicate speech.

## 6. Where errors are caught: two handlers, no zone

```dart
void main() async {
  // Same function body as runApp(): no zone, no zone-mismatch warning.
  WidgetsFlutterBinding.ensureInitialized();
  final log = await CrashLog.open(); // FIRST — a crash before this is invisible

  // Errors inside Flutter's build/layout/paint callbacks.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.record(details.exceptionAsString(), details.stack);
  };

  // Uncaught async errors outside the framework's callbacks.
  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      log.record(error.toString(), stack);
      if (kDebugMode) debugPrint('$error\n$stack'); // our only visibility
    } catch (_) {
      // never let the handler throw
    }
    // ALWAYS true. Returning false routes to the embedder's
    // unhandled_exception_callback, which may make "the VM or the process exit
    // or become unresponsive" — the one behaviour a crisis UI cannot tolerate.
    // debugPrint above gives debug visibility for free, so `return kReleaseMode`
    // buys nothing and costs that risk.
    return true;
  };

  runApp(const AacApp());
}
```

**No `runZonedGuarded`.** The documented fix for the zone-mismatch warning is to *remove zones from the application*, and Flutter's error-handling guidance shows only these two handlers. The "use all three" advice is **crash-SDK advice** — Sentry needs a zone because it wraps its own init. There is no SDK here (Sentry, Crashlytics, Firebase and every analytics package are banned; the privacy promise is the product), so the zone is pure footgun.

`CrashLog.record` is **synchronous and flushed** (`flush: true`), because a buffered write loses exactly the startup crash you need; **size-bounded**, because nothing is watching the disk fill; and **incapable of throwing**:

```dart
void record(String message, StackTrace? stack) {
  try {
    // ... bounded, synchronous, flushed, redacted write ...
  } catch (_) {
    // INTENTIONAL bare catch, INTENTIONALLY discarded.
    //
    // This runs inside FlutterError.onError and PlatformDispatcher.onError.
    // If it throws, the error handler's error re-enters the error handler and
    // recurses until the app dies.
    //
    // Effective Dart says never silently discard from a bare catch. This is the
    // one place in this codebase where that rule is wrong. Do NOT "fix" this by
    // rethrowing or by logging to the same file.
  }
}
```

That comment is load-bearing — without it someone converts this into infinite recursion. This is the **only** licensed bare catch; `empty_catches` and `avoid_catches_without_on_clauses` are errors everywhere else.

Also **unwrap `ProviderException` to its real cause before logging.** Riverpod rethrows provider failures wrapped, and an unwrapped log records the wrapper — every entry reads `ProviderException`, destroying the one diagnostic that exists.

## 7. Redaction: the log is a privacy artifact

The log is **user-exportable** and `record(message, stack)` will happily capture phrase text. A user emailing a log to a maintainer must never leak "I need to leave, I'm not able to talk right now" or whatever they typed. Rules:

- **Never pass `spokenText`, a `Button.vocalization`, a `label`, `display_text`, or type-to-speak field contents to `record`.** Log the variant's `logLine`, which is written to contain only engine facts and voice names. That is why `logLine` exists as a separate member from `spokenText`.
- **Redact inside `record`, not at the call sites.** Call-site discipline fails silently the first time someone interpolates an exception whose `toString()` embeds the phrase (drift statement text, a `PlatformException.message` echoing the utterance). `record` is the single choke point; scrub there and the guarantee holds for handlers you did not write.
- Every `SpeakFailure.logLine` added later must be checked against this: no new variant may interpolate `spokenText`.
- Assert it: a test writes a failure carrying a known phrase and asserts the phrase's characters never appear in the file bytes. Test the logger harder than the tiles — nobody tests their crash logger, and this one is the only line of sight into the field that will ever exist.
