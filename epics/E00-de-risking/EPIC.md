# E00 — De-risking

> Seven cheap probes that answer, in writing, whether Reed should be built as specified — before a single line of shippable code exists.

| | |
|---|---|
| **Status** | Not started |
| **Tasks** | 7 |
| **Depends on** | Nothing |

## Why this epic exists

Reed's entire thesis rests on assumptions that have never been checked against a device or a person. The evidence base is one unrefereed preprint (n=12, US, recruited via social media) plus a second unrefereed n=5 text focus group — combined N=17, and the two overlap: they are largely the same twelve people. A validated adult phrase list does not exist in public sources. The only one-tap messages directly attested anywhere are *"too loud," "I need a break," "I want to go."* Everything else in a starter set is the author's assumption wearing a confident face.

The product also assumes a free, offline, on-device TTS voice on a cheap Android phone is good enough that an adult will let it speak for them. Nobody has verified that. If it is not, the product is not "a bit rough" — it is a board that puts a voice in someone's mouth that they will not use, and 10 of 12 named TTS quality as a complaint. Voice is identity here; four of twelve criticised the absence of nonbinary/middle-pitch voices, one deliberately prefers pitched-down child/teen TTS because of age dysphoria.

And the positioning assumes novelty. *"Every mainstream AAC app is built for young children"* is verifiably false and will be fact-checked in public by an audience that reads adversarially. An adult-first text AAC product has been marketed to literate adults for over a decade. One caught overclaim costs the product the exact community it needs.

Getting this wrong is not a slipped sprint. It is two weeks spent building a well-tested, beautifully accessible, WCAG-AAA-contrast board that nobody wants, in a voice nobody will use, against a competitor who already ships it for free. The cost of finding out now is one week and about $25.

## What "done" means

- Each of the seven tasks has written answers committed under `epics/E00-de-risking/` — not remembered, not "we discussed it."
- A **build / no-build / pivot** decision is written down with the specific finding that drove it, and the person who wrote it can point at the artefact (recording, note, transcript, screenshot) behind each claim.
- If **build**: the twelve starter phrases exist as a list where every entry carries provenance and a date — `attested`, `implied`, or `ASSUMPTION — author's own, unvalidated` — ready to paste into `kStarterPhrases`.
- If **build**: a named, real, cheap Android device (budget silicon, ~2GB RAM) is nominated as *the* target hardware, with its TTS engine, its offline voice list, and its measured time-to-first-word recorded.
- Nothing in E01 or later has started. This epic is a gate.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E00-T01 | Use the incumbents for 90 minutes | S | Nothing |
| E00-T02 | Ask twenty people three questions | M | E00-T01 |
| E00-T03 | TTS quality probe on a cheap Android | M | E00-T02 |
| E00-T04 | Latency probe: time to first word | S | E00-T03 |
| E00-T05 | Airplane-mode probe | XS | E00-T03 |
| E00-T06 | Switch Control and screen reader spike | S | Nothing |
| E00-T07 | Positionality, and contact the AAC-user developer | XS | Nothing |

**E00-T01** exists to make the author the least ignorant person in the room before they open their mouth in public. Ninety minutes actually *using* the competition — not reading its listing — is what separates a defensible positioning claim from the one that gets corrected in a Reddit thread. It also feeds T02: you cannot ask twenty people a useful question about a category you have only read about, and "what would you want instead?" is a worthless question from someone who has not tried what exists.

**E00-T02** is the one that decides whether the starter set is a gift or a presumption. Twenty people, three questions, using the field's own vocabulary — *part-time AAC use*, *intermittent* / *unreliable* / *insufficient* speech, *non-speaking* not *non-verbal*, identity-first — because generic phrasing marks you as an outsider in the first sentence and the answers you get back are the answers outsiders get. This task is where "12 of 12" and "10 of 12" stop being borrowed numbers and start being something the author has heard directly. It is also where the phrase list either gets real content or gets honestly tagged as assumption.

**E00-T03** is the hardest kill switch. It runs on the phone the audience actually owns — cheap, not a flagship — because that is the target hardware, not a degraded case, and because *"I don't take my iPad with me most of the time"*: situational speech loss is unplanned, so only the phone is present. It has to establish that offline voices exist at all on that device after `network_required` and `notInstalled` are filtered out, that they sound like something an adult will accept, and that a nonbinary or middle-pitch option is reachable. If the honest answer is "no usable offline voice," the pivot is a bundled engine (Kokoro-82M, Apache-2.0 — Piper's successor is GPL-3.0 and out) and that is a different project with a different budget. It blocks E01-T01 because there is no point designing a speech seam around an engine that cannot do the job.

**E00-T04** measures the gap between tap and audio on that same cheap device, cold and warm. It matters because TTS engine binding runs binder IPC and voice deserialization *synchronously on the main thread* inside `OnInitListener` — a real, separate cost that Flutter profiling does not surface, and a first tap that feels dead reads as silence to a person who is not going to tap twice. The number this task produces is what the post-frame warm-up rule is later measured against.

**E00-T05** is twenty minutes and one switch. Airplane mode on, speak, listen. It is the only honest test of the voice filter's central claim, because online a network-required voice works fine and the failure only appears in the moment it matters. It also validates the approved privacy wording — *"we only select voices that declare they need no network"* — as something the device actually supports, before it goes in a store listing.

**E00-T06** is the one that runs on its own track from day one. Switch Access and Switch Control have no automation and never will: no API simulates scanning, group selection, or point scanning, and Flutter publishes no support statement for either. So the only way to learn what a switch user's Reed feels like is to turn it on and drive it, on hardware, before the grid is designed around a thumb. It blocks E05-T06 because the traversal decision — `sortKey: OrdinalSortKey(priority)`, authored from priority rather than inherited from layout — has to be made by someone who has felt 8–11 seconds of linear autoscan at 1s/step, not by someone who read about it.

**E00-T07** costs an hour and closes the gap the field itself named. The published position, from AAC users and researchers together, is that people who use AAC must be leaders and co-creators in anything about them — and it names tokenism as a specific risk. So the choice is: state plainly in the listing who built this and why, or recruit and *pay* an advisory group. Silence reads as exactly the thing that paper is about. Reaching out to the AAC-user developer is the cheapest first move, and it must be an offer, not an extraction.

## Skills this epic draws on

**Audience and positioning**
- `reed-aac-audience` — the segment (autistic adults with shutdown, nobody else), the vocabulary that must be used verbatim, the three cut populations and why re-adding them is a different product, and the 12-of-12 honesty rule that governs every claim T01/T02 produce.
- `reed-vocabulary-rules` — the label/`says` split, the 16-character cap, and the requirement that every starter phrase carry provenance and a date. This is the shape T02's output must land in.
- `reed-copy-voice` — the register for the questions themselves and for anything written down afterwards: second person, no praise, no "we," no caregiver framing.

**Speech**
- `reed-speech-service` — the four `flutter_tts` calls that exist (`speak`, `stop`, `getVoices`, `setVoice`), what `setVoice` returning 0 means, and why `notInstalled` returns 1 and still produces silence. T03/T04/T05 probe exactly this surface.
- `reed-speech-testing` — the `SpeechEnv` catalogue of ways the world breaks, and the honest statement of what no automated test can ever reach. `reportedSuccessButSilent` is why T03 is a human with ears and not a CI job.
- `reed-dependency-hygiene` — the gate every dependency passes, the licence facts behind the pivot option (Kokoro-82M Apache-2.0; Piper's successor GPL-3.0), and the rule that green CI is never evidence of audio.

**Startup**
- `reed-app-startup` — the cold-launch order, why `warmUp()` fires from `addPostFrameCallback` and is never awaited, and the honest framing that most of cold start is Android's and not measurable from Dart. T04's number is interpreted against this.

**Privacy**
- `reed-privacy-claims` — the banned sentence, the approved three-clause wording, and the word *declare*. T05 is the physical check behind the third clause.

**Accessibility**
- `reed-a11y-coding` — where a11y state comes from, why traversal is authored from priority, and the rule that feedback is never single-channel. T06 is the felt version of all three.
- `reed-a11y-testing` — the honest ceiling: four built-in guidelines, one known-broken, and switch access untestable. It is the reason T06 exists as a manual spike.
- `reed-manual-checklist` — the hardware rules T03/T04/T05/T06 all inherit: physical phone, cheap phone, ringer switch off, release build. An emulator answers none of these questions.
- `reed-tile-anatomy` — the tile T06 is driving with a switch, including the scan-highlight-visible-against-every-stock problem the flat opaque palette creates.

**Store and legal**
- `reed-store-and-legal` — the constraints that could invalidate a finding before it is acted on: the EU geo-restriction verdict, the LLM-generation stop-list entry, and the licence table behind any symbol or voice decision T01 surfaces.

## Sequencing

There are three independent tracks and they should run concurrently, because the epic is a week and the human-dependent one has the longest latency.

**Track A — the hard chain: T01 → T02 → T03 → {T04, T05}.** Each link is real, not bureaucratic. T01 before T02 because you cannot ask a good question about a category you have not used. T02 before T03 because T02 tells you which voices to listen for — a probe that evaluates "does it sound natural" without knowing that four of twelve want a nonbinary or middle-pitch voice will test the wrong thing and pass. T03 before T04 and T05 because both are measurements *of a chosen voice on a chosen device*; without T03 there is nothing to measure. T04 and T05 are siblings and run in one sitting on the same phone.

**Track B — T06, from day one, in parallel.** It shares no input with Track A and is gated only on hardware. Start it immediately; it blocks E05-T06 and a late finding there is expensive.

**Track C — T07, day one, in parallel.** It is an hour of writing and an email, and the email's reply time is entirely outside your control. Send it first and let it sit.

**The chain does not compress.** T02 depends on twenty humans replying, which is the longest pole in the epic regardless of how fast T01 finishes. Post the questions the day T01 ends.

**Nothing in E01+ starts until all seven land.** E00-T03 formally blocks E01-T01, but the gate is the epic, not the arrow.

## Risks specific to this epic

- **Confirming the answer you brought.** Twenty people asked a leading question return twenty confirmations. The mechanism is specific: the existing evidence base is self-selected social-media recruitment, and recruiting the same way reproduces the same sample. Watch for the moment a finding "confirms" something from several directions — check whether every direction traces back to the same twelve people. It usually does.
- **Counting as a rate.** "17 of 20 said yes" is a count of twenty self-selected people, not 85% of a population. The precision *is* the honesty; the moment a count becomes a percentage in a note, the note is now marketing.
- **Testing on the wrong phone.** A flagship has a good TTS engine, fast binder IPC, and plenty of RAM. Every one of T03/T04/T05 passes on it and tells you nothing. The audience is cost-constrained; a budget device with ~2GB RAM *is* the target, not the edge case.
- **Testing on an emulator.** Standard Android emulator images ship without a TTS engine or voice data. T03 on an emulator is not a weak probe — it is a probe of nothing, and it will look green.
- **Testing with the ringer on.** Silent mode is the default state of a person having a bad day in public. A probe run with the ringer up cannot see the `.ambient`-vs-`.playback` class of failure at all, and the plugin's own README example uses `.ambient`.
- **Believing the engine.** `setVoice` returns 1 for a `notInstalled` voice and synthesis then silently substitutes a different one. A probe that checks return codes and does not *listen* will report a voice that works and does not.
- **Mistaking scope for a pivot.** "Also support aphasia / selective mutism / post-seizure" will surface in T02 and it will sound sympathetic. Each inverts an assumption: aphasia's evidence base is personalised photo Visual Scene Displays, not grids; postictal confusion means no navigation is possible at all. The test is whether X's evidence base recommends grids and typing. If it recommends photo scenes, single buttons, or partner-mediated setup, X is a different product — say so, in those words.
- **Extraction dressed as research.** T02 and T07 both ask disabled people for unpaid labour on a product that will be theirs only in the marketing. Pay, or ask for less. Tokenism is named as a risk by the field's own position paper, and a fifteen-minute chat cited as "co-design" is exactly what that paper is about.
- **Skipping the write-up.** The findings that never get written down get re-derived, wrongly, in week three — from memory, in the author's favour. This epic's only deliverable is text.
- **Letting the gate become a warm-up.** Three of these tasks can kill the project. If none of them can change the plan, they were not probes; they were rituals, and the week is gone.

## Out of scope

- **Any shippable code.** No `lib/`, no widgets, no schema. Probe code is throwaway and is deleted or quarantined outside `lib/` when the epic closes. The speech seam is E01.
- **The final starter phrases.** T02 produces raw material and provenance tags. Authoring the twelve — labels within the 16-character cap, `says` sentences, stock assignment scattered by category, `sortKey` from priority — is vocabulary work in a later epic, governed by `reed-vocabulary-rules`.
- **Choosing the palette, the typeface, or the grid geometry.** Nothing here decides a colour or a dp. Those live in the colour, typography, and grid epics.
- **The manual pre-release pass.** T03/T04/T05 borrow its hardware discipline but are not it. `CHECKLIST.md` and the per-tag ritual belong to the release epic.
- **Store paperwork.** The Play Health apps declaration, the Data Safety form, the privacy policy page and its in-app link, and the EU geo-restriction are all real submission blockers and all live in the store-and-legal epic. T01 and T07 may surface a constraint; they do not action it.
- **Automated a11y tests.** T06 is a manual spike on hardware. `test/ui/a11y_test.dart` — the geometry loop, the display-label assertion, the traversal-order test, the anti-clamp test — is E05.
- **Vendoring `flutter_tts`.** It is healthy today and vendoring pre-emptively buys a maintenance burden against a break that has not happened. The trigger and the procedure are in `reed-dependency-hygiene`; nothing in E00 pulls it forward.
