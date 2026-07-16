import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:offline_aac/data/media_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// The Reed build version stamped into an export's manifest. A plain constant,
/// not read from pubspec at runtime: package_info_plus would be a whole plugin
/// for one string, and the value only records which build wrote a file.
const String kReedVersion = '0.1.0';

/// The platform edges of export/import — the file picker, the share sheet, the
/// temp directory, the documents base, the clock.
///
/// Pulled behind ONE seam so the controller is a pure state machine a test can
/// drive with a fake: the round-trip and rejection tests never touch a real
/// share sheet or document picker. It is also the only file that imports the
/// share and picker plugins, which keeps that surface auditable in one place —
/// and it is where the "no INTERNET permission survived the plugin merge" test
/// earns its keep.
class PortabilityIo {
  const PortabilityIo();

  /// Ask the OS document picker for a board file. Null when the user cancels —
  /// which is not a failure and gets no message. No URL scheme, ever: a picker
  /// that could return an http(s) source would put a socket in an app whose
  /// whole claim is that it has none.
  Future<File?> pickBoardFile() async {
    final picked = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[
        XTypeGroup(
          label: 'Reed board',
          extensions: <String>['zip'],
          mimeTypes: <String>['application/zip'],
        ),
      ],
    );
    return picked == null ? null : File(picked.path);
  }

  /// Hand [file] to the OS share sheet. The app never sends it; the user picks
  /// the destination the app never sees or names.
  Future<void> shareFile(File file) async {
    await Share.shareXFiles(<XFile>[XFile(file.path)]);
  }

  /// The cache/temp directory the export stages its zip in — never documents,
  /// where the DB lives and where a plaintext copy would linger.
  Future<Directory> stagingDirectory() => getTemporaryDirectory();

  /// The documents-owning media helper, for copying media bytes in and out.
  Future<MediaStore> mediaStore() => MediaStore.open();

  DateTime now() => DateTime.now();

  String get reedVersion => kReedVersion;
}
