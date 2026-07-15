# current-design-language--flutter-has-not-shipped-material-3-expressiv

> Phase: **verify** · Agent `aa30314222e9d9bf1` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Strike "Flutter 3.44 stable (2026-05-16) shipped material_ui: ^1.0.0 and cupertino_ui: ^1.0.0 on pub.dev." Replace with: Flutter froze contributions to the in-SDK Material and Cupertino libraries beginning at the 3.44 stable cutoff (April 7th, per flutter/flutter#184093). Placeholder packages material_ui and cupertino_ui exist on pub.dev under verified publisher flutter.dev, but both are at version 0.0.1, unlisted, and marked "Coming soon" — there is no 1.0.0 of either, and they are not yet a usable migration target. The "^1.0.0", "code freeze: bug fixes only, no new APIs", and "emits a deprecation warning" details trace to the startdebugging.net blog post, not to Flutter's release notes or issue tracker; treat them as unverified secondary sourcing. Per #184093, near-term "nothing should change" for existing users and migration is not required for a year or more. The claim's NOTE is upgraded from unverified to confirmed: material_ui's own pub.dev roadmap says "Once landed and published, look forward to updates from Material 3 Expressive!" — M3E has not landed anywhere official. Practical upshot is unchanged and reinforced: hand-roll.

**Evidence:** CORE CLAIM CONFIRMED. flutter/flutter#168813 "☂️ Bring Material 3 Expressive to Flutter" is real, opened 2025-05-14, still open. The team statement is verbatim accurate: "Currently, we are not actively developing Material 3 Expressive, and we will not be accepting contributions for Expressive features or updates at this time." Every sub-feature is unchecked: the 15 new/updated components (app bars, button groups, carousel, common buttons, extended FAB, FAB menu, FABs, icon buttons, loading indicator, navigation bar, navigation rail, progress indicators, split button, toolbars), motion-physics system, visually emphasized typography, the 35-shape expanded library, and vibrant color schemes. The 2025-07-29 update about decoupling Material/Cupertino into standalone packages, with M3E work happening there "once established" (tracked under #101479), is accurate.

The researcher's own hedge is now RESOLVED IN THEIR FAVOR, upgraded from "unverified" to affirmatively confirmed. material_ui's pub.dev page, published by verified publisher flutter.dev, states in its roadmap: "Once landed and published, look forward to updates from Material 3 Expressive!" Future tense, from Flutter's own publisher. M3E has NOT landed in material_ui. The instinct to quarantine the Medium-sourced "Flutter will support M3E and Liquid Glass as optional packages" claim was correct.

m3e_core CONFIRMED: exists on pub.dev, publisher muditpurohit.tech, v0.1.2, MIT, github.com/mudit200408/m3e_core. Unofficial, as stated.

SPECIFICS THAT BREAK:

(1) VERSION ROT — the central factual error. "Flutter 3.44 stable shipped material_ui: ^1.0.0 and cupertino_ui: ^1.0.0 on pub.dev" is FALSE. Both packages sit at version 0.0.1, are marked unlisted, and are labeled "Coming soon." The material_ui/versions page shows exactly one published release: 0.0.1, ~4 months ago. No 1.0.0 exists for either package. They are not a usable migration target today.

(2) SOURCE CONTAMINATION — the ^1.0.0 number traces to startdebugging.net, the researcher's own cited secondary source, which instructs readers to "Pin material_ui: ^1.0.0 in pubspec.yaml" and prints a working pubspec example presenting the packages as immediately usable. The phrasings "code freeze: bug fixes only, no new APIs" and "you will see a deprecation warning on package:flutter/material.dart" are that blog's wording verbatim. Neither appears in the official 3.44.0 release notes at docs.flutter.dev. This is the exact failure mode the researcher flagged for M3E/Liquid Glass, then committed one sentence later with a blog-invented version number.

(3) PRIMARY SOURCE CONTRADICTS THE TONE — flutter/flutter#184093 "[Decoupling] Material and Cupertino are now frozen" says contributions are frozen "beginning at the next stable release cutoff (3.44) on April 7th" (not 2026-05-16), that the new packages become available "some time after the 3.44 stable release," and near-term "nothing should change for you and Material and Cupertino should continue working as usual." Full deprecation/removal is anticipated beyond one year out. The freeze on contributions is real; the picture of a shipped, deprecation-warning-emitting, migrate-now 1.0.0 is not.

DECISION IMPACT: none adverse — the recommendation is strengthened. The corrections remove the only reason to consider waiting on the framework. There is no shippable material_ui to migrate to; waiting buys a 0.0.1 placeholder whose own roadmap defers M3E to the future. Hand-rolling the shape/type/color language for 12 tiles, a text field, and ~3 buttons remains correct. Do not block on the framework.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "current-design-language" made this claim, and a design decision depends on it.

CLAIM: Flutter has NOT shipped Material 3 Expressive. As of 2026-07 there is no official implementation — the founder must hand-roll, which is fine for a one-screen app
DETAIL: flutter/flutter issue #168813 ('Bring Material 3 Expressive to Flutter'), opened 2025-05-14. Team statement, verbatim: 'Currently, we are not actively developing Material 3 Expressive, and we will not be accepting contributions for Expressive features or updates at this time.' ALL sub-features listed as not-started: 15 new/updated components, motion-physics system, emphasized typography, the 35-shape expanded library, vibrant color schemes. 2025-07-29 update: Material/Cupertino being decoupled into standalone packages; M3E work would happen there 'once established.' Flutter 3.44 stable (2026-05-16) shipped `material_ui: ^1.0.0` and `cupertino_ui: ^1.0.0` on pub.dev; in-SDK `package:flutter/material.dart` is now code-frozen (bug fixes only, no new APIs) and emits a deprecation warning. NOTE: I found NO verification that M3E actually landed in material_ui — claims that 'Flutter will support M3E and Liquid Glass as optional packages' trace to a low-quality Medium post, not Flutter's team. Treat as unshipped until proven. Community package `m3e_core` exists on pub.dev (unofficial). PRACTICAL UPSHOT: this app consumes almost no Material components — 12 tiles, a text field, ~3 buttons. Hand-rolling the shape/type/color language is a weekend, not a quarter. Do not block on the framework.
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/168813, https://startdebugging.net/2026/05/flutter-3-44-material-cupertino-packages-swiftpm-default/, https://pub.dev/packages/m3e_core
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
