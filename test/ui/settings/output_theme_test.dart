import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart' show databaseProvider;
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/speech/speech_service.dart' show OutputMode;
import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:offline_aac/model/aac_palette.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/board/board_controller.dart'
    show crashLogProvider, gridProvider, speechServiceProvider;
import 'package:offline_aac/ui/board/board_screen.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';

import '../../support/fake_speech_service.dart';
import '../../support/fonts.dart';
import '../../support/harness.dart';
import '../../support/tiles.dart';

/// The theme and output controls. The theme cycle is the escape hatch for an
/// unreadable palette, so it must be one tap from the board; output mode is a
/// remembered choice and NEVER speaks a preview.
void main() {
  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(BoardScreen)));

  testWidgets('the theme control is one tap from the board', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    expect(
      find.bySemanticsLabel(RegExp('^Theme: ')),
      findsOneWidget,
      reason: 'the palette escape hatch lives on the board, not three screens in',
    );
  });

  testWidgets('the visible theme label names each cycle position', (
    tester,
  ) async {
    for (final entry in <AacPalette, String>{
      AacPalette.paper: 'theme: paper',
      AacPalette.ink: 'theme: ink',
      AacPalette.hcInk: 'theme: high contrast',
      AacPalette.hcPaper: 'theme: high contrast',
    }.entries) {
      tester.useDevice(Device.small);
      await tester.pumpApp(palette: entry.key);
      expect(
        find.text(entry.value),
        findsOneWidget,
        reason: '${entry.key} must read "${entry.value}"',
      );
    }
  });

  testWidgets('selecting output modes and cycling theme never speaks', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);
    final settings = container(tester).read(settingsProvider.notifier);
    final palette = container(tester).read(paletteProvider.notifier);

    settings
      ..setOutputMode(OutputMode.show)
      ..setOutputMode(OutputMode.both)
      ..setOutputMode(OutputMode.speak);
    palette
      ..cycle()
      ..cycle()
      ..cycle();
    await tester.pump();

    expect(
      speech.calls,
      isEmpty,
      reason: 'settings is where a user goes to STOP noise, not make it',
    );
  });

  testWidgets('changing HC polarity while on paper changes nothing on screen', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(palette: AacPalette.paper);
    final c = container(tester);

    c.read(settingsProvider.notifier).setHcPolarity(AacPalette.hcPaper);
    await tester.pump();

    expect(
      c.read(paletteProvider),
      AacPalette.paper,
      reason: 'polarity is a stored preference; it does not repaint the app',
    );
    // And the next cycle into HC lands on the chosen polarity.
    final palette = c.read(paletteProvider.notifier)
      ..cycle() // paper -> ink
      ..cycle(); // ink -> high contrast
    await tester.pump();
    expect(c.read(paletteProvider), AacPalette.hcPaper);
    expect(palette.palette, AacPalette.hcPaper);
  });

  testWidgets('changing HC polarity while ON high contrast applies at once', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(palette: AacPalette.hcInk);
    final c = container(tester);

    c.read(settingsProvider.notifier).setHcPolarity(AacPalette.hcPaper);
    await tester.pump();

    expect(
      c.read(paletteProvider),
      AacPalette.hcPaper,
      reason: 'on HC the polarity flips the live palette immediately',
    );
  });

  testWidgets('a saved palette wins over the platform high-contrast flag', (
    tester,
  ) async {
    // MediaQuery.highContrast is iOS-only and always false on Android; it may
    // nudge the initial default but never override an explicit choice.
    await loadAppFonts();
    tester.useDevice(Device.small);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          speechServiceProvider.overrideWithValue(FakeSpeechService()),
          crashLogProvider.overrideWithValue(CrashLog.discard()),
          initialPaletteProvider.overrideWithValue(AacPalette.paper),
          // Canned grid, so the live drift stream (and the timer it leaks under
          // a widget test's fake clock) stays out of this theme-only test.
          gridProvider.overrideWith((ref) => Stream<BoardGrid>.value(fixtureGrid())),
        ],
        child: const MediaQuery(
          data: MediaQueryData(highContrast: true),
          child: ReedApp(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      container(tester).read(paletteProvider),
      AacPalette.paper,
      reason: 'the explicit choice wins; the platform flag never overrides it',
    );
  });
}
