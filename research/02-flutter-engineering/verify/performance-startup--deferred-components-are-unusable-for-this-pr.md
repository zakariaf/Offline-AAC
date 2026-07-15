# performance-startup--deferred-components-are-unusable-for-this-pr

> Phase: **verify** · Agent `a279e252c3295dea6` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Keep the refusal. Two corrections to the wording: (1) Drop "the entire Dart app is a few hundred KB" — unverified and likely understated (small Flutter libapp.so is typically several MB); the argument does not need it. (2) Soften "unusable" to "unusable without operating your own component-hosting server" — a custom DeferredComponentManager bypassing the Play Store is documented in the flutter/flutter Deferred Components wiki for regions lacking Play Store access, but it still requires a runtime network fetch from your own server, so the no-network promise still rules it out. Add the strongest available reason, which the claim omits: the docs' pinned com.google.android.play:core:1.8.0 is the retired Play Core monolith (last released 2022, split into com.google.android.play:feature-delivery), Google Play Console blocks Play Core at targetSdk 34+, and flutter#171954 (2025-07-10, unresolved) reports Flutter has no supported migration. Also note the docs' import on line 165 (io.flutter.embedding.engine.dynamicfeatures.PlayStoreDeferredComponentManager) is a documentation bug — the real package is io.flutter.embedding.engine.deferredcomponents.

**Evidence:** Attempted adversarial refutation; claim survives on every load-bearing specific.

API VERIFICATION (all real, none invented, none deprecated):
- FlutterPlayStoreSplitApplication — confirmed at api.flutter.dev/javadoc/io/flutter/embedding/android/FlutterPlayStoreSplitApplication.html. Extends com.google.android.play.core.splitcompat.SplitCompatApplication; injects a PlayStoreDeferredComponentManager via FlutterInjector. Not deprecated.
- PlayStoreDeferredComponentManager — confirmed real; actual package io.flutter.embedding.engine.deferredcomponents (per engine source + flutter#139462).
- FlutterInjector.Builder().setDeferredComponentManager() — confirmed real.

PRIMARY SOURCE (fetched raw doc source from flutter/website@main via GitHub API, path sites/docs/src/content/perf/deferred-components.md, 688 lines — not the rendered page):
- L58/L70: implementation("com.google.android.play:core:1.8.0") — Play Core dependency confirmed.
- L81-83: "If using the Google Play Store as the distribution model for dynamic features, the app must support SplitCompat and provide an instance of a PlayStoreDeferredComponentManager."
- L150: android:name="com.google.android.play.core.splitcompat.SplitCompatApplication".
- L669-672: "When loadLibrary() is called, the needed module... is downloaded by the Flutter engine using the Play store's delivery feature." => runtime network fetch from Google Play CONFIRMED. This is incompatible with a no-network promise and with F-Droid/sideload distribution.

FINDINGS THAT STRENGTHEN THE CLAIM:
1. Version rot exists but is in the DOCS, not the claim. com.google.android.play:core is the retired monolith (last release 2022; split into com.google.android.play:feature-delivery). Google Play Console blocks uploads using Play Core 1.10.3 at targetSdk 34+. flutter#171954 (opened 2025-07-10, awaiting triage) reports Flutter has no supported newer version. The documented setup is currently broken against Play's own requirements.
2. Docs self-contradict: L165 says import io.flutter.embedding.engine.dynamicfeatures.PlayStoreDeferredComponentManager (stale, nonexistent package) while L424 of the same file uses the correct ...engine.deferredcomponents. Copying the doc's import will not compile.

MINOR IMPRECISIONS (do not change the decision):
- "Unusable" is absolute; the Flutter wiki documents a custom DeferredComponentManager bypassing the Play Store, aimed at regions without Play Store access (e.g. China). But it requires operating your own server to host components — still a network fetch — so it does not rescue the no-network promise. bundletool --local-testing is local testing only, not a distribution model.
- Step count: docs organize setup into 3 numbered steps, though Step 1 bundles ~5 sub-tasks (gradle dep, manifest, injector, pubspec deferred-components, validator). "~6 manual config steps" is a fair characterization, not an exact quote.
- "The entire Dart app is a few hundred KB" is UNVERIFIABLE from sources and likely understated (a typical small Flutter libapp.so is several MB). Recommend dropping this figure; the conclusion does not depend on it.

The decision to refuse deferred components is correct, and correct for a stronger reason than the researcher gave: not merely a poor fit, but a documented path that is currently blocked by Google Play's own Play Core retirement.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "performance-startup" made this claim, and a project decision depends on it.

CLAIM: Deferred components are unusable for this project and should be explicitly refused
DETAIL: Flutter deferred components on Android require `implementation "com.google.android.play:core"`, FlutterPlayStoreSplitApplication (or manual SplitCompat), a PlayStoreDeferredComponentManager injected via FlutterInjector, and Play Store dynamic-feature delivery — i.e. a network fetch from Google Play at runtime. That contradicts the no-network promise, breaks sideload/F-Droid distribution, and adds ~6 manual config steps. It is also pointless: the entire Dart app is a few hundred KB of the binary.
CLAIMED SOURCES: https://docs.flutter.dev/perf/deferred-components
CONFIDENCE: high

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
