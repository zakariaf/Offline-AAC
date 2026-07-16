# E09-T03 — The on-device crash log

| | |
|---|---|
| **Epic** | E09 — Portability and the crash log |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E01-T06 |
| **Blocks** | E11-T03 |

**Skills:** `reed-error-model` · `reed-privacy-claims` · `reed-no-silent-failures` · `reed-app-startup`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

There is no telemetry, no crash reporting SDK, no server, and there never will be — the privacy promise is the product. This file is the **only line of sight into the field that will ever exist**. A user who goes non-speaking during a shutdown, taps a tile, gets silence, and closes the app will never file a bug report; the only way anyone ever learns what happened is if that user chooses to send this file. So it has to be there, it has to have flushed, and it has to be safe to send — because the phrases on their board are their voice, and mailing "I need to leave, I'm not able to talk right now" to a stranger is a harm this task either prevents or causes.

## Scope

Build `CrashLog` — the sink for `FlutterError.onError`, `PlatformDispatcher.instance.onError`, the `SpeakFailure` arm of the speak switch, and the `on SqliteException` catches at the DB call sites. On-device only, user-exportable, never transmitted by the app.

**The API is exactly two members.** Nothing else.

```dart
// lib/diagnostics/crash_log.dart
final class CrashLog {
  /// Opens (creating if absent) the log file. Called FIRST in main(), before
  /// anything that can throw. A crash before this is invisible forever.
  static Future<CrashLog> open() async { ... }

  /// Synchronous. Flushed. Bounded. Redacted. Cannot throw.
  void record(String message, StackTrace? stack) { ... }
}
```

**`record` is synchronous and flushed.** Use `File.writeAsStringSync(..., mode: FileMode.append, flush: true)`. Not `writeAsString`, not an `IOSink`, not a buffer drained on a timer, not an isolate. The entry that matters most is the one written microseconds before the process dies — a crash on the very first frame, an unhandled throw during DB open. A buffered write loses exactly that entry and keeps the ones you never needed. `flush: true` is not a tuning knob; it is the feature.

**`record` cannot throw.** It runs *inside* both global error handlers. Wrap the whole body in the one licensed bare catch in this codebase, and keep the comment verbatim in spirit:

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

That comment is load-bearing. `empty_catches` and `avoid_catches_without_on_clauses` are `error` everywhere else in this repo; this is the single exemption and it needs the comment so the next reader does not "clean it up" into infinite recursion.

**`record` redacts, and redaction lives inside `record` — not at the call sites.** Call-site discipline fails silently the first time someone interpolates an exception whose `toString()` embeds the phrase: a drift `SqliteException` carrying the statement text, a `PlatformException.message` echoing the utterance back. `record` is the single choke point. Scrub there and the guarantee holds for handlers you did not write.

Redaction is by construction plus a net:
- The by-construction half already exists in the error model: `SpeakFailure` splits `spokenText` (the on-screen fallback) from `logLine` (engine facts and voice names only). That split exists *for this*. The speak call site logs `logLine`, never `spokenText`.
- The net half is inside `record`: given the set of strings that must never appear (every `Button.vocalization` / `display_text` / label currently in the DB, plus the live type-to-speak field contents), replace any occurrence in `message` and in the rendered stack with a fixed marker such as `[redacted]`. Feed `CrashLog` a redaction source — a `Set<String> Function()` supplied at `open()` or injected after the DB is up — rather than having it reach into the database itself.

Never pass `spokenText`, a `Button.vocalization`, a `label`, `display_text`, or type-to-speak field contents to `record`. Every `SpeakFailure.logLine` added later gets checked against this rule: **no new variant may interpolate `spokenText`.**

**`record` is size-bounded.** Nothing is watching the disk fill on a user's phone. Pick a byte ceiling and enforce it on every write — when the file exceeds it, truncate the oldest entries (read, drop from the front, rewrite) and keep going. Losing the tail is worse than losing the head: the newest entry is the one describing the crash the user is about to report.

**Unwrap `ProviderException` to its real cause before logging.** Riverpod 3 rethrows provider failures wrapped. An unwrapped log records the wrapper, so every entry reads `ProviderException` and the one diagnostic that exists is destroyed. Unwrap in the handler that has the `ProviderException` in hand, before it reaches `record`.

**Wire the handlers** in `main()`, in this order, per the startup sequence:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final CrashLog log = await CrashLog.open(); // FIRST

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log.record(details.exceptionAsString(), details.stack);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    try {
      log.record(error.toString(), stack);
      if (kDebugMode) debugPrint('$error\n$stack');
    } catch (_) {
      // never let the handler throw
    }
    return true; // ALWAYS true.
  };

  // ... DB open, settings read, audio session, runApp ...
}
```

`onError` returns `true` unconditionally — returning `false` routes to the embedder's unhandled-exception callback, where the VM or the process may exit or become unresponsive, which is the one behaviour a crisis UI cannot tolerate. `debugPrint` under `kDebugMode` already buys local visibility, so `return kReleaseMode` costs that risk and buys nothing.

**No `runZonedGuarded`.** Two handlers, no zone. The "you need all three" advice is crash-SDK advice — Sentry needs a zone because it wraps its own init. Sentry, Crashlytics, Firebase and every analytics package are banned here, so the zone is pure footgun. `main()` and `runApp()` share a function body, so there is no zone-mismatch warning to "fix".

**Export.** A settings affordance that hands the file to the OS share sheet. The app never sends it; the user does. Copy describes what the file is and that they are the one sending it.

**Out of scope:** any upload, any "send report" that talks to a network; a log viewer UI; log levels / categories / structured JSON; an isolate or background flush; the export UI's visual design (that is the settings epic's); rotation across multiple files.

## Acceptance criteria

- [ ] `flutter test test/diagnostics/crash_log_test.dart` passes, and includes: **a test that writes a `SpeakFailure` carrying a known phrase through the real speak path and asserts that phrase's characters never appear in the file bytes.**
- [ ] A redaction test where the phrase is embedded in an *exception's* `toString()` (simulate a `SqliteException`/`PlatformException` whose message contains the vocalization) passes — proving redaction is in `record`, not at the call site.
- [ ] A test that makes the underlying write throw (read-only path, or an injected failing file sink) asserts `record` returns normally and records nothing — no throw, no recursion.
- [ ] A test asserts the write is flushed and readable synchronously: `record(...)` followed immediately by a synchronous read of the file finds the entry, with no `await` between them.
- [ ] A test writes past the byte ceiling and asserts the file stays under it **and** that the most recent entry survives while the oldest is gone.
- [ ] A test asserts a `ProviderException` wrapping a known cause logs the cause's text, not `ProviderException`.
- [ ] `dart analyze` is clean with `empty_catches: error` and `avoid_catches_without_on_clauses` in force — the single bare catch in `record` carries its ignore + the explanatory comment.
- [ ] `grep -rn "runZonedGuarded" lib/` returns nothing.
- [ ] `grep -rn "record(" lib/` shows no call site passing `spokenText`, a `vocalization`, a `label`, `display_text`, or compose-field text.
- [ ] `CrashLog.open()` is the first statement after `WidgetsFlutterBinding.ensureInitialized()` in `lib/main.dart`, before the DB open.

## Traps

- **The handler's error re-enters the handler.** `record` is called from `FlutterError.onError`. If `record` throws — disk full, permission denied, a null in the redaction set — the throw goes to the error handler, which calls `record`, which throws. The app dies in a loop with nothing on disk. This is why the bare catch exists and why it must not rethrow, must not `debugPrint` through a path that can throw, and must never log its own failure to the same file.
- **Someone "fixes" the bare catch.** It violates Effective Dart and it looks like exactly the bug this codebase bans everywhere else. A linter, a reviewer, or a future you will try to add a `rethrow` or an `on` clause. The comment is the only defence. Keep it, and put the `// ignore:` directly above it so the reason travels with the suppression.
- **Buffering loses the only crash that matters.** An `IOSink`, a `writeAsString` without `flush: true`, or a batched drain all look fine in tests — the test awaits, the buffer drains, the assertion passes. On device, the process dies before the drain and the startup crash is gone. This trap is invisible to any test that does not read the file *synchronously and immediately*. Write that test.
- **`await` sneaks back in.** `record` gets called from a sync error handler; making it `Future<void>` forces every call site into `unawaited(...)` and reopens the buffering problem. It is `void` on purpose.
- **The phrase leaks through an exception's `toString()`.** Nobody passes `spokenText` to `record` deliberately. The leak arrives wrapped: drift puts the failing statement in `SqliteException.toString()`, and Android echoes the utterance in `PlatformException.message`. A reviewer scanning call sites sees `_log.record('saveTile failed: $e', s)` and passes it. Redaction inside `record` is the only thing that catches this class.
- **Redacting only `message` and not the stack.** A stack trace can carry the phrase in a frame's argument rendering or through a `toString()` in an error's own trace text. Scrub both.
- **A new `SpeakFailure` variant interpolates `spokenText` into its `logLine`.** The split between `spokenText` and `logLine` is the by-construction half of redaction, and it is enforced by nothing but review. Anyone adding a variant to `lib/speech/speak_outcome.dart` re-runs this check.
- **The redaction set is empty at the moment it is needed.** `CrashLog.open()` runs before the DB open, so at startup there are no known phrases to scrub. A crash during DB open therefore has an empty redaction set — which is fine (nothing is loaded to leak) *unless* the redaction source is a nullable field that someone later dereferences, which throws, inside the error handler. Make the source default to an empty set, never null.
- **Inviting users to send logs before redaction ships.** Do not write export copy, a support email line, or a README section asking for logs until the redaction tests are green. The copy outlives the assumption.
- **`ProviderException` flattens the log.** Riverpod wraps. Log the wrapper and every entry reads the same, and the only diagnostic in existence becomes noise.
- **`return false` from `PlatformDispatcher.onError` "to see crashes in debug".** It routes to the embedder, where the process may exit or hang. `kDebugMode` + `debugPrint` gives the same visibility without it.
- **Unbounded growth.** No one is watching this file. Without a ceiling it grows until a device with no free space cannot save a phrase edit either.
- **Truncating from the wrong end.** Dropping the newest entries to stay under the ceiling keeps a perfect record of the first crash the user ever hit and none of the one they are writing to you about.

## Files

- `lib/diagnostics/crash_log.dart` — new. `CrashLog.open()`, `CrashLog.record()`, redaction, bounding.
- `lib/main.dart` — changed. `CrashLog.open()` first, then the two handlers, before the DB open.
- `lib/speech/speech_controller.dart` — changed if needed. The `SpeakFailure` arm logs `logLine`, never `spokenText`.
- `test/diagnostics/crash_log_test.dart` — new. Redaction, flush, bounding, non-throwing, `ProviderException` unwrapping.
- The settings export affordance's wiring (screen file per the settings epic) — changed to hand the file to the share sheet.

## Done when

A crash on the first frame leaves a readable, size-bounded entry on disk that the user can export from settings, and a test proves that a phrase from their board never appears anywhere in that file's bytes.
