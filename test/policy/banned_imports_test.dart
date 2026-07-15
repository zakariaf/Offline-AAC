import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// Some dependencies are refused permanently. A lint cannot express "this
/// package is against the product's thesis", so a grep does.
void main() {
  // (pattern, why). The `why` is the failure message: a developer who hits this
  // at 2am needs the reason, not just a veto.
  const banned = <String, String>{
    'package:http/': 'a network client. There is no INTERNET permission.',
    'package:dio/': 'a network client. There is no INTERNET permission.',
    'package:web_socket_channel/': 'a network client.',
    'package:firebase_core/':
        'analytics/telemetry. The privacy label gets '
        'WORSE with Firebase than with anything else.',
    'package:firebase_crashlytics/':
        'crash reporting. There is none, by design.',
    'package:sentry_flutter/':
        'crash reporting. The crash log is on-device and '
        'user-exported, or it does not exist.',
    'package:google_fonts/':
        'fetches fonts over HTTP at runtime by default. '
        'The typeface is bundled.',
    'package:dynamic_color/':
        'wallpaper-derived palettes are untestable at '
        'build time and break the colour/position learning the product rests on.',
  };

  test('no banned import appears in lib/', () {
    final violations = <String>[];
    for (final file in dartFilesUnder('lib')) {
      // Comments are stripped first. "// never use package:http here" is
      // documentation, not a defect — failing on it teaches people to delete
      // the comments that explain the rule.
      final code = stripComments(file.readAsStringSync());
      for (final entry in banned.entries) {
        for (final hit in matchingLines(file, code, entry.key)) {
          violations.add('$hit\n      -> ${entry.value}');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Banned imports found:\n${violations.join('\n')}',
    );
  });
}
