# color-system--wcag-2-s-specific-flaw-is-that-it-is-polarit

> Phase: **verify** · Agent `a2142823cc05f3c83` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Keep the numbers — every one is verified against the official apca-w3 reference. Replace the thesis. Correct version: "WCAG 2 is provably polarity-blind (identically symmetric by construction), but that symmetry is a MINOR error: the pure-polarity effect is only median 1.4 / max 9.0 Lc and rarely changes a verdict — the claim's own swap test (|88.8| vs |83.9|, both above the Lc 75 body minimum) shows the two metrics AGREEING, because APCA discards the sign before its font lookup. WCAG 2's severe and design-relevant flaw is that it OVERRATES DARK PAIRS: 43% of grays passing WCAG AA on #000 fail APCA's Lc 60 content-text minimum, versus 0% on #FFF. #767676/#000 scores 4.62:1 (AA) at APCA |30.1| (spot-read floor); #AFAFAF/#000 scores 9.57:1 (AAA) at |59.0| (below content minimum). The cause is NOT the +0.05 flare 'inflating' dark ratios — the flare demonstrably suppresses them (drop it to 0.005 and #767676/#000 jumps from 4.62 to 37.23) and doesn't dominate at these colors anyway (Y=0.18 >> 0.05). The cause is that the 4.5:1 threshold was calibrated on light-mode pairs while the linear-luminance-ratio model doesn't track perception at the dark end; the CRT-era 0.05 is masking an even larger overstatement. Practical upshot: trust WCAG 2 in light mode, do not use it to validate a dark-mode palette."

**Evidence:** ARITHMETIC: FULLY CONFIRMED — no invented specifics. I downloaded the official apca-w3 reference implementation (raw.githubusercontent.com/Myndex/apca-w3/master/src/apca-w3.js), npm-installed its colorparsley dependency, and ran calcAPCA() against every claimed pair. All 8 match to the stated decimal: #888/#FFF=63.1, #FFF/#888=-68.5, #000/#AAA=58.1, #757575/#FFF=72.0, #767676/#000=-30.1, #AFAFAF/#000=-59.0, #FFF/#5A5A5A=-88.8, #5A5A5A/#FFF=83.9. The Python constants match the reference line-for-line (normBG .56, normTXT .57, revTXT .62, revBG .65, blkThrs .022, blkClmp 1.414, scaleBoW/WoB 1.14, loBoWoffset/loWoBoffset .027, loClip .1, deltaYmin .0005, mainTRC 2.4). Independent third-party corroboration: Datawrapper reports #888888 on white = APCA 63. WCAG values reproduce the W3C (L1+0.05)/(L2+0.05) definition. The researcher's instrumentation is sound.

PREMISE CONFIRMED: WCAG 2 IS exactly polarity-blind. Over 200k random pairs, max |WCAG(a,b) − WCAG(b,a)| = 0 (identically zero — it's min/max by construction, so symmetry is provable, not empirical). APCA is polarity-sensitive. That part is airtight.

THREE FAILURES IN THE DIAGNOSIS:

(1) SEVERITY IS INVERTED — the showcase demo actually shows AGREEMENT. The swap test "-88.8 vs 83.9" reads dramatic only because of the sign. Line 569 of the official APCA reference reads `contrast = Math.abs(contrast); // Polarity unneeded for LUT` — APCA STRIPS THE SIGN before the font lookup. The sign is a polarity label, not a worse score. So APCA says |88.8| vs |83.9| = 5.0 Lc apart, both far above the Lc 75 body-text minimum: both polarities are fine for body text. Same verdict as WCAG. The "clean demo" of a severe flaw demonstrates the two metrics agreeing. Across 300k random pairs the pure-polarity swing is median 1.4 Lc, 99th pct 8.1, MAX 9.0 Lc. A ≤9 Lc effect is not "severe."

(2) MISATTRIBUTED — the claim's own strongest data is not polarity. #757575-on-#FFF vs #767676-on-#000 are DIFFERENT color pairs, not a swap; a polarity demo requires the same two colors reversed, so this example cannot demonstrate polarity-blindness at all. Same for #AFAFAF/#000. What those examples actually show is dark-pair overrating, and THAT effect is genuinely severe and asymmetric: of 139 grays passing WCAG AA on #000, 60 (43%) fail APCA Lc 60; of 119 grays passing WCAG AA on #FFF, 0 (0%) fail. The real flaw is real — the claim just filed it under the wrong heading.

(3) MECHANISM IS BACKWARDS. The claim: the +0.05 flare "dominates when both luminances are near zero, inflating ratios for dark pairs." Both halves are false. Sweeping the flare F for #767676/#000: F=0.0001→1812.64, F=0.005→37.23, F=0.02→10.06, F=0.05→4.62, F=0.2→1.91. Lowering the flare RAISES dark-pair ratios toward infinity — the +0.05 SUPPRESSES them; it is the only thing preventing division by zero. And it does not "dominate" at #767676/#000: Y=0.1812 >> 0.05. It dominates only for genuinely near-black pairs (#121212/#000: Y=0.0060 → WCAG 1.12), where it CRUSHES the ratio toward 1 — strict, not inflated. Myndex's actual critique is different: 0.05 models CRT-era glare and is too HIGH for modern LCD/OLED, meaning an accurate flare term would make WCAG's dark-end overstatement WORSE, not better. The 0.05 is masking the problem, not causing it.

WHY THIS MATTERS FOR THE DESIGN DECISION: the corrected diagnosis changes what you do. If you believe polarity is the flaw, you look for a polarity-aware fix and assume WCAG is otherwise usable. The true finding is stronger and more actionable: WCAG 2 is usable in light mode (0% false-pass rate on white) and structurally unreliable in dark mode (43% false-pass on black). Per Myndex: "WCAG 2.x contrast cannot be used for guidance designing dark mode."

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "color-system" made this claim, and a design decision depends on it.

CLAIM: WCAG 2's specific flaw is that it is polarity-blind — I quantified it, and it is severe
DETAIL: I implemented WCAG 2 relative luminance and APCA 0.98G-4g in Python and validated against published references (#000/#FFF=21.00; #E0E0E0/#000=15.91; #FFF/#121212=18.73; APCA #888-on-#FFF=63.1, #FFF-on-#888=-68.5, #000-on-#AAA=58.1 — all exact). Results: #757575 on #FFFFFF = WCAG 4.61:1 / APCA Lc 72.0. #767676 on #000000 = WCAG 4.62:1 / APCA Lc -30.1. Identical WCAG verdict ('AA pass'); APCA says one is fine body text and the other is at the 'spot readable only' floor. Worse: #AFAFAF on #000 scores WCAG 9.57:1 (AAA!) but APCA Lc -59.0 — below the Lc 60 minimum for content text. The cause is the +0.05 additive flare constant, which dominates when both luminances are near zero, inflating ratios for dark pairs. The swap test is the clean demo: text #FFF/bg #5A5A5A and text #5A5A5A/bg #FFF are both WCAG 6.90:1, but APCA gives -88.8 vs 83.9. WCAG cannot see polarity at all.
CLAIMED SOURCES: computed: /private/tmp/.../scratchpad/color.py (validated against APCA reference pairs), https://git.apcacontrast.com/documentation/APCA_in_a_Nutshell.html
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
