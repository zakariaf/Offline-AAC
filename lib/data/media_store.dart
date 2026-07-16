import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Owns the app documents directory — the ONE base every media path resolves
/// against.
///
/// The database lives under application SUPPORT; media lives under DOCUMENTS.
/// The two bases are deliberately different and are not interchangeable: joining
/// a media path against the support base (where the DB is) fails silently,
/// permanently, invisibly. Every read and write of a media file goes through
/// here so that base is named in exactly one place.
///
/// Paths stored in the `images`/`sounds` tables are RELATIVE to [documentsDir].
/// An absolute path dies on reinstall or restore when the OS container id
/// changes: the row survives, the file survives, and the tile renders blank
/// forever with no error and no telemetry. Resolve to absolute only at read
/// time, here.
///
/// This is the seam import writes bundled media through and export copies bytes
/// out of; a later task (image capture/downscale) layers onto the same base.
class MediaStore {
  MediaStore(this.documentsDir);

  /// Production: the real app documents directory. Tests construct [MediaStore]
  /// directly against a temp directory so no platform channel is required.
  static Future<MediaStore> open() async =>
      MediaStore(await getApplicationDocumentsDirectory());

  /// The one base. Never the support directory — that is where the DB lives.
  final Directory documentsDir;

  /// Media lives under this subdirectory of documents, split by kind, so an
  /// import never collides with anything else the app writes to documents.
  static const String mediaSubdir = 'media';

  /// Resolve a stored RELATIVE path to the absolute file on disk. The one place
  /// a media path is joined against a base, so it can never be joined against
  /// the wrong one.
  File resolve(String relativePath) =>
      File(p.join(documentsDir.path, relativePath));

  /// The relative path an imported image with [id] and file [extension] is
  /// stored at. Returned for the DB row; kept relative on purpose.
  String imageRelativePath(int id, String extension) =>
      p.posix.join(mediaSubdir, 'images', '$id.$extension');

  /// The relative path an imported sound with [id] and file [extension] is
  /// stored at.
  String soundRelativePath(int id, String extension) =>
      p.posix.join(mediaSubdir, 'sounds', '$id.$extension');

  /// Write [bytes] under [relativePath], creating parent directories, and return
  /// the same relative path for the caller to store in the DB. Bytes are written
  /// through here, never at a call site that hand-builds a documents path.
  Future<String> write(String relativePath, List<int> bytes) async {
    final file = resolve(relativePath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return relativePath;
  }
}
