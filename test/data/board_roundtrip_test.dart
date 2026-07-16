import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_export.dart';
import 'package:offline_aac/data/board_import.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/media_store.dart';
import 'package:path/path.dart' as p;

/// A board survives export and import with every tile at its original
/// coordinate, every empty slot still empty, every hidden button still hidden,
/// every user_edited flag intact, and its text byte-for-byte identical. The
/// import lands as a NEW board and touches nothing in the board already on the
/// phone but its is_root flag.
void main() {
  // These tests deliberately hold a source and a target database at once; the
  // warning is about a SHARED executor, which they do not have (separate
  // in-memory connections).
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory tmp;
  late MediaStore sourceMedia;
  late MediaStore targetMedia;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('reed_roundtrip');
    sourceMedia = MediaStore(
      Directory(p.join(tmp.path, 'source_docs'))..createSync(),
    );
    targetMedia = MediaStore(
      Directory(p.join(tmp.path, 'target_docs'))..createSync(),
    );
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  /// Export [db] and return the zip bytes, proving in passing that the staging
  /// file is gone once the (fake) share sheet returns and that nothing was ever
  /// written under the documents directory.
  Future<Uint8List> exportBytes(AppDatabase db, MediaStore media) async {
    final staging = Directory(p.join(tmp.path, 'cache'))..createSync();
    Set<String> docFiles() =>
        media.documentsDir.listSync(recursive: true).map((e) => e.path).toSet();
    final docsBefore = docFiles();

    Uint8List? captured;
    var stagingFileExistedDuringShare = false;
    await BoardExport(db, media).run(
      stagingDir: staging,
      now: DateTime.utc(2026, 7, 16),
      reedVersion: '0.1.0',
      share: (file) async {
        stagingFileExistedDuringShare = file.existsSync();
        captured = await file.readAsBytes();
      },
    );
    expect(stagingFileExistedDuringShare, isTrue);
    expect(
      staging.listSync(),
      isEmpty,
      reason: 'the staging zip is plaintext; it must be deleted once shared',
    );
    expect(
      docFiles(),
      docsBefore,
      reason:
          'export writes NOTHING new under documents — that is where the DB '
          'lives; it stages in cache and copies media out, never in',
    );
    return captured!;
  }

  test('a full board round-trips with every field intact', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    await _wipe(source);
    final built = await _buildSource(source);

    final before = await _snapshot(source, built.boardId);
    // Sanity: the fixture is what the test claims — two empty cells, one hidden.
    expect(before.values.where((c) => c == null).length, 2);
    expect(before.values.whereType<_Cell>().where((c) => c.hidden).length, 1);

    final bytes = await exportBytes(source, sourceMedia);
    await source.close();

    final target = AppDatabase.forTesting(NativeDatabase.memory());
    await BoardImport(target, targetMedia).importBytes(bytes);

    final importedRoot = await _rootBoard(target);
    final after = await _snapshot(target, importedRoot.id);

    expect(
      after.keys.toSet(),
      before.keys.toSet(),
      reason: 'the imported board holds exactly grid_rows x grid_cols slots',
    );
    for (final coord in before.keys) {
      final was = before[coord];
      final now = after[coord];
      if (was == null) {
        expect(
          now,
          isNull,
          reason: 'empty slot at $coord came back filled — a reflow',
        );
        continue;
      }
      expect(now, isNotNull, reason: 'tile at $coord vanished');
      // Text byte-identical, all three fields, distinct per button so a swap
      // cannot pass. Then the flags that make a phrase the user's.
      expect(now!.label, was.label, reason: 'label at $coord');
      expect(
        now.vocalization,
        was.vocalization,
        reason: 'vocalization at $coord',
      );
      expect(
        now.displayText,
        was.displayText,
        reason: 'display_text at $coord',
      );
      expect(now.hidden, was.hidden, reason: 'hidden at $coord');
      expect(now.userEdited, was.userEdited, reason: 'user_edited at $coord');
      expect(now.isSystem, was.isSystem, reason: 'is_system at $coord');
      expect(now.priority, was.priority, reason: 'priority at $coord');
    }

    await target.close();
  });

  test(
    'a null vocalization stays null — the fallback is not resolved',
    () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      await _wipe(source);
      final built = await _buildSource(source);
      final bytes = await exportBytes(source, sourceMedia);
      await source.close();

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      await BoardImport(target, targetMedia).importBytes(bytes);

      final importedRoot = await _rootBoard(target);
      final after = await _snapshot(target, importedRoot.id);
      final nullVocCell = after[built.nullVocalizationCoord]!;
      expect(
        nullVocCell.vocalization,
        isNull,
        reason:
            'null means "fall back to label"; resolving it at export ships a '
            'different utterance',
      );
      expect(nullVocCell.label, isNotEmpty);

      await target.close();
    },
  );

  test('foreign keys are on and hold after import', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    await _wipe(source);
    await _buildSource(source);
    final bytes = await exportBytes(source, sourceMedia);
    await source.close();

    final target = AppDatabase.forTesting(NativeDatabase.memory());
    await BoardImport(target, targetMedia).importBytes(bytes);

    final fkOn = await target.customSelect('PRAGMA foreign_keys').getSingle();
    expect(
      fkOn.data.values.first,
      1,
      reason: 'FKs off silently accept dangling refs',
    );

    final violations = await target
        .customSelect('PRAGMA foreign_key_check')
        .get();
    expect(violations, isEmpty);

    // Every slot points at a button that exists, or at null.
    final buttonIds = (await target.select(target.buttons).get())
        .map((b) => b.id)
        .toSet();
    final slots = await target.select(target.gridSlots).get();
    for (final slot in slots) {
      if (slot.buttonId != null) {
        expect(buttonIds, contains(slot.buttonId));
      }
    }

    await target.close();
  });

  test('import into a DB with a user-edited board leaves it untouched '
      'but for is_root', () async {
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    // The board the user already has, with a tile they have touched.
    final existingRoot = await _rootBoard(target);
    final aButton = (await target.select(target.buttons).get()).firstWhere(
      (b) => !b.isSystem,
    );
    await (target.update(target.buttons)..where((b) => b.id.equals(aButton.id)))
        .write(const ButtonsCompanion(userEdited: Value(true)));
    final oldBoardBefore = await _fullRows(target, existingRoot.id);
    final oldButtonIds = (await target.select(target.buttons).get())
        .map((b) => b.id)
        .toSet();

    // A board exported from somewhere else.
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    await _wipe(source);
    await _buildSource(source);
    final bytes = await exportBytes(source, sourceMedia);
    await source.close();

    await BoardImport(target, targetMedia).importBytes(bytes);

    // The old board's rows are bit-for-bit unchanged, except is_root.
    final oldBoardAfter = await _fullRows(target, existingRoot.id);
    expect(
      oldBoardAfter.buttons,
      oldBoardBefore.buttons,
      reason: 'every button of the board the user had must be identical',
    );
    expect(oldBoardAfter.slots, oldBoardBefore.slots);
    expect(
      oldBoardAfter.board.copyWith(isRoot: true),
      oldBoardBefore.board,
      reason: 'only is_root may differ on the previous board',
    );
    expect(oldBoardAfter.board.isRoot, isFalse);

    // The imported buttons have fresh, non-colliding ids.
    final importedRoot = await _rootBoard(target);
    final importedButtons = await (target.select(
      target.buttons,
    )..where((b) => b.boardId.equals(importedRoot.id))).get();
    for (final b in importedButtons) {
      expect(
        oldButtonIds,
        isNot(contains(b.id)),
        reason: 'a reused file id would line slots up with the wrong button',
      );
    }

    await target.close();
  });

  test('imported media path is relative and resolves under documents', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    await _wipe(source);
    final built = await _buildSource(source);

    // A real image file under the SOURCE documents base, and a button that uses
    // it, so export copies the bytes out and import writes them back in.
    const imageBytes = <int>[0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4, 0xFF, 0xD9];
    final relative = await sourceMedia.write(
      sourceMedia.imageRelativePath(1, 'jpg'),
      imageBytes,
    );
    final imageId = await source
        .into(source.images)
        .insert(
          ImagesCompanion.insert(
            path: relative,
            contentType: 'image/jpeg',
            width: 512,
            height: 384,
            attribution: const Value('CC-BY someone'),
          ),
        );
    await (source.update(source.buttons)
          ..where((b) => b.id.equals(built.firstButtonId)))
        .write(ButtonsCompanion(imageId: Value(imageId)));

    final bytes = await exportBytes(source, sourceMedia);
    await source.close();

    final target = AppDatabase.forTesting(NativeDatabase.memory());
    await BoardImport(target, targetMedia).importBytes(bytes);

    final rows = await target.select(target.images).get();
    expect(rows, hasLength(1));
    final row = rows.single;
    expect(
      p.isAbsolute(row.path),
      isFalse,
      reason: 'an absolute path dies on restore',
    );
    expect(row.path, isNot(contains(tmp.path)));
    expect(
      row.path.toLowerCase(),
      isNot(contains('cache')),
      reason: 'no staging/cache path may be baked into the row',
    );
    // The file resolves under the DOCUMENTS base, not the support (DB) base.
    final resolved = targetMedia.resolve(row.path);
    expect(resolved.existsSync(), isTrue);
    expect(await resolved.readAsBytes(), imageBytes);
    expect(
      row.attribution,
      'CC-BY someone',
      reason: 'attribution travels or it is a licence violation',
    );

    await target.close();
  });
}

// ── The controlled source board ──────────────────────────────────────────────

class _Built {
  _Built({
    required this.boardId,
    required this.firstButtonId,
    required this.nullVocalizationCoord,
  });
  final int boardId;
  final int firstButtonId;
  final (int, int) nullVocalizationCoord;
}

/// A 3x4 board of 12 buttons, then two slots emptied and one button hidden.
/// One button carries every troublesome character across all three text fields
/// (distinct per field); one button's vocalization is null; several are
/// user_edited. Inserted through raw drift so nothing curls or rewrites the text.
Future<_Built> _buildSource(AppDatabase db) async {
  const rows = 3;
  const cols = 4;
  final boardId = await db
      .into(db.boards)
      .insert(
        BoardsCompanion.insert(
          name: 'exported board',
          gridRows: rows,
          gridCols: cols,
          isRoot: const Value(true),
        ),
      );

  // The troublesome fixture: curly apostrophe, ellipsis, em dash, emoji, and a
  // literal newline break hint. Three DISTINCT strings so a field swap fails.
  const tortureLabel = 'a’…—😀';
  const tortureVoc = 'I can’t talk—wait…\n😀 one';
  const tortureDisplay = 'show this…—😀\ntwo’end';

  final buttonAtCell = <int>[];
  for (var i = 0; i < rows * cols; i++) {
    final isTorture = i == 0;
    final isNullVoc = i == 5;
    final id = await db
        .into(db.buttons)
        .insert(
          ButtonsCompanion.insert(
            boardId: boardId,
            label: isTorture ? tortureLabel : 'L$i',
            vocalization: isNullVoc
                ? const Value<String?>(null)
                : Value<String?>(isTorture ? tortureVoc : 'V$i'),
            displayText: Value<String?>(isTorture ? tortureDisplay : 'D$i'),
            userEdited: Value(i.isEven),
            priority: Value(1000 + i),
          ),
        );
    buttonAtCell.add(id);
  }

  // Slots for every cell, pointing at its button.
  for (var i = 0; i < rows * cols; i++) {
    await db
        .into(db.gridSlots)
        .insert(
          GridSlotsCompanion.insert(
            boardId: boardId,
            rowIndex: i ~/ cols,
            colIndex: i % cols,
            buttonId: Value(buttonAtCell[i]),
          ),
        );
  }

  // Empty two slots by deleting their buttons — FK setNull leaves the slot in
  // place with button_id NULL.
  for (final cell in <int>[7, 10]) {
    await (db.delete(
      db.buttons,
    )..where((b) => b.id.equals(buttonAtCell[cell]))).go();
  }
  // Hide one button that is still placed.
  await (db.update(
    db.buttons,
  )..where((b) => b.id.equals(buttonAtCell[3]))).write(
    const ButtonsCompanion(hidden: Value(true), userEdited: Value(true)),
  );

  return _Built(
    boardId: boardId,
    firstButtonId: buttonAtCell[0],
    nullVocalizationCoord: (5 ~/ cols, 5 % cols),
  );
}

// ── Snapshotting for comparison ──────────────────────────────────────────────

class _Cell {
  const _Cell({
    required this.label,
    required this.vocalization,
    required this.displayText,
    required this.hidden,
    required this.isSystem,
    required this.userEdited,
    required this.priority,
  });
  final String label;
  final String? vocalization;
  final String? displayText;
  final bool hidden;
  final bool isSystem;
  final bool userEdited;
  final int priority;
}

/// Every coordinate of [boardId] mapped to its button's fields, or null for an
/// empty slot.
Future<Map<(int, int), _Cell?>> _snapshot(AppDatabase db, int boardId) async {
  final slots = await (db.select(
    db.gridSlots,
  )..where((s) => s.boardId.equals(boardId))).get();
  final buttons = <int, Button>{
    for (final b in await (db.select(
      db.buttons,
    )..where((b) => b.boardId.equals(boardId))).get())
      b.id: b,
  };
  final out = <(int, int), _Cell?>{};
  for (final slot in slots) {
    final coord = (slot.rowIndex, slot.colIndex);
    final button = slot.buttonId == null ? null : buttons[slot.buttonId];
    out[coord] = button == null
        ? null
        : _Cell(
            label: button.label,
            vocalization: button.vocalization,
            displayText: button.displayText,
            hidden: button.hidden,
            isSystem: button.isSystem,
            userEdited: button.userEdited,
            priority: button.priority,
          );
  }
  return out;
}

class _FullRows {
  const _FullRows({
    required this.board,
    required this.buttons,
    required this.slots,
  });
  final Board board;
  final List<Button> buttons;
  final List<GridSlot> slots;
}

Future<_FullRows> _fullRows(AppDatabase db, int boardId) async {
  final board = await (db.select(
    db.boards,
  )..where((b) => b.id.equals(boardId))).getSingle();
  final buttons =
      await (db.select(
          db.buttons,
        )..where((b) => b.boardId.equals(boardId))).get()
        ..sort((a, b) => a.id.compareTo(b.id));
  final slots =
      await (db.select(
          db.gridSlots,
        )..where((s) => s.boardId.equals(boardId))).get()
        ..sort(
          (a, b) => a.rowIndex == b.rowIndex
              ? a.colIndex.compareTo(b.colIndex)
              : a.rowIndex.compareTo(b.rowIndex),
        );
  return _FullRows(board: board, buttons: buttons, slots: slots);
}

Future<Board> _rootBoard(AppDatabase db) =>
    (db.select(db.boards)..where((b) => b.isRoot.equals(true))).getSingle();

/// Clear the seeded starter board so the source is exactly the controlled
/// fixture. Order respects the foreign keys.
Future<void> _wipe(AppDatabase db) async {
  await db.delete(db.gridSlots).go();
  await db.delete(db.buttons).go();
  await db.delete(db.images).go();
  await db.delete(db.sounds).go();
  await db.delete(db.boards).go();
}
