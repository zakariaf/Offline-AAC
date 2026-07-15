# beauty-without-motion

> Phase: **research** · Agent `a9fbe71ddb335c93f` · Run `wf_f237e8a6-694`

## Result

## Summary

Motion is not a source of beauty — it is a source of *temporal hierarchy*. It tells you what matters by ordering things in time. Static design must encode the same hierarchy spatially, all at once. That is harder to design and strictly better for this user: a person in shutdown cannot re-derive hierarchy from a sequence they missed, and static hierarchy is re-readable at any instant. So the animation ban is not a tax on beauty; it forces the composition to actually be good, because nothing will paper over it. The four levers that remain are more than enough: (1) COMPOSITION — a 3x4 grid becomes a composition rather than a spreadsheet the moment its row heights stop being uniform and its labels stop being centered; non-uniform row rhythm mapped to the lower-center value arc is the single highest-leverage move in the whole app, because it serves beauty and reachability with one decision. (2) TYPOGRAPHY — the Feb 2025 release of Atkinson Hyperlegible Next changed the math: the old font had 2 weights, which made weight-contrast typography impossible; Next has 7 weights plus a variable version, so type can finally carry the identity. Show mode is a poster, not a label, and is where the app gets to be genuinely beautiful for free. (3) COLOR — warm the INK, not the paper; warm backgrounds read as brown on OLED, but a warm off-white text (#E8E4DC) on a near-neutral near-black delivers the "ink on paper" read while pulling text luminance down, which prior research already established as the dominant halation lever. Restraint plus exactly one bold move, used once per screen. (4) FINISH — `RoundedSuperellipseBorder` landed in Flutter 3.32 stable (May 2025) with a real GPU implementation on Impeller; hairlines at 1 physical pixel rather than 1dp; zero shadows; zero blur. The things to refuse: BackdropFilter (costs raster milliseconds in a product whose premise is instant speech, and destroys contrast), drop shadows (the 2014 tell), and — with genuine regret — anything but the most restrained grain, because visual noise aimed at a sensory-sensitivity audience is a hazard, not a texture.

### Flutter shipped a true Apple-grade squircle in 3.32 stable (May 20, 2025): RoundedSuperellipseBorder, ClipRSuperellipse, Canvas.drawRSuperellipse, with a GPU implementation in Impeller. The old workarounds are obsolete.

*Confidence: high, **LOAD-BEARING***

Prior to 3.32 the options were all compromised: ContinuousRectangleBorder needs its radius multiplied by 2.3529 to approximate iOS (derived from 24dp ≈ iOS 10.2dp radius, 24/10.2 = 2.3529) and still degenerates into a 'TIE-fighter' shape at higher radii — and the multiplier makes the degeneration happen EARLIER. figma_squircle matches iOS at smoothing 0.6 but has documented jank/perf complaints. smooth_corner has no perf feedback because nobody uses it. RydMike's squircle_study concludes RoundedSuperellipseBorder is the only shape that matches iOS and handles all edge cases. Caveat that does NOT apply here: RSuperellipse falls back to RRect on Web because it must be drawn as Bezier paths there; flutter/flutter PR #167784 reverted several Cupertino widgets to RRect for Web cost. This project is Android-first with Impeller, so the fast path applies. Second caveat: Impeller is default only on Android API 29+; API 28 and below use legacy Skia (since 3.29.3).

- https://github.com/rydmike/squircle_study/blob/master/README.md

- https://api.flutter.dev/flutter/painting/RoundedSuperellipseBorder-class.html

- https://docs.flutter.dev/release/release-notes/release-notes-3.32.0

- https://github.com/flutter/flutter/issues/91523

- https://github.com/flutter/flutter/pull/167784

### Atkinson Hyperlegible Next (Feb 10, 2025) has 7 weights and a variable version — up from 2 weights. This is the fact that makes typography-led beauty possible in this app at all.

*Confidence: high, **LOAD-BEARING***

Braille Institute launched Next on 2025-02-10: ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold, each with italics, plus a variable version and a Mono version, and 150+ language support (up from 27). Free, on Google Fonts and brailleinstitute.org/freefont. The original Atkinson Hyperlegible had only Regular and Bold — with 2 weights you cannot build weight hierarchy, so every prior 'use Atkinson' recommendation implicitly forced you into size-only hierarchy, which is exactly what makes accessible apps look like spreadsheets. Next removes that excuse: you can now set a 600 tile label against a 300 secondary and a 700 show-mode display in one family with matched letterforms.

- https://www.brailleinstitute.org/about-us/news/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier/

- https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html

- https://www.printmag.com/type-tuesday/atkinson-hyperlegible-next-applied-design/

### BackdropFilter is the single most expensive widget Flutter ships and must be banned outright in this app — on latency grounds alone, before the accessibility argument.

*Confidence: high, **LOAD-BEARING***

Reported cost: a single full-width BackdropFilter at sigma 20 costs roughly 6–9ms of raster on mid-tier Android (treat the exact number as indicative, not measured here). Impeller specifically regressed vs Skia on blur: flutter/flutter #126353 documents raster thread 16ms avg / 24ms max on Impeller vs 6ms avg / 5ms max on Skia for multiple blurred widgets; #149368 documents Impeller blurs being WORSE than Skia when covering only a small screen region; #161297 documents iOS BackdropFilter issues that vanish when Impeller is disabled. In an app whose entire premise is 'tap and it speaks instantly', spending 6–9ms of raster per frame on decoration is indefensible. Separately, translucency over arbitrary content makes text contrast non-deterministic — you cannot certify a contrast ratio against a background you do not control. If a frosted look is ever wanted: pre-render a blurred PNG behind a translucent fill (approximately free when the backdrop is static), or use ImageFiltered (cheaper than BackdropFilter) — but the honest recommendation is don't.

- https://github.com/flutter/flutter/issues/126353

- https://github.com/flutter/flutter/issues/149368

- https://github.com/flutter/flutter/issues/161297

- https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html

### Warm neutrals are a real 2025–26 move and are nearly free — but the naive application (warm the dark background) backfires. Warm the ink, not the paper.

*Confidence: medium, **LOAD-BEARING***

The temperature rule: a grey at hue 40–60° with low saturation reads warm; hue 200–240° reads cool. The 2025–26 reaction against cold corporate white has products using warm off-whites to reduce eye strain and read as 'thoughtful'. BUT the same sources note the failure mode explicitly: warm dark neutrals suffer a 'warm-dark-reads-as-brown' problem, and cool dark greys produce the layered depth that dark UI needs. This directly complicates the tempting '#141210 not #141218' move. The resolution: prior research already established that TEXT luminance, not background hex, is the dominant halation lever (#FFFFFF→#E0E0E0 cuts contrast 21:1→15.91:1, a 24% drop; #000→#121212 only moves 21:1→18.73:1). So put the warmth where it is both visible and useful — in the off-white text — and leave the background near-neutral. Warm ink on near-neutral paper is the 'ink' read; warm paper on OLED is the 'brown' read.

- https://colorarchive.org/guides/neutral-color-palettes/

- https://colorarchive.org/guides/color-temperature-design-guide/

- https://moda.app/resources/colors/warm-gray

### APCA is the right tool for this palette because it is perceptually uniform across muted/desaturated colors, where WCAG 2.x ratios are known to misbehave.

*Confidence: high, **LOAD-BEARING***

APCA reports Lc 0 to ±106. Lc 75 is the floor for body text at 18px/400. Lc 60 is the floor for non-body text you actually want read. The key property: an Lc value represents the same perceived readability contrast regardless of how light or dark the two colors are — which is exactly the property WCAG 2.x lacks and exactly the property this brief needs, since the whole palette is muted hues at high luminance contrast. Caveat, load-bearing: APCA is not the legal standard. It is a design tool. Ship WCAG 2.x AA/AAA as the compliance floor and use APCA to choose among the many palettes that pass, because APCA will correctly tell you which muted pairs are genuinely readable and WCAG will not.

- https://git.apcacontrast.com/documentation/APCA_in_a_Nutshell.html

- https://git.apcacontrast.com/documentation/WhyAPCA

- https://apcacontrast.com/

### Variable-font axes worth caring about here are wght and (if present) GRAD; opsz is a nice-to-have you will likely have to fake by hand.

*Confidence: medium, **LOAD-BEARING***

opsz auto-adjusts design by display size — thicker/wider small text, finer large headlines — mimicking print's optical sizing. GRAD increases apparent weight/darkness WITHOUT changing character width, so it does not reflow text — which is why it is the correct axis for compensating stroke weight in high-contrast or small-text conditions. In a fixed-position grid where reflow is banned outright, GRAD's no-width-change property is unusually valuable: it lets you darken type for the high-contrast theme without a single tile relaying out. Load-bearing uncertainty: I did not verify which axes Atkinson Hyperlegible Next's variable version actually exposes — it is likely wght-only. Verify before designing around GRAD/opsz. If only wght exists, fake optical sizing manually with per-size-bracket tracking (see design moves).

- https://fonts.google.com/knowledge/glossary/grade_axis

- https://ultimatedesigntools.com/blog/how-to-use-variable-fonts-css/

- https://allbestfonts.com/articles/variable-fonts-guide

### Fragment shaders are the cheap way to do gradient/grain in Flutter — the cost scales with pixels, not CPU — but for this app a baked PNG is cheaper still and a shader is not warranted.

*Confidence: medium*

Effects that are expensive in widget code are cheap as shaders: gradients, noise textures, blur approximations, colour corrections. They scale with pixel count, which is what GPUs are for. Impeller hits the 120Hz frame budget 91.6% of the time in heavy layer composition vs Skia's 67.1%, with ~70% fewer dropped frames in heavy graphics workloads (vendor-flavoured numbers; treat as directional). Critical implementation note: ui.FragmentProgram.fromAsset is a one-time async cost — cache the program at top level, never call it per frame. But: this app's background is a static, unchanging surface. A tiling PNG costs one texture upload at startup and zero per-frame work. Reach for a shader only if you need the grain to respond to the theme toggle at runtime, and even then, three baked PNGs (one per theme) is the boring correct answer.

- https://docs.flutter.dev/ui/design/graphics/fragment-shaders

- https://nick-we.com/251124_shaders-in-flutter/

- https://medium.com/@m.m.shahmeh/flutter-performance-deep-dive-skia-impeller-and-the-frame-pipeline-e1b82fd1d3a5

### The 2026 'quiet luxury / editorial' consensus is typography-led, restraint-with-presence, and explicitly anti-templated — which is the exact register this founder asked for, and it happens to be almost entirely static.

*Confidence: medium*

The reported 2026 vocabulary: typography carries the visual identity and emotional tone rather than supporting it; 'interfaces that feel crafted, not templated'; 'restraint with presence, structural clarity over decoration'. The luxury/hospitality/fashion sector has converged on wide, generous tracking at 0.05em–0.15em with light-to-regular weights, generous line-height, and rigorous monochromatic palettes. IMPORTANT INVERSION for this app: that 0.05–0.15em positive tracking is a DISPLAY-at-large-size-and-light-weight convention. This app needs the opposite at tile scale (17–20pt at weight 500–600 wants NEGATIVE tracking) — copying the trend's tracking numbers literally would damage legibility. Steal the philosophy (type as identity, restraint, monochrome plus one move), not the metrics.

- https://www.fontfabric.com/blog/10-design-trends-shaping-the-visual-typographic-landscape-in-2026/

- https://tubikstudio.com/blog/ui-design-trends-2026/

- https://madegooddesigns.com/font-trends-2026/

### Motion mostly papers over weak composition — and the ban is a net win for THIS user, not a compromise.

*Confidence: high, **LOAD-BEARING***

Reasoning, not a sourced claim. Motion supplies hierarchy in the time dimension: stagger, reveal order, and easing tell you what to look at first. That is a crutch, because it means the still frame does not have to be organised — and a still frame that is not organised is a spreadsheet. Static design must place all hierarchy in the spatial dimension simultaneously. Two consequences specific to this product: (a) motion-supplied hierarchy is only available to someone who was watching when it played — a user in shutdown who looks down mid-transition gets nothing, whereas a static composition re-delivers its full hierarchy at every instant, indefinitely, on every glance; (b) the animation ban means every state change is instantaneous, and an instant state change is MORE legible than a 150ms crossfade, not less — there is no ambiguous in-between frame where the tile is 40% pressed. Print has been beautiful for 500 years with exactly these constraints. The honest cost is that the designer has no place to hide.

### Flutter's default corner radius, default letterSpacing, and default 1dp borders are the three specific defaults that make Flutter apps look like Flutter apps.

*Confidence: high, **LOAD-BEARING***

Reasoning + the squircle sources. M3's default card/button radius (8–12dp circular) on a 76dp+ tile is proportionally the 2014 look. Flutter's default TextStyle.letterSpacing is 0, which is correct at ~14pt and visibly too loose at 20pt+ and grossly too loose at show-mode display sizes — print tightens tracking as size rises, and doing nothing means doing the wrong thing. And Border.all() defaults to width 1.0 LOGICAL pixels, which on a 3x device is a 3-physical-pixel line — a heavy rule, not a hairline. All three are one-line fixes and together they account for most of the gap between 'default' and 'designed'.

- https://github.com/rydmike/squircle_study/blob/master/README.md

## Design moves

- **Break row-height uniformity: give the 3x4 grid non-uniform row heights on a modular scale — e.g. rows at 76 / 88 / 100 / 112dp descending the screen (ratio ≈1.14, roughly a major second), not 4 × 94dp. Tallest rows sit in the lower-center value arc.**
  - Why: This is the single highest-leverage move in the app. A grid of identical rectangles is a spreadsheet; a grid with rhythm is a composition. And it is not decoration — the row rhythm IS the value hierarchy the prior research demanded (highest-value tiles lower-center), and it IS the reach gradient for one-handed thumb use. One decision, three payoffs. Every row stays above the 76dp floor, so nothing is sacrificed.
  - Risk: Bigger tile could be read as 'more important phrase', implying the smaller ones are lesser — but that IS the intended hierarchy, so it is honest, not accidental. Real risk: at 200% TextScaler the top 76dp row will need to grow, and if all rows grow proportionally the grid may exceed viewport height. Decide now whether the ratio compresses toward 1.0 as text scales (recommended) or the grid scrolls (avoid — scrolling breaks fixed-position retrieval, which is the app's core mechanic).
- **Differential gutters: column gap 12dp, row gap 20dp. Never the same number.**
  - Why: Equal gutters in both axes read as a table. Unequal gutters read as a designed page and, specifically, group the grid into ROWS — which is what you want, since rows are the value tiers. This is the cheapest 'composed vs aligned' move that exists. Print has done it forever.
  - Risk: 12dp is exactly the stated minimum gap, leaving zero margin for motor imprecision during a shutdown. Consider 14/22 instead so the tighter axis is not sitting on the floor. Verify against mis-tap testing, not eyeballing.
- **Left-align tile labels to the tile's bottom-left, on a shared baseline per row, with 16dp inset — do NOT center them.**
  - Why: Centered text in a box is the universal signal for 'button'. Left-aligned text sitting on a consistent baseline is the universal signal for 'page'. Because every label in a row shares a baseline, the row scans as a line of type rather than four unrelated widgets, and the eye gets a horizontal rule for free without drawing one. It is the difference between setting text and typography, and it costs one Alignment value.
  - Risk: Long phrases that wrap to 2–3 lines will bottom-align and push upward at different rates per tile, breaking the shared baseline for that row. Mitigate: baseline-align the LAST line, allow the tile to grow upward, and cap at 3 lines. Also, at 200% scale bottom-anchoring may clip ascenders against the tile edge — test with a tall-ascender phrase at max scale.
- **Negative tracking that scales with size. Tile labels at 20pt: letterSpacing -0.2 (≈ -0.01em). Show mode at 96pt: letterSpacing -1.9 (≈ -0.02em). Settings/secondary at 14pt: +0.1. Never leave letterSpacing at Flutter's default 0.**
  - Why: Print's oldest rule: as size goes up, tracking comes down. Flutter's default of 0 is calibrated for ~14pt and is visibly loose at 20pt, and at show-mode display sizes it makes the phrase look like it was typed rather than set. This is a hand-rolled substitute for the opsz axis, which Atkinson Next probably does not expose. It is free and it is most of the perceived 'someone designed this'.
  - Risk: Negative tracking at small sizes or high weights damages legibility for exactly this audience — the values above are deliberately conservative (-0.01em, not the -0.03em a display designer would reach for). Do NOT apply negative tracking below 17pt, and do NOT let it compound with high-contrast theme weight increases. If the user enables OpenDyslexic, drop all negative tracking to 0 — that font's proportions assume default spacing.
- **Show mode is a poster, not a label. Set the utterance left-aligned, ragged-right, at the largest size that fits in 3 lines (clamp 56–120pt), weight 700, leading at 0.95–1.0× size (i.e. height: 0.98), flush to a 24dp left margin, vertically centered as an optical block. Fill the screen with the words.**
  - Why: This is where the app gets to be unambiguously beautiful, and it is 100% free — no motion, no assets, no color. Type as image. A huge phrase set tight and ragged on a plain field is a Swiss poster, and it is ALSO the maximally legible thing for a cashier at arm's length in daylight. Beauty and function are the same artifact here. Centered display type with default leading is the tell of a product that didn't try.
  - Risk: Show mode is the documented exception to the calm rule: it needs a LIGHT background regardless of the user's theme, because a stranger reading at arm's length in daylight needs it. That means tapping into show mode from dark theme produces a full-screen dark→light flash — a large-area luminance jolt aimed at a sensory-sensitized nervous system holding the phone. This is a real hazard and the animation ban makes it worse (no fade to soften it). Genuinely unresolved; needs a decision. Options: a 'show mode brightness' setting; or accept it and warn on first use. Do not solve it with a fade — that reintroduces motion and latency.
- **Warm the ink, near-neutralize the paper. Dark theme: text #E8E4DC (warm off-white) on surface #131212. Light theme: text #1C1A17 on surface #FAF8F4. Do NOT ship a #141210 warm-brown dark surface.**
  - Why: Two established facts compose here. Prior research: text luminance is the dominant halation lever (#FFF→#E0E0E0 costs 24% of contrast; #000→#121212 costs almost nothing) — so the lever you must pull is the text one anyway. Color research: warm dark surfaces read as brown on OLED, while warm off-whites read as thoughtful and reduce eye strain. Putting the warmth in the text therefore does both jobs at once: it pulls text luminance down (halation) AND delivers the ink-on-paper read (beauty). A warm background delivers neither and risks brown.
  - Risk: This contradicts the tempting '#141210 not #141218 because it reads as ink' formulation. I am arguing against it on evidence. But #E8E4DC on #131212 must be APCA-verified — warm off-whites lose luminance vs pure white, and combined with the deliberate luminance reduction you could land under Lc 75. Check it; if it fails, the warmth is the thing to sacrifice, not the contrast. The high-contrast theme should abandon warmth entirely and go pure #FFFFFF/#000000 — warmth is a comfort feature, and the HC theme is not a comfort feature.
- **RoundedSuperellipseBorder at radius 20–24dp on tiles. Not RoundedRectangleBorder, not ContinuousRectangleBorder, not figma_squircle, not 8dp.**
  - Why: Flutter 3.32 (May 2025) shipped the real thing with a GPU implementation in Impeller — the workarounds are obsolete and the ContinuousRectangleBorder×2.3529 hack degenerates into a 'TIE-fighter' at exactly the radii a 76dp+ tile wants. Radius must scale with tile size to keep a constant optical ratio: 8dp on a 100dp tile is the 2014 look; ~22dp is the 2026 look. The superellipse's continuous curvature is the difference between a corner that looks drawn and one that looks calculated, and on a screen that is 12 rectangles it is 48 corners of payoff.
  - Risk: Impeller is default only on Android API 29+; API 28 and below fall back to legacy Skia (since 3.29.3), where the GPU superellipse path may not apply — verify it doesn't regress raster time on an old device, since this app's premise is instant response. Also: if rows have different heights (move 1), a constant radius across differently-sized tiles is optically inconsistent — either accept it (probably fine at this range) or scale radius per row and verify it doesn't read as sloppy.
- **Hairlines at 1 physical pixel, not 1dp: width: 1 / MediaQuery.devicePixelRatioOf(context). On a 3x phone that is 0.333dp.**
  - Why: Border.all() defaults to 1.0 LOGICAL pixel = 3 physical pixels on a modern phone. That is a rule, not a hairline, and it is one of the three defaults that make Flutter apps look like Flutter apps. A true 1-physical-pixel line reads as engraved/etched and is the signature of engineered products (Braun panel lines, Teenage Engineering silkscreen, Vignelli's rules). Nearly free, invisible until you A/B it, then unmissable.
  - Risk: Sub-pixel hairlines can vanish or alias on some renderers and are a genuine problem for low-vision users if they are load-bearing. So: hairlines may only ever be DECORATIVE here. Tile boundaries must be carried by surface tone difference, never by the hairline alone. And the high-contrast theme must promote every hairline to a solid 2dp border — HC users need the boundary, not the craft.
- **Zero shadows. Depth via layered flat surface tones only — M3 ColorScheme.fromSeed surfaceContainerLowest → surfaceContainerHighest, using tone steps, not elevation overlays.**
  - Why: Drop shadows on cards are THE 2014 tell — Material 1's signature and the thing that dates a screen instantly. M3's tone-based surface containers (baseline dark #141218, neutral tone 6) exist precisely to replace them. Flat layered tone is also what every product on the beautiful-and-static list does: Kindle, Instapaper, Muji packaging, Vignelli's signage. It costs nothing to render and it cannot introduce a contrast surprise the way a shadow gradient can.
  - Risk: Tone-step depth needs enough steps to be legible, and this palette is already muted at high luminance contrast — the surface steps may be too close together to read as separate layers. Verify the tile surface vs page surface delta is perceptible (APCA Lc ~15+ between adjacent surfaces) without eating into the label's contrast budget.
- **Category color-coding as a low-chroma SURFACE tint, not a badge or a border. 3–4 categories → 3–4 tile surface tints at LCh chroma ≈ 8–12, all at the same lightness. One text color across all of them.**
  - Why: Prior research says category color is fine and useful for findability and was NOT found infantilizing — this is the permission slip, so use it. The craft move is duotone thinking: the tint lives in the surface, the ink stays constant, so the palette reads as one material dyed four ways rather than four colors stuck on. Chroma 8–12 is the line between 'sophisticated tinted neutral' and 'primary-color rainbow' — the latter is the banned children's-AAC look. Holding lightness constant across tints is what makes it a system rather than four choices.
  - Risk: Color-coding must never be the ONLY channel — position is the retrieval mechanism per prior research, and color is a redundant assist. Verify all 3–4 tints hold Lc 75+ against the single shared ink color (this is why they must share lightness). Test with a deuteranopia/protanopia simulator; at chroma 8–12 some hue pairs will be indistinguishable to CVD users, which is acceptable ONLY because position carries the real load. The high-contrast theme should drop tints entirely.
- **Restraint plus exactly one bold move: the whole screen is muted tinted neutrals, and precisely ONE element per screen carries a saturated accent. Nominate it: the type-to-speak field's active/speak affordance.**
  - Why: This is what separates a beautiful palette from a default one, and it is the shared logic behind every reference on the list — Field Notes (kraft + one ink), Braun (grey + one orange), Teenage Engineering (white + one red), Vignelli's subway (black + the line dots). A single saturated element in a muted field has enormous presence precisely because nothing competes with it. It also satisfies the sensory constraint literally: 'high saturation only as sparing accents' — one accent is the most sparing possible reading.
  - Risk: The one accent must not be the thing a distressed user needs to find fastest, or you have made findability depend on a single color channel. It should mark the SECONDARY path (typing), while the 12 tiles — the primary path — stay findable by position and tint. Verify the accent doesn't become the visual center of gravity and pull the eye away from the lower-center tile arc.
- **Press state = instant tone step + hairline promotion, NOT an instant full invert. Tile surface jumps one container tone lighter/darker and its hairline goes from 1 physical px to 2dp, at zero duration.**
  - Why: Zero animation means state changes are instantaneous, and instantaneous is MORE legible than a 150ms crossfade — there is no ambiguous 40%-pressed frame. This is a real advantage of the constraint, not a workaround. Honor MediaQuery.disableAnimationsOf → Duration.zero and the feedback still lands, because the feedback is a state, not a transition.
  - Risk: I specifically rejected the full-invert version (swap surface and text color), which is the more beautiful poster-like move, because an instant full-area luminance inversion on a 100dp tile is a flash — aimed at a sensory-sensitized nervous system, possibly mid-meltdown. That is a hazard, not a delight. The tone-step version is deliberately less striking. Also verify the tone step is perceptible at all in the muted palette (same concern as move 9) — if it isn't, the hairline promotion must carry the whole signal, and 1px→2dp may be too subtle. Consider a 3dp promotion.
- **Grain: at most a single tiling PNG at 1–2% alpha, baked per theme, applied to the page surface only — never the tiles, never the type. Ship it OFF by default behind a settings toggle.**
  - Why: Grain is the cheapest paper metaphor there is and a tiling PNG costs one startup texture upload and zero per-frame work (cheaper than a fragment shader here, since the surface never changes). It is what makes a flat field read as material rather than void.
  - Risk: This is the move I am least confident about and I'd rather flag it than sell it. Deliberately introducing visual noise into an app whose audience's DEFINING trait is sensory sensitivity is, on its face, a bad idea — for some users static grain is not texture, it is visual static, and it may be actively aversive during overload. It also fights the muted-high-contrast target by adding luminance variance behind text. Hence: page surface only, off by default, and cut it entirely from the high-contrast theme. If v1 scope is tight, cut it entirely — the app is not less beautiful without it, and moves 1–5 do far more work.
- **Ban gradients as decoration. If any gradient exists, it is a single linear ramp across ≤4% lightness on the page surface, with zero hue shift. No mesh gradients.**
  - Why: The 2026 mesh-gradient look is the current equivalent of the 2014 drop shadow — it will date, it is a blob of unearned atmosphere, and it makes text contrast non-deterministic across the screen. This app's beauty budget is entirely spent on composition and type, which is where it should be. Restraint IS the aesthetic; a 4% ramp is enough to keep a large flat field from looking dead on OLED without introducing a single contrast question.
  - Risk: Even a 4% ramp means the text at the top of the screen and the text at the bottom have different measured contrast — pick the WORST point on the ramp for APCA verification, not the average. Cut the ramp entirely from the high-contrast theme.
- **Icon stroke weight must match type weight numerically: if tile labels are Atkinson Next at 600, icons are 2dp strokes at 24dp — and settings/secondary at 400 gets 1.5dp strokes. Pick the icon set by stroke weight, not by shape preference.**
  - Why: Mismatched icon and type weight is the most common invisible sloppiness in otherwise-good apps: a hairline icon next to a semibold label reads as two different design systems collided. Matching them is what 'designed by someone who cares' actually consists of at this granularity. Atkinson Next's 7 weights (vs the old 2) make this tunable for the first time.
  - Risk: Icon strokes must survive the 200% TextScaler requirement — if type scales and icons don't, the match breaks at exactly the accessibility setting that matters most. Scale icon size AND stroke weight with textScaler, or the whole move inverts into sloppiness for the users who most need it. Also: at high-contrast theme, icons need to go heavier alongside type.
- **Verify what the Atkinson Hyperlegible Next variable font's axes actually are before building the type system on them. Do not assume opsz or GRAD.**
  - Why: The 2026 typography discourse leans hard on opsz and GRAD, and GRAD is genuinely the perfect axis for this app — it darkens type without changing character width, which means the high-contrast theme could darken every label with ZERO tile reflow, in an app where reflow is banned because position is the retrieval mechanism. That is an unusually good fit. But Next's variable version is most likely wght-only.
  - Risk: If GRAD is absent, the high-contrast theme must darken type via wght, which DOES change advance widths — which can reflow a label from 2 lines to 3, changing tile content height, in an app where fixed position is sacred. Plan for this: either reserve line-count headroom at the widest weight you will ever use, or lock tile content boxes and let the type shrink. Find out before designing, not after.

## References

- **RydMike's squircle_study** https://github.com/rydmike/squircle_study
  - Steal: The empirical verdict, not the aesthetics: use RoundedSuperellipseBorder (Flutter 3.32+), skip every workaround. Also has the ContinuousRectangleBorder ×2.3529 derivation and the 'TIE-fighter' degeneration demo if you need to justify the choice to yourself.
- **Vignelli — NYC Subway signage & the 1970 Graphics Standards Manual** 
  - Steal: The proof that a rigid grid of rectangles can be beautiful with zero motion and near-zero color: a strict modular system, a single typeface, one saturated dot per line against pure neutral. Specifically steal the 'black field + one color per category' logic for the tile tints, and the discipline that the system's rules are visible AS the aesthetic.
- **Field Notes** https://fieldnotesbrand.com/
  - Steal: Kraft substrate + exactly one ink. The single-bold-move palette (design move 11) in its purest form. Also: their whole appeal is that it looks like a tool, not a toy — which is precisely this project's dignity wedge, executed via material rather than copy.
- **Teenage Engineering (OP-1 / OP-Z / TP-7)** https://teenage.engineering/
  - Steal: Silkscreen-thin hairlines on flat fields (design move 8), and the confidence to leave enormous areas of a surface completely empty. Their UIs are essentially static and are the strongest existing proof that 'no motion' and 'delightful' are compatible. Also: white + one red, held for a decade.
- **Kindle / Instapaper** 
  - Steal: Both are beautiful and literally cannot animate (or refuse to). Type IS the entire interface. Steal Instapaper's discipline on measure and leading, and Kindle's proof that a warm off-white paper tone + near-black ink is the most comfortable long-read surface ever shipped — but note this project should invert it (warm the ink, neutral the paper) because the dark theme is OLED, not e-ink.
- **Braun (Dieter Rams) — ET66, T3, RT20** 
  - Steal: Grey field, one orange element, and non-uniform module sizes within a strict grid — the ET66 calculator's differently-sized keys on a fixed layout is almost literally design move 1. Position never changes; size encodes value. This is the closest physical precedent for a fixed-grid AAC surface.
- **Panic (Nova, Playdate OS)** https://panic.com/
  - Steal: Personality without mascots. Panic's products have enormous character delivered entirely through color choice, type, and surface finish — no characters, no gamification. Proof for the founder that 'no cartoon avatars' and 'has personality' are not in tension.
- **Things 3** https://culturedcode.com/things/
  - Steal: Optical spacing obsession — Cultured Code's blog documents hand-tuned optical alignment where mathematical alignment looked wrong. That is the register of finish being asked for. (Caveat: Things leans on motion heavily; steal its spacing craft, not its interaction model.)
- **Braille Institute — Atkinson Hyperlegible Next** https://www.brailleinstitute.org/freefont/
  - Steal: The font itself, and specifically the 2025 Next version's 7 weights + variable — not the original 2-weight Atkinson. Verify the variable axes before designing on them. The Mono version may be useful for the type-to-speak field if you want that surface to read as a distinct instrument.
- **APCA contrast calculator** https://apcacontrast.com/
  - Steal: Use it as the design tool for choosing among muted palettes (Lc 75 body floor, Lc 60 non-body floor) while still shipping WCAG 2.x AA as the compliance floor. This is the tool that lets you defend 'muted hues at high luminance contrast' with numbers instead of vibes.
- **Muji** 
  - Steal: Restraint and negative space as the entire product identity, plus the specific lesson that 'no branding' IS the branding. Relevant to the dignity wedge: Muji products don't tell you you're doing a good job.

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


YOUR DIMENSION: How do you make something BEAUTIFUL when you cannot animate? This is the core creative problem of this project.

The app bans animation for two good reasons (distress + latency). Every contemporary "delightful design" playbook leans on motion. So: what are the OTHER levers, and how good can they get?

Research with WebSearch/WebFetch, and reason hard. Look to: editorial/print design, book design, typography, poster design, Swiss/International style and its modern descendants, brutalist and neo-brutalist web design, the "quiet luxury" aesthetic, album art, signage/wayfinding systems (Vignelli), museum graphics, and static-first digital products.

- **Composition**: grids, rhythm, optical alignment, tension, asymmetry, the difference between "aligned" and "composed". How does a 3x4 grid of rectangles become a composition rather than a spreadsheet? Concrete moves.
- **Typography as the primary expressive instrument**: type as image, scale contrast, weight contrast, optical sizing, variable fonts (which axes matter?), tracking/leading craft, the difference between "setting text" and "typography". What does GREAT type look like on a phone in 2026?
- **Material and surface without motion**: grain/noise texture, subtle gradients (mesh gradients? the 2026 kind), depth via layered surfaces vs shadows, edge treatment (hairlines, insets, bevels), translucency/blur (and its a11y cost), paper/ink metaphors. What's cheap in Flutter and what's expensive?
- **Color as craft**: how do sophisticated products use color? Restraint + one bold move? Duotone? Unexpected neutral temperature (warm greys vs cool greys — this matters enormously and is nearly free)? Tinted blacks? What separates a beautiful palette from a default one?
- **Detail and finish**: the small things that read as "designed by someone who cares" — optical corner radius (superellipse/squircle vs circular radius — Apple's continuous corners; is it available in Flutter? `ContinuousRectangleBorder`? Is it right?), consistent optical spacing, icon weight matching type weight, hairline treatment, focus states.
- **Empty states, negative space, restraint** as beauty.
- Find products that are genuinely beautiful and essentially STATIC. What do they do? (Consider: Things 3, Bear, Ivory, Oak, Kindle, Instapaper, Teenage Engineering's UIs, Panic's apps, Field Notes, Braun/Rams objects, Muji.) What's the transferable move?
- **Honest question**: is "beautiful without motion" actually harder, or does motion mostly paper over weak composition? Argue.

Return CONCRETE MOVES, not principles. "Use a warm near-black (#141210) not a blue-black (#141218) because it reads as ink rather than screen" is the register I want.
````

</details>
