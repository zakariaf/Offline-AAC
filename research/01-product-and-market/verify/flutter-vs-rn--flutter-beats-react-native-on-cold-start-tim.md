# flutter-vs-rn--flutter-beats-react-native-on-cold-start-tim

> Phase: **verify** · Agent `a1b35a8589f16ae0c` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Flutter is plausibly equal to or slightly faster than React Native to first frame, but this is NOT established as a cold-start advantage. The cited 2025 SynergyBoat figures measure a vsync-quantized frame-presentation interval within a running process (Flutter's iOS 16.67ms is exactly one 60Hz frame period), not launch from a cold process; the same run has Swift native "losing" to Flutter with an SD larger than its mean over n=3, which invalidates the metric. Both cited sources are non-independent vendor blogs (SynergyBoat is a Flutter agency; the bolderapps cold-start numbers are uncited). Separately, the Impeller claim is wrong as stated: Impeller is the only renderer with Skia removed on iOS, whereas on Android it is default on API 29+ only, still falls back to legacy OpenGL below API 29 or without Vulkan, still has a (3.38-deprecated but functional) opt-out flag, and removal of the legacy Skia backend on Android 10+ is an explicit 2026 roadmap goal, not shipped. Impeller's build-time shader precompilation and its jank reduction are real and documented. Real-world cold start (~1-2s, dominated by process spawn and TTS engine init) is where the mid-shutdown launch requirement actually lives, and no reliable framework comparison exists for it — so this dimension should not drive the Flutter-vs-RN decision.

**Evidence:** NUMBERS QUOTED ACCURATELY, BUT THE METRIC AND A KEY SUB-CLAIM DO NOT HOLD.

1) The numbers are real. WebFetch of the SynergyBoat page confirms every figure verbatim: iOS Flutter 16.67ms (SD 1.25), RN 32.96ms (SD 0.16), Swift 41.37ms (SD 54.75); Android Flutter 10.33ms (SD 4.5), RN 15.31ms (SD 0.46), Kotlin 16ms (SD 0); iPhone 16 Plus / Galaxy Z Fold 6, 100-item list, 3 runs. Nothing was invented.

2) The metric is vsync-quantized and therefore cannot be cold start. iPhone 16 Plus ran at 60Hz = 16.67ms frame period. Flutter's iOS "TTFF" is 16.67ms — EXACTLY one vsync interval to 4 significant figures. RN's 32.96ms is ~two intervals (33.33ms). On the 120Hz Fold 6 (8.33ms period), Kotlin reports 16.00ms with SD of exactly 0 — ~two intervals with zero variance across 3 runs. Genuine elapsed launch timings do not land precisely on display-refresh multiples. Stated methodology (CADisplayLink / Choreographer, "automated scrolling with identical layouts and distances") confirms these are frame-presentation intervals inside an already-running process. The researcher's caveat is too weak: TTFF here is not merely "not the same as" cold launch, it does not measure process launch at all.

3) The benchmark self-invalidates. Swift native (41.37ms) losing to Flutter (16.67ms) by 2.5x on Apple's own platform is implausible for true time-to-first-frame — native has no engine runtime to initialize. Swift's SD (54.75ms) EXCEEDS its mean (41.37ms) over n=3, so at least one run was a massive outlier and the distribution is meaningless. n=3, one device per platform, trivial app, no confidence intervals, no significance testing.

4) Neither source is independent or primary. SynergyBoat is a Flutter development agency (commercial stake); its own summary reads "Flutter is fastest and smoothest... React Native needs more tuning." WebFetch of the bolderapps article confirms it "provides no citations or links to primary benchmark sources" for its cold-start numbers (~250ms Flutter vs ~350ms RN). Two blogs — one conflicted, one uncited — are not corroboration.

5) The Impeller sub-claim is FACTUALLY WRONG as of 2026-07-15, conflating iOS with Android. Primary source docs.flutter.dev/perf/impeller: Impeller is "the only supported rendering engine on iOS with no ability to switch to Skia" — that is iOS. On Android it is "available and enabled by default on Android API 29+," falls back to the legacy OpenGL renderer below API 29 or without Vulkan, and the opt-out STILL EXISTS (`flutter run --no-enable-impeller`; `io.flutter.embedding.android.EnableImpeller` manifest meta-data), deprecated in 3.38 but present. flutter/flutter Roadmap.md lists "completing the migration to the Impeller renderer on Android, and removing the legacy Skia backend on Android 10 and above" as a 2026 GOAL — planned, not shipped. So "default on modern Android" = true; "only renderer, Skia removed" = false. The shader-precompilation benefit is real and documented ("Impeller precompiles a smaller, simpler set of shaders at engine-build time so they don't compile at runtime").

6) The RN baseline moved. Hermes V1 shipped as default JS engine in RN 0.84 with build-time bytecode precompilation; New Architecture default since 0.76; old bridge retired in 0.82. The 2025 benchmark does not state its RN version/config, so it may measure a superseded RN.

7) Decision relevance is near zero. Published real cold-start figures scatter by an order of magnitude (1.2s vs 1.6s; 2.1s vs 2.8s; "Flutter ~2s vs RN 4s Android/10s iOS"; "Flutter under 200ms"; "RN 300-400ms") — no controlled measurement exists. A 16ms-vs-33ms first-frame gap is imperceptible mid-shutdown; actual launch latency for this AAC app will be dominated by process spawn and on-device TTS engine initialization, which neither source measures.

BOTTOM LINE: directionally Flutter is plausibly equal-or-faster to first frame, but the cited evidence does not establish a cold-start advantage, the sources are not independent, and the Skia-removed-on-Android specific is incorrect. Choose Flutter on other grounds (single codebase, Impeller jank reduction, team preference), not on this benchmark.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "flutter-vs-rn". A product decision depends on it, so it must be right.

CLAIM: Flutter beats React Native on cold start / time-to-first-frame on both platforms
THEIR DETAIL: 2025 benchmark (iPhone 16 Plus / Galaxy Z Fold 6, 100-item list, 3 runs each): iOS TTFF — Flutter 16.67ms (SD 1.25), RN 32.96ms (SD 0.16), Swift native 41.37ms (SD 54.75). Android TTFF — Flutter 10.33ms (SD 4.5), RN 15.31ms (SD 0.46), Kotlin native 16ms. Caveat: TTFF is not the same as user-perceived cold launch from a cold process, and these are trivial apps; treat as directional. Directionally it favors Flutter, which matters for a mid-shutdown launch. Impeller is now the default and only renderer on modern Android with Skia removed, eliminating first-run shader-compilation jank — historically Flutter's worst 'first tap feels bad' failure.
THEIR CLAIMED SOURCES: https://www.synergyboat.com/blog/flutter-vs-react-native-vs-native-performance-benchmark-2025, https://www.bolderapps.com/blog-posts/flutter-vs-react-native-in-2026-why-the-new-architecture-and-impeller-2-0-changed-everything
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
