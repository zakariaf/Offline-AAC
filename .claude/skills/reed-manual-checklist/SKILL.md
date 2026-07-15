---
name: reed-manual-checklist
description: On-device pre-release pass — physical phone, ringer off, release build. Covers .ambient vs .playback silencing, setVoice returning 1 with no audio, Bluetooth yanked mid-utterance, TalkBack and Switch Access focus traps, 200% TextScaler clipping, the engineless Quick Settings TileService, export/import, and obfuscated crash logs. Use when tagging or preparing a release, verifying a build on hardware, touching flutter_tts or AVAudioSession, or asking what cannot be tested automatically.
---

# The manual pre-release pass

This is not a chore, and it is not a placeholder for tests not yet written. It is
the deliberate replacement for tests that **cannot exist**. The Android emulator
ships no TTS engine, so CI can never verify speech at all. No API on either
platform captures synthesized PCM, so "audio actually came out" is unassertable
forever. Switch Access has no automation and no vendor support statement, so this
pass is the only verification it will ever get.

Four of the highest-severity failures in this app are unreachable by every
automated means: **`.ambient` muting on the hardware silent switch**, **the
engine reporting success while emitting no audio**, **the Quick Settings tile
speaking a stale phrase**, and **Switch Access focus traps**. Every one of them
ends with a person mid-shutdown tapping a tile and getting nothing. There is no
telemetry and never will be — a user who cannot speak does not file a bug report.
If this pass does not catch it, nobody catches it.

Copy `assets/CHECKLIST.md` into the repo as a tracked `CHECKLIST.md`, and tick a
fresh copy of it off before every tag. Never tag from memory of having "basically done this last time."

## The hardware

| Rule | Why |
|---|---|
| A **physical phone**. Never an emulator. | The emulator has no TTS engine. Everything below is about audio. |
| A **cheap** Android device — budget silicon, ~2GB RAM — not a flagship. | The audience is cost-constrained. That IS the target hardware, not a degraded case. A 12MP image × 12 tiles OOM-kills a 2GB phone and the kill is permanently invisible; downscaling at import to ≤512px is what prevents it, and only this device proves it. |
| **Ringer switch OFF / silent mode ON for the whole pass.** | Silent mode is the default state of a person who is having a bad day in public. Testing with the ringer on hides the top-severity bug. |
| The **release** build, signed as shipped. | Obfuscation and split-debug-info only manifest in release. |
| One device farm run is worth zero here. | Farm images are the same TTS-poor images and no farm asserts audio. One real phone strictly dominates. |

Fill in device, OS version and date at the top of the sheet. When a check fails,
that header is the entire reproduction context that exists.

## Order, and why it is this order

Run the sections in the checklist's order. It is cheapest-to-set-up first, and it
front-loads the class that ends in silence:

1. **Audio** — the silent-failure class. Everything else is cosmetic if the app
   does not speak.
2. **Screen reader traversal** — TalkBack/VoiceOver, which needs the same quiet
   room and the same device state.
3. **Switch Access / Switch Control** — the only verification that will ever
   exist. Needs hardware or the on-screen switch set up; do it while the
   accessibility services are already on.
4. **Scaling** — a system-settings change, so batch it.
5. **Native surfaces** — needs force-stop, which destroys the state above.
6. **Data** — needs sideloading the previous release, which destroys the install.
7. **Crash log** — needs a deliberate crash, which destroys the run.

Sections 5–7 are destructive. Doing them early means redoing 1–4.

## Audio: what each check actually catches

**Silent switch / silent mode, tile still speaks.** If it goes quiet, the audio
session category is `.ambient` rather than `.playback`. This is the single
top-severity bug in the product: the hardware switch silences a person's voice.
It is easy to reintroduce because the plugin's own README example uses
`.ambient`, so it reads like the blessed configuration. A Dart test can only
assert *that the code passed `.playback` to the wrapper* — a value-level
assertion, not the real session category. Only the ear resolves it.

**Airplane mode on, tap every tile.** Catches a `network_required` voice slipping
through the filter. Android sends that flag as the **string** `"1"`/`"0"`, not a
bool — so a naive `raw['network_required'] == true` is always false, and `"0"` is
a non-empty string that survives a truthiness check. The failure silently inverts
the safety property in the direction that hurts: the app keeps a network voice
and goes silent offline. Airplane mode is the only honest test of it, because
online the bad voice works fine.

**Select each offered voice in settings, then tap a tile.** Two distinct traps.
`setVoice` returns **0** on a name it cannot find — `result.success(0)`, not
`result.error`, so it never throws; the code must check `== 1`. And a voice
carrying the `notInstalled` feature makes `setVoice` return **1 (success)** while
synthesis either errors or silently substitutes a different voice. The
return-value check does not catch that one. Features arrive **tab-separated**.
Hearing each voice is the only proof.

**Uninstall or disable the TTS engine entirely, then launch and tap.** Must
produce a **visible** error. Never silence. Roughly 4% of devices have no usable
engine, and this is the state they are permanently in.

**Music playing → speech ducks it and music resumes.** **Incoming call during
speech → speech stops, and the app still speaks after the call ends.** Audio
focus denial during a call is manual-only; the "still speaks after" half is the
one that regresses, because a focus request that is never re-acquired leaves the
app permanently mute with no error anywhere.

**Bluetooth headphones connected → speech routes to them.** Then **yank them
mid-utterance**: the user is in a room with people and the phrase must not
vanish. No API tests a route change under way.

**First tap after a cold launch.** TTS bind latency reads as silence to a person
who is not going to tap twice — binder IPC and voice deserialization run
synchronously on the main thread inside the engine's init callback. Warm the
engine from a post-frame callback and never await it. If the very first tap of a
cold start feels dead, the warm-up regressed.

## Screen reader

The automated suite already pins traversal order, the display-label-not-
vocalization rule, and the button role. This pass verifies the things it cannot:
that **audio was actually heard on double-tap**, and that **no surface is a focus
trap**. Every mode the user can enter — the type-to-speak field, show-text mode,
edit mode — must be exitable using only the screen reader. A trap in edit mode
means a non-speaking person is locked out of their own board.

Check that empty slots are **not** announced as buttons. Twelve buttons where
three do nothing wastes scan steps in a crisis.

On iOS, verify that TTS output and VoiceOver do not deadlock each other, and that
denying Personal Voice permission falls back audibly rather than silently.

Finish with **Google's Accessibility Scanner** on the grid screen. It works — it
is an `AccessibilityService` and reads the framework's virtual node tree — but it
is human-driven and on-device, so it lives here, never in CI. Expect a small
minority of real issues from it: the framework ships four machine-checkable
guidelines and one is known-broken. Treat a clean scan as a tripwire that did not
trip, not as evidence.

## Switch Access / Switch Control

**No automation exists for this. None will.** No API simulates scanning, group
selection, or point scanning. Traversal order is a weak proxy: point scanning is
coordinate-based and has no order at all, group selection is a nested binary
narrowing, and scanning targets only *actionable* elements while semantics
traversal enumerates non-actionable nodes too.

So these boxes are the entire body of evidence:

- Every tile reachable by scanning, in an order matching the traversal test.
- The scan highlight is **visible against every tile colour**, including high
  contrast mode. The palette is flat, opaque, dyed-paper chips with a fine
  keyline and no shadow — a highlight that relies on elevation to read will
  disappear here, and the person who cannot see the highlight cannot select.
- Edit mode exitable with **only** the switch.
- The text field exitable with **only** the switch — text fields are the classic
  trap.
- iOS point scanning can hit every tile.

## Scaling

System font size at maximum, plus Display Zoom, plus Bold Text: no tile text
clipped, layout intact, show-text mode still readable. The unit suite asserts
text grows past 1.8× at `TextScaler.linear(2.0)` and that every tile stays
≥76×76 dp at 200% on the smallest phone — that catches a clamp, not a clip on
real hardware with a real font. Someone will eventually clamp `TextScaler` to
keep the fixed grid tidy. At 200%+ being wrong is total failure, not a cosmetic
bug: the user cannot read their own tiles.

## Native surfaces

The Quick Settings `TileService` runs with **no Flutter engine** — that is the
point; it is the fastest path to speech in the product. It also means no Flutter
test of any level can reach it. **Zero Dart coverage, by design.** It is checked
here or never.

Three checks, and the second is the one that finds real bugs:

1. Add the tile to the shade, **force-stop the app**, tap → speaks.
2. Edit the phrase in-app, **force-stop**, tap → speaks the **new** phrase.
   This catches a break in the storage contract between Dart and Kotlin. That
   contract breaks quietly and in ways a green test will not reveal: an
   in-memory preference mock has a fake mutate a fake; the modern async
   preferences API is backed by Jetpack DataStore, which Kotlin's
   `getSharedPreferences(...)` reads nothing from; and the legacy API prefixes
   every key with `flutter.`, so a native `getString("phrase")` returns null. The
   app owns a versioned JSON file precisely to escape all three — this check is
   what proves the file is actually the file being read.
3. Tile with the **screen locked** → speaks, or prompts unlock predictably. Never
   silently does nothing.

## Data

A hand-curated board is months of someone's phrases. It is irreplaceable and
unmergeable. It is their voice.

- **Install the previous release, create and edit tiles, then upgrade in place.**
  Every board intact. This is the real migration test; the schema-shape check in
  CI is blind to rows and passes green on a migration that copies zero of them.
- **Restore previous board** in settings recovers the pre-migration backup.
- **Phone-migration rehearsal: export on device A, wipe or use device B, import.**
  Offline plus no account means no cloud restore — six months of curated phrases
  die on a phone upgrade unless export/import genuinely works, and that is the
  loss of the accommodation, not a lost preference. Rehearse it as the user
  would: through the share sheet, to whatever they actually use. Import is the
  only place untrusted input enters the app; feed it a truncated and a
  hand-corrupted file too and confirm a visible error rather than a wiped board.

## Crash log

It is the only line of sight into the field that will ever exist, which makes it
load-bearing infrastructure.

- Trigger a known crash in a debug build and export the log.
- **The stack trace must have readable Dart function names.** Hex offsets mean
  `--obfuscate` or `--split-debug-info` crept into the build and the only field
  signal this app has is dead — while every test still passes.
- **The exported log contains no vocalization text.** The user emails this file
  to a stranger. Leaking "I need to leave, I'm not able to talk right now" from a
  privacy-promising app is a betrayal, not a bug.
