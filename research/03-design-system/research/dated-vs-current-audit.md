# dated-vs-current-audit

> Phase: **research** · Agent `ad1161b33121c6318` · Run `wf_f237e8a6-694`

## Result

## Summary

Major methodological caveat up front: the Chrome extension was not connected and Apple's App Store rate-limited me (HTTP 429), so I could NOT visually inspect competitor screenshots. Competitor visual descriptions below are reconstructed from textual sources plus prior knowledge and are marked medium/low confidence — the founder should verify them himself before quoting them. What I CAN establish with high confidence is more useful anyway. First, a factual correction to the brief: Proloquo shipped in 2022, not 2021, and won the App Store Award for Cultural Impact in 2023 — and critically, it won for VOCABULARY and cultural sensitivity (categorizing bread under "carbs" not "breakfast foods"), not for being pretty. There is no beautiful AAC app. The category's ceiling is "competently modern iPad software," and that ceiling is set by a 48-button symbol grid on a tablet — a completely different product from a one-screen phone app. Nobody is competing on beauty. Second, the single most load-bearing find: Google's Material 3 Expressive research (46 studies, 18,000+ participants) defines expressiveness as five levers — color, shape, size, motion, and CONTAINMENT. Four of five are static. Expressive designs were spotted up to 4x faster in eye-tracking, and the age-related performance gap "dramatically" narrowed, with benefits for users with varying movement and visual abilities. This demolishes the assumed beauty-vs-accessibility tradeoff and proves motion is not required for expressiveness. Third, Smashing Magazine's July 2026 piece on distressed users reports that distressed users explicitly prefer "dark palettes, sleek and sophisticated looks, and clean, uncluttered aesthetics" — meaning the calm/spa aesthetic is a genuine trap and "sophisticated" beats "soft." Fourth, Graham Pullin's eyewear thesis is exactly right but is routinely misread: glasses de-stigmatized through CONFIDENT VISIBILITY, not concealment — and the Open Bionics counter-lesson is that its Marvel/Star Wars covers work because its users are children, so "superhero branding" is precisely this product's infantilization trap. The escape route for this app is not more restraint (the sleek-dark-minimal look is itself the new generic) but a committed, opinionated tonal palette, an expressive size hierarchy inside the fixed grid, and treating Show Mode as an unapologetic typographic set piece.

### The brief's date is wrong: Proloquo shipped 2022 and won the 2023 App Store Award for Cultural Impact — and it won for vocabulary/cultural sensitivity, not visual design

*Confidence: high, **LOAD-BEARING***

AssistiveWare released Proloquo in 2022; it earned the 2023 App Store Award for Cultural Impact, the first AAC app to do so. Apple's and AssistiveWare's own framing of WHY it won is about the Crescendo Evolution vocabulary built on anonymous data from 10,000+ AAC users, and about cultural/religious sensitivity in categorization — the cited example is that bread is filed under 'carbs' rather than 'breakfast foods' because not everyone eats bread for breakfast. Design Lead Eleonora (an autistic designer) is quoted saying 'The goal was to design an interface that is not only functional but also beautiful and up-to-date,' and UX Designer Rikako on hiding complexity — but AssistiveWare publishes no hex codes, type specimens, or design system documentation anywhere I could find. The award is a vocabulary/ethics award wearing a design award's clothes. IMPLICATION: the bar for 'best-looking AAC app' has never actually been contested on looks. That is an opening, not a threat.

- https://www.assistiveware.com/blog/proloquo-winner-cultural-impact-app-store-award

- https://www.assistiveware.com/press-releases/proloquo-wins-2023-app-store-award

- https://www.apple.com/newsroom/2023/11/apple-unveils-app-store-award-winners-the-best-apps-and-games-of-2023/

### Material 3 Expressive's own research defines expressiveness as five levers — color, shape, size, motion, containment — and FOUR of the five are static. The zero-animation constraint costs you 20% of the expressive toolkit, not 100%

*Confidence: high, **LOAD-BEARING***

Google ran 46 separate research studies with hundreds of designs and 18,000+ participants. Reported results: participants spotted key UI elements up to 4x faster in M3 Expressive designs vs standard M3; time-to-tap on key actions decreased by seconds; 34% boost in perceived modernity; 87% preference among 18-24s. The five named attributes of expressive design are color, shape, size, motion, and containment. This is the single most useful finding for this brief: 'beauty must come from composition, type, color, material, craft' is not a compromise position — it is 4/5 of Google's own definition of expressive, validated at scale.

- https://design.google/library/expressive-material-design-google-research

- https://m3.material.io/blog/building-with-m3-expressive

### Expressive design NARROWED the age-related performance gap and helped users with varying movement and visual abilities — the beauty-vs-accessibility tradeoff this brief fears is empirically backwards

*Confidence: high, **LOAD-BEARING***

Google's write-up: 'expressive design seems to level the playing field for users of all ages.' Age-related performance gaps in spotting UI elements narrowed 'dramatically,' with 45+ users performing comparably to younger users. The mechanism named is larger buttons and high-contrast containment — i.e., exactly the moves this app is already constrained toward (76dp floor, high luminance contrast). The expressive move and the accessible move are the SAME move. The canonical case study: the send button was enlarged, relocated near the keyboard, and colored to stand out → 4x faster recognition.

- https://design.google/library/expressive-material-design-google-research

- https://developer.android.com/design/ui/wear/guides/get-started/benefits

### Google's own caveat: expressive design HURT usability when it replaced familiar patterns with novel ones. This is the guardrail on the fixed-grid constraint

*Confidence: high, **LOAD-BEARING***

From the same research: 'Not all contexts suit expressive design. Replacing familiar patterns (like vertical song lists with scattered album art) hurt usability despite modern appearance.' Read directly onto this product: expressiveness must be applied to the RENDERING of the grid (color, shape, size, containment, type), never to its STRUCTURE (position, order, reflow). Scattering the tiles artfully is the exact failure mode Google measured. Fixed positions are not the enemy of beauty; they are the canvas.

- https://design.google/library/expressive-material-design-google-research

### Distressed users prefer 'dark palettes, sleek and sophisticated looks, and clean, uncluttered aesthetics' — the calm/spa aesthetic is a documented trap, and 'sophisticated' beats 'soft'

*Confidence: high, **LOAD-BEARING***

Smashing Magazine, July 2026, 'Designing For Distressed Users: Why Mental Health Apps Shouldn't Follow Every UI Fashion.' Named trends to REJECT: glassmorphism and ultra-minimalism chosen purely for aesthetics; neo-brutalist stark-contrast layouts; hidden gesture-only navigation; abstract unlabeled icons; low-contrast minimalism that excludes visually impaired users; confetti; streaks (shame on missed days); can't-skip celebration screens. Named preferences: muted earthy tones and dark palettes over bright cheerful colors; WCAG 2.2 (4.5:1 body, 3:1 large text/UI); stable predictable IA; linear flows. The key line for the founder: reject interfaces that feel 'too bright, too happy, and too overwhelming,' and 'what matters is not whether the interface is bright or muted, but whether its emotional tone fits the product's purpose and the likely state in which users arrive.' The founder's 'beautiful' and this research's 'sleek and sophisticated' are the SAME target. 'Calm app' pastel softness is a THIRD failure mode alongside grey-enterprise and cartoon-child.

- https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/

### The 'calm app' aesthetic IS infantilizing in a second direction — and there is 2026 design criticism naming it

*Confidence: medium, **LOAD-BEARING***

Priya Khanchandani in Dezeen (29 Jan 2026): 'Underneath wellness design's tasteful minimalist aesthetic lie some uncomfortable truths. Wellness design offers essentially comfort – a highly aestheticised, deeply exclusive form of it,' and wellness 'has very little to do with health at all,' functioning as 'a vague signifier for something that feels quite nice.' (Fetched 403 — sourced via search snippet; verify directly.) Applied here: the spa aesthetic — rounded blobs, dusty pastels, hairline weights, breathy lowercase copy, 'take a moment' tone — treats the user as fragile and in need of soothing. That is a caregiver posture in a different costume. A user in shutdown is not fragile; they are temporarily without speech and need a tool that WORKS and that they are not embarrassed to hold out to a cashier. Endel/Calm/Oak are optimized for lingering; this app is optimized for exit. Steal their restraint and their color discipline; reject their emotional posture and their contrast.

- https://www.dezeen.com/2026/01/29/wellness-opinion-priya-khanchandani/

- https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/

### Pullin's eyewear thesis is 'fashion meets discretion' — and the lesson is CONFIDENT VISIBILITY, not concealment. Most people cite Pullin and then build the thing he argues against

*Confidence: high, **LOAD-BEARING***

Design Meets Disability (MIT Press, 2009). Chapter 1 is 'Fashion meets discretion.' Pullin's framing: the priority for design for disability has traditionally been to enable while attracting as little attention as possible, producing 'decades of pink plastic aids and miniaturised devices designed to be camouflaged or hidden: to go unseen.' Glasses are the counterexample — they reduced stigma 'not through invisibility, but through good design.' Pullin's axis is discretion vs. DISCUSSION: design that invites conversation rather than hiding. Direct application: Show Mode is this product's 'discussion' moment — the instant the phone is turned to a stranger, the app IS on display. Every AAC app treats that screen as a utility readout. Pullin says it is the entire stigma battleground. It is also, conveniently, the one screen with no calm constraint (a cashier at arm's length in daylight), which means it can carry the app's whole aesthetic argument at full volume.

- https://mitpress.mit.edu/books/design-meets-disability

- https://www.core77.com/posts/15597/book-review-design-meets-disability-by-graham-pullin

- https://www.utne.com/science-and-technology/design-meets-disability-prosthetics-arts/

### AirPods Pro as hearing aid is the strongest destigmatization-through-design datapoint that exists, and it's quantified

*Confidence: high, **LOAD-BEARING***

Traditional hearing aid form factors (RIC, BTE) were identified as hearing aids by ~80% of respondents; for the Apple AirPod the association frequency was only 22%. MarkeTrak 2025 puts hearing aid adoption at 39%, up from 23% in 1989 — i.e., decades of miniaturization moved the needle slowly; one consumer product reframed the category. The mechanism is NOT that AirPods hide the disability — they are large, white, and highly visible. It's that they are visibly a DESIRABLE CONSUMER OBJECT rather than a medical appliance. Transferable thesis: the goal is not that nobody can tell it's an AAC app; the goal is that what they can tell is 'that's a nice piece of software.' The founder's brief and the stigma research are the same requirement.

- https://audioxpress.com/article/perception-stigma-and-ergonomics-in-hearing

- https://www.entandaudiologynews.com/features/audiology-features/post/the-apple-effect-could-apple-s-involvement-redefine-the-future-of-hearing-aid-technology

- https://www.engadget.com/audio/headphones/apples-airpods-pro-hearing-health-tools-could-normalize-wearing-earbuds-everywhere-140054858.html

### Open Bionics' Hero Arm is a TRAP for this product, not a model — it's the child market's answer, and copying it would reintroduce exactly what's banned

*Confidence: high, **LOAD-BEARING***

Open Bionics: 'Children and young people consulted indicated that they did not want to hide their limb difference with a lifelike prosthetic but would rather celebrate it with something fantastical.' Result: 50+ swappable magnetic covers including licensed Marvel, Star Wars and Disney designs. The insight that transfers — users want 'a device that they found empowering to wear,' 'less like a medical device and more as a medium for self-expression' — is real and applies. The EXECUTION does not: superhero branding for autistic adults is the mascot ban wearing a cooler jacket. Note also Proloquo2Go's cited inclusivity improvement is 'female superhero icons' — i.e., the category's idea of progress is still superheroes. What to actually steal: swappable covers = the theme system. Personalization as identity expression, not decoration. Ship 3-4 genuinely distinct, fully-committed themes (not 'dark/light/HC' as three lighting conditions of one design) and let choosing one be the self-expression act.

- https://openbionics.com/our-story/

- https://www.vam.ac.uk/blog/museum-life/the-hero-arm-why-children-make-great-designers

- https://www.assistiveware.com/products/proloquo2go

### Aesthetics drive assistive device ABANDONMENT — this is peer-reviewed, not vibes, and abandonment is this product's core risk

*Confidence: high, **LOAD-BEARING***

Santos & Ferrari, 'Aesthetics and the perceived stigma of assistive technology for visual impairment,' Disability and Rehabilitation: Assistive Technology 17(2) (2020/2022). Finding: devices without negative symbolism but with modern aesthetics (smart glasses) were accepted more positively than devices with traditional aesthetics and symbolisms of visual impairment (white cane). Corroborating: Bruno Oro, 'Designing for Dignity – The Role of Esthetic Empathy in Assistive Technologies' (IntechOpen) — 'assistive technologies with poor esthetics and limited personalization options are significantly more likely to be abandoned'; stigma, not functionality, drives abandonment. Its comparison pair is instructive: Rollz Flex 2 rollator ('the beautiful design hides the more traditional look of a mobility aid') vs Medline folding walker ('it makes me feel old. I wish it looked less like hospital equipment'). No specific abandonment percentages given in the chapter. The founder's 'I want something beautiful' is a RETENTION requirement. Prior research established adults abandon AAC apps; this establishes aesthetics as a named cause.

- https://www.tandfonline.com/doi/full/10.1080/17483107.2020.1768308

- https://pubmed.ncbi.nlm.nih.gov/32501732/

- https://www.intechopen.com/chapters/1212883

### Even the award-winning AAC app deliberately ships thousands of TEXT-ONLY buttons — text-only is not a downgrade, it's what the state of the art converged on

*Confidence: high, **LOAD-BEARING***

Proloquo has 9,000+ text-only buttons vs 4,500+ symbolized buttons — text-only OUTNUMBERS symbols roughly 2:1 in the category's most decorated app. Reasoning given: function words are 'difficult to picture'; low-frequency synonyms ('terrible,' 'awful,' 'offensive') can't be visually distinguished; closed sets work better as text ('memorizing every state flag or every state's shape is more difficult than recognizing the printed word'). Text-only buttons render as 'half-height' buttons in alphabetized lists, letting users use letter recognition and word length as search cues. This directly validates the MVP's text-only decision AND supplies a beauty argument: if the tile is text, the tile IS typography, and typography is where all the craft budget should go. Note also Proloquo is a single fixed grid size of 48 buttons — the same fixed-grid, motor-planning philosophy as this app, just on a tablet.

- https://www.assistiveware.com/blog/proloquo-buttons-symbols

- https://www.assistiveware.com/products/proloquo-and-proloquo-coach-for-aac-professionals

### Atkinson Hyperlegible Next (Feb 2025) fixed the exact gap that made the original unusable for this brief — it now has the 500/600 weights the tile spec requires, plus a variable font and a Mono

*Confidence: high, **LOAD-BEARING***

Braille Institute launched Atkinson Hyperlegible Next on 10 Feb 2025. Seven weights (ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold) up from two, each with upright and Italic; a variable version; Atkinson Hyperlegible Mono ('one of the most requested additions,' aimed at coders); 150+ languages up from 27. Free via Google Fonts and brailleinstitute.org/freefont. This is decisive: the brief demands weight 500-600 for tile labels, which the ORIGINAL Atkinson (Regular/Bold only) could not supply — you'd have been faking it with Bold or falling back to system font. Next ships Medium and SemiBold natively. And Atkinson Hyperlegible Mono is a free, legitimate, accessibility-native way to buy the 'indie craft / precision' signal that 2026 editorial design reaches for with monospace — use it for the type-to-speak field, giving that field a distinct voice from the tiles without adding a single non-accessible typeface.

- https://www.brailleinstitute.org/about-us/news/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier/

- https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html

- https://www.printmag.com/type-tuesday/atkinson-hyperlegible-next-applied-design/

### Emergency Chat is the closest existing analogue to Show Mode, was built by an autistic adult for this exact use case, and is aesthetically abandoned — this is the gap in the market, precisely located

*Confidence: medium, **LOAD-BEARING***

Emergency Chat, by Jeroen De Busser, an autistic adult, 'to help other people like him who went non-verbal during meltdowns or during periods of extreme anxiety.' Mechanic: open the app → a splash screen explains to a stranger that you can't use speech right now → 'you will then hand your phone to a stranger to read' → a simple chat client. Fully customizable text (asthma, specific needs). Free, iOS/Android/Windows. Reviewers describe it as 'a simple, intentionally basic design.' Its distribution channel is listed as a Facebook page. This is the exact product thesis — hand the phone to a stranger — validated by an autistic adult a decade ago, and executed with zero design investment. The situational-speech-loss user already has a proven interaction pattern; nobody has ever made it beautiful. That is the whole wedge in one sentence.

- https://lifeonautism.wordpress.com/2016/10/06/aac-app-review-emergency-chat/

- https://nyrequirements.com/blog/autistic-man-creates-emergency-chat-app

- https://www.atandme.com/accessible-apps/apps-for-adults-with-autism-spectrum-disorders/

### Speech Assistant AAC — the direct incumbent — is architecturally dated in a way that's more damning than its pixels, and its own user manual gives it away

*Confidence: medium, **LOAD-BEARING***

From the official User Manual v6.4 and store listings: 'The interface of the main screen has 4 components: the textbox and 3 scrollable areas with buttons. There are 12 action buttons. The first 6 buttons are always visible, the other buttons can be made visible by SCROLLING DOWN over the action buttons.' That is the tell. Scrollable button regions destroy motor planning — the single thing fixed-position grids exist to protect. It's a 2013-era Android form: text field on top, scrolling lists below, settings behind a menu. It has the right features (full-screen large-font display mode = show mode; photo/symbol options; recorded speech) and the wrong everything else. Praise in reviews is always for CUSTOMIZATION and never for design ('you can really make it your own,' 'simple button-based interface'). What a 2026 designer does differently: kill the scroll (fixed 3x4, position is memory), kill the 12-action-button chrome (one screen, no toolbar), and treat the full-screen display mode as the hero rather than a buried feature. CAVEAT: I could not view its screenshots directly — verify the visual specifics yourself.

- https://www.asoft.nl/SpeechAssistantAAC-Android-UserManual.pdf

- https://play.google.com/store/apps/details?id=nl.asoft.speechassistant

- https://speech-assistant-aac.en.uptodown.com/android

### Spoken is the only competitor positioning explicitly on adult design — and it's the real competitive threat, not Proloquo

*Confidence: medium, **LOAD-BEARING***

Spoken (launched 2019, iOS/Android/Mac): 'one of the only AAC apps specifically created for adults, reflected by its design and function.' Reviewers call the interface 'beautiful' and 'clean... free of any distractions.' Ships large print, dark mode, word dividers. Has an 'attention button' — a substitute for clearing your throat: one tap blinks the flashlight and plays a customizable sound (a genuinely good idea worth stealing outright; it solves 'how do I get a stranger's attention when I can't speak' which Show Mode alone does not). Its design blog (v1.8.8, ~50 new icons across 600+ words) reveals its actual design philosophy is icon-craft: 'we strive for simplicity and clarity, allowing users to quickly recognize and understand each symbol without needing any additional context,' rejecting a detailed truck icon for a simplified bus. Weaknesses to attack: it's predictive-text/sentence-building oriented (typing under load), it's networked/VC-shaped, and its competitor page reviews only Proloquo2Go, TouchChat HD, and Grid — it does not see a phone-first, offline, situational-speech-loss product coming. CAVEAT: visual claims are secondhand; verify.

- https://spokenaac.com/

- https://spokenaac.com/blog/version-1.8.8/

- https://spokenaac.com/best-aac-for-adults/

- https://en.wikipedia.org/wiki/Spoken_(app)

### The whole category is tablet-shaped, clinician-mediated, and vocabulary-obsessed — which means its dated-ness is structural, and a phone-first product doesn't inherit it

*Confidence: medium*

Proloquo: single fixed grid of 48 symbol buttons, sized 'so that anyone who can independently operate an iPad can use Proloquo' — iPad is the assumed device. Proloquo2Go (2009, 'the world's most popular AAC app'): Fitzgerald-style color-coding by part of speech, 25,000+ SymbolStix symbols, ships a Proloquo Coach companion app for professionals. Proloquo2Go's marketing frame is 'Created in collaboration with speech-language pathologists, parents, and other therapeutic service providers' — the parent/clinician framing is in the POSITIONING, not just the pixels. TouchChat HD: 'Some of its vocabulary sets are clearly designed with children in mind.' AsTeRICS Grid and Cboard: open-source, web/PWA, offline-capable, explicitly framed as 'an alternative to expensive AAC tools' and 'democratizing AAC' — they are configurable grid ENGINES supporting eye-tracking, head-tracking, EMG sensors, smart home control and YouTube. Their aesthetic is an admin panel because they are one. NONE of these is designed for a phone in a pocket, for one hand, for 90 seconds, for someone who could speak this morning. The category isn't badly designed for this user — it isn't designed for this user at all.

- https://www.assistiveware.com/products/proloquo

- https://www.assistiveware.com/products/proloquo2go

- https://www.assistiveware.com/support/proloquo2go/appearance/color-code-page-background

- https://github.com/asterics/AsTeRICS-Grid

- https://www.openaac.org/aac.html

- https://spokenaac.com/best-aac-for-adults/

### M3 Expressive's headline features are mostly motion — but its STATIC additions (35 shapes, corner radius tokens, expressive type, containment) are free to take, and the 'full = fully rounded' token change is a concrete dating marker

*Confidence: high, **LOAD-BEARING***

M3 Expressive added 35 new shapes and shape morphing to the Material Shapes library and Jetpack Compose; 15-28 new/refreshed components; spring-based motion physics replacing the old easing/duration system; emphasized typography; expressive color palettes. Specifically on radius: 'Corner radii tokens were added, and fully rounded corners were updated to use full, whereas before this was set at 50% of the component size.' The motion system — springy shape-morphing buttons — is entirely unusable here and must be actively disabled, not merely not-used (Flutter's M3 components will animate by default). But shapes, radius tokens, emphasized type, size hierarchy and containment are static and are 4/5 of the expressive definition. Practical Flutter note: M3 is default since Flutter 3.16 and ColorScheme.fromSeed generates the tonal palettes this needs.

- https://m3.material.io/blog/building-with-m3-expressive

- https://supercharge.design/blog/material-3-expressive

- https://www.androidauthority.com/google-material-3-expressive-features-changes-availability-supported-devices-3556392/

- https://developer.android.com/develop/ui/compose/designsystems/material3

### 2026 trend consensus is low-quality SEO slop and should be discounted — but three signals repeat across independent sources and one of them is a direct threat to this app's contrast floor

*Confidence: low*

I read across ~8 trend roundups (DesignStudio, Muzli, Tubik, Fontfabric, MadeGood, uxpilot, Intuitia). Most are content-farm output; treat as weak evidence. Three signals recur: (1) flat design's end — 'subtle shadows, layering motion and perspective to create a sense of dimension'; (2) glassmorphism's return but 'surgically,' for overlay cards and floating panels only — the difference from 2021 'is restraint'; (3) typography-led editorial layouts, monospace as an indie-craft/precision signal, 'headings are becoming larger, but body text remains restrained.' THE TRAP, and it's a serious one: these same sources push 'ultra-thin typography, generous whitespace, and muted palettes' and 'resonant stark design.' Ultra-thin type at low contrast is precisely what the Smashing distressed-users piece names as excluding visually impaired users, and it directly violates this app's 500-600 weight floor. The most fashionable 2026 look is disqualified here on contrast grounds. Also note glassmorphism is explicitly rejected by the distressed-users research — so trend #2 is out too. Take the typography signal; leave the rest.

- https://muz.li/blog/whats-changing-in-mobile-app-design-ui-patterns-that-matter-in-2026/

- https://blog.tubikstudio.com/ui-design-trends-2026/

- https://www.fontfabric.com/blog/10-design-trends-shaping-the-visual-typographic-landscape-in-2026/

- https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/

### Klemens Strasser's Art of Fauna (2025 Apple Design Award, Inclusivity) is the proof that a solo developer can win on accessibility AND visual identity simultaneously — and it's the single best reference for this product

*Confidence: high, **LOAD-BEARING***

2025 Apple Design Awards, Inclusivity category, two winners: Speechify (hundreds of voices, 50+ languages, Dynamic Type, VoiceOver — serving dyslexia, ADHD, low vision) and Art of Fauna by Klemens Strasser — 'a puzzle game that blends vintage-inspired wildlife imagery with a deep commitment to inclusivity,' full VoiceOver support and haptic feedback, 'accessibility is woven throughout.' Strasser is a solo indie developer who has now won/been recognized repeatedly for accessibility-first design. The load-bearing point: Art of Fauna did not win by being accessible-therefore-plain. It won by having a committed, specific, opinionated visual identity — vintage natural-history illustration — that is ALSO fully accessible. It picked an aesthetic lane and drove it. That is what 'creative and beautiful' means operationally: not more polish on a generic base, but a POINT OF VIEW. This app currently has no aesthetic lane. Picking one is the actual work.

- https://developer.apple.com/design/awards/2025/

- https://www.apple.com/newsroom/2025/06/apple-unveils-winners-and-finalists-of-the-2025-apple-design-awards/

- https://www.applevis.com/blog/speechify-art-fauna-cozy-puzzles-win-2025-apple-design-awards-inclusive-design

### I could not visually inspect a single competitor screenshot — the founder must do this himself, and it's a half-day of work with outsized payoff

*Confidence: high, **LOAD-BEARING***

The Chrome extension was not connected ('Browser extension is not connected'), and apps.apple.com returned HTTP 429 Too Many Requests. Text sources for AAC apps are written by SLPs, parents, and the vendors themselves — audiences who never discuss visual design. Searching explicitly for 'Proloquo2Go looks dated/old/childish' returned NOTHING: no reviews critique the appearance, because the reviewer population is clinical, not design. The search engine's own summary said to try 'Reddit discussions, or dedicated AAC user communities where adults using the app might share more candid feedback about interface aesthetics.' That is the actual research gap and it's where the wedge evidence lives: r/AAC, r/autism, r/aphasia, and AAC-user Mastodon/Bluesky, searched for 'infantilizing,' 'embarrassed,' 'looks like a kids app,' 'I'd never use this in public.' Every competitor visual description in this report is prior-knowledge reconstruction and should be treated as a hypothesis to verify, not a finding.

## Design moves

- **Pick an aesthetic LANE and name it in one sentence before writing any code. Not 'clean, accessible, adult' — that's a description of the absence of mistakes. Something like 'Swiss transit signage' or 'letterpress specimen book' or 'field notebook' or 'late-night terminal.' Write it on a sticky note. Every subsequent decision either serves it or gets cut.**
  - Why: Art of Fauna won a 2025 ADA for Inclusivity with 'vintage natural-history illustration' — a committed point of view that was also fully accessible. Google's expressive research found 34% higher perceived modernity from committed expressive choices. The grey-rectangle failure mode the founder fears is not caused by too little polish; it's caused by having no thesis. Both 'grey enterprise' and 'sleek dark minimal' are what you get by default when nobody chose.
  - Risk: A strong lane can drift decorative. Rule: the lane governs COLOR, TYPE, SHAPE, and CONTAINMENT only. It never governs position, order, target size, or contrast — those are locked by the accessibility spec and win every conflict.
- **Adopt Atkinson Hyperlegible Next (Feb 2025) as default, NOT the original Atkinson. Tile labels at Medium(500)/SemiBold(600) — weights the original literally does not have. Use Atkinson Hyperlegible Mono for the type-to-speak field only.**
  - Why: The brief mandates weight 500-600; original Atkinson ships Regular+Bold only, so you'd be faking it or falling back. Next ships seven weights plus a variable font, free on Google Fonts, 150+ languages. The Mono variant buys the 2026 'indie craft/precision' signal that editorial design reaches for with monospace — for free, from an accessibility-native foundry, with zero legitimacy cost. Two voices (grid = humanist, input = mono) from ONE family is a real typographic idea that costs nothing.
  - Risk: Mono has wider advriance and may wrap sooner at 200% TextScaler — the input field must be a free-scrolling multiline field, never a fixed-height box. Verify Google Fonts serves Next (some listings still default to the original); if unsure, bundle the variable TTF as an asset rather than relying on the network — this app is offline-first anyway, so bundling is mandatory regardless.
- **Build the size hierarchy INSIDE the fixed 3x4. Row heights unequal: the lower-center arc rows get ~1.3-1.4x the height of the top row. Positions never move; only the geometry is non-uniform. Every tile still clears the 76dp floor — you make the important ones BIGGER, never the others smaller.**
  - Why: This is the single highest-leverage beauty move available and it is free. 'Size' is one of Google's five expressive levers, and the canonical M3 Expressive case study is literally 'the send button was enlarged, relocated, and colored to stand out → 4x faster recognition.' A uniform grid of twelve identical rectangles is the visual definition of the 2014 enterprise screen; a deliberate size hierarchy is composition. And it makes the highest-value lower-center tiles physically easier to hit under motor imprecision. Beauty and accessibility are the same move here.
  - Risk: Google's own caveat: expressiveness that replaces FAMILIAR STRUCTURE hurt usability (the scattered-album-art finding). Non-uniform sizing is safe because position is preserved; non-uniform POSITIONING would be the exact failure they measured. Hard constraint: the size ratio must be fixed and never data-dependent — no 'frequently used tiles grow,' which would be reflow with extra steps and would destroy motor memory.
- **Kill every drop shadow. Express elevation and grouping with M3 tonal surface containers only: surfaceContainerLowest → surfaceContainerHighest. Set elevation: 0 explicitly on Card/Material — Flutter's M3 defaults will otherwise give you shadows you didn't ask for.**
  - Why: A soft grey blurred shadow under a card is the most reliable single tell of 2014-2018 Material. M3 replaced M2's #121212-plus-elevation-overlay model with tone-based surface containers, and the brief already commits to M3's #141218 baseline. Tonal separation reads as intentional; drop shadows read as legacy. This also directly serves 'containment' — Google's fifth expressive lever and the one nobody uses.
  - Risk: Tonal separation alone can fall below 3:1 for adjacent large UI surfaces under WCAG 2.2. In the high-contrast theme, tonal steps will be insufficient — that theme needs explicit borders (2dp, onSurface) instead. Don't let 'no shadows' become 'no boundaries'; containment must survive all three themes.
- **Corner radius: ~24-28dp on the tiles, not 8dp. Radius must scale with the element — a 100dp-tall tile at 8dp radius is a 2016 Material button scaled up, and it looks exactly like one. Investigate Flutter's RoundedSuperellipseBorder / ClipRSuperellipse (squircle) for the tiles.**
  - Why: Radius-to-size ratio is the most checkable dating marker on the list. M3 Expressive added explicit corner radius tokens and changed 'fully rounded' to use `full` rather than 50% of component size — radius is now a first-class expressive axis, not an afterthought. Shape is lever #2 of five.
  - Risk: MEDIUM CONFIDENCE — verify RoundedSuperellipseBorder exists in your Flutter version and check its raster cost; I could not confirm the API surface. Do NOT use ContinuousRectangleBorder as a squircle substitute — it is not a superellipse and renders visibly under-rounded. Also: very large radii shrink the effective corner hit area; keep the InkWell/GestureDetector target rectangular and full-bleed even if the paint is rounded.
- **Tint the tiles themselves. Category color = a tonal container at LOW chroma: build TonalPalettes via material_color_utilities with chroma ~16-24 (not fromSeed's default ~48), take tone 90 for container in light / tone 30 in dark, and tone 10/90 for the label. 4-5 categories max.**
  - Why: 'One saturated accent color floating on a field of grey' is the 2014 signature. A fully tinted tonal surface is the 2026 one — and 'color' is expressive lever #1. Crucially this is the mechanical answer to the brief's central tension: tone 90 vs tone 10 is a luminance relationship, so contrast stays ~15:1+ while chroma stays low. Muted hue AND high luminance contrast, which the brief names as the target and which the tonal system delivers for free. Prior research explicitly cleared category color-coding as non-infantilizing, and Proloquo2Go already color-codes (by part of speech — wrong axis here, right instinct).
  - Risk: fromSeed's default chroma will look candy-bright and blow the sensory constraint — you MUST override it, not accept the default. Reserve high chroma exclusively for Show Mode and possibly one destructive action. Verify all 4-5 category containers against onSurface in all three themes with a contrast checker in CI, not by eye. Also: color must never be the ONLY category signal — position carries retrieval, color is confirmation.
- **Make Show Mode the app's signature — a full-bleed typographic set piece, not a utility readout. High-chroma full-bleed ground, Atkinson Next at display size (~96-140pt) auto-fitted to the phrase, tight tracking (-1 to -2%), optically centered, forced max brightness, screen-wake-lock on. This is the one screen with permission to shout.**
  - Why: Pullin's actual thesis is discretion vs DISCUSSION — stigma falls through confident visibility, not concealment, and Show Mode is the only moment this product is seen by anyone but its owner. The brief already establishes Show Mode as the exception to the calm rule on optical grounds (a cashier at arm's length in daylight), which means the aesthetic freedom is already paid for by the ergonomics. Emergency Chat proved the hand-the-phone-over pattern a decade ago and never designed it. This is where the whole 'beautiful' brief can be cashed at full volume with zero constraint conflict.
  - Risk: Direct conflict with the user's own eyes: they're likely photophobic and in sensory overload while holding a maximally bright saturated screen. Mitigations: ramp brightness at the OS level only while Show Mode is foregrounded and restore on exit; make the reveal instantaneous (no fade — that's the animation ban anyway); ensure the exit target is large, in the ergonomic thumb arc, and NOT where a stranger might tap. Consider letting the user choose the Show Mode ground color as part of theme identity.
- **Ship 3-4 fully-committed named THEMES rather than 'dark/light/high-contrast' as three lighting conditions of one design — and put the one-tap switcher on the main screen as a crafted control, not a settings row.**
  - Why: Open Bionics' real transferable insight is 50+ swappable covers: personalization as identity expression, not decoration ('users really wanted to wear a device that they found empowering'). The Marvel licensing is the child market's answer and is banned here — but the swappable-cover MECHANIC is exactly right for an audience that skews trans/nonbinary and for whom self-definition is load-bearing. Choosing your theme becomes the identity act, replacing the mascot/avatar the category uses to do that job badly. The brief already requires a one-tap switcher; making it an aesthetic act rather than a plumbing control costs nothing.
  - Risk: Each theme multiplies the contrast-audit surface — 4 themes x 5 category containers x 2 text roles is a real matrix; automate it or you will ship a broken combination. The high-contrast theme must remain a NON-negotiable, non-artistic escape hatch that always wins — never let it become the fourth 'look.' Also don't let theme choice hide behind a long-press or gesture: the distressed-users research names hidden gesture-only navigation as a specific anti-pattern.
- **BANNED-BY-EVIDENCE list, pin it above the monitor: glassmorphism (any), neumorphism, blurred translucent panels, ultra-thin/Light type weights, low-contrast 'elegant' grey-on-grey, blob/organic shapes, dusty pastel spa palettes, breathy lowercase 'take a moment' copy, gradient backgrounds as decoration, thin 1px-stroke icons, drop shadows, neo-brutalist stark-contrast layouts, hidden gesture-only navigation, and abstract unlabeled icons.**
  - Why: Every item here is named as an anti-pattern by the July 2026 Smashing distressed-users research or fails the brief's own contrast floor. Notably glassmorphism and ultra-minimalism — the two most fashionable 2026 moves in the trend press — are explicitly rejected for this exact user population: 'reject interfaces that feel too bright, too happy, and too overwhelming,' and avoid 'low-contrast minimalism trends that exclude users with visual impairments.' The most fashionable look of 2026 is disqualified here on contrast grounds alone.
  - Risk: This list is a floor, not a design. Following it perfectly produces a competent, inoffensive, forgettable app — the exact grey-rectangle outcome the founder is paying to avoid. It only works paired with the aesthetic-lane move. Restraint is not a point of view.
- **Steal Spoken's attention button outright: one tap strobes the flashlight and plays a short custom sound. Ship it as a persistent element on the main surface.**
  - Why: It solves a real problem Show Mode does not — how do you get a stranger's attention when you cannot speak and cannot clear your throat? Spoken frames it exactly that way: 'a substitution for verbal cues like clearing one's throat.' It's offline, needs no network, no account, costs nothing, and it's the kind of specific competence that reads as respect for the user's actual situation rather than a designer's idea of it.
  - Risk: DIRECT CONFLICT WITH THE SENSORY CONSTRAINT AND A SAFETY ISSUE: a strobing flashlight is a photosensitive-seizure risk and is exactly the 'sudden visual alert' the distressed-users research says to avoid. Must be OFF by default, opt-in only, with user-set flash rate (keep well under 3Hz) and the option of sound-only or vibration-only. Never fires without a deliberate tap. Verify Android torch API behaviour across OEMs — this will not work uniformly.
- **Use Material Symbols as a variable font and drive state with the FILL axis (0→1) rather than swapping colors or icons. Set weight to match the type (500-600) and set optical size to the render size.**
  - Why: 1px-stroke uniform-weight icons are a hard 2014-2017 tell (the Font Awesome / early-Material era). Variable-axis Material Symbols with weight/fill/grade/optical-size are the current standard and let icon stroke weight harmonize with Atkinson's — a small, cheap coherence move that reads as craft. FILL-as-state is a static state change, so it survives the animation ban intact (just don't animate the axis transition, which is Google's showcase use).
  - Risk: Flutter's variable-font axis support is inconsistent — verify FILL/wght axes actually apply on Android at your target SDK before committing; you may need separate static font files per axis position, which bloats the bundle. Also the distressed-users research warns against 'abstract, unlabeled icons requiring interpretation effort' — icons here must be paired with text labels or confined to chrome, never used as a tile's only content.
- **Consider a static grain/paper texture at ≤2% opacity on the base surface — but gate it behind a toggle, default OFF, and force it off in high-contrast mode.**
  - Why: The brief's own framing is the argument: 'print has been beautiful for 500 years without moving.' With motion banned, MATERIAL is one of the few remaining sources of tactility and warmth, and a whisper of grain is what separates 'designed object' from 'flat color fill.' It's the cheapest available answer to 'creative' that doesn't touch structure.
  - Risk: LOWEST-CONFIDENCE MOVE HERE — this is a genuine gamble against the audience's defining trait. Visual noise is precisely what sensory-sensitive users may not tolerate, and I found no evidence either way for autistic adults specifically. Also costs a shader or a tiled asset on the hot path of an app whose premise is instant speech. Treat as a v1.1 experiment to test with real users, not an MVP decision. If in doubt, cut it — the tonal/type/size moves carry the aesthetic on their own.
- **Before any of this: spend half a day in r/AAC, r/autism, r/aphasia and AAC-user Bluesky/Mastodon searching 'infantilizing,' 'embarrassed,' 'looks like a kids app,' 'wouldn't use in public.' Screenshot every quote.**
  - Why: I could not verify a single competitor's appearance visually (extension offline, App Store 429), and — more importantly — a targeted search for critiques of Proloquo2Go's appearance returned literally nothing. Not because the app looks fine, but because the entire published reviewer population is SLPs, parents, and vendors, none of whom discuss visual design. Even the search engine suggested going to Reddit for candid aesthetic feedback. The founder's whole wedge is dignity-through-design; the evidence for it exists only in user communities, and it is currently uncollected. It is also the best marketing copy this app will ever have.
  - Risk: Confirmation bias — you will find what you're looking for. Search for the disconfirming case too ('Proloquo2Go looks great,' 'I like the symbols'), and specifically test whether users object to the SYMBOLS or the VOCABULARY, since prior research says vocabulary, and that distinction determines whether text-only-first is a real wedge or an assumption.

## References

- **Art of Fauna — Klemens Strasser (2025 Apple Design Award, Inclusivity)** https://developer.apple.com/design/awards/2025/
  - Steal: THE reference for this product. A solo indie dev won an accessibility award by having a committed aesthetic point of view (vintage natural-history illustration) that was also fully VoiceOver-native — not by being plain. Steal the strategy, not the style: pick a lane and drive it. Study how he talks publicly about accessibility-first solo development.
- **Google Design — 'Expressive Material Design' research** https://design.google/library/expressive-material-design-google-research
  - Steal: The five expressive levers (color, shape, size, motion, containment) — four of which are static and legal here. The 4x-faster eye-tracking result, the age-gap-narrowing finding, and the send-button case study (enlarge + relocate + color = 4x faster). Also steal the CAVEAT: expressiveness applied to familiar structure hurt usability. Your grid structure is sacred; its rendering is not.
- **Smashing Magazine — 'Designing For Distressed Users' (July 2026)** https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/
  - Steal: The most directly applicable source found. Distressed users prefer 'dark palettes, sleek and sophisticated looks, clean uncluttered aesthetics.' Its reject-list (glassmorphism, ultra-minimalism, neo-brutalism, hidden gestures, low-contrast, confetti, streaks, can't-skip celebrations) is your banned list, pre-validated. Its core test — does the emotional tone fit the state users arrive in? — is the question to ask of every screen.
- **Graham Pullin — 'Design Meets Disability' (MIT Press), esp. Ch.1 'Fashion meets discretion'** https://mitpress.mit.edu/books/design-meets-disability
  - Steal: The discretion-vs-DISCUSSION axis, and the line about 'decades of pink plastic aids... designed to be camouflaged or hidden: to go unseen.' Glasses de-stigmatized through confident visibility, not invisibility. Read Ch.1 before designing Show Mode — Show Mode is this product's discussion moment and the entire stigma battleground.
- **Atkinson Hyperlegible Next + Mono — Braille Institute (Feb 2025)** https://www.brailleinstitute.org/freefont/
  - Steal: Seven weights (finally including Medium 500 and SemiBold 600 — the brief's requirement, impossible with the original), a variable font, 150+ languages, and a Mono. Free, OFL. Two typographic voices from one accessibility-native family: humanist for tiles, Mono for the type-to-speak field. Bundle the variable TTF as an asset — this app is offline.
- **Emergency Chat — Jeroen De Busser** https://lifeonautism.wordpress.com/2016/10/06/aac-app-review-emergency-chat/
  - Steal: The exact interaction pattern, already validated by an autistic adult for this exact use case a decade ago: open → splash screen explains to a stranger you can't speak → hand the phone over. Steal the flow and the customizable stranger-facing text. Its aesthetic investment is zero and it's distributed via a Facebook page — that gap IS the wedge. Install it and use it before designing Show Mode.
- **Spoken — Tap to Talk AAC** https://spokenaac.com/
  - Steal: The attention button (one tap = flashlight strobe + custom sound, framed as 'a substitution for verbal cues like clearing one's throat') — steal the idea, but opt-in, default-off, sub-3Hz, with sound/vibration-only options. Also study its positioning: the only competitor explicitly claiming adult-first design, and therefore the real threat. Its blind spot is that it's typing/prediction-first and networked.
- **AssistiveWare — 'Why don't all buttons in Proloquo have symbols?'** https://www.assistiveware.com/blog/proloquo-buttons-symbols
  - Steal: Ammunition: the award-winning app ships 9,000+ text-only buttons vs 4,500+ symbolized ones. Text-only outnumbers symbols 2:1 in the category's most decorated product. Cite this whenever anyone says text-only is a downgrade. Corollary: if the tile is text, the tile IS typography — put the entire craft budget there.
- **Santos & Ferrari — 'Aesthetics and the perceived stigma of assistive technology for visual impairment' (Disability & Rehabilitation: AT, 2020)** https://www.tandfonline.com/doi/full/10.1080/17483107.2020.1768308
  - Steal: The peer-reviewed citation that turns 'I want it beautiful' into a retention requirement: modern-aesthetic devices without disability symbolism (smart glasses) were accepted more than traditional-aesthetic ones (white cane). Pair with Oro's 'Designing for Dignity' (IntechOpen) for the abandonment argument and the Rollz Flex 2 vs Medline walker quote pair ('it makes me feel old. I wish it looked less like hospital equipment').
- **AirPods Pro as OTC hearing aid — recognition data** https://audioxpress.com/article/perception-stigma-and-ergonomics-in-hearing
  - Steal: The killer stat for any pitch deck: traditional hearing aids (RIC/BTE) were identified as hearing aids by ~80% of respondents; AirPods only 22%. And AirPods are big, white, and highly visible — they de-stigmatized by being a DESIRABLE OBJECT, not a hidden one. This is Pullin's eyewear thesis, quantified, in the current decade.
- **Open Bionics Hero Arm — as a CAUTIONARY reference** https://openbionics.com/our-story/
  - Steal: Steal: swappable covers as identity expression ('less like a medical device and more as a medium for self-expression') → your theme system. Do NOT steal: Marvel/Star Wars/Disney licensing and 'Hero' branding. That's the child market's answer (the design research was conducted with children), and for autistic adults it's the mascot ban in a cooler jacket. Note Proloquo2Go's idea of inclusivity progress is 'female superhero icons' — the category is still stuck here.
- **Priya Khanchandani — 'I feel bombarded by so-called wellness design', Dezeen (Jan 2026)** https://www.dezeen.com/2026/01/29/wellness-opinion-priya-khanchandani/
  - Steal: The vocabulary for rejecting the spa aesthetic as a THIRD failure mode alongside grey-enterprise and cartoon-child: wellness design 'offers essentially comfort — a highly aestheticised, deeply exclusive form of it' and is 'a vague signifier for something that feels quite nice.' Calm/Endel/Oak are optimized for lingering; this app is optimized for exit. Returned 403 to my fetcher — read it directly.
- **Speech Assistant AAC — official User Manual v6.4 (the incumbent, read adversarially)** https://www.asoft.nl/SpeechAssistantAAC-Android-UserManual.pdf
  - Steal: Nothing — read it to find the seams. Its own manual: '3 scrollable areas with buttons... the other buttons can be made visible by scrolling down.' Scrollable button regions destroy the motor planning that fixed grids exist to protect. It has the right features (full-screen large-font display mode!) buried under 2013 Android form-design. Every review praises customization; none praises design.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PRODUCT ===

An offline AAC (augmentative & alternative communication) app for autistic adults and teens with situational/part-time speech loss — people who can usually speak but go non-speaking during shutdowns, meltdowns, or sensory overload. Flutter, Android-first. Solo developer.

The app is ONE screen: a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface. Tap a tile, the phone speaks it aloud (or shows it in huge text — a co-equal "show mode" where you turn the screen to a stranger). Plus an edit mode and settings. No accounts. No network. Nothing leaves the device.

=== THE DESIGN BRIEF FROM THE FOUNDER (verbatim, and it is the point of this research) ===

"I don't want something like the design of ten years ago. I don't want something formal. I want something creative. I want something beautiful."

Take this seriously and literally. The default failure mode of an "accessible, calm, adult" app is that it becomes a grey rectangle grid that looks like a 2014 enterprise settings screen. That is the thing to avoid. The founder is asking for craft, personality, and beauty — and the research must find how to deliver that WITHOUT breaking the constraints below, not treat the constraints as an excuse to be boring.

=== WHAT PRIOR RESEARCH ESTABLISHED (do not re-litigate; design WITHIN these, or argue explicitly and with evidence where a constraint is softer than it looks) ===

- **The wedge is dignity.** Every mainstream AAC app is designed for children — cartoon avatars, mascots, puzzle pieces, primary-color rainbows, star/reward motifs, "Great job!" copy, parental gates. Adults abandon them. BANNED, permanently: cartoon avatars, mascots, animal characters, puzzle-piece iconography, gamification, streaks, badges, confetti, encouragement copy, any "parent/caregiver" framing.
- **CRITICAL NUANCE, and the opening for this whole research:** the study behind this found infantilization was about **VOCABULARY and being treated as a student — NOT about color**. The prior brief's own conclusion: *"DO NOT confuse 'adult' with 'monochrome and cold.' You can be warm and adult. The enemy is cartoon avatars and parental gates — not saturation."* So "adult" does NOT mandate grey. This is the permission slip. Use it.
- **Zero animation.** Two independent reasons: (a) distress/trauma-informed guidance warns against sudden motion for sensitized nervous systems; (b) animation costs latency in a product whose premise is instant speech. Honor `MediaQuery.disableAnimationsOf` → zero duration. **So beauty here CANNOT come from motion. It must come from composition, type, color, material, and craft. Print has been beautiful for 500 years without moving.**
- **Sensory sensitivity is the audience's defining trait.** Muted, low-saturation, ~2-5 intentional hues; high saturation only as sparing accents. But saturation and contrast are SEPARABLE — muted hues at high luminance contrast is the target.
- **Dark, light, AND high-contrast themes, all switchable in ONE TAP from the main screen.** Dark mode is contested in the research: [While & Sarvghad 2024](https://arxiv.org/pdf/2409.10841) found each polarity benefits comparable proportions and recommends shipping both; observers with cloudy ocular media read 10-15% better in dark. So dark is a choice, not the answer. **The dominant halation lever is TEXT luminance, not background hex** (#FFFFFF→#E0E0E0 drops contrast 21:1→15.91:1, a 24% cut; #000→#121212 only moves 21:1→18.73:1).
- **Material 3 is Flutter's default since 3.16.** M3's baseline dark surface is #141218 (neutral tone 6) with tone-based surface containers, NOT M2's #121212 + elevation overlays. Use `ColorScheme.fromSeed`.
- **Huge targets** (76dp floor, 12dp min gaps), 3x4 grid default with a 2x3 "large" option, **fixed tile positions** (no reflow ever — position IS the retrieval mechanism), highest-value tiles in the **lower-CENTER arc** (not upper-left; not the extreme bottom edge).
- **Typography**: system font or Atkinson Hyperlegible (Braille Institute, OFL). Tile labels min 17pt, default ~20pt, weight 500-600. MUST honor TextScaler to 200%+ without clamping. No dyslexia font as default (OpenDyslexic *decreased* fluency in the studies) but offer it as an option.
- **Show mode is the exception to the calm rule** — a cashier reads it at arm's length in daylight. Dark/low-luminance is right for the user's eyes and WRONG for a stranger reading the screen. Opposite optimizations.
- **Fitzgerald Key part-of-speech coloring is out** (each tile is a whole utterance, so grammar coloring is meaningless). But **category color-coding is fine and useful** for findability — the research explicitly did NOT find color-coding infantilizing.
- Symbols are v1+, text-only for MVP, and text-only stays first-class (for many literate adults the symbol set IS the infantilizing element). If symbols ship: Mulberry, runtime-tinted.
- The user may be in a shutdown: reduced decision-making, possible motor imprecision. One-handed. Phone, not tablet.
- Voice/identity matters: this audience skews trans/nonbinary; 4/12 wanted nonbinary/middle-pitch voices.

Today is 2026-07-15. Prefer 2025-2026 sources. Design moves fast — a 2019 article on "modern mobile design" is describing history.


YOUR DIMENSION: The "not ten years ago" audit. What EXACTLY makes an app look dated, and what does the AAC category look like today?

- **Go look at the actual competitors** and describe their visual design honestly and specifically: Proloquo2Go, Proloquo (the 2021 one — it won an Apple Design/App Store award for Cultural Impact, so it's presumably the best-looking in the category — WHAT DOES IT ACTUALLY LOOK LIKE? Go find screenshots and describe its design language in detail), Proloquo4Text, Speech Assistant AAC (the direct incumbent — describe its design; it's a decade-old indie app), TouchChat, LAMP, Avaz, CoughDrop, Spoken (a newer, VC-ish entrant — what does it look like?), Cboard, AsTeRICS Grid, Emergency Chat. Use WebSearch/WebFetch to find screenshots, App Store listings, press, design case studies, Behance/Dribbble.
- For each: what specifically dates it? What does it get right? **What would a 2026 designer do differently?**
- **Is there ANY beautiful AAC app?** If Proloquo won an App Store Award for Cultural Impact, that's the bar. Find out what its design actually does. Be specific.
- **The broader "assistive tech looks like medical equipment" problem**: research the design discourse on this. Eone watches, Aira, Be My Eyes, OrCam, hearing aids as fashion (Eargo, Apple AirPods Pro as hearing aids — a MASSIVE example of destigmatization through design), prosthetics (Open Bionics' Hero Arm — deliberately beautiful, superhero-branded), Rebecca Cokley/disability design discourse, "design for disability" (Graham Pullin's book "Design Meets Disability" — its central thesis is about eyewear: glasses went from medical appliance to fashion. THAT IS EXACTLY THIS PRODUCT'S THESIS. Go deep on Pullin). What are the transferable lessons?
- **The checkable "looks old" list**: give a concrete audit checklist a developer can run against their own screens. Be specific: what corner radius is dated? what shadow? what type weight? what color treatment? what layout? what iconography?
- **What does 2026-current look like in adjacent categories that are doing it well** — note-taking, meditation/calm apps (Endel, Oak, Calm — but beware, these are often TOO soft/spa-like for this audience; is "calm app" aesthetic actually infantilizing in a different direction? Interrogate that), journaling, health, indie iOS apps that win design awards. What's transferable and what's a trap?

Be specific and honest. Screenshots described in words. Name what to steal and what to avoid.
````

</details>
