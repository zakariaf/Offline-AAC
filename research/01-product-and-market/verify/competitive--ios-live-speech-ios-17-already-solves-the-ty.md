# competitive--ios-live-speech-ios-17-already-solves-the-ty

> Phase: **verify** · Agent `a6dc6382f66a8b1c7` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** iOS Live Speech (iOS 17+, still shipping and improved in iOS 26) does deliver free, preinstalled, zero-login type-to-speak with saved favorite phrases, dozens of downloadable voices, Personal Voice, and Phone/FaceTime support — the core claim is sound and the sources are genuine. Three fixes: (1) It is invoked by TRIPLE-CLICKING THE SIDE BUTTON (Accessibility Shortcut), not from a Control Center panel, and since iOS 18 Favorites is NOT merely "a text list" — users can create custom CATEGORIES WITH ICONS alongside default Recent/Saved, so the quick-recall overlap is greater than claimed and the tile-grid wedge is narrower (individual phrases are still text rows, so no large-tile symbol grid and no distress-optimized one-handed layout — that gap survives, reduced). (2) "Works offline once voices are downloaded" is PLAUSIBLE BUT UNSOURCED — Apple never documents Live Speech's offline runtime; verify by airplane-mode device test before relying on it, since offline parity is the product's core premise. (3) "Every iPhone since 2023" should be "iOS 17+, iPhone XS or later." Critical omission: Live Speech is APPLE-PLATFORM-ONLY, so it poses no threat on Android — material to a Flutter cross-platform strategy.

**Evidence:** CORE CLAIM SURVIVES ADVERSARIAL CHECK. All three cited sources resolve and are genuine Apple primary sources — nothing invented. The feature exists, is current as of iOS 26 (2026), and was strengthened, not weakened, since 2023.

CONFIRMED against primary sources:
1. Feature/path exists: Settings > Accessibility > Live Speech, toggle on. Apple's own guide is titled "Type to speak using Live Speech on iPhone" (support.apple.com/guide/iphone/type-to-speak-iphcf92d2d9b/ios) and "Use Live Speech on your iPhone, iPad, Mac, or Apple Watch" (105018).
2. In-person + Phone/FaceTime: CONFIRMED. Apple: "you can use Live Speech to stay connected during Phone and FaceTime calls as well as in-person conversations."
3. Saved favorite phrases: CONFIRMED verbatim in the 2023 Newsroom release: "Users can also save commonly used phrases to chime in quickly during lively conversation with family, friends, and colleagues." Apple support confirms Favorite Phrases: Settings > Accessibility > Live Speech > Favorite Phrases > Add a phrase.
4. Dozens of system voices + Personal Voice: CONFIRMED. Voices require a Download tap before selection; Personal Voice "integrates seamlessly with Live Speech."
5. Free / preinstalled / no account / nothing leaves device: CONFIRMED directionally. Personal Voice uses "on-device machine learning to keep users' information private and secure," is "encrypted and stored securely on device."
6. STILL LIVE IN 2026 — the claim is not outdated. Personal Voice was improved: now needs only ~10 brief phrases (~1 minute) versus the original "15 minutes of audio," and iOS 26 ships faster-installing, more natural on-device voices.

THREE CORRECTIONS — one of which cuts AGAINST the researcher's comfort:

(A) "Favorites is a text list buried in a Control Center panel" — WRONG ON BOTH COUNTS, and this is the load-bearing error. Live Speech is invoked by TRIPLE-CLICKING THE SIDE BUTTON (the Accessibility Shortcut), not from a Control Center panel. Control Center is only an optional secondary route, and only if the user has added the Accessibility Shortcut control. More importantly, it is no longer a flat text list: iOS 18 added USER-CREATED CATEGORIES WITH CHOSEN ICONS on top of the default Recent and Saved categories ("tap a plus icon, enter a name for the category, choose an icon, then tap Done"). Apple explicitly pitched categories as a nonspeaking-user feature. The researcher's differentiation gap is therefore NARROWER than they assert — Apple has already moved toward organized quick-recall. The gap does survive, but in reduced form: category icons are icons for categories, while individual phrases remain text rows, so there is still no large-tile symbol grid and no one-handed distress-optimized tap-target layout.

(B) "Works offline once voices are downloaded" — PLAUSIBLE BUT NOT SUBSTANTIATED BY ANY PRIMARY SOURCE. This is the researcher's weakest link and they rated it "high" confidence. Apple nowhere documents that Live Speech functions offline. It is a reasonable inference (voices are explicitly downloaded to the device, and Apple's neighboring on-device claims cover Personal Voice storage/ML, not Live Speech runtime), but it is an inference, not a sourced fact. Given that "offline is essential" is the product's entire premise, this specific must be settled by DEVICE TESTING IN AIRPLANE MODE, not by citation.

(C) "Free on every iPhone since 2023" — imprecise. Correct framing: iOS 17+ (September 2023), which requires iPhone XS or later. True of every iPhone SOLD since 2023, but not of every iPhone in use.

BOTTOM LINE FOR THE PRODUCT DECISION: The researcher UNDERSTATED the threat rather than overstating it. Live Speech is real, free, zero-login, preinstalled, has saved phrases AND icon-labeled custom categories, and is actively invested in by Apple through 2026. But it is iOS-only — which leaves Android structurally uncontested by this particular threat, a point the claim omits entirely and which matters given the Flutter cross-platform target. The honest surviving wedge is: (1) Android entirely, (2) large-tile symbol grid, (3) one-handed distress layout, (4) adult AAC framing. "Apple has no quick-recall" is NOT a defensible wedge and should not be built into positioning.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "competitive". A product decision depends on it, so it must be right.

CLAIM: iOS Live Speech (iOS 17+) already solves the type-to-speak job — free, offline, preinstalled, zero-login
THEIR DETAIL: Settings > Accessibility > Live Speech. Type-to-speak aloud in person and on phone/FaceTime calls; supports SAVED FAVORITE PHRASES for quick recall (directly overlapping the tile-grid job); dozens of system voices plus Personal Voice. Works offline once voices are downloaded. Free on every iPhone since 2023 — no install, no account, nothing leaves device. This is the strongest structural threat: the free default is already installed on the user's phone, is already offline, and requires zero acquisition. What it lacks is a large-tile visual grid and one-handed distress-optimized layout — Favorites is a text list buried in a Control Center panel, not a tap-target grid.
THEIR CLAIMED SOURCES: https://support.apple.com/en-us/105018, https://support.apple.com/guide/iphone/type-to-speak-iphcf92d2d9b/ios, https://www.apple.com/newsroom/2023/05/apple-previews-live-speech-personal-voice-and-more-new-accessibility-features/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
