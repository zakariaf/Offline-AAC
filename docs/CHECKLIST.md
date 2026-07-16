# Pre-release device checklist

The suite stands in for telemetry; this sheet stands in for the tests that
**cannot exist**. The emulator ships no TTS engine and no API on either platform
captures synthesized PCM, so "audio came out" is unassertable forever. Everything
here is checked by a human on hardware, or it is not checked at all.

**Tick a FRESH copy of this sheet before every tag.** Never tag from memory of
having "basically done this last time" — that is how `.ambient` ships.

## This run

| | |
|---|---|
| Device model | ____________________ (real hardware, not "Pixel emulator") |
| OS version | ____________________ |
| Build / tag | ____________________ |
| Date | ____________________ |
| Tester | ____________________ |

When a check fails, this header is the entire reproduction context that exists.
Write a filed task id next to any failed box. **A tag never ships with an
un-triaged failed box.**

## The five hardware rules

| Rule | Why |
|---|---|
| A **physical phone**, never an emulator. | The emulator has no TTS engine; everything below is about audio. |
| A **cheap** device — budget silicon, ~2 GB RAM — not a flagship. | The audience is cost-constrained; that IS the target hardware. A 12 MP image × 12 tiles OOM-kills a 2 GB phone and the kill is permanently invisible; only this device proves the ≤512px import downscale prevents it. |
| **Ringer switch OFF / silent mode ON for the whole pass.** | Silent mode is the default state of a person having a bad day in public. Testing with the ringer on hides the top-severity bug. |
| The **release** build, signed as shipped. | Obfuscation and split-debug-info only manifest in release. |
| One device-farm run is worth zero. | Farm images are the same TTS-poor images and no farm asserts audio. One real phone strictly dominates. |

## Section order — do not reorder

Cheapest-to-set-up first, front-loading the class that ends in silence.
**Sections 5–7 are DESTRUCTIVE** (force-stop, sideload, deliberate crash); doing
them early means redoing 1–4.

---

## 1. Audio — the silent-failure class

Everything else is cosmetic if the app does not speak.

- [ ] **Silent mode ON → tap a tile → it speaks.** If it goes quiet, the audio session is `.ambient` not `.playback`. The unit test can only assert the code *passed* `.playback` to the wrapper — a value, not the real session category. Only the ear resolves it.
- [ ] **Airplane mode ON → tap every tile.** Catches a `network_required` voice slipping through `voice_filter`. Android sends the flag as the **string** `"1"`/`"0"`; online a bad voice works fine, so airplane mode is the only honest test.
- [ ] **Select each offered voice in settings, then tap a tile — hear each one.** `setVoice` returns **0** on a name it cannot find (`result.success(0)`, never throws — code must check `== 1`); and a `notInstalled` voice makes `setVoice` return **1** while synthesis errors or silently substitutes another. Features arrive **tab-separated**.
- [ ] **Uninstall / disable the TTS engine → launch → tap.** Must produce a **visible** error, never silence. ~4% of devices are permanently in this state.
- [ ] **Music playing → speech ducks it → music resumes.**
- [ ] **Incoming call during speech → speech stops; after the call the app still speaks.** The "still speaks after" half regresses: a focus request never re-acquired leaves the app permanently mute with no error anywhere.
- [ ] **Bluetooth headphones connected → speech routes to them.**
- [ ] **Yank the Bluetooth headphones mid-utterance** → the phrase must not vanish. No API tests a route change under way.
- [ ] **First tap after a COLD launch speaks.** TTS bind latency reads as silence to someone who will not tap twice; warm-up runs from `addPostFrameCallback`, never awaited. A dead first tap means the warm-up regressed.

## 2. Screen reader

The suite already pins traversal order, display-label-not-vocalization, and the
button role (`test/ui/a11y_test.dart`). This verifies what it cannot.

- [ ] **Double-tap a tile under TalkBack → audio actually heard.**
- [ ] **No surface is a focus trap.** The type-to-speak field, show-text mode, and edit mode each exitable using **only** the screen reader. A trap in edit mode locks a non-speaking person out of their own board.
- [ ] **Empty slots are not announced as buttons** in speak mode. (In edit mode an empty slot IS a button — the "Add phrase" +.)
- [ ] **Google's Accessibility Scanner run on the grid screen** and on edit mode. Human-driven, on-device — never in CI. A clean scan is a tripwire that did not trip, not evidence.

iOS boxes (mark **N/A** on an Android-only pass, do not delete):

- [ ] TTS output and VoiceOver do not deadlock each other.
- [ ] Denying Personal Voice permission falls back **audibly**, not silently.

## 3. Switch Access / Switch Control

**No automation exists for this. None will.** No API simulates scanning, group
selection, or point scanning. These boxes are the entire body of evidence.

- [ ] Every tile reachable by scanning, in an order matching the traversal test.
- [ ] The scan highlight is **visible against every tile colour, including high contrast**. The palette is flat, opaque dyed-paper chips with a fine keyline and no shadow — a highlight relying on elevation disappears here.
- [ ] **Edit mode exitable with only the switch**, including reaching Move / Hide / **Remove** and the empty-slot + to add a phrase (the board ships full, so Remove frees a slot).
- [ ] **The text field exitable with only the switch** — text fields are the classic trap.
- [ ] iOS point scanning can hit every tile.

## 4. Scaling

- [ ] **System font size at maximum + Display Zoom + Bold Text**: no tile text clipped, layout intact, show-text mode still readable. The suite asserts text grows past 1.8× and every tile stays ≥76×76 dp at 200% on the smallest phone — that catches a *clamp*, not a *clip* on real hardware with a real font. At 200%+ being wrong is total failure: the user cannot read their own tiles.

---

## 5. Native surfaces — DESTRUCTIVE (force-stop)

The Quick Settings `TileService` runs with **no Flutter engine** — the fastest
path to speech in the product. **Zero Dart coverage, by design.**

- [ ] Add the tile to the shade, **force-stop the app**, tap → speaks.
- [ ] Edit the phrase in-app, **force-stop**, tap → speaks the **new** phrase. This finds real bugs: it proves the versioned JSON file (not a `flutter.`-prefixed pref, not a DataStore-backed `SharedPreferencesAsync` Kotlin cannot read) is the file being read.
- [ ] Tile with the **screen locked** → speaks, or prompts unlock predictably. Never silently does nothing.

## 6. Data — DESTRUCTIVE (sideload / wipe)

A hand-curated board is months of someone's phrases. Irreplaceable, unmergeable.

- [ ] **Install the previous release, create/edit tiles, upgrade in place → every board intact.** The real migration test; CI's schema-shape check is blind to rows.
- [ ] **Restore previous board** in settings recovers the pre-migration backup.
- [ ] **Phone-migration rehearsal: export on device A, wipe or use device B, import** through the share sheet. Offline + no account means no cloud restore — this is the whole durability story.
- [ ] **Feed import a truncated file and a hand-corrupted file** → visible error, board **not** wiped. Import is the only place untrusted input enters the app.

## 7. Crash log — DESTRUCTIVE (deliberate crash)

The only line of sight into the field that will ever exist.

- [ ] Trigger a known crash and export the log from settings.
- [ ] **The stack trace has readable Dart function names.** Hex offsets mean `--obfuscate` / `--split-debug-info` crept in and the only field signal this app has is dead — while every test still passes.
- [ ] **The exported log contains no vocalization text.** The user emails this file to a stranger. Leaking "I need to leave, I'm not able to talk right now" is a betrayal, not a bug. (The suite proves redaction on injected phrases; this proves it on a real crash.)
