# E04-T02 — The voice filter

| | |
|---|---|
| **Epic** | E04 — Speech |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E04-T01 |
| **Blocks** | E04-T03, E08-T02 |

**Skills:** `reed-speech-service` · `reed-speech-testing` · `reed-no-silent-failures`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A voice that needs the network, or a voice whose data is still half-downloaded, looks exactly like a working voice on the wire. If one of them reaches `setVoice`, Android returns **1 (success)** and then either says nothing or substitutes a different voice — a user taps a tile in airplane mode, mid-shutdown, and gets silence. There is no telemetry; nobody will ever tell you this happened. The filter is where that whole failure class gets removed before it can reach the engine, and because it is pure Dart over a data structure, it is the one part of the speech path that can be tested to 100%.

## Scope

Build `lib/data/speech/voice_filter.dart` and its test file. **This file must never `import 'package:flutter_tts/...'`.** Purity is what makes it fully coverable, and this is where the safety actually lives. It takes `Object?` straight off the channel and returns `List<Voice>`.

Two public functions and one public constant:

```dart
// lib/data/speech/voice_filter.dart
const String kFeatureNotInstalled = 'notInstalled';

/// Android: until voice data finishes downloading, synthesis reports
/// ERROR_NOT_INSTALLED_YET *or substitutes a different voice* — while setVoice
/// still returns 1. The return-value check does not catch this.
bool _isOfflineSafe(Voice v) =>
    !v.networkRequired && !v.features.contains(kFeatureNotInstalled);

Voice? tryParseVoice(Object? raw) {
  if (raw is! Map) return null;
  final Object? name = raw['name'];
  final Object? locale = raw['locale'];
  if (name is! String || name.isEmpty) return null;
  if (locale is! String || locale.isEmpty) return null;

  // TRAP 1: Android sends the STRING "1"/"0". "0" is non-empty, so it survives
  //         a truthiness/null check. `raw['network_required'] == true` is
  //         ALWAYS false (String vs bool) — every network voice would be
  //         classified offline-safe.
  // TRAP 2: iOS OMITS this key entirely. Absent means not-network-required.
  final Object? nr = raw['network_required'];
  final bool networkRequired = nr == '1' || nr == 1 || nr == true;

  // TRAP 3: TAB-separated (voice.features.joinToString(separator = "\t")).
  final Object? f = raw['features'];
  final Set<String> features = (f is String && f.isNotEmpty)
      ? f.split('\t').where((String s) => s.isNotEmpty).toSet()
      : const <String>{};

  return Voice(
    name: name,
    locale: locale,
    networkRequired: networkRequired,
    features: features,
  );
}

/// TRAP 4: getVoices can return NULL — the plugin catches NullPointerException
/// and calls result.success(null). And it hands back List<Object?> of
/// Map<Object?, Object?>: `(raw as List).cast<Map<String, String>>()` throws
/// TypeError at runtime.
List<Voice> offlineSafeVoices(Object? raw) {
  if (raw is! List) return const <Voice>[];
  return raw.map(tryParseVoice).whereType<Voice>().where(_isOfflineSafe).toList();
}
```

Keep the trap comments verbatim. They sit at the exact point of temptation, and every one of them reads as paranoia to a reviewer who has not been bitten.

### Stored-voice re-resolution

Android garbage-collects voice data, so a voice id stored in settings can be uninstalled between launches. **This is the most probable real-world silent failure.** Re-resolve the stored voice id against `voices()` at startup and fall back audibly — never keep a dangling id and discover it at tap time. Ordering is load-bearing:

```
FIRST FRAME — grid visible and tappable
  addPostFrameCallback:
    SpeechService.warmUp()       — NOT awaited, NEVER blocks the frame
    voice_filter → resolve stored voice, fall back audibly if it vanished
```

A stored id absent from `voices()` yields a surfaced failure (the phrase on screen), not a silent no-op.

### Tests

`test/speech/voice_filter_test.dart`, plain `test()` over hand-built maps — no binding, no widget, no channel. Fixtures encode the *actual* wire format or they prove nothing:

```dart
Map<Object?, Object?> androidVoice(String name, String locale,
        {bool network = false, List<String> features = const <String>[]}) =>
    <Object?, Object?>{
      'name': name,
      'locale': locale,
      'quality': 'normal',
      'network_required': network ? '1' : '0', // STRING, not bool
      'features': features.join('\t'),         // TAB-separated
    };

Map<Object?, Object?> iosVoice(String name, String locale) =>
    <Object?, Object?>{'name': name, 'locale': locale, 'quality': 'default'};
    // NO network_required key at all.
```

Each trap gets its own named test, plus: `notInstalled` is not offline-safe even though it is not network-required; empty voice list and no-engine-installed both reduce to `[]`; only-network-voices reduces to `[]` (which becomes `NoVoiceSelected` downstream); and the safety property over ~50 generated voices with mixed `network`/`notInstalled` flags — `safe` is non-empty and *every* returned voice satisfies `!v.networkRequired && !v.features.contains(kFeatureNotInstalled)`. That last one is the assertion that survives a rewrite of the parser.

### Out of scope

- `FlutterTtsSpeechService` and the `setVoice != 1` check — E04-T01.
- `SpeechController`, tap wiring, the `silence_is_impossible` suite — E04-T03.
- `test/native/tts_channel_contract_test.dart`. It is a separate, single-file canary.
- **Do not test `flutter_tts` itself.** Testing the plugin buys maintenance and zero signal about whether a user hears anything.

## Acceptance criteria

- [ ] `grep -r "flutter_tts" lib/data/speech/voice_filter.dart` returns nothing.
- [ ] `offlineSafeVoices(null)` returns `const <Voice>[]` and does not throw.
- [ ] `offlineSafeVoices(<Object?>[androidVoice('a', 'en-US', network: true)])` returns `[]`.
- [ ] `offlineSafeVoices(<Object?>[androidVoice('a', 'en-US', features: <String>['notInstalled'])])` returns `[]`.
- [ ] A test named for the iOS case asserts a map with **no** `network_required` key parses to `networkRequired == false` and survives the filter.
- [ ] `tryParseVoice(androidVoice('a', 'en-US', features: <String>['male', 'notInstalled']))` yields `features` containing exactly `{'male', 'notInstalled'}` — proving the `'\t'` split, not a `,` or ` ` split.
- [ ] `tryParseVoice(<Object?, Object?>{'locale': 'en-US'})`, `{'name': ''}`, and a non-Map all return `null`.
- [ ] The property test over ~50 generated mixed voices asserts `safe.isNotEmpty` **and** `safe.every((Voice v) => !v.networkRequired && !v.features.contains(kFeatureNotInstalled))`.
- [ ] A test asserts a stored voice id absent from `voices()` surfaces a failure the user can see, not a no-op.
- [ ] `flutter test --coverage test/speech/voice_filter_test.dart` shows **100%** line coverage for `lib/data/speech/voice_filter.dart`. This file carries a 100% floor; it is the only file in the repo that does.
- [ ] `flutter analyze` is clean.

## Traps

- **`raw['network_required'] == true` is always false.** Android sends the **STRING** `"1"`/`"0"`. A `String` never equals a `bool`, so this comparison classifies *every network-only voice as offline-safe* and compiles clean. Parse with `nr == '1' || nr == 1 || nr == true`.
- **`"0"` is truthy in every guard you would reach for.** It is a non-empty String, so `if (nr != null)`, `if (nr.isNotEmpty)` and any truthiness idiom all say "network required" for a voice that is not. Compare the value; never test presence.
- **iOS omits the key entirely.** Treating absent as network-required drops every iOS voice and the board goes mute on iOS. Absent means not-network-required.
- **`features` is TAB-separated**, from `joinToString(separator = "\t")`. Split on `,` or `' '` and `notInstalled` is never matched — the filter then passes half-downloaded voices, which is trap 1's failure again by a different route.
- **`notInstalled` looks redundant next to the `setVoice == 1` check and is not.** Android returns **1 (success)** for a `notInstalled` voice, then reports `ERROR_NOT_INSTALLED_YET` or silently substitutes a different voice. Only `features.contains(kFeatureNotInstalled)` catches it.
- **`getVoices` can return null.** The plugin catches a NullPointerException and calls `result.success(null)`. `if (raw is! List) return const <Voice>[]` is the whole defence — an unguarded `raw as List` crashes the startup path.
- **The list is `List<Object?>` of `Map<Object?, Object?>`.** `(raw as List).cast<Map<String, String>>()` throws `TypeError` at runtime and passes every code review. `tryParse`, never cast — this is what `avoid_dynamic_calls: error` is defending.
- **The stored voice vanished between launches.** Android GCs voice data. Keeping a dangling id and finding out at tap time is silence at the exact worst moment. Re-resolve after the first frame, fall back audibly.
- **Tidy fixtures prove nothing.** A fixture with `'network_required': true` (bool) and `'features': ['notInstalled']` (List) makes a broken parser green. If the fixture is not string-`"1"` and tab-joined, the test is decoration.
- **Do not add a `default:` or `case _:`** anywhere this data reaches a sealed switch downstream. It disables the only alarm system this app has.

## Files

- `lib/data/speech/voice_filter.dart` — new.
- `test/speech/voice_filter_test.dart` — new.
- The startup re-resolution hook (post-first-frame `addPostFrameCallback`) — edit wherever E04-T01 placed the service wiring.

## Done when

`offlineSafeVoices` has 100% line coverage, every returned voice provably needs no network and is fully installed under a generated mixed input, and a voice that vanished between launches surfaces as words on screen rather than as nothing.
