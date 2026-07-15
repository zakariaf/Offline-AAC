# E00-T01 — Use the incumbents for 90 minutes

| | |
|---|---|
| **Epic** | E00 — De-risking |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | Nothing |
| **Blocks** | E00-T02 |

**Skills:** `reed-aac-audience` · `reed-store-and-legal`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

You are about to spend two weeks building a competitor to products that already ship, are already offline, and are already free at the tier your audience actually uses. `reed-aac-audience` is explicit that "Every mainstream AAC app is built for young children" is verifiably false and will be fact-checked in public — an adult-first text AAC product has been marketed to literate adults for over a decade. If you cannot name, from your own thumbs, what the incumbents get wrong, you have no positioning, only a hunch. This costs about $25 and 90 minutes. Nothing else in the project starts until it is spent.

## Scope

Install and **actually use** three things. Not screenshots, not reviews, not the App Store description — use them.

1. **Speech Assistant AAC** — about $24.99 on iOS; free tier on Android. Buy the iOS one. The $25 is the entire budget of this task.
2. **Spoken** — free tier.
3. **The OS's own built-in type-to-speak.** iOS: Settings > Accessibility > Live Speech, then triple-click the side button. This is the incumbent nobody counts and it is already on every phone your audience owns.

For each of the three, do all of these, on a **phone**, not a tablet — `reed-aac-audience` is unambiguous: *"I don't take my iPad with me most of the time. It was expensive, and I don't want to break it."* Situational speech loss is unplanned and only the phone is present.

- Cold-start it: locked phone in pocket → audible output. Count taps and count seconds. Speed is 11-of-12 in the ranked complaint list; retrieval speed is the thing you are actually competing on.
- Type a sentence and speak it. Then do it again in a room with other people in it and notice what you feel.
- Pre-program a phrase, the way 10 of 12 participants described doing (*"I can pre-program phrases before I enter a situation."*). Time the authoring path. This is the single strongest validation the product has; if an incumbent already protects it well, say so.
- Find the voice settings. Look specifically for a nonbinary / middle-pitch voice and for pitch control. 4 of 12 raised this — *"Having the voice that matches every other person who uses AAC is very disempowering."* Note whether the app imposes an adult-sounding default.
- Find the "show text" equivalent, if any. Whether users want it to speak or to show is a **known unknown**; the incumbents' answer is data you do not otherwise have.
- Check what it does offline and what it asks for. Airplane mode, then look at the permission list and the store Data Safety declaration. 11 of 12 raised unauthorised data-collection concerns.
- Judge concealability. Can you use it without visibly disclosing — can it look like you are just texting? 11 of 12 use AAC only in environments they perceive as safe; 4 avoid social situations entirely to dodge reactions to their device.

**Use each one through a real low-capacity moment if one presents itself.** Do not manufacture one. If a shutdown or a near-shutdown happens in the 90 minutes, that is the most valuable data in the whole project — write it down while it is happening if you can, immediately after if you cannot.

### The write-up

Per app, three headings. Prose, not a rubric. Concrete, not vibes.

- **Better than the plan** — name the specific thing, and write the sentence you would have to delete from Reed's positioning because of it.
- **Worse than the plan** — the specific failure, with the tap count or the seconds or the screenshot.
- **What would make an adult delete it** — one paragraph. This is the section that matters. "It's ugly" is not an answer; "it infantilises you at the exact moment you are least able to tolerate it" is, and note that infantilisation ranks 5 of 12 — it is the emotional core of the positioning and the *fifth* complaint. Never let it outrank speed, typing, customisation, privacy, or voice quality.

Then one section for the OS Live Speech feature answering one question: **what is left over?** Everything Reed does that Live Speech already does is not a reason to build Reed.

### THE KILL CRITERION

Write it down before you start, and hold to it after:

> If Speech Assistant / Spoken plus the OS type-to-speak feature are **adequate**, the honest response is to file an issue with the incumbent's developer, or contribute, and build something else.

Adequate means: a part-time user with intermittent speech can get from a locked phone to a pre-programmed phrase spoken aloud, offline, without an account, without disclosing, at a speed that works mid-shutdown. If that is already true, the project's remaining value is a GitHub issue and an email. Write the issue. That is a success outcome for this task, not a failure.

The task ends in one of exactly two states, written down explicitly: **PROCEED**, with the three-to-five specific gaps that justify two weeks; or **KILL**, with the issue URL or the email you sent.

### Out of scope

- Any Reed code. No repo, no `pubspec.yaml`, no grid. Nothing.
- Feature ideas from the incumbents. You are testing whether to build, not what to build. Ideas go in a scratch list you do not act on until E00-T02.
- Symbol-grid apps built for children (Proloquo2Go, TouchChat, LAMP). They are a different product for a different population and beating them proves nothing — the honest claim is only ever "every mainstream *symbol-grid* app is built for children."
- The three cut populations. Do not evaluate the incumbents on selective mutism, aphasia, or post-seizure use. Aphasia in particular **inverts every assumption** — a type-to-speak box may be the *least* accessible modality for that group, and their evidence base is personalised photo Visual Scene Displays, not grids.
- Competitor legal/licensing teardown. That is `reed-store-and-legal` territory and it is not this task, with one exception below.

## Acceptance criteria

- [ ] A purchase receipt for Speech Assistant AAC on iOS exists (~$24.99). If you did not spend the money, the task is not done.
- [ ] All three are installed on a **phone** and each has been opened from a locked screen at least once.
- [ ] Written measurements exist for all three: taps-from-locked and seconds-from-locked to audible output.
- [ ] For each of the three apps, all three headings are written: "Better than the plan", "Worse than the plan", "What would make an adult delete it".
- [ ] The "what is left over?" section for OS Live Speech is written and names at least one thing Live Speech does *better* than Reed's plan. If it names none, you did not use it hard enough.
- [ ] Voice settings checked on all three, with an explicit note on whether a nonbinary / middle-pitch voice exists and whether pitch is user-controllable.
- [ ] Airplane-mode behaviour recorded for all three.
- [ ] The document ends with the literal word **PROCEED** or **KILL** on its own line.
- [ ] If PROCEED: three to five specific gaps are listed, each one a thing you observed, not a thing you assume.
- [ ] If KILL: a filed issue URL or a sent email exists, and it is linked.
- [ ] No line in the write-up contains "loses their voice", "goes mute", "non-verbal", "person with autism", "suffers from", or "backup for when speech fails". Grep for them.
- [ ] No claim in the write-up uses "most users" or "research shows". Counts only — "10 of 12", "4 of 12".

## Traps

- **You will read the store listings instead of using the apps.** Reading is not using. The findings you need are in the tap count and in the feeling of pressing "speak" in a room with people in it. Neither is in a screenshot.
- **You will decide before you start.** You have already designed Reed in your head. The kill criterion is worthless if you write the write-up to reach PROCEED. Write the criterion down first, on paper, before the first install.
- **You will skip the $25.** The free Android tier of Speech Assistant is not the product adults are comparing Reed to, and skipping the purchase is precisely the flinch that makes this task worthless. `reed-aac-audience` notes the segment is cost-constrained but *not destitute* — 5 of 12 avoided full-price apps, 4 gravitate to free — which means some of them **did** pay. Pay.
- **You will not count Live Speech as a competitor.** It is the strongest one. It is free, it is preinstalled, it is on the lock screen behind a triple-click, and it has zero install friction. Whether the app-launch barrier is even real is an explicit **known unknown** — no direct testimony exists, and the counter-hypothesis is "the phone is already unlocked and in my hand." Live Speech is the test of that hypothesis. Do not wave it away.
- **You will test on a tablet because it's on the desk.** Then everything you learn is about a device the user does not have with them.
- **You will grade the incumbents on the cut populations and feel good about it.** Speech Assistant being bad for aphasia is not a point for Reed; Reed is also not for aphasia. Grade only on: autistic adults, intermittent/unreliable/insufficient speech, part-time use.
- **You will treat infantilisation as the finding.** It is 5 of 12. If your write-up's "delete it" paragraph is entirely about the app looking childish and says nothing about speed, typing, customisation, privacy, or TTS quality, you found the emotional core and missed the roadmap.
- **You will conclude "they're all offline anyway, so offline is my wedge."** Offline is table stakes precisely *because* the free competition is already offline. `reed-aac-audience` is blunt: privacy was validated (11 of 12), offline was not — nobody in any source lost access for lack of signal. Offline is a consequence of the privacy stance, not the wedge. Do not write "offline is essential because you might have no signal in an ER".
- **You will invent a mechanism to explain what you felt.** "TTS worsens shutdown by injecting audio into an overloaded channel" is stated by no source; the only audio complaint in the data is that devices are too *quiet*. If you feel something, write "I felt X" — a first-person observation from one person is honest data. A mechanism you made up is not.
- **You will note down the incumbents' starter phrases and plan to copy them.** A validated adult phrase list does not exist in public sources. The only directly attested one-tap messages anywhere are *"too loud," "I need a break," "I want to go."* An incumbent's starter set is that developer's assumption, not evidence — copying it launders a guess into a citation. Record what they ship; tag it as *their assumption*.
- **You will find an LLM phrase-suggestion feature in one of them and want it.** Per `reed-store-and-legal`, LLM phrase generation is a **regulatory** decision, not a feature decision — it plausibly "operates using a different fundamental scientific technology" under 21 CFR 890.9 and voids the exemption. Note it as a competitor fact. Never scope it here.
- **You will file a snarky issue.** If the outcome is KILL, the issue you file is the deliverable and it goes to a developer who is doing the thing you were about to do. `reed-aac-audience` closes on the field's own position: people who use AAC must be leaders and co-creators, and **tokenism** is a named risk. Write the issue you would want to receive.
- **You will write the notes in a voice you have not earned.** Unless part-time AAC use is your lived experience, do not write as a lived-experience insider. Write "I, a developer with intact speech, found X". Positionality is a required field.

## Files

Creates one document — a scratch write-up, your own notes, wherever you keep them. It creates no code and touches no repo file. Its only formal output is the word PROCEED or KILL and the gap list under it, which is the direct input to E00-T02.

## Done when

Three apps are installed on a phone, ~$25 is spent, all three write-ups exist with tap counts and seconds, and the document ends with PROCEED plus three-to-five observed gaps, or KILL plus a filed issue link.
