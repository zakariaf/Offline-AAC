# E00-T04 — Latency probe: time to first word

| | |
|---|---|
| **Epic** | E00 — De-risking |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E00-T03 |
| **Blocks** | Nothing |

**Skills:** `reed-speech-service` · `reed-app-startup`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A user taps a tile mid-shutdown. If the first word arrives half a second late they tap again, and again, and hand the phone over anyway. "Pre-render every tile to a WAV" has three contradictory positions behind it and zero measurement — nobody has ever put a stopwatch on `speak()` on a real device. Pre-rendering is a large, permanent architectural cost (audio files on disk, invalidation on every edit, a second playback path), and it is the wrong thing to pay if a singleton engine plus a post-frame warm-up already gets us there. This task replaces the argument with a number.

## Scope

Same throwaway app as E00-T03 — a `flutter_tts` scratch harness, **not** `lib/`. Nothing from this task ships. The output is a number and a decision.

**Measure.** Stopwatch from the call to `speak()` to the **first audio callback** — `setStartHandler`, i.e. the engine reporting synthesis has begun, not the `Future<Object?>` from `speak()` returning (that resolves when the call is dispatched, not when sound exists). Do not use `setProgressHandler` as the primary mark; use `setStartHandler` and note whether progress fires earlier or later on this device.

```dart
final sw = Stopwatch()..start();
_tts.setStartHandler(() => print('TTFW ${sw.elapsedMilliseconds}ms'));
await _tts.speak(text);
```

Run four conditions on a **real Android device** on current Android (not the emulator — the emulator's TTS engine is not the one users have):

1. **Cold process, first tap.** Force-stop the app, launch, tap immediately. This is the number that matters most.
2. **Cold process, second tap.** Same launch, tap again a few seconds later.
3. **Warm.** App has spoken several times already; steady state.
4. **Backgrounded and resumed.** App to background for ~60s, resume, tap.

At least 5 samples per condition. Record min / median / max per condition. Note the device model, Android version, and TTS engine + version (Settings → Accessibility → Text-to-speech output).

**If cold-first-tap latency is material, apply the mitigations in this order and re-measure after each.** Stop at the first one that lands the number.

1. **One synthesizer, alive as a singleton.** Construct `FlutterTts` exactly once for the process lifetime and hold it. Never construct one per tap, per widget, or per `build()`. Measure a per-tap-construction variant too — knowing the cost of the mistake is worth one run, because it is the mistake a future refactor will make.
2. **Pre-activate the audio session at launch**, not at first tap. Per `reed-speech-service`: `.playback` + `duckOthers` + `setSharedInstance`, **never `.ambient`** — `.ambient` lets the hardware silent switch mute the app, and flutter_tts's own README example uses `.ambient`, so the copy-paste ships the worst bug in the product. In the real app this sits in `main()` before `runApp`; in the probe, put it on the same relative position and measure whether moving it off the first-tap path changes anything.
3. **Fire a silent warm-up utterance at launch** — from `addPostFrameCallback`, unawaited, never blocking the first frame. Engine binding runs binder IPC and voice deserialization **synchronously on the main thread** inside `OnInitListener`; awaiting it on the cold-start path is an ANR, which is why `reed-app-startup` puts `warmUp()` after the first frame. `flutter_tts` exposes **no warm-up API** — try `speak(' ')` / a near-silent utterance, or `setVolume(0.0)` + speak + restore, and measure whether either actually binds the engine. If neither does, a platform channel that touches `TextToSpeech` directly may be required; scope that here as a finding, not as an implementation.

Also record, because it feeds the real startup ordering: how long does the warm-up itself take, and does firing it from `addPostFrameCallback` visibly delay the first frame? (It must not.)

**Only if warm-up demonstrably fails** — i.e. cold-first-tap TTFW stays high after all three mitigations — is pre-rendering considered. And then **only for the fixed tiles**, never the type-to-speak field, whose text is arbitrary by definition and cannot be pre-rendered even in principle. Write that constraint into the finding; a "pre-render everything" proposal is incoherent and must die at the first reading.

**Out of scope:** any change to `lib/`. Building the pre-render pipeline. Building the platform channel. Choosing a latency target before the numbers exist — measure first, then argue about what is acceptable. iOS.

## Acceptance criteria

- [ ] A table of TTFW min/median/max in ms for all four conditions, ≥5 samples each, from a named physical device + Android version + TTS engine version.
- [ ] The number is measured at `setStartHandler`, and the file records what the `speak()` Future's own resolution time was for comparison — showing they are not the same thing.
- [ ] A recorded number for the per-tap-construction variant vs. the singleton variant.
- [ ] Each mitigation applied has a before/after pair of numbers, not a claim.
- [ ] A one-line verdict, in the finding, of the form: *"Cold first tap is N ms with singleton + post-frame warm-up; pre-render is / is not needed."*
- [ ] If the verdict is "pre-render needed", the finding states explicitly that it covers fixed tiles only and that type-to-speak keeps live synthesis.
- [ ] Confirmed that the warm-up utterance produces **no audible sound** on the device (a speaking app on launch is a failure of the probe, not a curiosity).
- [ ] The probe app is not in `lib/` and nothing from it is imported by app code.

## Traps

- **Timing `await _tts.speak(text)` instead of the start callback.** The Future resolves when the platform call returns — the engine has not necessarily made a sound. This produces a flatteringly small number and the wrong decision. `setStartHandler` is the mark.
- **Measuring on an emulator.** The emulator's TTS engine and audio path are not the user's. The whole number is fiction.
- **Measuring only the warm case.** The warm number will look great and prove nothing; the tap that matters is the first one after a force-stop, on a phone that has been in a pocket. Force-stop between cold samples or you are measuring case 3 five times.
- **Constructing `FlutterTts` inside the probe's `build()` or the tap handler** and then reporting that as the baseline. That is the mistake case, and it will make cold latency look like an unavoidable platform cost when it is a code bug.
- **Awaiting warm-up in `main()`.** Binder IPC + voice deserialization on the main thread inside `OnInitListener` — this ANRs on the cold-start path. It is also the reason the app's own sequence puts `warmUp()` in `addPostFrameCallback`, unawaited. If the probe blocks here it measures a design the app will never ship.
- **`.ambient` on the audio session** because it was copied from the flutter_tts README. Then the ringer switch silences the user's voice, and the probe validated it.
- **The stored voice vanished, or is `notInstalled`.** A slow or absent first word may not be latency at all — Android GCs voice data, and `setVoice` returns **1 (success)** for a `notInstalled` voice while synthesis reports `ERROR_NOT_INSTALLED_YET` or silently substitutes another voice. Check `setVoice`'s return and the voice's `notInstalled` feature flag before believing any timing number. A missing `<queries>` / `android.intent.action.TTS_SERVICE` in the probe's manifest gives an empty voice list with only a `Log.d` on Android 11+ — that is zero words, not slow words.
- **Concluding "pre-render" from one bad device.** One phone with a broken engine build is a data point, not an architecture. If the number is bad, say which device produced it.
- **Scope creep into a real `SpeechService`.** This is a probe. `speak`/`stop`/`getVoices`/`setVoice` is the entire surface the real impl uses; do not start building the sealed `SpeakOutcome` here.
- **Letting the warm-up utterance be audible.** A blank string may be rejected; a space may be spoken as a pause; volume 0 may leak on some engines. Verify with ears, not with the API docs.

## Files

- Creates: the throwaway probe under the E00-T03 scratch app (a screen with a tap button, `setStartHandler` instrumentation, and the four launch variants toggleable).
- Changes: the scratch app's `AndroidManifest.xml`, if it does not already carry the `<queries>` / `TTS_SERVICE` intent.
- Changes: nothing under `lib/`.

## Done when

There is a measured time-to-first-word table from a real Android device for cold-first-tap, cold-second-tap, warm, and resumed, plus before/after numbers for the singleton, audio-session-at-launch, and silent-warm-up mitigations, ending in a one-line verdict on whether pre-rendering is needed at all.
