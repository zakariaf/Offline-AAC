# typography-system--licensing-trap-brailleinstitute-org-gates-th

> Phase: **verify** · Agent `a17d8a89893ab0746` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the claim's assertions — all verified. Two additions worth folding in: (1) Atkinson Hyperlegible Next, Atkinson Hyperlegible, and Atkinson Hyperlegible Mono are all available directly on Google Fonts (fonts.google.com/specimen/Atkinson+Hyperlegible+Next), which is an equally ungated and generally simpler source than the GitHub repo. (2) The claim should not be extended to assert the Braille Institute EULA imposes non-OFL terms — that document is behind a JS viewer and its contents could not be verified. What is verified is only that the flow requires email + EULA acceptance and never names the OFL.

**Evidence:** Every falsifiable specific in this claim survived primary-source checking. This is unusual for this corpus — I attempted the standard failure modes (invented specifics, API rot, license folklore) and found no substantive error.

1) REPO EXISTS, OFL CONFIRMED (verified at source). github.com/googlefonts/atkinson-hyperlegible-next exists, is described as "New (2024) second version of the Atkinson Hyperlegible fonts," and OFL.txt IS in the repo root. Its text states "This Font Software is licensed under the SIL Open Font License, Version 1.1." Copyright line: "Copyright 2020-2024 The Atkinson Hyperlegible Next Project Authors". The original repo googlefonts/atkinson-hyperlegible carries "Copyright 2020 Braille Institute of America, Inc." also under OFL 1.1. So "The font IS SIL OFL 1.1" is correct.

2) THE GATING IS REAL, AND THE EXACT QUOTED STRING IS REAL. Fetching brailleinstitute.org/freefont/ directly: the strings "Open Font License", "OFL", and "SIL" do NOT appear anywhere on the page. The phrase "Free for personal use and all commercial applications" appears three times — once each for Atkinson Hyperlegible, Atkinson Hyperlegible Next, and Atkinson Hyperlegible Mono. Exactly as the claim describes, verbatim. Download requires (a) an email address, marked Required, and (b) a required checkbox: "By downloading, installing and/or using the font software, you confirm that you have read and agree to be bound by the terms of this End-User License Agreement." The EULA is a separate link to https://brailleinstitute.box.com/s/rin3vzegmcy7sil28yfqslz2r5etv5nl. Both the email gate and the EULA-acceptance gate are confirmed.

3) THE FLUTTER API IS REAL AND CORRECTLY NAMED — no version rot. api.flutter.dev confirms LicenseRegistry in the foundation library with static method addLicense. Exact signature: `static void addLicense(LicenseEntryCollector collector)`. The claim's API name is right, which is the specific thing that usually breaks in this corpus.

4) THE "MIS-FILED AS CUSTOM LICENSE" MECHANISM IS CORROBORATED, NOT SPECULATION. Wikipedia's licensing history states the Braille Institute "released it on its website through a custom license" and that "in 2021, they made it available through Google Fonts under the SIL Open Font License." So the BI-hosted distribution genuinely did originate under non-OFL terms — the confusion the claim describes has a real historical root, not just a wording accident.

TWO CAVEATS (neither refutes the claim):

(a) I could NOT read the EULA contents. The box.com link renders through a JavaScript viewer and returned no text. So whether that EULA is proprietary terms or merely a restatement of the OFL is UNVERIFIED. The claim doesn't actually assert the EULA is non-OFL — it only asserts the flow requires accepting one, which is confirmed — so this doesn't damage it. But anyone repeating the stronger "the EULA is a different license" framing would be going beyond what I could substantiate.

(b) The claim's remedy is correct but narrower than necessary. Atkinson Hyperlegible Next is ALSO on Google Fonts directly (fonts.google.com/specimen/Atkinson+Hyperlegible+Next), as are Atkinson Hyperlegible and Atkinson Hyperlegible Mono. So the GitHub repo is not the only ungated OFL route — Google Fonts itself is ungated and is the simpler path for most Flutter workflows (including google_fonts package usage). The claim isn't wrong, just incomplete on options.

BOTTOM LINE: The design decision this supports is safe to make. The font is OFL 1.1; taking it from googlefonts (repo or Google Fonts specimen), shipping OFL.txt, and registering via LicenseRegistry.addLicense() is correct and buildable as written.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "typography-system" made this claim, and a design decision depends on it.

CLAIM: LICENSING TRAP: brailleinstitute.org gates the OFL font behind email registration + EULA acceptance. Download from the googlefonts repo instead.
DETAIL: The font IS SIL OFL 1.1, but the Braille Institute's own download flow requires accepting a EULA and handing over an email — for a font that is open-source. The brailleinstitute.org/freefont page says only 'Free for personal use and all commercial applications' and never names OFL, which is how this gets mis-filed as a custom license. Take it from github.com/googlefonts/atkinson-hyperlegible-next (OFL.txt in repo root), ship OFL.txt, and register it via LicenseRegistry.addLicense().
CLAIMED SOURCES: https://github.com/googlefonts/atkinson-hyperlegible-next, https://www.brailleinstitute.org/freefont/, https://en.wikipedia.org/wiki/Atkinson_Hyperlegible
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
