# user-needs

> Phase: **research** · Agent `a817d8df3778a237c` · Run `wf_3a8e3c64-43a`

## Result

## Summary

The strongest evidence for this product comes from two recent HCI papers built on interviews with autistic adult AAC users — "Aging Up AAC" (Martin & Nagalakshmi, arXiv 2404.17730, n=12) and "The Role of AAC in Social Communication" (arXiv 2507.00202) — plus a 2025 metaphor analysis of autistic shutdowns in Autism in Adulthood. They validate the core thesis almost line by line: one participant said plainly, "Many AAC apps feel like they're made for kids or students, and it feels infantilizing," and another described the exact MVP as the unmet need — "Future AAC that has both symbols and typing and a vocabulary designed for autistic adults would be very empowering." Critically, shutdown is not one state but a spectrum: mild verbal shutdown leaves comprehension intact ("all your words are still there in your head... you just can't get your mouth to do it"), while deep shutdown degrades reading, decision-making, and voluntary movement ("Impossible to move"; "I can't decide which thoughts to prioritize, and I freeze"). This means category-diving is not merely slow — it is a decision tree presented to someone whose decision-making has failed. Two findings should reshape the plan: TTS voice quality is an abandonment trigger at the two-use mark, not a polish item; and 11 of 12 participants objected to data collection with 6 saying auto-personalization should *never* activate — so "offline" is validated, but so is a warning against prediction/adaptive-reordering features that would otherwise seem like obvious wins. The weakest link in my evidence is the app-launch barrier: it is strongly implied by motor freeze but I found no direct user testimony, and it needs validation before you build for it.

### Autistic shutdown is a spectrum, and in its deeper form it degrades reading comprehension, decision-making, and voluntary movement — not just speech production.

*Confidence: high, **LOAD-BEARING***

The 2025 metaphor analysis of autistic shutdowns (Autism in Adulthood, 'Shutdowns Are Like You're Stuck on the Blue Screen of Death') collects verbatim participant reports: 'Impossible to move'; 'I freeze like a statue and can't move by myself'; 'I can't decide which thoughts to prioritize, and I freeze while my brain is trying to sort it out'; 'The ability to notice I'm shutting down, shuts down too'; 'if I'm not mute, I'm a yes man'. Community sources add that receptive language can fail too: 'other people's speech around you can stop making sense.' This CONTRADICTS the milder framing in other sources, which hold comprehension intact — 'a traffic jam between thoughts and verbal expression' and 'All your words are still there in your head, you know what you want to say – you just can't get your mouth to do it.' Both are true at different depths. Design must serve the deep case, where text is unprocessable and choosing is itself impossible.

- https://journals.sagepub.com/doi/10.1089/aut.2024.0193

- https://weirdlysuccessful.org/verbal-shutdown/

- https://autismunderstood.co.uk/struggling-as-an-autistic-person/shutdowns/

- https://sensoryoverload.info/autism/autistic-shutdowns/

### The infantilization thesis is confirmed in users' own words, and the exact MVP (symbols + typing + adult vocabulary in ONE app) is named by a participant as the missing product.

*Confidence: high, **LOAD-BEARING***

From 'Aging Up AAC' (arXiv 2404.17730v3, n=12 autistic adult AAC users): 'Many AAC apps feel like they're made for kids or students, and it feels infantilizing' (5 participants reported child-oriented design failing adult needs). On the fragmentation that this product would fix: '[I dislike] symbols and typing being so completely separate in different apps,' and 'Future AAC that has both symbols and typing and a vocabulary designed for autistic adults would be very empowering.' This is close to a product spec written by a target user.

- https://arxiv.org/html/2404.17730v3

### TTS voice quality is an abandonment trigger, not a polish concern — one participant abandoned an app after TWO uses because the voice sounded like a child.

*Confidence: high, **LOAD-BEARING***

'My friend said it felt a little incongruous to hear a child's voice from [it]. So I only used AAC with them twice.' Voice is also identity: 'I am trans, but I deal with age dysphoria as well, which is part of why I like [this voice]'; 'Having a voice that sounds right is, therefore really, really important.' The paper also notes three participants faced extra charges for text-to-speech voices. The 'risk' listed in the brief ('TTS must sound acceptable') is understated — an age-inappropriate default voice re-creates the infantilization the product exists to escape, in the one channel bystanders actually hear.

- https://arxiv.org/html/2404.17730v3

### Users actively reject adaptive/learning/prediction features — offline is validated, but so is a prohibition on 'smart' personalization.

*Confidence: high, **LOAD-BEARING***

From 'Aging Up AAC': 11 of 12 participants expressed concerns about unauthorized data collection; 6 stated automatic personalization should NEVER activate. Verbatim: 'I don't like it when the way I use something automatically changes the way an app or website functions'; 'I turned off every single prediction that ClaroCom [has], including its built-in support for learning automatically'; 'I don't even like that it has those knobs. I'd rather it just plain didn't do any of that.' Separately, a participant cited 'needing to swap motor plans back and forth a lot' as a burden — meaning tiles that reorder by frequency/recency actively break the muscle memory this population relies on.

- https://arxiv.org/html/2404.17730v3

### The bystander problem is real but is primarily a SAFETY problem, not an awkwardness problem — and using AAC around authority figures can feel dangerous rather than helpful.

*Confidence: high, **LOAD-BEARING***

This complicates the brief's assumption. From arXiv 2507.00202: 'It is not safe for me to communicate in a "more disabled" looking manner to people who have the power to do things that could cost me too dramatically much' (P1). From 'Aging Up AAC': 'I don't use AAC [...] when there are people who have dramatic power over me who can drastically control my life.' Fear also blocks use even when the tool is present: 'I have a communication book that I carry with me, but I've not been brave enough to use it' (P5). Counterintuitively, 2507.00202 found participants were MORE comfortable disclosing to strangers they'd never see again. Implication: a bystander card must do the explaining *on the user's behalf* (a static, authoritative-looking statement) rather than requiring the user to perform disability live.

- https://arxiv.org/html/2507.00202v1

- https://arxiv.org/html/2404.17730v3

### There is an established low-tech incumbent for the bystander problem — printed autism/non-speaking alert cards — confirming demand but setting a reliability bar the app must beat.

*Confidence: high, **LOAD-BEARING***

Cards stating 'I have Autism and am Non Speaking' with 'how to help' guidance on the reverse are widely sold (Etsy, Amazon) and institutionally endorsed: the Pennsylvania State Police unveiled an informational card program with advocates, directing officers to be patient, use a calm direct voice, and keep questions simple. Meanwhile a participant in 'Aging Up AAC' said they 'always have and always will carry pen and paper just because it's the most reliable.' The app is competing with paper, which never fails to boot, never dies, and never needs unlocking.

- https://www.pa.gov/agencies/psp/newsroom/after-meeting-with-advocates--pennsylvania-state-police-unveils-

- https://www.etsy.com/listing/1867756207/personalized-autism-medical-alert-card

- https://arxiv.org/html/2404.17730v3

### The phone gets physically handed to other people — the app must have a 'show, don't speak' mode and must not leak private content when handed over.

*Confidence: medium, **LOAD-BEARING***

From 'Aging Up AAC': 'Sometimes my AAC use involves handing my phone to another person for them to read and I always have to trust...' [quote truncated in source]. This is a distinct interaction mode from speaking aloud, and it matters in loud shops, in ERs, and where speaking aloud would draw attention. It also means a handed-over phone should not expose notifications, message history, or other apps.

- https://arxiv.org/html/2404.17730v3

### Speed is the #1 cited functional issue, and 'speed' explicitly includes finding words on boards and app-switching overhead — not just words-per-minute.

*Confidence: high, **LOAD-BEARING***

'Aging Up AAC': 11 of 12 participants cited speed as a critical issue — 'not just communication speed, but also locating words on boards and input method delays,' with 'infrastructure overhead of setup and switching between applications' creating friction that prevented adoption. Broader AAC literature: speech-generating devices run 8-10 words per minute conversational throughput. This directly justifies a flat, no-dive first screen and in-app typing.

- https://arxiv.org/html/2404.17730v3

- https://ussaac.org/speakup/articles/key-aac-issues/

- https://senmagazine.co.uk/content/tech/assistive-tech/28585/aac-abandonment/

### AAC abandonment runs roughly one-third to one-half of users, driven by stigma, speed, cost, and programming difficulty — and for adults specifically, by absent professional support.

*Confidence: high, **LOAD-BEARING***

AAC abandonment occurs in ~1/3 of client cases; up to 50% of users/families abandon or underuse. Drivers: stigma ('carrying an AAC signals that one is incapable'), slow throughput, expense, difficulty programming. 'Aging Up AAC' adds adult-specific drivers: poor customer support, unfixed bugs, device restrictions, voice quality, and limited institutional support for adults — 'I am by far not the only adult autistic AAC user who feels like Coughdrop support kinda blows us off,' and 'In my experience, [...] speech therapists were not helpful.' Note the implication for a solo indie build: unresponsive support is itself a named abandonment cause.

- https://ussaac.org/speakup/articles/key-aac-issues/

- https://senmagazine.co.uk/content/tech/assistive-tech/28585/aac-abandonment/

- https://arxiv.org/html/2404.17730v3

- https://scholars.unh.edu/thesis/385/

### Cost and iOS-exclusivity are confirmed as concrete access blockers, and users carry PHONES not tablets — validating the Flutter phone-first, cheap/free strategy.

*Confidence: high, **LOAD-BEARING***

'Aging Up AAC': 10 participants emphasized affordability as crucial; 5 avoided full-price expensive applications; 4 gravitated toward free options; 4 specifically mentioned iOS-only restrictions preventing access to preferred apps. On form factor: 'I don't take my iPad with me [...] most of the time. It was expensive, and I don't want to break it.' The premium AAC market's ~$299 iPad-centric model fails on exactly the axis where situational users need it — the device that is physically on you during an unplanned shutdown is the phone.

- https://arxiv.org/html/2404.17730v3

### Part-time AAC users have a distinct identity problem full-time users don't: they are disbelieved and pushed back toward speech because they CAN talk.

*Confidence: high, **LOAD-BEARING***

AssistiveWare and PrAACtical AAC frame three patterns: intermittent ('I can talk, but only sometimes'), unreliable ('may say things that do not match their intended meaning'), and insufficient speech. User language: 'just because I can say some of the things and even sound fluent, that doesn't mean I can tell you what I need'; 'When you have issues connecting head words to mouth words, it can be hard to EXPRESS that it is hard for you'; 'My brain connects words better to my eyes and fingers than my mouth; it takes less energy to communicate precisely using AAC.' From the ASHA/Autistic Nottingham material: 'My speech was exhausting, and didn't feel natural. I did it because it was the only thing people would respond to,' and 'I primarily tried to use nonspeech forms of communication when I could but everyone else pushed for speech.' Product angle: the app's framing/copy should legitimize part-time use, because users arrive carrying internalized doubt about whether they're 'allowed' to use it.

- https://www.assistiveware.com/learn-aac/support-communication-for-part-time-aac-users

- https://praacticalaac.org/praactical/praactical-perspectives-on-part-time-aac-use/

- https://autisticnottingham.blog/2021/09/20/autistic-adults-aac/

### Setup burden is a real trap: users spend heavy time configuring boards and then can't remember their own layout.

*Confidence: high, **LOAD-BEARING***

'Aging Up AAC': 4 participants reported spending considerable time setting up applications and creating boards; 3 noted difficulty remembering where everything is and what capabilities exist. Import/export is broken across the ecosystem: 'There's an option to import boards, but where am I importing them from?'; 'It's not transparent as to what format it's in'; 'And you can't import a Proloquo board to Speech Assistant. I wish there was a standard.' Implication: ship an opinionated adult default phrase set that works on first launch with zero configuration — customization is a calm-state activity, never a prerequisite.

- https://arxiv.org/html/2404.17730v3

### Dark, low-stimulus visual design is a functional sensory accommodation with direct user evidence — not just an adult aesthetic preference.

*Confidence: high, **LOAD-BEARING***

'Aging Up AAC': 7 participants wanted interfaces that didn't feel overwhelming; 4 preferred clear layout/fewer options; 3 disliked bright colors PARTICULARLY WHEN OVERWHELMED — i.e., exactly at the moment of use. Independently, bright phone screens (especially in dark environments) are documented sensory-overload triggers, and high-pitched phone sounds are named as distressing. The 'dark, calm' design choice in the brief is therefore load-bearing accessibility, and the app's own TTS output is itself a potential aversive stimulus needing prominent volume control.

- https://arxiv.org/html/2404.17730v3

- https://autismguide.co.uk/sensory-issues/autistic-triggers-for-meltdowns-visual-sensory-overload/

- https://www.autism.org.uk/advice-and-guidance/topics/sensory-differences/sensory-differences/all-audiences

- https://riseupforautism.com/blog/autism-and-sound-sensitivity

### Symbol-based AAC is reported as the easiest modality DURING a meltdown/shutdown specifically, while text is preferred when there is time to process.

*Confidence: medium, **LOAD-BEARING***

Reported from the 'Everyone Deserves AAC' study line of work: 'Some participants reported symbols-based AAC as the easiest to use during a meltdown/shutdown, while others reported writing online and texting as their preferred method to allow time for processing information.' This maps cleanly onto a two-modality app: symbol/phrase tiles for crisis, type-to-speak for considered communication. It also supports icons on tiles being functional (not decorative) — they carry meaning when text processing has degraded.

- https://pubs.asha.org/doi/10.1044/2021_PERSP-20-00220

- https://autisticnottingham.blog/2021/09/20/autistic-adults-aac/

- https://www.assistiveware.com/learn-aac/support-communication-for-part-time-aac-users

### Confirmed one-tap phrases reported in the literature are few and blunt: 'too loud', 'I need a break', 'I want to go'. A comprehensive validated phrase list for adults does NOT exist in public sources.

*Confidence: low, **LOAD-BEARING***

Directly attested one-tap messages: 'too loud,' 'I need a break,' 'I want to go' — framed as reducing escalation 'before distress turns into shutdown or meltdown.' 'Aging Up AAC' confirms 10 of 12 participants pre-program whole phrases and commonly-used messages ahead of time, but the paper explicitly does not enumerate which phrases. Other attested needs implying tiles: 'I can talk, but only sometimes'; 'I can't tell you what I need.' This is the largest content gap: the phrase set is the product's core IP and cannot be sourced from literature. It must come from direct community consultation (r/AutisticAdults, r/selectivemutism) before launch. Building it from assumption is the highest-risk shortcut available here.

- https://joyrealtoys.com/blogs/news/how-aac-devices-help-autistic-individuals-manage-overwhelm

- https://arxiv.org/html/2404.17730v3

- https://praacticalaac.org/praactical/praactical-perspectives-on-part-time-aac-use/

### A user-facing manual 'shutdown mode' (simplified interface) is an idea already surfaced in the research — but the research framed it as AI-detected, which conflicts with users' rejection of automatic adaptation.

*Confidence: medium, **LOAD-BEARING***

From the AAC-for-autistic-adults literature: 'An AAC system designed for autistic people who experience shutdown could provide both detailed controls and a simplified interface, with AI learning to switch to the simplified interface if it detects shutdown and needs less stimulation.' Given that 6 of 12 participants in 'Aging Up AAC' said automatic personalization should never activate, the correct synthesis is a manually-triggered, user-controlled simplified mode — the feature is validated, the automation is not.

- https://arxiv.org/pdf/2507.00202

- https://arxiv.org/html/2404.17730v3

### App-launch as a barrier is strongly IMPLIED by motor freeze and decision paralysis, but I found NO direct user testimony confirming it. This is the biggest unvalidated assumption in the brief.

*Confidence: low, **LOAD-BEARING***

The inference chain is sound: participants report 'Impossible to move' and 'My body freezes while my brain tries to decide what to do,' and 11/12 cited app-switching infrastructure overhead as adoption-preventing friction. But no source I reached says 'I couldn't open my AAC app in time.' Searches for lock-screen/widget AAC access returned only product marketing; no AAC app appears to advertise lock-screen or widget entry. Reddit — the richest vein of first-person testimony on exactly this — is blocked to my crawler, so I could not retrieve r/autism or r/selectivemutism threads directly; all first-person quotes here are second-hand via academic papers and AAC organizations. Treat 'app-launch is a barrier' as a plausible hypothesis to test with users, not an established finding. If true, it also implies a pre-shutdown workflow (open the app when you feel it coming) may matter more than fast launch — but 'The ability to notice I'm shutting down, shuts down too' undercuts that too.

- https://journals.sagepub.com/doi/10.1089/aut.2024.0193

- https://arxiv.org/html/2404.17730v3

- https://www.speechandlanguagekids.com/aac-apps-review/

### Fine motor impairment is common in autism and correlates with verbal ability, but the best evidence I found is in youth and is not shutdown-specific.

*Confidence: medium*

Beyond Words (PMC11148429): 80% of autistic participants showed impairment on at least one motor measure vs 47.6% of controls — deficits in dominant-hand finger tapping, bilateral fine motor dexterity (grooved pegboard), and pencil motor coordination; impaired fine motor skills associated with 'poorer performance on standardized clinical measures of verbal abilities.' IMPORTANT CAVEAT: sample was 97 autistic YOUTH aged 8-17, not adults, and this is a correlational baseline study — it says nothing about motor precision during a shutdown. It supports generous touch targets as a baseline; it does not quantify in-distress motor precision, which remains unmeasured. Separately, 'Aging Up AAC' notes 3 of 12 participants required indirect selection methods due to dynamic disabilities (seizures, hemiparesis) — relevant to the post-seizure segment in the brief.

- https://pmc.ncbi.nlm.nih.gov/articles/PMC11148429/

- https://arxiv.org/html/2404.17730v3

### All 12 participants in the key study wanted keyboard input available — type-to-speak is not a secondary feature to the tile grid.

*Confidence: high, **LOAD-BEARING***

'Aging Up AAC': all 12 participants expressed preferences for keyboard input options (3 preferred physical keyboards, 8 preferred on-screen). Verbatim: 'I can type on a phone, but I type 100 words a minute on a regular keyboard so that's always gonna be my preference'; 'Sometimes I talk faster than I think and struggle to explain a complex idea, and AAC lets me collect thoughts clearly.' Typing serves a cognitive function beyond speech replacement — it externalizes and organizes thought.

- https://arxiv.org/html/2404.17730v3

## Product implications

- **[must-have-mvp]** Flat, zero-dive first screen: every crisis phrase reachable in ONE tap, no categories above it. Categories may exist only BELOW the flat crisis layer.
  - Category diving asks the user to make a decision. In shutdown, decision-making is the specific faculty that fails: 'I can't decide which thoughts to prioritize, and I freeze while my brain is trying to sort it out.' A menu tree is not slow-but-usable; it is a wall. This is the single highest-leverage design decision in the product.
- **[must-have-mvp]** Tile positions are FIXED and never reorder — no frequency sorting, no recents, no adaptive layout. Position is the interface.
  - Users rely on motor plans ('needing to swap motor plans back and forth a lot' was named as a burden) and report 'difficulty remembering where everything is.' A tile that moves breaks muscle memory precisely when muscle memory is all that remains. This also happens to be free to implement — it is a decision not to build something.
- **[must-have-mvp]** Every tile carries a symbol/icon AND text, with the icon meaningful enough to work alone.
  - Deep shutdown can degrade reading ('other people's speech around you can stop making sense'), and symbol-based AAC is reported as the easiest modality during a meltdown/shutdown specifically. Icons here are load-bearing function, not decoration — but they must be adult iconography, since child-styled symbols are the exact abandonment trigger.
- **[must-have-mvp]** Ship a high-quality, age-appropriate default voice and let users choose/preview voices before first use. Budget real engineering time for on-device TTS quality.
  - A participant abandoned an app after TWO uses because the voice sounded like a child to their friend. Voice is also identity ('Having a voice that sounds right is, therefore really, really important'). An infantile default voice recreates the exact harm the product exists to solve, in the only channel bystanders perceive. The brief lists this as a risk; the evidence says it is a top-three abandonment cause.
- **[must-have-mvp]** Type-to-speak lives in the same app, one tap from the grid — never a separate app or a mode switch.
  - All 12 participants wanted keyboard input; the most explicit product wish in the literature is 'Future AAC that has both symbols and typing and a vocabulary designed for autistic adults would be very empowering,' against the complaint that 'symbols and typing [are] so completely separate in different apps.' App-switching overhead was named as adoption-preventing. This is the product's clearest differentiator and it is cheap.
- **[must-have-mvp]** Ship an opinionated adult default phrase set that is fully functional on first launch. Zero configuration before first use. Customization is a calm-state activity.
  - 4 participants spent considerable time on setup and 3 then couldn't remember their own layout. A user downloading this app may be doing so BECAUSE they just had an episode. An app that demands board-building before it can speak has failed the core job. Editable categories stay in the MVP — but as an optional later step, not a gate.
- **[must-have-mvp]** A full-screen, high-contrast 'I am autistic and cannot speak right now' bystander statement — designed to be READ off a handed-over phone, not spoken.
  - Printed autism/non-speaking alert cards are a real established market (Etsy, Amazon, PA State Police program), proving demand. Users physically hand phones to others ('Sometimes my AAC use involves handing my phone to another person for them to read'). Critically, it must do the explaining FOR the user — because using AAC in front of authority is experienced as a safety risk ('It is not safe for me to communicate in a "more disabled" looking manner to people who have the power...'), and because fear blocks use even when a tool is present ('I've not been brave enough to use it').
- **[must-have-mvp]** Dark, low-luminance, muted palette with a genuinely dim minimum brightness. Prominent, reachable TTS volume control.
  - 3 participants disliked bright colors 'particularly when overwhelmed' — i.e., at the exact moment of use; 7 wanted non-overwhelming interfaces. Bright phone screens are a documented overload trigger. Also note the app's own speech output is a sound stimulus and high-pitched phone sounds are documented as distressing — the app can itself become aversive if it speaks loudly into a sensory crisis.
- **[must-have-mvp]** No account, no cloud, no telemetry — and say so in plain language on the first screen.
  - 11 of 12 participants raised unauthorized data-collection concerns. This is already the plan; the finding is that it should be marketed loudly as a feature to this audience, because it directly addresses a stated fear rather than being invisible plumbing.
- **[must-have-mvp]** Large touch targets, bottom-weighted layout for one-handed thumb reach, generous spacing, forgiving hit areas.
  - Motor impairment is common in autism at baseline (80% impaired on at least one measure — though in a youth sample), 3 of 12 participants needed indirect selection due to seizures/hemiparesis, and shutdown involves motor freeze. In-distress motor precision is genuinely unmeasured, so design conservatively: assume worse precision than you think.
- **[should-have-v1]** A manually-triggered 'shutdown mode' that strips the UI to the largest, fewest, most essential tiles.
  - The simplified-interface-for-shutdown concept already appears in the research. But the literature proposed AI-detecting the shutdown, which directly conflicts with users rejecting automatic adaptation (6 of 12: auto-personalization should never activate). Ship the feature, reject the automation — a manual toggle the user controls.
- **[should-have-v1]** Home-screen widget / quick-launch entry — but VALIDATE the launch-barrier hypothesis with users before investing heavily.
  - This is the brief's most confident assumption and my least confident finding. Motor freeze and decision paralysis strongly imply launch is a barrier, and no competitor appears to offer widget/lock-screen entry (a possible moat). But no user testimony I could reach states it, and Reddit — where that testimony would live — was inaccessible to me. Test before building; the answer may instead be 'the phone is already unlocked and in hand' or 'someone else opens it for me.'
- **[should-have-v1]** Copy and onboarding that explicitly legitimize part-time use — 'you can talk sometimes and still need this.'
  - Part-time users are disbelieved and pushed back to speech ('everyone else pushed for speech'; 'My speech was exhausting... I did it because it was the only thing people would respond to') and arrive carrying internalized doubt ('I USED TO have negative beliefs about AAC'). The barrier to adoption here is permission, not features — and it costs only words to address.
- **[nice-to-have-later]** Import/export of phrase boards via a documented open format.
  - A named ecosystem pain point ('you can't import a Proloquo board to Speech Assistant. I wish there was a standard'; 'It's not transparent as to what format it's in'). Real, but it serves existing AAC users migrating in — not the first-time situational user who is the MVP target. Later.
- **[explicitly-avoid]** Do NOT build word prediction, usage-learning, adaptive tile ordering, or auto-personalization.
  - This is the strongest counterintuitive finding. These read as obvious product wins but are actively unwanted: 'I turned off every single prediction that ClaroCom [has]'; 'I don't even like that it has those knobs. I'd rather it just plain didn't do any of that'; 6 of 12 said auto-personalization should never activate. They also break motor plans. Not building them saves effort AND improves the product — take the win.
- **[explicitly-avoid]** Do NOT add cartoon avatars, mascots, bright primary colors, gamification, rewards, or celebratory animation.
  - 'Many AAC apps feel like they're made for kids or students, and it feels infantilizing.' This is the core wedge. Any single childish element risks reproducing the whole problem — and stigma is a documented abandonment driver ('carrying an AAC signals that one is incapable').
- **[explicitly-avoid]** Do NOT gate the app behind a tablet-class experience or iOS-first release; phone-first, Android and iOS together, cheap or free.
  - 4 of 12 participants were specifically blocked by iOS-only apps; 10 emphasized affordability, 5 avoided full-price apps, 4 gravitated to free. And the tablet isn't there when needed: 'I don't take my iPad with me most of the time. It was expensive, and I don't want to break it.' Situational speech loss is unplanned — only the phone is present. Flutter is the right call.
- **[should-have-v1]** Plan for responsive user support, or be honest that you can't provide it.
  - Uncomfortable finding for a 50-app-challenge project: unresponsive support is a named abandonment cause in this exact population — 'I am by far not the only adult autistic AAC user who feels like Coughdrop support kinda blows us off.' Users are building dependence on this for a disability accommodation. An abandoned app is worse here than in most categories; the offline/no-account architecture at least means it keeps working if you stop maintaining it, which is an ethical argument for offline beyond privacy.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
PRODUCT IDEA UNDER RESEARCH — "Dignified offline AAC for adults & teens with situational speech loss"

Who it's for: Autistic adults and teens who go non-speaking during shutdowns/meltdowns/sensory overload, plus people with selective mutism, aphasia, or post-seizure speech loss. Communities: r/autism, r/AutisticAdults, r/selectivemutism, AAC communities.
The problem: Mainstream AAC apps are built for young children — cartoon avatars, "parental" account gates, kiddie vocabulary — infantilizing for adults, so they abandon them. Premium options (Proloquo2Go/TouchChat/LAMP) run ~$299 and are iOS-only.
Why offline is essential: It's a disability accommodation, not a networked service. The user must be able to "speak" instantly — in a shop, an ER, a car with no signal, mid-shutdown — with zero login, zero loading, full privacy.
The core job: Tap a phrase/symbol tile (or type) and the phone speaks it aloud, instantly, offline, adult-appropriate design, no account.
MVP: grid of large customizable phrase tiles + "type to speak" box + on-device TTS. Editable categories. No sign-up. Nothing leaves device. Dark, calm, adult visual design.
Risks: TTS must sound acceptable; design must feel adult without being cold; must be usable one-handed by someone in distress.
Target stack: Flutter (cross-platform iOS + Android; user prefers Flutter over React Native).
Today's date: 2026-07-15. Prefer recent sources (2024-2026).


YOUR DIMENSION: The real lived needs of adults with SITUATIONAL / intermittent speech loss.

Research deeply using WebSearch and WebFetch. Look for first-person accounts (Reddit r/autism, r/AutisticAdults, r/selectivemutism, r/aphasia, AAC user blogs, AssistiveWare's "AAC user" content, Twitter/X threads, forums), academic literature on "part-time AAC users", "situational mutism", "autistic shutdown communication", "intermittent speech loss".

Answer specifically:
- What actually happens cognitively/motorically during an autistic shutdown or meltdown? Can the person read? Can they navigate menus? Can they type? What motor precision remains? Does the app need to work when the user CANNOT process text?
- What do part-time/ambulatory AAC users say they need that full-time AAC users don't? (e.g., fast onboarding into the app mid-episode, no category diving, explaining to others why you're using a phone)
- What is the "explain to bystanders" problem? Do users need a way to tell a stranger/cop/doctor "I am autistic and cannot speak right now"? How important is this?
- What are the specific highest-frequency phrases these users report needing? Gather ACTUAL reported phrase lists.
- What causes abandonment of AAC by adults? Gather specifics.
- How do users get INTO the app during a shutdown? (lock screen, widget, watch, launch time) Is app-launch itself a barrier?
- What role does the phone's existing behavior play (notification sounds, brightness) during sensory overload?

Return concrete, sourced findings. Quote real user language where you find it.
````

</details>
