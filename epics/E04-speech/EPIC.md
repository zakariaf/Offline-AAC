# E04 — Speech

> The whole product in six tasks: a sealed outcome, a pure filter over an untyped wire, a wrapper that checks every return code by hand, a void-returning seam, and a test loop that is unsatisfiable by silence.

| | |
|---|---|
| **Status** | Not started |
| **Tasks** | 6 |
| **Depends on** | E01 (E04-T01 gates on E01-T01's tree and analyzer config) |

## Why this epic exists

Someone mid-shutdown taps a tile. Either words come out of the speaker or the words go on the screen. There is no third outcome, and this epic is the code that makes that true. Everything else in Reed — the grid, the palette, the schema — is a way of reaching `speak()`.

The failure mode is not a crash. It is nothing. The tap registers, the log says success, every test is green, and the person holding the phone is still unable to speak. There is no telemetry and there never will be; a user who cannot talk does not file a bug report. So the hostile environment has to be enumerated a priori and encoded in types and tests, because the field will never report a single one of these back.

Nearly every rule in this epic reads as a mistake to a stranger. Checking a `setVoice` return value reads as paranoia — it is the documented behaviour of the plugin, which does `Log.d(tag, "Voice name not found: $voice"); result.success(0)`. `.playback` instead of `.ambient` reads as an oversight — `.ambient` is what flutter_tts's own README example uses, and it hands the hardware silent switch the power to mute a person's voice. `speakNow` returning `void` reads as sloppy — it is the only construction that closes a hole no lint in the ecosystem catches. Every one of these will be "cleaned up" by someone eventually, and no test and no crash report will ever say so. The reasoning goes in a comment at the point of temptation, not in a tracker.

## What "done" means

- `flutter test test/speech` passes, including `test/speech/silence_is_impossible_test.dart` looping every value of `SpeechEnv.detectable` and asserting `spoke || showedFallback` with `tester.takeException()` null.
- Barge-in is pinned: two taps record exactly `['stop', 'speak', 'stop', 'speak']`.
- `lib/data/speech/voice_filter.dart` is at its 100% coverage floor and contains no `import 'package:flutter_tts/...'`.
- `flutter test test/policy/android_manifest_policy_test.dart` passes: `android.intent.action.TTS_SERVICE` is inside `<queries>`.
- `flutter test test/policy/audio_session_policy_test.dart` passes: `AVAudioSessionCategory.playback` is in `lib/data/speech/audio_session_config.dart`, `.ambient` appears nowhere in `lib/`, and no other file constructs an `AudioSessionConfiguration`.
- `flutter test test/native/tts_channel_contract_test.dart` passes: `setVoice` returning `0` does not throw, and the naive `(raw as List).cast<Map<String, String>>()` throws `TypeError` while `offlineSafeVoices` survives.
- `dart analyze` is clean **and** the app builds — `non_exhaustive_switch_statement` is enforced by `dart compile`, and CI must build, not merely analyze.
- `grep -rn 'default:\|case _:' lib/data/speech/ lib/ui/board/` shows no wildcard over `SpeakOutcome`.
- No callback anywhere is `onTap: () => speech.speak(...)`. Every user-event handler into speech routes through a `void` method.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E04-T01 | SpeechService interface and the sealed outcome | S | E01-T01 |
| E04-T02 | The voice filter | M | E04-T01 |
| E04-T03 | The flutter_tts implementation | M | E04-T02 |
| E04-T04 | Audio session and the manifest | S | E04-T03 |
| E04-T05 | SpeechController: close the dropped-result hole | S | E04-T03 |
| E04-T06 | The speech test suite | M | E04-T05 |

**E04-T01 — SpeechService interface and the sealed outcome.** The vocabulary the other five tasks are written in: `abstract interface class SpeechService` with `speak`/`stop`/`voices`, and the sealed `SpeakOutcome` hierarchy — `SpokeAloud` plus the intermediate sealed `SpeakFailure` carrying `spokenText` and `logLine`, with `NoVoiceSelected`, `VoiceUnavailable`, `VoiceNotInstalled`, `EngineRejected`, `EngineTimedOut` under it. An S because nothing is invented; the shape is fixed. It is first because it is the only decision here that is structural: `spokenText` on every failure variant is what makes "put the words on screen" a *total function* of the outcome, so every downstream switch has exactly one thing to do.

**E04-T02 — The voice filter.** `lib/data/speech/voice_filter.dart`: pure Dart over `Object?` off the wire, no plugin import, 100% covered. It is an M and not an S because of four confirmed wire traps that each invert the safety property *in the direction that hurts* — Android's `network_required` is the **string** `"1"`/`"0"`, iOS omits the key entirely, `features` is **TAB**-separated, and `getVoices` can return **null** because the plugin catches a NullPointerException and calls `result.success(null)`. This file is where the bugs actually live, which is exactly why it lives one layer above the plugin where a test can reach it.

**E04-T03 — The flutter_tts implementation.** `FlutterTtsSpeechService`, deliberately the thinnest file in the epic: four plugin methods, hand-written checks at every one. The `notInstalled` guard sits *before* the `setVoice == 1` check because Android returns 1 for a half-downloaded voice and then substitutes another or says nothing — the return check cannot see it. `speak` carries `.timeout(_speakTimeout)` at 8 seconds with `on TimeoutException` and `on PlatformException` arms. It blocks E01-T06 (`main()` cannot warm the engine or resolve the stored voice against a service that does not exist) and E04-T05.

**E04-T04 — Audio session and the manifest.** Two lines of configuration that outrank most of the code above them. `<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>` — without it, Android 11+ package visibility hides the engine and *every Android 11+ user* gets an empty voice list and a board that cannot speak. `.playback` + `duckOthers` + `setSharedInstance`, never `.ambient`. Both are guarded by policy greps because both are textually decidable, silent when broken, and one line to break. Both tests can only assert the value; the ear resolves the rest. It blocks nothing and it is a release blocker anyway.

**E04-T05 — SpeechController: close the dropped-result hole.** The smallest task with the highest structural leverage. `speakNow` returns `void` on purpose: `onTap: () => s.speak(p)` is reported by **no** diagnostic — the arrow closure returns the Future so `discarded_futures` thinks it is handled, but the target type is `VoidCallback` so the Future and its error both hit the floor. Inside, `unawaited(_speak(p).catchError(...))`, `await _service.stop()` before every speak, and a switch over `SpeakOutcome` with no `default:`. It blocks E05-T04 — no tile gets wired to speech until the seam that makes the hole unreachable exists.

**E04-T06 — The speech test suite.** ~35 tests against a budget, not a floor. It owns `test/support/fake_speech_service.dart` (bare `implements`, no `noSuchMethod` superclass, `SpeechEnv` modelling every way the world breaks), the exhaustive `voice_filter` trap tests, the barge-in ordering pin, the single channel-contract canary, and the loop that gates the whole epic. `reportedSuccessButSilent` is excluded from `detectable` on purpose and its doc comment is the entire justification for the manual device pass.

## Skills this epic draws on

**The seam**
- `reed-speech-service` — the four plugin methods, the hand-written `== 1` checks, the `notInstalled` guard's position, the startup ordering, the `.playback` session, the `TTS_SERVICE` manifest line, and why the interface earns its eight lines.
- `reed-layering-rules` — `SpeechService` is one of exactly two things in this app that earn an interface, because it is the only thing in `data/` that cannot run in `flutter test`. Also why the `Command` pattern is refused.
- `reed-dart3-idioms` — `sealed` + `final class` variants, the intermediate sealed layer, `abstract interface class` for the seam, no `Result<T>`, no freezed, no `default:`.

**The failure model**
- `reed-error-model` — throw vs assert vs sealed outcome, the variant list and each `logLine`, `@useResult` biting only because `unused_result: error`, the two global handlers, and the log's redaction rule.
- `reed-no-silent-failures` — the arrow-callback hole, `unawaited` that lies, banned catch shapes, and the audit order for a diff.
- `reed-async-rules` — `unawaited(x)` is only honest when `x` ends in `catchError`, no controller method a callback invokes returns a Future, warm-up never blocks first frame, and the lit-latch timer bounded under the 8s speak timeout.
- `reed-riverpod-usage` — `speechServiceProvider` throws until overridden, `ref.read` inside callbacks, and never capturing a `build()` value into an `onTap`.

**Verification**
- `reed-speech-testing` — the fake's shape, `SpeechEnv`, the silence loop's maintenance rules, the wire-format fixtures, and the four things no Dart test can reach.
- `reed-testing-strategy` — the ~35-test speech budget inside ~135 total under 30 seconds, the 100% floor on `voice_filter.dart`, and why more integration tests are the wrong answer.
- `diagnosing-tile-silence` — the 28 enumerated ways a tap yields silence, tagged D/I/M/X. Consult it when a tap produced nothing; extend it when a 29th is found.
- `reed-policy-tests` — the three criteria a grep must meet, and the manifest and audio-session tests as written.
- `reed-manual-checklist` — the on-device pass that owns everything above tagged M or X.

## Sequencing

This is mostly a hard chain, and the chain is real rather than bureaucratic. T01 defines the types T02 returns and T03 constructs; T03 cannot be written before T02 because `speak()` reads `voice.notInstalled`, a field only the filter produces.

The one fork is after T03: **T04 and T05 are genuinely parallel.** T04 edits `AndroidManifest.xml`, `audio_session_config.dart`, and two policy tests; T05 writes `speech_controller.dart`. They share no file.

T06 is a hard follow because the silence loop taps a tile and asserts the fallback rendered — it needs the controller and the UI path, not just the service. Do not push its `voice_filter` tests earlier for a false parallelism win; they belong in one suite with one fake.

Outward: **T03 blocks E01-T06** — `main()`'s post-frame callback warms the engine and re-resolves the stored voice id, and it needs a real service to do it against. **T05 blocks E05-T04** — no tile is wired to speech before the void seam exists, because the first wiring anyone writes is the arrow-callback bug.

## Risks specific to this epic

- **The `!= _ttsSuccess` checks read as paranoia and get deleted.** They are the documented behaviour of the plugin: `result.success(0)`, never `result.error`. Nothing in the type system detects this — the sealed outcome only guarantees a failure propagates *once detected*. The comment at the point of temptation is the whole mitigation.
- **Someone drops `VoiceNotInstalled` as redundant.** It looks like a duplicate of `VoiceUnavailable`. It is not: `setVoice` returns **1** for a `notInstalled` voice. Delete the variant and the exhaustive switch still compiles green while never handling the case — a silent failure hiding inside the mechanism built to make silent failures impossible.
- **A wildcard branch appears.** `default:` or `case _:` over `SpeakOutcome` disables the only compiler-grade net in the codebase. Note that `analyzer: errors: non_exhaustive_switch_statement: ignore` silences `dart analyze` while `dart compile` still fails — which is why CI has to build.
- **`speakNow` gets "improved" to `Future<void>`.** That single edit reopens the hole no lint sees and returns the silence bug to the product. Same for `unawaited(...)` losing its `catchError`.
- **The channel mock spreads.** One contract file is the upgrade canary; a second means the design went wrong and the seam belongs in `SpeechService`. Channel mocks couple tests to the plugin's private method-name strings and prove nothing about audio. And a leaked mock handler with no `tearDown` is an order-dependent flake.
- **A tidy fixture.** Test fixtures that use `'network_required': false` and `'features': 'notInstalled'` (bool, comma) prove nothing — the real wire is the string `'0'` and a tab. A green filter test over an idealized payload is worse than no test.
- **`.ambient` returns by copy-paste.** It is what the plugin's README shows. A Dart test only proves the code passed `.playback` to the wrapper; the real check is a physical phone with the ringer switch off.
- **The silence loop gets softened.** "Assert `speak` was called" is the shape it decays into, and that version is satisfiable by a path that fails silently. It is the closest thing to telemetry this app will ever have. Iterate `detectable`, never `values`; keep `takeException`; keep `pump()`, never `pumpAndSettle()`.
- **A green suite is mistaken for a speaking app.** The analyzer cannot see the arrow-callback hole, an engine that reports success while emitting no audio, or a session category the OS actually applied. Those are caught by building and tapping.

## Out of scope

- **The tile, the tap, and the lit state.** `Listener.onPointerDown`, the 120ms minimum hold, the stuck-lit force-clear, and resolving the tile from `(row, col)` at tap time are E05 work. This epic hands E05 a `void speakNow` and stops.
- **`main()`'s startup order.** `CrashLog.open()` first, the two error handlers, the DB migration, the session config, and the post-frame warm-up plus stored-voice re-resolve live in E01-T06. T03 supplies the service it calls; it does not own the call site.
- **The crash log itself.** `record`'s bounded synchronous flushed write, its one licensed bare catch, and the redaction test belong with the diagnostics work. This epic only promises that no `logLine` ever interpolates `spokenText`.
- **The settings voice picker.** Presenting `voices()` and persisting a selection is settings UI. This epic owns the filter that decides what may be offered and the re-resolve contract that catches a stored id going stale.
- **The Quick Settings tile — and it may never be built at all.** It runs with **no Flutter engine** — no Dart, no `SpeechService`, no test at any level reaches it. Its versioned JSON contract, its `integration_test` round-trip, and its plain-Kotlin extraction are native-boundary work; `reed-native-boundary` governs, and it is the one skill with no task in this plan. That is deliberate. The tile exists to shorten time-to-first-word for someone whose phone is locked and pocketed, and **there is no evidence that user exists**: the launch barrier is an inference with zero direct testimony behind it. E00-T02 asks the question. If the answer is "my phone was already unlocked and in my hand", the whole native surface is worthless and must not be built — so it is not planned before the answer arrives. Note the standing tension while it is unbuilt: that skill asserts the speak path is native and reads from shared storage, while E04-T03 builds a Flutter-side speak path. Both are true in sequence, not in parallel — the Flutter path is the product; the native path, if it is ever justified, is a second door into the same phrases.
- **`reportedSuccessButSilent`, audio focus during a call, and Bluetooth yanked mid-utterance.** Structurally unreachable by every automated means available. They are owned by `reed-manual-checklist`, and that is a decision, not a gap to be plastered over with a mock.
