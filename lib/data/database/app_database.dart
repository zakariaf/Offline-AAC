import 'package:drift/drift.dart';

import 'package:offline_aac/data/database/app_database.steps.dart';
import 'package:offline_aac/data/database/connection.dart';
import 'package:offline_aac/data/database/tables.dart';
import 'package:offline_aac/data/seed/starter_phrases.dart';

part 'app_database.g.dart';

/// The current schema version, for the migration test's shape loop.
///
/// It must equal [AppDatabase.schemaVersion] below. They are two lines apart so
/// they move together, and a startup assertion pins them — `drift_dev`'s static
/// analysis cannot read a const reference for `schemaVersion`, so that getter
/// has to return the literal, and this constant mirrors it for the tests.
///
/// Bump this and dump the schema in the same commit. Dumping AFTER the bump
/// records the wrong shape, and then the migration test validates a lie.
const int kLatestSchemaVersion = 2;

@DriftDatabase(tables: [Boards, Buttons, GridSlots, Images, Sounds, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Test constructor. Pass `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.e);

  /// A literal, not `kLatestSchemaVersion`: `drift_dev`'s static analysis reads
  /// this getter to know the current version and cannot resolve a const
  /// reference. It must equal [kLatestSchemaVersion]; a policy test asserts it.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Seed the starter board here, inside onCreate, so it runs exactly once
      // in the life of the file. A fresh install opens straight onto a working
      // board rather than an empty grid — the install may itself be the crisis —
      // and a board the user has since made their own is never touched, because
      // onCreate never fires again.
      await seedStarterBoard(this);
    },
    // v1 -> v2 adds buttons.priority, the screen-reader traversal order. Every
    // existing button gets the column's default; the seed's priorities apply
    // only to fresh installs. The step-by-step helper runs each version's
    // migration in turn, so a user who skipped a release still crosses every
    // step rather than jumping the gap — the migration test proves phrases
    // survive it byte for byte.
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.buttons, schema.buttons.priority);
      },
    ),
    beforeOpen: (details) async {
      // SQLite defaults foreign keys OFF, and the setting is PER-CONNECTION
      // rather than stored in the file. This is unconditional and must stay
      // that way: grid_slots.button_id is a nullable FK whose entire purpose
      // is `onDelete: setNull`. With FKs off, SQLite SILENTLY IGNORES that
      // action — the delete succeeds, the slot keeps a dangling button_id,
      // and the tile renders blank or throws. Nothing else in the toolchain
      // checks this.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
