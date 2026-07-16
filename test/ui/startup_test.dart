import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/crash_log.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/board/board_screen.dart';
import 'package:offline_aac/ui/core/tokens.dart';

import '../support/fake_speech_service.dart';

/// The cold-launch contract.
///
/// Everything here guards the first frame, because the first frame is the whole
/// product: someone opens this app mid-shutdown to say a sentence. A splash, a
/// wrong-polarity flash, or a frame spent waiting on the TTS engine is not a
/// polish problem — it is the app failing at the only moment it exists for.
void main() {
  late AppDatabase db;
  late FakeSpeechService speech;

  setUp(() {
    // A database is still provided because the controller reads it, but the grid
    // itself is a canned override (see `app`), so nothing here exercises the seed
    // or the live query stream.
    db = AppDatabase.forTesting(NativeDatabase.memory());
    speech = FakeSpeechService();
  });

  tearDown(() async => db.close());

  Widget app({
    AacPalette palette = AacPalette.ink,
    FakeSpeechService? withSpeech,
  }) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        speechServiceProvider.overrideWithValue(withSpeech ?? speech),
        crashLogProvider.overrideWithValue(const CrashLog.discard()),
        initialPaletteProvider.overrideWithValue(palette),
        // A canned grid, not the live database stream. These tests are about the
        // launch frame and the theme, not the data layer — the repository tests
        // own that. Overriding here keeps drift's query-stream infrastructure,
        // and the coalescing Timer it schedules, out of a test that would
        // otherwise trip the binding's "a Timer is still pending" invariant for
        // reasons that have nothing to do with the app.
        gridProvider.overrideWith(
          (ref) => Stream.value(
            BoardGrid(
              boardId: 1,
              rows: 4,
              cols: 3,
              tiles: List<Tile?>.filled(12, null),
            ),
          ),
        ),
      ],
      child: const ReedApp(),
    );
  }

  group('first frame', () {
    testWidgets('lands on the board with no splash, dialog, route or overlay', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      // pump, never pumpAndSettle: the app has zero animation, so settling is
      // meaningless here and is a known flake source. If pumpAndSettle were ever
      // required, something is animating that should not be.
      await tester.pump();

      expect(find.byType(BoardScreen), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      // A progress indicator IS a splash by another name: it tells someone who
      // cannot speak to wait.
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Nothing is stacked ABOVE the board. Note this is deliberately not
      // `find.byType(ModalBarrier)`: ModalRoute builds a barrier for the
      // initial route too, so every MaterialApp with a `home:` has one and
      // asserting its absence fails against a perfectly good app. The real
      // question is whether anything was pushed on top of the grid.
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      expect(
        nav.canPop(),
        isFalse,
        reason:
            'Something is stacked above the board on the first frame. '
            'Someone opening this mid-shutdown must land on the grid, not on '
            'a thing to dismiss first.',
      );
    });

    testWidgets('restores a saved palette on the FIRST frame, not the second', (
      tester,
    ) async {
      await tester.pumpWidget(app(palette: AacPalette.hcPaper));

      // Deliberately no pump() before this read. A theme corrected on frame 2
      // is a sudden luminance change delivered to someone in a shutdown — the
      // exact event the animation ban exists to prevent.
      final ctx = tester.element(find.byType(BoardScreen));
      expect(AacTheme.of(ctx).palette, AacPalette.hcPaper);
    });

    testWidgets('a corrupt stored palette comes up on ink, not on an assert', (
      tester,
    ) async {
      // The stored value is whatever was on disk. It can be truncated, from a
      // future version, or garbage. Launch must survive all three: an assert
      // here is a blank window in front of someone who needs words, on a device
      // with no debugger attached.
      expect(paletteFromName('not-a-palette'), AacPalette.ink);
      expect(paletteFromName(null), AacPalette.ink);
      expect(paletteFromName(''), AacPalette.ink);

      await tester.pumpWidget(app(palette: paletteFromName('not-a-palette')));
      await tester.pump();

      final ctx = tester.element(find.byType(BoardScreen));
      expect(AacTheme.of(ctx).palette, AacPalette.ink);
    });
  });

  group('the engine never blocks the first frame', () {
    testWidgets('paints even when warmUp() never completes', (tester) async {
      final hung = FakeSpeechService(warmUpCompletes: false);
      await tester.pumpWidget(app(withSpeech: hung));
      await tester.pump();

      // If the launch path awaited warm-up, this frame would not exist. On a
      // real device that await is binder IPC on the main thread — an ANR that
      // no Flutter profile surfaces, in front of a user mid-shutdown.
      expect(find.byType(BoardScreen), findsOneWidget);
    });
  });

  group('theme cycle', () {
    testWidgets('cycles paper -> ink -> high contrast in three taps', (
      tester,
    ) async {
      await tester.pumpWidget(app(palette: AacPalette.paper));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BoardScreen)),
      );
      final controller = container.read(paletteProvider.notifier);

      expect(container.read(paletteProvider), AacPalette.paper);
      controller.cycle();
      expect(container.read(paletteProvider), AacPalette.ink);
      controller.cycle();
      // Three positions, four palettes: the HC polarity is a set-once
      // preference, because someone in a shutdown needs one tap to produce one
      // predictable next state.
      expect(
        container.read(paletteProvider),
        anyOf(AacPalette.hcInk, AacPalette.hcPaper),
      );
      controller.cycle();
      expect(container.read(paletteProvider), AacPalette.paper);
    });
  });
}
