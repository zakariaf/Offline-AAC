# design-tokens-implementation

> Phase: **research** · Agent `abe3c8b5a23713265` · Run `wf_f237e8a6-694`

## Result

## Summary

I built and compile-verified the complete token layer against the installed toolchain (Flutter 3.41.2 / Dart 3.11): 500 lines across primitives, a ThemeExtension, three ThemeData objects, and a CI contrast test. `flutter analyze` is clean; 39 tests pass in ~1s. The headline result: the contrast test found two real bugs in my own hand-authored palette on first run, and the correct fix turned out to be a *design* finding rather than a number tweak — naively asserting WCAG 1.4.11's 3:1 on tile borders would have forced exactly the 2014 grey-rectangle-grid the founder banned. A phrase tile carries its own 4.5:1 label, which earns it the same self-identification exemption a text button gets; the edge is decorative. That distinction is now encoded as a separate, honestly-labeled "edge findability" rule. Recommendations: skip DTCG/Style Dictionary and Figma entirely (both are pipelines between two people, and there is one person); use `ColorScheme.fromSeed` with per-role overrides — a real hybrid that keeps M3's tonal correctness for the ~25 roles you don't care about while hand-authoring the ~8 that carry the design (verified: the seed-generated `onError`/`error` pairings passed at 6.46/7.72/18.43:1 with zero effort); ship one `ThemeExtension` plus three discrete themes, not two themes × a contrast modifier; and reject `dynamic_color`. `lerp` returning a hard cut is legal, correct, and testable — the animation ban genuinely simplifies the extension. Golden tests are a trap at 3 themes × N text scales; the contrast test is the cheap, high-value 80%.

### The DTCG format reached a stable Community Group Report (2025.10) in Oct 2025 — but it is NOT a W3C Recommendation, and it is irrelevant to this project regardless.

*Confidence: high, **LOAD-BEARING***

Announced 2025-10-28 as 'first stable version', spec version string 2025.10, at designtokens.org/tr/2025.10/. Uses $value/$type/$description (vs legacy value/type/comment). Supported by Figma, Penpot, Sketch, Framer, Tokens Studio, Style Dictionary v5, Terrazzo, Knapsack, Supernova, zeroheight. CRITICAL PROCESS NUANCE: W3C Community Groups structurally cannot publish Recommendations — that requires a chartered Working Group. So 'did it reach spec?' = it reached a stable *vendor-neutral CG report*, which is real industry consensus but not a W3C standard. Style Dictionary v5 adopted DTCG 2025.10 as its base format. But: DTCG exists to move tokens BETWEEN a design tool and a codebase, i.e. between a designer and an engineer. Here those are the same person. A JSON→Style Dictionary→Dart codegen step for ~30 colors adds a build step, a node_modules, and a generated-file diff review — to solve a handoff problem that does not exist. Hand-authored `abstract final class Prim` is the right answer at this scale.

- https://www.w3.org/community/design-tokens/2025/10/28/design-tokens-specification-reaches-first-stable-version/

- https://www.designtokens.org/tr/drafts/format/

- https://styledictionary.com/info/dtcg/

### The 3-tier token model is right here, but collapsed to 2.5 tiers — and the reason is the 3 themes, exactly as the brief suspected.

*Confidence: high, **LOAD-BEARING***

Tier 1 (primitives): `Prim.inkT06`, `Prim.clayT40` — hex literals live here and NOWHERE else. Tier 2 (semantic): the `AacTheme` ThemeExtension — `tileInk`, `showModeSurface`. Tier 3 (component) is DELETED: with one screen there are ~4 components, so a `tilePhraseLabelColorRest` tier is pure ceremony that adds indirection with zero reuse payoff. But tiers 1+2 are NOT optional: the entire justification is that `tileInk` resolves to three different primitives across three themes. Without the semantic tier, every widget needs an `if (isDark)` — which is the actual failure mode, because it scatters palette logic across the widget tree where no test can see it. The tier boundary is what makes the contrast test possible at all: the test enumerates semantic pairings, which only exist because the semantic tier exists. Tokens earn their keep here at 3 themes, not at 1.

### The contrast CI test is the single highest-value move in this dimension — VERIFIED WORKING, and it found two real bugs in my own palette on the first run.

*Confidence: high, **LOAD-BEARING***

Implemented at /private/tmp/claude-501/-Users-zakariafatahi-50-apps-challenge-Offline-AAC/894d23b4-edde-414c-90f6-a0c3d1367fdd/scratchpad/tokencheck/test/contrast_test.dart. Pure Dart, no widget tree, no golden files: 39 tests, ~1.0s wall clock. The whole algorithm is `Color.computeLuminance()` (which already implements WCAG sRGB linearization) → `(hi+0.05)/(lo+0.05)`. Enumerates a `typedef Pairing = ({String name, Color fg, Color bg, double min})` per theme via `AacThemeMode.values`. MEASURED RESULTS (all passing): light tileInk/tileSurface 17.12:1, dark 10.74:1, HC 21.00:1; show mode 21.00:1 in all three; dark tileInk/tilePressed 6.26:1. THE TWO BUGS IT CAUGHT: light tileBorder-on-surface 1.52:1 and dark 1.78:1, both asserted against 3:1. Also note the pressed-state pairing — `tileInk on tilePressed` — is the one that silently rots when someone tweaks a press color months later, because the label does not recolor on press. Nobody eyeballs that pairing; a test does.

- https://api.flutter.dev/flutter/dart-ui/Color/computeLuminance.html

### MOST IMPORTANT FINDING: a naive WCAG contrast test actively pushes this design toward the grey rectangle grid the founder banned. The 3:1 border rule does not apply to these tiles.

*Confidence: high, **LOAD-BEARING***

My first test run failed on tileBorder-vs-surface at 1.52:1/1.78:1 against WCAG 1.4.11's 3:1 for non-text UI components. The naive fix — darken the borders — draws a hard 3:1 line around all 12 tiles, which IS the 2014 enterprise grid. But 1.4.11 requires 3:1 only where the visual information is REQUIRED TO IDENTIFY the component. A phrase tile carries its own 4.5:1 text label; it is self-identifying, the same exemption a borderless text button gets. The border is decorative. So the assertion was wrong, not the palette. Replaced with an honestly-named non-WCAG rule: 'edge findability' asserts `max(fillStep, borderStep) >= 1.5` for light/dark and `>= 3.0` for high-contrast (where the 3dp border IS load-bearing). Requiring BOTH fill separation and a border is what produces heavy-handed UI — asserting the max lets the designer choose which carries the edge. The rationale is a 9-line comment in the test, because the next person WILL try to 'fix' this to 3:1. This is the general lesson: a design system verified by CI is only as good as whether the assertions encode the right rule, and copying WCAG thresholds without reading the applicability clause makes the tests a force for ugliness.

- https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html

### `lerp` returning a hard cut is legal, correct, and testable — the animation ban genuinely simplifies ThemeExtension.

*Confidence: high, **LOAD-BEARING***

`ThemeExtension<T>` has exactly two abstract members: `copyWith()` and `lerp(covariant ThemeExtension<T>? other, double t)`. The contract requires returning a valid T — it does NOT require interpolation. Flutter calls lerp only from AnimatedTheme / MaterialApp's implicit theme animation, which this app never mounts with nonzero duration. Shipped implementation is one line: `AacTheme lerp(covariant AacTheme? other, double t) => t < 0.5 ? this : (other ?? this);`. Note `t < 0.5` rather than bare `return this`: bare `this` would mean a theme switch that somehow got animated would never reach the new theme at all. The `? this : other` cut is a correct step function — it lands on the right endpoint. This removes ~13 lines of `Color.lerp(a,b,t)!` boilerplate per field AND removes the bug surface where someone forgets to lerp a newly-added field. It is CI-locked by a test asserting the result is always one of the two endpoints and never a mix, at t ∈ {0, 0.25, 0.49, 0.5, 0.75, 1.0} — so a future 'helpful' real-lerp refactor fails the suite. copyWith still must be written in full (13 fields); it is not optional because ThemeData.copyWith machinery uses it.

- https://api.flutter.dev/flutter/material/ThemeExtension-class.html

### `ColorScheme.fromSeed` accepts per-role overrides — so 'seed vs hand-authored' is a false binary. Seed AND override is the right answer and it is one constructor call.

*Confidence: high, **LOAD-BEARING***

VERIFIED signature: `ColorScheme.fromSeed({required Color seedColor, Brightness brightness = Brightness.light, DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot, double contrastLevel = 0.0, Color? primary, Color? onPrimary, Color? primaryContainer, ..., Color? surface, Color? onSurface, Color? outline, ...})`. Docs: 'If any of the optional color parameters are non-null they will be used in place of the generated colors for that field.' So: hand-author the ~8 roles that carry the design (primary, onPrimary, primaryContainer, onPrimaryContainer, secondary, surface, onSurface, outline), let the seed generate the ~25 you will never look at (error, inverseSurface, scrim, surfaceTint, all 5 surfaceContainer tones). PROOF THIS PAYS: the seed-generated error pairings measured 6.46:1 (light), 7.72:1 (dark), 18.43:1 (HC) — passing AA with zero design effort. You get M3 tonal correctness for free on the boring roles and exact control where the design lives. Deprecated params to avoid: `background`, `onBackground`, `surfaceVariant`.

- https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html

### `contrastLevel` IS in Flutter 3.44 (and in the installed 3.41.2 — I compiled against it). But high-contrast should still be a discrete third theme, not `contrastLevel: 1.0` on the other two.

*Confidence: high, **LOAD-BEARING***

VERIFIED by compilation on Flutter 3.41.2: `ColorScheme.fromSeed(seedColor: x, contrastLevel: 1.0)` analyzes clean. Range -1.0..1.0, default 0.0; Material's medium/high contrast correspond to 0.5 and 1.0. Also available: `ColorScheme.highContrastLight()` / `.highContrastDark()` factories. ARCHITECTURE DECISION — 3 discrete themes, not 2 × contrast modifier. Rationale: contrastLevel only stretches the tonal palette. It cannot express the actual high-contrast design decisions this app needs: drop category hues entirely (they collapse to a single black face, findability degrading to position — which the fixed grid already guarantees), swap the 1dp hairline border for a 3dp load-bearing one, go to pure #000/#FFF. Those are design choices, not a math parameter. A '2 themes × contrast level' matrix would also make the one-tap switcher a 2D control, which is wrong for a user in a shutdown with reduced decision-making — one tap must cycle a flat list of 3. I still PASS contrastLevel: 1.0 inside the HC theme, because it correctly fixes the ~25 roles I don't override. Both/and, not either/or.

- https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html

- https://github.com/flutter/flutter/issues/149683

### Material Theme Builder does NOT export Flutter/Dart in 2026. The 'pick colors → ThemeData' workflow the brief asks about does not exist as a pipeline.

*Confidence: high, **LOAD-BEARING***

MTB (material-foundation.github.io/material-theme-builder) exports Android Views XML, Jetpack Compose Kotlin, and Design System Package (DSP). Flutter is not an export target. Issue #50 'Fully support Flutter export' (opened 2022-04-01) is CLOSED without the feature landing. So the honest workflow is: use MTB purely as an HCT VISUALIZER (its HCT picker lets you tune hue/chroma/tone and copy hex out), then hand-type ~8 hex values into `Prim` and pass them as fromSeed role overrides. That is a 10-minute manual step, once. Do not go looking for a generator. Adjacent tools: `appainter.dev` (visual ThemeData editor, exports JSON not Dart) and rydmike's `flex_seed_scheme` v4.0.1 (~7mo old, 475k downloads, verified publisher) which adds multi-seed palettes, per-palette chroma control, custom tone mapping, monochrome surfaces, and 12 FlexTones presets. flex_seed_scheme is genuinely better than fromSeed — but for a 2-week MVP with 8 hand-authored roles, fromSeed+overrides already gets you there with zero dependencies.

- https://github.com/material-foundation/material-theme-builder/issues/50

- https://material-foundation.github.io/material-theme-builder/

- https://pub.dev/packages/flex_seed_scheme

### Skip Figma. Design in Flutter directly — but with one specific, cheap mitigation for the divergent-exploration weakness the brief correctly identifies.

*Confidence: medium, **LOAD-BEARING***

For a solo dev with a 2-week MVP: Figma's value is (a) handoff to another human — nonexistent here; (b) exploring divergent directions cheaply — real, and hot reload IS bad at this because every direction costs a refactor; (c) a source of truth that outlives the code — the code IS the source of truth for a solo dev. Meanwhile Flutter-direct wins decisively on the things this app is ABOUT: you cannot test TextScaler 200% in Figma, you cannot test a 76dp target against a real thumb in Figma, you cannot feel tap→TTS latency in Figma, and a Figma mock of a fixed 3×4 grid at 3 themes is ~12 frames of manual, immediately-stale work. What's genuinely lost: divergent exploration. MITIGATION: paper. Thumbnail 6 grid/type/color directions on paper in 30 minutes — faster than Figma at divergence, and worse than Figma at nothing that matters here. Then build the winner in Flutter. Total Figma value delivered by a pencil, at zero tool cost. VERDICT: no Figma, no DTCG pipeline. Both are handoff machinery between two people, and there is one person.

### Reject `dynamic_color` / Material You wallpaper theming. This is the clearest call in the dimension.

*Confidence: high, **LOAD-BEARING***

`dynamic_color` v1.8.1 (~11mo old), Android 12+ (S+) only. The argument against is decisive and it is a SAFETY argument, not a taste one: this app's palette is contrast-tested in CI across 3 themes. Wallpaper-derived colors are, by construction, untestable at build time — they are computed on-device from an image the developer has never seen. Every guarantee the contrast suite provides evaporates the moment the palette becomes user-wallpaper-derived. For an app whose failure mode is 'a person in a shutdown cannot make themselves understood', shipping an untestable palette is not a feature. The package's `harmonize` helper does not save it — harmonization shifts hue/chroma toward the wallpaper, which perturbs exactly the tested pairings. Secondary argument: the brief's audience is sensory-sensitive with a 2-5 muted-hue budget; a saturated wallpaper produces a palette that violates the sensory constraint on purpose. Counter-argument acknowledged — Material You reads as 'current' and is beloved on Android, and 'current' is literally what the founder asked for. But currency here must come from composition, type, material and craft (which is what the artist gets paid for), not from delegating the palette to a wallpaper. The designed palette IS the product's voice; dynamic color gives it away.

- https://pub.dev/packages/dynamic_color

### Golden tests: a trap at 3 themes × N text scales. Ship the contrast test instead; add exactly 3 goldens, not 3×N.

*Confidence: high, **LOAD-BEARING***

The combinatorics: 3 themes × 4 text scales (1.0/1.3/1.6/2.0) × 2 modes (grid/show) = 24 PNGs. Every one is invalidated by any palette or padding change, and they are reviewed by a human eyeballing 24 diffs — which is precisely the review that does not happen at 11pm in week 2. Worse, golden PNGs cannot ASSERT anything: a golden that renders unreadable grey-on-grey passes forever once blessed. The contrast test asserts. TOOLING NOTE: `golden_toolkit` is DISCONTINUED (v0.15.0, last published ~3 years ago, explicit discontinued badge on pub.dev) — do not start here in 2026 despite the tutorials. Betterment's `alchemist` is the maintained successor and supports inherited theming via a pumpWidget callback. RECOMMENDATION: 3 goldens total (one per theme, at TextScaler 1.0, grid only) as a coarse 'did I catastrophically break layout' tripwire. Put the real coverage in (a) the contrast suite and (b) a widget test that pumps the grid at TextScaler 2.0 and asserts no RenderFlex overflow — that catches the actual TextScaler failure mode, deterministically, with no PNG to bless.

- https://pub.dev/packages/golden_toolkit

- https://github.com/Betterment/alchemist

### Flutter 3.44 (May 2026) is current stable; 3.41.2 is installed in this repo. Color API has shifted under wide-gamut and the old idioms are deprecated.

*Confidence: high, **LOAD-BEARING***

`Color.value` deprecated → use `.toARGB32()` (I use exactly this in the test's failure messages) or component accessors `.r/.g/.b/.a`. `withOpacity()` deprecated in 3.27 → `withValues(alpha: x)`, because since 3.27 alpha is stored as a float and withOpacity quantizes. Components `.r/.g/.b/.a` are now doubles in 0.0..1.0, NOT ints 0..255 — this silently breaks any hand-rolled contrast math copied from a pre-2024 blog post. My test sidesteps the whole issue by using `Color.computeLuminance()`, which is wide-gamut-aware. It DOES assert `fg.a == 1.0 && bg.a == 1.0`, because contrast ratio is undefined for a translucent foreground — you must composite first. That assert is a real guard: it's what stops someone from adding a `tileInk.withValues(alpha: 0.6)` 'disabled' token and getting a meaningless green test.

- https://docs.flutter.dev/release/breaking-changes/wide-gamut-framework

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

### Token naming that doesn't rot: name primitives by MEASURED TONE, semantics by ROLE. Never by appearance, brand, or rank.

*Confidence: high, **LOAD-BEARING***

Primitives use `<family><tone>`: `Prim.inkT06`, `Prim.clayT40`, `Prim.mossT90`. Tone = HCT tone (0=black, 100=white). Why this doesn't rot: T40 is a measured lightness, so it stays true forever. Contrast with the three schemes that DO rot: (1) `grey700` / `blue500` — Material's rank scale, where inserting a color between 500 and 600 has no name and the '500 is the main one' convention is a lie in dark mode; (2) `colorDarkGrey` — appearance names invert catastrophically in dark theme, where `darkGrey` is your LIGHTEST color; (3) `brandPrimary` — dies the day the brand changes. Semantics use `<component><property>`: `tileInk`, `tilePressed`, `showModeSurface`. Note `tileInk` not `tileText` (ink covers icon fills too) and not `tileForeground` (vague). The killer test for a semantic name: it must be answerable WITHOUT knowing the theme. 'What is tileInk in high contrast?' → white. 'What is colorDarkGrey in dark mode?' → nonsense. Also: `AacTheme.of(context)` ASSERTS non-null rather than falling back to a default — a `?? AacTheme.fallback()` would silently ship an untested palette to production, which is the exact failure this whole system exists to prevent.

## Design moves

- **Ship exactly 3 files for the token layer, 500 lines total, all compile-verified: `lib/theme/tokens.dart` (59 lines, primitives — the ONLY file in the codebase allowed a hex literal), `lib/theme/aac_theme.dart` (289 lines, the ThemeExtension + 3 ThemeData), `test/theme/contrast_test.dart` (152 lines, CI). Working code at /private/tmp/claude-501/-Users-zakariafatahi-50-apps-challenge-Offline-AAC/894d23b4-edde-414c-90f6-a0c3d1367fdd/scratchpad/tokencheck/ — `flutter analyze` clean, 39 tests green in ~1.0s on Flutter 3.41.2.**
  - Why: This is the entire design system. It is smaller than the average team's Style Dictionary config. That is the argument against the pipeline.
  - Risk: Scratchpad is ephemeral — copy into the repo before it's lost. The `Prim` palette values are my placeholders to make the tests real; the artist replaces the ~14 hex values and the tests re-verify automatically. That substitution is the whole point of the tier boundary.
- **Enforce the hex-literal rule with a lint, not a promise: add `custom_lint` or a 3-line CI grep — `grep -rn '0xFF' lib/ --include=*.dart | grep -v 'lib/theme/tokens.dart'` must return empty.**
  - Why: The primitive/semantic tier boundary is the load-bearing architectural claim, and it is worth exactly nothing if it isn't mechanically enforced. Every design system that rotted, rotted by someone typing a hex into a widget at 11pm.
  - Risk: Will false-positive on `toARGB32()` test output or icon data. Scope the grep to `Color(0x` to narrow it.
- **Write the contrast test as a data-driven `typedef Pairing = ({String name, Color fg, Color bg, double min})` list generated per `AacThemeMode.values`, not as hand-written per-theme test bodies.**
  - Why: Adding a 4th theme later costs ZERO new test code — the loop picks it up. Adding a new semantic color costs one line in `pairingsFor`. This is the property that makes the test survive contact with a tired solo dev.
  - Risk: A new semantic color added to AacTheme but forgotten in pairingsFor is silently untested. Mitigate with a test asserting the pairing count matches expectation, so adding a field forces a conscious decision.
- **Hold show mode to AAA (7:1), not AA — and hard-code `showModeSurface: Prim.white, showModeInk: Prim.black` in ALL THREE themes including dark. Measured 21.00:1 everywhere.**
  - Why: Show mode's reader is a stranger, at arm's length, in daylight, and the user cannot repeat themselves or explain. There is no recovery path if it's unreadable, so it does not get the same threshold as surfaces the user reads themselves. This is the 'opposite optimization' from the brief, encoded as a CI assertion rather than a comment someone deletes.
  - Risk: A white full-screen flash when a dark-mode user enters show mode is a sensory hazard for exactly this audience — a max-luminance surface appearing suddenly. Genuinely conflicts with the sensory constraint. Needs a mitigation the token layer can't provide: consider a brief user-controlled brightness ramp on the OS screen brightness rather than the surface color, or make show-mode polarity a settings toggle defaulting to light. Flag to the parent — this is a real unresolved tension, not a solved one.
- **Assert the pressed state (`tileInk on tilePressed`) as a first-class pairing, not just the resting state. Measured: light 13.25:1, dark 6.26:1, HC 10.40:1.**
  - Why: The label does not recolor on press, so the same ink must survive two different backgrounds. This is the single pairing most likely to rot, because nobody screenshots a pressed state and no golden test captures one.
  - Risk: Dark's 6.26:1 has the least headroom of any tile pairing — a future 'make the press more visible' tweak to tilePressed will trip it. That's the test working, but expect it to fire.
- **`splashFactory: NoSplash.splashFactory` + a custom `_NoTransitionsBuilder` PageTransitionsBuilder returning `child` unchanged, both set once in the shared `_build()`.**
  - Why: The animation ban must be enforced at the THEME root, not per-widget. Material's default ink splash is an animation, and it is on by default on every InkWell — so 'we don't animate' is false the moment anyone uses a Material button. One line at the root kills it globally and permanently.
  - Risk: Removing all press feedback creates a real problem: a user in a shutdown with motor imprecision gets zero confirmation their tap registered. The tile MUST still change color on press instantly (hence tilePressed) — the ban is on the ANIMATED ripple, not on state change. Do not let 'zero animation' become 'zero feedback'; that would be a worse failure than the ripple.
- **Assert the research constraints as tests, not just as comments: `expect(t.tileGap, greaterThanOrEqualTo(12.0))` for every theme, plus a widget test pumping the grid at `TextScaler.linear(2.0)` asserting no RenderFlex overflow.**
  - Why: The 76dp/12dp floors and the 200% TextScaler requirement came from research at real cost. Encoded as a comment they survive until the first layout tweak; encoded as a test they survive forever. The TextScaler overflow test is also the single test that catches the most likely real-world MVP bug.
  - Risk: The overflow test needs a real widget tree, so it's the one place golden-adjacent machinery creeps in. Keep it as a plain widget test asserting `tester.takeException()` is null — no PNG, no blessing.
- **Cycle themes with a flat `AacThemeMode.values[(i+1) % 3]` on one tap, persisted as an int index — never a 2D (brightness × contrastLevel) control.**
  - Why: Directly follows from choosing 3 discrete themes over 2×contrast. A user in a shutdown has reduced decision-making; one tap must produce one predictable next state, not open a settings surface.
  - Risk: Cycling means reaching high-contrast from light costs 2 taps. Acceptable — but the cycle ORDER matters (light→dark→HC→light) and the current mode must be legible at a glance without reading, or the user taps blindly. The tile palette itself is that signal.
- **Name primitives `Prim.inkT06` / `Prim.clayT40` (family + HCT tone), semantics `tileInk` / `showModeSurface` (component + property). Ban `grey700`, `colorDarkGrey`, `brandPrimary` outright.**
  - Why: Tone is a measured lightness — it stays true forever and inverts correctly across themes by construction. Appearance names invert catastrophically (`darkGrey` is your lightest color in dark mode), rank names have no room for insertion, brand names die with the brand.
  - Risk: Requires the artist to think in HCT tone, which is unfamiliar. Material Theme Builder's HCT picker is the bridge — use it as a visualizer to read tone values off the colors they pick, then hand-type them.
- **`AacTheme.of(context)` asserts non-null and throws in debug. Never write a `?? AacTheme.fallback()`.**
  - Why: A fallback theme is a palette that no test has ever verified, silently shipped to a user who may be mid-shutdown. Loud failure in debug is strictly better than a quiet untested palette in production.
  - Risk: An assert-only guard means release builds get a null-check crash instead. That's still correct — but ensure the extension is registered in the single `_build()`, which structurally makes it impossible to forget for a new theme.

## References

- **rydmike/flex_seed_scheme** https://pub.dev/packages/flex_seed_scheme
  - Steal: The FlexTones concept — decoupling 'which tone maps to which ColorScheme role' from the seed algorithm. Even if you don't add the dependency (and for a 2-week MVP you shouldn't), read its tone-mapping tables to understand what fromSeed is actually doing to your 8 override colors. v4.0.1, verified publisher, 475k downloads. Its `respectMonochromeSeed` and 'remove color tint from surfaces' options are exactly the levers a muted-palette app wants if fromSeed's tonalSpot proves too colorful.
- **Betterment/alchemist** https://github.com/Betterment/alchemist
  - Steal: The inherited-theming pattern (theme via pumpWidget callback rather than global config) — that's the right shape for 3-theme golden coverage IF you later decide you need it. Steal the pattern, resist the 24 PNGs. Also the successor to the discontinued golden_toolkit; use it, not the tutorials that still recommend golden_toolkit.
- **Material Theme Builder (material-foundation)** https://material-foundation.github.io/material-theme-builder/
  - Steal: ONLY the HCT picker, as a visualizer. Tune hue/chroma/tone, copy hex out, hand-type into `Prim`. Do NOT look for a Flutter export — it doesn't exist (issue #50 closed unimplemented). Its Kotlin/XML exports are worth reading once to see the role list M3 expects you to fill.
- **WCAG 2.2 Understanding 1.4.11 Non-text Contrast** https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html
  - Steal: The applicability clause — specifically the exemption for components identified by their own text label. This is the citation that keeps the contrast test from forcing the grey rectangle grid. Read the 'required to identify' language before writing any border assertion.
- **Flutter wide-gamut Color migration guide** https://docs.flutter.dev/release/breaking-changes/wide-gamut-framework
  - Steal: The specific deprecations that break copy-pasted contrast math: `.value`→`.toARGB32()`, `withOpacity()`→`withValues(alpha:)`, and the fact that `.r/.g/.b/.a` are now doubles 0.0-1.0 not ints 0-255. Read before writing any color arithmetic.
- **DTCG Format Module 2025.10** https://www.designtokens.org/tr/drafts/format/
  - Steal: Read it, then don't adopt it. Worth 20 minutes to see the theming/mode model — it validates the primitive/semantic tier split. But its whole reason to exist is tool interop across a designer/engineer boundary that doesn't exist here. Revisit only if a second person joins or a web/iOS port needs the same palette.

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


YOUR DIMENSION: How a design system is actually built and shipped in a Flutter codebase in 2026 — the engineering of design.

Research with WebSearch/WebFetch: design tokens (the W3C Design Tokens Community Group format — what's its 2026 status? did it reach spec?), Style Dictionary, Material Theme Builder, Figma→Flutter pipelines, ThemeExtension patterns, and real open-source Flutter design systems worth reading.

- **Token architecture**: the 3-tier model (primitive/reference → semantic/alias → component). Is that right for a one-screen app, or is it enterprise ceremony? Be honest — but note this app has 3 themes × several text scales, which is exactly the situation tokens exist for. Resolve.
- **How to express tokens in Flutter**: `ThemeExtension<T>` (show real, complete code including `copyWith` and `lerp` — and note `lerp` matters not at all here since we ban animation; does that simplify it? Can lerp just return `this`?), vs plain static const classes, vs `ColorScheme` + `TextTheme` alone. Which for this app? Argue.
- Is `ColorScheme.fromSeed` sufficient, or does a bespoke palette need hand-authored `ColorScheme(...)`? What are the trade-offs (fromSeed gives you M3's tonal correctness and a11y-safe pairings for free, but you lose exact control — and a *designed* palette is the point here). Can you seed and then override specific roles? Show how.
- **Material Theme Builder** and the HCT tooling — is it usable in 2026, and does it export Flutter code? What's the actual workflow from "I picked some colors" to "ThemeData"?
- **Figma**: is it worth a solo dev designing in Figma first, or designing in Flutter directly (hot reload as the design tool)? Argue honestly — this is a real decision for a solo dev with a 2-week MVP. What's lost by skipping Figma? (Note: Flutter's hot reload makes it plausibly the best design tool for its own apps. But it's terrible for exploring divergent directions.)
- **Testing a design system**: golden tests per theme? (Note prior research is deciding this separately — coordinate: a fixed grid × 3 themes × N text scales is either the ideal golden case or a maintenance trap.) Can you test that all token pairings meet contrast? **A test that asserts every semantic color pairing passes WCAG contrast, for all 3 themes, is a real and cheap test — design it.** That's a design system verified by CI, which is the kind of move this project's constraints reward.
- **Structuring the theme code**: where do tokens live, how do 3 themes share structure, how does high-contrast relate to dark/light (a third theme, or a modifier on each? — that's a real architecture question: 2 themes × contrast levels, or 3 discrete themes? Material has "contrast levels" now — VERIFY `ColorScheme.fromSeed`'s `contrastLevel` param and whether it's in Flutter 3.44).
- Dynamic color / Material You (Android wallpaper-based theming, `dynamic_color` package): should this app support it? **Strong argument against**: the palette is designed, and a user's wallpaper could produce a garish or low-contrast result in a safety-relevant app. But it's also a beloved Android feature and reads as "current". Argue and decide.
- Naming conventions for tokens that don't rot.

Give real, complete, compiling code for the token layer. This is the bridge from design to codebase.
````

</details>
