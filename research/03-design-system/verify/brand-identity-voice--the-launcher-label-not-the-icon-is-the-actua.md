# brand-identity-voice--the-launcher-label-not-the-icon-is-the-actua

> Phase: **verify** · Agent `ad1c71a83e458a653` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The label is a real outing surface and shipping a name containing "AAC" or "Speech" is a genuine mistake worth fixing — but the "~80%" figure is fabricated with no methodology, the 11/12 and 4/12 participant figures are uncited, unlocatable, and describe reactions to device *use* rather than home-screen glances (so they cannot adjudicate label-vs-icon), and "60x60dp" is not an Android spec figure (the spec is 108x108dp with a 66x66dp safe zone and a 72x72dp masked viewport; ~48–60dp is a variable Launcher3 per-grid display value). Critically, the premise that only third-party launchers can rename is backwards from the team's position: the developer fully controls android:label, and per the documented <activity-alias> element (whose android:label/android:icon override the target's) combined with PackageManager.setComponentEnabledSetting, an app can ship user-selectable launcher labels and icons that work on stock Pixel Launcher. Correct framing: label and icon are BOTH outing surfaces with no evidence establishing a ratio between them; ship a discreet default name and expose a documented in-app alias switcher so the user chooses their own disclosure — and drop the 80/20 claim, which no study supports.

**Evidence:** The claim's core intuition (the label is an outing surface and deserves attention) survives, but every load-bearing specific is either fabricated, uncited, or wrong — and the central premise is factually inverted.

1. "~80% a naming problem" — FABRICATED. No source, no methodology, no derivation. It is a rhetorical number dressed as a measurement. There is no study anywhere apportioning outing risk between launcher label and launcher icon, and none could produce a figure like this without an experimental design (bystander recognition task, controlled glance duration) that does not exist in the literature. A design decision is being justified with an invented ratio. This alone is disqualifying for a "high confidence" rating.

2. "11/12 use AAC only where they feel safe" and "4/12 avoid situations to dodge device reactions" — UNCITED and NOT LOCATABLE. Searches across the AAC stigma literature (tandfonline AAC journal, ASSETS/SIGACCESS proceedings, PMC) surfaced adjacent work — e.g. "Mental health and mental health problems among users of AAC: a scoping review" (AAC journal, 2024; n across included studies 3–78), "Public Reflections on the Use of AAC Devices by People with I/DD in Everyday Life" (ASSETS '25), and multi-stakeholder AAC barrier work (PMC11197385) — but nothing matching an n=12 study with these two proportions. Even granting the figures are real, they are a NON SEQUITUR for this claim: both describe reactions to *using* the device in public (synthesized speech, on-screen grid, the act of tapping) — not to a bystander glancing at a home screen. They cannot adjudicate label-vs-icon. The claim borrows their authority for a proposition they do not address.

3. "~60x60dp icon" — NOT A SPEC FIGURE. Per developer.android.com adaptive icon guidance: all layers are 108x108dp, the masked viewport is the inner 72x72dp, and the guaranteed-unclipped safe zone is 66x66dp. There is no 60dp in the Android icon spec. The number appears to be conflated with AOSP Launcher3's `device_profiles.xml` `launcher:iconSize`, a *display* value that varies roughly 48–60dp by grid/density/launcher — i.e. a per-grid config value, not a design constant, and it is the low end of the range at best.

4. "~12sp label" — ROUGHLY RIGHT, by accident. Launcher3's `device_profiles.xml` sets `launcher:iconTextSize` per grid profile at approximately 12–13sp. Directionally fine, but it is a variable OEM/grid config, not the fixed constant the claim implies, and Android 15 added a "show long app names" two-line toggle that changes label rendering.

5. "Stock launchers (Pixel) provide no rename; only third-party launchers (Nova) do" — TRUE FOR USERS, FATALLY INCOMPLETE FOR THE TEAM. Confirmed that stock Pixel Launcher has no rename affordance and that Nova/Action Launcher do. But this framing treats the label as something imposed on the app, which is backwards: the DEVELOPER controls `android:label` absolutely, and per developer.android.com's `<activity-alias>` documentation, `android:label` and `android:icon` on an alias override the target's values ("none of the values set for the target carry over to the alias"), while an alias carrying MAIN/LAUNCHER intent filters is "represented in the application launcher, even though none of the filters on the target activity itself set these flags." Combined with `PackageManager.setComponentEnabledSetting`, this is the standard, documented mechanism for shipping *user-selectable* launcher labels and icons that work on stock Pixel Launcher with no third-party launcher required. The claim's own recommendation is therefore both more achievable and more powerful than it realizes — but its stated reasoning for why the label is intractable is wrong.

6. "The text string is far more semantically legible to a glancing bystander than any 60x60 mark" — ASSERTED, UNEVIDENCED, and mechanically dubious. No study is offered. The icon occupies roughly 5–25x the pixel area of the label and is the element that survives distance and peripheral vision; 12sp text requires close proximity and foveation to read. A speech-bubble-and-grid mark is also semantically legible to any informed observer. The inversion ("optimizing the wrong surface") is a preference stated as a finding.

BOTTOM LINE: "Do not ship a name containing 'AAC' or 'Speech'" is sound, cheap, actionable advice and is well supported by the manifest/alias mechanics. But it does not *invert* the brief — nothing here demonstrates the icon is the wrong surface, only that the label is also a surface. Both are outing surfaces; the claim substitutes a fabricated 80/20 for the comparative evidence it would need. Treat the naming recommendation as a design instinct worth acting on (via activity-alias, offering the user a choice), and discard the quantification, the borrowed participant stats, and the 60x60dp figure entirely.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "brand-identity-voice" made this claim, and a design decision depends on it.

CLAIM: The launcher LABEL, not the icon, is the actual outing surface — discretion is ~80% a naming problem
DETAIL: Android home screens display the app label by default at ~12sp immediately under a ~60x60dp icon. Stock launchers (Pixel) provide no rename; only third-party launchers (Nova) do. Given 11/12 use AAC only where they feel safe and 4/12 avoid situations to dodge device reactions, the text string is far more semantically legible to a glancing bystander than any 60x60 mark. This inverts the brief's framing: agonizing over icon discretion while shipping a name containing 'AAC' or 'Speech' is optimizing the wrong surface.
CLAIMED SOURCES: (none)
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
