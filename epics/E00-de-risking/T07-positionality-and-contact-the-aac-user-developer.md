# E00-T07 — Positionality, and contact the AAC-user developer

| | |
|---|---|
| **Epic** | E00 — De-risking |
| **Status** | Not started |
| **Size** | XS |
| **Depends on** | Nothing |
| **Blocks** | Nothing |

**Skills:** `reed-aac-audience` · `reed-copy-voice` · `reed-store-and-legal`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

There is a nonspeaking AAC user building a symbol/typing hybrid AAC app in Flutter — free, with open voices — and publicly asking for a partner for beta testing and release support. That is the exact overlap with Reed, held by exactly the person Reed's entire evidence base says must be a co-creator rather than a subject. The field's own published position, written by AAC users and researchers together, is that people who use AAC must be leaders and co-creators in anything about them, and it names **tokenism** as the specific risk. This task costs an hour and can end with Reed being a contribution to someone else's app instead of a competitor to it — a move no app-store survey would ever surface.

## Scope

Two deliverables. Both are writing, not code.

### 1. Email the AAC-user developer

Find the public post seeking a beta-testing/release partner and reply to it directly. The email is short and it is not a pitch.

What it must contain:

- What Reed is, in the function-not-benefit register: *"Tap a tile or type; your phone speaks it aloud or shows it in large type. Offline. No account."* — this is the sentence `reed-store-and-legal` sanctions verbatim. Do not improve it.
- The overlap, stated plainly: a fixed 3×4 text-phrase grid, type-to-speak, on-device TTS, no accounts, no server, no network, no telemetry, Android-first Flutter.
- The offer, concrete: release support, beta testing, Play Console mechanics, Android build work — whatever the post actually asked for. Name the specific thing they asked for, not "happy to help however."
- The positionality line (see 2 below) stated up front, in the same email. Not disclosed later under questioning.
- **No** claim of shared lived experience unless it is true. `reed-aac-audience`: *do not write copy in the voice of a lived-experience insider unless that is true.*

Register rules that bind this email as much as any `Text()` literal (`reed-copy-voice`):

- No exclamation marks. Anywhere.
- No "we" — there is no team behind glass.
- No apology, no praise, no "just", no "simply", no "Please".
- Identity-first: **autistic**, never "person with autism".
- **non-speaking**, never "non-verbal". **loses access to speech**, never "goes mute" or "loses their voice".
- Use the field's terms where they apply: **part-time AAC**, **intermittent speech**, **unreliable speech**, **insufficient speech**. They cost nothing and buy credibility instantly with someone in this community.
- Never write "AAC is a backup for when speech fails". The framing is *"AAC is not the backup plan; it is the plan."*

Do **not** claim in the email that "every mainstream AAC app is built for young children". It is verifiably false, it will be fact-checked by exactly this reader, and it is unrecoverable. The defensible version is "every mainstream *symbol-grid* app is built for children" — an adult-first text AAC product has been marketed to literate adults for over a decade.

### 2. Decide and write down the positionality

Answer, in writing, in one place: **is the developer autistic? is the developer an AAC user?** Then pick exactly one of two paths and commit to it:

- **Path A — state it plainly in the store listing.** One or two sentences, first person, no hedging. Whatever the true answer is, including "not autistic, not an AAC user, built this after reading the only study of this population."
- **Path B — recruit and PAY an advisory group** of part-time AAC users. Paid, not "consulted". Unpaid consultation of disabled people by a person building a product about them is the thing the tokenism paper names.

Silence is not a third path. `reed-aac-audience`: *silence reads as exactly the thing that paper is about.*

### PIVOT CRITERION

**If a partnership is genuinely available, take it seriously before building a competitor.** Two free offline AAC apps for overlapping audiences, built by two solo developers, is worse for users than one. Write down the decision either way with the reason. If the answer is "build Reed anyway", the reason must be specific — a segment or a constraint their app does not serve — not "I already started."

### Out of scope

- Writing the store listing itself. This task produces the positionality *decision* and the sentence; the listing is assembled elsewhere.
- Recruiting the advisory group. This task picks the path and budgets it, or picks Path A.
- Any legal/regulatory work. EU geo-restriction, the Play Health apps declaration and the Data Safety form are separate and are not touched here.
- Reciprocal code contribution, a shared repo, or any licence conversation. That is what a reply, if it comes, starts.

## Acceptance criteria

- [ ] The email is sent. The sent copy exists as a file so the wording is reviewable after the fact.
- [ ] Grep the email text for each of: `!` · `we ` · `just ` · `simply` · `Please` · `Sorry` · `Oops` · `Great` · `non-verbal` · `person with autism` · `mute` · `backup` · `caregiver` · `parent`. Every hit is a finding until proven otherwise. Zero unresolved hits.
- [ ] The email contains at least one of `part-time AAC`, `intermittent speech`, `unreliable speech` used correctly.
- [ ] The email contains no claim of lived experience that is not true.
- [ ] The email contains no variant of "every mainstream AAC app is built for young children".
- [ ] Two questions are answered in writing with a literal yes or no: *is the developer autistic?* *is the developer an AAC user?*
- [ ] Exactly one of Path A or Path B is marked chosen, with a date.
- [ ] If Path A: the exact listing sentence is written out, ≤2 sentences, first person, and passes the same grep above.
- [ ] If Path B: a named budget figure per advisor and a recruitment channel are written down. "TBD" fails this criterion.
- [ ] The pivot decision is recorded: partner / build anyway / no reply by <date>. If "build anyway", the recorded reason names a segment or constraint, not a sunk cost.

## Traps

- **Writing the email in the voice of an insider.** The single fastest way to lose this reader permanently. If the developer is not autistic and not an AAC user, the email says so in the first three lines. Faking rapport with someone who has spent their life being talked down to is not a recoverable error.
- **Pitching instead of offering.** The post asks for beta testing and release support. An email that describes Reed for four paragraphs and offers help in the last line is an ask wearing a gift's clothes. Lead with the thing they asked for.
- **Treating "I'll ask them to test Reed" as collaboration.** That is recruiting an unpaid disabled tester for a competitor. It is the tokenism failure mode exactly, and it will be recognised as such.
- **Deferring the positionality answer until the listing is written.** By then the copy has already been drafted in some voice, and the voice will have leaked an implied claim. Decide first; the answer constrains every listing sentence downstream.
- **Path B without money.** "Advisory group" with no budget line is Path A with extra steps and worse faith. Either the figure is named or Path A is chosen.
- **Softening the true answer.** "I'm autistic-adjacent", "I have sensory stuff", "I've experienced something similar" — hedged identity claims read as claims, get treated as claims, and collapse under one follow-up question. Yes or no.
- **Letting the email imply a curated or safe vocabulary.** Reed has no content filter, ever — the majority ask from this population is a comprehensive adult-level lexicon including profanity, sex, medical and work vocabulary. Copy that hints at curation says the opposite of the product.
- **Overclaiming the evidence.** If the study comes up, it is *one small self-selected unrefereed preprint, n=12, all US, recruited via social media*, plus a second unrefereed n=5 text focus group. Say "12 of 12" or "10 of 12"; never "research shows" or "most users". This reader may well know the paper, and may well be in it.
- **Implying Reed is medical or emergency-grade.** Banned words hold in an email to a developer as much as in the listing: treats, therapy, improves language outcomes, clinically proven, diagnoses, prescribed, medical-grade, emergency. Intended purpose is set by "promotional or sales materials", and an email describing the product is exactly that.
- **Discovering the partnership is real and continuing anyway out of momentum.** The pivot criterion exists because this failure is quiet, feels like discipline, and costs a user population two half-built apps instead of one finished one.
- **Waiting for a reply as a blocker.** This task blocks nothing on purpose. Send it, record the decision date, keep building. A reply that lands in week three is still a pivot worth taking.

## Files

- `epics/E00-de-risking/T07-positionality-and-contact-the-aac-user-developer.md` — this file; the decision block gets filled in here.
- The sent email text, saved verbatim alongside this file.
- Nothing under `lib/`. No code changes.

## Done when

The email is sent, both identity questions are answered yes-or-no in writing, one of Path A or Path B is chosen with a date, and the pivot decision — partner, build anyway with a named reason, or no-reply-by-date — is recorded.
