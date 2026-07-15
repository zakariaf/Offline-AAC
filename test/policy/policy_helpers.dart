/// Shared helpers for the policy suite.
///
/// Policy tests assert project-wide invariants that no lint and no type can
/// see. They are tests rather than review items because review is a person on a
/// deadline, and each invariant here is a single line that silently destroys
/// the product.
library;

import 'dart:io';

/// Every `.dart` file under [dir], excluding generated output.
///
/// Generated files are excluded because they are not hand-written and cannot
/// violate an intent; including them makes the suite noisy and gets it muted.
List<File> dartFilesUnder(String dir) {
  final root = Directory(dir);
  if (!root.existsSync()) return const [];
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.drift.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

/// [source] with `//` and `/* */` comments blanked out, preserving line count
/// and column positions so reported line numbers stay accurate.
///
/// This matters: a test that greps raw source cannot tell a banned import from
/// a comment saying "never import this". The first is a defect; the second is
/// documentation, and failing on it teaches developers to delete the comments
/// that explain the rule.
///
/// String literals are deliberately NOT stripped. A banned name inside a string
/// is rare, and the false-positive costs a rename while the false-negative
/// costs the product.
String stripComments(String source) {
  final out = StringBuffer();
  var i = 0;
  var inLine = false;
  var inBlock = false;
  var inString = false;
  String? quote;

  while (i < source.length) {
    final c = source[i];
    final next = i + 1 < source.length ? source[i + 1] : '';

    if (inLine) {
      if (c == '\n') {
        inLine = false;
        out.write(c);
      } else {
        out.write(' ');
      }
      i++;
      continue;
    }
    if (inBlock) {
      if (c == '*' && next == '/') {
        inBlock = false;
        out.write('  ');
        i += 2;
        continue;
      }
      out.write(c == '\n' ? '\n' : ' ');
      i++;
      continue;
    }
    if (inString) {
      if (c == r'\') {
        out
          ..write(c)
          ..write(next);
        i += 2;
        continue;
      }
      if (c == quote) {
        inString = false;
        quote = null;
      }
      out.write(c);
      i++;
      continue;
    }
    if (c == '/' && next == '/') {
      inLine = true;
      out.write('  ');
      i += 2;
      continue;
    }
    if (c == '/' && next == '*') {
      inBlock = true;
      out.write('  ');
      i += 2;
      continue;
    }
    if (c == "'" || c == '"') {
      inString = true;
      quote = c;
      out.write(c);
      i++;
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

/// `file:line` for every line of [source] matching [pattern], 1-indexed.
///
/// A failure message that names the file and line is actionable at 2am; one
/// that says "a violation exists somewhere" is a scavenger hunt.
List<String> matchingLines(File file, String source, Pattern pattern) {
  final hits = <String>[];
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains(pattern)) {
      hits.add('${file.path}:${i + 1}  ${lines[i].trim()}');
    }
  }
  return hits;
}
