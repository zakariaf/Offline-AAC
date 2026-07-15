# flutter-tts--personal-voice-is-usable-by-third-party-aac

> Phase: **verify** · Agent `a4f3ac34153310519` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Personal Voice IS usable by third-party AAC apps, works fully offline (generated and played on-device), and requires no entitlement, no Info.plist key, and no Apple approval beyond standard app review — Apple explicitly named AAC as the intended use case in WWDC23-10033. All of that is confirmed, including the API flow (requestPersonalVoiceAuthorization → .isPersonalVoice trait), the "Allow Apps to Request to Use" gate, revocability, the absence of a Settings deep link, and .denied-vs-.unsupported on older devices.

CORRECTION to the onboarding constraints, which are outdated: as of iOS 26 (shipped Sept 2025), Personal Voice requires only 10 recorded phrases and takes LESS THAN A MINUTE to create on-device — not ~150 prompts, ~15 minutes of recording, and 3+ hours of processing while plugged in and idle. Those were the iOS 17 (2023) figures. Apple rebuilt the feature on on-device ML, announced May 2025, and also added a short three-word-phrase option for users who have difficulty reading full sentences. Note that AssistiveWare's Proloquo documentation still cites the old 150-phrase figure and should not be trusted on this point; Apple's newsroom and accessibility pages are current.

ADDITIONAL CAVEATS not in the original claim: Personal Voice is iOS-only with no Android equivalent, and is not exposed by flutter_tts — it requires a custom Swift platform channel, making it a platform-conditional enhancement rather than a cross-platform feature. Combined with the undiagnosable failure path (.denied on unsupported devices + no deep link to the toggle), it should be treated strictly as progressive enhancement layered over a standard on-device TTS baseline, never as a dependency.

**Evidence:** I tried to refute this and could not break the core claim — every load-bearing element survives primary-source checking. But one specific in their DETAIL is materially outdated, and it happens to be the one that most affects the product decision.

WHAT SURVIVES (all CONFIRMED):

1. "Usable by third-party apps, no entitlement, no Info.plist key, no approval beyond app review" — CONFIRMED by two independent sources. Ben Dodson's writeup documents the full implementation with no entitlement or plist key anywhere. Stronger evidence: AssistiveWare's Proloquo — a real, shipping, third-party AAC app — documents using Personal Voice via ordinary iOS voice selection, with no entitlement or approval process. A shipping competitor doing exactly this is about as good as existence proof gets. I searched specifically for a hypothetical NSPersonalVoiceUsageDescription key and found no evidence any such key exists.

2. "Works fully offline / on-device" — CONFIRMED. WWDC23-10033 quote verified verbatim: "Your Personal Voice is generated on the device and not on a server." Apple's current accessibility page independently confirms: "Personal Voice is created on your device to keep your information private and secure." Generation and playback are both local. (Nuance: iCloud sync of an encrypted voice copy across devices is optional, not required — it does not compromise the offline story.)

3. "Apple named AAC as the intended use case" — CONFIRMED. WWDC23-10033 quote verified verbatim: "usage of Personal Voice is sensitive and should be primarily used for augmentative or alternative communication apps." This is unusually favorable — Apple explicitly blessing this product category is not a case of stretching a general-purpose API.

4. API surface (requestPersonalVoiceAuthorization, .isPersonalVoice trait via voiceTraits, speechVoices()), the Settings > Accessibility > Personal Voice > "Allow Apps to Request to Use" gate, revocability, no openSettingsURLString deep link to the Personal Voice panel, and .denied-instead-of-.unsupported on older supported devices — all CONFIRMED by Dodson, with the Settings toggle independently corroborated by AssistiveWare. Dodson's exact wording on the deep link: "Your app settings also do not contain any mention of Personal Voice, even when enabled, so you can't link to UIApplication.openSettingsURLString to get the user to view these settings."

THE ONE REAL ERROR — the onboarding-friction numbers are iOS 17-era and stale:

Their claim: "~150 prompts, ~15 min, and processing takes 3+ hours plugged in and idle."

That was true at iOS 17 launch. It is no longer true. Apple Newsroom (May 2025) announced Personal Voice rebuilt on on-device ML: users "create a smoother, more natural-sounding voice in less than a minute, using only 10 recorded phrases." This shipped in iOS 26 (Sept 2025). Apple's current accessibility page confirms the live state: "Read through a series of 10 randomized phrases," created "in less than a minute," with a three-word-phrase option for users who struggle with full sentences.

The researcher appears to have anchored on 2023-2024 sources (WWDC23 + Dodson 2024) without checking whether the constraint still held in 2026. Note the trap: AssistiveWare's Proloquo page STILL says "150 phrases" and "a few hours to days" — a stale third-party page that would have confirmed their number. Apple's own primary sources override it.

WHY THE CORRECTION MATTERS (it cuts in the product's favor):

The researcher listed the 150-prompt/3-hour flow as a constraint — implying Personal Voice is a high-friction, niche add-on. The real number is 10 phrases in under a minute, on-device. For an app targeting situational speech loss, that reframes Personal Voice from "power-user feature almost nobody will complete" to something a user could plausibly set up during onboarding. The three-word-phrase option is also directly relevant to this audience.

REMAINING CAVEATS FOR THE FLUTTER DECISION (not errors, but gaps the claim doesn't address):

- iOS-only. Personal Voice has no Android equivalent, so in Flutter this is a platform-conditional enhancement requiring a Swift platform channel — AVSpeechSynthesizer's Personal Voice APIs are not exposed by flutter_tts. This is a real integration cost the claim does not mention.
- The .denied-vs-.unsupported ambiguity plus the missing deep link means the failure path is genuinely bad UX: you cannot tell the user why it failed, nor send them to the toggle. Treat Personal Voice strictly as progressive enhancement over a standard on-device TTS baseline — never a dependency.
- I could not read Apple's developer.apple.com API reference pages directly (JS-rendered; WebFetch returns only the title). The API specifics rest on WWDC23, wwdcnotes, Dodson, and a shipping third-party AAC app rather than a rendered reference page. They agree with each other, so I rate this high-confidence, but flagging that the entitlement question is confirmed by absence-of-evidence plus a working competitor implementation, not by an explicit Apple statement saying "no entitlement required."

CORRECTED CONFIDENCE: high on the core claim; the researcher's "high" was justified on substance, but their constraint detail should not have been rated high without a recency check.

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

CLAIM: Personal Voice IS usable by third-party AAC apps, works fully offline, and needs no entitlement or Apple approval — Apple named AAC as its intended use case
THEIR DETAIL: iOS 17+. Flow: AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in ... }, then voices appear in AVSpeechSynthesisVoice.speechVoices() carrying the .isPersonalVoice trait (filter via $0.voiceTraits). WWDC23-10033: 'Your Personal Voice is generated on the device and not on a server' and 'usage of Personal Voice is sensitive and should be primarily used for augmentative or alternative communication apps' — the session literally demos an AAC app. Per Ben Dodson's implementation writeup, NO special entitlement and NO Info.plist key are required, and no approval beyond standard app review. Constraints: user must first record Personal Voice (~150 prompts, ~15 min) and processing takes 3+ hours plugged in and idle; user must enable Settings > Accessibility > Personal Voice > 'Allow Apps to Request to Use'; users can revoke anytime; there is NO openSettingsURLString deep link to the Personal Voice panel, so you cannot send the user straight to the toggle; older-but-supported devices return .denied rather than .unsupported, so you cannot cleanly explain failure.
THEIR CLAIMED SOURCES: https://developer.apple.com/videos/play/wwdc2023/10033/, https://wwdcnotes.com/documentation/wwdc23-10033-extend-speech-synthesis-with-personal-and-custom-voices/, https://bendodson.com/weblog/2024/04/03/using-your-personal-voice-in-an-ios-app/, https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/personalvoiceauthorizationstatus-swift.type.property
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
