# design-tokens-implementation--lerp-returning-a-hard-cut-is-legal-correct-a

> Phase: **verify** · Agent `a2e6c88aa59b5ff97` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The Flutter API facts are right: ThemeExtension has exactly two abstract members, lerp's contract requires only that you return a valid T, and `t < 0.5 ? this : (other ?? this)` is a legal step function that lands on the correct endpoints (verified against _lerpThemeExtensions, which calls extensionA.lerp(extensionB, t), so this=a and other=b).

Three things must be corrected before this decision is relied on:

(a) The animation ban is not in effect and is not the default. MaterialApp mounts AnimatedTheme with kThemeAnimationDuration = 200ms unless you explicitly pass themeAnimationStyle: AnimationStyle.noAnimation. If you want the ban, you must write it — and under the current default the step function produces a visible pop, because ColorScheme lerps smoothly for 200ms while the extension snaps at the midpoint.

(b) copyWith is mandatory because it is an abstract interface member (omitting it will not compile), NOT because "ThemeData.copyWith machinery uses it." ThemeData.copyWith replaces the extensions map wholesale via _themeExtensionIterableToMap and never invokes ThemeExtension.copyWith. Do not reason about copyWith's necessity from a call path that does not exist.

(c) Nothing is shipped or CI-locked. The repo has zero commits and zero Dart files. Restate as a proposal: "we intend to implement lerp as a step function and lock it with a test," not as an accomplished, test-enforced fact.

Also: the boilerplate saving is ~13 lines total (one Color.lerp per field across 13 fields), not 13 lines per field.

The stronger honest form of the argument: the step function is legal and endpoint-correct, and it does remove the forget-to-lerp-a-new-field bug surface — but the saving is ~13 lines, and it only reads as "no visible difference" if you actually disable the theme animation, which requires code that hasn't been written. Confidence should drop from high to moderate.

**Evidence:** The API mechanics check out; the load-bearing justifications do not.

WHAT SURVIVES:
1. "Exactly two abstract members" — CONFIRMED. api.flutter.dev/flutter/material/ThemeExtension-class.html lists copyWith() and lerp() as the two abstract methods. Signature is exactly `ThemeExtension<T> lerp(covariant ThemeExtension<T>? other, double t)`.
2. "Contract does not require interpolation" — CONFIRMED by absence. The docs say only "Linearly interpolate with another ThemeExtension object" and describe t as a timeline position (0.0 = not started, 1.0 = finished, outside range "valid for extrapolation"). There is no assert, no runtime check, no stated invariant beyond returning a valid T. Nothing enforces interpolation.
3. "The `t < 0.5 ? this : other` cut lands on the right endpoint" — CONFIRMED against source. In theme_data.dart, `_lerpThemeExtensions` calls `extensionA.lerp(extensionB, t)`, so `this` = a (the from-theme) and `other` = b (the to-theme). t=0 -> a, t=1 -> b. Endpoints are correct, and it is correct under extrapolation too (t<0 -> a, t>1 -> b). The reasoning for preferring `t < 0.5` over bare `return this` is sound.

WHAT FAILS:

4. "MaterialApp's implicit theme animation, which this app never mounts with nonzero duration" — UNSUPPORTED, and the default runs the other way. `kThemeAnimationDuration = Duration(milliseconds: 200)` and MaterialApp.themeAnimationDuration defaults to it. app.dart mounts AnimatedTheme unconditionally unless you explicitly opt out:
    if (widget.themeAnimationStyle != AnimationStyle.noAnimation) {
      childWidget = AnimatedTheme(data: theme, duration: widget.themeAnimationStyle?.duration ?? widget.themeAnimationDuration, ...);
    } else {
      childWidget = Theme(data: theme, child: childWidget);
    }
Animation is the default; disabling it requires passing `themeAnimationStyle: AnimationStyle.noAnimation` (or a zero duration). The claim states the ban as an existing fact — it is at best an unimplemented intention.

5. "copyWith ... is not optional because ThemeData.copyWith machinery uses it" — the mechanism is invented. ThemeData.copyWith replaces the extensions collection wholesale: `extensions: (extensions != null) ? _themeExtensionIterableToMap(extensions) : this.extensions`. It never calls copyWith on an individual ThemeExtension. The conclusion (you must write copyWith) is right, but only because it is an abstract member — omitting it is a compile error. The cited reason is fabricated.

6. "Shipped implementation" and "CI-locked by a test at t ∈ {0, 0.25, 0.49, 0.5, 0.75, 1.0}" — nothing is shipped and nothing is locked. `git log` reports no commits on main; `git ls-files` returns 0 files. The repo contains only RESEARCH.md, idea.md, analysis_options.yaml, and research/. There are no .dart files, no AacTheme, no test suite. "Shipped" and "CI-locked" describe artifacts that do not exist.

7. "~13 lines of Color.lerp(a,b,t)! boilerplate per field" — Color.lerp is one line per field. Across 13 fields that is ~13 lines total, not 13 per field. The saving is overstated by roughly 13x.

BEHAVIORAL POINT THE CLAIM MISSES: under default MaterialApp settings the step function is not inert. ThemeData.lerp interpolates ColorScheme, TextTheme, etc. smoothly across 200ms while the extension snaps at t=0.5. The result is a visible mid-transition mismatch — extension colors jump to the new theme while the surrounding Material surfaces are still halfway. That is legal and lands correctly, but "genuinely simplifies" understates the cost, and it is a real consideration for an AAC app where a color pop mid-transition is the kind of thing that matters to the user population.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "design-tokens-implementation" made this claim, and a design decision depends on it.

CLAIM: `lerp` returning a hard cut is legal, correct, and testable — the animation ban genuinely simplifies ThemeExtension.
DETAIL: `ThemeExtension<T>` has exactly two abstract members: `copyWith()` and `lerp(covariant ThemeExtension<T>? other, double t)`. The contract requires returning a valid T — it does NOT require interpolation. Flutter calls lerp only from AnimatedTheme / MaterialApp's implicit theme animation, which this app never mounts with nonzero duration. Shipped implementation is one line: `AacTheme lerp(covariant AacTheme? other, double t) => t < 0.5 ? this : (other ?? this);`. Note `t < 0.5` rather than bare `return this`: bare `this` would mean a theme switch that somehow got animated would never reach the new theme at all. The `? this : other` cut is a correct step function — it lands on the right endpoint. This removes ~13 lines of `Color.lerp(a,b,t)!` boilerplate per field AND removes the bug surface where someone forgets to lerp a newly-added field. It is CI-locked by a test asserting the result is always one of the two endpoints and never a mix, at t ∈ {0, 0.25, 0.49, 0.5, 0.75, 1.0} — so a future 'helpful' real-lerp refactor fails the suite. copyWith still must be written in full (13 fields); it is not optional because ThemeData.copyWith machinery uses it.
CLAIMED SOURCES: https://api.flutter.dev/flutter/material/ThemeExtension-class.html
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
