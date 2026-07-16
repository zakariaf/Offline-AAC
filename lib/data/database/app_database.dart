import 'package:drift/drift.dart';

import 'package:offline_aac/data/database/connection.dart';
import 'package:offline_aac/data/database/tables.dart';
import 'package:offline_aac/data/seed/starter_phrases.dart';

part 'app_database.g.dart';

/// The current schema version, in one place so nothing drifts from it.
///
/// The migration test's shape loop reads this to know how many versions to
/// cross, and [AppDatabase.schemaVersion] returns it. Bump this and dump the
/// schema in the same commit — dumping AFTER the bump records the wrong shape,
/// and then the migration test validates a lie.
const int kLatestSchemaVersion = 1;

@DriftDatabase(tables: [Boards, Buttons, GridSlots, Images, Sounds, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Test constructor. Pass `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.e);

  /// Bump this ONLY together with a schema dump. Dump BEFORE bumping, or the
  /// snapshot records the wrong shape and the migration test validates a lie.
  @override
  int get schemaVersion => kLatestSchemaVersion;

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
