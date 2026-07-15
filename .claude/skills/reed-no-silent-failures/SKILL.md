---
name: reed-no-silent-failures
description: "Reed's no-silent-failure rule — the arrow-callback hole no lint catches (`onTap: () => speak(x)`), void-returning handlers, unawaited() without catchError, empty/bare catches, `throw e` over rethrow, `default:` in a sealed switch. Use when writing or reviewing async code, wiring onTap/VoidCallback on a tile, writing a try/catch, or auditing a diff for swallowed errors. Not for defining a new failure type or its variants, and not for the TTS implementation itself."
---

# No failure may be silent

The most important standard in this codebase. Every rule below exists for one scenario: a user in a shutdown taps a tile, nothing happens, and **nobody will ever tell you**. There is no telemetry, no crash reporting, no server. A user who cannot speak does not file a bug report. The analyzer and the test suite are the entire feedback loop, and one of them has a hole big enough to drive the product through.

## 1. The hole no lint covers

This is verified behaviour, not theory. All four callback shapes probed with `discarded_futures`, `unawaited_futures`, and `@useResult`/`unused_result` **all promoted to `error`**:

| Code | Diagnostics reported |
|---|---|
| `onTap: () => s.speak('A')` | **NONE. Zero. All three miss it.** |
| `onTap: () { s.speak('B'); }` | `discarded_futures` + `unused_result` |
| `onTap: () async { s.speak('C'); }` | `unawaited_futures` + `unused_result` |
| `onTap: () => c.speakNow('D')` | clean — the fix |

The mechanism: the arrow closure **returns** the Future, so every rule considers it used. But the target type is `VoidCallback`, so Dart's void-compatibility silently discards it. **The Future and its error both hit the floor.** This is the single most idiomatic way to wire a Flutter tile, and it is exactly this app's silence bug.

Do not try to solve this with discipline. Solve it with shape.

**A callback must never touch a Future.** Give every user-event handler a void return so there is no Future to drop.

```dart
// lib/speech/speech_controller.dart
final class SpeechController {
  SpeechController(this._speech, this._log, this._showText);
  final SpeechService _speech;
  final CrashLog _log;
  final void Function(String) _showText;

  /// VOID-RETURNING ON PURPOSE. Do not "improve" this to return a Future.
  ///
  /// `onTap: () => c.speakNow(p)` is safe precisely because there is no Future
  /// to drop. VERIFIED: `onTap: () => speech.speak(p)` is caught by NO lint —
  /// not discarded_futures, not unawaited_futures, not @useResult. This method
  /// makes that hole unreachable by construction.
  void speakNow(String vocalization) {
    unawaited(
      _speakAndShow(vocalization).catchError((Object e, StackTrace s) {
        // _speakAndShow should not throw — speak() returns outcomes. If we
        // land here, the crash log or the fallback UI threw. Show the words
        // anyway; that is the product.
        _log.record('speak path threw: $e', s);
        _showText(vocalization);
      }),
    );
  }

  Future<void> _speakAndShow(String vocalization) async { /* see below */ }
}
```

`unawaited` is the explicit, greppable escape hatch: it says discarding is intended, and the attached `catchError` guarantees the failure still surfaces. `unawaited(f)` **without** a `catchError` on an async path that can fail is not a fix — it is the same silence with a permission slip.

The comment on `speakNow` is load-bearing. Without it, the next reader "cleans up" the void return into `Future<void>` and reopens the hole. Keep it.

## 2. Expected failures are values, not exceptions

`speak()` never throws for an expected failure. It returns a sealed outcome whose every failure arm carries the text that was supposed to be spoken, so the caller can **always** fall back to putting the words on screen.

```dart
@immutable
sealed class SpeakOutcome { const SpeakOutcome(); }

final class SpokeAloud extends SpeakOutcome { const SpokeAloud(); }

/// The phrase was NOT spoken. The caller MUST show [spokenText] instead.
@immutable
sealed class SpeakFailure extends SpeakOutcome {
  const SpeakFailure(this.spokenText);
  final String spokenText;      // the on-screen fallback
  String get logLine;           // one line for the on-device log, never shown
}
```

Variants: `NoVoiceSelected`, `VoiceUnavailable` (setVoice ≠ 1), `VoiceNotInstalled`, `EngineRejected` (bad code), `EngineTimedOut`. `sealed` requires every subtype in **the same library** — that file is the closed set and the compiler enforces it.

Mark the seam method `@useResult`. It is load-bearing: without it, `await speak(text);` discards the outcome and compiles perfectly clean.

```dart
abstract interface class SpeechService {
  /// Never throws for an expected failure. Returns a [SpeakFailure] instead.
  @useResult
  Future<SpeakOutcome> speak(String text);
}
```

Do not introduce a generic `Result<T>`. Its error arm is typed `Exception`, which tells the caller nothing about *which* failure — destroying the exhaustiveness that is the entire point — and it names a variant `Error`, shadowing `dart:core.Error` in every importing file.

## 3. The type system detects nothing. Write the detection.

`flutter_tts` calls `result.success(0)` after only a `Log.d`. **It never throws.** A sealed outcome only guarantees a failure propagates *once detected*. Check every platform return code by hand.

```dart
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
```

**Never `assert` a platform return value.** Asserts are stripped in release: `assert(await _tts.setVoice(v) == 1)` is green in every test and *absent on the user's device* — the perfect silent-failure bug.

```dart
// WRONG — vanishes in release. Total silence.
Future<void> speak(String t) async {
  assert(await _tts.setVoice(v) == 1);
}
```

Asserts cover `Error` ground (bugs we could make: negative grid coordinates, empty vocalization). Sealed outcomes cover `Exception` ground (things the device did). Never catch an `Error` subclass — it means a bug in our code.

Note the ceiling: `setVoice` returns **1 (success)** for a voice flagged `notInstalled`, and synthesis then reports `ERROR_NOT_INSTALLED_YET` *or silently substitutes a different voice*. Checking the return value alone does not catch it — hence the explicit `notInstalled` guard before the call.

## 4. The call site: no `default:`, no `case _:`, ever

```dart
Future<void> _speakAndShow(String vocalization) async {
  final outcome = await _speech.speak(vocalization);
  switch (outcome) {
    case SpokeAloud():
      return;
    // Matching the intermediate sealed type IS exhaustive. Adding a new
    // SpeakFailure variant does not break this switch, which is correct:
    // every failure resolves the same way. The user sees the words.
    case SpeakFailure(:final spokenText, :final logLine):
      _log.record('speak failed: $logLine', StackTrace.current);
      _showText(spokenText);
  }
}
```

A `default:` makes any switch compile, disabling the only compiler-grade net available. A dropped branch is `non_exhaustive_switch_statement`, reported by `dart analyze` **and** `dart compile` (`Error: AOT compilation failed`). Setting `non_exhaustive_switch_statement: ignore` silences the analyzer but the compile still fails — so CI must actually **build**, not just analyze.

## 5. The rule table

| Hazard | Rule | Enforcement |
|---|---|---|
| Dropped Future in an async body | `await` or `unawaited(...)` | `unawaited_futures: error` |
| Future-returning call in a sync body | Same | `discarded_futures: error` |
| **Future in an arrow callback** | **Handler returns void** | **Nothing. Structural only.** |
| Discarded outcome (`await speak(x);`) | `@useResult` on the method | `unused_result: error` — default is only a *warning* |
| New failure variant nobody handles | sealed + no `default:` | **compile error** |
| Swallowed exception | `on` clause on every catch but the crash log | `avoid_catches_without_on_clauses`, `empty_catches: error` |
| Leaked StreamController | close it in `dispose()` | `close_sinks` — must be enabled under `linter: rules:`, not just `errors:` |
| Untyped platform-channel payload | `tryParse`, never cast | `avoid_dynamic_calls: error` |
| Lost stack trace | `rethrow`, never `throw e` | review only |

`throw e` resets the stack to the rethrow line. With no crash reporting, the trace in the on-device log is the *entire* forensic record.

`analyzer: errors:` only re-ranks diagnostics that are already generated — it cannot enable a lint that is off. Verified: with `errors: close_sinks: error` alone and no `linter: rules:` entry, a never-closed `StreamController` produced **no diagnostic at all**.

## 6. Catches

Three shapes are banned outright:

```dart
// WRONG — empty catch. The failure is now unrecoverable and unknowable.
try { await _repo.saveTile(t); } catch (_) {}

// WRONG — bare catch, no `on` clause. Swallows Errors (our own bugs) too.
try { await _repo.saveTile(t); } catch (e) { _log.record('$e', null); }

// WRONG — caught, logged nowhere, execution continues as if it worked.
try { await _repo.saveTile(t); } on SqliteException { /* oh well */ }

// RIGHT — typed, logged with its trace, and the user learns the truth.
try {
  await _repo.saveTile(t);
} on SqliteException catch (e, s) {
  _log.record('saveTile failed: $e', s);
  _showError('That phrase was not saved.');
}
```

drift throws `SqliteException`; catch it at the few call sites that read or write the DB, not in a blanket handler. A caught-and-swallowed write means a user believes their board was edited when it was not — and boards are hand-curated over months with no server backup.

## 7. The one licensed silent catch

Exactly one place in this codebase may bare-catch and discard: the crash log's own write.

```dart
void record(String message, StackTrace? stack) {
  try {
    // ... bounded, synchronous, flushed write ...
  } catch (_) {
    // INTENTIONAL bare catch, INTENTIONALLY discarded.
    //
    // This runs inside FlutterError.onError and PlatformDispatcher.onError.
    // If it throws, the error handler's error re-enters the error handler and
    // recurses until the app dies.
    //
    // Effective Dart says never silently discard from a bare catch. This is
    // the one place in this codebase where that rule is wrong. Do NOT "fix"
    // this by rethrowing or by logging to the same file.
  }
}
```

The comment is the whole safeguard. Without it someone converts this into infinite recursion.

The same reasoning governs the global handlers. `PlatformDispatcher.instance.onError` must **always return true**: returning false routes to the embedder's unhandled-exception callback, where "the VM or the process may exit or become unresponsive" — the one behaviour a crisis UI cannot tolerate. Use `if (kDebugMode) debugPrint(...)` inside it for local visibility; that makes `return kReleaseMode` buy nothing and cost that risk.

## 8. Reviewing a diff

Scan for these, in order of how much silence they buy:

1. `=>` inside `onTap:`, `onPressed:`, `onSubmitted:`, or any `VoidCallback` slot where the right-hand side is async. No lint will tell you. Route it through a void handler.
2. `await someMethod();` where the return value is dropped — check the method is `@useResult`.
3. `catch` with no `on`, an empty body, or a body that logs and then continues down the success path.
4. `throw e;` inside a catch. Make it `rethrow`.
5. `assert(` wrapping anything that came back from a platform channel or plugin.
6. `default:` or `case _:` in a switch over a sealed type.
7. `unawaited(` with no `catchError` attached.

A green analyzer is not proof that a tile speaks. It cannot see the arrow-callback hole, an engine that reports success while emitting no audio, or an audio session that lets the hardware silent switch mute the app. Those are caught by building and tapping, not by lints.
