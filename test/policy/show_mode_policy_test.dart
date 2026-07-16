import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// Show mode's bans, as greps that outlast the reviewer who knows them.
///
/// The screen is the one surface the user is not looking at, so its failures are
/// invisible in review: a `t.ground` that hands a stranger a dark screen, an
/// animation on the flash, a clamp that shrinks the words. Each of these renders
/// fine and fails only in a stranger's hands. These checks fail the build
/// instead. Comments are stripped first, so the prose that explains a rule never
/// trips it.
void main() {
  const showDir = 'lib/ui/show_text';

  void expectAbsent({
    required String dir,
    required List<String> needles,
    required String why,
    bool Function(String path)? skip,
  }) {
    final offenders = <String>[];
    for (final file in dartFilesUnder(dir)) {
      if (skip != null && skip(file.path)) continue;
      final code = stripComments(file.readAsStringSync());
      for (final needle in needles) {
        offenders.addAll(matchingLines(file, code, needle));
      }
    }
    expect(offenders, isEmpty, reason: '$why\n${offenders.join('\n')}');
  }

  test('no transition or animation touches the flash', () {
    expectAbsent(
      dir: showDir,
      needles: <String>[
        'Animated',
        'Duration',
        'Curve',
        'Tween',
        'Hero',
        'PageRouteBuilder',
        'Color.lerp',
      ],
      why: 'the flash is one frame — nothing in show mode may animate',
    );
  });

  test('the poster never clamps, shrinks, or truncates the words', () {
    expectAbsent(
      dir: showDir,
      needles: <String>[
        'withClampedTextScaling',
        'textScaleFactor',
        'FittedBox',
        'AutoSizeText',
        'TextOverflow',
      ],
      why: 'the words are the product; a clipped sentence is a total failure',
    );
  });

  test('every colour comes from the theme, never a literal', () {
    expectAbsent(
      dir: showDir,
      needles: <String>['Color(0x'],
      why: 'read showGround/showInk/showStandingLine from AacTheme.of(context)',
    );
  });

  test('no text transform lives on the show or settings path', () {
    // A transform is a rule about all text, and text includes a user's own
    // sentence. Authored literals only.
    for (final dir in <String>[showDir, 'lib/ui/settings']) {
      expectAbsent(
        dir: dir,
        needles: <String>['toLowerCase(', 'toUpperCase('],
        why: 'author the labels lowercase; never lower a user string',
      );
    }
  });

  test('the show-mode preference keys are named only in the repository', () {
    final offenders = <String>[];
    for (final file in dartFilesUnder('lib')) {
      if (file.path.endsWith('settings_repository.dart')) continue;
      final code = stripComments(file.readAsStringSync());
      for (final key in <String>[
        'standing_line_enabled',
        'standing_line_text',
        'show_polarity',
      ]) {
        offenders.addAll(matchingLines(file, code, key));
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'a preference key is a magic string that must not leak out of the '
          'repository:\n${offenders.join('\n')}',
    );
  });

  test('the show ground/ink/standing hexes appear only in the tokens file', () {
    final offenders = <String>[];
    for (final file in dartFilesUnder('lib')) {
      if (file.path.endsWith('tokens.dart')) continue;
      final code = stripComments(file.readAsStringSync());
      for (final hex in <String>['0xFFFFFCF7', '0xFF1A140D', '0xFF5A544E']) {
        offenders.addAll(matchingLines(file, code, hex));
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'the poster colours live in the tokens file:\n${offenders.join('\n')}',
    );
  });
}
