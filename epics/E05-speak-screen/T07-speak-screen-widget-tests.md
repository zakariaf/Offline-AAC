# E05-T07 — Speak-screen widget tests

| | |
|---|---|
| **Epic** | E05 — The speak screen |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E05-T04 |
| **Blocks** | E10-T01, E10-T02, E10-T04 |

**Skills:** `reed-widget-test-harness` · `reed-text-scale-testing` · `reed-a11y-testing` · `reed-testing-strategy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Nobody will ever tell this app it broke. There is no telemetry, and a user mid-shutdown cannot file a bug report — the suite is the only feedback loop that will ever exist. Two failures matter here and neither is visible from the code: a tile that speaks the wrong string (or nothing), and a label that is clipped at 200% text scale on a 360dp phone. Both ship green unless this suite catches them.

## Scope

Build the shared harness, then the three widget suites that stand on it.

### 1. `test/support/harness.dart` — one file, not a framework

Tests import this and nothing else of their own. It contains exactly two things: `Device` and the `AacHarness` extension on `WidgetTester`.

```dart
class Device {
  const Device(this.name, this.logicalSize, this.dpr);
  final String name;
  final Size logicalSize;
  final double dpr;

  static const seLike  = Device('se_like_320', Size(320, 568), 2.0);
  static const small   = Device('small_360',   Size(360, 800), 3.0);
  static const pixel7  = Device('pixel_7',     Size(412, 915), 2.625);
  static const all = <Device>[seLike, small, pixel7];

  @override
  String toString() => name;
}

extension AacHarness on WidgetTester {
  void useDevice(Device d) {
    view.devicePixelRatio = d.dpr;
    view.physicalSize = d.logicalSize * d.dpr;   // physicalSize is PHYSICAL px
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

Four lines are load-bearing and will get "cleaned up" by anyone who does not know why. Comment each in the file:

| Line | Why it stays |
|---|---|
| `addTearDown(view.reset)` | A leaked view size poisons every later test in the file. `reset()` over the `resetPhysicalSize` / `resetDevicePixelRatio` pair — one call, nothing forgotten. |
| `MediaQuery` **above** `MaterialApp` | `pumpWidget` wraps the tree in a `View`, inserting `MediaQuery.fromView`. `MaterialApp` inserts none of its own (`useInheritedMediaQuery` is gone), so this is the nearest ancestor and wins. Below `MaterialApp` it is shadowed. |
| `Builder` + `MediaQuery.of(context).copyWith` | A bare `MediaQueryData()` zeroes the view-derived `size` and `padding` that `useDevice` just pinned. The test then measures a 0×0 screen and passes. |
| `overrideWithValue` | `overrideValue` does not exist. |

`tester.binding.window` is deprecated — never touch it. `tester.view` is the current API and the only one that pairs with `reset()`.

**Default fixture: override `gridProvider` with a fixed `BoardGrid`.** No real database in this task.

```dart
await tester.pumpApp(overrides: <Override>[
  gridProvider.overrideWith((ref) => Stream<BoardGrid>.value(kTestGrid)),
]);
```

`flutter test` runs in a plain Dart VM where `sqlite3_flutter_libs` does nothing — macOS falls back to a system libsqlite3 older than the bundled one, Ubuntu needs `libsqlite3-dev` first. Binding this suite to that means a stranger who clones and runs `flutter test` sees a wall of red. A drift stream under `FakeAsync` also emits an `AsyncValue.loading` frame that a single `pump()` renders as a spinner — a green test asserting on an empty screen.

Do not widen `pumpApp`'s signature speculatively. Every parameter is a promise that some test drives it. `highContrast` is iOS-only and permanently false on Android; `disableAnimations` is moot; `invertColors` happens below the widget tree. None get a parameter.

### 2. `test/ui/speak_test.dart` — a tap SPEAKS

`FakeSpeechService` records into `spoken`, so it is a spy as well as a fake. Assert on **what** was spoken, never merely that `speak` was called.

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

Swapping those two strings is a silent, plausible-looking regression that no type checker catches and no user will report — because they cannot speak. This assertion is why the suite exists.

Also assert here: the semantic label is the display label and does **not** contain the vocalization (`node.label`, `isNot(contains(t.vocalization))`) — otherwise a screen-reader user hears a whole sentence on every scan step. Use `tester.getSemantics(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')))` and `isSemantics(...)`, never `containsSemantics` (deprecated after v3.40.0-1.0.pre).

**`pump()`, never `pumpAndSettle()`.** Zero animation is a design rule, so state changes settle in one frame and `pumpAndSettle`'s only job has nothing to wait for. It carries a 10-minute default timeout and truncates its stack trace when it fires — it can only add flake and hide the cause. Do not overstate the rule: `pump()` does not advance the fake clock, so a `Timer`, `Future.delayed`, or debounce still needs `pump(duration)` or `fakeAsync`.

### 3. `test/ui/overflow_matrix_test.dart` — the scale matrix

`Device.all` × `[1.0, 1.3, 1.5, 2.0, 3.0]` × `[false, true]` bold = **30 tests**, one frame each.

```dart
const List<double> scales = <double>[1.0, 1.3, 1.5, 2.0, 3.0];

for (final Device device in Device.all) {
  for (final double scale in scales) {
    for (final bool bold in <bool>[false, true]) {
      testWidgets('board: no overflow @ $device x$scale${bold ? ' bold' : ''}',
          (WidgetTester tester) async {
        tester.useDevice(device);
        await tester.pumpApp(
          textScaler: TextScaler.linear(scale),
          boldText: bold,
        );
        expect(tester.takeException(), isNull,
            reason: 'tile text overflowed at $device x$scale');
      });
    }
  }
}
```

1.3 and 1.5 are in the list precisely because nonlinear device scaling makes the mid-range the non-obvious part. 3.0 is Larger Accessibility Sizes territory. `TextScaler.linear` is a deliberate over-approximation — Android 14+ scales large text *less* than small text, so linear stresses big tile labels harder than a device would. That conservatism is wanted; do not claim these tests are device-faithful. `boldText` is a first-class axis: it widens advance widths, and a tile that fits at 2.0x unbolded can overflow at 2.0x bold.

### 4. The mechanic that decides whether the matrix is worth anything

**`RenderFlex` overflow already FAILS a widget test by default.** It is not merely a yellow-black banner and a log line: `DebugOverflowIndicatorMixin._reportOverflow` calls `FlutterError.reportError`, `TestWidgetsFlutterBinding` captures it into `_pendingExceptionDetails`, and `testWidgets` rethrows at test end unless something clears it. The entire blog genre on this topic is about how to **suppress** it.

So the job inverts from the intuition: **never lose the net that already exists**, and make that structural rather than per-test discipline — discipline is exactly what a no-telemetry app cannot rely on. Add the suite-wide grep in `test/policy/no_text_clamping_test.dart`:

```dart
test('test/ never suppresses overflow', () {
  const List<String> forbidden = <String>[
    'ignoreOverflowErrors',
    'FlutterError.onError =',
  ];
  // Walk Directory('test') recursively; collect offenders; expect(offenders, isEmpty).
  // A single hit disarms the whole matrix.
});

test('lib/ never clamps or overrides text scaling', () {
  const List<String> forbidden = <String>[
    'withClampedTextScaling', // clamps TextScaler — violates the a11y contract
    'textScaleFactor',        // deprecated, and almost always a clamping hack
    'FittedBox',              // auto-shrink; makes the longest phrase the smallest
  ];
  // Same walk over Directory('lib').
});
```

**The loud class is not enough.** A clipped `Text` reports nothing, ever — `RenderParagraph` has no overflow indicator, so a label running past a fixed-height `SizedBox` + clip produces zero errors, a green test, and unreadable words on a real phone. Only a `Flex` child reports. `takeException(), isNull` is necessary and **not sufficient**.

### 5. `test/ui/label_fit_test.dart` — the real gate

```dart
int linesOf(WidgetTester tester, String label) => tester
    .renderObject<RenderParagraph>(find.text(label))
    .computeLineMetrics()
    .length;

for (final double scale in <double>[1.0, 1.3, 1.5, 2.0, 3.0]) {
  testWidgets('every starter label fits its tile @ x$scale',
      (WidgetTester tester) async {
    tester.useDevice(Device.small); // 360x800: the tightest shipped 3x4
    await tester.pumpApp(textScaler: TextScaler.linear(scale));

    expect(tester.takeException(), isNull); // the loud class

    for (final TestTile t in kTestTiles) {
      final Rect slot =
          tester.getRect(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')));
      final Size text = tester.getSize(find.text(t.label));

      // Tile inset is 16dp every side. Label is bottom-anchored, start-aligned;
      // overrun leaves NO exception, only clipped words.
      expect(text.height, lessThanOrEqualTo(slot.height - 32.0),
          reason: '"${t.label}" needs ${text.height}dp inside a '
              '${slot.height}dp tile at x$scale — it is being clipped silently');
      expect(text.width, lessThanOrEqualTo(slot.width - 32.0),
          reason: '"${t.label}" is ${text.width}dp wide at x$scale');

      // A literal \n in a shipped label is a HINT: past 3 lines the layout falls
      // back to natural wrap. Assert the ceiling holds.
      expect(linesOf(tester, t.label), lessThanOrEqualTo(3),
          reason: '"${t.label}" wrapped to >3 lines at x$scale');
    }
  });
}
```

Plus two invariants in the same file:

- **Grid geometry at 2.0x** (`Device.small`): tiles in a row share a `top`, tiles in a column share a `left`, via `getRect` and `moreOrLessEquals(..., epsilon: 0.5)`. **This replaces goldens** and fails with a sentence a human can read. Reflow moves a tile under someone's muscle memory.
- **An empty slot still occupies its cell** (`width > 0`). `grid_slots.button_id` is nullable; a collapsed cell drags the next tile into its position.
- **Anti-clamp:** `base = getSize(find.text('Overwhelmed')).height` unscaled, `scaled` at `TextScaler.linear(2.0)`, `expect(scaled, greaterThan(base * 1.8))`. 1.8 not 2.0 tolerates line-height rounding while still failing hard on a clamp. The grep catches the named API; this catches a clamp built by hand.

### Finders

| Purpose | Finder |
|---|---|
| Behaviour (tap, speak) | `find.bySemanticsLabel('Overwhelmed')` — names behaviour, survives layout refactors |
| Geometry (position, size) | `find.byKey(ValueKey<String>('slot_${r}_$c'))` — position IS the primary key of a fixed grid |
| A tile | **Never `find.byType`** — couples the test to the class hierarchy |

### Out of scope

- **Goldens.** Decided: none for v1. Everything a golden catches here is caught by the overflow matrix and the `getRect` invariants, more cheaply and with a readable message. Goldens add binary blobs, churn on every padding tweak, and a stranger running the suite on Linux against macOS-generated goldens sees red and walks away.
- **Show-text mode and edit mode.** They do not paint under a board test, so they need their own pumped matrices — separate tasks, not this file.
- **Real drift / `NativeDatabase.memory()`.** Only for tests that assert an edit writes and reads back.
- **`meetsGuideline`, traversal order, contrast, tap-target geometry.** They belong to the a11y suite (`test/ui/a11y_test.dart`), not here.
- **Riverpod plumbing, rebuild counts, `RepaintBoundary`, frame timing.** Every one is a jank remedy; a static grid with zero animation renders one frame and stops.

## Acceptance criteria

- [ ] `test/support/harness.dart` exists and exports `Device` (`seLike` 320×568 @2.0, `small` 360×800 @3.0, `pixel7` 412×915 @2.625, and `all`) and `AacHarness` with `useDevice` and `pumpApp`.
- [ ] `flutter test test/ui/overflow_matrix_test.dart` reports exactly **30** tests, all passing.
- [ ] `grep -rn "pumpAndSettle" test/` returns nothing.
- [ ] `grep -rn "find.byType" test/ui/` returns no tile finder.
- [ ] `grep -rn "ignoreOverflowErrors\|FlutterError.onError =" test/` returns nothing, and `test/policy/no_text_clamping_test.dart` asserts this and passes.
- [ ] The speak test asserts `speech.spoken` equals the vocalization list — not `isNotEmpty`, not a call count.
- [ ] Deliberately breaking it proves the net: shorten one tile's height in `lib/`, run the matrix, watch a specific `(device, scale, bold)` test go red with a readable message. Revert.
- [ ] Deliberately lengthen one starter label to 40 characters; `label_fit_test.dart` fails on the width or line-count assertion, not on `takeException`. Revert.
- [ ] `flutter analyze` is clean.
- [ ] The full `flutter test` run stays under 30 s.

## Traps

- **The scope brief you were handed says overflow does not fail by default and must be made to fail. That is wrong** — verify it against `reed-text-scale-testing` before writing any `FlutterError.onError` wiring. The net exists; the work is refusing to break it. Anyone who "adds overflow failing" by assigning `FlutterError.onError` has just disarmed the binding's own capture.
- **`takeException()` in a global `tearDown`** clears `_pendingExceptionDetails` before `testWidgets` rethrows, silently converting the whole suite's overflow net into a no-op. One line, whole suite gone.
- **Overflow is reported ONCE per `RenderObject`.** `_overflowReportNeeded` goes false after the first report and resets only on `reassemble()`. Looping scales *inside* one `testWidgets` silently under-reports every scale after the first. The `for` loop goes **around** the `testWidgets` call, never inside it.
- **It only reports if the widget PAINTS.** `Offstage` subtrees and content scrolled outside a viewport never report. (Clipped content still does — `RenderFlex` paints the indicator after pushing its own clip.) The fixed grid is fine; show-text and edit mode are not covered by any board test.
- **The 800×600 default surface.** Wider than any phone and shorter than most. Unpinned, tiles come out roughly twice as wide as shipped, all text fits, the suite is green, and the 360dp phone in someone's hand is broken. `useDevice` first, `pumpApp` second, in that order.
- **`physicalSize` is in physical pixels.** `view.physicalSize = Size(320, 568)` at the default DPR of 3.0 yields a 107×189 logical surface — not a small phone. Always multiply by the DPR; `useDevice` does.
- **A bare `MediaQueryData()`** zeroes the view-derived `size` and `padding` and the test measures a 0×0 screen — green, meaningless.
- **The four wrong fixes for a red matrix.** Each turns the test green and the product worse: `MediaQuery.withClampedTextScaling` / `textScaleFactor` (defeats the entire matrix and overrides the user's own OS setting — the setting they need); `FittedBox` or any auto-shrink (makes the longest, most complex phrase the smallest and silently cancels the user's TextScaler); `TextOverflow.ellipsis` or `maxLines` truncation (an ellipsis on an AAC utterance is a **different utterance** — the editor refuses at 16 characters instead; nothing truncates at render time); a smaller font on the offending tile (one uniform size across all 12 is load-bearing — variable line count reads fine, variable size reads as broken). The legitimate resolutions: shorten the `label` (the tile is a *handle*; the sentence lives in `says`), add a hand-set `\n`, adjust the shared tile type role, or accept the 6-tile layout.
- **`containsSemantics`** is deprecated after v3.40.0-1.0.pre; virtually every tutorial predates this. Use `isSemantics`.
- **Semantics is ON by default** in widget tests — `testWidgets` takes `semanticsEnabled = true` and calls `ensureSemantics()` for you. The manual `ensureSemantics()` / `dispose()` pair is a redundant second handle here. If ever needed, `addTearDown(handle.dispose)`, never a trailing `handle.dispose()` — teardown survives a throwing `expect()`, and a leaked `SemanticsHandle` is itself a flake source.
- **`SpeechEnv.reportedSuccessButSilent` is unobservable** — the engine returns success and no audio leaves the phone. Never write a widget test that claims to cover it.

## Files

- `test/support/harness.dart` — new
- `test/support/fake_speech_service.dart` — consumed (from the speech epic); not authored here
- `test/support/tiles.dart` — new or extended: `kTestTiles` (`row`, `col`, `label`, `vocalization`, `priority`), `kTestGrid`
- `test/ui/speak_test.dart` — new
- `test/ui/overflow_matrix_test.dart` — new
- `test/ui/label_fit_test.dart` — new
- `test/policy/no_text_clamping_test.dart` — new

## Done when

`flutter test` runs the harness-backed speak, overflow-matrix and label-fit suites green in under 30 s, a deliberately clipped label turns a named `(device, scale, bold)` test red with a readable message, and the policy grep fails the build if anyone reintroduces overflow suppression or text clamping.
