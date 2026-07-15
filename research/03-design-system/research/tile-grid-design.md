# tile-grid-design

> Phase: **research** · Agent `a68059598049b422b` · Run `wf_f237e8a6-694`

## Result

## Summary

The founder's brief and the constraints are not in tension — the constraints are the aesthetic. The single most important reframe: **the tile is a key, not a card.** Cards (Material/dashboard/enterprise) are what produce the 2014 grey grid; keys (MPC pads, monome, Push, keycaps, elevator buttons) are a 40-year-polished tradition of grids you hit fast under pressure, made beautiful through material, precision and light rather than ornament. Everything below follows from switching reference class. Three verified findings do heavy lifting. (1) **Zero-animation is not a sacrifice — it is the measured optimum.** Kaaresoja's Glasgow PhD gives visual-feedback PSS of 32ms and a guideline window of 30–85ms, with perceived quality dropping significantly at 100–150ms; Flutter's `InkSplash` fade is 200ms and its unconfirmed splash is 1 second. Flutter's default button feel is empirically a quality regression for this app. Killing animation makes the buttons *better*, not merely safer. (2) **`ContinuousRectangleBorder` is not a squircle** — it needs its radius multiplied ~2.3529×, degenerates into a "TIE fighter" at high radii, and has broken stroke alignment. `RoundedSuperellipseBorder` (Flutter 3.32.0, May 2025) is the real one and supports Android. (3) **ISO 13850 resolves the STOP tension**: red works because it is *reserved exclusively*, not because it is loud — so a muted red, used nowhere else, is both calm and instantly findable. Saturation was never the mechanism; uniqueness was. On the open questions: the label/vocalization relationship should be expressed as a **headword + quiet ghost line, left-aligned** — the ghost is not clutter, it is the tile's typographic texture, it gives each tile a distinct text silhouette (a free differentiator that survives colorblindness and greyscale), and left-alignment is the cheapest adult/child signal available while also reserving the corner a symbol will later need. Filled colored tiles are **not** the kid signature — Apple Shortcuts is a grid of filled colored tiles that no adult calls childish; the childishness lives in centering, saturation, the 12-hue rainbow, and the vocabulary. Bento is right in principle and wrong as a v1 default (it breaks the editor and shatters at 200% text scale) — but add `row_span`/`col_span` to `grid_slots` today, because the type-to-speak field is already a 3-column cell and that proves you need the mechanism on day one.

### Flutter's ContinuousRectangleBorder is NOT a usable squircle and must not be used; RoundedSuperellipseBorder is the correct API and it supports Android

*Confidence: high, **LOAD-BEARING***

ContinuousRectangleBorder requires its borderRadius to be multiplied by ~2.3529 to approximate an iOS squircle (a cornerRadius of ~10.2 needs a value of ~24), degenerates into an undesired 'TIE fighter' shape at higher radii (and does so EARLIER because of the 2.35x multiplier), and its stroke alignment is broken — it centers strokes regardless of the BorderSide strokeAlign specified. RoundedSuperellipseBorder landed in Flutter stable 3.32.0 (21 May 2025); it is the only shape that matches iOS, maintains continuous curvature at all radii and aspect ratios, correctly implements copyWith/lerp/strokeAlign, and has GPU implementation support so there is no meaningful perf cost vs a rounded rect. Platform support is iOS + Android (falls back to RoundedRectangleBorder on web/desktop) — Android-first is exactly the supported case. Caveat: issue #170593 (BorderSide drawn outside the render box) affected 3.32.1–3.33 and was fixed by PR #171351 — be on a recent stable and visually verify if you draw a hairline border.

- https://github.com/rydmike/squircle_study

- https://flutterawesome.com/a-flutter-study-and-comparision-of-different-squircle-shapeborder-options/

- https://github.com/flutter/flutter/issues/170593

- https://blog.flutter.dev/whats-new-in-flutter-3-32-40c1086bab6e

### Zero animation is the empirically OPTIMAL choice for tile feedback, not an accessibility compromise — and Flutter's default ink splash sits in the measured perceived-quality-drop zone

*Confidence: high, **LOAD-BEARING***

Kaaresoja, 'Latency Guidelines for Touchscreen Virtual Button Feedback' (PhD thesis, University of Glasgow, submitted March 2015; core study published as Kaaresoja, Brewster & Lantz, ACM Transactions on Applied Perception, 2014). Verified from the primary source, Table 4-2: Point of Subjective Simultaneity — visual 32ms, audio 19ms, tactile 5ms. 75% simultaneity thresholds — visual 85ms, audio 80ms, tactile 52ms. Significant drop in perceived quality scores — visual at 100–150ms, audio 70–100ms, tactile 70–100ms. Resulting unimodal guidelines: visual feedback 30–85ms, audio 20–70ms, tactile 5–50ms. Bimodal visual-tactile: visual 100ms, tactile 55ms. Against this: Flutter's ink_splash.dart defines _kSplashFadeDuration = Duration(milliseconds: 200) and _kUnconfirmedSplashDuration = Duration(seconds: 1). A 200ms splash fade is DOUBLE the upper guideline and squarely inside the measured quality-drop band. Note the guideline has a LOWER bound of 30ms because the minimum was set at the PSS — but you do not need to add delay: Android's touch pipeline (~20–40ms) plus one frame (8–16ms) lands you naturally at ~30–55ms, inside the window.

- https://theses.gla.ac.uk/7075/1/2016kaaresojaphd.pdf

- https://dl.acm.org/doi/10.1145/2611387

- https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/ink_splash.dart

### Edge-to-edge is FORCED on Android 16 and cannot be opted out — but this settles nothing about the grid, because the window and the targets are different questions

*Confidence: high, **LOAD-BEARING***

Android 15 (targetSdk 35) enforces edge-to-edge by default but allows opt-out via R.attr#windowOptOutEdgeToEdgeEnforcement (e.g. a values-35 resource dir). For apps targeting Android 16 (targetSdk 36) that attribute is DEPRECATED AND DISABLED — the app cannot opt out. Flutter has targeted Android 15 by default since 3.27 and sets SystemUiMode.edgeToEdge as the default. Resolution: the background PLANE is edge-to-edge (mandatory), the tile grid is inset via SafeArea + margin. These were never the same decision, and the full-bleed-plane/inset-grid composition is also the more beautiful answer — a grid crammed to the bezel reads cheap.

- https://developer.android.com/about/versions/16/behavior-changes-16

- https://medium.com/androiddevelopers/insets-handling-tips-for-android-15s-edge-to-edge-enforcement-872774e8839b

- https://docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge

### Side margins of >=24dp are a HARD constraint, not taste — and gesture-exclusion APIs cannot rescue you

*Confidence: high, **LOAD-BEARING***

Android's left/right back-gesture zones have a default width of 20dp each. Tiles placed in that band will either eat back-gestures or have their taps eaten. Critically: the system imposes a 200dp limit on the VERTICAL extent of exclusions it will honour via setSystemGestureExclusionRects(). A 3x4 grid of ~120dp tiles is ~500dp+ tall, so you CANNOT exclude the grid from back-gestures programmatically — the cap makes it impossible. Margin is the only available solution. Flutter exposes MediaQuery.systemGestureInsets; read it rather than hardcoding 20dp, since OEMs vary and users can adjust back-gesture sensitivity.

- https://medium.com/androiddevelopers/gesture-navigation-handling-gesture-conflicts-8ee9c2665c69

- https://developer.android.com/develop/ui/views/touch-and-input/gestures/gesturenav

- https://api.flutter.dev/flutter/widgets/MediaQueryData/systemGestureInsets.html

### ISO 13850 resolves the STOP colour tension: red is findable because it is RESERVED, not because it is loud — so a muted red satisfies both constraints

*Confidence: high, **LOAD-BEARING***

ISO 13850 requires the emergency-stop actuator be RED on a YELLOW background, and mandates that this red/yellow combination 'shall be reserved exclusively for emergency stop applications.' The standard's stated rationale: the colour scheme ensures high visibility 'even in low-light environments or when an operator is under stress,' and recognition of the colour combination alone is FASTER than recognition of text or symbols — which is why the standard recommends AVOIDING text/symbols on the actuator. It is also shape-coded (mushroom head: palm-operable, physically larger). The transferable insight: the mechanism is exclusivity + two-channel figure/ground coding + shape difference, NOT arousal. Alarm is a property of saturation, motion and sound — none of which this app uses. A large, muted-red, uniquely-shaped bar that is ALWAYS present is furniture, not an alarm; an alarm is something that appears.

- https://machinerysafety101.com/2026/05/18/iso-13850-emergency-stop-requirements/

- https://us.idec.com/RD/safety/law/iso-iec/iso13850

- https://incompliancemag.com/understanding-symbols-emergency-stop/

### Filled, coloured tiles are NOT the kid-AAC signature — Apple Shortcuts refutes it directly, and it is structurally the same product as this app

*Confidence: medium, **LOAD-BEARING***

Shortcuts is a grid of solid-filled, coloured, rounded tiles, each with an icon top-left and a LEFT-ALIGNED label bottom-left, where a short label fronts a hidden multi-step action. That is precisely this app's tile anatomy (label != vocalization) and precisely its surface (a grid of coloured rectangles). It is a mainstream adult productivity product and nobody describes it as childish. Therefore the infantilizing variables are elsewhere: (1) centering everything, (2) high saturation, (3) the 12-different-hues rainbow, (4) the symbol set, (5) the vocabulary — which is exactly what the prior research already concluded ('the enemy is cartoon avatars and parental gates — not saturation'). Fill is exonerated.

- https://www.assistiveware.com/support/proloquo2go/organize/buttons/buttons-actions

### Atkinson Hyperlegible Next (Feb 2025) went from 2 weights to 7 — this is what makes the label/ghost typographic hierarchy possible in a single accessible family

*Confidence: high, **LOAD-BEARING***

Braille Institute released Atkinson Hyperlegible Next and Atkinson Hyperlegible Mono on 10 February 2025, free via Google Fonts and brailleinstitute.org/freefont. Next ships SEVEN weights (ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold), each with upright and italic, plus a variable version, and expands language support from 27 to over 150 languages. This materially changes the typography recommendation: the ORIGINAL Atkinson Hyperlegible's two weights could not carry a label(600)/ghost(400) hierarchy, forcing a mixed-family compromise. Next can. The prior brief's font recommendation was written against the old release.

- https://www.brailleinstitute.org/freefont/

- https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html

- https://pimpmytype.com/font/atkinson-hyperlegible-next/

### Material 3's corner radius scale gives the exact dp ladder; 20dp ('largeIncreased') is the 2026 read for a ~120dp tile

*Confidence: high*

M3 shape scale: none 0dp, extraSmall 4dp, small 8dp, medium 12dp, large 16dp, largeIncreased 20dp, extraLarge 28dp, extraLargeIncreased 32dp, extraExtraLarge 48dp, full (pill). M3 Expressive (2025) added 35 new shapes, a more granular 10-step scale, and built-in shape morphing to the Material Shapes Library and Jetpack Compose. Read on a ~120dp tile: 8dp = Material 1 / 2014; 12–16dp = M3 default card, safe but generic; 20–28dp = current; 48dp/full = lozenge, wastes corner area and shrinks the effective target. Note the shape-morphing half of M3 Expressive is animation and is unavailable to this product — you get Expressive's shape vocabulary, not its motion.

- https://m3.material.io/styles/shape/corner-radius-scale

- https://pub.dev/documentation/material_design/latest/material_design/M3Radius-class.html

- https://supercharge.design/blog/material-3-expressive

### Ableton Push 3 and monome converge on the same answer to 'how do you make a grid of identical rectangles beautiful': neutral material + colour as LIGHT + precision, never pigment or ornament

*Confidence: medium, **LOAD-BEARING***

Push 3: the pads are a 'continuous white square appearance that's easy to spot', firmer than Push 2's 'gummy' feel, with REDUCED gaps and reduced vertical profile; all colour comes from RGB backlighting behind a neutral substrate. monome grid: 'no lettering or labels apart from Monome printed on the underside'; the control surface is 'completely uniform: a matrix of identical, anonymous, back-lit buttons'; silicone rubber set into an aluminium faceplate, walnut body treated with teak oil, hand-made. monome made the 8x8 grid the dominant interface for sampling/sequencing with zero decoration. The transferable principle: the tile's identity is its MATERIAL; the hue is its STATE. This is the direct answer to the founder's brief — beauty from exactness, not from adding things.

- https://monome.org/docs/grid/

- https://cdm.link/2014/06/watch-wonders-grids-monome-makers-defend-minimal-design/

- https://cdm.link/new-ableton-push/

- https://www.soundonsound.com/reviews/ableton-push-3

### Teenage Engineering's method is literally 'restrict the palette and give every colour a fixed meaning' — and it costs nothing to copy

*Confidence: high, **LOAD-BEARING***

Jesper Kouthoofd, direct quotes (SFMOMA): 'I set up restrictions when I design. I always work with simple geometric shapes, RAL colors — which is a 40-color scale — and try to adhere to German industrial standards.' On why RAL over Pantone: choosing from only two blues creates 'efficiency in the process and the expression.' On semantics: 'I connect colors to a meaning and then apply that to all products. If it's orange or red, it means recording.' He also systematically pairs colour with shape (triangles yellow, squares blue, circles red) to build 'this universal understanding about color and shapes.' And on typography: teenage engineering 'don't use capital letters and only write in lower case. It's democratic — why should certain words have more meaning.' Every one of these is a zero-implementation-cost decision that reads as craft.

- https://www.sfmoma.org/read/stay-curious-stay-naive-an-interview-with-teenage-engineering-jesper-kouthoofd/

- https://blakecrosley.com/guides/design/teenage-engineering

### The dominant 2025-26 design signature (Liquid Glass) is a trap this app must explicitly reject — and rejecting it is the more current move, not the more conservative one

*Confidence: high, **LOAD-BEARING***

NN/g ('Liquid Glass Is Cracked, and Usability Suffers in iOS 26') identifies transparency as the core defect: 'anything placed on top of something else becomes harder to see'; text over images has too-low contrast; content becomes 'camouflaged.' They separately criticise controls that 'appear, vanish, collapse, and expand depending on context' and cite the Microsoft Office adaptive-menus precedent: 'People hated them because nothing stayed where you left it' — which is independent, non-clinical corroboration of this app's fixed-position rule. Reports note Increase Contrast and Reduce Motion are insufficiently implemented in iOS 26 vs prior releases, and Reduce Transparency does not fully eliminate translucency. Practical rule for this app: NO translucency, NO blur, NO backdrop filters, NO context-dependent chrome. Opacity is a contrast bug in a product whose users are selected for sensory and visual sensitivity. By 2026 the backlash is itself the trend — a confidently opaque, materially precise surface reads MORE current than a glass imitation.

- https://www.nngroup.com/articles/liquid-glass/

- https://osxdaily.com/2025/09/17/tips-improve-liquid-glass-ios-26-look-legibility-iphone-ipad/

### The popular 'rounded corners are processed faster / are easier on the eyes' claims are design-blog folklore; the real underlying citation supports a different and better argument

*Confidence: medium*

Claims like 'a button with rounded corners is processed milliseconds faster' and 'the fovea processes circular shapes more efficiently' circulate widely across design blogs with no primary source and should not be cited. The genuine research is Bar & Neta (2006), 'Humans Prefer Curved Visual Objects', Psychological Science 17:645-648, plus Bar & Neta (2007), 'Visual elements of subjective preference modulate amygdala activation', Neuropsychologia 45:2191-2200. The actual finding is about PREFERENCE and THREAT: sharp contour transitions convey a sense of threat and trigger a negative bias. That is a materially better argument for this specific app than a speed claim — in a trauma-informed product for sensitized nervous systems, 'sharp contours read as threat' is directly on-brief. Use generous radii for that reason; do not repeat the processing-speed folklore.

- https://journals.sagepub.com/doi/10.1111/j.1467-9280.2006.01759.x

- https://www.semanticscholar.org/paper/Humans-Prefer-Curved-Visual-Objects-Bar-Neta/52b1c06824f96a513c7e9b0f4fed1289b566c028

### The bento-grid evidence base is marketing content, not research — adopt it for compositional reasons or not at all

*Confidence: medium*

Searches for bento grid guidance return near-exclusively SEO/agency blog content with circular sourcing and unverifiable statistics (e.g. an unsourced '67% of the top 100 SaaS products on ProductHunt now use this modular layout system' claim). There is no usability research behind the trend. What IS defensible without any of that literature: size is a pre-attentive visual variable, and Fitts's law means a larger target is faster to acquire and more tolerant of motor imprecision — which is a genuine argument for making the most urgent phrase physically bigger. Make the bento decision on those grounds and on composition; do not cite the trend pieces, and do not let '67%' near the pitch.

- https://www.saasframe.io/blog/designing-bento-grids-that-actually-work-a-2026-practical-guide

- https://www.galaxyux.studio/blog/bento-grids-the-new-standard-for-modular-ui-design/

### label != vocalization exists in mainstream AAC but is only ever an EDITOR capability — no product expresses the relationship in the tile's visual design

*Confidence: medium, **LOAD-BEARING***

Proloquo2Go lets you edit the word or message spoken for any button so the displayed label can differ from spoken output, and has a 'Speak Text Immediately' behaviour that speaks without adding to the message window; CoughDrop similarly allows vocalization output separate from button labels. In both, this is a configuration field buried in a button-editing sheet. The rendered button shows only the label; the hidden sentence is invisible at the surface. This is an unoccupied design space, and it matters here more than it does for those products because this app's tiles are WHOLE UTTERANCES fired at strangers — a misfire has real social cost, which is exactly why the prior research already elevated Repair to a permanent primitive. If misfires are common enough to warrant a dedicated repair tile, the tile should help prevent them.

- https://www.assistiveware.com/support/proloquo2go/organize/buttons/buttons-actions

- https://www.assistiveware.com/support/proloquo2go/speech/buttons-speak-tap

- https://coughdrop.zendesk.com/hc/en-us/articles/360033463672-How-can-I-use-CoughDrop-s-vocalization-box-sentence-composition-features-in-speak-mode

### Your own high-contrast theme is the proof that colour cannot be the primary differentiator

*Confidence: high, **LOAD-BEARING***

The constraint set requires a switchable high-contrast theme. A high-contrast theme necessarily flattens or eliminates a low-chroma category palette. If colour were the load-bearing channel for finding 'I need to leave' among 12 tiles, then enabling high-contrast mode would destroy findability for the users who need it most — an accessibility feature would break the core interaction. Combined with ~8% of men having colour vision deficiency, this forces the ranking: position (survives everything) > size (survives greyscale, CVD, text scale) > text silhouette (free, comes with the type design) > colour accent (supplementary only, never sole channel) > type weight (too weak to rely on). Rule: colour must always be redundant with a non-colour channel.

## Design moves

- **Switch reference class: the tile is a KEY, not a CARD. Ban Card, Material elevation, and drop shadows from the tile entirely. The tile is a flat, opaque, precisely-cut surface sitting on a recessed plane.**
  - Why: Cards are what produce the 2014 enterprise grid — shadow + rounded rect + centered content IS the failure mode the founder described. Keys (MPC, monome, Push, keycaps) are a polished 40-year tradition of grids hit fast under pressure that are beautiful through material and precision rather than ornament. monome's grid has literally zero labels and is one of the most beloved objects in music. Changing the reference class resolves most downstream decisions for free.
  - Risk: Flat opaque tiles on a flat plane can read as low-affordance. Mitigate with a real luminance step between plane and tile (not a shadow), and with the pressed-state flood. Do NOT reintroduce elevation to solve this — elevation overlays are M2 thinking and M3 replaced them with tone-based surface containers.
- **Left-align everything. Label top-left or bottom-left, never centered. Ragged right.**
  - Why: This is the single cheapest and highest-yield adult/child signal in the product, and it costs one line. Centered type reads as 'caption for a picture' — the kid-AAC signature. Left-aligned type reads as 'text for a reader' and creates a strong vertical rule down each grid column, which is what makes a grid look composed. Apple Shortcuts (icon top-left, label bottom-left) is the proof from a mainstream adult product. It ALSO makes the future symbol addition free — a centered label has nowhere to put a symbol later without recomposing the tile; a bottom-left label leaves the top-right corner open by construction.
  - Risk: Long single-word labels look slightly less 'balanced' than centered. That is the correct trade. Verify with RTL locales — use TextAlign.start and EdgeInsetsDirectional, never TextAlign.left/EdgeInsets, so RTL mirrors correctly.
- **Tile anatomy: headword + ghost. Label in ~20pt/weight 600 at the top-left; the vocalization beneath it in ~13pt/weight 400 at ~55-60% opacity, clamped to 2 lines with maxLines + TextOverflow.ellipsis. The ghost is the FIRST thing dropped as text scale increases (hide it above ~130% textScaleFactor).**
  - Why: This is the answer to the brief's central open question. The ghost is not clutter — it is the tile's typographic texture. At a glance it reads as a quiet grey band; up close it is readable. Three payoffs: (1) it lets the user VERIFY what they are about to say to a stranger, which matters because these tiles fire whole utterances with real social cost — the prior research already conceded misfires are common enough to warrant a permanent Repair tile; (2) it gives every tile a distinct TEXT SILHOUETTE, a free differentiator that survives greyscale, colour-blindness and high-contrast mode; (3) hierarchy is what typographic beauty IS — one word centered in a box is a 2014 button, a headword with a quiet second line is a designed object. Atkinson Hyperlegible Next's 7 weights (Feb 2025) make the 600/400 pairing possible in one accessible family, which the original 2-weight release could not.
  - Risk: Real conflict with sensory load and with degraded reading in shutdown. Mitigate: ship it as a setting defaulting ON, and make it the first casualty of text scaling — at 200% the tile must show ONLY the label, and the ghost must not compete for space. Also: when the label and vocalization are identical (the common default-set case), render NO ghost — a duplicated line is pure noise. That single conditional prevents most of the clutter risk.
- **Fill strategy: neutral tinted substrate + a reserved 4dp accent rule. The tile is an M3 surfaceContainer tinted only ~4-8% toward its category hue; the hue itself appears as a small saturated accent (a 4dp bar on the leading edge, or a short rule under the label) occupying <2% of tile area.**
  - Why: This separates saturation from contrast exactly as the constraints demand, and it is the Push 3 move: the pad substrate is neutral white; all colour is LIGHT applied on top. Label contrast stays onSurface at near-full ratio across all 12 tiles because the fill barely moves — you never fight per-hue contrast. Meanwhile a small vivid accent gives instant colour findability with essentially zero sensory area. This is also ISO 13850's logic (small reserved colour, high findability). Outline-only tiles are rejected: thin low-contrast borders are worst-case for low vision, an outlined 76dp target reads as disabled, and outlines make the empty-slot problem unsolvable because an empty slot then looks identical to a tile.
  - Risk: A 4dp accent may be too small to find pre-attentively at arm's length. Test at 4/6/8dp. If it fails, widen the accent rather than saturating the fill. And per the high-contrast-theme finding, the accent MUST be redundant — it can never be the only way to find a tile.
- **Pressed state = the accent floods the tile. On pointer-down, the fill jumps instantly to the full-strength category accent and the label flips to the on-accent colour. No interpolation, no splash, no ripple. Zero duration.**
  - Why: This is the MPC/Push 'the pad lights up' moment, and it is the most delightful thing in the app for zero cost — it uses a colour you already defined and adds no tokens. The accent stripe at rest is a promise; the press is the payoff. It is unmistakable, works identically in light/dark/high-contrast, and is legible at any text scale. Crucially, Kaaresoja's data says this is not merely acceptable but OPTIMAL: visual PSS is 32ms with a 30-85ms guideline window, while Flutter's InkSplash fade is 200ms — deep in the measured 100-150ms perceived-quality-drop band. The zero-animation constraint and the best-feeling-button goal are the same goal.
  - Risk: A full-tile colour flood is a large, sudden luminance change — precisely what distress-informed guidance warns about. Mitigate by matching the flooded state's LUMINANCE to the resting state as closely as possible (change chroma, hold lightness). That gives an unmistakable hue shift with minimal luminance shock, and it is the same 'saturation and contrast are separable' lever already established. Test this specifically with the low-stimulus mode ON — it may need to degrade to a simple border-weight change.
- **Latch the lit state to the speech, not the touch: the tile stays flooded for as long as TTS is speaking, then returns. Minimum hold ~100ms so a fast tap is never imperceptible.**
  - Why: This converts decoration into a functional state readout the app needs anyway — 'which tile is currently talking?' — and it gives STOP a referent: the lit tile is the thing STOP stops. It exactly matches the drum-machine metaphor (lit pad = playing). It is free: you already have TTS start/completion handlers. And the min-hold is a floor on visibility, not an animation — no interpolation is involved, so it does not violate the zero-motion rule.
  - Risk: flutter_tts completion-handler reliability varies by platform and can leave a tile stuck lit if a handler never fires. Guard with a timeout that force-clears the state. Also ensure the lit state is exposed to screen readers via Semantics, not by colour alone.
- **Fire feedback in this exact code order on Listener.onPointerDown (NOT onTap): haptic -> setState(pressed) -> TTS.**
  - Why: Directly implements Kaaresoja's measured windows, which are tightest for touch (tactile 5-50ms, PSS 5ms), looser for visual (30-85ms, PSS 32ms), and middling for audio (20-70ms). The ordering falls straight out of the data. onTap is the trap: it fires on pointer UP, delaying all feedback by the entire press duration and blowing every window. Using onPointerDown plus Android's native touch pipeline (~20-40ms) plus one frame (8-16ms) lands visual feedback at ~30-55ms — inside the window with no artificial delay added.
  - Risk: onPointerDown fires before gesture disambiguation, so a scroll or an accidental graze could speak. This grid does not scroll, which removes most of the risk — but it makes 'the grid must never scroll' load-bearing rather than aesthetic. If the grid ever needs to scroll at large text sizes, this decision must be revisited. Also honor MediaQuery.disableAnimationsOf and set ThemeData(splashFactory: NoSplash.splashFactory) globally so no Material descendant sneaks a 200ms splash back in.
- **Corner radius: 20dp on a ~112-120dp tile (M3 'largeIncreased'), rendered with RoundedSuperellipseBorder. Never ContinuousRectangleBorder.**
  - Why: Radius:size of roughly 1:6 reads 2026; 8dp reads 2014, 12-16dp reads generic M3 card, 48dp/pill wastes corner area and shrinks the effective target. The superellipse is the cheapest craft signal available — one shape constructor — and the corner is the most-repeated form in a product that IS twelve rectangles. The brief asked to verify: ContinuousRectangleBorder is NOT a squircle (needs radius x2.3529, degenerates into a 'TIE fighter', broken strokeAlign). RoundedSuperellipseBorder (3.32.0, May 2025) is real, is GPU-accelerated, and supports Android.
  - Risk: The visual delta vs a plain rounded rect at this size is ~1-2px — genuinely subtle. This is polish, not load-bearing; do not block the MVP on it, and do not let it become a yak-shave. Also check Flutter version against issue #170593 (BorderSide painted outside the render box, 3.32.1-3.33, fixed in PR #171351) if you draw any hairline on the tile.
- **Grid geometry: background plane bleeds full edge-to-edge under status and nav bars; grid inset by SafeArea + >=24dp horizontal margin; 12dp gaps; no dividers, no hairlines between tiles.**
  - Why: Resolves the brief's edge-to-edge-vs-thumb-reach tension by observing they are different questions: the WINDOW is edge-to-edge (mandatory — Android 16 removed the opt-out entirely), the TARGETS are inset. The 24dp margin is forced, not chosen: back-gesture zones are 20dp per side, and setSystemGestureExclusionRects cannot save you because the system caps exclusions at 200dp of vertical extent while the grid is 500dp+ tall. Dividers are rejected — they read 2014 and turn keys into a spreadsheet. The gap IS the design: it is what makes the grid read as discrete keys. Nice detail worth being deliberate about: at 20dp radius and 12dp gap, the negative space where four tiles meet forms a small four-pointed star — that recurring shape is a real compositional element, so pick the ratio on purpose (gap ~= 0.6-0.8x radius).
  - Risk: Read MediaQuery.systemGestureInsets rather than hardcoding 20dp — OEMs vary and users can raise back-gesture sensitivity. Also verify the plane's colour behind the nav bar in all three themes; a mismatched system bar scrim is the classic edge-to-edge tell.
- **Make the type-to-speak field the 13th cell — same grid, same radius, same material, spanning 3 columns — and put it at the TOP, above the tiles.**
  - Why: This is the answer to 'two apps stapled together': the field is not an input bolted onto a grid, it is the grid cell that is blank because you fill it. And the position is principled rather than aesthetic — the constraints reserve the lower-center thumb arc for the highest-value targets, and typing is the LOWEST-urgency action in the product because the ability to type implies more capacity than the ability to tap. Tiles are for crisis; typing is for when you are okay. So typing earns the worst position. This also forces the span mechanism into existence on day one, which is exactly the point of the next move.
  - Risk: Must NOT autofocus — a keyboard covering the grid at cold launch would be catastrophic for the core use case. Raising the keyboard will cover the tiles; that is acceptable because the user chose that mode, but ensure the grid is not resized/reflowed by the keyboard insets (use resizeToAvoidBottomInset: false or equivalent) since reflow would violate the fixed-position guarantee.
- **Add `row_span INT NOT NULL DEFAULT 1` and `col_span INT NOT NULL DEFAULT 1` to `grid_slots` TODAY. Ship uniform 3x4 as the default; offer bento as a named layout PRESET later.**
  - Why: This is the highest-leverage cheap decision in the report. Bento is right in principle — size is pre-attentive, survives greyscale/CVD/text-scaling, and per Fitts's law a bigger target is faster and more forgiving of motor imprecision, so the most urgent phrase SHOULD be physically bigger. It is also the single biggest 'this was designed' signal available, since a uniform grid of identical rectangles is inherently generic. But it is wrong as a v1 DEFAULT for two reasons the trend pieces never mention: (1) it breaks the editor — size becomes a property of the SLOT while the user's mental model is about the PHRASE, so moving a long phrase into a small slot truncates it; (2) it shatters at 200% text scale — a uniform grid degrades uniformly, a bento grid fails catastrophically at its smallest cell. Two integer columns now costs nothing; a migration on user-authored content later is a data-loss risk on someone's voice. And you need spans immediately anyway for the 3-column type field.
  - Risk: Spans plus the fixed-position guarantee need care: the editor must never allow a span that would overlap an occupied slot or overflow the grid. Enforce in the schema/repository, not in UI code. Also every bento preset must be validated at 200% text scale before shipping — if the smallest cell cannot hold a 2-word label at 200%, the preset is invalid.
- **Empty (NULL) slot = the recessed plane showing through. No fill, no border, no ripple, no touch target, and NO semantics node at all.**
  - Why: Answers both halves of the brief's question. Aesthetically it is not a hole and not broken — it is a socket with nothing installed, which is precisely and honestly what it is; this is the monome/keycap logic and it requires the plane to be a visible material rather than an absence, which the raised-tile-on-recessed-plane strategy already gives you. Functionally: excluding it from the semantics tree entirely (not merely disabling it) means Switch Access and TalkBack skip it rather than burning a scan step on nothing — which matters enormously for switch users, where every wasted step is real time. An outlined empty slot would fail both tests at once: it looks like a broken or disabled tile AND it invites a tap.
  - Risk: An entirely invisible slot could make the grid look accidentally sparse or make users think tiles vanished. Consider a 1-2% luminance inset to read as a recess. And in EDIT mode the empty slot MUST become a real target with a '+' and full semantics — different mode, different rules. Make sure the semantics exclusion is mode-dependent, or the editor becomes unusable via switch access.
- **STOP: reserve red absolutely. Red appears NOWHERE else in the product — not as a category hue, not in errors, not in edit mode. Because it is exclusive, desaturate it hard (muted brick/oxblood at high luminance contrast). Differentiate by SHAPE too: STOP is full-width and not tile-shaped, sitting on its own distinct plinth so it is a figure/ground PAIR rather than a single colour. It is always present and never changes.**
  - Why: ISO 13850 gives the mechanism and it is not the one people assume: the standard mandates red-on-yellow and mandates that the combination 'shall be reserved exclusively' — the exclusivity does the work. It is recognizable 'under stress' and in low light, and the standard notes colour-combination recognition is FASTER than reading text or symbols. So findability comes from uniqueness + two-channel coding + shape, not from arousal. That fully resolves the brief's tension: alarm is a property of saturation, motion and sound, none of which this app uses. And permanence is what makes it calm — a thing that is always there is furniture; an alarm is something that APPEARS. The calmest possible STOP is one that never changes.
  - Risk: Do NOT copy the literal yellow surround — yellow-on-red at full saturation is a sensory assault and wrong for this audience. Steal the PRINCIPLE (a reserved figure/ground pair), not the hex. Also, unlike a trained factory operator the user is untrained, so keep the word STOP — just do not rely on it. Verify the muted red still passes contrast in all three themes, and confirm the reserved-red rule holds in the high-contrast theme, which is where a palette most wants to collapse hues together.
- **Adopt a Teenage Engineering-style palette contract: pick exactly 5 hues, assign each a fixed MEANING, and never use them for anything else. Red = STOP (only). Amber = repair/correction (only). The remaining 3 = tile category accents.**
  - Why: Direct steal from Kouthoofd: 'I connect colors to a meaning and then apply that to all products. If it's orange or red, it means recording.' He restricts to RAL's 40-colour scale specifically because having only two blues creates 'efficiency in the process and the expression.' The discipline of 'this colour means this, everywhere, always' is most of what makes TE's work look designed, and it costs zero implementation. It also satisfies the ~2-5 intentional hues constraint by construction rather than by willpower, and it makes the reserved-red STOP rule a consequence of the system rather than a special case.
  - Risk: 3 category hues across 12 tiles means ~4 tiles share each hue — colour alone cannot identify a tile. That is fine and in fact correct given the high-contrast-theme finding (colour must always be redundant), but it means position and size must carry the real load. Do not solve it by adding hues.
- **All app chrome is lowercase. 'stop' is the only exception — the single capitalized word in the entire product.**
  - Why: Steal from TE: 'we don't use capital letters and only write in lower case. It's democratic — why should certain words have more meaning.' For a product whose entire wedge is dignity and non-infantilization, lowercase chrome is a precise register: calm, current, adult-indie rather than clinical, and it removes the shouting/institutional tone that AAC apps default to. Then STOP in caps becomes the one thing in the app permitted to shout — typography doing semantic work, and the exception proving the system exists. This is exactly the kind of cheap, opinionated craft detail the founder is asking for.
  - Risk: Apply lowercase ONLY to the app's own chrome, never to user-authored content. Force-lowercasing a user's own phrases would be presumptuous — the precise flavour of condescension this product exists to avoid. Render user content exactly as typed. Also never implement this with a text transform on labels; it must be authored lowercase in the string table, or you will eventually lowercase someone's name.
- **Ban translucency, blur, and backdrop filters outright. The surface is opaque at every layer.**
  - Why: The dominant 2025-26 platform signature is Liquid Glass, and NN/g's assessment is that its core premise fails: 'anything placed on top of something else becomes harder to see,' with content becoming 'camouflaged.' For an audience selected for sensory and visual sensitivity, opacity is a contrast bug. Rejecting it is not the conservative choice in 2026 — the backlash is itself the trend, and a confidently opaque, materially precise surface (monome, TE, Braun) reads more current and more crafted than a glass imitation. NN/g's criticism of chrome that 'appears, vanishes, collapses and expands' plus the Microsoft adaptive-menus precedent ('people hated them because nothing stayed where you left it') is also free, non-clinical, mainstream corroboration of the fixed-position rule — worth citing to skeptics who dismiss the AAC literature as pediatric.
  - Risk: None for this product. The only cost is that the app will not look like iOS 26 — which is the intent, and the app is Android-first regardless.

## References

- **Apple Shortcuts** https://support.apple.com/guide/shortcuts/welcome/ios
  - Steal: THE closest mainstream analogue and the most important reference here — structurally identical to this app: a grid of filled, coloured, rounded tiles where a short label fronts a hidden multi-step action. Steal the entire tile anatomy (icon top-left, label bottom-left, LEFT-ALIGNED, never centered) and the restrained-but-coloured fill. It single-handedly refutes 'filled colour tiles are the kid-AAC signature' — it is an adult productivity product and nobody calls it childish. Proves the childishness lives in centering, saturation, the rainbow, the symbol set, and the vocabulary — not in the fill.
- **monome grid** https://monome.org/docs/grid/
  - Steal: The answer to 'how do you make 12 identical rectangles beautiful': make them EXACT. No lettering or labels anywhere on the device; a completely uniform matrix of identical, anonymous backlit silicone buttons in an aluminium faceplate. Beauty from material, precision and restraint — zero ornament. Steal the conviction that a grid of anonymous rectangles needs nothing added to be one of the most beloved objects in its field.
- **Ableton Push 3** https://www.ableton.com/en/push/
  - Steal: Neutral substrate + colour as LIGHT. The pads are a continuous white square; every colour is RGB backlighting behind neutral material, never pigment. Push 3 also deliberately REDUCED the gaps and the pads' vertical profile vs Push 2 and made them firmer — an explicit, shipped judgment that tighter and crisper beats squishier for fast, accurate hits under pressure. Directly informs 'tile substrate is neutral, hue is state' and the pressed-state flood.
- **Akai MPC (Roger Linn)** https://en.wikipedia.org/wiki/Akai_MPC
  - Steal: The 4x4 pad grid — the original 'grid of pads you hit fast under pressure', and the layout that became the industry standard across manufacturers. Linn's stated intent was an intuitive instrument that was explicitly NOT 'an enormous, stationary mixing panel with as many buttons as an airplane cockpit' — i.e. the fixed small grid is the feature. Steal the premise: a small fixed grid of large uniform pads, learned by position, is a 40-year-validated interface for speed under pressure.
- **Teenage Engineering (Jesper Kouthoofd)** https://www.sfmoma.org/read/stay-curious-stay-naive-an-interview-with-teenage-engineering-jesper-kouthoofd/
  - Steal: The method, verbatim and free: restrict to a small fixed palette (he uses RAL's 40-colour scale over Pantone precisely because 'only two blues' creates 'efficiency in the process and the expression'); give every colour a fixed meaning applied across everything ('if it's orange or red, it means recording'); simple geometric shapes; and lowercase-only text ('it's democratic — why should certain words have more meaning'). Every one of these is a zero-cost decision that reads as craft. This is the most directly copyable reference in the list.
- **ISO 13850 (emergency stop) / IDEC + Rockwell e-stop design literature** https://us.idec.com/RD/safety/law/iso-iec/iso13850
  - Steal: The reserved-colour mechanism. Red actuator on yellow ground, with the combination 'reserved exclusively' for e-stop; recognizable under stress and in low light; colour-combination recognition is faster than reading text or symbols; shape-coded (mushroom = palm-operable, larger). Steal the logic — exclusivity + figure/ground pair + shape difference — and NOT the saturated hex. This is what lets STOP be muted AND instantly findable.
- **Elgato Stream Deck** https://www.elgato.com/ww/en/p/stream-deck
  - Steal: A grid of LCD keys where a short label fronts a hidden action and the key face carries live state (Mic On green / Mic Off red). Also the muscle-memory argument from a completely non-clinical source: 'if your mic mute is always in the bottom-left corner of every profile, you'll build muscle memory' — useful corroboration of fixed positions for reviewers who dismiss the AAC pediatric literature. Steal state-on-the-key-face.
- **Atkinson Hyperlegible Next + Mono (Braille Institute, 10 Feb 2025)** https://www.brailleinstitute.org/freefont/
  - Steal: Use Next, not the original. 7 weights + italics + variable + 150 languages (up from 2 weights / 27 languages), free on Google Fonts under OFL. The weight expansion is what makes the label(600)/ghost(400) hierarchy possible inside one accessible family — the original's 2 weights could not carry it. The Mono cut is a genuine option for the type-to-speak field if you want the TE register.
- **Material 3 corner radius scale + M3 Expressive** https://m3.material.io/styles/shape/corner-radius-scale
  - Steal: The exact dp ladder (0/4/8/12/16/20/28/32/48/full) and 'largeIncreased' = 20dp as the 2026 read for a ~120dp tile. Steal M3 Expressive's shape vocabulary and its tone-based surface containers (which replaced M2's elevation overlays); ignore its shape-morphing and motion half, which this product cannot use.
- **rydmike/squircle_study** https://github.com/rydmike/squircle_study
  - Steal: The empirical comparison that settles the brief's squircle question. Documents ContinuousRectangleBorder's 2.3529x radius fudge, its 'TIE fighter' degeneration, and its broken strokeAlign, versus RoundedSuperellipseBorder (Flutter 3.32.0) as the only correct, GPU-accelerated, all-aspect-ratio option. Read it before writing the tile's ShapeBorder.
- **Kaaresoja, 'Latency Guidelines for Touchscreen Virtual Button Feedback' (PhD, Univ. of Glasgow, 2015) + Kaaresoja/Brewster/Lantz, ACM TAP 2014** https://theses.gla.ac.uk/7075/1/2016kaaresojaphd.pdf
  - Steal: The numbers that turn 'zero animation' from a constraint into a selling point. Table 4-2: PSS visual 32ms / audio 19ms / tactile 5ms; guidelines visual 30-85ms, audio 20-70ms, tactile 5-50ms; perceived quality drops significantly for visual at 100-150ms. Compare against Flutter's _kSplashFadeDuration = 200ms. Cite this when anyone claims the app feels 'unpolished' without ripples.
- **NN/g, 'Liquid Glass Is Cracked, and Usability Suffers in iOS 26'** https://www.nngroup.com/articles/liquid-glass/
  - Steal: The argument for rejecting the dominant 2026 platform aesthetic, from a source founders respect. Also its Microsoft adaptive-menus precedent — 'people hated them because nothing stayed where you left it' — which is free mainstream corroboration of the fixed-position rule.
- **Bar & Neta (2006), 'Humans Prefer Curved Visual Objects', Psychological Science 17:645-648** https://journals.sagepub.com/doi/10.1111/j.1467-9280.2006.01759.x
  - Steal: The real citation behind the rounded-corner folklore. The finding is about preference and threat — sharp contour transitions convey threat and trigger a negative bias — not processing speed. That is a much better argument for generous radii in a trauma-informed product than the 'processed milliseconds faster' claim the design blogs repeat. Use this one; discard the folklore.

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


YOUR DIMENSION: The tile and the grid — the entire product surface. 12 rectangles. Make them beautiful.

This is the crux. The whole app IS a grid of phrase tiles. Everything else is secondary. Reason hard and research widely.

- **What IS a tile here?** It holds a label (what it shows) that differs from its vocalization (what it speaks) — e.g. shows "Overwhelmed", speaks "I need to leave, I'm not able to talk right now." Does the design express that relationship? Should the tile hint at its hidden sentence, or is that clutter? THIS IS A GENUINELY INTERESTING DESIGN PROBLEM — go at it.
- **Tile anatomy**: shape, corner radius (what radius reads 2026 vs 2015? is the superellipse/squircle worth it — and is `ContinuousRectangleBorder` in Flutter actually a squircle or a poor approximation? VERIFY), fill vs outline vs both, border/hairline treatment, internal padding, label position (centered? bottom-left like a book?), optical balance, how a symbol would later coexist with the label.
- **Fill strategy**: solid color tiles? tinted surfaces? outlined? What does each communicate? Solid colored tiles are the kid-AAC signature — is that fair, or is the childishness in the SATURATION and the rainbow, not the fill? Can a filled tile be adult? (Argue with examples.)
- **Differentiating 12 tiles**: how does a user find "I need to leave" instantly? Color? Position alone? Type weight? Size variation (can tiles be different sizes — a bento/mosaic grid — while positions stay FIXED? That's allowed by the constraints and might be the single best move: a spatial hierarchy where the most urgent phrase is physically bigger)? Investigate the bento grid idea seriously.
- **The grid itself**: gaps vs dividers vs bleeding to the edge, margins, does the grid touch the screen edges (edge-to-edge is a 2026 signature — but tiles at the very edge conflict with thumb-reach findings; resolve it), safe areas, gesture insets.
- **State**: pressed/active feedback WITHOUT animation — what does a tile look like the instant it's tapped? (This matters enormously: no animation means the feedback must be instantaneous and static. Is that a limitation or an opportunity?) Focus state for Switch Control/keyboard. Disabled? Hidden slots (the schema allows NULL slots — what does an EMPTY slot look like? A hole? Nothing? This is an aesthetic AND functional question — an empty slot must not look broken, and must not invite a tap).
- **The type-to-speak field** sharing the surface with the grid: how do you compose a text input and a tile grid on one screen without it looking like two apps stapled together?
- **STOP and the repair tile**: always visible, larger than a tile, must read as urgent without being alarming. How? (Red = alarm = the wrong register for a calm app? But STOP must be findable instantly. Resolve this tension.)
- Research real references: what do beautiful grid interfaces look like? (Soundboards, drum machines/MPC pads, Teenage Engineering, Ableton Push, keyboard/keycap design, Launchpad, elevator/keypad design, tile-based dashboards, bento grids, Apple's Shortcuts, iOS Home Screen widgets.) **Drum machines and MPC pads are the closest functional analogue to this app that anyone has ever polished** — a grid of pads you hit fast under pressure, designed to be beautiful and instantly locatable. Go deep on what they do.

Return concrete specs and real reference products with what to steal.
````

</details>
