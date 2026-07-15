# m3-expressive-deep--m3-expressive-is-not-implemented-in-flutter

> Phase: **verify** · Agent `a7ef05cb1b43f564b` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Split the claim in two, because the halves have opposite verdicts as of 2026-07-15.

TRUE and safe to build on: M3 Expressive is NOT implemented in Flutter. Nothing has shipped in stable 3.44.0 — no components, no motion-physics springs, no 35-shape library, no emphasized typography, no vibrant/contrast-level color schemes. No milestone or Flutter version number is attached to any M3E issue, and the material_ui package is 0.0.2 with publish_to: none (unpublished, unusable). If the design decision is "we cannot use M3E from the framework today," that still holds and is well-supported.

FALSE as of today: "is not being worked on" and "contributions are refused." Both were true from 2025-05-14 to roughly 2025-07-29 and are now obsolete. Flutter decoupled Material into packages/material_ui in flutter/packages specifically to ship M3E faster; the team opened 20 P2 proposal issues in April 2026, has a public design proposal doc, merged the Material token pipeline (tokens v38.0.15, 2026-07-13), has an M3 Expressive IconButton PR in review (flutter/packages#12093), and has publicly invited community collaboration. The "won't accept your PR" line is a third-party paraphrase, not a Flutter team quote, and no longer describes policy.

Correct framing: "M3 Expressive is not yet available in Flutter stable (3.44.0) and has no announced version target. After a strategic pause from May-July 2025, work resumed in the decoupled material_ui package in flutter/packages; ~20 tracked P2 proposals exist and the first components (IconButton) are in review as of July 2026. Timeline unknown — treat availability as indefinite, but not as abandoned or closed to contribution."

Practical consequence: if the decision was "don't wait for Flutter, hand-roll or use third-party," the conclusion survives on timeline uncertainty alone. If the decision was "Google has abandoned this / there's no point contributing / it will never land," that rationale is refuted and should be rewritten. Re-check #168813 and the #1849xx series quarterly rather than treating any single read as durable.

**Evidence:** The claim's quotes are REAL but STALE BY ~13 MONTHS. Every quoted string is verbatim-accurate to an older revision of flutter/flutter#168813 (opened 2025-05-14, title "☂️ Bring Material 3 Expressive to Flutter", still OPEN, milestone: null). The May 14 2025 and June 10 2025 updates say exactly what the researcher quotes: "we are not actively developing Material 3 Expressive right now, and we will not be accepting contributions for these features at this time", "consistent design pattern and a planned rollout", "strategic pause". The X/Twitter paraphrase "so that someone does not spend a bunch of their time crafting a big PR that won't be accepted" is a third-party gloss (@mahersafadii, 2025-05-14), NOT Flutter team language — it does not appear in the issue.

WHAT THE RESEARCHER MISSED — the two 2025 updates they quote are now collapsed inside <details> tags on the live issue, i.e. explicitly SUPERSEDED. The issue's current top-level text is a July 29 2025 update: "The material and cupertino libraries are being decoupled into standalone packages to accelerate feature development. All new work for Material 3 Expressive will happen in the new packages once established in flutter/packages." Reading only the collapsed sections inverts the meaning of the page. Issue last updated 2026-06-30.

REFUTED — "is not being worked on": It is being actively worked on by paid Flutter team members, in the open, right now:
- packages/material_ui EXISTS in flutter/packages (pubspec: name material_ui, "The official Flutter Material UI Library", version 0.0.2, flutter: ">=3.44.0", publish_to: none). Sibling cupertino_ui also exists.
- Twenty M3 Expressive tracking issues opened 2026-04-12/13 by the team, each with a written proposal, all labeled c: proposal + P2 + team-design + triaged-design: #184932 Motion-physics, #184933 Typography (assigned to elliette, a Google Flutter engineer), #184934 Expanded shape library, #184935 App bars, #184936 Button groups, #184937 Buttons, #184938 Extended FAB, #184939 FAB menu, #184940 Icon buttons, #184941 Loading Indicator, #184942 Nav bar, #184944 Nav rail, #184945/#184946 Progress indicators, #184947 Sliders, #184948 Split buttons, #184949 Toolbars, #184950 Fix token pipeline, #184951 Colors, plus #185124 [VPAT] accessibility review.
- Note P2, not P3 — the umbrella #168813 is still P3, which is likely what the researcher sampled.
- Live PRs by Flutter team members: flutter/packages#12093 "[material_ui] Add Material 3 Expressive IconButton" (QuncCccccc, opened 2026-07-01, open), #11800 same title (2026-05-28, superseded), #11931 "Add global Material style variant", #11801 "Add contrastLevel for M3 ColorScheme", #12192 "Import of Material tokens v38.0.15" (MERGED 2026-07-13), #11762/#11918 gen_defaults pipeline (merged). This is token-pipeline-plus-first-component work, not investigation.

REFUTED — "contributions are refused": Flutter team member Piinks commented on #168813: "We have decided to decouple the design libraries in order to more rapidly adopt new features in the Material library." Google's CarlosMendonca commented: "Flutter remains fully committed to supporting both Cupertino and Material... The decoupling effort is the first step toward becoming faster in delivering updates. Once that work lands, we will follow up with details on how M3 Expressive updates will gradually roll out IN COLLABORATION WITH OTHER COMMUNITY MEMBERS that have already implemented some features," and links a public design proposal doc. Piinks also floated on-thread: "if we introduced a material_expressive package in flutter/packages, would contributors want to work with us to build Expressive there?" The refusal was time-boxed and has lapsed.

STILL TRUE — not implemented: Correct, and this is the part the design decision can rely on. All 20 M3E issues are OPEN, none assigned a milestone, no Flutter version number attached anywhere. material_ui is 0.0.2 with publish_to: none — not on pub.dev, not usable. CHANGELOG has only "Initial setup of the material_ui package, preparing for decoupling Material widgets from the Flutter framework." docs.flutter.dev/ui/design/material still documents only M3-via-useMaterial3 (default since 3.16) and does not mention Expressive, material_ui, or decoupling at all. So in Flutter stable 3.44.0 today: no motion-physics springs, no 35-shape library, no emphasized typography, no LoadingIndicator/ButtonGroup/SplitButton/FabMenu/Toolbar widgets. Anything shipping M3E today is third-party pub.dev packages (expressive_loading_indicator, m3e_collection, etc.), not framework.

MINOR SPECIFICS: "all 15 components" — the issue prose says "Fifteen new or updated components" but renders only 14 checkboxes (App bars, Button groups, Carousel, Common buttons, Extended FAB, FAB menu, FABs, Icon buttons, Loading indicator, Navigation bar, Navigation rail, Progress indicators, Split button, Toolbars). The researcher's own enumeration lists 13 and drops plain FABs. The team's 2026 breakdown adds Sliders and Colors — items not on the 2025 umbrella at all. The "35 shapes" figure is real and sourced to the M3 Figma Design Kit per #184934.

ALSO WORTH FLAGGING: m3.material.io/develop at one point listed Flutter as "in maintenance mode... will no longer receive feature updates from Material" — a researcher could easily cite this as corroboration. Google staff called it wrong on-thread: guidezpl "let me get that fixed"; CarlosMendonca "The documentation on material.io is inaccurate, and we are already working with the Material team to fix it." Do not use that page as a source.

CONFIDENCE HAZARD: the claim was filed "high" confidence on a single URL read once, apparently without expanding collapsed sections or checking the issue's updatedAt. A load-bearing fact sourced to one GitHub issue read at one point in time will rot silently; this one did.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "m3-expressive-deep" made this claim, and a design decision depends on it.

CLAIM: M3 Expressive is NOT implemented in Flutter, is not being worked on, and contributions are refused. This is the load-bearing fact of the whole dimension.
DETAIL: Umbrella issue flutter/flutter#168813 opened 2025-05-14. On 2025-06-10 the team announced a 'strategic pause': 'we are not actively developing Material 3 Expressive right now', wanting a 'consistent design pattern and planned rollout'. Unimplemented: all 15 components (button groups, FAB menu, loading indicator, split button, toolbars, updated app bars/carousel/buttons/extended FAB/icon buttons/nav bar/rail/progress indicators) AND all expressive styles (motion-physics system, emphasized typography, the 35-shape expanded library, vibrant color schemes). No Flutter version number or milestone has ever been attached. Flutter's team communicated early specifically 'so that someone does not spend a bunch of their time crafting a big PR that won't be accepted'.
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/168813
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
