import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// Two invariants no lint enforces. Text scaling is the audience's primary
/// accommodation, so the app must never clamp it — and the tests must never
/// suppress the overflow errors that prove it wasn't clamped, or the whole
/// text-scale matrix becomes theatre.
void main() {
  test('lib never clamps or overrides text scale', () {
    final offenders = <String>[];
    const banned = <String>[
      'textScaleFactor',
      'withClampedTextScaling',
      'MediaQuery.withNoTextScaling',
      // Auto-shrink is a clamp wearing a different name: it makes the LONGEST,
      // most complex phrase the smallest and silently cancels the user's own
      // TextScaler while contrast and tap-target stay green.
      'FittedBox',
    ];
    for (final file in dartFilesUnder('lib')) {
      final code = stripComments(file.readAsStringSync());
      for (final needle in banned) {
        for (final hit in matchingLines(file, code, needle)) {
          offenders.add(
            '$hit\n      -> text scaling is the accommodation; '
            'never clamp it',
          );
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('no test suppresses overflow errors', () {
    // A RenderFlex overflow fails a widget test by default. Re-installing
    // FlutterError.onError or calling ignoreOverflowErrors would hide exactly
    // the failure the overflow matrix exists to catch.
    final offenders = <String>[];
    for (final file in dartFilesUnder('test')) {
      // This checker NAMES the forbidden strings, so it would flag itself; it is
      // the one file whose mention of them is the enforcement, not a breach.
      if (file.path.endsWith('no_text_clamping_test.dart')) continue;
      final code = stripComments(file.readAsStringSync());
      for (final needle in ['ignoreOverflowErrors', 'FlutterError.onError =']) {
        offenders.addAll(matchingLines(file, code, needle));
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'a test that swallows overflow makes the scale matrix a lie:\n'
          '${offenders.join('\n')}',
    );
  });
}
