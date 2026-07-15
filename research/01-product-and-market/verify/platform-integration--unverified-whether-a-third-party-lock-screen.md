# platform-integration--unverified-whether-a-third-party-lock-screen

> Phase: **verify** · Agent `a6ad532dd0e9ca6d6` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** Both points ARE documented by Apple; the claim's "no documentation found" is a search failure from citing only WWDC24 10157 (which never covers authentication). (1) Third-party control AppIntents run WITHOUT unlock by default: AppIntent.authenticationPolicy defaults to .alwaysAllowed — "allows the intent to run without authentication, including when the device is locked." Authentication is opt-in via .requiresAuthentication / .requiresLocalDeviceAuthentication. The researcher likely conflated Controls with interactive Lock Screen WIDGETS, whose buttons/toggles genuinely ARE inactive until unlock — a different surface. (2) AudioPlaybackIntent conformance routing an intent to the app's process is explicitly documented: "if the intent conforms to AudioPlaybackIntent, ForegroundContinuableIntent, LiveActivityIntent, or PushToTalkTransmissionIntent, the system performs the app intent in the app's process." Controls share this execution model per WWDC24 10157 ("Just like with interactive widgets, the control executes actions using an app intent"), and ControlWidgetButton is documented for "fire-and-forget actions such as playing a sound." Remaining real risks are narrower than claimed: the Controls page doesn't restate process-routing, and speaking from a locked/backgrounded app process needs the audio background mode plus AVAudioSession activation. Confidence should be raised from low to moderate-high; the genuine blocker for this project is that ControlWidget/AppIntent require native Swift and cannot be written in Flutter.

**Evidence:** See evidence field.

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

CLAIM: UNVERIFIED: whether a third-party Lock Screen Control can run its AppIntent without Face ID/passcode unlock, and whether AudioPlaybackIntent conformance works from a Control
THEIR DETAIL: Apple's own flashlight/camera Lock Screen controls work without unlock, but no documentation found confirming third-party control intents run pre-authentication, nor confirming a Control can host an AudioPlaybackIntent to reach the app process for audio. Both are plausible and both are load-bearing for the best-case iOS design. MUST be settled by a device spike before committing to this path.
THEIR CLAIMED SOURCES: https://developer.apple.com/videos/play/wwdc2024/10157/
THEIR CONFIDENCE: low

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
