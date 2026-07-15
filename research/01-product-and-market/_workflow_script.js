export const meta = {
  name: 'aac-research',
  description: 'Research the offline adult-first AAC app idea: features, UX, Flutter feasibility, competitive landscape',
  phases: [
    { title: 'Research', detail: 'parallel researchers across 10 dimensions' },
    { title: 'Verify', detail: 'adversarially verify load-bearing claims' },
    { title: 'Critique', detail: 'completeness critic + missing dimensions' },
    { title: 'Synthesize', detail: 'merge into feature spec + architecture' },
  ],
}

const FINDINGS_SCHEMA = {
  type: 'object',
  properties: {
    dimension: { type: 'string' },
    summary: { type: 'string', description: '3-6 sentence executive summary of what you found' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          claim: { type: 'string', description: 'A specific, falsifiable factual claim' },
          detail: { type: 'string', description: 'Supporting detail, numbers, specifics' },
          sources: { type: 'array', items: { type: 'string' }, description: 'URLs actually fetched/searched' },
          confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
          loadBearing: { type: 'boolean', description: 'True if a product decision hinges on this claim' },
        },
        required: ['claim', 'detail', 'confidence', 'loadBearing'],
      },
    },
    productImplications: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          implication: { type: 'string' },
          priority: { type: 'string', enum: ['must-have-mvp', 'should-have-v1', 'nice-to-have-later', 'explicitly-avoid'] },
          rationale: { type: 'string' },
        },
        required: ['implication', 'priority', 'rationale'],
      },
    },
  },
  required: ['dimension', 'summary', 'findings', 'productImplications'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    refuted: { type: 'boolean', description: 'True if the claim is wrong, outdated, or unsupported' },
    verdict: { type: 'string', enum: ['CONFIRMED', 'PARTIALLY_TRUE', 'REFUTED', 'UNVERIFIABLE'] },
    correction: { type: 'string', description: 'If not fully confirmed, the corrected version of the claim' },
    evidence: { type: 'string' },
    sources: { type: 'array', items: { type: 'string' } },
  },
  required: ['refuted', 'verdict', 'evidence'],
}

const IDEA = `
PRODUCT IDEA UNDER RESEARCH — "Dignified offline AAC for adults & teens with situational speech loss"

Who it's for: Autistic adults and teens who go non-speaking during shutdowns/meltdowns/sensory overload, plus people with selective mutism, aphasia, or post-seizure speech loss. Communities: r/autism, r/AutisticAdults, r/selectivemutism, AAC communities.
The problem: Mainstream AAC apps are built for young children — cartoon avatars, "parental" account gates, kiddie vocabulary — infantilizing for adults, so they abandon them. Premium options (Proloquo2Go/TouchChat/LAMP) run ~$299 and are iOS-only.
Why offline is essential: It's a disability accommodation, not a networked service. The user must be able to "speak" instantly — in a shop, an ER, a car with no signal, mid-shutdown — with zero login, zero loading, full privacy.
The core job: Tap a phrase/symbol tile (or type) and the phone speaks it aloud, instantly, offline, adult-appropriate design, no account.
MVP: grid of large customizable phrase tiles + "type to speak" box + on-device TTS. Editable categories. No sign-up. Nothing leaves device. Dark, calm, adult visual design.
Risks: TTS must sound acceptable; design must feel adult without being cold; must be usable one-handed by someone in distress.
Target stack: Flutter (cross-platform iOS + Android; user prefers Flutter over React Native).
Today's date: 2026-07-15. Prefer recent sources (2024-2026).
`

const DIMENSIONS = [
  {
    key: 'user-needs',
    label: 'user-needs-situational-mutism',
    prompt: `${IDEA}

YOUR DIMENSION: The real lived needs of adults with SITUATIONAL / intermittent speech loss.

Research deeply using WebSearch and WebFetch. Look for first-person accounts (Reddit r/autism, r/AutisticAdults, r/selectivemutism, r/aphasia, AAC user blogs, AssistiveWare's "AAC user" content, Twitter/X threads, forums), academic literature on "part-time AAC users", "situational mutism", "autistic shutdown communication", "intermittent speech loss".

Answer specifically:
- What actually happens cognitively/motorically during an autistic shutdown or meltdown? Can the person read? Can they navigate menus? Can they type? What motor precision remains? Does the app need to work when the user CANNOT process text?
- What do part-time/ambulatory AAC users say they need that full-time AAC users don't? (e.g., fast onboarding into the app mid-episode, no category diving, explaining to others why you're using a phone)
- What is the "explain to bystanders" problem? Do users need a way to tell a stranger/cop/doctor "I am autistic and cannot speak right now"? How important is this?
- What are the specific highest-frequency phrases these users report needing? Gather ACTUAL reported phrase lists.
- What causes abandonment of AAC by adults? Gather specifics.
- How do users get INTO the app during a shutdown? (lock screen, widget, watch, launch time) Is app-launch itself a barrier?
- What role does the phone's existing behavior play (notification sounds, brightness) during sensory overload?

Return concrete, sourced findings. Quote real user language where you find it.`,
  },
  {
    key: 'aac-clinical',
    label: 'aac-clinical-standards',
    prompt: `${IDEA}

YOUR DIMENSION: AAC clinical/SLP domain knowledge and evidence-based design standards.

Research using WebSearch and WebFetch. Sources: ASHA, AssistiveWare Learn AAC, ISAAC, PrAACtical AAC, CommunicationMatrix, academic papers on AAC design, USSAAC, Speech-language pathology literature.

Answer specifically:
- Core vocabulary vs. fringe vocabulary: what is it, what are the actual high-frequency core word lists, and does core vocabulary matter for a PHRASE-based adult app or is that a kid-AAC paradigm? Be critical — the product is phrase-based, is that clinically defensible?
- Motor planning / motor automaticity in AAC (LAMP Words for Life's premise): why do serious AAC apps keep button positions FIXED? What does this imply for a phrase-tile grid that users can edit/reorder? Is dynamic reordering (e.g. "most used floats to top") actively harmful?
- What are the recognized AAC access methods? (direct touch, scanning, switch access, eye gaze, partner-assisted scanning, head tracking) Which matter for this audience?
- What is "AAC modeling" and does it apply to adults?
- Symbol sets: PCS, SymbolStix, ARASAAC, Mulberry, Blissymbols, Open Symbols. Which are FREE / openly licensed for commercial use? Which look adult vs. childish? Licensing terms and cost specifics matter a lot — get exact license names and fees.
- What does the literature say about text-based vs symbol-based AAC for literate adults?
- Rate enhancement techniques: word prediction, phrase prediction, abbreviation expansion. What is proven?
- Any established guidance specifically about AAC for autistic adults or acquired/intermittent conditions?

Be rigorous and cite sources.`,
  },
  {
    key: 'competitive',
    label: 'competitive-landscape',
    prompt: `${IDEA}

YOUR DIMENSION: Competitive landscape — verify the market gap claim rigorously and adversarially.

Research using WebSearch and WebFetch. Check App Store, Google Play, product sites, review sites.

Answer specifically and with CURRENT (2025-2026) data:
- Proloquo2Go, Proloquo (the new subscription one), TouchChat, LAMP Words for Life, Speech Assistant AAC, Predictable, Grid for iPad, CoughDrop, Avaz, LetMeTalk, Cboard, AAC BoardMaker, Leeloo, Otsimo, Jabberwocky, Voiceitt, Talkitt, Speech Blubs, Tobii Dynavox apps. For each relevant one: platform(s), price/model, offline capability, adult-appropriateness, target audience.
- CRITICALLY TEST THE CORE CLAIM: "no one has built the adult-first, tasteful, offline version". Search HARD for counterexamples. Look for: apps marketed to adults, apps for aphasia/stroke survivors (this is an ADULT market with existing apps — e.g. Lingraphica, Tactus Therapy, Constant Therapy, SmallTalk), apps for ALS/MND users (adult!), selective mutism apps, "text to speech" apps used AS AAC (e.g. Speech Assistant AAC, Voice Aloud, Natural Reader), and the built-in iOS "Live Speech" feature (iOS 17+) and Android equivalents. Does iOS Live Speech already solve the type-to-speak job for free?
- What about generic TTS/soundboard apps that adults already repurpose? What do users say about them?
- Is Proloquo2Go really ~$299 and iOS-only in 2026? Verify. What is Proloquo (2023+) priced at now? What is TouchChat priced at? Any Android options?
- CoughDrop is open-source-ish and cross-platform — how does it compare? Is it offline?
- Are there open-source AAC projects (Cboard, Open AAC, AsTeRICS) and what are their gaps?
- What is the actual size/reachability of this audience?
- Funding paths: are AAC apps covered by insurance/Medicaid/NHS? Does that shape the market? (SGD funding requires dedicated devices historically)

Your job is to try to REFUTE the market gap claim. Report honestly whether the gap is real, partial, or already filled.`,
  },
  {
    key: 'flutter-tts',
    label: 'flutter-tts-feasibility',
    prompt: `${IDEA}

YOUR DIMENSION: Flutter + offline TTS technical feasibility. This is the #1 technical risk.

Research using WebSearch and WebFetch (pub.dev, GitHub issues, Flutter docs, Apple docs, Android docs, Stack Overflow).

Answer specifically for 2026:
- flutter_tts package: current version, maintenance status, open issue count, known bugs. Does it support offline/on-device voices? How do you FORCE offline-only and guarantee no network call? (AVSpeechSynthesizer is on-device by default; Android TextToSpeech may route to Google's servers for some voices — verify, and find how to check/require KEY_FEATURE_NOT_INSTALLED / isNetworkTts / EngineInfo)
- On iOS: AVSpeechSynthesizer — voice quality tiers (Compact / Enhanced / Premium), how a user downloads Enhanced/Premium voices, can an app trigger that download or prompt? What are Personal Voice (iOS 17+) and can a third-party app use it? (AVSpeechSynthesisProviderVoice / Personal Voice authorization API) Is Personal Voice usable offline by a 3rd party app? THIS IS A BIG DEAL for this product — verify carefully.
- On Android: Google TTS engine vs Samsung TTS vs others. How to enumerate voices, check offline availability, force offline. Quality of Android offline voices in 2026.
- Latency: what is realistic time-to-first-audio for on-device TTS on iOS and Android? Is "instant" achievable? Any warm-up trick (pre-synthesizing to a file/buffer)? Can you pre-render tile phrases to audio files at edit time and just play a cached file for zero latency? Evaluate this idea.
- Alternatives if flutter_tts is inadequate: writing a thin platform channel to AVSpeechSynthesizer/Android TextToSpeech directly; bundling a neural TTS (Piper, Sherpa-ONNX, Coqui, Kokoro) — is on-device neural TTS via sherpa_onnx viable in Flutter in 2026? App size cost? Licensing? Quality vs OS voices? Which packages exist (e.g. sherpa_onnx Flutter bindings)?
- Audio session config: does the app duck other audio? Play through silent switch? Route to speaker vs bluetooth? Interruption handling? This matters — user in a shop with earbuds in must have speech come out the SPEAKER.
- Does TTS work when device is on silent/mute? (iOS AVAudioSession category .playback vs .ambient)
- Background/lock screen speaking?

Be brutally specific with package names, versions, API names, and known pitfalls.`,
  },
  {
    key: 'flutter-vs-rn',
    label: 'flutter-vs-react-native',
    prompt: `${IDEA}

YOUR DIMENSION: Flutter vs React Native for THIS SPECIFIC app in 2026. The user prefers Flutter — validate or challenge that honestly.

Research using WebSearch and WebFetch. Consider 2026 state: Flutter (post-Impeller, current stable), React Native (New Architecture / Fabric, Expo).

Answer specifically:
- ACCESSIBILITY: This is the crux. An AAC app must itself be accessible (VoiceOver/TalkBack, Switch Control/Switch Access, Dynamic Type / font scaling, Reduce Motion, high contrast, AssistiveTouch). Flutter renders its own canvas and maps to platform a11y APIs via SemanticsNode — how good is Flutter's accessibility in 2026 really? Known gaps? React Native uses native views — is it materially better for a11y? Find specific evidence, bug reports, and expert opinion. Does Flutter support iOS Switch Control properly? Does Flutter respect iOS Dynamic Type automatically? What about Android Switch Access?
- Does Flutter honor system text scaling by default? What breaks?
- App size: baseline Flutter vs RN app size on iOS and Android.
- Cold start time: Flutter vs RN — matters because user launches mid-crisis.
- Platform integrations needed: Home Screen widget (iOS WidgetKit / Android App Widget), Lock Screen widget, Control Center / Quick Settings tile, Siri Shortcuts / App Intents, Action Button (iPhone 15 Pro+), Apple Watch app, Wear OS. Flutter CANNOT write widgets in Dart — they must be native SwiftUI/Jetpack Glance. How painful is this in Flutter vs RN? Which packages help (home_widget)?
- Text input / IME quality: Flutter's custom text field vs native. Any issues with keyboards, autocorrect, dictation, or third-party keyboards?
- TTS support parity in each ecosystem.
- Long-term maintainability for a solo dev; ecosystem health of both in 2026.
- Desktop/web reach: does Flutter's web/desktop support matter here? Would a web build (PWA, offline via service worker) be a good extra channel?

Give an honest recommendation with reasoning. If Flutter is right, say why. If there are real risks, name them and name the mitigation.`,
  },
  {
    key: 'design-distress',
    label: 'design-for-distress-and-dignity',
    prompt: `${IDEA}

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

Give concrete, implementable design rules, not vague principles.`,
  },
  {
    key: 'platform-integration',
    label: 'platform-integration-and-speed-to-speak',
    prompt: `${IDEA}

YOUR DIMENSION: "Time to first word" — every OS-level path to speaking FAST, and what's possible in 2026.

The core insight to test: if a user is mid-shutdown, unlocking a phone, finding an app, waiting for launch, and navigating to a tile may itself be too slow/too hard. Research every OS affordance that shortens this.

Research using WebSearch and WebFetch (Apple developer docs, Android developer docs, WWDC/Google IO content, Flutter packages).

Answer specifically for iOS and Android in 2026:
- iOS Home Screen widgets (WidgetKit): can a widget contain tappable buttons that trigger an action WITHOUT opening the app? (AppIntent + interactive widgets, iOS 17+). Can a widget SPEAK audio directly? Verify — this is the killer feature if true. What are the limits (memory, execution time, audio playback from an AppIntent in a widget extension)?
- iOS Lock Screen widgets: interactive? Can they run AppIntents? (iOS 18+?) Can you speak from the lock screen without unlocking?
- iOS Control Center widget / Controls (iOS 18 ControlWidget) — can a third-party control run an AppIntent? Could a Control speak a phrase?
- iPhone Action Button + Apple Watch Action button: can it launch a Shortcut that speaks a phrase? Does that work offline?
- Siri Shortcuts / App Intents: "Hey Siri, say I need help" — but user cannot speak. Shortcuts run from Back Tap? Accessibility > Touch > Back Tap can run a Shortcut — verify. That's a double-tap-on-back-of-phone to speak. Huge if true.
- Apple Watch: standalone AAC on the wrist? Watch speaker volume? Is a watch app worth it?
- iOS Live Speech (Accessibility feature, iOS 17+): what is it exactly, how is it invoked (triple-click side button?), does it have saved phrases, and does it already do this job? Be honest — this may be a serious competitor built into the OS.
- iOS Personal Voice: how it works, offline, and whether Live Speech / third-party apps can use it.
- Android: App Widgets (Jetpack Glance), Quick Settings Tiles (can a QS tile speak?), Assistant shortcuts, Android accessibility shortcuts, lock screen options, Wear OS.
- Android: can an app play TTS audio from a widget/tile broadcast without opening? (Foreground service? Broadcast receiver?)
- Flutter interop: home_widget package, quick_actions, flutter_shortcuts, app_intents. What's the state of writing AppIntents/WidgetKit widgets alongside a Flutter app? Any known working recipes for interactive widgets from Flutter?
- What about a persistent notification with action buttons that speak? Android notification actions / iOS notification actions.
- Screen-off / pocket use?

Rank these paths by (impact x feasibility). Be concrete about what is actually possible vs. marketing.`,
  },
  {
    key: 'data-architecture',
    label: 'data-model-and-offline-architecture',
    prompt: `${IDEA}

YOUR DIMENSION: Data model, local storage, and offline-first architecture in Flutter for 2026.

Research using WebSearch and WebFetch (pub.dev, benchmarks, GitHub).

Answer specifically:
- What is the right AAC data model? Research how AAC boards are modeled: boards, buttons, grids, links, categories, vocabulary sets, "pagesets". Look at the Open Board Format (OBF / .obz) from Open AAC / CoughDrop — is it a real interop standard? Should this app import/export OBF? What about Proloquo/TouchChat/Grid proprietary formats?
- Local DB choice in Flutter 2026: Drift (SQLite), Isar (is it maintained? there were maintenance concerns — verify current status), Hive / Hive CE, ObjectBox, sqflite, Realm (Atlas Device SDK was deprecated — verify), sembast, or just JSON files. For a small phrase set (<2000 tiles) with images, what's right? Consider: cold start speed, no-network guarantee, migrations, and solo-dev maintainability.
- Backup/restore WITHOUT a server: the user has no account and nothing leaves the device — but they will get a new phone or lose the phone. How do you handle backup while keeping the privacy promise? Options: iCloud/Google Drive app-scoped backup (is it "leaving the device"?), iOS/Android automatic device backup (does app data get included by default? Documents vs Library/Caches, allowsCloudBackup / android:allowBackup), manual export to a file, AirDrop/share sheet, QR code, local file. What's the honest recommendation? What's the privacy story to tell the user?
- Does iOS automatic iCloud backup include app documents by default? Android auto-backup default behavior and 25MB limit?
- Custom images on tiles (user photos): storage, size, migration. Photos of family members etc. Should tiles support photos?
- Custom recorded audio per tile (user's own voice or a loved one's voice, or a pre-recorded phrase): is this better than TTS for some phrases? Storage implications.
- Settings/state: what persists? Should the app remember scroll position/last board? Should it RESET to home on relaunch (a distressed user should always land in a known state) — argue both sides.
- Migration/versioning strategy for a data model that users have hand-customized. What happens on app update?
- Encryption at rest: is it needed? These phrases are intimate ("I am being hurt", medical info). iOS Data Protection classes, Android encryption defaults. What's appropriate?

Give a concrete recommendation with reasoning.`,
  },
  {
    key: 'legal-regulatory',
    label: 'legal-regulatory-and-store',
    prompt: `${IDEA}

YOUR DIMENSION: Legal, regulatory, app store, and licensing constraints.

Research using WebSearch and WebFetch.

Answer specifically:
- Is an AAC app a regulated MEDICAL DEVICE? Check FDA (US) — is AAC software a device? What about the FDA's stance on "general wellness" / low-risk devices and the enforcement discretion policy? Check EU MDR (EU) — is AAC software Class I? Does the EU MDR / MDCG 2019-11 guidance capture communication aids? What about UK MHRA? Real answer needed — many AAC apps ship without clearance, why? Is there a specific exemption/classification? (Look for FDA product codes, e.g. for "augmentative communication device", and the "Speech Generating Device" classification, and whether SOFTWARE-ONLY is treated differently.)
- App Store / Play Store: any special rules for medical/accessibility apps? Apple guideline 1.4.1 (physical harm) / 5.1 medical data? Any risk of rejection for an app that claims medical benefit? How should the app describe itself to avoid trouble while still being findable?
- Age rating implications: an AAC app with a fully editable text-to-speech field can speak ANY text. Any store issue with UGC? (An app with a free-text field is technically UGC only if shared — it's local, so probably fine. Verify.)
- Accessibility law: does the EU Accessibility Act (EAA, applicable June 2025) apply to a mobile app like this? What compliance does it require? What about ADA/Section 508 (US) — do private apps have obligations? Does the app need a VPAT? Would EN 301 549 / WCAG 2.1/2.2 AA conformance be required or advisable?
- Privacy law: if truly nothing leaves the device, what's still required? Apple Privacy Nutrition Label (must be filled even if "no data collected"), Google Play Data Safety section, and what about crash reporting/analytics — does adding Sentry/Firebase break the privacy promise? Is there a privacy-preserving analytics option? What must a privacy policy say? Is a privacy policy required at all by both stores? (Yes for Play — verify.)
- COPPA / children: audience includes TEENS. Any implications? Age rating choice?
- Symbol licensing (CRITICAL): exact license and cost for ARASAAC (CC BY-NC-SA — the NC clause is a problem for a paid app! verify), Mulberry Symbols (CC BY-SA 2.0?), SymbolStix (commercial license, cost?), PCS/Boardmaker (commercial, cost?), Open Symbols aggregator, Blissymbolics, Sclera, Tawasol, Global Symbols. Which can a commercial/paid app legally ship? What about Noun Project, Material Symbols, SF Symbols (SF Symbols license restricts to Apple platforms and to system-like use — verify)? Emoji? Give a concrete, safe recommendation.
- Voice licensing: are OS TTS voices free to use in a commercial app? Any Apple/Google restriction on using the system synthesizer in a paid app? Any restriction on RECORDING TTS output to a file (Apple's AVSpeechSynthesizer write API and terms)? THIS MATTERS if pre-rendering audio.
- Font licensing for any bundled font.
- Liability: what if the app fails at a critical moment (medical emergency)? What disclaimer is standard? Look at what existing AAC apps disclaim.

Be precise and cite sources. Flag anything that could kill or reshape the product.`,
  },
  {
    key: 'business-model',
    label: 'business-model-and-distribution',
    prompt: `${IDEA}

YOUR DIMENSION: Business model, pricing, and reaching this audience — for a solo/indie developer building an offline, no-account app.

Research using WebSearch and WebFetch.

Answer specifically:
- How do you monetize an app with NO SERVER and NO ACCOUNT? Options: one-time purchase, freemium with IAP unlock, subscription (hard to justify with no server + hostile to disabled users on fixed incomes), donation, free+open-source, "pay what you want". What do successful indie accessibility apps do? Find real examples with real numbers.
- What is the disability community's attitude toward paid accessibility apps and subscriptions? Research the backlash to AssistiveWare's Proloquo subscription move (2023) — what happened, what did users say? This is directly relevant. Also research general "accessibility tax" discourse.
- Pricing anchoring: Proloquo2Go ~$249-299 makes almost anything look cheap. What's the right price? What do comparable apps charge (Speech Assistant AAC, Predictable, CoughDrop)? Is free-with-optional-tip viable?
- Distribution/reach: how do you actually reach autistic adults and selective mutism communities? Reddit rules on self-promotion in r/autism / r/AutisticAdults (they're strict — verify current rules). What works: SLP/AAC professional channels, Mastodon, TikTok, disability Twitter, ISAAC, AAC Facebook groups, word of mouth, r/AAC?
- Would autistic adults trust a for-profit closed-source app that promises "nothing leaves your device"? Does open-sourcing materially increase trust/adoption here? What are the trade-offs (monetization, copycats)?
- Funding: are there grants for assistive tech? (e.g., disability innovation grants, national AT programs, NIDILRR SBIR, EU funding, Apple/Google accessibility programs). Any indie-relevant ones?
- Is there any path where insurance/Medicaid/NHS/school district funding buys this? Probably not for a cheap app — but check AAC funding (SGD funding requires a "dedicated device" historically; has that changed?).
- App Store discoverability: what do people search? What ASO keywords matter? ("AAC", "text to speech", "nonverbal", "selective mutism", "speech app")
- What is the realistic TAM/SAM? Autistic adults, selective mutism prevalence, aphasia prevalence — get real numbers.
- Localization: does this need multiple languages to matter? TTS voice availability per language?

Give an honest, specific recommendation.`,
  },
  {
    key: 'failure-modes',
    label: 'failure-modes-and-red-team',
    prompt: `${IDEA}

YOUR DIMENSION: Red-team the product. Find the ways this fails that an enthusiastic founder would miss.

Research using WebSearch and WebFetch where useful, but also reason hard.

Investigate and report:
- The "adults don't want to be seen using an AAC app" problem: is there stigma? Do users prefer to look like they're just texting? Should the app be DISGUISED/discreet? Research what users say. Is a loud robot voice in a shop actually what they want, or would showing text on screen to the cashier be preferred? Does the product need a "show, don't speak" mode (big text on screen, or a screen you turn around)? Investigate seriously — this could invert a core assumption.
- The blank-slate problem: a fresh AAC app with empty tiles is useless. But pre-filling with someone else's phrases is presumptuous. How do serious AAC apps handle first-run? What is the right onboarding when the user might install it DURING a crisis (or never open it until a crisis)? Should there be starter sets? Who writes them?
- The "never opened until crisis" problem: user installs it, forgets it, and 6 months later during a shutdown cannot remember it exists or how it works. How do you solve discoverability-at-time-of-need? Is muscle memory a myth here? Does this argue for a widget/back-tap/watch?
- The customization paradox: the app is only good when customized, but customization requires the calm-state self to predict the crisis-state self's needs. Does anyone do that? Is there a "capture a phrase you needed" retro-flow?
- TTS voice quality: will OS voices actually be acceptable? What do AAC users say about robotic voices and identity/dignity? Voice = identity in AAC discourse. Is offering only OS voices a dignity failure — the same infantilization problem in a different form?
- What happens if the user's device is dead/lost? Paper backup? Is there a role for a printable card?
- Is "one screen, one job" actually achievable, or does every AAC app inevitably grow into a board editor with folders and become complex? What's the honest scope creep risk?
- Competition from the OS itself (iOS Live Speech, Android Live Caption/TTS) and from LLM keyboards.
- Is the phrase-tile paradigm right, or would a smarter approach win (fast-typing + prediction, or a small on-device LLM expanding "hurt loud leave" into a sentence)? Argue it.
- Will the audience actually pay? Autistic adults have high unemployment/underemployment rates — verify and quantify. What does that mean for pricing?
- Safety: could the app be misused (e.g. speaking something harmful)? Could the phrases be embarrassing if someone else picks up the phone? Does it need a lock? But a lock breaks instant access — tension!
- Accessibility of the EDITOR itself, not just the speaking screen.
- The multi-user problem: could a family member/caregiver need to help set it up? But no accounts...

Be brutally honest. Rank the risks by severity. For each, propose a mitigation or say it's unmitigable.`,
  },
]

phase('Research')
log(`Researching ${DIMENSIONS.length} dimensions in parallel, then adversarially verifying every load-bearing claim.`)

const researched = await pipeline(
  DIMENSIONS,
  (d) => agent(d.prompt, { label: `research:${d.key}`, phase: 'Research', schema: FINDINGS_SCHEMA, effort: 'high' }),
  (res, d) => {
    if (!res) return null
    const loadBearing = (res.findings || []).filter((f) => f.loadBearing)
    if (!loadBearing.length) return { dimension: d.key, research: res, verdicts: [] }
    return parallel(
      loadBearing.slice(0, 8).map((f) => () =>
        agent(
          `${IDEA}

You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "${d.key}". A product decision depends on it, so it must be right.

CLAIM: ${f.claim}
THEIR DETAIL: ${f.detail}
THEIR CLAIMED SOURCES: ${(f.sources || []).join(', ') || '(none given)'}
THEIR CONFIDENCE: ${f.confidence}

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.`,
          { label: `verify:${d.key}`, phase: 'Verify', schema: VERDICT_SCHEMA, effort: 'high' }
        ).then((v) => ({ claim: f.claim, ...(v || { refuted: true, verdict: 'UNVERIFIABLE', evidence: 'verifier failed' }) }))
      )
    ).then((verdicts) => ({ dimension: d.key, research: res, verdicts: verdicts.filter(Boolean) }))
  }
)

const ok = researched.filter(Boolean)
log(`${ok.length}/${DIMENSIONS.length} dimensions researched and verified.`)

const digest = ok
  .map((r) => {
    const corrections = r.verdicts
      .filter((v) => v.verdict !== 'CONFIRMED')
      .map((v) => `    - [${v.verdict}] "${v.claim}" → CORRECTION: ${v.correction || v.evidence}`)
      .join('\n')
    const confirmed = r.verdicts.filter((v) => v.verdict === 'CONFIRMED').map((v) => `    - [CONFIRMED] ${v.claim}`).join('\n')
    return `
### DIMENSION: ${r.dimension}
SUMMARY: ${r.research.summary}

FINDINGS:
${(r.research.findings || []).map((f) => `  - (${f.confidence}${f.loadBearing ? ', LOAD-BEARING' : ''}) ${f.claim}\n    ${f.detail}\n    sources: ${(f.sources || []).join(' | ')}`).join('\n')}

FACT-CHECK RESULTS:
${confirmed || '    (none confirmed)'}
${corrections || '    (no corrections)'}

PRODUCT IMPLICATIONS:
${(r.research.productImplications || []).map((p) => `  - [${p.priority}] ${p.implication} — ${p.rationale}`).join('\n')}
`
  })
  .join('\n---\n')

phase('Critique')
const critiques = await parallel([
  () => agent(
    `${IDEA}

Below is the full research corpus from 10 parallel researchers plus adversarial fact-checks. You are the COMPLETENESS CRITIC.

${digest}

What is MISSING? Identify:
1. Questions a serious product/eng lead would ask that nobody answered.
2. Claims that are still unverified but load-bearing.
3. Contradictions BETWEEN dimensions (e.g. one says X, another says not-X). List them explicitly.
4. Any dimension of the problem entirely unexplored.
5. Any place the research is just repeating the founder's assumptions back rather than testing them.

Use WebSearch/WebFetch to fill the most important gaps yourself. Return a prose critique with specifics and any new sourced facts you found.`,
    { label: 'completeness-critic', phase: 'Critique', effort: 'high' }
  ),
  () => agent(
    `${IDEA}

Below is the full research corpus. You are a SKEPTICAL SENIOR PRODUCT LEAD who has shipped accessibility software. Read it and write the honest "should we build this, and what exactly" memo.

${digest}

Address head-on:
- Is the market gap real after the fact-checking? What survived?
- Is iOS Live Speech / built-in OS features a fatal competitor for the type-to-speak half? What's left that's defensible?
- What is the ACTUAL smallest thing worth building — be ruthless.
- What are the top 3 things that will kill this, and what's the cheapest experiment to de-risk each BEFORE writing much code?
- Where is the founder's framing wrong?

Be direct. No cheerleading.`,
    { label: 'skeptic-memo', phase: 'Critique', effort: 'high' }
  ),
  () => agent(
    `${IDEA}

Below is the full research corpus. You are an AAC-experienced SPEECH-LANGUAGE PATHOLOGIST reviewing this product plan.

${digest}

Write a clinical review: what does this plan get right, what is clinically naive or harmful, what would you insist on before recommending this to a client, and what features would you add or remove? Use WebSearch/WebFetch to back up any clinical claims. Be specific about the part-time/situational AAC user population, since that is the target.`,
    { label: 'slp-review', phase: 'Critique', effort: 'high' }
  ),
])

const critiqueText = critiques.filter(Boolean).map((c, i) => `\n### CRITIQUE ${i + 1}\n${c}`).join('\n')

phase('Synthesize')
const spec = await agent(
  `${IDEA}

You are the lead product engineer. Below is (a) the verified research corpus from 10 dimensions with adversarial fact-checks, and (b) three critiques (completeness critic, skeptical product lead, SLP clinical review).

${digest}

${critiqueText}

Write the definitive research-backed product brief in MARKDOWN. It must be dense, specific, and honest — no filler, no cheerleading, no restating the idea back. The reader is the solo developer who will build this in Flutter.

Required structure:

# 1. What the research changed
The 5-8 findings that should actually change the plan vs. the original idea.md. Lead with anything that REFUTES or reshapes a founder assumption (especially: is the market gap real? does iOS Live Speech already do this? is "speak aloud" even what users want, vs. show-text?). Be blunt.

# 2. Who this is really for
Sharpened audience definition based on evidence, including what part-time/situational AAC users need that the original framing missed. Include the "explain to bystanders" job if research supports it.

# 3. Feature set
Three tables: MUST-HAVE (MVP), SHOULD-HAVE (v1), EXPLICITLY-NOT-DOING (with reasons). Every row: feature, why (with the research reason), rough complexity. Be ruthless about the MVP — it should be small.

# 4. The interaction model
Concretely describe the screens and the flows. Include time-to-first-word paths ranked by impact × feasibility (widget/back-tap/watch/control center/app icon). Say what happens on cold launch, on misfire, on undo. Describe the show-text mode if research supports it.

# 5. Design rules
Concrete, implementable rules: layout, thumb zones, tile sizes, grid dimensions, typography, color, dark/light, motion, haptics, and precisely what "adult, not infantilizing" means operationally. Include the fixed-position/motor-planning decision and justify it.

# 6. Architecture (Flutter)
Package-by-package. State management, local DB choice + why, data model (sketch the actual entities/schema), TTS layer + the offline guarantee + the pre-render decision, audio session config, native interop surface (widgets/intents), file layout of the Flutter project. Name real packages with real version constraints where known. Flag anything that needs a platform channel.

# 7. Flutter vs React Native
The honest verdict for THIS app, with the accessibility analysis front and center. Name the specific Flutter risks and their mitigations.

# 8. Risks
Ranked table: risk, severity, likelihood, mitigation, and the cheapest experiment to de-risk it before building.

# 9. Legal / licensing / store
What's actually binding: medical device status, symbol licensing (which symbol set to use and why — with the license), voice licensing, store rules, privacy labels, accessibility law.

# 10. Business model
The honest recommendation with reasoning.

# 11. Build order
A concrete sequenced plan. Phase 0 = the de-risking experiments (what to prototype first, in what order, and what result would kill/pivot the idea). Then milestones.

# 12. Open questions
What is still genuinely unknown and how to find out — including what to ask the actual user community.

Cite sources inline as markdown links where a claim is load-bearing. Where the fact-checkers corrected a researcher, use the CORRECTED version and say so. Where research was contradictory or unverifiable, SAY SO explicitly rather than papering over it — a "we don't know" is more useful than a confident guess.`,
  { label: 'synthesize-brief', phase: 'Synthesize', effort: 'max' }
)

return { spec, dimensionCount: ok.length }
