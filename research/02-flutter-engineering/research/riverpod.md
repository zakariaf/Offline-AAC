# riverpod

> Phase: **research** · Agent `a89452388670d59cf` · Run `wf_12b14467-451`

## Result

## Summary

Riverpod 3 is stable and has been since 2025-09-10; current is flutter_riverpod 3.3.2 (2026-06-10), riverpod_lint 3.1.4. This matters more than usual because Riverpod 3 was a redesign, not a point release: essentially every Riverpod tutorial written before late 2025 — including Code With Andrea's canonical "Riverpod 2.0 Ultimate Guide" and the widely-copied `createContainer` + `addTearDown(container.dispose)` test helper — is now describing a dead API. The pinned decision (flutter_riverpod, acknowledged as not load-bearing, chosen for a testable repository/UI seam) survives contact with 3.x and I would keep it. But one of the three stated justifications for it is wrong and should be dropped: MediaQuery accessibility flags should NOT go through Riverpod. They are already an InheritedWidget, they are BuildContext-scoped, and routing them through a provider converts a correct-by-construction rebuild into a staleness bug — in an app where TextScaler handling *is* correctness. Read them at build time in the widget tree. The single most important 3.x finding for THIS app is that automatic retry is ON by default with exponential backoff. In an app with no network, a throwing provider means a corrupt DB or a missing file on disk — a real bug that retry will hide behind a permanent spinner, on a device whose developer will never receive a crash report. Disable it globally. Second most important: Riverpod 3 pauses providers whose only listeners are invisible widgets, so a `ref.listen` safety callback (e.g. "your TTS voice vanished") silently will not fire while the "show text" fullscreen mode covers the grid — a silent-failure vector that maps exactly to constraint #4. On codegen: the official docs explicitly do NOT recommend it as a default ("only if you already use code-generation for other things"). Drift already puts build_runner in the loop so the usual cost argument is weak here, but for six providers the payoff is still near zero and the `.g.dart` noise works against the "readable by a stranger" exit plan. Skip it — with one discipline cost noted below.

### Riverpod 3 is stable; flutter_riverpod 3.3.2 is current. Any tutorial predating 2025-09-10 describes a superseded API.

*Confidence: high, **LOAD-BEARING***

riverpod 3.0.0 stable released 2025-09-10. 3.1.0 (2025-12-26) added AsyncValue.requireValue sync-combining and Override.origin. 3.2.0 (2026-01-17) added Ref.isPaused, fixed Notifiers losing state on dependency change, and deprecated family.overrideWith in favour of family.overrideWith2. 3.3.2 (2026-06-10) is current: fixes unpause assertion errors and AsyncNotifierProvider/StreamNotifierProvider dependency disposal. riverpod_lint is at 3.1.4. Docs were restructured — the old /docs/concepts/* paths are 404 or stale; current content lives under /docs/concepts2/* and /docs/how_to/*.

- https://pub.dev/packages/flutter_riverpod

- https://pub.dev/packages/riverpod/changelog

- https://pub.dev/packages/riverpod_lint

- https://riverpod.dev/docs/whats_new

### Automatic retry is ON by default in Riverpod 3 and is actively harmful for this app. Disable it globally.

*Confidence: high, **LOAD-BEARING***

Riverpod 3 retries failing providers by default with exponential backoff starting at 200ms and doubling to 6.4s. The rationale is transient network failure — a failure mode this app does not have by construction. Here, a provider that throws means a corrupt DB, a missing image/sound file on disk, or a drift migration that went wrong. Retry converts that loud, diagnosable error into an indefinite loading state, on a device where the developer will never learn it happened (constraint #1). Disable with `retry: (retryCount, error) => null` on ProviderScope; the `Retry` typedef is `Duration? Function(int retryCount, Object error)` and returning null means do not retry. Secondary benefit: retry with a backoff Duration also breaks `tester.pumpAndSettle()` in widget tests, which times out waiting for a scheduler that never settles.

- https://riverpod.dev/docs/concepts2/retry

- https://riverpod.dev/docs/3.0_migration

- https://github.com/rrousselGit/riverpod/discussions/4431

### Riverpod 3 pauses providers whose only listeners are invisible widgets. This is a silent-failure vector for ref.listen-based safety warnings.

*Confidence: high, **LOAD-BEARING***

Providers used only by widgets that are not visible are paused by default, detected via Flutter's TickerMode. Pausing cascades: a provider listened to only by paused providers is itself paused. Concretely for this app: when the 'show text' fullscreen route covers the grid, the grid's providers pause. If a voice-availability warning is implemented as `ref.listen(voiceAvailabilityProvider, ...)` on the grid screen, that callback does not fire while paused — the user returns to the grid with a stale/absent warning and taps a tile that produces no speech. This is exactly constraint #4. Mitigation is architectural, not configurational: safety-critical checks belong at the speak() call site inside SpeechService, not in a screen-scoped ref.listen. `Ref.isPaused` (3.2.0+) exists if you need to reason about it; TickerMode can force resume.

- https://riverpod.dev/docs/whats_new

- https://riverpod.dev/docs/3.0_migration

### StateProvider, StateNotifierProvider and ChangeNotifierProvider are quarantined to a `legacy.dart` import, not deleted. Notifier/AsyncNotifier is the only current idiom.

*Confidence: high, **LOAD-BEARING***

In 3.0 these three moved out of the main barrel file into `package:flutter_riverpod/legacy.dart` (and `package:hooks_riverpod/legacy.dart`) and are explicitly discouraged. They still compile if you import legacy.dart — which is the trap: a 2023 tutorial's code will look almost right and the fix will look like 'add an import'. Don't. Use Notifier/AsyncNotifier/StreamNotifier. Related removal: FamilyNotifier, FamilyAsyncNotifier and FamilyStreamNotifier are gone — families now use the base classes with constructor parameters. ScopedProvider is removed (use Provider).

- https://riverpod.dev/docs/3.0_migration

- https://riverpod.dev/docs/whats_new

### The `.autoDispose` modifier and all AutoDispose* classes are gone. Manual providers default to autoDispose OFF via a new `isAutoDispose:` parameter; codegen defaults it ON.

*Confidence: high, **LOAD-BEARING***

Riverpod 2 duplicated every provider/Ref/Notifier for autoDispose (Ref vs AutoDisposeRef, Notifier vs AutoDisposeNotifier). 3.0 unified them; the old compile-time guard is now a riverpod_lint rule (avoid_keep_alive_dependency_inside_auto_dispose). Verified constructor signature: `Provider(Create<ValueT> _create, {String? name, Iterable<ProviderOrFamily>? dependencies, bool isAutoDispose = false, Retry? retry})`. So `Provider.autoDispose((ref) => x)` becomes `Provider((ref) => x, isAutoDispose: true)`. Note the asymmetry that bites: manual providers default to keeping state alive; `@riverpod`-generated ones default to disposing it. `ref.keepAlive()` returns a link with `.close()`, and disposal re-enables automatically on recompute.

- https://pub.dev/documentation/riverpod/latest/riverpod/Provider-class.html

- https://riverpod.dev/docs/concepts2/auto_dispose

- https://riverpod.dev/docs/3.0_migration

### The canonical test idiom changed: `ProviderContainer.test()` self-disposes. `createContainer` + `addTearDown(container.dispose)` is obsolete.

*Confidence: high, **LOAD-BEARING***

Added in 3.0.0-dev.12: 'Added ProviderContainer.test(). This is a custom constructor for testing purpose. It is meant to replace the createContainer utility.' The docs state plainly 'No need to dispose the container when the test ends.' This is the highest-traffic stale pattern in existing tutorials — the createContainer/addTearDown helper is copy-pasted across essentially every Riverpod testing article from 2022-2024 and is now pure ceremony. Also added in dev.12: `NotifierProvider.overrideWithBuild`, which mocks a Notifier's build() without replacing the notifier's methods — useful for seeding settings state without a fake class.

- https://riverpod.dev/docs/how_to/testing

- https://riverpod.dev/docs/concepts2/containers

- https://pub.dev/packages/riverpod/changelog

### `family.overrideWith` is deprecated as of 3.2.0 in favour of `family.overrideWith2`, and will be renamed back in 4.0.

*Confidence: high*

Changelog 3.2.0: 'Deprecated family.overrideWith in favour of family.overrideWith2. The behaviour is the same, but the callback now takes the argument as a parameter.' In 4.0.0 overrideWith2 will be renamed to overrideWith. This only matters if a family is used (e.g. a per-slot or per-board provider) AND it is overridden in tests. Given the recommendation below to avoid families entirely for a 12-tile fixed grid, this is likely avoidable — but it is a live deprecation warning if a family sneaks in.

- https://pub.dev/packages/riverpod/changelog

### Notifiers are now recreated on every provider rebuild. Holding a TTS controller, timer, or subscription as a Notifier field leaks.

*Confidence: high, **LOAD-BEARING***

Changelog 3.0.0-dev.12: 'Notifier and variants are now recreated whenever the provider rebuilds. This enables using Ref.mounted to check dispose.' The 2.x pseudo-singleton behaviour is gone. Directly relevant: SpeechService (flutter_tts wrapper) must NOT be constructed inside or owned by a Notifier — it belongs in a plain `Provider` with `ref.onDispose(() => service.dispose())`, injected via override at the ProviderScope root. `Ref.mounted` (analogous to BuildContext.mounted) now exists to guard post-await state writes.

- https://pub.dev/packages/riverpod/changelog

- https://riverpod.dev/docs/whats_new

### All providers now filter updates with `==`, and provider failures are wrapped in `ProviderException`. Both interact with drift.

*Confidence: medium, **LOAD-BEARING***

3.0 unified update filtering on `==` (2.x was inconsistent, notably for StreamProvider/StreamNotifier); override `Notifier.updateShouldNotify` to opt out. Drift interaction: drift's generated data classes DO override ==, so a settings row provider gets free rebuild suppression (good). But `List<T>` does not override == in Dart, so a `watch()` returning List<GridSlot> always compares unequal and always rebuilds — correct, just not free. Separately, provider failures are rethrown as `ProviderException` wrapping the original; the planned on-device exportable crash log must unwrap `.  ` to record the real error, or every logged entry will read 'ProviderException'.

- https://riverpod.dev/docs/3.0_migration

- https://riverpod.dev/docs/whats_new

- https://drift.simonbinder.eu/dart_api/streams/

### Official docs do NOT recommend code generation as the default — and most riverpod_lint rules are generator-only, which is the real (and only serious) argument for it here.

*Confidence: high, **LOAD-BEARING***

riverpod.dev on codegen: adopt it 'only if you already use code-generation for other things' like Freezed or json_serializable, and notes 'code generation is still fairly slow.' The honest tension for this project: drift ALREADY requires build_runner, so the marginal build cost of riverpod_generator is near zero — the usual con doesn't apply. And of riverpod_lint 3.1.4's ~15 rules, roughly 9 are generator-only (provider_dependencies, avoid_build_context_in_providers, unsupported_provider_value, functional_ref, notifier_extends, notifier_build, riverpod_syntax_error, scoped_providers_should_specify_dependencies, avoid_keep_alive_dependency_inside_auto_dispose). Given constraint #3 says enforce by lint not discipline, that's a genuine pull toward codegen. It still loses: those rules police codegen-specific footguns and multi-provider dependency graphs, neither of which a 6-provider hand-written app has. The rules that survive without codegen (missing_provider_scope, avoid_ref_inside_state_dispose, avoid_public_notifier_properties, async_value_nullable_pattern) are the ones that would actually catch a bug here.

- https://riverpod.dev/docs/concepts/about_code_generation

- https://pub.dev/packages/riverpod_lint

- https://riverpod.dev/docs/whats_new

### Routing MediaQuery accessibility flags through Riverpod is wrong, and the prior decision doc names this as a reason to adopt Riverpod. That specific justification should be dropped.

*Confidence: high, **LOAD-BEARING***

RESEARCH.md line 361 justifies Riverpod partly by 'clean reaction to MediaQuery a11y flags.' MediaQuery is already an InheritedWidget — it is already a reactive propagation mechanism with correct-by-construction invalidation. To get it into a provider you must either read BuildContext inside a provider (which riverpod_lint bans via avoid_build_context_in_providers, and which the FAQ calls out as putting logic in the UI layer) or push it in from a widget, which introduces a write-then-read ordering hazard and a stale value on the first frame after a settings change. For TextScaler at 200%+ — where being wrong is a total-failure a11y bug, not a cosmetic one — trading a compiler-guaranteed rebuild for a manual sync is a strictly bad trade. Read `MediaQuery.textScalerOf(context)` / `boldTextOf` / `accessibleNavigationOf` at build time in the widget that uses them. Riverpod's other two justifications (testable repository seam, TTS voice-availability changes) are sound and sufficient.

- https://riverpod.dev/docs/root/faq

- https://pub.dev/packages/riverpod_lint

- https://api.flutter.dev/flutter/widgets/MediaQuery/textScalerOf.html

### For this app Riverpod is mild, affordable ceremony — justified by the test seam alone, but only if usage stays at ~6 plain providers with zero families and zero scoping.

*Confidence: medium, **LOAD-BEARING***

Honest accounting. What Riverpod actually buys here: (1) override-based dependency injection at the ProviderScope root, which is the whole ballgame given tests are the only safety net — swapping a fake SpeechService and an in-memory drift DB is one line each; (2) AsyncValue's forced loading/error handling, which is a real anti-silent-failure lever; (3) drift .watch() → StreamProvider with caching and multi-listener support without broadcast-stream bookkeeping. What ValueNotifier/InheritedWidget would cost instead: you'd hand-roll a constructor-injected repository (fine, honestly — arguably MORE readable to a stranger), lose AsyncValue and re-derive loading/error by hand (this is where it starts losing), and use StreamBuilder directly (fine). Net: ValueNotifier + constructor injection is a genuinely defensible choice that would cost roughly a day less and read more plainly to a stranger. Riverpod's edge is AsyncValue discipline and override ergonomics in tests. It's close enough that the prior decision's 'don't spend a day on this' is correct — but the decision is only cheap if it stays minimal. Riverpod's cost curve is not in adoption, it's in the family/scoping/codegen/generated-lint stack that teams reach for. A fixed 3x4 grid keyed by (row, col) needs none of it.

- https://riverpod.dev/docs/concepts2/providers

- https://riverpod.dev/docs/how_to/testing

### The ref.watch/read/listen rules, and the one bug that actually bites in this app.

*Confidence: high, **LOAD-BEARING***

Rules: ref.watch in build() and in provider bodies — it subscribes and recomputes. ref.read only inside callbacks (onPressed, Notifier methods) — never in build(), because it takes no subscription and the value goes stale. ref.listen for side effects that are not state (snackbars, navigation, TTS triggers) — it must be called in build()/provider body, not in a callback. The bug that bites here: capturing a value from ref.watch in build() and using it inside an onPressed closure. On a rapid double-tap (plausible under distress — the exact user state this app targets) the closure can hold the pre-rebuild value and speak the previous tile's vocalization. Fix: read the vocalization inside the callback via ref.read at tap time, or better, pass the slot's (row, col) — which is the immutable primary key — into the callback and resolve at speak time. The DB schema already makes this trivial: position IS the key, so a coordinate can never go stale.

- https://github.com/rrousselGit/riverpod/issues/2426

- https://github.com/bizz84/flutter-tips-and-tricks/blob/main/tips/0046-riverpod-difference-between-ref-watch-ref-read-ref-listen/index.md

- https://riverpod.dev/docs/root/faq

## Recommendations

- **[must]** Set `retry: (retryCount, error) => null` on the root ProviderScope, and write a test asserting a throwing provider surfaces AsyncError rather than looping.
  - Riverpod 3 retries by default with 200ms→6.4s backoff. This app has no network; a throwing provider is a corrupt DB or a missing file — a real bug that must be loud. With no telemetry, a bug hidden behind a permanent spinner is a bug the developer will never learn about. Bonus: retry backoff makes pumpAndSettle() time out in widget tests.
- **[must]** Read MediaQuery accessibility flags (textScalerOf, boldTextOf, accessibleNavigationOf, disableAnimationsOf) directly in widget build() methods. Never put them in a provider, and never pass BuildContext to one.
  - MediaQuery is already an InheritedWidget with correct-by-construction invalidation. Wrapping it in a provider trades a compiler-guaranteed rebuild for a manual sync and a first-frame staleness bug — in the one area (TextScaler at 200%) where being wrong is total failure. Amend RESEARCH.md line 361: this is not a valid justification for Riverpod.
- **[must]** Never construct SpeechService, timers, or stream subscriptions inside a Notifier. Put them in a plain `Provider` with `ref.onDispose`, and inject via ProviderScope override at the root.
  - Riverpod 3 recreates Notifier instances on every provider rebuild (changelog 3.0.0-dev.12). Resources held as Notifier fields leak on each rebuild. A leaked flutter_tts engine is not a memory curiosity — it is a plausible route to a wedged TTS engine and no speech.
- **[must]** Use `ProviderContainer.test(overrides: [...])` in unit tests. Do not write a createContainer helper and do not call addTearDown(container.dispose).
  - ProviderContainer.test self-disposes; the docs say so explicitly. The createContainer + addTearDown pattern is in nearly every Riverpod testing article from 2022-2024 and is now obsolete ceremony. Getting this right at project start avoids propagating a stale idiom through the whole test suite — which, with no telemetry, is the entire safety net.
- **[must]** Do not import `package:flutter_riverpod/legacy.dart`. If a tutorial's code needs it, the tutorial is pre-3.0 — port it to Notifier/AsyncNotifier instead.
  - StateProvider/StateNotifierProvider/ChangeNotifierProvider still compile from legacy.dart, which makes the wrong fix (add an import) look like the right one. Treat the missing import as the API telling you the code is three years old.
- **[should]** Skip riverpod_generator and @riverpod. Write the ~6 providers by hand. Add riverpod_lint anyway.
  - Official docs don't recommend codegen by default. Drift already runs build_runner so the cost argument is weak — but for 6 providers the payoff is near zero, and .g.dart noise works against the open-source-and-abandon exit plan (constraint #5). riverpod_lint still earns its keep: missing_provider_scope, avoid_ref_inside_state_dispose, avoid_public_notifier_properties and async_value_nullable_pattern all work without codegen. Accept one discipline cost: you must remember `isAutoDispose:` explicitly, since manual providers default it to false while codegen defaults it to true.
- **[must]** Do not put safety-critical reactions (voice vanished, TTS engine died) in `ref.listen` on a screen-scoped provider. Check at the speak() call site inside SpeechService.
  - Riverpod 3 pauses providers whose only listeners are invisible widgets. When 'show text' fullscreen covers the grid, a grid-scoped ref.listen stops firing — the user returns and taps a tile into silence. Constraint #4 says silence must be impossible; the only place that can guarantee it is the code path that actually speaks.
- **[should]** Expose drift via `StreamProvider` wrapping `.watch()`, with `isAutoDispose: false` for the grid. Do not combine get() and watch().
  - Drift streams always emit a current snapshot on subscribe, so watch() alone is sufficient. The grid IS the app — it is never not needed, and tearing it down to rebuild it on every navigation is pointless churn on the one screen that must never be slow (zero-animation/latency rule). Use isAutoDispose: true only for edit-mode-scoped queries.
- **[should]** Use no provider families and no provider scoping. Key tile lookups by (row, col) from the already-loaded slot list.
  - A fixed 3x4 grid is 12 known positions. Families buy per-argument caching that a 12-element list does not need, and they drag in the overrideWith→overrideWith2 deprecation and the scoped_providers_should_specify_dependencies lint (generator-only, so unenforced here). Riverpod's real cost is not adoption, it's this stack. Staying flat is what makes the earlier 'don't spend a day on this' true.
- **[must]** Unwrap `ProviderException` before writing to the on-device exportable crash log.
  - Riverpod 3 rethrows provider failures wrapped in ProviderException. An unwrapped log records the wrapper, not the cause. Since this log is the ONLY channel through which a field failure can ever reach the developer (constraint #1), it recording 'ProviderException' for every entry would be a total loss of the one diagnostic that exists.
- **[avoid]** Never capture a ref.watch value in build() and use it inside an onPressed closure. Pass (row, col) into the callback and resolve the vocalization at tap time.
  - The captured value can be stale on rapid re-taps, causing the previous tile's vocalization to be spoken — the wrong sentence, out loud, to a stranger, on behalf of someone who cannot correct it verbally. The schema already makes the fix free: position is the primary key and can never go stale.
- **[should]** Treat any Riverpod source without a visible 2026-era date as wrong until verified against riverpod.dev/docs/concepts2/* and the pub.dev changelog.
  - Riverpod 3.0 (2025-09-10) was a redesign. Code With Andrea's 'Riverpod 2.0: The Ultimate Guide' and 'Unit Test AsyncNotifier with Riverpod 2.0' are still top search results and still teach createContainer/addTearDown, .autoDispose modifiers, and FamilyNotifier. The docs themselves moved from /docs/concepts/ to /docs/concepts2/ — a stale URL is a reliable staleness signal.

### Root: disable retry, inject the two seams

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AacDatabase(openConnection());
  final speech = FlutterTtsSpeechService();
  await speech.init(); // audio_session config + voice_filter run here

  runApp(
    ProviderScope(
      // Riverpod 3 retries failing providers by default (200ms -> 6.4s backoff).
      // This app has no network. A provider that throws means a corrupt DB or a
      // missing file on disk -- a real bug. Retrying hides it behind a permanent
      // spinner, on a device that will never send us a crash report. Fail loud.
      retry: (retryCount, error) => null,
      overrides: [
        databaseProvider.overrideWithValue(db),
        speechServiceProvider.overrideWithValue(speech),
      ],
      child: const AacApp(),
    ),
  );
}
```

`retry` is `Duration? Function(int retryCount, Object error)`; returning null disables. Also settable per-provider. Verified against riverpod.dev/docs/concepts2/retry.

### The six providers, hand-written, Riverpod 3 syntax

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Seams. Overridden at the root and in every test. -----------------------
// Throwing by default is deliberate: an un-overridden seam fails at the first
// read with a clear message, instead of silently constructing a real DB/TTS
// engine inside a unit test.
final databaseProvider = Provider<AacDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final speechServiceProvider = Provider<SpeechService>(
  (ref) => throw UnimplementedError('speechServiceProvider must be overridden'),
);

// --- Repository -------------------------------------------------------------
final boardRepositoryProvider = Provider<BoardRepository>(
  (ref) => BoardRepository(ref.watch(databaseProvider)),
);

// --- The grid. drift .watch() -> StreamProvider. ----------------------------
// isAutoDispose defaults to FALSE for manual providers in Riverpod 3 (codegen
// defaults it to true -- the asymmetry that bites). False is what we want: the
// grid IS the app, it is never not needed, and rebuilding it on every nav is
// pointless churn on the one screen that must never be slow.
//
// drift streams always emit a current snapshot on subscribe, so watch() alone
// is enough -- no need to combine get() and watch().
final gridSlotsProvider = StreamProvider<List<GridSlot>>(
  (ref) => ref.watch(boardRepositoryProvider).watchSlots(kDefaultBoardId),
);

// --- Settings ---------------------------------------------------------------
class SettingsNotifier extends AsyncNotifier<Settings> {
  @override
  Future<Settings> build() => ref.watch(boardRepositoryProvider).loadSettings();

  // NOTE: In Riverpod 3, Notifiers are recreated on every rebuild. Never cache
  // anything on `this` -- no timers, no controllers, no subscriptions.
  Future<void> setRate(double rate) async {
    await ref.read(boardRepositoryProvider).setRate(rate);
    if (!ref.mounted) return; // Ref.mounted is new in 3.x
    ref.invalidateSelf();
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
```

Six providers, no families, no scoping, no codegen. `Provider.autoDispose(...)` is gone in 3.x — it's `Provider(..., isAutoDispose: true)`.

### Unit test: ProviderContainer.test (no addTearDown)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('a tile speaks its vocalization, never its label', () async {
    final speech = FakeSpeechService();

    // ProviderContainer.test() disposes itself when the test ends.
    // Do NOT write a createContainer helper. Do NOT addTearDown(container.dispose).
    // That pattern is in every 2022-2024 tutorial and is obsolete as of 3.0.
    final container = ProviderContainer.test(
      overrides: [
        speechServiceProvider.overrideWithValue(speech),
        databaseProvider.overrideWithValue(inMemoryDb(seed: [
          GridSlot(row: 0, col: 0, button: Button(
            label: 'Overwhelmed',
            vocalization: "I need to leave, I'm not able to talk right now",
          )),
        ])),
      ],
    );

    final slots = await container.read(gridSlotsProvider.future);
    await container.read(speakSlotProvider)(row: 0, col: 0);

    expect(slots.single.button!.label, 'Overwhelmed');
    expect(speech.spoken, ["I need to leave, I'm not able to talk right now"]);
  });

  test('a provider failure surfaces as an error, and does NOT retry forever', () async {
    final container = ProviderContainer.test(
      overrides: [databaseProvider.overrideWithValue(CorruptDb())],
    );

    // With the root retry disabled this settles into an error immediately.
    // If this test ever hangs, someone re-enabled automatic retry.
    await expectLater(
      container.read(gridSlotsProvider.future),
      throwsA(isA<ProviderException>()),
    );
  });
}
```

Second test is the load-bearing one: it pins the retry:null decision so a future refactor can't silently undo it. Note failures arrive wrapped in ProviderException.

### Widget test: overrides + TextScaler at 200%

```dart
testWidgets('tiles are semantic and survive 200% text scale', (tester) async {
  tester.platformDispatcher.textScaleFactorTestValue = 2.0;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(inMemoryDb(seed: kSeedBoard)),
        speechServiceProvider.overrideWithValue(FakeSpeechService()),
      ],
      child: const AacApp(),
    ),
  );
  // Safe only because retry is disabled at the root -- a retrying provider
  // reschedules with a backoff Duration and pumpAndSettle() times out.
  await tester.pumpAndSettle();

  expect(find.bySemanticsLabel('Overwhelmed'), findsOneWidget);
  expect(tester.takeException(), isNull); // no overflow at 2.0x
});
```

addTearDown IS still correct here — for the test-value cleanup, not for container disposal.

### MediaQuery a11y flags stay in the widget tree — not in Riverpod

```dart
class PhraseTile extends ConsumerWidget {
  const PhraseTile({super.key, required this.row, required this.col});

  final int row;
  final int col;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A11y flags are read HERE, at build time, from the InheritedWidget that
    // already propagates them correctly. They do not belong in a provider:
    // that would mean either BuildContext inside a provider (lint-banned by
    // avoid_build_context_in_providers) or a manual push-and-sync that is stale
    // for one frame. Never clamp textScaler.
    final textScaler = MediaQuery.textScalerOf(context);
    final boldText = MediaQuery.boldTextOf(context);

    // App state comes from Riverpod. Platform a11y state comes from context.
    final slot = ref.watch(
      gridSlotsProvider.select((a) => a.valueOrNull?.at(row, col)),
    );

    return Semantics(
      button: true,
      label: slot?.button?.label ?? 'Empty tile, row $row column $col',
      child: InkWell(
        // Resolve at TAP time via ref.read, keyed by the immutable (row, col)
        // primary key. Capturing slot.vocalization from build() into this
        // closure would speak a stale sentence on a fast double-tap.
        onTap: slot?.button == null
            ? null
            : () => ref.read(speakSlotProvider)(row: row, col: col),
        child: Text(
          slot?.button?.label ?? '',
          textScaler: textScaler,
          style: TextStyle(
            fontWeight: boldText ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
```

The split to hold onto: app state via Riverpod, platform/a11y state via BuildContext. This contradicts RESEARCH.md line 361's stated justification for Riverpod.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PROJECT THESE PRACTICES ARE FOR ===

An offline AAC (augmentative & alternative communication) app for autistic adults with situational/part-time speech loss. Flutter, Android-first, iOS later. Solo developer. Today is 2026-07-15; Flutter stable is 3.44.0, Dart 3.x.

The app: ONE screen — a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface + on-device TTS. A "show text" full-screen mode. An explicit edit mode. Settings (voice/pitch/rate/output mode/theme). No accounts, no server, no network.

DECISIONS ALREADY MADE (from a prior deep research pass — do not re-litigate these, design practices AROUND them):
- **drift** (SQLite) for local DB. Schema: boards / buttons / grid_slots / images / sounds / settings. Critically, `grid_slots` has PRIMARY KEY (board_id, row, col) with a NULLABLE button_id — position IS the primary key, so tile reflow is structurally impossible. Data model borrows Open Board Format semantics (label != vocalization: the tile SHOWS "Overwhelmed" but SPEAKS "I need to leave, I'm not able to talk right now").
- **flutter_riverpod** for state — explicitly acknowledged as NOT load-bearing (12 tiles and a text field; ValueNotifier would work). Chosen for a testable seam between repository and UI, and to react to MediaQuery a11y flags + TTS voice-availability changes.
- **flutter_tts** wrapped behind an abstract `SpeechService` (speak/stop/voices), with a `voice_filter` (Android network_required check + setVoice return-value check — flutter_tts returns 0 with only a Log.d on failure, which would silently give a user in crisis NO SPEECH) and an `audio_session` config (iOS .playback + duckOthers; NEVER .ambient).
- Native platform channels needed for: Personal Voice (iOS), an Android Quick Settings TileService (Kotlin, speaks natively from SharedPreferences with NO Flutter engine on that path), an iOS 18 ControlWidget (Swift).
- Images/sounds are FILES ON DISK with paths in the DB, never BLOBs.

=== THE CONSTRAINTS THAT MAKE THIS PROJECT'S ENGINEERING UNUSUAL ===

1. **NO TELEMETRY, EVER.** No Firebase, no Crashlytics, no Sentry, no analytics — the privacy promise forbids it and the audience reads privacy labels adversarially. THE DEVELOPER WILL NEVER LEARN THAT THE APP CRASHED IN THE FIELD. Tests are the ONLY safety net. This should raise the bar on testing dramatically and change what is worth testing. There is a planned on-device-only, user-exportable crash log.
2. **A BOTCHED DB MIGRATION IS THE LOSS OF SOMEONE'S VOICE.** Users hand-curate phrase boards over months; that data is irreplaceable and unmergeable. Migration testing is a safety property, not hygiene.
3. **ACCESSIBILITY IS CORRECTNESS, NOT POLISH.** An inaccessible accessibility app is a total failure. Semantics on every tile; iOS Switch Control / Android Switch Access / VoiceOver / TalkBack must work; TextScaler must be honored at 200%+ and never clamped. This must be enforced by TESTS and lints, not by discipline.
4. **A SILENT FAILURE IS THE WORST BUG CLASS.** An unchecked setVoice return, a voice that vanished, an audio session misconfigured to .ambient so the silent switch mutes the app — each means a user taps a tile mid-shutdown and NOTHING happens. Error handling must make silence impossible.
5. **The developer may abandon this** (it is app #N of a 50-app challenge). The offline architecture means it keeps working unmaintained; open-sourcing is the exit plan. So the code must be READABLE BY A STRANGER and the docs must let someone else pick it up.
6. **Solo dev, ~2-week MVP.** Practices must be proportionate. Ceremony that a team needs and a solo dev doesn't is a real cost. Be honest about what to SKIP.
7. Zero animation is a design rule (distress + latency). Deterministic UI.

Today's date: 2026-07-15. Prefer 2025-2026 sources. Flutter and its ecosystem move fast — a 2022 blog post is probably wrong.


YOUR DIMENSION: Riverpod in 2026 — correct, current usage, and testing.

Research with WebSearch/WebFetch: riverpod.dev, pub.dev/packages/flutter_riverpod, Remi Rousselet's repo + changelogs, codewithandrea's Riverpod articles (check dates!), migration guides.

CRITICAL — establish the CURRENT VERSION and API. Riverpod 3.0 was in development; is it stable in 2026? What changed from 2.x → 3.x? What is DEPRECATED? Specifically:
- Is `StateProvider` / `StateNotifierProvider` / `ChangeNotifierProvider` deprecated or legacy now? What replaced them?
- `Notifier` / `AsyncNotifier` — current idiom?
- **riverpod_generator + @riverpod annotation vs manual providers** — is code generation now the recommended default? What does it cost (build_runner in the loop)? For a solo dev on a 6-provider app, is codegen worth it? Be honest.
- `ref.watch` vs `ref.read` vs `ref.listen` — the actual rules and the common bugs.
- Provider lifecycle: autoDispose (is it default in 3.x?), keepAlive, ref.onDispose.
- **Overriding providers in tests** — the exact idiom (ProviderContainer, ProviderScope overrides, container.read, addTearDown(container.dispose)). Give real test code.
- How to expose a Stream from drift into Riverpod correctly (drift's .watch() → StreamProvider).
- How to react to MediaQuery accessibility flags — should those go through Riverpod at all, or stay in the widget tree? Argue it.
- Common Riverpod anti-patterns and how they bite.
- Honest challenge: for THIS app (12 tiles, a text field, settings), is Riverpod justified, or is it ceremony? What is the minimal correct usage? What would ValueNotifier/InheritedWidget cost/save?

Give real, current, compiling code. Flag anything where 2023-era tutorials are now wrong.
````

</details>
