import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_export.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/media_store.dart';
import 'package:offline_aac/ui/strings.dart';
import 'package:path/path.dart' as p;

/// The export shape: a dated filename, a grid `order` with its nulls in place
/// (never compacted), hidden buttons carried, settings NOT carried, and a
/// manifest that says what wrote the file. Plus the copy rules for the strings
/// this task adds.
void main() {
  late Directory tmp;
  late MediaStore media;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('reed_export');
    media = MediaStore(Directory(p.join(tmp.path, 'docs'))..createSync());
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  /// Build a controlled 2x2 board with one empty slot and one hidden button,
  /// export it, and return the decoded archive plus the filename.
  Future<(Archive, String)> exportControlled(AppDatabase db) async {
    await _buildBoard(db);
    final staging = Directory(p.join(tmp.path, 'cache'))..createSync();
    Uint8List? captured;
    var filename = '';
    filename = await BoardExport(db, media).run(
      stagingDir: staging,
      now: DateTime.utc(2026, 7, 16, 9, 30),
      reedVersion: '0.1.0',
      share: (file) async => captured = await file.readAsBytes(),
    );
    return (ZipDecoder().decodeBytes(captured!), filename);
  }

  Map<String, Object?> jsonOf(Archive archive, String name) => jsonDecode(
    utf8.decode(
      archive.files.firstWhere((f) => f.name == name).content as List<int>,
    ),
  ) as Map<String, Object?>;

  Map<String, Object?> boardJson(Archive archive) {
    // Resolve the board file through the manifest root — the DB assigns the
    // board's id by autoincrement, so it is not necessarily 1.
    final root = jsonOf(archive, 'manifest.json')['root']! as String;
    return jsonOf(archive, root);
  }

  List<Map<String, Object?>> buttonsOf(Archive archive) =>
      (boardJson(archive)['buttons']! as List).cast<Map<String, Object?>>();

  test('the filename is reed-board-YYYY-MM-DD.zip in UTC', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final (_, filename) = await exportControlled(db);
    expect(filename, 'reed-board-2026-07-16.zip');
    await db.close();
  });

  test('grid.order keeps its nulls IN PLACE — never compacted', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final (archive, _) = await exportControlled(db);
    final grid = boardJson(archive)['grid']! as Map<String, Object?>;
    expect(grid['rows'], 2);
    expect(grid['columns'], 2);
    final order = grid['order']! as List;
    // Exactly rows x columns entries, with the emptied cell serialized as null.
    expect(order, hasLength(2));
    var nulls = 0;
    var ids = 0;
    for (final row in order) {
      final cells = row! as List;
      expect(cells, hasLength(2), reason: 'every row is exactly `columns` long');
      for (final cell in cells) {
        if (cell == null) {
          nulls++;
        } else if (cell is int) {
          ids++;
        }
      }
    }
    expect(nulls, 1, reason: 'the empty cell is a null in place, not dropped');
    expect(ids, 3, reason: 'three real button ids remain');
  });

  test('hidden buttons ARE exported — hide is not delete', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final (archive, _) = await exportControlled(db);
    final hidden = buttonsOf(archive).where((b) => b['hidden'] == true).toList();
    expect(hidden, hasLength(1), reason: 'a hidden button must survive the round trip');
  });

  test('a null vocalization serializes as null, not resolved to the label', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final (archive, _) = await exportControlled(db);
    final nullVoc = buttonsOf(
      archive,
    ).where((b) => b['vocalization'] == null).toList();
    expect(nullVoc, isNotEmpty);
    // Its label is present — proving null was not backfilled from it.
    expect(nullVoc.first['label'], isNotNull);
  });

  test('settings are NOT exported — no voice_id, theme, rate or pitch', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    // A stored voice id that must NOT travel: it does not resolve on another
    // phone, and the failure is a silent NoVoiceSelected mid-shutdown.
    await db.into(db.settings).insert(
      SettingsCompanion.insert(key: 'voice_id', value: 'en-US-voice-42'),
    );
    final (archive, _) = await exportControlled(db);

    expect(
      archive.files.any((f) => f.name.contains('settings')),
      isFalse,
      reason: 'there is no settings file in the archive',
    );
    final wholeArchive = archive.files
        .map((f) => utf8.decode(f.content as List<int>, allowMalformed: true))
        .join('\n');
    for (final leak in <String>['voice_id', 'en-US-voice-42', 'rate', 'pitch']) {
      expect(
        wholeArchive.contains(leak),
        isFalse,
        reason: 'a settings value ($leak) must never appear in an export',
      );
    }
    await db.close();
  });

  test('the manifest records the format version, reed version and root', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final (archive, _) = await exportControlled(db);
    final manifest = jsonOf(archive, 'manifest.json');
    expect(manifest['format_version'], 1);
    expect(manifest['reed_version'], '0.1.0');
    expect(manifest['root'], matches(r'^boards/\d+\.json$'));
    expect(manifest['exported_at'], startsWith('2026-07-16'));
    // The board file the root points at exists in the archive.
    expect(
      archive.files.any((f) => f.name == manifest['root']),
      isTrue,
    );
    await db.close();
  });

  group('copy', () {
    test('the added strings state the fact, no exclamation, no straight quote, '
        'no banned words', () {
      const lines = <String>[
        exportBoardChrome,
        importBoardChrome,
        importOkResult,
        importNotReedResult,
        importNeedsNewerResult,
        importFailedResult,
        exportFailedResult,
      ];
      for (final line in lines) {
        expect(line.contains('!'), isFalse, reason: 'exclamation in "$line"');
        expect(line.contains("'"), isFalse, reason: 'straight quote in "$line"');
        expect(line.contains('...'), isFalse, reason: 'ascii ellipsis in "$line"');
        for (final banned in <String>[
          'sorry',
          'oops',
          'please',
          'we ',
          'just ',
          'simply',
          'parent',
          'caregiver',
        ]) {
          expect(
            line.toLowerCase().contains(banned),
            isFalse,
            reason: '"$banned" in "$line"',
          );
        }
      }
    });

    test('no modal dialog anywhere in the export/import path', () {
      for (final path in <String>[
        'lib/ui/settings/portability_controller.dart',
        'lib/ui/settings/portability_io.dart',
        'lib/data/board_import.dart',
        'lib/data/board_export.dart',
      ]) {
        final code = File(path).readAsStringSync();
        expect(code.contains('showDialog'), isFalse, reason: '$path has a modal');
      }
    });
  });
}

/// A 2x2 board: three buttons, one cell emptied, one button hidden, one button
/// with a null vocalization. Root, on a fresh (wiped) database.
Future<void> _buildBoard(AppDatabase db) async {
  await db.delete(db.gridSlots).go();
  await db.delete(db.buttons).go();
  await db.delete(db.boards).go();

  final boardId = await db.into(db.boards).insert(
    BoardsCompanion.insert(
      name: 'exported board',
      gridRows: 2,
      gridCols: 2,
      isRoot: const Value(true),
    ),
  );
  final ids = <int>[];
  for (var i = 0; i < 4; i++) {
    ids.add(
      await db.into(db.buttons).insert(
        ButtonsCompanion.insert(
          boardId: boardId,
          label: 'L$i',
          vocalization: i == 2 ? const Value<String?>(null) : Value('V$i'),
        ),
      ),
    );
  }
  for (var i = 0; i < 4; i++) {
    await db.into(db.gridSlots).insert(
      GridSlotsCompanion.insert(
        boardId: boardId,
        rowIndex: i ~/ 2,
        colIndex: i % 2,
        buttonId: Value(ids[i]),
      ),
    );
  }
  // Empty one slot (delete its button) and hide another.
  await (db.delete(db.buttons)..where((b) => b.id.equals(ids[3]))).go();
  await (db.update(db.buttons)..where((b) => b.id.equals(ids[1])))
      .write(const ButtonsCompanion(hidden: Value(true)));
}
