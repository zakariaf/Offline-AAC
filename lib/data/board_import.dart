import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/media_store.dart';
import 'package:offline_aac/data/portable_board.dart';
import 'package:path/path.dart' as p;

/// Imports a board file as a NEW board, additively, never overwriting.
///
/// The rule that shapes everything: import CREATES a board and never writes into
/// an existing one. A board is months of hand-curated phrases, unmergeable, and
/// there is no merge better than leaving someone's phrase alone. So there is no
/// conflict picker, no per-tile diff, no "keep mine / keep theirs" — those are
/// all ways of asking a user to authorise damage. The only thing that changes
/// about the board they already had is which one `is_root` points at, and
/// switching back in settings restores it exactly.
///
/// Parse and validate the WHOLE file before any write; write in one transaction;
/// verify foreign keys before the transaction commits, so a violation rolls the
/// whole thing back rather than leaving half a board and a live root flag.
final class BoardImport {
  BoardImport(this._db, this._media);

  final AppDatabase _db;
  final MediaStore _media;

  /// Read and import [zipFile]. Throws [FileSystemException] if it cannot be
  /// read; delegates the rest to [importBytes].
  Future<void> importFile(File zipFile) async =>
      importBytes(await zipFile.readAsBytes());

  /// Decode, validate, and import [bytes]. Throws — for the call site to map to
  /// inline copy — on:
  ///  - [ArchiveException] : not a zip / corrupt zip,
  ///  - [FormatException]  : a rejection rule (see [PortableArchive.parse]),
  ///  - `SqliteException` / [FileSystemException] : a write that failed.
  /// On any of these it has written nothing, or rolled back what it began.
  Future<void> importBytes(Uint8List bytes) async {
    // Validate the entire archive up front. This builds no DB state, so a
    // rejection here leaves the phone exactly as it was.
    final archive = PortableArchive.parse(ZipDecoder().decodeBytes(bytes));
    await _write(archive);
  }

  Future<void> _write(PortableArchive archive) async {
    await _db.transaction(() async {
      final boardIdMap = <int, int>{};

      // 1. Boards first — buttons, media and slots all reference a board, and
      //    load_board_id may point at another imported board. All inserted with
      //    is_root = false; the real root is set at the end.
      for (final board in archive.boards) {
        boardIdMap[board.fileId] = await _db
            .into(_db.boards)
            .insert(
              BoardsCompanion.insert(
                name: board.name,
                locale: Value(board.locale),
                gridRows: board.gridRows,
                gridCols: board.gridCols,
                isRoot: const Value(false),
                createdAt: _dateValue(board.createdAt),
                updatedAt: _dateValue(board.updatedAt),
              ),
            );
      }

      // 2. Per board: media, then buttons (which reference media), then slots
      //    (which reference buttons). The id maps are per board because the
      //    file-local ids are only unique within a board.
      for (final board in archive.boards) {
        final newBoardId = boardIdMap[board.fileId]!;
        final imageIdMap = await _insertImages(board, archive);
        final soundIdMap = await _insertSounds(board, archive);
        final buttonIdMap = await _insertButtons(
          board,
          newBoardId,
          boardIdMap,
          imageIdMap,
          soundIdMap,
        );
        await _insertSlots(board, newBoardId, buttonIdMap);
      }

      // 3. Reroot: clear the previous root and set the imported one. This is the
      //    ONLY thing that changes about the board the user already had, and it
      //    changes nothing inside it.
      await (_db.update(
        _db.boards,
      )..where((b) => b.isRoot.equals(true))).write(
        const BoardsCompanion(isRoot: Value(false)),
      );
      await (_db.update(_db.boards)
            ..where((b) => b.id.equals(boardIdMap[archive.rootFileId]!)))
          .write(const BoardsCompanion(isRoot: Value(true)));

      // 4. Foreign keys must hold. Run the check INSIDE the transaction so a
      //    dangling reference rolls the import back rather than committing a
      //    board that renders blank or throws later, on someone else's phone.
      final violations = await _db
          .customSelect('PRAGMA foreign_key_check')
          .get();
      if (violations.isNotEmpty) {
        throw StateError(
          'import produced ${violations.length} foreign-key violations',
        );
      }
    });
  }

  Future<Map<int, int>> _insertImages(
    PortableBoard board,
    PortableArchive archive,
  ) async {
    final map = <int, int>{};
    for (final image in board.images) {
      // Insert first for the autoincrement id, then write the bytes under a name
      // derived from that NEW id, then store the RELATIVE path. Absolute paths
      // die on restore when the container id changes; the DB row survives and the
      // tile renders blank forever.
      final newId = await _db
          .into(_db.images)
          .insert(
            ImagesCompanion.insert(
              path: '',
              contentType: image.contentType,
              width: image.width,
              height: image.height,
              license: Value(image.license),
              attribution: Value(image.attribution),
            ),
          );
      final relative = await _media.write(
        _media.imageRelativePath(newId, _extensionOf(image.path)),
        archive.mediaBytes[image.path]!,
      );
      await (_db.update(_db.images)..where((i) => i.id.equals(newId))).write(
        ImagesCompanion(path: Value(relative)),
      );
      map[image.fileId] = newId;
    }
    return map;
  }

  Future<Map<int, int>> _insertSounds(
    PortableBoard board,
    PortableArchive archive,
  ) async {
    final map = <int, int>{};
    for (final sound in board.sounds) {
      final newId = await _db
          .into(_db.sounds)
          .insert(
            SoundsCompanion.insert(
              path: '',
              contentType: sound.contentType,
              durationMs: sound.durationMs,
            ),
          );
      final relative = await _media.write(
        _media.soundRelativePath(newId, _extensionOf(sound.path)),
        archive.mediaBytes[sound.path]!,
      );
      await (_db.update(_db.sounds)..where((s) => s.id.equals(newId))).write(
        SoundsCompanion(path: Value(relative)),
      );
      map[sound.fileId] = newId;
    }
    return map;
  }

  Future<Map<int, int>> _insertButtons(
    PortableBoard board,
    int newBoardId,
    Map<int, int> boardIdMap,
    Map<int, int> imageIdMap,
    Map<int, int> soundIdMap,
  ) async {
    final map = <int, int>{};
    for (final b in board.buttons) {
      // FRESHLY generated id, always. Reusing the file's id either collides with
      // an existing row or lines the slots up with the wrong buttons against a
      // fresh sequence. Media and load-board references are remapped through the
      // same tables.
      final newId = await _db
          .into(_db.buttons)
          .insert(
            ButtonsCompanion.insert(
              boardId: newBoardId,
              label: b.label,
              vocalization: Value(b.vocalization),
              displayText: Value(b.displayText),
              hidden: Value(b.hidden),
              isSystem: Value(b.isSystem),
              userEdited: Value(b.userEdited),
              priority: Value(b.priority),
              backgroundColor: Value(b.backgroundColor),
              borderColor: Value(b.borderColor),
              imageId: Value(_remap(imageIdMap, b.imageId)),
              soundId: Value(_remap(soundIdMap, b.soundId)),
              loadBoardId: Value(_remap(boardIdMap, b.loadBoardId)),
              createdAt: _dateValue(b.createdAt),
              updatedAt: _dateValue(b.updatedAt),
            ),
          );
      map[b.fileId] = newId;
    }
    return map;
  }

  Future<void> _insertSlots(
    PortableBoard board,
    int newBoardId,
    Map<int, int> buttonIdMap,
  ) async {
    // Exactly grid_rows x grid_cols slot rows, allocated by coordinate. A null in
    // `order` is a real empty cell — a slot row with button_id NULL, in place,
    // never omitted and never backfilled by a neighbour.
    for (var row = 0; row < board.gridRows; row++) {
      for (var col = 0; col < board.gridCols; col++) {
        final fileButtonId = board.order[row][col];
        await _db
            .into(_db.gridSlots)
            .insert(
              GridSlotsCompanion.insert(
                boardId: newBoardId,
                rowIndex: row,
                colIndex: col,
                buttonId: Value(_remap(buttonIdMap, fileButtonId)),
              ),
            );
      }
    }
  }

  /// Remap a file-local id through [map]; null stays null. A non-null id absent
  /// from the map would be a validation miss, so it surfaces as a StateError
  /// (which rolls the transaction back) rather than a silent null.
  int? _remap(Map<int, int> map, int? fileId) {
    if (fileId == null) return null;
    final mapped = map[fileId];
    if (mapped == null) {
      throw StateError('an id survived validation with no remapping');
    }
    return mapped;
  }

  Value<DateTime> _dateValue(String? iso) {
    if (iso == null) return const Value.absent();
    final parsed = DateTime.tryParse(iso);
    return parsed == null ? const Value.absent() : Value(parsed);
  }

  String _extensionOf(String path) {
    final ext = p.extension(path);
    return ext.startsWith('.') ? ext.substring(1) : ext;
  }
}
