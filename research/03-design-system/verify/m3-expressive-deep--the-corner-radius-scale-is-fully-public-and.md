# m3-expressive-deep--the-corner-radius-scale-is-fully-public-and

> Phase: **verify** · Agent `aaed4aebd41d1b202` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The eight fixed corner-radius steps are real and correctly stated: none/zero 0, extra-small 4, small 8, medium 12, large 16, large-increased 20, extra-large 28, extra-large-increased 32, extra-extra-large 48 dp. M3E did add the -increased tokens (20, 32) and the 48 step. But `full` is NOT 9999dp — Google's Android implementation defines it as 50%, a relative value that resolves against component size, and that is still true on master. M3E gave fully-rounded an explicit NAME, it did not give it an explicit dp value; the claim's stated before/after is backwards on that point. 9999 is a sentinel invented by the third-party `material_design` pub package (not Flutter SDK, not on api.flutter.dev) to work around Flutter's lack of a percentage radius primitive. In Flutter, use BorderRadius.circular(n) for the fixed steps and StadiumBorder — not circular(9999) — for `full`. Finally, "largest 'not 2014' lever" is opinion, not a finding, and "just numbers, no package needed" holds only for the fixed steps: `full` needs a different primitive, and M3E's asymmetric shapes and shape-morph library are outside the scale entirely. Re-source the scale to material-components-android/docs/theming/Shape.md rather than to the pub.dev mirror; downgrade confidence to medium.

**Evidence:** THE NUMERIC CORE SURVIVES (8 of 10 values confirmed against a primary Google source):

material-components-android/docs/theming/Shape.md (Google's own repo, master) independently lists: Extra Small 4, Small 8, Medium 12, Large 16, Large Increased 20, Extra Large 28, Extra Large Increased 32, Extra Extra Large 48. This is NOT circular — it corroborates the claim from a source other than the pub.dev package. The M3E-added tokens (20, 32, 48) are also confirmed as CSS custom properties: --md-sys-shape-corner-large-increased: 20px, --md-sys-shape-corner-extra-large-increased: 32px, --md-sys-shape-corner-extra-extra-large: 48px. The M3Corners page at pub.dev fetched cleanly and matches the claim's list exactly. The naming change (an explicit `full` token was added where fully-rounded was previously described as 50% of component size) is corroborated.

WHAT IS REFUTED — "full 9999 (pill)" is an implementation artifact, not a spec value:

material-components-android/docs/theming/Shape.md defines Full as **50%** — "Shape with full corner size i.e., circle with rounded corners or rhombus with cut corners - 50%". It is a RELATIVE value, still, on master today. It is not 9999dp and never was. 9999 is a sentinel that the third-party Dart package uses because Flutter's BorderRadius has no percentage primitive. The claim presents this sentinel as an "exact token value in dp" from the spec. It is not.

This also inverts the M3E change the claim describes. The claim says M3E changed fully-rounded FROM "50% of the component size" TO "the explicit `full` token" — implying 50% was replaced by a fixed number. It wasn't. `full` was given a NAME; its SEMANTICS remain relative. "Explicit token" is not "explicit dp value."

SOURCING FAILURE (the mechanism that produced the error):

M3Corners belongs to `material_design`, a THIRD-PARTY pub.dev package. It is not Flutter SDK and does not appear on api.flutter.dev. The claim says it was "verified against the Dart M3Corners class constants, which mirror the spec" — that is verification against a mirror, not against the spec. The mirror agreed on the eight fixed steps and propagated its own 9999 sentinel as if it were spec. The claim cites m3.material.io as a source but that page is JS-rendered and returns no token data to a fetch; it cannot have been the thing actually checked.

"THE ENTIRE IMPLEMENTATION" IS OVERSTATED:

BorderRadius.circular(32) is correct for a fixed step. It is NOT correct for `full` — BorderRadius.circular(9999) is a hack that approximates a stadium and can misrender on small or non-uniform components; the correct Flutter primitive is StadiumBorder. And "these are just numbers" only covers the radius scale. M3E's shape system also includes asymmetric/per-corner shapes and the shape-morph library, which are emphatically not numbers and do cost animation.

NOT A FACT CLAIM:

"The single largest 'not 2014' lever that costs zero animation" is an unfalsifiable aesthetic assertion with no study, no methodology, and no source behind it. It should not be carried in a research corpus as a finding. Note the confidence was "high" — the specifics that failed are exactly the ones a high-confidence label discourages re-checking.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "m3-expressive-deep" made this claim, and a design decision depends on it.

CLAIM: The corner radius scale is fully public and copyable — and is the single largest 'not 2014' lever that costs zero animation.
DETAIL: Exact token values in dp: none/zero 0, extra-small 4, small 8, medium 12, large 16, large-increased 20, extra-large 28, extra-large-increased 32, extra-extra-large 48, full 9999 (pill). M3E added the -increased tokens (20, 32) and the 48 step; it also changed 'fully rounded' from 'set at 50% of the component size' to the explicit `full` token. Verified against the Dart M3Corners class constants, which mirror the spec. These are just numbers — no package needed, `BorderRadius.circular(32)` is the entire implementation.
CLAIMED SOURCES: https://pub.dev/documentation/material_design/latest/material_design/M3Corners-class.html, https://m3.material.io/styles/shape/corner-radius-scale
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
