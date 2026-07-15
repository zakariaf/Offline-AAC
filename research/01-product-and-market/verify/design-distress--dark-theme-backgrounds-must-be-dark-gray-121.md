# design-distress--dark-theme-backgrounds-must-be-dark-gray-121

> Phase: **verify** · Agent `afeab6f0d848c68be` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Material 2 (2019) specified #121212 as the dark-theme baseline with a translucent-white elevation-overlay ramp (#1E1E1E at ~5%, ~#242424 at 7-8%). Material 3 — the current spec and Flutter's default since 3.16 — superseded this: the baseline dark surface is #141218 (neutral tone 6), and elevation overlays were REPLACED by tone-based surface containers (surfaceContainerLowest/Low/…/Highest). Flutter's docs explicitly state ColorScheme.dark() "matches the baseline Material 2 color scheme" and "shouldn't be used to update the Material 3 color scheme."

Of the three claimed reasons, only ONE is Material's actual sourced rationale — that high white-on-black contrast can increase eye strain (Chris Banes, Android Developers). The other two are not from Material Design; they originate from codeformatter.in, an SEO blog for a CSS formatter with no primary citations, and were misattributed:
- OLED black smear: not Material's rationale; the "pixels are off and lag when waking" mechanism is folk physics. Display-engineering sources indicate dark-gray-to-mid-gray transitions often ghost MORE than black-to-white, so #121212 is not an established fix and may not help.
- Halation/iris aperture: physically wrong as a #000-vs-#121212 discriminator. Contrast only moves 21.0:1 → 18.73:1 (-11%), and #121212 sits at 0.605% of white luminance — far too low to change pupil aperture, which per Piepenbrock et al. (2014) responds to overall display luminance (near-identical for both).
- Elevation: the real M2 argument, but the mechanism is deprecated. Shadows are invisible on #121212 too — that is WHY M3 switched to tone rather than shadow.

The corollary is inverted in importance: capping text (#FFFFFF→#E0E0E0) drops contrast 21.0 → 15.91 (-24%), more than double the effect of lifting the background off pure black. Capping text luminance is the primary halation lever; the background hex is secondary.

Corrected claim: "Use a dark gray background rather than pure black, and cap text luminance below pure white. The dominant reason is contrast/eye-strain and halation control — driven mainly by text luminance, not the background hex — plus the need for a visible surface hierarchy. In Flutter, implement this with ColorScheme.fromSeed(brightness: Brightness.dark) and M3 surfaceContainer roles (baseline dark surface #141218), not the deprecated M2 #121212 + white-overlay ramp. #121212 vs #141218 vs #000000 is a minor cosmetic choice; OLED black smear is not a substantiated reason." Confidence should be moderate, not high.

**Evidence:** CONCLUSION: The recommendation (dark gray background, not pure black; capped text contrast) is directionally correct and should NOT change. But the claim is misattributed, outdated by a full Material version, and two of its three "independent reasons" are unsupported or physically backwards. "High" confidence was not warranted.

WHAT SURVIVES:
- Material does recommend dark gray over pure black. Chris Banes (Google, Android Developers) confirms the rationale: pure black maximizes OLED power savings, but "Placing these against a pure black background means that the resulting contrast is much higher, which can increase eye strain." #121212 is a real Material value.
- Verified in Flutter master source (packages/flutter/lib/src/material/color_scheme.dart): ColorScheme.dark() hardcodes `this.surface = const Color(0xff121212)` (4 occurrences incl. deprecated `background`).
- The corollary (don't use pure white text) is the best-supported part of the whole claim — see #3 below.

REFUTATION 1 — MISATTRIBUTION. The cited m3.material.io/blog/android-dark-theme-tutorial is a 2019 MATERIAL 2-era tutorial. I fetched its Medium twin (medium.com/androiddevelopers/dark-theme-with-mdc-4c6fc357d956): it discusses ONLY power-vs-eye-strain and elevation overlays. It says NOTHING about black smear or halation. Those two reasons trace verbatim to the second source, codeformatter.in — which I fetched and confirmed is an SEO content-marketing blog for a free CSS formatter tool. It is the literal origin of "black pixels are turned completely off", pixels having to "wake up", "This lag creates a motion blur effect", and forcing "the iris to open wider" — with NO primary citations for any of those physics claims. The researcher laundered an SEO blog's folk-physics into an attribution to Material Design.

REFUTATION 2 — OUTDATED BY A FULL MATERIAL VERSION (kills reason 3 as stated). Material 3 replaced the #121212 + translucent-white-overlay elevation model with tone-based surfaces. material-components-android docs/theming/Dark.md: "Surface with elevation overlays has been replaced in Material components with the tonal surface color system." Flutter's own API docs state ColorScheme.dark "matches the baseline Material 2 color scheme" and "shouldn't be used to update the Material 3 color scheme" — use ColorScheme.fromSeed(brightness: Brightness.dark). M3 baseline dark surface is #141218 (neutral tone 6), NOT #121212. So "the #121212 baseline permits an elevation ramp (level 1 = #1E1E1E, level 2 = #242424)" describes a DEPRECATED system. Also "you cannot cast a shadow on #000000" is imprecise: shadows are effectively invisible on ANY near-black including #121212 — which is precisely WHY M3 abandoned shadow/overlay for tone. #121212 does not rescue shadows.

REFUTATION 3 — REASON 2's PHYSICS IS FALSIFIED BY ARITHMETIC (I computed WCAG contrast directly):
  white on #000000 = 21.0:1
  white on #121212 = 18.73:1  (only -11%; both far above any comfort threshold)
  #121212 relative luminance = 0.605% of white
A background at 0.6% of white luminance CANNOT meaningfully change iris aperture. Piepenbrock et al. (Ergonomics, 2014) ties pupil size to OVERALL DISPLAY LUMINANCE (the "display luminance hypothesis") — which is essentially identical for #000000 and #121212, since the field is dominated by text/UI, not the background. Halation is real for moderate-to-high astigmatism, but it is driven by the BRIGHT SOURCE (the text), not the 0.6% background lift. Decisive: capping text #FFFFFF→#E0E0E0 on #000000 drops contrast 21.0 → 15.91 (-24%) — MORE THAN TWICE the effect of lifting the background. The "corollary" they treated as an afterthought is the load-bearing lever; the main claim is the weak one. They have it backwards.

REFUTATION 4 — REASON 1 IS UNSUPPORTED AND POSSIBLY BACKWARDS. Black smear is not in Material's stated rationale at all. Display-engineering sources note response time is not one universal number — panels are often quick black-to-white yet "noticeably slower when shifting from dark gray to medium gray," i.e. dark-gray-to-mid-gray transitions frequently ghost MORE than black-to-white. Black smear is also predominantly a VA-panel / OLED-monitor-TV phenomenon. #121212 is not an established smear fix, and may not help.

NET: "Three independent reasons" is the weakest framing. There is really ONE sourced reason (contrast/eye-strain, which in M3 is restructured as tone-based surfaces), one deprecated reason (elevation overlay ramp), and two unsourced SEO-blog reasons of which one is arithmetically wrong.

PRACTICAL IMPACT FOR THIS AAC APP: Keep the dark-gray background (#121212–#141218 are both fine; the difference is cosmetic). But (a) build it with ColorScheme.fromSeed(seedColor: ..., brightness: Brightness.dark) and M3 surfaceContainerLow/surfaceContainer/surfaceContainerHigh roles for tile elevation — NOT a hand-rolled #121212/#1E1E1E/#242424 overlay ramp, which is the M2 mechanism Flutter has moved off (useMaterial3 has defaulted true since Flutter 3.16). (b) Prioritize capping text luminance (~#E0E0E0) over agonizing about the background hex — that is where the actual halation/eye-strain win is for distressed autistic and astigmatic users, and it is the one part of the claim the literature genuinely supports.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
PRODUCT IDEA UNDER RESEARCH — "Dignified offline AAC for adults & teens with situational speech loss"

Who it's for: Autistic adults and teens who go non-speaking during shutdowns/meltdowns/sensory overload, plus people with selective mutism, aphasia, or post-seizure speech loss. Communities: r/autism, r/AutisticAdults, r/selectivemutism, AAC communities.
The problem: Mainstream AAC apps are built for young children — cartoon avatars, "parental" account gates, kiddie vocabulary — infantilizing for adults, so they abandon them. Premium options (Proloquo2Go/TouchChat/LAMP) run ~$299 and are iOS-only.
Why offline is essential: It's a disability accommodation, not a networked service. The user must be able to "speak" instantly — in a shop, an ER, a car with no signal, mid-shutdown — with zero login, zero loading, full privacy.
The core job: Tap a phrase/symbol tile (or type) and the phone speaks it aloud, instantly, offline, adult-appropriate design, no account.
MVP: grid of large customizable phrase tiles + "type to speak" box + on-device TTS. Editable categories. No sign-up. Nothing leaves device. Dark, calm, adult visual design.
Risks: TTS must sound acceptable; design must feel adult without being cold; must be usable one-handed by someone in distress.
Target stack: Flutter (cross-platform iOS + Android; user prefers Flutter over React Native).
Today's date: 2026-07-15. Prefer recent sources (2024-2026).


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "design-distress". A product decision depends on it, so it must be right.

CLAIM: Dark theme backgrounds must be dark gray (#121212), not pure black, for three independent reasons
THEIR DETAIL: Material Design specifies #121212 as the dark-theme baseline. (1) OLED black smear: #000000 pixels are physically off and lag when waking during scroll, producing ghosting. (2) Halation: maximum white-on-pure-black contrast triggers the astigmatic bleed effect and forces wider iris aperture. (3) Elevation: you cannot cast a shadow on #000000; the #121212 baseline permits an elevation ramp (level 1 = #1E1E1E, level 2 = #242424) that pure black collapses. Corollary: also do not use pure white text — cap contrast rather than maximize it.
THEIR CLAIMED SOURCES: https://m3.material.io/blog/android-dark-theme-tutorial, https://www.codeformatter.in/blog-dark-mode.html
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
