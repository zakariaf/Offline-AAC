# Offline AAC for Situational Speech Loss — Product Brief

**Status:** research complete, build/no-build **not yet decided**. Phase 0 (§11) decides it.
**Date:** 2026-07-15. **Stack:** Flutter (validated, §7). **Audience:** solo dev.
**Source corpus:** 10 research dimensions, adversarially fact-checked; 3 critiques (completeness, product lead, SLP clinical review). Where a fact-checker corrected a researcher, this brief uses the **corrected** version and says so.

---

# 1. What the research changed

`idea.md` closes with "**Confidence: High.**" That is the first thing the research refutes. Eight findings, ranked by how much they should move you.

### 1.1 "No one has built the adult-first, tasteful, offline version" is false. It shipped in 2016.

**[CONFIRMED by fact-check.]** [Speech Assistant AAC](https://apps.apple.com/us/app/speech-assistant-aac/id1139762358) (ASoft, Netherlands): $24.99 iOS one-time, **free basic tier on Android** with one-time unlock, no subscription, no account, App Store text states "The app does not require an internet connection," developer "does not collect any data." Explicitly targets "Aphasia, MND/ALS, **Autism**, Stroke, Cerebral Palsy" — adults named first. User-created categories and subcategories, phrase buttons, type-to-speak, adjustable button size and text scaling, multiple color schemes, per-situation profiles, 3,400 Mulberry symbols, **an Apple Watch app**, and **selectable side-of-screen placement for action buttons — i.e. one-handed use, one of your stated differentiators, already shipped**. ~810k Android downloads, 4.44/5; 4.6/5 iOS. Last Android update May 2026. It is listed in [Aphasia Software Finder](https://www.aphasiasoftwarefinder.org/speech-assistant-aac), [JAN](https://askjan.org/products/Speech-Assistant-AAC.cfm), the [Parkinson's UK Tech Guide](https://techguide.parkinsons.org.uk/catalogue/speech-assistant-aac), and Towson's SLP research guide.

That is your MVP, feature-for-feature, at 1/10th your assumed competitor price, on both platforms, for a decade.

**Nobody in the research corpus installed it.** The competitive dimension called doing so "the highest-value hour available." It cost $24.99 and it went unspent. Do not write a line of code before you do.

### 1.2 The pricing premise is wrong, and an explicitly adult AAC product has existed since 2014.

**[CONFIRMED.]** [Proloquo2Go is **$249.99**](https://apps.apple.com/us/app/proloquo2go-aac/id308368164), not ~$299. And [Proloquo4Text](https://www.assistiveware.com/products/proloquo4text) is **$119.99**, marketed verbatim as "the leading AAC solution for literate adults, teens and children… If you can write, you can use Proloquo4Text" — 150+ voices, Acapela Neural, prediction, **single-screen architecture with no mode switch**. AssistiveWare and PRC-Saltillo both run frequent 50%-off sales.

"Every mainstream AAC app is built for young children" is true of the **symbol-grid category** (Proloquo2Go, TouchChat, LAMP, Avaz) and **false of the category as a whole**. The adult text-AAC segment is established and competitive and has been for over a decade. Delete this line from every pitch — the community will fact-check you, and being caught overclaiming in r/AutisticAdults is unrecoverable.

### 1.3 On iOS, the type-to-speak half is already an OS feature you cannot out-access.

[iOS Live Speech](https://support.apple.com/en-us/105018) (iOS 17+, still shipping and improved in iOS 26): free, preinstalled, zero-install, zero-login. Type-to-speak in person and on Phone/FaceTime. **Saved phrases**, and **since iOS 18, user-created categories with icons**. Dozens of voices plus Personal Voice. Also on Apple Watch via Digital Crown triple-click.

It is invoked by **triple-clicking the side button** — the Accessibility Shortcut, which is reserved for built-in accessibility features. **Third-party apps have no registration API for it, in any framework.** That asymmetry cannot be engineered around.

**[CORRECTED, two ways.]** (a) The researcher's "flat text list buried in Control Center" is wrong — it's a side-button shortcut, and since iOS 18 the categories have icons, so the quick-recall overlap is *larger* than claimed and your tile-grid wedge is *narrower*. (b) "Works offline once voices are downloaded" is **plausible but unsourced** — Apple never documents Live Speech's offline runtime. **Verify by airplane-mode test before relying on it** (§11, 0.5).

What survives: no large-tile symbol grid, no per-phrase images, no distress-optimized one-handed layout, **and no existence on Android at all**. That is the whole defensible surface on iOS. **Do not put type-to-speak in your iOS pitch.**

### 1.4 "The phone speaks it aloud" may not be the core job.

`idea.md` §"The core job" assumes speech output. In [Martin & Nagalakshmi, "Aging Up AAC" (arXiv 2404.17730)](https://arxiv.org/html/2404.17730v3), **8 of 12 autistic adult AAC users display text instead of or alongside TTS; 3 of 12 prefer showing text for most or all communication**. 10/12 raised TTS concerns; 7/12 said voices were hard to understand or hear; 4–6/12 said devices cannot get loud enough to carry over background noise.

**[CORRECTED, and this matters.]** The drivers are **ambient noise and TTS intelligibility/volume — not privacy**. And **do not repeat "there is no stigma against writing"**: that is the authors' hedged speculation ("*Perhaps* it is because of the lack of stigma against writing (vs an application)…") about a *single* handwriting-using participant. It is not a finding.

**[CORRECTED against the failure-modes researcher.]** The inference that "TTS injects audio into an already-overloaded channel and worsens shutdown" is stated by **no source**, and the AAC literature leans the other way (AAC reducing the cognitive load of speaking; symbol AAC reported as usable *during* shutdown). The only audio complaint in the data is that devices are too **quiet**.

So: **do not drop TTS, do not suppress audio by default, do not claim TTS worsens shutdown.** Do ship **show-text as a co-equal MVP mode** — well-evidenced, cheap, and nobody in the cheap tier does it well. Note it fails too: small screens, sun glare, impossible with groups (2/12), and handing over a device raises real security concerns.

### 1.5 "Offline is essential" was never validated. Privacy was. And offline is not provable the way you think.

The corpus's own fact-check is blunt: Aging Up **"does not validate offline; it is about privacy/data collection, not connectivity."** 11/12 raised unauthorized data-collection concerns; **no source anywhere shows a user losing access for lack of signal**. An 11/12 *privacy* finding was laundered into an *offline* finding and made the product's central differentiator.

Offline is also **table stakes, not a wedge**: Speech Assistant is fully offline; [Spoken publicly documents](https://spokenaac.com/) that offline it "will show a warning, but still work – just with limited functionality," falling back to device TTS, and shipped "improved offline voices" in v1.9.2 (Aug 2025).

**[CORRECTED — the single most important architecture correction.]** "No INTERNET permission ⇒ nothing leaves device" is **false**. TTS synthesis runs in a **separate engine app** bound via `android.intent.action.TTS_SERVICE`, under **its own UID and its own INTERNET permission**. Your manifest cannot constrain it. The honest, defensible, still-excellent claim:

> *This app has no network code and no network permission. Speech is synthesized by your device's own system TTS engine, and we only select voices that declare they need no network connection.*

Also honest: **iCloud/Google backup includes your app data by default**, and under iOS Standard Data Protection [Apple holds the backup keys](https://support.apple.com/guide/security/security-of-icloud-backup-sec2c21e7f49/web). The absolutist claim is a trap you set for yourself in front of an audience that reads privacy labels adversarially.

### 1.6 Infantilization is the fifth-ranked complaint, not the first.

In the same n=12 study: **typing wanted 12/12 · customization 12/12 · speed 11/12 · trust/privacy 11/12 · TTS quality 10/12 · infantilizing design 5/12.** The paper never ranks themes, but the counts are unambiguous.

Your headline is real and it is the emotional core of the positioning. It is not the diagnosis. The top complaints are **speed of retrieval, typing, customization, privacy, and voice quality** — and Speech Assistant already addresses four of them.

Related: **"one-handed in distress"** is weaker than it reads. **[CORRECTED.]** Hoober's own 2014 follow-up argues reach charts are "flawed" because users simply re-grip, and recommends key controls go in the **middle** of the screen. Kim & Ji (Yonsei, IEA 2018) found **both** the upper-left **and** the lowermost region fall outside the natural thumb zone, and no study tested 6.7–6.8in devices. "A distressed user cannot re-grip" is a hypothesis, not a finding — and the incumbent already ships side-of-screen placement.

### 1.7 TTS voice is a gate, not a risk — and the fix is *not* an "adult-sounding default."

`idea.md` says "OS voices are fine." 10/12 disagree. It also lists this as a "real risk." It is a **top-two continued-use obstacle** and it is **largely outside your control on both platforms**.

- **iOS:** default voices are basic/Compact quality. Enhanced/premium are 100MB–400MB **manual** downloads. **[CORRECTED source]** — there is no API to enumerate downloadable-but-not-installed voices and no API to trigger a download, confirmed not by the thread the researcher cited but by [Apple Developer Forums 679401](https://developer.apple.com/forums/thread/679401), where an Apple Frameworks Engineer states: *"Only installed and usable voices will be returned by this API… Developers cannot initiate download requests on behalf of the user."* Still true under iOS 26, with new regressions reported (premium voices vanishing after reboot). There is **no deep link** to the voices Settings pane. Onboarding copy *is* the mitigation.
- **Incumbents solved it by licensing** — Proloquo4Text ships Acapela Neural; Speech Assistant integrates ElevenLabs; Spoken advertises next-gen TTS. Every one of those paths is closed by the offline constraint.
- **[CORRECTED, and it inverts the design implication.]** The famous "abandoned an app after two uses because the voice sounded like a child" anecdote **does not show app abandonment**. That participant *deliberately prefers* pitched-down child/teen TTS **because of age dysphoria*;* after a friend called it "incongruous" they used AAC *with that friend* twice — social withdrawal, not churn. **The paper uses this case to argue AGAINST imposing a voice on the user.** So the requirement is **free, offline, user-selectable voices with pitch control and nonbinary/middle-pitch options — NOT an adult-sounding default**, which would override this participant's stated need.

### 1.8 The entire evidence base is one small unrefereed preprint, and the field published a paper in 2025 saying you shouldn't do this alone.

**Aging Up AAC** (n=12, self-selected via Facebook/Twitter, all US, **unrefereed arXiv preprint**, no journal-ref, not CHI, not "Zhang et al.") is cited across **8 of 10 dimensions**. Five of them describe it as "independent corroboration." **It is the same twelve people.** The corpus manufactures the appearance of convergence from a single small sample. The second source ([Frisch, Peters & Vertanen, arXiv 2507.00202](https://arxiv.org/html/2507.00202v1)) is an **n=5 asynchronous text focus group**, also unrefereed, by a different team — **not a companion paper**. Combined N = 17.

Meanwhile, the field's flagship journal published: **[Blasko, Light, McNaughton, Williams & Zimmerman (2025), "Nothing about AAC users without AAC users: a call for meaningful inclusion in research, technology development, and professional training," *AAC* 41(3):184–194](https://doi.org/10.1080/07434618.2025.2514748)** — written collaboratively by AAC users and researchers out of the Future of AAC Research Summit, arguing that people who use AAC "must be leaders and co-creators in all activities that are about them or impact them," that they "have the best insights into their unmet needs," and naming **tokenism** as a specific risk of the shift.

And the corpus missed two things that reframe the project entirely:

- **[AsTeRICS Grid](https://github.com/asterics/AsTeRICS-Grid)** — AGPL-3.0, **free**, offline-capable, grid AAC with TTS, ARASAAC + OpenSymbols, word prediction, optional E2EE sync, ~10,570 commits, release **3 June 2026**, non-profit-maintained on Austrian public funding. It is a **PWA** — which directly contradicts the "a browser tab is the wrong container for a disability accommodation" line. The most mature free offline AAC in existence is a browser tab.
- **[Flutterkeys](https://github.com/earth-pheonix/Flutterkeys)** — an AAC app being built **in Flutter**, by **Pheonix, a nonspeaking AAC user**, explicitly "a hybrid of symbol and typing based AAC," free, open-source voices, ~4,000-word planned vocabulary — and **actively seeking a nonprofit partner for beta testing and release support**.

That is your product, in your framework, being built by a member of your target community, publicly asking for help. **Collaborating may be strictly better than competing.** Email them (§11, 0.7).

---

# 2. Who this is really for

## 2.1 The correct clinical name

**Part-time AAC use** / **unreliable speech** / **intermittent speech**. These are the established terms of art ([Zisk & Dalton 2019, *Autism in Adulthood*](https://pmc.ncbi.nlm.nih.gov/articles/PMC8992808/); [Donaldson et al. 2021, "Everyone Deserves AAC," ASHA Perspectives](https://pubs.asha.org/doi/10.1044/2021_PERSP-20-00220); [ASHA Perspectives 2023](https://pubs.asha.org/doi/abs/10.1044/2023_PERSP-22-00200); [AssistiveWare](https://www.assistiveware.com/learn-aac/support-communication-for-part-time-aac-users)). Zisk & Dalton's tripartite split is the spine:

- **intermittent** — "I can talk, but only sometimes"
- **unreliable** — "may say things that do not match their intended meaning"
- **insufficient** — speaks accurately, but not sufficiently

Using these words in the store listing, onboarding, and community posts will do more for credibility with both users and referring SLPs than any feature, and costs nothing. The literature's own framing to adopt: **"AAC is not the backup plan; it is the plan."**

## 2.2 Narrow to one segment for v1: autistic adults with shutdown

`idea.md` names four populations. **They are four different products sharing one insight about a *state*, not a coherent user segment.**

| Segment | Verdict | Why |
|---|---|---|
| **Autistic adults with shutdown** | **v1** | Clearest documented unmet need. Reachable community. Coherent profile: literate, intact language, intermittent *access* failure. Message banking works (they speak most days). |
| **Selective mutism** | **cut from v1** | **Anxiety**-driven, not capacity-driven. The clinical goal is often *not to draw attention* — a device that announces disability is the opposite accommodation. [ASHA](https://www.asha.org/practice-portal/clinical-topics/selective-mutism/) notes SM "manifests far more in young children than adolescents/adults," so the adult segment is small. **Honest caveat: the evidence cuts both ways** — ASHA also notes AAC "has been used in the hope that it will promote successful communication and thus reduce overall anxiety about speech," and the counter-caution ([CALL Scotland](https://www.callscotland.org.uk/blog/selective-mutism-and-technology/)) is a practitioner blog, not a study. Resolution: user-selectable output, never default to speaking, don't claim you know. |
| **Aphasia** | **cut — this is the biggest clinical error in `idea.md`** | Aphasia **inverts every assumption**. Anomia and alexia commonly co-occur, so a type-to-speak box may be the **least** accessible modality for that group. Their evidence base is **personalized photo Visual Scene Displays**, and the eye-tracking result is direct: adults with aphasia identified VSD themes **more rapidly and with fewer visual fixations than grid displays** ([AJSLP 2022](https://pubmed.ncbi.nlm.nih.gov/35858268/); [Light et al. 2019](https://pmc.ncbi.nlm.nih.gov/articles/PMC6436972/)). Claiming aphasia attracts users you cannot serve and invites clinical criticism you cannot answer. |
| **Post-seizure** | **cut from v1** | Postictal confusion means **no navigation is possible at all**. That user needs literally one button, or a lock-screen card — not a grid. |

## 2.3 What the original framing missed about part-time users

- **Part-time use is the DOMINANT pattern, not a doomed one.** **[CORRECTED against the failure-modes researcher's "crisis-only positioning is close to fatal."]** Only **2 of 12** participants were full-time AAC users. **Ten were persisting part-time users.** And they converged on your design unprompted: **10 of 12 pre-program whole phrases**, one explaining *"I can pre-program phrases before I enter a situation."* The paper frames pre-programmed phrases as the **remedy** for intermittent use, not its casualty.
- **The abandonment statistics being cited are the wrong ones.** **[CORRECTED.]** The ~30% figure is Phillips & Zhao on assistive technology *generally* (mobility aids worst). The ~39%-at-one-year figure is a survey of **SLPs about clinician-prescribed devices** — a model whose abandonment drivers (team failure, training gaps, funding, no user buy-in) are exactly what a free, self-selected, no-account app avoids. **Those base rates do not transfer.**
- **The real barrier is social fear and masking, not motor retrieval.** *"I have a communication book that I carry with me, but I've not been brave enough to use it"* (P5, Frisch et al., n=5). **11 of 12** use AAC only in environments they perceive as safe. *"It is not safe for me to communicate in a 'more disabled' looking manner to people who have the power to do things that could cost me too dramatically much."* 4/12 avoid social situations entirely to dodge reactions to their device.
- **They arrive carrying permission problems, not feature problems.** *"My speech was exhausting, and didn't feel natural. I did it because it was the only thing people would respond to."* *"Everyone else pushed for speech."* *"Just because I can say some of the things and even sound fluent, that doesn't mean I can tell you what I need."* Copy that legitimizes part-time use costs only words.
- **Voice is identity, and this market skews trans/nonbinary.** 4/12 — "many transgender or nonbinary" — criticized missing nonbinary/middle-pitch voices. *"Having the voice that matches every other person who uses AAC is very disempowering."* This is not fringe here.
- **Phones, not tablets.** *"I don't take my iPad with me most of the time. It was expensive, and I don't want to break it."* Situational loss is unplanned; only the phone is present.
- **Cost-constrained — but not as poor as the corpus claimed.** 10/12 discussed affordability; 5 avoided full-price apps; 4 gravitate to free. **[CORRECTED]**: the "75–85% unemployed / 14–16% full-time" figures describe autistic adults using **state DD services** (~111,000 of ~5.4M US autistic adults) — nearly the *opposite* subgroup from a literate, late-diagnosed, part-time-AAC user. Peer-reviewed estimates for autistic adults generally run ~40%.

## 2.4 The "explain to bystanders" job — supported, but not in the shape the corpus proposed

**[CORRECTED. The corpus's own fact-check calls the recommended feature "arguably counter-indicated."]**

The researcher proposed a *"full-screen, high-contrast, authoritative-looking 'I am autistic and cannot speak right now'"* statement aimed at bystanders including authority figures. Read the source finding again: a static, authoritative disclosure card handed to a police officer **performs exactly the disclosure P1 fears**, in a more permanent and legible form.

**What the evidence actually supports:**

1. **Large-text display mode** — 8/12 already display text instead of/alongside TTS. Well-evidenced, cheap, MVP.
2. **Concealability / deniability** — the ability to communicate *without visibly disclosing*, e.g. looking like you're just texting.
3. **Opt-in ambient status signal for TRUSTED settings only** — participants asked for a color-coded mental-state indicator for housemates, "something that would be seen that would say hey you need some extra support." Trusted, not authorities.
4. **A printable/wallet card as a separate, user-controlled artifact.** The real incumbent is **pen and paper**: *"I always have and always will carry pen and paper just because it's the most reliable."* Printed alert cards are institutionally endorsed — the [Pennsylvania State Police card program](https://www.pa.gov/agencies/psp/newsroom/after-meeting-with-advocates--pennsylvania-state-police-unveils-) (unveiled June 2024) directs officers verbatim to "be patient, use a calm and direct voice, and keep their questions and commands simple." **[CORRECTED]**: that card is *free*, so it evidences institutional recognition, not willingness to pay — and cards are a **complement** to AAC (passive disclosure), not a substitute (generative two-way speech).
5. **The Emergency Chat tell.** [Emergency Chat](https://lifeonautism.wordpress.com/2016/10/06/aac-app-review-emergency-chat/) — free, iOS+Android, built ~2015 by Jeroen De Busser, an autistic adult, opening straight to a customizable hand-to-a-stranger explanation screen — has owned this niche for a decade. Its reviewer's verdict: *"really the most useful part is the text explaining your condition."* **The static explanation carried more value than the interactive system.**

**Ship the show-text mode. Let the user author what it says. Ship a printable card. Do not architect a disclosure surface aimed at police and call it a safety feature.**

## 2.5 Your positionality is a required field

`idea.md` never says whether you are autistic or an AAC user. In this community that materially changes reception, and per Blasko et al. (2025) it is the field's stated position. Either say it plainly in the listing, or recruit and **pay** an advisory group, or partner with Flutterkeys. Silence reads as the thing the paper is about.

---

# 3. Feature set

## 3.1 MUST-HAVE — the MVP (target: 2 weeks, Android only)

Several rows are decisions *not* to build. Complexity: XS = <1h, S = <1d, M = 2–4d.

| # | Feature | Why (research) | Cx |
|---|---|---|---|
| 1 | **One screen: fixed tile grid + type-to-speak field, same surface, no mode switch, no navigation, no categories above it** | 12/12 wanted typing; 7/12 wanted symbols+typing **mixed in one app**; the named gap is *"symbols and typing being so completely separate in different apps"* and the named wish is *"Future AAC that has both symbols and typing and a vocabulary designed for autistic adults."* 6/12 struggle **locating** words on boards → flat, zero-dive. Steal [Proloquo4Text](https://www.assistiveware.com/products/proloquo4text)'s single-screen architecture. | M |
| 2 | **Tile positions immutable. No frequency sort, no recents-float-to-top, no adaptive layout, ever** | Position-based retrieval is the one channel that survives decision collapse (*"I can't decide which thoughts to prioritize, and I freeze"*). **[CORRECTED justification]**: the clinical evidence base is emergent symbol communicators (children, 84-location grids) — it does not transfer cleanly to literate adults on 12-tile phrase grids, and independent researchers say the motor-planning impact still needs study. Adopt it because it is **free** and reflow's downside is real — not because consensus mandates it. Note Proloquo4Text *does* use frequency-based sentence prediction, so frequency data isn't off-limits for this population; **unpredictable positions are.** | **Free** |
| 3 | **Show-text mode: one tap from any tile → full-screen, brightness override, huge high-contrast type, one message, navigation pinned** | 8/12 display text instead of/alongside TTS; drivers are noise + intelligibility + volume (4–6/12 say devices can't get loud enough). Cheap, well-evidenced, and the cheap tier does it badly. | S |
| 4 | **Output mode is a user choice (speak / show / both), remembered. Never auto-speak.** | 8/12 display. One participant on automatic word-by-word output: *"It messes me up a lot and distracts me."* **[CORRECTED]**: do NOT suppress audio by default on sensory-harm grounds — no source supports that mechanism. Make both first-class. | S |
| 5 | **Voice picker + pitch/rate/volume, prominent — not buried in a settings tree** | 10/12 TTS quality; 7/12 hard to understand; 4/12 nonbinary/middle-pitch missing; *"having the voice that matches every other person who uses AAC is very disempowering."* **[CORRECTED]**: do NOT ship an "adult-sounding default" — that overrides the age-dysphoric participant. **[CORRECTED]**: pitch alone probably cannot synthesize a genuine androgynous voice (f0 doesn't set perceived gender; formants/resonance do). Ship the sliders; don't oversell them. | S |
| 6 | **Android voice filter + `setVoice` return check + `<queries>` TTS_SERVICE** | Users land on network voices by accident (open issue #429, `en-us-x-sfg-network`). **[CORRECTED]**: `isNetworkConnectionRequired` is an unenforced engine-declared *hint* — "prefer with defensive checks," not "reliably force." **flutter_tts `setVoice` returns 0 with only a `Log.d` on failure** — unchecked, an AAC user mid-shutdown silently gets a network voice or **no speech at all**. | S |
| 7 | **iOS-only-when-you-get-there but decide now: `AVAudioSession .playback` + `.duckOthers` + `setSharedInstance(true)`. Never `.ambient`.** | `.ambient` respects the silent switch → user taps a tile and produces **nothing**. The worst possible failure for this product. One line, disproportionate stakes. | XS |
| 8 | **Always-visible STOP. Non-modal. Zero confirmation dialogs, anywhere.** | You cannot unsay speech. A dialog **doubles the decision count** at the moment decision-making has failed. **[CORRECTED]**: Proloquo2Go's Hold Duration/dwell is an **opt-in tremor accommodation, not a default**, and a 5s hold contradicts "speak instantly" — **ship dwell OFF**. An always-visible Stop is *your* design decision to validate in testing, not an established AAC convention. Say so. | S |
| 9 | **Permanent repair tile: "Sorry — wrong button, that's not what I meant." Adjacent to STOP. Undeletable.** | Undo in an AAC app is a **social repair, not a stack pop**. No mainstream AAC app treats repair as a primitive. This is the honest answer to "is undo essential?" — yes, and it's a speech act. | XS |
| 10 | **Zero-config launch: opens straight to a working grid with an opinionated adult default set. Skippable in one tap. Never a wizard.** | 4/12 spent considerable time on setup; 3 then couldn't remember their own layout; one cited *"big overhead for starting AAC."* **The install may BE the crisis.** Starter sets must carry **visible provenance** — who wrote them and why — which converts presumption into a gift. | S |
| 11 | **Editor v1 = an explicit Edit toggle; tap a tile to change its text. That is the whole editor.** | "One screen, one job" does not survive contact with an editor — **the editor is the product and the cost center.** Speech Assistant walked exactly this path to categories + subcategories + 3,400 symbols. Hold the line. | S |
| 12 | **Hide, don't delete. Deleting writes NULL to a grid slot; it never reflows.** | Masking-in-place is the established technique for reducing visual load while preserving position. Enforce it in the **schema** (§6), not in code discipline. | Free |
| 13 | **Large targets, bottom-**center** priority, direct touch only. No drag, no long-press, no multi-touch, no swipe on the speak path.** | Motor shutdown and dyspraxia co-occur with speech shutdown; 3/12 needed indirect selection (seizures, hemiparesis). Every gesture needs a visible button fallback; an accidental swipe silently repoints muscle memory. **In-distress motor precision is genuinely unmeasured** — design conservatively. | S |
| 14 | **Correct Flutter `Semantics` on every tile and control** | Inherits iOS Switch Control / Android Switch Access + VoiceOver/TalkBack **for free**. A custom-painted grid with raw `GestureDetector`s silently locks out every switch and screen-reader user. Cheapest possible a11y win. **Definition-of-done, not backlog.** | XS |
| 15 | **Dark + Light + High-Contrast themes, switchable in ONE TAP from the main screen** | **[CORRECTED — dark mode is genuinely contested.]** [While & Sarvghad (arXiv:2409.10841, 2024)](https://arxiv.org/pdf/2409.10841) found each polarity benefits comparable proportions and **recommends shipping both**. Legge et al. (1985): observers with cloudy ocular media read **10–15% better** in negative polarity — dark actively *helps* part of this population. Piepenbrock et al. (2013) found **no reading-speed difference** (p=0.69); the widely-repeated "26% drop" appears **fabricated**. Someone whose astigmatism makes the default unreadable must not have to *read their way through a settings tree* to fix it. | S |
| 16 | **No network code, no INTERNET permission, no analytics, no crash-reporting SDK** | 11/12 raised unauthorized data collection. **[CORRECTED claim wording]** — see §1.5. Verifiable pre-install; true. | Free |
| 17 | **User-initiated file export/import via the share sheet. `android:allowBackup="false"` (or empty `<cloud-backup>` + permissive `<device-transfer>`).** | **This is a clinical gate, not a nicety.** Offline + no account = **no backup** → six months of curated phrases die on a phone upgrade → **loss of the accommodation**. iOS app-private data is unrecoverable without a backup the user may not have. | S |
| 18 | **Honor `TextScaler`. Never hardcode or clamp `textScaleFactor`. Intrinsic tile heights; text wraps.** | Flutter does the right thing until you break it — [#22480](https://github.com/flutter/flutter/issues/22480)'s history shows the common instinct is to *disable* it for layout stability. Auto-shrinking text to fit a fixed tile is the same bug wearing a disguise. Test at 200%+ and with Larger Accessibility Sizes. | S |

**That's 18 rows, ~8 of which are XS or free.** The engineering surface is genuinely two weeks.

## 3.2 SHOULD-HAVE — v1 (order set by MVP feedback, not by this list)

| Feature | Why | Cx |
|---|---|---|
| **Message banking — record your own voice per tile; precedence: recording > TTS** | The population **can speak most days** — unlike the congenitally non-speaking children's market, they can bank real speech in a capacity window and replay it in shutdown. Retires the TTS-quality gate for the highest-value phrases. Established clinical practice since 1994 ([Boston Children's Message Banking Process](https://www.childrenshospital.org/centers-and-services/programs/f-_-n/inpatient-augmentative-communication-program/preoperative-message-banking); [RCSLT](https://www.rcslt.org/speech-and-language-therapy/clinical-information/voice-banking/); [Tobii Dynavox](https://us.tobiidynavox.com/pages/voice-banking-message-banking-voice-preservation)). **[CORRECTED — it is NOT a moat]**: already shipped in Proloquo2Go, CoughDrop, TouchChat. Table stakes. **Caveats**: some find their own recorded voice uncanny or dysphoric post-shutdown → option, never default, never the only path. It **cannot replace TTS** — 12/12 need typing for novel utterances. ~12–18KB per 3s phrase (mono AAC 32–48kbps) → 200 phrases ≈ 3MB. | M |
| **Exactly ONE level of categories. No nesting. Ever.** | Necessary, and the last thing you can safely add before becoming a board editor. | M |
| **Post-crisis phrase capture — pull-only, passive, always-present** | *"Add what you needed to say and couldn't."* **The highest-leverage answer to the customization paradox**: it lets the crisis-state self teach the calm-state self instead of requiring prediction. Nobody ships it. **Never a notification** — post-shutdown is a recovery/vulnerability window; a push asking "how was your shutdown?" is clinically harmful and reputationally fatal. | S |
| **Printable / wallet-card PDF export** | Pen and paper is the real incumbent: zero battery, zero unlock, no app to remember, never fails to boot. Doubles as backup. | S |
| **Manual low-stimulus mode** (desaturate, fewer tiles, zero animation) | 3/12 wanted bright colors removed **when overwhelmed** — the need is **state-dependent**, not a fixed preference. The literature proposed **AI-detecting** shutdown; **6/12 said auto-personalization should NEVER activate**. **Ship the feature, reject the automation.** | S |
| **Android Quick Settings tile — GATED on validating the launch barrier (§11, 0.2)** | `TileService.onClick()` runs **with the app not running**, is reachable from the **lock-screen shade**, and `unlockAndRun()` is only required for **sensitive** actions — speaking a stored phrase is not sensitive. The single best time-to-first-word affordance found on either platform. Caveats: `showDialog()` won't render under the lock screen (keep it UI-free); OEM skins and the user's "lock screen > quick settings" setting can restrict shade access. | M |
| **Symbols (Mulberry, runtime-tinted) — license question resolved first** | Symbols are a **hedge**, not evidence (see §12.3). **Text-only stays first-class** — for many literate adults the symbol set *is* the infantilizing element. | M |
| **Photo tiles** (≤512px JPEG q80, files on disk, paths in DB) | Cheap; double duty. Partially bridges to aphasia (crude VSD) and serves adults who want meaningful adult imagery over any drawn set. | S |
| **`.obz` export (Open Board Format)** | Anti-lock-in signal to a community with good reason to distrust AAC vendors. **Do NOT promise Proloquo import** — P2G and TouchChat don't support OBF and no community converter reads P2G. | M |
| **Editor for low executive function**: move up/down buttons (no drag); **dictation as an authoring path** | "Calm state" ≠ "high EF." The same user has fatigue, motor limits and low EF on a good day. Drag-to-reorder is an a11y failure for screen readers and one-handed motor-impaired use. Dictation exploits the key fact: **they can speak most of the time**. | M |
| **On-device-only, user-exportable crash log** | "Nothing leaves device" also means **you never learn the app is broken**, while 6/12 emphasized dependable performance and one abandoned an app because *"I reported several bugs and never got any fixed."* An unnoticed crash in a tool someone relies on in an ER is a hazard. | S |
| **Guided Access / screen-pinning prompt on handover** | **[CORRECTED]**: handing over an unlocked phone exposes the device — but that's an **OS-level problem the app can only prompt about, not solve.** 2/12 raised it. Do not promise leak-prevention you cannot architecturally deliver. | S |
| **Grip mirror as a fast, in-context, one-gesture flip — NOT a settings toggle** | **[CORRECTED]**: grip side is **situational and changes every few seconds**; only ~67% of one-handed grips are right-hand despite ~90% right-handedness. A settings-buried "handedness" toggle encodes a stable trait to predict a volatile state, and a user mid-shutdown will not open settings. **Bottom-center priority is the free part that helps everyone.** | S |

## 3.3 EXPLICITLY NOT DOING

| Not doing | Reason |
|---|---|
| **Aphasia positioning** | Anomia/alexia invert the typing assumption; VSDs beat grids on identification speed and fixation count. Attracts users you cannot serve; invites clinical criticism you cannot answer. |
| **LLM sentence expansion** (`"hurt loud leave"` → a sentence) | (1) It puts words in a disabled person's mouth — the AAC community's oldest and deepest objection; misrepresentation is a worse dignity harm than slowness. (2) Nondeterminism in a crisis tool is terrifying — the user must know exactly what will be said *before* it is said. (3) A plausible-but-wrong sentence in an ER is dangerous. (4) **It is a regulatory decision, not a feature decision**: [21 CFR 890.9](https://www.law.cornell.edu/cfr/text/21/890.9) voids the US 510(k) exemption for a device that "operates using a different fundamental scientific technology," and MDCG Rev.1 introduces "MDAI" as a new category of attention. The research supports pre-stored **conversation scripting**, not generation. |
| **Content filtering on what the user can say** | Filtering a disabled person's own speech is precisely the paternalism the product exists to oppose. The misuse risk is identical to any keyboard, or to Live Speech itself. |
| **Adaptive tile ordering / frequency sort / recents-float-to-top** | §3.1 row 2. **If** you ever want frequency benefits, surface them in a **separate, fixed-position zone** (a Recents strip whose *location* is constant even as contents change) — never mutate the user-arranged grid. |
| **AAC modeling / aided language stimulation / partner coaching / tutorials** | ALgS is real and evidence-based — [but the moderator analysis is decisive](https://link.springer.com/article/10.1007/s40474-023-00275-7): most effective "for younger children, for individuals with more advanced receptive skills." It is an intervention for people **acquiring** a language system. A literate autistic adult with full language has nothing to learn from modeling, and a partner modeling on their device mid-shutdown is an intrusion. **Know the term — SLPs will ask. Do not build it.** |
| **A core-vocabulary grid** | **[CORRECTED — do NOT call this a "category error."]** Core vocabulary is empirically real for adults: **203 words = 80.62% of adult conversational speech** ([Shin, Park & Hill 2021, JSLHR](https://pubmed.ncbi.nlm.nih.gov/34705517/), 330k spoken words, BNC), and it is documented in use with **literate acquired-loss adults**. Zisk & Dalton never discuss it and cannot be cited against it — and their "a rapid typist may prefer a text-based system" line actually **deprioritizes stored phrases**, arguing against your grid. The **honest reason**: word-by-word construction is dramatically slower than a stored phrase for someone in shutdown. The right decision is *"adult-appropriate vocabulary at both phrase AND word granularity, user-configurable,"* not *"phrases only."* An SLP will spot the category-error argument as pediatric folklore repurposed. |
| **Word prediction in the MVP** | **[CORRECTED — "explicitly avoid" is overstated and did not survive its own fact-check.]** **4 of 12 participants wanted auto-complete/word suggestion**, and the paper's actual recommendation (§6.3) is **opt-in-by-default control, not prohibition**. Also **[CORRECTED]**: the "swap motor plans back and forth" quote is a **misread** — it's one participant explaining why they prefer a keyboard *embedded in the AAC app* over the OS keyboard; the paper never discusses tile reordering. Defer for **cognitive-load** reasons (benefit is conditional on accuracy; load provably increases), not for ideology. |
| **Cartoon avatars, mascots, animal characters, puzzle pieces, gamification, streaks, badges, progress meters, rewards, confetti, encouragement copy** | The concrete, checkable definition of the infantilization that is your wedge. [Peer-reviewed](https://pmc.ncbi.nlm.nih.gov/articles/PMC9645676/) on persistent infantilization in autism representation; community sources are explicit that puzzle-piece/toy-box imagery is "patronizing, infantilizing, and deeply alienating" and "fails to grow with autistic people, freezing them in time." Calm Technology's "question every addition" bites hardest here. |
| **A "parent/caregiver" account concept** | The **structural** version of the same insult: it encodes that the adult user is not the account holder of their own voice. If you ever build caregiver handoff, phrases must arrive as **proposals to accept or reject** — a caregiver-authored bank is exactly how someone else's idea of you gets back into an app built to prevent that. |
| **Subscription** | See §10. Not because state funding refuses it (that rests on **one anonymous App Store review**) but because recurring billing implies entitlement checks, which conflict with "zero login, works in an ER with no signal." |
| **Fitzgerald Key part-of-speech coloring** | The Key is a **grammar-construction scaffold** (Fitzgerald 1949; color layer McDonald & Schultz 1973). Color-coding parts of speech is meaningless when each tile is a **whole utterance**. That alone is sufficient. **[CORRECTED — do NOT conclude color-coding categories is infantilizing.]** That inference is unsupported; adult evidence on background color and target-location speed exists (Thistle & Wilkinson, ASHA 2019); the palette isn't even "primary colors" (orange/green/pink aren't primaries); and the Key mandates **hue**, not saturation. Decide palette on autistic sensory-design grounds as a **separate** question. |
| **Dyslexia fonts as a default** | [Wery & Diliberto 2017](https://pmc.ncbi.nlm.nih.gov/articles/PMC5629233/) (n=12 children): OpenDyslexic **decreased** fluency (−49.65% to −88.65%) and accuracy. [Kuster et al. 2020](https://www.nessy.com/en-us/dyslexia-explained/understanding-dyslexia/dyslexia-fonts-do-they-work) systematic review: null. **[CORRECTED — but don't exclude it either]**: Broadbent (2023) found 58% of preference-expressing students preferred it on aesthetics; Franzen/Stark/Johnson (2019, adult eye-tracking, conference abstract) reported improved comprehension in adults. **Make it a user-selectable option.** Also **[CORRECTED]**: the "increase spacing instead" alternative isn't cleanly evidenced — Galliussi et al. found inter-letter spacing *without* matched inter-word spacing **reduces** reading speed. |
| **iOS Lock Screen interactive widgets as a primary path** | **[CORRECTED — they ARE interactive since iOS 17]** (`accessoryCircular`/`accessoryRectangular` on iPhone/iPad; **not** `accessoryInline`). But Apple: *"On a locked device, buttons and toggles are inactive and the system doesn't perform actions unless a person authenticates and unlocks their device."* A Face-ID-authenticated user still on the Lock Screen **can** tap — but **Face ID is unreliable in exactly the distress states this app targets** (averted gaze, covered face, lying down). Prototype-worthy as a secondary path; never primary. Note this is different from **Controls**, which are not gated (see §4.3). |
| **Flutter web PWA** | Flutter web ships a11y **OFF by default** — the semantics tree isn't built until an invisible `aria-label="Enable accessibility"` button is hit or `SemanticsBinding.instance.ensureSemantics()` is called — and paints to canvas with a synthesized semantic layer, plus a heavy initial payload. Inverts the "instant, zero-load" promise. **Be honest: the general claim was never tested.** AsTeRICS Grid proves a PWA is the most mature free offline AAC in existence. Only *Flutter's* version was refuted. If a web channel ever matters, hand-write plain HTML/JS. |
| **Background / lock-screen speaking** | Blocked for Personal Voice regardless; the core use case (tap a tile while looking at the phone) doesn't need it; adds an audio-session edge-case surface for zero user value. |
| **Cloud sync, board sharing, import-from-URL** | **One feature away from importing the whole UGC regime.** Apple 1.2's duties (filter content posted to the app, reporting mechanism, block abusive users, published contact info) all presuppose content reaching another user. Local-only free text presupposes none of it. Adding sharing costs moderation + reporting + blocking + published contact info + data disclosures. |
| **EU launch at v1** | §9. MDCG 2019-11 Rev.1 names your app almost verbatim as Class I MDR. One checkbox now; months later. |
| **Eye gaze / switch scanning implementation** | Comes free via `Semantics` (§3.1 row 14). Building a scanner is scope inflation — those access methods exist for severe **physical** disability, which is not this population. |
| **SQLCipher** | Both platforms already encrypt app data at rest ([iOS defaults to `NSFileProtectionCompleteUntilFirstUserAuthentication`](https://support.apple.com/guide/security/data-protection-classes-secb010e978a/web) since iOS 7; Android uses FBE with equivalent semantics). SQLCipher defends only a narrow attacker (post-first-unlock, root/jailbreak) at real cost. **One-way door**: `PRAGMA key` cannot be applied to an existing unencrypted DB — that needs `PRAGMA rekey` + temp-file migration. Decide deliberately or not at all. |

---

# 4. The interaction model

## 4.1 Screens (there are four; one matters)

**1. Speak screen — the only screen.**

```
┌─────────────────────────────────┐
│  [dim]                    [Aa]  │  theme + text-size, one tap, always present
├─────────────────────────────────┤
│                                 │
│   ┌───────┐ ┌───────┐ ┌───────┐ │
│   │       │ │       │ │       │ │  3 × 4 grid, ~120dp tiles
│   └───────┘ └───────┘ └───────┘ │  positions FIXED
│   ┌───────┐ ┌───────┐ ┌───────┐ │  empty slots stay empty
│   │       │ │       │ │       │ │
│   └───────┘ └───────┘ └───────┘ │  highest-value tiles: lower-CENTER arc
│   ┌───────┐ ┌───────┐ ┌───────┐ │  (not upper-left — outside natural thumb
│   │       │ │       │ │       │ │   zone for small/medium hands; not the
│   └───────┘ └───────┘ └───────┘ │   extreme bottom edge either — Kim & Ji 2018)
│   ┌───────┐ ┌───────┐ ┌───────┐ │
│   │       │ │       │ │       │ │
│   └───────┘ └───────┘ └───────┘ │
│                                 │
├─────────────────────────────────┤
│  [ type to speak…      ] [SAY]  │  same screen. no tab. no mode switch.
├─────────────────────────────────┤
│  [  ■ STOP  ]  [ Sorry — wrong  │  pinned. always visible. STOP > tile size.
│                  button.      ] │  Repair = a speech act, not a stack pop.
└─────────────────────────────────┘
```

- **Screen stays awake while visible.** An auto-lock mid-shutdown forces a passcode the user may not be able to enter.
- **No long-press anywhere.** It collides with dwell and is an invisible state machine. Edit is a **visible mode toggle**.

**2. Show screen** — one message, brightness override (restore on exit), maximum type size, high contrast, auto-rotate for the reader, navigation pinned. One tap from any tile or from the type field. **This is the exception to the dark/calm rule** — the reader is a cashier at arm's length in daylight. Dark, low-luminance, calm is right for the user's eyes and **wrong** for a stranger reading your screen. Opposite optimizations, distinct renders.

**3. Edit mode** — explicit toggle. Tap a tile → edit its text. Move up / move down buttons; **no drag**. Hide, don't delete.

**4. Settings** — voice, pitch, rate, output mode, theme, haptics, export/import, grid size.

## 4.2 Flows

| Event | Behavior |
|---|---|
| **Cold launch** | Straight to the Speak screen, default set already usable. **No splash, no onboarding gate, no login, no modal, no network wait.** The starter-set picker (if any) is a **dismissible strip on the grid**, never a gate. |
| **Every launch** | **Reset to the home board.** Persist customization and settings; do **not** persist navigation state or scroll position. Determinism beats tap-saving: *"why am I on the Food board?"* is cognitive load at the worst moment. Mitigate the cost by putting the highest-stakes phrases on home, not by restoring state. |
| **Tap a tile** | Immediate. Output per the user's chosen mode. Single short light-impact haptic. No animation. |
| **Type → SAY** | Live TTS (arbitrary text can never be pre-rendered). |
| **Misfire** | **STOP** halts speech instantly. Non-modal, always visible, bottom, larger than a tile. Then **Repair**. Cost of a misfire: half a second of noise, not a catastrophe. |
| **Undo** | **There is none, and there cannot be.** You cannot unsay speech. Repair is the primitive. Say this in the docs. |
| **Handover** | Show screen + prompt to enable Guided Access (iOS) / screen pinning (Android). Honest: the app can prompt; the OS delivers. |

## 4.3 Time-to-first-word paths, ranked by impact × feasibility

**Read this first: the whole ranking rests on an unvalidated hypothesis.** `user-needs` states plainly that the app-launch barrier is *"strongly IMPLIED by motor freeze and decision paralysis, but I found NO direct user testimony."* Reddit — where that testimony would live — was **unfetchable for every researcher**. If the answer is "the phone was already unlocked and in my hand," rows 3–7 are worthless. **Ask 20 people before you build any of it** (§11, 0.2).

| # | Path | Platform | Runs locked? | Verified? | Impact | Feasibility | Verdict |
|---|---|---|---|---|---|---|---|
| 1 | **App already open, phone in hand** | both | n/a | **unvalidated** | decisive | free | **Test this first.** It may make everything below moot. |
| 2 | **Home screen icon** | both | no | yes | baseline | free | The default. Ship it and measure. |
| 3 | **Android Quick Settings tile** | Android | **yes** — reachable from lock shade; `unlockAndRun()` only needed for **sensitive** actions, and speaking a stored phrase is not | docs-verified | **highest real** | M (Kotlin) | **The best affordance found on either platform.** Android beats iOS here — lead with it. Caveats: keep the tile action UI-free (`showDialog()` won't render under the lock screen); OEM skins and the user's lock-screen QS setting can restrict access. |
| 4 | **iOS 18 Control (`ControlWidget`) → Lock Screen slot / Action Button** | iOS 18+ | **yes** | **[CORRECTED — the researcher's "UNVERIFIED" was a search failure]** `AppIntent.authenticationPolicy` **defaults to `.alwaysAllowed`** — *"allows the intent to run without authentication, including when the device is locked."* Controls ≠ interactive Lock Screen **widgets** (which ARE gated). And `AudioPlaybackIntent` process-routing to the app IS documented. | high | M (**Swift only — cannot be written in Flutter**) | Real. **Remaining genuine unknown**: whether TTS audio actually *plays* from a locked/backgrounded app process — needs the audio background mode + AVAudioSession activation, and **no primary source settles it**. Prototype before committing. |
| 5 | **iOS Home Screen widget button (`AudioPlaybackIntent`)** | iOS 17+ | **no** | **[CORRECTED]** Apple: *"On a locked device, buttons and toggles are inactive… unless a person authenticates."* **No workaround.** And **[CORRECTED]** cold-launching the app for the intent is reported as **"several seconds"** (Apple Forums 761677; a DTS engineer endorsed the diagnosis by pointing to launch-time optimization). | medium | M | **Fast path only when the app is already resident** — which is exactly not the mid-shutdown case. If built, the speak path must be **pure Swift** (App Group phrases + AVSpeechSynthesizer), never a Flutter isolate. |
| 6 | **iOS Back Tap → Shortcut** | iOS 14+ / iPhone 8+ | **[CORRECTED — yes, mostly]** Back Tap **can** run shortcuts from the lock screen; unlock is required only if the shortcut needs input or must open an app. Since iOS 16.3 there's a per-shortcut "Allow Running When Locked" toggle, and App Intents default to permitting invocation on a locked device. | docs-verified | medium | S (expose a `Speak Phrase` App Intent) | **The real constraint is screen state, not authentication** — "phone asleep in pocket" fails because the screen must be awake. |
| 7 | **iOS Accessibility Shortcut (triple-click)** | iOS | yes | yes | — | **impossible** | **Closed to third parties in every framework.** This is Live Speech's structural advantage. Accept it. |
| 8 | **Apple Watch / Wear OS** | both | varies | mechanics verified | unknown | M–L | Live Speech is **already** on Apple Watch via Digital Crown triple-click. Speech Assistant **already** ships a Watch app. Wear OS 4+ supports `TextToSpeech#speak` through the watch speaker. **Binding constraint is unverified: watch speaker loudness in a noisy shop or ER.** Test loudness before investing — if it fails, the whole surface is a demo, not an accommodation. |

**The honest positioning claim** — do not exceed it:

> **Phone out, screen on, one tap → speech or large text. Offline. No login.**

Not screen-off. Not in-pocket. No verified path achieves those on iOS, and only marginally on Android. Over-promising here breaks trust with exactly the community whose trust is the only moat this product can have.

---

# 5. Design rules

## 5.1 Grid & targets

- **Default 3 × 4 = 12 tiles.** On a ~390pt-wide phone that yields ~120 × 120dp tiles. Offer **2 × 3 = 6 tiles (~180dp)** as a "large" layout. **12dp minimum gap** — gaps matter as much as size for tremor.
- **[CORRECTED — grid size must remain CHANGEABLE.]** The researcher's "pick one density and never let it change" is an **accessibility regression, not a clinical win**. openAAC and AssistiveWare both treat multiple grid sizes as an accessibility requirement (visual acuity, motor skill); AssistiveWare's actual guidance is *"Feel confident to try a larger grid size any time."* The correct rule: **default to the largest grid the user can comfortably see and touch**; make resize a **deliberate, warned, user-initiated** action; never automatic.
- **Target floor: 76dp for any control.** Reference points: WCAG 2.2 AA SC 2.5.8 = 24×24 CSS px (a *legal floor*, not a design target); AAA SC 2.5.5 = 44×44 with **no** spacing exception; Apple HIG 44pt; Material 48dp; **Google's Design for Driving = 76dp**, the closest impaired-attention analogue. **HONEST FLAG: this dimension's fact-check FAILED to verify** ("verifier failed"). The AA/AAA/Apple/Material figures are independently well-known; **treat 76dp as your design decision grounded in an unverified secondary source, not as a cited standard.** It is conservative and cheap; that is sufficient justification.

## 5.2 Reach

**[CORRECTED — this reverses the researcher's "bottom-first, mirror by handedness" rule.]**

- Hoober 2013 (1,333 observations, 780 screen-touching): **49% one-handed, 36% cradled, 15% two-handed**; ~75% thumb-driven. **Hoober himself cautions these are not population shares and that grip changes every few seconds.** His 2014 follow-up argues reach charts are "flawed" because users re-grip, and recommends key controls go in the **middle**.
- Kim & Ji (Yonsei, IEA 2018), 4.7–5.2in phones: the **natural** thumb zone (reachable without shifting grip) covers >50% for long-thumbed users, **~30% for small/medium**. **Both the upper-left AND the lowermost region fall outside it.** No study tested 6.7–6.8in.

**Rule:** highest-value tiles in the **lower-CENTER arc** — avoiding both the upper-left (the reading-order convention inherited from paper boards) **and** the extreme bottom edge. This is free and helps everyone from either grip. **"A distressed user cannot re-grip" is a hypothesis to test, not a finding.** Grip mirroring, if shipped, is a one-gesture in-context flip, not a settings toggle (§3.2).

## 5.3 Typography

- **System font (Roboto / SF Pro) or [Atkinson Hyperlegible](https://developer.apple.com/fonts/)** (Braille Institute, OFL — engineered for low-vision legibility). **Do NOT bundle SF Pro** — macOS SLA §2.E limits system fonts to display/print while running Apple software, so it can't ship in the Android build.
- Tile label **min 17pt, default ~20pt, weight 500–600**, generous line height.
- **Full Dynamic Type via `MediaQuery.textScalerOf`.** Intrinsic/flexible tile heights; text wraps. Test at 200%+.
- **No dyslexia font as default; OpenDyslexic as an option.** §3.3.
- The evidenced levers are **size, weight, spacing, contrast** — not letterform gimmickry. Weighted-bottom letterforms also visually brand the product as a special-needs device: a dignity cost for an unproven benefit.

## 5.4 Color

**[CORRECTED — the #121212 rule is Material 2 and Flutter has moved on.]**

- **Material 3** — the current spec and Flutter's default since 3.16 — superseded M2's `#121212` + translucent-white elevation ramp. M3's baseline dark surface is **`#141218`** (neutral tone 6), with **tone-based surface containers** (`surfaceContainerLowest`…`Highest`) replacing elevation overlays. Flutter's own docs state `ColorScheme.dark()` *"matches the baseline Material 2 color scheme"* and *"shouldn't be used to update the Material 3 color scheme."* → **Use `ColorScheme.fromSeed(brightness: Brightness.dark)` and M3 surface roles.**
- **The dominant halation lever is TEXT luminance, not the background hex.** `#FFFFFF` → `#E0E0E0` drops contrast 21.0:1 → 15.91:1 (**−24%**). `#000000` → `#121212` only moves 21.0:1 → 18.73:1 (**−11%**), and `#121212` sits at 0.605% of white luminance — far too low to change pupil aperture. **Cap the text; don't fetishize the background.** `#121212` vs `#141218` vs `#000000` is a minor cosmetic choice.
- **[CORRECTED]** "OLED black smear" is **not** Material's rationale and is **not substantiated** — display-engineering sources indicate dark-gray-to-mid-gray transitions often ghost *more* than black-to-white. Drop it from any rationale.
- **Saturation: muted, low-saturation, ~2–5 intentional hues; high saturation only as sparing accents.** Saturation and contrast are **separable** — muted hues at high luminance contrast is achievable and is the target. `#E0E0E0` on `#141218` lands well clear of the 4.5:1 body / 3:1 large-and-UI floors.
- **Category color-coding is fine and useful** (findability). Part-of-speech color-coding is not (§3.3).

## 5.5 Motion & haptics

- **Eliminate animation.** No transitions >~100ms, no bounce, parallax, shimmer, skeleton, pulse, or celebration. Honor `MediaQuery.disableAnimationsOf` / `accessibleNavigation` → **zero duration, not "gentler."** Distressed-user guidance explicitly warns against "sudden animations"; trauma-informed design names jarring visuals as fight-or-flight triggers in sensitized nervous systems. **And animation costs latency in a product whose entire premise is instant speech.**
- **Haptics: one short light-impact pulse on tile activation. Default ON, one-tap OFF from the main screen.** Never sustained, never repeated, never patterned. Genuinely double-edged: it confirms the tap registered without requiring the user to hear or read (valuable when auditory processing is impaired) — but this app's users are *selected* for sensory sensitivity, and **a user in sensory overload cannot navigate a settings tree to stop an irritant.**
- Also honor `AccessibilityFeatures.boldText`, `highContrast`, `invertColors`. Cheap to wire; the only cost is deciding to read them.

## 5.6 The fixed-position decision, justified honestly

**Rule:** tile positions are immutable until the user explicitly and deliberately edits them. Deleting a tile writes **NULL to a grid slot**; it does not shift tiles 5–12 up one. Adds fill empty slots; they do not re-sort.

**Justification, stated with the correct confidence:** LAMP's premise — the motor plan is consistent across time and unique per word, so automaticity with static locations lets users communicate "as fast as they think" via remembered *location* rather than visual scan — is real, and its compounding argument here is real too: a user mid-shutdown has the **least** capacity for visual search, which is the definition of the state the app is for. Adaptive reordering converts a 1-tap automatic retrieval into a search task at the worst possible moment.

**But be rigorous.** The evidence base is [emergent symbol communicators — children with ASD on 84-location devices](https://www.tandfonline.com/doi/full/10.1080/2331186X.2015.1045807) — not literate adults on 12-tile phrase grids, and the sourcing (PRC-founded Center for AAC & Autism; Avaz) is **vendor-side and will not survive an SLP reviewer**. Independent researchers note the motor-planning impact still needs study. What *is* independently supported is the encoding literature: memorized schemes become automatic and thereafter impose **low ongoing cognitive demand**, explicitly contrasted with word prediction, which imposes **ongoing** demand.

**Adopt it because it is free, because reflow's downside is real, and because unpredictable positions remove user control — not because clinical consensus mandates it here.** Drop "actively harmful" and "clinical consensus is explicit" from any external-facing rationale.

**Architectural corollary:** if you ever want frequency benefits, put them in a **separate zone whose LOCATION is fixed even as its contents change**. Proloquo4Text — the leading clinical app for literate adults — uses frequency-based sentence prediction, so frequency data is not off-limits for this population. Unpredictable *positions* are.

## 5.7 "Adult, not infantilizing" — operationally

**BAN (checkable):** cartoon avatars · mascots · animal characters · puzzle-piece iconography · rainbow/primary palettes · rounded bubbly typography · star/sticker/reward motifs · streaks · badges · progress meters · confetti · "Great job!" · "parent/caregiver" account concept · "student"/"learner" framing · tutorial hand-holding · any encouragement copy addressed to a child.

**REQUIRE:** second-person adult copy · no exclamation marks · no encouragement · vocabulary that includes **profanity, sex, medical terms, and job-specific/community terminology** (7/12 requested comprehensive adult-level lexicons; **2 specifically wanted job-specific/community terminology, not basic conversational words**) · the user is the account holder of their own voice, full stop.

**DO NOT confuse "adult" with "monochrome and cold."** `idea.md` correctly names this risk, and the research is the tell: **infantilizing was about vocabulary and being treated as a student, not about color.** The participant wish is *"both symbols and typing and a **vocabulary** designed for autistic adults."* You can be warm and adult. The enemy is cartoon avatars and parental gates — not saturation.

---

# 6. Architecture (Flutter)

**Flutter stable 3.44.0** as of 2026-07-15. Dart 3.x.

## 6.1 State management

**`flutter_riverpod ^2.x`** — but be honest: **this is not load-bearing.** For 12 tiles and a text field, `ValueNotifier` would work. The real reasons to pick Riverpod: a testable seam between the board repository and the UI, and clean reaction to `MediaQuery` a11y flags + TTS voice-availability changes. Don't spend a day on this decision.

## 6.2 Local DB

**`drift ^2.34.2`** — verified publisher `simonbinder.eu`, 2.43k likes, ~973k downloads, published ~July 2026, structurally funded (PowerSync employs Simon Binder; Stream co-sponsors). Android/iOS/Linux/macOS/Web/Windows. Built-in transactions, schema migrations, joins.

**[CORRECTED — drift is not the ONLY healthy relational option.]** `sqflite ^2.4.3` (verified publisher `tekartik.com`, 5.55k likes, **2.46M downloads**) is relational, actively maintained, and healthier on every popularity metric. The abandonment concerns apply to **Isar and Hive, which are NoSQL and were never relational competitors.** The researcher misread a recommendation as a uniqueness finding.

**The honest counter-argument, and why I still say drift from day one:** at 12 tiles, a JSON file is genuinely sufficient — and the product lead is right that it's fine for the two-week MVP. But: (a) the editor is Phase 2 and a JSON→drift migration is **itself a data-loss risk on user-authored content**; (b) drift's cost is ~30 minutes of `build_runner` setup; (c) **a botched migration in this app is the loss of someone's voice**, so versioned migrations + generated schema snapshots + migration tests are worth having from v1, not retrofitted. Take the boring right thing early — it's cheap here.

**DB location:** `getApplicationSupportDirectory()` → `NSApplicationSupportDirectory`. Backed up like Documents but **not user-visible in Files** — correct for an internal DB. **Not** `getApplicationDocumentsDirectory()`.

## 6.3 Data model — steal OBF's semantics

**[CONFIRMED]** [Open Board Format](https://www.openaac.org/docs.html) (OBF/OBZ) is a real, MIT-licensed, JSON-based AAC interop format from CoughDrop/OpenAAC. Field list verified by reading the reference implementation source ([`open-aac/obf`, `lib/obf/external.rb`](https://raw.githubusercontent.com/open-aac/obf/master/lib/obf/external.rb)).

**The single field that matters most: `vocalization` is separate from `label`.** The tile reads *"Overwhelmed"*; it speaks *"I need to leave, I'm not able to talk right now."* **Adopt this on day one** — retrofitting after users have customized boards is a painful migration.

```sql
-- boards
id TEXT PK · name TEXT · locale TEXT · grid_rows INT · grid_cols INT
is_root INT · created_at · updated_at

-- buttons                             -- OBF field →
id TEXT PK
board_id TEXT FK → boards.id
label TEXT NOT NULL                    -- label         : what the tile SHOWS
vocalization TEXT NULL                 -- vocalization  : what is SPOKEN (null ⇒ label)
display_text TEXT NULL                 -- (ours)        : what SHOW mode renders
                                       --                 (null ⇒ vocalization ?? label)
hidden INT DEFAULT 0                   -- hidden        : HIDE, don't delete
background_color TEXT · border_color TEXT
image_id TEXT NULL FK                  -- image_id      : v1 symbols/photos
sound_id TEXT NULL FK                  -- sound_id      : v1 message banking
load_board_id TEXT NULL                -- load_board    : v1, ONE level only
is_system INT DEFAULT 0                -- (ours) STOP / Repair: undeletable
user_edited INT DEFAULT 0              -- (ours) NEVER overwrite on default-set update
created_at · updated_at

-- grid_slots     ← OBF grid.order matrix, normalized. THIS IS THE FIXED-POSITION GUARANTEE.
board_id TEXT FK
row INT
col INT
button_id TEXT NULL FK                 -- NULL = empty slot. Delete writes NULL here.
PRIMARY KEY (board_id, row, col)

-- images
id TEXT PK · path TEXT                 -- image.path : FILES ON DISK, never BLOBs
content_type TEXT · width INT · height INT
license TEXT · attribution TEXT        -- license    : Mulberry attribution lives here

-- sounds
id TEXT PK · path TEXT                 -- sound.path
content_type TEXT · duration_ms INT    -- duration

-- settings  (k/v): voice_id, pitch, rate, output_mode, theme, haptics, grid_size
```

**`grid_slots` with `(board_id,row,col)` as PK and a nullable `button_id` is the schema-level enforcement of "hide/delete never reflows."** There is no ordering to recompute, so you *cannot* accidentally reflow. **Position IS the primary key.** This is the cheapest possible way to make the §5.6 rule structural rather than a code-review discipline you'll violate at 2am.

**Images/sounds on disk, paths in DB.** SQLite's own [intern-v-extern-blob study](https://www.sqlite.org/intern-v-extern-blob.html) favors in-DB BLOBs under 100KB (1.5–2.4× faster at 10KB) — but files-with-paths mirror OBF, allow per-directory backup exclusion (impossible for rows inside one DB file), keep the DB small, and Flutter's image cache erases most of the difference after first paint. Downscale photos on import (≤512px, JPEG q80, ~30–60KB) — a 4MB camera original destroys the backup story.

**Rule for default-set updates:** never overwrite or "upgrade" a tile the user has touched (`user_edited = 1`). Ship new default content as **additive, opt-in, and clearly separate**. User data is unmergeable ground truth.

## 6.4 TTS layer

**`flutter_tts ^4.2.5`** — published ~Jan 2026, MIT, 748 stars, 285k weekly downloads, 150/160 pub points (the 10-point loss is Platform Support — no Linux, web incompatible via `dart:io`, no wasm, no SPM, legacy Kotlin config; **none of which block an iOS+Android build**).

**[CORRECTED on the maintenance story.]** Effectively single-maintainer (dlutton / Daniel Lutton) — the bus-factor risk is **real**. But: (a) the `com.tundralabs.fluttertts` → `com.eyedeadevelopment.fluttertts` rename is **dlutton renaming his own domain, not ownership churn** — all "updating domain" commits authored *and* committed by dlutton (identical timestamp 2026-01-05 08:37:21), changelog says only "Android: Fixing namespace path," LICENSE still reads "Copyright (c) 2018 Daniel Lutton"; (b) "212 open issues" is the GitHub field including PRs — the real split is **196 issues + 16 PRs**; (c) the ~7-month commit gap is **the norm, not decay** — a 217-day gap immediately precedes it. **MIT means you vendor it the day it breaks. This is a fork-later risk, not a start-elsewhere risk.**

### The offline guarantee — the honest version

```
DO NOT SAY: "Nothing leaves your device."
DO SAY:     "This app has no network code and no network permission.
             Speech is synthesized by your device's own system TTS engine,
             and we only select voices that declare they need no network."
```

**[CORRECTED — the most important architecture correction in the corpus.]** TTS synthesis runs in a **separate engine app** bound via `android.intent.action.TTS_SERVICE` (`TextToSpeech.java:2424-2426`), **under its own UID and its own INTERNET permission.** Your manifest cannot constrain it. Omitting INTERNET is still worth doing — it proves *your* code has no network surface, and it's verifiable pre-install on the Play listing — but the claim must be scoped honestly.

For a genuinely provable **in-process** guarantee you'd bundle a TTS engine (FFI to Piper/eSpeak-NG, or `sherpa_onnx`). **That is a real MVP-scope decision this correction would otherwise let you skip.** See §6.5.

### Android voice filter (mandatory)

```dart
final voices = await tts.getVoices; // List<Map<String,String>>
final safe = voices.where((v) =>
    v['network_required'] == '0' &&
    !((v['features'] as String?) ?? '').contains('notInstalled'));

final ok = await tts.setVoice({'name': v['name']!, 'locale': v['locale']!});
if (ok != 1) {
  // flutter_tts returns 0 with only a Log.d on failure.
  // UNCHECKED, an AAC user mid-shutdown silently gets a network voice or NO SPEECH.
  surfaceRealError();
}
```

Keys verified in `FlutterTtsPlugin.kt` (~line 621): `quality`, `latency`, `network_required` (`'1'`/`'0'` **string**), `features` (tab-joined). The plugin's own `isLanguageAvailable` already does `if (v.locale == locale && !v.isNetworkConnectionRequired)` (line 484).

**[CORRECTED]** Drop `KEY_FEATURE_EMBEDDED_SYNTHESIS` / `KEY_FEATURE_NETWORK_SYNTHESIS` — **@Deprecated since API 21**; the docs redirect to `Voice#isNetworkConnectionRequired()` + `setVoice()`. Also handle the second silent-fallback path: the framework may "use a different voice" while voice data is still downloading.

**AndroidManifest, required for targetSdk 30+ or `getEngines`/`getVoices` fail:**
```xml
<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>
```

### iOS

AVSpeechSynthesizer synthesizes **locally**; there is no network-voice tier to defend against and no `isNetworkConnectionRequired` equivalent. **[CORRECTED]** iOS is "low risk, no filter available" rather than a non-problem: iOS 16+ third-party Speech Synthesis Provider extensions register voices system-wide with no way to screen them, and — more importantly — **the real iOS offline risk is voice AVAILABILITY**: enhanced/premium voices are 100MB+ user-downloaded and **user-deletable**, and an unknown identifier **silently falls back to the default compact voice**. For an AAC app that's a real quality regression. Handle it: existence check at speak time, `availableVoicesDidChangeNotification`, and first-run download guidance (there is **no deep link** to the voices Settings pane — the copy must be hand-written and illustrated).

**[CORRECTED]** `flutter_tts` open issue **#136 is NOT evidence of accidental network voices** — it's a 2020 report against 0.1.x, never diagnosed, and its only stack trace is a `SocketException` to the reporter's own dev server at `192.168.0.101:3000`. Drop it. **#429 is the real evidence** and is still open.

### Audio session (iOS)

```dart
await tts.setSharedInstance(true);
await tts.setIosAudioCategory(
  IosTextToSpeechAudioCategory.playback,        // NEVER .ambient — silent switch mutes you
  [IosTextToSpeechAudioCategoryOptions.duckOthers],
  // or .interruptSpokenAudioAndMixWithOthers so podcasts pause rather than dip
  IosTextToSpeechAudioMode.voicePrompt,
);
```
Verified in `SwiftFlutterTtsPlugin.swift` (`setAudioCategory` ~line 289, `setSharedInstance` ~line 280). The plugin's `shouldDeactivateAndNotifyOthers()` already inspects `.duckOthers` / `.interruptSpokenAudioAndMixWithOthers` to decide whether to deactivate and notify others after speaking — so ducking-then-restoring music is handled for you.

### Route override — DROP the requirement

`idea.md`'s "in a shop with earbuds in, speech must come out the SPEAKER" is **essentially unachievable on iOS**: `defaultToSpeaker` **only applies to `.playAndRecord`** and is ignored under `.playback` (which you need for silent-switch bypass); `overrideOutputAudioPort(.speaker)` **loses to an active Bluetooth route**; and adopting `.playAndRecord` to get `defaultToSpeaker` **triggers a microphone permission prompt** — actively corrosive to a no-account, privacy-first AAC app.

**Replace with:** route detection + a persistent visible warning ("Audio will play in your earbuds") + a one-tap route control. Honest UI beats a promise the OS will silently break in exactly the high-stakes moment the feature exists for.

### The pre-render decision: **DON'T** — measure first

**[CORRECTED — this reverses the researcher's `should-have-v1` recommendation.]**

The iOS first-utterance delay is real and documented — [Apple Forums 715339](https://developer.apple.com/forums/thread/715339) measures per-language pronunciation rule-data loading from disk: **English 862KB/~0.25s, Italian 537KB/~0.7s, German 4.4MB/~3.2s** — but **only when switching to a newer high-quality voice with a delegate set, on device, not Simulator**. Apple requested a sysdiagnose (FB11380447) and did not resolve it as of Apr 2023. **There is NO evidence either way for iOS 18–26** — treat current status as **unknown** and re-test.

**Because it is a one-time-per-language cost rather than per-tap, "instant" IS plausibly achievable with live TTS, and pre-rendering is likely premature optimization.** It also cannot serve the type-to-speak box (arbitrary text must be live), `synthesizeToFile` is buggy (#271 slow on iOS, #240 ignores the provided path, #312 multi-line → empty file, #272 no concurrency), and it forks the architecture (Personal Voice cannot be buffer-captured).

**Measure, then mitigate in order:** (a) keep **one synthesizer alive as a singleton** — never construct per tap; (b) **pre-activate the audio session at launch**, not at first tap; (c) fire a **silent warm-up utterance** (`" "`, volume 0) at launch. Note **flutter_tts has no warm-up API**, so (a) and (c) may need a platform channel or fork. Only if warm-up demonstrably fails should pre-rendering be considered, and then only for fixed tiles.

**Localization corollary survives:** rule-data varies ~8× by language → **English-first**, per-language on-device benchmarking before adding locales.

**[CORRECTED — and this matters for the legal section]** The claim that Apple's SLA bans pre-rendered TTS is **macOS-only**. The **iOS/iPadOS 26 SLA contains no system-voice restriction** — see §9.4. **The reason not to pre-render is engineering, not legal.**

## 6.5 Neural TTS escape hatch (v2, only if Phase 0 says so)

`sherpa_onnx ^1.13.4` — Apache-2.0, ~28.4k weekly downloads, published ~July 2026, upstream `k2-fsa/sherpa-onnx`. Android/iOS/Windows/macOS/Linux/HarmonyOS. **~25MB runtime + ~30MB voice ≈ 55MB** install; higher battery draw and thermal load; worse latency on low-end phones — which argues for pairing it with pre-rendering so slow synthesis is hidden at edit time.

**Model licensing, corrected and important:**
- **Kokoro-82M: Apache-2.0, no commercial restrictions.** The clean choice.
- **Piper: the license CHANGED.** `rhasspy/piper` (MIT) was **archived 2025-10-06**; the active successor `OHF-Voice/piper1-gpl` is **GPL-3.0** (v1.4.2, Apr 2026) — **effectively App-Store-incompatible for a proprietary app.** The corpus's "Piper engine is MIT" is stale.
- If you ship any Piper-lineage voices, **audit each voice model individually** — the engine license does not cover the models.

## 6.6 Native interop surface (what needs a platform channel)

| # | Surface | Why Flutter can't | Size |
|---|---|---|---|
| 1 | **Personal Voice (iOS)** | **[CONFIRMED by source inspection]** — grepped `SwiftFlutterTtsPlugin.swift` for `personal` / `requestPersonalVoiceAuthorization` / `voiceTraits` / `isPersonalVoice`: **zero matches.** The plugin surfaces `voice.quality` so it *does* read `AVSpeechSynthesisVoice`, but never calls the authorization API and never exposes traits. Since Personal Voice only appears in `speechVoices()` **after** authorization succeeds, an unmodified flutter_tts app **will never see one.** | ~1 method (`requestPersonalVoiceAuthorization` + surface `voiceTraits`) |
| 2 | **Android Quick Settings tile** | Kotlin `TileService`. **Speaks natively from SharedPreferences/DataStore. No Flutter engine on this path.** | S–M |
| 3 | **iOS 18 Control (`ControlWidget`)** | Swift only. App Group phrases + `AVSpeechSynthesizer` + `AudioPlaybackIntent` conformance + `authenticationPolicy = .alwaysAllowed` (the default). | M |
| 4 | **Warm-up / singleton synthesizer** | flutter_tts has no warm-up API. **Only if the latency probe says so.** | XS |
| 5 | **Route detection** | `AVAudioSession.currentRoute`. | XS |

**Personal Voice, corrected on three counts:**
- **[CORRECTED — onboarding is 15× cheaper than the corpus says.]** As of **iOS 26 (Sept 2025)** Personal Voice requires only **10 recorded phrases and takes under a minute**, generated on-device — **not** ~150 prompts / ~15 min / 3+ hours plugged in and idle (those were the iOS 17 figures). Apple rebuilt it on on-device ML (announced May 2025) and added a short three-word-phrase option for users who struggle to read full sentences. **AssistiveWare's docs still cite the 150-phrase figure and should not be trusted here.**
- **[CORRECTED — it does NOT solve the voice-identity gap.]** Personal Voice models the user's **own** voice. For a user with **voice dysphoria** it reproduces the dysphoric voice. It is voice **preservation**, not voice **identity** — targeting progressive loss (ALS), with zero androgynous options. It is not the answer to the 4/12 nonbinary/middle-pitch finding.
- **[CORRECTED, medium confidence]** "Personal Voice cannot be pre-rendered" is **undocumented runtime behavior**, not a documented by-design limitation — Apple has never stated it in docs, WWDC, or any forum reply. Rather than failing, the API *"defaults to output channel"* — meaning it **speaks aloud while producing a silent/empty file**. **Guard `synthesizeToFile` with `voiceTraits.contains(.isPersonalVoice)`.** And thread 736148 does **not** confirm a background-playback restriction — the OP asked exactly that and got no answer. Retest on current iOS.
- **Treat it strictly as progressive enhancement over a standard on-device baseline, never a dependency.** iOS-only, no Android equivalent, undiagnosable failure path (`.denied` on unsupported devices; no deep link to the toggle). **And ask App Review about the SLA §2(f) contradiction first** (§9.4).

## 6.7 The architectural rule that follows

> **The speak path is native and reads from shared storage. Flutter owns the editor and the in-app UI.**

Phrases persisted to **App Group (iOS)** / **SharedPreferences or DataStore (Android)** as the Flutter↔native contract. This makes time-to-first-word a **native code budget**, not a Flutter engine-start budget.

`home_widget`'s iOS interactive path routes through `HomeWidgetBackgroundWorker` (a Flutter **background isolate**), and the `ForegroundContinuableIntent` variant **boots the full Flutter app via the main entrypoint** — both add latency and failure modes on the one path that must be instant. Since `AudioPlaybackIntent` already gets you into the app's native process, route around Flutter entirely.

**`home_widget ^0.8.x`** if used at all: its own docs state it *"does not allow writing Widgets with Flutter itself — it still requires writing the Widgets with native code"* (SwiftUI/WidgetKit; Jetpack Glance on Android — and **Glance is NOT Compose**; many Compose features don't work). Since 0.8.1 the background service no longer needs manifest registration. **Use it as a data bridge only, or skip it and hand-roll the App Group / SharedPreferences read.**

## 6.8 The text field: keep it dumb

**No `TextInputFormatter` on the type-to-speak field.** It is the common thread in Flutter's two worst *wrong-text* bugs: [#171955](https://github.com/flutter/flutter/issues/171955) (open, P2, filed 2025-07-10 — Samsung Keyboard autocorrect race producing wrong text) and [#133034](https://github.com/flutter/flutter/issues/133034) (open, P2 — dictation breakage, reproduced on Gboard *and* SwiftKey).

**[CORRECTED — two of the six issues the researcher cited are closed and one is backwards.]**
- **#134881 was FIXED 2023-09-22** by engine PR #46144 and locked — **iOS spell-check/auto-suggest CAN be disabled since Flutter 3.14.** That bullet was stale and inverted.
- **#22828 closed 2019.**
- #139143 and #22828 are Android `TYPE_TEXT_FLAG_NO_SUGGESTIONS` / Gboard **platform-flag** issues (triage retitled #139143 to "[Documentation]") and would reproduce on a native `EditText` — they do **not** evidence "Flutter reimplements the text field."
- Live and relevant: #171955, #133034, **#84419** (open P2 — iOS dictation `onChanged` fires after `clear()`; **the TextInputFormatter mitigation does NOT cover this one**). Newer: #156691, #182876 (Feb 2026). There are **1,044 open `a: text input` issues**.
- **RN is not a clean escape**: #33139 (Samsung predictive text crashes TextInput), #30453/#18457 (`autoCorrect={false}` broken on Android), #30503.

**Net: test dictation + Gboard/SwiftKey/Samsung Keyboard early on whichever stack you pick.** This is a shared risk, not a Flutter-vs-RN differentiator. Accept raw text; format nothing.

## 6.9 Backup configuration (a landmine, with five corrections)

**Android Auto Backup** is **ON by default** (`android:allowBackup` defaults true for API 23+), **capped at 25MB per app per user**, and when exceeded the system **stops uploading with no notification to the user**. The 25MB is an **app-wide aggregate**, so 100 photo tiles at ~200KB (=20MB) **silently kills the backup of your phrase DB too**.

**[CORRECTED, five ways:]**
1. **As of July 7, 2026, Android backup app data DOES count against the user's Google Account / Google One storage.** The autobackup dev page's "does not count toward the user's personal Google Drive quota" line is **stale**.
2. **Charging is NOT a backup condition.** Conditions are: backup-enabled + ≥24h since last + idle + Wi-Fi.
3. **The stoppage is not permanent** — the system re-checks and resumes once data falls under 25MB. `onQuotaExceeded()` fires **only** for apps with a custom `BackupAgent`, so a plain Auto Backup app gets **no signal**.
4. **The encryption gate is `disableIfNoEncryptionCapabilities="true"` on the `<cloud-backup>` element** — gating the **whole channel**. It is **NOT** `requireFlags="clientSideEncryption"` on an `<include>`; that belongs to the legacy `<full-backup-content>` format and is **ignored** once the app points at `android:dataExtractionRules` on Android 12+. So the lever is **coarse (all-or-nothing per channel)**, not precise. `FLAG_CLIENT_SIDE_ENCRYPTION_ENABLED` via `BackupAgent.transportFlags` is the actual precise lever — and requires a custom `BackupAgent`.
5. **There is no documented evidence device-transfer is uncapped.** 25MB is documented only for cloud backup; Google is silent on D2D. Google's documented path for oversized backups is the **Large Backups API allowlist program**, not D2D.

**Ship this** — the simplest privacy-correct posture, depending on none of the contested specifics:
```xml
<application android:allowBackup="false" ... >
<!-- or: dataExtractionRules with an empty/omitted <cloud-backup>
     and a permissive <device-transfer> -->
```
Result: *"phrase tiles survive a new phone; nothing ever reaches Google Drive."* This matches your promise **better** than conditioning cloud upload on E2EE — because **E2EE backups still leave the device and still depend on the user having a screen lock**, and users in this population may not. Pair it with **user-initiated file export**, which is the real backup story anyway.

**iOS:** files in `Documents` and `Library/Application Support` are in iCloud backup **by default**. Under **Standard Data Protection, Apple holds the keys**; only **Advanced Data Protection** (opt-in) makes iCloud Backup E2EE. `isExcludedFromBackup` is documented by Apple as **guidance, not a guarantee**: *"exists only to provide guidance to the system… it's not a mechanism to guarantee those items never appear in a backup."* **Word the toggle honestly.**

**Threat-model note (medium confidence — an inference about user threat models, not a measured claim):** phrases like *"I am being hurt"* imply an adversary who is a **caregiver or partner with access to the user's Apple/Google account** — common for disabled adults, and for DV survivors. That makes an explicit, plainly-worded **"Keep my board off cloud backup"** toggle a **safety accommodation, not a preference.**

## 6.10 File layout

```
lib/
  main.dart
  app.dart                       # MaterialApp; ColorScheme.fromSeed(dark/light/highContrast)
  core/
    a11y.dart                    # MediaQuery: boldText, highContrast, invertColors,
                                 # disableAnimations, accessibleNavigation, textScaler
  data/
    db/
      database.dart              # @DriftDatabase
      tables.dart                # Boards, Buttons, GridSlots, Images, Sounds, Settings
      migrations.dart
      schema/                    # generated snapshots (drift_dev schema dump) + tests
    repo/
      board_repository.dart
      settings_repository.dart
    default_set/
      starter_sets.dart          # PROVENANCE-TAGGED: who wrote it, and why
    export/
      obf_export.dart            # hand-rolled OBF/OBZ writer — NO Dart OBF lib exists;
                                 # open-aac/obf is Ruby and only sporadically maintained
                                 # (last commit 2025-06-15; prior activity July 2022)
  speech/
    speech_service.dart          # abstract: speak(String) · stop() · voices()
    tts_speech_service.dart      # flutter_tts impl
    recorded_speech_service.dart # v1: play sound file if sound_id present, else TTS
    voice_filter.dart            # Android network_required/features + setVoice return check
    audio_session.dart           # iOS .playback + duckOthers + setSharedInstance
  ui/
    speak/  speak_screen.dart · tile_grid.dart · tile.dart · type_to_speak.dart · stop_bar.dart
    show/   show_screen.dart     # brightness override + restore; huge type
    edit/   edit_mode.dart       # explicit mode; move up/down; NO drag
    settings/ settings_screen.dart
  theme/  tokens.dart · themes.dart

android/app/src/main/kotlin/.../SpeakTileService.kt   # QS tile — native speak, no Flutter
ios/Runner/PersonalVoiceChannel.swift                 # requestPersonalVoiceAuthorization
ios/SpeakControl/                                     # v1: ControlWidget + AudioPlaybackIntent
```

**Explicitly not using:** Isar (author silent; original abandoned — **[CORRECTED]** it has *consolidated* on `isar_community`, a volunteer **v3-bugfix-only** fork with no v4 path, not fragmented three ways) · Hive (author abandoned) · **Realm** (**[CORRECTED]** — Atlas Device **Sync** shut down 2025-09-30 and the SDKs were deprecated Sept 2024, but they are **NOT unmaintained**: realm-swift v20.0.5 shipped 2026-06-14, realm-js pushed 2026-07-10, none archived. The **Flutter-specific** issue is that **realm-dart alone is dormant** — last commit 2025-10-23, ~9 months, 140 open issues — and its reason to exist was the sync layer we reject) · ObjectBox (maintained but commercial, centered on sync you don't need) · **Firebase/Crashlytics** (even Crashlytics-only pulls in Firebase core, which declares **additional** data categories — the nutrition label lists **more** collection with Firebase than with Sentry) · **Sentry** (milder — diagnostics only, no ad ID/user ID/analytics — but data still leaves the device, and then you can no longer make the §6.4 claim).

---

# 7. Flutter vs React Native

## Verdict: **Flutter. Your preference is validated — but every popular argument for it is wrong, and the accessibility objection is narrower than it sounds.**

## 7.1 Accessibility, front and center

**"Flutter paints to a canvas so it's inaccessible" is architecturally false on mobile.** `SemanticsNode` maps to real `UIAccessibility` / `AccessibilityNodeInfo` objects — assistive tech sees nodes, not pixels — and semantics is **ON by default** on mobile, unlike web where it's explicitly opt-in. The "black hole for TalkBack" reports trace to (a) [Flutter **Web**](https://docs.flutter.dev/ui/accessibility/web-accessibility), and (b) app-specific custom-painted widgets that never populate semantics.

**[CORRECTED nuance — it doesn't "not apply" at all.]** Because Flutter **synthesizes** rather than **inherits** the native a11y tree, residual mobile bugs remain open: **#173080** (TalkBack focus skipping/resetting in scrollable `ListView`/`Column`, open P2, 3.32/3.33), **#99600** (missing app-language declaration to VoiceOver/TalkBack), and no way to force screen-reader focus to newly presented widgets. **Achievable, but deliberate work — not free.** (For a 12-tile static grid, this is a non-issue.)

**Full Keyboard Access: REFUTED as a blocker.** **[CORRECTED — this was the strongest argument against Flutter and it collapsed.]** Flutter shipped basic iOS FKA support (engine PR #56842); **[#76497](https://github.com/flutter/flutter/issues/76497) was closed as COMPLETED with an `r: fixed` label on 2025-03-31**, in beta Jan 2025. Of the four issues cited against Flutter, **three are closed** (#76497 completed; #165303 closed as solved one day after filing; #148409 closed as a duplicate nine minutes after filing); only **#166683** remains, labeled P2 / "e: device-specific." A Google engineer confirmed Sept 2025 that the keyboard-breaking behavior *"doesn't happen on iOS >= 18"* and is only easily reproducible on iOS 17, with 90%+ of devices on 18+. A Nov 2025 tester validated Apple's full external-keyboard control set on iOS 26 with no problems. **The "FKA on Flutter does not exist / WCAG conformance unachievable" line is a single reader comment on a dev.to post from Oct 2024 — before the fix landed.** Real status: partial support with open gaps (#187055 scrolling to offscreen semantics nodes, #181007 scrolling with bottom nav bars, non-focusable Sliders, no way to query iOS accessibility focus, Cupertino widgets not keyboard-operable). **Largely orthogonal to a touch-first AAC app.**

**Switch Control: NOT missing — undocumented.** **[CORRECTED.]** [#126377](https://github.com/flutter/flutter/issues/126377) *was* opened by Hixie in May 2023 and *is* still open and unassigned — but it was **retitled by Flutter's accessibility engineer (chunhtai) on 2024-05-13 to "Adding more documentation about Flutter's Switch Control support"**, and in the comments he states support **already exists** and was a launch requirement for a first-party customer. Hixie accepts this and narrows the ask to a demo video for flutter.dev. **The honest score is "supported, unverified by vendor documentation," not "feature missing."** But the actionable implication is unchanged: **no vendor guarantee exists to lean on, so verify it empirically against your own grid on a real device** (§11, 0.6).

**Flutter's screen-reader defaults are BETTER than RN's.** Flutter's standard widgets auto-generate the semantics tree; [RN's own docs](https://reactnative.dev/docs/accessibility) confirm `accessibilityLabel`/`accessibilityRole`/`accessibilityLiveRegion` must be hand-authored per element with **no automatic role detection** (lone exception: Touchable components default their label to child `Text`). **[CORRECTED — drop the heading-level argument]**: iOS has supported true heading levels 1–6 via `accessibilityHeadingLevel` **since iOS 13**, so Flutter does **not** "exceed both native platforms" — it has actually **lagged** (#155928 open; iOS wiring landed only in 3.45.0-0.1.pre while stable is 3.44.0, so numeric heading levels currently reach **only Flutter web**). Irrelevant to a tile grid regardless. Also not free: `Icon`/`Image` still need manual `semanticLabel`.

**Text scaling: Flutter wins by default.** [#22480](https://github.com/flutter/flutter/issues/22480) (2018, closed) was a developer asking how to **disable** iOS Larger Text — the complaint was that it *works*. The failure mode is self-inflicted.

## 7.2 The real Flutter costs, named

1. **Every high-value platform surface requires native code.** `home_widget` is a data bridge; no official App Intents integration and no stated plan ([#170589](https://github.com/flutter/flutter/issues/170589)), only early community packages, while SiriKit is on a deprecation path. **[CORRECTED, and it's a real RN win]**: as of **Expo SDK 57**, Expo ships a **first-party `expo-widgets`** that authors iOS home screen widgets and Live Activities in **TypeScript** via `@expo/ui/swift-ui` "without writing native code" (iOS-only, dev build required, **no App Intents**). So on home-screen widgets RN now has a genuine no-native-code path. On **App Intents both ecosystems still require native Swift** — that half is a wash.
   **But the cost is smaller than it looks here.** WidgetKit forbids UIKit and watchOS targets are always separate SwiftUI targets, so **a fully native app writes the identical extensions**. Back Tap, the Action Button, and Shortcuts "Open App" require **no code at all** and work for Flutter apps identically to native. The Accessibility Shortcut can't launch a third-party app in **any** stack. **Choosing Flutter costs roughly a few hundred lines of platform-channel and extension glue; choosing native costs the entire Android build** — the more damaging trade for a product whose whole reach argument is Android.
2. **Text input.** §6.8. A shared risk, not a differentiator.
3. **[CORRECTED — the cold-start advantage is NOT established, and this argument should be dropped.]** The 2025 SynergyBoat figures measure a **vsync-quantized frame-presentation interval within a running process** (Flutter's iOS 16.67ms is exactly one 60Hz frame period), **not launch from a cold process**; the same run has **Swift native "losing" to Flutter with an SD larger than its mean over n=3**, which invalidates the metric. Both cited sources are **non-independent vendor blogs** (SynergyBoat is a Flutter agency). Real-world cold start (~1–2s, dominated by process spawn and TTS engine init) is where the mid-shutdown requirement actually lives, and **no reliable framework comparison exists for it.** **[CORRECTED on Impeller]**: it is the only renderer with Skia removed on **iOS**; on Android it's default on **API 29+ only**, still falls back to legacy OpenGL below API 29 or without Vulkan, and legacy-Skia removal on Android 10+ is a **2026 roadmap goal, not shipped**. Impeller's build-time shader precompilation and jank reduction are real and documented — but the "Flutter is faster to launch" claim is not.
4. **App size: a wash.** Measured 2025: iOS Flutter 18.3MB vs RN/Expo 20.2MB; Android Flutter 41.6MB vs RN/Expo 52.1MB. Other sources disagree because they measure different artifacts. **Not a decision input.**
5. **TTS parity: a non-issue.** Both are thin wrappers over the identical native engines. Voice quality is a **device** concern. flutter_tts additionally exposes per-voice quality/latency/network metadata, which you need. **Do not build the framework decision on TTS.**

## 7.3 What actually decides it

Full control over a visual system that **deliberately departs from platform defaults** (Flutter's home turf; RN's native-view advantage is worth least when you're overriding native look anyway) · one toolchain for a solo dev · better a11y defaults than RN.

**The trigger condition to watch, named now so you recognize it later:** if the roadmap's centre of gravity ever shifts to being **mostly widgets / Watch / Siri** rather than the in-app grid, the Flutter calculus **genuinely flips**.

**Budget real Swift and Kotlin learning time as a known cost of this choice. Do not pretend it away.**

---

# 8. Risks

Ranked. "Cheapest experiment" = what to do before building.

| # | Risk | Sev | Lik | Mitigation | Cheapest experiment |
|---|---|---|---|---|---|
| 1 | **The incumbents are already good enough** — Speech Assistant AAC is the described MVP, offline, adult-marketed, both platforms, since ~2016, ~810k Android downloads, and already ships side-of-screen one-handed placement | **fatal** | **high** | Reposition on episodic-state design + Android + show-text — or don't build. If they're adequate, the honest answer is to file an issue with ASoft or contribute. | **$24.99 + 90 min.** Install and use it. Then ask r/AAC (mods first): *"what specifically made you stop using it?"* — phrased so it can come back **no**. |
| 2 | **Stock TTS sounds bad; voice quality is a top-two continued-use obstacle** and it is **largely outside your control on both platforms** | **fatal** | med-high | sherpa_onnx + Kokoro-82M (Apache-2.0, +55MB, battery, thermal) as escape hatch; message banking for top phrases. Piper's successor is GPL-3.0 and is **not** available to you. | **1 day.** flutter_tts probe on a **$120–150 Android** (not "mid-range" — 10/12 are cost-constrained; that's where they are) and an iPhone with only the compact voice. Blind A/B vs Speech Assistant with 5 community members. **KILL CRITERION: can't match it → the project does not proceed as specified.** |
| 3 | **The app-launch barrier is unvalidated** — zero direct testimony exists anywhere; Reddit was unfetchable for every researcher. It is the **only** thing that makes the widget/Control/QS-tile work worth its native cost. | high | unknown | None until validated. | **Free.** Ask 20 people: *"Last time you needed this, was your phone already unlocked and in your hand, or in your pocket?"* |
| 4 | **"Speak aloud" may not be the core job** — 8/12 display text instead of/alongside TTS. If display-first is right, nine research dimensions optimized the wrong path. | high | med | Ship both first-class; remember the mode per context. | Same 20-person ask: *"When you use AAC in public, do you make it speak, or show the screen?"* |
| 5 | **The entire evidence base is one n=12 self-selected US-only unrefereed preprint + one n=5 focus group.** Five dimensions describe it as "independent corroboration." It is the **same twelve people.** | high | **certain** | Treat everything in this brief as directional. | Recruit 5 people from r/AAC. **Pay them.** |
| 6 | **You are entering a field that published *"Nothing about AAC users without AAC users"* in 2025**, naming **tokenism** as a specific risk — and there is a nonspeaking AAC user building this exact app in Flutter and asking for a partner | high (reputational; **reputation is the only moat available here**) | high if you ship solo | Name your positionality. Recruit and **pay** an advisory group. Consider partnering with [Flutterkeys](https://github.com/earth-pheonix/Flutterkeys) rather than competing. | **1 hour.** Read [Blasko et al. 2025](https://doi.org/10.1080/07434618.2025.2514748). Email Pheonix. |
| 7 | **Abandonment risk on YOU.** Users build dependence on a **disability accommodation**, and **unresponsive support is a named abandonment cause in this exact population**: *"I am by far not the only adult autistic AAC user who feels like Coughdrop support kinda blows us off."* App #N of a 50-app challenge. | high | high | **The offline/no-account architecture means it keeps working if you stop maintaining it — say that out loud; it is the one honest ethical answer.** Commit to an exit plan (open-source it / transfer it / sunset notice) **before** launch, and put it in the listing. | Free. Decide, then write it down. |
| 8 | **On iOS you compete with a free preinstalled OS feature that owns a shortcut you can never register for** | high on iOS | **certain** | Android-first. Don't pitch type-to-speak on iOS. | Free. Already known. |
| 9 | **EU MDR Class I.** [MDCG 2019-11 Rev.1](https://health.ec.europa.eu/document/download/b45335c5-1679-4c71-a91c-fc7a4d37f12b_en?filename=md_mdcg_2019_11_guidance_qualification_classification_software_en.pdf) p.35 names your app almost verbatim, **naming autism, selective mutism and aphasia** — and the example was **added in Rev.1** (17 June 2025); it is not in the 2019 original. | med (months + paperwork) | certain if you ship to EU | **Geo-restrict the EU at launch.** One checkbox in App Store Connect / Play Console. | None. It's settled. |
| 10 | **Android voice silently falls back** — `setVoice` returns 0 with only a `Log.d`; an AAC user mid-shutdown gets silence | med (but catastrophic for the individual) | med | Check the return value; surface a real error. | Test on a device with no matching voice. 20 min. |
| 11 | **iOS enhanced/premium voices vanish or never install** — iOS 26 regressions reported (voices vanishing after reboot, downloads stalling); unknown identifier silently falls back to compact | med | med | Existence check at speak time + `availableVoicesDidChangeNotification` + illustrated onboarding (no deep link exists). | Delete a premium voice on a test device; observe. |
| 12 | **flutter_tts bus factor** — effectively one maintainer, ~196 open issues | med | med | **MIT — vendor it the day it breaks.** A fork-later risk, not a start-elsewhere risk. | None. |
| 13 | **Data loss on phone upgrade** — six months of curated phrases + banked audio is an irreplaceable personal asset; iOS app-private data is unrecoverable without a backup the user may not have | high **for the individual user** | high without export | File export from v1 + `allowBackup="false"` + device-transfer. | None — just build it. |
| 14 | **Motor precision in distress is genuinely unmeasured.** Best evidence ([PMC11148429](https://pmc.ncbi.nlm.nih.gov/articles/PMC11148429/): 80% of autistic participants impaired on ≥1 motor measure vs 47.6% controls) is **97 autistic YOUTH aged 8–17**, correlational, and says nothing about shutdown. **The 76dp target-size claim's fact-check FAILED to verify.** | med | unknown | Design conservatively and **say so** rather than citing a standard you don't have. | Not ethically measurable at your scale. |
| 15 | **Symbol licensing** — Mulberry's license version is genuinely contested upstream; the real risk is the **anti-TPM/DRM clause vs Apple's FairPlay**, which applies to distributing the symbols *at all*, not just adaptations | med | med | **Ship text-only in the MVP.** If symbols ship: get written confirmation from Steve Lee, **or** ship symbols unmodified and do dark-theme adaptation **at runtime** (tint/`ColorFilter`/shader), never to the shipped asset files — which creates no Adapted Material and is also the cleanest engineering path for a themable grid. | Email Steve Lee. Free. |

---

# 9. Legal / licensing / store

## 9.1 Medical device status

**US: you're fine — but not for the reason the corpus says.**

[21 CFR 890.3710](https://www.law.cornell.edu/cfr/text/21/890.3710) "Powered communication system," product code **ILQ**, review panel Physical Medicine: Class II but **codified 510(k)-exempt** — written into the regulation, not a grey area.

**[CORRECTED, and this changes what protects you.]** This is **not why AAC apps ship without clearance.** 890.3710 only reaches devices "intended for **medical purposes**." FDA registration data shows hardware SGD makers (Tobii Dynavox, Prentke Romich, ProxTalker) **ARE registered** under ILQ, while app-only makers (AssistiveWare/Proloquo2Go, Saltillo, TouchChat) are **not registered at all**. They ship without clearance because **they are not marketed as devices intended for a medical purpose.** **The operative safeguard is your marketing/intended-use posture, not the exemption.** Also: it isn't blanket — **38 510(k)s exist under ILQ**, including one cleared in 2017 (K162817, Voxello Noddle); and 510(k)-exempt devices must still **register, list**, and (ILQ is **not** GMP-exempt) comply with CGMP/QMSR.

**[CONFIRMED]** The exemption is conditional under [21 CFR 890.9](https://www.law.cornell.edu/cfr/text/21/890.9): it is void for a device with an **intended use different from a legally marketed device** or one that **"operates using a different fundamental scientific technology."** Tap-a-tile and type-to-speak sit comfortably inside existing SGD characteristics. **LLM phrase generation plausibly does not — which is why it is a regulatory decision, not a feature decision.** Price the regulatory cost before the engineering cost.

**EU: don't launch there at v1.**

**[CONFIRMED by direct PDF extraction.]** MDCG 2019-11 Rev.1, published 17 June 2025, **page 35**:

> *"MDSW app intended to assist persons with a communication disorder (e.g. cerebral palsy, **autism (ASD), selective mutism**, MS, MND, Down's syndrome, **aphasia**, etc.) talk by converting a set of selected symbols into spoken language. Depending on the patient's medical status, the selection can be done through various means such as a touch screen, head tracking or eye gaze. **This MDSW app should be classified as class I per Rule 11c.**"*

That names **three of your four segments**, and **it was added in Rev.1** — the 2019 original has zero hits for "aphasia," "autism," "mutism," or "symbol."

Class I is **self-certified** (no notified body, no clinical investigation) — but still: Annex II/III technical file, clinical evaluation, Art. 10(9) QMS, **PRRC** (Art. 15), UDI, **EUDAMED registration (mandatory since 28 May 2026)**, PMS, CE marking, and an **EU Authorised Representative** if you're established outside the EU.

**[CORRECTED framing]**: this is **not** "a choice between MDR and discoverability." MDR Art. 2(12) defines intended purpose by *"the data supplied by the manufacturer on the label, in the instructions for use or in promotional or sales materials"* — **claims ARE the lever**, and the MHRA says compensation-for-disability equipment "may or may not be a medical device… depend[ing] entirely on the claims made." The standard industry path is to **declare the AAC purpose honestly and self-certify Class I**. The burden is real but is **not** "the single largest strategic tension." Also: Rev.1 **narrows** the "simple search" carve-out (*"would not be considered… 'Simple search' if it contributes to achieving a medical purpose"*) — so gaming the technical exemption is the route that does not work.

**Verdict: geo-restrict the EU at launch.** One checkbox now; months and five figures later.

## 9.2 Store medical rules

- **[CONFIRMED] Google Play forces the question.** All developers with a published app — **including closed/open testing** — must complete the **[Health apps declaration](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en)** (Policy > App content). Apps regulated as a medical device "must be declared as such," will be labeled **"Medical Device"** on Play, and "must provide proof of approval, clearance or certification by the relevant authority **upon request**." Non-device health apps must include "a clear disclaimer… that the app is not a medical device."
  **UNVERIFIED**: multiple secondary sources say a Jan-2026 update adds an EU "Medical Device" label and pulls MDCG guidance into the policy. **This could not be confirmed on Google's own policy page.** Treat the EU-label specifics as unverified.
- **Apple 1.4.1: low risk.** Its teeth are aimed at sensor-based measurement claims ("apps that claim to take x-rays, measure blood pressure… using only the sensors on the device are not permitted"). An AAC app **measures nothing and diagnoses nothing** — it speaks text the user chose. Note *"If your medical app **has** received regulatory clearance, please submit a link"* is **permissive, not a precondition.**
- **The disclaimer tension, resolved.** Play pushes non-device health apps to say "not a medical device." Asserting that to EU users **contradicts the Commission's own classification example** and could become evidence of a false statement. **Use [AssistiveWare's actual pattern](https://www.assistiveware.com/terms-conditions)**: as-is + limitation of liability + *"AssistiveWare does not, and will never, provide medical advice. The Material is by no means intended to be a substitute for professional medical advice, diagnosis, or treatment."* — and **scope any "not a medical device" language to non-EU storefronts.** Note the category leader has **no emergency-reliance disclaimer**; nobody disclaims emergency failure specifically. **Never imply emergency-grade reliability.**

## 9.3 Symbols

**MVP: ship text-only.** It dodges the entire question, keeps the MVP two weeks, and keeps text-only first-class — which for many literate adults is what they actually want.

**When symbols ship, use [Mulberry](https://mulberrysymbols.org/)** — the only major set marketed on your exact thesis: *"Adult oriented symbols - most proprietary sets are designed for children."* But be honest about what's contested:

- **The license version is genuinely ambiguous upstream, not settled.** `LICENSE.txt` links to `by-sa/4.0/`; the **website and README** instruct attribution as **"CC BY-SA 2.0 UK: England & Wales"**; **GitHub's detector returns NOASSERTION**. Copyright may be **two** holders: *"2008-2017 Garry Paxton, 2018-2020 Steve Lee."* **Resolve with Steve Lee before shipping.**
- **Count**: ~**3,436** SVGs on master (release v3.5.2, Sept 2025). The widely-cited 3,116 is OpenSymbols' **stale index**. Maintained but lightly, by one person (last commit 2026-02-12) — despite openaac.org still labeling it "unmaintained."
- **Non-CC extra condition**: *"you may charge for your product or added value, but you must not charge for the symbols themselves"* — no symbol-pack IAP; a paid app containing them is fine.
- **ShareAlike does NOT reach your Dart code.** Unmodified symbols + proprietary code = a **collection / mere aggregation** (CC BY-SA 2.0 UK §§1.3/2.3; CC BY-SA 4.0 §3(b)). SA bites only if you **modify** a symbol. There is **no** obligation to publish a standalone restyled set or ship source SVGs — licensing the adapted symbols BY-SA **as distributed in the app** suffices.
- **[CORRECTED — the real legal risk is not code infection.]** It's the **anti-TPM/DRM clause vs Apple's FairPlay**, and it applies to **distributing the symbols at all**, not just adaptations — so it is **not** avoided by staying in mere-aggregation territory. **CC 4.0 largely defuses this; 2.0 UK does not.** That is precisely why the version question must be settled.
- **The cleanest path that dodges all of it:** ship symbols **unmodified** and do dark-theme adaptation **at runtime** (tint / `ColorFilter` / shader in Flutter), never to the shipped asset files. **Creates no Adapted Material at all**, and is the better engineering choice for a themable grid anyway.

**Do NOT use ARASAAC or Sclera in a monetized app.** [ARASAAC](https://aulaabierta.arasaac.org/en/terms-of-use) (12,909–15,560, CC BY-NC-SA) states plainly: *"The use of these resources within any product or publication for commercial purposes is therefore excluded from this permission."* Sclera (11,443) is CC BY-NC. CC defines NonCommercial as "primarily intended for or directed toward commercial advantage or **monetary compensation**" — which covers paid apps AND ad-supported apps.

**[CORRECTED, and it matters for a free app]**: ARASAAC **is** commercially licensable with **written authorization from the Government of Aragón**, so "categorically unusable" overstates it. And if this app is **free with a tip jar** (§10), ARASAAC is *arguably* fine as-is with attribution (authors/ARASAAC team, source Aula Abierta + URL, license type, Government of Aragón ownership, ARASAAC logo on derivatives) — **but a tip jar may read as "monetary compensation" under the NC definition. Ask. It costs an email**, and it's 4× the set.

**[CORRECTED — Blissymbolics is NOT royalty-blocked.]** The "royalty based license required for all commercial products" claim is **outdated 3.0-era text**. [BCI's current licensing page](https://www.blissymbolics.org/index.php/licensing) places the BCI-AV under **CC BY-SA 4.0**, explicitly usable *"in any project or product, commercial or otherwise"* with attribution, **no royalty**. 5,819 symbols. So the commercial-safe adult-capable set list is **Mulberry AND Blissymbolics**, not Mulberry alone. (Bliss is a constructed semantic language, so its fit for adult *phrase tiles* is a separate design question.)

**Other clean sets:** **OpenMoji** (CC BY-SA 4.0, ~3,540) is a **stronger Twemoji substitute** since `twitter/twemoji` is **archived**; Twemoji CC BY 4.0 (2,770); Tawasol CC BY-SA (950). **Avoid "mixed licenses" sets** (Noun Project 17,165, IcoMoon 907, IconArchive 600) — they require per-symbol clearance and are unsafe to bulk-ship.

**Proprietary, for completeness:** **PCS** (Tobii Dynavox) — **[CORRECTED]** pricing is partly public: Maker Free / **Maker Personal (USD $149)** / **Maker Business (custom)**. The applicable tier is Maker Business — a **negotiable commercial path**, not "fees not public." Still requires Boardmaker + a 10–15 business day review. **SymbolStix** (n2y/Everway) — proprietary, non-redistributable; **[CORRECTED]** ~**$250 CDN**/yr and it's an **org seat model** (one service-provider access + up to 15 student licenses), not "personal use only."

## 9.4 Voice licensing — the biggest legal correction in the corpus

**[CORRECTED — the researcher's headline claim is wrong for your platform.]**

The claim was: Apple's SLA §2.F bans recording/redistributing System Voices commercially, therefore pre-rendering and shipping TTS audio is prohibited.

**That is macOS-only.** The macOS Sequoia/Tahoe SLA §2.F ("Voices; Live Captions") does say it, verbatim, and binds **macOS end users**. But:
- **The iOS/iPadOS 26 SLA contains NO system-voice restriction.** Its parallel §2(f) defines "System Characters" as **Genmoji/Memoji**, and restricts only **Live Captions and Personal Voice**.
- **The Xcode and Apple SDKs Agreement mentions voice / speech / TTS ZERO times.**

**So there is no iOS SLA prohibition on pre-rendering AVSpeechSynthesizer output. The reason not to pre-render is engineering (§6.4), not legal.** The restriction applies only if you ship a **macOS** build.

**But: Personal Voice IS restricted commercially under the iOS SLA §2(f)** — and that sits in **direct, unresolved tension** with Apple's own [WWDC23-10033](https://developer.apple.com/videos/play/wwdc2023/10033/), which states *"usage of Personal Voice is sensitive and should be primarily used for augmentative or alternative communication apps"* and **literally demos an AAC app**, and with [Ben Dodson's implementation writeup](https://bendodson.com/weblog/2024/04/03/using-your-personal-voice-in-an-ios-app/) reporting **no entitlement and no Info.plist key required**.

**This is a genuine contradiction between the SLA text and Apple's developer guidance. Do not treat it as settled. If you build Personal Voice support, ask App Review before you invest.**

**Piper: the license changed** — see §6.5. `rhasspy/piper` (MIT) archived 2025-10-06; successor is **GPL-3.0**, effectively App-Store-incompatible for a proprietary app. **Kokoro-82M is Apache-2.0** with no commercial restrictions.

## 9.5 Icons & fonts

- **SF Symbols: unusable.** Licensed as "system-provided images as defined in the Xcode and Apple SDKs license agreements" — the license contemplates use **on Apple platforms via the system**, so shipping them in an Android build is out. Also barred from app icons/logos/trademark use; Apple-technology glyphs (iCloud, AirPlay, FaceTime) are reserved.
- **Apple system fonts: unusable in the Android build.** macOS SLA §2.E: *"you may use the fonts included with the Apple Software to display and print content while running the Apple Software; however, you may only embed fonts in content if that is permitted by the embedding restrictions accompanying the font."*
- **Use:** Material Symbols (Apache 2.0) and **SIL OFL** fonts (Inter, **Atkinson Hyperlegible**, Lexend, Noto). OFL permits bundling in commercial software; the only real constraints are you can't sell the font alone and Reserved Font Names can't be reused on modified versions. Platform-native emoji rendered **as text** are fine (you're not redistributing the font).

## 9.6 Store rules & privacy

- **A local-only free-text field is NOT UGC.** Apple 1.2's obligations (filter objectionable material "from being posted to the app," reporting mechanism, block abusive users, published contact info) all presuppose content **being posted / reaching another user**. Nothing in a type-to-speak box leaves the device — no moderation surface, no counterparty to block. Same logic for IARC/Play content rating (asks whether users can share UGC, interact, or message — all **no**). Expect **4+ / Everyone**. **This flips the moment you add board sharing, cloud sync, or import-from-URL.**
- **Do NOT enroll in Apple's Kids Category.** Extra restrictions, and it pushes exactly the infantilizing framing the product exists to reject. In Play, declare the app is **not primarily child-directed** to stay out of the Families program.
- **COPPA: not triggered.** It attaches to **collection** of personal information. You collect none — even if a 12-year-old uses it.
- **"No data" ≠ "no paperwork."** [Google Play](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en): *"Even developers with apps that do not collect any user data must complete the Data Safety form and provide a link to their privacy policy."* Apple requires App Privacy details for every submission, plus — per guideline **5.1.1(i)** — a privacy policy link **in App Store Connect metadata AND in the app**. Privacy manifests required for the app and third-party SDKs. **These are submission blockers.** Upside: your policy is three honest paragraphs and is the strongest marketing page you have.
- **Store copy: describe function, not medical benefit.** *"Tap a tile or type; your phone speaks it aloud or shows it in large type. Offline. No account."* Avoid "treats," "improves language outcomes," "clinically proven." **Use the literature's own terms — "part-time AAC," "unreliable speech," "intermittent speech"** — because they are what the audience searches AND a credibility signal to SLPs. **Honest limit: in the EU this framing does not save you**, because compensation for a disability IS the medical purpose.

## 9.7 Accessibility law

- **No US law compels WCAG for a private app.** The [DOJ 2024 web/mobile rule](https://www.ada.gov/resources/2024-03-08-web-rule/) (WCAG 2.1 AA) binds **Title II** (state/local government) only, and DOJ **extended those compliance dates again in April 2026**. ADA Title III reaches private public accommodations and courts have applied it to apps, but there is **no adopted technical standard** — exposure is litigation risk, not a checklist. Section 508 binds **federal procurement**.
- **[CORRECTED] The EAA almost certainly does NOT apply.** Contrary to the "EAA applies to all apps from June 2025" framing, Directive (EU) 2019/882 Art. 2 is a **closed list**: consumer general-purpose computer hardware and their OSes, self-service terminals, consumer terminal equipment for e-comms and AV media, e-readers; and services: e-comms, AV media access, transport, banking, e-books, e-commerce. **A third-party AAC app is not an OS and not on the services list.** "E-commerce services" (Art. 3(30)) is **cumulative** and requires *"with a view to concluding a consumer contract"* — selling via Apple/Google IAP makes **the store** the e-commerce service, not your app. Belt and braces: the **microenterprise exemption** (<10 employees AND ≤€2m turnover/balance sheet) exempts services anyway.
- **A VPAT is voluntary but a commercial door-opener.** AAC is bought by school districts, state voc-rehab agencies, and hospitals — all Title II/508-adjacent buyers who ask for a VPAT before purchase. And, on brand: **an inaccessible accessibility app is a credibility failure with this specific audience.**

---

# 10. Business model

## The recommendation

**Free. The speaking surface is never gated. Optional tip ($5–20). Never a subscription.**

## Reasoning, with the corrections

**What's true:**
- 10/12 discussed affordability; **5 avoided full-price apps; 4 gravitate to free**.
- The premium anchor is real: Proloquo2Go $249.99, CoughDrop $295 lifetime, Spoken $249.99 lifetime, TouchChat/LAMP $299.99. A tip against that anchor reads as **generosity**, not cheapness.
- Speaking is a **disability accommodation**. Gating it during a shutdown is the failure mode the product exists to prevent.
- The low end is **$0, not $24.99**. **[CORRECTED]**: LetMeTalk (free, iOS+Android, offline, 9,000+ ARASAAC symbols, no upgrade limits), Cboard (free, open source, UNICEF-backed), AsTeRICS Grid (free, AGPL, PWA), Spoken's free tier, CoughDrop free modeling accounts, iOS Live Speech, Speech Assistant's free Android tier. **A $15–30 one-time price competes against $0, not against $249** — so the anchor argument does not by itself justify a price.

**[CORRECTED — "monetization is hopeless" is REFUTED, and the reasoning behind it was wrong.]**
- The employment argument doesn't hold: the **14–16% / 85%** figures describe autistic adults using **state DD services** (~111,000 of ~5.4M US autistic adults) — **nearly the opposite subgroup** from a literate, late-diagnosed, part-time-AAC user. Peer-reviewed unemployment estimates for autistic adults generally run **~40%**.
- Direct comparables **are paid**: Speech Assistant $24.99 one-time; Spoken $12.99/mo, $99/yr, $249 lifetime; Proloquo free download + $9.99/mo or $99.99/yr. Only Emergency Chat and Live Speech are truly free, and **neither does the core job** — Emergency Chat has **no TTS at all**; Live Speech is iOS-only with no tile grid.
- The n=12 study documents resentment of **$40 voice ADD-ONS on top of a purchased app** — resentment of **nickel-and-diming**, which argues for **one honest price**, not for free.

**[CORRECTED — the "subscriptions disqualify you from state funding" claim rests on one anonymous App Store review from Sept 2023.]** No state/Medicaid policy document establishing a categorical exclusion exists. What **is** corroborated by two independent vendors: auto-renewing billing creates real friction with agency procurement, and **prepaid multi-year licenses resolve it** (AssistiveWare sells 1–5 year non-auto-renewing licenses precisely for this). But the agency channel is mostly irrelevant to a self-purchasing adult with no SLP gatekeeper. **The stronger arguments against subscription for THIS product**: audience fit, and that **recurring billing implies entitlement checks, which conflict with "zero login, works in an ER with no signal."**

**[CORRECTED — the Proloquo 4.0-vs-4.8 rating gap is confounded and should not be used as evidence.]** A $249.99 paid app is rated only by people who already committed $249.99; a free-download app is rated by everyone who bounces off the paywall. Plus large product differences (Proloquo's locked base vocabulary + single 48-button grid vs Proloquo2Go's 23 grid sizes and full editability). And **Proloquo won the 2023 App Store Award for Cultural Impact — the first AAC app ever.** Also: Proloquo launched **December 2021**, not 2023, and AssistiveWare has **not** "moved to subscription" — it runs both in parallel and Proloquo2Go is not slated for discontinuation.

**[CORRECTED — insurance is REFUTED, not "structurally closed."]** [CMS removed the "dedicated device" requirement effective 07/29/2015](https://www.cms.gov/medicare-coverage-database/view/ncacal-decision-memo.aspx?proposed=N&ncaid=8) (NCD 50.1 v2): *"not necessary for the device to be dedicated only to audible/verbal speech output to be considered DME."* **HCPCS E2511** covers "speech generating software program" enabling "a laptop computer, desktop computer, **tablet, smartphone** or other hand-held general computing device to generate speech"; the phone itself is A9270 (non-covered) — **the exact inverse** of the claim. Active 2026 E2511 payer rates run ~$55–219; Proloquo2Go is Medicaid-funded today via bundled locked-down devices. **The channel is not legally closed — it is clinically gatekept and vendor-mediated** (SLP evaluation, physician prescription, documented severe expressive impairment per LCD L33739, DMEPOS supplier enrollment, face-to-face/written-order rules, modifiers, and typically a hardware bundler taking the reimbursement). A poor fit for a no-account, instant, cash, DTC app — and the medical-necessity bar may disfavor **situational** loss (plausible, unadjudicated). **Log E2511 as a possible future B2B/clinical channel; stop saying "structurally excluded."**

**[CORRECTED — do NOT open-source as a trust lever.]** The corpus's own fact-check demolishes this argument: (a) the study **never recommends open source** — its actual design implications are opt-in-by-default, transparent disclosure, and visualizing data practices; (b) the privacy promise is **not "otherwise unfalsifiable"** — no INTERNET permission is an **OS-enforced, pre-install-visible** guarantee **stronger** than publishing source (source cannot prove the shipped binary matches); (c) **the CoughDrop precedent reverses** — CoughDrop **stopped open-source releases in March 2023** on acquisition by Forbes AAC and no longer markets itself as open source; the surviving `open-aac/sweet-suite-aac` fork is a low-activity community project. **It is a cautionary precedent, not a supporting one.** Note also: **iOS offers no equivalent OS-enforced network guarantee.**
> **Counter-argument worth naming: open-sourcing IS the exit plan (risk #7).** If you're building app #N of 50, publishing the source is how the app survives you. That is an **ethical** reason, not a trust-lever reason. Don't conflate them.

## Mechanics

- **Enroll in [Apple's Small Business Program](https://developer.apple.com/app-store/small-business-program/) and Google's equivalent on day one.** 15% vs 30% is available to a new developer with **no earnings history** — but **enrollment is not automatic**; you must sign up and declare Associated Developer Accounts. Free money otherwise left on the table. At this scale 15% is effectively permanent.
- **English-only. OS-native TTS.** Proloquo2Go leads the market at $249.99 shipping only English, Spanish, French, Dutch. Native TTS inherits the platform's languages and voices for free — the app is effectively language-agnostic without per-language investment. **Localization is not an MVP gate**, and per-language rule-data cold-start risk (§6.4) argues for English-first anyway.
- **Channels: clinician + directory first, not peer subreddits.** [Aphasia Software Finder](https://www.aphasiasoftwarefinder.org/speech-assistant-aac), [JAN (askjan.org)](https://askjan.org/products/Speech-Assistant-AAC.cfm), BridgingApps, [PrAACtical AAC](https://praacticalaac.org/), National Aphasia Association, Towson's SLP guide, and **[state AT Act programs](https://acl.gov/programs/assistive-technology/assistive-technology)** — every US state runs one, mandated to provide short-term device loans, device **demonstration**, training, and public awareness ([directory: catada.info/state.html](https://catada.info/state.html)). Free, durable, searchable, high-trust, and they compound over years. **Speech Assistant — a tiny Dutch indie app — appears across all of them.**
- **Reddit rules were NOT verified.** Three dimensions independently report Reddit was unfetchable; searches returned only third-party SEO content. **Nobody knows what the rules say.** Open the About/Rules tabs manually. **Message mods first; never post cold to r/autism.** r/AAC is the most topically appropriate venue. A ban in the community you're serving is unrecoverable.
- **Grant (post-launch, and verify first):** [NIDILRR/ACL SBIR](https://acl.gov/programs/research-and-development/small-business-innovation-research-program) — Phase I up to **$100,000** / ~6 months / ~10 awards a year; Phase II up to **$575,000** / 24 months. Eligibility: American-owned, independently operated, for-profit, ≤500 employees, PI employed by the business — **a solo dev with an LLC plausibly qualifies**. Find via Grants.gov opportunity number `*BISA*` (Phase I) / `*BISB*` (Phase II), asterisks included. **CAVEAT: NIH announced early expiration of SBIR/STTR funding opportunities ([NOT-OD-26-006](https://grants.nih.gov/grants/guide/notice-files/NOT-OD-26-006.html))** — federal AT funding is unsettled. Verify before investing weeks. Grant writing is a months-long distraction from shipping.

## Honest expectation: **we do not know.**

The two market-size numbers in the corpus differ **~100×** and were **never reconciled**:
- `business-model`: ~102 iOS ratings → 5–10k lifetime iOS users → "three figures annually, build it as a portfolio project."
- `competitive` fact-check: **~810k Android downloads, 4.44/5, last updated May 2026.**

Both were reported by the same corpus. Nobody noticed. **If 810k is right, the "portfolio project" conclusion collapses.** Do not plan on either number (§12.1).

**Plan for three figures a year. Be pleasantly surprised. Build it because it should exist** — and because the offline/no-account architecture means **it keeps working if you stop maintaining it**. That is a real ethical answer to a real risk, and it is the one honest reason a 50-app-challenge project is defensible in a category where abandonment costs someone their voice.

---

# 11. Build order

## Phase 0 — de-risking (one week, ~$25, zero shippable code)

Ordered by cost ascending × kill-power descending. **Do not skip 0.1.**

| | Experiment | Cost | Kill / pivot criterion |
|---|---|---|---|
| **0.1** | **Install and use the incumbents.** Speech Assistant AAC (iOS $24.99), Spoken (free tier), iOS Live Speech (Settings > Accessibility > Live Speech; triple-click side button). Use each through a real low-capacity moment if you can. | **$24.99, 90 min** | **KILL: if Speech Assistant + Live Speech are adequate, file an issue with ASoft or contribute, and build something else.** This is the highest-value hour available and **nobody in the research corpus spent it.** |
| **0.2** | **Ask 20 people three questions.** Via r/AAC (**message mods first**), an AAC Discord/Facebook group, or paid participants. (a) *"Last time you needed AAC, was your phone already unlocked and in your hand, or in your pocket?"* (b) *"When you use AAC in public, do you make it speak, or do you show the screen?"* (c) *"You've tried Speech Assistant / Live Speech / Spoken — what specifically made you stop?"* | **free** | (a) kills the entire widget/Control/QS-tile architecture if "already in hand." (b) kills TTS-first if "show." (c) **KILL: if the answers to (c) are vague or aesthetic, the demand is not there.** Phrase it so it can come back **no**. |
| **0.3** | **TTS quality probe.** Throwaway Flutter app: `flutter_tts`, list voices with quality/latency/network_required, speak 10 real phrases. On **(a) a $120–150 Android** — not "mid-range"; 10/12 are cost-constrained and that's where they are — and **(b) an iPhone with only the default compact voice.** Blind A/B vs Speech Assistant with 5 people from 0.2. | **1 day** | **KILL: if you can't match Speech Assistant's output, the project does not proceed as specified.** You're then either bundling sherpa_onnx/Kokoro (+55MB, battery, thermal) or building message-banking-first. Both are **different products**. |
| **0.4** | **Latency probe.** Same throwaway app. Stopwatch `speak()` → `didStart` on a real device — cold process and warm — on current iOS and current Android. | **½ day** | **Settles the pre-render question**, which is currently **three contradictory positions in the research with zero measurement behind any of them.** If the delay is real, try in order: singleton synthesizer → pre-activate audio session at launch → silent warm-up utterance. (flutter_tts has no warm-up API; this may need a platform channel.) |
| **0.5** | **Airplane-mode probe.** Does iOS **Live Speech** actually work offline? Apple **never documents it.** Does Speech Assistant? Does your probe, with the Android voice filter on? | **30 min** | Offline parity is your core premise. **Verify it rather than asserting it.** |
| **0.6** | **Switch Control / VoiceOver / TalkBack spike.** 12-tile grid, `Semantics` on every tile. Turn on iOS **Switch Control** (item scanning + point scanning), **VoiceOver**, and Android **TalkBack + Switch Access** on real devices. Traverse and activate every tile. | **½ day** | Flutter publishes **no** Switch Control support statement (chunhtai says it exists; there is no doc). Cheap now, catastrophic at month six. |
| **0.7** | **Name your positionality, and email Pheonix.** [Flutterkeys](https://github.com/earth-pheonix/Flutterkeys) is a Flutter AAC app being built by a **nonspeaking AAC user** — a symbol/typing hybrid, free, open-source voices — and is **actively seeking a nonprofit partner for beta testing and release support.** Read [Blasko et al. 2025](https://doi.org/10.1080/07434618.2025.2514748). | **1 hour** | **PIVOT: collaborating may be strictly better than competing** — and it is a move the entire research corpus never surfaced because it only looked at app stores. If you are not an AAC user, either recruit and **pay** an advisory group, or say plainly in the listing who built this and why. |

## Phase 1 — the two-week Android MVP (only if Phase 0 doesn't kill it)

| | Milestone |
|---|---|
| M1.1 | drift schema (boards / buttons / **grid_slots** / settings), OBF `label` ≠ `vocalization` split, migration test harness with generated schema snapshots |
| M1.2 | **Speak screen** — 3×4 fixed grid, type-to-speak on the same surface, STOP + Repair pinned, no navigation. `Semantics` on every node. `TextScaler` honored. Zero animation. |
| M1.3 | **SpeechService** — flutter_tts, Android voice filter + `setVoice` return check, `<queries>` TTS_SERVICE, iOS `.playback` + `duckOthers` + `setSharedInstance` |
| M1.4 | **Show screen** — brightness override + restore, huge type, one message, pinned |
| M1.5 | **Edit mode** — explicit toggle, tap-to-edit-text, move up/down (no drag), hide-don't-delete |
| M1.6 | **Settings** — voice, pitch, rate, output mode, theme (dark/light/high-contrast, **one tap from main**), haptics, grid size |
| M1.7 | **Starter sets with visible provenance** — who wrote them, why. Skippable in one tap. |
| M1.8 | **File export/import** via share sheet. `allowBackup="false"` (or empty `<cloud-backup>` + permissive `<device-transfer>`). |
| M1.9 | **Ship it to the 20 people from Phase 0. NOT the store.** Then decide what's next **from what they say, not from this document.** |

## Phase 2 — v1 (order set by Phase 1 feedback)

Message banking (recording > TTS precedence) · one level of categories · post-crisis phrase capture (pull-only, **never a notification**) · printable/wallet-card PDF · manual low-stimulus mode · **Android QS tile — only if 0.2 validated the launch barrier** · symbols (Mulberry, **runtime-tinted**, license resolved with Steve Lee first; text-only stays first-class) · `.obz` export · on-device crash log · low-EF editor (dictation authoring).

## Phase 3 — iOS (only if there's a reason)

**The reason is not "cross-platform."** The reason is: someone in Phase 1/2 said the tile grid matters to them and they're on iPhone. On iOS you compete with **free preinstalled Live Speech with icon categories**, **Proloquo4Text at $119.99**, and **Personal Voice**.
- Personal Voice platform channel (~1 method) — **ask App Review about the SLA §2(f) vs WWDC23-10033 contradiction first** (§9.4).
- iOS 18 **Control** (`ControlWidget` + `AudioPlaybackIntent`, `authenticationPolicy = .alwaysAllowed`) — Swift, App Group, **no Flutter on the speak path**.

## Never

EU launch without a budgeted MDR decision · Watch/Wear before the speaker-loudness test · LLM generation · content filtering · cloud sync/board sharing · a caregiver account.

---

# 12. Open questions

Explicitly: **these are things we do not know**, not things to hand-wave.

**12.1 — Market size is unknown, and the corpus contradicts itself ~100×.**
`business-model`: ~102 iOS ratings → 5–10k lifetime users → three figures/year. `competitive` fact-check: **~810k Android downloads, 4.44/5, updated May 2026.** Never reconciled by anyone. → **Find out:** Play Console similar-app data, Sensor Tower/Appfigures free tier, or **just email ASoft (Ton Schalke)** — a solo dev in a tiny niche may well tell you.

**12.2 — Is the app-launch barrier real?**
`user-needs` states it plainly: **no direct testimony exists.** The inference chain (motor freeze + decision paralysis + app-switching overhead) is sound but unvalidated, and Reddit — where the testimony would live — was unfetchable for every researcher. → **Ask 20 people (0.2).** Note the counter-hypotheses nobody tested: *"the phone is already unlocked and in hand"* and *"someone else opens it for me."* And note the pre-shutdown-workflow hypothesis is undercut by its own evidence: ***"The ability to notice I'm shutting down, shuts down too."***

**12.3 — Does reading degrade during shutdown?**
**The corpus's own fact-check: no source supports it.** Receptive **auditory** language failing is documented (*"other people's speech around you can stop making sense"*); **reading is an unsupported extrapolation.** Motor immobilization and decision-making impairment **are** well documented ([Paris et al. 2025, *Autism in Adulthood*](https://journals.sagepub.com/doi/10.1089/aut.2024.0193)). **This is the load-bearing justification for symbols-on-every-tile**, and it does not hold. Note also **[CORRECTED]**: no source frames shutdown as a **depth spectrum** — the paper reports six qualitatively distinct metaphors, not a severity gradient; "both are true at different depths" was the researcher's own reconciliation, not a finding. And the five verbatim quotes are **paywalled and unverified**. → **Ask: "During a shutdown, can you read? Can you read a short phrase on a tile?"** It is answerable and **nobody asked it.**

**12.4 — What are the actual phrases? This is the product's core IP and it cannot be sourced from literature.**
`user-needs` says it outright: **a validated adult phrase list does NOT exist in public sources.** 10/12 pre-program phrases but the paper **explicitly does not enumerate them.** The only directly attested one-tap messages anywhere: ***"too loud," "I need a break," "I want to go."*** Others implied: *"I can talk, but only sometimes"; "I can't tell you what I need."* **Building this from assumption is the highest-risk shortcut available in this project.** → Ask the community directly. **Pay them.** Tag provenance on every starter phrase.

**12.5 — Do users want it to speak, or to show?**
8/12 display instead of/alongside TTS — **but that is the same twelve people**, and showing text also fails (small screens, sun glare, impossible with groups, security concerns on handover). **Do not over-read the "no stigma against writing" line** — it is the authors' hedged speculation about **one** handwriting-using participant. → Ask (0.2).

**12.6 — Motor precision during shutdown is unmeasured.**
Best evidence ([PMC11148429](https://pmc.ncbi.nlm.nih.gov/articles/PMC11148429/)) is **97 autistic YOUTH aged 8–17**, correlational, and says nothing about shutdown. The **76dp figure's fact-check FAILED to verify.** → Not ethically measurable at your scale. **Design conservatively and say so** rather than citing a standard you don't have.

**12.7 — Does iOS Live Speech actually work offline?**
**Apple never documents it.** The corpus asserts it. → **Airplane-mode test (0.5).** 30 minutes, and it's load-bearing.

**12.8 — Does TTS audio actually play from a background App Intent on a locked device?**
Depends on AVAudioSession config + the background-audio entitlement. **No primary source settles it.** → Prototype before committing to the Control path.

**12.9 — What license is Mulberry actually under?**
LICENSE.txt vs website vs README disagree; GitHub returns NOASSERTION; copyright may be one holder or two (Garry Paxton 2008–2017 + Steve Lee 2018–2020). → **Email Steve Lee.** This gates the **anti-TPM/FairPlay** question, which is the real risk — not code infection.

**12.10 — Is Personal Voice usable by a commercial third-party AAC app?**
WWDC23-10033 says AAC is the intended use case and **demos an AAC app**; the iOS 26 SLA §2(f) restricts Personal Voice commercially. **A genuine, unresolved contradiction.** → Ask App Review **before** investing.

**12.11 — What do the subreddit rules actually say?**
**Three dimensions independently failed to fetch Reddit**; searches returned only third-party SEO content. **Nobody knows.** → Open the About/Rules tabs manually. **A ban in the community you're serving is unrecoverable.**

**12.12 — How do you test a crisis path you cannot ethically induce?**
**The central research-design problem of this product, and it is absent from all ten research dimensions.** → Proxies: simulate with a countdown + a distraction task; recruit people to use it in low-capacity states they *can* predict (post-social, post-commute, end of a bad day); post-crisis retrospective capture (which is also a feature, §3.2). **No good answer exists. Say so rather than pretending.**

**12.13 — Does "adult, not infantilizing" positioning alienate the SLP channel** that `business-model` calls the highest-leverage reach path? The user quotes are *"In my experience, speech therapists were not helpful"*, and word-frequency tracking reads to participants as **SLP surveillance**. **Nobody asked whether the copy that wins the community loses the referrers.** → Ask two SLPs.

**12.14 — Is a PWA actually wrong for this?**
**AsTeRICS Grid — the most mature free offline AAC in existence — is a PWA.** Only *Flutter's* web accessibility was refuted; the general claim was never tested. → If reach ever matters, this is worth an hour before assuming.

**12.15 — What's the exit plan?**
Users build dependence on a **disability accommodation**. **Unresponsive support is a named abandonment cause in this exact population.** → **Decide before launch and say it in the listing**: open-source it? transfer it? sunset notice? *"It keeps working offline if I disappear"* is true, and worth stating — **but it is not a plan.**

---

## The one-paragraph version

`idea.md` says "Confidence: High" and "no one has built this." Both are wrong: Speech Assistant AAC has shipped the described MVP — offline, no account, adult-marketed, phrase tiles + type-to-speak, both platforms, one-handed placement included — for a decade at $24.99, and iOS Live Speech has done the type-to-speak half free and preinstalled since 2023. The evidence base under every "validated" claim is a single n=12 self-selected unrefereed preprint. Infantilization is the fifth-ranked complaint, not the first; "offline" was never validated (privacy was) and isn't provable the way you think; and 8 of 12 users show text rather than speaking it. What survives is narrow and real: **nobody designs for episodic loss in someone who spoke ten minutes ago, Android has no built-in type-to-speak, nobody serves the nonbinary/middle-pitch voice need, and nobody treats show-text or social repair as first-class.** That is a two-week, Android-only, one-screen app — **after** you spend $25 and two hours proving the incumbents aren't already enough, one day proving stock TTS is acceptable, and one free conversation proving the launch barrier exists at all. If any of those come back the wrong way, the honest answer is to contribute to ASoft, or to email the nonspeaking AAC user who is already building this in Flutter and asking for a partner.