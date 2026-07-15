---
name: reed-app-startup
description: Reed's cold-launch order in main() — where CrashLog.open(), the error handlers, AppDatabase open/migration, settings read, audio_session, and runApp(ProviderScope) sit, and why SpeechService.warmUp() fires from addPostFrameCallback. Use when editing lib/main.dart or lib/ui/app.dart, reordering anything in main(), adding a splash/onboarding gate, restoring theme before first paint, or chasing cold-start latency, ANRs, or first-frame jank. Not for defining what the error handlers do — this is the order of the launch sequence.
---

# Reed startup

One screen, no accounts, no network. Launch exists to put a tappable grid in front of someone who has just lost speech. Everything below defends that.

## The sequence

```
Android process fork (zygote) ─┐
Application.onCreate           ├─ Android's. Not ours. Not measurable from Dart.
libflutter.so load             ┘
    ↓
main()
    ↓  WidgetsFlutterBinding.ensureInitialized()
    ↓  CrashLog.open()                 — first; a crash before this is invisible forever
    ↓  FlutterError.onError = ...      — cheap, synchronous
    ↓  PlatformDispatcher.instance.onError = ...
    ↓  AppDatabase open + migration    — the ONLY plausible blocker
    ↓  SettingsRepository read         — palette + tile count, before first paint
    ↓  audio_session config (.playback, NEVER .ambient)
    ↓  runApp(ProviderScope(...))
    ↓
FIRST FRAME — grid visible and tappable
    ↓
addPostFrameCallback:
    ↓  SpeechService.warmUp()          — NOT awaited, NEVER blocks the frame
    ↓  voice_filter → re-resolve the stored voice; fall back audibly if it vanished
```

`main()` is **~40 lines**. It does error handlers, DB open, settings read, audio session, `ProviderScope`, `runApp`. Anything else added to it needs a reason that survives the rules below.

## The order is not stylistic

| Step | Why it sits exactly there |
|---|---|
| `CrashLog.open()` **before** anything that can throw | There is no crash reporting and there never will be. An unhandled error thrown during DB open with no handler installed is invisible **forever** — a user who cannot speak does not file a bug report. The log is the only line of sight into the field that will ever exist. |
| Both handlers **before** the DB open | The DB open is the step most likely to throw. Installing handlers after it inverts the whole point. |
| Theme/settings read **before** `runApp` | A flash of the wrong polarity is a sudden luminance change — the exact event the animation ban exists to prevent. Paint the right palette on frame one or not at all. |
| `warmUp()` **after** first frame | Its cost is real, synchronous, and on the main thread. Awaiting it delays the grid. See below. |

## Error handlers: exactly two, no zone

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

  runApp(/* ... */);
}
```

**Never add `runZonedGuarded`.** Flutter's own guidance shows these two handlers and says the fix for a zone-mismatch warning is to *remove zones from the application*. The "you need all three" advice circulating everywhere is **crash-SDK advice** — Sentry needs a zone because it wraps its own init. There is no SDK here, so a zone buys nothing and costs a documented footgun.

**`onError` returns `true` unconditionally.** Returning `false` routes to the embedder's fallback, where the VM or the process may exit or become unresponsive — the one behaviour a crisis UI cannot tolerate. `return kReleaseMode` buys debug console visibility at that price, and buys it unnecessarily: `debugPrint` in `kDebugMode` gives the same visibility for free.

**Unwrap `ProviderException` before logging.** Riverpod 3 rethrows provider failures wrapped. An unwrapped log records the wrapper, not the cause, and every entry reads `ProviderException` — destroying the one diagnostic that exists.

`CrashLog.record` is synchronous (an entry must survive a hard kill — including a crash on the very first frame), size-bounded (nothing is watching the disk fill), and incapable of throwing. Its bare `catch (_)` deliberately violates *"DON'T discard errors"*; keep the comment, because without it someone "fixes" it into infinite recursion inside the error handler.

## runApp and the scope

```dart
runApp(
  ProviderScope(
    // Riverpod 3 retries failing providers BY DEFAULT: 200ms doubling to a 6.4s
    // ceiling, maxRetries = 10 (~38s). It skips `Error` subclasses — but
    // SqliteException is an Exception, so a corrupt DB is retried for ~38
    // seconds behind a spinner. No network here: a throwing provider means a
    // corrupt DB or a missing file — a real bug that must be LOUD on a device
    // that will never send a crash report. Fail immediately.
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

## The DB open — the one Flutter-side blocker

Reading 12 rows is sub-10ms and safe to `await`. The risk is the **migration** on first launch after an update: unbounded work sitting between the user and their voice, over a hand-curated board that is months of someone's phrases and is irreplaceable and unmergeable.

The rule is **not** "make migration fast". It is: **show the grid shell immediately rather than a blank window while migrating.** And never put a migration on the Quick Settings tile speech path — the no-Flutter-engine tile design already guarantees that structurally, so do not introduce anything that breaks it.

Copy the `.sqlite` file before `onUpgrade` runs. That backup protects against the migration bug not enumerated in any test, which — with no telemetry — is the entire invisible category.

## TTS warm-up — fired, never awaited

```dart
// RIGHT — in AacApp's initState, or the board screen's.
WidgetsBinding.instance.addPostFrameCallback((_) {
  unawaited(_speech.warmUp()); // best-effort; the grid is already usable
});

// WRONG — in main(), before runApp.
await speech.warmUp(); // binder IPC + voice deserialization on the main thread
```

TTS engine binding is a real, separate cost that Flutter profiling does not surface. Binder IPC and voice deserialization run **synchronously on the main thread** inside the engine's `OnInitListener`, producing ANRs when placed on the cold-start path. Warming from `addPostFrameCallback` pays that cost while the user is already looking at a usable grid.

**Warm-up fails silently; `speak()` fails loudly.** Opposite error policies on the same service, deliberately. A failed warm-up costs latency on the first tap. A failed `speak()` is silence, and silence is the worst bug class in this product — every failure variant carries the text that must be shown on screen instead.

Also on the post-frame path: **re-resolve the stored voice id against the live `voices()` list.** Android garbage-collects voice data; a voice present at last launch may be gone. This is the most probable real-world silent failure in the app. Falling back must be audible, never a log line.

Related, and it outranks every latency concern here: without the `<queries>` / `TTS_SERVICE` intent declaration in the Android manifest, Android 11+ package visibility **hides the TTS engine**. The plugin returns an empty voice list with only a `Log.d`. Every Android 11+ user gets a board that cannot speak, and nobody will ever hear about it. A test can read the manifest and assert that string is present. It should.

## What launch resets, what it persists

| Persist | Reset on every launch |
|---|---|
| Board customisation — boards, buttons, grid_slots, images, sounds | Which board is showing → always the home board |
| Settings — palette (`paper` / `ink` / `hcInk` / `hcPaper`), tile count (12 or 6), voice id | Scroll position |
| | Compose-field contents, show-text mode, edit mode |

**Always reset to the home board.** Both sides are real — resuming saves taps — but the deciding case is the one the product exists for: someone mid-shutdown in an emergency room opens the app and must land somewhere known within one glance. *"Why am I on the Food board?"* is cognitive load at the exact moment there is none to spare. Determinism is the accommodation; tap-saving is an optimisation. Mitigate the cost by putting the highest-stakes phrases on home — **never** by restoring state.

Never add `RestorationMixin`, a restoration id, a "resume where you left off" setting, or a saved-route hydration step. Persisting navigation is not a feature request away; it is the wrong answer.

## Nothing stands between the user and the grid

Banned on the launch path, permanently:

- **No splash screen.** No branded first frame, no logo hold.
- **No onboarding.** No carousel, no tour, no "what's new", no permission-explainer screen. It opens to the grid or it is deleted.
- **No modal, no dialog, no bottom sheet** on launch — including "restore backup?", "pick a voice", "rate the app".
- **No network wait.** There is no network.
- **No first-launch prompt of any kind.** The one-time tile-count decision (lay out the longest starter label with a `TextPainter` at the live `textScaler`; pick 6 if it exceeds 3 lines or overflows; persist; never re-evaluate) happens *silently*. A prompt — "Text is large. Switch to 6 tiles?" — is the app offering an accommodation it noticed you need, which is the parental register in indie clothes.
- **No theme crossfade.** `themeAnimationStyle: AnimationStyle.noAnimation` at the app root; the restored palette is simply the first thing painted.

Starter phrases are a `const` Dart list, not a JSON asset: a missed pubspec entry would make first launch an empty board, and an empty board is a mute board.

## The latency budget

Android vitals treats a cold start of **≥5s** as excessive, and startup is not a core vital — it cannot affect discoverability. A one-screen app with no plugin work in `main()` and a 12-row read lands well inside that.

What dominates cold start — zygote fork, `Application.onCreate`, `libflutter.so` load, Dart VM snapshot — **is Android's, not ours, and is not measurable from Dart.** What a developer here actually controls is the short list above: don't block the first frame, don't await warm-up, don't let a migration paint a blank window.

**There is nothing to optimise here.** Cold-start micro-optimisation is not a good use of this project's time. Shader warm-up flags and `--bundle-sksl-path` are removed and irrelevant — Impeller precompiles shaders, and there is zero animation regardless. Any advice recommending them is stale. If asked to make launch faster, the honest answer is usually that the budget is already met and the remaining time belongs to Android.

The only rule is: **do not block the first frame.**
