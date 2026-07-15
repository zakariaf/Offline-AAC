# flutter-tts--flutter-tts-has-zero-personal-voice-support

> Phase: **verify** · Agent `a4bd4155d7a201957` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim's substance is correct and current as of 2026-07-15. Two refinements: (1) Their supporting evidence about the GitHub issue search is wrong — searching the repo for "personal voice" returns 0 results, not 1 unrelated 2020 Linux/Windows issue; the absence is even cleaner than they described. (2) getVoices exposes name, locale, quality, gender, AND identifier (not just quality as stated) — still no voiceTraits. (3) Forking is not strictly required: a standalone platform channel calling only requestPersonalVoiceAuthorization suffices, after which unmodified flutter_tts getVoices/setVoice would see and select the Personal Voice by identifier — you simply cannot identify it AS personal without voiceTraits. The claim already allows the platform-channel path, so this narrows rather than overturns it.

**Evidence:** Attempted refutation on five independent fronts; all failed. (1) SOURCE: Fetched ios/Classes/SwiftFlutterTtsPlugin.swift from master directly — zero matches for personal, requestPersonalVoiceAuthorization, AVSpeechSynthesisPersonalVoiceAuthorizationStatus, voiceTraits, isPersonalVoice, AVSpeechSynthesisVoice.Traits. (2) getVoices confirmed to read AVSpeechSynthesisVoice, exposing voiceDict["name"]=voice.name, ["locale"]=voice.language, ["quality"]=voice.quality.stringValue, ["gender"]=voice.gender.stringValue, ["identifier"]=voice.identifier — i.e. MORE fields than the researcher stated (they said only quality), but never voiceTraits. (3) NOT OUTDATED: CHANGELOG reviewed through latest 4.2.5; pub.dev confirms 4.2.5 is current, published ~6 months ago (~Jan 2026) by verified publisher eyedeadevelopment.com. The plugin has actively shipped iOS voice work recently (4.1.0 iOS 18 sample-rate fix, 3.8.5 AVSpeechSynthesisVoiceGender availability, 3.8.4 iOS voice info fields, 4.2.4 iOS audio category mapping) and still never added Personal Voice — so this is a deliberate/persistent gap, not a stale 2023 finding. (4) NO PR IN FLIGHT: scanned all PRs (state=all, sorted by updated desc); only voice-related PR is #637 "feat (voices): add getCurrentVoice getter (Android only)", open, updated 2026-06-16. Nothing pending changes this. (5) APPLE MECHANISM CONFIRMED — the causal step the conclusion depends on holds: personal voices do NOT appear in AVSpeechSynthesisVoice.speechVoices() until AVSpeechSynthesizer.requestPersonalVoiceAuthorization grants, and are identified via voiceTraits == .isPersonalVoice (iOS 17+). TWO CORRECTIONS, neither fatal: (a) Their GitHub issue-search evidence does not reproduce — GitHub API search repo:dlutton/flutter_tts "personal voice" returns total_count: 0, not "1 unrelated 2020 issue about Linux/Windows desktop support"; a broader term search returned only unrelated getLanguages/iOS-synthesis issues (#139, #290, #130). The citation is inaccurate; the conclusion it supported is unaffected and in fact strengthened. (b) "Requires forking" is overstated as stated in isolation: because getVoices calls speechVoices() at call time, a small STANDALONE platform channel that merely calls requestPersonalVoiceAuthorization would cause personal voices to appear in UNMODIFIED flutter_tts getVoices, selectable via setVoice by identifier — you just couldn't label them as personal without voiceTraits. The claim's own wording ("forking the plugin OR writing a platform channel") already covers this, so it is a sharpening rather than a refutation. UNSETTLED: Apple's requestPersonalVoiceAuthorization doc page failed to render, so entitlement/Info.plist requirements are unconfirmed against the primary source (Ben Dodson mentions none). PRODUCT READ for offline AAC: Personal Voice is reachable without forking but is unshipped plugin surface the team would own, iOS-17+, iOS-only, and requires the user to have pre-recorded a voice — a post-MVP dignity upgrade, not MVP TTS path.

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

CLAIM: flutter_tts has ZERO Personal Voice support — using Personal Voice requires forking the plugin or writing a platform channel
THEIR DETAIL: I grepped the plugin's iOS source (ios/Classes/SwiftFlutterTtsPlugin.swift) for personal/requestPersonalVoiceAuthorization/voiceTraits/isPersonalVoice — no matches. A GitHub issue search for 'personal voice' on the repo returns 1 result, and it is an unrelated 2020 issue about Linux/Windows desktop support. The plugin DOES surface voice.quality (premium/enhanced/default) in getVoices, so it reads AVSpeechSynthesisVoice, but never calls the authorization API and never exposes voiceTraits. Since Personal Voice only appears in speechVoices() AFTER requestPersonalVoiceAuthorization succeeds, an unmodified flutter_tts app will never see a Personal Voice at all.
THEIR CLAIMED SOURCES: https://github.com/dlutton/flutter_tts, https://raw.githubusercontent.com/dlutton/flutter_tts/master/ios/Classes/SwiftFlutterTtsPlugin.swift
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
