# distress-ux-aesthetics

> Phase: **research** · Agent `a7cf3dc7b76663cee` · Run `wf_f237e8a6-694`

## Result

## Summary

Verdict: the founder's brief is achievable, but the tension as posed is largely a false binary — and the real tension is somewhere else than where the brief puts it. The empirical formula for perceived beauty (Tuch et al. 2012, Google-funded) is *low visual complexity + high prototypicality*, which is the same formula as the usability constraints already in the spec; prototypicality is the stronger factor (η²p=.812 vs .581 for complexity), and a fixed, familiar 3x4 grid is maximally prototypical. So the constraints are not a tax on beauty — they are two-thirds of the empirical recipe for it. But that only buys "not ugly." The delta from *clean* to *beautiful* is unmeasured by that literature and must be spent entirely in material — color, type, surface, geometry — because complexity is the thing that costs (Tuch et al. 2009 found visual complexity raised arousal, negative valence, and corrugator muscle tension; chroma was not the culprit). The real tension is not beauty vs. usability, it is **state**: the person who judges the app beautiful is at rest, the person who uses it is in shutdown, and they are the same person. The primary source behind this whole product (Martin & Nagalakshmi's n=12 study) resolves it explicitly: its own design recommendation §6.5 is "simplifying the app's colors or board when the user is overwhelmed," in a way that "keeps the user in control" and "does not impede motor plans" — a rich default that manually strips down. That is the release valve, and it is not an invention, it is the source study's recommendation. Uncomfortable finding: the "muted, low-arousal" prescription is far softer in the first-person data than the brief carries it — only 3/12 participants said "no bright colors," and even that was state-conditional. Do not justify beauty via the aesthetic-usability effect; it is weak (Grishin & Gillan 2019 found aesthetics and usability were perceived *separately*). Justify it via adoption and dignity — the Pullin argument — which is where the actual evidence is.

### The empirical formula for perceived beauty is low visual complexity + high prototypicality — and prototypicality is the STRONGER lever, which the fixed grid already delivers for free.

*Confidence: high, **LOAD-BEARING***

Tuch, Presslaber, Stöcklin, Opwis & Bargas-Avila (2012), Int. J. Human-Computer Studies 70(11), Google-funded, 119 website screenshots. Main effects: PT η²p=.812, VC η²p=.581. Significant VC×PT interaction (F(1.7,96.1)=85.273, p<.001, η²p=.604): VC affects beauty MORE strongly in the high-PT condition, and the PT effect is BLUNTED when VC is high. Simple effects: PT differences were huge at low/medium complexity (Cohen's d=1.96, 1.79) but collapsed at high complexity (d=0.24). Effects appear within 50ms, and study 2 replicated at 17ms. Crucially, the paper explicitly declines to define VC objectively: 'we are primarily interested in the subjectively perceived complexity and not in an objective definition of VC' (following Edmonds 1995). So VC = perceived busyness/clutter, NOT element count, NOT chroma, NOT craft.

- https://research.google/pubs/the-role-of-visual-complexity-and-prototypicality-regarding-first-impression-of-websites-working-towards-understanding-aesthetic-judgments/

- https://dl.acm.org/doi/10.1016/j.ijhcs.2012.06.003

### That same paper contains the MAYA principle, which is the precise license for the founder's brief: novelty is rewarded right up to the point it damages prototypicality.

*Confidence: high, **LOAD-BEARING***

Tuch et al. cite Hekkert, Snelders & van Wieringen (2003): 'They found that people preferred novel designs only as long as the novelty did not affect prototypicality.' This is Raymond Loewy's MAYA (Most Advanced Yet Acceptable) with an evidence base. Operational rule for this product: novelty is unlimited in the SURFACE (color, type, material, geometry) and zero in the AFFORDANCE (the thing must instantly read as 'buttons that speak'). Google's own M3 Expressive research independently reproduced this caveat: 'Violating established UI patterns reduced usability despite visual appeal.'

- https://dl.acm.org/doi/10.1016/j.ijhcs.2012.06.003

- https://design.google/library/expressive-material-design-google-research

### The physiological cost of a screen comes from COMPLEXITY, not from chroma. This is the finding that makes 'beautiful material, simple structure' defensible for a sensory-sensitive audience.

*Confidence: high, **LOAD-BEARING***

Tuch et al. (2009), cited within the 2012 paper: visual complexity of web pages 'was related to increased experienced arousal, more negative valence appraisal, and increased facial muscle tension (musculus corrugator)' — i.e. measurable frowning. The manipulated variable was complexity. Also relevant and load-bearing against over-claiming: Berlyne's (1974) inverted-U predicts MODERATE complexity is most pleasurable and that low-arousal stimuli are experienced as BORING — but Tuch et al. note 'the empirical support for this inverted U-shaped relation is mixed, several studies found a linear rather than a quadratic relation (Martindale et al., 1990),' and their own data found complexity monotonically decreased beauty in the high-PT condition. So 'simple' does not empirically read as 'boring' here — but only when prototypicality is high.

- https://dl.acm.org/doi/10.1016/j.ijhcs.2012.06.003

### The 'muted / no bright colors' prescription is MUCH softer in the first-person autistic data than the brief carries it — a minority view, and state-conditional rather than trait-level.

*Confidence: high, **LOAD-BEARING***

Martin & Nagalakshmi, 'Aging Up AAC' (arXiv 2404.17730), n=12 autistic adults — this is the study behind the brief's 12-participant figures. §5.3.3 verbatim: all 12 wanted customization; 7/12 wanted the app to 'not feel overwhelming'; of those, only 2 said 'not visually overwhelming', 4 said 'clear layout and organization with fewer possibilities', and only **3 said 'no bright colors—especially when they are already feeling overwhelmed.'** Read carefully: 3/12 = 25%, and the qualifier is a STATE condition, not a standing preference. The 4/12 'fewer possibilities' vote is about COMPLEXITY, not color — consistent with Tuch. The evidence base does not support 'muted' as a universal law; it supports low complexity as the general rule and reduced chroma as a state-triggered, user-invoked accommodation.

- https://arxiv.org/pdf/2404.17730

### The source study's own design recommendation IS the low-stimulus release valve — including its two binding constraints. This is the architectural answer and it is not speculative.

*Confidence: high, **LOAD-BEARING***

Martin & Nagalakshmi §6.5 'Same-app Switching', verbatim recommendation (2) of 3: 'simplifying the app's colors or board when the user is overwhelmed (§5.3.3)'. Followed immediately by: 'The application should integrate these in an intentional way that keeps the user in control (§5.8.1) and does not impede motor plans (§5.1.1).' Two constraints fall out: (a) user-invoked, never automatic; (b) must not disturb motor plans — i.e. it may change COLOR but must never move a tile. A participant elsewhere in the paper: 'motor plans back and forth a lot' was a named complaint. This directly answers 'does progressive disclosure break the fixed-layout rule?' — No, provided only the surface changes and the geometry is invariant.

- https://arxiv.org/pdf/2404.17730

### Automatic adaptation is banned by the data — more strongly than any other feature tested. The low-stimulus mode must be manual.

*Confidence: high, **LOAD-BEARING***

Martin & Nagalakshmi §5.8.1: 'half of our participants (6) said that automatic personalization was never a good feature, more than any other feature in our quantitative analysis (Figure 4).' Participant quote: 'if it's dynamically adjusting itself in response to how I interact with it, I hate that.' Another: 'I turned off every single prediction that ClaroCom [has], including its built-in support for learning automatically. I don't even like that it has those knobs. I'd rather it just plain didn't do any of that.' Note the second quote goes further than opt-out: the mere PRESENCE of the knob was objectionable. Implication: don't ship an auto-detect-distress feature even switched off by default.

- https://arxiv.org/pdf/2404.17730

### Do NOT justify beauty with the aesthetic-usability effect. It is the weakest link in the pro-beauty case and it will not survive scrutiny.

*Confidence: high, **LOAD-BEARING***

The canonical chain is Kurosu & Kashimura (1995, ATM layouts) and Tractinsky's (1997) Israeli replication, which found 'very high correlations' between perceived aesthetics and a priori perceived ease of use. But: (a) Tractinsky et al. themselves flagged unknown boundary conditions; (b) the early work was CORRELATIONAL and did not manipulate aesthetics and usability as independent variables, so direction of causation was never established; (c) Grishin & Gillan (2019), J. Usability Studies 14, 76–104, which DID manipulate them separately, found 'only limited support, at best, that aesthetics played any role in participants' perceptions of usability, both in early interactions and with continued use,' concluding 'it appears that usability and aesthetics were perceived separately.' Also note Tractinsky et al. (2006)'s response-latency finding is criticized inside the Tuch 2012 paper itself: 'we will present evidence that these results are based on a problematic statistical procedure.' Beauty here must be argued on adoption and dignity, not on a claimed usability halo.

- https://uxpajournal.org/boundary-conditions-aesthetics-usability/

- https://dl.acm.org/doi/abs/10.5555/3532689.3532692

- https://dl.acm.org/doi/pdf/10.1145/258549.258626

### Material 3 Expressive's usability claim is real and peer-reviewed, but the honest number is 33%/20% — not the '4x' from the marketing page — and the mechanism is emphasis hierarchy, which this product must mostly REFUSE.

*Confidence: medium, **LOAD-BEARING***

Peer-reviewed: Bentley, Schmidt, Sheehan, Gallardo & Wang, 'Usability Hasn't Peaked: Exploring How Expressive Design Overcomes the Usability Plateau,' CHI 2026 (DOI 10.1145/3772318.3790373). n=48 participants, 10 applications: M3 Expressive designs produced fixation on the correct screen element 33% faster and task completion 20% faster, with more positive ratings. The Google Design marketing page instead claims 'up to four times faster' (eye-tracking, 10 apps) plus preference 'up to 87%' among 18–24s and desirability deltas (+34% modernity, +32% subculture, +30% rebelliousness) — 'up to' figures, not the published central estimates. Critical caveat for THIS product: M3E's speed gain comes from making ONE element win — differentiated shape/size/color/containment creating salience hierarchy. In a 12-tile grid of co-equal utterances where position is the retrieval mechanism, a salience hierarchy is actively harmful. Take M3E's material vocabulary; refuse its emphasis doctrine inside the grid.

- https://doi.org/10.1145/3772318.3790373

- https://research.google/conferences-and-events/google-at-chi-2026/

- https://design.google/library/expressive-material-design-google-research

### Trauma-informed design forbids SURPRISE and STEREOTYPE. It does not forbid beauty — and its sixth principle arguably MANDATES the anti-infantilization wedge.

*Confidence: high, **LOAD-BEARING***

SAMHSA's six principles (2014, 'SAMHSA's Concept of Trauma and Guidance for a Trauma-Informed Approach') are: 1) Safety; 2) Trustworthiness & Transparency; 3) Peer Support; 4) Collaboration & Mutuality (leveling power differences); 5) Empowerment, Voice & Choice; 6) Cultural, Historical & Gender Issues — explicitly 'actively moving past cultural stereotypes and biases.' Note what is absent: there is NO aesthetic prescription anywhere in the framework. It is organizational and relational, not visual. Three direct reads for this product: Principle 1 (Safety) is what bans sudden motion and unrequested change — predictability, not drabness. Principle 5 (Voice & Choice) makes the manual low-stimulus toggle a trauma-informed REQUIREMENT rather than a nicety. Principle 6 is a mandate against the mascot/parental-gate stereotype — i.e. trauma-informed practice is on the founder's side here, not the grey rectangle's.

- https://stacks.cdc.gov/view/cdc/56843

- https://www.ncbi.nlm.nih.gov/books/NBK601490/box/ch3.b16/?report=objectonly

### Calm Technology is orthogonal to expressive design, not opposed to it. It is a theory of ATTENTION DEMAND, and this app is already maximally calm by construction.

*Confidence: high, **LOAD-BEARING***

Amber Case's principles (2010, book 2015): technology should require the smallest possible amount of ATTENTION; should make use of the periphery; 'the right amount of technology is the minimum needed to solve the problem'; should work even when it fails; should respect social norms; should amplify the best of technology and the best of humanity. Case's own writeup makes no mention of visual aesthetics, beauty, color, or decoration — the framework is about interruption, notification, and periphery. A summoned, offline, notification-free, zero-animation app that never speaks unless tapped is already the calm-tech ideal. Two principles actively support the brief: 'respect social norms' (Case glosses this as not disrupting existing cultural practice — an app that marks its user as medical in a cafe is violating a social norm) and 'amplify the best of humanity' ('design for people first'). 'Question every addition' applies to FEATURES and attention claims, not to hues. Calm tech would object to a pulsing badge; it has nothing to say about a well-chosen ochre.

- https://www.caseorganic.com/post/principles-of-calm-technology

- https://calmtech.com/

### The Pullin 'glasses' argument is this product's strongest pro-beauty warrant, and unlike the aesthetic-usability effect it has supporting evidence in assistive tech specifically.

*Confidence: medium, **LOAD-BEARING***

Pullin, 'Design Meets Disability' (MIT Press, 2009): glasses moved from medical appliance to fashion accessory by adopting not just the LANGUAGE of fashion but its CULTURE; 'design for disability has traditionally seen its role to restore ability as discretely as possible,' yielding 'decades of pink plastic aids' — and eyewear's success 'challenges the notion that discretion is always the best policy.' Pullin is not a generic reference here: he ran the Six Speaking Chairs project at Dundee and co-authored Pullin & Hennig, '17 Ways to Say Yes: Toward Nuanced Tone of Voice in AAC and Speech Technology' (AAC, 31(2), 2015) — his central AAC claim is that flat, uncontrollable TTS tone 'can give a false impression that the person using them is also emotionally impaired.' Supporting empirical evidence: Aesthetics and the perceived stigma of assistive technology for visual impairment (Disability & Rehabilitation: Assistive Technology, 2022; 17(2)) found devices with modern aesthetics and no negative symbolism (smart glasses) were accepted MORE than devices carrying traditional disability symbolism (white cane), and concludes designers should consider aesthetics to avoid perceived stigma 'thereby reducing the chances of device abandonment.' Phillips & Zhao (1993) 'Predictors of Assistive Technology Abandonment' found lack of consideration of USER OPINION in device selection was a significant abandonment predictor — which is an argument for choice, and for the user's own taste counting.

- https://mitpress.mit.edu/9780262516747/design-meets-disability/

- https://www.tandfonline.com/doi/full/10.1080/17483107.2020.1768308

- https://www.researchgate.net/publication/13125783_Predictors_of_Assistive_Technology_Abandonment

- https://www.tandfonline.com/doi/full/10.3109/07434618.2015.1037930

### Autistic color preference is driven by sensory SUBTYPE, not by autism. 'Sensory-friendly = beige' is partly a stereotype designed AT autistic people — but the muted default is still defensible for THIS audience on selection grounds.

*Confidence: medium, **LOAD-BEARING***

Chen et al. (2025), Humanities & Social Sciences Communications (Nature portfolio), s41599-025-05753-4: n=46 autistic participants aged 6–40, mixed methods (120 survey responses, 15 interviews). High-sensitivity group preferred soft colors (M=4.5) over bold (M=2.0); LOW-sensitivity group inverted it — preferring bold colors (M=4.3) over soft (M=2.5), describing them as 'exciting' and 'energizing'; medium group was balanced. Correlation high-sensitivity↔soft color r=0.72, p<0.01. Caveats that matter: no non-autistic control group, wide age range, small n, and 'emotional resonance score' is a non-standard measure — treat as directional, not definitive. Separately, the provenance of the 'low arousal colours' doctrine is worth naming: it traces to National Autistic Society guidance and classroom design — i.e. developed largely by non-autistic educators for autistic CHILDREN in institutional settings, then generalized to adults and to software. The n=12 first-person adult data (3/12, state-conditional) does not carry it. HOWEVER: this product's audience is self-selecting for sensory hypersensitivity — they are defined by shutting down from overload — which maps onto the high-sensitivity group. So a muted DEFAULT is defensible on audience-fit grounds, and should be argued that way. It is not defensible as 'autistic people need beige.'

- https://www.nature.com/articles/s41599-025-05753-4

### The real tension is temporal, not aesthetic: beauty is consumed at rest, the interface is consumed in crisis, and they are never the same moment.

*Confidence: medium, **LOAD-BEARING***

Synthesis rather than a single citation, but it is what the sources converge on. The shutdown user's entire task is: find tile, tap. The beauty-judging user is in a shop, on a home screen, showing a friend, or in the ~95% of hours not in shutdown. Martin & Nagalakshmi's 3/12 'no bright colors' is explicitly hedged 'especially when they are already feeling overwhelmed' — the same people, different state. Melfsen et al. (2021)'s 'unsafe world model' of selective mutism, cited in that paper, frames loss of speech as 'a shut down of the nervous system from a perceived lack of safety,' with overstimulation as a trigger. So the design does not have to serve both states with one surface — it has to serve both states with one STRUCTURE and two surfaces, switched by the user. Because complexity (not chroma) is what carries the arousal cost, and because the structure is what carries the retrieval, the structure can be held invariant while the chroma flexes. That is the whole resolution.

- https://arxiv.org/pdf/2404.17730

### Counter-evidence worth holding: for some AAC users the goal is not to look non-medical — it is to be legible as needing support. Do not over-rotate on 'make it look like a consumer app.'

*Confidence: medium*

Kane et al. / 'The Role of AAC in Social Communication and Community Engagement: Experiences and Opinions of Autistic Adults' (arXiv 2507.00202), n=5 autistic adults aged 23–38, 5-week asynchronous text focus group. Participants feared using AAC in public — one had not been 'brave enough to use' their communication book: 'I'm terrified to use it because I don't think anyone will understand.' Another described being 'seen as not human because of how I communicate.' But critically, one wanted MORE visibility, not less: 'Instead of just a little book [in] my pocket, maybe something that would be seen that would say hey you need some extra support and help.' Interpretation: the enemy is being MISREAD, not being SEEN. This nuances Pullin — the aim is not camouflage and not a fashion object per se, it is a device that reads as 'a competent adult is speaking through this' rather than 'a patient' or 'a child.' Small n; treat as a caution flag, not a mandate. It also raises the stakes on show mode, which is the moment a stranger forms that judgment.

- https://arxiv.org/html/2507.00202v2

### There is no direct evidence on beauty/aesthetics and autistic users specifically. The field is assuming.

*Confidence: medium*

Searches surfaced abundant guidance on autistic sensory design (National Autistic Society low/high arousal colours, Mostafa's ASPECTSS, interior/architectural guidance) and abundant general aesthetics research (Tuch, Tractinsky, Grishin), but nothing measuring aesthetic JUDGMENT or aesthetic benefit in autistic users. The 2025 Nature paper measures sensory preference, not beauty. Neither the M3 Expressive CHI paper nor Tuch et al. report autistic subgroups. Practical consequence: no one can tell the founder that beauty is contraindicated for this audience, because nobody has looked. The burden of proof is not on the founder. Angelita Scott's Metropolis piece notes designers have operated with 'a generalized approach that assumes design for neurodiversity means a generalized sensory scale between hypersensitive and hyposensitive' — treating the spectrum as uniform, when 'a space designed to soothe one autistic person might actively disorient another.' Notably, that piece — a leading critique of autism design practice — itself contains no first-person autistic voices, which is a fair summary of the state of the field.

- https://metropolismag.com/viewpoints/we-need-a-new-approach-to-designing-for-autism/

- https://www.nature.com/articles/s41599-025-05753-4

## Design moves

- **Make the 12 tiles ISOLUMINANT: each tile gets its own muted hue from a 4-hue category system, but ALL tiles are rendered at identical L* (e.g. L*=42 in dark theme, L*=88 in light), within ±2 L*. Vary hue and chroma; never vary lightness.**
  - Why: This is the single highest-leverage move and it dissolves the tension mechanically. Salience is driven overwhelmingly by luminance contrast, not hue. Equal-lightness tiles mean the screen is chromatically rich (beautiful, warm, non-medical, adult) while NO tile shouts louder than any other — zero salience hierarchy, so nothing grabs a distressed nervous system, and position remains the sole retrieval mechanism per the fixed-layout rule. It also keeps VC low (Tuch): a regular grid of equal-weight elements reads as simple no matter how many hues it carries. Complexity is what raises corrugator tension (Tuch 2009), not chroma.
  - Risk: Isoluminant color is invisible to users with colour vision deficiency and washes out in the high-contrast theme. This is ONLY safe because hue is decorative here and carries no information position doesn't already carry — you must enforce that invariant: if hue ever becomes load-bearing (e.g. the only marker of category), this move becomes an a11y failure. Also verify L* equality in OKLCH, not HSL — HSL 'lightness' is not perceptual and will lie to you.
- **Ship low-stimulus as a FOURTH THEME, not as a mode. Light / Dark / High-contrast / Low-stimulus in the existing one-tap switcher. Low-stimulus collapses all 4 category hues to a single neutral at the same L*, and changes nothing else.**
  - Why: This is the key architectural answer and it's cheap. Calling it a theme rather than a mode structurally guarantees it can only touch surface, never layout — it inherits the theme system's existing contract. It costs zero new UI (the one-tap theme control is already in the spec), it is manual by construction (satisfying the 6/12 'automatic personalization is never good' finding), and it is precisely Martin & Nagalakshmi §6.5's own recommendation: 'simplifying the app's colors or board when the user is overwhelmed... keeps the user in control and does not impede motor plans.' It is the release valve that lets the default be beautiful. Note it also satisfies SAMHSA principle 5 (Voice & Choice), making it trauma-informed rather than merely nice.
  - Risk: The user must be able to reach it DURING a shutdown, one-handed, with reduced decision-making — so the theme control must itself be large (≥76dp), fixed-position, and reachable in the lower arc. Risk of the toggle becoming a 4-state cycle that requires 3 taps to get where you want: if a cycle, order it Light→Dark→Low-stimulus→High-contrast so the two calm states are adjacent. Do NOT add distress auto-detection even as an opt-in — a participant objected to the mere presence of the knob.
- **Spend the entire beauty budget on TYPOGRAPHY, not ornament. The tiles ARE type — text-only MVP means 90% of the pixels are letterforms. Use optical-size-aware type (Roboto Flex or the system font's optical axis), tune the grade for dark vs light theme separately, set tile labels at ~20pt/weight 550 with tightened tracking (-1.5%) at that size, and do real typographic craft: consistent baseline grid, optical centering (not geometric — text sits ~2% high), hanging punctuation.**
  - Why: This delivers 'beautiful, creative, not-2014' at ZERO visual complexity cost, which is exactly what Tuch's low-VC/high-PT formula demands. Print has been beautiful for 500 years without moving, and typography is the one design material that gets MORE legible as it gets more crafted — beauty and usability are literally the same variable here. It is also the highest-craft-per-byte move available to a solo dev: no illustration commissions, no asset pipeline.
  - Risk: Must survive TextScaler to 200%+ without clamping (spec requirement) — tightened tracking and baseline grids break under extreme scaling, so tracking must be a function of computed size, and the baseline grid must degrade gracefully rather than clip. Optical sizing + variable font axes add font file weight to an offline app. Atkinson Hyperlegible has no optical size axis and a limited weight range — if the user selects it, the tracking/grade tuning must have a documented fallback.
- **Set tile corner radius to ~24dp on a 76dp+ tile (roughly a 0.3 radius ratio), IDENTICAL on every tile, with a 16dp gutter. Do not vary shape, size, or radius for emphasis.**
  - Why: Large, consistent radius is the cheapest possible 'this is 2026, not 2014' signal — the 2014 enterprise grid is 2–4dp radius, hard rectangles, tight gutters. This borrows M3 Expressive's shape vocabulary (which the CHI 2026 paper, n=48, associates with 33% faster fixation and 20% faster task completion) while explicitly REFUSING its emphasis doctrine. M3E gets its speed by making one element win; a 12-tile grid of co-equal utterances must have no winner, or the salience hierarchy fights the positional retrieval the whole product depends on.
  - Risk: Radius that large eats corner area on a 76dp target — the touch target must stay a full rect (76dp minimum hit-slop), not the visual rounded shape, or motor-imprecise taps at corners will miss. Also, uniform shape forfeits M3E's actual measured benefit; you are taking the aesthetic and declining the ergonomics, so do not cite the 33%/20% figure as if this design earns it.
- **Apply M3 Expressive's emphasis vocabulary ONLY to the chrome — the theme toggle, the type-to-speak field, edit mode, settings. Never inside the tile grid.**
  - Why: Clean split that lets you take the modern design language without the hierarchy hazard. The chrome genuinely HAS a hierarchy (the type field and theme toggle are differently-important than each other), so differentiated shape/size/color is honest there and buys the 'creative, not formal' read. The grid has no hierarchy and must not fake one.
  - Risk: Chrome that is more expressive than the grid can end up out-shouting it — the grid is the product. Constrain chrome chroma to ≤ the tile chroma, and keep the chrome's L* clearly BELOW the tiles in dark theme (above in light) so the tiles remain the figure and the chrome stays ground.
- **Invert everything in show mode: maximum luminance contrast, single achromatic pair, type at 96pt+, one utterance, edge-to-edge. Show mode is where the design is allowed to be LOUD.**
  - Why: The audiences are opposite and the optimizations are opposite (already established in the brief). But there's a second reason grounded in the n=5 focus group: 'seen as not human because of how I communicate.' Show mode is the exact three seconds in which a stranger forms a judgment about the user's personhood. It is therefore the highest-stakes dignity surface in the app, not a utility screen. A confident, dramatic, beautifully-set full-bleed sentence reads as 'a competent adult is speaking'; a small grey label in a dialog reads as 'a patient.' This is where the Pullin argument cashes out.
  - Risk: Show mode's high luminance is actively hostile to the user's own eyes — they are holding the device and in a sensory-sensitive state. It must be strictly momentary and user-dismissed, never a state you can get stuck in, and the transition must be instant (zero animation) so there is no ramp. Consider that turning the screen to a stranger means the USER is not looking at it — but they may look back. Do not let a 96pt white screen be what they return to; dismissal must be one large tap anywhere.
- **Enforce geometric invariance across all four themes with a test: render the grid in every theme, assert tile rects are pixel-identical. Make it a CI check, not a convention.**
  - Why: This is the hard constraint from Martin & Nagalakshmi ('does not impede motor plans') and the spec's fixed-position rule, and it is the ONLY thing that makes the beautiful default safe. If the structure is provably invariant, then in shutdown the chroma is simply not attended to — it costs nothing, because the muscle memory addresses position and position never moved. The whole 'beautiful at rest, ruthless in use' strategy stands or falls on this being mechanically guaranteed rather than remembered.
  - Risk: A theme that changes type weight or tracking can reflow label line-breaks, which changes tile content height even when the rect is fixed — assert on the tile RECT, and separately assert that label line-count per tile is theme-invariant at a given TextScaler. High-contrast theme may want heavier type, which is exactly the thing that would break this; resolve by changing weight only, never size.
- **Drop 'no bright colors' from the constraint list as a universal, and re-derive the muted default from audience selection instead. Document it as: 'muted default because this audience self-selects for sensory hypersensitivity, and the user can change it' — not 'muted because autistic.'**
  - Why: Intellectual honesty that has a product consequence. The n=12 data says 3/12, state-conditional. The 2025 Nature data says sensory subtype — not autism — predicts color preference, with the low-sensitivity group actively preferring bold color (M=4.3). Carrying 'muted' as a law rather than a default is how you end up at the grey rectangle the founder is trying to escape, and it would be justified by evidence that doesn't exist. Re-deriving it from audience fit keeps the default (which is correct for this audience) while removing the false mandate that suppresses the founder's brief.
  - Risk: This opens the door to a user-facing chroma/palette setting, which is scope. Resist: ship the muted default plus the low-stimulus theme, and treat 'more saturated palette' as a v1+ option. Do not let 'autistic people aren't a monolith' become an argument for a color picker in the MVP — 4/12 explicitly wanted FEWER possibilities.
- **Kill any 'Great job' / mascot / reward surface — and cite SAMHSA principle 6 when the pressure comes to add one, not just taste.**
  - Why: Gives the ban an external, professional warrant rather than a founder preference. SAMHSA's sixth trauma-informed principle mandates 'actively moving past cultural stereotypes and biases.' Combined with Martin & Nagalakshmi's participant — 'Many AAC apps feel like they're made for kids or students, and it feels infantilizing' (5/12 held this view) — the anti-infantilization wedge is a trauma-informed REQUIREMENT, not a style choice. This matters when an app-store reviewer, a clinician, or an investor asks why there's no encouragement copy.
  - Risk: None to the product. The risk is rhetorical overreach: SAMHSA principle 6 is about cultural/historical/gender stereotypes in service delivery, and applying it to UI copy is an extension, defensible but not literal. Don't present it as SAMHSA prescribing UI.
- **Give tone-of-voice / voice identity the same craft budget as the visuals — nonbinary/middle-pitch voice options are a v1 dignity feature, not a settings-screen afterthought.**
  - Why: Pullin & Hennig's core AAC finding is that flat, uncontrollable TTS tone 'can give a false impression that the person using them is also emotionally impaired' — the voice IS the product's output, and it is the part strangers actually receive. Martin & Nagalakshmi §6.6 independently: participants want voices matching 'their identity, not necessarily their body's voice,' and note the large trans*/autistic overlap (Warrier et al. 2020), consistent with the brief's 4/12. This is the one dimension where 'beautiful' is unambiguously free of any usability cost — a well-chosen voice costs zero pixels and zero complexity.
  - Risk: Offline constraint is the real blocker: on-device Android TTS voice inventory is device-dependent and the nonbinary/middle-pitch options may simply not exist on a given handset. Pitch-shifting a gendered voice is a poor substitute and can read as a novelty effect — which would be actively undignified. Scope this as 'expose and curate what the device has, degrade honestly,' not 'ship a voice.'

## References

- **Teenage Engineering OP-1 / OP-Z** https://teenage.engineering/products/op-1
  - Steal: The proof that muted-ground-plus-saturated-accent is an ADULT signal, not a childish one. Flat neutral chassis, zero ornament, zero gradient, and then a small number of unapologetically saturated functional accents that carry identity. Steal specifically: the discipline of letting color be the ONLY decoration, and letting it sit on large fields of quiet neutral. This is the single closest existing answer to 'warm and adult, not grey and not cartoon.'
- **iA Writer** https://ia.net/writer
  - Steal: Existence proof that a text-only surface can be an object of desire. Nearly empty screen, beauty carried 100% by typography, spacing, and one restrained accent — no illustration, no motion. Steal: the type-as-the-entire-design approach, the custom-tuned typeface for screen at reading sizes, and the way its 'focus mode' strips chrome WITHOUT moving the text. That last part is exactly the low-stimulus-theme pattern.
- **Massimo Vignelli / 1972 NYC Subway Diagram + Unimark** https://www.moma.org/collection/works/139322
  - Steal: The 500-year argument, made in one artifact: a rigid grid, ~4 colors, one typeface, zero ornament — and it hangs in MoMA. Steal the specific technique of using a strictly limited hue set as pure identification on an invariant geometry, where color never encodes anything position doesn't. That is precisely the isoluminant-tile move. Also steal Vignelli's insistence that restraint IS the expressive act — useful ammunition against 'simple = boring' (Berlyne's inverted-U).
- **Graham Pullin, Six Speaking Chairs & '17 Ways to Say Yes' (Pullin & Hennig, AAC 31(2), 2015)** https://www.tandfonline.com/doi/full/10.3109/07434618.2015.1037930
  - Steal: Not a visual reference — the strategic one. Steal the framing that expressive RANGE is dignity, and that a device offering only flat affect misrepresents its user as emotionally flat. Directly applicable to voice selection and to show mode's typography. Also steal the research method: physical probes that let non-speaking people express preferences about tone without having to describe them verbally.
- **Eone Bradley Timepiece** https://eone-time.com/
  - Steal: The Pullin argument actually executed and commercially validated: a watch designed to be read by touch for blind users that sighted people buy because they want it. Steal the positioning move — never marketed as an accessibility device, marketed as a beautiful object that happens to be readable without sight. This is the exact posture for an AAC app that must not read as medical, and it's the counter-example to 'accessible products can't be desirable.'
- **Material 3 Expressive shape & containment vocabulary (Bentley et al., CHI 2026)** https://m3.material.io/blog/building-with-m3-expressive
  - Steal: Take the shape scale (large corner radii, generous containment, confident type scale) and the color-role system. Explicitly DECLINE the emphasis doctrine — the differentiated shape/size/color-for-hierarchy that produced the measured 33%/20% gains — because a co-equal 12-tile grid must have no salience winner. Steal the material, refuse the hierarchy.
- **Braille Institute — Atkinson Hyperlegible (and Hyperlegible Next, 2025)** https://www.brailleinstitute.org/freefont/
  - Steal: Already in the spec, but steal the right lesson: it is a legibility-first typeface that is also genuinely handsome, designed by a disability organization that refused to make it look clinical. Its existence is the counter-argument to the premise that accessibility forces ugliness. Check Hyperlegible Next's expanded weight range before committing to the weight-550 tile spec.
- **Martin & Nagalakshmi, 'Aging Up AAC' (arXiv:2404.17730)** https://arxiv.org/pdf/2404.17730
  - Steal: The n=12 primary source behind this entire product. Steal §6.5 'Same-app Switching' as the literal architecture spec for the low-stimulus theme, §5.3.3 for the real (much softer) color numbers, and §5.8.1 for the automation ban. Read the whole thing before making any further constraint decisions — the brief's constraints are downstream of this paper and, as shown above, are carried harder than the paper supports in at least one place.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PRODUCT ===

An offline AAC (augmentative & alternative communication) app for autistic adults and teens with situational/part-time speech loss — people who can usually speak but go non-speaking during shutdowns, meltdowns, or sensory overload. Flutter, Android-first. Solo developer.

The app is ONE screen: a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface. Tap a tile, the phone speaks it aloud (or shows it in huge text — a co-equal "show mode" where you turn the screen to a stranger). Plus an edit mode and settings. No accounts. No network. Nothing leaves the device.

=== THE DESIGN BRIEF FROM THE FOUNDER (verbatim, and it is the point of this research) ===

"I don't want something like the design of ten years ago. I don't want something formal. I want something creative. I want something beautiful."

Take this seriously and literally. The default failure mode of an "accessible, calm, adult" app is that it becomes a grey rectangle grid that looks like a 2014 enterprise settings screen. That is the thing to avoid. The founder is asking for craft, personality, and beauty — and the research must find how to deliver that WITHOUT breaking the constraints below, not treat the constraints as an excuse to be boring.

=== WHAT PRIOR RESEARCH ESTABLISHED (do not re-litigate; design WITHIN these, or argue explicitly and with evidence where a constraint is softer than it looks) ===

- **The wedge is dignity.** Every mainstream AAC app is designed for children — cartoon avatars, mascots, puzzle pieces, primary-color rainbows, star/reward motifs, "Great job!" copy, parental gates. Adults abandon them. BANNED, permanently: cartoon avatars, mascots, animal characters, puzzle-piece iconography, gamification, streaks, badges, confetti, encouragement copy, any "parent/caregiver" framing.
- **CRITICAL NUANCE, and the opening for this whole research:** the study behind this found infantilization was about **VOCABULARY and being treated as a student — NOT about color**. The prior brief's own conclusion: *"DO NOT confuse 'adult' with 'monochrome and cold.' You can be warm and adult. The enemy is cartoon avatars and parental gates — not saturation."* So "adult" does NOT mandate grey. This is the permission slip. Use it.
- **Zero animation.** Two independent reasons: (a) distress/trauma-informed guidance warns against sudden motion for sensitized nervous systems; (b) animation costs latency in a product whose premise is instant speech. Honor `MediaQuery.disableAnimationsOf` → zero duration. **So beauty here CANNOT come from motion. It must come from composition, type, color, material, and craft. Print has been beautiful for 500 years without moving.**
- **Sensory sensitivity is the audience's defining trait.** Muted, low-saturation, ~2-5 intentional hues; high saturation only as sparing accents. But saturation and contrast are SEPARABLE — muted hues at high luminance contrast is the target.
- **Dark, light, AND high-contrast themes, all switchable in ONE TAP from the main screen.** Dark mode is contested in the research: [While & Sarvghad 2024](https://arxiv.org/pdf/2409.10841) found each polarity benefits comparable proportions and recommends shipping both; observers with cloudy ocular media read 10-15% better in dark. So dark is a choice, not the answer. **The dominant halation lever is TEXT luminance, not background hex** (#FFFFFF→#E0E0E0 drops contrast 21:1→15.91:1, a 24% cut; #000→#121212 only moves 21:1→18.73:1).
- **Material 3 is Flutter's default since 3.16.** M3's baseline dark surface is #141218 (neutral tone 6) with tone-based surface containers, NOT M2's #121212 + elevation overlays. Use `ColorScheme.fromSeed`.
- **Huge targets** (76dp floor, 12dp min gaps), 3x4 grid default with a 2x3 "large" option, **fixed tile positions** (no reflow ever — position IS the retrieval mechanism), highest-value tiles in the **lower-CENTER arc** (not upper-left; not the extreme bottom edge).
- **Typography**: system font or Atkinson Hyperlegible (Braille Institute, OFL). Tile labels min 17pt, default ~20pt, weight 500-600. MUST honor TextScaler to 200%+ without clamping. No dyslexia font as default (OpenDyslexic *decreased* fluency in the studies) but offer it as an option.
- **Show mode is the exception to the calm rule** — a cashier reads it at arm's length in daylight. Dark/low-luminance is right for the user's eyes and WRONG for a stranger reading the screen. Opposite optimizations.
- **Fitzgerald Key part-of-speech coloring is out** (each tile is a whole utterance, so grammar coloring is meaningless). But **category color-coding is fine and useful** for findability — the research explicitly did NOT find color-coding infantilizing.
- Symbols are v1+, text-only for MVP, and text-only stays first-class (for many literate adults the symbol set IS the infantilizing element). If symbols ship: Mulberry, runtime-tinted.
- The user may be in a shutdown: reduced decision-making, possible motor imprecision. One-handed. Phone, not tablet.
- Voice/identity matters: this audience skews trans/nonbinary; 4/12 wanted nonbinary/middle-pitch voices.

Today is 2026-07-15. Prefer 2025-2026 sources. Design moves fast — a 2019 article on "modern mobile design" is describing history.


YOUR DIMENSION: The hard tension — can "creative and beautiful" coexist with "usable during a shutdown"? Interrogate this honestly; do not resolve it cheaply.

- **The case AGAINST expressive design here**: cognitive load, visual complexity, decision paralysis, sensory overload. Does beauty cost legibility? Does personality cost speed? What does the evidence on visual complexity and cognitive load actually say (Google's "visual complexity and prototypicality" research on aesthetic judgment — find it; the "low complexity + high prototypicality = perceived beauty AND usability" finding is directly relevant and may resolve the whole tension). Is there a real trade-off, or is that a false binary designers use to excuse ugliness?
- **The case FOR**: Material 3 Expressive's claim is that expressive design was FASTER to parse (verify). The aesthetic-usability effect (Kurosu & Kashimura 1995; Tractinsky's replication — get the real finding and its limits; it's often overstated). Does beauty create trust? Does an app you're proud to be seen using get used MORE — which for an abandonment-prone product is THE metric? (Recall: 11/12 use AAC only where they feel safe; 4/12 avoid situations to dodge reactions to their device. If the device looked *desirable* rather than *medical*, does that change? THAT'S THE PULLIN "glasses" ARGUMENT and it may be this product's most important design insight.)
- **Resolve it**: is there a design strategy that's beautiful at rest AND ruthlessly simple in use? Ideas to interrogate: beauty in the *material* (color, type, surface craft) but simplicity in the *structure*; "quiet" beauty vs "loud" beauty; progressive disclosure (rich in edit mode, stark in speak mode — does that break the fixed-layout rule? does the app get SIMPLER as the user gets more distressed, and can that be manual rather than automatic? Note: 6/12 said auto-personalization should NEVER activate, so automatic mode-switching is out — but a MANUAL low-stimulus mode is already in the spec. **Is the low-stimulus mode the release valve that lets the default be beautiful?** Go at this hard, it may be the key architectural answer).
- **Trauma-informed design**: get the actual principles from real sources, not blog summaries. What does it mandate and what does it merely suggest? Does it forbid beauty or forbid surprise?
- **Calm technology** (Amber Case's principles) — what does it actually say? "Question every addition"? Is calm technology compatible with expressive design or opposed to it?
- What do actual autistic designers say about design for autistic people? Find first-person sources, not clinical ones. Is the "muted, calm, low-stimulus" prescription something autistic people ASKED for, or something designed AT them? THIS IS A REAL QUESTION AND THE ANSWER MIGHT BE UNCOMFORTABLE — the audience is not a monolith, and "sensory-friendly = beige" may itself be a stereotype. Investigate seriously.
- Is there evidence about beauty/aesthetics and autistic users specifically? Or is the field just assuming?

Be rigorous. This dimension decides whether the founder's brief is achievable or a contradiction. Come back with an honest verdict and a strategy.
````

</details>
