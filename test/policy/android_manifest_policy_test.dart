import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The manifest carries three invariants that nothing else in the toolchain
/// checks. Each is one line, each is silent when broken, and one of them makes
/// the app mute on every device in the world.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  late String xml;

  setUpAll(() {
    expect(manifest.existsSync(), isTrue, reason: 'manifest not found');
    xml = manifest.readAsStringSync();
  });

  group('AndroidManifest', () {
    test('declares the TTS_SERVICE queries entry', () {
      // Android 11+ package visibility hides the TTS engine unless the app
      // declares it can see it. Without this, getVoices() returns an EMPTY LIST
      // on every device: no engine, no voices, no speech, no error. The app is
      // a silent rectangle and nothing reports it.
      expect(
        xml,
        contains('android.intent.action.TTS_SERVICE'),
        reason:
            'TTS_SERVICE is missing: getVoices() will be empty on Android '
            '11+ and the app is silent on every device.',
      );

      // It must be inside <queries>, not an <intent-filter>. In an
      // <intent-filter> it advertises that this app PROVIDES a TTS engine —
      // wrong meaning, and it does not grant visibility, so the failure is
      // identical while the manifest looks correct.
      final queries = RegExp(
        '<queries>(.*?)</queries>',
        dotAll: true,
      ).allMatches(xml).map((m) => m.group(1)!).join();
      expect(
        queries,
        contains('android.intent.action.TTS_SERVICE'),
        reason:
            'TTS_SERVICE must be inside <queries>. Inside an '
            '<intent-filter> it claims this app provides TTS and grants no '
            'visibility — same silence, correct-looking manifest.',
      );
    });

    test('disables cloud backup', () {
      // Offline plus no account means the only backup is the user's own export.
      // Cloud backup puts a board of intimate phrases on a provider's servers
      // under keys the provider holds. The threat model is not abstract: "I am
      // being hurt" implies an adversary who may be a caregiver or partner with
      // account access.
      expect(
        xml,
        contains('android:allowBackup="false"'),
        reason:
            'allowBackup must be false. Default is true: the board would '
            'silently upload to a cloud provider.',
      );
    });

    test('requests no INTERNET permission, and never will', () {
      // The absence of this permission is an OS-ENFORCED guarantee, verifiable
      // on the store listing before install. It is the strongest privacy claim
      // the app has — stronger than publishing source, which cannot prove the
      // shipped binary matches.
      expect(
        xml,
        isNot(contains('android.permission.INTERNET')),
        reason: 'The INTERNET permission would void the entire privacy claim.',
      );
    });
  });
}
