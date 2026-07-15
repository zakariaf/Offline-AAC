# aac-clinical

> Phase: **research** · Agent `afb4bb0eb6c2e496d` · Run `wf_3a8e3c64-43a`

## Result

## Summary

The product's phrase-based, adult-facing, offline design is clinically defensible — but for reasons different from the ones kid-AAC literature supplies, and the team should stop treating "core vocabulary" as a standard it must meet. Core vocabulary is real and holds for adults (203 words = 80.6% of adult speech; Shin/Park/Hill 2021, BNC), but it is a tool for people BUILDING generative language, not for literate adults who have language and have lost speech ACCESS. For this population the bottleneck is rate and cognitive load under distress, and stored phrases are themselves the highest-yield, clinically-established rate-enhancement technique (message/phrase banking) — stronger evidence than word prediction, whose rate benefit is genuinely contested. The single most important clinical constraint is motor planning: serious AAC fixes button positions because automaticity collapses under visual search, so any "most-used floats to top" reordering is actively harmful and would fail users precisely when they are in shutdown. On symbols, Mulberry (CC BY-SA 4.0, 3,116 symbols) is the answer and is the ONLY major set explicitly designed for adults; ARASAAC (12,909) is CC BY-NC-SA and legally blocks both paid and ad-supported apps. Two scope corrections: AAC modeling does not apply to this audience and should not be built, and aphasia is a genuinely different population whose evidence base is visual scene displays, not typing — including it in the MVP audience is a real risk.

### Core vocabulary is empirically real for adults, not just children — roughly 200 words cover ~80% of adult conversational speech

*Confidence: high, **LOAD-BEARING***

Shin, Park & Hill (2021, JSLHR) analyzed 330,000 spoken words from 66 adults (mean age 45.5) in the British National Corpus: 671 candidate words at the 0.1‰ threshold covered 90.94% of the sample; after applying an 80% speaker-commonality criterion, a final high-frequency list of 203 words accounted for 80.62% coverage. Corroborating: Stuart, Beukelman & King (1997) found 174 words = 72% of what older adults said across all environments/topics, 250 words = 78%, including shopping and phone calls. Balandin & Iacono (1999) established core/fringe vocabularies of adult workplace meal-break conversations (AAC 15(2), 95-109). So the '75-80% from a few hundred core words' claim is NOT a kid-AAC artifact — it replicates in adults.

- https://pubmed.ncbi.nlm.nih.gov/34705517/

- https://pubs.asha.org/doi/abs/10.1044/2021_JSLHR-21-00211

- https://aacinstitute.org/core-vocabulary-and-the-aac-performance-report/

- https://praacticalaac.org/strategy/join-together-core-fringe-vocabulary/

### BUT core vocabulary is a tool for building generative language, not for literate adults with intact language — the phrase-based design is defensible, and imposing a core-word grid would be a category error

*Confidence: high, **LOAD-BEARING***

Core vocabulary's clinical purpose is to let an emergent communicator generate novel, unpredicted utterances by recombining high-frequency words (verbs, pronouns, prepositions, determiners) rather than being trapped in nouns someone else pre-selected. The target user here is not building language — they have full language and have lost the motor/executive ACCESS to speech, situationally. Zisk & Dalton (2019, 'AAC for Speaking Autistic Adults: Overview and Recommendations', PMC8992808) frame the population precisely this way — adults with 'intermittent, unreliable, and/or insufficient speech' — and explicitly note the existing literature 'focuses on children' and 'people without functional speech.' Their guidance is to match system features to abilities and goals: 'a rapid typist may prefer a text-based system.' For this population the bottleneck is RATE and cognitive load, not vocabulary breadth. Phrase-based is the correct paradigm.

- https://pmc.ncbi.nlm.nih.gov/articles/PMC8992808/

- https://www.assistiveware.com/learn-aac/should-i-try-text-based-aac

### The clinical liability of phrase-only AAC is that the user can only say what someone predicted they would want to say — the type-to-speak box is what makes the design defensible, not an add-on

*Confidence: high, **LOAD-BEARING***

This is the classic and correct AAC critique of pre-stored-message systems, and it is the reason core vocabulary exists as a doctrine at all. A grid of phrases without a text escape hatch would be clinically indefensible for a literate adult: it caps expressive range at the author's imagination and reproduces the infantilization the product exists to fix. The MVP already includes 'type to speak' — the finding is that this must be framed as CO-EQUAL and first-class, not a secondary tab. Corroborated by the 'Aging Up AAC' study (arXiv 2404.17730): all 12 autistic adult participants wanted typing options alongside symbols, and 7 explicitly wanted 'mixing symbol usage with typing' rather than being forced to choose between separate apps. Participants identified a 'problematic divide': typing apps lack symbol support, symbol apps feel slow and infantilizing. The hybrid MVP is precisely the identified gap.

- https://arxiv.org/html/2404.17730v3

- https://pmc.ncbi.nlm.nih.gov/articles/PMC8992808/

### Dynamic reordering ('most used floats to top') is actively harmful and would fail users at exactly the moment of greatest need

*Confidence: high, **LOAD-BEARING***

LAMP's premise: the motor plan to say a word is consistent across time and unique from other words; automaticity with static button locations lets users communicate 'as fast as they think' via muscle memory, because users remember the physical LOCATION rather than visually scanning the screen. Clinical consensus is explicit that changing layouts 'can disrupt a person's motor plan for saying something they've said before,' and that once a word is programmed to a location it must stay there. The compounding argument for THIS product: a user mid-shutdown/sensory-overload has the least available capacity for visual search — that is the definition of the state the app is for. An adaptive grid converts a 1-tap automatic retrieval into a visual search task precisely when visual search has failed. Frequency-based reordering is a conventional-UX instinct that is anti-clinical here.

- https://lampwflapp.com/about

- https://aacandautism.com/assets/uploads/Research-Supporting-LAMP4.pdf

- https://aaccommunity.net/ccc/motor-planning/

- https://www.openaac.org/considerations.html

- https://www.avazapp.com/blog/aac-symbol-consistency/

### The correct design rule is 'hide, don't move' — editing must never reflow the grid

*Confidence: high, **LOAD-BEARING***

The established clinical technique for reducing visual load without destroying motor plans is masking/hiding buttons in place rather than deleting-and-reflowing. Implication for a user-editable phrase grid: deleting tile #4 must leave an empty slot, not shift tiles 5-12 up one position. Adding tiles appends to empty slots; it does not re-sort. Grid size changes are the most destructive operation of all ('if you give them 8 buttons to start, you will need to keep expanding the page, which changes the motor plan around') — so pick a grid density once and let users hide, not resize. Reorder must exist as a deliberate, explicit user action (they own their system), but must never be automatic, and is worth a one-time warning. This is directly at odds with 'customizable' as usually implemented and needs to be an engineering constraint, not a preference.

- https://aaccommunity.net/ccc/motor-planning/

- https://www.openaac.org/considerations.html

- https://achievehealthwellness.wordpress.com/2022/09/07/aac-and-motor-planning/

### Caveat on the motor-planning evidence: it is derived from children with autism learning language on large fixed grids, and its transfer to a 12-tile adult phrase grid is an extrapolation

*Confidence: medium*

Being rigorous: LAMP's evidence base (e.g. Tandfonline 10.1080/2331186X.2015.1045807) is an evidence-based evaluation in children with ASD acquiring language on 84-location devices; the cited supporting finding about adults is narrow (neurotypical adults recalled motor patterns better when patterns were dissimilar). Nobody has studied motor automaticity in situational-shutdown adult phrase grids. However, the underlying cognitive claim is independently supported by the encoding literature: encoding schemes (abbreviation expansion, semantic compaction, Morse) become automatic once memorized and thereafter impose low cognitive demand, explicitly contrasted with word prediction which imposes ongoing demand. So the principle is well-founded even where the population-specific study is absent. Treat 'fixed positions' as high-confidence design doctrine, not as a cited RCT result.

- https://www.tandfonline.com/doi/full/10.1080/2331186X.2015.1045807

- https://aacandautism.com/assets/uploads/Research-Supporting-LAMP4.pdf

- https://www.resna.org/sites/default/files/legacy/conference/proceedings/2005/Research/CAC/Lesher.html

### Mulberry Symbols is the only major symbol set explicitly designed for adults, and it is CC BY-SA 4.0 — commercially usable, 3,116 symbols

*Confidence: high, **LOAD-BEARING***

Mulberry states its own differentiator as: 'Adult oriented symbols - most proprietary sets are designed for children.' License is Creative Commons BY-SA 4.0 (some sources cite CC BY-SA 2.0 UK for older releases), copyright Steve Lee, 3,116 symbols per OpenSymbols, distributed as scalable SVG, hosted on GitHub (mulberrysymbols/mulberry-symbols). Commercial use IS permitted for products/services. Two binding conditions: (1) 'While you may charge for your product or added value, you must not charge for the symbols themselves' — i.e. do not sell a symbol pack as an IAP, but a paid app that includes them is fine; (2) ShareAlike — any DERIVED/edited symbols must be released under the same license, and attribution crediting Steve Lee with a link to mulberrysymbols.org is required. Note ShareAlike attaches to the symbol artwork and its derivatives, NOT virally to the app's source code. This set is a near-exact match for the product thesis.

- https://mulberrysymbols.org/

- https://www.opensymbols.org/

- https://www.opensymbols.org/repositories/mulberry

- https://github.com/mulberrysymbols/mulberry-symbols

- https://www.openaac.org/symbols.html

### ARASAAC (12,909 symbols) is CC BY-NC-SA and legally unusable — the NonCommercial clause blocks a paid app AND an ad-supported free app

*Confidence: high, **LOAD-BEARING***

ARASAAC's own Terms of Use state: 'The use of these resources within any product or publication for commercial purposes is therefore excluded from this permission.' License is CC BY-NC-SA; symbols by Sergio Palao, owned by the Government of Aragón. CC defines NonCommercial as 'primarily intended for or directed toward commercial advantage or monetary compensation' — this covers paid apps, ad-supported apps, and monetized products. Attribution must cite authors (ARASAAC team), source (Aula Abierta de ARASAAC + URL), license type, and property ownership (Government of Aragón), and derivatives must carry the same license and include the ARASAAC logo. ARASAAC's published terms do not document an exception procedure or a paid commercial license route. This is a trap: ARASAAC is the largest free-looking set and is widely used, so the team will be tempted. It is only viable if the app is permanently, entirely non-monetized — which is a business-model decision, not a design one.

- https://aulaabierta.arasaac.org/en/terms-of-use

- https://www.opensymbols.org/repositories/arasaac

- https://arasaac.org/

- https://www.opensymbols.org/

### Exact license status of the remaining symbol sets: only a handful are commercially usable

*Confidence: high, **LOAD-BEARING***

From OpenSymbols' own repository listing — Commercial use permitted: Mulberry CC BY-SA (3,116); Twitter Emoji CC BY (2,770); Tawasol CC BY-SA (950); CoughDrop Symbols CC BY (21); The Noun Project 'mixed licenses' (17,165); IcoMoon 'mixed' (907); IconArchive 'mixed' (600). NonCommercial only (unusable if monetized): ARASAAC CC BY-NC-SA (12,909); Sclera CC BY-NC (11,443); LanguageCraft CC BY-NC-SA (205). 'Mixed licenses' sets require per-symbol clearance and are unsafe to bulk-ship. Proprietary: PCS is owned by Tobii Dynavox — licensing requires a Boardmaker subscription first, there are three license tiers (no license / free license / paid license), and applications are reviewed in 10-15 business days; published fee schedules are not public. SymbolStix is owned by n2y, LLC; SymbolStix symbols may be distributed for personal use only with a SymbolStix Prime subscription — i.e. not shippable in a third-party app without a negotiated deal. Practical conclusion: Mulberry + Tawasol + Twemoji is the only clean, zero-fee, commercially safe, ship-today stack.

- https://www.opensymbols.org/

- https://www.tobiidynavox.com/pages/pcs-licensing

- https://touchchatapp.com/symbol-libraries

- https://www.prc-saltillo.com/support-materials

- https://www.spectronics.com.au/article/symbol-set-comparison/print

### For literate adults, text-based AAC is the established fit — but typing is not reliably available during the exact episodes this app targets

*Confidence: high, **LOAD-BEARING***

AssistiveWare's clinical guidance: 'a completely text-based AAC system may work for most literate people,' and literate adults often prefer alphabet-based systems. Proloquo4Text and Predictable are the recognized text-based products for literate teens/adults, built around stored phrases, word/sentence prediction, and abbreviation expansion. The critical nuance that justifies this product: AssistiveWare explicitly notes 'there are some people who can read and write very well and still find symbols useful sometimes, particularly people who intermittently lose speech, and those who have trouble remembering words or reading when they lose speech.' That sentence describes the target user exactly. The 'Aging Up AAC' study corroborates the mechanism: 4 participants reported symbol-based AAC required LESS mental effort than typing but was slower. So the two modes serve different states — tiles are the low-demand/high-speed mode for shutdown, typing is the high-bandwidth mode for capacity. Do not let a designer collapse them into one.

- https://www.assistiveware.com/learn-aac/should-i-try-text-based-aac

- https://arxiv.org/html/2404.17730v3

- https://www.assistiveware.com/learn-aac/support-communication-for-part-time-aac-users

### Stored phrases ARE the proven rate-enhancement technique; word prediction's rate benefit is genuinely contested and it raises cognitive load

*Confidence: high, **LOAD-BEARING***

Three-way split in the evidence. (1) Word prediction: earlier work (incl. Trnka & McCoy) found prediction gave 'only minor improvements in communication rate at best and lowered it at worst,' hypothesizing that the cognitive/perceptual load of scanning and recognizing the list consumes the time saved by fewer keystrokes; later work found accurate prediction does raise rate (one study: 58.6% enhancement, 45.8% faster with advanced vs. basic prediction, utilization 93.6% vs 78.2%) while confirming 'cognitive load increased with word prediction use.' Net: benefit is conditional on prediction ACCURACY, and the cost is cognitive load — the resource this user has least of. (2) Abbreviation expansion / semantic compaction: 'once the abbreviations are memorized, their use quickly becomes automatic,' explicitly contrasted with prediction's 'significant cognitive demands'; theoretical keystroke savings 40-50% for word completion, up to 70-77% with LLM-based expansion (Google/NAACL 2022) — but that requires a model and cuts against strict on-device offline. (3) Retrieval of a stored phrase is ~1 tap and is the ceiling of rate enhancement. The MVP's phrase grid is already the strongest technique available; word prediction is a v1 'should-have' at best and must be evaluated for load, not just keystrokes.

- https://www.eecis.udel.edu/~mccoy/publications/2008/trnka08at.pdf

- https://www.resna.org/sites/default/files/legacy/conference/proceedings/2005/Research/CAC/Lesher.html

- https://aclanthology.org/2022.naacl-main.91/

- https://arxiv.org/pdf/2205.03767

- https://pubs.asha.org/doi/abs/10.1044/1058-0360.0404.36

### AAC modeling / aided language stimulation does NOT apply to this audience and should not be built

*Confidence: high, **LOAD-BEARING***

Aided Language Stimulation (a.k.a. modeling, aided language input, aided language modeling, Natural Aided Language) is a partner strategy: the communication partner speaks while pointing to symbols on the device, to develop language and comprehension. It IS evidence-based — including one adult study (single-subject ABAB, adults with developmental disabilities and complex communication needs; responsiveness and AAC use increased for all participants) and a scoping review reporting positive outcomes in the majority of studies. BUT the moderator analysis is decisive: augmented input 'may be most effective for younger children, for individuals with more advanced receptive skills, and for participants with language disabilities without other concurrent diagnoses.' It is an intervention for people ACQUIRING a language system. A literate autistic adult with full language who loses speech situationally has nothing to learn from modeling — and a partner modeling on their device mid-shutdown would be an intrusion. Verdict: modeling is a real clinical concept the team will encounter and should be able to name, and a real reason NOT to build partner/coach/tutorial features.

- https://www.assistiveware.com/learn-aac/aided-language-stimulation

- https://pubmed.ncbi.nlm.nih.gov/18608145/

- https://link.springer.com/article/10.1007/s40474-023-00275-7

- https://praacticalaac.org/praactical/research-support-for-aided-language-input/

### Recognized AAC access methods are direct selection and indirect selection (scanning); only direct touch materially matters for this audience

*Confidence: high*

Per ASHA's Practice Portal and standard taxonomy: DIRECT SELECTION — pointing to a target with a body part (finger, hand, eye gaze) or adapted tool (laser pointer, head pointer, mouse); includes touch, eye gaze, head tracking. INDIRECT SELECTION (scanning) — items presented sequentially until the target appears, selected via an agreed motor movement or switch; includes automatic/step/directed scanning, switch access, and PARTNER-ASSISTED SCANNING, where the partner presents messages or letters visually/auditorily and the person selects with an agreed motor act (blink, grunt, nod, hand raise). Eye gaze and switch/scanning exist to solve access for people with severe PHYSICAL disability — that is not this population, and building them would be scope inflation. The relevant subset: direct touch, one-handed, with large targets. Two caveats worth carrying: (a) motor shutdown and dyspraxia frequently co-occur with speech shutdown in autism, so precision cannot be assumed — large targets, generous hit areas, no drag/long-press/multi-touch gestures on the speak path; (b) partner-assisted scanning is the real-world fallback in an ER when the phone is unreachable, which is an argument for a printable/lock-screen card, not an in-app feature.

- https://www.asha.org/practice-portal/professional-issues/augmentative-and-alternative-communication/

- https://www.communicationcommunity.com/aac-indirect-selection-access/

- https://allaboutaac.wordpress.com/considerations/access-method/

- https://www.assistiveware.com/learn-aac/support-communication-for-part-time-aac-users

### Switch access and screen reader support come nearly free on iOS/Android if Flutter Semantics is not broken — this is a low-cost accessibility floor

*Confidence: medium*

Both platforms ship system-level Switch Control / Switch Access and VoiceOver/TalkBack that traverse standard accessibility trees. A Flutter app that exposes correct Semantics nodes (labels on every tile, correct roles, no custom gesture-only hit targets, no tiles rendered as raw Canvas without semantics) inherits scanning and switch access without implementing a scanner. Conversely, a custom-painted grid with GestureDetectors and no Semantics silently locks out every switch and screen-reader user. This is the cheapest possible win on the access-method dimension and should be a definition-of-done item, not a backlog ticket.

- https://www.asha.org/practice-portal/professional-issues/augmentative-and-alternative-communication/

### Message banking — recording the user's OWN voice for stored phrases — is an established clinical practice that would directly retire the product's biggest stated risk (TTS quality)

*Confidence: high, **LOAD-BEARING***

Message banking is a recognized clinical approach formalized as the BCH Message Banking Process at Boston Children's Hospital (documented in PubMed 35000518, which also describes 'Double Dipping' — mining banked messages to build a personalized synthetic voice). Tobii Dynavox, RCSLT, and multiple ALS organizations run it as standard service delivery. Core insight for THIS product: the population is SPEAKING adults who lose speech intermittently — meaning, unlike ALS patients racing degeneration, they have their voice available on most days. They can bank their own real voice for their most-used phrases during a capacity window and play it back during shutdown. This is fully offline (local audio files), requires no TTS engine, sounds perfect by definition, and is arguably more dignified than any synthetic voice. It is also a strong differentiator no mainstream AAC app offers to this audience. The stated risk 'TTS must sound acceptable' is partially solvable by not using TTS for the top phrases.

- https://pubmed.ncbi.nlm.nih.gov/35000518/

- https://us.tobiidynavox.com/pages/voice-banking-message-banking-voice-preservation

- https://www.rcslt.org/speech-and-language-therapy/clinical-information/voice-banking/

- https://www.sciencedirect.com/science/article/abs/pii/S0892199725004382

### Voice identity is an unmet need with direct evidence from this exact population — and the product spec does not mention it

*Confidence: high, **LOAD-BEARING***

'Aging Up AAC' (arXiv 2404.17730, 12 autistic adult participants): 4 participants, 'many transgender or nonbinary,' criticized the lack of 'nonbinary or middle-pitch voice options' and wanted voices matching identity rather than physical characteristics. Given the demographic overlap between autistic adult communities (r/AutisticAdults, r/autism) and trans/nonbinary identity, this is not a fringe request for this specific market. Constraint: on-device TTS voices are supplied by the OS (iOS AVSpeechSynthesis / Android TextToSpeech) and are largely gendered-binary, so this is partly outside the app's control — which is a second, independent argument for message banking (own voice = perfect identity match) and for exposing pitch/rate controls rather than only a voice picker.

- https://arxiv.org/html/2404.17730v3

### Direct evidence from autistic adults confirms the infantilization thesis and specifies the design fixes

*Confidence: high, **LOAD-BEARING***

'Aging Up AAC' (arXiv 2404.17730), N=12 autistic adults: one participant stated 'Many AAC apps feel like they're made for kids or students, and it feels infantilizing'; 5 of 12 identified this as a major concern, noting childish imagery and limited adult vocabulary 'undermine their dignity.' Specific design findings: 7 requested comprehensive adult-level lexicons (2 wanted job-specific/community terminology, not basic conversational words); ALL 12 emphasized customization; 7 wanted interfaces that didn't feel overwhelming; 4 requested clear organization and fewer simultaneous options; 3 specifically requested REMOVING BRIGHT COLORS when overwhelmed. Participants actively used Proloquo2Go, Proloquo4Text, CoughDrop, and TD Snap. Note the tension the team must resolve: 'all 12 emphasized customization' vs. the motor-planning rule against reflow — the resolution is that customization means user-authored CONTENT and user-chosen positions, set deliberately, never algorithmic rearrangement. Also note '3 requested removing bright colors when overwhelmed' validates dark/calm but suggests it should be a switchable low-stimulus MODE, not merely a static aesthetic.

- https://arxiv.org/html/2404.17730v3

### Aphasia is a clinically distinct population whose evidence base is visual scene displays, not grids or typing — including it in the target audience is a real scope risk

*Confidence: high, **LOAD-BEARING***

For adults with chronic severe aphasia the researched approach is personalized photo Visual Scene Displays (VSDs): contextual photographs of familiar people in meaningful activities, with a navigation bar of thumbnail VSDs adjacent to the main scene. Evidence: participants identified VSDs more rapidly than grid displays and VSDs required fewer visual fixations to process than grids (Wilkinson/Light line of work; see also Light et al. 2019, 'Designing effective AAC displays for individuals with developmental or acquired disabilities', AAC 35(1)). Adults with acquired conditions benefit from text boxes adjacent to the scene. Critically, a 'type to speak' box assumes intact written word retrieval and reading — anomia and alexia commonly co-occur with aphasia, so typing may be the LEAST accessible modality for this group, exactly inverting the design assumption that serves literate autistic adults. Recommendation: the autistic-adult / selective-mutism / post-seizure segment shares a coherent profile (literate, intact language, intermittent access failure) and the grid+typing design serves it well. Aphasia does not fit that profile. Either drop aphasia from MVP positioning or add user-photo tiles — which is a cheap partial bridge (photos as tiles ≈ a crude VSD) and also serves the autistic segment.

- https://pubs.asha.org/doi/10.1044/aac15.1.13

- https://pubmed.ncbi.nlm.nih.gov/26044911/

- https://pubmed.ncbi.nlm.nih.gov/30648896/

- https://www.ohsu.edu/sites/default/files/2019-05/Designing%20effective%20AAC%20displays%20for%20individuals%20with%20developmental%20or%20acquired%20disabilities%20State%20of%20the%20science%20and%20future%20research%20directions.pdf

- https://pubmed.ncbi.nlm.nih.gov/34421171/

### 'Part-time AAC use' is the correct clinical term of art for this product's category, and it is a documented, under-served niche with a live research gap

*Confidence: high, **LOAD-BEARING***

The literature term is 'part-time AAC use' / people with 'unreliable speech.' Key sources: Zisk & Dalton (2019) PMC8992808; Donaldson et al., '"Everyone Deserves AAC": Preliminary Study of the Experiences of Speaking Autistic Adults Who Use AAC' (ASHA Perspectives, 2021, 10.1044/2021_PERSP-20-00220); 'Perspectives of Part-Time AAC Use in Adults and Implications for Pediatric Service Delivery' (ASHA Perspectives, 10.1044/2023_PERSP-22-00200); AssistiveWare's 'When speech is unreliable: Part-time AAC use.' Documented state of the field: speaking autistic adults who use AAC 'rely on peer knowledge, work on AAC with limited application to their own situations, and trial and error to select and effectively use their systems' — i.e. there is no clinical pathway, which is both the market opportunity and the reason r/autism peer recommendation is the distribution channel. Notable gap: 'There do not seem to be formal studies of intermittent speech in autistic adults that consider intermittent speech as potentially distinct from selective mutism' — DSM selective mutism requires 'consistent failure to speak in certain social situations,' whereas autistic intermittent speech 'does not always follow this pattern.' Triggers documented: illness, overall stress, sensory overload, meltdowns, and co-occurring migraine and epilepsy. Framing to adopt from the literature: 'AAC is not the backup plan; it is the plan.' Using the correct terminology in store listings and community posts is a credibility signal to this audience and to SLPs.

- https://pmc.ncbi.nlm.nih.gov/articles/PMC8992808/

- https://pubs.asha.org/doi/10.1044/2021_PERSP-20-00220

- https://pubs.asha.org/doi/abs/10.1044/2023_PERSP-22-00200

- https://www.assistiveware.com/learn-aac/support-communication-for-part-time-aac-users

### Strict 'nothing leaves device' creates a clinical single point of failure: a lost or dead phone erases the user's entire communication system

*Confidence: medium, **LOAD-BEARING***

The message/voice banking literature treats preservation of banked messages as a core part of the process — the whole point is that the artifact must survive. A user who has hand-authored 60 phrases and banked their own voice has built an irreplaceable personal asset. If it exists only in app-private storage on one handset, phone loss = loss of the accommodation, and iOS app-private data is not recoverable without an iCloud/iTunes backup the user may not have. This does NOT require compromising the offline/no-account principle: a user-initiated local export to a file (Files/Downloads, AirDrop, SD card) satisfies both. Recommend the Open Board Format (.obf/.obz) from OpenAAC as the export format — it is the existing open interoperability standard for AAC boards, used by CoughDrop, and would let users migrate in/out rather than be locked in, which is itself a trust signal to a community that is (justifiably) suspicious of AAC vendors. Treat backup/export as MVP-adjacent, not v2.

- https://www.openaac.org/symbols.html

- https://us.tobiidynavox.com/pages/voice-banking-message-banking-voice-preservation

- https://pubmed.ncbi.nlm.nih.gov/35000518/

## Product implications

- **[must-have-mvp]** Fix tile positions permanently. No frequency-based reordering, no 'recents float to top', no auto-sort, ever. Deleting a tile leaves an empty slot; it does not reflow the grid. Reorder exists only as a deliberate, explicit user action.
  - Motor automaticity is the entire reason serious AAC (LAMP, Minspeak) fixes button locations — users retrieve by remembered LOCATION, not visual search. A user mid-shutdown has the least capacity for visual search, which is exactly the state the app exists for. Adaptive reordering converts a 1-tap automatic retrieval into a search task at the worst possible moment. This is a conventional-UX instinct that is anti-clinical here, and it must be an engineering constraint, not a preference.
- **[must-have-mvp]** Ship 'hide tile' instead of 'delete tile' as the primary content-reduction affordance, and pick one grid density and never let it change dynamically.
  - Masking-in-place is the established clinical technique for reducing visual load while preserving motor plans. Grid resizing is the single most destructive operation to a motor plan — 'expanding the page changes the motor plan around'. Also serves the 7/12 participants who wanted less overwhelming interfaces and 4/12 who wanted fewer simultaneous options.
- **[must-have-mvp]** Treat type-to-speak as a co-equal, first-class mode reachable in one tap from the grid — not a secondary tab.
  - Phrase-only AAC caps the user at what someone else predicted they'd want to say, which is the classic (and correct) clinical critique of pre-stored-message systems and reproduces the infantilization the product exists to fix. The typing escape hatch is what makes phrase-based clinically defensible for a literate adult. All 12 participants in the Aging Up AAC study wanted typing alongside symbols; 7 explicitly wanted them mixed in one app rather than separate apps — this hybrid is the identified market gap.
- **[must-have-mvp]** Use Mulberry Symbols (CC BY-SA 4.0, 3,116 SVGs). Do not use ARASAAC, Sclera, PCS, or SymbolStix.
  - Mulberry is the ONLY major set explicitly designed for adults — its own stated differentiator is 'most proprietary sets are designed for children', which is the product thesis verbatim. It is commercially usable at zero cost. ARASAAC (12,909, CC BY-NC-SA) and Sclera (11,443, CC BY-NC) are NonCommercial — they legally block both a paid app and an ad-supported free app, and ARASAAC publishes no commercial-license route. PCS requires a Boardmaker subscription plus a 10-15 business day license review; SymbolStix (n2y) is personal-use-only without a negotiated deal. Comply with Mulberry's two conditions: attribute Steve Lee with a link, and never sell the symbols themselves as an IAP (a paid app containing them is fine). Any symbols you edit become CC BY-SA derivatives — this does not infect your Dart code.
- **[must-have-mvp]** Build message banking: let users record their own voice for any phrase tile, with TTS as the fallback.
  - This directly retires the product's #1 stated risk ('TTS must sound acceptable') by not using TTS for the highest-value phrases. Unlike ALS patients racing degeneration, this population SPEAKS most of the time — they can bank their real voice during a capacity window and play it back during shutdown. It is an established clinical practice (BCH Message Banking Process), fully offline (local audio files), sounds perfect by definition, more dignified than any synthetic voice, and no mainstream AAC app offers it to this audience. It also solves the nonbinary/middle-pitch voice gap that OS TTS voices cannot.
- **[must-have-mvp]** Add user-initiated local export/backup of the whole board (phrases + banked audio), ideally in Open Board Format (.obf/.obz).
  - Strict 'nothing leaves device' creates a clinical single point of failure: a hand-authored board plus banked voice recordings is an irreplaceable personal asset, and iOS app-private data is unrecoverable without a backup the user may not have. A phone loss would erase the accommodation. A user-initiated file export preserves both the offline and no-account principles while removing the failure mode, and OBF (the OpenAAC/CoughDrop interoperability standard) signals no-lock-in to a community that is justifiably suspicious of AAC vendors.
- **[must-have-mvp]** Guarantee touch-only direct selection with large targets, generous hit areas, and no drag / long-press / multi-touch anywhere on the speak path. Expose correct Flutter Semantics on every tile.
  - Direct selection is the only access method that matters for this audience — eye gaze, scanning, and switch access exist for severe physical disability and would be scope inflation. But motor shutdown and dyspraxia commonly co-occur with speech shutdown in autism, so precision cannot be assumed. Separately, correct Semantics nodes make iOS Switch Control / Android Switch Access and VoiceOver/TalkBack work for free; a custom-painted grid with raw GestureDetectors silently locks those users out. Cheapest possible accessibility win — make it definition-of-done.
- **[should-have-v1]** Make dark/calm a switchable low-stimulus MODE (desaturate, reduce tile count, drop animation), not just a static visual theme.
  - 3 of 12 autistic adult participants specifically requested removing bright colors WHEN OVERWHELMED — the need is state-dependent, not a fixed preference. Aligns with the 7/12 who wanted non-overwhelming interfaces. A one-tap 'I'm in shutdown' mode is a stronger expression of the design thesis than a dark palette alone.
- **[should-have-v1]** Add photo tiles (user's own camera-roll images as tile faces).
  - Cheap to build and does double duty. It partially bridges to the aphasia segment — personalized photo Visual Scene Displays are that population's evidence-based approach, and VSDs are identified faster and with fewer visual fixations than grid displays. It also serves autistic adults who want personally meaningful, non-symbolic, adult imagery rather than any drawn symbol set.
- **[explicitly-avoid]** Do NOT position aphasia as an MVP audience — or, if kept, scope it explicitly to photo tiles and accept that typing will not serve it.
  - Autistic adults + selective mutism + post-seizure share one coherent profile: literate, intact language, intermittent ACCESS failure — grid+typing serves them precisely. Aphasia inverts the core assumption: anomia and alexia commonly co-occur, so a type-to-speak box may be the LEAST accessible modality for that group, and their researched interface is VSDs, not grids. Claiming aphasia invites clinical criticism the MVP cannot answer and dilutes a sharp, defensible positioning.
- **[explicitly-avoid]** Do not build AAC modeling, partner-coaching, tutorial, or 'learn your system' features.
  - Aided Language Stimulation is real and evidence-based, but it is an intervention for people ACQUIRING a language system — the moderator analysis finds it most effective for younger children and those with more advanced receptive skills. A literate autistic adult with full language has nothing to learn from modeling, and a partner modeling on their device mid-shutdown would be an intrusion. Know the term (SLPs will ask); do not build it.
- **[explicitly-avoid]** Do not build a core-vocabulary grid, and do not treat 'core vocabulary' as a standard the app must meet.
  - Core vocabulary is empirically real for adults (203 words = 80.6% of adult speech; Shin/Park/Hill 2021 BNC), so the team should be able to defend the choice rather than appear ignorant of it. But its clinical PURPOSE is to let emergent communicators generate novel language by recombining high-frequency words. The target user already has language and has lost speech access — their bottleneck is rate and cognitive load, not vocabulary breadth. Word-by-word construction from core words would be dramatically SLOWER than a stored phrase for someone in shutdown. Phrase tiles + typing is the right paradigm; core vocabulary would be a category error imported from pediatric AAC.
- **[nice-to-have-later]** Defer word prediction; if built, evaluate it on cognitive load and not just keystroke savings, and let users turn it off.
  - Word prediction's rate benefit is genuinely contested: earlier work found it gave 'minor improvements at best and lowered rate at worst' because scanning/recognizing the list consumes the time saved; newer work shows real gains but only conditional on high accuracy, and confirms cognitive load INCREASES with prediction use. Cognitive load is exactly the resource this user lacks during a shutdown. Meanwhile a stored phrase is ~1 tap — the ceiling of rate enhancement — so the MVP already ships the strongest technique. Abbreviation expansion is the better long-term bet (becomes automatic once memorized, low ongoing demand, 40-77% keystroke savings), but LLM-based expansion conflicts with strict on-device offline.
- **[should-have-v1]** Use the literature's own terminology — 'part-time AAC', 'unreliable speech', 'intermittent speech' — in store listings, onboarding, and community posts.
  - These are the established clinical terms of art (Zisk & Dalton 2019; Donaldson et al. 2021 'Everyone Deserves AAC'; ASHA Perspectives 2023 on part-time AAC). The documented state of the field is that these adults 'rely on peer knowledge... and trial and error' because no clinical pathway exists — which is both the opportunity and the reason r/autism peer recommendation is the distribution channel. Correct terminology is a credibility signal to both the community and to SLPs who might recommend it, and it costs nothing.

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


YOUR DIMENSION: AAC clinical/SLP domain knowledge and evidence-based design standards.

Research using WebSearch and WebFetch. Sources: ASHA, AssistiveWare Learn AAC, ISAAC, PrAACtical AAC, CommunicationMatrix, academic papers on AAC design, USSAAC, Speech-language pathology literature.

Answer specifically:
- Core vocabulary vs. fringe vocabulary: what is it, what are the actual high-frequency core word lists, and does core vocabulary matter for a PHRASE-based adult app or is that a kid-AAC paradigm? Be critical — the product is phrase-based, is that clinically defensible?
- Motor planning / motor automaticity in AAC (LAMP Words for Life's premise): why do serious AAC apps keep button positions FIXED? What does this imply for a phrase-tile grid that users can edit/reorder? Is dynamic reordering (e.g. "most used floats to top") actively harmful?
- What are the recognized AAC access methods? (direct touch, scanning, switch access, eye gaze, partner-assisted scanning, head tracking) Which matter for this audience?
- What is "AAC modeling" and does it apply to adults?
- Symbol sets: PCS, SymbolStix, ARASAAC, Mulberry, Blissymbols, Open Symbols. Which are FREE / openly licensed for commercial use? Which look adult vs. childish? Licensing terms and cost specifics matter a lot — get exact license names and fees.
- What does the literature say about text-based vs symbol-based AAC for literate adults?
- Rate enhancement techniques: word prediction, phrase prediction, abbreviation expansion. What is proven?
- Any established guidance specifically about AAC for autistic adults or acquired/intermittent conditions?

Be rigorous and cite sources.
````

</details>
