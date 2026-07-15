# m3-expressive-deep--the-35-shape-library-is-real-named-and-porte

> Phase: **verify** · Agent `a5f3e49cb1a431be1` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The 35-shape library is real, correctly named, and genuinely usable as static geometry — that part holds against the primary spec. Three corrections:

1. Drop the headline framing. Morphing is NOT "the whole point" of the shape library; it is an optional motion layer over static geometry. The claim's own DETAIL says this and is correct. An animation ban does not disqualify the shape library — it only removes morph transitions. The library remains fully available.

2. Replace the cited package. flutter_m3shapes is GPL-3.0 (viral copyleft — likely disqualifying for a shipping app), is a CustomClipper/SVG-path clipper rather than a ShapeBorder or RoundedPolygon implementation, has ~7 stars, no morph support, and ships typo'd enum names ("hearth", "clampShell"). Use material_new_shapes instead: MIT-licensed, and an actual port of androidx.graphics.shapes (RoundedPolygon/Morph). androidx_graphics_shapes is another MIT-family option.

3. Fix the API specific. "A static cookie-9 is a non-animated ShapeBorder" is not true of flutter_m3shapes — it clips a child and cannot be passed to Material(shape:)/Card(shape:)/ShapeDecoration, so shadows, borders, and shape-conforming ink splashes are lost. To get a real ShapeBorder you must convert a RoundedPolygon path yourself (via material_new_shapes) and wrap it in a custom ShapeBorder — a small but real piece of work that should be budgeted, not assumed.

Minor: shapes landed in Compose material3 1.4.0-ALPHA10 (May 2025), not a stable release. And "several shapes are childish for this audience" is an aesthetic judgment, not a verified fact — label it as such.

Net for the design decision: the animation ban is NOT a reason to abandon M3E shapes. The real blockers are licensing (avoid the GPL package) and a modest ShapeBorder adapter cost.

**Evidence:** The factual core survives adversarial checking; the framing and the two load-bearing specifics do not.

WHAT CONFIRMS:
1. "35 shapes, real and named" — CONFIRMED against the primary spec. m3.material.io states verbatim: "The Material shape library has 35 shapes to apply to designs" and describes "a new set of 35 shapes to add decorative visual elements, with built-in shape morph motion." The count is not invented.
2. The 35 names — CONFIRMED. The list matches the androidx.compose.material3 MaterialShapes constants one-for-one (CIRCLE, SQUARE, SLANTED_SQUARE, ARCH, FAN, ARROW, SEMI_CIRCLE, OVAL, PILL, TRIANGLE, DIAMOND, CLAM_SHELL, PENTAGON, GEM, SUNNY, VERY_SUNNY, COOKIE_4/6/7/9/12, GHOSTISH, CLOVER_4, CLOVER_8, BURST, SOFT_BURST, BOOM, SOFT_BOOM, FLOWER, PUFFY, PUFFY_DIAMOND, PIXEL_CIRCLE, PIXEL_TRIANGLE, BUN, HEART). No invented specifics found. Rare for a list this long to check out; it does.
3. "Shapes are static geometry; morphing is separate" — CONFIRMED. Morph is a distinct capability with its own spec page (/styles/shape/shape-morph) and, in Compose, a separate Morph class in androidx.graphics.shapes; RoundedPolygon is standalone static geometry. The DETAIL is right.
4. Timeline — substantially right. M3E was announced May 2025 (I/O 2025); shapes shipped in androidx.compose.material3 1.4.0-alpha10 — an ALPHA in May 2025, not stable. A Figma "M3 Expressive - Shapes set" community file exists.

WHAT FAILS:

A. THE CLAIM CONTRADICTS ITS OWN DETAIL (failure mode 2 — folklore framing).
The headline says morphing "is its whole point," therefore the library dies under an animation ban. The DETAIL then says the opposite — shapes are static geometry, a static cookie-9 works fine. The spec backs the DETAIL: the library is described as "35 shapes to apply to designs" for decorative use, with morph as an additive motion layer ("built-in shape morph motion"), not its purpose. Morphing is NOT the whole point. The animation ban does not eliminate the shape library — it removes one optional layer. The headline's conclusion should be discarded; the detail's should be kept.

B. "A static cookie-9 is a beautiful non-animated ShapeBorder" — FALSE for the cited package (failure mode 3, version/API rot).
flutter_m3shapes exposes NO ShapeBorder. Its actual API surface is: M3Container (a widget that CLIPS its child), M3Clipper (a CustomClipper), and a Shapes enum. It parses SVG path-data strings (dependency: path_drawing) and scales them — it does not implement RoundedPolygon geometry. Consequence: you CANNOT pass these into Material(shape:), Card(shape:), ShapeDecoration, or InkWell customBorder. A CustomClipper is not a ShapeBorder — it clips, so you lose ink splashes conforming to the shape, elevation shadows that follow the outline, and borders. If the design decision assumes "drop cookie-9 into Material.shape," this package will not do it.

C. LICENSE LANDMINE, unmentioned (failure mode 5).
flutter_m3shapes is GPL-3.0. Verified on pub.dev's license tab (full GNU GPL v3 text) and the GitHub repo. GPL-3.0 statically linked into a Flutter app is viral copyleft — for a shipping AAC app this is a genuine legal hazard, not a footnote. The researcher cited this package at "high confidence" without noting it.

D. THE CITED PACKAGE IS NOT A CREDIBLE "PORT."
flutter_m3shapes: v1.0.0+2, unverified uploader, ~7 GitHub stars, last published ~9 months ago, no morphing support at all. Its enum names contain outright typos — "clampShell" (for clam shell) and "hearth" (for heart) — plus non-idiomatic names like c9_sided_cookie and l4_leaf_clover. Calling this "ported to Flutter" oversells a hobby project.

E. SOURCE QUALITY.
supercharge.design is an agency marketing blog, not a primary source. It is where the unmethodologized "46 studies / 18,000 participants" M3E marketing figure propagates. It should not carry evidentiary weight here (the claim doesn't lean on that number, but the source is contaminated).

F. NOT A FACT: "several of these shapes are squarely in the banned childishness register." This is an editorial aesthetic judgment about heart/flower/bun/clover/sunny, not a verifiable proposition. It may be a sound design instinct, but it is asserted, not evidenced, and should not be laundered into the corpus as fact.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "m3-expressive-deep" made this claim, and a design decision depends on it.

CLAIM: The 35-shape library is real, named, and ported to Flutter by a community package — but morphing (its whole point) is animation, which this app bans.
DETAIL: The 35 shapes: circle, square, slanted (slanted-square), arch, fan, arrow, semicircle, oval, pill, triangle, diamond, clam-shell, pentagon, gem, sunny, very-sunny, cookie-4, cookie-6, cookie-7, cookie-9, cookie-12, ghost-ish, clover-4, clover-8, burst, soft-burst, boom, soft-boom, flower, puffy, puffy-diamond, pixel-circle, pixel-triangle, bun, heart. Added to the Material Shapes Library (Figma) and Jetpack Compose in the May 2025 M3E update, alongside shape morphing. Critically: the shapes are STATIC geometry (RoundedPolygon); morphing is a separate animated capability. A static cookie-9 is a beautiful non-animated ShapeBorder. Note 'heart', 'flower', 'bun', 'clover', 'sunny' — several of these shapes are squarely in the banned childishness register for this audience.
CLAIMED SOURCES: https://pub.dev/documentation/flutter_m3shapes/latest/, https://supercharge.design/blog/material-3-expressive
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
