# E11-T04 — Ship to the twenty

| | |
|---|---|
| **Epic** | E11 — Release |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E10-T03, E10-T05, E11-T01, E11-T02 |
| **Blocks** | Nothing |

**Skills:** `reed-manual-checklist` · `reed-aac-audience` · `reed-copy-voice`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Twenty people recruited from the de-risking work agreed to try this. They are autistic adults with intermittent speech who will install a stranger's app and then depend on it in the state where they cannot ask for help. Shipping to them — not to the store — is the last cheap moment to learn that the starter phrases are wrong, that the voice list is wrong, that a tile is silent on a device nobody owns here. And because they will build dependence on a disability accommodation, the exit plan has to exist and be written down *before* the APK leaves the machine, not after the first person asks what happens if you stop.

## Scope

Three things: the build goes out, an exit plan goes out with it, and the roadmap after this point is deliberately empty.

**1. The build.**

Gate on the manual pass from `reed-manual-checklist` — a fresh tick-through of the tracked `CHECKLIST.md`, on a physical cheap Android device (budget silicon, ~2GB RAM, never a flagship, never an emulator), ringer switch **off / silent mode on for the whole pass**, on the **release** build signed as shipped. Fill in device, OS version and date at the top of the sheet; that header is the entire reproduction context that will ever exist. Do not tag from memory of having basically done this last time.

Distribution: whatever gets a signed APK to twenty specific people — direct APK link, or a Play internal testing track (**never a kids or families category**, that declaration is copy too and it says the opposite of everything the product says). No public store listing. No open beta.

**2. The exit plan, in writing, shipped with the build.**

This is a text they read before they install, not a footer. It has to say three facts and nothing more:

- **What happens if this developer disappears.** The app is offline, has no account and no server. It keeps working. Nothing expires, nothing phones home, nothing gets switched off. This is the one honest reassurance available and it is a consequence of the architecture, not a promise about a person.
- **How to leave with the board.** Export, through the share sheet, to whatever they already use. Their phrases are theirs and they can carry them out. E10-T05's rehearsal is what makes this sentence true; if it isn't true, do not write it.
- **What support actually is.** One channel, stated response reality — including "sometimes not at all" if that is the truth. Unresponsive support is a named abandonment cause in this exact population; a silent inbox after a promise of support is worse than a stated limit up front.

Register per `reed-copy-voice`: second person, present, active. **No "we"** — there is no team behind glass. No exclamation marks. No apology, no "Sorry", no "Oops", no "just", no "simply", no "Please", no praise, no "thank you for being part of this journey". Curly apostrophes (`’`), never `'`. Do not narrate their emotional state. State the fact, then the next action. Prose here is genuine sentences, so normal terminal punctuation applies — the no-terminal-period rule is about *labels*, not grammar.

Use the field's own terms where the text describes who it is for: **part-time AAC**, **unreliable speech**, **intermittent speech**. **Non-speaking**, never "non-verbal". **Autistic adults**, never "people with autism". Never "loses their voice" or "goes mute". Never "a backup for when speech fails" — AAC is not the backup plan; it is the plan.

**Positionality is a required field** (`reed-aac-audience`): the text states plainly who built this and why. If the author is not a lived-experience insider, the copy is not written in that voice. Silence on this point reads as exactly the tokenism the field's own position paper names.

Three claims stay out, because they are false: that the typeface is scientifically proven (the honest phrasing is *"developed and tested with low-vision readers at the Braille Institute; no independent peer-reviewed validation has been published"*); that Google or Apple verified the privacy claims (a Play Data Safety card is developer self-declared — the manifest-derived permissions list is the only fact); and any speed or engagement number borrowed from a platform vendor's design marketing. Nothing implies a curated or safe vocabulary.

**3. The unplanned part.**

After this ships, there is no next task. What gets built next is decided **from what these twenty people say**, not from anything written before they touched the app. That is a decision, recorded here as one. Do not pre-seed a backlog to fill the gap.

When their feedback arrives, rank against what `reed-aac-audience` already establishes rather than against sympathy: typing 12/12, customisation 12/12, speed 11/12, trust/privacy 11/12, TTS quality 10/12, infantilising design 5/12. Infantilisation leads the tone; it never outranks retrieval speed, typing, customisation, privacy or voice quality in the roadmap. Write counts, not rates — "3 of 20 asked for X", never "most testers want X". Twenty self-selected people are not a population estimate either.

Requests to serve **selective mutism**, **aphasia** or **post-seizure** users are out of scope and stay out: ask whether that population's evidence base recommends grids and typing. If it recommends photo scenes, single buttons or partner-mediated setup, it is a different product. Say so, in those words.

**Out of scope:** the public store listing. Telemetry of any kind, including a "just for the beta" exception — there is no such thing here. A feedback form inside the app. An onboarding gate, splash or modal wrapping the beta text. Any roadmap for what comes after.

## Acceptance criteria

- [ ] A completed `CHECKLIST.md` copy for this build exists, with device model, OS version and date filled in at the header, every box ticked, on a physical ~2GB Android device in silent mode against the signed release build.
- [ ] `flutter build apk --release` produces the artefact that is actually distributed, and the crash-log check from the manual pass passes on it: readable Dart function names, no hex offsets, no vocalization text in the exported log.
- [ ] The exit-plan text exists as a file in the repo and is included in what the twenty receive.
- [ ] `grep -nE "!|Sorry|Oops|\bwe\b|\bjust\b|simply|Please|Great|caregiver|parent|student|learner|non-verbal|'" <exit-plan file>` returns zero findings, or each hit is justified in review.
- [ ] The exit plan states, in these three parts: the app keeps working with no developer, no server and no account; how to export the board out; what support is and is not.
- [ ] The exit plan names who built this and why, and does not claim lived experience unless true.
- [ ] The exit plan contains none of: "scientifically proven", "clinically proven", "treats", "improves language outcomes", "therapy", "verified by Google", "verified by Apple".
- [ ] Distribution reaches exactly the twenty; the app is not listed publicly and is not enrolled in a kids or families category.
- [ ] No task file exists for work after this one, and no backlog was created in anticipation of feedback.

## Traps

- **Tagging from memory.** "I ran the checklist basically like this last release" is how the `.ambient` regression ships. The audio session category, the engineless Quick Settings tile, and Switch Access focus traps have **zero** automated coverage and never will. If this pass does not catch them, nobody catches them — the user who hits it cannot file a bug report.
- **Testing on the good phone.** A flagship hides the OOM kill that a 12MP image × 12 tiles inflicts on 2GB of RAM. That cheap device is the target hardware, not a degraded case.
- **Ringer on.** Silent mode is the default state of a person having a bad day in public. Testing with the ringer on hides the single top-severity bug in the product.
- **Shipping the export sentence before export is proven.** "You can take your board with you" is a lie until E10-T05's device-A-to-device-B rehearsal actually passed. Offline plus no account means there is no cloud restore behind it. A false exit promise is worse than no exit plan.
- **The exit plan drifting into reassurance.** "Don't worry — we'll be here for you!" fails on the exclamation mark, on "we", on emotional narration, and on being untrue. The architecture is the reassurance; say the architecture.
- **"Thank you for being part of this journey."** Praise and gratitude aimed at an adult for installing an app is the parental register in indie clothes. Delete it.
- **A "beta feedback" telemetry exception.** Someone will argue that twenty consenting testers justify one crash reporter. Eleven of twelve people in the only study of this population raised unauthorised data-collection concerns. The claim is either true or it is not a claim.
- **Pre-authorising the starter phrases.** "Most people replace half of these in the first week" in the beta note is the same pre-authorisation the copy skill bans in the app. The edit affordance is the permission.
- **Treating the twenty as a study.** They are self-selected people the developer recruited. Their counts are anecdotes with numbers attached. Never write "research shows".
- **Filling the empty roadmap while waiting.** The whole point of shipping to twenty humans is that their words outrank the plan. A backlog written before they speak will win by default, because it exists and their feedback does not yet.
- **A sympathetic request to widen the segment.** "My friend has aphasia and this would help her" arrives warm and is still wrong: anomia and alexia commonly co-occur, so a type-to-speak box may be the least accessible modality for that group, and their evidence base is personalised photo Visual Scene Displays, not grids. Answer with that, not with a maybe-later.
- **Over-claiming novelty to the twenty.** An adult-first text AAC product has been marketed to literate adults for over a decade. Some of these twenty have used it. "Every mainstream AAC app is built for young children" is verifiably false; "every mainstream *symbol-grid* app is built for children" is the claim that survives.

## Files

- `CHECKLIST.md` — a fresh completed copy for this build, with the device/OS/date header filled in.
- The exit-plan text file in the repo (the beta note that ships with the build).
- Whatever release metadata E11-T01/E11-T02 established — version tag, signing config. No new listing text.

## Done when

Twenty people have a signed release build and a written exit plan that tells them the truth about what happens if the developer disappears, and there is no plan for what comes next because they have not spoken yet.
