# widget-golden-testing

> Phase: **research** · Agent `a10d5bca220ef2210` · Run `wf_12b14467-451`

## Result

## Summary

Two premises in the brief are inverted, and both matter. (1) RenderFlex overflow DOES fail a widget test by default — it is not merely logged. DebugOverflowIndicatorMixin._reportOverflow calls FlutterError.reportError; the test binding captures it into _pendingExceptionDetails and testWidgets rethrows at test end unless takeException() is called. The entire blog genre on this topic is about how to SUPPRESS overflow failures. So "assert nothing overflows" is free — you just must not silence it. (2) The real trap is the default test surface: 800x600 logical, wider than any phone. An overflow suite that never sets tester.view tests a screen no user owns and passes while the real 360pt phone is broken. Every text-scale test MUST pin a real device size. Corrections: golden_toolkit is confirmed DISCONTINUED on pub.dev (last publish ~3 years ago); alchemist is alive (0.14.0) but is published by Betterment, NOT Very Good Ventures as the brief states — and its CI goldens obscure text into colored boxes, destroying the exact signal this app needs. The default test font is FlutterTest, not Ahem (engine PR #40245) — fluttergoldens.com's docs are stale here. A MediaQuery placed ABOVE MaterialApp now works: useInheritedMediaQuery is gone and MaterialApp never inserts its own MediaQuery — the View does. Verdict: build a text-scale × device × theme overflow matrix (text-based, platform-independent, near-zero maintenance) and SKIP the golden regression suite for the MVP.

### A RenderFlex overflow FAILS a widget test by default; it does not merely log

*Confidence: high, **LOAD-BEARING***

RenderFlex computes _overflow in performLayout (bool get _hasOverflow => _overflow > precisionErrorTolerance) but REPORTS during paint() via DebugOverflowIndicatorMixin.paintOverflowIndicator -> _reportOverflow -> FlutterError.reportError. TestWidgetsFlutterBinding overrides FlutterError.onError, stores FlutterErrorDetails in _pendingExceptionDetails, and rethrows at test completion unless takeException() clears it. Confirmed by reading debug_overflow_indicator.dart, flex.dart and flutter_test/binding.dart, and corroborated by the many blog posts teaching an 'ignoreOverflowErrors' helper (FlutterError.onError = ignoreOverflowErrors) to make tests pass despite overflow.

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/binding.dart

- https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/flex.dart

- https://dev.to/remejuan/widget-testing-dealing-with-renderflex-overflow-errors-hlg

### The default widget-test surface is 800x600 logical — bigger than any phone — so an unpinned overflow test is near-worthless

*Confidence: high, **LOAD-BEARING***

flutter_test defaults to physicalSize 2400x1800 with devicePixelRatio 3.0 => 800x600 logical. A 3x4 grid at 800 logical width gives ~260pt-wide tiles; at a real 360pt phone the tiles are ~115pt. Text that fits at 200% scale in the default surface overflows on the real device. Every scale test must set tester.view.physicalSize/devicePixelRatio to a real profile (e.g. 320x568 as worst case, 412x915 Pixel).

- https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html

- https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding/setSurfaceSize.html

### Overflow is reported only ONCE per RenderObject, so looping text scales inside one testWidgets under-reports

*Confidence: high, **LOAD-BEARING***

DebugOverflowIndicatorMixin guards with a _overflowReportNeeded flag: set false after the first report, reset only on reassemble(). If a test loops scales 1.0/2.0/3.0 against the same render tree and calls takeException() per iteration to collect failures, only the FIRST overflow reports — later scales silently 'pass'. Fix: generate one testWidgets per (device x scale x theme) so each gets a fresh render tree.

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart

### Overflow only reports if the widget actually PAINTS

*Confidence: high, **LOAD-BEARING***

The report fires from paint(), not performLayout(). Anything Offstage, inside a lazy list beyond the viewport, or clipped away never reports. For this app's fixed, fully-painted 3x4 grid this is fine — but it means the 'show text' fullscreen mode and edit mode need their own pumped tests; they will not be covered by a board test.

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart

### golden_toolkit is DISCONTINUED; alchemist is maintained but is Betterment's, not Very Good Ventures'

*Confidence: high, **LOAD-BEARING***

pub.dev shows golden_toolkit explicitly marked discontinued, v0.15.0, last published ~3 years ago, with no suggested replacement. alchemist: v0.14.0 published ~4 months ago, verified publisher betterment.dev, 160 pub points, 220 likes, ~305k weekly downloads. The brief's attribution of alchemist to Very Good Ventures is incorrect.

- https://pub.dev/packages/golden_toolkit

- https://pub.dev/packages/alchemist

- https://github.com/Betterment/alchemist

### alchemist's CI goldens obscure text into colored boxes — which destroys the only signal this app would want from a golden

*Confidence: high, **LOAD-BEARING***

alchemist splits Platform goldens (readable text, renderShadows: true, only stable on the machine that made them) from CI goldens (obscureText: true by default -> text replaced with opaque colored rectangles; renderShadows: false; forced Ahem). CI goldens are platform-stable precisely BECAUSE they throw away glyph rendering. For an app whose golden question is 'does the label still fit and read at 200% scale', a CI golden answers a question you did not ask.

- https://github.com/Betterment/alchemist

### The default test font is FlutterTest, not Ahem — most golden docs (incl. fluttergoldens.com) are stale on this

*Confidence: high*

Engine PR #40245 ('Reland: Make FlutterTest the default test font') made FlutterTest the default when fontFamily is unspecified or unregistered. Ahem remains available if explicitly named. FlutterTest has 1024 units-per-em (a power of 2, less precision loss) and ascent/descent 0.75/0.25em vs Ahem's 0.8/0.2em. Visually both render box glyphs — so the 'goldens show boxes' symptom is unchanged, and loadAppFonts is still the fix, but the metrics differ, which matters if you ever compare against old goldens.

- https://github.com/flutter/engine/pull/40245

- https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Flutter-Test-Fonts.md

- https://fluttergoldens.com/flutters-implementation/load-fonts-and-icons/

### Font loading in goldens is NOT automatic in 2026; it still requires an explicit FontLoader call in flutter_test_config.dart

*Confidence: high, **LOAD-BEARING***

You must call loadAppFonts() (parses FontManifest.json, registers each family via FontLoader) and separately loadMaterialIconsFont() (locates the MaterialIcons font in the Flutter cache) from a testExecutable in test/flutter_test_config.dart. Now that golden_toolkit is discontinued, the maintained sources of loadAppFonts are flutter_test_goldens and alchemist, or ~20 lines of your own FontLoader code.

- https://fluttergoldens.com/flutters-implementation/load-fonts-and-icons/

- https://pub.dev/documentation/golden_toolkit/latest/golden_toolkit/loadAppFonts.html

### Flutter officially concedes goldens are platform-dependent once real fonts are loaded

*Confidence: high, **LOAD-BEARING***

matchesGoldenFile docs: 'Custom fonts may render differently across different platforms, or between different versions of Flutter' and 'a golden file generated on Windows with fonts will likely differ from the one produced by another operating system.' There is no tolerance threshold in core matchesGoldenFile — comparison is exact by default; fuzzy matching requires a custom GoldenFileComparator (golden_screenshot ships one allowing ~0.1% pixel mismatch).

- https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html

- https://pub.dev/packages/golden_screenshot

### Impeller is NOT a factor for widget-test goldens

*Confidence: medium*

flutter test runs the widget tree in the flutter_tester host shell using software/Skia rasterization, not the on-device Impeller backend. Impeller (default on iOS, rolling out on Android) affects the shipped app, never the `flutter test` golden. Corollary that cuts the other way: goldens therefore CANNOT catch an Impeller-specific rendering regression on device — a real coverage gap that no golden strategy closes.

- https://github.com/flutter/flutter/issues/130633

- https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html

### A MediaQuery placed ABOVE MaterialApp DOES take effect — the old 'you must use MaterialApp.builder' folk wisdom is obsolete

*Confidence: high, **LOAD-BEARING***

useInheritedMediaQuery was deprecated after v3.7.0-29.0.pre and is now ignored: 'MaterialApp never introduces its own MediaQuery; the View widget takes care of that.' In a widget test, pumpWidget wraps the tree in View, which inserts MediaQuery.fromView; a MediaQuery you place below that and above MaterialApp is the nearest ancestor and wins. Separately, MediaQuery.fromView 'is constructed using the platform-specific data of the surrounding MediaQuery and the view-specific data of the provided view' — it composes with, not clobbers, an ancestor.

- https://api.flutter.dev/flutter/material/MaterialApp/useInheritedMediaQuery.html

- https://api.flutter.dev/flutter/widgets/MediaQuery/fromView.html

- https://api.flutter.dev/flutter/widgets/MediaQuery-class.html

### tester.binding.window is deprecated; the replacements are tester.view and tester.platformDispatcher

*Confidence: high, **LOAD-BEARING***

Deprecated after v3.9.0-0.1.pre in preparation for multi-window. physicalSizeTestValue -> tester.view.physicalSize; devicePixelRatioTestValue -> tester.view.devicePixelRatio; clearAllTestValues -> tester.platformDispatcher.clearAllTestValues() plus tester.view.reset(). Flutter PR #180840 explicitly cleaned up resetXyz() calls in favour of a single TestFlutterView.reset(), so prefer addTearDown(tester.view.reset) over resetPhysicalSize/resetDevicePixelRatio pairs.

- https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html

- https://github.com/flutter/flutter/pull/180840

### flutter_test ships four accessibility guideline matchers that directly encode this app's a11y-is-correctness rule

*Confidence: high, **LOAD-BEARING***

androidTapTargetGuideline (48x48 min), iOSTapTargetGuideline (44x44 min), labeledTapTargetGuideline (tappable nodes must be labeled), textContrastGuideline (3:1 for >=18pt text, 4.5:1 otherwise). Usage requires tester.ensureSemantics() first, expectLater(tester, meetsGuideline(...)) (async — must be awaited), then handle.dispose(). This turns 'accessibility is correctness' from discipline into a failing test.

- https://docs.flutter.dev/ui/accessibility/accessibility-testing

- https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html

- https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/accessibility.dart

### textContrastGuideline is the weakest of the four matchers and should not be over-trusted

*Confidence: medium*

It samples rendered pixels behind semantic text nodes. With the FlutterTest box-glyph font every 'character' is a solid filled box, so the sampled foreground coverage differs from real glyph antialiasing; it also produces unreliable results over images/gradients. Treat tap-target and labeled-tap-target as hard gates, and textContrast as an advisory check backed by a hand-computed contrast unit test on your 3 theme palettes.

- https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/accessibility.dart

- https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Flutter-Test-Fonts.md

### flutter test runs in a plain Dart VM — sqlite3_flutter_libs does NOTHING, so drift needs host sqlite3

*Confidence: high, **LOAD-BEARING***

Per drift's maintainer: native plugins like sqlite3_flutter_libs only apply to real apps or integration_test with a driver, not `flutter test`. NativeDatabase.memory() resolves sqlite3 from the host: macOS has a system libsqlite3 (older version — a real dev/CI version-skew risk), Linux CI needs libsqlite3-dev (Ubuntu) installed before flutter test, else 'Failed to load dynamic library libsqlite3.so'. Directly relevant to the abandonment/open-source plan: a stranger cloning on Linux gets DB test failures unless you document this.

- https://github.com/simolus3/drift/issues/2314

- https://github.com/simolus3/drift/issues/3702

- https://drift.simonbinder.eu/platforms/vm/

### Drift in a WIDGET test needs closeStreamsSynchronously: true or you get cross-test stream leakage

*Confidence: high, **LOAD-BEARING***

Drift docs: 'By default, unsubscribing from a query stream created by drift will keep the stream open for one event loop iteration... To avoid issues with Drift in that setup, pass a DatabaseConnection with closeStreamsSynchronously: true to your database.' Widget tests use a FakeAsync-controlled clock, so that deferred event-loop iteration may never run — streams stay open, the test binding complains about pending timers or state leaks into the next test. This is the specific gotcha that makes naive real-drift widget tests flaky.

- https://drift.simonbinder.eu/testing/

### Riverpod 3.x is stable and changed the test idioms

*Confidence: high*

flutter_riverpod 3.3.2 published ~35 days ago, ~2.45M downloads. Riverpod 3 adds ProviderContainer.test() (auto-disposes at test end; the docs say you can safely search-and-replace your createContainer helper with it), tester.container() to reach the container from a widget test, and NotifierProvider.overrideWithBuild to mock only Notifier.build rather than the whole notifier. Docs explicitly say: inside tests, never use ProviderContainer directly — use ProviderContainer.test.

- https://pub.dev/packages/flutter_riverpod

- https://riverpod.dev/docs/how_to/testing

- https://riverpod.dev/docs/whats_new

### TextScaler.linear(2.0) does not reproduce what Android 14+ actually does at 200%

*Confidence: high, **LOAD-BEARING***

textScaleFactor was deprecated after v3.12.0-2.0.pre specifically to support Android 14's NONLINEAR font scaling: large text scales less than small text. A real device at '200%' supplies a nonlinear TextScaler, so TextScaler.linear(2.0) is a deliberate over-approximation (it scales your big tile labels harder than Android would). That is the right conservatism for this app — but do not claim the test is device-faithful, and do test 1.3/1.5 too, since nonlinear scaling makes mid-range scales non-obvious.

- https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor

- https://docs.flutter.dev/release/breaking-changes/android-14-nonlinear-text-scaling-migration

### MediaQuery.withClampedTextScaling exists and is the single most dangerous API for this app

*Confidence: high, **LOAD-BEARING***

It restricts the scaled text range to prevent UI breakage — i.e. it is the exact violation of constraint #3 (TextScaler honored at 200%+ and never clamped). It is a one-line change any future contributor might add to 'fix' an overflow failure, silently defeating the whole overflow matrix. There is no built-in lint for it; a ~10-line source-grep test is the proportionate enforcement.

- https://api.flutter.dev/flutter/widgets/MediaQuery/withClampedTextScaling.html

### flutter_test_goldens is the emerging golden_toolkit successor but is too immature to bet a 2-week MVP on

*Confidence: high*

v0.0.12 (published ~19 days ago), publisher flutterbountyhunters.com, 130 pub points but only 11 likes and ~12.6k downloads. Novel model: 'golden scenes' — it tracks the position of each golden within a scene file and extracts individual images for comparison rather than diffing the whole file. Genuinely interesting, and it ships loadAppFonts/loadMaterialIconsFont. But a 0.0.x version is the wrong dependency for an app whose exit plan is unmaintained longevity.

- https://pub.dev/packages/flutter_test_goldens

- https://fluttergoldens.com/golden-scenes/what-is-it/

### golden_screenshot and spot solve adjacent problems, not this one

*Confidence: high*

golden_screenshot v11.0.1 (~3 months ago, adil.hanney.org, 25 likes, 18.4k downloads) targets App Store/Play/F-Droid/Flathub store screenshots, with a fuzzy comparator (~0.1% tolerance) and shadow rendering — genuinely useful for the store listing this dev must produce, but not a regression tool. spot v0.18.0 is ~13 months stale, publisher pascalwelsch.com, 110 likes; it is a chainable widget-selector + failure-timeline tool layered on flutter_test, not a golden framework.

- https://pub.dev/packages/golden_screenshot

- https://pub.dev/packages/spot

## Recommendations

- **[must]** Pin a real device size in EVERY layout/text-scale test via tester.view.physicalSize + devicePixelRatio, with addTearDown(tester.view.reset). Never let a layout test run at the default 800x600.
  - The 800x600 default is wider than any phone, so tiles are ~2x too wide and text fits. An unpinned overflow suite is green while the shipped 360pt phone UI is broken — the worst possible outcome for a project with no telemetry.
- **[must]** Never call takeException() to swallow, and never set FlutterError.onError, in any layout test. Add expect(tester.takeException(), isNull) as the explicit assertion instead.
  - Overflow already fails the test for free via FlutterError.reportError -> _pendingExceptionDetails -> rethrow at test end. The only way to lose this safety net is to suppress it, which is exactly what the popular 'ignoreOverflowErrors' blog helper teaches.
- **[must]** Generate one testWidgets per (device x textScale x theme) tuple in nested for-loops OUTSIDE the test body. Never loop scales inside a single test body.
  - DebugOverflowIndicatorMixin's _overflowReportNeeded flag reports each RenderObject's overflow only once (reset only on reassemble), so a scale loop inside one test silently under-reports the 2nd and 3rd scales.
- **[must]** Put the MediaQuery override above MaterialApp, and build its data from MediaQuery.of(context).copyWith(...) via a Builder rather than constructing MediaQueryData() from scratch.
  - MaterialApp no longer inserts its own MediaQuery (useInheritedMediaQuery is ignored; the View does it), so an ancestor MediaQuery wins. copyWith preserves view-derived padding/size that a raw MediaQueryData() would silently zero out.
- **[must]** Assert on a FakeSpeechService that a tile tap speaks the VOCALIZATION string, never the label — one test per seeded tile fixture.
  - label != vocalization is the core Open Board Format semantic of this app. Swapping them is a silent, plausible-looking regression that no type checker catches and that no user will report because they cannot speak.
- **[must]** Write an explicit test that a SpeechService failure (throw, empty voice list, setVoice returning false) renders a VISIBLE fallback, and assert the widget is found.
  - Constraint #4 says silence is the worst bug class. 'Nothing happens' is the default behaviour of an unasserted error path; only a test that demands a visible artifact makes silence impossible.
- **[must]** Gate every screen with tester.ensureSemantics() + meetsGuideline(androidTapTargetGuideline / iOSTapTargetGuideline / labeledTapTargetGuideline), run at 200% text scale on the smallest device.
  - These four matchers are already in flutter_test — they convert 'accessibility is correctness' from developer discipline into CI failure at zero dependency cost. Running them at 200% on 320pt catches the tap-target shrinkage that the 1.0x test misses.
- **[must]** Add a ~10-line test that greps lib/ for 'withClampedTextScaling' and 'textScaleFactor' and fails if either appears.
  - MediaQuery.withClampedTextScaling is the one-line 'fix' a future contributor will reach for when an overflow test fails, and it silently defeats constraint #3. No lint exists for it; a source-grep test is the proportionate solo-dev enforcement.
- **[should]** Fake the repository for the ~50 UI widget tests; use real drift NativeDatabase.memory() only in DAO/repository tests and in 2-3 end-to-end 'boot' widget tests.
  - Faking keeps the UI matrix fast and host-sqlite3-free. But with no telemetry, the DB->UI seam is precisely what you cannot observe in the field, so a few real-drift widget tests are worth their cost. Migration tests are a separate, non-negotiable suite (constraint #2) and always use real drift.
- **[must]** If you use drift in any widget test, pass DatabaseConnection(..., closeStreamsSynchronously: true).
  - Drift keeps unsubscribed query streams open for one event-loop iteration, which never arrives under the widget test's FakeAsync clock — producing pending-timer failures and state leaking into the next test. This is the specific reason naive real-drift widget tests are flaky.
- **[must]** Document the host sqlite3 requirement in README/CONTRIBUTING (macOS: system lib; Ubuntu: apt-get install libsqlite3-dev before flutter test).
  - flutter test runs in a plain Dart VM where sqlite3_flutter_libs does nothing. Constraint #5 is that a stranger picks this up — a stranger who clones on Linux and sees DB tests fail concludes the repo is broken and walks away.
- **[avoid]** Do NOT build a golden regression suite for the MVP.
  - Every failure mode goldens would catch here (text not fitting, tiles reflowing) is already caught more cheaply and with a readable message by the overflow matrix + getRect layout invariants + semantics assertions. Goldens add binary blobs to git, churn on every padding tweak, and — decisively for constraint #5 — a stranger running flutter test on Linux against macOS-generated goldens sees a wall of red and concludes the repo is broken. Goldens actively sabotage the open-source exit plan.
- **[should]** Replace the golden suite with getRect-based layout invariants: assert exactly 12 slots exist and that tiles in the same row share a top edge (moreOrLessEquals, epsilon 0.5) at every scale.
  - This asserts the actual design property — the grid is fixed and reflow is impossible — in plain text, platform-independently, with a diagnostic failure message and zero maintenance. It mirrors at the UI layer the guarantee that PRIMARY KEY (board_id, row, col) gives at the DB layer.
- **[should]** If you later want goldens anyway: exactly ONE golden of the board, tagged @Tags(['golden']) and excluded from the default run via dart_test.yaml, generated only in a pinned Docker image on CI.
  - Tag-excluding keeps a stranger's bare `flutter test` green (constraint #5) while still giving you a visual tripwire. One golden, not a 3-themes x N-scales matrix — the matrix is the maintenance trap; a single canary catches catastrophic regressions at ~1/30th the churn.
- **[avoid]** Do not adopt alchemist for this app's core question, and do not adopt flutter_test_goldens at 0.0.x.
  - alchemist is maintained (Betterment, 0.14.0) but its CI goldens set obscureText: true, replacing text with colored rectangles — it achieves platform stability by discarding exactly the glyph rendering this app needs to verify. flutter_test_goldens is 0.0.12 with 11 likes; betting an intentionally-unmaintained app on it contradicts the longevity plan.
- **[should]** Do use golden_screenshot — but for App Store / Play / F-Droid store listing screenshots, not regression.
  - It is maintained (v11.0.1) and purpose-built for store screenshots, which this dev must produce anyway. Reframing 'goldens' as a marketing-asset generator captures the real value without any of the regression-suite churn.
- **[should]** Test the a11y flags that change layout (boldText, accessibleNavigation, highContrast) as first-class matrix axes, not afterthoughts. Skip disableAnimations/invertColors tests.
  - boldText widens glyphs and can overflow a tile that passes at the same scale unbolded; accessibleNavigation is what Switch Access/VoiceOver set. disableAnimations is moot given the zero-animation design rule, and invertColors is applied by the OS compositor, not the Flutter tree — testing them spends budget for no signal.
- **[should]** Use TextScaler.linear at 1.0/1.3/1.5/2.0/3.0 and document in a comment that this is a deliberate over-approximation of Android 14 nonlinear scaling.
  - Android 14+ scales large text less than small text, so linear(2.0) stresses big tile labels harder than a real device — the right conservatism. But the mid-range values matter precisely because nonlinear scaling makes 1.3/1.5 non-obvious, and an undocumented linear assumption will mislead the stranger who inherits this.
- **[should]** Use Riverpod 3 test idioms: ProviderContainer.test() over a hand-rolled createContainer, and tester.container() to reach the container from a widget test.
  - flutter_riverpod 3.3.2 is stable and ProviderContainer.test auto-disposes at test end; the docs explicitly say never to use ProviderContainer directly in tests. Since Riverpod was chosen specifically for the testable repository/UI seam, using the seam idiomatically is the whole point of having paid for it.
- **[avoid]** Skip: golden diffing across 3 themes x N scales, integration_test/Patrol for the MVP, and any coverage-percentage gate.
  - Constraint #6 says ceremony a team needs and a solo dev does not is a real cost. Patrol has had recurring CI stability issues through late-2025/early-2026; a coverage gate optimizes a number rather than the two properties that actually matter here (no silence, no data loss), both of which are covered by targeted tests.

### test/support/harness.dart — the pumpApp harness (Riverpod 3 + real device sizes + a11y flags)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Logical sizes. `small` is the worst case we promise to support.
class Device {
  const Device(this.name, this.size, this.dpr);
  final String name;
  final Size size;
  final double dpr;

  static const small  = Device('small_360', Size(360, 640), 3.0);
  static const pixel7 = Device('pixel_7',   Size(412, 915), 2.625);
  static const seLike = Device('se_like',   Size(320, 568), 2.0);

  static const all = <Device>[small, pixel7, seLike];
  @override
  String toString() => name;
}

extension AacHarness on WidgetTester {
  /// Pins the test view to a real phone. Without this you are testing
  /// 800x600 logical - wider than any phone - and text-scale tests lie.
  void useDevice(Device d) {
    view.devicePixelRatio = d.dpr;
    view.physicalSize = d.size * d.dpr;
    addTearDown(view.reset); // TestFlutterView.reset(), not the deprecated resetXyz pairs
  }

  Future<void> pumpApp(
    Widget home, {
    List<Override> overrides = const [],
    TextScaler textScaler = TextScaler.noScaling,
    bool boldText = false,
    bool highContrast = false,
    bool accessibleNavigation = false,
    ThemeData? theme,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        // pumpWidget wraps this tree in a View, which inserts
        // MediaQuery.fromView. MaterialApp inserts NO MediaQuery of its own
        // (useInheritedMediaQuery is gone), so this MediaQuery is the nearest
        // ancestor for everything below and wins.
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: textScaler,
              boldText: boldText,
              highContrast: highContrast,
              accessibleNavigation: accessibleNavigation,
              disableAnimations: true, // zero-animation design rule
            ),
            child: MaterialApp(theme: theme, home: home),
          ),
        ),
      ),
    );
  }
}
```

MediaQuery sits ABOVE MaterialApp deliberately — legal since useInheritedMediaQuery was removed. The Builder + copyWith is load-bearing: constructing MediaQueryData() from scratch would zero out view-derived padding.

### test/board/overflow_matrix_test.dart — the real safety net

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';
import '../support/fakes.dart';

void main() {
  // Android 14+ scales nonlinearly (big text scales less than small text).
  // TextScaler.linear is a deliberate OVER-approximation: it stresses our
  // large tile labels harder than a real device would. That is the
  // conservatism we want. 1.3/1.5 are included precisely because nonlinear
  // scaling makes the mid-range non-obvious.
  const scales = <double>[1.0, 1.3, 1.5, 2.0, 3.0];

  for (final device in Device.all) {
    for (final scale in scales) {
      for (final bold in <bool>[false, true]) {
        // ONE testWidgets per tuple. Do NOT loop scales inside a single test:
        // DebugOverflowIndicatorMixin reports each RenderObject's overflow
        // exactly ONCE (_overflowReportNeeded, reset only on reassemble), so
        // later iterations would silently pass.
        testWidgets(
          'board: no overflow @ $device x${scale}${bold ? " bold" : ""}',
          (tester) async {
            tester.useDevice(device);
            await tester.pumpApp(
              const BoardScreen(),
              overrides: fakeBoardOverrides(longestLabels: true),
              textScaler: TextScaler.linear(scale),
              boldText: bold,
            );
            await tester.pump();

            // A RenderFlex overflow is reported from paint() via
            // FlutterError.reportError; the binding stores it and testWidgets
            // rethrows at test end. Asserting explicitly gives a cleaner
            // failure and documents that we must never suppress it.
            expect(tester.takeException(), isNull,
                reason: 'Tile text must never overflow at $device x$scale');
          },
        );
      }
    }
  }
}
```

No expect() for overflow is strictly needed: the binding rethrows at test end. The explicit takeException assertion is there to produce a better message AND to document that suppression is forbidden. Note tests are GENERATED per tuple, never looped inside one body.

### test/board/grid_invariants_test.dart — layout invariants instead of goldens

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';
import '../support/fakes.dart';

void main() {
  testWidgets('grid keeps 12 slots in fixed positions at 200%', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: fakeBoardOverrides(),
      textScaler: const TextScaler.linear(2.0),
    );
    await tester.pump();

    expect(find.byType(PhraseTile), findsNWidgets(12));

    Rect slot(int r, int c) =>
        tester.getRect(find.byKey(ValueKey('slot_${r}_$c')));

    // Position IS the primary key: tiles in a row share a top edge, tiles in
    // a column share a left edge. This mirrors PRIMARY KEY (board_id,row,col)
    // at the UI layer - reflow must be structurally impossible here too.
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 3; c++) {
        expect(slot(r, c).top, moreOrLessEquals(slot(r, 0).top, epsilon: 0.5),
            reason: 'row $r reflowed at col $c');
        expect(slot(r, c).left, moreOrLessEquals(slot(0, c).left, epsilon: 0.5),
            reason: 'col $c reflowed at row $r');
      }
    }
  });

  testWidgets('an empty slot still occupies its cell', (tester) async {
    tester.useDevice(Device.small);
    // grid_slots.button_id is NULLABLE - an empty cell must hold its space,
    // never collapse and pull the next tile into its position.
    await tester.pumpApp(
      const BoardScreen(),
      overrides: fakeBoardOverrides(emptySlots: {(1, 1)}),
    );
    await tester.pump();
    expect(tester.getRect(find.byKey(const ValueKey('slot_1_1'))).width,
        greaterThan(0));
  });
}
```

This is the golden-replacement. It asserts the actual design property (fixed grid, reflow impossible) in plain text, platform-independently, with a readable diff on failure and zero binary artifacts.

### test/board/speech_test.dart — asserting a tap SPEAKS, and that failure is never silent

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';

class FakeSpeechService implements SpeechService {
  final List<String> spoken = <String>[];
  Object? failWith;

  @override
  Future<void> speak(String text) async {
    if (failWith != null) throw failWith!;
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<List<Voice>> voices() async => const <Voice>[];
}

void main() {
  testWidgets('tapping a tile speaks the VOCALIZATION, not the label',
      (tester) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.pixel7);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: [
        speechServiceProvider.overrideWithValue(speech),
        boardRepositoryProvider.overrideWithValue(
          FakeBoardRepository.oneTile(
            row: 0,
            col: 0,
            label: 'Overwhelmed',
            vocalization: "I need to leave, I'm not able to talk right now",
          ),
        ),
      ],
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('slot_0_0')));
    await tester.pump();

    // The tile SHOWS 'Overwhelmed' but must SPEAK the full sentence.
    expect(find.text('Overwhelmed'), findsOneWidget);
    expect(speech.spoken,
        ["I need to leave, I'm not able to talk right now"]);
  });

  testWidgets('speech failure is VISIBLE, never silent', (tester) async {
    final speech = FakeSpeechService()..failWith = SpeechFailure('no voice');
    tester.useDevice(Device.pixel7);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: [
        speechServiceProvider.overrideWithValue(speech),
        boardRepositoryProvider.overrideWithValue(
          FakeBoardRepository.oneTile(
            row: 0, col: 0, label: 'Overwhelmed',
            vocalization: 'I need to leave',
          ),
        ),
      ],
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('slot_0_0')));
    await tester.pump();

    // Constraint #4: a user tapping mid-shutdown must NEVER get nothing.
    // If TTS cannot speak, the text must appear on screen instead.
    expect(find.text('I need to leave'), findsOneWidget);
    expect(tester.takeException(), isNull); // failure handled, not thrown
  });
}
```

The first test is the single highest-value test in the suite: it pins label != vocalization. The second encodes constraint #4 — a speech failure must produce a visible artifact.

### test/board/a11y_test.dart — guideline matchers + semantics, run at 200%

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';
import '../support/fakes.dart';

void main() {
  testWidgets('board meets a11y guidelines at 200% on the smallest phone',
      (tester) async {
    final handle = tester.ensureSemantics();
    tester.useDevice(Device.seLike);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: fakeBoardOverrides(),
      textScaler: const TextScaler.linear(2.0),
      accessibleNavigation: true, // Switch Access / VoiceOver on
    );
    await tester.pump();

    // Hard gates.
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    // Advisory: the FlutterTest font renders solid box glyphs, so sampled
    // contrast is not glyph-faithful. Back this with a hand-computed
    // contrast unit test over the 3 theme palettes.
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('each tile exposes the LABEL to screen readers, as a button',
      (tester) async {
    final handle = tester.ensureSemantics();
    tester.useDevice(Device.pixel7);
    await tester.pumpApp(const BoardScreen(), overrides: fakeBoardOverrides());
    await tester.pump();

    expect(
      tester.getSemantics(find.byKey(const ValueKey('slot_0_0'))),
      matchesSemantics(
        label: 'Overwhelmed',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });
}
```

Run the guidelines at the worst-case device AND 200% scale — that is where tap targets shrink. ensureSemantics() is required before meetsGuideline, and each expectLater must be awaited.

### test/policy/no_text_clamping_test.dart — enforcing 'never clamp' as a test

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no code clamps or overrides text scaling', () {
    const forbidden = <String>[
      'withClampedTextScaling', // clamps TextScaler - violates a11y contract
      'textScaleFactor',        // deprecated; and usually a clamping hack
      'TextScaler.noScaling',   // must not appear in lib/ (tests may use it)
    ];

    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      for (final bad in forbidden) {
        if (src.contains(bad)) offenders.add('${f.path}: $bad');
      }
    }

    expect(offenders, isEmpty,
        reason: 'TextScaler must be honored at 200%+ and never clamped.\n'
            'Fix the layout, do not clamp the text.\n'
            '${offenders.join("\n")}');
  });
}
```

Ten lines that make constraint #3 unbreakable by a future contributor (or by you at 2am). There is no lint for withClampedTextScaling; this is the proportionate solo-dev substitute.

### Drift in a widget test — the closeStreamsSynchronously requirement

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // `flutter test` runs in a plain Dart VM: sqlite3_flutter_libs does
    // NOTHING here. This resolves the HOST sqlite3.
    //   macOS: system libsqlite3 (older than the bundled one - version skew!)
    //   Ubuntu CI: apt-get install -y libsqlite3-dev  BEFORE flutter test
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        // REQUIRED in widget tests. Drift otherwise keeps an unsubscribed
        // query stream open for one event-loop iteration, which never
        // arrives under the widget test's FakeAsync clock -> pending timers
        // and state leaking into the next test.
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() => db.close());

  testWidgets('board renders tiles read from a real drift DB', (tester) async {
    await db.into(db.boards).insert(
        BoardsCompanion.insert(id: const Value(1), name: 'Default'));
    await db.into(db.buttons).insert(ButtonsCompanion.insert(
          id: const Value(1),
          label: 'Overwhelmed',
          vocalization: "I need to leave, I'm not able to talk right now",
        ));
    await db.into(db.gridSlots).insert(GridSlotsCompanion.insert(
          boardId: 1, row: 0, col: 0, buttonId: const Value(1),
        ));

    tester.useDevice(Device.pixel7);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Overwhelmed'), findsOneWidget);
  });
}
```

Use this shape ONLY for the 2-3 end-to-end boot tests. Everything else fakes the repository. Without closeStreamsSynchronously: true, drift's one-event-loop-iteration stream teardown never runs under the widget test's FakeAsync clock.

### IF you add goldens later: tag-exclude them so a stranger's `flutter test` stays green

```yaml
# dart_test.yaml
tags:
  golden:
    # Goldens are platform-dependent once real fonts are loaded (macOS dev vs
    # Linux CI produce different pixels). Excluded by default so that a
    # stranger cloning this repo gets a GREEN `flutter test` on any OS.
    # CI regenerates/verifies them in a pinned Docker image:
    #   flutter test --tags golden
    skip: "run only in the pinned CI container: flutter test --tags golden"

# test/board/board_golden_test.dart
#   @Tags(['golden'])
#   library;
#   ... testWidgets('board canary', (tester) async {
#         await expectLater(find.byType(BoardScreen),
#             matchesGoldenFile('goldens/board.png'));
#       });

# test/flutter_test_config.dart  (only needed if goldens exist)
#   Future<void> testExecutable(FutureOr<void> Function() testMain) async {
#     await loadAppFonts();            // else FlutterTest box glyphs, not Ahem
#     await loadMaterialIconsFont();
#     return testMain();
#   }
```

dart_test.yaml. Combine with `flutter test --tags golden --update-goldens` inside a pinned Docker image on CI only. This is the ONLY golden setup compatible with the open-source-and-abandon exit plan.

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


YOUR DIMENSION: Widget testing depth + golden/screenshot testing.

Research with WebSearch/WebFetch.

**Widget testing:**
- The pumpApp/testHarness pattern — wrapping with MaterialApp + ProviderScope + MediaQuery overrides. Show a real, current implementation.
- **Testing at different text scales**: how do you drive `TextScaler` in a widget test? (MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(2.0)))) — show it. How do you assert nothing overflows? (Does a RenderFlex overflow FAIL a test, or just log? VERIFY — this matters enormously: if overflow only prints to console, the test passes while the UI is broken. How do you make overflow fail the test?)
- Testing different screen sizes (tester.view.physicalSize / devicePixelRatio, addTearDown(tester.view.reset)). Current API — `tester.binding.window` is deprecated; what replaced it?
- Testing MediaQuery a11y flags: boldText, highContrast, disableAnimations, invertColors, accessibleNavigation.
- Testing that a tap SPEAKS: how do you assert on a faked SpeechService?
- Testing the drift-backed UI: in-memory DB (NativeDatabase.memory()) in widget tests — is that a good idea or should the repo be faked? Argue.

**Golden testing:**
- Current state 2026: `matchesGoldenFile`, `flutter test --update-goldens`, golden_toolkit (VERIFY — I believe it was DISCONTINUED/archived by eBay; check!), alchemist (Very Good Ventures), golden_screenshot, spot. What is actually maintained and recommended NOW?
- The font problem: goldens render boxes instead of text unless you load fonts — the actual fix in 2026 (loadAppFonts, FontLoader, or is it now automatic?).
- The platform problem: goldens differ between macOS/Linux/CI. How do teams solve it (CI-only goldens, Docker, tolerance thresholds, alchemist's CI vs platform goldens)? Is Impeller vs Skia a factor?
- **Honest verdict for THIS app**: it has a rigidly fixed grid, zero animation, and 3 themes × N text scales. Is that the ideal golden-test case, or a maintenance trap for a solo dev? Argue both sides and commit to an answer.

Give real, current, compiling code.
````

</details>
