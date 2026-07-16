import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/board_export.dart';
import 'package:offline_aac/data/board_import.dart';
import 'package:offline_aac/data/board_repository.dart' show databaseProvider;
import 'package:offline_aac/ui/board/board_controller.dart' show crashLogProvider;
import 'package:offline_aac/ui/settings/portability_io.dart';
import 'package:offline_aac/ui/strings.dart';
import 'package:sqlite3/common.dart' show SqliteException;

/// The platform edges. Overridden with a fake in tests so the controller's error
/// mapping can be driven without a real share sheet or picker.
final Provider<PortabilityIo> portabilityIoProvider = Provider<PortabilityIo>(
  (ref) => const PortabilityIo(),
);

/// The board export/import controller.
///
/// Its state is the ONE inline result line the settings screen shows — never a
/// modal, which would demand a decision from someone whose decision-making is
/// exactly what is impaired. Both actions are VOID methods, deliberately:
/// `onTap: () => importer.import(f)` is flagged by NO lint — the arrow closure
/// "returns" the Future so the target VoidCallback discards it and its error,
/// and the user taps import and nothing happens. These own the `unawaited(...)`
/// and their own try/catch internally, the same shape as `SpeechController`.
class PortabilityController extends Notifier<String?> {
  @override
  String? build() => null;

  PortabilityIo get _io => ref.read(portabilityIoProvider);

  void _log(String message, StackTrace? stack) =>
      ref.read(crashLogProvider).record(message, stack);

  /// Build the export and hand it to the OS share sheet. On failure, one inline
  /// line and a FIXED log message — never the exception, whose text can carry a
  /// zip entry name or a path.
  void exportBoard() {
    unawaited(
      _export().catchError((Object _, StackTrace s) {
        _log('export failed', s);
        state = exportFailedResult;
      }),
    );
  }

  Future<void> _export() async {
    final io = _io;
    try {
      final media = await io.mediaStore();
      final staging = await io.stagingDirectory();
      await BoardExport(ref.read(databaseProvider), media).run(
        stagingDir: staging,
        now: io.now(),
        reedVersion: io.reedVersion,
        share: io.shareFile,
      );
      // The share sheet IS the confirmation; there is nothing to announce.
      // Clear any stale result line from a previous attempt.
      state = null;
    } on FileSystemException catch (_, s) {
      // A FIXED message. The exception carries a path, and only chosen strings
      // reach a log the user might mail out.
      _log('export failed: could not write or share the file', s);
      state = exportFailedResult;
    }
  }

  /// Pick a board file and import it as a NEW board. Import is non-destructive by
  /// construction, which is what earns the right to have no confirmation modal.
  void importBoard() {
    unawaited(
      _import().catchError((Object _, StackTrace s) {
        _log('import failed', s);
        state = importFailedResult;
      }),
    );
  }

  Future<void> _import() async {
    final io = _io;
    final file = await io.pickBoardFile();
    // Cancelled. Not a failure, so no message and no accusation.
    if (file == null) return;

    try {
      final media = await io.mediaStore();
      await BoardImport(ref.read(databaseProvider), media).importFile(file);
      state = importOkResult;
      // Every `on` clause logs a FIXED, phrase-free message. The incoming file's
      // phrases are NOT in the crash log's redaction set (they are not on this
      // phone yet), so interpolating the exception here would be the one leak the
      // net cannot catch. Engine codes, zip entry names and SqliteException text
      // stay out of the log.
      // ArchiveException is a subtype of FormatException, so it MUST be caught
      // first — a corrupt zip is "not a Reed board", never "needs a newer Reed".
    } on ArchiveException catch (_, s) {
      _log('import rejected: not a readable archive', s);
      state = importNotReedResult;
    } on FormatException catch (e, s) {
      _log('import rejected: the file failed validation', s);
      // The one distinction the copy draws: a file from a newer Reed vs. a file
      // that is not a Reed board at all. The message is one of this build's own
      // fixed strings, so matching on it is safe.
      state = e.message.contains('newer')
          ? importNeedsNewerResult
          : importNotReedResult;
    } on SqliteException catch (_, s) {
      _log('import failed: a database write error', s);
      state = importFailedResult;
    } on FileSystemException catch (_, s) {
      _log('import failed: a file read or write error', s);
      state = importFailedResult;
    }
  }
}

/// The inline export/import result line, or null when there is nothing to say.
final NotifierProvider<PortabilityController, String?>
portabilityControllerProvider =
    NotifierProvider<PortabilityController, String?>(PortabilityController.new);
