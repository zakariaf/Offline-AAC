# platform-integration--ios-back-tap-can-run-a-shortcut-double-or-tr

> Phase: **verify** · Agent `af4fa2b1398d0e8aa` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** iOS Back Tap CAN run a Shortcut (double or triple tap), works offline, and requires iPhone 8+ on iOS 14+ via Settings > Accessibility > Touch > Back Tap. It does NOT categorically require the phone to be unlocked. Back Tap can run shortcuts from the lock screen; unlocking is required only when the shortcut needs user input or must open an app. Since iOS 16.3, a per-shortcut Privacy toggle ("Allow Running When Locked") controls this, and locked execution appears to be the default. For App Intents, Apple's default permits invocation on a locked device — developers must opt in to `authenticationPolicy = .requiresAuthentication` to block it (WWDC26 session 347). Therefore a "Speak Phrase" intent with a pre-filled phrase parameter and openAppWhenRun = false is precisely the shape that CAN fire while locked, without unlocking.

The real constraint is different: Back Tap requires the screen to be awake/on, so "phone asleep in pocket" still fails — due to screen state, not authentication. This preserves the researcher's cautious conclusion about the mid-shutdown scenario but for the wrong reason, and understates the unlocked-but-locked-screen capability.

Genuinely open and worth prototyping first: whether TTS audio actually plays from a background App Intent on a locked device (depends on AVAudioSession configuration and background-audio entitlement). No primary source settles this; do not assume it works.

**Evidence:** MECHANISM AND SPECS CONFIRMED. Apple's Shortcuts User Guide: "The Back Tap Accessibility action lets you run a shortcut when you double-tap or triple-tap the back of your phone," via Settings > Accessibility > Touch > Back Tap > Double/Triple Tap. Apple HT/111772 confirms hardware/OS floor: "Back Tap requires the latest version of iOS on your iPhone 8 or later" and "with Back Tap in iOS 14 or later." Offline operation is sound (local shortcut, no network). The App Intents/Shortcuts exposure requirement is correct.

THE UNLOCK REQUIREMENT IS WRONG AS STATED — and this is the load-bearing part. Notably, NEITHER of their two cited Apple sources mentions any unlock requirement; both are silent on it. The requirement was asserted beyond what the cited sources support, and three independent lines of evidence contradict the blanket form:

(1) Back Tap is documented as a way to run shortcuts FROM the lock screen. Unlock is CONDITIONAL, not categorical: "if the shortcut requires input from you or needs to open an app, you will need to unlock your iPhone." Back Tap is listed explicitly as one of the lock-screen methods: "there's an even quicker way to run a shortcut from your lock screen, and it's called Back Tap."

(2) Since iOS 16.3 there is a per-shortcut Privacy toggle, "Allow Running When Locked," in the Shortcuts editor (Info icon > Privacy tab). It "allows you to optionally disable a shortcut from running while the device is locked" — phrasing that indicates locked execution is the DEFAULT, and the toggle exists to turn it off.

(3) DECISIVE — Apple's own WWDC26 session 347 ("Secure your app: mitigate risks to agentic features"): "you can interact with Siri on the lock screen, without having to first unlock your device... But this also means that an attacker in physical possession of a locked device can potentially invoke your intent via Siri." Mitigation requires developers to OPT IN via `static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication`. Apple frames locked execution as the permissive default that risky intents must opt out of.

WHY THIS FLIPS THE PRODUCT CONCLUSION: a "Speak Phrase" App Intent with a pre-baked phrase parameter and openAppWhenRun = false requires no user input and opens no app — exactly the shape that can execute while locked. Their conclusion that Back Tap "saves navigation time, not unlock time" inverts the actual affordance.

THE PESSIMISM IS STILL PARTLY RIGHT, VIA A DIFFERENT MECHANISM: Back Tap requires the screen to be awake/on. Sources indicate "Back Tap only works when the screen is on" and advise using it "when the iPhone is 'awake' or illuminated." So the "phone in pocket, mid-shutdown" scenario does still fail — but because of SCREEN STATE, not an unlock gate. The distinction matters for product planning: a screen-wake constraint and an authentication gate are different problems with different workarounds.

UNRESOLVED RISK I COULD NOT CLOSE (flagging rather than asserting): whether AVSpeechSynthesizer audio actually PLAYS from a background App Intent on a locked device is a separate question involving AVAudioSession category and the background-audio entitlement. No source settled this. This — not the unlock requirement — is the real thing to prototype before betting design on Back Tap. Confidence "high" was not warranted for the unlock assertion given zero support in the cited sources.

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

CLAIM: iOS Back Tap CAN run a Shortcut (double or triple tap on the back of the phone), works offline, but REQUIRES the phone to be unlocked
THEIR DETAIL: Settings > Accessibility > Touch > Back Tap > Double/Triple Tap > choose a Shortcut. iPhone 8+ / iOS 14+. The unlock requirement substantially weakens the 'mid-shutdown, phone in pocket' scenario — it saves navigation time, not unlock time. Still valuable: unlocked-phone-in-hand → double tap → speaks, with no app navigation. Requires the app to expose App Intents/Shortcuts actions (e.g. a 'Speak Phrase' intent with a phrase parameter).
THEIR CLAIMED SOURCES: https://support.apple.com/guide/shortcuts/run-shortcuts-tapping-iphone-apd897693606/ios, https://support.apple.com/en-us/111772
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
