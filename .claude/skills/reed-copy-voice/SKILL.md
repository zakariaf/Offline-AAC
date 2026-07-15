---
name: reed-copy-voice
description: Register and mechanics of user-visible strings Reed authors — lowercase chrome (theme, edit, show, settings), sentence case, curly apostrophes, no terminal period on tile labels, errors that state the fact then the next action, no apology or praise, no caregiver framing. Use when writing a Text() literal, semanticLabel, SnackBar, settings caption, onboarding or store text; when reaching for .toUpperCase(). Not for who the user is or whether a feature serves them.
---

# Reed — copy and voice

Every user-visible byte is product surface. Reed's copy is the first thing that tells an autistic adult with part-time speech loss whether the app thinks they are an adult. Get the register wrong and the feature work does not matter.

## The register, in one table

| rule | why |
|---|---|
| Second person, present, active | The user is doing the thing. Reed is not narrating them. |
| **The app never says "we"** | There is no "we" — no team behind glass, no account, no server. "We couldn't reach the voice" invents a party that does not exist. |
| No exclamation marks. Anywhere. | An exclamation mark is enthusiasm directed at someone. Directed at an adult mid-shutdown it is a pat on the head. |
| No encouragement. No praise. No "Great job", "Nice one", "You're all set", "Well done" | Praise implies a task performed for an evaluator. Saying a sentence is not an achievement. |
| No "student", "learner", "practice", "progress", "level", "unlocked" | The single most-named infantilisation in this population is being treated as a student. It arrives through vocabulary first. |
| **No "parent", "caregiver", "guardian", "supervisor" concept anywhere** — not a label, not a settings section, not a class name, not a doc comment | Structural, not cosmetic: it encodes that the adult user is not the account holder of their own voice. There is one user. They own the board. |
| Never narrate the user's emotional state | "Feeling overwhelmed?" — the app does not know, and guessing is presumptuous. |
| No questions where a statement will do | A question demands a decision from someone whose decision-making is exactly what is impaired. |
| Never "just" or "simply" | Both mean "this is easy and you are struggling with it anyway." |
| ≤8 words on the main surface | The speak screen is read in a state where reading is expensive. |
| No tutorial hand-holding, no coach marks, no "tip:" | The grid is twelve labelled rectangles. It does not need a tour. |

## Case

**Reed's own chrome is lowercase**: `theme` · `edit` · `show` · `settings`. Democratic, current, adult-indie rather than clinical — and it is the whole icon system, since there are no icons in v1 and the words *are* the labels.

**Author it lowercase in the string table. Never a text transform.**

```dart
// WRONG — a transform is a rule about all text, and text includes people.
Text(label.toLowerCase(), style: meta)
Text(tile.label.toUpperCase())

// RIGHT — the literal is already the thing it renders.
const chromeTheme = 'theme';
Text(chromeTheme, style: meta)
```

A `.toLowerCase()` in a widget survives into a code path that eventually renders a user's phrase, and then Reed lowercases someone's name. No lint catches that day; no telemetry reports it. Author the case; do not compute it.

**Sentence case for content. Never all-caps.** Uppercase is measurably faster for glance-reading isolated words, and that finding is overridden here deliberately: it is bounded to 1–2 word phrases and Reed's labels run to four; and **all caps on an AAC utterance reads as shouting**, which is catastrophic when the phrase is `I need a minute` and the entire point is to signal distress calmly. `SHOWER` is a word. `I NEED A MINUTE` is a person yelling. The grid cannot tell them apart, so neither is allowed.

## Punctuation

Real apostrophes: `’`, never `'`. Intentional `…` and `—`. Normalise straight quotes to curly **on save only, never mid-typing** — retyping a character under someone's cursor is a possession violation on a text field.

**No terminal periods on tile labels.** A period on a button is institutional.

```
Can’t talk          ← right
I can't talk now.   ← wrong: straight apostrophe, terminal period
```

`I can’t talk right now` reads as made by a person. `I can't talk right now.` reads as a database dump. Zero bytes, zero risk, and most apps get it wrong — which is exactly why getting it right registers as craft.

Full sentences that are genuinely sentences — the `says` field, the standing line, settings prose — take normal terminal punctuation. The ban is on periods appended to *labels*, not on grammar.

## The two phrase fields

| field | shown | cap | copy rule |
|---|---|---|---|
| `label` | the tile | **16 characters**, hard | a handle. Sentence case, no terminal period. `Can’t talk` |
| `says` | TTS and the show screen | uncapped, defaults to `label` | the utterance. Full sentence. `I can’t talk right now but I’m okay.` |

The editor names them **"What you see"** and **"What it says"** — not "label"/"value", not "short"/"long". `says` stays collapsed and auto-mirrors `label` until explicitly opened; most users never see it.

**The editor refuses at 16 characters and never silently truncates**, and never ellipsizes — an ellipsis on an AAC utterance is a *different utterance*.

Shipped starter labels may carry a literal `\n` as a break hint (`I need\na minute`) because ragged text strands words. Treat it as a hint only.

## Starter phrases and vocabulary

Starters are written to be *replaced*, not admired. Do not ship copy that pre-authorises the user to change them ("Most people replace half of these in the first week") — pre-authorisation is the parental register in indie clothes. The edit affordance is the permission.

The repair tile, fixed position, is the model for the whole set:

> **label:** `Wrong one` · **says:** `Sorry — that wasn’t what I meant to say.`

Repair is something you *say*, not a mechanism the app grants you.

**The lexicon is adult, and this is the wedge.** The vocabulary must accommodate profanity, sex, medical terms, and job-specific and community terminology — the majority ask from this population is a comprehensive adult-level lexicon, and several specifically want work vocabulary rather than basic conversational words. Consequently:

- **No content filter. Ever.** Not on `says`, not on the type-to-speak field, not on import. Filtering a disabled person's own speech is precisely the paternalism the product exists to oppose, and the misuse risk is identical to any keyboard.
- No profanity warning, no confirmation step, no "are you sure" on any phrase.
- Nothing in the copy or the store listing may imply a curated or safe vocabulary.

**Never transform a user's phrase.** No lowercasing, no title-casing, no capitalising the first letter "for" them, no trimming a deliberate `…`, no adding a period. Straight-to-curly on save is the single sanctioned edit, and it is a typographic normalisation of the same character, not a change of words. Reed's strings are Reed's to style. The user's strings are theirs.

## Errors — the strings that matter most

Reed's errors land at the worst moment of someone's day: they tapped a tile because they cannot speak, and the phone stayed quiet. Silence is the worst bug class in this product. Copy is part of the repair.

**Shape: state what happened, then the next action.** Nothing else fits.

| ban | why |
|---|---|
| **No apology** | An apology implies the user needs soothing — the parental register through the back door. And "sorry" from software is a lie about who is upset. |
| **No blame** | "You haven't selected a voice" is an accusation for a default the app shipped without. |
| No hedging: "seems", "may have", "might not", "unexpectedly" | The app knows what happened. It has the failure variant in its hand. |
| No ellipses in errors | An ellipsis is a trailing-off. Nothing is trailing off; a thing failed. |
| No "we" | See above. |
| **No modal dialogs, ever** | A modal during a shutdown demands a decision from someone whose decision-making is impaired, and blocks the one screen they opened the app to use. Errors are inline and non-blocking. |

**Every speech failure shows the words.** The failure carries the text that should have been spoken, so the on-screen fallback is total by construction: when speech fails, the phrase goes up in large type and the user is still in the conversation. Copy never substitutes for that — it accompanies it.

Before → after:

```
✗  Oops! Something went wrong. Please try again.
✓  No voice selected. Pick one in settings.

✗  We're sorry — we couldn't reach the speech engine.
✓  The speech engine didn’t respond. Your words are on screen.

✗  Error: setVoice returned 0 (voice "en-gb-x-gba-network" unavailable)
✓  That voice isn’t installed. Pick another in settings.

✗  You haven't chosen a voice yet! Tap here to get started.
✓  No voice selected. Pick one in settings.

✗  Your board may not have saved. Please try again later.
✓  That tile didn’t save. Tap it to edit and save again.

✗  Something went wrong restoring your board. Don't worry, we've got a backup!
✓  This board didn’t open. The previous board is in settings.
```

Diagnostics — engine codes, rejected voice identifiers, database exceptions — go to the log line, never to the surface. A string the user cannot act on is noise at the exact moment noise costs the most.

## Settings and chrome captions

Settings copy is a statement of what a control does, in the user's terms, at the same register. Names first, prose only where a name is insufficient.

```
✓  Tiles: 12 · 6
✓  Show screen: bright · match my theme
✓  Keep my board off cloud backup
✓  Restore previous board
```

`Keep my board off cloud backup` is deliberately blunt and stays that way — for a user whose adversary may be someone with access to their phone account, it is a safety accommodation, not a preference, and euphemism costs them the control.

The theme control shows the **current** palette and cycles on tap: `theme: ink`, with `semanticLabel: 'Theme: ink. Tap to change.'` A semantic label is user-visible copy — it is read aloud to a person. It obeys every rule on this page. Sentence case is correct there even though the visible chrome is lowercase: a screen reader speaks a sentence.

**Never prompt an accommodation.** "Text is large. Switch to 6 tiles?" is the app noticing something about the user and offering to help — the parental posture in indie clothes. Ship the setting, visible from install, and let them find it.

## Onboarding and store copy

There is no onboarding gate, no splash, no login, no modal. Cold launch goes straight to a usable grid. Whatever onboarding exists is a dismissible strip, never a gate — and it earns its words or it is deleted.

**Use the field's own terms**, in the listing, in onboarding, in community posts: **part-time AAC**, **unreliable speech**, **intermittent speech**. They are what this audience searches, and they are a credibility signal to the speech therapists who refer. The framing to adopt: *"AAC is not the backup plan; it is the plan."*

**Describe function, not medical benefit:**

> Tap a tile or type; your phone speaks it aloud or shows it in large type. Offline. No account.

Never write "treats", "improves language outcomes", "clinically proven", or "therapy".

**Three claims that are forbidden in store copy and in settings, because they are false:**

1. That the typeface is "scientifically proven" — no independent peer-reviewed validation of Atkinson Hyperlegible exists. The honest phrasing: *"developed and tested with low-vision readers at the Braille Institute; no independent peer-reviewed validation has been published."*
2. That Google or Apple verified the privacy claims — a Play Data Safety card is developer *self-declared*. The manifest-derived permissions list is the only fact, and it is the thing to point at.
3. Any speed or engagement number borrowed from a platform vendor's design marketing.

Do not enroll the app in any kids or families category. That declaration is copy too, and it says the opposite of everything above.

## Review checklist

Grep a diff for: `!` in a string · `.toUpperCase(` · `.toLowerCase(` · `'` inside a user-facing literal · `caregiver` · `parent` · `student` · `learner` · `Sorry` · `Oops` · `we ` · `just ` · `simply` · `Please` · `Great`. Every hit is a finding until proven otherwise.
