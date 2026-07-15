---
name: reed-riverpod-usage
description: Riverpod 3.x kept minimal in Reed — six plain providers, ref.watch/read/listen, ProviderScope overrides, drift .watch() as a StreamProvider, ProviderContainer.test. Use when adding or changing a provider, editing lib/providers.dart or main.dart's ProviderScope, writing a Notifier/AsyncNotifier like BoardController, reading an AsyncValue in a ConsumerWidget, overriding databaseProvider or speechServiceProvider in a test, or reaching for StateProvider, family, or @riverpod codegen.
---

# Riverpod in Reed

## Be honest first: it is not load-bearing

Riverpod (`flutter_riverpod 3.3.2`) earns its place here for exactly **two** things:

1. **A testable seam between repository and UI.** One override swaps the whole board layer or the TTS engine.
2. **Clean reaction to TTS voice-availability changes.** Real, but weak — a `StreamBuilder` would also do it.

Twelve tiles and a text field would work fine with `ValueNotifier` + constructor injection. The decision is made; do not re-litigate it and do not spend a day on it. But it is only cheap while it stays minimal. Riverpod's cost curve is not adoption — it is the family/scoping/codegen/generated-lint stack. **Six plain providers. No families, no scoping, no codegen.** The moment `family` is typed, the argument that it was cheap has been lost.

When adding a provider, first ask whether the value could just be a constructor argument or a `ValueNotifier` field. Prefer that. Provider count going up is a smell, not progress.

## Current API — what 2023 tutorials get wrong

| Thing | Status here |
|---|---|
| `StateProvider` | Never. It is a mutable global with extra steps; nothing in this app needs it. |
| `StateNotifierProvider` | Legacy. `Notifier` + `NotifierProvider` is the idiom. |
| `ChangeNotifierProvider` | Never. `package:provider` for DI is also rejected — Riverpod already is a DI container and two DI mechanisms is strictly worse than one. |
| `Notifier` / `AsyncNotifier` | The idiom for anything with methods. A `Notifier` **is** the ViewModel. |
| `.autoDispose` | Still exists, still compiles. Only the interface clones (`AutoDisposeRef`, `AutoDisposeNotifier`) were removed. Current spelling is `Provider(create, isAutoDispose: true)`. Migrating is cosmetic. |
| "Notifiers are recreated on every rebuild" | **False.** That lifecycle change was reverted before stable — notifiers are preserved across rebuilds. Do not restructure code around the myth. |
| `overrideValue` | Does not exist. The method is **`overrideWithValue`**. |
| `createContainer` helper + `addTearDown(container.dispose)` | Obsolete. `ProviderContainer.test()` self-disposes. |
| `Command` pattern / `if (_running) return;` | Rejected. A re-tap of a speak button means "say it again" — swallowing it is the silence bug. |

## Codegen: no

Do not add `riverpod_generator` or write `@riverpod`. For ~6 providers, codegen buys inferred types and argument-typed families — the families this app has already banned — and charges a `build_runner` round-trip, a generated-file review surface, and a second dialect a stranger has to learn before reading six declarations. Six hand-written provider lines are readable with zero tooling.

Codegen also flips a default silently: **`isAutoDispose` defaults to `false` for hand-written providers and `true` under codegen.** That asymmetry is the kind of thing that bites once and costs an afternoon. Hand-written keeps the default that is correct here.

Consequence for lint config: `riverpod_syntax_error` stays off, because it references `riverpod_generator` internals and without codegen it is dead config. Keep `missing_provider_scope` on — no `ProviderScope` means every provider read throws on the first tap.

## The providers

```dart
// lib/providers.dart

// Riverpod is NOT load-bearing. These exist as a test seam. ValueNotifier would work.
// Do not grow this file without a reason that survives being said out loud.

// The two seams. Throwing by default is deliberate: an un-overridden seam fails at
// first read with a clear message instead of silently constructing a real TTS engine
// inside a unit test.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);
final speechServiceProvider = Provider<SpeechService>(
  (ref) => throw UnimplementedError('speechServiceProvider must be overridden'),
);

final boardRepositoryProvider =
    Provider<BoardRepository>((ref) => BoardRepository(ref.watch(databaseProvider)));

// isAutoDispose defaults to FALSE for hand-written providers. False is right here:
// the grid IS the app. There is no screen it is absent from, so disposal would only
// ever re-open a drift stream that is about to be watched again.
final gridProvider = StreamProvider<BoardGrid>(
  (ref) => ref.watch(boardRepositoryProvider).watchGrid(kDefaultBoardId),
);
```

Never construct `AppDatabase` or the real `SpeechService` inside a provider body. They are built in `main()` before `runApp` and injected via `ProviderScope(overrides:)`, so tests get the same wiring the app has, minus the platform.

## ProviderScope in main()

```dart
runApp(
  ProviderScope(
    // Riverpod 3 retries failing providers BY DEFAULT: 200ms doubling to a 6.4s
    // ceiling, bounded at maxRetries = 10 (~38s of added delay). It skips `Error`
    // subclasses — but SqliteException is an Exception, so a corrupt DB is retried
    // for ~38 seconds behind a spinner.
    //
    // This app has no network. A throwing provider means a corrupt DB or a missing
    // file on disk — a real bug that must be LOUD, on a device that will never send
    // a crash report. Fail immediately.
    //
    // `Retry` is `Duration? Function(int retryCount, Object error)`; null disables.
    retry: (retryCount, error) => null,
    overrides: [
      databaseProvider.overrideWithValue(db),
      speechServiceProvider.overrideWithValue(speech),
    ],
    child: const AacApp(),
  ),
);
```

Never delete `retry: (_, __) => null` to "add resilience". There is no network to be resilient against; the only thing retrying buys is 38 seconds of spinner between a user in shutdown and the discovery that their board is broken.

**Unwrap `ProviderException` before logging.** Riverpod 3 rethrows provider failures wrapped. Logging the wrapper records `ProviderException` on every entry and destroys the one diagnostic signal that exists — the on-device crash log is the only field feedback there will ever be.

## MediaQuery a11y flags do NOT go through Riverpod

Decided, and it is not a style preference. Read `MediaQuery.boldTextOf(context)` / `highContrastOf(context)` / `textScalerOf(context)` **at build time, in the widget**.

`MediaQuery` is already an `InheritedWidget` — already a reactive propagation mechanism with correct-by-construction invalidation. Routing it through a provider means either a `BuildContext` inside a provider or a manual push-and-sync that is stale for one frame. At 200%+ text scale, being wrong is total failure, not a cosmetic bug. Trading a compiler-guaranteed rebuild for a hand-maintained sync there is a strictly bad trade.

**App state via Riverpod; platform/a11y state via `BuildContext`.** If a provider is about to expose `boldText`, `textScaler`, `highContrast`, or `accessibleNavigation`, stop.

## ref.watch vs ref.read vs ref.listen

| Use | Where | Why |
|---|---|---|
| `ref.watch` | `build()`, and inside a provider body to depend on another provider | Rebuild/recompute on change. |
| `ref.read` | Inside callbacks — `onTap`, `onPressed`, notifier methods | A `read` in `build()` gives a value that never updates: a screen frozen on stale data with no error. |
| `ref.listen` | `build()`, for side effects on change | Reacting to voice-availability going away. Never call a side effect directly from `build()`. |

### The bug that actually matters

**Never capture a `ref.watch` value in `build()` into an `onTap` closure.** Pass the coordinates and resolve at tap time.

```dart
// WRONG — a fast re-tap speaks the PREVIOUS tile's sentence: the wrong words, out
// loud, to a stranger, on behalf of someone who cannot verbally correct it.
onTap: () => controller.speak(tile.vocalization),

// RIGHT — (row, col) is the grid_slots primary key. Position cannot go stale.
onTap: () => controller.speakSlot(slot.row, slot.col),
```

Inside `speakSlot`, resolve the tile **now**, via `ref.read`.

### The controller method returns void

```dart
class BoardController extends Notifier<BoardUiState> {
  // VOID, deliberately. Do not "improve" this to return a Future.
  //
  // `onTap: () => tts.speak('x')` is flagged by NEITHER discarded_futures NOR
  // unawaited_futures — the arrow closure "returns" the Future so the lint thinks
  // it is handled, but the target type is VoidCallback, so the Future AND ITS ERROR
  // are dropped. That is the silence bug, and no lint in the ecosystem catches it.
  //
  // A void-returning method means a callback never holds a Future, so the hole is
  // unreachable by construction.
  void speakSlot(int row, int col) {
    final tile = ref.read(gridProvider).valueOrNull?.tileAt(row, col);
    if (tile == null) return;
    unawaited(_speak(tile.vocalization).catchError(_recordAndShow));
  }
}
```

`ref.mounted` is the guard for a `Notifier` writing state after an `await` — the Riverpod analogue of the `use_build_context_synchronously` rule.

## Exposing drift's .watch() as a stream

`BoardRepository.watchGrid` returns `Stream<BoardGrid>`; `gridProvider` is a `StreamProvider` over it. Riverpod owns the subscription lifecycle, so no `StreamSubscription` is hand-managed and `cancel_subscriptions` has nothing to complain about.

The repository — not a widget — unpacks the join. drift generates a row class per table and **never per join**; a displayable tile is `grid_slots ⟕ buttons ⟕ images` with two nullable FKs, unpacked from `List<TypedResult>` via `readTable()` / `readTableOrNull()`. `BoardGrid` (dimensions × nullable tiles) is a shape the schema deliberately does not have. **No widget imports `package:drift`.**

Consume it with `AsyncValue`, and handle every arm — an empty slot renders as an empty tile that holds its space, never as a collapsed cell.

No optimistic state anywhere. A local SQLite write is single-digit milliseconds, so the revert path could never fire and is pure liability — and a state that appears then reverts is a visual change the user did not cause, which the zero-animation rule forbids.

## autoDispose and keepAlive

Default (`false`) is correct for all six providers. `gridProvider` is the app; `databaseProvider` and `speechServiceProvider` are process-lifetime singletons. Do not add `isAutoDispose: true` and do not reach for `ref.keepAlive()` — needing `keepAlive` means autoDispose was turned on for no reason.

Keep `SpeechService` in a plain `Provider` with `ref.onDispose` to release it. That is ordinary lifecycle hygiene, not a workaround for a notifier lifecycle rumour.

## Tests

```dart
test('empty slot speaks nothing', () {
  // ProviderContainer.test() self-disposes. No createContainer helper.
  // No addTearDown(container.dispose) — that pattern is obsolete.
  final container = ProviderContainer.test(
    overrides: [
      databaseProvider.overrideWithValue(db),          // real in-memory sqlite3
      speechServiceProvider.overrideWithValue(fake),   // the one thing tests cannot run
    ],
  );
  // ...
});
```

Widget tests go through `pumpApp` in `test/support/harness.dart`, which supplies `speechServiceProvider.overrideWithValue(speech ?? FakeSpeechService())` and appends caller overrides after it, so a caller's override wins.

**Override the database with real in-memory SQLite (`NativeDatabase.memory()`), not a fake.** A Map-backed fake happily accepts a row the real `PRIMARY KEY (board_id, row_index, col_index)` rejects, and never executes a migration step. A botched migration destroys a hand-curated board — months of someone's phrases, irreplaceable and unmergeable. That outranks the "make fakes for testing" advice, which assumes the real dependency is a network. Here it is SQLite, which runs fine in a test.

**Do not write tests of the providers themselves.** Testing that `ref.watch` propagates tests the framework. Test the repository against real SQLite, the pure voice filter, and the widgets — and override the two seams to get there.
