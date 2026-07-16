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
import 'package:offline_aac/ui/board/board_screen.dart';

import 'fake_speech_service.dart';
import 'fonts.dart';
import 'tiles.dart';

/// The phones the layout must hold on.
///
/// Widget tests default to an 800x600 desktop canvas, which hides every
/// overflow that only happens on a real phone. The audience is cost-constrained,
/// so the small end is where a tile that overflows at speak time is silence for
/// exactly the people this app is for. These are explicit so nothing passes on a
/// canvas no user has.
enum Device {
  /// The smallest screen still in use: an iPhone SE, 320x568 logical.
  seLike(320, 568, 2),

  /// A small, cheap Android phone, 360x800.
  small(360, 800, 3),

  /// A current mid-size Android, 412x915.
  pixel7(412, 915, 2.625);

  const Device(this.width, this.height, this.dpr);
  final double width;
  final double height;
  final double dpr;

  /// Every device, for a matrix that must hold across the range.
  static const List<Device> all = <Device>[seLike, small, pixel7];
}

/// The speak-screen test harness: size the viewport, then pump the real app with
/// only the seam that matters (the engine) faked.
extension AacHarness on WidgetTester {
  /// Sizes the viewport to [device]. Call before [pumpApp] in every widget
  /// test, so nothing accidentally passes on a desktop-sized canvas.
  void useDevice(Device device) {
    view.physicalSize = Size(
      device.width * device.dpr,
      device.height * device.dpr,
    );
    view.devicePixelRatio = device.dpr;
    addTearDown(view.reset);
  }

  /// Pumps the real board with a canned grid (not the live database stream,
  /// which schedules a coalescing timer that outlives a widget test) and the
  /// speech engine faked. [textScale] and [boldText] drive the overflow matrix;
  /// [grid] overrides the fixture; [db] wires a real database for the tests that
  /// need one instead of the canned grid.
  Future<void> pumpApp({
    FakeSpeechService? speech,
    BoardGrid? grid,
    double textScale = 1,
    bool boldText = false,
    AppDatabase? db,
    AacPalette palette = AacPalette.ink,
    CrashLog? crashLog,
    bool editing = false,
  }) async {
    // CrashLog is no longer const-constructible (it holds a mutable redaction
    // source), so a `const CrashLog.discard()` default is out; resolve the
    // fallback here instead.
    final log = crashLog ?? CrashLog.discard();
    // The board sizes its columns by MEASURING labels, so the whole suite must
    // render the shipped face. Under the default Ahem test font the fat glyphs
    // collapse the grid to one scrolling column even at 1x, pushing tiles
    // off-screen and making a plain tap miss. Idempotent; loads once per process.
    await loadAppFonts();

    final database = db ?? AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final overrides = <Override>[
      databaseProvider.overrideWithValue(database),
      speechServiceProvider.overrideWithValue(speech ?? FakeSpeechService()),
      crashLogProvider.overrideWithValue(log),
      initialPaletteProvider.overrideWithValue(palette),
    ];
    // With a real database, use its live grid; otherwise a canned fixture keeps
    // drift's stream infrastructure out of the test.
    if (db == null) {
      overrides.add(
        gridProvider.overrideWith(
          (ref) => Stream.value(grid ?? fixtureGrid()),
        ),
      );
    }

    await pumpWidget(
      ProviderScope(
        // A fresh key so a test that pumps more than once (a scale sweep, an
        // edit-then-reopen) gets a clean container each time instead of reusing
        // one whose board-controller state — a still-open editor, a lit tile —
        // leaked from the previous pump.
        key: UniqueKey(),
        overrides: overrides,
        child: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScale),
            boldText: boldText,
          ),
          child: const ReedApp(),
        ),
      ),
    );
    // Two pumps: the first mounts the tree, the second lets the canned
    // Stream.value emit into the StreamProvider so the real grid (not the
    // loading shell) is on screen before any assertion. Never pumpAndSettle —
    // the app has zero animation and settling is a known flake source.
    await pump();
    await pump();

    // Edit mode is board state, not a route: flip it through the controller the
    // app already owns, exactly as the visible toggle does, then settle the one
    // rebuild it causes.
    if (editing) {
      final container = ProviderScope.containerOf(
        element(find.byType(BoardScreen)),
      );
      container.read(boardControllerProvider.notifier).toggleEditing();
      await pump();
    }
  }
}
