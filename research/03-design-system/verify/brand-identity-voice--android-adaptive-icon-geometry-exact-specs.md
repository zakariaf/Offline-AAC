# brand-identity-voice--android-adaptive-icon-geometry-exact-specs

> Phase: **verify** · Agent `a757c1b75d2e2aec5` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** Claim is accurate as written; no correction required. One COMPLETENESS gap worth adding to the corpus entry: the claim omits the 72x72dp masked viewport. This matters for the dependent design decision — a reader who sees "18dp reserved on each side" may infer the safe zone is 108-36=72dp and push artwork 3dp per side beyond where clipping protection actually ends. Correct mental model: 108dp layer > 72dp viewport (what the device may display) > 66dp safe zone (guaranteed never clipped; keep all essential artwork here). Also worth noting: <monochrome> is optional, not required, and only takes effect from Android 13 (API 33) onward.

**Evidence:** All six specifics verified against the claimed primary source and independently corroborated on a second primary page.

CONFIRMED, item by item:
- All layers (foreground, background, monochrome) 108x108dp — stated verbatim.
- Safe zone 66x66dp centered, "never clipped by shaped masks defined by OEMs" — stated verbatim.
- 18dp reserved on each of four sides, "reserved for masking and visual effects such as parallax or pulsing" — stated verbatim.
- Logo/artwork min 48x48dp, max 66x66dp — stated verbatim.
- Vectors preferred over bitmaps — stated ("All layers can be either vectors or bitmaps, with vectors being preferred").
- <adaptive-icon> with <background>, <foreground>, <monochrome> children — confirmed; monochrome is optional, enabling user theming from Android 13 (API 33). Defined in res/mipmap-anydpi-v26/ic_launcher.xml.

METHOD CAVEATS (disclosed for integrity):
1. First fetch used a LEADING prompt that supplied the numbers and invited confirmation — that result is weak evidence on its own, since a summarizer will echo. Confirmation rests on the re-run against the Views page with a neutral prompt ("do not assume any numbers; report only what the page states"), which returned the same figures unprompted.
2. The AdaptiveIconDrawable API reference (https://developer.android.com/reference/android/graphics/drawable/AdaptiveIconDrawable) returned only navigation chrome, no content. Its summarizer HALLUCINATED "108dp total size with 72dp safe zone" from model memory while explicitly noting it was absent from the page. Treated as zero evidence — but pursued as a lead.
3. That lead resolved the only real ambiguity. 72dp is a genuine Android figure but is NOT the safe zone: 108 - (18*2) = 72 is the MASKED VIEWPORT (area the device may display). 66x66dp is the SAFE ZONE (never clipped by any OEM mask). The ~3dp band between them absorbs mask-shape variation. The claim's 18dp margin and 66dp safe zone are both correct and mutually consistent — different boundaries, not a contradiction.

CONFIDENCE LIMITS:
- Both confirming pages are Google-authored docs about Google's own platform. For an API/geometry spec this is the correct primary source (unlike a marketing statistic, there is no independent authority to triangulate against), but it is consistency across two first-party pages, not two independent parties.
- Verified at the design-documentation level only. The framework-implementation level (AdaptiveIconDrawable source/reference) could not be loaded.

No failure modes from the hunt list apply: no methodology-free statistics, no design folklore, no Flutter/version rot (claim makes no Flutter assertion), no invented specifics (every number is real), no license claims.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "brand-identity-voice" made this claim, and a design decision depends on it.

CLAIM: Android adaptive icon geometry — exact specs
DETAIL: All layers 108x108dp (foreground, background, monochrome). Safe zone 66x66dp centered. 18dp reserved on each of four sides for masking/visual effects. Logo/artwork min 48x48dp, max 66x66dp. Vectors preferred over bitmaps. Defined via `<adaptive-icon>` with `<background>`, `<foreground>`, `<monochrome>` children.
CLAIMED SOURCES: https://developer.android.com/develop/ui/compose/system/icon_design_adaptive
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
