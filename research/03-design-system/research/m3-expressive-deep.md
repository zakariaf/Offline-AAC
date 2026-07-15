# m3-expressive-deep

> Phase: **research** · Agent `a442c5ec767b5bb8e` · Run `wf_f237e8a6-694`

## Result

## Summary

The headline is negative and it is liberating: M3 Expressive does not exist in Flutter and will not soon. The umbrella issue (flutter/flutter#168813, opened 2025-05-14) went on "strategic pause" 2025-06-10 with the team stating they are "not actively developing Material 3 Expressive right now" and refusing contributions. Then it got deferred again by an architectural earthquake: since 2026-04-07 the Material library is FROZEN in flutter/flutter (#184093), migrating to a standalone material_ui pub package — today at v0.0.1 with a "Coming soon" README. All 15 expressive components, motion-physics, emphasized typography, the 35-shape library and vibrant schemes are unimplemented. "Adopt M3 Expressive" is not a decision available to a solo dev in July 2026. This barely matters, because the parts worth stealing were never the parts Flutter is missing. M3E's color system is essentially unchanged from M3 baseline — ColorScheme.fromSeed is still the mechanism, and Flutter ALREADY ships the two things this app most needs: DynamicSchemeVariant (9 variants) and contrastLevel (-1.0..1.0, where 0.5=medium and 1.0=high per Material guideline), making the mandated three-theme one-tap switcher nearly a one-parameter change. "Emphasized" type is just a weight step — a FontWeight constant, not a package. The corner-radius scale is public and free to copy. On the research claim: I expected marketing and found an actual peer-reviewed CHI 2026 full paper (Bentley et al., "Usability Hasn't Peaked", DOI 10.1145/3772318.3790373) — but its real numbers are 33% faster fixation and 20% faster task completion at n=48, not the "up to four times faster" Google's marketing repeats. The 4x is a cherry-picked best case (finding a Send button), and the "erasure of age effects" claim has no published numbers at all. Do not let a 4x claim justify a design direction; the honest number is 33%, and the paper's own causal story — bigger targets, stronger color differentiation, back-to-fundamentals — is something this app already does for other reasons. Verdict: steal the shape scale and the color/contrast API, ignore the components and motion, do not wait for material_ui, and build tiles on raw primitives while keeping Material for chrome.

### M3 Expressive is NOT implemented in Flutter, is not being worked on, and contributions are refused. This is the load-bearing fact of the whole dimension.

*Confidence: high, **LOAD-BEARING***

Umbrella issue flutter/flutter#168813 opened 2025-05-14. On 2025-06-10 the team announced a 'strategic pause': 'we are not actively developing Material 3 Expressive right now', wanting a 'consistent design pattern and planned rollout'. Unimplemented: all 15 components (button groups, FAB menu, loading indicator, split button, toolbars, updated app bars/carousel/buttons/extended FAB/icon buttons/nav bar/rail/progress indicators) AND all expressive styles (motion-physics system, emphasized typography, the 35-shape expanded library, vibrant color schemes). No Flutter version number or milestone has ever been attached. Flutter's team communicated early specifically 'so that someone does not spend a bunch of their time crafting a big PR that won't be accepted'.

- https://github.com/flutter/flutter/issues/168813

### The Material library is frozen and being extracted from the Flutter SDK — the reason M3E work stalled, and a live migration risk for any app starting today.

*Confidence: high, **LOAD-BEARING***

flutter/flutter#184093: as of 2026-04-07 (the 3.44 cutoff) all contributions to Material and Cupertino in flutter/flutter are frozen. Canonical home becomes two pub.dev packages, material_ui and cupertino_ui. Flutter 3.44 stable shipped May 2026 (Google I/O 2026). New packages ship 'some time after the 3.44 stable release' — no date. In-SDK copies get a long deprecation window: deprecated in the stable release after 3.44, deleted later, 'not within the next year'. Team reassurance: 'For now nothing should change for you and Material and Cupertino should continue working as usual before and after the freeze.' material_ui on pub.dev is v0.0.1, publisher flutter.dev (verified), published ~4 months ago, README says 'Coming soon' and 'Once landed and published, look forward to updates from Material 3 Expressive!'

- https://github.com/flutter/flutter/issues/184093

- https://pub.dev/packages/material_ui

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

### The '4x faster' figure is marketing. The peer-reviewed number is 33% faster fixation / 20% faster task completion, n=48.

*Confidence: high, **LOAD-BEARING***

Peer-reviewed source EXISTS and I did not expect it: Frank Bentley, Lennard Lukas Schmidt, Alyssa Sheehan, Bianca Gallardo, Ying Wang, 'Usability Hasn't Peaked: Exploring How Expressive Design Overcomes the Usability Plateau', CHI '26 full paper, Barcelona, April 13-17 2026, DOI 10.1145/3772318.3790373. Method: 48 diverse participants, tasks across 10 applications, M3 Expressive designs vs previous Material. Results: fixated on the correct screen element 33% faster, completed tasks 20% faster, rated experiences more positively, 'while maintaining or increasing aesthetic judgments'. Compare Google Design's marketing: 'Participants were able to spot key UI elements up to four times faster in the M3 Expressive designs' — note 'up to', and the task was specifically finding the Send button in an email app using eye-tracking glasses. 4x is a per-element best case; 33% is the aggregate. A ~12x gap between the marketing number and the published number.

- https://doi.org/10.1145/3772318.3790373

- https://research.google/pubs/usability-hasnt-peaked-exploring-how-expressive-design-overcomes-the-usability-plateau/

- https://design.google/library/expressive-material-design-google-research

### The '46 studies / 18,000 participants' umbrella figure is real as a program description but is NOT the evidence base for any specific claim — only one study (n=48) is published.

*Confidence: high, **LOAD-BEARING***

Google Design states 46 separate research studies, 18,000+ participants worldwide, 3-year duration (2022-2025), dozens of design iterations. Methods listed: eye tracking, surveys and focus groups, experiments, usability. But: 'No peer-reviewed papers, citations, or statistical analysis details are provided' on the Google Design page — it credits researchers by name with no links to published studies. So 46/18,000 is a program-scale number being used to lend weight to claims whose actual published sample is 48. Treat the 18,000 as marketing framing, not as statistical power behind the usability claims.

- https://design.google/library/expressive-material-design-google-research

- https://www.androidauthority.com/google-material-3-expressive-features-changes-availability-supported-devices-3556392/

### The 'biggest gains for users 45+' framing in the brief is not supported by any published number — and the actual claim is weaker and differently shaped.

*Confidence: low, **LOAD-BEARING***

Google Design's exact wording: 'M3 Expressive design enabled older users to spot key interactive elements on the screen just as fast as younger users across 10 apps tested', described as 'a dramatic erasure of age effects in fixation times', against the baseline that 'Usability tests typically find that older adults take longer to visually locate key UI elements'. Note: this is parity, not 'biggest gains', and no ages, no effect sizes, no n, no CI are published. The '45+' cutoff does not appear in Google's own article. The CHI paper's public abstract does not surface an age-effects result. The separate '87% preference among 18-24 year olds' figure appears in secondary coverage but I could not confirm it on a Google primary source. LOW confidence on all age claims — do not design around them.

- https://design.google/library/expressive-material-design-google-research

### The corner radius scale is fully public and copyable — and is the single largest 'not 2014' lever that costs zero animation.

*Confidence: high, **LOAD-BEARING***

Exact token values in dp: none/zero 0, extra-small 4, small 8, medium 12, large 16, large-increased 20, extra-large 28, extra-large-increased 32, extra-extra-large 48, full 9999 (pill). M3E added the -increased tokens (20, 32) and the 48 step; it also changed 'fully rounded' from 'set at 50% of the component size' to the explicit `full` token. Verified against the Dart M3Corners class constants, which mirror the spec. These are just numbers — no package needed, `BorderRadius.circular(32)` is the entire implementation.

- https://pub.dev/documentation/material_design/latest/material_design/M3Corners-class.html

- https://m3.material.io/styles/shape/corner-radius-scale

### The 35-shape library is real, named, and ported to Flutter by a community package — but morphing (its whole point) is animation, which this app bans.

*Confidence: high, **LOAD-BEARING***

The 35 shapes: circle, square, slanted (slanted-square), arch, fan, arrow, semicircle, oval, pill, triangle, diamond, clam-shell, pentagon, gem, sunny, very-sunny, cookie-4, cookie-6, cookie-7, cookie-9, cookie-12, ghost-ish, clover-4, clover-8, burst, soft-burst, boom, soft-boom, flower, puffy, puffy-diamond, pixel-circle, pixel-triangle, bun, heart. Added to the Material Shapes Library (Figma) and Jetpack Compose in the May 2025 M3E update, alongside shape morphing. Critically: the shapes are STATIC geometry (RoundedPolygon); morphing is a separate animated capability. A static cookie-9 is a beautiful non-animated ShapeBorder. Note 'heart', 'flower', 'bun', 'clover', 'sunny' — several of these shapes are squarely in the banned childishness register for this audience.

- https://pub.dev/documentation/flutter_m3shapes/latest/

- https://supercharge.design/blog/material-3-expressive

### Community Flutter packages for M3E shapes exist but are immature — adoption is a real supply-chain risk for a solo dev on an offline privacy app.

*Confidence: high, **LOAD-BEARING***

androidx_graphics_shapes v1.6.0, published ~9 days ago, publisher deminearchiver.qzz.io (verified), MIT, explicitly 'A Flutter port of the androidx.graphics.shapes library and the androidx.compose.material3.MaterialShapes object', supports morphing. Metrics: 0 likes, 160 pub points, 400 downloads. Deps: collection, meta, vector_math. m3e_core v0.1.2, published ~2 days ago, publisher muditpurohit.tech, 21 likes, 160 pub points, 598 downloads, MIT — bundles 8 component libraries with spring-based animations, README warns of breaking API changes at v0.1.0. Also flutter_m3shapes, flutter_m3shapes_extended, material3_expressive_loading_indicator (spring-physics morphing between soft burst/cookie/pentagon/pill/sunny/oval). All are one-maintainer, sub-1.0 or brand-new. For an app whose premise is 'nothing leaves the device', every dep is also an audit burden.

- https://pub.dev/packages/androidx_graphics_shapes

- https://pub.dev/packages/m3e_core

### M3E's color system did NOT meaningfully change from M3 baseline. fromSeed is still the mechanism. This is why 'we can't have M3E in Flutter' costs almost nothing.

*Confidence: high, **LOAD-BEARING***

M3E added 'vibrant color schemes' as a styling direction, not a new architecture. No new color roles, no new surface container roles, no changed tone values were introduced. The M3 tone-based surface roles remain: surfaceDim, surfaceBright, surfaceContainerLowest, surfaceContainerLow, surfaceContainer, surfaceContainerHigh, surfaceContainerHighest. Exact tone values — Light: N-100 / N-96 / N-94 / N-92 / N-90 (lowest→highest). Dark: N-4 / N-10 / N-12 / N-17 / N-22. Baseline M3 dark surface is neutral tone 6 (#141218 for the default scheme), replacing M2's #121212 + elevation overlays. All of this already ships in Flutter's material library today.

- https://m3.material.io/blog/tone-based-surface-color-m3

- https://api.flutter.dev/flutter/material/ColorScheme-class.html

- https://github.com/flutter/flutter/issues/137679

### Flutter ALREADY ships contrastLevel and DynamicSchemeVariant — the mandated three-theme one-tap switcher is nearly a one-parameter change. Most actionable finding in this dimension.

*Confidence: high, **LOAD-BEARING***

ColorScheme.fromSeed accepts contrastLevel: 0.0 default/normal, -1.0 lowest, 1.0 highest; 'From Material Design guideline, the medium and high contrast correspond to 0.5 and 1.0 respectively'. And dynamicSchemeVariant, default tonalSpot, with 9 values and exact documented semantics: tonalSpot ('Default for Material theme colors. Builds pastel palettes with a low chroma'), fidelity ('resulting color palettes match seed color, even if the seed color is very bright'), monochrome ('All colors are grayscale, no chroma'), neutral ('Close to grayscale, a hint of chroma'), vibrant ('Pastel colors, high chroma palettes. The primary palette's chroma is at maximum'), expressive ('Pastel colors, medium chroma palettes. The primary palette's hue is different from the seed color, for variety'), content ('Almost identical to fidelity'), rainbow ('A playful theme - the seed color's hue does not appear in the theme'), fruitSalad (same playful note). Landed via PR flutter/flutter#144805 (Hixie). NOTE THE TRAP: DynamicSchemeVariant.expressive SHIFTS THE HUE AWAY FROM YOUR SEED — the enum name is a false friend, it is not 'M3 Expressive' and it makes your palette unpredictable.

- https://api.flutter.dev/flutter/material/DynamicSchemeVariant.html

- https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html

- https://github.com/flutter/flutter/pull/144805

### 'Emphasized' typography is a weight delta, not a technology. Reproducible today in ~1 line, no package, no waiting.

*Confidence: high, **LOAD-BEARING***

M3 now has ONE type scale containing TWO sets: 15 baseline + 15 emphasized = 30 styles, same scale from Display Large to Label Small. Emphasized styles 'have a higher weight and other minor adjustments compared to the baseline styles, and are best applied to bold, selection, and other areas of emphasis'. Token prefixes: --md-sys-typescale-* vs --md-sys-typescale-emphasized-*. Each property (font, line height, size, tracking, weight) is an individual token. Baseline reference points: titleMedium = 16sp / 24sp line / weight 500 / tracking 0.15sp; labelLarge = 14sp / 20sp line / weight 500 / tracking 0.00625rem. Default font is Roboto Flex, a variable font with adjustable axes — weight and width are the two axes Material calls 'most applicable for product design'. Practical upshot: 'emphasized' ≈ bump 500→600/700. The brief's existing spec (tile labels ~20pt, weight 500-600) IS already the emphasized system.

- https://m3.material.io/styles/typography/type-scale-tokens

- https://m3.material.io/blog/roboto-flex

### M3E's expressiveness is delivered PRIMARILY through motion and morphing — the exact two things this app bans. What survives the ban is shape, weight, and color, which Flutter already gives you.

*Confidence: high, **LOAD-BEARING***

M3E replaced the 'easing and duration' approach with a spring-based 'motion physics system'. The flagship new components are motion vehicles: FAB menu (expands), loading indicator (morphs between soft burst/cookie/pentagon/pill/sunny/oval with spring physics), split button (animates on toggle), button groups (squeeze/react on press), toolbars. Strip motion and morphing and roughly half of M3E's identity is gone. But the residue — a 32dp corner instead of an 8dp one, a 700 weight instead of 400, a saturated container against a tonal surface — is real, static, and free. This is the honest answer to 'is expressive compatible with calm': the shape/type/color third is compatible and valuable; the motion/playfulness two-thirds is not, and none of it is in Flutter anyway. Flutter's non-implementation is accidentally the exact filter this app wants.

- https://github.com/flutter/flutter/issues/168813

- https://supercharge.design/blog/material-3-expressive

### The CHI paper's own causal explanation validates this app's EXISTING constraints — which is a better reason to trust it than the 4x number.

*Confidence: medium, **LOAD-BEARING***

The paper's conclusion: usability gains come from 'returning to basic design fundamentals and increasing flexibility in size and color use'. Not from springs. Not from morphing. Not from cookie shapes. The mechanism the peer-reviewed work credits is bigger differentiated targets and stronger color differentiation — which the brief already mandates (76dp floor, 12dp gaps, category color-coding). So M3E's defensible finding is a CONFIRMATION of prior research here, not a new direction. Secondary coverage also reports Google found 'a strong minority of users preferred calmer, less intense versions' — I could not confirm this on a Google primary source, so treat as unverified, but it is directionally consistent with shipping restraint.

- https://doi.org/10.1145/3772318.3790373

- https://research.google/pubs/usability-hasnt-peaked-exploring-how-expressive-design-overcomes-the-usability-plateau/

### Do NOT migrate to material_ui yet, but DO isolate Material usage now so the migration is cheap.

*Confidence: high*

material_ui is v0.0.1 'Coming soon'. package:flutter/material.dart keeps working through 3.44 and beyond; deprecation comes 'in the stable release after 3.44' and deletion 'some time after that', explicitly 'not within the next year' (so not before ~mid-2027). The migration will be largely an import swap plus a pubspec pin. Risk for this app is low IF Material surface area is small — which argues for the bespoke-tiles decision on independent grounds.

- https://github.com/flutter/flutter/issues/184093

- https://blog.flutter.dev/flutters-material-and-cupertino-code-freeze-d32d94c59c38

### None of M3E's new components are relevant to this app's surface. The component question answers itself.

*Confidence: high*

The 15 M3E components: button groups, FAB menu, loading indicator, split button, docked/floating toolbars, XR app bars, XR dialogs, plus updates to app bars, carousel, buttons, extended FAB, FABs, icon buttons, navigation bar, navigation rail, progress indicators. This app is ONE screen: a fixed 3x4 grid + a text field + edit mode + settings. No nav bar (one screen), no FAB (the grid IS the action), no loading indicator (offline, zero latency is the premise), no carousel (fixed positions are the retrieval mechanism), no toolbar. The only arguable one is a floating toolbar for the theme/show-mode toggles — and that is 3 IconButtons in a Row.

- https://github.com/flutter/flutter/issues/168813

## Design moves

- **Tile corner radius 28dp (M3 extraLarge) or 32dp (extraLargeIncreased) — NOT 8dp, NOT 12dp, NOT 16dp. Pick one and use it for every tile. Type the literal token name in a constant: `const tileRadius = 32.0; // M3 extra-large-increased`.**
  - Why: This is the highest-leverage, zero-cost, zero-animation move in the entire dimension. The '2014 enterprise settings screen' look the founder is fleeing IS a 4-8dp corner — that radius is literally the M2/Bootstrap-era default. M3E's own signature contribution to static visual identity is pushing radius up. A 32dp radius on a ~110dp tile reads as a soft, deliberate, contemporary object rather than a table cell. It costs one number.
  - Risk: At 76dp (the minimum target floor) a 32dp radius eats a large fraction of the tile — the corners round so hard the tile approaches a squircle and usable label width drops, which fights the 200% TextScaler requirement. Mitigation: scale radius with tile size (32dp at default 3x4, drop to 28dp if a tile ever renders near the 76dp floor), and never let the radius exceed ~30% of the short edge. Also: very round + saturated + small = 'toy block', the exact childish register banned. Roundness must be paid for with restrained color and adult type, not stacked on top of saturation.
- **Build the three themes as ONE ColorScheme.fromSeed call with contrastLevel as the only variable: normal = 0.0, high-contrast = 1.0. Keep dark/light as the `brightness` parameter. Three themes from two parameters, no hand-authored palettes for app chrome.**
  - Why: Flutter already ships this — it is the single most actionable finding here. contrastLevel maps directly onto the Material guideline (0.5 = medium, 1.0 = high), so the high-contrast theme is a spec-conformant, tested code path rather than a hand-rolled second palette the solo dev must maintain. This makes the mandated one-tap switcher genuinely cheap, which is the difference between it shipping well and shipping as an afterthought.
  - Risk: fromSeed's algorithm owns the output — you cannot fully predict the resulting hexes, and contrastLevel: 1.0 may push chroma in ways that violate the 'muted, low-saturation' sensory constraint. MUST be verified by measuring actual contrast ratios on real output, not trusted. Also, per prior research the dominant halation lever is TEXT luminance — fromSeed will happily hand you a near-#FFFFFF onSurface in dark mode, which is exactly the 21:1 halation problem. Override onSurface manually toward ~#E0E0E0 in dark regardless of what the seed produces.
- **Use DynamicSchemeVariant.tonalSpot (the default). Explicitly DO NOT use DynamicSchemeVariant.expressive, .vibrant, .rainbow, or .fruitSalad.**
  - Why: tonalSpot 'builds pastel palettes with a low chroma' — that is a direct match for the 'muted, low-saturation, 2-5 intentional hues' constraint, and it is the default so it is the best-tested path. The enum value named `expressive` is a false friend: it is unrelated to M3 Expressive and it deliberately shifts the primary hue AWAY from your seed 'for variety', destroying palette predictability. `vibrant` maxes chroma — a direct sensory-constraint violation. `rainbow`/`fruitSalad` are documented as 'a playful theme'.
  - Risk: tonalSpot's pastels may read as washed-out and undercut the 'beautiful' brief, and low chroma at low luminance contrast is the grey-rectangle failure mode. Guard: the constraint is low SATURATION at HIGH LUMINANCE CONTRAST — those are separable. Verify luminance contrast independently of what tonalSpot chose for hue.
- **Hand-author the category tile colors. Do not derive them from fromSeed. Use fromSeed ONLY for chrome (surfaces, text field, settings, icon buttons).**
  - Why: The tiles are the product and their colors are load-bearing for findability (category color-coding is explicitly sanctioned by prior research). A seed algorithm cannot know that 'I need to leave' and 'I can't talk right now' must be instantly distinguishable at a glance during a shutdown. 2-5 hand-picked hues, contrast-verified in all three themes, is a few hours of work and is where the craft lives. fromSeed for chrome gives you the M3 surface-container tone ladder (dark N-4/10/12/17/22, light N-100/96/94/92/90) for free.
  - Risk: Hand-authored colors must be re-verified against all three themes × both polarities = 6 combinations, and they will NOT automatically respond to contrastLevel. You are signing up to maintain a 6-way color matrix by hand. Mitigation: author them in HCT/LCh with fixed tone targets rather than as raw hex, so the high-contrast variant is a tone shift not a redesign.
- **Adopt 'emphasized' typography by simply setting tile labels to FontWeight.w600 or w700 at ~20pt. Do not add a package, do not wait for material_ui. Skip Roboto Flex's variable axes for v1.**
  - Why: M3E's emphasized type scale IS 'higher weight and other minor adjustments' — 15 baseline + 15 emphasized styles. The brief's existing spec (17pt min, ~20pt default, weight 500-600) is already 95% of it. Weight is the cheapest source of typographic confidence and it does not move. This is 'print has been beautiful for 500 years without moving' expressed as one FontWeight constant.
  - Risk: Heavier weights at high luminance contrast INCREASE halation for sensitized readers — a 700-weight near-white glyph on near-black is more blooming mass than a 400-weight one. The weight bump and the text-luminance reduction must be tuned together, not independently. Consider w600 in dark and w700 in light. Also verify the chosen font's 600/700 exist as real cuts (Atkinson Hyperlegible ships limited weights) — synthetic bold will look cheap and undermine the whole 'craft' brief.
- **If you want ONE M3E shape as a signature, use a single STATIC shape in exactly one place — the speak/show-mode affordance — via a hand-copied RoundedPolygon path, not the androidx_graphics_shapes dependency. Never morph it.**
  - Why: One deliberate non-rectangular form is the difference between 'grid of rounded rects' and 'someone designed this'. The shapes are static geometry; morphing is the separate animated feature. A static cookie-9 or gem is a ShapeBorder and costs nothing at runtime. Copying one path avoids taking a dependency on a 0-like, 400-download, 9-day-old package in an app whose entire premise is that nothing leaves the device.
  - Risk: REAL RISK OF SELF-SABOTAGE: the shape library's vocabulary is heart, flower, bun, clover, sunny, puffy, cookie — this is the banned childish register wearing a Google badge. Choosing wrong here reintroduces exactly the infantilization that is the product's wedge. If a shape reads as a sticker, it is a mascot with extra steps. Safest picks: gem, slanted-square, or a high-count cookie (cookie-9/cookie-12, which read as subtle scalloping, not as a cartoon). Reject heart/flower/bun/clover/sunny outright. And a novel silhouette on the primary affordance can hurt hit-target predictability under motor imprecision — keep the TOUCH target a generous rectangle even if the PAINTED shape is not.
- **Build the tile on raw primitives (CustomPaint / DecoratedBox / Container + InkWell-free GestureDetector), keep Material only for Scaffold, TextField, and settings. Budget the Material surface area deliberately so the material_ui migration is an import swap.**
  - Why: Two independent reasons converge. (1) Design: the app deliberately departs from platform defaults, the tile has no Material analogue (it is not a Card, not a Button, not a ListTile), and Material's ink ripple is ANIMATION — it must be suppressed anyway, so you are fighting the framework from line one. Flutter paints everything regardless; bespoke is genuinely cheap here. (2) Logistics: Material is frozen as of 2026-04-07 and moving to material_ui; small Material surface area = cheap migration. The counter-argument for Material — accessibility semantics, TextField's enormous IME/selection complexity, theming plumbing — is real, which is exactly why you keep it for the text field and chrome rather than going bespoke everywhere.
  - Risk: Going bespoke on the tile means you now OWN the accessibility semantics — TalkBack labels, focus order, tap target announcement, TextScaler propagation — which Material would have given you free. For an AAC app, botched semantics is a catastrophic failure, not a cosmetic one. Mandatory mitigation: wrap every bespoke tile in an explicit Semantics(button: true, label: ...) and test with TalkBack before shipping. Do NOT go bespoke on TextField — reimplementing IME/selection is a multi-month trap.
- **Do not cite the '4x faster' or '18,000 participants' figures internally as justification for anything. If a design decision needs M3E evidence, cite Bentley et al. CHI '26: 33% faster fixation, 20% faster task completion, n=48.**
  - Why: The 4x is 'up to', from a single cherry-picked element (a Send button) under eye-tracking glasses; the aggregate peer-reviewed figure is ~12x smaller. The 18,000 is program scale across 46 studies of which one is published. Designing on a marketing number means that when the number turns out to be soft, every decision resting on it is unmoored. The 33% is defensible and is still a real, meaningful effect — you do not need the 4x.
  - Risk: Under-weighting M3E is also a failure mode: the CHI paper is a legitimate CHI '26 full paper and 33%/20% is a genuine result worth respecting. The risk is overcorrecting into 'Google's research is marketing, ignore it' — it isn't, and its causal story (bigger targets, stronger color differentiation, back to fundamentals) independently confirms constraints this app already holds.
- **Explicitly reject, in writing, the M3E motion-physics system, FAB menu, loading indicator, split button, button groups, and toolbars. Record the reason so it is not relitigated when material_ui eventually ships them.**
  - Why: Zero animation is settled on two independent grounds (trauma-informed guidance + latency in a product whose premise is instant speech). Flutter's non-implementation means there is currently nothing to opt out of — opting out breaks nothing, because none of it exists. But material_ui WILL ship these eventually and they will arrive as tempting defaults. Deciding now, with the reason attached, costs nothing; deciding later under the pull of shiny defaults costs the product's identity.
  - Risk: Low. The genuine watch item is that when material_ui ships, updated Material components may bake spring motion into things you DO use (TextField cursor/selection, Scaffold, dialogs) with no opt-out flag. MediaQuery.disableAnimationsOf → zero duration is the defense, but it must be verified against the new packages at migration time rather than assumed — a component with hardcoded spring physics would be a migration blocker worth pinning material_ui to avoid.
- **For show mode, force light polarity + contrastLevel 1.0 + the emphasized weight, regardless of the app's current theme. Treat it as a separate ThemeData, not a variant of the current one.**
  - Why: Show mode has an inverted user: a stranger reading at arm's length in daylight. The dark/low-luminance optimization that protects the user's eyes actively harms the cashier's reading. contrastLevel: 1.0 + Brightness.light is a two-parameter expression of 'opposite optimizations' using the same fromSeed machinery — no second design system, no second palette.
  - Risk: A sudden full-screen flip from dark to bright white IS a sensory event for the user holding the phone, even though nothing 'animates' — a luminance jump from #141218 to near-white at arm's length during a shutdown is arguably worse than any motion. This is a real, unresolved tension the zero-animation rule does not cover. Mitigation worth testing: a fixed, non-animated intermediate, or letting show mode inherit a high-contrast DARK scheme (white-on-black is also legible at arm's length in daylight) — verify with actual users rather than assuming light is required.

## References

- **flutter/flutter#168813 — ☂️ Bring Material 3 Expressive to Flutter** https://github.com/flutter/flutter/issues/168813
  - Steal: The authoritative answer to 'can we use M3E'. Read the 2025-06-10 strategic-pause comment. Subscribe to it — it is the single signal that will tell you when this question reopens. Also the complete enumeration of the 15 M3E components and 4 expressive styles, useful as a checklist of what to consciously reject.
- **flutter/flutter#184093 — [Decoupling] Material and Cupertino are now frozen** https://github.com/flutter/flutter/issues/184093
  - Steal: The migration timeline and the exact reassurance ('nothing should change for you... before and after the freeze'). Steal the implication: keep your Material surface area small and the eventual material_ui swap is an import line, not a rewrite.
- **Bentley, Schmidt, Sheehan, Gallardo & Wang — 'Usability Hasn't Peaked', CHI '26** https://doi.org/10.1145/3772318.3790373
  - Steal: The only peer-reviewed evidence for M3E. Steal the real numbers (33% fixation, 20% completion, n=48, 10 apps) to replace the 4x marketing claim, and steal the causal conclusion — gains came from 'returning to basic design fundamentals and increasing flexibility in size and color use', i.e. bigger targets and stronger color differentiation, which this app already mandates.
- **Flutter API — ColorScheme.fromSeed / DynamicSchemeVariant** https://api.flutter.dev/flutter/material/DynamicSchemeVariant.html
  - Steal: contrastLevel (0.0/0.5/1.0 = normal/medium/high, per Material guideline) — this IS your three-theme switcher, today, with no package. And the exact documented semantics of all 9 variants, which is how you learn that `expressive` shifts hue off your seed and `tonalSpot` is the low-chroma pastel default you actually want.
- **M3 spec — Corner radius scale** https://m3.material.io/styles/shape/corner-radius-scale
  - Steal: The ten token values (0/4/8/12/16/20/28/32/48/full). Steal 28 or 32 for tiles. Steal the M3E change that 'full' is now an explicit token rather than 50% of component size. Note the page is JS-rendered — the Dart M3Corners class docs mirror the values in fetchable form.
- **Material Shapes — the 35-shape library** https://www.figma.com/community/file/1510597655879136621/m3-expressive-shapes-set
  - Steal: Browse it for ONE static signature shape (gem, slanted-square, cookie-9/cookie-12). Equally valuable as a negative reference: heart, flower, bun, clover, sunny, puffy are a catalogue of exactly the childish register this product exists to escape — proof that Google's 'expressive' and this app's 'beautiful' are not the same word.
- **androidx_graphics_shapes (pub.dev)** https://pub.dev/packages/androidx_graphics_shapes
  - Steal: A faithful MIT Flutter port of androidx.graphics.shapes + MaterialShapes. Steal the SHAPE PATH MATH by reading the source, not by adding the dependency — v1.6.0, 0 likes, 400 downloads, 9 days old, one maintainer is not a supply chain for an offline privacy app. Read it, copy the one path you need, attribute the MIT license.
- **M3 blog — Tone-based surface color** https://m3.material.io/blog/tone-based-surface-color-m3
  - Steal: The exact surface-container tone ladder (dark N-4/10/12/17/22; light N-100/96/94/92/90) and the rationale for killing M2's #121212 + elevation overlays. Steal the ladder as your depth system — five distinguishable surfaces with zero shadows and zero animation is a legitimate, contemporary source of compositional depth.
- **Google Design — Expressive Design: Google's UX Research** https://design.google/library/expressive-material-design-google-research
  - Steal: Read it specifically to see how the sausage is made: 46 studies / 18,000 participants / 'up to four times faster' with zero links to published methodology, next to a CHI paper reporting 33% at n=48. Steal it as a case study in why 'backed by research' needs the primary source checked before it justifies a design direction.
- **material_ui (pub.dev)** https://pub.dev/packages/material_ui
  - Steal: Watch, do not install. v0.0.1, 'Coming soon', publisher flutter.dev. Its README is the only forward-looking commitment that exists: 'Once landed and published, look forward to updates from Material 3 Expressive!' When this hits a real version, the M3E-in-Flutter question genuinely reopens — until then it is the proof that it hasn't.

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


YOUR DIMENSION: Material 3 Expressive in depth — and whether it's implementable in Flutter in 2026. This may be the single most actionable dimension.

Research with WebSearch/WebFetch: m3.material.io, Google Design blog, the May 2025 IO announcement, Flutter release notes, Flutter GitHub issues/PRs, pub.dev.

- The FULL mechanics of M3 Expressive. Get exact specs:
  - **Shape system**: the shape library (how many shapes? what are they? "cookie", "clover", "pill", "burst"?), shape morphing, corner radius scale (what are the actual token values — extra-small 4dp through extra-large 28dp? extra-large-increased? extra-extra-large?). `material-shapes` library?
  - **Type scale**: what changed? "Emphasized" type styles? New tokens (display/headline/title/body/label × large/medium/small — plus emphasized variants)? Actual sizes/weights? Variable font axes?
  - **Color**: what changed from M3 baseline? New roles? Is `ColorScheme.fromSeed` still the mechanism? What are the new surface container roles and their exact tone values?
  - **Motion**: spring-based motion physics (irrelevant to us — we ban animation — but confirm what we're opting out of and whether opting out breaks anything).
  - **Components**: FAB menu, button groups, split buttons, loading indicators, toolbars. Any relevant?
- **The research claim** — Google says M3 Expressive is backed by ~46 research studies / 18,000+ participants, and found expressive designs let users spot key elements dramatically faster (a "4x" claim?) with the biggest gains for users 45+. VERIFY THE ACTUAL NUMBERS AND METHODOLOGY. Did Google publish the methodology, or is it marketing? Is there peer review? Be skeptical — this is being used to justify a design direction.
- **CRITICAL: what is M3 Expressive's status in FLUTTER (3.44, 2026)?** Flutter historically lags Material spec updates. Search Flutter's release notes, the "Material 3 Expressive" umbrella issue on GitHub, and pub.dev. Which parts are in `flutter/material`? Which need hand-rolling? Are there community packages? This determines whether it's a real option or an aspiration.
- Does M3 Expressive CONFLICT with this app's constraints? It's motion-heavy and playful — is "expressive" compatible with "calm and adult", or is it Google's version of the childishness we're fleeing? Argue it honestly. Which parts are separable (shape, type, color) from the parts we must reject (motion, playfulness)?
- Is using Material at all right here, or should this app build a bespoke design system on Flutter's raw primitives? Flutter makes bespoke cheap (it paints everything anyway). Argue both sides — note the app already deliberately departs from platform defaults.

Get exact token values and dates. Distinguish spec from Flutter reality.
````

</details>
