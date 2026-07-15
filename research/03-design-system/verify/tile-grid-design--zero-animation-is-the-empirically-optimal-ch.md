# tile-grid-design--zero-animation-is-the-empirically-optimal-ch

> Phase: **verify** · Agent `a31c809c54da78087` · Run `wf_f237e8a6-694`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** Kaaresoja's guideline governs FEEDBACK ONSET LATENCY (touch -> start of feedback), not animation duration. Flutter's `_kSplashFadeDuration = 200ms` is the fade-OUT duration of the splash's alpha animation on release/cancel (`_alphaController.forward()` is called only in `confirm()`/`cancel()`), not a delay before feedback appears. Flutter's splash BEGINS immediately on tap-down (`_radiusController..forward()` in the constructor), so its onset latency is ~one frame plus the platform touch pipeline — roughly 30-55ms, which falls INSIDE the thesis's 30-85ms visual guideline. Flutter's default ink splash is therefore compliant with this research on the axis the research actually measured, not a violation of it.

The thesis provides NO support for "zero animation is empirically optimal." It never tested a no-animation condition — visual feedback was present in every condition (a green HLMP-0504 LED, since an LCD was too slow for the study design), and only its delay was varied. The thesis's actual conclusion runs the other way: PSS for visual is 32ms and significantly different from 0ms, and the author writes that "it is not necessary to reach zero latency." The guideline's 30ms lower bound places instantaneous feedback BELOW the recommended minimum.

Zero animation may still be the right call for this tile grid — on grounds of vestibular/motion sensitivity (WCAG 2.3.3 Animation from Interactions), cognitive load for AAC users, or frame budget on low-end devices. Those are legitimate, defensible reasons. But it is an accessibility and performance decision, not an empirically optimal one, and Kaaresoja cannot be cited as its evidence base. Citing it this way would not survive review by anyone who opens the PDF.

**Evidence:** UNUSUAL CASE: every citation and number checks out against the primary source. The INFERENCE is a category error, and the headline claim is contrary to what the thesis concludes.

WHAT VERIFIED (I extracted all 217 pages of the real PDF via pypdf; WebFetch could not parse it):

Table 4-2 (p.137), transcribed verbatim from the thesis:
  |         | PSS   | Sig. drop in "simultaneous" | 75% threshold | Sig. drop in quality | GUIDELINE  |
  | Visual  | 32 ms | 70-100 ms                   | 85 ms         | 100-150 ms           | 30 - 85 ms |
  | Audio   | 19 ms | 50-100 ms                   | 80 ms         | 70-100 ms            | 20 - 70 ms |
  | Tactile | 5 ms  | 20-50 ms                    | 52 ms         | 70-100 ms            | 5 - 50 ms  |
Every figure in the DETAIL matches exactly. Title page confirms "Submitted... March 2015", University of Glasgow (catalogued 2016). Table 5-2 (p.184) confirms bimodal visual-tactile. ACM TAP 11(2), Art. 9, 2014, DOI 10.1145/2611387 is real and peer-reviewed (verified via eprints.gla.ac.uk/104653/ — ACM returns 403 to bots). Flutter constants verified verbatim at lines 19-20 of ink_splash.dart.

WHY IT IS STILL REFUTED:

1. LATENCY IS NOT ANIMATION DURATION. The thesis measures onset latency — delay between touch and the ATTACK of feedback. `_kSplashFadeDuration` is the duration of the alpha fade-OUT. Line 159 binds it to `_alphaController`, which only calls `.forward()` inside `confirm()` (line 190) and `cancel()` (line 195) — i.e. when the splash DISAPPEARS after release. It is not an onset delay. The comparison is dimensionally invalid.

2. THE THESIS EXPLICITLY FORECLOSES THIS USE. Section 4.2.6.1: "asynchrony perception is not dependent on the duration of the feedback but was based on the attack (beginning) of the feedback. Therefore, it is assumed that the duration of the stimulus does not affect the simultaneity perception of touch and visual feedback, either." The thesis's own stated assumption says animation duration is outside what the guideline governs.

3. THE VISUAL STIMULUS WAS AN LED, NOT A SCREEN. Section 4.2.4.1: two rectangular green LEDs (HLMP-0504, 565nm, 2.5x7.6mm) mounted above capacitive switches on an Arduino rig. Section 4.2.6.1: "It was not possible to use a proper LCD display as it would not have had a low enough latency... The green feedback LED glowed as long as the button was pressed." A binary step function. The word "animation" appears ZERO times in 217 pages; so do "splash", "ripple", "fade", "Material Design".

4. FLUTTER'S SPLASH ALREADY CONFORMS. Line 155: `_radiusController ..forward()` fires in the constructor — expansion starts immediately on tap-down. By the thesis's own metric (onset), Flutter's splash lands at touch pipeline + one frame = ~30-55ms, INSIDE the 30-85ms window. The DETAIL does this arithmetic itself and fails to notice it exonerates Flutter rather than indicting it.

5. "ZERO ANIMATION IS OPTIMAL" IS CONTRARY TO THE SOURCE. No no-feedback condition was ever tested; feedback was always present and only its delay varied. The thesis concludes the OPPOSITE in spirit (p.134): "32 ms is enough for visual feedback and 19 ms for audio. Therefore, it is not necessary to reach zero latency." The 30ms lower bound means instant (0ms) is BELOW the recommended minimum.

6. ARITHMETIC ERROR ON ITS OWN TERMS. Visual quality drop is 100-150ms. 200 > 150 — so even accepting the invalid comparison, 200ms is BEYOND the band, not "squarely inside" it.

7. BIMODAL MISREAD. Table 5-2 gives visual-tactile as "<= 100 ms" / "<= 55 ms" — ceilings, not the point values the DETAIL states.

SAMPLE (context): 24 participants (12F, 26-50), 23 of 24 Nokia Research Center employees, Helsinki. Experiment 2: 24 participants, all Nokia employees. Single-lab, industry-employee sample; no replication found.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "tile-grid-design" made this claim, and a design decision depends on it.

CLAIM: Zero animation is the empirically OPTIMAL choice for tile feedback, not an accessibility compromise — and Flutter's default ink splash sits in the measured perceived-quality-drop zone
DETAIL: Kaaresoja, 'Latency Guidelines for Touchscreen Virtual Button Feedback' (PhD thesis, University of Glasgow, submitted March 2015; core study published as Kaaresoja, Brewster & Lantz, ACM Transactions on Applied Perception, 2014). Verified from the primary source, Table 4-2: Point of Subjective Simultaneity — visual 32ms, audio 19ms, tactile 5ms. 75% simultaneity thresholds — visual 85ms, audio 80ms, tactile 52ms. Significant drop in perceived quality scores — visual at 100–150ms, audio 70–100ms, tactile 70–100ms. Resulting unimodal guidelines: visual feedback 30–85ms, audio 20–70ms, tactile 5–50ms. Bimodal visual-tactile: visual 100ms, tactile 55ms. Against this: Flutter's ink_splash.dart defines _kSplashFadeDuration = Duration(milliseconds: 200) and _kUnconfirmedSplashDuration = Duration(seconds: 1). A 200ms splash fade is DOUBLE the upper guideline and squarely inside the measured quality-drop band. Note the guideline has a LOWER bound of 30ms because the minimum was set at the PSS — but you do not need to add delay: Android's touch pipeline (~20–40ms) plus one frame (8–16ms) lands you naturally at ~30–55ms, inside the window.
CLAIMED SOURCES: https://theses.gla.ac.uk/7075/1/2016kaaresojaphd.pdf, https://dl.acm.org/doi/10.1145/2611387, https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/ink_splash.dart
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
