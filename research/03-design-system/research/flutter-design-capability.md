# flutter-design-capability

> Phase: **research** · Agent `a10aabe64bac1a949` · Run `wf_f237e8a6-694`

## Result

## Summary

Flutter 3.44 (stable, May 2026) can render essentially everything this brief needs, and the app's static, non-scrolling nature makes most of it free — but for a subtler reason than "the raster cache saves us." Impeller has NO raster cache; the reason a static UI is cheap is that Flutter schedules no frames when nothing is dirty. That distinction matters enormously here, because the type-to-speak field's blinking cursor schedules a frame roughly every 500ms while focused, and every such frame re-renders the damage region from scratch. That single fact kills BackdropFilter (6-9ms raster on mid-tier Android, no cache, re-paid on every cursor blink) and strongly favors a bundled grain PNG over a FragmentProgram. The biggest genuine wins available in 2026 are: RoundedSuperellipseBorder (Flutter 3.32+, the only GPU-implemented, actually-correct Apple-squircle in the ecosystem — ContinuousRectangleBorder needs a 2.3529x fudge factor and still breaks down); Atkinson Hyperlegible Next (Feb 2025, variable, 7 weights, 150+ languages, OFL) driven by FontVariation.weight() for arbitrary non-discretized weights; and TextHeightBehavior leading-trim, which is the line between amateur and professional vertical rhythm in a grid of tiles. Material 3 Expressive is NOT in Flutter and is not being worked on — the team explicitly refuses contributions — so all "expressive" character must be hand-rolled, which is fine because this app uses almost no Material widgets. The correct token architecture is a hand-authored ThemeExtension, NOT ColorScheme.fromSeed's algorithmic variants: `vibrant` maxes primary chroma (directly hostile to the sensory constraint) and `expressive` rotates the primary hue AWAY from your seed, meaning the algorithm overrides the exact muted hues you chose. Two real hazards to flag: Impeller's Vulkan→OpenGL ES fallback corrupts radial gradients on some old Android devices (open P2, #179268), and MaterialApp animates theme changes by default (200ms) unless explicitly zeroed.

### Impeller has no raster cache. A static UI is cheap because no frames are scheduled when idle — not because anything is cached.

*Confidence: high, **LOAD-BEARING***

The Flutter team decided not to port the picture raster cache to Impeller (due to problems with its complexity-based scoring heuristics, flutter/flutter#131206, #88832). Impeller redraws every frame in real time. Consequence: the common claim 'expensive-per-frame effects are free in a static UI' is TRUE but only via a different mechanism — Flutter's pipeline produces a frame only when something is marked dirty. The moment ANY frame is produced, the full damage region is re-rendered from scratch with zero caching. Impeller does support partial-repaint/damage-rect scoping on Android and iOS, which limits the blast radius — but a full-screen BackdropFilter defeats damage-rect scoping because it must sample the whole backdrop.

- https://github.com/flutter/flutter/issues/131206

- https://github.com/flutter/flutter/issues/166184

- https://docs.flutter.dev/perf/impeller

- https://docs.flutter.dev/perf/ui-performance

### The type-to-speak field's blinking cursor is the hidden frame-scheduler that breaks the 'static UI = free' reasoning.

*Confidence: medium, **LOAD-BEARING***

EditableText blinks its cursor while focused, scheduling a frame roughly every 500ms. With no raster cache in Impeller, each of those frames re-renders the damage region. This is the concrete reason an expensive background effect is NOT free in this app: the type-to-speak field is on the SAME surface as the grid, so a focused field means continuous frame production. Corroborating evidence that Flutter treats this as a real cost: dart:ui AccessibilityFeatures now exposes `deterministicCursor` — 'show deterministic (non-blinking) cursor in editable text fields' — though note MediaQueryData does NOT expose it, so you cannot read it via MediaQuery; you'd need ui.window/PlatformDispatcher.instance.accessibilityFeatures.

- https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures-class.html

- https://api.flutter.dev/flutter/widgets/MediaQueryData-class.html

### BackdropFilter is the most expensive thing Flutter ships and should be banned from this app on latency AND legibility grounds.

*Confidence: high, **LOAD-BEARING***

BackdropFilter composes a saveLayer plus an ImageFilter (Gaussian blur) sampling the backdrop. Reported cost: 6-9ms of raster alone for a single full-width BackdropFilter at sigma:20 on mid-tier Android. Impeller GPU-accelerates it but the cost remains significant, and there are open performance regressions (flutter/flutter#126353 'Blur BackdropFilter performance degradation', #161297 'iOS BackdropFilter Performance Issues with Impeller'). Flutter 3.29 added BackdropGroup + BackdropFilter.grouped + BackdropKey so multiple blurs share ONE backdrop pass — genuinely useful, but it optimizes the many-blurs case this app doesn't have. Combined with the cursor-blink finding and the a11y cost of text-over-blur (the iOS Liquid Glass legibility backlash), the verdict is: no blur anywhere.

- https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html

- https://api.flutter.dev/flutter/widgets/BackdropGroup-class.html

- https://api.flutter.dev/flutter/widgets/BackdropFilter/BackdropFilter.grouped.html

- https://github.com/flutter/flutter/issues/126353

- https://github.com/flutter/flutter/issues/161297

- https://blog.flutter.dev/whats-new-in-flutter-3-29-f90c380c2317

### RoundedSuperellipseBorder (Flutter 3.32+) is the only correct Apple squircle in the Flutter ecosystem, and it is GPU-implemented.

*Confidence: high, **LOAD-BEARING***

Flutter 3.32 shipped RoundedSuperellipseBorder (ShapeBorder), ClipRSuperellipse (widget), plus low-level Canvas.drawRSuperellipse, Canvas.clipRSuperellipse, Path.addRSuperellipse. Per rydmike's squircle_study: it is 'the only super ellipse shape that is a match for the one used in iOS' and 'the only known shape that can handle all edge cases correctly', maintaining continuous curvature at all radii and degrading gracefully to stadium. It is the ONLY shape with GPU implementation support in the SDK. Supported on iOS and Android (VM builds); on web it silently falls back to a circular RoundedRectangleBorder — irrelevant for this Android-first app. By contrast ContinuousRectangleBorder is a poor approximation: it needs its radius multiplied by ~2.3529 to approach an iOS squircle, and still exhibits 'TIE-fighter' breakdown at higher radii. Flutter 3.44 added RoundedSuperellipseInputBorder (#177220) — directly usable for the type-to-speak field — and improved the superellipse path algorithm at very large ratios (#180453).

- https://api.flutter.dev/flutter/widgets/ClipRSuperellipse-class.html

- https://github.com/rydmike/squircle_study/blob/master/README.md

- https://blog.flutter.dev/whats-new-in-flutter-3-32-40c1086bab6e

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

### Material 3 Expressive is not in Flutter, is not being developed, and contributions are refused.

*Confidence: high, **LOAD-BEARING***

Umbrella issue flutter/flutter#168813 ('Bring Material 3 Expressive to Flutter'). Flutter team statement: 'we are not actively developing Material 3 Expressive right now, and we will not be accepting contributions for Expressive features or updates at this time.' 15 components proposed (button groups, carousel, FAB menu, loading indicator, split button, toolbars...), none in development. As of the July 29 2025 update, material and cupertino are being decoupled into standalone packages (tracking #101479) and all future Expressive work would happen there. Flutter 3.44's release notes show that decoupling work is actively in progress (extensive removal of Material cross-imports from widget tests) but still no Expressive widgets. So: everything 'expressive' is hand-rolled. This is a non-problem here — a 3x4 grid of custom-painted tiles plus one text field uses almost no Material widgets anyway.

- https://github.com/flutter/flutter/issues/168813

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

- https://m3.material.io/develop/flutter

### The DynamicSchemeVariant enum has exactly 9 values, and the two that 'sound relevant' (vibrant, expressive) are the two that actively fight this brief.

*Confidence: high, **LOAD-BEARING***

Verified from api.flutter.dev: tonalSpot ('Default for Material theme colors. Builds pastel palettes with a low chroma'), fidelity ('The resulting color palettes match seed color, even if the seed color is very bright (high chroma)'), monochrome ('All colors are grayscale, no chroma'), neutral ('Close to grayscale, a hint of chroma'), vibrant ('Pastel colors, high chroma palettes. The primary palette's chroma is at maximum'), expressive ('Pastel colors, medium chroma palettes. The primary palette's hue is DIFFERENT from the seed color, for variety'), content ('Almost identical to fidelity. Tokens and palettes match the seed color'), rainbow ('A playful theme - the seed color's hue does not appear in the theme'), fruitSalad (same description). Analysis: `vibrant` maxes primary chroma — directly violates the sensory-sensitivity constraint. `expressive` ROTATES the primary hue away from your seed — i.e. it takes away the exact control a designer picking 2-5 intentional muted hues needs. `rainbow`/`fruitSalad` are self-evidently out. Only `fidelity`/`content` preserve your chosen hex. Added to fromSeed via Hixie's PR #144805.

- https://api.flutter.dev/flutter/material/DynamicSchemeVariant.html

- https://github.com/flutter/flutter/pull/144805

- https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html

### ColorScheme.fromSeed has a contrastLevel parameter that gets you most of a high-contrast theme in one line — but it only touches ColorScheme roles, not your ThemeExtension tokens.

*Confidence: high, **LOAD-BEARING***

Verified signature: ColorScheme.fromSeed({required Color seedColor, Brightness brightness = Brightness.light, DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot, double contrastLevel = 0.0, ...plus optional overrides for every color role including primary/onPrimary/primaryContainer/primaryFixed/primaryFixedDim/onPrimaryFixed/onPrimaryFixedVariant and the secondary/tertiary/error/surface/outline families}). Docs quote: '0.0 is the default (normal); -1.0 is the lowest; 1.0 is the highest. From Material Design guideline, the medium and high contrast correspond to 0.5 and 1.0 respectively.' LOAD-BEARING CAVEAT: contrastLevel regenerates the ColorScheme's tonal roles. If (as recommended) your tile colors live in a hand-authored ThemeExtension, contrastLevel does nothing to them. You must author the high-contrast token set yourself. Do not let this parameter create false confidence.

- https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html

### Atkinson Hyperlegible Next (Feb 2025) is a variable font with 7 weights — and FontVariation lets you use arbitrary, non-discretized weights.

*Confidence: high, **LOAD-BEARING***

Braille Institute launched Atkinson Hyperlegible Next on 2025-02-10: 150+ languages (up from 27), seven weights Light→Extrabold in upright and italic, plus a VARIABLE version and a Monospace version. Free via Google Fonts and brailleinstitute.org/freefont. Flutter's FontVariation API (verified from api.flutter.dev): main constructor FontVariation(String axis, double value) plus named constructors FontVariation.weight(double), .width(double), .slant(double), .opticalSize(double), .italic(double); properties `axis` (String tag) and `value` (double); static lerp(). Used via TextStyle(fontVariations: [FontVariation.weight(560)]). The docs page did not state platform support or caveats — treat Android VF rendering as needing a device check.

- https://www.brailleinstitute.org/freefont/

- https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html

- https://api.flutter.dev/flutter/dart-ui/FontVariation-class.html

- https://pimpmytype.com/font/atkinson-hyperlegible-next/

### Flutter HAS leading trim, via TextHeightBehavior — and it is the single highest craft-per-line-of-code move available.

*Confidence: high, **LOAD-BEARING***

Verified API: TextHeightBehavior({bool applyHeightToFirstAscent = true, bool applyHeightToLastDescent = true, TextLeadingDistribution leadingDistribution = TextLeadingDistribution.proportional}). Setting applyHeightToFirstAscent:false removes the height-derived padding above the first line (uses the font's default ascent instead); applyHeightToLastDescent:false does the same below the last line. leadingDistribution is applied BEFORE those two flags. TextLeadingDistribution.even splits leading equally above/below (CSS half-leading model) instead of the font's proportional split. Docs warn leading can go negative when .even is combined with TextStyle.height much smaller than 1.0. This is what makes a multi-line tile label sit optically centered in its tile rather than 1-3px high. Also available: DefaultTextHeightBehavior (inherited widget) to set it app-wide, and TextStyle.leadingDistribution for per-style control. Known related pain: flutter/flutter#72521 'Text is not vertically centered with customized height'.

- https://api.flutter.dev/flutter/dart-ui/TextHeightBehavior-class.html

- https://api.flutter.dev/flutter/dart-ui/TextHeightBehavior/leadingDistribution.html

- https://api.flutter.dev/flutter/widgets/DefaultTextHeightBehavior/textHeightBehavior.html

- https://github.com/flutter/flutter/pull/77001

### Fragment shaders work well in 2026 with Impeller, but are the WRONG tool for static grain/texture in this specific app.

*Confidence: high, **LOAD-BEARING***

State of the art: shaders are authored as GLSL .frag, declared in pubspec under a `shaders:` section, compiled at BUILD time by impellerc and bundled as precompiled binaries — the old Skia runtime-compile-on-first-use jank is gone. Loaded via `ui.FragmentProgram.fromAsset()` which returns a FUTURE (async, relatively expensive; must be loaded once and cached, never per frame), then `.fragmentShader()` yields cheap reusable instances. Documented limitations: no UBOs/SSBOs; sampler2D is the only sampler type; only the 2-arg texture(sampler, uv); no custom varyings; no unsigned ints or booleans; use FlutterFragCoord() not gl_FragCoord; explicit `out vec4 fragColor` required (Impeller rejects gl_FragColor); ImageFilter-with-custom-shader is Impeller-only and throws elsewhere. WHY IT'S WRONG HERE: (1) fromAsset is async — you must either await it before first paint (adds cold-start latency to an app whose entire premise is instant access during a shutdown) or paint a flash of unshaded UI; (2) it buys you nothing a PNG doesn't in a UI that never animates; (3) it adds a GLES-fallback surface area on old Android. A shader is the right call for animated/parametric effects. This app has none.

- https://docs.flutter.dev/ui/design/graphics/fragment-shaders

- https://api.flutter.dev/flutter/dart-ui/FragmentProgram/fromAsset.html

- https://docs.flutter.dev/perf/impeller

### Open P2 bug: Impeller's Vulkan→OpenGL ES fallback corrupts radial gradients on some Android devices.

*Confidence: high, **LOAD-BEARING***

flutter/flutter#179268, status OPEN, labels P2/rendering/device-specific/Impeller/Android/engine-team. Radial gradients render corrupted specifically when Impeller falls back from Vulkan to OpenGL ES. Reproduced on Flutter 3.38.3 and 3.39.0-1.0.pre-340 master; NOT present in 3.27.4 or with Impeller disabled — a regression. Confirmed on a Positivo Q20, Android 10, PowerVR IMG8322 GPU. Context: Impeller is default on Android API 29+, prefers Vulkan, falls back to OpenGL ES 2.0 automatically; Android 9 and older unconditionally use OpenGL. For an Android-first app that wants gradient-driven beauty, this is a real tail risk on cheap/old hardware — which is disproportionately what a disabled-user audience carries. Mitigation: prefer LinearGradient over RadialGradient, and test on a real pre-Vulkan / weak-GPU API 29 device.

- https://github.com/flutter/flutter/issues/179268

- https://docs.flutter.dev/perf/impeller

- https://github.com/flutter/engine/blob/main/impeller/docs/android.md

### MaterialStateProperty is deprecated; WidgetStateProperty is current in 3.44.

*Confidence: high, **LOAD-BEARING***

MaterialState/MaterialStateProperty and the whole MaterialState* family were deprecated after v3.19.0-0.3.pre and moved to the widgets layer as WidgetState/WidgetStateProperty (so they're usable outside Material). They survive as typedefs, so old code compiles, but tracking issue flutter/flutter#148218 exists to remove all internal use. Official migration guide at docs.flutter.dev/release/breaking-changes/material-state. Use WidgetStateProperty. Relevant here: WidgetStateProperty<Color>.resolveWith on the tile's overlayColor is how you get instant press feedback, and `splashFactory: NoSplash.splashFactory` is how you kill the ripple (which is an animation, and therefore banned).

- https://docs.flutter.dev/release/breaking-changes/material-state

- https://api.flutter.dev/flutter/material/MaterialStateProperty.html

- https://github.com/flutter/flutter/issues/148218

### The real AccessibilityFeatures list has 11 flags; MediaQueryData exposes only 8 of them. reduceMotion and deterministicCursor are NOT readable via MediaQuery.

*Confidence: high, **LOAD-BEARING***

dart:ui AccessibilityFeatures (verified): accessibleNavigation, autoPlayAnimatedImages, autoPlayVideos, boldText, deterministicCursor, disableAnimations, highContrast, invertColors, onOffSwitchLabels, reduceMotion, supportsAnnounce. MediaQueryData exposes: accessibleNavigation, boldText, disableAnimations, highContrast, invertColors, onOffSwitchLabels, supportsAnnounce, navigationMode — plus textScaler, platformBrightness, size, orientation etc. NOT on MediaQueryData: reduceMotion, deterministicCursor, autoPlayAnimatedImages, autoPlayVideos. So MediaQuery has: disableAnimationsOf, highContrastOf, boldTextOf, accessibleNavigationOf, invertColorsOf, onOffSwitchLabelsOf, supportsAnnounceOf, textScalerOf, platformBrightnessOf, sizeOf, orientationOf (each with a maybe* null-returning variant). For reduceMotion/deterministicCursor you must read PlatformDispatcher.instance.accessibilityFeatures directly and listen to onAccessibilityFeaturesChanged — no automatic rebuild. NOTE: highContrast is documented as 'Whether the user requested a high contrast between foreground and background content' on MediaQueryData but as 'Signals that UI be rendered with darker colors' in dart:ui — the semantics are iOS-flavored (Increase Contrast); do NOT rely on it alone for the high-contrast theme, ship an explicit in-app toggle. Flutter 3.44 also added iOS motion accessibility features (#178102) — worth checking whether that wires reduceMotion through on iOS.

- https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures-class.html

- https://api.flutter.dev/flutter/widgets/MediaQueryData-class.html

- https://api.flutter.dev/flutter/widgets/MediaQuery-class.html

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

### ThemeExtension is the correct, officially-blessed way to ship a bespoke token system — and its lerp() is where you enforce zero animation.

*Confidence: high, **LOAD-BEARING***

Verified API: abstract class ThemeExtension<T extends ThemeExtension<T>> with const ThemeExtension() constructor, `Object get type`, `ThemeExtension<T> copyWith()`, `ThemeExtension<T> lerp(covariant ThemeExtension<T>? other, double t)`. Registered via ThemeData(extensions: <ThemeExtension<dynamic>>[...]), read via Theme.of(context).extension<T>()!. KEY INSIGHT FOR THIS APP: MaterialApp wraps in AnimatedTheme and interpolates ThemeData — including your extension's lerp() — over kThemeAnimationDuration (200ms) on theme change. Since animation is banned, implement lerp as a hard cut: `T lerp(T? other, double t) => t < 0.5 ? this : (other ?? this);` — this makes the one-tap theme switch instantaneous even if the AnimatedTheme is still nominally running.

- https://api.flutter.dev/flutter/material/ThemeExtension-class.html

### Wide-gamut Display P3 exists in Flutter but should not be relied on for an Android-first app; withOpacity is deprecated in favor of withValues.

*Confidence: medium*

Flutter 3.27 landed wide-gamut color: ui.ColorSpace enum has exactly three values — sRGB, extendedSRGB, displayP3. Access via the Color.from(alpha:, red:, green:, blue:, colorSpace:) constructor taking normalized doubles. Docs state P3 'is supported in cases like using Impeller on iOS'; on platforms that don't support it, colors are CLAMPED to sRGB. I could NOT verify Android P3 support status — flag this. Since this app is Android-first, author in sRGB and treat any P3 richness as a silent iOS bonus. Separately: Color.withOpacity() and Color.opacity are deprecated because they can cause unexpected data loss across color spaces; use color.withValues(alpha: 0.5). Flutter 3.44 also fixed P3→sRGB conversion to operate in linear light (#181720), which means gradient/blend fidelity improved.

- https://docs.flutter.dev/release/breaking-changes/wide-gamut-framework

- https://api.flutter.dev/flutter/dart-ui/ColorSpace.html

- https://github.com/flutter/flutter/issues/127855

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

### Mesh gradients are possible in Flutter but both packages are a bad bet for a solo developer here.

*Confidence: medium*

Two options: `mesh` (v0.5.0, last published ~14 months ago as of 2026-07 — i.e. stale; uses shaders + vertices; supports linear/LAB/xyY color spaces; tessellationFactor default 12 with triangle count (w-1)*(h-1)*(tess^2)*2; depends on archive, binarize, cached_value, flutter_shaders; notes Impeller issues 'resolved as of Flutter 3.24.3') and `mesh_gradient` (CustomPainter + FragmentShader, MeshGradient for static / AnimatedMeshGradient for animation, MeshGradientOptions exposes blend strength and noise intensity). Verdict: a stale 0.x dependency with a shader stack underneath, on the critical rendering path of an app that must launch instantly and never fail, for a visual effect that a 3-4 stop LinearGradient plus a grain PNG can approximate at 1% of the risk. The `mesh_gradient` package's built-in noise intensity is tempting, but you're buying an animation library to not animate.

- https://pub.dev/packages/mesh

- https://pub.dev/packages/mesh_gradient

- https://github.com/folksable/mesh_gradient/blob/main/README.md

- https://fluttergems.dev/effects-gradients-shaders/

### Flutter's OpenType feature support is comprehensive — 27 named FontFeature constructors — which is real, cheap typographic craft.

*Confidence: high*

Verified named constructors on dart:ui FontFeature: alternative, alternativeFractions, caseSensitiveForms, characterVariant, contextualAlternates, denominator, disable, enable, fractions, historicalForms, historicalLigatures, liningFigures, localeAware, notationalForms, numerators, oldstyleFigures, ordinalForms, proportionalFigures, randomize, scientificInferiors, slashedZero, stylisticAlternates, stylisticSet, subscripts, superscripts, swash, tabularFigures. Plus the escape hatches FontFeature.enable('ss01') / FontFeature.disable(tag) for any 4-char tag. Used via TextStyle(fontFeatures: [...]). Costs nothing at render time (it's shaping-time). Caveat: only works if the bundled font actually contains the feature — check the font's GSUB table before shipping a design that depends on one.

- https://api.flutter.dev/flutter/dart-ui/FontFeature-class.html

### Flutter 3.44 is the current stable (May 2026); Impeller is default on iOS/Android/macOS and text rendering is actively improving.

*Confidence: high*

Recent stable line: 3.35.0 → 3.38.0 → 3.41.0 → 3.44.0 (latest, May 2026, Dart 3.10). 3.44 rendering/text work: bilinear filtering for non-uniformly scaled text (#182224), a signed-distance-field text rendering switch with golden tests (#183543), P3→sRGB conversion in linear light (#181720), superellipse path algorithm improved at very large ratios (#180453), ShapeBorder paintInterior optimization for preferPaintInterior=true (#184258). Accessibility work: iOS motion accessibility (#178102), Android display corner radii (#179219), Android 36 CheckState APIs (#182113), a new non-text color-contrast accessibility evaluation (#183569 — directly useful, this can lint your tile-on-surface contrast). Impeller on Android: default at API 29+, prefers Vulkan, auto-falls-back to OpenGL ES 2.0; API 28 and below unconditionally OpenGL.

- https://docs.flutter.dev/release/release-notes

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

- https://docs.flutter.dev/perf/impeller

- https://github.com/flutter/engine/blob/main/impeller/docs/android.md

### Ranked cost list for this specific app — and most of it is genuinely free.

*Confidence: medium, **LOAD-BEARING***

Per-frame raster cost, most→least expensive: (1) BackdropFilter/ImageFilter.blur — 6-9ms, saveLayer + full backdrop sample, defeats damage-rect scoping, no cache to save you. BANNED. (2) Any saveLayer (Opacity widget over a subtree, ShaderMask, BlendMode that isn't srcOver on a group) — allocates an offscreen texture. Use color-with-alpha instead of Opacity; use a Container with a gradient instead of ShaderMask where possible. (3) FragmentShader paint — cheap per-frame with Impeller, but async load cost at startup. (4) Large PNG decode — one-time, at startup; a 256px tiled grain is negligible. (5) LinearGradient/RadialGradient in a BoxDecoration — Impeller-native, effectively free, EXCEPT for the GLES-fallback radial bug. (6) RoundedSuperellipseBorder — GPU-implemented, effectively free. (7) Custom ShapeBorder subclass returning a Path — cheap; Path construction happens at paint time and there's no raster cache, but a 12-tile grid of paths is nothing. (8) Text shaping — one-time per layout. THE LIBERATION IS REAL: this UI paints on cold start, on tap (one tile's overlay), on theme switch (one frame), and on cursor blink (one small damage rect). Everything except the cursor blink is a one-shot. So you can afford a LOT of static ornament — layered gradients, per-tile custom paths, textured surfaces, elaborate type — as long as you don't put it under a BackdropFilter that a blinking cursor forces to re-run.

- https://docs.flutter.dev/perf/ui-performance

- https://docs.flutter.dev/perf/impeller

- https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html

- https://github.com/flutter/flutter/issues/131206

### CustomPainter vs composed widgets: the boundary is semantics, not performance.

*Confidence: medium*

In an app with no scrolling and no animation, the perf argument for CustomPainter mostly evaporates — a Container with a BoxDecoration(gradient, borderRadius/shape, image) is compiled down to roughly the same draw calls. The real reason to prefer composed widgets here is ACCESSIBILITY: a CustomPainter paints pixels and contributes NO semantics tree. A tile drawn in a CustomPainter is invisible to TalkBack unless you manually wrap it in a Semantics widget with label/button/onTap. Since this app's users disproportionately use screen readers and switch access, and since Flutter 3.44 added an automated non-text color-contrast accessibility evaluation (#183569) that operates on the widget/semantics layer, staying in widgets keeps you inside the tooling. Reach for CustomPainter only for genuinely non-widget-expressible ornament (a hairline flourish, an asymmetric edge treatment), and always inside a RepaintBoundary-free, Semantics-wrapped, ExcludeSemantics-marked decoration layer.

- https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

## Design moves

- **Hand-author every color token in a ThemeExtension. Use ColorScheme.fromSeed ONLY as a scaffold to fill the Material roles you don't care about, and if you use it, pass dynamicSchemeVariant: DynamicSchemeVariant.fidelity (or .content) — never .expressive or .vibrant.**
  - Why: This is the single most important architectural call. `vibrant` sets 'the primary palette's chroma at maximum' — the opposite of the sensory-sensitivity constraint. `expressive` explicitly 'the primary palette's hue is different from the seed color, for variety' — it will silently discard the exact 2-5 muted hues you chose. The M3 tonal algorithm is designed for apps that DON'T have a designer. This one does. Only fidelity/content preserve your hex. Ship your palette as `class AacTokens extends ThemeExtension<AacTokens>` with named fields (tileSurface, tileInk, categoryA..E, showModeInk, ...) and three const instances: light, dark, highContrast.
  - Risk: Bypassing ColorScheme means bypassing contrastLevel:1.0 for free high-contrast — you now hand-author the HC token set, which is more work but is also the only way to hit real luminance-contrast targets. Also: any Material widget you DO use (the TextField, dialogs in edit mode) still reads ColorScheme, so the two systems must be kept visually in sync or the app will look like two apps.
- **Implement ThemeExtension.lerp as a hard cut: `AacTokens lerp(AacTokens? other, double t) => t < 0.5 ? this : (other ?? this);` AND set MaterialApp(themeAnimationDuration: Duration.zero) — verify that param name against 3.44 docs before relying on it.**
  - Why: MaterialApp wraps everything in an AnimatedTheme that interpolates ThemeData — including your extension's lerp() — over kThemeAnimationDuration (200ms) by default. The one-tap theme switch will CROSSFADE unless you stop it, which violates zero-animation on the exact interaction the brief calls out as needing to be one tap. Belt and braces: kill it at both the extension level (hard-cut lerp) and the app level.
  - Risk: I did not verify `themeAnimationDuration`/`themeAnimationStyle` on MaterialApp in the 3.44 API docs — flagged as unverified, check api.flutter.dev/flutter/material/MaterialApp-class.html before writing code. The hard-cut lerp is verified-safe regardless and is sufficient on its own for your own tokens; the risk is that Material's OWN ColorScheme still crossfades, producing a 200ms mismatch between your tiles (instant) and the text field (fading) — visually worse than either extreme.
- **Tiles: RoundedSuperellipseBorder with a corner radius around 20-24dp on a ≥76dp tile — NOT RoundedRectangleBorder(8), NOT ContinuousRectangleBorder. Text field: RoundedSuperellipseInputBorder (new in 3.44, #177220).**
  - Why: This is free beauty. It's GPU-implemented (the only shape in the SDK that is), it's the only accurate iOS-style squircle in the Flutter ecosystem per rydmike's comparison study, it handles all edge cases and degrades gracefully toward stadium, and it costs nothing per frame in a static UI. A 20-24dp continuous-curvature radius on a large tile is the difference between 'grid of buttons' and 'considered object'. ContinuousRectangleBorder is a trap: it needs its radius multiplied by 2.3529 to even approximate the shape and still TIE-fighters at high radii.
  - Risk: Web-only fallback to circular rounding — irrelevant, this is Android-first. Real risk: a large radius eats interior area, and the 76dp target floor plus a 20-24dp radius plus a large TextScaler value squeezes the label. Verify at 200% text scale on a 76dp tile before committing to the radius. Also unverified: whether RoundedSuperellipseBorder's GPU path is present on the Impeller OpenGL ES fallback backend, or whether it degrades there like gradients do (#179268).
- **Grain/texture: bundle a single ~256x256 seamless PNG (~8KB), tile it with DecorationImage(repeat: ImageRepeat.repeat, opacity: 0.03-0.06) — do NOT write a noise FragmentProgram.**
  - Why: In a UI that never animates, a shader buys you exactly nothing a PNG doesn't, and costs three things: FragmentProgram.fromAsset is async, so you either await it before first paint (adding cold-start latency to an app whose whole premise is instant access during a shutdown) or you flash unshaded UI; it adds GLES-fallback surface area on the cheap old Android hardware this audience actually carries; and it's more code for a solo dev to maintain. The PNG decodes once at startup and then it's a texture. Grain is also the single cheapest way to make flat muted color stop looking like a 2014 enterprise screen — it's what print has been doing for 500 years.
  - Risk: Tiled PNG at low opacity can moiré or band on some panels, and interacts badly with invertColors (the grain inverts too, which is probably fine but should be looked at). Also: an overlay grain layer costs a saveLayer if you use a BlendMode other than srcOver over a group — apply it as a DecorationImage inside each surface's BoxDecoration rather than as one full-screen ShaderMask/BlendMask over the whole tree.
- **NO BackdropFilter, NO blur, anywhere — including behind the type-to-speak field.**
  - Why: Three independent kills. (1) Latency: 6-9ms raster for one full-width blur at sigma:20 on mid-tier Android, and Impeller has NO raster cache to amortize it. (2) The cursor-blink trap: the type-to-speak field is on the SAME surface as the grid, so while it's focused EditableText schedules a frame every ~500ms, and a full-screen BackdropFilter defeats damage-rect scoping — you re-blur the whole screen twice a second, forever, while the user is trying to type during a shutdown. (3) A11y: text over blur is the iOS Liquid Glass legibility backlash, and this audience is exactly who it fails. If you want depth, get it from layered opaque surfaces at different tones, a hairline outline, and grain.
  - Risk: The founder may read 'no blur' as 'no modern depth'. Counter with the layered-tone approach — M3's surfaceContainer/surfaceContainerHigh/surfaceContainerHighest tonal ladder gives real depth with zero blur. If blur ever becomes non-negotiable for a non-interactive decorative area, use BackdropGroup + BackdropFilter.grouped (3.29+) so multiple blurs share one backdrop pass — but the single-blur case this app has gets no benefit from grouping.
- **Bundle Atkinson Hyperlegible Next VARIABLE (not 7 static weights), and set label weight with FontVariation.weight(560) rather than FontWeight.w500/w600.**
  - Why: The brief says weight 500-600. That range implies the designer wants something BETWEEN the two — a variable font gives you 560, or 545, continuously. It also ships one file instead of seven (smaller APK for an offline app), covers 150+ languages (up from 27 in the 2019 original), is OFL, and comes from the Braille Institute so it carries the right provenance for this product. This is 2025 tech the 2019 Atkinson didn't have.
  - Risk: UNVERIFIED: the FontVariation docs page did not state platform support or caveats — I could not confirm Android variable-font axis rendering quality under Impeller on old devices. Test on a real API 29 device before committing; have static-weight fallbacks bundled. Also: boldText accessibility flag (MediaQuery.boldTextOf) must map to a heavier FontVariation.weight, not to Flutter's default synthetic-bold path, or you'll get faux-bold on top of a real weight axis and it'll look broken.
- **Apply leading trim to every tile label: DefaultTextHeightBehavior(textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false, leadingDistribution: TextLeadingDistribution.even)) wrapping the grid.**
  - Why: This is the highest craft-per-line-of-code move on the list and it's the specific thing that separates professional from amateur vertical rhythm. Without it, a TextStyle.height of 1.3 on a centered tile label pads the first ascent and last descent, so a one-line label and a two-line label sit at visibly different optical centers in identical tiles — across a 3x4 grid that reads as sloppy. With it, labels optically center regardless of line count. Costs zero at runtime (it's layout-time).
  - Risk: Docs warn leading can go NEGATIVE when TextLeadingDistribution.even combines with a TextStyle.height much below 1.0 — keep height ≥1.1. Also, once first-ascent/last-descent padding is removed, tall diacritics and descenders in the 150+ languages Atkinson Next supports can clip against the tile edge; pad the tile, don't rely on the line box. Related known pain: flutter/flutter#72521.
- **Honor TextScaler to 200%+ by auto-promoting to the 2x3 'large' layout above a threshold (~150%), rather than by wrapping, shrinking, or FittedBox-ing the label.**
  - Why: The brief has a real internal conflict: 'fixed 3x4 grid, fixed tile positions, never reflow' AND 'must honor TextScaler to 200%+ without clamping'. At 200% a 20pt label is 40pt and will not fit a 3x4 tile on a phone. FittedBox/AutoSizeText IS clamping, just disguised. The honest resolution: the layout is a user setting (3x4 or 2x3) that TextScaler can promote. Positions stay fixed WITHIN each layout, so position-as-retrieval-mechanism survives — the user learns two stable maps, not an infinite reflow.
  - Risk: This is the move most likely to break the position-memory constraint, which is the app's core retrieval mechanism. If the OS text scale can change under the user (it can — Android Display Size & Text settings), the grid could silently re-map mid-shutdown, which is exactly the failure this constraint exists to prevent. MITIGATION: make the promotion a persisted setting suggested once ('your text size is large — switch to the 2x3 layout?'), never an automatic live reflow. Read textScalerOf, but ACT on it only with consent. This needs a decision from the founder, not from me.
- **Tile press feedback: splashFactory: NoSplash.splashFactory + WidgetStateProperty<Color>.resolveWith((states) => states.contains(WidgetState.pressed) ? tokens.tilePressed : tokens.tileSurface). Note WidgetState, not MaterialState.**
  - Why: The Material ink ripple is an animation and is therefore banned — but removing it without replacement leaves a tile with NO press feedback, which is bad for a user with motor imprecision in a shutdown who needs to know the tap registered. An instant color swap is zero-duration, gives unambiguous feedback, and is one frame. MaterialState/MaterialStateProperty were deprecated after 3.19.0-0.3.pre and moved to the widgets layer; they survive as typedefs so old code compiles, but write WidgetState.
  - Risk: An instant color swap is itself a sudden visual change, which the trauma-informed guidance flags as a concern for sensitized nervous systems — the same reason motion is banned. A hard flash may be worse than a gentle one. Consider making the pressed state a small luminance step rather than a hue change, and pair it with haptic feedback (HapticFeedback.selectionClick) so the confirmation isn't purely visual. This deserves testing with actual users, not a designer's judgment.
- **Prefer LinearGradient over RadialGradient for tile and surface fills, and test on a real pre-Vulkan / weak-GPU Android 10 device before shipping any gradient-dependent design.**
  - Why: Gradients are the cheapest route to 'not a flat grey rectangle' and Impeller renders them natively at effectively zero cost in a static UI — a 3-stop LinearGradient across a tile at low chroma is free beauty. BUT flutter/flutter#179268 is an OPEN P2: radial gradients render CORRUPTED specifically when Impeller falls back from Vulkan to OpenGL ES (repro'd on a Positivo Q20, Android 10, PowerVR GPU; regression — fine in 3.27.4 and fine with Impeller off). Impeller is default at API 29+ and auto-falls-back to GLES. Cheap old Android is disproportionately what a disabled audience carries.
  - Risk: This is a tail risk I can't size — one open device-specific issue is not proof of a broad problem, and it may be fixed by the time you ship. But the failure mode is catastrophic and silent: the app looks broken on exactly the low-end hardware where you'll never see it. Mitigation is cheap (linear over radial, one device test), so take it. Do NOT let gradient subtlety become the load-bearing element of the visual identity — the design should still read if every gradient flattened to its mid-stop.
- **Skip the mesh gradient packages. If the founder wants that look, approximate with 2-3 stacked LinearGradient layers at low alpha plus the grain PNG.**
  - Why: `mesh` is v0.5.0 last published ~14 months ago (stale 0.x), pulls in archive/binarize/cached_value/flutter_shaders, and sits on the critical render path of an app that must launch instantly and never fail. `mesh_gradient` is CustomPainter+FragmentShader and its headline feature is ANIMATED mesh gradients — you'd be adopting an animation library specifically to not animate. For a solo dev on an offline app with no update-pressure release cadence, a stale 0.x rendering dependency is a liability that outlives the aesthetic payoff.
  - Risk: The stacked-gradient approximation genuinely is not as good as a real mesh gradient — this is a real aesthetic concession, not a free win, and I should not pretend otherwise. If the mesh look turns out to be load-bearing for the founder's vision, the honest path is to vendor the shader (it's one .frag) rather than take the package dependency, accepting the async-load cost. That's a founder call about how much the look is worth.
- **Show mode gets its own ThemeData with a hard-coded light, maximum-luminance-contrast palette — not a variant of the user's chosen theme — plus a screen-brightness boost via a native plugin.**
  - Why: The brief correctly identifies these as opposite optimizations: the user's eyes want low luminance, the cashier's eyes at arm's length in daylight want maximum. This isn't a theme toggle, it's a different product surface, so it should be a separate ThemeData applied by a Theme widget over the show-mode subtree — that way the user's dark preference is untouched and instantly restored on exit. Max-size type here can use FontVariation.weight at the heavy end of Atkinson Next's Extrabold axis, which is exactly what a variable font is for.
  - Risk: Boosting screen brightness requires a native plugin (e.g. screen_brightness) — that's a new dependency and a permission surface on an app whose entire pitch is 'nothing leaves the device'. Verify the plugin requests no network/no unexpected permissions before adding it, and be prepared to justify it in the store listing. Also: slamming to full brightness is itself a sudden sensory event for the user holding the phone, immediately before they hand it to a stranger. Ramp is banned (animation). This may need to be opt-in.
- **Stay in composed widgets with BoxDecoration; reach for CustomPainter only for ornament that genuinely can't be expressed as a decoration, and always wrap it in Semantics/ExcludeSemantics explicitly.**
  - Why: In a static, non-scrolling UI the performance argument for CustomPainter evaporates — a Container with BoxDecoration(gradient, shape: RoundedSuperellipseBorder(...), image: grain) compiles to roughly the same draw calls. The real boundary is semantics: a CustomPainter paints pixels and contributes NOTHING to the semantics tree, so a tile drawn that way is invisible to TalkBack unless you hand-build the Semantics node. This audience disproportionately uses screen readers and switch access. Staying in widgets also keeps you inside Flutter 3.44's new automated non-text color-contrast accessibility evaluation (#183569), which can lint your tile-on-surface contrast for you.
  - Risk: Low risk, but it does cap how weird the ornament can get — some of the 'creative, beautiful' moves the founder wants (asymmetric edge treatments, hairline flourishes, overlapping forms) may genuinely need a custom ShapeBorder subclass or ClipPath. That's fine: a custom ShapeBorder still participates in the widget/semantics tree, and Path construction for 12 tiles is nothing even with no raster cache. Use custom ShapeBorder before reaching for CustomPainter.

## References

- **rydmike/squircle_study** https://github.com/rydmike/squircle_study
  - Steal: The empirical comparison that settles the squircle question: RoundedSuperellipseBorder is the only accurate iOS squircle, ContinuousRectangleBorder needs a 2.3529x radius multiplier and still 'TIE-fighter' breaks down at high radii, figma_squircle degrades past ~50% stadium radius, smooth_corner is visually identical to figma_squircle but has no lerp. Steal the conclusion and the multiplier number; skip the packages entirely now that 3.32+ has the real thing.
- **flex_seed_scheme (RydMike)** https://pub.dev/packages/flex_seed_scheme
  - Steal: A more flexible ColorScheme.fromSeed. Worth reading even if you don't adopt it: it exists precisely because Flutter's tonal algorithm overrides designer intent, and its FlexTones API lets you pin chroma per palette. If the hand-authored ThemeExtension approach proves too much work, this is the escape hatch that keeps your muted hues muted while still generating the full role set.
- **Atkinson Hyperlegible Next (Braille Institute, Feb 2025)** https://www.brailleinstitute.org/freefont/
  - Steal: The variable version and the Extrabold axis. Seven weights, 150+ languages, OFL, free on Google Fonts. Steal: use the VF for arbitrary weights (560, not w500-or-w600), use the heavy end for show mode, and use the Mono cut for nothing in this app but know it exists. The provenance also matters — it's the accessibility-legitimate choice that doesn't look like an accessibility font.
- **Flutter fragment shaders docs** https://docs.flutter.dev/ui/design/graphics/fragment-shaders
  - Steal: The exact limitation list (no UBOs/SSBOs, sampler2D only, 2-arg texture() only, no custom varyings, no uints/bools, FlutterFragCoord() not gl_FragCoord, explicit `out vec4 fragColor` required — Impeller rejects gl_FragColor). Read it to confirm you're NOT using shaders here, and to know exactly what you'd be signing up for if the grain PNG ever proves insufficient.
- **BackdropGroup / BackdropFilter.grouped (Flutter 3.29+)** https://api.flutter.dev/flutter/widgets/BackdropGroup-class.html
  - Steal: The BackdropKey concept — multiple blurs sharing one backdrop pass. Not applicable to this app (banned blur, single surface), but it's the state of the art if the constraint ever lifts, and knowing it exists is what lets you say 'no blur' from knowledge rather than ignorance.
- **flutter/flutter#179268 (Impeller GLES gradient corruption)** https://github.com/flutter/flutter/issues/179268
  - Steal: The device profile to test against: Android 10, PowerVR-class GPU, Vulkan→GLES fallback. Steal this as your bottom-end test target. It's also a reminder that Impeller's fallback path is materially less-tested than its Vulkan path, and your audience skews toward the hardware that takes the fallback.
- **flutter/flutter#168813 (M3 Expressive umbrella)** https://github.com/flutter/flutter/issues/168813
  - Steal: The list of 15 proposed Expressive components (button groups, carousel, FAB menu, loading indicator, split button, toolbars...) — read it as a list of what you must hand-roll if you want that language, and as confirmation that the Flutter team's own design direction is frozen. For an app that uses almost no Material widgets, this is liberation: nobody's shipping a house style you have to fight.
- **TextHeightBehavior / TextLeadingDistribution API** https://api.flutter.dev/flutter/dart-ui/TextHeightBehavior-class.html
  - Steal: applyHeightToFirstAscent:false + applyHeightToLastDescent:false + TextLeadingDistribution.even, wrapped app-wide in DefaultTextHeightBehavior. Four lines. It's the leading-trim the brief asked about, it does exist, and it's the highest craft-per-keystroke change available.

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


YOUR DIMENSION: What can Flutter actually RENDER in 2026, and what does beauty cost in code and latency?

Research with WebSearch/WebFetch: api.flutter.dev, docs.flutter.dev, Flutter release notes 3.16→3.44, Impeller docs, pub.dev.

Every design move must be checked against: can Flutter do it, what does it cost, and does it break the a11y/latency constraints?

- **Theming**: `ThemeData`, `ColorScheme.fromSeed` (and `dynamicSchemeVariant` — what variants exist? tonalSpot/vibrant/expressive/fidelity/content/neutral/monochrome/rainbow/fruitSalad? VERIFY the enum and what each does — "expressive" and "vibrant" sound directly relevant), `ThemeExtension<T>` for custom design tokens (the right way to ship a bespoke token system — show real code), `MaterialStateProperty`/`WidgetStateProperty` (the rename happened — VERIFY which is current in 3.44).
- **Is Material 3 Expressive in Flutter yet?** Which parts? Check the umbrella issue and release notes. What must be hand-rolled?
- **Shape**: `ShapeBorder`, `RoundedRectangleBorder`, `ContinuousRectangleBorder` (is it a real squircle? It's known to be a poor approximation of Apple's — VERIFY and say what to do instead), `StarBorder`, custom `ShapeBorder` subclasses, `ClipPath`. Can Flutter draw a proper superellipse? Is there a package? Does it cost anything per frame in a static UI (probably not — confirm)?
- **Gradients**: `LinearGradient`/`RadialGradient`/`SweepGradient`. Mesh gradients — possible? (`mesh_gradient` package? fragment shaders?) Cost?
- **Fragment shaders**: `FragmentProgram`, GLSL→`.frag`, the `shaders:` pubspec section. What's the 2026 state with Impeller? What can you do (grain, noise, subtle texture, gradients)? What does it cost at startup (shader compilation — Impeller precompiles; does that solve the old shader-jank problem)? **Is a static grain/noise texture via shader worth it, or should it be a bundled PNG?** (For a static UI, a PNG is probably right — argue it.)
- **Blur/translucency**: `BackdropFilter`/`ImageFilter.blur` — the real performance cost (it's historically the most expensive thing in Flutter), and the a11y cost (legibility over blur; the iOS Liquid Glass backlash). Verdict for this app?
- **Text rendering**: how good is Flutter's text? Variable font support (`FontVariation` — VERIFY the API), `fontFeatures` (OpenType features — ss01, tnum, etc.), optical sizing, letter spacing precision, text shaping quality vs native. Any known text-rendering weaknesses? `TextHeightBehavior`/leading trim (is there leading-trim support in 2026? It's the difference between amateur and professional vertical rhythm — VERIFY).
- **Custom painting**: `CustomPainter` — when is it the right tool vs composing widgets?
- **Images**: bundling, resolution-aware assets, the icon-font tree-shaking thing.
- **What's expensive and would blow the latency budget?** Rank the costly things. Note the app is STATIC — many perf concerns evaporate. Is that liberating? Say so concretely: a static UI paints once, so per-frame cost is nearly irrelevant, which means expensive-per-frame effects may actually be FREE here. VERIFY that reasoning — is it true? (What about scrolling? The grid doesn't scroll. What about the raster cache?)
- **Dark/light/high-contrast theme switching** in Flutter: `ThemeMode`, `MediaQuery.platformBrightnessOf`, `highContrastOf`, `boldTextOf`, `disableAnimationsOf`, `accessibleNavigationOf`, `invertColorsOf`, `onOffSwitchLabelsOf`? Get the real list of `AccessibilityFeatures` and which have MediaQuery accessors.

Be concrete. Real APIs, real costs, verified names. Flag anything you couldn't verify.
````

</details>
