import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the database file lives.
///
/// Application *support*, not documents: this is an internal database, not a
/// user-visible file. Documents is surfaced in the OS file browser, and a user
/// who finds `app_database.sqlite` there and deletes it to save space has
/// deleted their voice.
///
/// Note the app uses TWO base directories deliberately, and joining a path
/// against the wrong one fails silently and permanently: the database lives in
/// *support*; media paths are relative to *documents*.
Future<File> databaseFile() async {
  final dir = await getApplicationSupportDirectory();
  return File(p.join(dir.path, 'app_database.sqlite'));
}

/// Opens the database lazily, on a background isolate.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final file = await databaseFile();
    return NativeDatabase.createInBackground(file);
  });
}
