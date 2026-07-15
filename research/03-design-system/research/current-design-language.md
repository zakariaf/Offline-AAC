# current-design-language

> Phase: **research** · Agent `af95fe0ae3c4dc3df` · Run `wf_f237e8a6-694`

## Result

## Summary

Google's M3 Expressive numbers check out as *reported* (46 studies, 18,000+ participants, 3 years, "up to 4x faster" element spotting, older users spotting elements as fast as younger ones) — but they are unpublished vendor marketing research with no methodology, no confidence intervals, and no independent replication, and the mechanism is plain visual salience, not "expressiveness." This matters enormously here: salience is a *zero-sum budget* and relative, so the 4x does NOT transfer to a grid of 12 co-equal tiles. If every tile is expressive, no tile pops. The legitimate transfer is preattentive category color (search time stays roughly flat as set size grows when the target hue is known) and one genuine hierarchy: the grid vs the type field, and **show mode as the app's single "hero moment."** Spend the entire expressive budget there — it's the one screen where calm is not the constraint (a stranger, arm's length, daylight), and it's the screenshot that sells the app. Flutter has NOT shipped M3 Expressive: the tracking issue (#168813) says the team is "not actively developing" it and won't take contributions; Flutter 3.44 (2026-05-16) decoupled Material into `material_ui: ^1.0.0` and code-froze the in-SDK version, which is the enabling architecture but not the feature. For a one-screen app with 12 tiles and a text field, hand-rolling is trivially feasible — steal M3E's principles, not its components. Liquid Glass's translucency is disqualifying (contrast-destroying material, sensory-sensitive low-vision audience, motion-reactive specular highlights = banned twice over) and Apple itself retreated within six months via 26.1/26.2 rollbacks — but its real innovation is worth stealing: **visual interest lives at the element's EDGE, not in its fill**, which an opaque tile can do at zero contrast and zero animation cost. The mechanical difference between "formal" and "creative" is not adjectives, it's **ratio compression vs. ratio expansion** — same tokens, different spread. Critical catch: the prior brief's own spec is currently unbuildable — original Atkinson Hyperlegible ships only Regular/Bold (400/700), so "tile labels weight 500–600" requires Atkinson Hyperlegible **Next** (Feb 2025, 7 weights + variable).

### Google's M3 Expressive research numbers are accurately reported but are unpublished vendor research, and the '4x faster' mechanism is ordinary visual salience — which does NOT transfer to a grid of co-equal tiles

*Confidence: high, **LOAD-BEARING***

Verified from design.google (Google's own marketing property): 46 separate studies, 18,000+ participants, 3 years, methods = eye-tracking, surveys/focus groups, sentiment experiments, usability. Claim: 'Participants were able to spot key UI elements up to four times faster in the M3 Expressive designs.' The cited example is an email Send button. But that comparison pits a small, flat, low-contrast text button against a large, filled, color-contrasted container — a salience manipulation, not an aesthetic one. It reduces to well-established visual search science (preattentive features; Treisman feature-integration), rebranded. NO paper, NO published methodology, NO confidence intervals, NO preregistration, NO independent replication exists — targeted searching for critical/skeptical analysis of the methodology returned nothing but promotional coverage. CRITICAL CONSEQUENCE FOR THIS APP: salience is relative and zero-sum. A 3x4 grid of 12 equal-weight tiles has no hero element for the 4x to apply to; making every tile expressive makes no tile pop. Note the 'up to' hedge doing heavy lifting.

- https://design.google/library/expressive-material-design-google-research

- https://chromeunboxed.com/google-leaks-the-reason-and-process-behind-their-new-material-3-expressive-design-language/

### The M3E finding that DOES transfer is the older/low-vision result — and it points at size + color + containment, i.e. the founder's instinct that beauty and accessibility are not in tension is evidence-supported

*Confidence: medium, **LOAD-BEARING***

Google: 'M3 Expressive design enabled older users to spot key interactive elements on the screen just as fast as younger users across 10 apps tested' — against a baseline where 'usability tests typically find that older adults take longer to visually locate key UI elements.' Also: expressive designs were 'more visually appealing, intuitive, and easy to use for participants with varying movement and visual abilities.' Preference: up to 87% among 18–24s, net-positive across all age groups. Desirability deltas: +34% modernity, +32% subculture, +30% rebelliousness. Same vendor-research caveat applies, but the direction is consistent with independent literature on preattentive features. The usable version for this app: category color as a preattentive cue makes visual search time roughly flat as set size grows when the user knows the target hue — that is how a shutdown user finds 'I need to leave' among 12 tiles without reading all 12 labels. This is the real, defensible version of the 4x claim, and prior research already blessed category color-coding as non-infantilizing.

- https://design.google/library/expressive-material-design-google-research

### Flutter has NOT shipped Material 3 Expressive. As of 2026-07 there is no official implementation — the founder must hand-roll, which is fine for a one-screen app

*Confidence: high, **LOAD-BEARING***

flutter/flutter issue #168813 ('Bring Material 3 Expressive to Flutter'), opened 2025-05-14. Team statement, verbatim: 'Currently, we are not actively developing Material 3 Expressive, and we will not be accepting contributions for Expressive features or updates at this time.' ALL sub-features listed as not-started: 15 new/updated components, motion-physics system, emphasized typography, the 35-shape expanded library, vibrant color schemes. 2025-07-29 update: Material/Cupertino being decoupled into standalone packages; M3E work would happen there 'once established.' Flutter 3.44 stable (2026-05-16) shipped `material_ui: ^1.0.0` and `cupertino_ui: ^1.0.0` on pub.dev; in-SDK `package:flutter/material.dart` is now code-frozen (bug fixes only, no new APIs) and emits a deprecation warning. NOTE: I found NO verification that M3E actually landed in material_ui — claims that 'Flutter will support M3E and Liquid Glass as optional packages' trace to a low-quality Medium post, not Flutter's team. Treat as unshipped until proven. Community package `m3e_core` exists on pub.dev (unofficial). PRACTICAL UPSHOT: this app consumes almost no Material components — 12 tiles, a text field, ~3 buttons. Hand-rolling the shape/type/color language is a weekend, not a quarter. Do not block on the framework.

- https://github.com/flutter/flutter/issues/168813

- https://startdebugging.net/2026/05/flutter-3-44-material-cupertino-packages-swiftpm-default/

- https://pub.dev/packages/m3e_core

### The prior brief's typography spec is currently unbuildable: original Atkinson Hyperlegible has only 2 weights. 'Weight 500-600' requires Atkinson Hyperlegible Next (Feb 2025)

*Confidence: high, **LOAD-BEARING***

Original Atkinson Hyperlegible (Braille Institute, 2020) ships Regular (400) and Bold (700) only, each with italic — there is no Medium (500) or SemiBold (600). The prior brief specifies 'tile labels min 17pt, default ~20pt, weight 500-600', which the original font cannot render (Flutter would synthesize a fake weight or snap to 400/700). Atkinson Hyperlegible Next launched 2025-02-10: SEVEN weights (ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold), each with italic, PLUS a variable font (Light→ExtraBold axis) and a monospace cut. Language support expanded from 27 to 150+. Free, on Google Fonts and brailleinstitute.org/freefont. The variable font also unlocks the ratio-expansion move below (arbitrary weight along the axis) at one file's download cost. ACTION: specify Atkinson Hyperlegible Next Variable, not Atkinson Hyperlegible.

- https://www.brailleinstitute.org/freefont/

- https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html

- https://www.printmag.com/type-tuesday/atkinson-hyperlegible-next-applied-design/

- https://pimpmytype.com/font/atkinson-hyperlegible-next/

### MECHANICAL definition of formal vs. creative: ratio COMPRESSION vs. ratio EXPANSION. Same tokens, different spread. This is the single most actionable lever in this research

*Confidence: medium, **LOAD-BEARING***

Corporate/formal design compresses every scale toward its middle: type sizes all within ~1.4x of each other (14/16/18/20), weights 400–600, every corner the same radius, every gap a multiple of 8, every card identical. Creative/expressive design EXPANDS the same ratios: type size 1:3 or wider, weight 400:800, radius 8:32. Nothing is added — the spread is widened. Corollary levers, all mechanical and checkable: (1) symmetry vs. deliberate asymmetry; (2) uniformity vs. per-role differentiation; (3) neutral+one-accent vs. a committed palette where color carries meaning; (4) framework-default rectangles vs. an actual shape language; (5) mathematical grid-obedience vs. optical adjustment (type that LOOKS centered rather than IS centered); (6) generic system font vs. a typeface with a face; (7) — the heart of it — expressive design has ONE memorable, repeatable formal gesture; corporate design has none. This is exactly Liam Spradlin's M3E framing: 'Expressive can mean quiet. And it can also mean loud.' Quiet is not the same as formal. The founder's app should be quiet AND expressive, which is a coherent, achievable target.

- https://design.google/library/design-notes-material-3-expressive-liam-spradlin

### Liquid Glass, concretely: real-time lensing, motion-reactive specular highlights, content-adaptive tinting. Translucency is disqualifying here — and Apple itself retreated within 6 months

*Confidence: high, **LOAD-BEARING***

Announced 2025-06-09 at WWDC25. Apple's own framing: a 'digital meta-material that dynamically bends and shapes light'; 'lensing is the primary way Liquid Glass visually defines itself' — dynamically bending/concentrating light in real time at element edges; real-time rendering that 'dynamically reacts to movement with specular highlights'; color 'informed by surrounding content,' adapting between light/dark. Backlash: NN/g published 'Liquid Glass Is Cracked, and Usability Suffers in iOS 26' — text-on-image contrast too low ('camouflaged against their beach-vacation photo, or worse, their pet's fur'), overlapping text layers requiring 'Dan Brown-level cryptographic decoder skills,' Maps icons blending into backgrounds 'despite the blurring,' and abandonment of Apple's own 0.4cm target-gap / 1cm×1cm tap-area guidance producing 'cramped'/'squeezed' tab bars. Apple's retreat: Reduce Transparency + Increase Contrast offered as fixes (NN/g notes these are 'less effective at their stated functionality than they were in prior iOS releases'); iOS 26.1 added tinted/opaque options; iOS 26.2 (2025-12) rolled back Lock Screen glass. A vendor walking back its flagship redesign in 6 months IS the verdict. FOR THIS APP: translucency destroys contrast (the audience's #1 need), specular highlights are gyroscope-driven motion (violates zero-animation twice: distress-triggering AND uncontrollable by the user), and real-time refraction costs frame budget in a product whose premise is instant speech. Reject the material wholesale.

- https://developer.apple.com/videos/play/wwdc2025/219/

- https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/

- https://www.nngroup.com/articles/liquid-glass/

- https://www.macrumors.com/how-to/ios-reduce-transparency-liquid-glass-effect/

- https://techcrunch.com/2025/12/12/with-ios-26-2-apple-lets-you-roll-back-liquid-glass-again-this-time-on-the-lock-screen/

- https://en.wikipedia.org/wiki/Liquid_Glass

### What CAN be stolen from Liquid Glass: the EDGE as the site of visual interest, and concentric corner radii. Both are free of contrast and animation cost

*Confidence: medium*

Strip away the translucency and Liquid Glass's actual formal insight is that the element's boundary — not its fill — carries the craft. Lensing concentrates light AT THE RIM. An opaque tile can do this statically: a ~1–1.5dp inner rim, lighter on the top edge, marginally darker on the bottom, implying a physical bevel. Costs zero contrast (the fill stays opaque), zero animation, zero frame budget (it's a static border). This is how you get 'material' and 'crafted' without glass. Second steal — concentric radii: Apple's rounding is a superellipse (continuous curvature), and nested elements share a common center, so inner radius = outer radius − padding. Getting this right is a checkable craft signal that separates 2026 from 2015; getting it wrong (a 4dp inner chip inside a 24dp tile) reads amateur even when viewers can't say why.

- https://developer.apple.com/videos/play/wwdc2025/219/

### Flutter's ContinuousRectangleBorder is NOT an Apple squircle and should not be used. figma_squircle at smoothing 0.6 is the correct match

*Confidence: high*

From rydmike/squircle_study (a systematic Flutter comparison of squircle ShapeBorder options): 'The ContinuousRectangleBorder in Flutter SDK is a super ellipses shape, but it is not a match for the one used in iOS on UI elements... If FigmaSquircle at smoothing 0.6 is a correct representation of the iOS SwiftUI Squircle, then ContinuousRectangleBorder is NOT at all an acceptable option.' It's roughly half as smooth as it should be. Known workaround: multiplying ContinuousRectangleBorder's radius by 2.3529 approximates iOS — but 'only effective at lower border radii,' so it fails at the 24dp+ radii this app wants. ContinuousRectangleBorder also carries a performance cost over RoundedRectangleBorder. Correct options: `figma_squircle` (aloisdeniel; implements Figma's corner smoothing) or the lesser-known `smooth_corner`, which 'produces identical shapes to figma_squircle.' VERIFY current maintenance/null-safety status before adopting — figma_squircle's last widely-cited version is 0.6.2 and a community fork `figma_squircle_updated` exists, which hints the original may be stale.

- https://github.com/rydmike/squircle_study

- https://github.com/rydmike/squircle_study/blob/master/README.md

- https://pub.dev/packages/figma_squircle

- https://pub.dev/packages/figma_squircle_updated

- https://github.com/aloisdeniel/figma_squircle

### The M3 corner radius scale is a 10-step ladder, verified: 0 / 4 / 8 / 12 / 16 / 20 / 28 / 32 / 48 / full

*Confidence: high*

Verified via the material_design Dart package's M3Corners mirror of the M3 tokens: zero 0dp, extraSmall 4dp, small 8dp, medium 12dp, large 16dp, largeIncreased 20dp, extraLarge 28dp, extraLargeIncreased 32dp, extraExtraLarge 48dp, full 9999dp (pill). The '-Increased' steps (20dp, 32dp) and 48dp are M3 Expressive additions — a finer ladder than baseline M3. M3E also changed 'full' to mean literally full rather than the previous 50%-of-component-size. The separate '35 new shapes' are decorative RoundedPolygons built from cubic Béziers with per-corner radius and smoothing values, designed for shape-morph motion — IRRELEVANT to this app (they exist to animate, and animation is banned; a wiggle-shaped tile would also read as childish, which is the cardinal sin here). Take the radius ladder; leave the shape zoo.

- https://pub.dev/documentation/material_design/latest/material_design/M3Corners-class.html

- https://m3.material.io/styles/shape/shape-morph

- https://www.figma.com/community/file/1510597655879136621/m3-expressive-shapes-set

### The M3E type scale is 30 styles: 15 baseline + 15 'emphasized' parallel styles differing by weight

*Confidence: medium*

The updated M3 type scale comprises two parallel sets of 15 styles across the same roles (display, headline, title, body, label) × sizes (large, medium, small). Emphasized styles 'have a higher weight and other minor adjustments compared to the baseline styles' and are 'best applied to bold, selection, and other areas of emphasis' — headlines, actions, editorial treatments. Each variant encodes size, line height, weight, and tracking. Google's guidance: use baseline and emphasized TOGETHER to achieve expressive experiences. I could NOT retrieve exact numeric values — m3.material.io is JS-rendered and returns only titles to fetchers; the founder should pull tokens from the Figma kit or Compose's Typography class directly rather than trust any blog's transcription. The mechanic to steal is the pattern itself, not the numbers: a parallel emphasized weight for the same role is exactly the ratio-expansion lever, and Atkinson Hyperlegible Next Variable makes it free.

- https://m3.material.io/styles/typography/type-scale-tokens

- https://matraic.github.io/m3e/styles/typography.html

- https://composables.com/docs/androidx.compose.material3/material3/classes/Typography

### CHECKABLE 'your app looks 2015' list — 12 specific tells

*Confidence: medium, **LOAD-BEARING***

(1) Circular-arc corners at 2–8dp on large elements — M2 cards rested at 1–2dp radius; a 4dp radius on a 100dp tile is THE tell. (2) Drop shadows as elevation: `elevation: 1/4/6/8` with hard grey umbra — M3 replaced shadow-elevation with TONAL elevation (seed-tinted surface containers); if your Card has an elevation number and a grey shadow, it's 2015. (3) The M2 triad: FAB + hamburger + 4dp AppBar shadow. (4) Thin type: weight 300 at large sizes, centered — Roboto Light / iOS 7 Helvetica Neue UltraLight hangover. 2026 defaults to 500–700. (5) Compressed type-size scale — everything 14/16/18/20, within 1.4x. (6) The literal M2 palette hexes: #2196F3 blue500, #4CAF50 green500, #F44336 red500 — these are a fingerprint; using them is like leaving the Bootstrap #007BFF in. (7) Flat 1.0: pure #FFFFFF cards on #F5F5F5, separated by 1px #E0E0E0 dividers — dividers themselves are a tell; 2026 separates with SPACE and tonal surface steps. (8) PURE neutrals: #FFFFFF/#808080/#000000 with zero hue. 2026 neutrals are hue-tinted — M3's own dark surface #141218 is a neutral-VARIANT tone carrying the seed's hue, not grey. (9) Long shadows / skeuomorphic bevels (2013–14, dead). (10) Corporate Memphis / 'Alegria' flat illustration — disproportionate limbs, faceless figures; peaked 2019–21, now actively derided (banned here regardless). (11) 2014-style gradients: linear, 2-stop, top-to-bottom, high-chroma, lightness-shifted, visible banding. (12) Uniform density: identical padding everywhere, no rhythm, everything obedient to one 8dp grid.

- https://uxdesign.cc/material-3-expressive-building-on-the-failures-of-flat-design-d7a9bb627298

- https://pub.dev/documentation/material_design/latest/material_design/M3Corners-class.html

### What reads as 2026 — and the gradient distinction the founder specifically needs

*Confidence: medium, **LOAD-BEARING***

Shape: large radii (16–28dp+) with CONTINUOUS/superellipse curvature and concentric nesting. Shape used as hierarchy, not decoration. Type: high default weight (500–700), WIDE size contrast, tight tracking at display sizes, editorial/typographic layouts. Color: we are in a MUTED-BASE + SATURATED-ACCENT era — not the fully-saturated 2021 'bold minimalism' era, not the 2015 grey era. This is precisely the brief's existing constraint, which is a gift: the sensory-sensitivity requirement and the 2026 register POINT THE SAME WAY. Neutrals are hue-tinted, never pure grey. Depth: flat is over, but the replacement is TONAL depth + edge treatment + grain — NOT drop shadows and NOT neumorphism (which trades contrast for softness and is disqualified here on contrast grounds regardless of whether blogs are reviving it). GRADIENTS, the key distinction: 2014 = linear, 2-stop, top-to-bottom, high-chroma, lightness-shifted, banded. 2026 = multi-stop MESH, low-chroma, HUE-shifted rather than lightness-shifted (so luminance stays nearly flat — which is exactly what preserves text contrast), scaled LARGER than the element it fills, and dithered with fine grain to kill 8-bit banding. A low-chroma hue-shifted gradient at constant luminance is contrast-safe by construction. Grain/noise is back and has a FUNCTIONAL justification here, not just an aesthetic one: it dithers away banding. Bento grids: peaked ~2023–24, now baseline rather than fresh — and this app's fixed uniform grid can't chase it anyway. CAVEAT: the trend-source layer here is weak. Searches returned SEO farms and interior-design noise; I anchored on shipped, checkable design systems (M3/M3E tokens, iOS 26) rather than trend blogs. Treat the trend claims as medium confidence and the token claims as high.

- https://studiomeyer.io/en/blog/webdesign-trends-2026-reality-check

- https://fireart.studio/blog/the-best-web-design-trends/

- https://thecrit.co/resources/design-trends-2026

### Show mode is the legitimate 'hero moment' — and resolves the beauty-vs-calm tension structurally rather than by compromise

*Confidence: medium, **LOAD-BEARING***

M3E's 'hero moment' concept means concentrating the expressive budget in one place rather than spreading it. This app has an unusually clean candidate that prior research already identified as 'the exception to the calm rule': show mode. Its constraints are INVERTED from the main grid — a stranger, arm's length, daylight, no sensory-sensitivity constraint (the reader is not the sensitive party), no shutdown-state decision-making load, and the user is holding the phone OUT rather than reading it. So show mode can be loud, high-chroma, huge-type, full-bleed — the one place the app is allowed to be beautiful in the obvious way. This means the founder does NOT have to make the calm grid carry the 'creative and beautiful' mandate by itself, which is exactly the tension that would otherwise force a bad compromise. It is also the screenshot for the store listing. Strategic bonus: this is the app's signature gesture — the ONE memorable repeatable formal move that separates expressive from corporate.

- https://design.google/library/design-notes-material-3-expressive-liam-spradlin

## Design moves

- **Specify Atkinson Hyperlegible NEXT Variable (Feb 2025), not Atkinson Hyperlegible. Tile label: 20pt / wght 600. Ship the variable font, subset to Latin.**
  - Why: The original font has only 400 and 700 — the existing spec's 'weight 500-600' literally cannot render on it; Flutter would synthesize a fake weight or snap. Next adds Medium/SemiBold and a continuous Light→ExtraBold axis, which makes every weight-based ratio move free after one font file.
  - Risk: Variable font file size (mitigate with Latin subsetting). Verify Next's hinting at small sizes matches original Atkinson's — the legibility research was done on the ORIGINAL font, so Next's low-vision performance is an inference, not a measured result. If in doubt at ≤17pt, test both.
- **Tile corner radius 24dp (M3 'extraLarge' 28dp minus a touch), rendered as a TRUE superellipse via figma_squircle at smoothing 0.6 — NOT RoundedRectangleBorder, and explicitly NOT ContinuousRectangleBorder.**
  - Why: An 8dp circular-arc corner on a ~100dp tile is the single loudest '2015' tell. rydmike's squircle_study establishes ContinuousRectangleBorder is 'NOT at all an acceptable option' as an iOS-grade squircle, and its 2.3529x workaround only holds at LOW radii — i.e. it fails exactly at the radius this app wants.
  - Risk: figma_squircle 0.6.2 may be stale (a `figma_squircle_updated` fork exists — check maintenance/null-safety first). Custom ShapeBorders cost more to paint than RoundedRectangleBorder; measure it, because this app's whole premise is instant speech. If it costs frames, fall back to RoundedRectangleBorder at 24dp — a large circular radius still reads far more current than a small one.
- **Concentric radii everywhere: inner radius = outer radius − padding. Tile at 24dp with a 16dp inset chip → chip radius 8dp. Never nest a same-radius or larger-radius child.**
  - Why: Concentricity is the checkable craft signal that separates 2026 from 2015; violations read amateur even when viewers can't articulate why. Free to implement — it's arithmetic.
  - Risk: None functionally. Just requires discipline when radii change later — make it a computed function of the parent, not a hardcoded constant, or it will drift.
- **Zero drop shadows. Elevation via M3 tonal surface containers only (surfaceContainerLowest → surfaceContainerHighest), generated from ColorScheme.fromSeed.**
  - Why: `elevation: 4` + grey umbra is M2 and is a top-3 dating tell. M3 replaced shadow-elevation with tone-elevation. Tonal steps also survive high-contrast mode gracefully, where shadows just disappear.
  - Risk: Tonal steps are subtle by design and can collapse to near-invisible in high-contrast theme. Give the HC theme explicit borders instead of relying on tonal separation — do not assume one surface system serves all three themes.
- **EXPAND the ratios; that IS the creative/formal lever. Type size 20pt (tile label) → 96pt+ (show mode) = ~1:5. Weight 400 (hints/secondary) → 700 (show mode). Radius 8dp (small chips) → 24dp (tiles). Refuse to let everything sit within 1.4x of everything else.**
  - Why: This is the most actionable finding in the research. Formal/corporate design compresses every scale toward its middle; expressive design widens the same scales. Nothing is added, no constraint is broken — only the spread changes. Costs zero contrast, zero motion, zero latency.
  - Risk: Ratio expansion must not compress the SMALL end — do not shrink secondary text to manufacture contrast; grow the large end instead. Everything must still survive TextScaler at 200%+ without clamping, so test the 96pt show-mode type at 2x scale and design its overflow/auto-fit behavior deliberately (it will need to shrink-to-fit, and that shrink must have a floor).
- **Spend the ENTIRE expressive budget on show mode. Full-bleed high-chroma ground, type at 96pt+/wght 700, edge-to-edge, no chrome. Keep the grid quiet and warm. This is the app's one signature gesture.**
  - Why: Show mode's constraints are inverted — stranger, arm's length, daylight, and the sensory-sensitive party is not the one reading it. It's the only place calm isn't the constraint, so it's where beauty can be loud. Also resolves the beauty-vs-calm tension structurally instead of by compromise, and it's the store screenshot.
  - Risk: The transition INTO show mode must be instantaneous and non-startling — a sudden full-screen high-chroma flash is exactly the sensory event the zero-animation rule exists to prevent, and it hits the USER's eyes before the stranger's. Consider whether the user sees a dimmed intermediate state, and honor MediaQuery.disableAnimationsOf. Also: this screen must survive being shown in direct sunlight — validate chroma choices at max brightness outdoors, not on a desk.
- **Category color as a FULL opaque tile fill — low chroma, high luminance contrast against the label. Not a left-edge stripe, not a corner dot, not a colored icon.**
  - Why: Preattentive color search keeps find-time roughly flat as set size grows when the user knows the target hue — this is the real, defensible version of Google's '4x faster,' and it's the mechanism that lets a shutdown user find a tile without reading 12 labels. Full fill maximizes the preattentive signal; a stripe or dot is too small a color area to trigger it. A left-edge color stripe is also a Gmail/Trello ~2014 tell.
  - Risk: Full-fill color across 12 tiles risks becoming the 'primary-color rainbow' that reads as children's AAC — the cardinal banned thing. Mitigate hard: cap at 2-5 hues total (not 12), keep chroma genuinely low, keep all fills at similar LUMINANCE so the grid reads as one calm field rather than a Christmas tree, and let hue do the discriminating. Also: color must never be the ONLY channel (position is already load-bearing and prior research fixed it — good). Verify against the three most common CVD types; at low chroma, red/green pairs will collide.
- **Hue-tinted neutrals only. Derive every surface from ColorScheme.fromSeed. Ban pure #FFFFFF / #808080 / #000000 from the palette entirely.**
  - Why: Pure zero-hue neutrals are a 2015 tell. M3's own dark surface #141218 is a neutral-variant tone carrying the seed's hue — warmth costs nothing and is the cheapest single move from 'grey rectangle grid' toward 'warm and adult,' which the prior research explicitly licenses.
  - Risk: Direct conflict with the established halation finding: text luminance is the dominant lever, and #E0E0E0 vs #FFFFFF already costs 24% of contrast. Tinting must move HUE at constant luminance, never trade luminance for warmth. The high-contrast theme is the exception — it should be permitted true #FFFFFF/#000000, because HC mode's job is maximum contrast, not warmth.
- **Treat the tile EDGE as the material: a static ~1-1.5dp inner rim, lighter on the top edge, marginally darker on the bottom. Opaque fill, no blur, no translucency, no gyroscope.**
  - Why: This is the one genuinely stealable idea in Liquid Glass — visual interest lives at the boundary, not the fill. It implies physical material and reads crafted, at zero contrast cost (fill stays opaque), zero animation, and zero frame budget (it's a static border).
  - Risk: At 1dp this may vanish on low-DPI screens or in high-contrast mode. Make the rim a theme-aware token: decorative in light/dark, promoted to a real high-contrast border in HC mode — where it stops being decoration and starts doing the separation work the tonal steps can't.
- **If any gradient is used: multi-stop, HUE-shifted at near-constant luminance, low chroma, scaled larger than the element, with a precomputed static grain/noise overlay (~2-4% opacity) baked as an asset.**
  - Why: Hue-shifted-at-constant-luminance is contrast-safe by construction — it's the property that makes 2026 gradients compatible with accessibility where 2014's lightness-ramped 2-stop gradients weren't. Grain has a functional justification here beyond aesthetics: it dithers away 8-bit banding, which is itself a visible artifact.
  - Risk: Ship grain as a static image asset, NEVER a runtime shader — shader compilation jank on first paint would hit exactly the instant-speech premise. Verify the noise doesn't read as visual texture/static to sensory-sensitive users; if in doubt, make gradients an option rather than the default, and keep a flat-fill theme. Honestly: the flat opaque tile may simply be the better answer, and this is the move most likely to be cut.
- **Optically center tile labels, not mathematically — cap-height centered, which typically sits the text ~1-2% above the box's true center.**
  - Why: Optical adjustment over grid-obedience is one of the mechanical separators between expressive and corporate. It's the kind of craft that isn't consciously noticed but is felt.
  - Risk: Must be derived from font metrics, not a hardcoded nudge, or it breaks at 200% TextScaler and on the dyslexia-font option. If it can't be done metrically, skip it — a hardcoded offset that drifts at large text scales is worse than mathematical centering.
- **Do NOT adopt M3E's 35-shape library, shape-morph, or the motion-physics system. Take only the corner-radius ladder (0/4/8/12/16/20/28/32/48/full) and the baseline+emphasized type pattern.**
  - Why: The 35 shapes exist to morph — they are a motion feature, and animation is banned twice over here. A wiggle/cookie-shaped tile would also read as childish, which is the cardinal sin. Flutter hasn't shipped any of it anyway (#168813), so declining costs nothing.
  - Risk: None. This is a subtraction. Note the corollary: since Flutter ships no M3E, every move here is hand-rolled — which is entirely feasible for one screen with 12 tiles, a text field, and ~3 buttons. Do not block on the framework; also pin `material_ui: ^1.0.0` rather than tracking the code-frozen in-SDK library, so a future Flutter upgrade can't force a design change under you.

## References

- **Google Design — Expressive Material Design research** https://design.google/library/expressive-material-design-google-research
  - Steal: The evidence that expressive ≠ inaccessible: older users spotting elements as fast as younger ones. This is the founder's permission slip, quotable in the store listing. But steal the MECHANISM (size + color + containment as preattentive cues), not the aesthetic — and know it's unpublished vendor research with no methodology, so don't cite the 4x as if it were peer-reviewed.
- **NN/g — 'Liquid Glass Is Cracked, and Usability Suffers in iOS 26'** https://www.nngroup.com/articles/liquid-glass/
  - Steal: The counter-case, and specific failure modes to design against: text-on-image contrast collapse, controls obscuring content, abandoning the 0.4cm gap / 1cm×1cm tap-area guidance. Note that Apple's OWN targets shrank when the material took over — a direct warning for a 76dp-floor app.
- **Apple — 'Meet Liquid Glass' (WWDC25 session 219)** https://developer.apple.com/videos/play/wwdc2025/219/
  - Steal: The edge/lensing idea in the abstract — that a material's craft lives at its boundary, not its fill. Reimplement statically and opaquely. Take nothing else.
- **Braille Institute — Atkinson Hyperlegible Next & Mono (Feb 2025)** https://www.brailleinstitute.org/freefont/
  - Steal: The variable font itself. It's the only way the existing 'weight 500-600' spec is buildable, and its Light→ExtraBold axis makes the ratio-expansion move free. Free, OFL, on Google Fonts.
- **rydmike/squircle_study** https://github.com/rydmike/squircle_study
  - Steal: Empirical, visual Flutter comparison of every squircle ShapeBorder option, with the verdict that ContinuousRectangleBorder is not iOS-grade and figma_squircle@0.6 smoothing is. Saves the founder from shipping the wrong curve — the single most-likely-to-be-gotten-wrong move in this list.
- **flutter/flutter issue #168813 — 'Bring Material 3 Expressive to Flutter'** https://github.com/flutter/flutter/issues/168813
  - Steal: The ground truth that M3E is unshipped and unstaffed, plus the material_ui decoupling context. Watch it, don't wait on it. Pin material_ui ^1.0.0 (Flutter 3.44, 2026-05-16) so framework upgrades can't force design changes.
- **M3 corner radius scale via the material_design Dart package (M3Corners)** https://pub.dev/documentation/material_design/latest/material_design/M3Corners-class.html
  - Steal: The verified 10-step ladder (0/4/8/12/16/20/28/32/48/full) as literal Dart constants — a fetchable mirror of tokens that m3.material.io won't serve to non-JS clients.
- **Liam Spradlin — Design Notes on M3 Expressive** https://design.google/library/design-notes-material-3-expressive-liam-spradlin
  - Steal: 'Expressive can mean quiet. And it can also mean loud.' The framing that resolves this brief's central tension: quiet is not the same as formal, and the founder can have a calm grid AND an expressive product.

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


YOUR DIMENSION: What does mobile design actually look like RIGHT NOW (2025-2026), and what specifically reads as "ten years ago"?

Research with WebSearch/WebFetch. Be concrete and visual, not vibes.

- **iOS 26 "Liquid Glass"** — Apple's 2025 redesign (announced WWDC25). What IS it, concretely? What are the actual material/optical properties (refraction, specular highlights, adaptive tinting, lensing)? What was the reception and the accessibility backlash (legibility complaints, the "Reduce Transparency" fix)? Is it relevant to a Flutter app that deliberately departs from platform defaults? What can be STOLEN from it without the legibility cost?
- **Material 3 Expressive** — Google's 2025 update (announced May 2025 at IO). THIS IS DIRECTLY RELEVANT AND MAY BE THE CENTRAL FINDING: Google did large-scale research (46 studies, 18,000+ participants?) and found expressive design measurably outperformed on speed of element-spotting AND that it worked BETTER for older/low-vision users. VERIFY THOSE NUMBERS AND THAT CLAIM CAREFULLY. What are M3 Expressive's actual mechanics — the shape system (35 shapes?), the new type scale (emphasized styles), color, the spring motion system, "containment", "hero moments"? What is its status in Flutter in 2026 — has Flutter shipped M3 Expressive support? Which parts? (Check Flutter release notes / GitHub issues.)
- **What specifically dates a design to ~2015?** Be concrete and checkable: skeuomorphism? long shadows? flat design 1.0? Material 2's rigid 8dp shadows + FAB + hamburger? bootstrap-y card grids? centered thin-weight type? "corporate memphis" illustration? gradients (which are BACK — how are 2026 gradients different from 2014 gradients)? Give a checkable "if your app has this, it looks old" list.
- **What reads as 2026?** Concrete: shape/corner-radius language, type weight and scale contrast, color (are we in a muted era or a saturated one?), depth (is flat dead? is grain/noise back? is neo-brutalism over?), density, edge treatment, layout (bento grids?), photography vs illustration vs 3D.
- What's the difference between "formal/corporate" design and "creative/expressive" design MECHANICALLY? Name the actual levers, not adjectives.

Be specific enough that a developer could act on it. Name real specs, real numbers, real dates.
````

</details>
