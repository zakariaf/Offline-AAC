import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/database/app_database.dart';

/// The schema's job is to make three product rules unbreakable, not merely
/// discouraged. These tests exercise the enforcement, because a rule that lives
/// only in a comment is a rule that fails at 2am, and there is no crash report
/// coming to tell anyone it did.
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('foreign keys are ON for the connection the app uses', () async {
    // SQLite defaults this OFF and stores it per-connection, so it must be set
    // on open. Without it, onDelete: setNull is silently ignored and a deleted
    // button leaves a dangling reference behind a blank tile.
    final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(
      result.data.values.first,
      equals(1),
      reason: 'foreign_keys must be ON, or delete-writes-null does nothing',
    );
  });

  test('a second slot at an existing coordinate is rejected', () async {
    final boardId = await db
        .into(db.boards)
        .insert(
          BoardsCompanion.insert(name: 'B', gridRows: 1, gridCols: 1),
        );
    await db
        .into(db.gridSlots)
        .insert(
          GridSlotsCompanion.insert(boardId: boardId, rowIndex: 0, colIndex: 0),
        );
    // The composite primary key is what makes reflow unrepresentable: two rows
    // cannot claim one coordinate, so there is nothing to reorder.
    await expectLater(
      db
          .into(db.gridSlots)
          .insert(
            GridSlotsCompanion.insert(
              boardId: boardId,
              rowIndex: 0,
              colIndex: 0,
            ),
          ),
      throwsA(isA<SqliteException>()),
      reason:
          'a duplicate coordinate must be a database error, not a silent '
          'second row',
    );
  });

  test('deleting a button writes NULL to its slot and moves nothing', () async {
    // A full 3-column, 4-row board: 12 slots, all filled.
    final boardId = await db
        .into(db.boards)
        .insert(
          BoardsCompanion.insert(name: 'B', gridRows: 4, gridCols: 3),
        );
    final ids = <String, int>{};
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 3; c++) {
        final buttonId = await db
            .into(db.buttons)
            .insert(
              ButtonsCompanion.insert(boardId: boardId, label: '$r$c'),
            );
        await db
            .into(db.gridSlots)
            .insert(
              GridSlotsCompanion.insert(
                boardId: boardId,
                rowIndex: r,
                colIndex: c,
                buttonId: Value<int?>(buttonId),
              ),
            );
        ids['$r,$c'] = buttonId;
      }
    }

    // Delete the button at (1, 1) — the button row, never the slot row.
    await (db.delete(db.buttons)..where((b) => b.id.equals(ids['1,1']!))).go();

    // Scoped to this board: onCreate seeds a Home board too, so an unscoped
    // query would also see those twelve slots.
    final slots = await (db.select(
      db.gridSlots,
    )..where((s) => s.boardId.equals(boardId))).get();
    expect(
      slots,
      hasLength(12),
      reason:
          'the slot count never changes; a delete empties a slot, it '
          'does not remove one',
    );

    final emptied = slots.firstWhere((s) => s.rowIndex == 1 && s.colIndex == 1);
    expect(
      emptied.buttonId,
      isNull,
      reason: 'onDelete: setNull must clear exactly this coordinate',
    );

    for (final s in slots.where((s) => !(s.rowIndex == 1 && s.colIndex == 1))) {
      expect(
        s.buttonId,
        equals(ids['${s.rowIndex},${s.colIndex}']),
        reason:
            'no other tile may move: (${s.rowIndex}, ${s.colIndex}) must '
            'still hold the button it started with',
      );
    }
  });

  test('a 2x3 board accepts slots at all six coordinates', () async {
    // The grid is not hardcoded 3x4. A CHECK baking the phone layout into the
    // schema would make the 2x3 large layout an insert failure at v2 — the exact
    // migration to avoid.
    final boardId = await db
        .into(db.boards)
        .insert(
          BoardsCompanion.insert(name: 'L', gridRows: 2, gridCols: 3),
        );
    for (var r = 0; r < 2; r++) {
      for (var c = 0; c < 3; c++) {
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
    final count =
        await (db.selectOnly(db.gridSlots)
              ..where(db.gridSlots.boardId.equals(boardId))
              ..addColumns([db.gridSlots.boardId.count()]))
            .getSingle();
    expect(count.read(db.gridSlots.boardId.count()), equals(6));
  });
}
