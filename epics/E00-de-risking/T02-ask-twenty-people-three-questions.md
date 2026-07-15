# E00-T02 — Ask twenty people three questions

| | |
|---|---|
| **Epic** | E00 — De-risking |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E00-T01 |
| **Blocks** | E00-T03 |

**Skills:** `reed-aac-audience` · `reed-vocabulary-rules` · `reed-copy-voice`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

The entire evidence base under this product is **one unrefereed preprint (n=12, all US, recruited via social media)** plus a second unrefereed n=5 asynchronous text focus group. Combined N = 17 — and the parts of the analysis that look like independent corroboration mostly trace back to the same twelve people. Four load-bearing architectural decisions rest on **zero direct testimony**: whether the app-launch barrier exists, whether users want speech or screen, whether reading survives a shutdown, and what the phrases actually are. Ship those as guesses and you build a widget nobody opens, a speech default nobody wants, and twelve tiles of your own intuitions sitting in someone else's mouth.

## Scope

Recruit **~20 part-time AAC users** — autistic adults with **intermittent** speech (speech intact, *access* fails episodically), plus **unreliable** and **insufficient** speakers. Not selective mutism, not aphasia, not post-seizure: those are three different products and their answers will point the design somewhere Reed is not going.

**Pay them.** The field's own published position is that people who use AAC must be leaders and co-creators in anything about them, and it names **tokenism** as a specific risk. An unpaid extraction of twenty people's crisis experiences to de-risk your roadmap is the thing that paper is about. If payment is genuinely impossible, say so in the recruitment post in plain words rather than omitting it.

### Recruitment order — moderators first, always

1. **Message subreddit moderators before posting anything.** A ban in the community you are serving is unrecoverable: you lose the recruitment channel, the launch channel, and the reputation, permanently, and a cold promotional post is exactly how that happens. Ask permission, state that you are building an app, state whether participants are paid, and accept "no."
2. Equally valid, same rule: an **AAC Discord**, a **Facebook group**, or **paid participants via a recruitment panel**. Panels sidestep the moderator problem entirely and cost money instead — that is a fair trade.
3. **Positionality is a required field in the post.** State plainly who you are and why you are building this. Do not write in the voice of a lived-experience insider unless that is true.

### Register of every word you send them

The recruitment post, the consent blurb, and the questions themselves obey `reed-copy-voice` and `reed-aac-audience`, because these people are the audience and they will read the register before they read the content:

- Use the field's terms verbatim: **part-time AAC use**, **intermittent** / **unreliable** / **insufficient** speech. Generic phrasing ("people who struggle to talk") marks you as an outsider in the first line.
- Never: "non-verbal", "goes mute", "loses their voice", "suffers from", "person with autism", "backup for when speech fails". Write: **non-speaking**, **loses access to speech**, **autistic adults who…**, and adopt **"AAC is not the backup plan; it is the plan."**
- No exclamation marks. No "just" or "simply". No apology. No "we" — there is no team behind glass. Second person, present, active.
- Do not narrate their state back at them ("when you're feeling overwhelmed…"). You do not know.

### The three questions, and what each one kills

Phrase every question so it can come back **NO**. A question that cannot be answered against the plan is not research — it is a survey looking for applause.

**(a) Launch barrier.**
> "Last time you needed AAC, was your phone already unlocked and in your hand, or in your pocket?"

There is currently **zero direct testimony either way**. The launch barrier is an inference, not a finding, and the counter-hypothesis — "the phone is already unlocked and in my hand" — is exactly as supported. If the answer is "already in hand", the **entire widget / Quick Settings tile / lock-screen architecture is worthless and must not be built.** Write that consequence down before you ask, so you cannot relitigate it afterwards.

**(b) Speak or show.**
> "When you use AAC in public, do you make it speak, or do you show someone the screen?"

If the answer is "show", **speech-first is the wrong default** and the show screen is the product, not a mode. Note the pressure this sits under: 11 of 12 use AAC only in environments they perceive as safe, and 4 of 12 avoid social situations entirely to dodge reactions to their device. Concealability — looking like you are just texting — is a feature. Ask where they were and who they were talking to, because "speak" at home and "show" at a pharmacy counter is a different finding from either alone.

**(c) Why they left the incumbents.**
> "You've tried the incumbents — what specifically made you stop?"

Push for the specific moment, not the general grievance. **If the answers are vague or purely aesthetic, the demand is not there** and E00-T03 is a cancellation decision, not a refinement. Do not lead them to infantilisation: it ranked **5th of 6** in the source data (typing 12/12, customisation 12/12, speed 11/12, trust/privacy 11/12, TTS quality 10/12, infantilising design 5/12). It is the emotional core of the positioning and it must never outrank retrieval speed, typing, customisation, privacy, or voice quality in the roadmap. Let them raise it or let it stay unraised.

### The fourth question, which nobody has ever asked

> "During a shutdown, can you read? Can you read a short phrase on a tile?"

**No source supports reading degrading during shutdown.** Motor immobilisation and decision-making impairment *are* documented; reading is an extrapolation someone made and everyone repeated. The whole symbols-on-tiles rationale rests on the answer, and a 16-character text label on every tile rests on it too. Ask it as two questions — reading at all, then reading a short phrase — because "I can read but I can't decide which one" is a different product than "I can't read", and both are different from "reading is fine."

### Also collect, if the conversation allows

- **Phrases.** A validated adult phrase list does not exist in public sources. The only directly attested one-tap messages anywhere are **"too loud," "I need a break," "I want to go."** Ask what they actually needed to say and could not. Every phrase you get here replaces an assumption in the starter set with an attributed line — and provenance is a gift, not a disclaimer.
- **Voice.** 4 of 12 criticised missing nonbinary/middle-pitch voices; one deliberately prefers pitched-down child/teen TTS because of age dysphoria. Ask what voice they want, not whether they want an "adult-sounding default."

### Out of scope

- Any recruitment of selective mutism, aphasia, or post-seizure participants. Do not "widen the funnel."
- Building anything. This task ships answers, not code.
- Statistics. Twenty self-selected people are not a population estimate — see Traps.
- Deciding what to build. That is E00-T03. This task's job is to be answerable "no."

## Acceptance criteria

- [ ] Moderator permission obtained **in writing** (DM screenshot or saved message) for every subreddit posted to, **before** the post goes up — or the channel is documented as panel/Discord/Facebook-group instead.
- [ ] Payment offered and recorded per participant, or a written statement of why it was not possible.
- [ ] ≥15 participants who self-identify as part-time AAC users with intermittent, unreliable, or insufficient speech. Zero participants recruited on a selective mutism, aphasia, or post-seizure basis.
- [ ] All four questions asked of every participant, verbatim as written above, with the launch-barrier and speak-or-show questions asked **before** any description of Reed's design. Answers recorded per participant, attributable to a participant id.
- [ ] For each of (a), (b), (c) and the reading question: a written kill-condition recorded **before** recruitment starts, and a recorded verdict of met / not met against the actual answers.
- [ ] Every answer count is reported as **"14 of 20"**, never "most participants" or "research shows." Grep the write-up for `most users`, `most people`, `research shows`, `%` — each hit is a finding until proven otherwise.
- [ ] Recruitment post and question text pass the `reed-copy-voice` review checklist: grep for `!` · `just ` · `simply` · `Sorry` · `Oops` · `we ` · `Please` · `Great` · `non-verbal` · `mute` · `caregiver` · `parent` · `student` · `learner` · `person with autism`. Zero unjustified hits.
- [ ] Any phrase a participant volunteers is recorded with participant id and date, in a form that can be pasted into the starter set as an `// attested (participant P07) · 2026-07` provenance comment.

## Traps

- **Posting before asking the mods.** The channel you burn is the channel you launch in. This is the single unrecoverable failure in the task and it takes one impatient evening.
- **Asking a question that cannot answer no.** "Would a home-screen widget be helpful?" gets a yes from everyone and tells you nothing — people are agreeable, especially to someone building something for them. "Was your phone in your hand or in your pocket?" has two answers and one of them cancels a feature. If you cannot state in advance what answer kills the feature, you have not written a question.
- **Describing Reed first, then asking.** Once you have said "I'm building a fast-launch AAC app," the launch-barrier question is answered by politeness. Ask (a) and (b) cold, then describe.
- **Counting the same twelve people twice.** When an answer here matches the preprint, that is not corroboration if your participant read the preprint or came from the same subreddit that recruited it. Ask where they heard about the study. Self-selected social-media recruitment is exactly how the existing n=12 was built; you are at risk of rebuilding it.
- **Reporting a count as a rate.** "70% of part-time AAC users keep their phone unlocked" is a fabrication built from 14 of 20 self-selected people. Say **14 of 20**. The precision is the honesty; a reader who checks finds exactly what was claimed.
- **Leading on infantilisation.** It is the most emotionally satisfying answer to fish for and the fifth-ranked complaint. Fish for it and you will get it, and you will have manufactured a mandate to reorder the roadmap behind a fake finding.
- **Manufacturing a mechanism from an answer.** "TTS worsens shutdown by injecting audio into an overloaded channel" is stated by no source — the only audio complaint in the existing data is that devices are too **quiet**. If a participant says something adjacent, record the sentence, not your theory of it.
- **Hearing "show" and rebuilding everything on one answer.** Two participants saying "show" against eighteen saying "speak" is a settings default, not an architecture. Write the threshold down before you count.
- **Tokenism.** Twenty conversations, a thank-you, and then never speaking to any of them again, while the store listing implies co-design. Either the listing states plainly who built this and why, or there is a paid advisory group. Silence reads as exactly the thing the field's position paper is about.
- **Recruiting sympathetically outward.** Someone with aphasia will reply and their reply will be moving. Their evidence base is personalised photo Visual Scene Displays, not grids — adults with aphasia identify VSD themes faster and with fewer fixations than on grid displays. Their answers will pull Reed toward a product it is not. Thank them and exclude them.
- **Treating part-time use as a problem to solve.** 10 of 12 persisted as part-time users; only 2 were full-time. If you ask "what would get you using it more?" you have revealed that you think part-time is churn-in-progress, and the answers will be shaped to that frame.

## Files

- `/Users/zakariafatahi/50-apps-challenge/Offline-AAC/epics/E00-de-risking/T02-ask-twenty-people-three-questions.md` (this task)
- Recruitment post text, consent blurb, and question script — one file each, drafted and grepped before any message is sent.
- Per-participant answer records, keyed by participant id, with recruitment channel and date on each.
- The verdict record: four kill-conditions, written before recruitment, with met / not met marked after.

## Done when

Four kill-conditions written in advance have a recorded met-or-not-met verdict against answers from ≥15 paid part-time AAC users, with every count stated as *n of 20* and no community banned in the process.
