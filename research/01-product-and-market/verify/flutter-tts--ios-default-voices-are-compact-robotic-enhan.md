# flutter-tts--ios-default-voices-are-compact-robotic-enhan

> Phase: **verify** · Agent `ac030fec5dbbaf68b` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** iOS default voices are basic quality (labeled "Compact" in the Settings UI, NOT in Apple's API docs, which say .default is "A basic quality voice that's available on the device by default"). Enhanced/premium "must be downloaded to use" per Apple's docs and are 100MB-to-~400MB manual downloads (the ">100MB" figure is Ben Dodson's blog, not Apple; Apple Support says "can be 100 MB or larger"). There is NO API to enumerate downloadable-but-not-installed voices and NO API to trigger a download — this is confirmed not by thread 758460 (which is an UNANSWERED developer question where the OP said "Ah ok, I found it" without ever sharing the answer) but by Apple Developer Forums thread 679401, where an Apple Frameworks Engineer states: "Only installed and usable voices will be returned by this API... Developers cannot initiate download requests on behalf of the user." Corroborated by thread 723503. Still true under iOS 26 as of July 2026, with new iOS 26 regressions reported (premium voices vanishing after reboot, downloads stalling), so even a detected enhanced voice may not persist. The flutter_tts iOS getVoices "quality" key (default/enhanced/premium) is verified in SwiftFlutterTtsPlugin.swift, so Compact-detection plus hand-written instructions is a valid workaround — and there is no public deep-link to the voices Settings pane either. Given this lands on the project's #1 risk, bundling an own on-device TTS voice should be evaluated alongside the onboarding fix.

**Evidence:** CORE CLAIM SURVIVES ADVERSARIAL CHECK; TWO SPECIFICS ARE WRONG.

CONFIRMED (primary sources):
1. Three tiers, exact wording. Apple docs JSON (developer.apple.com/tutorials/data/documentation/avfaudio/avspeechsynthesisvoicequality.json — HTML pages are JS-rendered and return only the title via fetch): .default = "A basic quality voice that's available on the device by default"; .enhanced = "An enhanced quality voice that you must download to use"; .premium = "A premium quality voice that you must download to use." The researcher's quoted "must be downloaded to use" is verbatim-accurate.

2. NO API to trigger or discover uninstalled voices — CONFIRMED, and by a STRONGER source than the researcher found. Apple Frameworks Engineer (staff) in forum thread 679401: "'Available' and 'installed' pretty much mean the same thing in this context. Only installed and usable voices will be returned by this API... Additional voices can be downloaded by the user in Settings > Accessibility > Spoken Content > Voices. Developers cannot initiate download requests on behalf of the user. If you request speech using a voice that isn't installed, then we will do our best to pick a suitable fallback voice that matches the same language code." Corroborated by thread 723503 (Apple staff, Jan 2023, Web Speech API): "it is expected that with Web Speech APIs only the pre-installed voices are available. Optionally downloadable voices are not available."

3. flutter_tts quality key — VERIFIED IN SOURCE. ios/Classes/SwiftFlutterTtsPlugin.swift getVoices returns dictionaries with keys name, locale, quality, gender (iOS 13+), identifier; quality stringifies to "default"/"enhanced"/"premium". The Compact-detection workaround is real and implementable.

4. NOT OUTDATED as of iOS 26 / 2026-07-15. No new API. Risk is arguably WORSE: AppleVis and Apple Community (discussions.apple.com/thread/256137942) report iOS 26 regressions where premium voices (e.g. Karen) disappear after reboot/power-off and downloads stall mid-way — so the app cannot rely on a detected voice remaining installed.

5. Download paths confirmed: Settings > Accessibility > Spoken Content > Voices (per Apple staff, 679401) and Accessibility > Live Speech > Voices (per Dodson). Both valid.

CORRECTIONS:
A. Thread 758460 does NOT confirm the no-API point. It is a developer ASSERTING the limitation in a question that received no Apple answer; the OP posted "Ah ok, I found it" without disclosing what, and a later commenter ("So what was the answer? I have the same requirement") went unanswered. Citing it as confirmation is a misread of an unresolved thread. The actual confirmation is thread 679401 (Apple staff). Right conclusion, wrong evidence.

B. "Compact" is not Apple API terminology. The word appears nowhere in AVSpeechSynthesisVoiceQuality docs; .default is documented as "basic quality." "Compact" is the Settings/VoiceOver UI label. The real-world mapping is defensible but must not be attributed to the API.

C. ">100MB each" is Ben Dodson's April 2024 blog figure, not Apple's. Apple Support 111798 says enhanced voices "can be 100 MB or larger"; 2025-2026 sources (mcmw.abilitynet.org.uk iOS 26 guide) put enhanced at ~400 MB. Directionally right, understated if anything, and secondary-sourced.

DECISION IMPACT: The engineering conclusion stands — no programmatic download trigger, no enumeration of uninstalled voices, no public deep-link to that Settings pane; hand-written onboarding instructions are the only lever. Unraised by the researcher: because this hits the stated #1 risk AND iOS 26 is actively breaking downloaded voices, bundling an on-device TTS voice/engine instead of depending on AVSpeechSynthesizer deserves evaluation as an alternative, not just better onboarding copy.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "flutter-tts". A product decision depends on it, so it must be right.

CLAIM: iOS default voices are Compact (robotic); Enhanced/Premium are >100MB manual downloads and NO API can trigger or discover them
THEIR DETAIL: AVSpeechSynthesisVoiceQuality has three tiers: .default (Compact), .enhanced, .premium. Enhanced and premium 'must be downloaded to use' and each exceed ~100MB. Users download them manually via Settings > Accessibility > Spoken Content > Voices (also reachable via Live Speech > Voices). Apple Developer Forums thread 758460 confirms there is NO API to enumerate voices that are available-for-download-but-not-installed; speechVoices() returns only what is already on device. Therefore the app cannot trigger a download and cannot even tell the user 'a better voice exists'. What you CAN do: flutter_tts's iOS getVoices returns a 'quality' key mapping to premium/enhanced/default, so you can detect that the user is stuck on a Compact voice and show hand-written instructions to go download a better one. This is a first-run onboarding problem, and it lands squarely on the project's stated #1 risk that 'TTS must sound acceptable'.
THEIR CLAIMED SOURCES: https://developer.apple.com/documentation/avfaudio/avspeechsynthesisvoicequality, https://developer.apple.com/forums/thread/758460, https://bendodson.com/weblog/2024/04/03/using-your-personal-voice-in-an-ios-app/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
