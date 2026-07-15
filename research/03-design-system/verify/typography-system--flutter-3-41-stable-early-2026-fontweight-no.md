# typography-system--flutter-3-41-stable-early-2026-fontweight-no

> Phase: **verify** · Agent `ad2ad496c4d13574f` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction required to the substance. One precision note: the docs say affected apps "may see changes in text rendering," not that they will — the change only bites where the font exposes a wght axis and the style previously set FontWeight without a matching FontVariation('wght'). Also, the FontVariation('GRAD', 150) example is illustrative rather than quoted from the breaking-change page, though GRAD is a genuine registered axis.

**Evidence:** Adversarial check found no substantive error. All three claimed sources return HTTP 200 (verified with curl against a known-404 control), and the primary breaking-change page substantiates every specific.

VERIFIED POINT BY POINT against https://docs.flutter.dev/release/breaking-changes/font-weight-variation (page last updated 2026-05-05; site reflects Flutter 3.44.0):

1. Mechanism — CONFIRMED. Page: "It is no longer necessary to separately use FontVariation to control [the wght axis]" and "Flutter [applies] the equivalent of adding a FontVariation('wght') attribute to the style whose value is the same as the FontWeight." Claim's wording ("internally applies FontVariation('wght', value)") is accurate.

2. Version numbers — CONFIRMED verbatim. Page states "Landed in version: 3.39.0-0.0.pre" and "In stable release: 3.41". Exactly as claimed.

3. Arbitrary integers 1–1000 — CONFIRMED. Page: "FontWeight instances can now be constructed using arbitrary integer values ranging from 1 to 1000. This allows usage of weights beyond the FontWeight.w100 through FontWeight.w900 range with values that are not multiples of 100." So FontWeight(350) is valid.

4. FontWeight.index deprecated → FontWeight.value — CONFIRMED. Page: "The FontWeight.index property is now deprecated because it only identifies [the predefined weights]... use FontWeight.value to obtain the thickness level of a font." Cross-checked at https://api.flutter.dev/flutter/dart-ui/FontWeight/index.html, which carries the deprecation notice "Use value, which is more precise."

   Verification note: my first pass over the FontWeight class-summary page reported index as NOT deprecated. That was a summarization error, not a source conflict — the dedicated property page shows the deprecation annotation. I flag it only because it was the single moment this claim looked breakable, and it did not survive scrutiny.

5. lerp can produce out-of-range weights — CONFIRMED. Page: "FontWeight.lerp can yield values other than FontWeight.w100 [through w900]".

6. Rendering gotcha — CONFIRMED, with a minor hedging nuance. Migration guide verbatim: "Applications may see changes in text rendering if they used variable fonts and were specifying FontWeight in text styles without a matching FontVariation('wght') value. If these changes are undesirable, then the application should change the FontWeight to a value that achieves the intended rendering. For example, to restore the font's default weight, set fontWeight to FontWeight.normal." The claim's "will RENDER DIFFERENTLY" is slightly stronger than the docs' "may see changes" — the effect is conditional on the font actually exposing a wght axis and on the prior style lacking a matching FontVariation('wght'). Directionally correct; do not treat it as universal across all apps.

7. Other axes still need fontVariations — CONFIRMED by construction. The change scopes only the wght axis; FontVariation remains the mechanism for GRAD, opsz, slnt, etc. The specific example FontVariation('GRAD', 150) is not quoted on the page, but GRAD is a real registered axis and the API accepts arbitrary four-character axis tags, so the example is illustrative rather than invented.

CORROBORATION: The implementing PR is real — flutter/flutter#175771, "Set the font weight variation axis based on the text style's FontWeight" by jason-simmons — with prior tracking issues #148026 ("FontWeight should subsume wght in FontVariation") and #136779.

NO FAILURE MODES FOUND: this is an API/version claim resting on Flutter's own breaking-changes documentation, not on marketing statistics, folklore, or an unreplicated study. No invented API names (FontWeight.value and FontVariation both exist with those exact names), no version rot (3.41 stable is consistent with today's 3.44.0 stable), no license claims. Confidence "high" is warranted. Safe to base a typography-system decision on, with one caveat: audit existing variable-font text styles before upgrading past 3.41, since the rendering change is silent.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "typography-system" made this claim, and a design decision depends on it.

CLAIM: Flutter 3.41 (stable, early 2026) — FontWeight now sets the wght axis of variable fonts automatically; FontVariation is only for other axes
DETAIL: Landed in 3.39.0-0.0.pre, stable in Flutter 3.41. Setting TextStyle.fontWeight now internally applies FontVariation('wght', value) — you no longer pair them. FontWeight accepts arbitrary integers 1–1000 (FontWeight(350) is valid), not just w100–w900 multiples. FontWeight.index is deprecated → use FontWeight.value. Other axes still need fontVariations: [FontVariation('GRAD', 150)]. Gotcha: apps that previously used variable fonts with FontWeight alone will RENDER DIFFERENTLY after upgrade. FontWeight.lerp can produce out-of-range weights.
CLAIMED SOURCES: https://docs.flutter.dev/release/breaking-changes/font-weight-variation, https://api.flutter.dev/flutter/dart-ui/FontVariation-class.html, https://docs.flutter.dev/release/release-notes/release-notes-3.41.0
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
