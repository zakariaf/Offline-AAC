import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

/// The migration test, and the distinction it exists to enforce: a schema can
/// migrate perfectly and still drop every phrase. drift's verifier proves the
/// SHAPE survives — the tables, columns, and constraints — and is blind to the
/// rows. But the rows are the product. A user's board is months of hand-curated
/// sentences, irreplaceable and unmergeable, and there is no backup but their
/// own export and no telemetry to report the loss. So the shape check is
/// necessary and nowhere near sufficient; the content test below is the one
/// that matters.
///
/// The fixture is chosen to break naive serialization: a curly apostrophe, an
/// em dash beside non-ASCII, an emoji in a place a UTF-8 bug would mangle,
/// embedded quotes and a backslash, and a whitespace-only string that a `TRIM`
/// or an emptiness check would silently drop. No placeholder filler rows — a
/// fixture that reads like a stub gets skimmed, and the point is that every one
/// of these exact bytes comes back.
const List<({String label, String says})> _torture = [
  (label: 'It’s fine', says: 'It’s fine — really, I just can’t say it aloud.'),
  (label: 'Café — now', says: 'Café — now, before the noise gets worse. 日本語'),
  (label: '🫥 quiet', says: 'I need it 🫥 quiet in here for a minute.'),
  (label: r'quote\slash', says: r'She said "leave" and I had to \ go.'),
  (label: 'spaces', says: '   '),
];

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('schema shape survives every upgrade', () {
    // The nested loop is the whole point: it covers every from->to pair, not
    // just adjacent versions, because a user who skips six months of updates
    // migrates v1 straight to v3 without ever running v2's path. Bounded by
    // kLatestSchemaVersion so it grows automatically — adding a version never
    // requires editing this test. (At v1 there are no pairs yet; the harness is
    // in place for the day there are.)
    for (var from = 1; from < kLatestSchemaVersion; from++) {
      for (var to = from + 1; to <= kLatestSchemaVersion; to++) {
        test('v$from -> v$to', () async {
          final connection = await verifier.startAt(from);
          final db = AppDatabase.forTesting(connection.executor);
          await verifier.migrateAndValidate(db, to);
          await db.close();
        });
      }
    }

    test('the latest schema instantiates cleanly', () async {
      // A single shape assertion that exists today, so the group is not empty
      // before the first real migration lands.
      final schema = await verifier.schemaAt(kLatestSchemaVersion);
      expect(schema.rawDatabase, isNotNull);
      schema.rawDatabase.close();
    });
  });

  test('every phrase survives a migration, byte for byte', () async {
    // testWithDataIntegrity writes the fixture at the old version, runs the real
    // database's migration, and reads back at the new version. At v1 old==new,
    // so this is a degenerate migration today — but the assertions are the ones
    // that will catch a v2 that silently drops a column's data, and the fixture
    // is already in place to catch it.
    await verifier.testWithDataIntegrity(
      oldVersion: kLatestSchemaVersion,
      newVersion: kLatestSchemaVersion,
      createOld: v1.DatabaseAtV1.new,
      createNew: v1.DatabaseAtV1.new,
      openTestedDatabase: AppDatabase.forTesting,
      createItems: (batch, db) {
        // A 2x3 board: five phrases and one deliberately empty slot, so the
        // "empty is a hole, not a missing row" invariant is under test too.
        batch.insert(
          db.boards,
          v1.BoardsCompanion.insert(
            id: const Value(1),
            name: 'Fixture',
            gridRows: 2,
            gridCols: 3,
          ),
        );
        for (var i = 0; i < _torture.length; i++) {
          batch.insert(
            db.buttons,
            v1.ButtonsCompanion.insert(
              id: Value(i + 1),
              boardId: 1,
              label: _torture[i].label,
              vocalization: Value(_torture[i].says),
            ),
          );
        }
        // Six slots for a 2x3 board. Five point at a button; the sixth is empty.
        for (var r = 0; r < 2; r++) {
          for (var c = 0; c < 3; c++) {
            final index = r * 3 + c;
            batch.insert(
              db.gridSlots,
              v1.GridSlotsCompanion.insert(
                boardId: 1,
                rowIndex: r,
                colIndex: c,
                buttonId: index < _torture.length
                    ? Value(index + 1)
                    : const Value(null),
              ),
            );
          }
        }
      },
      validateItems: (db) async {
        final buttons = await db.select(db.buttons).get();
        final slots = await db.select(db.gridSlots).get();

        expect(
          slots,
          hasLength(_torture.length + 1),
          reason:
              'a 2x3 board must still hold exactly six slot rows: five '
              'filled and one empty. A migration that drops the empty row '
              'loses a coordinate and invites reflow',
        );
        expect(
          slots.where((s) => s.buttonId == null),
          hasLength(1),
          reason:
              'exactly one slot is empty. Zero means the empty coordinate '
              'was back-filled; two means a phrase was dropped',
        );

        // The load-bearing assertion: every phrase comes back byte for byte.
        final saysByLabel = {for (final b in buttons) b.label: b.vocalization};
        for (final phrase in _torture) {
          expect(
            saysByLabel[phrase.label],
            equals(phrase.says),
            reason:
                'the phrase "${phrase.label}" did not survive intact — '
                'this is someone’s voice, and it is unrecoverable',
          );
        }

        // A migration can leave a slot pointing at a button that no longer
        // exists. foreign_key_check finds exactly that, and an empty result is
        // the only acceptable one — a dangling reference is a blank or crashing
        // tile with no error anywhere.
        final violations = await db
            .customSelect('PRAGMA foreign_key_check')
            .get();
        expect(
          violations,
          isEmpty,
          reason:
              'a dangling foreign key after migration is a tile that '
              'renders blank or throws, silently',
        );
      },
    );
  });
}
