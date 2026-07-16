import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/model/speak_outcome.dart';

/// The sealed outcome is the whole reason "silence" is not a possible result of
/// a tap. Two properties make that work and are tested here: every failure
/// carries the words it failed to say, so the screen always has something to
/// show; and no failure's log line carries those words, so the on-device log a
/// user might mail to a stranger never carries their voice.

/// Every failure variant, constructed with one phrase, so a single list drives
/// both guarantees. A private helper rather than a loop over `SpeakFailure`
/// subtypes because the constructors differ, and naming each keeps a failure
/// message pointing at the exact variant.
List<SpeakFailure> _allFailures(String phrase) => [
  NoVoiceSelected(phrase),
  VoiceUnavailable(phrase, voiceName: 'en-us-x'),
  VoiceNotInstalled(phrase, voiceName: 'en-us-x'),
  EngineRejected(phrase, code: 0),
  EngineTimedOut(phrase, waited: const Duration(seconds: 8)),
];

/// A total function of the outcome. Written as the app's fallback path is: a
/// switch with no `default:` and no `case _:`, matching the intermediate sealed
/// [SpeakFailure] so a new variant resolves here the same way — every failure
/// shows its words. If this ever fails to compile, a variant escaped the net.
String fallbackFor(SpeakOutcome outcome) => switch (outcome) {
  SpokeAloud() => '',
  SpeakFailure(:final spokenText) => spokenText,
};

void main() {
  const phrase = 'I need a minute';

  test('there are exactly five failure variants', () {
    // Guards the count the fallback and the fake both depend on. VoiceNotInstalled
    // is the one that looks redundant and is not: setVoice returns 1 for it, so
    // the return-value check cannot see it and it needs its own variant.
    expect(_allFailures(phrase), hasLength(5));
  });

  test('every failure carries the words it did not say', () {
    for (final f in _allFailures(phrase)) {
      expect(
        f.spokenText,
        equals(phrase),
        reason:
            '${f.runtimeType} lost the phrase; the screen would have '
            'nothing to show, which is silence by another name',
      );
    }
  });

  test('no failure leaks the phrase into its log line', () {
    // The log is user-exportable. logLine must carry engine facts and voice
    // names only — never the sentence — so a user mailing the log does not mail
    // their voice with it.
    const secret = 'the secret sentence nobody else should read';
    for (final f in _allFailures(secret)) {
      expect(
        f.logLine.contains(secret),
        isFalse,
        reason: '${f.runtimeType}.logLine leaked the phrase',
      );
    }
  });

  test('the fallback resolves every failure to its phrase', () {
    for (final f in _allFailures(phrase)) {
      expect(
        fallbackFor(f),
        equals(phrase),
        reason: '${f.runtimeType} did not resolve through the sealed switch',
      );
    }
  });

  test('a spoke-aloud outcome resolves to no fallback', () {
    expect(fallbackFor(const SpokeAloud()), isEmpty);
  });

  test('VoiceNotInstalled is distinct from VoiceUnavailable', () {
    // They are different failures: setVoice returns 0 for one and 1 for the
    // other, so collapsing them would make the notInstalled case undetectable.
    expect(
      const VoiceNotInstalled(phrase, voiceName: 'x'),
      isNot(isA<VoiceUnavailable>()),
    );
  });
}
