import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/data/speech/voice_filter.dart';

/// The voice filter is where the app's silence is prevented, and it is pure Dart
/// over an untyped platform payload so it can be exhausted here. Every case is a
/// trap that, if the parser gets it wrong, classifies an unusable voice as
/// usable — it reaches `setVoice`, is accepted, and the user gets nothing. This
/// file carries a 100% line-coverage floor; it is the only file in the repo
/// that does, because a missed branch here is a missed way to go silent.

/// Builds a raw Android `getVoices` map the way the plugin actually sends it:
/// `network_required` as the STRING "1"/"0", `features` TAB-separated. Using the
/// real wire shapes is the point — a helper that pre-parsed them would test the
/// helper, not the filter.
Map<Object?, Object?> androidVoice(
  String name,
  String locale, {
  bool network = false,
  List<String> features = const [],
}) => <Object?, Object?>{
  'name': name,
  'locale': locale,
  'network_required': network ? '1' : '0',
  if (features.isNotEmpty) 'features': features.join('\t'),
};

void main() {
  group('offlineSafeVoices rejects the unusable', () {
    test('a null payload yields an empty list and does not throw', () {
      // getVoices can return null; the plugin catches a NullPointerException and
      // hands back null. A cast here would throw; the type guard must hold.
      expect(offlineSafeVoices(null), const <Voice>[]);
    });

    test('a non-List payload yields an empty list', () {
      expect(offlineSafeVoices(<String, String>{'not': 'a list'}), isEmpty);
    });

    test('a network-required voice is dropped', () {
      expect(
        offlineSafeVoices(<Object?>[androidVoice('a', 'en-US', network: true)]),
        isEmpty,
        reason:
            'a network voice on an app with no INTERNET permission is '
            'silence; the "1" string must be read as true',
      );
    });

    test('a not-installed voice is dropped even though it is offline', () {
      // setVoice returns 1 for a half-downloaded voice, so the return check
      // cannot catch it. Only the feature flag can.
      expect(
        offlineSafeVoices(<Object?>[
          androidVoice('a', 'en-US', features: [kFeatureNotInstalled]),
        ]),
        isEmpty,
      );
    });
  });

  group('tryParseVoice', () {
    test('an iOS voice with no network_required key parses as offline-safe', () {
      // iOS omits the key entirely; absent must mean not-network-required, or
      // every iOS voice would be dropped and the app would be silent on iPhone.
      final voice = tryParseVoice(<Object?, Object?>{
        'name': 'Samantha',
        'locale': 'en-US',
      });
      expect(voice, isNotNull);
      expect(voice!.networkRequired, isFalse);
      expect(
        offlineSafeVoices(<Object?>[
          <Object?, Object?>{'name': 'Samantha', 'locale': 'en-US'},
        ]),
        hasLength(1),
      );
    });

    test('features split on TAB, not comma or space', () {
      final voice = tryParseVoice(
        androidVoice('a', 'en-US', features: ['male', kFeatureNotInstalled]),
      );
      // A comma or space split would never match 'notInstalled', and the filter
      // would pass a half-downloaded voice.
      expect(voice!.features, equals({'male', kFeatureNotInstalled}));
    });

    test('an integer or boolean network_required is also read as network', () {
      // Belt and braces: a future platform could send a real int or bool. All
      // three truthy forms mean network-required.
      expect(
        tryParseVoice(<Object?, Object?>{
          'name': 'a',
          'locale': 'en-US',
          'network_required': 1,
        })!.networkRequired,
        isTrue,
      );
      expect(
        tryParseVoice(<Object?, Object?>{
          'name': 'a',
          'locale': 'en-US',
          'network_required': true,
        })!.networkRequired,
        isTrue,
      );
    });

    test('malformed maps and non-maps return null', () {
      expect(tryParseVoice(<Object?, Object?>{'locale': 'en-US'}), isNull);
      expect(tryParseVoice(<Object?, Object?>{'name': ''}), isNull);
      expect(tryParseVoice(<Object?, Object?>{'name': 'a'}), isNull);
      expect(
        tryParseVoice(<Object?, Object?>{'name': 'a', 'locale': ''}),
        isNull,
      );
      expect(tryParseVoice('not a map'), isNull);
      expect(tryParseVoice(null), isNull);
      // A voice with an empty features string keeps the const-empty set path.
      expect(
        tryParseVoice(<Object?, Object?>{
          'name': 'a',
          'locale': 'en-US',
          'features': '',
        })!.features,
        isEmpty,
      );
    });
  });

  test('the safety property holds over many mixed voices', () {
    // The assertion that survives a rewrite of the parser: whatever comes back
    // is non-empty AND every voice in it is genuinely usable. A seeded, not
    // random, mix so the failure is reproducible.
    final raw = <Object?>[];
    for (var i = 0; i < 50; i++) {
      raw.add(
        androidVoice(
          'v$i',
          'en-US',
          network: i % 3 == 0,
          features: i % 4 == 0 ? [kFeatureNotInstalled] : const [],
        ),
      );
    }
    final safe = offlineSafeVoices(raw);
    expect(safe, isNotEmpty);
    expect(
      safe.every(
        (v) => !v.networkRequired && !v.features.contains(kFeatureNotInstalled),
      ),
      isTrue,
      reason: 'the filter let through a voice that will produce silence',
    );
  });
}
