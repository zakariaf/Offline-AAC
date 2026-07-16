# E04-T06 — The speech test suite

| | |
|---|---|
| **Epic** | E04 — Speech |
| **Status** | Done |
| **Size** | M |
| **Depends on** | E04-T05 |
| **Blocks** | Nothing |

**Skills:** `reed-speech-testing` · `reed-testing-strategy` · `diagnosing-tile-silence`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

There is no telemetry and there never will be. A user who has lost speech mid-shutdown taps a tile, gets nothing, and uninstalls — and nobody ever finds out. This suite is the only feedback loop that exists for the speech path, so it is written to assert the **absence of a failure class** (never neither speech nor visible text) rather than the presence of a behaviour. It is also where the four `voice_filter` wire-format traps get pinned, because any one of them silently inverts the safety property *in the direction that hurts*: a network-required voice gets classified offline-safe, and the app goes mute in airplane mode.

## Scope

Three deliverables, in this order.

### 1. `test/support/fake_speech_service.dart` — fake the service, do not mock the channel

A plain class, `implements SpeechService`, with **no `noSuchMethod` superclass and no `extends Fake`**. Bare `implements` means adding a fourth method to `SpeechService` is a **compile error**, not a runtime surprise in one test. The risk here is *state* ("what happens when the stored voice vanished / `setVoice` returned 0"), which a fake models as a field; a mock needs `when` plus side-effect gymnastics. And the fake **is** the contract's documentation — whoever inherits this repo reads it to learn every way the world breaks.

Do **not** justify this in a comment by claiming mocks "silently absorb" interface changes. That is overstated and a reviewer will correctly push back: `mocktail` throws a `TypeError` on an un-stubbed `Future`-returning method, and its own `Fake` class uses `noSuchMethod` too. Both `mocktail` and `mockito` are healthy. The rule is: `mocktail` for genuinely external dependencies, bare-`implements` fakes for services this repo owns.

Model the world as an enum, not booleans:

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

The fake maps each env to a `SpeakOutcome` and records what happened:

- `spoken` — `List<String>`, appended to **only** in `healthy`. It is a spy: assert on *what* was spoken. This is how the label-vs-vocalization bug gets caught.
- `calls` — `List<String>` of `'stop'` / `'speak'` / `'voices'`, for ordering.
- `voices()` returns `const <Voice>[]` for `noEngineInstalled`, `zeroVoices`, `onlyNetworkVoices` and `onlyNotInstalledVoices`. The filter has already run by the time voices reach the service, so the network-required and half-downloaded worlds correctly present as "no usable voice" — the state the UI must handle.
- `speak()` switches on `env` with **no `default:`**, so a new `SpeechEnv` value is a compile error until the fake decides what it means.
- `reportedSuccessButSilent` returns `const SpokeAloud()` — the fake believes it spoke, and it did not. That value exists to be excluded, and the exclusion is the honest part. Keep its doc comment intact; it is the single line that justifies the manual pre-release device pass.

The failure variants the fake must produce: `NoVoiceSelected`, `VoiceUnavailable`, `EngineRejected`, `EngineTimedOut` — each carrying `spokenText` (the on-screen fallback) and `logLine` (crash-log only, never shown).

### 2. `test/speech/voice_filter_test.dart` — pure Dart, exhausted

`offlineSafeVoices(Object? raw)` and `tryParseVoice(Object? raw)` are pure functions over a data structure. Plain `test()` over hand-built maps — no binding, no widget, no channel. **100% coverage floor** on `lib/speech/voice_filter.dart`.

Fixtures encode the *actual* wire format, not a tidy idealization:

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

Each of the four wire traps gets its own **named** test:

| Trap | The bug it hides |
|---|---|
| `network_required` is the STRING `"1"`/`"0"` | `raw['network_required'] == true` is *always* false (String vs bool), and `"0"` is non-empty so it survives a truthiness or null check. Parse as `nr == '1' \|\| nr == 1 \|\| nr == true`. |
| iOS **omits** the key entirely | Absent means not-network-required. Name the test *iOS voice with no network_required key defaults to offline-safe*. |
| `features` is **TAB**-separated | Split on `'\t'`, drop empties. Splitting on `,` or `' '` means `notInstalled` is never matched and the filter passes half-downloaded voices. |
| `getVoices` can return **null**, untyped list | The plugin catches a NullPointerException and calls `result.success(null)`. `offlineSafeVoices(null)` must return `const <Voice>[]`, not crash. |

Plus, mandatory:

- **`notInstalled` is not offline-safe even though it is not network-required.** `setVoice` returns **1 (success)** for a half-downloaded voice, and synthesis then reports `ERROR_NOT_INSTALLED_YET` *or silently substitutes a different voice*. The return-value check cannot catch it. Only `features.contains(kFeatureNotInstalled)` can.
- **Empty voice list** and **no engine installed** both reduce to `[]` reaching the UI — assert the visible fallback, not an exception.
- **Only network voices** → filter returns empty → `NoVoiceSelected`.
- **`setVoice` returns 0** → `VoiceUnavailable`. Nothing in the type system detects this; it is a hand-written `== 1` check. **Test the detection, not just the propagation** — the sealed type only guarantees the failure propagates once detected.
- **The stored voice vanished between launches** (Android GCs voice data) — the most probable real-world silent failure. Re-resolve the stored voice id against `voices()` at startup; assert a stored id absent from `voices()` yields a *surfaced* failure rather than a silent no-op.
- **The safety property**, as one test over ~50 generated voices with mixed `network`/`notInstalled` flags: `safe` is non-empty, and *every* returned voice satisfies `!v.networkRequired && !v.features.contains(kFeatureNotInstalled)`. This is the assertion that survives a rewrite of the parser.

### 3. `test/speech/silence_is_impossible_test.dart` — the highest-value test in the app

Parameterized over `SpeechEnv.detectable`. For each env, a tile tap must yield speech **OR** the phrase visibly on screen — never neither.

```dart
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

Also in this file (or `test/speech/barge_in_test.dart`), the barge-in ordering test. A re-tap means "say it again / I need this NOW", so `speak` must never sit behind an `if (_running) return`:

```dart
await tester.tap(find.bySemanticsLabel('Overwhelmed'));
await tester.pump();
await tester.tap(find.bySemanticsLabel('Yes'));
await tester.pump();

expect(speech.calls, <String>['stop', 'speak', 'stop', 'speak']);
```

And the label-vs-vocalization test: the screen reader announces `Overwhelmed`, the engine receives the *sentence*. Nothing in the type system distinguishes two `String`s.

### Honest test names for what cannot be tested here

Where the exclusion happens, say what is excluded — in a comment at the exclusion site, not in a tracker. Four high-severity failures are unreachable by every automated means available:

| Failure | Why automation cannot reach it |
|---|---|
| Engine reports success, emits **no audio** | No hook exists to capture PCM from `AVSpeechSynthesizer` or Android TTS. This is `reportedSuccessButSilent`. Manual, permanently. |
| The audio session category the OS actually applied | A Dart test can only assert *your code passed `.playback` to the wrapper* — a value-level assertion, not the real `AVAudioSession` category. `.ambient` lets the hardware silent switch mute the app, and the plugin's own README example uses `.ambient`. Real check: iPhone, hardware silent switch ON, tap a tile, audio still plays. |
| Audio focus denied (call in progress) | Requires a real incoming call. |
| Bluetooth routing; headset yanked mid-utterance | Requires real hardware. |

A green test that proves nothing is **worse** than an admitted gap, because it stops anyone from checking by hand.

### Out of scope

- **Mocking the `flutter_tts` MethodChannel anywhere in this suite.** The one permitted channel mock lives in `test/native/tts_channel_contract_test.dart` and is not this task. If a test here seems to need a channel mock, the design is wrong — the seam goes in `SpeechService`.
- **Testing `flutter_tts` itself.** Maintenance burden, zero signal about whether a user hears anything.
- Goldens. Integration tests. Coverage percentage gates.
- The manual pre-release device pass (it is the deliberate replacement for the four rows above, not a placeholder).

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] `flutter test test/speech/ test/support/` passes; the whole `flutter test` suite still runs **under 30 seconds**.
- [ ] `test/support/fake_speech_service.dart` declares `class FakeSpeechService implements SpeechService` — `grep -n 'extends Fake\|noSuchMethod\|mocktail\|mockito' test/support/fake_speech_service.dart` returns nothing.
- [ ] `grep -rn 'setMockMethodCallHandler' test/speech/ test/support/` returns nothing.
- [ ] `SpeechEnv` has all ten values, and `detectable` excludes exactly `reportedSuccessButSilent`, with its doc comment present.
- [ ] Deleting a `case` from the fake's `speak()` switch is a compile error (no `default:` clause present — verify by `grep -n 'default:' test/support/fake_speech_service.dart` returning nothing).
- [ ] `silence_is_impossible_test.dart` iterates `SpeechEnv.detectable`, and its body contains `expect(tester.takeException(), isNull, ...)`.
- [ ] `grep -rn 'pumpAndSettle' test/speech/` returns nothing.
- [ ] `useDevice(Device.small)` is called before `pumpApp` in every widget test in `test/speech/`.
- [ ] The barge-in test asserts `<String>['stop', 'speak', 'stop', 'speak']` exactly.
- [ ] Named tests exist for: the `"1"`/`"0"` string, the absent iOS key, TAB-separated features, `offlineSafeVoices(null)`, `notInstalled` rejection, `setVoice` → 0 detection, the vanished stored voice, and the ~50-voice safety property.
- [ ] `lib/speech/voice_filter.dart` reaches **100%** line coverage, measured with untested files included (`dlcov --include-untested-files=true`, or via a generated `test/coverage_helper_test.dart`).
- [ ] The speech suite lands at roughly **35 tests**; if it is materially over, the PR says what the extra tests bought.

## Traps

- **`flutter test --coverage` omits files that no test imports.** A file with zero tests contributes zero lines to the *denominator* rather than counting as 0%. The number **lies upward** — the unsafe direction. Do not read a raw lcov percentage as evidence `voice_filter.dart` is at 100%.
- **`pumpAndSettle()` instead of `pump()`.** Zero animation is a design rule, so there is nothing to settle; `pumpAndSettle` carries a 10-minute default timeout and truncates its stack trace on timeout. It can only add flake. But note `pump()` does not advance the fake clock — a debounce or `Future.delayed` still needs `pump(duration)`.
- **Not pinning the surface.** The default 800×600 logical test surface is wider than any phone. An unpinned layout assertion measures a screen nobody owns.
- **Dropping `expect(tester.takeException(), isNull)`.** Without it, a thrown `PlatformException` that *happens* to also render the fallback passes the silence test. The line is load-bearing.
- **Iterating `SpeechEnv.values` instead of `detectable`.** The silent-audio env fails for a reason no code change can fix, and a permanently-red test gets deleted — taking the whole suite's best test with it.
- **Softening the silence test into "assert `speak` was called."** That makes it satisfiable by a code path that fails silently, which is the exact property that makes it valuable. Protect it.
- **"Optimizing away" the redundant `stop()`.** If barge-in ever asserts `['stop', 'speak', 'speak']`, someone did. It is not redundant — gating speech behind `if (_running) return` swallows the tap and manufactures the silence this app forbids.
- **Testing propagation instead of detection for `setVoice` → 0.** The sealed `SpeakOutcome` guarantees a failure propagates *once detected*. The detection is a hand-written `== 1` check and it is the actual root cause. A test that hands `VoiceUnavailable` to the UI and asserts the fallback appears has tested nothing about the gap.
- **Splitting `features` on `,` or `' '`.** `notInstalled` never matches, the filter passes half-downloaded voices, `setVoice` returns **1**, and synthesis silently substitutes a different voice. Fully green, fully broken.
- **A tidy fixture with `network_required: false` (bool).** It makes the naive `== true` check pass. The wire sends `"0"`.
- **A fake that appends to `spoken` in more than `healthy`.** Then the silence test is satisfiable by envs where nothing was said, and the suite's one real assertion goes hollow.
- **Adding a `default:` to the fake's switch.** A new `SpeechEnv` value then silently means "healthy" instead of breaking the build. Adding a value is how a newly-imagined failure becomes an obligation.
- **Writing a test that appears to cover `reportedSuccessButSilent`.** It stops anyone from checking by hand, and the hand check is the only one that exists.

## Files

Creates:

- `test/support/fake_speech_service.dart` — `SpeechEnv`, `FakeSpeechService`
- `test/speech/voice_filter_test.dart`
- `test/speech/silence_is_impossible_test.dart`

May touch:

- `test/support/` widget-test harness (`pumpApp`, `useDevice`) if it does not yet accept a `speech:` override
- `test/coverage_helper_test.dart` if the generated-import route is chosen over `dlcov`

Explicitly does **not** touch `test/native/tts_channel_contract_test.dart`.

## Done when

`flutter test` is green in under 30 seconds, `lib/speech/voice_filter.dart` is at 100% with untested files counted, and every environment the app can detect provably yields speech or visible text on a tile tap — with the environments it cannot detect named in a comment rather than faked green.


---

## What actually happened

SpeechEnv (10 values; detectable excludes exactly reportedSuccessButSilent) drives a plain implements-SpeechService fake with a no-default speak switch. silence_is_impossible_test parameterizes over detectable and asserts, end-to-end through the real board, that every tap yields speech OR visible text — never neither. Plus barge-in ordering (stop,speak,stop,speak) and the label-vs-sentence test. pumpApp/Device.small harness in test/support/.
