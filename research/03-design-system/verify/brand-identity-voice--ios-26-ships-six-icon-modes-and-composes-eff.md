# brand-identity-voice--ios-26-ships-six-icon-modes-and-composes-eff

> Phase: **verify** · Agent `a5d4fa727c968267f` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** iOS 26 renders six app icon appearances (Default, Dark, Clear Light, Clear Dark, Tinted Light, Tinted Dark), but as of the current Icon Composer you author only THREE — Default, Dark, Mono — and the system derives the Clear and Tinted appearances from Mono. Tinted applies one user-chosen color across all icons, via preset, color picker, Match Wallpaper, or (as of ~iOS 26.4) auto-match to iPhone chassis or MagSafe case color. Icon Composer ships with Xcode 26 (current build needs macOS Tahoe 26.4+), exports a single .icon, and previews across iPhone/iPad/Mac/Watch and all appearances.

Correct the two errors: (1) Gradients are NOT wrong to bake. Apple supports gradients directly in Icon Composer and tells you to export complex gradients as PNG layers. The system adds specular highlights, refraction, blur, shadow and translucency — no gradient — so nothing doubles. What Apple actually says to strip is static MATERIAL effects: drop shadows, bevelled edges, baked specular highlights. Baked DROP SHADOWS are genuinely wrong; baked gradients are fine. (2) You DO control the final pixels to a large degree: per-layer and per-group specular, shadow (neutral/chromatic), blur, translucency, opacity, blend mode, fill, per-appearance property variants, and a per-layer Liquid Glass off switch that Apple recommends for thin shapes and text.

Also: Icon Composer is optional. A plain AppIcon asset catalog still ships on iOS 26 and the system applies Liquid Glass to it. For a Flutter project this matters — there is no Flutter-side Icon Composer integration; the .icon is added on the Xcode side, and flutter_launcher_icons produces the legacy asset-catalog path, which remains valid.

For an AAC app specifically, the per-layer "disable Liquid Glass" escape hatch is the relevant detail the claim omits: symbol legibility at small sizes is an accessibility requirement, and Apple's own guidance says turn the glass off on thin shapes rather than accept the material.

**Evidence:** DIRECTION IS RIGHT, TWO LOAD-BEARING SPECIFICS ARE WRONG.

WHAT CHECKS OUT (Apple primary):
1. Six rendered appearances — CONFIRMED. WWDC25-220 ("Say hello to the new look of app icons"): "a monochrome glass that comes in a light or dark version, and we've created two different tint modes: a dark tint that adds color to the foreground, and a light tint where the color gets directly infused into the glass." Plus Default and Dark = six.
2. Pare back baked STATIC effects — CONFIRMED, and this is the claim's strongest point. WWDC25-220 verbatim: "As many dynamic effects are available in the material recipe, we also recommend pairing back any built-in static effects in your source artwork." The Home icon example: "You can see a range of these baked-in effects in the previous Home icon, like drop shadows or bevelled edges... We've reduced the amount of layers, made the shapes rounder, and removed any additional material effects."
3. Single .icon export — CONFIRMED. WWDC25-361: "all you have to do is save the .icon file out, drag it into Xcode."
4. Previews iPhone/iPad/Mac/Watch — CONFIRMED (developer.apple.com/icon-composer/).
5. Tint auto-match to iPhone body / MagSafe case color — CONFIRMED, but only via secondary press (9to5Mac, MacRumors, Tom's Guide), and it is a ~iOS 26.4 addition (April 2026), NOT a launch feature. No Apple primary source found.

REFUTED #1 — "Any gradient you bake in will double up against the system's." FALSE. Apple explicitly sanctions gradients. WWDC25-361 says you can add "simple background colors and gradients directly in Icon Composer," and for gradients too complex for SVG, Apple's instruction is to EXPORT THE LAYER AS PNG — i.e. a baked gradient raster is the recommended path, not an error. The system applies specular highlights, refraction, blur, shadow and translucency; it does NOT apply a gradient of its own, so there is nothing to double against. The researcher generalized Apple's narrow guidance about static MATERIAL effects (drop shadows, bevels, baked highlights) into a blanket ban on gradients that Apple never issued.

REFUTED #2 — "You supply layered flat artwork; you do not control final pixels." FALSE / badly overstated. Icon Composer exposes per-layer and per-group control over specular highlights, shadow (neutral or chromatic), blur, translucency, opacity, blend mode and fill. You can toggle Liquid Glass OFF per layer — Apple explicitly recommends this "if thin shapes (like text) become illegible." And per WWDC25-361: "click the plus on the hover over and you can create an individual variant of a property" — i.e. per-appearance overrides. That is a large amount of authored control, not zero.

STALE — the mode taxonomy is WWDC25-era. Apple has since split authoring modes from rendered appearances. WWDC25-361 as currently published: "This year we renamed these to default, dark and mono, with the artwork producing all the appearances for clear and for tinted." You author THREE (Default, Dark, Mono); the system derives the six. The claim's six-mode framing describes what ships on device but misdescribes what a designer actually annotates.

OMISSION THAT MATTERS FOR THE DESIGN DECISION — Icon Composer is OPTIONAL. If you skip it, an AppIcon asset catalog of ordinary PNGs still works and the system applies Liquid Glass itself. The claim's "you must supply layered flat artwork" implies a mandate that does not exist. Also unstated: current Icon Composer requires macOS Tahoe 26.4+, and Icon Composer and asset-catalog icons are effectively mutually exclusive (the asset catalog suppresses the .icon).

SOURCING — all three CLAIMED sources are secondary (createwithswift blog, MacObserver how-to, a Medium post). Zero Apple primary sources cited for a claim rated "high" confidence about Apple platform behavior. The two refuted specifics are exactly the kind of over-generalization that propagates through that tier of source.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "brand-identity-voice" made this claim, and a design decision depends on it.

CLAIM: iOS 26 ships six icon modes and composes effects itself via Icon Composer — baked gradients and shadows are now actively wrong
DETAIL: iOS 26 modes: Default, Dark, Clear Light, Clear Dark, Tinted Light, Tinted Dark. Tinted applies a single user-chosen color overlay across all icons (color slider, or auto-match to iPhone body/MagSafe case color). Clear renders icons semi-transparent over wallpaper. Icon Composer ships with Xcode 26, exports a single `.icon` file, previews across iPhone/iPad/Mac/Watch and across modes, and the system applies Liquid Glass specular highlights, blur and shadow at render time. You supply layered flat artwork; you do not control final pixels. Any gradient or drop shadow you bake in will double up against the system's.
CLAIMED SOURCES: https://www.createwithswift.com/crafting-liquid-glass-app-icons-with-icon-composer/, https://www.macobserver.com/tips/how-to/customize-app-icons-in-ios-26-complete-guide/, https://medium.com/@foks.wang/adapting-app-icons-for-ios-26s-liquid-glass-style-5bde00f565fa
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: m3.material.io, developer.apple.com, api.flutter.dev, docs.flutter.dev, the actual type foundry, the actual paper.

Hunt for these failure modes, in order of likelihood:
1. **Marketing repeated as research.** Google's M3 Expressive claims (46 studies, 18,000 participants, "4x faster") and Lexend's readability claims are the specific hazards. Did anyone publish a methodology? Is it peer-reviewed, or is it a blog post? If a number has no methodology behind it, SAY SO — a design direction is being justified with it.
2. **Design folklore presented as evidence.** "Autistic people prefer muted colors", "sans-serif is more legible", "the aesthetic-usability effect", color psychology. Find the actual study, check the sample and whether it replicated, and check whether the popular claim matches what the paper found.
3. **Version/API rot.** Flutter lags the Material spec — a spec feature is NOT a Flutter feature. If the claim says Flutter can do something, VERIFY on api.flutter.dev or the release notes. Check whether a named API exists with that exact name.
4. **Invented specifics** — hex values, token names, type sizes, shape counts, font axes, license terms. If it's specific, verify it's real.
5. **License claims** about typefaces or assets. Verify against the actual foundry/repo.

Default to refuted=true if you cannot substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + correction if directionally right but wrong in the specifics. UNVERIFIABLE if nothing settles it — say so plainly rather than guessing.
````

</details>
