import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// The obfuscation decision (E11-T03), guarded as a test rather than a comment.
///
/// `--obfuscate`, `--split-debug-info`, and R8 (`isMinifyEnabled`) each strip the
/// one field signal Reed will ever have: the on-device, user-exported crash log.
/// R8 fails in the worst possible shape — a tile tap that makes no sound, at
/// runtime, with a green build. None of that is visible to the analyzer, so it
/// is asserted here. See RELEASE.md.
void main() {
  group('R8 / obfuscation stays off (E11-T03)', () {
    test(
      'release buildType pins isMinifyEnabled and isShrinkResources off',
      () {
        final gradle = File('android/app/build.gradle.kts');
        expect(
          gradle.existsSync(),
          isTrue,
          reason: 'build.gradle.kts is missing',
        );

        // Comment-stripped so a comment NAMING the rule cannot satisfy it — the
        // assertion must read the configuration, not its documentation.
        final code = stripComments(gradle.readAsStringSync());
        expect(
          code.contains('isMinifyEnabled = false'),
          isTrue,
          reason: 'R8 minification must be explicitly OFF in the release block',
        );
        expect(
          code.contains('isShrinkResources = false'),
          isTrue,
          reason:
              'resource shrinking must be explicitly OFF in the release block',
        );
      },
    );

    test(
      'no proguard-rules.pro exists (its presence reverses the decision)',
      () {
        expect(
          File('android/app/proguard-rules.pro').existsSync(),
          isFalse,
          reason: 'a proguard-rules.pro means R8 is being turned back on',
        );
      },
    );

    test('no build command carries --obfuscate or --split-debug-info', () {
      final buildFiles = <File>[
        File('.github/workflows/ci.yml'),
        ...Directory('.')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.sh')),
      ].where((f) => f.existsSync());

      final offenders = <String>[];
      for (final f in buildFiles) {
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains('flutter build') &&
              (line.contains('--obfuscate') ||
                  line.contains('--split-debug-info'))) {
            offenders.add('${f.path}:${i + 1}  ${line.trim()}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'a build invocation carries a symbol-stripping flag:\n'
            '${offenders.join('\n')}',
      );
    });
  });
}
