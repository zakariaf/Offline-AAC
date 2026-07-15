export const meta = {
  name: 'aac-design-system',
  description: 'Research a contemporary, creative, beautiful design system for the offline AAC app',
  phases: [
    { title: 'Research', detail: '11 parallel researchers across design dimensions' },
    { title: 'Verify', detail: 'fact-check load-bearing design/tech claims' },
    { title: 'Critique', detail: 'art director + a11y designer + autistic-user lens' },
    { title: 'Author', detail: 'write DESIGN_SYSTEM.md + DESIGN_RATIONALE.md' },
  ],
}

const FINDINGS_SCHEMA = {
  type: 'object',
  properties: {
    dimension: { type: 'string' },
    summary: { type: 'string', description: '4-8 sentence executive summary' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          claim: { type: 'string' },
          detail: { type: 'string', description: 'Specifics: exact values, hex codes, type sizes, spec names, dates' },
          sources: { type: 'array', items: { type: 'string' } },
          confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
          loadBearing: { type: 'boolean' },
        },
        required: ['claim', 'detail', 'confidence', 'loadBearing'],
      },
    },
    designMoves: {
      type: 'array',
      description: 'Concrete, specific, implementable design decisions — not principles',
      items: {
        type: 'object',
        properties: {
          move: { type: 'string', description: 'e.g. "tile corner radius 20dp, not 8" — specific and checkable' },
          why: { type: 'string' },
          risk: { type: 'string', description: 'How this could conflict with distress-use, a11y, or dignity constraints' },
        },
        required: ['move', 'why'],
      },
    },
    references: {
      type: 'array',
      description: 'Specific products/apps/designers/artifacts worth stealing from, with WHAT to steal',
      items: {
        type: 'object',
        properties: { name: { type: 'string' }, url: { type: 'string' }, steal: { type: 'string' } },
        required: ['name', 'steal'],
      },
    },
  },
  required: ['dimension', 'summary', 'findings', 'designMoves'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    refuted: { type: 'boolean' },
    verdict: { type: 'string', enum: ['CONFIRMED', 'PARTIALLY_TRUE', 'REFUTED', 'UNVERIFIABLE'] },
    correction: { type: 'string' },
    evidence: { type: 'string' },
    sources: { type: 'array', items: { type: 'string' } },
  },
  required: ['refuted', 'verdict', 'evidence'],
}

const BRIEF = `
=== THE PRODUCT ===

An offline AAC (augmentative & alternative communication) app for autistic adults and teens with situational/part-time speech loss — people who can usually speak but go non-speaking during shutdowns, meltdowns, or sensory overload. Flutter, Android-first. Solo developer.

The app is ONE screen: a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface. Tap a tile, the phone speaks it aloud (or shows it in huge text — a co-equal "show mode" where you turn the screen to a stranger). Plus an edit mode and settings. No accounts. No network. Nothing leaves the device.

=== THE DESIGN BRIEF FROM THE FOUNDER (verbatim, and it is the point of this research) ===

"I don't want something like the design of ten years ago. I don't want something formal. I want something creative. I want something beautiful."

Take this seriously and literally. The default failure mode of an "accessible, calm, adult" app is that it becomes a grey rectangle grid that looks like a 2014 enterprise settings screen. That is the thing to avoid. The founder is asking for craft, personality, and beauty — and the research must find how to deliver that WITHOUT breaking the constraints below, not treat the constraints as an excuse to be boring.

=== WHAT PRIOR RESEARCH ESTABLISHED (do not re-litigate; design WITHIN these, or argue explicitly and with evidence where a constraint is softer than it looks) ===

- **The wedge is dignity.** Every mainstream AAC app is designed for children — cartoon avatars, mascots, puzzle pieces, primary-color rainbows, star/reward motifs, "Great job!" copy, parental gates. Adults abandon them. BANNED, permanently: cartoon avatars, mascots, animal characters, puzzle-piece iconography, gamification, streaks, badges, confetti, encouragement copy, any "parent/caregiver" framing.
- **CRITICAL NUANCE, and the opening for this whole research:** the study behind this found infantilization was about **VOCABULARY and being treated as a student — NOT about color**. The prior brief's own conclusion: *"DO NOT confuse 'adult' with 'monochrome and cold.' You can be warm and adult. The enemy is cartoon avatars and parental gates — not saturation."* So "adult" does NOT mandate grey. This is the permission slip. Use it.
- **Zero animation.** Two independent reasons: (a) distress/trauma-informed guidance warns against sudden motion for sensitized nervous systems; (b) animation costs latency in a product whose premise is instant speech. Honor \`MediaQuery.disableAnimationsOf\` → zero duration. **So beauty here CANNOT come from motion. It must come from composition, type, color, material, and craft. Print has been beautiful for 500 years without moving.**
- **Sensory sensitivity is the audience's defining trait.** Muted, low-saturation, ~2-5 intentional hues; high saturation only as sparing accents. But saturation and contrast are SEPARABLE — muted hues at high luminance contrast is the target.
- **Dark, light, AND high-contrast themes, all switchable in ONE TAP from the main screen.** Dark mode is contested in the research: [While & Sarvghad 2024](https://arxiv.org/pdf/2409.10841) found each polarity benefits comparable proportions and recommends shipping both; observers with cloudy ocular media read 10-15% better in dark. So dark is a choice, not the answer. **The dominant halation lever is TEXT luminance, not background hex** (#FFFFFF→#E0E0E0 drops contrast 21:1→15.91:1, a 24% cut; #000→#121212 only moves 21:1→18.73:1).
- **Material 3 is Flutter's default since 3.16.** M3's baseline dark surface is #141218 (neutral tone 6) with tone-based surface containers, NOT M2's #121212 + elevation overlays. Use \`ColorScheme.fromSeed\`.
- **Huge targets** (76dp floor, 12dp min gaps), 3x4 grid default with a 2x3 "large" option, **fixed tile positions** (no reflow ever — position IS the retrieval mechanism), highest-value tiles in the **lower-CENTER arc** (not upper-left; not the extreme bottom edge).
- **Typography**: system font or Atkinson Hyperlegible (Braille Institute, OFL). Tile labels min 17pt, default ~20pt, weight 500-600. MUST honor TextScaler to 200%+ without clamping. No dyslexia font as default (OpenDyslexic *decreased* fluency in the studies) but offer it as an option.
- **Show mode is the exception to the calm rule** — a cashier reads it at arm's length in daylight. Dark/low-luminance is right for the user's eyes and WRONG for a stranger reading the screen. Opposite optimizations.
- **Fitzgerald Key part-of-speech coloring is out** (each tile is a whole utterance, so grammar coloring is meaningless). But **category color-coding is fine and useful** for findability — the research explicitly did NOT find color-coding infantilizing.
- Symbols are v1+, text-only for MVP, and text-only stays first-class (for many literate adults the symbol set IS the infantilizing element). If symbols ship: Mulberry, runtime-tinted.
- The user may be in a shutdown: reduced decision-making, possible motor imprecision. One-handed. Phone, not tablet.
- Voice/identity matters: this audience skews trans/nonbinary; 4/12 wanted nonbinary/middle-pitch voices.

Today is 2026-07-15. Prefer 2025-2026 sources. Design moves fast — a 2019 article on "modern mobile design" is describing history.
`

const DIMENSIONS = [
  {
    key: 'current-design-language',
    prompt: `${BRIEF}

YOUR DIMENSION: What does mobile design actually look like RIGHT NOW (2025-2026), and what specifically reads as "ten years ago"?

Research with WebSearch/WebFetch. Be concrete and visual, not vibes.

- **iOS 26 "Liquid Glass"** — Apple's 2025 redesign (announced WWDC25). What IS it, concretely? What are the actual material/optical properties (refraction, specular highlights, adaptive tinting, lensing)? What was the reception and the accessibility backlash (legibility complaints, the "Reduce Transparency" fix)? Is it relevant to a Flutter app that deliberately departs from platform defaults? What can be STOLEN from it without the legibility cost?
- **Material 3 Expressive** — Google's 2025 update (announced May 2025 at IO). THIS IS DIRECTLY RELEVANT AND MAY BE THE CENTRAL FINDING: Google did large-scale research (46 studies, 18,000+ participants?) and found expressive design measurably outperformed on speed of element-spotting AND that it worked BETTER for older/low-vision users. VERIFY THOSE NUMBERS AND THAT CLAIM CAREFULLY. What are M3 Expressive's actual mechanics — the shape system (35 shapes?), the new type scale (emphasized styles), color, the spring motion system, "containment", "hero moments"? What is its status in Flutter in 2026 — has Flutter shipped M3 Expressive support? Which parts? (Check Flutter release notes / GitHub issues.)
- **What specifically dates a design to ~2015?** Be concrete and checkable: skeuomorphism? long shadows? flat design 1.0? Material 2's rigid 8dp shadows + FAB + hamburger? bootstrap-y card grids? centered thin-weight type? "corporate memphis" illustration? gradients (which are BACK — how are 2026 gradients different from 2014 gradients)? Give a checkable "if your app has this, it looks old" list.
- **What reads as 2026?** Concrete: shape/corner-radius language, type weight and scale contrast, color (are we in a muted era or a saturated one?), depth (is flat dead? is grain/noise back? is neo-brutalism over?), density, edge treatment, layout (bento grids?), photography vs illustration vs 3D.
- What's the difference between "formal/corporate" design and "creative/expressive" design MECHANICALLY? Name the actual levers, not adjectives.

Be specific enough that a developer could act on it. Name real specs, real numbers, real dates.`,
  },
  {
    key: 'm3-expressive-deep',
    prompt: `${BRIEF}

YOUR DIMENSION: Material 3 Expressive in depth — and whether it's implementable in Flutter in 2026. This may be the single most actionable dimension.

Research with WebSearch/WebFetch: m3.material.io, Google Design blog, the May 2025 IO announcement, Flutter release notes, Flutter GitHub issues/PRs, pub.dev.

- The FULL mechanics of M3 Expressive. Get exact specs:
  - **Shape system**: the shape library (how many shapes? what are they? "cookie", "clover", "pill", "burst"?), shape morphing, corner radius scale (what are the actual token values — extra-small 4dp through extra-large 28dp? extra-large-increased? extra-extra-large?). \`material-shapes\` library?
  - **Type scale**: what changed? "Emphasized" type styles? New tokens (display/headline/title/body/label × large/medium/small — plus emphasized variants)? Actual sizes/weights? Variable font axes?
  - **Color**: what changed from M3 baseline? New roles? Is \`ColorScheme.fromSeed\` still the mechanism? What are the new surface container roles and their exact tone values?
  - **Motion**: spring-based motion physics (irrelevant to us — we ban animation — but confirm what we're opting out of and whether opting out breaks anything).
  - **Components**: FAB menu, button groups, split buttons, loading indicators, toolbars. Any relevant?
- **The research claim** — Google says M3 Expressive is backed by ~46 research studies / 18,000+ participants, and found expressive designs let users spot key elements dramatically faster (a "4x" claim?) with the biggest gains for users 45+. VERIFY THE ACTUAL NUMBERS AND METHODOLOGY. Did Google publish the methodology, or is it marketing? Is there peer review? Be skeptical — this is being used to justify a design direction.
- **CRITICAL: what is M3 Expressive's status in FLUTTER (3.44, 2026)?** Flutter historically lags Material spec updates. Search Flutter's release notes, the "Material 3 Expressive" umbrella issue on GitHub, and pub.dev. Which parts are in \`flutter/material\`? Which need hand-rolling? Are there community packages? This determines whether it's a real option or an aspiration.
- Does M3 Expressive CONFLICT with this app's constraints? It's motion-heavy and playful — is "expressive" compatible with "calm and adult", or is it Google's version of the childishness we're fleeing? Argue it honestly. Which parts are separable (shape, type, color) from the parts we must reject (motion, playfulness)?
- Is using Material at all right here, or should this app build a bespoke design system on Flutter's raw primitives? Flutter makes bespoke cheap (it paints everything anyway). Argue both sides — note the app already deliberately departs from platform defaults.

Get exact token values and dates. Distinguish spec from Flutter reality.`,
  },
  {
    key: 'beauty-without-motion',
    prompt: `${BRIEF}

YOUR DIMENSION: How do you make something BEAUTIFUL when you cannot animate? This is the core creative problem of this project.

The app bans animation for two good reasons (distress + latency). Every contemporary "delightful design" playbook leans on motion. So: what are the OTHER levers, and how good can they get?

Research with WebSearch/WebFetch, and reason hard. Look to: editorial/print design, book design, typography, poster design, Swiss/International style and its modern descendants, brutalist and neo-brutalist web design, the "quiet luxury" aesthetic, album art, signage/wayfinding systems (Vignelli), museum graphics, and static-first digital products.

- **Composition**: grids, rhythm, optical alignment, tension, asymmetry, the difference between "aligned" and "composed". How does a 3x4 grid of rectangles become a composition rather than a spreadsheet? Concrete moves.
- **Typography as the primary expressive instrument**: type as image, scale contrast, weight contrast, optical sizing, variable fonts (which axes matter?), tracking/leading craft, the difference between "setting text" and "typography". What does GREAT type look like on a phone in 2026?
- **Material and surface without motion**: grain/noise texture, subtle gradients (mesh gradients? the 2026 kind), depth via layered surfaces vs shadows, edge treatment (hairlines, insets, bevels), translucency/blur (and its a11y cost), paper/ink metaphors. What's cheap in Flutter and what's expensive?
- **Color as craft**: how do sophisticated products use color? Restraint + one bold move? Duotone? Unexpected neutral temperature (warm greys vs cool greys — this matters enormously and is nearly free)? Tinted blacks? What separates a beautiful palette from a default one?
- **Detail and finish**: the small things that read as "designed by someone who cares" — optical corner radius (superellipse/squircle vs circular radius — Apple's continuous corners; is it available in Flutter? \`ContinuousRectangleBorder\`? Is it right?), consistent optical spacing, icon weight matching type weight, hairline treatment, focus states.
- **Empty states, negative space, restraint** as beauty.
- Find products that are genuinely beautiful and essentially STATIC. What do they do? (Consider: Things 3, Bear, Ivory, Oak, Kindle, Instapaper, Teenage Engineering's UIs, Panic's apps, Field Notes, Braun/Rams objects, Muji.) What's the transferable move?
- **Honest question**: is "beautiful without motion" actually harder, or does motion mostly paper over weak composition? Argue.

Return CONCRETE MOVES, not principles. "Use a warm near-black (#141210) not a blue-black (#141218) because it reads as ink rather than screen" is the register I want.`,
  },
  {
    key: 'color-system',
    prompt: `${BRIEF}

YOUR DIMENSION: The color system. Beautiful, calm, accessible, and NOT grey — all at once.

Research with WebSearch/WebFetch: color science for UI, OKLCH/OKLab and perceptual color (2025-2026 state), APCA vs WCAG 2 contrast (APCA is in WCAG 3 drafts — what's its actual status in 2026?), Material 3's HCT color space and tonal palettes, dark mode color craft, color and autistic sensory sensitivity, color psychology (be skeptical — most of it is junk; say so).

- **The contrast question, properly**: WCAG 2.x contrast ratio math and its known flaws (it's badly wrong for dark mode — verify and explain WHY). APCA/Lc — what is it, what's its status in 2026, should this project use it? What are the actual APCA Lc thresholds vs WCAG's 4.5:1? If they disagree for this app's palette, which wins? (Note: legal/store expectations may still be WCAG.)
- **HCT vs OKLCH vs HSL** — Material uses HCT (Google's own space). What's the practical difference and does it matter for hand-picking a palette? Which should a developer author in? Is there tooling in 2026?
- **The dark palette**: how do you make a dark theme that's beautiful rather than "black with grey text"? Specifics: tinted blacks (warm vs cool — what does each communicate?), the surface elevation ladder (M3 surfaceContainer tones — get the exact tone values), how much chroma to leave in "neutral" surfaces (M3 lets you set neutral chroma — what value reads as crafted vs muddy?), text luminance capping (the research says cap text at ~#E0E0E0 — is that right, and what's the equivalent principle in a tinted/warm palette?).
- **The light palette**: NOT pure white? Warm paper tones? What's the craft move? How do you keep light mode from looking clinical?
- **The high-contrast theme**: is it just black/white, or can it be beautiful too? What do the platforms actually do (iOS Increase Contrast, Android high contrast text)? What does Flutter expose (\`MediaQuery.highContrastOf\`)?
- **Autistic sensory sensitivity and color — what does the EVIDENCE actually say?** Be rigorous and skeptical: is there real research on autistic color preference/aversion, or is it folklore? (Look for actual studies — I've heard claims about yellow aversion and saturation sensitivity. Verify or debunk.) What about photosensitivity/migraine (specific spatial frequencies and colors are actual migraine triggers — find the real science)?
- **Category color-coding**: how many hues can you use before it's a rainbow? How do you make a categorical palette that's harmonious AND distinguishable AND colorblind-safe (8% of men)? What are the real colorblind-safe categorical palettes (Okabe-Ito? Paul Tol's?) and do they look good or scientific?
- Give an ACTUAL PROPOSED PALETTE with real hex values for dark/light/high-contrast, with contrast ratios computed, and a rationale for each choice. This is the deliverable.

Be quantitative. Real values, real ratios.`,
  },
  {
    key: 'typography-system',
    prompt: `${BRIEF}

YOUR DIMENSION: The typographic system — the primary expressive instrument in a motion-less, image-less app.

Research with WebSearch/WebFetch: type foundries and their 2025-2026 releases, variable fonts, OFL/open-licensed typefaces good enough to ship commercially, Atkinson Hyperlegible (including **Atkinson Hyperlegible Next / Mono — the 2025 releases; VERIFY what shipped and when**), Inter (and Inter Variable / Inter Display), and the legibility research literature.

- **The typeface decision.** Requirements: OFL or otherwise commercially shippable; excellent at large sizes AND at 200%+ scaling; distinguishable letterforms (Il1 / O0 / rn-m confusion matters for a user in a shutdown reading a phrase fast); adult and characterful, NOT institutional; supports the weights we need; ideally variable. Evaluate REAL candidates with real names and licenses: Atkinson Hyperlegible (+ Next?), Inter, Lexend (and the Lexend readability research — VERIFY it, I believe the claims are contested), Public Sans, Source Sans, IBM Plex, Work Sans, Manrope, Geist (Vercel's — license?), Instrument Sans, Bricolage Grotesque, Redaction, Newsreader, Literata, Fraunces, Recursive, Commissioner, and any strong 2025-2026 OFL release. For each: license, variable axes, character, and fitness here.
- **Is Atkinson Hyperlegible actually the right call, or is it the "accessible" choice that looks institutional?** Be honest and specific about how it LOOKS, not just its credentials. Is there a typeface that is both genuinely legible AND has character? Does pairing solve it (a characterful display face for the tile labels + a workhorse for UI)? Or is pairing a mistake at this scale?
- **The legibility evidence, rigorously.** What does research ACTUALLY support: x-height, counter size, letter differentiation, weight, tracking, line length, ALL CAPS vs sentence case? What's folklore? (Lexend's claims, OpenDyslexic's failure, the "sans-serif is more legible" claim — check them all.)
- **The type SCALE.** For an app whose entire content is 12 phrase labels + one text field: what's the scale? How much contrast between levels? Is a conventional 6-level type scale even needed for a 4-element app? What's the M3 Expressive "emphasized" scale and is it usable in Flutter?
- **Variable font axes worth using**: weight, optical size, grade (grade is interesting for dark mode — it adjusts weight WITHOUT changing metrics, so text doesn't reflow; is that the fix for dark-mode bloom?), width. What does Flutter support for variable fonts in 2026 (\`FontVariation\`)? VERIFY the API.
- **Setting the tile label**: one word? a phrase? how does it wrap? centered or left? optical centering? how do you handle a 2-word tile next to a 9-word tile in a fixed grid without it looking broken? THIS IS THE CORE TYPOGRAPHIC PROBLEM OF THE APP — go deep on it.
- **The show-text screen**: a phrase at maximum size, read at arm's length in daylight by a stranger. What's the typographic treatment? This is a poster, not UI. How big, what weight, what measure, what alignment?
- Font loading/bundling in Flutter: size cost, subsetting, \`google_fonts\` package (does it fetch at runtime? THAT WOULD BE A NETWORK CALL AND IS BANNED — verify how to bundle instead), tree-shaking.

Give a decision with a named typeface, real sizes, real weights, and the reasoning. This is the deliverable.`,
  },
  {
    key: 'tile-grid-design',
    prompt: `${BRIEF}

YOUR DIMENSION: The tile and the grid — the entire product surface. 12 rectangles. Make them beautiful.

This is the crux. The whole app IS a grid of phrase tiles. Everything else is secondary. Reason hard and research widely.

- **What IS a tile here?** It holds a label (what it shows) that differs from its vocalization (what it speaks) — e.g. shows "Overwhelmed", speaks "I need to leave, I'm not able to talk right now." Does the design express that relationship? Should the tile hint at its hidden sentence, or is that clutter? THIS IS A GENUINELY INTERESTING DESIGN PROBLEM — go at it.
- **Tile anatomy**: shape, corner radius (what radius reads 2026 vs 2015? is the superellipse/squircle worth it — and is \`ContinuousRectangleBorder\` in Flutter actually a squircle or a poor approximation? VERIFY), fill vs outline vs both, border/hairline treatment, internal padding, label position (centered? bottom-left like a book?), optical balance, how a symbol would later coexist with the label.
- **Fill strategy**: solid color tiles? tinted surfaces? outlined? What does each communicate? Solid colored tiles are the kid-AAC signature — is that fair, or is the childishness in the SATURATION and the rainbow, not the fill? Can a filled tile be adult? (Argue with examples.)
- **Differentiating 12 tiles**: how does a user find "I need to leave" instantly? Color? Position alone? Type weight? Size variation (can tiles be different sizes — a bento/mosaic grid — while positions stay FIXED? That's allowed by the constraints and might be the single best move: a spatial hierarchy where the most urgent phrase is physically bigger)? Investigate the bento grid idea seriously.
- **The grid itself**: gaps vs dividers vs bleeding to the edge, margins, does the grid touch the screen edges (edge-to-edge is a 2026 signature — but tiles at the very edge conflict with thumb-reach findings; resolve it), safe areas, gesture insets.
- **State**: pressed/active feedback WITHOUT animation — what does a tile look like the instant it's tapped? (This matters enormously: no animation means the feedback must be instantaneous and static. Is that a limitation or an opportunity?) Focus state for Switch Control/keyboard. Disabled? Hidden slots (the schema allows NULL slots — what does an EMPTY slot look like? A hole? Nothing? This is an aesthetic AND functional question — an empty slot must not look broken, and must not invite a tap).
- **The type-to-speak field** sharing the surface with the grid: how do you compose a text input and a tile grid on one screen without it looking like two apps stapled together?
- **STOP and the repair tile**: always visible, larger than a tile, must read as urgent without being alarming. How? (Red = alarm = the wrong register for a calm app? But STOP must be findable instantly. Resolve this tension.)
- Research real references: what do beautiful grid interfaces look like? (Soundboards, drum machines/MPC pads, Teenage Engineering, Ableton Push, keyboard/keycap design, Launchpad, elevator/keypad design, tile-based dashboards, bento grids, Apple's Shortcuts, iOS Home Screen widgets.) **Drum machines and MPC pads are the closest functional analogue to this app that anyone has ever polished** — a grid of pads you hit fast under pressure, designed to be beautiful and instantly locatable. Go deep on what they do.

Return concrete specs and real reference products with what to steal.`,
  },
  {
    key: 'dated-vs-current-audit',
    prompt: `${BRIEF}

YOUR DIMENSION: The "not ten years ago" audit. What EXACTLY makes an app look dated, and what does the AAC category look like today?

- **Go look at the actual competitors** and describe their visual design honestly and specifically: Proloquo2Go, Proloquo (the 2021 one — it won an Apple Design/App Store award for Cultural Impact, so it's presumably the best-looking in the category — WHAT DOES IT ACTUALLY LOOK LIKE? Go find screenshots and describe its design language in detail), Proloquo4Text, Speech Assistant AAC (the direct incumbent — describe its design; it's a decade-old indie app), TouchChat, LAMP, Avaz, CoughDrop, Spoken (a newer, VC-ish entrant — what does it look like?), Cboard, AsTeRICS Grid, Emergency Chat. Use WebSearch/WebFetch to find screenshots, App Store listings, press, design case studies, Behance/Dribbble.
- For each: what specifically dates it? What does it get right? **What would a 2026 designer do differently?**
- **Is there ANY beautiful AAC app?** If Proloquo won an App Store Award for Cultural Impact, that's the bar. Find out what its design actually does. Be specific.
- **The broader "assistive tech looks like medical equipment" problem**: research the design discourse on this. Eone watches, Aira, Be My Eyes, OrCam, hearing aids as fashion (Eargo, Apple AirPods Pro as hearing aids — a MASSIVE example of destigmatization through design), prosthetics (Open Bionics' Hero Arm — deliberately beautiful, superhero-branded), Rebecca Cokley/disability design discourse, "design for disability" (Graham Pullin's book "Design Meets Disability" — its central thesis is about eyewear: glasses went from medical appliance to fashion. THAT IS EXACTLY THIS PRODUCT'S THESIS. Go deep on Pullin). What are the transferable lessons?
- **The checkable "looks old" list**: give a concrete audit checklist a developer can run against their own screens. Be specific: what corner radius is dated? what shadow? what type weight? what color treatment? what layout? what iconography?
- **What does 2026-current look like in adjacent categories that are doing it well** — note-taking, meditation/calm apps (Endel, Oak, Calm — but beware, these are often TOO soft/spa-like for this audience; is "calm app" aesthetic actually infantilizing in a different direction? Interrogate that), journaling, health, indie iOS apps that win design awards. What's transferable and what's a trap?

Be specific and honest. Screenshots described in words. Name what to steal and what to avoid.`,
  },
  {
    key: 'distress-ux-aesthetics',
    prompt: `${BRIEF}

YOUR DIMENSION: The hard tension — can "creative and beautiful" coexist with "usable during a shutdown"? Interrogate this honestly; do not resolve it cheaply.

- **The case AGAINST expressive design here**: cognitive load, visual complexity, decision paralysis, sensory overload. Does beauty cost legibility? Does personality cost speed? What does the evidence on visual complexity and cognitive load actually say (Google's "visual complexity and prototypicality" research on aesthetic judgment — find it; the "low complexity + high prototypicality = perceived beauty AND usability" finding is directly relevant and may resolve the whole tension). Is there a real trade-off, or is that a false binary designers use to excuse ugliness?
- **The case FOR**: Material 3 Expressive's claim is that expressive design was FASTER to parse (verify). The aesthetic-usability effect (Kurosu & Kashimura 1995; Tractinsky's replication — get the real finding and its limits; it's often overstated). Does beauty create trust? Does an app you're proud to be seen using get used MORE — which for an abandonment-prone product is THE metric? (Recall: 11/12 use AAC only where they feel safe; 4/12 avoid situations to dodge reactions to their device. If the device looked *desirable* rather than *medical*, does that change? THAT'S THE PULLIN "glasses" ARGUMENT and it may be this product's most important design insight.)
- **Resolve it**: is there a design strategy that's beautiful at rest AND ruthlessly simple in use? Ideas to interrogate: beauty in the *material* (color, type, surface craft) but simplicity in the *structure*; "quiet" beauty vs "loud" beauty; progressive disclosure (rich in edit mode, stark in speak mode — does that break the fixed-layout rule? does the app get SIMPLER as the user gets more distressed, and can that be manual rather than automatic? Note: 6/12 said auto-personalization should NEVER activate, so automatic mode-switching is out — but a MANUAL low-stimulus mode is already in the spec. **Is the low-stimulus mode the release valve that lets the default be beautiful?** Go at this hard, it may be the key architectural answer).
- **Trauma-informed design**: get the actual principles from real sources, not blog summaries. What does it mandate and what does it merely suggest? Does it forbid beauty or forbid surprise?
- **Calm technology** (Amber Case's principles) — what does it actually say? "Question every addition"? Is calm technology compatible with expressive design or opposed to it?
- What do actual autistic designers say about design for autistic people? Find first-person sources, not clinical ones. Is the "muted, calm, low-stimulus" prescription something autistic people ASKED for, or something designed AT them? THIS IS A REAL QUESTION AND THE ANSWER MIGHT BE UNCOMFORTABLE — the audience is not a monolith, and "sensory-friendly = beige" may itself be a stereotype. Investigate seriously.
- Is there evidence about beauty/aesthetics and autistic users specifically? Or is the field just assuming?

Be rigorous. This dimension decides whether the founder's brief is achievable or a contradiction. Come back with an honest verdict and a strategy.`,
  },
  {
    key: 'flutter-design-capability',
    prompt: `${BRIEF}

YOUR DIMENSION: What can Flutter actually RENDER in 2026, and what does beauty cost in code and latency?

Research with WebSearch/WebFetch: api.flutter.dev, docs.flutter.dev, Flutter release notes 3.16→3.44, Impeller docs, pub.dev.

Every design move must be checked against: can Flutter do it, what does it cost, and does it break the a11y/latency constraints?

- **Theming**: \`ThemeData\`, \`ColorScheme.fromSeed\` (and \`dynamicSchemeVariant\` — what variants exist? tonalSpot/vibrant/expressive/fidelity/content/neutral/monochrome/rainbow/fruitSalad? VERIFY the enum and what each does — "expressive" and "vibrant" sound directly relevant), \`ThemeExtension<T>\` for custom design tokens (the right way to ship a bespoke token system — show real code), \`MaterialStateProperty\`/\`WidgetStateProperty\` (the rename happened — VERIFY which is current in 3.44).
- **Is Material 3 Expressive in Flutter yet?** Which parts? Check the umbrella issue and release notes. What must be hand-rolled?
- **Shape**: \`ShapeBorder\`, \`RoundedRectangleBorder\`, \`ContinuousRectangleBorder\` (is it a real squircle? It's known to be a poor approximation of Apple's — VERIFY and say what to do instead), \`StarBorder\`, custom \`ShapeBorder\` subclasses, \`ClipPath\`. Can Flutter draw a proper superellipse? Is there a package? Does it cost anything per frame in a static UI (probably not — confirm)?
- **Gradients**: \`LinearGradient\`/\`RadialGradient\`/\`SweepGradient\`. Mesh gradients — possible? (\`mesh_gradient\` package? fragment shaders?) Cost?
- **Fragment shaders**: \`FragmentProgram\`, GLSL→\`.frag\`, the \`shaders:\` pubspec section. What's the 2026 state with Impeller? What can you do (grain, noise, subtle texture, gradients)? What does it cost at startup (shader compilation — Impeller precompiles; does that solve the old shader-jank problem)? **Is a static grain/noise texture via shader worth it, or should it be a bundled PNG?** (For a static UI, a PNG is probably right — argue it.)
- **Blur/translucency**: \`BackdropFilter\`/\`ImageFilter.blur\` — the real performance cost (it's historically the most expensive thing in Flutter), and the a11y cost (legibility over blur; the iOS Liquid Glass backlash). Verdict for this app?
- **Text rendering**: how good is Flutter's text? Variable font support (\`FontVariation\` — VERIFY the API), \`fontFeatures\` (OpenType features — ss01, tnum, etc.), optical sizing, letter spacing precision, text shaping quality vs native. Any known text-rendering weaknesses? \`TextHeightBehavior\`/leading trim (is there leading-trim support in 2026? It's the difference between amateur and professional vertical rhythm — VERIFY).
- **Custom painting**: \`CustomPainter\` — when is it the right tool vs composing widgets?
- **Images**: bundling, resolution-aware assets, the icon-font tree-shaking thing.
- **What's expensive and would blow the latency budget?** Rank the costly things. Note the app is STATIC — many perf concerns evaporate. Is that liberating? Say so concretely: a static UI paints once, so per-frame cost is nearly irrelevant, which means expensive-per-frame effects may actually be FREE here. VERIFY that reasoning — is it true? (What about scrolling? The grid doesn't scroll. What about the raster cache?)
- **Dark/light/high-contrast theme switching** in Flutter: \`ThemeMode\`, \`MediaQuery.platformBrightnessOf\`, \`highContrastOf\`, \`boldTextOf\`, \`disableAnimationsOf\`, \`accessibleNavigationOf\`, \`invertColorsOf\`, \`onOffSwitchLabelsOf\`? Get the real list of \`AccessibilityFeatures\` and which have MediaQuery accessors.

Be concrete. Real APIs, real costs, verified names. Flag anything you couldn't verify.`,
  },
  {
    key: 'brand-identity-voice',
    prompt: `${BRIEF}

YOUR DIMENSION: Identity — name, icon, tone of voice, and the App Store presence. The parts of "design" that aren't the UI.

- **The app icon.** It sits on a home screen among the user's other apps, and it may need to be findable INSTANTLY during a shutdown. It also announces what the app IS to anyone who glances at the phone — which matters, because 11/12 use AAC only where they feel safe and 4/12 avoid situations to dodge reactions to their device. **So there's a real tension: findable vs discreet.** Research: what makes an icon findable at 60x60? (Shape? Color? Contrast? Not detail.) What do beautiful 2026 app icons look like vs 2015 ones (gradients? glyphs? depth? iOS 26 introduced icon modes — clear/tinted/dark; VERIFY what Apple shipped and what it means for icon design; Android adaptive icons + themed icons)? Should this app's icon be legible-as-AAC or deliberately neutral? Argue both. Can it be beautiful AND discreet AND findable?
- **The name.** Not chosen yet. What are the naming conventions in this category (descriptive: "Speech Assistant AAC", "Proloquo2Go" — Latin, meaning "speak out loud"; "TouchChat"; "Spoken"; "Emergency Chat")? For a product whose thesis is dignity, what naming register works? Should "AAC" be in the name (findability/ASO) or not (dignity/discretion)? Note the ASO tension: users search "AAC", "text to speech", "nonverbal", "selective mutism". Give real, specific name candidates with reasoning — not just criteria. Check obvious collisions.
- **Tone of voice.** Every string in the app. The research says: second-person adult copy, no exclamation marks, no encouragement, no "Great job!", no student/learner framing. But that's a list of DON'Ts — what's the positive register? Warm? Dry? Neutral? Matter-of-fact? Find examples of products with a tone worth stealing. Write actual example strings for: first launch, empty tile, edit mode, the voice picker, an error ("no voice available"), the export screen, the privacy explanation. **The error strings matter most** — this app's errors happen at the worst moment of someone's day. What does a good error message sound like here?
- **The starter phrase set as a design artifact**: the research says starter phrases need VISIBLE PROVENANCE — who wrote them and why — because pre-filling someone's voice is presumptuous, and provenance converts presumption into a gift. How do you DESIGN that? What does it look like on screen? What does the copy say? This is a design problem, not just a content problem.
- **App Store presence**: screenshots, the listing. What do beautiful 2026 app store screenshots look like? What does this app's first screenshot need to communicate in 2 seconds to an autistic adult who has been burned by kiddie AAC apps? (This may be the single highest-leverage design surface in the whole project — it's what decides whether they install at all.)
- **The privacy story as a design surface**: "no network permission" is verifiable pre-install on the Play listing. How do you SHOW that? Nutrition labels, the listing, an in-app page. Can it be beautiful and credible rather than legalese?

Give real, specific, opinionated output: actual name candidates, actual strings, actual icon directions.`,
  },
  {
    key: 'design-tokens-implementation',
    prompt: `${BRIEF}

YOUR DIMENSION: How a design system is actually built and shipped in a Flutter codebase in 2026 — the engineering of design.

Research with WebSearch/WebFetch: design tokens (the W3C Design Tokens Community Group format — what's its 2026 status? did it reach spec?), Style Dictionary, Material Theme Builder, Figma→Flutter pipelines, ThemeExtension patterns, and real open-source Flutter design systems worth reading.

- **Token architecture**: the 3-tier model (primitive/reference → semantic/alias → component). Is that right for a one-screen app, or is it enterprise ceremony? Be honest — but note this app has 3 themes × several text scales, which is exactly the situation tokens exist for. Resolve.
- **How to express tokens in Flutter**: \`ThemeExtension<T>\` (show real, complete code including \`copyWith\` and \`lerp\` — and note \`lerp\` matters not at all here since we ban animation; does that simplify it? Can lerp just return \`this\`?), vs plain static const classes, vs \`ColorScheme\` + \`TextTheme\` alone. Which for this app? Argue.
- Is \`ColorScheme.fromSeed\` sufficient, or does a bespoke palette need hand-authored \`ColorScheme(...)\`? What are the trade-offs (fromSeed gives you M3's tonal correctness and a11y-safe pairings for free, but you lose exact control — and a *designed* palette is the point here). Can you seed and then override specific roles? Show how.
- **Material Theme Builder** and the HCT tooling — is it usable in 2026, and does it export Flutter code? What's the actual workflow from "I picked some colors" to "ThemeData"?
- **Figma**: is it worth a solo dev designing in Figma first, or designing in Flutter directly (hot reload as the design tool)? Argue honestly — this is a real decision for a solo dev with a 2-week MVP. What's lost by skipping Figma? (Note: Flutter's hot reload makes it plausibly the best design tool for its own apps. But it's terrible for exploring divergent directions.)
- **Testing a design system**: golden tests per theme? (Note prior research is deciding this separately — coordinate: a fixed grid × 3 themes × N text scales is either the ideal golden case or a maintenance trap.) Can you test that all token pairings meet contrast? **A test that asserts every semantic color pairing passes WCAG contrast, for all 3 themes, is a real and cheap test — design it.** That's a design system verified by CI, which is the kind of move this project's constraints reward.
- **Structuring the theme code**: where do tokens live, how do 3 themes share structure, how does high-contrast relate to dark/light (a third theme, or a modifier on each? — that's a real architecture question: 2 themes × contrast levels, or 3 discrete themes? Material has "contrast levels" now — VERIFY \`ColorScheme.fromSeed\`'s \`contrastLevel\` param and whether it's in Flutter 3.44).
- Dynamic color / Material You (Android wallpaper-based theming, \`dynamic_color\` package): should this app support it? **Strong argument against**: the palette is designed, and a user's wallpaper could produce a garish or low-contrast result in a safety-relevant app. But it's also a beloved Android feature and reads as "current". Argue and decide.
- Naming conventions for tokens that don't rot.

Give real, complete, compiling code for the token layer. This is the bridge from design to codebase.`,
  },
]

phase('Research')
log(`Researching ${DIMENSIONS.length} design dimensions. Core question: can this be genuinely beautiful without motion, without saturation, and without breaking distress-use?`)

const researched = await pipeline(
  DIMENSIONS,
  (d) => agent(d.prompt, { label: `research:${d.key}`, phase: 'Research', schema: FINDINGS_SCHEMA, effort: 'high' }),
  (res, d) => {
    if (!res) return null
    const lb = (res.findings || []).filter((f) => f.loadBearing)
    if (!lb.length) return { dimension: d.key, research: res, verdicts: [] }
    return parallel(
      lb.slice(0, 7).map((f) => () =>
        agent(
          `You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "${d.key}" made this claim, and a design decision depends on it.

CLAIM: ${f.claim}
DETAIL: ${f.detail}
CLAIMED SOURCES: ${(f.sources || []).join(', ') || '(none)'}
CONFIDENCE: ${f.confidence}

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: m3.material.io, developer.apple.com, api.flutter.dev, docs.flutter.dev, the actual type foundry, the actual paper.

Hunt for these failure modes, in order of likelihood:
1. **Marketing repeated as research.** Google's M3 Expressive claims (46 studies, 18,000 participants, "4x faster") and Lexend's readability claims are the specific hazards. Did anyone publish a methodology? Is it peer-reviewed, or is it a blog post? If a number has no methodology behind it, SAY SO — a design direction is being justified with it.
2. **Design folklore presented as evidence.** "Autistic people prefer muted colors", "sans-serif is more legible", "the aesthetic-usability effect", color psychology. Find the actual study, check the sample and whether it replicated, and check whether the popular claim matches what the paper found.
3. **Version/API rot.** Flutter lags the Material spec — a spec feature is NOT a Flutter feature. If the claim says Flutter can do something, VERIFY on api.flutter.dev or the release notes. Check whether a named API exists with that exact name.
4. **Invented specifics** — hex values, token names, type sizes, shape counts, font axes, license terms. If it's specific, verify it's real.
5. **License claims** about typefaces or assets. Verify against the actual foundry/repo.

Default to refuted=true if you cannot substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + correction if directionally right but wrong in the specifics. UNVERIFIABLE if nothing settles it — say so plainly rather than guessing.`,
          { label: `verify:${d.key}`, phase: 'Verify', schema: VERDICT_SCHEMA, effort: 'high' }
        ).then((v) => ({ claim: f.claim, ...(v || { refuted: true, verdict: 'UNVERIFIABLE', evidence: 'verifier failed' }) }))
      )
    ).then((verdicts) => ({ dimension: d.key, research: res, verdicts: verdicts.filter(Boolean) }))
  }
)

const ok = researched.filter(Boolean)
log(`${ok.length}/${DIMENSIONS.length} dimensions researched and fact-checked.`)

const digest = ok.map((r) => {
  const corr = r.verdicts.filter((v) => v.verdict !== 'CONFIRMED')
    .map((v) => `    - [${v.verdict}] "${v.claim}"\n      CORRECTION: ${v.correction || v.evidence}`).join('\n')
  const conf = r.verdicts.filter((v) => v.verdict === 'CONFIRMED')
    .map((v) => `    - [CONFIRMED] ${v.claim}`).join('\n')
  const moves = (r.research.designMoves || [])
    .map((m) => `  - MOVE: ${m.move}\n    WHY: ${m.why}\n    RISK: ${m.risk || '(none noted)'}`).join('\n')
  const refs = (r.research.references || [])
    .map((x) => `  - ${x.name}${x.url ? ` (${x.url})` : ''} — STEAL: ${x.steal}`).join('\n')
  return `
### DIMENSION: ${r.dimension}
SUMMARY: ${r.research.summary}

FINDINGS:
${(r.research.findings || []).map((f) => `  - (${f.confidence}${f.loadBearing ? ', LOAD-BEARING' : ''}) ${f.claim}\n    ${f.detail}\n    sources: ${(f.sources || []).join(' | ')}`).join('\n')}

DESIGN MOVES:
${moves || '  (none)'}

REFERENCES:
${refs || '  (none)'}

FACT-CHECK:
${conf || '    (none confirmed)'}
${corr || '    (no corrections)'}
`
}).join('\n---\n')

phase('Critique')
const critiques = await parallel([
  () => agent(`${BRIEF}

Below is the full design research corpus (11 dimensions + adversarial fact-checks).

${digest}

You are a working ART DIRECTOR with a portfolio of beautiful, award-winning digital products. You have no patience for research that describes beauty instead of specifying it.

Write the honest critique:
- **Is there an actual DESIGN here, or just a list of constraints and hedges?** Be brutal. Research corpora produce "muted but not too muted, warm but not soft" mush. Name every place that happened.
- **Propose the actual design direction.** Not options — a direction, committed to, with specifics: the palette (hex), the typeface (named), the tile (radius, fill, label treatment), the grid (bento or uniform?), the one bold move that makes it memorable. If the corpus won't commit, YOU commit.
- What is the ONE thing that would make someone screenshot this app and post it? Every beautiful product has one. What's this app's?
- Where is the corpus being cowardly — hiding behind accessibility or "calm" to avoid making a choice?
- What's the reference product this should feel like a sibling to?

Use WebSearch/WebFetch if you need to check a reference. Be specific and opinionated. Prose.`, { label: 'art-director', phase: 'Critique', effort: 'high' }),

  () => agent(`${BRIEF}

Below is the full design research corpus.

${digest}

You are an ACCESSIBILITY-SPECIALIST DESIGNER who has shipped assistive software and who is also a good designer — you reject the premise that accessible means ugly, AND you reject beauty that costs users.

Critique honestly:
- Which proposed design moves would ACTIVELY HURT a user in a shutdown, or a Switch Control user, or someone at 200% text scale, or someone with low vision? Name each and say why. Be specific — "grain texture reduces effective contrast" not "be careful with texture".
- Which "accessibility" constraints in this corpus are actually FOLKLORE that a designer could safely ignore? (Be brave here — the corpus may be over-constraining out of caution. Is the 76dp floor real? Is "muted" real? Is the animation ban over-broad? Is dark-by-default right?)
- What does the corpus MISS about real accessible design? (Focus indicators? Touch vs switch vs screen reader having different visual needs? Reflow at 200%? Contrast of non-text elements — tile borders, focus rings? The fact that a 3x4 grid's screen-reader traversal order is a DESIGN decision?)
- Contrast math: check any contrast claims in the corpus. Do the proposed palettes actually pass? Verify with real computation.
- What's the a11y test that should gate every design decision here?

Use WebSearch/WebFetch to verify. Be specific.`, { label: 'a11y-designer', phase: 'Critique', effort: 'high' }),

  () => agent(`${BRIEF}

Below is the full design research corpus.

${digest}

You are reviewing this as an **autistic adult who uses AAC part-time** — the actual user. You have tried the kiddie apps and deleted them. You have opinions about being designed at.

Read the corpus and react honestly:
- Where does this smell like non-autistic people deciding what autistic people need? Name it.
- The corpus assumes muted/calm/low-stimulus. **Is that what you'd want, or is it a stereotype?** Autistic people are not a monolith and "sensory-friendly = beige" may be its own condescension. Interrogate it — and note some autistic people love intense color and pattern.
- Would you be seen using this in a shop? What would make you proud to hold it up vs. hide it? (Recall: 11/12 use AAC only in environments they perceive as safe; 4/12 avoid situations entirely to dodge reactions.) **What does the design do about THAT?**
- The Graham Pullin "glasses vs medical appliance" thesis is the whole product bet. Does this design cash it? What would?
- What in this corpus is still infantilizing in a way the researchers didn't notice?
- What would make you trust this app in the first 5 seconds?
- Anything the corpus gets RIGHT that you'd defend against the art director's push for boldness?

Use WebSearch/WebFetch to ground your reactions in real first-person autistic writing about AAC and design where you can — quote real people, don't roleplay. Be direct.`, { label: 'user-lens', phase: 'Critique', effort: 'high' }),
])

const critiqueText = critiques.filter(Boolean).map((c, i) => `\n### CRITIQUE ${i + 1}\n${c}`).join('\n')

const AUTHOR_PREAMBLE = `${BRIEF}

You are authoring a design document for this project's repo, from the research corpus and critiques below.

=== RESEARCH CORPUS (11 dimensions, adversarially fact-checked) ===
${digest}

=== CRITIQUES (art director, accessibility designer, autistic-user lens) ===
${critiqueText}

=== AUTHORING RULES — strict ===
1. **Output raw GitHub-flavored Markdown. No fence around the whole document, no preamble. Your entire response IS the file, starting with the H1.**
2. **COMMIT.** The founder asked for creative and beautiful. A document full of "consider" and "you might" is a failure. Specify: real hex values, a named typeface, real dp values, real weights. Where the research offered options, PICK ONE and say why. The art director's critique exists to push you off the fence — respect it.
3. **Never ship an unverified API, spec value, or license claim.** Use fact-checker CORRECTIONS over the original claims. Where something was UNVERIFIABLE or is a Material spec feature that Flutter may not have implemented, mark it inline \`<!-- VERIFY -->\`. Flutter lags the Material spec — never assume a spec feature exists in Flutter 3.44.
4. **Be honest about evidence.** Google's M3 Expressive research claims and Lexend's readability claims are marketing until proven otherwise — if the fact-checkers couldn't verify a number, don't launder it into a justification. Say "we're choosing this on design judgment" instead. That's a stronger position than a fake citation.
5. **Every rule needs a WHY tied to THIS app** — a user mid-shutdown, one-handed, in a shop, who deleted the last app because it had a cartoon dog on it.
6. Code must compile against Flutter 3.44 / Dart 3.x.
7. Don't pad. Don't restate the brief.
`

phase('Author')
const [system, rationale] = await parallel([
  () => agent(`${AUTHOR_PREAMBLE}

=== YOUR DOCUMENT: docs/DESIGN_SYSTEM.md ===

The specification. A developer builds from this without asking a single question. Concrete throughout — this doc is values, not adjectives.

Cover:
- **The direction, in one paragraph.** What this app looks like and feels like. Committed. Name the reference products it's a sibling to.
- **Color.** The complete palette: dark, light, high-contrast. Real hex values in a table with computed contrast ratios against their pairings. The neutral temperature decision (warm vs cool near-black — decide and justify; it's nearly free and it's the difference between "ink" and "screen"). The accent strategy. The category-hue palette (colorblind-safe, harmonious, and NOT a rainbow — give the actual hues). How it's expressed in Flutter (\`ColorScheme.fromSeed\` + role overrides, or hand-authored — decide and show the code).
- **Typography.** The named typeface + license + why (and honestly whether Atkinson Hyperlegible is the right call or the institutional-safe one). The complete type scale with real sizes/weights/tracking/leading. The tile-label treatment. The show-mode poster treatment. Variable-font axes used. How it's bundled (NOT google_fonts at runtime — that's a network call and it's banned).
- **The tile.** Complete anatomy: dimensions, radius (with the squircle decision resolved against what Flutter can actually render), fill, border, padding, label position and wrapping behavior, how a 2-word label and a 9-word label coexist in a fixed grid. Pressed state without animation. Focus state for Switch Control. The empty-slot treatment (it must not look broken and must not invite a tap).
- **The grid.** Dimensions, gaps, margins, edge treatment, the bento/size-hierarchy decision (resolved), the lower-center priority zone, and how the type-to-speak field composes with it on one surface.
- **STOP and the repair tile.** The urgency-without-alarm problem, resolved with real values.
- **The show screen.** It's a poster, not UI. Full spec.
- **Space, shape, and depth**: the spacing scale, the shape scale, and how depth is expressed without motion (and what's banned — blur? shadow? grain?).
- **Iconography**: if any. Weight matching, sizing, semanticLabel as a hard requirement.
- **The design tokens**, as real Flutter code: the \`ThemeExtension\` (note \`lerp\` can be trivial since animation is banned — say so), or the argued alternative. Complete and compiling.
- **The contrast test** that gates the system in CI — every semantic pairing, every theme, asserted. Real test code. A design system verified by CI is the move this project's constraints reward.
- **The "looks dated" audit checklist** — concrete and checkable, to run against every screen.
- **The banned list** — visual, permanent, and checkable.

Target 400-600 lines. Specification register: values, tables, code.`, { label: 'author:DESIGN_SYSTEM', phase: 'Author', effort: 'max' }),

  () => agent(`${AUTHOR_PREAMBLE}

=== YOUR DOCUMENT: docs/DESIGN_RATIONALE.md ===

The argument. Why the system is what it is, what was rejected, and what's still unresolved. This is the doc that stops the developer relitigating a decision at 2am, and the one that lets a stranger who inherits this repo understand the reasoning rather than just the values.

Cover:
- **The central tension, resolved**: creative/beautiful vs. usable-in-a-shutdown. State the honest verdict from the research. Is the founder's brief achievable? What's the strategy that gets both? (The manual low-stimulus mode as the release valve that lets the DEFAULT be beautiful is a candidate — evaluate it properly. So is "beauty in the material, simplicity in the structure".)
- **The Pullin argument** — "Design Meets Disability", glasses vs medical appliance, and the AirPods-as-hearing-aids precedent. This is the product's core design bet: that a device someone is PROUD to hold up gets used, and 11/12 only use AAC where they feel safe. Make the argument properly and honestly, including where it might not hold.
- **What the evidence actually supports vs. what is design judgment.** Be scrupulous. The muted-calm prescription, the M3 Expressive research claims, the aesthetic-usability effect, Lexend, autistic color preference — go through them and label each: evidenced, contested, or folklore. **Where we chose on taste, say so plainly.** A design decision made on judgment and labeled as such is honest; one dressed in a fake citation is not.
- **The uncomfortable question from the user-lens critique**: is "sensory-friendly = muted" a stereotype imposed on autistic people rather than requested by them? Give it a full hearing. What did the corpus find? What did it assume? How does the design hedge against being wrong?
- **Rejected directions and why** — each with a real reason: Liquid Glass, full M3 Expressive, dark-only, the calm/spa aesthetic, neo-brutalism, dynamic color/Material You, symbols in the MVP, motion, saturated color-coded tiles, whatever else the corpus killed.
- **The dated-design audit**: what specifically would make this look ten years old, and the mechanism by which each is avoided.
- **Open questions** — what's genuinely unresolved, and how to settle it. Include what to test with real users, and what to ask them. Be honest about what the research could NOT answer, and about anything the fact-checkers could not verify.
- **The one thing that makes it memorable** — the art director's question. Answer it, or say honestly that it's unresolved and what would resolve it.

Target 250-400 lines. Argument register: prose, honest, no hedging.`, { label: 'author:DESIGN_RATIONALE', phase: 'Author', effort: 'max' }),
])

return {
  dimensions: ok.length,
  docs: {
    'docs/DESIGN_SYSTEM.md': system,
    'docs/DESIGN_RATIONALE.md': rationale,
  },
}
