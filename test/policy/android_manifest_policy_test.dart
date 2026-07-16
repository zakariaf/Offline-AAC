import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// The manifest carries invariants that nothing else in the toolchain checks.
/// Each is one line, each is silent when broken, and one of them makes the app
/// mute on every device in the world while another puts a survivor's board of
/// intimate phrases in an adversary's Google Drive.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  final rulesFile = File(
    'android/app/src/main/res/xml/data_extraction_rules.xml',
  );
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

    test('cloud backup is off, device transfer is preserved', () {
      // Read through xmlOf so a comment that merely NAMES the rule cannot
      // satisfy it: `<!-- android:allowBackup="false" -->` would pass a raw
      // `contains` while the live attribute defaulted to true. Accumulate every
      // offender and fail once, so one broken line does not hide the next.
      final manifestXml = xmlOf(manifest);
      final rulesXml = xmlOf(rulesFile);
      final offenders = <String>[];

      // allowBackup="false" is the pre-Android-12 lever. Default is true, which
      // uploads the SQLite database — every phrase the user ever curated — to
      // Google Drive, an account a caregiver or partner may hold.
      if (!manifestXml.contains('android:allowBackup="false"')) {
        offenders.add(
          'android:allowBackup is not "false": the board uploads to the '
          "user's Google Drive, where an abuser with account access reads "
          '"I am being hurt".',
        );
      }

      // dataExtractionRules is what Android 12+ (API 31+) reads instead. Setting
      // only allowBackup leaves that version band on defaults.
      if (!manifestXml.contains(
        'android:dataExtractionRules="@xml/data_extraction_rules"',
      )) {
        offenders.add(
          'android:dataExtractionRules is not wired to '
          '@xml/data_extraction_rules: on Android 12+ the board reaches '
          "the user's Google Drive despite allowBackup, same disclosure.",
        );
      }

      // The rules file itself. A missing file makes xmlOf return '' — so these
      // fail with a message instead of a FileSystemException out of the runner.
      final cloud = xmlElement(rulesXml, 'cloud-backup');
      if (cloud == null || cloud.contains('<include')) {
        offenders.add(
          'data_extraction_rules.xml <cloud-backup> is missing or contains an '
          '<include>: whatever it includes is copied to Google Drive, where '
          'the person the user is hiding phrases from can read them.',
        );
      }

      // device-transfer is a DIFFERENT list on purpose: excluding the database
      // here is the failure this config exists to avoid — the user's board does
      // not survive a new phone and, with no telemetry, nobody ever learns.
      final transfer = xmlElement(rulesXml, 'device-transfer');
      if (transfer == null || !transfer.contains('<include')) {
        offenders.add(
          'data_extraction_rules.xml <device-transfer> has no <include>: the '
          "user's hand-curated board does not survive a new phone and they "
          'open to an empty grid.',
        );
      }

      expect(offenders, isEmpty, reason: offenders.join('\n'));
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
