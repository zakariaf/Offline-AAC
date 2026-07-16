import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_import.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/media_store.dart';
import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:path/path.dart' as p;

/// A crafted or corrupt board file is rejected WHOLE, before any write — the DB
/// is byte-identical before and after the attempt — and no phrase from the file
/// ever reaches the crash log. One test per row of the rejection table, plus the
/// redaction guarantee for both a parse failure and a SqliteException.
void main() {
  late Directory tmp;
  late MediaStore media;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('reed_reject');
    media = MediaStore(Directory(p.join(tmp.path, 'docs'))..createSync());
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  /// Encode a board archive. [manifest] / [board] default to a valid 1x2 board;
  /// [rawBoard] overrides the board JSON with exact (possibly invalid) text;
  /// [extra] adds arbitrary entries (for the zip-slip and media-absent rows).
  Uint8List encode({
    Map<String, Object?>? manifest,
    Map<String, Object?>? board,
    String? rawBoard,
    List<(String, List<int>)> extra = const <(String, List<int>)>[],
  }) {
    final archive = Archive();
    void addText(String name, String content) {
      final bytes = utf8.encode(content);
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    addText('manifest.json', jsonEncode(manifest ?? _validManifest()));
    addText('boards/1.json', rawBoard ?? jsonEncode(board ?? _validBoard()));
    for (final (name, bytes) in extra) {
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  Future<(int, int, int)> counts(AppDatabase db) async => (
    (await db.select(db.boards).get()).length,
    (await db.select(db.buttons).get()).length,
    (await db.select(db.gridSlots).get()).length,
  );

  /// Assert [bytes] is rejected and the DB is unchanged.
  Future<void> expectRejected(Uint8List bytes) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final before = await counts(db);
    await expectLater(
      BoardImport(db, media).importBytes(bytes),
      throwsA(anyOf(isA<FormatException>(), isA<ArchiveException>())),
    );
    expect(
      await counts(db),
      before,
      reason: 'a rejected file must write nothing — boards, buttons and slots '
          'identical before and after',
    );
    await db.close();
  }

  test('a valid board imports (control) so the rejections mean something', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final before = await counts(db);
    await BoardImport(db, media).importBytes(encode());
    final after = await counts(db);
    expect(after.$1, greaterThan(before.$1), reason: 'a board was added');
    await db.close();
  });

  group('rejection table — one per row', () {
    test('format_version absent, non-int, or > 1', () async {
      await expectRejected(encode(manifest: _manifest(formatVersion: 2)));
      await expectRejected(encode(manifest: _manifest(formatVersion: 'one')));
      await expectRejected(encode(manifest: _manifest(omitFormatVersion: true)));
    });

    test('order length != rows, or a row length != columns', () async {
      final board = _validBoard()
        ..['grid'] = <String, Object?>{
          'rows': 1,
          'columns': 2,
          'order': <List<int?>>[
            <int?>[10], // one column, not two
          ],
        };
      await expectRejected(encode(board: board));
    });

    test('an id in order with no matching button', () async {
      final board = _validBoard()
        ..['grid'] = <String, Object?>{
          'rows': 1,
          'columns': 2,
          'order': <List<int?>>[
            <int?>[10, 99], // 99 is not a button in this board
          ],
        };
      await expectRejected(encode(board: board));
    });

    test('a label longer than 16, or absent', () async {
      final tooLong = _validBoard();
      (tooLong['buttons']! as List<Object?>)[0] =
          _button(id: 10, label: 'seventeen chars!!'); // 17 chars
      await expectRejected(encode(board: tooLong));

      final absent = _validBoard();
      final button = Map<String, Object?>.from(
        (absent['buttons']! as List<Object?>)[0]! as Map<String, Object?>,
      )..remove('label');
      (absent['buttons']! as List<Object?>)[0] = button;
      await expectRejected(encode(board: absent));
    });

    test('more than one is_system button in a board', () async {
      final board = _validBoard()
        ..['buttons'] = <Map<String, Object?>>[
          _button(id: 10, label: 'Yes', isSystem: true),
          _button(id: 11, label: 'No', isSystem: true),
        ];
      await expectRejected(encode(board: board));
    });

    test('load_board_id forming a cycle (self-load)', () async {
      final board = _validBoard()
        ..['buttons'] = <Map<String, Object?>>[
          _button(id: 10, label: 'Yes', loadBoardId: 1), // this board's own id
          _button(id: 11, label: 'No'),
        ];
      await expectRejected(encode(board: board));
    });

    test('a zip entry path that is absolute or contains ..', () async {
      final outside = File(p.join(tmp.parent.path, 'reed_evil.txt'));
      addTearDown(() {
        if (outside.existsSync()) outside.deleteSync();
      });
      await expectRejected(
        encode(extra: <(String, List<int>)>[
          ('../../reed_evil.txt', utf8.encode('pwned')),
        ]),
      );
      expect(
        outside.existsSync(),
        isFalse,
        reason: 'a zip-slip entry must never write outside the app container',
      );
    });

    test('a media entry whose bytes are absent from the zip', () async {
      final board = _validBoard()
        ..['images'] = <Map<String, Object?>>[
          <String, Object?>{
            'id': 1,
            'path': 'images/1.jpg', // no such entry in the archive
            'content_type': 'image/jpeg',
            'width': 10,
            'height': 10,
          },
        ];
      (board['buttons']! as List<Object?>)[0] =
          _button(id: 10, label: 'Yes', imageId: 1);
      await expectRejected(encode(board: board));
    });

    test('a file that is not a zip at all', () async {
      await expectRejected(Uint8List.fromList(utf8.encode('this is not a zip')));
    });
  });

  group("redaction — the file's phrases never reach the crash log", () {
    // The exact sentence a user says when they cannot speak. Straight apostrophe,
    // matching the acceptance criterion verbatim.
    const phrase = "I need to leave, I'm not able to talk right now";

    test('a parse failure: the exception is phrase-free and the log stays clean',
        () async {
      // Invalid JSON that CONTAINS the phrase — exactly what jsonDecode would
      // echo back in its own message.
      final bytes = encode(rawBoard: '{ "name": "$phrase", broken');
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      // board_import throws a FIXED FormatException — jsonDecode's phrase-bearing
      // message is replaced inside portable_board, so no call site can leak it.
      await expectLater(
        BoardImport(db, media).importBytes(bytes),
        throwsA(
          predicate<Object>(
            (e) => e is FormatException && !e.toString().contains(phrase),
          ),
        ),
      );

      // And logging the failure the way the controller does — a FIXED message —
      // leaves nothing of the phrase on disk.
      final logFile = File(p.join(tmp.path, 'log.txt'));
      final log = CrashLog.atFile(logFile);
      try {
        await BoardImport(db, media).importBytes(bytes);
      } on FormatException catch (_, s) {
        log.record('import rejected: the file failed validation', s);
      }
      expect(logFile.readAsStringSync().contains(phrase), isFalse);
      await db.close();
    });

    test('a forced SqliteException carrying the phrase never reaches the log',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final logFile = File(p.join(tmp.path, 'log.txt'));
      final log = CrashLog.atFile(logFile);

      // Force a real SqliteException whose statement text embeds the phrase — a
      // FK violation on an insert that names it. This is the shape drift raises
      // when a write fails mid-import.
      try {
        await db.customStatement(
          'INSERT INTO buttons (board_id, label, vocalization) '
          "VALUES (999999, 'x', '$phrase')",
        );
        fail('the FK violation should have thrown');
      } on SqliteException catch (_, s) {
        // The controller logs a FIXED message for this arm, never the exception.
        log.record('import failed: a database write error', s);
      }

      expect(
        logFile.readAsStringSync().contains(phrase),
        isFalse,
        reason: 'the statement text carries the phrase; only a fixed message may '
            'reach a log the user might mail out',
      );
      await db.close();
    });
  });
}

// ── Archive fixtures ─────────────────────────────────────────────────────────

Map<String, Object?> _validManifest() => _manifest();

Map<String, Object?> _manifest({
  Object? formatVersion = 1,
  bool omitFormatVersion = false,
}) => <String, Object?>{
  if (!omitFormatVersion) 'format_version': formatVersion,
  'reed_version': '0.1.0',
  'exported_at': '2026-07-16T00:00:00Z',
  'root': 'boards/1.json',
};

Map<String, Object?> _validBoard() => <String, Object?>{
  'id': 1,
  'name': 'exported board',
  'locale': 'en',
  'grid_rows': 1,
  'grid_cols': 2,
  'is_root': true,
  'buttons': <Map<String, Object?>>[
    _button(id: 10, label: 'Yes'),
    _button(id: 11, label: 'No'),
  ],
  'grid': <String, Object?>{
    'rows': 1,
    'columns': 2,
    'order': <List<int?>>[
      <int?>[10, 11],
    ],
  },
  'images': <Object?>[],
  'sounds': <Object?>[],
};

Map<String, Object?> _button({
  required int id,
  required String label,
  bool isSystem = false,
  int? loadBoardId,
  int? imageId,
}) => <String, Object?>{
  'id': id,
  'label': label,
  'vocalization': label,
  'display_text': null,
  'hidden': false,
  'is_system': isSystem,
  'user_edited': false,
  'priority': 1000,
  'background_color': null,
  'border_color': null,
  'image_id': imageId,
  'sound_id': null,
  'load_board_id': loadBoardId,
};
