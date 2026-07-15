# design-distress--the-fitzgerald-key-is-a-grammar-construction

> Phase: **verify** · Agent `a2ac8f89a8fd1d471` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The Fitzgerald Key is a grammar-construction scaffold originating in Edith Fitzgerald's deaf-education work (1926 book, 1949 republication = the standard "Fitzgerald 1949" citation), with the AAC color-coding layer added by McDonald & Schultz (1973). Its GRAMMAR purpose genuinely does not apply to a phrase-tile MVP — color-coding parts of speech is meaningless when each tile is an entire utterance. That is a sufficient reason to skip it.

However: (1) the Key's color layer serves a second, documented purpose — helping users locate targets quickly — which DOES apply to a phrase grid; if categories are colored semantically (Needs / Feelings / Boundaries / Medical), the findability benefit is retained without the grammar apparatus. (2) Adult-specific evidence on background color and target-location speed exists (Thistle & Wilkinson, ASHA 2019), contra the claim. (3) The palette is not "primary colors" (orange, green, pink are not primaries) and the Key mandates hue, not saturation — a muted, dark-theme rendering of the same hues is entirely possible, so the infantilizing signal comes from children's-product rendering conventions, not from the Key itself. (4) The puzzle-piece source cited for the infantilization link is about jigsaw symbolism and does not mention AAC color coding at all.

PRODUCT DECISION: skip Fitzgerald grammar color-coding — correct call, wrong reasons. Do NOT conclude from this that color-coding categories is itself infantilizing; that inference is unsupported. Decide saturation and palette on autistic sensory-design grounds (muted, low-saturation, 2-5 intentional colors, high-saturation only as sparing accents) as a SEPARATE decision from whether to color-code at all.

**Evidence:** The claim's HISTORY checks out; its REASONING contains three substantive errors, one of which is contradicted by the researcher's own cited source.

WHAT SURVIVES:
1. Origins are correct. Edith Mansford Fitzgerald (1877-1940), deaf educator; "Straight Language for the Deaf" published 1926, republished 1949 (hence the "Fitzgerald, 1949" citation convention). Communication Community dates the Key to 1929. Purpose was teaching deaf students correct subject-verb-object placement. Confirmed via Wikipedia, Gallaudet, Dictionary of Virginia Biography.
2. The 1973 attribution is correct and is the standard citation: the AAC color-coding layer is McDonald & Schultz (1973), a modification of Fitzgerald (1949).
3. The palette assignments are substantially right (orange nouns, green verbs, yellow pronouns, blue adjectives, pink prepositions/social).

WHAT IS REFUTED:

(a) "Its function is to help a user LOCATE a part of speech while assembling a sentence word-by-word" — their own cited source says otherwise. PrAACtical AAC (cited source #2) frames color coding's purpose as "the use of color to help us organize vocabulary so that the AAC users can locate specific messages quickly and efficiently." That is a VISUAL SEARCH / findability rationale, and it transfers to a phrase-tile grid unchanged. The grammar rationale doesn't survive the move to whole phrases; the findability rationale does. "Purpose does not apply" is therefore overstated — one of its two purposes applies fully.

(b) "Evidence cited is generic rather than specific to adults" — false as stated. Adult-specific evidence exists: Thistle & Wilkinson, "The Effect of Symbol Background Color on the Speed of Locating Targets by Adults Without Disabilities: Implications for AAC Display Design" (Perspectives of the ASHA SIGs, 2019). Literature also indicates background color cuing may facilitate speed to locate targets in older individuals. The researcher did not find this, but it is directly on point.

(c) "Its standard palette ... is high-saturation primary color — precisely the 'primary colors' pattern" — factually wrong twice. First, orange, green, and pink are NOT primary colors (primaries are red, yellow, blue); only yellow and blue in the palette qualify. Second, and more important, the Key specifies HUE ASSIGNMENTS, not saturation levels. Saturation is an implementation choice. Sources explicitly note "there has been some variation with the color schema of the Modified Fitzgerald Key." Nothing in the Key prevents implementing orange/green/yellow/blue as desaturated, dark-theme-appropriate hues. The "childish signal" is not intrinsic to the Key — it is intrinsic to how children's AAC products have chosen to render it.

(d) The third cited source does not support the claim it is attached to. heyasd.com/autism-puzzle-piece-controversy is about the jigsaw puzzle SYMBOL. It contains no mention of the Fitzgerald Key, AAC color coding, or AAC palettes. Its infantilization argument is that "jigsaw pieces belong to childhood" — a critique of toy-like SYMBOLISM, not of primary colors. The researcher used it to bridge "Fitzgerald palette → infantilizing," and it does not carry that bridge. This is the load-bearing inference in the claim and it is uncited.

(e) The autistic sensory design guidance is real but was over-applied. Guidance does warn that "fluorescent or highly saturated colors are most likely to provoke sensory overload" and recommends muted, low-saturation palettes. But that same guidance says "brighter or high-contrast colours are not banned — they are simply used sparingly, as small accents," and it is drawn largely from built-environment/classroom research, much of it on autistic children rather than AAC app palettes for adults.

NET: The product recommendation (don't import Fitzgerald grammar color-coding into a phrase-tile MVP) survives, but only on the narrow ground that grammar-category coding is meaningless when tiles are whole phrases. The argument as written should not be relied on: it misidentifies the palette as primary colors, asserts absent adult evidence that in fact exists, cites an irrelevant source for its central inference, and ignores that its own source names a findability purpose that DOES apply.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "design-distress". A product decision depends on it, so it must be right.

CLAIM: The Fitzgerald Key is a grammar-construction scaffold from 1949/1973 whose purpose does not apply to literate adults tapping whole phrases
THEIR DETAIL: The Fitzgerald Key was developed in the 1920s to teach deaf students grammatically correct sentence structure; the color-coding layer is McDonald & Schultz's 1973 modification of Fitzgerald (1949). Its function is to help a user LOCATE a part of speech while assembling a sentence word-by-word. Evidence cited is generic ('colour can have a positive effect on ability to work with an AAC system') rather than specific to adults or to phrase-level AAC. Its standard palette (orange nouns, green verbs, yellow pronouns, blue adjectives, pink social) is high-saturation primary color — precisely the 'primary colors' pattern autistic adults name as infantilizing, and precisely what autistic sensory design guidance warns against. For a phrase-tile MVP the Key delivers no grammatical benefit while importing the childish signal.
THEIR CLAIMED SOURCES: https://www.communicationcommunity.com/fitzgerald-key-for-aac/, https://praacticalaac.org/strategy/communication-boards-colorful-considerations/, https://www.heyasd.com/blogs/autism/autism-puzzle-piece-controversy
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
