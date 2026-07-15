# beauty-without-motion--warm-neutrals-are-a-real-2025-26-move-and-ar

> Phase: **verify** · Agent `a3ab8626fb46bdc6f` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Directionally right on two things, wrong on the part the design decision rests on.

SURVIVES: (a) warm neutrals are a real current trend; (b) the ink lever genuinely moves contrast ~2.2x more than the paper lever (15.91 vs 18.73 — verified exactly).

DOES NOT SURVIVE: "Cool dark greys produce the layered depth dark UI needs" is uncited folklore from a single anonymous page, contradicted by both primary sources — M3's default TonalSpot derives neutral hue FROM THE SEED at chroma 6 (warm wallpaper → warm dark surface, shipped by default), and Apple gets dark-mode depth from base/elevated LIGHTNESS pairs, not blue tint. Depth in dark UI is a tonal-elevation mechanism, not a hue-temperature one.

"Warm the ink, not the paper" is invented by the claim — it appears in none of the cited sources, and it contradicts both M3 (surface = neutralPalette tone 6, onSurface = neutralPalette tone 90 — one palette, one hue, ink and paper warmed together) and colorarchive's own "commit to one temperature per layer."

WHAT TO DO INSTEAD: If you want warmth, do what M3 does — pick ONE neutral hue and derive both ink and paper from it at different tones. That is the shipping, primary-source-backed pattern. The #141210-vs-#141218 agonizing is a non-decision either way: 0.03% of the luminance range, imperceptible at tone 6. Spend the attention on the elevated surface ramp (tones ~20-40), which is where a warm neutral actually can go brown and where dark-UI depth is really won. And drop "halation" — the verified numbers are WCAG contrast, no halation study is cited, and hue temperature has no established link to halation at all.

**Evidence:** SOURCES ARE REAL AND QUOTED ACCURATELY (credit where due). All three URLs return HTTP 200. I bypassed the summarizer (which echoed my own prompt phrasing back at me — a hallucination signature) and grepped raw HTML. The load-bearing phrases are verbatim on colorarchive.org/guides/neutral-color-palettes/: "a gray with hue 40-60° at low saturation is warm; a gray with hue 200-240° is cool" and "dark cool grays (blue-tinted dark) create the layered depth required for effective dark UI without the warm-dark-reads-as-brown problem that affects warm dark neutrals". No fabrication.

THE MATH IS EXACT. Recomputed per WCAG 2.x: #FFFFFF/#000 = 21.0; #E0E0E0/#000 = 15.91 (24.2% drop); #FFF/#121212 = 18.73 (10.8% drop). The ink lever moves contrast ~2.2x more than the paper lever. Verified independently.

WHAT BREAKS:

1. SINGLE-SOURCED FOLKLORE SOLD AS CONVERGENCE. The claim says "the same sources note the failure mode explicitly" (plural). False. Only ONE of the three URLs contains it. The color-temperature-design-guide does NOT contain the hue rule (grep-confirmed absent). moda.app/warm-gray never mentions dark mode at all. So both the temperature rule and the brown failure mode trace to ONE page on an anonymous, undated, zero-citation site (grep for author/date/doi/et al/journal: nothing). That is one designer's opinion, not corroborated evidence.

2. PRIMARY SOURCES REFUTE "COOL DARK IS REQUIRED FOR DEPTH." Google's material-color-utilities (dynamic_scheme.ts, getNeutralPalette), for TONAL_SPOT — "The default Material You theme on Android 12 and 13" — is: TonalPalette.fromHueAndChroma(sourceColorHct.hue, 6.0). The dark surface hue IS THE SEED HUE. A warm wallpaper produces a warm dark surface at chroma 6, shipped by Google to billions of devices by design. There is no cool-only rule. Apple HIG achieves dark depth via "base and elevated" background pairs (lightness) on a #000000/neutral base — depth comes from TONAL ELEVATION, not blue tint.

3. THE RESOLUTION IS REFUTED BY M3 *AND* BY ITS OWN CITED SOURCE. color_spec_2021.ts: surface = neutralPalette, tone 6 (dark); onSurface = neutralPalette, tone 90 (dark). SAME palette, SAME hue — M3 tints ink and paper TOGETHER, differing only by tone. "Warm the ink, leave the paper near-neutral" is the opposite of the primary system's architecture. Worse, colorarchive.org itself says: "The most common neutral mistake is mixing warm and cool within the same elevation level... Commit to one temperature per layer" and temperature "should be consistent across all neutral values in the system: background, surface, card, sidebar, modal, tooltip." The claim cites this page for the failure mode, then prescribes the split it warns against. The page NEVER discusses text-color temperature — so it cannot support "warm the ink" in either direction.

4. UNSUPPORTED ATTRIBUTIONS. The page contains NO mention of "eye strain" (grep: zero hits), no "2025/2026", no "reaction against cold corporate white". Those framings are the claim author's, presented as source content. "Warm off-whites reduce eye strain" is an efficacy claim with zero evidence at any cited source.

5. CATEGORY ERROR: CONTRAST ≠ HALATION. The verified numbers are WCAG photometric contrast ratios, not halation. "Prior research already established that TEXT luminance is the dominant halation lever" cites no halation research — the basis is the researcher's own prior arithmetic. The OLED physics is defensible (text is the emitter; near-black paper emits ~nothing) but that is an argument, not established research. And halation is orthogonal to temperature: nothing links warm/cool hue to halation.

6. CHERRY-PICK. The page gives TWO hue rules, two sentences apart: "40-60° warm / 200-240° cool" AND "if hue is 0-70°, it leans warm... 180-270°, it leans cool". The claim presents the narrow one as "the temperature rule".

7. THE PREMISE IS NEARLY MOOT ANYWAY. I computed #141218 (hue 260°) vs #141210 (hue 30°): relative luminance 0.006473 vs 0.006187 — the entire warm-vs-cool dark-background decision spans 0.03% of the luminance range (contrast vs #E0E0E0: 14.08 vs 14.16). At tone 6 the hue is nearly imperceptible, so the "brown problem" is ALSO overstated at near-black. Brown-ness emerges at elevated mid-tones (tone ~20-40), not at the base.

VERSION NOTE: Flutter's ColorScheme.dark() literal default surface is const Color(0xff121212) — the legacy M2 value, not the M3 #141218 baseline (which comes via ColorScheme.fromSeed). The claim makes no Flutter API assertion, so no API rot, but #141218 is a spec-baseline value, not what Flutter's ColorScheme.dark() hands you.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "beauty-without-motion" made this claim, and a design decision depends on it.

CLAIM: Warm neutrals are a real 2025–26 move and are nearly free — but the naive application (warm the dark background) backfires. Warm the ink, not the paper.
DETAIL: The temperature rule: a grey at hue 40–60° with low saturation reads warm; hue 200–240° reads cool. The 2025–26 reaction against cold corporate white has products using warm off-whites to reduce eye strain and read as 'thoughtful'. BUT the same sources note the failure mode explicitly: warm dark neutrals suffer a 'warm-dark-reads-as-brown' problem, and cool dark greys produce the layered depth that dark UI needs. This directly complicates the tempting '#141210 not #141218' move. The resolution: prior research already established that TEXT luminance, not background hex, is the dominant halation lever (#FFFFFF→#E0E0E0 cuts contrast 21:1→15.91:1, a 24% drop; #000→#121212 only moves 21:1→18.73:1). So put the warmth where it is both visible and useful — in the off-white text — and leave the background near-neutral. Warm ink on near-neutral paper is the 'ink' read; warm paper on OLED is the 'brown' read.
CLAIMED SOURCES: https://colorarchive.org/guides/neutral-color-palettes/, https://colorarchive.org/guides/color-temperature-design-guide/, https://moda.app/resources/colors/warm-gray
CONFIDENCE: medium

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
