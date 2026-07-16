import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/database/app_database.dart';

/// Hide is a flag on the button, never a NULL in the slot. The slot keeps its
/// `button_id`, so the coordinate, the phrase, the vocalization, and the colours
/// all survive intact and Unhide is a one-tap reversal. Implemented as a slot
/// NULL it would look identical on screen and be unrecoverable — the coordinate
/// would forget which phrase lived there.
void main() {
  late AppDatabase db;
  late BoardRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BoardRepository(db);
  });
  tearDown(() => db.close());

  Future<Button> button(int id) =>
      (db.select(db.buttons)..where((b) => b.id.equals(id))).getSingle();

  Future<int> nonSystemButtonId() async {
    final grid = await repo.readGrid(await repo.rootBoardId());
    for (var r = 0; r < grid.rows; r++) {
      for (var c = 0; c < grid.cols; c++) {
        final tile = grid.tileAt(r, c);
        if (tile != null && !tile.isSystem) return tile.buttonId;
      }
    }
    throw StateError('no non-system button on the seeded board');
  }

  Future<int> systemButtonId() async {
    final row = await (db.select(
      db.buttons,
    )..where((b) => b.isSystem.equals(true))).getSingle();
    return row.id;
  }

  Future<int?> slotButtonFor(int buttonId) async {
    final slot = await (db.select(
      db.gridSlots,
    )..where((s) => s.buttonId.equals(buttonId))).getSingleOrNull();
    return slot?.buttonId;
  }

  test(
    'hide sets hidden=1 and leaves the slot pointing at the button',
    () async {
      final id = await nonSystemButtonId();
      await repo.setHidden(id, hidden: true);

      expect((await button(id)).hidden, isTrue);
      expect(
        await slotButtonFor(id),
        id,
        reason: 'the slot still points at the hidden button — hide is a flag',
      );
      expect((await button(id)).userEdited, isTrue);
    },
  );

  test('unhide restores it with a single flag flip', () async {
    final id = await nonSystemButtonId();
    await repo.setHidden(id, hidden: true);
    await repo.setHidden(id, hidden: false);
    expect((await button(id)).hidden, isFalse);
    expect(await slotButtonFor(id), id, reason: 'nothing was ever lost');
  });

  test('hiding the repair phrase throws and mutates nothing', () async {
    final id = await systemButtonId();
    final before = await button(id);

    expect(() => repo.setHidden(id, hidden: true), throwsStateError);

    final after = await button(id);
    expect(
      after.hidden,
      before.hidden,
      reason: 'the system phrase is untouched',
    );
    expect(after.hidden, isFalse);
  });
}
