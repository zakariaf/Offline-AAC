# color-system--muted-tile-fills-fail-wcag-sc-1-4-11-on-thei

> Phase: **verify** · Agent `a06bdacc69171fb5f` · Run `wf_f237e8a6-694`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** The tile fills' low contrast (Clay 1.04, Teal 1.17, Blue 1.46, Rose 1.61 against #171411) is arithmetically correct but is NOT an SC 1.4.11 failure. SC 1.4.11 explicitly does not require a visual boundary on a control whose visible content (symbol + word label, as on every AAC tile) already identifies it. The outline is therefore NOT compelled by WCAG; W3C recommends delineating control boundaries only as an advisory best practice for cognitive accessibility. Furthermore, the requirement that the outline clear 3:1 against the tile fill as well as the background is not a WCAG requirement: for UI components, "adjacent color" means the external background (W3C's own example measures a dark border against the white EXTERNAL background, not the white internal fill), and colors that do not interfere with identifying the component may be ignored. Consequently #6C6863 is not disqualified: its 3.32:1 against the background is all 1.4.11 would ask of an outline, and its 2.06:1 against the Rose fill is not measured. Correct framing: keep the 1dp outline and #8A857F if desired, but justify it as craft plus a W3C-endorsed cognitive-accessibility best practice, not as SC 1.4.11 conformance. Do not tell the team WCAG mandates it. Separately, note that if the category fill colors are intended to convey meaning independently (e.g. Fitzgerald Key part-of-speech coding), that raises a distinct question under the "graphical objects" half of 1.4.11 -- which would be an argument against the muted palette, not an argument for the outline.

**Evidence:** ARITHMETIC: fully verified, all five checkable ratios exact to 3 decimal places using the WCAG 2.x relative-luminance formula. #6C6863 vs #171411 = 3.318 (claimed 3.32); #6C6863 vs #552F35 = 2.059 (claimed 2.06); #8A857F vs #171411 = 5.017 (claimed 5.02); #8A857F vs #552F35 = 3.113 (claimed 3.11); Rose #552F35 vs bg = 1.611 (claimed 1.61). The computation is not the problem.

NORMATIVE CLAIM REFUTED ON THREE POINTS, all from the primary source (W3C Understanding SC 1.4.11):

1. "Muted tile fills FAIL SC 1.4.11 on their own" is false. Verbatim: "This success criterion does not require that controls have a visual boundary indicating the hit area." And: "If a control has visible content (such as text or a sufficiently contrasting icon), which helps users identify the presence of the control, then a border or other indication of the overall boundary of the hit area is not required." The doc's own example: "A button without a visual boundary - the button's text is sufficient to indicate the presence of the control." An AAC tile carries a symbol plus a word label, which is exactly the exempted case. The fills are never asked by 1.4.11 to carry 3:1.

2. "The hairline outline is load-bearing, not decoration" is inverted relative to the source. W3C places the boundary recommendation in advisory text: "For people with cognitive disabilities, it is a best practice to delineate the boundary of all controls, even those that have visible content, to aid in the recognition of controls and the completion of activities." Best practice, not requirement. The claim promotes advisory guidance to a conformance mandate and then uses that fabricated mandate to constrain the palette.

3. The "must clear 3:1 against BOTH the background and the lightest tile fill" constraint is invented, and it is the sole basis for rejecting #6C6863. WCAG defines adjacent color for a UI component as the EXTERNAL color: "if an input has a white internal background, dark border, and white external background the 'adjacent color' to the component would be the white external background." The internal fill is not measured. Additionally: "If components use several colors, any color which does not interfere with identifying the component can be ignored for the purpose of measuring contrast ratio." The 2.06:1 outline-vs-Rose-fill measurement therefore has no normative force, and #6C6863 (3.32:1 vs bg) is not disqualified.

UNVERIFIABLE SUB-CLAIMS: Clay (1.04), Teal (1.17), Blue (1.46) fill hexes were never supplied, so those ratios cannot be independently checked; Rose, the only hex given, is exact, which is a reasonable prior that the others are too. The light-mode "paper" hex is also absent: #6F6A64 yields 4.756:1 against a paper of ~#F5F1EA vs the claimed 4.79:1, so plausible but unconfirmed.

WHAT SURVIVES: #8A857F is a sound outline color, and the craft/cognitive-accessibility case for a keyline is real and endorsed by W3C as best practice, which carries genuine weight for an AAC user population. The recommendation is defensible; the justification for it is not.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "color-system" made this claim, and a design decision depends on it.

CLAIM: Muted tile fills FAIL WCAG SC 1.4.11 on their own — the hairline outline is load-bearing, not decoration
DETAIL: Computed tile-fill vs background contrast in the proposed dark palette: Clay 1.04:1, Teal 1.17:1, Blue 1.46:1, Rose 1.61:1. SC 1.4.11 Non-text Contrast requires 3:1 for visual information needed to identify UI components — the tile boundary qualifies. The muted fills cannot possibly carry this (that's the point of muting them). Therefore every tile needs an explicit 1dp outline, and its color is constrained: it must clear 3:1 against BOTH the background and the lightest tile fill. #6C6863 gives 3.32:1 vs bg #171411 but only 2.06:1 vs the Rose tile #552F35 — FAILS. #8A857F gives 5.02:1 vs bg and 3.11:1 vs Rose — PASSES both. Use #8A857F (dark) / #6F6A64 (light, 4.79:1 vs paper). This is the happy case where compliance and craft coincide: a fine keyline around each tile is the letterpress/engraving move that makes the grid read as considered rather than as flat blocks.
CLAIMED SOURCES: computed: /private/tmp/.../scratchpad/final.py
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
