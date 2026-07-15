# Design Rationale

This document is the argument. The values live in `theme/tokens.dart`. Read this when you want to change something and need to know what it costs — and when you want to know which decisions are load-bearing and which are taste wearing a citation.

**Start with the uncomfortable part.** In the n=12 study this product is built on, the themes rank: typing 12/12 · customization 12/12 · speed 11/12 · trust/privacy 11/12 · TTS quality 10/12 · **infantilizing design 5/12**. Visual design is last of the six, at less than half the participants. The voice — which this document barely touches — is *double* it.

So: this is a design document about the sixth-ranked complaint, and it should be read as such. It matters, it is the emotional core of the positioning, and it is not the diagnosis. If the voice picker ships badly and the grid ships beautifully, the app fails. The order of work is voice, then speed, then this.

That said — 5/12 is not nothing, the abandonment literature names aesthetics as a cause, and the founder asked for something beautiful. What follows is how to deliver that without lying about the evidence.

---

## 1. The central tension, resolved

**The brief is achievable. The tension as posed is mostly false — but not for the reason the research first claimed.**

The corpus's headline resolution was Tuch et al. (2012): perceived beauty = low visual complexity + high prototypicality, which is the same recipe as the usability constraints, so the constraints aren't a tax on beauty. That argument does not survive its own fact-check. The study is n=59 mostly-Basel psychology undergraduates rating 2012 company homepages in 17–1000ms flashes. Prototypicality is measured *against a category* — nobody has measured whether an AAC grid is prototypical of AAC apps, so "the fixed grid delivers prototypicality for free" is an assumption, not a finding. And complexity was *selected* (via JPEG file size and subjective pre-ratings), not manipulated — which means saturation is **confounded with** complexity in the one physiological result everyone quotes, not contrasted against it.

So the honest position is worse and more useful: **nobody has measured whether chroma costs a sensory-sensitive user anything.** Not the corpus, not the field. The "visual complexity raises corrugator tension" finding cannot be cleanly separated from chroma, and it was measured on neurotypical undergrads looking at web pages.

The resolution is structural, in two parts.

### 1.1 The tension is between two states, not two properties

The person who judges the app beautiful is at rest. The person who uses it is in shutdown. They are the same human and they are almost never in the same moment. Beauty is consumed at rest — installing it, showing a friend, seeing the icon on the home screen, editing a phrase on a Sunday. The interface is consumed in crisis: find tile, tap.

That means one surface does not have to serve both states. **One structure, two surfaces, switched by the user.** The structure carries retrieval and never moves. The surface carries identity and can be stripped in one tap.

This is not our invention. It is the source study's own §6.5 recommendation: *"simplifying the app's colors or board when the user is overwhelmed"* in a way that *"keeps the user in control"* and *"does not impede motor plans."* The paper flags it as an untested research direction, not a finding — say so — but it is the right architecture and it costs nothing to build correctly the first time.

**Evaluate the release valve properly, because the corpus over-claimed it.** The argument runs: *the default can be beautiful because there is a low-stimulus escape hatch.* Three problems:

1. The dedicated low-stimulus theme is **v1, not MVP**. So the MVP's default has to be defensible on its own. The valve arriving later licenses a louder *option*, not a louder *default*, retroactively.
2. 6/12 said automatic personalization should **never** activate — the highest "never" of any feature tested. One participant: *"if it's automatically adjusting itself in response to how I interact with it, I hate that."* The valve is manual or it is a bug.
3. It must be a **theme**, not a mode. Structurally that guarantees it can only touch colour and never geometry, because it inherits the theme system's contract. A "mode" is a thing someone eventually makes reflow tiles.

**What actually ships in the MVP is better than the corpus noticed.** The three themes are already one tap from the main screen, and the high-contrast theme *drops the category stocks entirely* — at HC, the fills fall to 1.08:1 against the ground and structure moves to full-strength keylines. So **the high-contrast theme is already the MVP's escape from colour.** It is doing double duty. The v1 low-stimulus theme is the version that drops chroma *without* maxing contrast, for the person who wants calm rather than legibility. That is a real gap, and it is a v1 gap.

### 1.2 The split the corpus missed: retention is not stigma

Eleven dimensions of research treat "beautiful" as one goal. It is two, with different evidence, different surfaces, and different stakes.

| | Who sees it | The argument | The evidence |
|---|---|---|---|
| **The grid, the type, the palette** | Only the user | **Retention.** People abandon assistive devices they find ugly. | Santos & Ferrari (2020); Oro, *Designing for Dignity*; 5/12 named infantilizing design. Real, modest. |
| **The icon, the launcher label, show mode** | Strangers | **Stigma.** 11/12 use AAC only where they feel safe; 4/12 avoid situations to dodge reactions. | The strongest numbers in the corpus. |

A stranger glancing at your phone sees **a phone**. They do not see the grid. The tile radius has never once been the reason someone didn't use AAC in a shop. So the Pullin bet — the dignity argument, the one that motivates the whole product — **cashes at exactly three surfaces: the icon, the label under it, and show mode.** Everything else is a retention argument dressed in a stigma argument's clothes.

That reframe is why show mode gets the entire expressive budget (§9) and why the name is worth more than every corner-radius decision in this repo (§2.3).

### 1.3 The strategy, stated plainly

**Beauty in the material. Simplicity in the structure.** Hold the geometry ruthlessly simple — uniform grid, fixed positions, no reflow, no motion — and let colour, type, edge and surface carry the identity.

Be honest about the standing: the simplicity half is cheap, has no downside, and is weakly supported. The material half is **unmeasured** and is a design judgment. We take it because it is the entire brief, and because the hedge is total: the material is a token layer. If user testing says we are wrong about chroma, the correction is fourteen hex values, not a redesign.

**The cost we are accepting, stated once so nobody relitigates it at 2am:** banning motion means the object-correspondence and input-registration feedback that motion normally carries has to be carried by colour, luminance, haptics and audio instead. That cost is real. We are not pretending it is zero — we are paying it in a luminance step, a keyline promotion, and a haptic pulse, all fired on `onPointerDown`.

---

## 2. The Pullin bet

Graham Pullin, *Design Meets Disability* (MIT Press, 2009). Chapter 1 is **Fashion meets discretion** — not "discretion vs discussion," which is how the corpus quoted it and which appears nowhere in his work. Getting this right matters, because the misread inverts his conclusion.

Pullin's argument is that design for disability defaulted to *"enable while attracting as little attention as possible"* — decades of pink plastic aids built to be camouflaged. Eyewear disproves the assumption that discretion must mean invisibility. But he does **not** conclude "be loud." He writes: *"Fashion can be understated, and discretion does not require invisibility."* His stated ideal is an object that is *"unmistakably, unashamedly and unremarkably a hearing aid."*

**Unremarkably.** Glasses did not win by shouting. They won by being ordinary, well-made, and available in versions that were *yours*.

The quantified modern case is AirPods. Traditional hearing-aid form factors (RIC, BTE) were identified as hearing aids by ~80% of respondents; the AirPod, 22%. AirPods are not discreet — they are large, white, and highly visible. They de-stigmatized by being a **desirable consumer object** rather than a medical appliance.

**The bet:** a device someone is not embarrassed to hold up gets held up. 11/12 only use AAC where they feel safe. Move that number and you have moved the product's only metric that matters.

### Where the bet does not hold

Three honest limits, and the third is the serious one.

1. **AirPods' mechanism was ubiquity, not design.** Everyone already had them. An AAC app cannot buy a network effect. The comparison flatters us.
2. **Not everyone wants discretion.** From the n=5 focus group: one participant wanted *more* visibility — *"maybe something that would be seen that would say hey you need some extra support and help."* Another: *"seen as not human because of how I communicate."* **The enemy is being misread, not being seen.** Discretion is a default, not a value.
3. **The phone already did the de-stigmatizing.** The object in the user's hand is a phone — already the most normalized consumer object on earth. The app is invisible inside it. So the marginal stigma value of app-interior beauty is plausibly near zero, and the honest scope of the Pullin bet is the icon, the label, and show mode. Which is §1.2, and which is why this document spends its budget there.

### What that licenses

Ship `android:label="Reed"` and the Play Store title `Reed: AAC & Text to Speech`. They are different fields with different jobs — the store title is read once by someone who typed "AAC" into search; the launcher label is read a thousand times, in public, by everyone who glances at the phone. Google Play indexes the full description, so you rank for "selective mutism" and "autistic shutdown" in honest prose without those words ever touching the home screen.

Better still, and missed by the corpus: `<activity-alias>` plus `PackageManager.setComponentEnabledSetting` lets the **user** pick their own launcher label and icon, on stock Pixel Launcher. That is strictly better than us picking a discreet default for them — it is Pullin's "versions that were yours," and it is the difference between designing *for* discretion and handing someone the control.

Note for whoever implements it: there is no `android:shortLabel` attribute in `AndroidManifest.xml`. Launchers ellipsize `android:label`. Keep it short on judgment.

`Reed` is not collision-checked or TM-checked. Do that before committing (§10).

---

## 3. The ledger: evidence, contested, folklore

The rule: **a design decision made on judgment and labeled as such is honest. One dressed in a fake citation is not.** Every row below was fact-checked adversarially; where the check killed the citation, the decision either found a better reason or died.

| Claim | Status | What we do |
|---|---|---|
| **"Muted/low-arousal for autistic users"** | **Contested.** 3/12 said "no bright colors" — and said *"especially when they are already feeling overwhelmed."* State-conditional, 25%. The doctrine traces to National Autistic Society *classroom* guidance, developed largely by non-autistic educators for autistic *children*. | Muted **default** on audience-selection grounds (§4). Not a law. Never cite it as one. |
| **Chen et al. 2025** (autistic colour preference) | **Weak, directional.** n=46, no control group, ages 6–40, non-standard "emotional resonance" measure. High-sensitivity prefer soft (M=4.5 vs 2.0); **low-sensitivity prefer bold (M=4.3 vs 2.5)**; r=0.72. | Cite for "sensory subtype predicts, autism does not." Do not design a magnitude around it. |
| **M3 Expressive "4x faster"** | **Marketing.** "Up to," one cherry-picked element (an email Send button that was enlarged, moved, and recoloured). | Never cite it. |
| **M3E, the peer-reviewed version** | **Real.** Bentley et al., CHI '26 (DOI 10.1145/3772318.3790373), n=48, 10 apps: **33% faster fixation, 20% faster task completion.** | Usable — but the comparator is non-Expressive M3, *not* an accessibility-optimized design, and expressiveness is confounded with size and contrast. It cannot show beauty and accessibility are non-antagonistic. It can show large high-contrast targets do not cost aesthetic appeal. That is all we take. |
| **M3E "erases age effects"** | **Vendor blog, no n, no effect size, no test.** Absent from the peer-reviewed abstract. | Do not design around it. |
| **Aesthetic-usability effect** | **Contested to the point of unusable.** Kurosu & Kashimura / Tractinsky were correlational. Grishin & Gillan (2019) manipulated aesthetics and usability separately and found *"only limited support, at best"* — *"usability and aesthetics were perceived separately."* | **Do not use this to justify beauty.** Use retention and dignity, where the evidence actually is. |
| **Lexend** | **Folklore.** Headline numbers trace to the author's own 2019 work; the underlying dissertation tested 25 second-graders. | Rejected. |
| **OpenDyslexic** | **Evidenced negative.** Wery & Diliberto: fluency −49.65% to −88.65%. But Broadbent (2023): 58% of preference-expressing students preferred it aesthetically. | Never a default. Ship it as an option, because preference is legitimate. |
| **Atkinson Hyperlegible** | **No independent peer-reviewed evidence.** Tested with students and clinicians at the Braille Institute using reading-speed and retention tests — unpublished, non-independent, no methodology or results. Award-winning, not evidence-based. | Ship it — on letterform differentiation (Il1, O0, rn/m, the exact failure mode for someone reading fast in shutdown) and low stroke contrast. **Never write "scientifically proven" in store copy or settings.** Honest phrasing: *"developed and tested with low-vision readers at the Braille Institute; no independent peer-reviewed validation has been published."* |
| **"Sans-serif is more legible"** | **Folklore.** Minakata & Beier (2022) built four fonts isolating serif and stroke contrast: **no main effect of serif** (Cr.I. [−1.29, 3.26]), replicated. Low stroke contrast has a small effect (~5%, 58 vs 61pt threshold). The low-vision follow-up (n=19 ADOA) found serifs + uniform stroke **best** — the opposite direction. | Serif is population-dependent, not second-order. Prefer low stroke contrast. Do not claim Atkinson wins on this axis; nothing in those papers tests it. |
| **Fixed tile positions** | **Contested justification, correct decision.** The LAMP evidence is emergent symbol communicators — children on 84-location devices — and the sourcing is vendor-side. Independent researchers say the motor-planning impact still needs study. The encoding literature *does* independently support memorized schemes imposing low ongoing demand. | Adopt because it is **free**, because reflow's downside is real, and because unpredictable positions remove user control. Drop "clinical consensus is explicit" from any external claim. |
| **76dp target floor** | **Unverified.** Its fact-check failed outright. WCAG 2.5.8 AA = 24×24 CSS px; 2.5.5 AAA = 44×44; Apple 44pt; Material 48dp. 76dp comes from Google's Design for Driving via a secondary source. | Our design decision, conservative and cheap. **Also non-binding** — at 3×4 on a phone tiles are ~120dp anyway. At 200% text scale the constraint inverts entirely (§10). |
| **"Rounded corners are processed faster"** | **Folklore.** No primary source. | The real citation is Bar & Neta (2006), *Humans Prefer Curved Visual Objects* — the finding is **preference and threat**: sharp contour transitions convey threat. For a trauma-informed product that is a *better* argument than a speed claim. Use it. |
| **Kaaresoja / "zero animation is optimal"** | **Refuted.** The thesis measures feedback **onset latency**, never tested a no-animation condition, and its guideline has a 30ms *lower* bound. Flutter's ink splash begins on tap-down; its 200ms figure is the fade-*out*. | Zero animation is an accessibility-and-latency **decision**, not an empirical optimum. Say so (§1.3). |
| **ISO 13850 / "red works because it's reserved"** | **Refuted.** The standard specifies *saturated* safety red on high-contrast yellow (ISO 3864-4 fixes the chromaticity corners). Reservation works because a legally-enforced installed base trained the prior over decades. An app cannot reserve a colour in a first-time user's head. | Dropped entirely. See §5.1. |
| **Pattern glare** | **Split.** The grid debunk holds and is worth keeping: at 35cm a 130dp 3-column grid is 0.30 cpd against a ~3 cpd peak — 10× clear. The type-floor half does not: it is a gradient, not a floor, and cannot select 17pt over 20pt. | Use it to retire a plausible worry. Do not use it to justify the type size. |
| **APCA** | **Not a standard.** Removed from the WCAG 3 draft in July 2023; as of April 2026 the draft says the contrast algorithm is *"yet to be determined."* WCAG 3 is a ~2030 artifact. | **WCAG 2.x AA is the compliance floor** (that is what stores and the EAA reference). APCA is the design instrument — because it accounts for font size and weight and for dark-end behaviour, **not** because of anything to do with muted colour. It is luminance-only and blind to saturation, same as WCAG 2. |
| **WCAG 2's real flaw** | **Verified, and it is not polarity.** Polarity symmetry costs a median 1.4 Lc. The severe flaw is that it **overrates dark pairs**: 43% of greys passing AA on `#000` fail APCA's Lc 60 content minimum, vs 0% on `#FFF`. `#AFAFAF` on `#000` scores 9.57:1 (AAA) at Lc −59. | Trust WCAG 2 in light mode. **Never validate a dark palette with it alone.** |
| **Tuch et al.** (complexity + prototypicality) | **Weak, out of scope.** See §1. | A plausibility argument for simplicity. Not a result about our users. |

---

## 4. Is "sensory-friendly = muted" a stereotype?

It deserves a full hearing, because the answer is *partly yes* and the design has to survive being wrong.

**What the corpus found.** The first-person adult data is 3 of 12, and the qualifier is state-conditional: *"no bright colors — especially when they are already feeling overwhelmed."* That is 25% of a self-selected n=12, describing a state, not a trait. Meanwhile the study's own conclusion about infantilization is that it was about **vocabulary and being treated as a student — not colour.** The participant wish, verbatim: *"Future AAC that has both symbols and typing and a **vocabulary** designed for autistic adults."*

**What the corpus assumed.** That "muted" follows from "autistic." It does not. Chen et al. (2025) found sensory *subtype* predicts colour preference, and the low-sensitivity group actively preferred bold (M=4.3) over soft (M=2.5). The broader sensory literature reports a substantial minority of autistic adults who *seek* bright colour or report no reactivity difference. The low-arousal doctrine's provenance is classroom design guidance written largely by non-autistic educators for autistic children in institutional settings, then generalized onto adults and onto software. Nobody re-derived it for this population. Nine of eleven research dimensions restated it as settled law anyway.

**The defensible version, and it is narrower than the corpus's.** This app's audience self-selects for sensory hypersensitivity — they are defined by shutting down from overload, which maps onto the high-sensitivity group. That makes a muted default a reasonable **audience-fit** bet.

**And here is the hole in our own argument, which the user-lens critique found and the research did not:** shutdown is not only sensory. Social overload, demand overload and emotional overload all produce it. Sensory-seeking autistic people go non-speaking too. So the selection argument is weaker than it reads — it covers a majority of the audience, not the audience.

**Verdict: muted is a defensible default and an indefensible law.** We ship it, and we say plainly that it is a judgment.

**How the design hedges against being wrong:**

- **The palette is a token layer.** Fourteen hex values in `tokens.dart`, the only file in the repo permitted a hex literal (enforced by a CI grep, not a promise). If testing says we are wrong, the correction is a swap, not a redesign.
- **The three themes are one tap from the main screen**, and the HC theme is already a full escape from chroma (§1.1).
- **The v1 low-stimulus theme** is the calm-without-max-contrast version — manual, surface-only, never automatic.
- **The cheapest possible correction, if we are wrong in the other direction:** a saturated theme is also fourteen hex values. The architecture does not care which way the error goes.
- **The tile stocks are staggered in lightness, not isoluminant** (§5.4) — which means they carry a real discriminating channel that survives being muted.

What we will not do is pretend. If a reviewer asks why the palette is muted, the answer is: *"this audience self-selects for hypersensitivity and we defaulted conservatively; three of twelve participants asked for it, conditionally; the user can change it in one tap."* Not: *"research shows autistic people need muted colour."*

---

## 5. Rejected directions

### 5.1 The emergency-red STOP

The control stays. **Its costume goes.**

The function is load-bearing and nothing replaces it: **you cannot unsay speech.** Stop is the only brake on irreversible social output, and Repair — *"Sorry, wrong button, that's not what I meant"* — is the primitive that follows it. No mainstream AAC app treats repair as a primitive; that is a genuine gap and it stays.

But the ISO 13850 argument is dead (§3), and the user-lens critique's response to what was left is unanswerable:

> *"a big red emergency button on my communication device. I am not a lathe. What does STOP even do? It cancels TTS mid-utterance. That's a cancel. Calling it STOP and coding it emergency-red designs for a bystander's fear of me, not for my use."*

So: `Stop`, sentence case. Full-width, at the bottom, larger than a tile, permanently present, in the surface-container tone with a keyline. It is findable because it is the only full-width element besides the type field and because it never moves — silhouette and position, the same mechanism the entire grid already relies on. **Red is not used anywhere in this app.** A thing that is always there is furniture; an alarm is something that appears.

Honest flag, from `RESEARCH.md` and unchanged: an always-visible Stop is **our design decision to validate in testing**, not an established AAC convention.

### 5.2 The rest

| Rejected | Why |
|---|---|
| **Liquid Glass / translucency / blur / backdrop filters** | Translucency makes text contrast **non-deterministic by construction** — you cannot certify a ratio against a background you do not control. That argument alone carries the ban for a contrast-critical audience and no engine release will fix it. Specular highlights are involuntary motion. Argue it from user needs, **not** from "Apple retreated" — Apple did not; iOS 26.1/26.2 shipped opt-in controls and Liquid Glass remains the default. That narrative would not survive scrutiny. |
| **Full M3 Expressive** | Not available. Nothing has shipped in Flutter 3.44 — no components, no motion physics, no 35-shape library, no emphasized type. **But do not write "abandoned"** — that is stale. After a May–July 2025 pause, work resumed in the decoupled `material_ui` package in `flutter/packages`; ~20 P2 proposals opened April 2026; an Expressive IconButton PR was in review July 2026. `material_ui` is 0.0.x, unlisted, "Coming soon." Treat as **indefinite, not dead.** Re-check quarterly. We take the corner-radius scale and the weight step; both are just numbers. |
| **M3E's 35-shape library** | The vocabulary is *heart, flower, bun, clover, sunny, puffy, cookie*. That is the banned childish register wearing a Google badge. Not because of the animation ban — the shapes are static geometry and the ban does not disqualify them — but because a tile that reads as a sticker is a mascot with extra steps. |
| **Motion** | On **latency** (the premise is instant speech; a 200ms splash is 200ms of nothing happening) and on **judgment** informed by trauma-informed guidance. **Not** on Kaaresoja, which measured something else (§3). WCAG 2.3.3 is AAA and scoped to non-essential motion; it does not mandate this. The cost is real and stated in §1.3. |
| **Dark-only** | Contested and wrong. While & Sarvghad (2024) found each polarity benefits comparable proportions and recommend shipping both; Legge et al. (1985): observers with cloudy ocular media read **10–15% better** in dark. Gilbert et al., CHI 2023 (n=459) found light read reliably **faster** — and that readers do **not prefer** it. Preference and performance diverge. Ship all three, default dark, and never "correct" a user toward light on speed grounds. |
| **The calm/spa aesthetic** | Rejected on judgment, and label it as such — the corpus's supporting citation (Khanchandani, Dezeen) is an *exclusion/ableism* critique of spatial design, not an infantilization critique of app UI, and cannot carry the claim. Our reason: dusty pastels, blob shapes, hairline weights and breathy "take a moment" copy treat the user as fragile. That is the caregiver posture in a different costume. A user in shutdown is not fragile; they are temporarily without speech. Calm and Endel are optimized for lingering. This app is optimized for **exit**. |
| **Neo-brutalism** | Stark maximum-contrast layouts are named as an anti-pattern for distressed users, and `#FFF`-on-`#000` plus small text is the pattern-glare worst case. |
| **Dynamic colour / Material You** | The palette is contrast-tested in CI across three themes. Wallpaper-derived colour is **untestable at build time** — computed on-device from an image we have never seen. Every guarantee the suite provides evaporates. `harmonize` does not save it; it perturbs exactly the tested pairings. Secondary: it would also make position/colour learning unstable, which is the thing the fixed grid exists to protect. Material You reads as current, and that is genuinely what the founder asked for — but currency has to come from the design, not from delegating the palette to a wallpaper. |
| **Symbols in the MVP** | Text-only, and text-only stays first-class. Proloquo — the category's most decorated app — ships **9,000+ text-only buttons vs 4,500+ symbolized**. For many literate adults the symbol set *is* the infantilizing element. When symbols ship: Mulberry (the only major set marketed on this exact thesis), runtime-tinted, license resolved first. |
| **Saturated / rainbow colour-coding** | Not because colour-coding is childish — the research explicitly did **not** find that, and the Fitzgerald Key mandates hue, not saturation. Because 12 hues is the children's-AAC signature and because colour is redundant here by design: position carries retrieval. 4 stocks maximum, low chroma, lightness-staggered. |
| **Isoluminant tiles** | The best-argued idea in the corpus, and it fails on arithmetic. At matched luminance and chroma 0.05, four muted hues collapse to **ΔE 1.14 under deuteranopia — and ΔE 3.64 for normal vision.** Mute the chroma *and* remove lightness variation and you have deleted both discriminating channels. Its goal — no salience winner — is right and is achieved by a ±0.07 L stagger, which additionally makes the grid read as woven rather than as an institutional board. Computation beats preference. |
| **The "ghost line"** (vocalization under the label at 13sp/60%) | Computed: **3.98:1 on the Rose stock — fails AA outright**, and APCA Lc −39 on the page ground where it *passes* WCAG. That is the dark-overrating trap in one element. It was also proposed with three escape hatches (a setting, hidden above 130% scale, suppressed when label == utterance). An element with three exits is an element nobody believes in. **The label is the utterance.** If a `says` field ever diverges from the label, the tile earns one 6dp hairline tick in the top-right. That is the whole affordance. |
| **Non-uniform row heights / bento** | Three independent kills, and the third is the one that matters. (1) It breaks at 200% text scale, catastrophically at the smallest cell. (2) The corpus's own M3E caveat: novel structure hurt usability. (3) **Non-uniform tile size encodes *our* value hierarchy into *their* vocabulary.** Day two they replace half the phrases and the beautiful ratio is now lying about what matters. Uniform is not the timid choice here; it is the honest one. Keep `row_span`/`col_span` in the schema — the type field is already a 3-column cell — but ship uniform and mean it. |
| **Grain / paper texture** | Four dimensions proposed it and all four killed it in their own risk note. Contrast is not the reason — at 2% alpha on `#171411` the worst case costs 0.60 of a 13.03:1 budget, a rounding error. **The reason is taste:** a flat, opaque, dyed field is better, and grain is what you reach for when you do not trust your colour. Cut it. This is a judgment call, stated as one. |
| **Mesh gradients** | `mesh` is a stale 0.x with a shader stack, on the critical render path of an app that must launch instantly and never fail. `mesh_gradient`'s headline feature is *animated* mesh gradients — you would be adopting an animation library in order not to animate. |
| **Figma / DTCG / Style Dictionary** | All three are machinery for a handoff between a designer and an engineer. There is one person. A JSON→codegen step for ~30 colours adds a build step and a `node_modules` to solve a problem that does not exist. The divergent-exploration loss is real and is recovered with a pencil: six thumbnails in thirty minutes beats Figma at divergence and loses to it at nothing that matters here. |
| **`google_fonts`** | Fetches over HTTP at runtime **by default**. It can be made offline, but that ships an HTTP client and a network code path into an app whose entire premise is that it has no network permission. Declare the font under pubspec `fonts:` and have zero network surface — greppably verifiable, which is the point. |
| **The provenance byline that changes to `Yours.`** | That is a gold star. It is the app noticing you did a thing and commenting approvingly. It is confetti with better kerning. Provenance stays — as a static page, first person, named author — because a starter set that arrives anonymous reads as *correct*, and deviating from it reads as *error*. But cut *"Most people replace half of them in the first week"*: telling someone what most people do so they know they are normal is reassurance nobody asked for. Keep *"a starting point, not a prescription"* — that is a statement about the thing, not about them. |
| **The attention button** (flashlight strobe) | A photosensitive-seizure risk, a "sudden visual alert" the distressed-user guidance names directly, and — the part the corpus missed — it is a *look at the disabled person* button. |
| **Auto-detected distress / adaptive anything** | 6/12: never. Do not ship it switched off. One participant objected to *the presence of the knob*. |
| **The TextScaler prompt** (*"Text is large. Switch to 6 tiles?"*) | The app noticing something about you and offering an accommodation. Even as a prompt. Grid size is already a setting the user owns; leave it there. See §10 — this one is not fully solved. |

---

## 6. The dated-design audit

What would make this look ten years old, and the mechanism that prevents each. These are checkable, which is the point — "looks modern" is not reviewable and this list is.

| The tell | Why it dates | The defense |
|---|---|---|
| **4–8dp radius on a ~120dp tile** | The single loudest 2014 signal. M2's default card radius is 4dp; scaled onto a large tile it reads as a table cell. | **20dp** (M3 `largeIncreased`), rendered with **`RoundedSuperellipseBorder`** (Flutter 3.32+, May 2025 — the only shape in the SDK with an Impeller GPU geometry implementation on iOS/Android). **Not `ContinuousRectangleBorder`**: it needs its radius multiplied by ~2.3529 to approximate iOS, degenerates into a "TIE fighter" at exactly the radii we want, and centers strokes regardless of `strokeAlign`. Note the text field's border is **`ShapedInputBorder`** (3.44) — `RoundedSuperellipseInputBorder` does not exist and will not compile. |
| **Drop shadows as elevation** | M1's signature. | Tonal surface containers. **But get the tell right:** shadows are not the tell — `surfaceTintColor` is the *deprecated* pattern (api.flutter.dev: *"not recommended for use"*), and current M3 uses tone-based containers **and** shadows. The 2014 tell is a grey **umbra on a pure-grey surface**. We ship zero shadows because tonal steps survive the HC theme and shadows just vanish there. |
| **Pure neutrals** (`#FFFFFF`/`#808080`/`#000000`) | Zero-hue greys are the enterprise fingerprint. M3's own dark surface `#141218` is OKLCH C=0.0124 at hue 300 — Google already tints its blacks. | Warm-tinted ladder, ground `#171411`, ink `#DCD9D3` (13.03:1, APCA −82.9). **The HC theme is the exception** and keeps its warmth for **1.9 Lc out of 108** (`#FFFCF7`/`#0B0906` = 19.43:1 vs 21.00:1 pure). 1.8% of perceptual contrast to stay recognizably the same app. If a user says it is insufficient, ship pure `#FFF`/`#000` and do not argue — HC is a medical accommodation, not a look. |
| **The M2 500-series hexes** (`#2196F3`, `#4CAF50`, `#F44336`) | A literal fingerprint. Like leaving Bootstrap's `#007BFF` in. | Hand-authored stocks. `ColorScheme.fromSeed` generates only the ~38 roles nobody looks at. |
| **Thin type** (weight 300, centered, large) | The Roboto Light / iOS 7 hangover. | Atkinson Hyperlegible **Next** Variable, wght axis 200–800, tile labels at **560**. `FontWeight` sets the `wght` axis automatically since Flutter 3.41 and accepts arbitrary integers 1–1000 — `FontWeight(560)` is legal. The **original** Atkinson ships only 400/700, so the brief's "weight 500–600" is literally unrenderable on it; Flutter would synthesize a fake weight. Next (Nov 2024 / announced Feb 2025) has 7 weights and a variable cut. **One axis only — `wght`.** There is no `ital` axis; italic is a separate file. |
| **Compressed type scale** (14/16/18/20, everything within 1.4×) | The corporate tell. | Tile label 20pt → show mode 40–120pt. Roughly 1:3 to 1:6. The scale jump *is* the aesthetic — posters are beautiful because of scale contrast, and we cannot use motion, so scale is the loudest instrument available. |
| **1px `#E0E0E0` dividers between cells** | Flat 1.0. Turns keys into a spreadsheet. | No dividers. The **gap** is the design. Differential gutters — 14dp column, 22dp row, never equal — because equal gutters read as a table and unequal ones read as a page and group the grid into rows. Two integers. |
| **Flutter's own defaults** | The reason Flutter apps look like Flutter apps. `TextStyle.letterSpacing` defaults to 0 (calibrated for ~14pt, visibly loose at 20pt); `Border.all()` defaults to 1.0 **logical** px = 3 physical px on a 3× phone — a rule, not a hairline. | Tracking scales with size: −1% at 20pt, −2% at show-mode display sizes, never below 17pt. Hairlines at `1 / MediaQuery.devicePixelRatioOf(context)`, and **decorative only** — the tile boundary is carried by surface tone, never by the hairline alone, and the HC theme promotes every hairline to 3dp where it becomes load-bearing. |
| **2014 gradients** (linear, 2-stop, top-to-bottom, lightness-ramped, banded) | Dated on sight. | No decorative gradients. If one ever exists it is a ≤4% lightness ramp with zero hue shift, and it is verified at its **worst** point, not its average. Also: prefer `LinearGradient` — flutter/flutter#179268 is an **open P2** where radial gradients render corrupted on Impeller's Vulkan→GLES fallback. That fallback is disproportionately what this audience's hardware takes. |
| **Uniform density** | Everything obedient to one 8dp grid, no rhythm. | Differential gutters; optical rather than mathematical centering (`TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false, leadingDistribution: TextLeadingDistribution.even)`). Without it a one-line and a two-line label sit at visibly different optical centers in identical tiles — across twelve tiles that reads as sloppy. Four lines of code, app-wide via `DefaultTextHeightBehavior`. |
| **Corporate Memphis** | Peaked 2019–21, now derided. | Banned regardless. |

One thing the corpus got backwards and it is worth recording: **the keyline around each tile is not a WCAG requirement.** SC 1.4.11 requires 3:1 only where visual information is *required to identify* the component, and a tile carrying its own 4.5:1 label is self-identifying — the same exemption a borderless text button gets. The corpus wanted the hairline because a hairline is beautiful, was embarrassed to say so, and went looking for a standard to hide behind. **That reflex is exactly what produces grey rectangle grids: aesthetic conviction laundered through compliance until it dies.** So, plainly: the keyline is there because a fine rule around a field of colour is how printers have made objects look *made* for five hundred years. It is contrast-tested anyway, at `max(fillStep, borderStep) ≥ 1.5` in light/dark and ≥ 3.0 in HC where it becomes structural.

---

## 7. Traversal order: the inversion nobody caught

The corpus proudly identifies one inverted optimization — show mode's polarity — and misses the structurally identical one under its nose.

"Highest-value tiles in the lower-center arc" plus Flutter's default row-major semantic traversal means **the most urgent phrase is the 8th-to-11th thing TalkBack reads.** Under Switch Access linear autoscan at 1s/step it is reached in 8–11 seconds. The thumb-reach optimization actively *pessimizes* the screen-reader and switch experience.

`Semantics(sortKey: OrdinalSortKey(n))` decouples traversal order from visual position. You get lower-center thumb placement **and** first-in-traversal. It is free.

Traversal order is a **design decision**, and right now it is being inherited from layout by accident. Make it explicit. <!-- VERIFY: OrdinalSortKey is a real API; confirm TalkBack honors it across a GridView on a real device before relying on it. -->

Two related facts that change what the focus ring is for: Switch Access **draws its own highlight**, user-configurable in colour and thickness, and in group selection *"the highlighter colors change each time you press a switch."* So our focus ring serves keyboard and TalkBack, not Switch Access — and group selection reaches any of 12 items in 4 presses regardless of position, which means for those users the lower-center arc is neither help nor harm and only `sortKey` matters. **Touch, switch and screen reader have three different visual needs.** Design for all three or admit which one you dropped.

---

## 8. The gate

Not a golden-file suite — 3 themes × 4 text scales × 2 modes is 24 PNGs, invalidated by any padding change, reviewed by a human eyeballing diffs at 11pm in week two. And a golden **cannot assert anything**: one that renders unreadable grey-on-grey passes forever once blessed.

The gate is a matrix over `themes × textScales × channels`, in CI:

1. **Contrast** — every pairing clears WCAG AA **and** APCA Lc 75 (body) / Lc 60 (non-body). Both, not either. This is what catches the class of bug where something passes WCAG on a dark ground and is unreadable.
2. **Grayscale** — render, strip chroma, assert every semantic distinction survives. Android ships a Grayscale colour-correction mode, and **every chroma-only signal in this design is identically zero in it.** ~10 lines. It independently kills isoluminant tiles, a chroma-only press flood, and any future chroma-only signal.
3. **Geometry** — no `RenderFlex` overflow at 200%; label fits; focus ring clears 3:1 against every surface it touches and 3:1 focused-vs-unfocused on changed pixels.
4. **Traversal** — assert `sortKey` order equals priority order, not layout order.

Channel 2 is the one nobody had, and it is the one that catches this corpus's characteristic bug.

The question that should gate every decision, because it is the one the research never asked:

> **Does this still work for someone who cannot see colour, is at 200% text, and is driving the app with one switch at one second per step?**

Answer it honestly and the isoluminant tiles, the chroma-only press feedback, the ghost line, the 76dp floor and the row-major traversal all fall out in the same motion.

Two implementation notes that are load-bearing and easy to get wrong:

- **`MediaQuery.highContrast` is iOS-only** — `dart:ui`'s `AccessibilityFeatures.highContrast` says plainly *"Only supported on iOS."* On Android it is always false. Gate the HC theme on it and it silently never fires for the entire target audience. The in-app one-tap switcher is **the only mechanism that works on Android** — load-bearing infrastructure, not a convenience.
- **`MaterialApp` animates theme changes over 200ms by default.** The one-tap switch will crossfade unless you pass `themeAnimationStyle: AnimationStyle.noAnimation` <!-- VERIFY: two research dimensions disagreed on this parameter's name; check api.flutter.dev/flutter/material/MaterialApp-class.html against 3.44 before writing it. --> and implement `ThemeExtension.lerp` as a hard cut (`t < 0.5 ? this : (other ?? this)` — legal, endpoint-correct, and testable). Do both, or your tiles snap while the text field fades, which is worse than either.

---

## 9. The one thing that makes it memorable

**Show mode is a poster, and the poster is optically justified line by line.**

Take the phrase. Break it into 2–4 lines. Scale **each line independently** so it touches both margins exactly. Ranged flush left *and* flush right — not by tracking, by size. Line one might be 96pt, line two 138pt, line three 71pt. Paper `#FFFCF7`, ink `#1A140D` (17.85:1, APCA 103.3), 24dp margins, screen at max brightness, weight 500 — **not 700**, because bold at 100pt closes the counters and counter size is a real legibility factor. Tracking −2%. One tap anywhere exits.

**Why this is the right answer and not merely a nice one:** while width binds — which it does for any phrase long enough to need two lines — per-line justification is **arithmetically ≥ uniform setting for every line.** A uniform setting is constrained by the *longest* line, so every other line is smaller than it could be. Justified gives each line its own maximum. So the most beautiful setting and the most legible setting are the same computation. A cashier reading at arm's length in daylight gets the largest letters physically available, and you get a Swiss poster. That coincidence is the entire reason to do it.

It moves not at all. It costs one layout pass. Nothing in AAC looks remotely like it — Emergency Chat proved the interaction a decade ago and shipped it in system font on white.

**And it gets a sentence.** This is the correction the whole corpus needed and none of the eleven dimensions made. Show mode's job is **not beauty — it is frame control.** It is the two seconds in which a stranger decides whether they are talking to a competent adult with a temporary problem or to a person something is wrong with. *"Seen as not human because of how I communicate"* is the harm; a 138pt phrase does not address it. Emergency Chat's actual innovation was the screen that **explains the situation to the stranger**, and the corpus reduced that to "validated the hand-the-phone flow, executed with zero design investment."

So: above the poster, one small standing line, user-editable and user-deletable, defaulting to something like *"I can't speak right now. I can hear you."* The phrase is what they said. The line is what stops it being misread. **The design investment show mode needs is not 96pt type. It is the sentence above it.**

**The flash: it flashes.** Every dimension flagged the dark→near-white jump and none decided. Deciding: the user deliberately pressed a button and is turning the phone away from their own face. That *is* the mitigation, and it is the one an autistic reviewer explicitly defended — *"the cashier's eyes win in that moment. That's correct and I'd defend it."* Do not fade it: a fade is motion, costs latency, and makes the flash *longer*. Ship a settings escape hatch for people who cannot tolerate it and let them pay the legibility cost knowingly. Be honest that the animation ban's evidence base does not reach this decision (§3) — this is judgment, with a real cost to a real person, defended by one of them.

**The honest risk, and it is the first thing to test.** Varying line size is typographic emphasis, and emphasis is semantic. *"I can't **TALK** right now"* with TALK at 138pt says something the user did not say. A stranger may read the biggest line as the stressed line. Unmeasured. Fallback if it bites: uniform setting at the longest line's size — still a poster, less of one.

**That is the screenshot.** Someone holds up a phone and it says *I can't talk right now* in type that fills the glass edge to edge, each line a different size, ranged both margins, black on warm white, with one quiet line above it explaining why. That image is the product's thesis with zero copy attached.

---

## 10. Open questions

Ordered by how much damage a wrong answer does.

**1. The voice, and it is not close.** 10/12 raised TTS quality; 7/12 said voices were hard to understand; 4/12 named missing nonbinary/middle-pitch voices — *"having the voice that matches every other person who uses AAC is very disempowering."* This document is about a 5/12 problem. **Fix the voice first.**

Two corrections that matter, because both critiques and most of the corpus get them wrong in opposite directions:

- The famous *"the voice sounded like a child so they used it twice"* anecdote **does not show app abandonment.** That participant *deliberately prefers* pitched-down child/teen TTS because of age dysphoria; after a friend called it "incongruous" they withdrew socially from that friend. The paper uses the case to argue **against imposing a voice on the user.** So the requirement is free, offline, user-selectable voices with pitch control and middle-pitch options — **not** an "adult-sounding default," which would override that participant's stated need.
- **Sorting the voice picker by measured f0 will not deliver an androgynous voice.** f0 does not set perceived gender; formants and resonance do. Ship the sliders. Do not oversell them. Stripping the OS's Male/Female labels is still right — it stops forcing a person choosing their own voice through someone else's binary — but the honest framing is "we removed a label," not "we solved gender-neutral speech."

**Test:** hand five people the voice list on a real device and ask them to find a voice they would be willing to be heard in. Not "do you like it." *"Would you say this in front of your coworkers?"*

**2. Does the 3×4 grid render at 200%?** Genuinely unresolved and the arithmetic is uncomfortable: 20pt × 2.0 × 1.15 line-height × 2 lines + padding ≈ **124dp per tile**. Four rows plus gutters plus the type field plus Stop/Repair plus safe area lands around 740–800dp. A modern 6.7" phone is ~930dp tall, so it fits; a smaller or older phone does not. And the resolution cannot be auto-promotion (breaks position, and the app noticing something about you is the thing 6/12 rejected), cannot be scrolling (breaks fixed position and the `onPointerDown` decision), cannot be truncation (a truncated AAC utterance is a *different* utterance), and cannot be auto-shrink (that is clamping wearing a disguise, and it makes the longest phrase the smallest).

**The decision:** no prompt, no auto-promotion, no clamp. Grid size is already a setting the user owns, 2×3 already exists, and `RESEARCH.md`'s rule stands — default to the largest grid the user can comfortably see and touch; resize is deliberate, warned and user-initiated. **The CI gate is a widget test at 200% on the smallest supported viewport asserting no overflow.** If it fails, that is a layout bug to fix, not a constraint to paper over. Residual risk: a user at 200% on an old phone gets a default that does not fit and has to find a setting to fix it. That is not good, and I do not have a better answer that does not violate something worse.

**3. Is the muted default right?** §4. **Test:** show the same grid in the muted palette and in a saturated one, to people in both sensory subtypes, and ask which they would keep — not which is prettier. The answer changes fourteen hex values either way, which is exactly why the token layer exists.

**4. Does the justified poster read as unintended emphasis?** §9. **Test:** show three strangers a justified poster and ask them to read it back, then ask what the person meant. If "TALK" comes back stressed, fall back to uniform.

**5. Does the launch barrier exist at all?** The entire time-to-first-word ranking rests on it and `user-needs` states plainly there is **no direct user testimony** — Reddit was unfetchable for every researcher. If the answer is "the phone was already unlocked and in my hand," several downstream decisions are worthless. **Ask twenty people before building any of it.**

**6. Can you test a shutdown state at all?** The central research-design problem of this product, and it is absent from all eleven dimensions. Proxies: a countdown plus a distraction task; recruiting people to use it in low-capacity states they *can* predict (post-social, post-commute, end of a bad day); post-crisis retrospective capture — which is also a feature. **No good answer exists. Say so rather than pretending.**

**7. `Reed`** is not collision-checked on Play or USPTO. `Ebb`, `Sotto` and `Understudy` were checked and are all dead (`works.ebb.v4` is a same-category communication app; Headspace has an Ebb). Do the check before committing. Note `Wren` invites a bird mark, which walks straight into the banned animal-character territory.

**What the fact-checkers could not verify, flagged inline above:** `themeAnimationStyle`'s exact parameter name on `MaterialApp` in 3.44; whether TalkBack honors `OrdinalSortKey` across a `GridView` on a real device; whether `RoundedSuperellipseBorder`'s GPU path exists on Impeller's OpenGL ES fallback backend (API 28 and below run legacy Skia, where its cost is undocumented and unmeasured); and Atkinson Hyperlegible Next's hinting at ≤17pt — the legibility work was done on the *original* font, so Next's low-vision performance is an inference, not a measured result. Test both at small sizes if in doubt.

**What the research could not answer at all:** whether beauty helps or harms autistic users specifically. There is abundant guidance on autistic sensory design and abundant general aesthetics research, and **nothing measuring aesthetic judgment or aesthetic benefit in autistic users.** Nobody has looked. That cuts our way — no one can tell the founder that beauty is contraindicated for this audience — but it means every claim in this document about beauty and this audience is a bet, and the burden of proof is genuinely unassigned rather than discharged.

---

## 11. The sibling

**Field Notes.**

Kraft stock, one ink, no ornament, no mascot, no encouragement. Adults buy it *because it is beautiful* and it has never once told anyone they are doing a good job. It reads as a tool, not a toy — the dignity wedge executed in material rather than in copy.

The corpus's other references — monome, Teenage Engineering, Braun, Vignelli — are all correct and all about hardware you cannot ship. Field Notes is the one whose entire method is *choose a paper and a single ink, print the type, and then have the confidence to add nothing.*

Twelve chips of dyed stock with one line of type each, and one poster.
