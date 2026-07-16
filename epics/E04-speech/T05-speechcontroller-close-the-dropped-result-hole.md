# E04-T05 — SpeechController: close the dropped-result hole

| | |
|---|---|
| **Epic** | E04 — Speech |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E04-T03 |
| **Blocks** | E04-T06, E05-T04 |

**Skills:** `reed-no-silent-failures` · `reed-riverpod-usage` · `reed-error-model` · `reed-async-rules`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

`onTap: () => speech.speak(phrase)` is the most idiomatic way to wire a tile in Flutter, and it is this app's silence bug. Verified on this toolchain with `discarded_futures`, `unawaited_futures` **and** `unused_result` all promoted to `error`: that line produces **zero diagnostics**. The arrow closure *returns* the Future so every rule considers it used, but the target type is `VoidCallback`, so Dart's void-compatibility discards it — the Future and its error both hit the floor. A user in a shutdown taps a tile, gets nothing, and nobody will ever tell you. This task builds the one object that makes that hole unreachable by construction instead of forbidden by memory: a rule you have to remember is a rule that fails at 2am.

## Scope

Build `SpeechController` in `lib/speech/speech_controller.dart`. It sits between a `VoidCallback` and `SpeechService.speak`, and it is the **only** thing in the app allowed to hold the speak Future.

Three properties, all load-bearing:

1. **The public method returns `void`.** Not `Future<void>`. A callback then has no Future to drop.
2. **It consumes its own outcome.** `speak()` returns a sealed `SpeakOutcome` (E04-T03); the controller switches over it exhaustively and resolves every failure the same way — the user sees the words.
3. **It never takes a `BuildContext`.** It takes `void Function(String) _showText`. A plain controller has no `mounted` and no `ref`, so it must never be in a position to hold a context across an await gap.

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

  // No `default:`. No `case _:`. Ever.
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
}
```

The doc comments above are not decoration. They are the safeguard against the next reader "cleaning up" the `void` into `Future<void>` and reopening the hole. Copy them in.

Also in scope:

- **Barge-in.** A re-tap means "say it again": `stop()` then `speak()`. Never `if (_running) return;` and never a `Command` pattern — swallowing a tap *is* the silence bug.
- **Redaction discipline.** Pass `logLine` to `_log.record`, never `spokenText` and never the raw vocalization on the failure path. `logLine` is written to carry engine facts and voice names only; the crash log is user-exportable.
- **Provider wiring** in `lib/providers.dart`, plain and hand-written, reading `speechServiceProvider`. No `family`, no `@riverpod` codegen, no `StateProvider`. If it is easier as a constructor argument, make it a constructor argument — provider count going up is a smell, not progress.

**Out of scope:** the `flutter_tts` implementation behind the seam and its return-code checks (E04-T03); `warmUp()`; the lit-state latch and its 120ms minimum hold; `CrashLog` internals and the redaction implementation; the type-to-speak field and tile widgets (E05-T04 consumes this).

## Acceptance criteria

- [ ] `lib/speech/speech_controller.dart` exists; `speakNow` is declared `void` and `grep -n 'Future<void> speakNow' lib/` returns nothing.
- [ ] `grep -rn 'BuildContext' lib/speech/speech_controller.dart` returns nothing.
- [ ] `dart analyze` is clean, and `flutter build apk --debug` succeeds — the switch's exhaustiveness is only enforced at compile time; `non_exhaustive_switch_statement: ignore` would silence the analyzer while the AOT build still fails, so CI must build, not just analyze.
- [ ] `grep -n 'default:\|case _' lib/speech/speech_controller.dart` returns nothing.
- [ ] Every `unawaited(` in the file has a `.catchError(` attached to the Future passed in.
- [ ] Test: fake `SpeechService` returns `NoVoiceSelected('I need a minute')`; after `speakNow`, the captured `_showText` calls contain exactly `'I need a minute'`.
- [ ] Test: fake returns `VoiceUnavailable`, `VoiceNotInstalled`, `EngineRejected`, `EngineTimedOut` — each one reaches `_showText` with its `spokenText`, one case per variant.
- [ ] Test: fake returns `SpokeAloud()` — `_showText` is never called.
- [ ] Test: `_showText` itself throws — `speakNow` does not throw out of the callback, and `_log.record` receives a line starting `speak path threw:`.
- [ ] Test: a fake `CrashLog` records nothing containing the characters of the phrase passed in — assert `spokenText` never appears in any recorded line.
- [ ] Test: two `speakNow` calls in a row both reach `speak()`. No de-duplication, no swallowed second tap.
- [ ] Tests use `ProviderContainer.test()` if a container is needed (it self-disposes — no `createContainer` helper, no `addTearDown(container.dispose)`), with `speechServiceProvider.overrideWithValue(fake)`. Note the method is `overrideWithValue`; `overrideValue` does not exist.

## Traps

- **Making `speakNow` return `Future<void>` "for testability".** This is the exact regression this file exists to prevent, and it will look like an improvement in review. Await the private `_speakAndShow` in tests, or have the fake `SpeechService` expose a completer — do not change the public signature.
- **`unawaited(_speakAndShow(phrase));` with no `catchError`.** It silences `unawaited_futures` and keeps the bug: the error routes to `PlatformDispatcher.onError`, technically logged, detached from the UI, and the user still gets nothing. `unawaited` without an error path is a lie that reads as a decision.
- **`case _:` or `default:` added to make the switch compile.** It disables the only compiler-grade net in the codebase — the thing that makes a new `SpeakFailure` variant impossible to forget.
- **Switching on each concrete failure variant instead of the intermediate `SpeakFailure`.** Matching `SpeakFailure` is already exhaustive and is correct here: every failure resolves the same way.
- **Passing `spokenText` (or the raw vocalization) to `_log.record` "for context".** The log is user-exportable. That leaks "I'm not able to talk right now" into a file someone emails a maintainer. `logLine` exists as a separate member from `spokenText` for exactly this reason.
- **`throw e` inside the `catchError`.** It resets the stack to that line. With no crash reporting, the trace in the on-device log is the entire forensic record. Use `rethrow` if you must re-raise at all.
- **Giving the controller a `BuildContext` so it can show a SnackBar.** It has no `State`, so no `mounted`, so no legal way to check the element is alive after the await. `_showText` is a captured callback for this reason.
- **Adding `if (_speaking) return;` to stop "double speech".** Barge-in is the policy. A re-tap means say it again.
- **Calling `speakNow` from `build()`.** Rebuilds fire for things outside your control — bold text, high contrast, voice availability — and each one speaks again.
- **Capturing a `ref.watch(gridProvider)` tile in `build()` and closing over its `vocalization`.** A fast re-tap then speaks the previous tile's sentence out loud to a stranger, on behalf of someone who cannot verbally correct it. Pass coordinates, resolve at tap time with `ref.read`. (That belongs to the caller in E05-T04 — but the controller's API is what makes it possible or not.)
- **A green analyzer read as proof.** It cannot see the arrow-callback hole. The only evidence this works is the tests above plus building and tapping.

## Files

- `lib/speech/speech_controller.dart` — new.
- `lib/providers.dart` — add the controller's provider (or justify out loud that a constructor argument is enough).
- `test/speech/speech_controller_test.dart` — new.
- `test/support/` — a fake `SpeechService` returning a scripted `SpeakOutcome`, and a recording fake `CrashLog`, if E04-T03 did not already land them.

## Done when

A tile can be wired with `onTap: () => controller.speakNow(phrase)`, every `SpeakFailure` variant puts the words on screen instead of producing silence, and no callback in the codebase holds a Future.


---

## What actually happened

Extracted the speak path into a widget-free lib/speech/speech_controller.dart: void speakNow, no widget context, exhaustive outcome switch with no default, unawaited+catchError, barge-in before every speak. board_controller now delegates to it, keeping only the lit latch. A throwing showText is caught and logged, never escapes; no phrase reaches the log. test/speech/speech_controller_test.dart.
