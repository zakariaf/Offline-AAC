import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/crash_log.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/board/board_controller.dart';

import 'fake_speech_service.dart';

/// A device to size the test viewport to.
///
/// The audience is cost-constrained, so the small end is where the layout has
/// to hold — a tile that overflows on a 360-wide phone at speak time is silence
/// for exactly the people this app is for. Widget tests default to an 800x600
/// desktop that hides those failures, so [WidgetTesterDevice.useDevice] makes
/// the target explicit.
enum Device {
  /// A small, cheap Android phone: 360x760 logical at 3x. Where it must work.
  small(360, 760, 3);

  const Device(this.width, this.height, this.dpr);
  final double width;
  final double height;
  final double dpr;
}

extension WidgetTesterDevice on WidgetTester {
  /// Sizes the viewport to [device]. Call before `pumpApp` in every widget test
  /// here, so nothing accidentally passes on a desktop-sized canvas.
  void useDevice(Device device) {
    view.physicalSize = Size(
      device.width * device.dpr,
      device.height * device.dpr,
    );
    view.devicePixelRatio = device.dpr;
    addTearDown(view.reset);
  }
}

/// A one-tile board, filled so a tap has something to speak.
///
/// The tile at (0,0) speaks a full sentence while showing a short label — the
/// label/vocalization split — so a test can assert the engine received the
/// sentence, not the handle. A canned grid, not the live database stream, keeps
/// drift's query-stream infrastructure (and the coalescing timer it schedules)
/// out of these tests.
BoardGrid cannedGrid({String phrase = 'I need a minute', int count = 1}) {
  Tile tile(int i, String label, String says) => Tile(
    buttonId: i + 1,
    row: 0,
    col: i,
    label: label,
    vocalization: says,
    displayText: says,
    hidden: false,
    isSystem: false,
  );
  final tiles = <Tile?>[tile(0, 'Minute', phrase)];
  if (count > 1) tiles.add(tile(1, 'Leave', 'I need to leave'));
  return BoardGrid(boardId: 1, rows: 1, cols: count, tiles: tiles);
}

extension WidgetTesterPumpApp on WidgetTester {
  /// Pumps the real app with the seam that matters — [speech] — faked, and
  /// everything else that would otherwise reach the network, the disk, or the
  /// device replaced with an in-memory or canned stand-in.
  Future<void> pumpApp({
    required FakeSpeechService speech,
    int tiles = 1,
  }) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          speechServiceProvider.overrideWithValue(speech),
          crashLogProvider.overrideWithValue(const CrashLog.discard()),
          gridProvider.overrideWith(
            (ref) => Stream.value(cannedGrid(count: tiles)),
          ),
        ],
        child: const ReedApp(),
      ),
    );
    // pump, never pumpAndSettle: the app has zero animation, so settling is
    // meaningless and is a known flake source.
    await pump();
  }
}
