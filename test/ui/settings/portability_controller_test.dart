import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/board_repository.dart' show databaseProvider;
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/media_store.dart';
import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:offline_aac/ui/board/board_controller.dart'
    show crashLogProvider;
import 'package:offline_aac/ui/settings/portability_controller.dart';
import 'package:offline_aac/ui/settings/portability_io.dart';
import 'package:offline_aac/ui/strings.dart';
import 'package:path/path.dart' as p;

/// The controller ties the two VOID settings controls to the tested export /
/// import classes: it maps every failure to one inline result line, never a
/// modal, and never lets a phrase from a rejected file reach the crash log.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory tmp;
  late AppDatabase db;
  late File logFile;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('reed_portability');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    logFile = File(p.join(tmp.path, 'log.txt'));
  });
  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  ProviderContainer containerWith(_FakeIo io) {
    final c = ProviderContainer(
      overrides: <Override>[
        databaseProvider.overrideWithValue(db),
        crashLogProvider.overrideWithValue(CrashLog.atFile(logFile)),
        portabilityIoProvider.overrideWithValue(io),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> pumpUntil(bool Function() done) async {
    for (var i = 0; i < 800 && !done(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }

  _FakeIo fakeIo() => _FakeIo(
    docs: Directory(p.join(tmp.path, 'docs'))..createSync(),
    staging: Directory(p.join(tmp.path, 'cache'))..createSync(),
  );

  test(
    'export clears the result line and hands a file to the share seam',
    () async {
      final io = fakeIo();
      final c = containerWith(io);

      c.read(portabilityControllerProvider.notifier).exportBoard();
      await pumpUntil(() => io.sharedBytes != null);

      expect(
        io.sharedBytes,
        isNotNull,
        reason: 'the export reached the share seam',
      );
      expect(
        c.read(portabilityControllerProvider),
        isNull,
        reason:
            'the share sheet is the confirmation; no inline line on success',
      );
    },
  );

  test('a cancelled import sets no message and makes no accusation', () async {
    final io = fakeIo()..picked = null; // user backed out of the picker
    final c = containerWith(io);

    c.read(portabilityControllerProvider.notifier).importBoard();
    await pumpUntil(() => false); // let any work settle

    expect(c.read(portabilityControllerProvider), isNull);
  });

  test('a valid file imports and reports it, board kept', () async {
    final valid = File(p.join(tmp.path, 'board.zip'))
      ..writeAsBytesSync(_zip(_validBoard()));
    final io = fakeIo()..picked = valid;
    final c = containerWith(io);

    c.read(portabilityControllerProvider.notifier).importBoard();
    await pumpUntil(() => c.read(portabilityControllerProvider) != null);

    expect(c.read(portabilityControllerProvider), importOkResult);
  });

  test(
    'a malformed file maps to "not a Reed board" and leaks no phrase',
    () async {
      const phrase = "I need to leave, I'm not able to talk right now";
      final malformed = File(p.join(tmp.path, 'bad.zip'))
        ..writeAsBytesSync(_zipRaw('{ "name": "$phrase", broken'));
      final io = fakeIo()..picked = malformed;
      final c = containerWith(io);

      c.read(portabilityControllerProvider.notifier).importBoard();
      await pumpUntil(() => c.read(portabilityControllerProvider) != null);

      expect(c.read(portabilityControllerProvider), importNotReedResult);
      expect(
        logFile.existsSync() ? logFile.readAsStringSync() : '',
        isNot(contains(phrase)),
        reason: 'the file’s phrases never reach a log the user might mail out',
      );
    },
  );

  test(
    'a newer-format file asks the user to update, not "not a Reed board"',
    () async {
      final newer = File(p.join(tmp.path, 'newer.zip'))
        ..writeAsBytesSync(_zip(_validBoard(), formatVersion: 2));
      final io = fakeIo()..picked = newer;
      final c = containerWith(io);

      c.read(portabilityControllerProvider.notifier).importBoard();
      await pumpUntil(() => c.read(portabilityControllerProvider) != null);

      expect(c.read(portabilityControllerProvider), importNeedsNewerResult);
    },
  );
}

/// A fake for the platform edges, so the controller runs with no real share
/// sheet, picker, or path_provider.
class _FakeIo implements PortabilityIo {
  _FakeIo({required this.docs, required this.staging});

  final Directory docs;
  final Directory staging;

  /// The file the picker "returns". Null models a cancelled pick.
  File? picked;

  /// The bytes handed to the share seam, captured before the export deletes the
  /// staging copy.
  Uint8List? sharedBytes;

  @override
  Future<File?> pickBoardFile() async => picked;

  @override
  Future<void> shareFile(File file) async =>
      sharedBytes = await file.readAsBytes();

  @override
  Future<Directory> stagingDirectory() async => staging;

  @override
  Future<MediaStore> mediaStore() async => MediaStore(docs);

  @override
  DateTime now() => DateTime.utc(2026, 7, 16);

  @override
  String get reedVersion => '0.1.0';
}

Uint8List _zip(Map<String, Object?> board, {int formatVersion = 1}) {
  final archive = Archive();
  void add(String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  add(
    'manifest.json',
    jsonEncode(<String, Object?>{
      'format_version': formatVersion,
      'reed_version': '0.1.0',
      'exported_at': '2026-07-16T00:00:00Z',
      'root': 'boards/1.json',
    }),
  );
  add('boards/1.json', jsonEncode(board));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

Uint8List _zipRaw(String boardContent) {
  final archive = Archive();
  void add(String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  add(
    'manifest.json',
    jsonEncode(<String, Object?>{
      'format_version': 1,
      'reed_version': '0.1.0',
      'exported_at': '2026-07-16T00:00:00Z',
      'root': 'boards/1.json',
    }),
  );
  add('boards/1.json', boardContent);
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

Map<String, Object?> _validBoard() => <String, Object?>{
  'id': 1,
  'name': 'exported board',
  'locale': 'en',
  'grid_rows': 1,
  'grid_cols': 2,
  'is_root': true,
  'buttons': <Map<String, Object?>>[
    <String, Object?>{'id': 10, 'label': 'Yes', 'vocalization': 'Yes'},
    <String, Object?>{'id': 11, 'label': 'No', 'vocalization': 'No'},
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
