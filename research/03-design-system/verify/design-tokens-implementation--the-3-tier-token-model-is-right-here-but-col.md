# design-tokens-implementation--the-3-tier-token-model-is-right-here-but-col

> Phase: **verify** · Agent `ab3682df9857d16e3` · Run `wf_f237e8a6-694`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** There is no token implementation in Offline-AAC — the repo has zero Dart files and zero commits, and `Prim.inkT06`, `Prim.clayT40`, `AacTheme`, `tileInk`, `showModeSurface` do not exist anywhere in it. RESEARCH.md:616 lists `theme/ tokens.dart · themes.dart` as a planned file layout; research/README.md:40 lists ThemeExtension tokens as an unstarted research topic. Restated defensibly as a PLAN: adopt M3's reference and system token classes (M3's names, not "primitive/semantic"), skip the component class — at ~4 components component tokens alias nothing, which is consistent with M3's own rationale for them. But build the system tier on Flutter's existing `ColorScheme` roles and the `MaterialApp.theme` / `darkTheme` / `highContrastTheme` / `highContrastDarkTheme` slots, which already deliver the three themes AND already prevent the `if (isDark)` scatter the claim invokes as justification. Reserve a custom `ThemeExtension` only for roles ColorScheme genuinely lacks (a `showModeSurface` may qualify; a `tileInk` probably maps to `onSurface`). The contrast test is not downstream of the tier boundary — `Color.computeLuminance()` works on any pair, so the test can iterate ThemeData objects and ColorScheme roles regardless of token architecture. Confidence should be "planned, unbuilt," not "high."

**Evidence:** FAILURE MODE #4 (invented specifics), fatally. The claim's first four words — "The 3-tier token model is right here" — are false. There is no "here."

/Users/zakariafatahi/50-apps-challenge/Offline-AAC contains ZERO Dart files (`find . -name "*.dart"` → empty) and ZERO commits (`git log` → "your current branch 'main' does not have any commits yet"; `git ls-files | wc -l` → 0). The repo is RESEARCH.md, idea.md, analysis_options.yaml, and a research/ corpus. `grep -rn "Prim\.\|inkT06\|clayT40\|AacTheme\|tileInk\|showModeSurface\|tilePhraseLabelColorRest"` across every non-.git file returns ONE hit, and it is not code — it is /Users/zakariafatahi/50-apps-challenge/Offline-AAC/research/README.md:40 mentioning "design tokens via `ThemeExtension`" as a topic still to be researched. The `03-design-system/` directory that README promises does not exist on disk.

Every named identifier is fabricated: `Prim.inkT06`, `Prim.clayT40`, `AacTheme`, `tileInk`, `showModeSurface`, `tilePhraseLabelColorRest`. The only trace of any of this is /Users/zakariafatahi/50-apps-challenge/Offline-AAC/RESEARCH.md:616, which is a PLANNED directory tree inside a fenced block: `theme/  tokens.dart · themes.dart`. Two filenames that have never been created. The claim reads a wishlist as an audit and reports back with "high" confidence and a tier count.

FAILURE MODE #3 (API rot / framework already does this). The load-bearing engineering argument is also wrong on its own terms. The claim: "Without the semantic tier, every widget needs an `if (isDark)` — which is the actual failure mode." Flutter already ships the semantic tier. `ColorScheme` is "a set of 45 colors based on the Material spec," exposing named roles (`primary`, `onPrimary`, `surface`, `onSurface`, `surfaceContainer`, `outline`, `error`…) that hold constant meaning while their values change per theme (https://api.flutter.dev/flutter/material/ColorScheme-class.html). A widget reads `Theme.of(context).colorScheme.onSurface`; no `if (isDark)` anywhere, and no custom ThemeExtension required. The fan-out to multiple themes is likewise a framework feature, not a token-tier payoff: `MaterialApp` has four theme slots — `theme`, `darkTheme`, `highContrastTheme` (ThemeData?, triggered by `MediaQueryData.highContrast`, falls back to `theme`), and `highContrastDarkTheme` (ThemeData?, triggered by dark + high-contrast, falls back to `darkTheme`) — which map exactly onto the brief's Dark + Light + High-Contrast trio at RESEARCH.md:167. `ThemeExtension<T extends ThemeExtension<T>>` is real (requires `copyWith()` and `lerp()`), but it is for roles ColorScheme does NOT cover — a genuine `showModeSurface`-shaped need would qualify; `tileInk` almost certainly maps to an existing `onSurface`/`onPrimaryContainer` role. So "the entire justification is that tileInk resolves to three different primitives across three themes" justifies nothing that `ColorScheme` + `highContrastTheme` doesn't already deliver for free.

"The tier boundary is what makes the contrast test possible at all" is false. `computeLuminance()` takes any two `Color` values. A contrast test can iterate the ThemeData objects and pair ColorScheme roles with zero custom tiers. The test the claim says is downstream of the architecture is in fact orthogonal to it — and, like the architecture, does not exist yet.

FAILURE MODE #2-adjacent (folklore naming). "Primitives / semantic / component" is design-token community vocabulary, not Material's. M3's three token classes are **reference**, **system**, and **component**: reference tokens "point to a static value – such as a color hex code"; system tokens are "decisions and roles that give the design system its character"; component tokens are "the design properties assigned to elements in a component" (https://m3.material.io/foundations/design-tokens). The mapping is sound, so the 3-tier shape itself is real and correctly described. Nothing in M3 says tokens only "earn their keep" at 3 themes rather than 1 — that is the claim's own assertion carrying no source, and M3's stated rationale ("streamline the work of building, maintaining, and scaling") is theme-count-independent. Also note `Prim.inkT06` puts hex in the REFERENCE tier, which is correct per M3 — the one architecturally accurate thing here, asserted about code that doesn't exist.

WHAT SURVIVES: as a forward-looking PLAN, drop-component-tier-at-4-components is defensible and matches M3's own framing (component tokens exist to be aliased across many components; with ~4, they alias nothing). That is the only part worth keeping.

WHAT MUST NOT SURVIVE: a design decision is riding on a description of an implementation that has never been written, plus a justification for a custom semantic tier whose stated failure mode (`if (isDark)` scattered through widgets) the Flutter framework already prevents without it.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "design-tokens-implementation" made this claim, and a design decision depends on it.

CLAIM: The 3-tier token model is right here, but collapsed to 2.5 tiers — and the reason is the 3 themes, exactly as the brief suspected.
DETAIL: Tier 1 (primitives): `Prim.inkT06`, `Prim.clayT40` — hex literals live here and NOWHERE else. Tier 2 (semantic): the `AacTheme` ThemeExtension — `tileInk`, `showModeSurface`. Tier 3 (component) is DELETED: with one screen there are ~4 components, so a `tilePhraseLabelColorRest` tier is pure ceremony that adds indirection with zero reuse payoff. But tiers 1+2 are NOT optional: the entire justification is that `tileInk` resolves to three different primitives across three themes. Without the semantic tier, every widget needs an `if (isDark)` — which is the actual failure mode, because it scatters palette logic across the widget tree where no test can see it. The tier boundary is what makes the contrast test possible at all: the test enumerates semantic pairings, which only exist because the semantic tier exists. Tokens earn their keep here at 3 themes, not at 1.
CLAIMED SOURCES: (none)
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
