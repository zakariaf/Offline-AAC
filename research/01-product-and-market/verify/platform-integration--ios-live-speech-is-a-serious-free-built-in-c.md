# platform-integration--ios-live-speech-is-a-serious-free-built-in-c

> Phase: **verify** · Agent `a539cee8025dd0f1a` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** iOS Live Speech is a serious, free, built-in competitor whose feature inventory the researcher described accurately: saved phrases, user-created categories with icons (20 stock icons), triple-click Accessibility Shortcut invocation, and Apple Watch support via Digital Crown triple-click (type or pick a favorite phrase). All of these verify against Apple's primary documentation and are current as of iOS 26.

However, two claims must be corrected:

(1) The "unbeatable structural advantage on time-to-first-word" is false. While the triple-click Accessibility Shortcut is genuinely reserved for Apple's built-in features, third-party apps have several near-equivalent no-look hardware launch paths: Back Tap (Settings > Accessibility > Touch > Back Tap explicitly lists every third-party app as a launch target), the Action Button via Shortcuts on iPhone 15 Pro and later, and — since iOS 18 — Lock Screen controls that can replace the default Flashlight/Camera buttons plus Control Center controls via ControlWidget. A well-configured third-party AAC app lands within a fraction of a second of Live Speech. The advantage is a real onboarding/default-state edge (Apple's works with zero configuration), not a structural one.

(2) Live Speech does NOT "already do the core MVP job." It is a type-to-speak text field plus a flat list of text phrases organized into icon-labeled categories. It has no grid of large tiles and no per-phrase symbol/picture support — precisely the MVP's central artifact. It is also iOS/watchOS/macOS only and has no bearing on Android, half the intended Flutter target.

Strategic read: Live Speech should reset expectations about willingness-to-pay for a plain type-to-speak app on iOS, and it makes "free type-to-speak" a non-differentiator there. But the defensible product surface — symbol/tile grid, adult visual design, Android coverage, cross-platform parity — is untouched by it.

**Evidence:** MECHANICAL FACTS — ALL CONFIRMED against Apple primary docs:
- Live Speech is free, built-in, no account. Confirmed (support.apple.com/en-us/105018, apple.com/accessibility/speech).
- Saved phrases AND user-created categories with icons: CONFIRMED. Apple docs: "go to Settings > Accessibility > Live Speech, then tap Phrases. Tap the plus button, enter a name for the category, choose an icon, then tap Done." 20 icons available.
- Triple-click side/Home button (Accessibility Shortcut) invocation: CONFIRMED.
- Apple Watch: CONFIRMED. watchOS guide states "Triple-click the Digital Crown, choose Live Speech if you have more than one accessibility shortcut enabled," then "type what you'd like to have spoken or choose a favorite phrase," with Settings > Accessibility > Live Speech > Favorite Phrases.
- iPhone/iPad/Mac/Watch availability: CONFIRMED. Feature is current, not stale — Apple's iPhone guide references iOS 26/18/17.
- Offline: not explicitly stated in fetched pages, but Live Speech uses on-device TTS voices (Personal Voice is processed on-device); no contradicting evidence found. Treat as likely-true but not independently nailed down.

THE LOAD-BEARING CONCLUSION — REFUTED:
"Third-party apps CANNOT register for it. This is an unbeatable structural advantage on time-to-first-word."
The Accessibility Shortcut (triple-click) is indeed reserved for Apple's built-in accessibility features — that narrow sub-claim holds. But it is NOT the only hardware/no-look path to launching an app, so the advantage is not structural or unbeatable:
1. BACK TAP (Settings > Accessibility > Touch > Back Tap) — Apple's own docs and multiple sources confirm the action list includes "a list of every app on your device... including both native and third-party ones." Double/triple-tap the back of the phone opens a third-party AAC app directly. This is itself an accessibility feature, no-look, one-handed, and supported on a wider install base than the Action Button.
2. ACTION BUTTON (iPhone 15 Pro and later) — Apple docs: "Swipe to Shortcut, tap Choose a Shortcut" — a shortcut can open any third-party app on a single long press.
3. iOS 18+ LOCK SCREEN CONTROLS / CONTROL CENTER — WWDC24 session 10157 (ControlWidget). Third-party controls can replace the default Flashlight and Camera controls at the bottom of the Lock Screen (precedent: Halide launches from Lock Screen while device is locked), and appear in the Controls Gallery.
Net: the gap is a fraction of a second plus one settings toggle, not a moat.

"ALREADY DOES THE CORE MVP JOB" — OVERSTATED:
- Live Speech's phrases UI is a text field plus a flat LIST of text phrases grouped into categories. No Apple documentation describes a grid of large tiles, nor symbol/picture/image support on phrases. The stated MVP is "a grid of large customizable phrase tiles + symbols" — Live Speech does not provide that.
- Category icons exist at the CATEGORY level only (20 stock icons), not per-phrase symbols.
- iOS/watchOS/macOS only. It is irrelevant to the Android half of the Flutter cross-platform target, where no equivalent built-in exists.

CONFIDENCE ADJUSTMENT: researcher's "high" confidence is justified for the feature inventory, unjustified for the strategic conclusion.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "platform-integration". A product decision depends on it, so it must be right.

CLAIM: iOS Live Speech is a serious, free, built-in competitor that already does the core MVP job — including saved phrases, user-created categories, offline operation, and Apple Watch support
THEIR DETAIL: Invoked by triple-click of the side/Home button (Accessibility Shortcut). Settings > Accessibility > Live Speech > Phrases supports saved phrases AND custom categories with icons. Available iPhone/iPad/Mac/Watch; on Apple Watch via triple-click of the Digital Crown → type or pick a favorite phrase. Crucially, Live Speech gets the triple-click Accessibility Shortcut, which is reserved for built-in accessibility features — third-party apps CANNOT register for it. This is an unbeatable structural advantage on time-to-first-word.
THEIR CLAIMED SOURCES: https://support.apple.com/en-us/105018, https://support.apple.com/guide/iphone/type-to-speak-iphcf92d2d9b/ios, https://support.apple.com/guide/watch/type-to-speak-apd86a007717/watchos, https://www.apple.com/lae/accessibility/speech/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
