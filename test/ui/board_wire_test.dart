import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:offline_aac/model/aac_palette.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/board/compose_field.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/fake_speech_service.dart';
import '../support/fonts.dart';
import '../support/harness.dart';
import '../support/tiles.dart';

/// The grid, wired to the real board on disk, and the one silent bug that lives
/// on this seam: a tap closure that captured the tile it saw at build time
/// speaks the PREVIOUS sentence after an edit — the wrong words, aloud, to a
/// stranger, on behalf of someone who cannot correct them. Position is the
/// primary key and cannot go stale; content behind it can. The staleness test
/// below is the whole reason this task exists, and it fails the instant the tap
/// path reads a captured value instead of resolving `(row, col)` live.
void main() {
  Finder tileAt(int row, int col) => find.byWidgetPredicate(
    (w) => w is PhraseTile && w.row == row && w.col == col,
  );

  // The live drift stream schedules a coalescing timer, and a widget test's fake
  // clock flags it as "a Timer is still pending" the moment the tree disposes —
  // unless the database is closed first, which cancels it. So these tests own
  // their scope (no harness auto-teardown of the db) and close it in-body, in
  // real async, before the invariant check runs. The harness's canned-grid path
  // exists precisely to keep this off every other test; here the live stream is
  // the point.
  Future<void> pumpLiveBoard(
    WidgetTester tester,
    AppDatabase db,
    FakeSpeechService speech,
  ) async {
    await loadAppFonts();
    tester.useDevice(Device.small);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          speechServiceProvider.overrideWithValue(speech),
          crashLogProvider.overrideWithValue(CrashLog.discard()),
          initialPaletteProvider.overrideWithValue(AacPalette.ink),
        ],
        child: const ReedApp(),
      ),
    );
    // rootBoardId() opens and seeds the db, then watchGrid yields; a poke in real
    // async resolves that chain and the pumps render what it produced.
    await tester.runAsync(() => db.customSelect('SELECT 1').get());
    await tester.pump();
    await tester.pump();
  }

  testWidgets('renders the seeded board from real in-memory sqlite', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await pumpLiveBoard(tester, db, FakeSpeechService());

    expect(find.byType(PhraseTile), findsNWidgets(12));
    expect(
      find.text('Yes'),
      findsOneWidget,
      reason: 'the real starter seed, materialised through the repository',
    );

    await tester.runAsync(db.close);
  });

  testWidgets('a re-tap after an edit speaks the NEW sentence, not the old', (
    tester,
  ) async {
    // The capture bug is a UI/controller property — does the tap resolve
    // (row, col) LIVE, or replay the tile it saw at build time? A controllable
    // stream drives it deterministically: emit the edited grid, then tap. That
    // the real repository materialises a grid correctly is the render test's job
    // (and the data layer's); this isolates the one hole where a stale closure
    // speaks the wrong sentence aloud to a stranger.
    const oldWords = 'The sentence before the edit.';
    const newWords = 'These are brand new words for slot zero.';

    BoardGrid saying(String vocalization) {
      final tiles = List<Tile?>.from(kTestTiles);
      final base = tiles[0]!;
      tiles[0] = Tile(
        buttonId: base.buttonId,
        row: 0,
        col: 0,
        label: base.label,
        vocalization: vocalization,
        displayText: vocalization,
        hidden: false,
        isSystem: false,
        priority: base.priority,
      );
      return BoardGrid(boardId: 1, rows: 4, cols: 3, tiles: tiles);
    }

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final controller = StreamController<BoardGrid>();
    addTearDown(controller.close);
    final speech = FakeSpeechService();

    await loadAppFonts();
    tester.useDevice(Device.small);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          speechServiceProvider.overrideWithValue(speech),
          crashLogProvider.overrideWithValue(CrashLog.discard()),
          initialPaletteProvider.overrideWithValue(AacPalette.ink),
          gridProvider.overrideWith((ref) => controller.stream),
        ],
        child: const ReedApp(),
      ),
    );

    controller.add(saying(oldWords));
    await tester.pump();
    await tester.pump();

    // The edit lands. A tap now must speak these words, not the ones the tile
    // was built with.
    controller.add(saying(newWords));
    await tester.pump();
    await tester.pump();

    await tester.tap(tileAt(0, 0));
    await tester.pump();

    expect(
      speech.spoken,
      contains(newWords),
      reason:
          'the tap resolved (0,0) live; a captured tile would speak the old '
          'sentence',
    );
    expect(speech.spoken, isNot(contains(oldWords)));
  });

  testWidgets('an empty slot holds its space and speaks nothing when tapped', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(
      grid: fixtureGrid(emptyAt: (0, 0)),
      speech: speech,
    );

    expect(
      find.byType(PhraseTile),
      findsNWidgets(12),
      reason: 'the empty cell is still a cell, not a missing one',
    );
    expect(tester.getSize(tileAt(0, 0)).width, greaterThan(0));

    await tester.tap(tileAt(0, 0), warnIfMissed: false);
    await tester.pump();

    expect(
      speech.calls,
      isEmpty,
      reason: 'an empty slot has no phrase; a tap on it says nothing',
    );
    expect(tester.takeException(), isNull);
  });

  group('every AsyncValue arm renders a grid-shaped shell, never a spinner', () {
    Widget scope({
      required AppDatabase db,
      required Stream<BoardGrid> grid,
      CrashLog? log,
    }) {
      final crashLog = log ?? CrashLog.discard();
      // No MediaQuery wrapper: a bare MediaQueryData() would zero the view size
      // that useDevice just pinned. ReedApp's own MediaQuery.fromView carries it.
      return ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          speechServiceProvider.overrideWithValue(FakeSpeechService()),
          crashLogProvider.overrideWithValue(crashLog),
          initialPaletteProvider.overrideWithValue(AacPalette.ink),
          gridProvider.overrideWith((ref) => grid),
        ],
        child: const ReedApp(),
      );
    }

    void expectShell(WidgetTester tester) {
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
        reason: 'a spinner tells someone who cannot speak to wait',
      );
      expect(
        find.byType(PhraseTile),
        findsNWidgets(12),
        reason: 'the shell holds the full grid shape so nothing collapses',
      );
      expect(
        find.byWidgetPredicate((w) => w is PhraseTile && w.tile != null),
        findsNothing,
        reason: 'the shell is empty cells, not stale data',
      );
      expect(find.byType(ComposeField), findsOneWidget);
    }

    testWidgets('loading', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final controller = StreamController<BoardGrid>();
      addTearDown(controller.close);

      tester.useDevice(Device.small);
      await tester.pumpWidget(scope(db: db, grid: controller.stream));
      await tester.pump();

      expectShell(tester);
    });

    testWidgets('error', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final logFile = _tempFile();
      addTearDown(() => logFile.parent.deleteSync(recursive: true));

      tester.useDevice(Device.small);
      await tester.pumpWidget(
        scope(
          db: db,
          grid: Stream<BoardGrid>.error(StateError('board read blew up')),
          log: CrashLog.atFile(logFile),
        ),
      );
      await tester.pump();

      expectShell(tester);
      expect(
        logFile.readAsStringSync(),
        contains('board read failed'),
        reason: 'a failed read is recorded — the only channel there is',
      );
    });
  });
}

File _tempFile() => File(
  '${Directory.systemTemp.createTempSync('reed_wire').path}/crash_log.txt',
);
