# aac-clinical--but-core-vocabulary-is-a-tool-for-building-g

> Phase: **verify** · Agent `a23cd87e4491ccfa3` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Core vocabulary's PRIMARY clinical purpose is indeed teaching generative language to emergent communicators, and Zisk & Dalton (2019) do genuinely support individualized, adult-appropriate, goal-matched AAC rather than imposing child-oriented systems — so a phrase-tile + type-to-speak MVP is defensible. However: (1) Zisk & Dalton never discuss core vocabulary and cannot be cited for the "category error" claim; (2) their "rapid typist" quote actually deprioritizes SAVED PHRASES in favor of typing, so it argues against the phrase grid rather than for it; (3) the researcher's own AssistiveWare source states the opposite for this exact population — "people who intermittently lose speech... If you have trouble remembering words or reading when you lose speech, symbols may still be helpful"; (4) core vocabulary is documented in use with literate acquired-loss adults (aphasia), so it is not exclusive to emergent communicators; (5) 2024-2025 primary research (Martin & Nagalakshmi 2024; Frisch et al. 2024) finds autistic adults want generative/flexible vocabulary, find stored phrases "of limited use" in real interaction, and report symbols as requiring LESS mental effort than typing during shutdown. Correct framing: word-level tiles are a legitimate accommodation for word-finding failure during shutdown — the design decision should be "adult-appropriate vocabulary at both phrase AND word granularity, user-configurable," not "phrases only, core words are a category error." Confidence should be MEDIUM, not high.

**Evidence:** CITATION ACCURACY — mostly clean. Zisk & Dalton (2019) is real: "Augmentative and Alternative Communication for Speaking Autistic Adults: Overview and Recommendations," Alyssa Hillary Zisk & Elizabeth Dalton, Autism in Adulthood, 2019, PMC8992808 (PMID 36601528). Title slightly abbreviated by the researcher but substantively correct. Both quotes verified VERBATIM: "Autistic people who use speech may experience intermittent, unreliable, and/or insufficient speech" and "A rapid typist may prefer a text-based system and put less priority on saved words or phrases." The literature-focus point is also verbatim-supported: "Research into AAC use for autistic people, like other autism research, has typically focused on children, so there is little academic work on AAC use by autistic adults."

FAILURE 1 — the paper does not discuss core vocabulary AT ALL. The claim's central assertion is that a core-word grid is a "category error." Zisk & Dalton never mention core vocabulary and make no phrase-based-vs-word-based recommendation. The cited source cannot bear the weight placed on it. This is citation overreach, not support.

FAILURE 2 — the "rapid typist" quote argues AGAINST the phrase grid, not for it. Read in full, it says a rapid typist "may prefer a text-based system and put less priority ON SAVED WORDS OR PHRASES." The researcher deployed this to defend phrase-based tiles, but the sentence explicitly DEPRIORITIZES saved phrases for that user. It supports the type-to-speak box in the MVP; it is evidence against the phrase grid being the primary paradigm. Also note it is conditional ("may prefer") inside an individualization argument — Zisk & Dalton's actual recommendation is to support individualized needs and a RANGE of options, which is the opposite of declaring one paradigm "correct."

FAILURE 3 — the researcher's own second source directly contradicts them, on exactly this population. AssistiveWare's "Should I try text-based AAC?" states that some literate people still need symbols, and singles out this exact user: "people who intermittently lose speech may be more likely to experience this. If you have trouble remembering words or reading when you lose speech, symbols may still be helpful." The companion AssistiveWare page on part-time AAC quotes a speaking autistic user: "I do still prefer [Proloquo2Go] during moments of particular overwhelm, even though it's not the pictures that are important to me. It mostly just helps to be able to LOCATE the word rather than think it up on my own." That is word-finding support — precisely the function a core/word grid serves — and it refutes the claim that the bottleneck is "RATE and cognitive load, not vocabulary breadth."

FAILURE 4 — the premise "they have full language and have lost the motor/executive ACCESS to speech" misreads Zisk & Dalton's own taxonomy. Their "unreliable speech" category means a person "may say things that do not match their intended meaning and/or preferences" — a language-level breakdown, not merely lost motor access. Intact language is not a safe assumption during shutdown.

FAILURE 5 — recent primary research (2024-2025) contradicts phrase-sufficiency. Martin & Nagalakshmi (2024), arXiv:2404.17730, n=12 autistic adults: all 12 wanted typing access, BUT users wanted generative capability and "high flexibility in terms of vocabulary," and some found symbols require LESS mental effort than typing ("typing is faster but symbol-based systems require less mental effort"). One participant wanted "both symbols and typing and a vocabulary designed for autistic adults." Frisch, Peters & Vertanen (2024/2025), arXiv:2507.00202, found saved phrases are "of limited use just because of the way that communication is itself an interaction between multiple people." Some participants report symbol-based AAC as the EASIEST modality during meltdown/shutdown.

FAILURE 6 — core vocabulary is not exclusive to emergent communicators. ASHA Perspectives, "Vocabulary Selection in AAC: Application of Core Vocabulary in Atypical Populations" (pubs.asha.org/doi/10.1044/persp1.SIG12.125), applies core vocab beyond emergent communicators; PRC-Saltillo publishes core-vocabulary guidance specifically for adults with aphasia — a literate, previously-fluent, acquired-loss population. Core vocab exists "in all age groups, language levels, and languages." (Both ASHA URLs returned HTTP 403; verified via search abstracts and secondary sources, so treat FAILURE 6 as moderately rather than fully substantiated.)

NET: The defensible core is that phrase tiles + type-to-speak is a REASONABLE design for this population, and that child-oriented core-word grids should not be imposed wholesale — Zisk & Dalton's individualization guidance genuinely supports adult-appropriate, goal-matched design. But the specific decision-bearing claim — that a core-word grid is a "category error" and phrase-based is "the correct paradigm" — is unsupported by the cited sources and contradicted by the researcher's own AssistiveWare citation plus 2024-2025 primary research. The stated confidence of "high" is not warranted.

PRODUCT IMPACT: Do not treat this as license to ship phrase-tiles-plus-typing as sufficient. The evidence says word-finding fails during shutdown for a meaningful subset, that typing can be the HIGHER-cognitive-load modality at exactly the moment of need, and that users want generative capability. A single-word tile layer (adult vocabulary, not kiddie core boards) is a plausible v2 requirement, not a category error. The MVP is not invalidated, but the justification for excluding word-level tiles is.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "aac-clinical". A product decision depends on it, so it must be right.

CLAIM: BUT core vocabulary is a tool for building generative language, not for literate adults with intact language — the phrase-based design is defensible, and imposing a core-word grid would be a category error
THEIR DETAIL: Core vocabulary's clinical purpose is to let an emergent communicator generate novel, unpredicted utterances by recombining high-frequency words (verbs, pronouns, prepositions, determiners) rather than being trapped in nouns someone else pre-selected. The target user here is not building language — they have full language and have lost the motor/executive ACCESS to speech, situationally. Zisk & Dalton (2019, 'AAC for Speaking Autistic Adults: Overview and Recommendations', PMC8992808) frame the population precisely this way — adults with 'intermittent, unreliable, and/or insufficient speech' — and explicitly note the existing literature 'focuses on children' and 'people without functional speech.' Their guidance is to match system features to abilities and goals: 'a rapid typist may prefer a text-based system.' For this population the bottleneck is RATE and cognitive load, not vocabulary breadth. Phrase-based is the correct paradigm.
THEIR CLAIMED SOURCES: https://pmc.ncbi.nlm.nih.gov/articles/PMC8992808/, https://www.assistiveware.com/learn-aac/should-i-try-text-based-aac
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
