# E10-T03 — The manual device checklist

| | |
|---|---|
| **Epic** | E10 — Verification |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E04-T04 |
| **Blocks** | E11-T04 |

**Skills:** `reed-manual-checklist` · `diagnosing-tile-silence` · `reed-speech-service`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Four of the highest-severity failures in this app are unreachable by every automated means: `.ambient` muting on the hardware silent switch, the engine reporting success while emitting no audio, the Quick Settings tile speaking a stale phrase, and Switch Access focus traps. Every one of them ends with a person mid-shutdown tapping a tile and getting nothing, and there is no telemetry — a user who cannot speak does not file a bug report. The Android emulator ships no TTS engine, so CI can never verify speech at all; no API on either platform captures synthesized PCM, so "audio actually came out" is unassertable forever. This checklist is the deliberate replacement for tests that **cannot exist**, not a placeholder for tests not yet written.

## Scope

Write `CHECKLIST.md` at the repo root, tracked in git. Tick a fresh copy of it before every tag. Never tag from memory of having "basically done this last time."

### The header the sheet must carry

Device model, OS version, build/tag, date, tester. When a check fails, that header is the entire reproduction context that exists.

### The hardware rules — state them at the top of the sheet

| Rule | Why |
|---|---|
| A **physical phone**. Never an emulator. | The emulator has no TTS engine. Everything below is about audio. |
| A **cheap** Android device — budget silicon, ~2GB RAM — not a flagship. | The audience is cost-constrained. That IS the target hardware, not a degraded case. A 12MP image × 12 tiles OOM-kills a 2GB phone and the kill is permanently invisible; downscaling at import to ≤512px is what prevents it, and only this device proves it. |
| **Ringer switch OFF / silent mode ON for the whole pass.** | Silent mode is the default state of a person having a bad day in public. Testing with the ringer on hides the top-severity bug. |
| The **release** build, signed as shipped. | Obfuscation and split-debug-info only manifest in release. |
| One device-farm run is worth zero. | Farm images are the same TTS-poor images and no farm asserts audio. One real phone strictly dominates. |

### Section order — do not reorder

Cheapest-to-set-up first, front-loading the class that ends in silence. Sections 5–7 are destructive; doing them early means redoing 1–4.

1. **Audio** — the silent-failure class. Everything else is cosmetic if the app does not speak.
2. **Screen reader traversal** — same quiet room, same device state.
3. **Switch Access / Switch Control** — the only verification that will ever exist. Do it while the accessibility services are already on.
4. **Scaling** — a system-settings change, so batch it.
5. **Native surfaces** — needs force-stop, which destroys the state above.
6. **Data** — needs sideloading the previous release, which destroys the install.
7. **Crash log** — needs a deliberate crash, which destroys the run.

### 1. Audio — every box with the reason on the line

- [ ] **Silent mode ON → tap a tile → it speaks.** If it goes quiet, the audio session category is `.ambient` rather than `.playback`. The Dart test can only assert *the code passed `.playback` to the wrapper* — a value-level assertion, not the real session category. Only the ear resolves it.
- [ ] **Airplane mode ON → tap every tile.** Catches a `network_required` voice slipping through `voice_filter`. Android sends that flag as the **string** `"1"`/`"0"`; online, a bad voice works fine, so airplane mode is the only honest test.
- [ ] **Select each offered voice in settings, then tap a tile — hear each one.** Two traps: `setVoice` returns **0** on a name it cannot find (`result.success(0)`, never throws — the code must check `== 1`); and a voice carrying `notInstalled` makes `setVoice` return **1 (success)** while synthesis errors or silently substitutes a different voice. The return-value check does not catch the second. Features arrive **tab-separated**.
- [ ] **Uninstall or disable the TTS engine entirely → launch → tap.** Must produce a **visible** error. Never silence. Roughly 4% of devices have no usable engine and are permanently in this state.
- [ ] **Music playing → speech ducks it → music resumes.**
- [ ] **Incoming call during speech → speech stops; after the call ends the app still speaks.** The "still speaks after" half is the one that regresses: a focus request never re-acquired leaves the app permanently mute with no error anywhere.
- [ ] **Bluetooth headphones connected → speech routes to them.**
- [ ] **Yank the Bluetooth headphones mid-utterance.** The user is in a room with people and the phrase must not vanish. No API tests a route change under way.
- [ ] **First tap after a cold launch speaks.** TTS bind latency reads as silence to a person who is not going to tap twice — binder IPC and voice deserialization run synchronously on the main thread inside `OnInitListener`. The warm-up runs from `addPostFrameCallback`, never awaited. If the first tap of a cold start feels dead, the warm-up regressed.

### 2. Screen reader

The automated suite already pins traversal order, the display-label-not-vocalization rule, and the button role. This section verifies what it cannot.

- [ ] **Double-tap a tile under TalkBack → audio actually heard.**
- [ ] **No surface is a focus trap.** Every mode — the type-to-speak field, show-text mode, edit mode — exitable using **only** the screen reader. A trap in edit mode locks a non-speaking person out of their own board.
- [ ] **Empty slots are not announced as buttons.** Twelve buttons where three do nothing wastes scan steps in a crisis.
- [ ] **Google's Accessibility Scanner run on the grid screen.** It is an `AccessibilityService` reading the framework's virtual node tree — human-driven and on-device, so it lives here, never in CI. Expect a small minority of real issues: the framework ships four machine-checkable guidelines and one is known-broken. A clean scan is a tripwire that did not trip, not evidence.

iOS boxes (mark N/A on an Android-only pass, do not delete):

- [ ] TTS output and VoiceOver do not deadlock each other.
- [ ] Denying Personal Voice permission falls back **audibly**, not silently.

### 3. Switch Access / Switch Control

**No automation exists for this. None will.** No API simulates scanning, group selection, or point scanning. Traversal order is a weak proxy: point scanning is coordinate-based and has no order at all, group selection is a nested binary narrowing, and scanning targets only *actionable* elements while semantics traversal enumerates non-actionable nodes too. These boxes are the entire body of evidence.

- [ ] Every tile reachable by scanning, in an order matching the traversal test.
- [ ] The scan highlight is **visible against every tile colour**, including high contrast mode. The palette is flat, opaque, dyed-paper chips with a fine keyline and no shadow — a highlight relying on elevation to read disappears here, and a person who cannot see the highlight cannot select.
- [ ] Edit mode exitable with **only** the switch.
- [ ] The text field exitable with **only** the switch — text fields are the classic trap.
- [ ] iOS point scanning can hit every tile.

### 4. Scaling

- [ ] System font size at maximum **+ Display Zoom + Bold Text**: no tile text clipped, layout intact, show-text mode still readable. The unit suite asserts text grows past 1.8× at `TextScaler.linear(2.0)` and that every tile stays ≥76×76 dp at 200% on the smallest phone — that catches a clamp, not a clip on real hardware with a real font. At 200%+ being wrong is total failure, not cosmetic: the user cannot read their own tiles.

### 5. Native surfaces

The Quick Settings `TileService` runs with **no Flutter engine** — that is the point; it is the fastest path to speech in the product. **Zero Dart coverage, by design.** Checked here or never.

- [ ] Add the tile to the shade, **force-stop the app**, tap → speaks.
- [ ] Edit the phrase in-app, **force-stop**, tap → speaks the **new** phrase. This is the one that finds real bugs: it catches a break in the storage contract between Dart and Kotlin, which breaks quietly and green — an in-memory preference mock has a fake mutate a fake; `SharedPreferencesAsync` is backed by Jetpack DataStore, which Kotlin's `getSharedPreferences(...)` reads nothing from; and the legacy API prefixes every key with `flutter.`, so a native `getString("phrase")` returns null. The app owns a versioned JSON file to escape all three, and this check proves the file is actually the file being read.
- [ ] Tile with the **screen locked** → speaks, or prompts unlock predictably. Never silently does nothing.

### 6. Data

A hand-curated board is months of someone's phrases. Irreplaceable, unmergeable. It is their voice.

- [ ] **Install the previous release, create and edit tiles, upgrade in place → every board intact.** This is the real migration test; the schema-shape check in CI is blind to rows and passes green on a migration that copies zero of them.
- [ ] **Restore previous board** in settings recovers the pre-migration backup.
- [ ] **Phone-migration rehearsal: export on device A, wipe or use device B, import.** Offline plus no account means no cloud restore — six months of curated phrases die on a phone upgrade unless export/import genuinely works, and that is the loss of the accommodation, not a lost preference. Rehearse it as the user would: through the share sheet, to whatever they actually use.
- [ ] **Feed import a truncated file and a hand-corrupted file** → visible error, board not wiped. Import is the only place untrusted input enters the app.

### 7. Crash log

The only line of sight into the field that will ever exist, which makes it load-bearing infrastructure.

- [ ] Trigger a known crash in a debug build and export the log.
- [ ] **The stack trace has readable Dart function names.** Hex offsets mean `--obfuscate` or `--split-debug-info` crept into the build and the only field signal this app has is dead — while every test still passes.
- [ ] **The exported log contains no vocalization text.** The user emails this file to a stranger. Leaking "I need to leave, I'm not able to talk right now" from a privacy-promising app is a betrayal, not a bug.

### Out of scope

- Any attempt to automate the Switch Access, `.ambient`, silent-audio, or QS-tile-staleness checks. They are structurally unautomatable; a test that appears to cover them is a lie that removes the check.
- Device-farm configuration. Farm images have the same TTS problem and no farm asserts audio.
- Writing the app code the checks exercise. This task produces the sheet and one verified run of it.

## Acceptance criteria

- [ ] `CHECKLIST.md` exists at the repo root and is tracked: `git ls-files --error-unmatch CHECKLIST.md` exits 0.
- [ ] The sheet has a fill-in header with device model, OS version, build/tag, date, tester.
- [ ] The sheet states the five hardware rules, including "physical phone", "cheap device ~2GB RAM", "ringer switch OFF for the whole pass", and "release build, signed as shipped".
- [ ] Sections appear in exactly the order Audio → Screen reader → Switch Access → Scaling → Native surfaces → Data → Crash log, with a note that 5–7 are destructive.
- [ ] Every box listed in Scope above is present as a `- [ ]` checkbox, each carrying its one-line reason on the same line.
- [ ] A full pass is completed on a physical, cheap Android device in a release build with silent mode on; the filled-in copy is attached to the release, and the header names the actual device and OS version (not "Pixel emulator", not blank).
- [ ] Any failed box has a filed task id written next to it; a tag never ships with an un-triaged failed box.

## Traps

- **Running the pass with the ringer on.** Silent mode is the default state of the user this app is for. With the ringer on, `.ambient` looks identical to `.playback` and the top-severity bug in the product ships.
- **Running it on an emulator or a flagship.** The emulator has no TTS engine, so the audio section is vacuous. A flagship hides the OOM kill that ≤512px downscaling exists to prevent — and that kill is permanently invisible without telemetry.
- **Running it on a debug build.** Obfuscation and split-debug-info only manifest in release, so the crash-log section proves nothing.
- **Substituting a device-farm run.** Farm images are the same TTS-poor images and no farm asserts audio. It is worth zero here.
- **Doing sections 5–7 first.** Force-stop, sideloading the previous release, and a deliberate crash each destroy the state sections 1–4 depend on.
- **Ticking the voice section without listening to each voice.** `setVoice` returning **1** for a `notInstalled` voice is exactly the case the return-value check cannot see. Reading the settings list is not the check; hearing each voice is.
- **Testing offline voices while online.** A `network_required` voice works fine online. Only airplane mode is honest about it.
- **Skipping "still speaks after the call ends".** The stop half rarely regresses; the re-acquire half does, and it leaves the app permanently mute with no error anywhere.
- **Treating a clean Accessibility Scanner run as evidence.** It ships four machine-checkable guidelines and one is known-broken. It is a tripwire that did not trip.
- **Treating the Switch Access boxes as redundant with the traversal test.** Point scanning is coordinate-based with no order at all; scanning targets only actionable elements. The traversal test is a weak proxy, not coverage.
- **Judging the scan highlight on a bright screen at a good angle.** The palette is flat opaque chips with a fine keyline and no shadow. Check every tile colour, and high contrast mode.
- **Ticking the QS tile after only check 1.** Check 1 passes on a broken Dart↔Kotlin storage contract. Only "edit the phrase → force-stop → tap → hears the *new* phrase" finds it.
- **Ticking the migration box on a fresh install.** You must install the *previous* release, create real tiles, and upgrade in place. A fresh install has no rows to lose, and the CI shape check is blind to rows.
- **Testing export/import over adb pull.** Rehearse it through the share sheet to whatever the user actually uses; adb is not the path that breaks.
- **"We basically did this last time."** Tick a fresh copy every tag. A sheet ticked from memory is a sheet that verified nothing.

## Files

- Creates `CHECKLIST.md` (repo root, tracked).
- Creates the filled-in copy attached to the release run (per-tag, not committed unless the release process says otherwise).
- Changes nothing under `lib/`. Failures found here become their own tasks.

## Done when

`CHECKLIST.md` is committed at the repo root and one full pass of it has been ticked off on a physical, cheap Android device in a signed release build with the ringer switch off, with every failed box carrying a filed task id.
