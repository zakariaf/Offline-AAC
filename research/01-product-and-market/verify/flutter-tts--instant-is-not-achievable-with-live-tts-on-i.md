# flutter-tts--instant-is-not-achievable-with-live-tts-on-i

> Phase: **verify** · Agent `af14ee3e0530794bb` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Accurate version: Apple Developer Forums document a real first-utterance cold-start latency in AVSpeechSynthesizer, reported since iOS 16.0, caused by loading per-language pronunciation rule data from disk. Two SEPARATE threads: 731238 (June 2023) reports 0.6-1+s generically with "[AXTTSCommon] Invalid rule:" in console; 715339 (Sept 2022-Apr 2023) measures the rule data directly — English 862KB/~0.25s, Italian 537KB/~0.7s, German 4.4MB/~3.2s — but only when switching to a newer high-quality German voice WITH a delegate set, on device (not Simulator). Apple requested a sysdiagnose (FB11380447) and did not resolve it as of Apr 2023; there is NO evidence either way for iOS 18-26, so treat current status as UNKNOWN and re-test on-device before designing around it.

The correct conclusion is the OPPOSITE of the claim's headline: because this is a one-time-per-language cost rather than per-tap, "instant" IS plausibly achievable with live TTS, and pre-rendering is likely premature optimization. Do not build a pre-render pipeline on this evidence — it cannot serve the "type to speak" box anyway (arbitrary text must be live), and flutter_tts synthesizeToFile is buggy (#312 multi-line → empty file, #272 no concurrency).

Recommended action: measure first, don't architect on a 2023 forum post. Build a throwaway Flutter probe, stopwatch speak()→didStart on a real device on current iOS, cold and warm. If the delay is real, try the (unproven, self-derived — not Apple-endorsed) mitigations in order: keep one synthesizer alive as a singleton, pre-activate the audio session at launch, then a silent warm-up utterance. Note flutter_tts has no warm-up API, so (a) and (c) may require a platform channel or fork. Only if warm-up demonstrably fails should pre-rendering be considered, and then only for fixed tiles with live TTS retained for typed text.

The localization point survives and is worth keeping: rule-data size varies ~8x by language, so a German/multi-language launch carries materially more cold-start risk than English-only. That argues for English-first and per-language on-device benchmarking before adding locales — not for abandoning live TTS.

**Evidence:** The forensic detail is largely ACCURATE — this researcher did not invent the numbers. But the citation is wrong, the mitigations are unsourced inference presented as documented fact, the evidence is 3-4 years stale, and the headline conclusion is overstated in a way that drives the wrong product decision.

WHAT CONFIRMS (impressively precise):
Thread 715339 is real: "AVSpeechSynthesizer iOS 15/16 lagging for seconds when switching to (different) German language voice" (Sept 2022 - Apr 2023). Verbatim figures match the claim almost exactly:
- German de-DE: 4,392,529 bytes disk rule data, ~3.2s load (10:55:07.636 → 10:55:10.818), 459 rules
- English en-US: 862,210 bytes, ~0.25s (10:55:16.148 → 10:55:16.407), 12,192 rules
- Italian it-IT: 536,565 bytes, ~0.7s
Console "[AXTTSCommon] Invalid rule:" immediately precedes the delay — confirmed. FB11380447 filed Sept 2022; Apple requested a sysdiagnose with Siri logging profile; no resolution as of Apr 2023 — confirmed. The lag is between speak() and the didStart delegate callback — confirmed.

FAILURE 1 — SOURCE CONFLATION. The headline "0.6-1s" figure is NOT in thread 715339. It comes from a DIFFERENT thread, 731238 ("AVSpeechSynthesizer delay issue, [AXTTSCommon] Invalid rule:", June 2023, author Kim Ju Young), which reports 0.6-1+s delays post-iOS 16.0. The claim welds two threads into one citation. Thread 715339 reports 3-4s German delays, not 0.6-1s.

FAILURE 2 — MITIGATIONS ARE UNSOURCED. Neither cited source contains ANY of mitigations (a) singleton synthesizer, (b) pre-activate AVAudioSession at launch, or (c) warm-up utterance of " " at volume 0. Thread 731238 explicitly proposes no workarounds at all. These are the researcher's own inference wearing the authority of an Apple forum citation. The warm-up-utterance trick that does exist in the wild (e.g. thread 713848) is a workaround for a DIFFERENT bug — first utterance being too QUIET/silent — not for rule-data load latency. No source demonstrates that a silent warm-up utterance actually forces the pronunciation-rule load. Stated confidence "high" is unwarranted here.

FAILURE 3 — STALE. Every data point is iOS 15/16, 2022-2023, with one report of persistence to iOS 17.0.3. Today is 2026-07. NO source substantiates that this is unresolved on current iOS (18/26). "Unresolved" is an extrapolation across ~4 OS generations.

FAILURE 4 — GERMAN FIGURE DROPS ITS CONDITIONS. Thread 715339 says the 3+s German delay (i) occurs on SWITCHING to a different German voice, (ii) requires BOTH a German voice AND a delegate set — either alone is fast, (iii) affects only the newer high-quality voices (Anna, Martin, Helena) and NOT older ones (Sandy, Shelley, Eddy, Reed, Rocko, Flo), and (iv) does NOT reproduce on Simulator, only on device. "German = 3+s" is not unconditional.

FAILURE 5 — HEADLINE CONTRADICTS ITS OWN DETAIL. "'Instant' is NOT achievable with live TTS on iOS" cannot coexist with "rule-data load is a first-utterance-per-language cost, not per-tap" plus "mitigations solve it." If it is a one-time cost absorbed at launch, then live TTS IS instant on every subsequent tap — which is exactly the AAC use case. The claim argues itself out of its own conclusion.

FAILURE 6 — "PRE-RENDERING SOLVES IT" HAS A PRODUCT-FATAL GAP. The MVP spec includes a "type to speak" box. Arbitrary typed text CANNOT be pre-rendered — it must go through live TTS. Pre-rendering covers only the fixed phrase tiles, so it does not solve the stated core job. Worse, flutter_tts synthesizeToFile (v4.2.5, MIT, published ~Jan 2026, 197 open issues) has documented defects: empty audio file when text exceeds one line (#312), cannot run concurrently — only the first file generates, on both platforms (#272), and required an explicit "iOS: Fix synthesizeToFile on iOS 17+" changelog fix. It also emits .caf on iOS vs .wav on Android. It uses the SAME AVSpeechSynthesizer engine, so it incurs the same rule load — it only helps because the cost is paid ahead of time.

NOTE ALSO: flutter_tts exposes no warm-up or pre-initialization API. setSharedInstance()/setIosAudioCategory() configure audio category, not synthesizer warm-up. So mitigations (a) and (c) may not even be reachable from Dart without a platform channel or fork — a material gap the claim does not address.

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

CLAIM: 'Instant' is NOT achievable with live TTS on iOS — there is a documented 0.6-1s+ first-utterance delay — but pre-rendering to cached audio files solves it
THEIR DETAIL: Apple Developer Forums thread 715339 documents that since iOS 16, the gap between speak(utterance) and the didStart delegate callback runs 0.6s to >1s, and is caused by loading per-language pronunciation rule data from disk: English ~862KB / ~0.25s, Italian ~536KB / ~0.7s, German ~4.4MB / ~3+s. Console shows '[AXTTSCommon] Invalid rule:'. Apple requested sysdiagnose then went quiet; unresolved. Mitigations: (a) instantiate AVSpeechSynthesizer at app launch and keep it alive as a singleton — never construct per tap; (b) pre-activate the AVAudioSession at launch, not at first tap; (c) fire a warm-up utterance of ' ' at volume 0 on launch to force the rule data load. Rule-data load is a first-utterance-per-language cost, not per-tap. Note the delay is far worse for German than English, so this is a localization risk, not just a launch risk.
THEIR CLAIMED SOURCES: https://developer.apple.com/forums/thread/715339, https://github.com/dlutton/flutter_tts
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
