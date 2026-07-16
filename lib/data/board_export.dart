import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/media_store.dart';
import 'package:path/path.dart' as p;

/// Writes the whole board out as a zip and hands it to the OS share sheet.
///
/// The app NEVER sends the file. It stages a zip in the cache directory, hands
/// it to whoever the user picks in the share sheet, and deletes the staging
/// copy. Nothing is written under documents — that is where the DB lives, and a
/// plaintext copy of every phrase left there would quietly undo the backup
/// promise this feature exists to keep.
///
/// Concrete, not an interface: there is one environment. The share step is a
/// function seam so a test can prove the staging file is gone after it returns
/// without a real share sheet, and so the platform plugin stays out of this
/// file and off the data layer.
final class BoardExport {
  BoardExport(this._db, this._media);

  final AppDatabase _db;
  final MediaStore _media;

  /// Build the export in [stagingDir] (the cache/temp directory), hand it to
  /// [share], then delete it — even if [share] throws. [now] stamps the manifest
  /// and the filename; [reedVersion] records which build wrote the file.
  ///
  /// Returns the filename handed to the share sheet.
  Future<String> run({
    required Directory stagingDir,
    required DateTime now,
    required String reedVersion,
    required Future<void> Function(File file) share,
  }) async {
    final archive = await _buildArchive(now: now, reedVersion: reedVersion);
    final bytes = ZipEncoder().encode(archive);
    if (bytes == null) {
      throw const FileSystemException('the export produced no bytes');
    }

    final filename = 'reed-board-${_isoDate(now)}.zip';
    final file = File(p.join(stagingDir.path, filename));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    try {
      await share(file);
    } finally {
      // The staging copy is plaintext and holds every phrase. It exists only for
      // the duration of the share hand-off; delete it the moment that returns,
      // success or not.
      if (file.existsSync()) file.deleteSync();
    }
    return filename;
  }

  Future<Archive> _buildArchive({
    required DateTime now,
    required String reedVersion,
  }) async {
    final boards = await _db.select(_db.boards).get();
    if (boards.isEmpty) {
      // Nothing to export is not a crash; the caller maps it to copy. A board
      // always exists after seeding, so this is a corrupt-DB guard, not a path.
      throw const FileSystemException('no board to export');
    }
    final buttons = await _db.select(_db.buttons).get();
    final slots = await _db.select(_db.gridSlots).get();
    final images = await _db.select(_db.images).get();
    final sounds = await _db.select(_db.sounds).get();

    final root = boards.firstWhere(
      (b) => b.isRoot,
      orElse: () => boards.first,
    );

    final archive = Archive();

    for (final board in boards) {
      final boardJson = _boardJson(
        board: board,
        buttons: buttons.where((b) => b.boardId == board.id).toList(),
        slots: slots.where((s) => s.boardId == board.id).toList(),
        images: images,
        sounds: sounds,
      );
      _addTextFile(archive, 'boards/${board.id}.json', _pretty(boardJson));
    }

    // Media bytes, copied out of documents through the ONE helper that owns that
    // base. Never re-encoded — media_store already downscales at IMPORT time, so
    // the stored bytes are the shippable ones. Only images referenced by a button
    // travel; an orphaned image row carries no phrase and no obligation.
    final usedImageIds = buttons.map((b) => b.imageId).whereType<int>().toSet();
    for (final image in images.where((i) => usedImageIds.contains(i.id))) {
      _addBinaryFile(
        archive,
        _inZipMediaPath('images', image.id, image.path),
        await _media.resolve(image.path).readAsBytes(),
      );
    }
    final usedSoundIds = buttons.map((b) => b.soundId).whereType<int>().toSet();
    for (final sound in sounds.where((s) => usedSoundIds.contains(s.id))) {
      _addBinaryFile(
        archive,
        _inZipMediaPath('sounds', sound.id, sound.path),
        await _media.resolve(sound.path).readAsBytes(),
      );
    }

    _addTextFile(
      archive,
      'manifest.json',
      _pretty(<String, Object?>{
        'format_version': 1,
        'reed_version': reedVersion,
        'exported_at': now.toUtc().toIso8601String(),
        'root': 'boards/${root.id}.json',
      }),
    );

    return archive;
  }

  Map<String, Object?> _boardJson({
    required Board board,
    required List<Button> buttons,
    required List<GridSlot> slots,
    required List<MediaImage> images,
    required List<MediaSound> sounds,
  }) {
    final usedImageIds = buttons.map((b) => b.imageId).whereType<int>().toSet();
    final usedSoundIds = buttons.map((b) => b.soundId).whereType<int>().toSet();

    return <String, Object?>{
      'id': board.id,
      'name': board.name,
      'locale': board.locale,
      'grid_rows': board.gridRows,
      'grid_cols': board.gridCols,
      'is_root': board.isRoot,
      'created_at': board.createdAt.toUtc().toIso8601String(),
      'updated_at': board.updatedAt.toUtc().toIso8601String(),
      'buttons': <Map<String, Object?>>[
        for (final b in buttons)
          <String, Object?>{
            'id': b.id,
            // Three separate keys, never collapsed. A null vocalization means
            // "fall back to label" and is preserved as null — resolving it here
            // would ship a different utterance than the user wrote.
            'label': b.label,
            'vocalization': b.vocalization,
            'display_text': b.displayText,
            'hidden': b.hidden,
            'is_system': b.isSystem,
            'user_edited': b.userEdited,
            'priority': b.priority,
            'background_color': b.backgroundColor,
            'border_color': b.borderColor,
            'image_id': b.imageId,
            'sound_id': b.soundId,
            'load_board_id': b.loadBoardId,
            'created_at': b.createdAt.toUtc().toIso8601String(),
            'updated_at': b.updatedAt.toUtc().toIso8601String(),
          },
      ],
      // rows x columns entries with nulls IN PLACE. Building this from the
      // returned slot rows only — dropping the empties — would reflow the board.
      'grid': <String, Object?>{
        'rows': board.gridRows,
        'columns': board.gridCols,
        'order': _orderMatrix(board, slots),
      },
      'images': <Map<String, Object?>>[
        for (final image in images.where((i) => usedImageIds.contains(i.id)))
          <String, Object?>{
            'id': image.id,
            'path': _inZipMediaPath('images', image.id, image.path),
            'content_type': image.contentType,
            'width': image.width,
            'height': image.height,
            'license': image.license,
            'attribution': image.attribution,
          },
      ],
      'sounds': <Map<String, Object?>>[
        for (final sound in sounds.where((s) => usedSoundIds.contains(s.id)))
          <String, Object?>{
            'id': sound.id,
            'path': _inZipMediaPath('sounds', sound.id, sound.path),
            'content_type': sound.contentType,
            'duration_ms': sound.durationMs,
          },
      ],
    };
  }

  /// The `rows x columns` matrix of button ids and nulls, allocated full and
  /// PLACED by coordinate — never appended from returned rows.
  List<List<int?>> _orderMatrix(Board board, List<GridSlot> slots) {
    final matrix = List<List<int?>>.generate(
      board.gridRows,
      (_) => List<int?>.filled(board.gridCols, null),
    );
    for (final slot in slots) {
      if (slot.rowIndex < 0 ||
          slot.rowIndex >= board.gridRows ||
          slot.colIndex < 0 ||
          slot.colIndex >= board.gridCols) {
        continue;
      }
      matrix[slot.rowIndex][slot.colIndex] = slot.buttonId;
    }
    return matrix;
  }

  /// The in-zip path for a media file: `images/<id><ext>`, extension taken from
  /// the stored path so a `.jpg` stays a `.jpg` across the round trip.
  String _inZipMediaPath(String kind, int id, String storedPath) =>
      p.posix.join(kind, '$id${p.extension(storedPath)}');

  String _isoDate(DateTime now) {
    final d = now.toUtc();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  String _pretty(Object? json) =>
      const JsonEncoder.withIndent('  ').convert(json);

  void _addTextFile(Archive archive, String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  void _addBinaryFile(Archive archive, String name, List<int> bytes) {
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }
}
