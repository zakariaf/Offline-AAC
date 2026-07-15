---
name: reed-async-rules
description: Async correctness for Reed — mounted/ref.mounted guards across every await gap, capturing Navigator or ScaffoldMessenger before it, honest unawaited() with catchError, cancelling watchGrid() subscriptions, closing StreamControllers and Timers in dispose(), no zones, never blocking first frame. Use when writing async/await, touching BuildContext after an await, wiring initState/dispose/addPostFrameCallback, adding a Timer or Future.delayed, seeing use_build_context_synchronously / cancel_subscriptions / close_sinks / unawaited_futures / discarded_futures, or reviewing a diff for async correctness.
---

# Async rules that bite

This app has no telemetry and no crash reporting. Nobody will ever tell us the app broke — the user cannot speak, which is why they opened it. A dropped Future is a phrase never spoken. A dead `BuildContext` is an exception nobody sees. Async bugs here are silence, and silence is the worst failure this product has.

---

## 1. The async gap and `BuildContext`

`context` is not a value. It is a **handle into a live element tree**. `await` yields to the event loop, and while suspended anything may happen: the route pops, the dialog closes, the user backgrounds the app, the `State` is disposed and its `Element` becomes defunct. When execution resumes, the handle points at a corpse. Using it throws or asserts — into a void where no one is watching.

`use_build_context_synchronously` is promoted to **error** for this reason. It is a live hazard in edit mode: await a drift write, then pop the dialog.

```dart
// WRONG
Future<void> _save() async {
  await _repo.saveTile(tile);   // ← the gap
  Navigator.of(context).pop();  // the Element may be defunct
}
```

Two fixes. Both are legitimate; prefer whichever makes the intent obvious.

**Capture before the gap.** The captured object does not need the tree.

```dart
// RIGHT — nothing touches context after the await
Future<void> _save() async {
  final navigator = Navigator.of(context);
  await _repo.saveTile(tile);
  navigator.pop();
}
```

**Guard after the gap.** The check must come **after every await and before every context use** — not once at the top of the method, and not before the await, where it proves nothing.

```dart
// RIGHT
Future<void> _save() async {
  await _repo.saveTile(tile);
  if (!mounted) return;
  Navigator.of(context).pop();
}
```

Two awaits mean two guards. A guard only certifies the interval since the last suspension point.

```dart
// WRONG — the second await reopens the hole the first guard closed
await _repo.saveTile(tile);
if (!mounted) return;
await _repo.reindex();
Navigator.of(context).pop();   // unguarded

// RIGHT
await _repo.saveTile(tile);
await _repo.reindex();
if (!mounted) return;
Navigator.of(context).pop();
```

### Which `mounted`, where

| Context | Guard | Note |
|---|---|---|
| `State<T>` subclass | `if (!mounted) return;` | `State.mounted` — the field the analyzer recognises |
| Riverpod `Notifier` after an await | `if (!ref.mounted) return;` | Riverpod 3.x. Guards `state = ...` writes on a disposed provider |
| Plain class / controller with no `State` and no `ref` | Do not take a `BuildContext` at all | Pass the captured `NavigatorState`, or a `void Function(String)` callback |
| `StatelessWidget` method | Same — there is no `mounted` | Capture before the gap; there is nothing to check |

The last row is the one people get wrong. A `StatelessWidget` or a bare helper has no lifecycle to interrogate, so `context.mounted` (the `BuildContext` extension) is the only option and it only proves the element is alive *right then*. Prefer restructuring: hand the class a captured object or a callback so it never holds a context across a gap. `SpeechController` takes `void Function(String) _showText` for exactly this reason — it never sees a context, so it can never hold a dead one.

Never write `if (!mounted) return;` *before* the await and call it done. That is the most common false fix and it checks the one moment that was never in doubt.

---

## 2. `unawaited()` — a statement of intent, and when it lies

`unawaited_futures` (async body) and `discarded_futures` (sync body) are both **error**. `unawaited(...)` is the explicit, greppable escape hatch: it says *discarding this Future is the design*.

`unawaited` is honest **only if the Future cannot fail silently**. `unawaited(f)` on a bare Future routes any error to `PlatformDispatcher.onError` — technically logged, but detached from the UI, so the user gets nothing. `unawaited` without an error path is a lie that reads as a decision.

```dart
// WRONG — silences the lint, keeps the bug
unawaited(_speakAndShow(phrase));

// RIGHT — the failure has somewhere to go
void speakNow(String vocalization) {
  unawaited(
    _speakAndShow(vocalization).catchError((Object e, StackTrace s) {
      // _speakAndShow is total — speak() returns outcomes rather than throwing.
      // Landing here means stop(), the crash log, or the fallback UI threw.
      // Show the words anyway; that is the product.
      _log.record('speak path threw: $e', s);
      _showText(vocalization);
    }),
  );
}
```

Rule: **`unawaited(x)` is only correct when `x` already terminates in a `catchError` or is provably total.** Otherwise `await` it.

### The hole no lint sees

Verified on this toolchain, with `discarded_futures`, `unawaited_futures`, and `unused_result` all at `error`:

| Callback | Diagnostics |
|---|---|
| `onTap: () => s.speak('A')` | **none — all three miss it** |
| `onTap: () { s.speak('B'); }` | `discarded_futures` + `unused_result` |
| `onTap: () async { s.speak('C'); }` | `unawaited_futures` + `unused_result` |
| `onTap: () => c.speakNow('D')` | clean — the fix |

The arrow closure *returns* the Future, so every rule considers it used; the target type is `VoidCallback`, so Dart's void-compatibility discards it. The Future **and its error** vanish. This is the most idiomatic way to wire a Flutter tile and it is precisely this app's silence bug.

The mitigation is **structural, never disciplinary**: `SpeechController.speakNow` and `speakSlot` return **`void`**, and do the `unawaited(... .catchError(...))` internally. A callback then never holds a Future and the hole is unreachable by construction. Do not "improve" a void-returning controller method into a `Future<void>` — that returns the hole to the codebase. Keep the comment saying so; without it the next reader tidies it away.

---

## 3. Subscriptions and sinks

Every `StreamSubscription` is cancelled. Every `StreamController` is closed. `cancel_subscriptions: error` and `close_sinks: error`.

The live case is drift's `watchGrid()` — a `.watch()` query stream. It stays open until cancelled, keeps its query alive, and fires into a disposed listener.

```dart
// RIGHT
class _GridState extends State<Grid> {
  StreamSubscription<BoardGrid>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _repo.watchGrid(kDefaultBoardId).listen(_onGrid);
  }

  @override
  void dispose() {
    _sub?.cancel();   // fire-and-forget is correct here; there is nothing to await
    super.dispose();
  }
}
```

Prefer not owning the subscription at all: `gridProvider` is a `StreamProvider` over `watchGrid`, so a `ConsumerWidget` watching it gets teardown from the provider and no field to leak. Reach for a hand-held subscription only when a provider genuinely cannot express it.

For a `Provider`-held service that owns a stream or controller, release it in `ref.onDispose` — the provider equivalent of `dispose()`.

`close_sinks` only fires because it is enabled under `linter: rules:` in the analyzer config, not merely re-ranked under `analyzer: errors:`. The `errors:` block re-ranks diagnostics that already exist; it cannot switch a lint on. If a never-closed controller produces no diagnostic, that block was deleted — restore it rather than trusting a green run.

---

## 4. `initState` and first frame

`initState` is synchronous and cannot be `async`. Two consequences.

**Never make `initState` async, and never `unawaited` real work out of it into the void.** Kick the Future off, guard the landing.

```dart
// WRONG — the widget may be gone; setState throws into nothing
@override
void initState() {
  super.initState();
  _repo.loadTiles().then((t) => setState(() => _tiles = t));
}

// RIGHT
@override
void initState() {
  super.initState();
  unawaited(_load());
}

Future<void> _load() async {
  final tiles = await _repo.loadTiles();
  if (!mounted) return;
  setState(() => _tiles = tiles);
}
```

**Never block the first frame on an await.** The startup order is fixed:

```
CrashLog.open()                — first; a crash before it is invisible
FlutterError.onError           — cheap, synchronous
PlatformDispatcher.onError     — same
AppDatabase open + migration   — the only plausible blocker
audio_session config           — .playback
runApp(ProviderScope(...))
── FIRST FRAME: grid visible and tappable ──
addPostFrameCallback:
  SpeechService.warmUp()       — NOT awaited, NEVER blocks the frame
  voice_filter → resolve the stored voice, fall back audibly if it vanished
```

Reading 12 rows is sub-10ms and safe to await. A **migration** is not: it is unbounded work over a hand-curated board — months of someone's phrases, irreplaceable — sitting between the user and their voice. Show the grid shell immediately rather than a blank window while migrating. Never put a migration on the Quick Settings tile speech path.

TTS warm-up goes in `addPostFrameCallback` and is **never awaited**: `flutter_tts` runs binder IPC and voice deserialization synchronously on the main thread inside `OnInitListener`, which ANRs on the cold-start path. Pay that cost while the user is looking at an already-usable grid. Warm-up is **best-effort and fails silently**; `speak()` fails **loudly**. That asymmetry on one service is deliberate — do not normalise it in either direction.

---

## 5. Timers and the lit-state latch

A tile lights on `Listener.onPointerDown` and stays lit until TTS completes. The latch is asynchronous state driven by an external engine, so it has two failure modes and both need a timer.

**Minimum hold: 120ms.** A fast tap must never be imperceptible — feedback the user cannot see is feedback that did not happen.

**Maximum hold: a force-clear timeout.** `flutter_tts` completion-handler reliability varies by OEM. A handler that never fires leaves a permanently lit tile, which is a lie about what the app is doing. Bound it — `speak()` already carries an 8-second `.timeout(_speakTimeout)`, so the latch must not outlive it.

```dart
// WRONG — trusts the engine, and leaks the timer
void _onSpeakStart() {
  setState(() => _lit = true);
  Timer(_maxHold, () => setState(() => _lit = false));
}

// RIGHT
Timer? _latch;

void _onSpeakStart() {
  setState(() => _lit = true);
  _latch?.cancel();                    // re-tap means barge-in: restart the latch
  _latch = Timer(_maxHold, _clearLit); // force-clear if completion never lands
}

void _clearLit() {
  if (!mounted) return;                // a Timer outlives dispose()
  setState(() => _lit = false);
}

@override
void dispose() {
  _latch?.cancel();
  super.dispose();
}
```

Every `Timer` field is cancelled in `dispose()` and every timer callback that touches `setState` guards on `mounted` first — a `Timer` holds a strong reference to its closure and fires happily after the widget is gone. `Future.delayed` has the same shape and the same rule.

Barge-in is the policy: a re-tap means "say it again", so `stop()` then `speak()` — never `if (_running) return`, which swallows the tap and produces the silence we forbid.

In tests, `pump()` does **not** advance the fake clock. Timers, `Future.delayed`, and debounces need `pump(duration)` or `fakeAsync`. `pumpAndSettle` is banned: zero animation means one frame settles it, and `pumpAndSettle` adds only a 10-minute-timeout flake vector with a truncated stack trace.

---

## 6. No zones

**No `runZonedGuarded`.** Flutter's own guidance for the zone-mismatch warning is to remove zones from the application, and only two handlers are needed: `FlutterError.onError` and `PlatformDispatcher.instance.onError`. The "use all three" advice is crash-SDK advice — Sentry needs a zone because it wraps init. There is no SDK here, so a zone is pure footgun. `main()` must have the same function body as `runApp()`: no zone, no mismatch.

`PlatformDispatcher.instance.onError` always returns `true`. Returning `false` routes to the embedder's unhandled-exception callback, where the VM or process may exit or become unresponsive — the one behaviour a crisis UI cannot tolerate.

---

## Review checklist

- Every `await` followed by a `context` use has a `mounted` / `ref.mounted` guard **between** them, or the object was captured before the gap.
- Multiple awaits ⇒ the guard sits after the last one.
- Every `unawaited(...)` ends in a `catchError` or is provably total.
- No controller method that a callback invokes returns a `Future`.
- Every `StreamSubscription`, `StreamController`, and `Timer` field is released in `dispose()` / `ref.onDispose`.
- Every timer or stream callback calling `setState` guards `mounted` first.
- Nothing unbounded — no migration, no TTS warm-up — sits before `runApp`.
