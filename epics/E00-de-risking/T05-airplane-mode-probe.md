# E00-T05 — Airplane-mode probe

| | |
|---|---|
| **Epic** | E00 — De-risking |
| **Status** | Not started |
| **Size** | XS |
| **Depends on** | E00-T03 |
| **Blocks** | Nothing |

**Skills:** `reed-speech-service` · `reed-privacy-claims`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Offline parity is the premise the whole product rests on: a person in shutdown, on a train, in a basement, with no signal, taps a tile and words come out. That premise is currently an assertion. Thirty minutes with a device in airplane mode converts it into a measured fact — and the measurement is what sets the ceiling on the privacy wording, because the approved sentence says we *"only select voices that declare they need no network"* and a claim must never exceed what was measured. If synthesis turns out to fail offline on this device with the filter on, everything downstream — the tile, the poster fallback, the store copy — is built on sand and we need to know now, not at review.

## Scope

Three subjects, one device, airplane mode ON for all of it. Answer each with an observation, not a belief.

**Setup (do this before switching airplane mode on):**

1. A real physical Android device. Not an emulator — emulators ship a stub or absent TTS engine and will produce a fake negative that costs a day.
2. Note and record the device model, Android version, TTS engine name and version (Settings → Accessibility → Text-to-speech output), and the selected language/voice. Every result below is only true *for this row*. One device is one data point, and the write-up must say so.
3. Install the E00-T03 probe app.
4. Install the incumbent AAC app you are comparing against.
5. Enable airplane mode. Verify Wi-Fi and mobile data are both actually off — airplane mode does not always kill Wi-Fi if it was on; toggle Wi-Fi off explicitly and confirm no connectivity (a browser load must fail).

**Subject 1 — the OS's own type-to-speak feature.** Its vendor documents nothing about offline behaviour, which is precisely why we measure. Drive the system's own text-to-speech surface (the Text-to-speech output settings screen has a text field and a "Play" preview; use whatever equivalent type-to-speak surface the device exposes). Type a sentence. Record: did audio come out, was it delayed, was it a different-sounding voice than online, or silence?

**Subject 2 — the incumbent.** Open the incumbent AAC app, tap a phrase, and use its type-to-speak field if it has one. Record the same three outcomes. This tells us whether offline TTS on this device class is solved, or whether every app in the category is quietly network-dependent.

**Subject 3 — the probe app from E00-T03, with the voice filter on.** This is the one that matters. `offlineSafeVoices` must be filtering — i.e. no voice with `networkRequired` and no voice carrying `kFeatureNotInstalled` ('notInstalled') is selectable. Then:

- Select a filtered voice, speak a sentence, record the result.
- Record the *size of the filtered list* offline versus with the network on. If the list shrinks in airplane mode, the engine is reporting voices differently by connectivity state and the filter is not the only thing gating us.
- Record what `setVoice` returned and what `speak` returned. `_ttsSuccess` is `1`; anything else is the interesting case. Note the value.
- Watch for the failure the return codes cannot see: `setVoice` returns **1** for a `notInstalled` voice and synthesis then either reports `ERROR_NOT_INSTALLED_YET` or **silently substitutes a different voice**. If the audio comes out in a voice you did not select, that is a positive detection, not a pass.

**Also record, because it is free while you are already here:** whether the engine returns `1` from `speak` with no audio at all. That is `SpeechEnv.reportedSuccessButSilent` — it has no Dart-side signal and is permanently a manual device check. This probe is one of the only places it can ever be observed.

**Write-up.** A short result note appended to the E00-T03 probe app's README (or its equivalent scratch note in the probe project). Four rows: subject, expected, observed, verdict. Plus the device/engine/version row. It must be readable by the person writing the store listing, because that person is you in a month and you will have forgotten.

**Out of scope:** iOS (the probe is Android-first, and the iOS asymmetry is a separate fact — iOS offers no OS-enforced network guarantee at all). Fixing anything found. Writing final store copy. Testing more than one device. Any code change to the probe app beyond what is needed to display the filtered voice list and the raw return codes.

## Acceptance criteria

- [ ] The result note exists in the E00-T03 probe project and records device model, Android version, TTS engine name + version, and the selected voice.
- [ ] It contains a yes/no answer for each of the three subjects: OS type-to-speak, incumbent, probe app with filter on.
- [ ] It records the filtered voice-list length offline and online, as two numbers.
- [ ] It records the literal integer returned by `setVoice` and by `speak` for the offline attempt.
- [ ] It states whether the voice heard matched the voice selected (the `notInstalled` substitution check).
- [ ] It states explicitly that the result is one device, one engine version — not a category claim.
- [ ] If the probe app produced no audio offline, the note says so plainly and the task is still complete. A negative result is the point of the probe.
- [ ] No sentence in the note upgrades *declare* to *guarantee* / *ensure* / *cannot*, and no sentence says "nothing leaves your device" or "100% offline".

## Traps

- **Emulator.** No real TTS engine. A fake negative that reads exactly like a real one, and you will spend a day chasing it. Physical device only.
- **Airplane mode does not turn off Wi-Fi.** On most Android builds, toggling airplane mode leaves Wi-Fi enabled if it was on, or lets the user re-enable it while still in airplane mode. If Wi-Fi is live, you measured nothing. Confirm with a failing browser load before you touch the apps.
- **Cached voice data reads as offline capability.** A network voice whose audio was recently synthesized may replay from cache and look offline-capable. Speak a *novel* sentence you have never spoken on this device. Not "hello".
- **Concluding one device is the category.** One device, one engine, one language. The note must carry that scope or it will be quoted back as if it were general.
- **The substitution failure looks like success.** `setVoice` returns 1 for a `notInstalled` voice, then the engine speaks in a different voice. Audio came out, so it reads as a pass. Listen to *which* voice.
- **Letting the result inflate the claim.** The strongest thing measurable here is: *this engine, this version, this voice, synthesized offline.* That does not license "Reed works offline everywhere", and it never licenses any claim about what the TTS engine does with the text — the engine runs in a **separate app, under its own UID, with its own INTERNET permission**, which Reed's manifest cannot constrain, inspect, or revoke. The measurement bounds the claim; it does not extend it.
- **Forgetting the manifest precondition.** Without `<queries><intent><action android:name="android.intent.action.TTS_SERVICE" /></intent></queries>`, Android 11+ package visibility hides the engine and the voice list comes back empty with only a `Log.d`. If the probe shows zero voices, check the manifest before concluding anything about airplane mode — you would be recording the wrong failure.
- **Doing the write-up from memory afterwards.** Record the numbers on the spot. `setVoice` returned "some non-1 thing, I think" is not a data point.

## Files

- Changes: the E00-T03 probe app's result note / README (append the airplane-mode result section).
- Creates: nothing in `lib/`. This task ships no product code.

## Done when

The probe project carries a dated, device-scoped note that answers — with observed return codes and heard audio, not assertions — whether the OS type-to-speak feature, the incumbent, and the filtered probe app each speak in airplane mode.
