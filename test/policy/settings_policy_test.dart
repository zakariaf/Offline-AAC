import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// Settings' bans, as greps. The screen a user opens WHILE in trouble must stay
/// flat, still, and inline: no tree, no dialog, no animation, no key string
/// leaking out of the repository, no text transform on a list that contains
/// names. Comments are stripped first, so the prose that explains a rule never
/// trips it.
void main() {
  const settingsDir = 'lib/ui/settings';

  void expectAbsent(
    List<String> needles, {
    required String why,
    String dir = settingsDir,
  }) {
    final offenders = <String>[];
    for (final file in dartFilesUnder(dir)) {
      final code = stripComments(file.readAsStringSync());
      for (final needle in needles) {
        offenders.addAll(matchingLines(file, code, needle));
      }
    }
    expect(offenders, isEmpty, reason: '$why\n${offenders.join('\n')}');
  }

  test('no dialog, sheet, or second settings level', () {
    expectAbsent(
      <String>[
        'showDialog',
        'AlertDialog',
        'SimpleDialog',
        'BottomSheet',
        'ExpansionTile',
      ],
      why:
          'errors and choices are inline; a modal blocks the one screen they '
          'opened to use',
    );
  });

  test('no InkWell, ListTile, or animation', () {
    expectAbsent(
      <String>['InkWell', 'InkResponse', 'ListTile', 'Animated'],
      why: 'a settings row is a state change, not a 200ms ink highlight',
    );
  });

  test('the voice picker talks to SpeechService only, never flutter_tts', () {
    expectAbsent(
      <String>['package:flutter_tts'],
      why:
          'flutter_tts direct bypasses the setVoice check and the timeout — '
          'the picker would become the one screen a silent failure reports '
          'success',
    );
  });

  test('no text clamp or ellipsis on a settings label', () {
    expectAbsent(
      <String>[
        'withClampedTextScaling',
        'textScaleFactor',
        'FittedBox',
        'TextOverflow.ellipsis',
      ],
      why: 'voice ids are long; let them wrap, never clamp the user setting',
    );
  });

  test('no text transform on a screen whose list contains names', () {
    expectAbsent(
      <String>['toUpperCase(', 'toLowerCase('],
      why: 'a transform is a rule about all text, and text includes names',
    );
  });

  test('the preference keys are named only in the repository', () {
    final offenders = <String>[];
    for (final file in dartFilesUnder('lib/ui')) {
      final code = stripComments(file.readAsStringSync());
      for (final key in <String>[
        "'theme'",
        "'grid_size'",
        "'voice_id'",
        "'output_mode'",
        "'haptics'",
        "'low_stimulus'",
      ]) {
        offenders.addAll(matchingLines(file, code, key));
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'every read and write goes through SettingsRepository, which owns the '
          'key strings:\n${offenders.join('\n')}',
    );
  });
}
