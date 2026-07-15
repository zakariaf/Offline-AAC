# failure-modes

> Phase: **research** · Agent `a0855ad0913f36651` · Run `wf_3a8e3c64-43a`

## Result

## Summary

The premise contains a factual error that undermines the whole thesis: the claim that adult AAC means "$299, iOS-only, built for children" is false. Speech Assistant AAC is free on Android / €23.99 one-time on iOS, no account, fully offline, adult-targeted, text-first, with categories, phrase tiles, type-to-speak — and an Apple Watch app. That is the described MVP, already shipped, cheaper, on more platforms. Meanwhile iOS Live Speech gives type-to-speak free at the OS level with Personal Voice, and Emergency Chat has owned the autistic-shutdown "hand someone your phone" niche free since 2015. Second, the core assumption may be inverted: in the best available research on this exact population (Zhang et al., CHI 2024, n=12 autistic adults), 8/12 use text display instead of or alongside TTS and 3/12 prefer showing text for most or all communication; there is documented stigma against AAC *apps* but not against *writing*; and for selective mutism, speech output can raise anxiety rather than reduce it. For autistic sensory shutdown specifically, TTS emits an auditory stimulus into the exact channel that is already overloaded — the app's core action can worsen the state it is meant to relieve. Third, the two hardest problems (crisis-time discoverability and voice-as-identity) are both solved by native OS surfaces — widgets, Action Button, Back Tap, watch complications, Personal Voice — which is precisely where Flutter is weakest, so the stack choice fights the top two risks. Finally, monetization is close to hopeless: ~75-85% of autistic adults are unemployed or underemployed and only ~14-16% hold full-time work, and the incumbents are free. Treat this as a reputation/portfolio or grant project, not a business. There is a real product here, but it is not "adult AAC tiles" — it is situational speech loss, where the user can speak 90% of the time, which means the single strongest unexplored move is record-your-own-voice-in-calm-state, and the strongest unbuilt feature is post-crisis phrase capture.

### The stated competitive premise is factually wrong: a free, offline, no-account, adult-targeted, cross-platform AAC app with phrase tiles, categories and type-to-speak already exists and is the described MVP

*Confidence: high, **LOAD-BEARING***

Speech Assistant AAC (asoft.nl): basic Android version FREE with one-time in-app upgrade, iOS €23.99 one-time, explicitly no subscription and no account. Works fully offline. Create categories and subcategories, save phrases on buttons for quick access, plus type-to-speak. Explicitly targets adults with aphasia, autism, stroke, MND/ALS, cerebral palsy. Reviewers describe it as 'aimed at adults or teens without learning disabilities, no images' and 'a fantastic, affordable alternative to Proloquo4Text.' Runs on iPhone, iPad, Mac (Apple silicon) AND Apple Watch (watchOS 9+) — meaning it already solves the crisis-discoverability problem the founder has not yet addressed. Also Spoken - Tap to Talk AAC: free tier, explicitly for 'adults and teenagers', word suggestions. The $299/iOS-only framing describes Proloquo2Go/TouchChat/Avaz — the symbol-based child market — not the adult text-to-speech niche this MVP actually enters. Every stated differentiator (adult design, offline, no account, cross-platform, cheap) is already on the shelf.

- https://asoft.nl/

- https://play.google.com/store/apps/details?id=nl.asoft.speechassistant

- https://apps.apple.com/us/app/speech-assistant-aac/id1139762358

- https://spokenaac.com/best-aac-for-android/

- https://www.assistiveware.com/products/proloquo4text

### The core assumption is partially inverted: the majority of autistic adult AAC users show text rather than (or as well as) speaking it, and there is stigma against AAC apps but NOT against writing

*Confidence: high, **LOAD-BEARING***

Zhang et al. (arXiv 2404.17730, CHI-track study of 12 autistic adults who use AAC): 8/12 use text display features instead of or alongside TTS; 3/12 prefer showing text for most or all communication. Drivers: 10/12 had TTS intelligibility concerns, 7/12 said voices were 'hard to understand or hard to hear', 6/12 said devices could not produce adequate volume — i.e. the loud-robot-voice-in-a-shop scenario measurably fails for its advocates. The stigma finding is direct: 'there is a lack of stigma against writing (vs an application)', 4/12 avoid social situations entirely to dodge reactions to their device, one reports 'people hear it and laugh because they think I'm making a joke', and 11/12 only use AAC in environments they perceive as safe ('when there are people who have dramatic power over me... my trauma tells me it is actively not safe'). A second 2025 study (arXiv 2507.00202) found participants 'strongly preferred asynchronous text-based communication' and one carried a communication book but 'I've not been brave enough to use it.' BUT do not over-rotate: the same paper documents that showing text fails too — screens too small, sun glare, impossible with groups (2/12), and handing your device to a stranger raises security concerns. The honest conclusion is not 'drop TTS'; it is that TTS-first is wrong. This is a display-first, speak-optional communicator, and 'show, don't speak' is a co-equal MVP mode, not a v2 nice-to-have.

- https://arxiv.org/html/2404.17730v1

- https://arxiv.org/html/2507.00202v2

### For autistic sensory shutdown specifically, TTS output is an auditory stimulus injected into the exact sensory channel that is already overloaded — the core action can worsen the state it treats

*Confidence: medium, **LOAD-BEARING***

This is a reasoned inference the founder has not made and no reviewed source states outright, but it follows directly from the mechanism: shutdown is frequently triggered or sustained by sensory overload including auditory load, and the product's core interaction is 'the phone speaks it aloud' in a shop or ER — adding noise, plus the social attention that follows the noise, plus the startle of one's own device speaking. Converging evidence: 11/12 only use AAC where they feel safe; one participant called automatic word-by-word speech output 'infantilizing'. For selective mutism the same logic is documented rather than inferred — CALL Scotland notes SM is anxiety-driven, that a speech-producing device 'might increase stress rather than help if the person associates speaking (even through a device) with their anxiety triggers', and that one practitioner found AAC with speech output didn't help because individuals wouldn't use devices in anxiety-triggering environments. Their recommendation for SM is text-based solutions. Silent modes (screen display, haptics-only confirmation) are therefore a clinical requirement, not a preference.

- https://www.callscotland.org.uk/blog/selective-mutism-and-technology/

- https://arxiv.org/html/2404.17730v1

### The 'never opened until crisis' problem is close to fatal to the product as positioned, and muscle memory is not a myth — it is real, which is exactly why crisis-only positioning fails

*Confidence: high, **LOAD-BEARING***

Muscle memory works, but requires regular use, and an app used only in crisis by definition never gets regular use. This is a closed vicious circle. Direct evidence: 11/12 frustrated with communication slowness, 6/12 struggle locating symbols, one states plainly 'would need to use it regularly enough to memorize the symbol locations', and 3/12 struggle to remember where features are. Compounding it, shutdown involves executive-function collapse, and retrieval requires a chain of: remember the app exists → unlock phone → find icon → navigate → find phrase. Each link is a failure point at the moment capacity is lowest. The only escape is to stop positioning it as a break-glass tool and design for everyday low-demand use (tiredness, 'I don't want to talk right now', partial speech days) so the motor pattern is rehearsed — which also matches 'situational speech loss' being a spectrum rather than a binary. Assistive-tech abandonment data underlines the stakes: ~30% of AAC users abandon their systems, only ~39% still use AAC a year after introduction, and >35% of assistive devices go unused — most within the first three months.

- https://arxiv.org/html/2404.17730v1

- https://pubmed.ncbi.nlm.nih.gov/10171664/

- https://www.theaacacademy.org/course/what-leads-to-aac-abandonment

### Flutter is the wrong stack for this specific product: the top two risks are both solved by native OS surfaces where Flutter is weakest

*Confidence: medium, **LOAD-BEARING***

Risk #1 (crisis discoverability) is solved by Lock Screen widgets, Control Center controls, iOS Action Button, Back Tap, Accessibility Shortcut triple-click, App Intents, and watch complications — all of which require native Swift/Kotlin work that Flutter does not cover; Flutter gives you the one surface (the app's own UI) that is least useful when the user cannot remember the app exists. Note the incumbent already ships an Apple Watch app. Risk #2 (voice = identity) requires Apple Personal Voice, which third-party apps CAN use via AVSpeechSynthesizer.requestPersonalVoiceAuthorization + filtering AVSpeechSynthesisVoice.speechVoices() for the .isPersonalVoice trait — but there is no evidence flutter_tts exposes this, so it needs a custom platform channel. flutter_tts is also documented as having platform-variable voice quality, iOS-specific output bugs, and a general warning that TTS engines 'vary heavily between iOS and Android'. Cross-platform reach is being bought at the price of the two features that determine whether the product works at all.

- https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/personalvoiceauthorizationstatus

- https://developer.apple.com/videos/play/wwdc2023/10033/

- https://github.com/dlutton/flutter_tts

- https://pub.dev/packages/flutter_tts

- https://asoft.nl/

### Yes — shipping only OS voices IS a dignity failure, and it is the infantilization problem wearing a different mask

*Confidence: high, **LOAD-BEARING***

The founder's hypothesis is correct and the evidence is blunt. One participant: 'It's very personal and having the voice that matches every other person who uses AAC is very disempowering.' 4/12 specifically flagged that nonbinary and middle-pitch voice options are severely lacking. A trans participant experiencing both gender and age dysphoria: 'Having a voice that sounds right is, therefore really, really important.' OS voice sets are a small, fixed, binary-gendered menu — so an OS-voices-only app hands every user the same handful of identities and tells adults which voices they are allowed to have. That is the same paternalism as cartoon avatars. Cheap partial mitigation: expose pitch/rate/volume controls to synthesize the middle-pitch androgynous voices users explicitly ask for and the OS does not provide. Real mitigations: Personal Voice on iOS (native channel), or bundle on-device neural voices (Piper-class) with androgynous options — at the cost of ~tens of MB per voice, added latency and battery. Android has no Personal Voice equivalent, so the Android build is structurally condemned to a worse dignity experience; that asymmetry should be stated openly rather than papered over.

- https://arxiv.org/html/2404.17730v1

- https://www.apple.com/newsroom/2023/05/apple-previews-live-speech-personal-voice-and-more-new-accessibility-features/

- https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/personalvoiceauthorizationstatus

### The biggest unexploited insight: this population can speak most of the time, so they can record their own real voice in advance — which deletes the TTS quality risk and the voice-identity risk simultaneously

*Confidence: medium, **LOAD-BEARING***

Situational speech loss is definitionally intermittent — unlike the congenitally non-speaking children's AAC market, these users have a working, authentic voice on a normal day. Recording your own phrases in calm state and replaying them in crisis means: no synthetic voice, no dignity compromise, no TTS intelligibility problem (7/12 found voices hard to understand), no Personal Voice API dependency, no Android/iOS asymmetry, no model download, near-zero latency, trivially offline. It is also the only approach where the voice heard in the shop is unambiguously the user's own. No children's AAC app has this because their users cannot do it. Caveats to respect: some users find hearing their own recorded voice uncanny or dysphoric, and post-shutdown it can feel 'fake' or like a performance of a self they cannot currently access — so it must be an option alongside TTS, never the default, and never the only path. It also does not help aphasia users who cannot author fluently. Also solves an adjacent problem: a trusted person's recorded voice is an option for users who want that.

- https://arxiv.org/html/2404.17730v1

- https://arxiv.org/html/2507.00202v2

### Monetization is close to hopeless and should be abandoned as a goal: the audience is the poorest disability cohort and the incumbents are free

*Confidence: high, **LOAD-BEARING***

Roughly 75% of autistic adults in the US are unemployed or underemployed; estimates of unemployment alone range from ~40% to ~85% depending on method; only about 14-16% hold full-time paid work, and even among college-educated autistic adults only ~15% are fully employed. Willingness to pay is irrelevant when ability to pay is absent. Stacked against free Speech Assistant AAC (Android), free Emergency Chat, free iOS Live Speech and a free Spoken tier, the price ceiling is effectively zero. Worse, the $299 Proloquo resentment the founder cites is precisely a resentment about monetizing a disability accommodation — charging this community for the ability to speak carries real reputational risk in a highly networked, vocally anti-exploitation audience that will discuss you on r/AutisticAdults. The 2024 study's own list of desired features includes 'affordability: free or low-cost options with robust feature sets'. Viable shapes: free with optional tip jar; one-time small unlock ($5-15) for editor conveniences with the speaking screen NEVER gated; or grant/institutional funding. Subscriptions are disqualifying. Realistically: build this as a portfolio and reputation project, not a business.

- https://mydisabilityjobs.com/statistics/autism-employment/

- https://en.wikipedia.org/wiki/Employment_of_autistic_people

- https://arxiv.org/html/2404.17730v1

- https://asoft.nl/

### Emergency Chat already owns the exact 'autistic shutdown, hand someone your phone' niche, is free, was built by an autistic adult, and has been shipping since ~2015

*Confidence: high, **LOAD-BEARING***

Created by Jeroen De Busser after a meltdown where he went nonverbal and friends couldn't help. Opens straight to a customizable explanation screen designed to be handed to a stranger, then drops into a chat view where the owner types and the other person reads/responds. Free, Android and iOS. Its founder-credibility ('made by one of us') is an asset that a new entrant cannot buy — and in this community, provenance matters as much as features. Useful caveat from a reviewer: 'there are a very limited number of people who could make use of it, and really the most useful part is the text explaining your condition' — i.e. the explain-my-situation screen carried more value than the chat itself, which is a strong hint that the highest-value artifact is a static, instantly-readable explanation card, not an interactive system.

- https://lifeonautism.wordpress.com/2016/10/06/aac-app-review-emergency-chat/

- https://www.upworthy.com/an-autistic-man-made-an-app-to-help-people-help-him-during-panic-attacks

### iOS Live Speech beats the proposed app on the two axes that matter most — crisis access and voice identity — and it is free and pre-installed

*Confidence: high, **LOAD-BEARING***

Live Speech: type-to-speak in person and on calls, invoked via the Accessibility Shortcut (triple-click side button) so there is no app to find, no icon to remember, no unlock-navigate-hunt chain — it is available at the moment of need in a way an installed Flutter app structurally cannot match. It supports Personal Voice, which as of 2025 generates a natural-sounding voice from ~10 recorded phrases in under a minute, entirely on-device, with voice data never leaving the device. Apple's trajectory is explicit: 'features that used to require third-party apps... are becoming platform capabilities the OS handles, resulting in fewer apps to install for the user and a different participation model for developers.' What Live Speech lacks: phrase tiles/one-tap pre-stored phrases (it has saved phrases but shallow), no show-don't-speak display mode, no categories, and it is iOS-only. Those gaps — not 'adult design' — are the only defensible wedge.

- https://www.apple.com/newsroom/2023/05/apple-previews-live-speech-personal-voice-and-more-new-accessibility-features/

- https://www.eastersealstech.com/2025/05/22/exploring-ios-18s-new-accessibility-features/

- https://blakecrosley.com/blog/accessibility-platform-features

### The tile-vs-typing question is settled by evidence and the MVP already has it right — but the on-device LLM expansion idea should be explicitly rejected for v1

*Confidence: high, **LOAD-BEARING***

Evidence for both: ALL 12/12 participants wanted typing available, including those who prefer symbols, for vocabulary flexibility and speed; and cited work (Martin & Nagalakshmi) found typing is faster than symbols BUT symbols require less mental effort. That is the crux — in shutdown the binding constraint is cognitive load, not words-per-minute, so tiles win in crisis and typing wins the rest of the time. Both are required; the MVP is correct here. Against LLM sentence expansion ('hurt loud leave' → a sentence): (1) it puts words in a disabled person's mouth, which is the AAC community's deepest and oldest objection — misrepresentation is a worse dignity harm than slowness; (2) nondeterminism in a crisis tool is terrifying — the user must know exactly what will be said before it is said; (3) an ER is a place where a plausible-but-wrong sentence is dangerous; (4) latency/battery on-device during a shutdown. The research supports pre-stored conversation scripting, not generation. If ever built: propose candidates, user selects, never auto-speak, never paraphrase silently.

- https://arxiv.org/html/2404.17730v1

- https://arxiv.org/html/2507.00202v2

### 'One screen, one job' is NOT achievable once you ship an editor — the editor is the real product and the real cost center, and symbol libraries are a licensing trap the founder hasn't flagged

*Confidence: medium, **LOAD-BEARING***

'Editable categories' is load-bearing scope. It immediately implies: add/edit/delete, reordering, category management, backup/export, import, grid sizing, and then users ask for symbols, nesting, folders, sync. This is how every AAC app becomes a board editor. Evidence the incumbent walked this exact path: Speech Assistant AAC has categories AND subcategories AND 3,400 Mulberry symbols in its paid tier. Evidence the burden is real: 4/12 spend significant time configuring, 3/12 then can't remember where features are, and one described 'big overhead for starting AAC or moving to another AAC application.' Hard constraint to hold: flat phrase list + exactly ONE level of category, no nesting, no drag-reorder, text-only tiles in v1. Text-only also dodges an unflagged legal landmine — the major symbol sets (SymbolStix, PCS) are proprietary and expensively licensed; the free alternatives are Mulberry and ARASAAC, and ARASAAC is CC BY-NC-SA, which is incompatible with a commercial app. Do not put symbols in v1.

- https://asoft.nl/

- https://arxiv.org/html/2404.17730v1

### The blank-slate problem has a defensible answer, and the retro-capture flow is the strongest unbuilt feature in this space — but it must never be a notification

*Confidence: medium, **LOAD-BEARING***

On the paradox: people DO successfully predict their crisis-state needs — the 2025 study documents conversation scripting, participants 'preparing responses for anticipated situations' and saving 'different possible pathways conversations could go.' So it is not a fantasy, but it is the behavior of highly-invested users, and 4/12 report setup burden as discouraging. Right answer to first run: ship starter sets, but authored BY autistic adults / AAC users and labeled with who wrote them and why, offered as a menu of situations (medical, shop/transaction, work, home, 'explain my situation'), every phrase editable and deletable, with a visible 'these are someone else's words, make them yours' framing — provenance converts presumption into a gift. Crucially, first-run must be skippable in one tap to a working screen, because the install may BE the crisis. On retro-capture: 'what did you need to say and couldn't?' is high-leverage and nobody ships it. But post-crisis is a recovery/vulnerability window — a push notification asking 'how was your shutdown?' is actively harmful and would get the app pilloried. It must be pull-only: a passive, always-present, unobtrusive affordance the user reaches for when ready.

- https://arxiv.org/html/2507.00202v2

- https://arxiv.org/html/2404.17730v1

### The privacy purity position creates a data-loss problem and a blindness problem, and the printable card is a genuinely serious answer, not a consolation prize

*Confidence: medium, **LOAD-BEARING***

Offline + no account + nothing-leaves-device means no backup, no restore, no sync — so a user who curated phrases for six months loses them on phone upgrade, loss, theft, or reinstall. For someone in shutdown at hour 10 of a bad day, the phone is also frequently at 4% battery. Paper wins on every crisis axis: zero battery, zero latency, zero unlock, no app to remember, and — per the stigma finding — writing carries no stigma where apps do. Communication cards ('I can understand you, but I can't speak right now') are already established practice in the selective mutism world. A 'print my card / export a wallet PDF' feature is cheap, high-dignity, and doubles as backup. Second-order cost of purity: no analytics and no crash reporting means you cannot learn whether the app works or that it is broken — while 6/12 emphasized needing dependable performance and one abandoned an app because 'I reported several bugs and *never* got any fixed'. Shipping an uninstrumented crash into a tool people rely on in an ER is a real hazard. Mitigation: on-device-only crash log the user can manually export, plus local-file export/import via the share sheet and inclusion in native OS backup.

- https://arxiv.org/html/2404.17730v1

- https://www.callscotland.org.uk/blog/selective-mutism-and-technology/

- https://www.reachlink.com/advice/social-anxiety/selective-mutism-in-adults/

### The lock/instant-access tension has a clean resolution: don't lock the app, lock the navigation — but the privacy risk is real and understated

*Confidence: medium, **LOAD-BEARING***

Phrase banks for this population contain intensely private content: 'I'm being hurt', medication and diagnosis disclosure, 'I'm autistic', self-harm or suicidal content, sexual content, safewords. The Emergency Chat model — hand your unlocked phone to a stranger — exposes not just the phrase bank but the whole phone. The research states this directly: showing text 'requires handing devices to others — raising security concerns'. A passcode on the speaking screen is disqualifying: it defeats the entire premise. Resolution: a 'hand to stranger' pinned/kiosk mode that displays ONLY the current message, blocks back/navigation/app-switching, and hides the rest of the bank (approximately Guided Access, but built in and one tap). Plus a per-phrase 'private' flag that keeps sensitive phrases out of any shown-to-others view. On misuse: yes, the app can speak something harmful, but this is a text-to-speech app — that risk is identical to any keyboard or the OS's own Live Speech, it is the user's own words, and adding content filtering to a disabled person's voice would itself be a paternalism failure of exactly the kind the product exists to oppose. Do not filter.

- https://arxiv.org/html/2404.17730v1

- https://lifeonautism.wordpress.com/2016/10/06/aac-app-review-emergency-chat/

### The four target personas are four different products, and bundling them will produce something that serves none of them well

*Confidence: medium, **LOAD-BEARING***

Autistic shutdown: sensory-driven, so sound and screen brightness are aversive, wants silence and minimal stimulus, needs one-tap. Selective mutism: anxiety-driven, wants to NOT draw attention, and speech output may increase anxiety (CALL Scotland); a device that announces 'this person is disabled' is the opposite of what is wanted — masking is the goal, not disclosure. Aphasia: often cannot author the phrase bank they most need (the core paradox — highest need, lowest authoring ability), often benefits from symbols not text, frequently older, and hemiparesis makes one-handed a hard requirement rather than a nice-to-have. Post-seizure: postictal confusion means no navigation is possible at all — that user needs literally one button, and arguably a lock-screen card, not an app. The 'situational speech loss' framing is a genuine and underserved insight, but it is an insight about a *state*, not a coherent user segment. Ship for autistic adults with shutdown first — that is the community you can reach, the one with the clearest documented unmet need, and the one where record-your-own-voice works.

- https://www.callscotland.org.uk/blog/selective-mutism-and-technology/

- https://arxiv.org/html/2404.17730v1

- https://arxiv.org/html/2507.00202v2

### 'Dark, calm, adult' visual design directly conflicts with the show-don't-speak mode

*Confidence: medium*

The research flags sun glare and small screens as concrete failure modes for showing text to others. A dark, low-contrast, calm palette is right for the user's own eyes during sensory overload — and wrong for a cashier reading your screen at arm's length in daylight. These are opposite optimizations. The show-mode must be a distinct render: maximum brightness override, huge high-contrast type, one message filling the screen, auto-rotate for the reader. It should also be reachable in one gesture from the tile grid, and it must temporarily override the system brightness and then restore it. Related, sub-severity but real: 'adult design' does not mean 'monochrome and cold'. The stated risk of feeling cold is correct, and the tell from the research is that infantilizing was about *vocabulary and being treated as a student*, not about color — one participant wanted 'both symbols and typing and a vocabulary designed for autistic adults'. You can be warm and adult; the enemy is cartoon avatars and parental gates, not saturation.

- https://arxiv.org/html/2404.17730v1

### Editor accessibility is a real gap, and the caregiver/multi-user problem does not need accounts — but it does reopen the infantilization vector

*Confidence: medium*

Editor accessibility is systematically underrated because 'calm state' is silently equated with 'high executive function', which is false — the same user has fatigue, aphasia, motor limits and low EF on a calm day. Drag-to-reorder grids are an accessibility failure for screen readers and for motor-impaired one-handed use; provide move-up/move-down buttons instead. Offer voice dictation as an authoring path (the user CAN speak on a calm day — use it), which also partly addresses the aphasia authoring paradox. Multi-user: no accounts is genuinely fine — caregiver help = physical device handoff, or exporting/importing a file, or a local QR/AirDrop transfer. No cloud needed. But the real risk is not technical: a caregiver-authored phrase bank is exactly how someone else's words and someone else's idea of you get back into an app built to prevent that. If you build any handoff, the phrases must be presented to the user as proposals to accept or reject, and the user must always be able to see and delete everything.

- https://arxiv.org/html/2404.17730v1

- https://arxiv.org/html/2507.00202v2

## Product implications

- **[must-have-mvp]** Reposition away from 'adult AAC tiles' — that product exists, free, cross-platform, with a watch app. The only defensible wedge is the SHUTDOWN/situational-speech-loss state: instant access at the moment of collapse, show-don't-speak, and your own recorded voice.
  - Speech Assistant AAC is free on Android / €23.99 iOS, offline, no account, adult-targeted, with categories, phrase buttons and type-to-speak. Building the stated MVP means shipping a worse version of a shipped free app. The premise's competitive claim is simply wrong and everything downstream of it needs re-deriving.
- **[must-have-mvp]** Ship 'show, don't speak' as a co-equal primary mode, not a setting: one tap from any phrase to a full-screen, max-brightness, high-contrast, single-message display designed to be turned around or handed over — with navigation pinned so only that message is visible.
  - 8/12 autistic adult AAC users use text display instead of or alongside TTS; 3/12 prefer showing text for most or all communication; stigma attaches to AAC apps but not to writing; 6/12 say devices can't get loud enough anyway. Pinning it also resolves the privacy-vs-instant-access tension without a passcode.
- **[must-have-mvp]** Make silence a first-class mode. Never auto-speak. TTS is opt-in per action, with haptic-only confirmation available.
  - Speaking aloud injects auditory stimulus into the channel already overloaded during sensory shutdown, and for selective mutism speech output can raise anxiety rather than reduce it. A participant called automatic word-by-word speech output 'infantilizing'. The core action can worsen the state it treats.
- **[must-have-mvp]** Build record-your-own-voice-in-calm-state as the flagship differentiator: record phrases with your real voice, play them back in crisis. Offer TTS alongside, never as the only path.
  - Situational speech loss means the user has a working, authentic voice ~90% of the time — unlike the children's AAC market this feature is possible here and no incumbent has it. It simultaneously deletes the TTS-quality risk (7/12 found voices hard to understand), the voice-identity dignity failure, the Personal Voice API dependency and the Android/iOS voice asymmetry.
- **[must-have-mvp]** Solve crisis-time launch with native OS surfaces — Lock Screen widget, Control Center control, Action Button, Back Tap, Accessibility Shortcut, App Intents, watch complication — and budget native Swift/Kotlin work for it. Reconsider Flutter or accept it must be a hybrid.
  - The top risk is that the user can't remember or reach the app during shutdown. Flutter gives you only the in-app UI — the least useful surface at that moment. iOS Live Speech wins on this axis today via triple-click with no app to find, and the free incumbent already ships an Apple Watch app. The stack choice currently fights the #1 risk.
- **[should-have-v1]** Do not ship OS-voices-only. At minimum expose pitch/rate controls to synthesize middle-pitch/androgynous voices; ideally wire Personal Voice on iOS via a native channel. State the Android limitation honestly rather than hiding it.
  - 'Having the voice that matches every other person who uses AAC is very disempowering'; 4/12 flagged missing nonbinary/middle-pitch options; a trans participant cited gender and age dysphoria. A fixed binary-gendered OS voice menu is the same paternalism as cartoon avatars, in a different mask.
- **[must-have-mvp]** First run: skippable in one tap to a working screen; offer starter sets authored by named autistic adults / AAC users, organized by situation, every phrase editable and deletable, framed as 'someone else's words — make them yours'.
  - An empty grid is useless and a pre-filled grid is presumptuous — visible provenance is what converts presumption into a gift. Skippability matters because the install may itself be the crisis. 4/12 already find setup burden discouraging.
- **[should-have-v1]** Build post-crisis phrase capture as a passive, always-available, pull-only affordance ('add what you needed to say'). Never a push notification.
  - Nobody ships this and it is the highest-leverage answer to the customization paradox — it lets the crisis-state self teach the calm-state self instead of requiring prediction. But post-crisis is a recovery window; a notification asking about someone's shutdown is actively harmful and would be reputationally fatal in this community.
- **[should-have-v1]** Ship 'print my card' / wallet PDF export from day one, and local file export/import via the share sheet.
  - Offline + no account currently means no backup — six months of curated phrases die on a phone upgrade. Paper beats the phone on every crisis axis (dead battery, no unlock, no app to remember) and writing carries no stigma where apps do. Communication cards are already established practice for selective mutism.
- **[must-have-mvp]** Abandon monetization as a goal. Free, with an optional tip jar or a small one-time unlock for editor conveniences — the speaking screen must never be gated. No subscription, ever.
  - ~75% of autistic adults are unemployed or underemployed and only ~14-16% work full-time; the incumbents are free. Willingness to pay is irrelevant without ability to pay, and monetizing a disability accommodation is exactly the grievance that fuels the $299 Proloquo resentment being cited as motivation. Treat this as reputation/portfolio or grant work.
- **[must-have-mvp]** Hard-constrain the data model: flat phrase list plus exactly one level of category. No nesting, no drag-reorder, no symbols in v1. Text-only tiles.
  - 'One screen, one job' does not survive contact with an editor — the incumbent walked this exact path to categories + subcategories + 3,400 symbols. Text-only also dodges an unflagged legal trap: SymbolStix/PCS are expensively licensed and ARASAAC is CC BY-NC-SA, incompatible with commercial use.
- **[should-have-v1]** Narrow to autistic adults with shutdown for v1. Drop selective mutism, aphasia and post-seizure from the MVP framing.
  - These are four different products: SM wants to avoid attention and may be harmed by speech output; aphasia users can't author the bank they most need and often need symbols; postictal users can't navigate at all and need one button. 'Situational speech loss' is a real insight about a state, not a coherent segment.
- **[should-have-v1]** Design the editor for low executive function and one-handed use: no drag-to-reorder (use move up/down), voice dictation as an authoring path, large targets, full screen-reader support.
  - 'Calm state' is wrongly equated with 'high executive function'. The same user has fatigue, motor limits and low EF on a good day. Dictation also exploits the key fact that these users can speak most of the time, and partly addresses the aphasia authoring paradox.
- **[should-have-v1]** Add an on-device-only, user-exportable crash log; do not ship fully uninstrumented.
  - 'Nothing leaves device' also means you never learn the app is broken, while 6/12 emphasized dependable performance and one abandoned an app over unfixed bugs. An unnoticed crash in a tool someone relies on in an ER is a genuine hazard, not a metrics inconvenience.
- **[explicitly-avoid]** Do not build LLM sentence expansion ('hurt loud leave' → a sentence), and do not build content filtering on what the user can say.
  - Generation puts words in a disabled person's mouth — the AAC community's oldest and deepest objection; misrepresentation is a worse dignity harm than slowness. Nondeterminism in a crisis tool is terrifying and dangerous in an ER. Conversely, filtering a disabled person's own speech is precisely the paternalism the product exists to oppose — and the misuse risk is identical to any keyboard.
- **[must-have-mvp]** Do not position or market this as an emergency/break-glass app. Design for everyday low-demand use so the motor pattern is actually rehearsed.
  - Muscle memory is real, which is exactly why crisis-only positioning fails — an app used only in crisis never gets the repetition that makes it usable in crisis. 11/12 cite slowness and one states plainly they'd 'need to use it regularly enough to memorize the symbol locations'. ~30% of AAC users abandon their systems and only ~39% still use AAC after a year.

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


YOUR DIMENSION: Red-team the product. Find the ways this fails that an enthusiastic founder would miss.

Research using WebSearch and WebFetch where useful, but also reason hard.

Investigate and report:
- The "adults don't want to be seen using an AAC app" problem: is there stigma? Do users prefer to look like they're just texting? Should the app be DISGUISED/discreet? Research what users say. Is a loud robot voice in a shop actually what they want, or would showing text on screen to the cashier be preferred? Does the product need a "show, don't speak" mode (big text on screen, or a screen you turn around)? Investigate seriously — this could invert a core assumption.
- The blank-slate problem: a fresh AAC app with empty tiles is useless. But pre-filling with someone else's phrases is presumptuous. How do serious AAC apps handle first-run? What is the right onboarding when the user might install it DURING a crisis (or never open it until a crisis)? Should there be starter sets? Who writes them?
- The "never opened until crisis" problem: user installs it, forgets it, and 6 months later during a shutdown cannot remember it exists or how it works. How do you solve discoverability-at-time-of-need? Is muscle memory a myth here? Does this argue for a widget/back-tap/watch?
- The customization paradox: the app is only good when customized, but customization requires the calm-state self to predict the crisis-state self's needs. Does anyone do that? Is there a "capture a phrase you needed" retro-flow?
- TTS voice quality: will OS voices actually be acceptable? What do AAC users say about robotic voices and identity/dignity? Voice = identity in AAC discourse. Is offering only OS voices a dignity failure — the same infantilization problem in a different form?
- What happens if the user's device is dead/lost? Paper backup? Is there a role for a printable card?
- Is "one screen, one job" actually achievable, or does every AAC app inevitably grow into a board editor with folders and become complex? What's the honest scope creep risk?
- Competition from the OS itself (iOS Live Speech, Android Live Caption/TTS) and from LLM keyboards.
- Is the phrase-tile paradigm right, or would a smarter approach win (fast-typing + prediction, or a small on-device LLM expanding "hurt loud leave" into a sentence)? Argue it.
- Will the audience actually pay? Autistic adults have high unemployment/underemployment rates — verify and quantify. What does that mean for pricing?
- Safety: could the app be misused (e.g. speaking something harmful)? Could the phrases be embarrassing if someone else picks up the phone? Does it need a lock? But a lock breaks instant access — tension!
- Accessibility of the EDITOR itself, not just the speaking screen.
- The multi-user problem: could a family member/caregiver need to help set it up? But no accounts...

Be brutally honest. Rank the risks by severity. For each, propose a mitigation or say it's unmitigable.
````

</details>
