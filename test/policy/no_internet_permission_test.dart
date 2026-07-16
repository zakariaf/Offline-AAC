import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'policy_helpers.dart';

/// No `android.permission.INTERNET` reaches the shipped app, and the TTS_SERVICE
/// `<queries>` entry survives.
///
/// The absence of INTERNET is the STRONGEST asset the product has: it is
/// OS-enforced, visible on the store listing before install, and verifiable
/// without trusting a line of Reed's code. A share-sheet or file-picker plugin
/// that merged the permission in would break that claim without a line of our
/// code changing — so this checks the INPUTS to the manifest merger (the source
/// manifest and EVERY plugin manifest in the resolved graph), which is both
/// deterministic and exactly where a merged-in permission would originate.
///
/// It deliberately does NOT read the debug merged manifest: `flutter build apk
/// --debug` injects `android.permission.INTERNET` itself, for the Dart VM
/// service and hot reload. That injection is absent from the RELEASE build that
/// ships and that the store listing reflects. Asserting on a plugin's declared
/// permissions proves the release claim without a slow release build, and cannot
/// be fooled by tooling that only touches debug.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');

  test('no plugin in the graph declares the INTERNET permission', () {
    final deps = File('.flutter-plugins-dependencies');
    expect(
      deps.existsSync(),
      isTrue,
      reason: 'run `flutter pub get` — the plugin list is generated',
    );
    final json = jsonDecode(deps.readAsStringSync()) as Map<String, Object?>;
    final android =
        (json['plugins']! as Map<String, Object?>)['android']! as List<Object?>;

    final offenders = <String>[];
    for (final plugin in android.cast<Map<String, Object?>>()) {
      final path = plugin['path']! as String;
      final pluginManifest = File(
        p.join(path, 'android', 'src', 'main', 'AndroidManifest.xml'),
      );
      if (!pluginManifest.existsSync()) continue;
      // Comment-stripped, so a plugin's own explanatory comment cannot trip this.
      if (xmlOf(pluginManifest).contains('android.permission.INTERNET')) {
        offenders.add(plugin['name']! as String);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'these plugins would merge android.permission.INTERNET into the app, '
          'putting a socket in an app whose whole claim is that it has none: '
          '${offenders.join(', ')}',
    );
  });

  test('the source manifest declares no INTERNET permission', () {
    // Through xmlOf so a comment that merely NAMES the permission (there is one,
    // explaining why it is absent) cannot register as a declaration.
    expect(
      xmlOf(manifest),
      isNot(contains('android.permission.INTERNET')),
      reason: 'the INTERNET permission would void the entire privacy claim',
    );
  });

  test('the TTS_SERVICE queries entry is present, inside <queries>', () {
    final xml = xmlOf(manifest);
    // Without this, package visibility on Android 11+ hides the TTS engine,
    // getVoices() returns empty, and the app is silent on every device.
    expect(xml, contains('android.intent.action.TTS_SERVICE'));
    final queries = RegExp(
      '<queries>(.*?)</queries>',
      dotAll: true,
    ).allMatches(xml).map((m) => m.group(1)!).join();
    expect(
      queries,
      contains('android.intent.action.TTS_SERVICE'),
      reason: 'TTS_SERVICE must sit inside <queries>; in an <intent-filter> it '
          'claims Reed PROVIDES a TTS engine and grants no visibility',
    );
  });

  test('if a RELEASE merged manifest exists, it too has no INTERNET', () {
    // Belt and suspenders: the release build, unlike debug, does not inject
    // INTERNET, so its merged manifest is a truthful end-to-end check. Skipped
    // when no release build has run, so the suite stays green without one.
    final candidates = Directory('build').existsSync()
        ? Directory('build')
              .listSync(recursive: true)
              .whereType<File>()
              .where(
                (f) =>
                    f.path.endsWith('AndroidManifest.xml') &&
                    f.path.contains('merged_manifest') &&
                    f.path.contains('release'),
              )
              .toList()
        : <File>[];
    if (candidates.isEmpty) {
      markTestSkipped('no release merged manifest; run flutter build apk');
      return;
    }
    for (final merged in candidates) {
      expect(
        xmlOf(merged),
        isNot(contains('android.permission.INTERNET')),
        reason: 'the release merged manifest ${merged.path} declares INTERNET',
      );
    }
  });
}
