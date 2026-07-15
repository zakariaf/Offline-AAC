---
name: reed-speech-testing
description: FakeSpeechService, the silence-is-impossible suite, and voice_filter's wire traps — bare-implements fakes over mocktail/mockito, the SpeechEnv matrix, barge-in stop/speak ordering, and the STRING "1"/"0" network_required, TAB-separated features, notInstalled and null getVoices cases. Use when writing tests under test/speech/ or test/support/, faking or stubbing speak()/stop()/voices() or SpeakOutcome, mocking the flutter_tts MethodChannel, or asserting a tile tap never yields silence.
---

# Testing speech

Speech is the one path where a bug is invisible forever. There is no telemetry, and a
user who has lost speech mid-shutdown will never file a report. Tests are the only
feedback loop that exists, so the speech suite is written to assert the *absence of a
failure class*, not the presence of a behaviour.

## The contract under test

`SpeechService` is three methods: `Future<SpeakOutcome> speak(String)`,
`Future<void> stop()`, `Future<List<Voice>> voices()`. `speak` returns a sealed
`SpeakOutcome` — `SpokeAloud`, or a `SpeakFailure` subtype carrying `spokenText` (the
on-screen fallback) and `logLine` (crash-log only, never shown). The failure variants are
`NoVoiceSelected`, `VoiceUnavailable`, `EngineRejected`, `EngineTimedOut`.

Every failure carries `spokenText` so that showing the phrase on screen is a **total
function of the outcome**. Tests exploit this: whatever the environment, the assertion is
always *spoke OR showed*, never a per-variant special case.

## Fake the service. Do not mock the channel.

Write `test/support/fake_speech_service.dart` as a plain class with
`implements SpeechService` and **no `noSuchMethod` superclass**. Reasons, in order:

| Why | Detail |
|---|---|
| Interface drift breaks the **build** | Bare `implements` means adding a fourth method to `SpeechService` is a compile error, not a runtime surprise in one test. |
| The risk is **state**, not call-order | The question is never "was `speak()` called". It is "what happens when the voice vanished / `setVoice` returned 0". A fake models that as a field; a mock needs `when` plus side-effect gymnastics. |
| The fake **is** the contract's documentation | Whoever inherits this repo reads the fake to learn every way the world breaks. |

Do not justify the fake by claiming mocks "silently absorb" interface changes — that is
overstated and a reviewer will correctly push back. `mocktail` throws a `TypeError` on an
un-stubbed `Future`-returning method, and its own `Fake` class uses `noSuchMethod` too.
Both `mocktail` and `mockito` are healthy packages. Reserve `mocktail` for genuinely
external dependencies; use bare-`implements` fakes for services this repo owns.

**Never mock the `flutter_tts` MethodChannel across the suite.** Channel mocks couple
tests to the plugin's private method-name strings and untyped payloads, so a plugin
upgrade turns 50 tests red for reasons unrelated to what they assert — and they still
prove nothing about audio. They assert the *plugin's* behaviour, not this app's.

The one exception is a single file, `test/native/tts_channel_contract_test.dart`, whose
narrow job is to pin the plugin's wire behaviour so an upgrade fails loudly. With no
telemetry, that file is the only upgrade canary. It must:

- call `TestWidgetsFlutterBinding.ensureInitialized()` at the top of `main()` — a plain
  `test()` does not initialize the binding, and touching
  `TestDefaultBinaryMessengerBinding.instance` without it fails the whole file to load
  with "Binding has not yet been initialized";
- `tearDown(() => messenger.setMockMethodCallHandler(channel, null))` — a leaked handler
  is an order-dependent flake in later tests;
- pin exactly two facts: `setVoice` returning `0` does **not** throw (it is
  `result.success(0)`, never `result.error`), and `getVoices` hands back
  `List<Object?>` of `Map<Object?, Object?>` so the naive
  `(raw as List).cast<Map<String, String>>()` throws `TypeError`.

Nothing else goes in that file. If a new speech test needs a channel mock, the design is
wrong — put the seam in `SpeechService`.

## The fake's shape

Model the world as an enum, not as booleans:

```dart
enum SpeechEnv {
  healthy,
  noEngineInstalled,
  zeroVoices,
  onlyNetworkVoices,
  onlyNotInstalledVoices,
  setVoiceReturnsZero,
  storedVoiceUninstalled,
  speakReturnsZero,
  engineTimesOut,

  /// The engine returns 1 and NO AUDIO COMES OUT. No Dart-side signal exists.
  reportedSuccessButSilent;

  /// The environments the app can actually detect, and must therefore handle.
  static Iterable<SpeechEnv> get detectable =>
      values.where((SpeechEnv e) => e != SpeechEnv.reportedSuccessButSilent);
}
```

The fake maps each env to an outcome and records what happened:

- `spoken` — a `List<String>` appended to only in `healthy`. It is a spy: assert on
  *what* was spoken, which is how the label-vs-vocalization bug gets caught.
- `calls` — a `List<String>` of `'stop'` / `'speak'` / `'voices'`, for ordering.
- `voices()` returns `const <Voice>[]` for `noEngineInstalled`, `zeroVoices`,
  `onlyNetworkVoices` and `onlyNotInstalledVoices`. The filter has already run by the
  time voices reach the service, so the network-required and half-downloaded worlds
  correctly present as "no usable voice" — which is the state the UI must handle.
- `speak()` switches on `env` with **no `default:`**, so a new `SpeechEnv` value is a
  compile error until the fake decides what it means.

`reportedSuccessButSilent` returns `const SpokeAloud()` — the fake believes it spoke, and
it did not. That value exists to be excluded, and the exclusion is the honest part.

## The highest-value test in the app

```dart
// test/speech/silence_is_impossible_test.dart
for (final SpeechEnv env in SpeechEnv.detectable) {
  testWidgets('$env: a tile tap yields speech OR visible text, never neither',
      (WidgetTester tester) async {
    final FakeSpeechService speech = FakeSpeechService(env: env);
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);

    await tester.tap(find.bySemanticsLabel('Overwhelmed'));
    await tester.pump();

    final bool spoke = speech.spoken.isNotEmpty;
    final bool showedFallback = find.text(_kVocalization).evaluate().isNotEmpty;

    expect(spoke || showedFallback, isTrue,
        reason: 'SILENT FAILURE under $env. A user tapped a tile mid-shutdown and '
            'got neither speech nor the phrase on screen. Nobody will ever '
            'report this to you.');
    expect(tester.takeException(), isNull,
        reason: 'the failure must be handled, not thrown');
  });
}
```

Why this one matters structurally: it is the only test in the suite **unsatisfiable by a
code path that fails silently**. Every other test asserts a specific behaviour and can be
green while a neighbouring path drops a Future on the floor.

Rules for maintaining it:

- Iterate `SpeechEnv.detectable`, never `SpeechEnv.values` — the silent-audio env would
  fail it for a reason no code change can fix, and a permanently-red test gets deleted.
- Adding a value to `SpeechEnv` is how a newly-imagined failure becomes an obligation
  instead of a backlog note. Add the value first; let the build go red.
- `expect(tester.takeException(), isNull)` is load-bearing. Without it, a thrown
  `PlatformException` that happens to also render the fallback passes.
- Use `pump()`, never `pumpAndSettle()`. Zero animation is a design rule, so there is
  nothing to settle; `pumpAndSettle` carries a 10-minute default timeout and truncates
  its stack trace on timeout, so it can only add flake. `pump()` does not advance the
  fake clock — a debounce or `Future.delayed` still needs `pump(duration)`.
- Pin the surface with `useDevice(...)`. The default 800x600 logical test surface is
  wider than any phone; an unpinned layout assertion measures a screen nobody owns.

## Barge-in ordering

A re-tap means "say it again" / "I need this NOW", so `speak` must never be gated behind
an `if (_running) return` — that swallows the tap and produces the exact silence this app
forbids. Pin the order:

```dart
await tester.tap(find.bySemanticsLabel('Overwhelmed'));
await tester.pump();
await tester.tap(find.bySemanticsLabel('Yes'));
await tester.pump();

expect(speech.calls, <String>['stop', 'speak', 'stop', 'speak']);
```

If this test ever fails with `['stop', 'speak', 'speak']`, someone has "optimized away" a
redundant `stop()`. It is not redundant.

## `voice_filter` — pure Dart, tested exhaustively

`offlineSafeVoices(Object? raw)` and `tryParseVoice(Object? raw)` take the raw untyped
channel payload and return `List<Voice>`. They are pure functions over a data structure,
so test them with plain `test()` over hand-built maps — no binding, no widget, no channel.
This file carries a **100% coverage floor**, because it has four wire-format traps and any
one of them silently inverts the safety property *in the direction that hurts*: a voice
that needs the network gets classified offline-safe, and the app goes silent in airplane
mode.

Build fixtures that encode the *actual* wire format, not a tidy idealization:

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

The traps, each of which needs its own named test:

| Trap | The bug it hides |
|---|---|
| `network_required` is the **STRING** `"1"`/`"0"` | `raw['network_required'] == true` is *always* false (String vs bool), and `"0"` is non-empty so it survives a truthiness or null check. Parse as `nr == '1' \|\| nr == 1 \|\| nr == true`. |
| iOS **omits** the key entirely | Absent means not-network-required. A test named *iOS voice with no network_required key defaults to offline-safe* pins it. |
| `features` is **TAB**-separated (`joinToString(separator = "\t")`) | Split on `'\t'`, drop empties. Splitting on `,` or ` ` means `notInstalled` is never matched and the filter passes half-downloaded voices. |
| `getVoices` can return **null**, and its list is untyped | The plugin catches a NullPointerException and calls `result.success(null)`. `offlineSafeVoices(null)` must return `const <Voice>[]`, not crash. |

Beyond the traps, these cases are mandatory:

- **`notInstalled` is not offline-safe even though it is not network-required.** This is
  the subtle one: `setVoice` returns **1 (success)** for a half-downloaded voice, and
  synthesis then reports `ERROR_NOT_INSTALLED_YET` *or silently substitutes a different
  voice*. The return-value check cannot catch it. Only
  `features.contains(kFeatureNotInstalled)` can.
- **An empty voice list**, and **no engine installed**, both reduce to `[]` reaching the
  UI — assert the visible fallback, not an exception.
- **Only network voices** → the filter returns empty → `NoVoiceSelected`.
- **`setVoice` returns 0** → `VoiceUnavailable`. Nothing in the type system detects this;
  it is a hand-written `== 1` check, and the sealed type only guarantees the failure
  propagates *once detected*. Test the detection, not just the propagation.
- **The stored voice vanished between launches** (Android garbage-collects voice data) —
  the most probable real-world silent failure. Re-resolve the stored voice id against
  `voices()` at startup and fall back audibly; test that a stored id absent from
  `voices()` yields a surfaced failure rather than a silent no-op.
- **The safety property**, as one test over ~50 generated voices with mixed
  `network`/`notInstalled` flags: `safe` is non-empty, and *every* returned voice
  satisfies `!v.networkRequired && !v.features.contains(kFeatureNotInstalled)`. This is
  the assertion that survives a rewrite of the parser.

## What no Dart test can cover — say so, do not fake it

Four high-severity failures are unreachable by every automated means available. Do not
write a test that appears to cover them; a green test that proves nothing is worse than
an admitted gap, because it stops anyone from checking by hand.

| Failure | Why automation cannot reach it |
|---|---|
| The engine reports success and emits **no audio** | No hook exists to capture PCM from `AVSpeechSynthesizer` or Android TTS. This is `reportedSuccessButSilent`, and it is manual permanently. |
| The **audio session category** the OS actually applied | A Dart test can only assert *your code passed `.playback` to the wrapper* — a value-level assertion, not the real `AVAudioSession` category. `.ambient` lets the hardware silent switch mute the app, and the plugin's own README example uses `.ambient`. The only real check is: iPhone, hardware silent switch ON, tap a tile, audio still plays. |
| **Audio focus** denied (call in progress) | Requires a real incoming call. |
| **Bluetooth routing**, and a headset yanked mid-utterance | Requires real hardware. |

State these in a comment where the exclusion happens rather than in a tracker. The
`reportedSuccessButSilent` exclusion in `SpeechEnv.detectable` is the single line that
justifies the manual pre-release device pass; keep its doc comment intact.

Also out of scope: **do not test `flutter_tts` itself.** Test this app's `voice_filter`
and its `SpeechService` implementation. Testing the plugin buys a maintenance burden and
zero signal about whether a user hears anything.
