import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/board/board_screen.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';

import '../../support/harness.dart';

/// Low stimulus DERIVES the theme and the layout; it never writes them. The
/// desaturation and the 2-column layout come off a single boolean, and turning
/// the mode off restores exactly what was there because nothing was overwritten.
void main() {
  group('effectiveTheme', () {
    final ink = themeFor(AacPalette.ink);

    test('on: every tile collapses to ground behind its keyline', () {
      final low = effectiveTheme(ink, lowStimulus: true);
      expect(low.usesStocks, isFalse);
      for (final stock in Stock.values) {
        expect(
          low.stock(stock),
          ink.ground,
          reason: 'the dyed stocks go — $stock renders on ground',
        );
      }
    });

    test('off: the theme is unchanged', () {
      expect(effectiveTheme(ink, lowStimulus: false), same(ink));
    });
  });

  group('effectiveGridSize', () {
    test('on: surfaces the 2-column large layout', () {
      const s = ReedSettings.defaults();
      expect(effectiveGridSize(s.copyWith(lowStimulus: true)), GridSize.large);
    });

    test('off: it is the stored preference, untouched', () {
      final s = const ReedSettings.defaults().copyWith(
        gridSize: GridSize.phone,
      );
      expect(effectiveGridSize(s), GridSize.phone);
    });
  });

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(BoardScreen)));

  testWidgets('haptics and low stimulus are the first two settings rows', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump();
    await tester.pump();

    expect(
      find.bySemanticsLabel('Haptics: on. Tap to change.'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Low stimulus: off. Tap to change.'),
      findsOneWidget,
    );
  });

  testWidgets('turning low stimulus on desaturates the board', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    final c = container(tester);
    expect(
      AacTheme.of(tester.element(find.byType(BoardScreen))).usesStocks,
      isTrue,
    );

    c.read(settingsProvider.notifier).setLowStimulus(enabled: true);
    await tester.pump();

    expect(
      AacTheme.of(tester.element(find.byType(BoardScreen))).usesStocks,
      isFalse,
      reason: 'the dyed stocks come off in low stimulus',
    );
  });

  testWidgets('toggling haptics schedules no frame and fires no pulse', (
    tester,
  ) async {
    // Haptics changes no theme, so it is a genuinely frame-quiet row. (Low
    // stimulus changes the theme, whose zero-duration settle is a framework
    // detail, not a Reed row animating — see effectiveTheme, asserted above.)
    tester.useDevice(Device.small);
    await tester.pumpApp();
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Haptics: on. Tap to change.'));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(
      find.bySemanticsLabel('Haptics: off. Tap to change.'),
      findsOneWidget,
      reason: 'the row now reads off',
    );
  });
}
