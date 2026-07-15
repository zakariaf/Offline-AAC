# E01-T06 — Cold-launch sequence in main()

| | |
|---|---|
| **Epic** | E01 — Foundation |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E02-T03, E04-T03, E05-T08 |
| **Blocks** | E09-T03 |

**Skills:** `reed-app-startup` · `reed-error-model` · `reed-theming-code` · `reed-speech-service`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Launch exists for one thing: put a tappable grid in front of someone who has just lost speech. Every step in `main()` sits where it sits because moving it produces a specific field failure nobody will ever report — a crash during database open with no handler installed is invisible forever, a palette read after `runApp` is a flash of the wrong polarity delivered to a person in a shutdown, and an awaited TTS warm-up is binder IPC on the main thread turning cold start into an ANR. This task nails the order down and pins it with tests, because the ordering is the only thing defending the first frame.

## Scope

Write `main()` in `lib/main.dart` in exactly this order. Target ~40 lines. Anything added needs a reason that survives the rules below.

```
main()
  WidgetsFlutterBinding.ensureInitialized()
  CrashLog.open()                    — FIRST; a crash before this is invisible forever
  FlutterError.onError = ...         — cheap, synchronous
  PlatformDispatcher.instance.onError = ...
  AppDatabase open + migration       — the ONLY plausible blocker
  SettingsRepository read            — palette + tile count, BEFORE first paint
  audio_session config (.playback)   — never .ambient
  runApp(ProviderScope(...))
FIRST FRAME — grid visible and tappable
  addPostFrameCallback:
    unawaited(speech.warmUp())       — NEVER awaited
    voice re-resolve against voices() — fall back audibly
```

### The two error handlers, no zone

```dart
Future<void> main() async {
  // Same function body as runApp(): no zone, so no zone-mismatch warning.
  WidgetsFlutterBinding.ensureInitialized();
  final CrashLog log = await CrashLog.open();

  // Errors inside Flutter's build/layout/paint callbacks.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log.record(details.exceptionAsString(), details.stack);
  };

  // Uncaught async errors outside the framework's callbacks.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    try {
      log.record(error.toString(), stack);
      if (kDebugMode) debugPrint('$error\n$stack');
    } catch (_) {
      // Never let the error handler throw.
    }
    return true; // ALWAYS true.
  };
  // ...
}
```

`onError` returns `true` unconditionally. Returning `false` routes to the embedder's fallback where the VM or process may exit or become unresponsive — the one behaviour a crisis UI cannot tolerate. `return kReleaseMode` buys debug visibility at that price and buys it unnecessarily: the `kDebugMode` `debugPrint` gives the same thing for free.

**No `runZonedGuarded`.** The "you need all three" advice is crash-SDK advice — Sentry needs a zone because it wraps its own init. There is no SDK here and never will be.

Unwrap `ProviderException` to its real cause before logging. Riverpod 3 rethrows provider failures wrapped; unwrapped, every log entry reads `ProviderException` and the one diagnostic this app has is destroyed.

### The scope and `runApp`

```dart
runApp(
  ProviderScope(
    // Riverpod 3 retries failing providers BY DEFAULT: 200ms doubling to a
    // 6.4s ceiling, maxRetries = 10 (~38s). It skips `Error` subclasses — but
    // SqliteException is an Exception, so a corrupt DB is retried for ~38
    // seconds behind a spinner. There is no network here: a throwing provider
    // means a corrupt DB or a missing file. Fail immediately, loudly.
    retry: (retryCount, error) => null,
    overrides: [
      databaseProvider.overrideWithValue(db),
      speechServiceProvider.overrideWithValue(speech),
    ],
    child: const AacApp(),
  ),
);
```

`retry: (retryCount, error) => null` is not optional and is not a micro-optimisation. Deleting it puts ~38 seconds of spinner between a user in shutdown and the discovery that the app is broken.

### Theme restored before first paint

The `SettingsRepository` read happens before `runApp`, and `runApp` receives the restored palette — one of `paper` / `ink` / `hcInk` / `hcPaper` — plus the tile count (12 or 6) and the stored voice id. Not a default corrected a frame later. Restoring an unknown or corrupt palette name falls back to `AacPalette.ink` explicitly and visibly, never to a null that leaves `AacTheme.of` asserting on a device with no debugger attached.

Palette lives in the versioned JSON settings file, not `shared_preferences` — a `shared_preferences` read is async and arrives after first paint.

At the app root:

```dart
MaterialApp(
  theme: aacThemeData(current),
  themeAnimationStyle: AnimationStyle.noAnimation, // MaterialApp otherwise mounts
  home: const BoardScreen(),                       // AnimatedTheme and interpolates
)                                                  // over kThemeAnimationDuration (200ms)
```

### Warm-up fired, never awaited

```dart
// RIGHT — in AacApp's initState, or the board screen's.
WidgetsBinding.instance.addPostFrameCallback((_) {
  unawaited(_speech.warmUp()); // best-effort; the grid is already usable
});

// WRONG — in main(), before runApp.
await speech.warmUp(); // binder IPC + voice deserialization on the main thread
```

Also on the post-frame path: re-resolve the stored voice id against the live `voices()` list. Android garbage-collects voice data; a voice present at last launch may be gone. Falling back must be audible, never a log line. **Warm-up fails silently; `speak()` fails loudly** — opposite policies on the same service, deliberately. Do not unify them.

### The audio session

`audio_session` configured with `.playback` + `duckOthers` + `setSharedInstance`, from `lib/data/speech/audio_session_config.dart`. **Never `.ambient`** — `.ambient` lets the hardware silent switch mute the app, so a user flips the ringer for a meeting and their voice is gone. `flutter_tts`'s own README example uses `.ambient`; copying the example ships the worst bug in the product.

### What launch persists, what it resets

| Persist | Reset on every launch |
|---|---|
| Board customisation — boards, buttons, grid_slots, images, sounds | Which board is showing → **always the home board** |
| Settings — palette, tile count (12 or 6), voice id | Scroll position, compose-field contents, show-text mode, edit mode |

Always reset to the home board. Someone mid-shutdown in an emergency room must land somewhere known within one glance; *"why am I on the Food board?"* is cognitive load at the exact moment there is none to spare. Determinism is the accommodation.

### Explicitly out of scope

- **Banned on the launch path, permanently:** splash screen, branded first frame, logo hold; onboarding, carousel, tour, "what's new", permission explainer; any modal, dialog or bottom sheet on launch (including "restore backup?", "pick a voice", "rate the app"); any network wait; any first-launch prompt; theme crossfade.
- `RestorationMixin`, restoration ids, a "resume where you left off" setting, saved-route hydration. Persisting navigation is not a feature request away; it is the wrong answer.
- `runZonedGuarded`, and any crash SDK.
- Cold-start micro-optimisation: shader warm-up flags, `--bundle-sksl-path`. Impeller precompiles shaders and there is zero animation regardless. Android vitals treats ≥5s cold start as excessive; zygote fork, `Application.onCreate`, `libflutter.so` load and the VM snapshot dominate and are Android's, not ours, and are not measurable from Dart. The only rule is: do not block the first frame.
- Defining `CrashLog.record`'s internals, the `SpeakOutcome` variants, or `aacThemeData()`'s token values — those come from their own tasks. This task wires them in order.

## Acceptance criteria

- [ ] `lib/main.dart` is ~40 lines and contains, in source order: `WidgetsFlutterBinding.ensureInitialized()`, `await CrashLog.open()`, `FlutterError.onError`, `PlatformDispatcher.instance.onError`, DB open, settings read, audio session config, `runApp`.
- [ ] A test asserts `main()` completes and a first frame is pumped with the grid present and tappable, with no dialog, route, splash or overlay in the widget tree.
- [ ] A test launches with a saved palette of `hcPaper` and asserts the **first** frame's `AacTheme` is the `hcPaper` palette — not a default corrected on frame 2.
- [ ] A test launches with a corrupt/unknown palette string in the settings file and asserts the app comes up on `AacPalette.ink` (no assert fires, no null).
- [ ] A test with a fake `SpeechService` whose `warmUp()` never completes asserts the first frame still paints and a tile is tappable — proving warm-up is not awaited.
- [ ] A test asserts `warmUp()` has not been called at `runApp` time and *has* been called after one `pump()`.
- [ ] A test with `SpeechEnv.storedVoiceUninstalled` asserts the stored voice id is re-resolved at startup and the fallback is audible (a `speak` reaching the fake), not just logged.
- [ ] `! grep -rn 'runZonedGuarded' lib/` returns nothing.
- [ ] `! grep -rn 'RestorationMixin\|restorationId\|restorationScopeId' lib/` returns nothing.
- [ ] `grep -rn 'AudioSessionCategory' lib/data/speech/audio_session_config.dart` shows `.playback` and no `.ambient`.
- [ ] `grep -n 'retry:' lib/main.dart` shows `retry: (retryCount, error) => null` on the `ProviderScope`.
- [ ] `grep -n 'themeAnimationStyle' lib/ui/app.dart` shows `AnimationStyle.noAnimation`.
- [ ] `flutter analyze` is clean and `flutter build apk --debug` succeeds (analyze alone does not catch a non-exhaustive switch if it has been `ignore`d; the build does).

## Traps

- **Installing the handlers after the DB open.** The DB open is the step most likely to throw. Handlers after it inverts the entire point, and the throw is invisible forever.
- **Putting `main()`'s body in a different zone from `runApp()`.** Adding `runZonedGuarded` produces the documented zone-mismatch warning whose documented fix is to remove zones from the application. Someone will add it back citing Sentry advice for an app with no Sentry.
- **`return kReleaseMode` from `PlatformDispatcher.onError`.** Reads as clever, routes debug crashes to the embedder's `unhandled_exception_callback` where the process may exit or hang. `debugPrint` under `kDebugMode` gives the same visibility with none of the risk.
- **`await speech.warmUp()` in `main()`, "just to be safe".** Binder IPC and voice deserialization run synchronously on the main thread inside the engine's `OnInitListener`. Flutter profiling does not surface this cost, so it looks free right up until the ANR.
- **Reading the palette in a provider that resolves after the first frame.** Frame 1 paints the default, frame 2 paints the restored palette: a sudden large luminance change, the exact event the animation ban exists to prevent, aimed at a user in a shutdown.
- **Deleting `retry: (retryCount, error) => null` because "the default seems fine".** `SqliteException` is an `Exception`, not an `Error`, so Riverpod 3 retries it: 200ms doubling to a 6.4s ceiling, maxRetries 10 — ~38 seconds of spinner over a corrupt DB.
- **Migration painting a blank window.** The rule is not "make migration fast"; it is show the grid shell immediately rather than a blank window while migrating. Copy the `.sqlite` file before `onUpgrade` runs — a hand-curated board is months of someone's phrases, irreplaceable and unmergeable, and the migration bug not enumerated in any test is the entire invisible category.
- **Loading starter phrases from a JSON asset.** A missed pubspec entry makes first launch an empty board, and an empty board is a mute board. They are a `const` Dart list.
- **A first-launch prompt for the tile-count decision.** The one-time decision — lay out the longest starter label with a `TextPainter` at the live `textScaler`, pick 6 if it exceeds 3 lines or overflows, persist, never re-evaluate — happens *silently*. "Text is large. Switch to 6 tiles?" is the app offering an accommodation it noticed you need: the parental register in indie clothes.
- **`CrashLog.record`'s bare `catch (_)` getting "fixed".** It runs inside both handlers; rethrowing or logging to the same file recurses until the app dies. Keep the comment — it is load-bearing.
- **Logging phrase text.** `record` is user-exportable. Never pass `spokenText`, a `Button.vocalization`, a label, `display_text` or compose-field contents to it; log `logLine`, which carries only engine facts and voice names.
- **Copying `flutter_tts`'s README audio session example.** It uses `.ambient`. Ship that and the ringer switch mutes the user's voice.
- **Adding "resume where you left off" after someone points out it saves taps.** Both sides are real; the deciding case is not. Mitigate by putting the highest-stakes phrases on home — never by restoring state.

## Files

- `lib/main.dart` — created; the launch sequence, both error handlers, `ProviderScope` with `retry: null` and the two overrides.
- `lib/ui/app.dart` — created/changed; `AacApp`, `themeAnimationStyle: AnimationStyle.noAnimation`, the `addPostFrameCallback` firing `unawaited(warmUp())` and the stored-voice re-resolve.
- `lib/data/speech/audio_session_config.dart` — changed if needed; `.playback` + `duckOthers` + `setSharedInstance`, with the reason at the point of temptation.
- `test/startup/launch_sequence_test.dart` — created; first-frame, palette-restore, warm-up-not-awaited and voice-re-resolve tests.
- `test/policy/launch_bans_test.dart` — created; the greps for `runZonedGuarded`, restoration, `.ambient`.

## Done when

A cold launch paints a usable, tappable home grid in the restored palette on frame one, with both error handlers already installed and TTS warm-up still running behind it.
