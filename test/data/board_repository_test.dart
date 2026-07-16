import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/database/app_database.dart';

/// The repository is the only door between the UI and the database — no widget
/// imports drift — and its one non-negotiable promise is that a tile never
/// moves. These tests run against a real in-memory database, not a fake,
/// because the property under test (a delete empties a slot without shifting
/// any other) is a property of the SQL, and a fake would prove the fake obeys
/// it while the schema quietly did not.
void main() {
  late AppDatabase db;
  late BoardRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BoardRepository(db);
  });
  tearDown(() => db.close());

  test('the seeded root board reads as a full 4x3 grid', () async {
    final boardId = await repo.rootBoardId();
    final grid = await repo.readGrid(boardId);
    expect(grid.rows, equals(4));
    expect(grid.cols, equals(3));
    // Twelve addressable cells, all filled on the starter board.
    var filled = 0;
    for (var r = 0; r < grid.rows; r++) {
      for (var c = 0; c < grid.cols; c++) {
        if (grid.tileAt(r, c) != null) filled++;
      }
    }
    expect(filled, equals(12), reason: 'the starter board fills every cell');
  });

  test('deleting a button empties its cell and moves no other tile', () async {
    final boardId = await repo.rootBoardId();
    final before = await repo.readGrid(boardId);

    // A snapshot of every occupied coordinate and the label it holds.
    final labelAt = <String, String>{};
    for (var r = 0; r < before.rows; r++) {
      for (var c = 0; c < before.cols; c++) {
        final tile = before.tileAt(r, c);
        if (tile != null) labelAt['$r,$c'] = tile.label;
      }
    }

    // Delete the tile at (2, 2) — "I want to go" on the seeded board.
    final victim = before.tileAt(2, 2)!;
    await repo.deleteTile(victim.buttonId);
    final after = await repo.readGrid(boardId);

    expect(
      after.tileAt(2, 2),
      isNull,
      reason: 'the deleted coordinate is now empty',
    );
    for (var r = 0; r < after.rows; r++) {
      for (var c = 0; c < after.cols; c++) {
        if (r == 2 && c == 2) continue;
        final tile = after.tileAt(r, c);
        expect(
          tile?.label,
          equals(labelAt['$r,$c']),
          reason:
              'the tile at ($r, $c) must not have moved: a shifted board '
              'means the user presses a remembered position and speaks the '
              'wrong sentence',
        );
      }
    }
  });

  test(
    'an empty slot yields a null tile without disturbing its neighbours',
    () async {
      final boardId = await repo.rootBoardId();
      final victim = (await repo.readGrid(boardId)).tileAt(0, 0)!;
      await repo.deleteTile(victim.buttonId);

      final grid = await repo.readGrid(boardId);
      expect(grid.tileAt(0, 0), isNull);
      expect(
        grid.tileAt(0, 1),
        isNotNull,
        reason:
            'an empty coordinate is a hole, not a gap that pulls the row up',
      );
    },
  );

  test('label, vocalization and display_text fall back independently', () async {
    final boardId = await repo.rootBoardId();
    // Place a tile with a distinct value in each field so a swap cannot pass.
    final id = await repo.placeTile(
      boardId,
      0,
      0,
      label: 'SHOWN',
      vocalization: 'SPOKEN',
      displayText: 'POSTER',
    );
    var tile = (await repo.readGrid(boardId)).tileAt(0, 0)!;
    expect(tile.label, equals('SHOWN'));
    expect(tile.vocalization, equals('SPOKEN'));
    expect(tile.displayText, equals('POSTER'));

    // Editing with only a label leaves vocalization and display_text null. The
    // spoken text then falls back to the label, and the poster to
    // vocalization ?? label — the schema's own meaning for a null column.
    await repo.editTileText(id, label: 'ONLY');
    tile = (await repo.readGrid(boardId)).tileAt(0, 0)!;
    expect(tile.label, equals('ONLY'));
    expect(
      tile.vocalization,
      equals('ONLY'),
      reason: 'null vocalization speaks the label',
    );
    expect(
      tile.displayText,
      equals('ONLY'),
      reason: 'null display_text renders vocalization ?? label',
    );
  });

  test('watchGrid emits a new grid when a tile is deleted', () async {
    final boardId = await repo.rootBoardId();
    final emissions = <int>[];
    final sub = repo.watchGrid(boardId).listen((grid) {
      var filled = 0;
      for (var r = 0; r < grid.rows; r++) {
        for (var c = 0; c < grid.cols; c++) {
          if (grid.tileAt(r, c) != null) filled++;
        }
      }
      emissions.add(filled);
    });

    await Future<void>.delayed(Duration.zero);
    final victim = (await repo.readGrid(boardId)).tileAt(0, 0)!;
    await repo.deleteTile(victim.buttonId);
    await Future<void>.delayed(Duration.zero);

    await sub.cancel();
    expect(emissions.first, equals(12), reason: 'first emission is the seed');
    expect(
      emissions.last,
      equals(11),
      reason: 'the stream re-emits with the emptied cell',
    );
  });
}
