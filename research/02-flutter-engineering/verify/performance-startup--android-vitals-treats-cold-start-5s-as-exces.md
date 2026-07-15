# performance-startup--android-vitals-treats-cold-start-5s-as-exces

> Phase: **verify** · Agent `a142ea657635b2259` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Three fixes. (1) The 28-day figure is Google Play's quality-*evaluation* window, not the measurement window — vitals data spans 90 days in Play Console and 3 years in the Play Developer Reporting API; TTID is measured per-session. (2) The 700ms–1.8s cold-start estimate is not supported by any primary source (docs.flutter.dev/add-to-app/performance gives no timing numbers), and flutter/flutter#175577 (OPEN) documents +560–790ms Impeller cold-start regressions concentrated on Cortex-A53 devices — the exact $120–150 class cited — while the upstream fix #166918 was reverted by #167427 on 2025-04-19. Budget ~600–800ms less headroom than claimed. (3) The decisive argument is stronger than the one made: startup time is not a core vital and has no bad behavior threshold, so it cannot affect discoverability at all. The metrics that do are user-perceived ANR rate (≥0.47% overall / ≥8% per-device) and user-perceived crash rate (≥1.09% / ≥8%). Also note TTID measures the first frame — for Flutter that is the Android launch-theme splash, not the Dart UI — so Android's own docs recommend reportFullyDrawn()/TTFD instead; the rule should be "do not block the first Dart frame."

**Evidence:** I was tasked to refute this claim. I could not. The core facts verify exactly against the two primary sources the researcher actually cited, and the decision the project depends on is sound — and in fact under-argued. Reporting the corrections that do apply rather than manufacturing a refutation.

WHAT VERIFIED EXACTLY (developer.android.com/topic/performance/vitals/launch-time):
Direct quote: "Android vitals considers the following startup times for your app excessive: Cold startup takes 5 seconds or longer. Warm startup takes 2 seconds or longer. Hot startup takes 1.5 seconds or longer. Android vitals uses the time to initial display (TTID) metric." All three thresholds and the TTID metric are stated verbatim. Claim is correct. Confidence "medium" was too low; the threshold half deserves high.

WHAT NEEDS CORRECTION:

1. The 28-day window is conflated. Per support.google.com/.../7385505, 28 days is the window Google Play "will generally consider... when evaluating your app's quality" — it is not the metric's reporting window. Vitals data is available for 90 days in Play Console and 3 years in the Play Developer Reporting API. TTID is not "measured over a 28-day window"; it is measured per-session and *evaluated* over 28 days.

2. The 700ms–1.8s estimate has no primary source. docs.flutter.dev/add-to-app/performance describes the load sequence (find resources, load library, start Dart VM, create Isolate, attach UI) but contains zero millisecond figures, no benchmarks, no device classes. This number is an unsourced engineering guess presented with the same authority as the sourced thresholds. It may well be right, but nothing on docs.flutter.dev substantiates it.

3. The named device class has an active, unresolved regression. flutter/flutter#175577 (OPEN) reports Impeller cold-start regressions of +560–790ms upgrading 3.24.1 → 3.32.5, and states "Devices with CPU cores cortex-A53 seem to suffer the most after upgrade to impeller" — naming OPPO CPH2239, Samsung Galaxy A12, OPPO A57. That is precisely the $120–150 Snapdragon 4-series / Helio G class the claim names. Relatedly, flutter/flutter#166918 (engine init on a separate thread) was REVERTED by #167427 on 2025-04-19 — the obvious upstream startup win is not landed. So the headroom is real but ~600–800ms smaller than the claim's own estimate assumes, on the exact hardware it cites.

4. TTID ≠ time-to-usable for a Flutter app. The Android page itself flags this and recommends the opposite metric: "When optimizing for app startup we recommend implementing reportFullyDrawn to get information up to TTFD." For a Flutter app the first frame is typically the Android launch theme/splash drawable, not the Dart UI — so vitals TTID *undercounts* real time-to-usable. This cuts in the claim's favor on the vitals number while undermining its framing that the two are the same thing.

5. Minor Google doc inconsistency, not the claim's fault: the Play Console page (9844486) says slow hot start is "1 second or more" while the developer page says 1.5s. The claim followed the canonical launch-time page and matched it.

THE STRONGEST POINT THE CLAIM MISSED — which strengthens its own conclusion:
Startup time is NOT a core vital and carries NO bad behavior threshold. Per 9844486 and 7385505, core vitals are user-perceived ANR rate (≥0.47% overall / ≥8% per-device), user-perceived crash rate (≥1.09% / ≥8%), excessive battery usage (watch face), and excessive partial wake locks (beta, currently not affecting discoverability). "Excessive" startup time is advisory only — it does not reduce Play Store discoverability. The claim argues headroom; the real argument is that this metric has no enforcement teeth at all. The 2-week budget is better spent on ANR and crash rate, which are the metrics that actually gate discoverability.

BOTTOM LINE: Thresholds correct. Decision correct, for a partly wrong reason plus a stronger unstated one. Fix the 28-day framing, drop or label the 700ms–1.8s figure as an unsourced estimate, and note the open Impeller regression on the target hardware. "Do not block the first frame" is a reasonable rule, but on Flutter the first frame is the splash — the rule worth writing is "do not block the first *Dart* frame," which TTID will not catch for you.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "performance-startup" made this claim, and a project decision depends on it.

CLAIM: Android vitals treats cold start ≥5s as excessive; this app has enormous headroom and does not need cold-start optimization work
DETAIL: Android vitals thresholds: cold ≥5s, warm ≥2s, hot ≥1.5s are 'excessive', measured as TTID (time to initial display) over a 28-day window. A Flutter app with one screen, no plugins doing work in main(), and a 12-row DB read is realistically 700ms–1.8s cold on a $120–150 device (Snapdragon 4-series / Helio G-series class). The gap between 'realistic' and 'excessive' is ~3s. Cold-start micro-optimization is therefore NOT a good use of the 2-week budget; the only rule needed is 'do not block the first frame'.
CLAIMED SOURCES: https://developer.android.com/topic/performance/vitals/launch-time, https://support.google.com/googleplay/android-developer/answer/9844486
CONFIDENCE: medium

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: pub.dev package pages (for real current versions, publisher, and maintenance status), api.flutter.dev (for real API signatures), dart.dev, docs.flutter.dev, and the actual GitHub repos (for whether something is archived/discontinued).

The failure modes you are hunting for, in order of likelihood:
1. **Version rot** — the claim was true in 2023. APIs get deprecated and removed; `setMockMethodCallHandler` moved; `window` was deprecated; formatters changed.
2. **Dead packages presented as alive** — golden_toolkit, dart_code_metrics, isar, hive, mockito-vs-mocktail. CHECK THE REPO: is it archived? When was the last publish? Does pub.dev show it as discontinued?
3. **Invented or misremembered API signatures.** If the claim names a method, class, or parameter, VERIFY IT EXISTS with that exact name on api.flutter.dev or the package docs. LLM-plausible API names are a specific hazard here.
4. **Cargo cult** — presenting a team practice or a large-app practice as universal, when the actual source doesn't say that.
5. **Overstated consensus** — "the community recommends X" when it's one blog post.

Default to refuted=true if you cannot independently substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + a correction if directionally right but wrong in specifics (name the exact right version/API). UNVERIFIABLE if no source settles it — and say that plainly rather than guessing.
````

</details>
