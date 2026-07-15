import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// One word in one file decides whether the app can speak with the ringer
/// switch off. No lint sees it and no Dart test can observe the real OS
/// category — this asserts the value the code passes, which is the most a test
/// can reach. The rest is the device checklist.
void main() {
  final file = File('lib/data/speech/audio_session_config.dart');

  test('the audio session is playback, never ambient', () {
    expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
    final code = stripComments(file.readAsStringSync());

    expect(
      code,
      contains('AVAudioSessionCategory.playback'),
      reason: 'The session must use .playback.',
    );

    // .ambient respects the hardware silent switch: a user who flipped their
    // ringer for a meeting taps a tile mid-shutdown and produces nothing, with
    // no error anywhere. flutter_tts's own README example uses .ambient, so
    // this is one copy-paste away at all times.
    expect(
      code,
      isNot(contains('AVAudioSessionCategory.ambient')),
      reason:
          '.ambient lets the silent switch mute the app. A user flips their '
          'ringer switch for a meeting and loses their voice.',
    );
  });
}
