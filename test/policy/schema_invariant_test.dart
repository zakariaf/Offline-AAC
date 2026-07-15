import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// The grid_slots primary key is the mechanism that makes tile reflow
/// unrepresentable. A surrogate key would permit two rows claiming one
/// coordinate and quietly re-enable it — and no test, no lint, and no crash
/// report would surface that. It shows up only as a real person pressing a
/// remembered position and saying the wrong sentence out loud.
void main() {
  final tables = File('lib/data/database/tables.dart');

  test(
    'grid_slots keeps the composite primary key and gains no surrogate id',
    () {
      final code = stripComments(tables.readAsStringSync());
      final match = RegExp(
        r'class GridSlots extends Table \{(.*?)\n\}',
        dotAll: true,
      ).firstMatch(code);
      expect(match, isNotNull, reason: 'GridSlots table not found');
      final body = match!.group(1)!;

      expect(
        body,
        contains('primaryKey => {boardId, rowIndex, colIndex}'),
        reason: 'Position IS the primary key. Removing it re-enables reflow.',
      );
      expect(
        body,
        isNot(contains('autoIncrement()')),
        reason:
            'A surrogate id permits two rows per coordinate. If a change '
            'needs one here, the change is wrong.',
      );
      for (final banned in ['get order', 'get position', 'get sortIndex']) {
        expect(
          body,
          isNot(contains(banned)),
          reason:
              'An ordering column re-enables reflow: a delete shifts the '
              'grid and the user speaks the wrong sentence.',
        );
      }
    },
  );

  test('foreign keys are enabled unconditionally', () {
    final db = File('lib/data/database/app_database.dart');
    final code = stripComments(db.readAsStringSync());
    // SQLite defaults FKs OFF, per-connection. grid_slots.button_id is a
    // nullable FK whose whole purpose is onDelete: setNull — with FKs off,
    // SQLite SILENTLY IGNORES the action and leaves a dangling reference.
    expect(
      code,
      contains('PRAGMA foreign_keys = ON'),
      reason: 'Without this, onDelete: setNull is silently ignored.',
    );
  });
}
