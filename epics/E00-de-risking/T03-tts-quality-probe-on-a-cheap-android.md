# E00-T03 — TTS quality probe on a cheap Android

| | |
|---|---|
| **Epic** | E00 — De-risking |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E00-T02 |
| **Blocks** | E00-T04, E00-T05, E01-T01 |

**Skills:** `reed-speech-service` · `reed-speech-testing` · `reed-dependency-hygiene`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

The entire product is a bet that the TTS engine already on a user's phone sounds good enough to speak for them in front of another human. If it does not — if the voice is so robotic that a person in a shutdown would rather type on a screen than press play — then the one-tap grid is decoration and the real product is something else. This probe is the only chance to find that out before two weeks of work assume the answer. It runs on a throwaway app, on the hardware the audience actually owns, and it is allowed to kill the project as specified.

## Scope

**A throwaway Flutter app. Not the real project.** Create it outside `lib/` — a separate `flutter create` at a path of your choosing (e.g. `~/scratch/tts_probe`). No `SpeechService` interface, no `SpeakOutcome`, no Riverpod, no tests beyond what you need to trust the numbers. Nothing from this app is merged into Reed. Its only output is a decision and a table of measurements.

### 1. Wire flutter_tts

Add `flutter_tts` with a caret range (`flutter_tts: ^<current>` via `dart pub add`), and before you trust it, run the dependency gate from `reed-dependency-hygiene` — the probe app is where you learn what the tree drags in, while it is still free to walk away:

```sh
dart pub add --dry-run flutter_tts
dart pub deps --json > /tmp/deps.json
python3 /Users/zakariafatahi/50-apps-challenge/Offline-AAC/.claude/skills/reed-dependency-hygiene/scripts/audit_deps.py /tmp/deps.json
```

Exit 1 means a banned pattern resolved (network path, crash/usage reporting, Firebase, device identifiers, `--enable-experiment`) — report it, because it is a finding about the real app, not about the probe. Record `flutter_tts`'s licence (expected MIT), maintainer count and last publish date while you are here; MIT is the precondition for the vendoring escape hatch and this is when it gets confirmed.

**The manifest line comes first, not last.** In the probe app's `android/app/src/main/AndroidManifest.xml`:

```xml
<queries>
  <intent><action android:name="android.intent.action.TTS_SERVICE" /></intent>
</queries>
```

Without it, Android 11+ package visibility hides the TTS engine and `getVoices` returns an empty list with only a `Log.d`. If you skip this you will conclude "the cheap phone has no voices" and kill the project for the wrong reason.

Set the audio session to `.playback` + `duckOthers` + `setSharedInstance`. **Never `.ambient`** — the `flutter_tts` README example uses `.ambient`, and copying it means the hardware silent switch mutes your probe and you measure silence.

### 2. Enumerate voices with their real metadata

Call `getVoices` and dump every voice with `name`, `locale`, `quality`, `network_required` and `features` — **printed raw, before any parsing**, so you see the actual wire format with your own eyes. This is the second deliverable of the task: a verified record of what a $120-150 Android phone reports.

Then parse it with the same logic `voice_filter` will use, so the probe validates the parser design rather than a tidy idealization:

```dart
const String kFeatureNotInstalled = 'notInstalled';

final Object? nr = raw['network_required'];
final bool networkRequired = nr == '1' || nr == 1 || nr == true;

final Object? f = raw['features'];
final Set<String> features = (f is String && f.isNotEmpty)
    ? f.split('\t').where((String s) => s.isNotEmpty).toSet()
    : const <String>{};

bool offlineSafe(Voice v) =>
    !v.networkRequired && !v.features.contains(kFeatureNotInstalled);
```

Android sends `network_required` as the **STRING** `"1"`/`"0"`; iOS omits the key entirely; `features` is **TAB**-separated (`joinToString(separator = "\t")`); `getVoices` can return **null** (the plugin catches a NullPointerException and calls `result.success(null)`), and hands back `List<Object?>` of `Map<Object?, Object?>` so `(raw as List).cast<Map<String, String>>()` throws `TypeError`. Confirm each of these four against what the device actually prints, and write down any that do not match — a mismatch is a finding that changes `voice_filter` before it is written.

Report, per device: total voices, how many survive the offline-safe filter, how many are `network_required`, how many carry `notInstalled`, and the `quality` value of each.

### 3. Speak ten real phrases and time them

Use ten phrases from the E00-T02 sessions — real ones people said they need, not "Hello world". Include at least one long enough to run past a clause boundary, because prosody collapse shows up in sentences and not in single words.

For each phrase, on each device, record:

- **Latency**: milliseconds from tap to first audible sound. Time it from the tap handler to the engine's start callback, and separately confirm with a stopwatch or a recording — the callback can fire before audio does.
- **`setVoice` return code.** Log it. `flutter_tts`'s Kotlin does `Log.d(tag, "Voice name not found: $voice"); result.success(0)` — that is `result.success`, not `result.error`, so it never throws. If you do not check `== 1` by hand, a wrong voice silently substitutes and you A/B the wrong engine.
- **`speak` return code**, and whether audio actually came out. `speak` returning 1 with no audio is `reportedSuccessButSilent` — no Dart-side signal exists for it, ever. Your ears are the instrument.
- Whether anything was cut off, clipped at the start, or routed somewhere unexpected.

Use an 8-second timeout on `speak` (`Duration(seconds: 8)`), matching the real impl's `_speakTimeout`, and note any phrase that hits it.

### 4. Run it on the right two devices

**(a) A $120-150 Android phone.** Not a flagship. Not a "mid-range" compromise. The audience is cost-constrained, so that price band *is* the target hardware — a Moto G Play / Galaxy A0x-class device bought new, not a three-year-old ex-flagship. Buy or borrow one. An emulator does not count: standard emulator images ship without a TTS engine or voice data, so an emulator run measures nothing.

**(b) A device carrying only the default compact voice** — no downloaded high-quality voice data. This is what a user gets on first launch before they have been told to go into Android settings and download anything, and a large fraction of them never will. If your $120 phone already has the compact voice only, it satisfies both (a) and (b); say so explicitly rather than pretending you ran two.

Also do one pass with the ringer switch / Do Not Disturb engaged and one with Bluetooth audio connected, and note the result. These are permanently outside every automated test.

### 5. Blind A/B against the incumbent

Five people from E00-T02. For each of the ten phrases, play Reed's stock-TTS rendering and the incumbent app's rendering **in randomised order, without saying which is which**, and ask the question that matters: *would you be willing to let this speak for you, to a stranger, right now?* Not "which sounds nicer" — willingness, because that is the thing the product needs.

Record per-phrase preference and, for each participant, an overall verdict. Do not average away a participant who says "neither, I would type." That answer is the finding.

Out of scope: any code in `lib/`, `SpeechService`, `SpeakOutcome`, the `SpeechEnv` matrix, `test/native/tts_channel_contract_test.dart`, choosing a voice-picker UI, and measuring iOS. The probe is Android-only and disposable.

### The kill criterion — state it before you run, not after

**If stock TTS cannot match the incumbent, the project does not proceed as specified.** Write the threshold down and get it agreed *before* the first A/B session, because after five sessions of sunk effort every result looks passable. A defensible form: fewer than 4 of 5 participants willing to let stock TTS speak for them, or a clear majority preferring the incumbent on the blind comparison, is a fail.

The two fallbacks:

- **Bundle a neural engine.** Roughly +55MB APK, plus battery and thermal cost — on the $120 phone, which is exactly the device that can least afford either.
- **Build message-banking-first**, where the user's own recorded voice is the primary channel and synthesis is the fallback.

**Both are DIFFERENT PRODUCTS.** They change the install size, the onboarding, the storage model and the promise. Neither gets absorbed into the current plan as "a small change to E01" — each must be re-decided from the top, with its own scope. If the probe fails, this task's output is a stop, not a workaround.

## Acceptance criteria

- [ ] The probe app's `AndroidManifest.xml` contains `android.intent.action.TTS_SERVICE`, and you can show that removing it makes `getVoices` return empty on the target device — that is the check that proves the manifest line is load-bearing.
- [ ] `python3 .claude/skills/reed-dependency-hygiene/scripts/audit_deps.py /tmp/deps.json` exits 0 for the `flutter_tts` tree, or the exit-1 hits are reported by name and marked `direct`/`TRANSITIVE`.
- [ ] `flutter_tts`'s licence is recorded and is MIT (or the vendoring escape hatch is documented as closed).
- [ ] A raw dump of `getVoices` output from the $120-150 device exists, unparsed, in the results.
- [ ] Each of the four wire-format facts is marked confirmed or contradicted against that dump: `network_required` is the string `"1"`/`"0"`, iOS omits the key, `features` is tab-separated, `getVoices` returns untyped `List<Object?>` of `Map<Object?, Object?>`.
- [ ] Per device: voice count, offline-safe count, network-required count, `notInstalled` count, and each voice's `quality` value.
- [ ] Ten phrases × two devices: tap-to-first-audio latency in ms, `setVoice` return code, `speak` return code, and whether audio was actually heard.
- [ ] Any `reportedSuccessButSilent` occurrence — return code 1 with no audio — is recorded with the phrase and voice that produced it.
- [ ] Both devices are named with model and street price. A run on an emulator, a flagship, or a "mid-range" phone does not satisfy (a).
- [ ] The kill threshold is written down and dated **before** the first A/B session.
- [ ] Five blind A/B sessions, randomised order, with per-participant willingness verdicts recorded verbatim.
- [ ] A single explicit written verdict: PROCEED, or FAIL → which fallback is now on the table and needs its own decision.

## Traps

- **Skipping the `<queries>` block and concluding the phone has no voices.** Android 11+ package visibility hides the TTS engine; `flutter_tts` returns an empty list with only a `Log.d`. You would kill a viable project on a manifest omission.
- **Testing on an emulator.** Standard emulator images have no TTS engine and no voice data. Zero signal about audio, and green.
- **Testing on your own phone.** It is a better device than the audience owns, it has downloaded high-quality voice data you forgot you downloaded, and it will tell you the project is fine.
- **`raw['network_required'] == true` is always false** (String vs bool), and `"0"` is non-empty so it survives a truthiness or null check. Every network-only voice classifies as offline-safe, and the probe reports a voice pool that does not exist offline.
- **Splitting `features` on `,` or a space.** It is TAB-separated. `notInstalled` never matches, half-downloaded voices pass the filter, and the phrase you swear you heard was a substituted voice.
- **Not checking `setVoice == 1`.** `result.success(0)`, never `result.error` — no throw, no exception, and Android returns **1 (success)** for a `notInstalled` voice anyway, then substitutes a different one. You will A/B an engine you did not select and record the result under the wrong name.
- **Trusting `speak` returning 1 as proof of audio.** It is not. No hook captures PCM from Android `TextToSpeech`. Listen to every single utterance; do not batch-run and read logs.
- **Timing the callback instead of the sound.** The engine's start callback can fire before audio reaches the speaker. Cross-check with a recording at least once per device.
- **Warming the engine on the cold-start path and measuring an ANR.** TTS binding runs binder IPC and voice deserialization synchronously on the main thread inside `OnInitListener`. If your probe warms up before the first frame, your latency numbers include a stall the real app will not have. Warm after the first frame, unawaited, then measure.
- **Using `.ambient` from the `flutter_tts` README example.** The hardware silent switch mutes it and you record a silent device as an engine failure.
- **Non-blind A/B.** You know which is Reed. Participants read your face. Randomise and stay out of the room, or the result is a compliment, not data.
- **Asking "which sounds better".** Nicer is not the bar. Willingness to let it speak for you, to a stranger, is.
- **Moving the threshold after the sessions.** This is the trap that actually kills the project — quietly, later. Sunk cost makes a marginal result look like a pass. Write the number down first.
- **Treating "bundle a neural engine" as a small change.** +55MB, plus battery and thermal cost on the cheapest phone, plus a store listing that now has to explain its size. It is a different product.
- **Letting probe code leak into `lib/`.** It has no `SpeakOutcome`, no return-code discipline worth keeping, and no tests. Throw it away. The real seam is E01-T01's job.

## Files

- A throwaway Flutter app outside this repo (e.g. `~/scratch/tts_probe/`) — created and discarded. Nothing under `/Users/zakariafatahi/50-apps-challenge/Offline-AAC/lib/` or `/Users/zakariafatahi/50-apps-challenge/Offline-AAC/test/` changes.
- `/Users/zakariafatahi/50-apps-challenge/Offline-AAC/epics/E00-de-risking/T03-tts-quality-probe-on-a-cheap-android.md` — this task, updated with the results table and the verdict.

## Done when

Ten real phrases have been spoken by stock TTS on a $120-150 Android phone and on a compact-voice-only device, measured for latency and return codes, blind-A/B'd against the incumbent with five people from E00-T02, and a written PROCEED or FAIL verdict exists against a threshold that was recorded before the first session.
