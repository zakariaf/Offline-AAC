---
name: reed-widget-test-harness
description: pumpApp, Device presets, and ProviderScope overrides for widget tests — pinning tester.view.physicalSize/devicePixelRatio, driving textScaler/boldText/accessibleNavigation through MediaQuery, pump versus pumpAndSettle, find.bySemanticsLabel versus find.byKey, and NativeDatabase.memory() versus an overridden gridProvider. Use when writing test/support/harness.dart, calling pumpWidget or pumpApp, overriding speechServiceProvider or databaseProvider, sizing a test surface, or reviewing a widget test for flake. Not for FakeSpeechService's internals or the voice_filter wire traps.
---

# The widget-test harness

Nobody will ever tell this app it broke. There is no telemetry, and a user
mid-shutdown cannot file a bug. The suite is the only feedback loop, so a test
that passes while checking nothing is worse than no test.

## One harness file, not a framework

Put it at `test/support/harness.dart`. Everything below belongs in that file;
tests import it and nothing else of their own.

```dart
// test/support/harness.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:offline_aac/app.dart';
import 'package:offline_aac/providers.dart';
import 'package:offline_aac/speech/speech_service.dart';

import 'fake_speech_service.dart';

/// physicalSize is in PHYSICAL pixels. `view.physicalSize = Size(320, 568)` at
/// the default DPR of 3.0 yields a 107x189 logical surface — not an iPhone SE.
/// Always multiply by the DPR.
class Device {
  const Device(this.name, this.logicalSize, this.dpr);

  final String name;
  final Size logicalSize;
  final double dpr;

  static const seLike = Device('se_like_320', Size(320, 568), 2.0);
  static const small = Device('small_360', Size(360, 800), 3.0);
  static const pixel7 = Device('pixel_7', Size(412, 915), 2.625);

  static const all = <Device>[seLike, small, pixel7];

  @override
  String toString() => name;
}

extension AacHarness on WidgetTester {
  void useDevice(Device d) {
    view.devicePixelRatio = d.dpr;
    view.physicalSize = d.logicalSize * d.dpr;
    addTearDown(view.reset);
  }

  Future<void> pumpApp({
    SpeechService? speech,
    List<Override> overrides = const <Override>[],
    TextScaler textScaler = TextScaler.noScaling,
    bool boldText = false,
    bool accessibleNavigation = false,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: <Override>[
          speechServiceProvider.overrideWithValue(speech ?? FakeSpeechService()),
          ...overrides,
        ],
        child: Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: textScaler,
              boldText: boldText,
              accessibleNavigation: accessibleNavigation,
            ),
            child: const AacApp(),
          ),
        ),
      ),
    );
    await pump();
  }
}
```

Four things in there are load-bearing and get "cleaned up" by anyone who does
not know why:

| Line | Why it must stay |
|---|---|
| `addTearDown(view.reset)` | A leaked view size poisons every later test in the file. Prefer `reset()` over the `resetPhysicalSize` / `resetDevicePixelRatio` pair — one call, nothing forgotten. |
| `MediaQuery` **above** `MaterialApp` | `pumpWidget` wraps the tree in a `View`, which inserts `MediaQuery.fromView`. `MaterialApp` inserts none of its own (`useInheritedMediaQuery` is gone), so this `MediaQuery` is the nearest ancestor and wins. Below `MaterialApp` it would be shadowed. |
| `Builder` + `MediaQuery.of(context).copyWith` | A bare `MediaQueryData()` zeroes the view-derived `size` and `padding` that `useDevice` just pinned — the test then measures a 0×0 screen and passes. |
| `overrideWithValue` | `overrideValue` does not exist. |

`tester.binding.window` is deprecated — never touch it. `tester.view` is the
current API and the only one that pairs with `reset()`.

## Pin the device on every layout test

The default widget-test surface is **800×600 logical** — wider than any phone and
shorter than most. Unpinned, tiles come out roughly twice as wide as shipped, all
text fits, the suite is green, and the 360pt phone in someone's hand is broken.
`useDevice` first, `pumpApp` second, in that order.

## `pump()`, never `pumpAndSettle()`

Zero animation is a design rule here, so state changes settle in one frame and
`pumpAndSettle`'s only job — waiting out animations — has nothing to wait for. It
carries a 10-minute default timeout and truncates its stack trace when it fires,
so it can only add flake and hide the cause.

Do not overstate the rule. `pump()` does **not** advance the fake clock. `Timer`,
`Future.delayed`, and debounces still need `pump(duration)` or `fakeAsync`.

> Ban `pumpAndSettle` as an *animation* wait. Use `pump()` for state changes and
> `pump(duration)` for time-based async.

## Driving MediaQuery

`textScaler`, `boldText`, and `accessibleNavigation` are named parameters on
`pumpApp` because they are real axes with real failures behind them:

- **`textScaler`** — `TextScaler.linear(2.0)`. Linear is a deliberate
  over-approximation: Android 14+ scales large text *less* than small text, so
  linear stresses big tile labels harder than a device would. Wanted
  conservatism; do not claim these tests are device-faithful.
- **`boldText`** — a first-class axis, not an afterthought. It widens glyphs and
  overflows tiles that pass unbolded at the same scale.
- **`accessibleNavigation`** — true means Switch Access / VoiceOver is on.

The other three flags belong to `copyWith` too, and each has a catch worth
knowing before adding a parameter for it:

| Flag | Verdict |
|---|---|
| `highContrast` | `AccessibilityFeatures.highContrast` is **iOS-only** and permanently false on Android — the entire target platform. The app's contrast switch is an in-app setting, so test it by overriding that setting's provider, not by faking this flag. Add a `highContrast:` parameter only if the app reads the flag opportunistically, and never let a test's pass depend on it. |
| `disableAnimations` | Moot — there are none. Testing it asserts nothing. |
| `invertColors` | The platform inverts at composite, below the widget tree. Nothing in a widget test observes the result. Skip it. |

Do not widen `pumpApp`'s signature speculatively. Every parameter is a promise
that some test drives it.

## Finders that survive refactors

| Purpose | Finder | Why |
|---|---|---|
| Behaviour (tap, speak) | `find.bySemanticsLabel('Overwhelmed')` | Names behaviour, not tree structure. Survives layout refactors, and can genuinely be written before the widget. |
| Geometry (position, size) | `find.byKey(ValueKey<String>('slot_${r}_$c'))` | Position IS the primary key of a fixed grid. Assert on it by name. |
| A tile | **Never `find.byType`** | Couples the test to the class hierarchy; renaming a private widget reds the suite for no reason. |

## Asserting a tap actually speaks

`FakeSpeechService` records into `spoken`, so it is a spy as well as a fake.
Assert on *what* was spoken — never merely that `speak` was called.

```dart
testWidgets('tapping a tile speaks the VOCALIZATION, never the label',
    (WidgetTester tester) async {
  final FakeSpeechService speech = FakeSpeechService();
  await tester.pumpApp(speech: speech);

  await tester.tap(find.bySemanticsLabel('Overwhelmed'));
  await tester.pump();

  expect(find.text('Overwhelmed'), findsOneWidget);   // the tile SHOWS this
  expect(speech.spoken, <String>[_kVocalization]);    // and SAYS the sentence
});
```

Swapping those two strings is a silent, plausible-looking regression that no type
checker catches and no user will report — because they cannot speak. This
assertion is the reason the suite exists.

Drive failure worlds with the fake's `env` field (`SpeechEnv.noEngineInstalled`,
`zeroVoices`, `setVoiceReturnsZero`, `engineTimesOut`, …) and assert the UI goes
**loud**. `SpeechEnv.reportedSuccessButSilent` is the one world no test can
observe — the engine returns success and no audio leaves the phone. Never write a
widget test that claims to cover it.

## In-memory drift, or a faked repo?

**Default: override `gridProvider` with a fixed `BoardGrid`.** Reach for a real
in-memory database only in tests that assert an *edit writes and reads back*.

```dart
// Layout, a11y, speech — the fixture is the point, the DB is not.
await tester.pumpApp(overrides: <Override>[
  gridProvider.overrideWith((ref) => Stream<BoardGrid>.value(kTestGrid)),
]);
```

Three reasons, in order of force:

1. **`flutter test` runs in a plain Dart VM, where `sqlite3_flutter_libs` does
   nothing.** macOS falls back to a system libsqlite3 older than the bundled one;
   Ubuntu needs `libsqlite3-dev` installed first. Binding the whole widget suite
   to that means a stranger who clones and runs `flutter test` sees a wall of red
   and concludes the repo is broken.
2. **A drift stream under `FakeAsync` is a flake generator.** drift keeps an
   unsubscribed query stream open for one event-loop iteration that never arrives
   under the test clock, so any DB-backed widget test needs
   `closeStreamsSynchronously: true` on its `DatabaseConnection` and still emits
   an `AsyncValue.loading` frame that a single `pump()` will show as a spinner
   instead of the grid — a green test asserting on an empty screen.
3. The grid's reflow guarantee lives in `PRIMARY KEY (board_id, row, col)` and is
   already proven by the database tests. Re-proving it through the widget layer
   buys nothing and costs seconds off a budget that must stay under 30s total.

When a test genuinely needs the real thing, use the real `AppDatabase` — never a
bare connection, because `beforeOpen` is where foreign-key enforcement is turned
on and skipping it lets FK-violating code pass green:

```dart
AppDatabase(DatabaseConnection(
  NativeDatabase.memory(),
  closeStreamsSynchronously: true, // REQUIRED under a widget test's clock
))
```

Override `databaseProvider` with it; `boardRepositoryProvider` and `gridProvider`
compose off it for free. Both seams throw `UnimplementedError` unless overridden,
by design — an un-overridden seam fails loudly rather than quietly constructing a
real TTS engine inside a test.

## Overflow: it already fails — do not break the net

A `RenderFlex` overflow **fails a widget test by default**. It is not merely
logged: the overflow indicator routes through `FlutterError.reportError`, the
test binding captures it, and `testWidgets` rethrows at test end. So the rule is
inverted from the folklore:

> **Never call `takeException()` to swallow an overflow, and never assign
> `FlutterError.onError`, in a layout test.** The popular `ignoreOverflowErrors`
> helper is exactly how this net gets lost.

Three traps that make an overflow suite pass while checking nothing:

1. The 800×600 default surface. Pin a `Device`.
2. **Overflow is reported once per RenderObject** — the flag resets only on
   `reassemble()`. Looping scales *inside* one `testWidgets` silently
   under-reports every scale after the first. **Generate one `testWidgets` per
   tuple**, in a `for` loop around the `testWidgets` call, not inside it.
3. **It only reports if the widget PAINTS.** `Offstage` subtrees and content
   scrolled outside a viewport never report. (Clipped content still does.) The
   fixed grid is fine, but **show-text mode and edit mode need their own pumped
   tests** — a board test will never cover them.

The matrix is `Device.all` × `[1.0, 1.3, 1.5, 2.0, 3.0]` × `[false, true]` bold.
1.3 and 1.5 are in the list precisely because nonlinear device scaling makes the
mid-range the non-obvious part.

## The tests worth writing for 12 tiles

| Test | What it defends |
|---|---|
| Tap speaks the vocalization, tile shows the label | The one thing that must never silently invert. |
| Overflow matrix, one `testWidgets` per (device, scale, bold) | Text that does not fit is a tile that cannot be read mid-shutdown. |
| `getRect` grid invariant at 2.0x: tiles in a row share a `top`, tiles in a column share a `left` (`moreOrLessEquals`, `epsilon: 0.5`) | Reflow moves a tile under someone's muscle memory. **This replaces goldens.** |
| An empty slot still occupies its cell (`width > 0`) | `grid_slots.button_id` is nullable; a collapsed cell drags the next tile into its position. |
| Tap-target geometry ≥ 76×76 dp at 2.0x on `Device.seLike`, measured with `getSize` | The real gate. `MinimumTapTargetGuideline` skips nodes flush with the view edge — 10 of the 12 tiles. |
| Semantic label is the display label and does **not** contain the vocalization | Otherwise a screen-reader user hears a whole sentence on every scan step. |
| Text grows `> base * 1.8` at 2.0x | Catches a `TextScaler` clamp added to keep the grid tidy. Contrast and tap-target both still pass while text stops growing. |
| Show-text mode and edit mode, pumped separately | They do not paint under a board test, so they have no overflow coverage otherwise. |

And what is **not** worth writing:

- **Goldens.** Decided: none for v1. Everything a golden catches here — text not
  fitting, tiles reflowing — is caught by the overflow matrix and the `getRect`
  invariants, more cheaply and with a readable failure message. Goldens add
  binary blobs, churn on every padding tweak, and a stranger running the suite on
  Linux against macOS-generated goldens sees red and walks away.
- **Riverpod plumbing.** Overriding a provider and asserting it overrode tests
  the framework.
- **Rebuild counts, `RepaintBoundary`, frame timing.** Every one is a jank
  remedy. A static grid with zero animation renders one frame and stops. There is
  no frame budget to miss — this is the largest available sink of wasted effort
  here.
