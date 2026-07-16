# E08-T02 — The voice picker

| | |
|---|---|
| **Epic** | E08 — Settings |
| **Status** | Done |
| **Size** | M |
| **Depends on** | E04-T02, E08-T01 |
| **Blocks** | Nothing |

**Skills:** `reed-speech-service` · `reed-copy-voice` · `reed-a11y-coding`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

The voice is the user's voice. At least one documented user deliberately pitches a voice down to a child/teen register because an adult-sounding voice triggers age dysphoria — shipping an adult default and burying the control overrides exactly the need this control exists to serve. This audience skews trans and nonbinary and asked for middle-pitch options that neither Android's nor any free offline engine's voice set provides; pitch shifting is what is actually available, and the copy has to say so rather than let someone hunt for an androgynous voice that is not in the list. Get this wrong and the app speaks for someone in a voice that is not theirs, at the moment they cannot correct it out loud.

## Scope

A first-class section at the top of the settings screen — above theme, above tile count. Not a submenu, not an "Advanced" disclosure.

**Four controls plus a preview:**

| control | source | stored |
|---|---|---|
| Voice | `SpeechService.voices()` — already filtered by `offlineSafeVoices` (E04-T02) | `Voice` (`name` + `locale`) |
| Pitch | slider | double |
| Rate | slider | double |
| Volume | slider | double |
| Preview | button; speaks a fixed line through the current settings | — |

**The list is `voices()` and nothing else.** `offlineSafeVoices` has already dropped every voice where `networkRequired` is true or `features` contains `kFeatureNotInstalled` (the tab-separated `'notInstalled'` string off the wire). Do not re-filter, do not re-parse, do not add a "show all voices" toggle. A network voice in this list is a user tapping a tile in a dead zone and getting silence.

Do not import `package:flutter_tts` anywhere in this screen. Talk to `SpeechService` only — four methods (`speak`, `stop`, `getVoices`, `setVoice`) are the entire surface, keep it that way.

**No default voice is chosen for the user.** If nothing is stored, `speak()` returns `NoVoiceSelected(text)` and the speak screen shows the words — that path already exists and is correct. The picker's job is to make selection obvious and reachable, not to guess. Do not sort the list to float an "adult" or "natural" voice to the top; render engine order, or alphabetical by name — one rule, applied to all.

**Selection writes through the setVoice check.** Selecting a voice is the moment to find out it does not work, not the next shutdown:

```dart
// Selecting -> speak the preview line. The outcome is the validation.
final SpeakOutcome outcome = await _controller.previewWith(voice, pitch, rate, volume);
switch (outcome) {
  case SpokeAloud():
    // persisted, no confirmation copy, no praise, no snackbar
  case SpeakFailure(:final String logLine):
    _log.record('voice preview failed: $logLine', StackTrace.current);
    // inline, non-blocking, in-place under the row
}
```

Never `assert` the return code — stripped in release, green in every test, absent on the device.

**Preview text.** A fixed literal, adult register, no terminal ellipsis, curly apostrophe. Use the standing line the app already owns rather than inventing chirp: `I can’t talk right now but I’m okay.` Preview does barge-in: `stop()` before `speak()`, always — a re-tap means "say it again", never `if (_running) return`.

**Slider copy.** Names first, prose only where a name is insufficient.

```
✓  Pitch
✓  Rate
✓  Volume
```

Under the pitch slider, exactly one honest line — this is the sentence the task exists for:

```
Pitch shifts the voice you picked. It can’t make a voice that sits in the middle.
```

Not "we can't", not "unfortunately", not "may not", no exclamation, no apology, no ellipsis. State the fact. There is no next action to offer because there is no middle-pitch offline voice to offer, and inventing one ("try the female voice at low pitch") is the app guessing at somebody's gender.

**Error copy — the exact strings:**

```
✓  That voice isn’t installed. Pick another in settings.   → VoiceNotInstalled
✓  That voice isn’t available. Pick another.               → VoiceUnavailable
✓  The speech engine didn’t respond. Your words are on screen. → EngineTimedOut / EngineRejected
```

Engine codes, rejected voice ids, `setVoice returned 0` — log line only, never the surface.

**Zero voices** (no engine, or the engine has only network voices): render the list area with a statement, not a dialog, not an empty shrug. `No offline voices on this phone. Reed shows your words on screen instead.` This is a real state on real devices; it is not an error to apologise for.

**Accessibility, non-negotiable:**

- Every voice row is `Semantics(container: true, button: true, label: <display name>, ...)` around a `GestureDetector(behavior: HitTestBehavior.opaque)`. Not the vocalization, not the locale blob.
- The selected row's state goes through a non-colour channel — a `Semantics` `value`/`checked`, plus a visible non-colour mark. Colour-only selection is invisible under `invertColors` and Android's Grayscale mode.
- Sliders: `Slider` already carries semantics; give each a `label`. Do not build a custom-painted slider.
- Any `Icon`/`Image` gets a `semanticLabel` or `ExcludeSemantics`. No third option.
- `MediaQuery.boldTextOf(context)` honoured on voice names; no hardcoded `fontWeight` on user-facing text.
- No `withClampedTextScaling`, no `textScaleFactor`, no `FittedBox`, no `TextOverflow.ellipsis` on the pitch caption. Voice names are long (`en-gb-x-gbb-local`); let them wrap.
- `MediaQuery.highContrastOf(context)` may be read opportunistically; it is **always false on Android**, so gate nothing on it.

**Out of scope:** downloading or installing voices; deep-linking to Android TTS settings; per-tile voices; voice import; SSML; any pitch/rate preset ("child", "adult", "neutral") — presets are the app assigning someone a register.

## Acceptance criteria

- [ ] `flutter test test/ui/settings/voice_picker_test.dart` passes.
- [ ] A test with a fake `SpeechService` in `SpeechEnv.onlyNetworkVoices` asserts the picker renders **zero** voice rows and shows the no-offline-voices statement.
- [ ] A test in `SpeechEnv.onlyNotInstalledVoices` asserts zero voice rows.
- [ ] A test in `SpeechEnv.setVoiceReturnsZero`: selecting a voice renders `That voice isn’t available. Pick another.` inline and pushes **no route** (`find.byType(Dialog)` → `findsNothing`, `AlertDialog` → `findsNothing`).
- [ ] A test asserts every voice row with `isSemantics(isButton: true, label: <name>)` — not `containsSemantics`.
- [ ] A test asserts the selected row exposes selection through semantics, not only colour.
- [ ] Pumping the screen at `TextScaler.linear(2.0)` produces no overflow exception, with pitch caption and the longest fixture voice name present in full (`findsOneWidget` on the exact string).
- [ ] A test asserts preview ordering is exactly `['stop', 'speak']` on the fake, and `['stop', 'speak', 'stop', 'speak']` on two rapid taps.
- [ ] A source-grep test asserts no file under the picker's directory contains `package:flutter_tts`.
- [ ] Grep of the diff is clean for: `!` in a string · `.toUpperCase(` · `.toLowerCase(` · `'` in a user-facing literal · `Sorry` · `Oops` · `we ` · `just ` · `simply` · `Please` · `parent` · `caregiver` · `default voice`.
- [ ] `flutter analyze` reports zero issues; no `SpeakOutcome` switch in this task uses `default:` or `case _:`.
- [ ] Manual, on a physical Android device: select a voice, preview it, kill the app, relaunch — the same voice speaks.

## Traps

- **Re-filtering the list.** The filter already ran in `offlineSafeVoices`. Writing `voices.where((v) => !v.networkRequired)` here looks harmless and is a second, unaudited copy of a rule that has four documented wire-format traps — including that Android sends the string `'1'`/`'0'`, so `raw['network_required'] == true` is *always false*. One filter, one place, tested there.
- **Trusting `setVoice == 1`.** Android returns **1 (success)** for a voice carrying the `notInstalled` flag, then synthesis reports `ERROR_NOT_INSTALLED_YET` or silently substitutes a different voice. That is why `VoiceNotInstalled` exists as a separate variant. If the picker validates by return code alone, the user picks a voice, sees no error, and hears a stranger's voice — or nothing — hours later.
- **`onTap: () => service.speak(preview)`.** Caught by **no lint**: the arrow closure "returns" the Future so `discarded_futures` is satisfied, but the target type is `VoidCallback`, so the Future and its error are dropped. Route the preview through the controller's void `speakNow`-shaped method; do not hold a Future in a callback.
- **Wrapping preview in a Command / `if (_running) return`.** Swallows the second tap. A user re-tapping preview means "I need to hear that again."
- **A confirmation snackbar on selection.** `Voice set!` / `Great — that's your voice.` Praise implies a task performed for an evaluator. Picking a voice is not an achievement, and the preview already confirmed it audibly.
- **A modal on failure.** Ever. Errors are inline and non-blocking.
- **Sorting or badging the list toward "natural"/"adult"/"female"/"male" defaults.** Any ranking the app applies is the app having an opinion about how someone should sound.
- **Ellipsizing the voice name to fit the row.** Turns a 200% layout bug into an unreadable identifier; the fix is a wrapping row, not `TextOverflow.ellipsis`.
- **Softening the pitch caption.** "Pitch might not produce a fully neutral voice" is hedging — the app knows what the platform ships. The honest sentence is not a downer; it saves someone twenty minutes of hunting for a voice that does not exist.
- **A "test all voices" or bulk-preview button.** It fires `speak` in a loop, the outcomes get discarded, and it is the fastest known way to reintroduce the dropped-result hole.
- **Reading a stored voice id straight into the list selection.** Android garbage-collects voice data; the stored id may be gone. The startup re-resolve (`voices()` lookup, audible fallback) owns that. The picker renders what `voices()` returned and marks a stored id it cannot find as unselected — it does not render a phantom row for it.
- **Persisting on slider drag.** Writing settings on every `onChanged` frame hammers the DB. Persist on `onChangeEnd`; preview on `onChangeEnd` too, or a drag becomes a stutter of overlapping utterances.

## Files

- `lib/ui/settings/voice_picker.dart` — new; the section widget.
- `lib/ui/settings/settings_screen.dart` — changed; mount the picker as the first section.
- `lib/ui/settings/settings_strings.dart` — new or changed; all literals in this task, authored lowercase/sentence case, curly apostrophes, no transform.
- `test/ui/settings/voice_picker_test.dart` — new.
- `test/ui/settings/voice_picker_text_scale_test.dart` — new; the 200% pass.

## Done when

A user opens settings, sees the voice list first, picks a voice, hears it immediately at their pitch, and every way that can fail lands as one inline sentence they can act on.
