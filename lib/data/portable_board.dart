/// The on-disk export format — hand-written DTOs and their validation.
///
/// The format mirrors Open Board Format's field names (the schema already
/// borrows its semantics) but does NOT claim OBF compatibility. Not `freezed`,
/// not codegen: validation is the point of this file and it must be readable
/// cold by a stranger deciding whether a crafted archive is safe to write.
///
/// Every rejection here throws a [FormatException] with a FIXED, phrase-free
/// message. The offending file is a user's board full of intimate sentences, and
/// `FormatException.toString()` embeds its message — so a message that quoted the
/// bad value would be the leak the crash log's redaction exists to prevent. Say
/// what rule broke, never with what text.
library;

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// The one format version this build writes and the highest it will read. A file
/// declaring a higher version is rejected whole rather than imported as a subset
/// that silently drops the fields this build does not know.
const int kPortableFormatVersion = 1;

/// The fixed rejection message for an out-of-range label. Phrase-free on
/// purpose: it names the rule, never the offending value.
const String _labelRejection = 'a button label is empty or over 16 characters';

/// A parsed, VALIDATED export archive, ready to write in one transaction.
///
/// Construction goes through [PortableArchive.parse], which validates everything
/// before this object exists — so holding a [PortableArchive] is proof the file
/// passed every rejection rule, and the importer can write without re-checking.
@immutable
final class PortableArchive {
  const PortableArchive._({
    required this.formatVersion,
    required this.boards,
    required this.mediaBytes,
    required this.rootFileId,
  });

  /// Parse and fully validate [archive]. Throws [FormatException] on any
  /// rejection, having written nothing (this builds no DB state).
  factory PortableArchive.parse(Archive archive) {
    // Index entries by their in-zip name, rejecting zip-slip up front: an
    // absolute path or one containing `..` is a crafted archive trying to write
    // outside the app container, and it is refused before a single byte is read.
    final entries = <String, Uint8List>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name;
      if (p.isAbsolute(name) || _hasDotDot(name)) {
        throw const FormatException(
          'archive entry path is absolute or escapes the archive root',
        );
      }
      entries[name] = Uint8List.fromList(file.content as List<int>);
    }

    final manifestBytes = entries['manifest.json'];
    if (manifestBytes == null) {
      throw const FormatException('manifest.json is missing');
    }
    final manifest = _decodeObject(manifestBytes, 'manifest.json');

    final formatVersion = manifest['format_version'];
    if (formatVersion is! int || formatVersion > kPortableFormatVersion) {
      // Absent, non-int, or newer than this build understands. A newer file that
      // parsed "well enough" would import a subset and silently drop fields.
      throw const FormatException(
        'format_version is absent, not an integer, or newer than this build',
      );
    }

    if (manifest['root'] is! String) {
      throw const FormatException('manifest.root is absent or not a string');
    }

    // Each board JSON the manifest can reach. The seed is one root board; a
    // future one-level sub-board set travels as more entries under boards/.
    final boards = <PortableBoard>[];
    final boardEntries =
        entries.keys
            .where((k) => k.startsWith('boards/') && k.endsWith('.json'))
            .toList()
          ..sort();
    for (final key in boardEntries) {
      boards.add(PortableBoard._fromJson(_decodeObject(entries[key]!, key)));
    }
    if (boards.isEmpty) {
      throw const FormatException('the archive contains no boards');
    }

    final rootFileId = _singleRootFileId(boards);

    final media = <String, Uint8List>{};
    for (final board in boards) {
      board._validate();
      for (final image in board.images) {
        media[image.path] = _requireMediaBytes(entries, image.path);
      }
      for (final sound in board.sounds) {
        media[sound.path] = _requireMediaBytes(entries, sound.path);
      }
    }

    _validateLoadChain(boards);

    return PortableArchive._(
      formatVersion: formatVersion,
      boards: boards,
      mediaBytes: media,
      rootFileId: rootFileId,
    );
  }

  final int formatVersion;

  /// Boards in file order. Exactly one has `isRoot == true` after parsing.
  final List<PortableBoard> boards;

  /// In-zip media path -> its bytes. The importer writes these through the media
  /// store; parsing has already proven every referenced path is present here.
  final Map<String, Uint8List> mediaBytes;

  /// The file-local id of the root board, from `manifest.root`.
  final int rootFileId;

  /// load_board is one level only, across the whole archive: a board that is
  /// itself the target of a `load_board_id` may not contain a button that loads
  /// another board. This catches A→B→C (two levels) and any multi-board cycle;
  /// a board loading itself is caught in [PortableBoard._validate].
  static void _validateLoadChain(List<PortableBoard> boards) {
    final loaded = <int>{};
    for (final board in boards) {
      for (final button in board.buttons) {
        if (button.loadBoardId != null) loaded.add(button.loadBoardId!);
      }
    }
    for (final board in boards) {
      if (!loaded.contains(board.fileId)) continue;
      final chainsFurther = board.buttons.any((b) => b.loadBoardId != null);
      if (chainsFurther) {
        throw const FormatException('load_board_id chains more than one level');
      }
    }
  }

  static int _singleRootFileId(List<PortableBoard> boards) {
    // The importer marks exactly one board is_root; more than one, or none, is a
    // broken file with no single board to open onto.
    final byRoot = boards.where((b) => b.isRoot).toList();
    if (byRoot.length != 1) {
      throw const FormatException(
        'the archive must contain exactly one root board',
      );
    }
    return byRoot.single.fileId;
  }

  static Uint8List _requireMediaBytes(
    Map<String, Uint8List> entries,
    String path,
  ) {
    final bytes = entries[path];
    if (bytes == null) {
      // A media entry whose bytes are absent renders blank forever, with no
      // error and no telemetry. Reject the file rather than import the void.
      throw const FormatException('a referenced media file is missing bytes');
    }
    return bytes;
  }
}

/// One board: its row fields, its buttons, its grid order, and its media.
@immutable
final class PortableBoard {
  const PortableBoard({
    required this.fileId,
    required this.name,
    required this.locale,
    required this.gridRows,
    required this.gridCols,
    required this.isRoot,
    required this.buttons,
    required this.order,
    required this.images,
    required this.sounds,
    this.createdAt,
    this.updatedAt,
  });

  factory PortableBoard._fromJson(Map<String, Object?> json) {
    final grid = json['grid'];
    if (grid is! Map<String, Object?>) {
      throw const FormatException('a board is missing its grid block');
    }
    return PortableBoard(
      fileId: _int(json, 'id'),
      name: _string(json, 'name'),
      locale: _stringOr(json, 'locale', 'en'),
      gridRows: _int(grid, 'rows'),
      gridCols: _int(grid, 'columns'),
      isRoot: _boolOr(json, 'is_root', false),
      buttons: _list(
        json,
        'buttons',
      ).map(PortableButton._fromJson).toList(growable: false),
      order: _orderFrom(grid['order']),
      images: _listOrEmpty(
        json,
        'images',
      ).map(PortableImage._fromJson).toList(growable: false),
      sounds: _listOrEmpty(
        json,
        'sounds',
      ).map(PortableSound._fromJson).toList(growable: false),
      createdAt: _stringOrNull(json, 'created_at'),
      updatedAt: _stringOrNull(json, 'updated_at'),
    );
  }

  /// The file-local board id. Never reused as a DB primary key on import.
  final int fileId;
  final String name;
  final String locale;
  final int gridRows;
  final int gridCols;
  final bool isRoot;
  final List<PortableButton> buttons;

  /// The grid as `rows` arrays of `columns` file-local button ids, `null` for an
  /// empty cell. Exactly `rows x columns` entries, nulls IN PLACE — this is the
  /// on-disk form of `PRIMARY KEY (board_id, row_index, col_index)`, and a file
  /// that drops nulls reflows the board on the way back in.
  final List<List<int?>> order;
  final List<PortableImage> images;
  final List<PortableSound> sounds;
  final String? createdAt;
  final String? updatedAt;

  /// Every rejection rule that is decidable from a single board.
  void _validate() {
    // The coordinate set must be exactly right; there is no safe repair of a
    // grid whose shape disagrees with its cells.
    if (order.length != gridRows) {
      throw const FormatException('grid order row count != grid_rows');
    }
    for (final row in order) {
      if (row.length != gridCols) {
        throw const FormatException('a grid order row length != grid_columns');
      }
    }

    final byId = <int, PortableButton>{};
    var systemCount = 0;
    for (final button in buttons) {
      // Refuse at the cap; never truncate. An ellipsis on an AAC utterance is a
      // different utterance, and the editor refuses at 16 for the same reason.
      if (button.label.isEmpty || button.label.length > 16) {
        throw const FormatException(_labelRejection);
      }
      if (button.isSystem) systemCount++;
      byId[button.fileId] = button;
    }
    if (systemCount > 1) {
      // is_system is undeletable. A file setting it on every button hands the
      // user a board they cannot edit.
      throw const FormatException(
        'a board declares more than one is_system button',
      );
    }

    // Every id named in the grid must resolve to a button in this board.
    for (final row in order) {
      for (final id in row) {
        if (id != null && !byId.containsKey(id)) {
          throw const FormatException(
            'grid order names a button id with no match',
          );
        }
      }
    }

    // A button that loads its own board is the only cycle a single board can
    // express; cross-board chains are checked in [PortableArchive].
    for (final button in buttons) {
      if (button.loadBoardId == fileId) {
        throw const FormatException('a button loads its own board (a cycle)');
      }
    }
  }

  static List<List<int?>> _orderFrom(Object? raw) {
    if (raw is! List) {
      throw const FormatException('grid.order is absent or not an array');
    }
    return raw.map((row) {
      if (row is! List) {
        throw const FormatException('a grid.order row is not an array');
      }
      return row.map((cell) {
        if (cell == null) return null;
        if (cell is int) return cell;
        throw const FormatException(
          'a grid.order cell is neither an int nor null',
        );
      }).toList(growable: false);
    }).toList(growable: false);
  }
}

/// One button. All three text fields are separate keys, never collapsed;
/// `vocalization == null` means *falls back to label* and that null is preserved.
@immutable
final class PortableButton {
  const PortableButton({
    required this.fileId,
    required this.label,
    required this.vocalization,
    required this.displayText,
    required this.hidden,
    required this.isSystem,
    required this.userEdited,
    required this.priority,
    this.backgroundColor,
    this.borderColor,
    this.imageId,
    this.soundId,
    this.loadBoardId,
    this.createdAt,
    this.updatedAt,
  });

  factory PortableButton._fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('a button entry is not an object');
    }
    final label = json['label'];
    if (label is! String) {
      // Absent or null label. The tile has no handle; there is nothing to show.
      throw const FormatException('a button has an absent or non-string label');
    }
    return PortableButton(
      fileId: _int(json, 'id'),
      label: label,
      vocalization: _stringOrNull(json, 'vocalization'),
      displayText: _stringOrNull(json, 'display_text'),
      hidden: _boolOr(json, 'hidden', false),
      isSystem: _boolOr(json, 'is_system', false),
      userEdited: _boolOr(json, 'user_edited', false),
      priority: _intOr(json, 'priority', 1000),
      backgroundColor: _stringOrNull(json, 'background_color'),
      borderColor: _stringOrNull(json, 'border_color'),
      imageId: _intOrNull(json, 'image_id'),
      soundId: _intOrNull(json, 'sound_id'),
      loadBoardId: _intOrNull(json, 'load_board_id'),
      createdAt: _stringOrNull(json, 'created_at'),
      updatedAt: _stringOrNull(json, 'updated_at'),
    );
  }

  final int fileId;
  final String label;
  final String? vocalization;
  final String? displayText;
  final bool hidden;
  final bool isSystem;
  final bool userEdited;
  final int priority;
  final String? backgroundColor;
  final String? borderColor;
  final int? imageId;
  final int? soundId;
  final int? loadBoardId;
  final String? createdAt;
  final String? updatedAt;
}

/// One image record. Attribution travels WITH the board — a symbol set's licence
/// obligation that lived only in a README would be unmet on the other phone.
@immutable
final class PortableImage {
  const PortableImage({
    required this.fileId,
    required this.path,
    required this.contentType,
    required this.width,
    required this.height,
    this.license,
    this.attribution,
  });

  factory PortableImage._fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('an image entry is not an object');
    }
    return PortableImage(
      fileId: _int(json, 'id'),
      path: _string(json, 'path'),
      contentType: _stringOr(json, 'content_type', 'image/jpeg'),
      width: _intOr(json, 'width', 0),
      height: _intOr(json, 'height', 0),
      license: _stringOrNull(json, 'license'),
      attribution: _stringOrNull(json, 'attribution'),
    );
  }

  final int fileId;

  /// The in-zip path, e.g. `images/3.jpg`. Validated non-absolute / no `..`.
  final String path;
  final String contentType;
  final int width;
  final int height;
  final String? license;
  final String? attribution;
}

/// One sound record.
@immutable
final class PortableSound {
  const PortableSound({
    required this.fileId,
    required this.path,
    required this.contentType,
    required this.durationMs,
  });

  factory PortableSound._fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('a sound entry is not an object');
    }
    return PortableSound(
      fileId: _int(json, 'id'),
      path: _string(json, 'path'),
      contentType: _stringOr(json, 'content_type', 'audio/mpeg'),
      durationMs: _intOr(json, 'duration_ms', 0),
    );
  }

  final int fileId;
  final String path;
  final String contentType;
  final int durationMs;
}

// ── Parsing primitives ───────────────────────────────────────────────────────
// Every one throws a FIXED, phrase-free FormatException on a shape mismatch, so
// no error message can carry a user's sentence out through the crash log.

bool _hasDotDot(String path) =>
    p.split(path).contains('..') || path.contains('..');

Map<String, Object?> _decodeObject(Uint8List bytes, String what) {
  final Object? decoded;
  try {
    decoded = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    // jsonDecode embeds the offending source (the user's phrases) in its
    // message; re-throw a fixed one so nothing leaks through a caught toString.
    throw FormatException('$what is not valid JSON');
  }
  if (decoded is! Map<String, Object?>) {
    throw FormatException('$what is not a JSON object');
  }
  return decoded;
}

int _int(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('field "$key" is absent or not an int');
  }
  return value;
}

int _intOr(Map<String, Object?> json, String key, int fallback) {
  final value = json[key];
  return value is int ? value : fallback;
}

int? _intOrNull(Map<String, Object?> json, String key) {
  final value = json[key];
  return value is int ? value : null;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('field "$key" is absent or not a string');
  }
  return value;
}

String _stringOr(Map<String, Object?> json, String key, String fallback) {
  final value = json[key];
  return value is String ? value : fallback;
}

String? _stringOrNull(Map<String, Object?> json, String key) {
  final value = json[key];
  return value is String ? value : null;
}

bool _boolOr(Map<String, Object?> json, String key, bool fallback) {
  final value = json[key];
  return value is bool ? value : fallback;
}

List<Object?> _list(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('field "$key" is absent or not an array');
  }
  return value;
}

List<Object?> _listOrEmpty(Map<String, Object?> json, String key) {
  final value = json[key];
  return value is List ? value : const <Object?>[];
}
