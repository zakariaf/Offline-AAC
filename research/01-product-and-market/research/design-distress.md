# design-distress

> Phase: **research** · Agent `af3364ef25e592c67` · Run `wf_3a8e3c64-43a`

## Result

## Summary

The research supports a coherent design position, but it overturns three assumptions worth checking before you build. First, the misfire problem is already solved by serious AAC and the solution is NOT confirmation dialogs — AssistiveWare's Proloquo2Go uses adjustable Hold Duration (dwell up to 5.0s), Repeat Delay, and a persistent "Stop Speaking" button. Prevention via dwell, recovery via instant stop, zero added decisions. Second, the Fitzgerald Key should probably be dropped: it is a 1949/1973-era grammar-construction scaffold for emerging language learners building sentences word-by-word, and its saturated primary palette is simultaneously the main thing that reads "childish" AND exactly what autistic sensory guidance says to avoid (muted tones, max ~3 colors). Your literate adults tap whole phrases; they aren't constructing grammar, so the Key buys nothing and costs dignity. Third, dark mode is genuinely contested — Piepenbrock et al. found positive polarity (dark-on-light) read faster, and halation affects roughly 30-50% of adults with astigmatism — yet distressed users consistently prefer dark. Resolution: dark default (#121212, never pure black, per Material — OLED smear + halation + no elevation range), light and high-contrast themes mandatory, never a locked-in aesthetic. Dyslexia fonts have no evidentiary support and should not be used; the real levers are size, weight, spacing, and contrast. The single highest-leverage rule found: never dynamically reorder tiles, because position-based muscle memory is the only retrieval channel that survives a shutdown.

### Serious AAC apps prevent misfires with dwell time and repeat-delay, not confirmation dialogs, and pair this with a persistent Stop Speaking control

*Confidence: high, **LOAD-BEARING***

Proloquo2Go's Access Method Options expose 'Hold Duration' — a minimum press time before a button activates, settable up to 5.0 seconds, explicitly documented as helpful for users with hand tremors who brush buttons accidentally. 'Repeat Delay' ignores taps within a set window after the last tap; with 'Allow Repeat' OFF, the same button cannot re-fire until another is selected. Separately, button actions include 'Stop Speaking' (halts the current utterance) and 'Clear Message'. This resolves the big-target-vs-misfire tension in the brief: error TOLERANCE (instant recovery) rather than error PREVENTION (confirmation), because a confirmation dialog doubles the decision count in exactly the moment decision capacity is lowest.

- https://www.assistiveware.com/support/proloquo2go/alternative-access/access-method

- https://www.assistiveware.com/support/proloquo2go/alternative-access/repeated-taps

- https://www.assistiveware.com/support/proloquo2go/organize/buttons/buttons-actions

### The Fitzgerald Key is a grammar-construction scaffold from 1949/1973 whose purpose does not apply to literate adults tapping whole phrases

*Confidence: medium, **LOAD-BEARING***

The Fitzgerald Key was developed in the 1920s to teach deaf students grammatically correct sentence structure; the color-coding layer is McDonald & Schultz's 1973 modification of Fitzgerald (1949). Its function is to help a user LOCATE a part of speech while assembling a sentence word-by-word. Evidence cited is generic ('colour can have a positive effect on ability to work with an AAC system') rather than specific to adults or to phrase-level AAC. Its standard palette (orange nouns, green verbs, yellow pronouns, blue adjectives, pink social) is high-saturation primary color — precisely the 'primary colors' pattern autistic adults name as infantilizing, and precisely what autistic sensory design guidance warns against. For a phrase-tile MVP the Key delivers no grammatical benefit while importing the childish signal.

- https://www.communicationcommunity.com/fitzgerald-key-for-aac/

- https://praacticalaac.org/strategy/communication-boards-colorful-considerations/

- https://www.heyasd.com/blogs/autism/autism-puzzle-piece-controversy

### Dark mode is preferred by distressed users but measurably degrades reading for the general population and causes halation for a large minority of astigmatics

*Confidence: high, **LOAD-BEARING***

Piepenbrock et al. (Ergonomics, 2013) found faster, more accurate reading in positive polarity (dark text on light) vs negative polarity; reported reading-speed drops of up to 26% in negative polarity for normally-sighted users. Dark backgrounds dilate the pupil, which amplifies optical aberration; white-on-black text appears to bleed/halo for roughly 30-50% of adults with astigmatism, with moderate-to-high astigmatism most affected. A 2024 arXiv study found no significant polarity difference in daytime conditions but light mode outperforming dark at night, especially at small font sizes. Meanwhile distressed users in mental-health app research explicitly prefer 'dark palettes, sleek and sophisticated looks' and reject interfaces that are 'too bright, too happy, and too overwhelming'. These are not reconcilable by picking one — they require a user choice.

- https://www.boia.org/blog/dark-mode-can-improve-text-readability-but-not-for-everyone

- https://arxiv.org/pdf/2409.10841

- https://stephaniewalter.design/blog/dark-mode-accessibility-myth-debunked/

- https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/

### Dark theme backgrounds must be dark gray (#121212), not pure black, for three independent reasons

*Confidence: high, **LOAD-BEARING***

Material Design specifies #121212 as the dark-theme baseline. (1) OLED black smear: #000000 pixels are physically off and lag when waking during scroll, producing ghosting. (2) Halation: maximum white-on-pure-black contrast triggers the astigmatic bleed effect and forces wider iris aperture. (3) Elevation: you cannot cast a shadow on #000000; the #121212 baseline permits an elevation ramp (level 1 = #1E1E1E, level 2 = #242424) that pure black collapses. Corollary: also do not use pure white text — cap contrast rather than maximize it.

- https://m3.material.io/blog/android-dark-theme-tutorial

- https://www.codeformatter.in/blog-dark-mode.html

### Dyslexia-specific fonts have no evidentiary support and one study found OpenDyslexic actively reduced reading speed and accuracy

*Confidence: high, **LOAD-BEARING***

A 2017 study (Annals of Dyslexia / PMC5629233) using an alternating-treatment design found no improvement in reading rate or accuracy for individual students with dyslexia or the group as a whole using OpenDyslexic, and no participant preferred reading material in it; the font reduced speed and accuracy. A separate study found the Dyslexie font does not benefit reading in children with or without dyslexia. A 2020 systematic review of several dyslexia fonts concluded there is 'currently no evidence that these fonts lead to improved reading performance.' The reliable typographic levers are size, weight, line spacing, and contrast — not letterform gimmickry. This is also a dignity win: OpenDyslexic's weighted-bottom letterforms visually signal 'special needs product.'

- https://pmc.ncbi.nlm.nih.gov/articles/PMC5629233/

- https://link.springer.com/article/10.1007/s11881-017-0154-6

- https://www.nessy.com/en-us/dyslexia-explained/understanding-dyslexia/dyslexia-fonts-do-they-work

### WCAG 2.2 AA floor is 24x24 CSS px; AAA is 44x44 with no spacing escape hatch; platform guidance is 44pt (Apple) / 48dp (Material); impaired-context guidance goes to 76dp

*Confidence: high, **LOAD-BEARING***

WCAG 2.2 SC 2.5.8 Target Size (Minimum, AA, Oct 2023) requires 24x24 CSS px OR 24px spacing between small targets, with five exceptions. SC 2.5.5 Target Size (Enhanced, AAA) requires 44x44 CSS px and offers no spacing exception. Apple HIG: 44x44pt default minimum. Material: 48x48dp, with Google explicitly stating it prefers the larger figure to 'accommodate a larger spectrum of users.' Critically, Google's Design for Driving guidance — the closest analogue to a distracted/impaired-attention context — recommends a 76dp x 76dp minimum. Research cited indicates smaller interactive elements produce 25%+ tap error rates, disproportionately affecting motor-impaired users. 76dp is the right floor for this app; the phrase grid should far exceed it.

- https://www.w3.org/WAI/WCAG21/Understanding/target-size.html

- https://wcag22aa.org/new-criteria/target-size/

- https://blog.logrocket.com/ux-design/all-accessible-touch-target-sizes/

- https://developer.apple.com/design/human-interface-guidelines/accessibility

### Roughly half of phone use is one-handed and thumb reach on modern large phones excludes the top of the screen entirely for small/medium hands

*Confidence: high, **LOAD-BEARING***

Hoober's foundational research: ~75% of users interact primarily with thumbs, ~49% operate one-handed. Screens divide into an easy zone (bottom third), stretch zone (middle third), and hard zone (top third requiring grip repositioning). Heat-map analysis found that for large-hand groups the comfortable thumb zone covered >50% of the screen, but for small and medium hand groups only ~30% — across device sizes. With 6.7-6.8in devices (iPhone Pro Max, Galaxy S Ultra) now standard, the top zone is 'practically inaccessible' one-handed for smaller hands. Peer-reviewed backing: Yonsei study on natural thumb zone effects of thumb length and screen size. Consequence for AAC: the conventional top-left-first reading-order grid puts the highest-value tiles in the least reachable region.

- https://www.smashingmagazine.com/2016/09/the-thumb-zone-designing-for-mobile-users/

- https://link.springer.com/chapter/10.1007/978-3-319-96071-5_50

- https://parachutedesign.ca/blog/thumb-zone-ux/

- https://www.lukew.com/ff/entry.asp?1927=

### The thumb arc is mirrored by handedness, so a fixed layout is wrong for half of users

*Confidence: medium, **LOAD-BEARING***

Thumb-zone heat maps are asymmetric — the comfortable arc sweeps from the bottom corner on the holding-hand side. A right-handed one-handed grip makes the bottom-right the easiest region and the top-left the hardest; left-handed grip mirrors this exactly. This is not covered by generic accessibility settings and no mainstream AAC app surfaces it as a first-class option. A left/right handedness toggle that mirrors tile priority ordering is a cheap, differentiating accommodation.

- https://www.smashingmagazine.com/2016/09/the-thumb-zone-designing-for-mobile-users/

- https://timgraf.com/ux-design/designing-for-the-thumb-zone-a-modern-guide-to-mobile-ux-that-respects-human-anatomy/

### Crisis/panic UX guidance converges on: few obvious actions, no browsing, linear flows, no dense dashboards, and state-preserving exits

*Confidence: high, **LOAD-BEARING***

Smashing Magazine (July 2026) on designing for distressed users: panic tools should offer 'a small number of obvious actions, rather than asking the user to browse'; a clear panic entry point lowers cognitive load; avoid visually rich home screens and complex trend-driven UI in acute states; prefer linear flows over comprehensive dashboards; 'exit affordances that preserve state benefit every user in a hurry'; avoid 'bright alerts or sudden animations'; every gesture needs 'a visible button fallback'; error tolerance modeled as 'streaks should not reset when a user misses a day.' Trauma-informed design literature adds: predictable navigation and consistent interaction regulate the nervous system, while jarring visuals and fear-inducing/blame-based language trigger fight-or-flight in sensitized users.

- https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/

- https://uxmag.com/articles/trauma-informed-design-understanding-trauma-and-healing

- https://uxcontent.com/a-guide-to-trauma-informed-content-design/

### Autistic-specific design guidance calls for muted low-saturation palettes capped at ~3 colors, which conflicts directly with standard AAC color-coding

*Confidence: medium, **LOAD-BEARING***

Guidance converges on: avoid bright, highly saturated colors and clashing combinations that overstimulate; use soft, mild, muted tones in a neutral palette; cap at roughly three colors to prevent sensory overload; but maintain clear text/background contrast and a defined visual hierarchy. Distressed-user research independently lands on 'muted, earthy tones — neutral hues like soft greens and taupes — set against darker, calming backgrounds.' Note the tension the sources acknowledge: high contrast aids comprehension while high saturation harms it — these are separable (you can have muted hues at high luminance contrast). The ASPECTSS index (2013) is the first evidence-based ASD design guideline set but is architectural, not digital.

- https://uxdesign.cc/designing-for-autistic-people-overview-of-existing-research-d6f6dc20710e

- https://uxpa.org/designing-for-autism-in-ux/

- https://medium.com/@oksana.iudenkova/create-an-accessible-website-make-it-autism-friendly-db6821c72ed3

- https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/

### Infantilizing design is concretely identifiable: primary colors, cartoon/mascot imagery, puzzle-piece iconography, and 'growth' framing that freezes users as perpetual children

*Confidence: high, **LOAD-BEARING***

Autistic adult sources name specifics: primary colors and puzzle-piece imagery 'erase autistic adults, reinforce harmful stereotypes, and center neurotypical comfort over autistic dignity'; such imagery feels 'patronizing, infantilizing, and deeply alienating'; 'a symbol that looks like it fell out of a toy box doesn't represent' an adult holding down work and relationships; imagery 'fails to grow with autistic people, freezing them in time.' Peer-reviewed: 'Still Infantilizing Autism?' (PMC9645676) updates and extends Stevenson et al. (2011) documenting persistent infantilization in autism representation. Concrete AAC translations: rounded bubbly typography, mascot/avatar characters, star/sticker reward motifs, 'parent/caregiver' account gates, cartoon symbol sets, and encouragement copy addressed to a child.

- https://pmc.ncbi.nlm.nih.gov/articles/PMC9645676/

- https://www.heyasd.com/blogs/autism/autism-puzzle-piece-controversy

- https://bricehildreth.substack.com/p/the-infantilization-of-autistic-adults

- https://autisticnick.com/infantilizing-autistic-adults

### Written/visual language may remain accessible when auditory processing is impaired, supporting text — but this does not establish that reading is intact during shutdown

*Confidence: low, **LOAD-BEARING***

Search surfaced the claim that 'some aspects of language processing don't rely on auditory signals, such as nonverbal and written language processing, which may remain more accessible during periods of auditory processing difficulty.' Around 70% of autistic children have auditory processing differences; stress in multi-source sensory environments intensifies these, and speech-processing brain regions must 'recruit extra neural resources' when sound is distracting. However, I found NO direct study measuring reading comprehension or word-retrieval during autistic shutdown specifically. The brief's hypothesis (reading degrades in shutdown, making symbols valuable to literate adults) is plausible and is the standard clinical rationale for dual coding, but I could not source direct evidence. Treat as a design hedge, not a proven fact.

- https://www.wpspublish.com/blog/sound-check-auditory-processing-in-autism

- https://onlinelibrary.wiley.com/doi/10.1002/aur.3259

- https://www.autismparentingmagazine.com/autism-language-processing-disorders/

### Haptics help but are a genuine sensory risk for this population and must be short, crisp, predictable, and switchable off

*Confidence: medium*

Guidance: 'for users with touch sensitivity or sensory processing differences, unexpected or intense vibrations can be overwhelming; prioritize crisp, predictable, short feedback and ensure the Minimal/Off settings are readily available.' Multi-channel haptics risk sensory overload and add cognitive load. Best practice: use sparingly and only when necessary, consistently and predictably, with user controls for intensity or mute. Verdict for this app: a single short confirmation pulse on tile activation is defensible (it confirms 'the tap registered' without requiring the user to hear or read anything), but it must default to a light impact, never repeat, never sustain, and be toggleable in one tap.

- https://saropa.com/articles/2025-guide-to-haptics-enhancing-mobile-ux-with-tactile-feedback/

- https://www.uxtweak.com/ux-glossary/haptic-feedback/

- https://pmc.ncbi.nlm.nih.gov/articles/PMC9695395/

### Proloquo4Text is the closest adult-appropriate exemplar and its single-screen, no-navigation architecture is worth copying

*Confidence: medium*

Proloquo4Text (AssistiveWare) is text-based AAC positioned for literate teens and adults across autism, cerebral palsy, ALS, aphasia and others. Key architectural choice: 'laid out on a single screen to reduce the effort of typing,' combining typing, stored phrases, and quick access to common phrases without mode-switching. Adds word/sentence prediction to reduce keystrokes, plus customizable screen layout and voice choice. Speech Assistant AAC (Android, low-cost) uses the closest model to the proposed MVP: user-created categories and phrases on buttons that speak or display text, targeted at aphasia, MND/ALS, autism, stroke, CP. Both avoid symbol-first child framing. Notably neither is offline-first-as-a-stance nor free of the iOS/price problem the brief identifies.

- https://www.assistiveware.com/products/proloquo4text

- https://apps.apple.com/us/app/proloquo4text-aac/id751646884

- https://usaspeechtablets.com/blogs/news/best-aac-apps-2026

- https://towson.libguides.com/speech-language-pathology/aac-apps

### Calm Technology gives a defensible design north star: minimum attention, no unnecessary features, periphery-first

*Confidence: high*

Amber Case's Calm Technology principles (2015, building on Xerox PARC 1995): technology should require the smallest possible amount of attention; interaction should occur in the periphery and move to the center only when needed; 'slim the feature set down so the product does what it needs to do and no more, questioning every addition'; 'give people what they need to solve their problem, and nothing more.' The Calm Tech Institute now publishes these as a formal principle set. This is directly usable as a scope-discipline heuristic for the MVP: every feature that is not 'tap tile, phone speaks' must justify its existence against attention cost.

- https://www.calmtech.institute/calm-tech-principles

- https://principles.design/examples/principles-of-calm-technology

- https://www.caseorganic.com/post/principles-of-calm-technology

### Contrast targets: 4.5:1 for body text, 3:1 for large text and interface elements — but maximize legibility, not contrast ratio

*Confidence: high*

Distressed-user guidance restates the WCAG baseline: body text 4.5:1 against background, large text and interface elements 3:1. Combined with the halation finding, this argues for hitting comfortably above the 4.5:1 floor without going to the pure-white-on-pure-black extreme: e.g. #E0E0E0 on #121212 lands around 13-14:1, well clear of the floor while avoiding maximum-polarity bleed. A separate 'high contrast' theme should exist for low-vision users who genuinely need the extreme, exposed as a choice rather than imposed.

- https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/

- https://www.boia.org/blog/dark-mode-can-improve-text-readability-but-not-for-everyone

## Product implications

- **[must-have-mvp]** Never dynamically reorder tiles. No 'recently used' auto-sort, no frecency ranking, no adaptive layout. Tile position is immutable until the user explicitly edits it.
  - Position-based muscle memory is the retrieval channel most likely to survive a shutdown — it requires no reading, no scanning, and no decision. Every adaptive-reordering feature destroys it, and does so precisely when the user most needs it, because 'what I tapped recently' is different in a crisis than in calm use. This is the cheapest rule here (it is literally not building a feature) and the highest-leverage. Predictable navigation is also the core trauma-informed principle. If you build one thing from this research, build this.
- **[must-have-mvp]** Misfire model: adjustable Hold Duration (default OFF, 0-2000ms, up to 5s) + Repeat Delay + a permanently-visible STOP control that halts speech instantly. No confirmation dialogs, ever.
  - This is the proven pattern from Proloquo2Go and it directly resolves the brief's stated tension. Confirmation dialogs are the wrong answer: they double the decision count and add a modal at the worst moment. Dwell prevents tremor/brush misfires for those who need it while costing nothing for those who don't (default off). Instant Stop converts a misfire from a catastrophe into a half-second of noise. Stop must be in the bottom easy zone, always visible, never scrolled away, and larger than a phrase tile.
- **[must-have-mvp]** Add a permanent, unremovable repair tile: 'Sorry — wrong button, that's not what I meant.' Place it adjacent to STOP.
  - You cannot unsay speech, so 'undo' in an AAC app is a social repair, not a state rollback. The user in a shop or ER who misfires a wrong phrase needs a one-tap way to correct the social record without composing a sentence while distressed. No mainstream AAC app treats repair as a first-class primitive. This is nearly free to build, is a genuine dignity feature, and is the honest answer to 'is an undo button essential?' — yes, but it is a speech act, not a stack pop.
- **[must-have-mvp]** Invert the grid: highest-frequency tiles at the BOTTOM, filling upward. Add a left/right handedness toggle that mirrors priority ordering. Never place critical controls in the top third.
  - Conventional AAC grids follow reading order (top-left first), which on a 6.7in phone puts the most important tiles in the hard zone that ~50-70% of hands cannot reach one-handed. The user is holding a phone one-handed, possibly shaking, possibly in public. The easy zone is the bottom third. Handedness mirroring costs one setting and one layout transform and no competitor offers it. Reading order is a convention inherited from paper communication boards; thumb reach is physics.
- **[must-have-mvp]** Touch targets: 76dp floor for any control, ~120x120dp for phrase tiles. 3x4 grid (12 tiles) default on a phone; offer 2x3 (6 tiles, ~180dp) as a 'crisis/large' layout. 12dp minimum gap between tiles.
  - WCAG AA's 24x24 is a legal floor, not a design target; AAA is 44x44; Apple 44pt; Material 48dp. But the honest analogue for a distressed, possibly tremoring, one-handed user is Google's Design for Driving spec at 76dp — an impaired-attention context. On a ~390pt-wide phone a 3x4 grid yields roughly 120pt tiles, far above every minimum and cheap to build. Small targets carry 25%+ tap error rates for motor-impaired users, and here a tap error speaks the wrong thing aloud. Gaps matter as much as size for tremor.
- **[must-have-mvp]** Dark theme default at #121212 (never #000000) with ~#E0E0E0 text; ship Light and High Contrast themes at launch, switchable in one tap from the main screen, with no account or settings-tree spelunking.
  - This is the honest resolution of a real conflict in the evidence: distressed and autistic users prefer dark, but negative polarity measurably slows reading (up to 26%) and causes halation for 30-50% of astigmatic adults. Neither side wins on evidence — so it must be a choice, and 'is dark actually right?' has the answer 'as a default, yes; as a mandate, no.' Pure black is separately wrong for three independent reasons (OLED smear, halation, no elevation ramp). Theme choice must not be buried: someone whose astigmatism makes the default unreadable must not have to read their way through a settings tree to fix it.
- **[must-have-mvp]** Drop Fitzgerald Key part-of-speech coloring. Use muted, low-saturation CATEGORY colors instead (max ~5 hues, desaturated, earthy), and let users pick per-category color.
  - The Key solves grammar construction for emerging word-by-word communicators — a job your literate, phrase-tapping adults do not have. What it does deliver is the saturated primary palette that autistic adults specifically name as infantilizing, and that autistic sensory guidance says overstimulates. It is the single clearest example of AAC convention that is childish AND useless here. Category color for findability is a different, defensible job and can be done in muted tones at high luminance contrast — saturation and contrast are separable levers.
- **[must-have-mvp]** Typography: system font (SF Pro / Roboto) or Atkinson Hyperlegible. No OpenDyslexic/Dyslexie. Full Dynamic Type support via MediaQuery.textScalerOf. Tile label minimum 17pt, default ~20pt, weight 500-600, generous line height.
  - Dyslexia fonts have no supporting evidence and one study found OpenDyslexic reduced reading speed and accuracy with zero participants preferring it. They also visually brand the product as a special-needs device — a dignity cost for no benefit. The evidenced levers are size, weight, spacing, contrast, all of which are free. System fonts are familiar, well-hinted, and read as adult software. Honoring OS text-size settings matters more than any typeface choice and is a one-line concern in Flutter that most apps get wrong by hardcoding.
- **[must-have-mvp]** Eliminate animation. No page transitions over ~100ms, no bounce, parallax, shimmer, skeleton, pulse, or celebration. Honor reduced-motion (Flutter: MediaQuery.disableAnimationsOf / accessibleNavigation) by dropping to zero-duration.
  - Distressed-user guidance explicitly warns against 'bright alerts or sudden animations,' and trauma-informed design identifies jarring visuals as fight-or-flight triggers in sensitized nervous systems. Animation costs latency in a product whose entire premise is instant speech. The only defensible motion is a state change that confirms a tap registered, and haptics plus visual press-state already do that job faster. Reduce Motion must reduce to zero, not to 'gentler.'
- **[must-have-mvp]** Ship both symbols and text on every tile, with three user-selectable modes: text-only, symbol+text, symbol-only. Default to symbol+text.
  - Be honest that this is a hedge, not evidence-backed. I found no study measuring reading during autistic shutdown, so the brief's hypothesis is unproven. But visual search of a symbol grid is faster than reading regardless of shutdown, and written language may remain accessible when auditory processing degrades. Dual coding costs little and covers both possibilities. Critically, text-only must be a supported first-class mode — for many literate adults, symbol sets are the infantilizing element, and forcing pictograms on someone who reads fine is exactly the abandonment mechanism the brief identifies. Let the user decide which channel they trust.
- **[must-have-mvp]** Zero-navigation crisis screen: the app opens directly to the phrase grid, already usable, no splash, no onboarding, no login, no modal. 0 taps to reach critical phrases, 1 tap to speak.
  - Panic tools should offer 'a small number of obvious actions, rather than asking the user to browse.' Every screen between launch and speech is a failure in a shop, an ER, or mid-shutdown. This also aligns with the offline-as-accommodation stance: no network wait, no auth, no loading state. Keep the screen awake while the grid is visible — an auto-lock mid-shutdown forces a passcode the user may not be able to enter.
- **[should-have-v1]** Haptics: single short light-impact pulse on tile activation. Default ON, toggle off in one tap from the main screen, never sustained, never repeated, never patterned.
  - Genuinely double-edged for this population. It confirms the tap registered without requiring the user to hear or read — valuable when auditory processing is impaired and the user cannot verify their own TTS output. But unexpected or intense vibration is overwhelming for sensory-sensitive users, and this app's users are selected for sensory sensitivity. Guidance says crisp, predictable, short, with Minimal/Off readily available. The 'readily available' part matters: a user in sensory overload cannot navigate a settings tree to stop an irritant.
- **[should-have-v1]** Every gesture needs a visible button fallback. No swipe-only category switching, no long-press-only actions, no edge gestures.
  - Distressed-user guidance is explicit that gesture-only interactions exclude users with motor difficulties. Gestures also compound with the misfire problem — an accidental swipe that changes category means the user's muscle memory now points at the wrong tiles, silently. Buttons are inspectable; gestures are invisible state machines. Long-press is doubly problematic here because it collides with the Hold Duration dwell mechanic.
- **[should-have-v1]** Steal from Proloquo4Text: single-screen architecture combining stored phrases and typing with no mode switch. Do NOT put type-to-speak behind a tab.
  - Proloquo4Text's core insight is that mode-switching costs effort literate users cannot spare. The type field should sit directly above the keyboard when open (bottom easy zone) and the Speak control must remain reachable with the keyboard raised — the keyboard eats the entire easy zone, so Speak must live immediately above it, not at the screen top. Prediction is the v1 feature worth copying for keystroke reduction, but it is not MVP.
- **[explicitly-avoid]** Ban the reward/gamification layer entirely: no streaks, no badges, no progress meters, no encouragement copy, no mascot, no avatar, no puzzle-piece iconography, no 'caregiver' account concept.
  - This is the concrete, checkable definition of the infantilization the brief names as the abandonment driver. Autistic adults specifically name primary colors, puzzle pieces, and toy-box aesthetics as patronizing and alienating; peer-reviewed work documents persistent infantilization in autism representation. A 'parent/caregiver' gate is the structural version of the same insult — it encodes that the adult user is not the account holder of their own voice. Calm Technology's 'question every addition' applies hardest here: none of these serve the core job of speaking a phrase.

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


YOUR DIMENSION: UX/UI design for (a) use during distress/shutdown and (b) adult dignity.

Research using WebSearch and WebFetch: crisis UX, "design for cognitive load", "trauma-informed design", accessibility guidelines (WCAG 2.2, Apple HIG accessibility, Material Design accessibility), autistic-designed interfaces, sensory-friendly design, "calm technology", one-handed mobile use / thumb zone research, Fitts's law for touch targets, dark mode and photosensitivity, dyslexia-friendly typography, and what "infantilizing design" concretely means in AAC.

Answer specifically:
- What are concrete design rules for an interface used by someone in a shutdown/meltdown or panic? (decision count, animation, color, sound, text density, undo, error tolerance)
- One-handed use: thumb-reach zones on modern large phones. Where must the highest-frequency tiles go? What about the "type to speak" field position? Should the keyboard/bottom of screen be the priority zone? Any research on the "thumb zone"?
- Touch targets: minimum sizes per Apple HIG / Material / WCAG 2.2 (target size AAA = 44x44? 24x24 minimum?). What size for a user with tremor/reduced motor control? What about accidental-tap prevention vs speed (there is a tension: big targets + no confirmation = misfires that SPEAK something wrong aloud — how do serious AAC apps handle misfires? Is an undo/stop button essential?)
- Dark mode: is dark actually right? Autistic sensory research on brightness/contrast — but also: is dark mode bad for astigmatism/low vision? Should it be a choice? What about pure black vs dark gray on OLED?
- Colors: what makes AAC look childish vs adult? Fitzgerald Key color-coding (parts of speech) is standard in AAC — is it childish or useful? Should an adult app keep it?
- Typography: what typefaces serve this audience? Is there evidence for dyslexia fonts? Font size defaults?
- Symbols vs text vs both for literate adults in distress. Does reading ability degrade during shutdown (making symbols valuable even for literate adults)?
- Motion/animation: what should be eliminated? Respect Reduce Motion.
- Concrete examples of ADULT-appropriate AAC or assistive design done well. Any references worth stealing from?
- Haptics: useful confirmation or sensory irritant?

Give concrete, implementable design rules, not vague principles.
````

</details>
