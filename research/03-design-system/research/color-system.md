# color-system

> Phase: **research** · Agent `a265cfba930c4fc5f` · Run `wf_f237e8a6-694`

## Result

## Summary

Three of the brief's premises need correcting, and all three corrections open design space rather than closing it. (1) APCA is OUT of WCAG 3 — removed from the July 2023 draft, and as of April 2026 the spec still says the contrast algorithm is "yet to be determined"; WCAG 3 is a ~2030 artifact. So ship to WCAG 2.x AA/AAA for legal/store safety and use APCA as the design instrument. I implemented both algorithms, validated them against reference values, and they disagree enormously in dark mode: #767676 on #000 and #757575 on #FFF both score ~4.6:1 "AA pass," but APCA rates them Lc -30 (unreadable) and Lc 72 (fine). WCAG 2 is polarity-blind — that is the specific flaw, and it means WCAG-passing dark palettes can be junk. Design to APCA, then verify WCAG clears. (2) The permission slip is bigger than "not grey": the highest-leverage craft move is chroma in the neutrals. M3's own default dark surface #141218 is not neutral — it is OKLCH C=0.0124 at hue 300 (purple). Google already tints its blacks; the question is only which hue, and warm (hue ~65) reads as lamplight/paper rather than screen. (3) The colorblind-safe categorical palette is a trap: I simulated protan/deutan/tritan and found that at iso-lightness only TWO categories survive (min dE ~10); four collapse to dE 1.4. Okabe-Ito only works because it uses chroma 0.117–0.172 and a lightness range of 0.370 — both disqualifying here, and it contains #F0E442 bright yellow. The resolution is that lightness stagger is simultaneously the CVD fix AND the aesthetic move: a grid whose tiles vary slightly in lightness reads as a woven color field (Richter's colour charts, Albers) rather than a uniform board. The deliverable palette is "warm ink" — dark surface #171411, text capped at #DCD9D3 (13.03:1, APCA -82.9), light paper #F4F2EE with #27221D ink (14.09:1, APCA 95.1), and a high-contrast theme that keeps its warmth for a cost of 1.9 Lc out of 108 (1.8%). Two hard implementation catches: muted tile fills FAIL SC 1.4.11 (1.04–1.61:1 vs background) so the hairline outline is load-bearing, not decorative; and MediaQuery.highContrast is iOS-only — always false on Android — so the in-app toggle is mandatory, not a convenience.

### APCA is not in WCAG 3 and will not be soon; WCAG 2.x remains the only compliance target through this app's lifetime

*Confidence: high, **LOAD-BEARING***

APCA was marked exploratory and removed from the WCAG 3 working draft in July 2023 after failing to gain working-group consensus. As of April 2026 the draft states verbatim: 'The contrast algorithm used in WCAG 3 is yet to be determined.' No replacement algorithm is proposed. Roselli estimates WCAG 3 completion ~2030 or later. Practical consequence: ship WCAG 2.x AA (4.5:1 body / 3:1 large+non-text) as the compliance floor because that is what EAA/ADA/Play Store expectations reference, and use APCA Lc as the design tool for dark-mode judgment. Somers' own BridgePCA exists precisely to satisfy both. The proposed palette clears AAA (7:1) on all primary text pairs, so this tension never actually binds.

- https://adrianroselli.com/2026/04/wcag3-contrast-as-of-april-2026.html

- https://git.apcacontrast.com/documentation/APCA_in_a_Nutshell.html

### WCAG 2's specific flaw is that it is polarity-blind — I quantified it, and it is severe

*Confidence: high, **LOAD-BEARING***

I implemented WCAG 2 relative luminance and APCA 0.98G-4g in Python and validated against published references (#000/#FFF=21.00; #E0E0E0/#000=15.91; #FFF/#121212=18.73; APCA #888-on-#FFF=63.1, #FFF-on-#888=-68.5, #000-on-#AAA=58.1 — all exact). Results: #757575 on #FFFFFF = WCAG 4.61:1 / APCA Lc 72.0. #767676 on #000000 = WCAG 4.62:1 / APCA Lc -30.1. Identical WCAG verdict ('AA pass'); APCA says one is fine body text and the other is at the 'spot readable only' floor. Worse: #AFAFAF on #000 scores WCAG 9.57:1 (AAA!) but APCA Lc -59.0 — below the Lc 60 minimum for content text. The cause is the +0.05 additive flare constant, which dominates when both luminances are near zero, inflating ratios for dark pairs. The swap test is the clean demo: text #FFF/bg #5A5A5A and text #5A5A5A/bg #FFF are both WCAG 6.90:1, but APCA gives -88.8 vs 83.9. WCAG cannot see polarity at all.

- computed: /private/tmp/.../scratchpad/color.py (validated against APCA reference pairs)

- https://git.apcacontrast.com/documentation/APCA_in_a_Nutshell.html

### At iso-lightness, muted category colors collapse under colorblind simulation — only 2 survive, not 5

*Confidence: high, **LOAD-BEARING***

I implemented Viénot 1999 dichromat simulation and measured pairwise OKLab dE. At L=0.290 uniform, chroma 0.060: 2 hues (blue 250° + clay 55°) → min dE 10.1–11.9 across normal/protan/deutan/tritan = safe. 3 hues → 3.0–7.1. 4 hues → deutan 1.4, tritan 1.3 = indistinguishable. Blue(250°)~Violet(300°) hits deutan dE 0.7. Teal(175°)~Rose(10°) hits deutan 1.4 — because deutan destroys the red-green axis and teal/rose sit at opposite ends of exactly that axis. The surviving axis under deutan is blue-yellow, which affords ~2 categories. Adding lightness stagger (L 0.215–0.355) lifts 4 hues to deutan dE 5.6 — better, still under the dE~10 comfort threshold. Conclusion: 5 muted CVD-distinct categories is not achievable; it is a color-science impossibility, not a taste failure. Cap at 4 and make color strictly redundant with position + text label (which WCAG 1.4.1 Use of Color requires anyway, and which the brief's 'position IS the retrieval mechanism' already establishes).

- computed: /private/tmp/.../scratchpad/cat.py, cat2.py (Viénot 1999 matrices, OKLab dE)

### Okabe-Ito is the wrong tool for this app and would actively harm it

*Confidence: high, **LOAD-BEARING***

I scored Okabe-Ito on the same metric: 7 colors, min dE normal 15.6 / protan 9.1 / deutan 8.0 / tritan 6.8. It achieves this only via OKLCH chroma 0.117–0.172 (5–10× the muted budget this audience needs) and an OKLCH lightness range of 0.532→0.902 (range 0.370). It also contains #F0E442, a bright yellow at L=0.902 — the single highest-luminance stimulus, which is exactly what the (weak) autism luminance literature and the (stronger) aesthetic-preference data both point away from. Okabe-Ito was designed for thin lines and small markers on white in scientific figures, where tiny marks must pop; large field size lowers chromatic discrimination thresholds (Brown 1952 JOSA; large 12° fields discriminate better and are surround-independent vs 2° fields), so 76dp+ tiles need far less chroma than a scatter-plot dot to be identified. Steal the METHOD (vary lightness, verify under simulation), not the hex values.

- computed: /private/tmp/.../scratchpad/cat2.py

- https://opg.optica.org/josa/abstract.cfm?uri=josa-42-11-837

- https://pubmed.ncbi.nlm.nih.gov/3985906/

- https://personal.sron.nl/~pault/

### The 3x4 grid is NOT a pattern-glare risk — but small text is. This is an independent physiological argument for the type floor

*Confidence: medium, **LOAD-BEARING***

Wilkins' pattern glare peaks at 3 cycles/degree square-wave, high contrast, 50% duty; the 2-5 cpd band provokes illusory colors, distortion, nausea, and is implicated in visually-induced migraine. Migraine and visual stress are strongly comorbid with autistic sensory sensitivity. I computed actual spatial frequencies at 35cm viewing (1° = 6.11mm; 1dp = 0.15875mm): the 3-col tile grid at ~130dp pitch = 0.30 cpd; 2-col large mode = 0.20 cpd. That is 10× BELOW the glare peak — the grid is inherently safe, and a plausible-sounding worry is debunked. But stacked text: 20pt/1.4 line pitch = 1.37 cpd (safe); 14pt = 1.96; 11pt caption = 2.69 cpd (IN BAND); 9pt = 3.56 cpd (IN BAND, near peak). So the 17pt floor is justified twice over — legibility AND pattern glare. Caveat: applying grating research to text/tile arrays is an extrapolation, though Wilkins himself argues text approximates a grating and that this is why reading provokes visual stress. Corollary: glare requires HIGH contrast, so small text at max contrast is the worst case — another reason not to ship #FFF-on-#000.

- https://pubmed.ncbi.nlm.nih.gov/18565084/

- https://headachejournal.onlinelibrary.wiley.com/doi/abs/10.1111/head.12062

- computed: spatial frequency at 35cm, 160dpi baseline

### The 'autistic yellow aversion' claim is real but far too weak to design on — treat it as a tiebreaker, not a rule

*Confidence: low*

The primary source is Grandgeorge & Masataka 2016 (Front. Psychol.): 29 boys with ASD vs 38 TD boys, ages 4-17, forced-choice paired comparison across only SIX cardboard rectangles. Findings: ASD group significantly less likely to prefer yellow, more likely to prefer green and brown; no difference on red, blue, pink. Authors' own limitations: 'relatively small sample size,' restricted color selection. This is CHILDREN, n=29, one study, six colors — and this app's users are autistic ADULTS. Do not cite it as established. The proposed mechanism (yellow has the highest luminance of the tested set and requires simultaneous L+M cone activation) is at least a real physical claim and converges with the pattern-glare/luminance story. Weak convergent support: a 2025 BMC Psychology study on autistic traits and abstract color works found liking highest in the blue-purple-pink region and lowest in orange-yellow. Two weak studies pointing the same direction is a reason to steer away from yellow/orange as DOMINANT hues when nothing is lost by doing so — which is the case here. It is not a reason to ban yellow (I keep #FFD9A0 as the HC focus ring, where its high luminance is the point).

- https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2016.01976/full

- https://link.springer.com/article/10.1186/s40359-025-03876-6

### Color psychology (as usually invoked in design) is junk and must not justify any decision here

*Confidence: high*

The founder should be told this plainly. Specifics: the meta-analysis of red-on-cognitive-performance found that after correcting for publication bias, 'limited evidential value' remained, with a substantial number of negative findings missing from the literature. Baker-Miller Pink — the most famous 'color calms aggression' result — failed a controlled replication (Genschow et al. 2014): no effect on aggression, anger, or physical strength. The 2015 Elliot review concedes the empirical work 'remains at a nascent level.' Documented field-wide problems: inadequate color specification, underpowered samples, no cultural controls, oversimplified stimuli. Practical rule for this project: never argue 'blue is calming.' Argue from things that are measurable — luminance, chroma, contrast, spatial frequency, CVD dE. Every choice in the proposed palette is defended on photometric or perceptual-discrimination grounds, not semantics. The ONE legitimate use of color meaning here is cultural convention within the user's own vocabulary (e.g. a warmer tile for urgent phrases), and that is a learnable, user-editable association, not a psychological law.

- https://pmc.ncbi.nlm.nih.gov/articles/PMC7704521/

- https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2015.00368/full

- https://link.springer.com/article/10.3758/s13423-024-02615-z

### MediaQuery.highContrast is iOS-ONLY and always false on Android — a blocker for this Android-first app

*Confidence: high, **LOAD-BEARING***

Flutter's own API docs for MediaQueryData.highContrast state: 'This flag is currently only updated on iOS devices that are running iOS 13 or above' (it maps to iOS Settings → Accessibility → Increase Contrast). flutter/flutter#48418 tracks 'MediaQuery highContrast is always false.' Android's own 'high contrast text' setting is a separate, cruder OS-level force (it paints outlines behind text) and is not surfaced through this flag. Consequence: the brief's in-app one-tap theme switcher is not a nicety, it is the ONLY mechanism that will work on the target platform. Do not gate the HC theme behind MediaQuery.highContrastOf(context) — it will silently never fire. Read the flag if present (free win on any future iOS build) but drive the theme from app state. Related and useful: ColorScheme.fromSeed exposes contrastLevel (0.0 normal / 0.5 medium / 1.0 high, per M3 spec), which is the right knob if you generate rather than hand-author.

- https://api.flutter.dev/flutter/widgets/MediaQueryData/highContrast.html

- https://github.com/flutter/flutter/issues/48418

- https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html

### Muted tile fills FAIL WCAG SC 1.4.11 on their own — the hairline outline is load-bearing, not decoration

*Confidence: high, **LOAD-BEARING***

Computed tile-fill vs background contrast in the proposed dark palette: Clay 1.04:1, Teal 1.17:1, Blue 1.46:1, Rose 1.61:1. SC 1.4.11 Non-text Contrast requires 3:1 for visual information needed to identify UI components — the tile boundary qualifies. The muted fills cannot possibly carry this (that's the point of muting them). Therefore every tile needs an explicit 1dp outline, and its color is constrained: it must clear 3:1 against BOTH the background and the lightest tile fill. #6C6863 gives 3.32:1 vs bg #171411 but only 2.06:1 vs the Rose tile #552F35 — FAILS. #8A857F gives 5.02:1 vs bg and 3.11:1 vs Rose — PASSES both. Use #8A857F (dark) / #6F6A64 (light, 4.79:1 vs paper). This is the happy case where compliance and craft coincide: a fine keyline around each tile is the letterpress/engraving move that makes the grid read as considered rather than as flat blocks.

- computed: /private/tmp/.../scratchpad/final.py

### The text luminance cap is right, and the correct generalization is 'cap OKLCH L at ~0.885', not 'use #E0E0E0'

*Confidence: high, **LOAD-BEARING***

The brief's #E0E0E0 instinct is correct but hex-bound and hue-bound. #E0E0E0 is OKLCH L=0.907, C=0. The polarity- and hue-independent statement of the same principle: cap on-surface text at OKLCH L≈0.88-0.91 and let hue/chroma be whatever the palette wants. My warm equivalent #DCD9D3 sits at L=0.885, C=0.009, H=80. Cost accounting: #FFFFFF on #171411 = 18.35:1 / APCA -107.1. #DCD9D3 on #171411 = 13.03:1 / APCA -82.9. So the cap costs 24.2 Lc (23% of perceptual contrast) — and buys the elimination of halation bloom, which is the dominant dark-mode legibility complaint for the astigmatic (a large share of any adult population). It remains affordable because -82.9 still clears APCA's Lc 75 body-text minimum and vastly clears the Lc 60 needed for 20pt/weight-600 tile labels, while also clearing WCAG AAA (7:1) with room. The brief's framing that text luminance is the dominant halation lever (not background hex) is confirmed by these numbers.

- computed: /private/tmp/.../scratchpad/hc.py

- https://arxiv.org/pdf/2409.10841

### The high-contrast theme can keep its warmth almost for free — 1.8% of perceptual contrast

*Confidence: high*

Measured: pure #FFFFFF on #000000 = 21.00:1 / APCA -107.9. Warm #FFFCF7 on #0B0906 = 19.43:1 (92.5% of the WCAG max) / APCA -106.0. The APCA delta is 1.9 Lc out of 108 — 1.8%. Warmer still (#FFFAF2 on #120E09) = 18.50:1 / -104.6. So the answer to 'is high contrast just black and white?' is a quantified no: you can retain the palette's identity at max contrast for a rounding error. Caveats that keep this honest: (a) HC is a medical accommodation — if a user turns it on they cannot read otherwise, so never trade their contrast for your aesthetics beyond this near-free margin; (b) at HC the tile FILLS must be abandoned entirely (HC dark tile #171310 vs bg #0B0906 = 1.08:1, fails 1.4.11) and structure must move to full-strength outlines; (c) pure #FFF/#000 plus small text is precisely the pattern-glare worst case (max contrast, 2-5 cpd), so the warm variant is arguably better for the migraine-prone, not merely prettier.

- computed: /private/tmp/.../scratchpad/hc.py

### Author in OKLCH, ship hex; do NOT let ColorScheme.fromSeed generate the surfaces

*Confidence: high*

Practical differences: HSL is perceptually broken (fixed L across hues gives wildly different luminance — yellow at HSL 50% L is far brighter than blue). OKLCH and HCT are both perceptually uniform in hue/chroma; the real difference is the L axis. HCT's tone axis IS CIELAB L*, engineered so equal tone difference ⇒ predictable WCAG contrast — HCT is a hybrid of OKLab's hue/chroma with CIE L*'s contrast guarantee. That is HCT's whole reason to exist, and it is a WCAG-2-shaped guarantee — i.e. it optimizes for the algorithm I showed is polarity-blind. OKLCH has better perceptual uniformity, native browser support, and vastly better 2026 tooling (oklch.com, Evil Martians' work). Recommendation: author in OKLCH, verify in APCA + WCAG, emit hex constants. Do not use ColorScheme.fromSeed for surfaces: tonalSpot fixes the neutral palette at HCT chroma 4 and pins hue to the seed, which is exactly how every generic Material app gets its identical look — and M3's own default dark surface #141218 is OKLCH C=0.0124/H=300 (purple-tinted), which is a fine choice but is Google's choice, not yours. Use the explicit ColorScheme(...) constructor with hand-authored values while KEEPING the M3 role names so Material widgets theme correctly. If you want generation with control, rydmike's flex_seed_scheme exposes neutral chroma directly.

- https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl

- https://github.com/material-foundation/material-color-utilities/issues/125

- https://github.com/rydmike/flex_seed_scheme

- https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html

- computed: hex2oklch('#141218') = L 0.1874, C 0.0124, H 300.4

### Neutral chroma is the single highest-leverage craft variable; the crafted-vs-muddy window is OKLCH C 0.006-0.014

*Confidence: medium*

C=0.000 is a dead system grey — the 2014-enterprise look the founder is describing. C>0.020 in a large surface reads as 'tinted wrong' / muddy, because the eye reads a big field as a deliberate color rather than as a neutral and starts judging it as a hue choice. The usable window is roughly C 0.006-0.014, and the reference point is M3 itself: tonalSpot's neutral palette is HCT chroma 4 (≈ OKLCH C 0.012-0.015 at mid tones), neutralVariant HCT 8. The proposed ladder runs C 0.007→0.012, rising as surfaces get lighter — this mimics how real pigment and film behave (shadows desaturate, midtones hold chroma) and prevents the darkest surfaces from muddying. Chroma should also stay BELOW the tile chroma (0.048-0.065) by roughly 5x so the tiles read as the colored elements and the chrome recedes.

- https://m3.material.io/styles/color/the-color-system

- computed: /private/tmp/.../scratchpad/palette.py

### Dark mode is a polarity choice, not a default — and this app has a unique reason to ship all three that the brief already half-states

*Confidence: high, **LOAD-BEARING***

While & Sarvghad 2024 found each polarity benefits comparable proportions of users and recommend shipping both; observers with cloudy ocular media (cataract, common with age) read 10-15% better in dark, while astigmatics suffer halation in dark. There is no correct answer, only a per-user one. What is specific to THIS app: show mode inverts the requirement mid-interaction — the user's eyes want low luminance, the cashier reading the screen at arm's length in daylight wants high. Computed: warm show mode #1A140D on #FFFCF7 = 17.85:1 / APCA 103.3, versus pure #000/#FFF = 21.00:1 / 106.0. So show mode can stay in the palette's warm family at a cost of ~2.7 Lc. Recommendation: show mode should force the LIGHT/high-luminance polarity regardless of the app's current theme, because in that moment the display is an instrument pointed at a stranger, not at the user — and it should return to the user's theme on exit without asking.

- https://arxiv.org/pdf/2409.10841

- computed: /private/tmp/.../scratchpad/hc.py

## Design moves

- **THE CONCEPT: treat the 3x4 grid as a color-field composition, not a toolbar. Reference Gerhard Richter's colour charts (1024 Farben) and Albers' Homage to the Square — flat rectangles of muted color in a fixed grid, which is literally the app's form factor and hangs in major museums.**
  - Why: This is the answer to 'beautiful without motion.' The brief's hardest constraints — fixed grid, fixed positions, zero animation, huge tiles — are exactly the constraints of mid-century hard-edge abstraction, which was beautiful precisely because it was still. It also solves the dignity wedge at the level of cultural register: a children's AAC board and a Richter colour chart are the same OBJECT (grid of colored rectangles) in different registers. You are not fighting the grid, you are claiming a different lineage for it. Nothing needs to move because a color field doesn't move.
  - Risk: An art reference can slide into art-directed illegibility. Guard rail: the composition never overrides position (tiles never reflow for visual balance) and never overrides contrast. If a beautiful arrangement and a fixed position conflict, position wins every time — position IS the retrieval mechanism during a shutdown.
- **DARK SURFACE LADDER, warm (OKLCH H=65, C 0.007→0.012): surfaceDim #120F0C (L.170) / surface #171411 (L.192) / surfaceContainerLow #1E1A17 (L.222) / surfaceContainer #26211D (L.252) / surfaceContainerHigh #2F2A25 (L.288) / surfaceContainerHighest #39342F (L.328). onSurface #DCD9D3, onSurfaceVariant #AEAAA4, outline #8A857F.**
  - Why: Warm-tinted charcoal reads as lamplight and paper — domestic, evening, safe — where cool/purple-tinted dark (#141218, M3's default, which is OKLCH H=300) reads as screen and tech. For an app opened during a shutdown, that connotation is the whole product. Verified: onSurface/surface = 13.03:1 WCAG (clears AAA) and APCA -82.9 (clears the Lc 75 body minimum). onSurfaceVariant/surface = 7.94:1 / Lc -55.7 — correctly rated as secondary-only by APCA, so never use it for tile labels.
  - Risk: Warm low-chroma darks are one wrong step from mud. The chroma ladder must RISE with lightness (0.007 at the darkest → 0.012 at the lightest); a flat chroma across the ladder is what makes warm darks look brown and cheap. Also: this is a low-chroma warm on OLED, where near-black pixels switch off — check for black smearing on real Android OLED hardware, which #120F0C mitigates versus true #000.
- **LIGHT SURFACE LADDER, warm paper (OKLCH H=85, C 0.005→0.010): surfaceBright #F8F7F3 / surface #F4F2EE (L.962) / surfaceContainerLow #EDEBE6 / surfaceContainer #E8E5DF / surfaceContainerHigh #E1DED7 / surfaceContainerHighest #DAD6D0. onSurface #27221D (warm ink, NOT black), onSurfaceVariant #5A544E, outline #6F6A64.**
  - Why: Two moves keep light mode from going clinical, and both matter. (1) Background is #F4F2EE, not #FFFFFF — uncoated-paper warmth. (2) The one people skip: the INK is #27221D, not #000000. Pure black text on near-white is the clinical signal; warm-black ink on warm paper is the letterpress signal. Verified 14.09:1 / APCA 95.1 — which actually EXCEEDS APCA's Lc 90 'preferred for fluent text' bar, so the warmth costs nothing legible. Note light mode reaches Lc 95 where dark mode tops out at ~-83; light polarity simply has more perceptual headroom, which is worth knowing when tuning.
  - Risk: Warm paper under a blue-shifted night-mode filter or Android's own color correction can go visibly yellow-green. Test with Night Light on. Keep C≤0.010 in the surface ladder specifically so that any OS-level warming stacks without tipping into amber.
- **CATEGORY TILES — dark: Teal #00291F (L.250/C.048/H172), Blue #163553 (L.322/C.065/H250), Rose #552F35 (L.355/C.056/H10), Clay #2A1201 (L.214/C.050/H56). FOUR maximum, deliberately staggered in lightness (L 0.214→0.355), never iso-lightness.**
  - Why: The lightness stagger is simultaneously the accessibility fix and the beauty move — the rare case where they are the same decision. Accessibility: iso-lightness collapses to deutan dE 1.4; the stagger lifts it to 5.6. Beauty: a grid whose tiles differ slightly in lightness reads as woven/tapestry-like rather than as a uniform institutional board. Hues steer away from orange-yellow (weak convergent evidence) and toward blue/teal/rose (mildly preferred), with Clay as a low-chroma warm that reads brown, not yellow. Verified label contrast on every tile: 8.08:1–12.58:1, APCA -75.6 to -82.4 — all clear AAA and all clear Lc 75.
  - Risk: Even staggered, deutan dE 5.6 is below the ~10 comfort threshold — color ALONE will not distinguish these for a colorblind user. This is acceptable ONLY because color is redundant here (position is fixed and primary; the text label is always present, per WCAG 1.4.1). If any future feature makes color the sole carrier of meaning, this palette breaks. Also: 4 categories × 12 tiles means categories repeat — never let a category's color imply a category's position.
- **Every tile gets a 1dp outline: #8A857F (dark) / #6F6A64 (light). This is a compliance requirement, not a style choice.**
  - Why: Muted tile fills score 1.04:1–1.61:1 against the background — nowhere near the 3:1 that SC 1.4.11 requires to identify a UI component. The fills CANNOT carry the boundary; that is the arithmetic consequence of muting them for sensory reasons. #8A857F is the specific value that clears 3:1 against both the background (5.02:1) and the worst-case lightest tile (Rose, 3.11:1) — the more obvious #6C6863 passes vs background (3.32:1) but FAILS vs Rose (2.06:1), which is an easy bug to ship. Aesthetically this is free: a fine keyline is the engraving/letterpress move that makes the grid look drawn rather than dumped.
  - Risk: 1dp hairlines can disappear to sub-pixel rendering on low-DPI Android devices or vanish under aggressive display scaling. Use a physical-pixel-aware stroke and verify on a real ~1.5x device. If the outline vanishes, 1.4.11 fails silently with no visible symptom.
- **HIGH CONTRAST THEME — keep the warmth: dark #FFFCF7 on #0B0906 (19.43:1 / APCA -106.0); light #0B0906 on #FFFCF7 (19.43:1 / APCA 104.2). At HC, DROP all tile fills and move structure to full-strength outlines. Focus ring #FFD9A0 (14.85:1).**
  - Why: Warmth at max contrast costs 1.9 Lc out of 108 — 1.8%. So the high-contrast theme does not have to be an ugly mode the user is punished with; it can be recognizably the same app. Fills must go because HC tile #171310 vs bg #0B0906 = 1.08:1, which fails 1.4.11 outright — at HC the outline IS the tile. The amber focus ring is the one place high-luminance yellow earns its keep: a focus indicator is supposed to grab.
  - Risk: HC is a medical accommodation — someone enables it because they cannot read otherwise. Never trade their contrast for aesthetics beyond this near-free 1.8%. If a user reports the warm HC is insufficient, ship a pure #FFF/#000 escape hatch and do not argue. Also note the tension: max contrast + small text = the pattern-glare worst case, so HC must be paired with the large type ramp, never with dense text.
- **Drive the theme from app state, NOT from MediaQuery.highContrastOf. Read the system flag opportunistically if present, but never gate on it.**
  - Why: MediaQuery.highContrast is iOS-only per Flutter's own docs and is always false on Android — the target platform. Gating the HC theme on it means the theme literally never appears for the actual user base, and the bug is invisible in testing on a simulator. The brief's one-tap in-app switcher is therefore load-bearing infrastructure, not a convenience feature.
  - Risk: None to the user; this is strictly a correctness fix. Secondary consideration: persist the theme choice to local storage and restore it before first paint — a user in shutdown must not have to re-select the readable theme, and a flash of the wrong polarity is a sudden luminance change, which is the exact thing the zero-animation rule exists to prevent.
- **Show mode forces the light/high-luminance polarity regardless of the user's theme, in the palette's warm family: #1A140D on #FFFCF7 (17.85:1 / APCA 103.3). Return to the user's theme on exit, silently.**
  - Why: In show mode the screen stops being the user's instrument and becomes a sign pointed at a stranger, in daylight, at arm's length. The optimizations genuinely invert. Warm ink-on-paper holds 103.3 Lc versus 106.0 for pure #000/#FFF — a ~2.7 Lc cost to stay in family, which is affordable at these levels since anything past ~Lc 90 is beyond the fluent-reading bar anyway.
  - Risk: This is a large sudden luminance jump for the USER — from ~L0.19 surface to ~L0.98 — which is exactly the sensory hazard the zero-animation rule guards against. But cross-fading is also banned and costs latency. Honest recommendation: make the jump instant (it is briefer than a fade, and the user initiated it deliberately), and consider auto-raising screen brightness on entry with restoration on exit. Flag this as needing real user testing — I can compute the contrast but not whether the flash is tolerable.
- **Author in OKLCH, verify in APCA, ship WCAG-clearing hex constants via the explicit ColorScheme(...) constructor with M3 role names. Do not use ColorScheme.fromSeed for surfaces.**
  - Why: fromSeed/tonalSpot pins neutral chroma at HCT 4 and derives hue from the seed — it is a machine for producing the generic Material look, which is the founder's stated enemy. Hand-authoring costs one afternoon and is the entire difference between 'a Flutter app' and 'this app.' Keeping the M3 role names (surface, surfaceContainer, onSurface, outline…) means Material widgets still theme correctly with zero fighting. Every value in this palette is already computed and verified — the developer types constants, not guesses. If generation is ever wanted, flex_seed_scheme exposes neutral chroma directly.
  - Risk: Hand-authored schemes lose Android 12+ Material You dynamic color (wallpaper-derived theming). That is a real feature loss and should be a deliberate call — but for THIS app it is arguably a feature: a communication tool whose colors shift because the user changed their wallpaper would break position/color learning, and the brief already forbids reflow for exactly that reason. Color stability is part of the retrieval mechanism.
- **Never argue a color choice from color psychology. Ban 'blue is calming' from the design vocabulary and defend every value photometrically instead.**
  - Why: The red-on-cognition meta-analysis found limited evidential value surviving publication-bias correction; Baker-Miller Pink failed controlled replication. This app has real users in real distress and cannot afford decisions grounded in folklore. Every choice above is defended on measurable grounds — OKLCH L, chroma, WCAG ratio, APCA Lc, CVD dE, cycles/degree. That is also, incidentally, what makes the palette defensible to an app-store reviewer, a clinician, or a skeptical user.
  - Risk: None, but note the one legitimate exception: user-assigned color meaning. If a user wants their panic phrases on the Rose tiles, that association is real and learned and belongs to them — it just isn't a universal law, and it must be user-editable rather than baked in.

## References

- **Gerhard Richter — colour charts (192 Farben, 1024 Farben)** https://www.gerhard-richter.com/en/art/paintings/abstracts/colour-charts-12
  - Steal: THE central reference. Literally a fixed grid of flat, unmodulated color rectangles — the app's exact form factor — hanging in the Pompidou and Tate. Steal the proof that a grid of colored tiles is a museum object, not a kindergarten object; the register is set by chroma discipline, flatness, and edge quality, not by the grid itself. Also steal the flatness: Richter's tiles have no gradient, no shadow, no bevel. Zero animation and zero depth are the aesthetic, not a compromise.
- **Josef Albers — Homage to the Square / Interaction of Color** 
  - Steal: Nested flat rectangles with no motion, proving that adjacency alone generates visual interest. Steal the core lesson directly applicable to the category tiles: perceived color depends on neighbors, so verify tile colors IN SITU next to each other, never in isolation on a swatch sheet — two tiles that look distinct alone can collapse when adjacent.
- **Braille Institute — Atkinson Hyperlegible** https://www.brailleinstitute.org/freefont/
  - Steal: Already in the brief for type, but steal its POSITIONING: an accessibility artifact that is genuinely well-crafted and shipped by a disability institution without a single cartoon. It is the existence proof for the founder's whole thesis — accessible and beautiful are not in tension, they were just never funded together.
- **Andrew Somers — APCA / BridgePCA** https://git.apcacontrast.com/
  - Steal: Use the Lc scale as the design instrument (the tool, not the compliance target). Specifically steal BridgePCA, which is built precisely for this project's situation: satisfy APCA's perceptual truth while remaining provably WCAG 2 compliant for legal/store purposes.
- **Evil Martians — OKLCH in CSS + oklch.com picker** https://oklch.com
  - Steal: The authoring workflow and the free interactive picker with live P3/sRGB gamut boundaries. Use it to tune the L/C/H triples in this report without writing conversion code.
- **rydmike — flex_seed_scheme (Flutter package)** https://github.com/rydmike/flex_seed_scheme
  - Steal: The escape hatch if hand-authoring proves unmaintainable: it exposes neutral/neutralVariant chroma and per-palette tone control that ColorScheme.fromSeed hides, letting you keep M3 machinery while overriding the chroma-4 neutral that causes the generic look.
- **Paul Tol — muted qualitative scheme (#6699CC #004488 #EECC66 #994455 #997700 #EE99AA)** https://personal.sron.nl/~pault/
  - Steal: Steal the METHOD, not the hexes (they are tuned for white scientific figures, not dark tiles). Specifically steal Tol's discipline of publishing CVD-simulated versions of every scheme alongside the original — replicate that as a CI check on the tile palette so a future color tweak cannot silently break deutan separation.
- **Adrian Roselli — WCAG 3 / contrast status writing** https://adrianroselli.com/2026/04/wcag3-contrast-as-of-april-2026.html
  - Steal: The standing correction to APCA hype and the source of record for what is actually normative. Re-check before shipping any accessibility claim in store copy — this is the dimension where confidently-wrong 2021-era blog advice is still widely repeated.
- **Arnold Wilkins — pattern glare / visual stress research** https://pubmed.ncbi.nlm.nih.gov/18565084/
  - Steal: The 3 cycles/degree criterion, and the habit of computing spatial frequency rather than guessing at it. Worth revisiting before adding ANY repeating visual texture, list, or symbol grid in v1+ — the tile grid is safe at 0.30 cpd, but a dense symbol set or a settings list could easily land in the 2-5 cpd band.
- **Muji / Aesop / Kinfolk — warm-neutral commercial palettes** 
  - Steal: The commercial proof that warm off-whites and low-chroma warm darks read as adult, calm, and premium rather than as clinical or childish. Steal the specific restraint: these brands use ~2-3 hues at very low chroma and let material, type, and spacing do the work — the exact budget this app has.

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


YOUR DIMENSION: The color system. Beautiful, calm, accessible, and NOT grey — all at once.

Research with WebSearch/WebFetch: color science for UI, OKLCH/OKLab and perceptual color (2025-2026 state), APCA vs WCAG 2 contrast (APCA is in WCAG 3 drafts — what's its actual status in 2026?), Material 3's HCT color space and tonal palettes, dark mode color craft, color and autistic sensory sensitivity, color psychology (be skeptical — most of it is junk; say so).

- **The contrast question, properly**: WCAG 2.x contrast ratio math and its known flaws (it's badly wrong for dark mode — verify and explain WHY). APCA/Lc — what is it, what's its status in 2026, should this project use it? What are the actual APCA Lc thresholds vs WCAG's 4.5:1? If they disagree for this app's palette, which wins? (Note: legal/store expectations may still be WCAG.)
- **HCT vs OKLCH vs HSL** — Material uses HCT (Google's own space). What's the practical difference and does it matter for hand-picking a palette? Which should a developer author in? Is there tooling in 2026?
- **The dark palette**: how do you make a dark theme that's beautiful rather than "black with grey text"? Specifics: tinted blacks (warm vs cool — what does each communicate?), the surface elevation ladder (M3 surfaceContainer tones — get the exact tone values), how much chroma to leave in "neutral" surfaces (M3 lets you set neutral chroma — what value reads as crafted vs muddy?), text luminance capping (the research says cap text at ~#E0E0E0 — is that right, and what's the equivalent principle in a tinted/warm palette?).
- **The light palette**: NOT pure white? Warm paper tones? What's the craft move? How do you keep light mode from looking clinical?
- **The high-contrast theme**: is it just black/white, or can it be beautiful too? What do the platforms actually do (iOS Increase Contrast, Android high contrast text)? What does Flutter expose (`MediaQuery.highContrastOf`)?
- **Autistic sensory sensitivity and color — what does the EVIDENCE actually say?** Be rigorous and skeptical: is there real research on autistic color preference/aversion, or is it folklore? (Look for actual studies — I've heard claims about yellow aversion and saturation sensitivity. Verify or debunk.) What about photosensitivity/migraine (specific spatial frequencies and colors are actual migraine triggers — find the real science)?
- **Category color-coding**: how many hues can you use before it's a rainbow? How do you make a categorical palette that's harmonious AND distinguishable AND colorblind-safe (8% of men)? What are the real colorblind-safe categorical palettes (Okabe-Ito? Paul Tol's?) and do they look good or scientific?
- Give an ACTUAL PROPOSED PALETTE with real hex values for dark/light/high-contrast, with contrast ratios computed, and a rationale for each choice. This is the deliverable.

Be quantitative. Real values, real ratios.
````

</details>
