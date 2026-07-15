# ci-release--r8-minification-failures-surface-as-missing

> Phase: **verify** · Agent `a8b55a2325ad525bf` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Correct the flutter_tts rationale only; the decision-relevant conclusion stands. flutter_tts does NOT avoid reflection — FlutterTtsPlugin.kt imports java.lang.reflect.Field and uses declaredFields + isAccessible=true in ismServiceConnectionUsable() to probe the private mServiceConnection field of android.speech.tts.TextToSpeech. The right reason the R8 risk is near-zero is that this reflection targets an Android *framework* class on the boot classpath, which is not in the app's DEX and is therefore never shrunk or renamed by R8 (and the call is try/catch-guarded with a safe default). The plugin ships no consumer-rules.pro and its README documents no keep rules. Also note two path corrections for anyone reading the source: the Android implementation is Kotlin, not Java, and the package is com.eyedeadevelopment.fluttertts (formerly com.tundralabs.fluttertts) — the old Java path no longer exists. Current version is flutter_tts 4.2.5.

**Evidence:** I tried hard to break this claim and mostly failed. Every load-bearing element verified against primary sources:

1. ERROR STRING + RULES FILE PATH — CONFIRMED VERBATIM. flutter/flutter#154489 quotes the literal build output: "Missing classes detected while running R8. Please add the missing classes or apply additional keep rules that are generated in ...\build\app\outputs\mapping\release\missing_rules.txt." The claimed path `build/app/outputs/mapping/release/missing_rules.txt` is exactly right, not an LLM-plausible reconstruction. Generic AGP form is `app/build/outputs/mapping/<variant>/missing_rules.txt`.

2. ALL THREE CITED CASES ARE REAL AND ON-POINT — no invented issue numbers, which is where these claims usually die:
   - flutter/flutter#155458 — title matches the claim almost word for word: "Missing classes detected while running R8 when using `camera: ^0.11.0+2` and `google_sign_in_android: ^6.1.30`". Missing class `com.google.j2objc.annotations.ReflectionSupport` from Guava's AbstractFuture. Closed as fixed.
   - flutter_stripe#2139 — "Flutter building release app for android problems minifying." Missing `com.stripe.android.pushProvisioning` classes. Reporter's fix is literally `-keep class com.stripe.** { *; }` + `-dontwarn com.reactnativestripesdk.**`, confirming the claimed "broad keep + dontwarn" fix pattern.
   - razorpay-flutter#415 — "Issue with Missing Classes During R8 Minification (ProGuard Annotations)". Missing `proguard.annotation.Keep` from `com.razorpay.AnalyticsEvent`. Still open.

3. BUILD-vs-RUNTIME DISTINCTION — CORRECT, and it's the subtlest part. These are two separate failure modes and the claim keeps them straight. A *detected* missing class is a hard build error under AGP 8+ (was a warning pre-8.0). A *missing keep rule* for a reflectively-loaded class is silent at build time and blows up at runtime. Android's "Fix optimization problems" doc independently corroborates the second half: it lists app crashes "primarily caused by broken reflection" as the headline R8 symptom, and the add-keep-rules page has a "Conditional keep rules for reflection" section on exactly this hazard.

4. flutter_tts IS ALIVE — not a dead-package smuggle. pub.dev shows v4.2.5, verified publisher eyedeadevelopment.com, 1.59k likes. GitHub API: `"archived": false`, `"pushed_at": "2026-01-05"`.

THE ONE DEFECT — the flutter_tts reflection mechanism is factually wrong. The claim asserts flutter_tts "drives android.speech.tts.TextToSpeech over a platform channel rather than reflection." It does both. The current Kotlin source at android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt (note: package moved from com.tundralabs to com.eyedeadevelopment, and Java to Kotlin — the old path 404s) imports `java.lang.reflect.Field` at line 28 and contains a genuine reflection routine at 758-781:

    private fun ismServiceConnectionUsable(tts: TextToSpeech?): Boolean {
        val fields: Array<Field> = tts.javaClass.declaredFields
        for (j in fields.indices) {
            fields[j].isAccessible = true
            if ("mServiceConnection" == fields[j].name && "android.speech.tts.TextToSpeech\$Connection" == fields[j].type.name) {

So the stated reason for the low-risk conclusion is false. But the conclusion itself survives, and is actually stronger than the researcher argued — for a reason they did not identify. The reflection targets `android.speech.tts.TextToSpeech`, an Android *framework* class on the boot classpath. Framework classes are not in the app's DEX, so R8 never shrinks or renames them, and no keep rule could apply. The lookup is also wrapped in try/catch (IllegalArgumentException, IllegalAccessException, Exception) and defaults `isBindConnection = true`, so it degrades safely. The plugin ships no consumer-rules.pro or proguard file anywhere in the repo tree, and its README says nothing about R8 — consistent with a plugin that has no keep-rule requirements.

Net: the R8 mechanics, file path, error string, case law, and fix pattern are all accurate. The "risk is lowish for flutter_tts" bottom line holds and should be relied on. Only the supporting rationale needs correcting. I found no version rot, no dead package, and no invented API.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "ci-release" made this claim, and a project decision depends on it.

CLAIM: R8 minification failures surface as 'Missing classes detected while running R8' with a generated rules file, and are a runtime-silent-failure risk
DETAIL: R8 writes suggested keep rules to build/app/outputs/mapping/release/missing_rules.txt. Real Flutter plugin cases exist (flutter/flutter#155458 for camera + google_sign_in_android; flutter_stripe#2139; razorpay-flutter#415). Fixes are broad `-keep class com.x.** { *; }` + `-dontwarn`. Crucially, a *missing* keep rule for a reflectively-loaded class does not fail the build — it fails at runtime, which for this app means a tile tap producing no speech. flutter_tts drives android.speech.tts.TextToSpeech over a platform channel rather than reflection, so risk is lowish, but the payoff on a 12-tile app is also near-zero.
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/155458, https://arahimli.medium.com/troubleshooting-r8-minification-errors-in-flutter-my-journey-to-a-solution-ac88cc43fae3, https://www.devsecopsnow.com/error-missing-classes-detected-while-running-r8/
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
