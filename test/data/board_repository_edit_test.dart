import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/database/app_database.dart';

/// Editing a tile's text against a real database. The load-bearing invariant is
/// `user_edited`: the moment the user touches a tile, that phrase is theirs — a
/// one-way latch no seed, migration, or default-set update may ever cross. There
/// is no telemetry; if an update ate a curated phrase, nobody would learn it and
/// the person it happened to could not phone it in while unable to speak.
void main() {
  late AppDatabase db;
  late BoardRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BoardRepository(db);
  });
  tearDown(() => db.close());

  Future<int> firstButtonId() async {
    final grid = await repo.readGrid(await repo.rootBoardId());
    return grid.tileAt(0, 0)!.buttonId;
  }

  Future<Button> rawButton(int id) => (db.select(
    db.buttons,
  )..where((b) => b.id.equals(id))).getSingle();

  test('saving any edit sets user_edited to 1', () async {
    final id = await firstButtonId();
    expect(
      (await rawButton(id)).userEdited,
      isFalse,
      reason: 'seed is unedited',
    );

    await repo.editTileText(id, label: 'Mine now');
    expect((await rawButton(id)).userEdited, isTrue);
  });

  test(
    'saving with "What it says" never opened writes vocalization NULL',
    () async {
      // NULL, not a copy of the label: the schema falls back to the label, so a
      // later label edit never strands a stale sentence the tile still speaks.
      final id = await firstButtonId();
      await repo.editTileText(id, label: 'Hello');
      expect((await rawButton(id)).vocalization, isNull);
    },
  );

  test('an opened "What it says" is written for real', () async {
    final id = await firstButtonId();
    await repo.editTileText(
      id,
      label: 'Hi',
      vocalization: 'Hello there, friend',
    );
    expect((await rawButton(id)).vocalization, 'Hello there, friend');
  });

  test('a straight apostrophe is curled on save, in label and says', () async {
    final id = await firstButtonId();
    await repo.editTileText(
      id,
      label: "I can't",
      vocalization: "I can't talk",
    );
    final row = await rawButton(id);
    expect(row.label, 'I can’t');
    expect(row.vocalization, 'I can’t talk');
    expect(row.label.contains("'"), isFalse);
  });

  test(
    'nothing else is transformed — no case change, no appended period',
    () async {
      final id = await firstButtonId();
      await repo.editTileText(id, label: 'wtf no', vocalization: 'wtf no');
      final row = await rawButton(id);
      expect(row.label, 'wtf no');
      expect(row.vocalization, 'wtf no');
    },
  );

  test(
    'profanity saves unchanged, with no filter and no confirmation',
    () async {
      // Filtering a disabled person's own speech is the paternalism this product
      // exists to oppose. The repository stores exactly what it is given.
      final id = await firstButtonId();
      const blunt = 'piss off';
      await repo.editTileText(id, label: blunt);
      expect((await rawButton(id)).label, blunt);
    },
  );

  test('the 17th label character is refused at the boundary', () async {
    // 17 chars must not persist — the repository is the last line if the field
    // formatter is ever bypassed. It refuses; it never substrings to 16.
    final id = await firstButtonId();
    expect(
      () => repo.editTileText(id, label: '12345678901234567'),
      throwsArgumentError,
    );
    // And the untouched row still carries its original label.
    expect((await rawButton(id)).label.length, lessThanOrEqualTo(16));
  });

  test(
    'a default-set pass that filters user_edited=0 leaves an edited row intact',
    () async {
      // The hard stop lives in the WHERE clause of any default-content path, and
      // this is the shape that path must take. An edited row is byte-identical
      // after it runs; an unedited row is fair game.
      final id = await firstButtonId();
      await repo.editTileText(
        id,
        label: 'Curated',
        vocalization: 'My own words',
      );
      final before = await rawButton(id);

      // Simulate the ONLY safe default-set update: WHERE user_edited = 0.
      await (db.update(
        db.buttons,
      )..where((b) => b.userEdited.equals(false))).write(
        const ButtonsCompanion(label: Value<String>('DEFAULT')),
      );

      final after = await rawButton(id);
      expect(
        after.label,
        before.label,
        reason: 'the edited phrase is untouched',
      );
      expect(after.vocalization, before.vocalization);
    },
  );
}
