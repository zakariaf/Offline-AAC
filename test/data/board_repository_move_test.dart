import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/database/app_database.dart';

/// Reordering, expressed as a swap that cannot reflow. `grid_slots` is keyed
/// `(board_id, row_index, col_index)` with a nullable `button_id`, so a move is
/// two `button_id` writes into two rows that already exist — never a change to a
/// primary-key column, never a delete-and-insert. If this ever renumbered or
/// dropped a slot, a real person would press their muscle-memory tile and say
/// the wrong sentence, and no telemetry would ever say so.
void main() {
  late AppDatabase db;
  late BoardRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BoardRepository(db);
  });
  tearDown(() => db.close());

  Future<int?> buttonIdAt(int boardId, int row, int col) async {
    final slot =
        await (db.select(db.gridSlots)..where(
              (s) =>
                  s.boardId.equals(boardId) &
                  s.rowIndex.equals(row) &
                  s.colIndex.equals(col),
            ))
            .getSingle();
    return slot.buttonId;
  }

  Future<int> slotCount(int boardId) async {
    final rows = await (db.select(
      db.gridSlots,
    )..where((s) => s.boardId.equals(boardId))).get();
    return rows.length;
  }

  /// A board of `rows x cols` empty slots, plus its board row. Bounds must be
  /// read from this row, not a constant — the 2x3 crisis layout ships alongside
  /// the 3x4 default.
  Future<int> makeBoard({required int rows, required int cols}) async {
    final boardId = await db
        .into(db.boards)
        .insert(
          BoardsCompanion.insert(name: 'test', gridRows: rows, gridCols: cols),
        );
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        await db
            .into(db.gridSlots)
            .insert(
              GridSlotsCompanion.insert(
                boardId: boardId,
                rowIndex: r,
                colIndex: c,
              ),
            );
      }
    }
    return boardId;
  }

  test('foreign keys are ON on the connection under test', () async {
    // onDelete: setNull — the whole delete mechanism — is a silent no-op with
    // FKs off, and SQLite does not error. Assert the pragma directly.
    final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(result.data.values.first, 1);
  });

  test(
    'moveUp swaps a tile with the empty slot above it; nothing reflows',
    () async {
      final boardId = await repo.rootBoardId(); // seeded 4 rows x 3 cols, full
      // Empty (1,1) by deleting its button, then move (2,1) up into it.
      final at21 = await buttonIdAt(boardId, 2, 1);
      await repo.deleteTile((await buttonIdAt(boardId, 1, 1))!);

      await repo.moveUp(boardId, 2, 1);

      expect(
        await buttonIdAt(boardId, 1, 1),
        at21,
        reason: 'the tile moved up',
      );
      expect(
        await buttonIdAt(boardId, 2, 1),
        isNull,
        reason: 'empty landed below',
      );
      expect(await slotCount(boardId), 12, reason: 'exactly rows x cols slots');
    },
  );

  test('after a move every coordinate is present exactly once', () async {
    final boardId = await repo.rootBoardId();
    await repo.moveDown(boardId, 0, 0);

    final slots = await (db.select(
      db.gridSlots,
    )..where((s) => s.boardId.equals(boardId))).get();
    final coords = slots.map((s) => '${s.rowIndex},${s.colIndex}').toSet();
    expect(coords.length, 12, reason: 'no coordinate missing or duplicated');
    expect(await slotCount(boardId), 12);
  });

  test('moveDown of a full column is a true swap, not an overwrite', () async {
    final boardId = await repo.rootBoardId();
    final at00 = await buttonIdAt(boardId, 0, 0);
    final at10 = await buttonIdAt(boardId, 1, 0);

    await repo.moveDown(boardId, 0, 0);

    expect(await buttonIdAt(boardId, 1, 0), at00);
    expect(await buttonIdAt(boardId, 0, 0), at10, reason: 'the tiles traded');

    // No button_id appears in two slots.
    final slots = await (db.select(
      db.gridSlots,
    )..where((s) => s.boardId.equals(boardId))).get();
    final ids = slots.map((s) => s.buttonId).whereType<int>().toList();
    expect(ids.length, ids.toSet().length, reason: 'no button in two slots');
  });

  test('a move sets user_edited on the moved button', () async {
    final boardId = await repo.rootBoardId();
    final movedId = (await buttonIdAt(boardId, 0, 0))!;
    // Confirm the seed left it unedited first.
    Future<bool> edited(int id) async => (await (db.select(
      db.buttons,
    )..where((b) => b.id.equals(id))).getSingle()).userEdited;
    expect(await edited(movedId), isFalse);

    await repo.moveDown(boardId, 0, 0);
    expect(await edited(movedId), isTrue);
  });

  test('a 2x3 board reads its bounds from the board row', () async {
    final boardId = await makeBoard(rows: 2, cols: 3);
    await repo.placeTile(boardId, 1, 0, label: 'Bottom');

    // Row 1 is the last row on a 2-row board: moveDown must refuse.
    expect(() => repo.moveDown(boardId, 1, 0), throwsStateError);
    // But moveUp from row 1 is fine.
    await repo.moveUp(boardId, 1, 0);
    expect(await buttonIdAt(boardId, 0, 0), isNotNull);
    expect(await slotCount(boardId), 6);
  });

  test(
    'moveUp from row 0 refuses rather than silently doing nothing',
    () async {
      final boardId = await repo.rootBoardId();
      expect(() => repo.moveUp(boardId, 0, 0), throwsStateError);
    },
  );
}
