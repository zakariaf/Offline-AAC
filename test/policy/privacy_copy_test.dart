import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The privacy policy is a claim an adversarial reader checks with a decompiler
/// and a packet capture (E11-T01). One overclaimed sentence costs the product
/// the exact community it needs, so the banned phrasings are guarded as a test.
///
/// `legal/privacy-policy.md` is the single source of truth: it is the hosted
/// policy AND the asset the in-app privacy screen loads. See `reed-privacy-claims`.
void main() {
  final policy = File('legal/privacy-policy.md');

  group('privacy policy copy (E11-T01)', () {
    test('the policy source exists', () {
      expect(
        policy.existsSync(),
        isTrue,
        reason: 'legal/privacy-policy.md is missing',
      );
    });

    test('contains no banned absolutist or medical phrasing', () {
      final text = policy.readAsStringSync().toLowerCase();
      const banned = <String>[
        'nothing leaves your device',
        'fully private',
        '100% offline',
        'never leave',
        "we can't see",
        'guarantee', // the honest wording uses "assurance"/"guidance, not a promise"
        'clinically proven',
        'medical-grade',
        'therapy',
        'treats',
        'emergency',
        'open source', // never the trust argument in privacy copy
      ];
      final hits = banned.where(text.contains).toList();
      expect(
        hits,
        isEmpty,
        reason: 'banned phrase(s) in the privacy policy: ${hits.join(', ')}',
      );
    });

    test('keeps all three scoping clauses of the network sentence', () {
      final text = policy.readAsStringSync();
      expect(text, contains('no network code and no network permission'));
      expect(text, contains("your device's own system text-to-speech engine"));
      // The verb is "declare" — never upgraded to "guarantee"/"ensure".
      expect(text, contains('declare they need no network'));
    });
  });
}
