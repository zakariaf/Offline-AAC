import 'package:drift/drift.dart';

import 'package:offline_aac/data/database/connection.dart';
import 'package:offline_aac/data/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Boards, Buttons, GridSlots, Images, Sounds, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Test constructor. Pass `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.e);

  /// Bump this ONLY together with a schema dump. Dump BEFORE bumping, or the
  /// snapshot records the wrong shape and the migration test validates a lie.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
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
