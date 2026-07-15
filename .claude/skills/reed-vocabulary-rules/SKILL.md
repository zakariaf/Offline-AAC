---
name: reed-vocabulary-rules
description: Reed's phrase content model — the label/says/display_text split, the 16-character label cap, the twelve provenance-tagged starter phrases, adult lexicon requirements, and the never-overwrite-user-edits rule. Use when writing or editing starter phrases, designing the buttons/grid_slots schema, reaching for FittedBox/AutoSizeText/ellipsis on a tile, building zero-config first launch or the phrase editor, or adding post-crisis phrase capture. Not for the register or mechanics of chrome, settings, error, or onboarding strings, and not for table or column mechanics, drift Table subclasses, or queries.
---

# Reed — phrase and vocabulary rules

The phrases are the product. Everything else is delivery. These rules govern what gets written, what gets shown, what gets spoken, and what the app is never allowed to assume about the person holding it.

## 1. Two fields per phrase. This is the whole model.

| field | shown where | cap |
|---|---|---|
| `label` | the tile | **16 characters, hard** |
| `says` (`vocalization`) | TTS + show screen | uncapped; `null` ⇒ `label` |
| `display_text` | show screen only, when it must differ | `null` ⇒ `says ?? label` |

Tile reads `Can't talk`. Says `I can't talk right now but I'm okay.`

**A 2-word label beside a 9-word label is a CONTENT problem, not a typography one.** The cap is where it gets solved, and the cap is the reason "never truncate" is safe. The tile is a *handle* for an utterance, not the utterance.

Adopt the split on day one even if `says` is unused at first. Retrofitting a second field after users have curated boards is a migration across irreplaceable, unmergeable data — months of someone's phrases, which are their voice.

**The editor labels them "What you see" and "What it says".** `says` is collapsed and auto-mirrors `label` until explicitly opened; most users never open it. The editor **refuses at 16 characters** — it does not silently truncate, it does not accept-and-clip.

### Banned on the tile — permanently

```dart
// WRONG — every one of these is the same bug wearing a costume
FittedBox(child: Text(tile.label))
AutoSizeText(tile.label, minFontSize: 12)
Text(tile.label, maxLines: 2, overflow: TextOverflow.ellipsis)
```

```dart
// RIGHT — one uniform size for all twelve; text wraps; scaler is obeyed
Text(tile.label, style: theme.textTheme.titleLarge, softWrap: true)
```

Auto-shrink is backwards: it makes the *longest* — i.e. most complex — phrase the *smallest*, destroys the grid's rhythm, and silently defeats the user's own `TextScaler` setting. An ellipsis on an AAC utterance is **a different utterance**. Variable line count across tiles is fine; variable *size* reads as broken.

Support a literal `\n` in shipped labels (`I need\na minute`) — ragged text strands words and Flutter has no text-balance. Treat `\n` as a **hint**: if scaled text exceeds 3 lines, fall back to natural wrap.

### No ghost line, ever

Do not render `says` under the label as small dim text. At 60% ink it measures 5.34:1 on `ground` — passing WCAG AA while sitting at **APCA Lc −39.0, i.e. unreadable** — and 4.24:1 on `slate` and 3.94:1 on `oxblood`, which fail AA outright. Verifying `says` belongs in edit mode, where nobody is in a shutdown.

**On the grid, divergence gets one 6dp hairline tick, top-right, in `keyline`, only when `says ≠ label`.** That is the entire affordance. A chip has a name on it, not a paragraph.

## 2. The starter set

Twelve phrases. Opinionated, adult, and **honestly labelled as assumptions**.

### Be honest about the evidence

**A validated adult phrase list does not exist in public sources.** The only one-tap messages directly attested anywhere are:

- "too loud"
- "I need a break"
- "I want to go"

Implied, not attested: "I can talk, but only sometimes" · "I can't tell you what I need."

Everything else shipped is an assumption. So: **tag every starter phrase with its provenance and a date in the source file**, and treat the list as a placeholder to be replaced by contact with actual part-time AAC users — paid, not mined. Writing twelve confident phrases from intuition is the highest-risk shortcut available in this project; writing twelve *dated, attributed* phrases costs a comment per line.

```dart
// RIGHT — the assumption is visible to the next reader
const kStarterPhrases = <StarterPhrase>[
  // attested (participant one-tap message) · 2026-07
  StarterPhrase(label: 'Too loud', says: 'It is too loud in here.', stock: Stock.slate),
  // ASSUMPTION — author's own, unvalidated · 2026-07 · replace after user contact
  StarterPhrase(label: 'Wrong one', says: 'Sorry — that wasn’t what I meant to say.', stock: Stock.oxblood),
];
```

### Provenance is required, and it is a gift, not a disclaimer

Pre-filling someone's voice is presumptuous. Provenance converts presumption into a gift: a starter set that arrives anonymous reads as **correct**, and deviating from something correct reads as **error**.

Ship provenance as a **static page — first person, named author, saying who wrote these and why**, reachable from the grid, never modal. Keep the line "a starting point, not a prescription": it is a statement about the thing.

Two things that must never ship:
- **A byline that changes to `Yours.` once the user edits.** That is the app noticing you did a thing and commenting approvingly. It is a gold star with better kerning.
- **"Most people replace half of them in the first week."** Telling someone what most people do so they know they are normal is reassurance nobody asked for.

### Repair is a phrase, not a mechanism

There is no undo. You cannot unsay speech. One of the twelve starters *is* the repair:

> **label:** `Wrong one` · **says:** `Sorry — that wasn't what I meant to say.` · **stock:** `oxblood`

Fixed position, and **replaceable like any other tile**. Repair is something you *say*. Building it as a system primitive — an undo stack, a special red control, a modal — designs for a bystander's fear of the user rather than the user's use. Cancelling speech is a cancel: tapping the lit (speaking) tile stops it. That needs no vocabulary at all.

`oxblood` is a paper stock at OKLCH C 0.026, not an alarm. **There is no red in Reed.**

### Stock assignment

Four stocks across twelve tiles — each appears about three times, **scattered by category, never by rank**. Assignment is per-category and stable forever. A category's colour must never imply a category's position, and a lighter tile must never mean a more important tile: that is a salience hierarchy, and it is banned. Colour is a redundant assist; **position is the retrieval mechanism**.

### Author the traversal order with the set

Highest-value phrases sit in the lower-centre arc for the thumb, which puts them 8th–11th in row-major traversal — 8–11 seconds under linear autoscan at 1s/step. Author `sortKey: OrdinalSortKey(priority)` from the phrase's **priority, not its layout position**, when defining the set. Inheriting traversal from layout by accident is not a decision.

## 3. An adult lexicon, operationally

**REQUIRE:** vocabulary that includes **profanity, sex, medical terms, and job-specific/community terminology**. A "basic conversational vocabulary" is precisely the infantilisation this product exists to oppose — users asked for comprehensive adult lexicons, and some asked specifically for job and community terminology rather than basic words. Second-person adult copy. No exclamation marks. No encouragement. The user is the account holder of their own voice, full stop.

**BAN, checkable, in any phrase, string, asset name, or copy:** cartoon avatars · mascots · animal characters · puzzle pieces · star/sticker/reward motifs · streaks · badges · progress meters · confetti · "Great job!" · any "parent/caregiver" account concept · "student" or "learner" framing · tutorial hand-holding · any encouragement copy addressed to a child.

**Never filter what the user can say.** Filtering a disabled person's own speech is the paternalism the product opposes; the misuse surface is identical to any keyboard.

**Never generate or expand phrases.** No LLM turning `hurt loud leave` into a sentence. Nondeterminism in a crisis tool is terrifying — the user must know exactly what will be said *before* it is said — and a plausible-but-wrong sentence puts words in a disabled person's mouth, which is a worse dignity harm than slowness.

Use the field's own words in copy and the store listing: **part-time AAC use**, **intermittent** / **unreliable** / **insufficient** speech. "AAC is not the backup plan; it is the plan." These cost nothing and buy credibility with users and clinicians alike.

## 4. Zero-config launch

Cold launch goes **straight to the Speak screen with the default set already usable**. No splash, no onboarding gate, no login, no modal, no network wait, **never a wizard**. The install may itself BE the crisis.

If a starter-set picker exists at all, it is a **dismissible strip on the grid**, skippable in one tap — never a gate.

Every launch **resets to the home board**. Persist customisation and settings; never persist navigation state. "Why am I on the Food board?" is cognitive load at the worst possible moment.

Grid size (`Tiles: 12 · 6`) is a setting, visible from install, **never prompted**. At *first launch only*, lay out the longest starter label with a `TextPainter` at the live `textScaler` and pick 6 tiles if it exceeds 3 lines or overflows. Persist. **Never re-evaluate, and never ask.** "Text is large. Switch to 6 tiles?" is the app noticing something about you and offering an accommodation it decided you need — the parental register in indie clothes.

## 5. User content is ground truth

```sql
user_edited INT DEFAULT 0   -- 1 ⇒ NEVER overwrite on default-set update
hidden      INT DEFAULT 0   -- hide, never delete
```

**Never overwrite or "upgrade" a phrase the user has touched.** Ship new default content as **additive, opt-in, and clearly separate**. There is no telemetry and no server: nobody will ever learn that an update ate someone's board, and the person it happened to cannot phone in a bug report while unable to speak. User data is unmergeable ground truth.

Hide, don't delete. Deleting writes `NULL` to `grid_slots.button_id`; the slot stays empty and **nothing reflows** — position is the primary key.

## 6. Post-crisis phrase capture

The feature: *"add what you needed to say and couldn't."* It lets the crisis-state self teach the calm-state self instead of requiring prediction. It is the best available answer to the customisation paradox and nobody ships it.

**Pull-only, passive, always-present. NEVER a notification, a prompt, a badge, or a timed check-in.** Post-shutdown is a recovery and vulnerability window; a push asking "how was your shutdown?" is clinically harmful and reputationally fatal. The affordance waits; it does not ask.

Likewise, never auto-detect distress and never adapt content or layout to inferred state — users are explicit that automatic personalisation should never activate, and one objected to the mere *presence* of the knob. Do not ship it switched off.
