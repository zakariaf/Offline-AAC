# platform-channel-testing--android-s-notinstalled-voice-feature-defeats

> Phase: **verify** · Agent `a11fac068b334d948` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Claim is correct; two refinements to the specifics, both of which strengthen rather than weaken it.

(1) TYPE ERROR IN THE PROPOSED MITIGATION. The claim says voice_filter must exclude `features.contains('notInstalled')`, implying features is a List<String>. It is not. readVoiceProperties (FlutterTtsPlugin.kt:618) emits `map["features"] = voice.features.joinToString(separator = "\t")` — a TAB-JOINED STRING. The getVoices map is HashMap<String,String>, all values are Strings. So `features.contains('notInstalled')` happens to work as a Dart String substring check and the mitigation is functionally correct, but anyone implementing it against an assumed List<String> will hit a type error, and code must null-guard since 'features' may be absent on non-Android platforms (iOS/macOS/Windows emit different keys: quality, gender, identifier).

(2) THE UNDERLYING DEFECT IS WORSE THAN THE CLAIM STATES. The claim frames flutter_tts as returning 1 because the loop matched. True, but flutter_tts additionally throws away TextToSpeech.setVoice's return value via the Kotlin property-setter assignment `tts!!.voice = ttsVoice`. Consequence: the brief's stated mitigation ("check the setVoice return value") is not merely insufficient against notInstalled voices — on Android it is checking the plugin's name-match result, NOT the platform's SUCCESS/ERROR code, and therefore cannot detect ANY platform-level setVoice failure, including service.loadVoice returning ERROR. The brief should be corrected on this broader point, not just the notInstalled path.

(3) Minor provenance note, not a defect in the claim: the plugin's Android implementation migrated from Java (com.tundralabs.fluttertts.FlutterTtsPlugin.java) to Kotlin (com.eyedeadevelopment.fluttertts.FlutterTtsPlugin.kt). Any brief citing the old Java path is stale; cite the .kt path.

**Evidence:** Attempted refutation on all five failure modes; claim survives every one. VERIFIED AGAINST LOCAL SDK SOURCE (not docs): /Users/zakariafatahi/Library/Android/sdk/sources/android-35/android/speech/tts/TextToSpeech.java:678 contains exactly `public static final String KEY_FEATURE_NOT_INSTALLED = "notInstalled";`. The cited line number is exact. Doc comment at lines 667-677 matches the claim verbatim: "Feature key that indicates that the voice may need to download additional data to be fully functional. The download will be triggered by calling setVoice(Voice) or setLanguage(Locale). Until download is complete, each synthesis request will either report ERROR_NOT_INSTALLED_YET error, or use a different voice to synthesize the request." Corroborated independently at android.googlesource.com platform/frameworks/base master. ERROR_NOT_INSTALLED_YET = -9 at line 150. setVoice(Voice) at line 1738, documented "@return ERROR or SUCCESS", validates via service.loadVoice(getCallerIdentity(), voice.getName()).

MECHANISM CONFIRMED AND STRONGER THAN CLAIMED. flutter_tts Android impl (android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt:514-526) reads:
    for (ttsVoice in tts!!.voices) {
        if (ttsVoice.name == voice["name"] && ttsVoice.locale.toLanguageTag() == voice["locale"]) {
            tts!!.voice = ttsVoice
            result.success(1)
            return
        }
    }
    result.success(0)
`tts!!.voice = ttsVoice` is the Kotlin property setter, which DISCARDS the Int returned by TextToSpeech.setVoice entirely; result.success(1) then fires unconditionally. So a Dart-side return of 1 does not even establish that the framework setVoice returned SUCCESS — it establishes only that a Voice with matching name+locale was present in tts.voices. A notInstalled voice IS present in tts.voices (it is enumerable and selectable; that is the whole premise of the download-on-select design), so the loop matches it and returns 1 while synthesis subsequently reports ERROR_NOT_INSTALLED_YET or silently substitutes a different voice. The claim's conclusion — setVoice-return-value checking is necessary but NOT sufficient, and voice_filter must also exclude the notInstalled feature — is correct.

Version-rot check: NEGATIVE. flutter_tts 4.2.5, publisher eyedeadevelopment.com (verified pub.dev publisher), published ~6 months ago, not discontinued, repo dlutton/flutter_tts not archived. Android SDK 35 sources present and current. No invented API names: KEY_FEATURE_NOT_INSTALLED, ERROR_NOT_INSTALLED_YET, setVoice(Voice), Voice.getFeatures() all exist with those exact names.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "platform-channel-testing" made this claim, and a project decision depends on it.

CLAIM: Android's `notInstalled` voice feature defeats a setVoice-return-value check: setVoice returns 1 (success) and synthesis still fails or silently substitutes a DIFFERENT voice.
DETAIL: Android SDK 35 source, TextToSpeech.java:678, KEY_FEATURE_NOT_INSTALLED = "notInstalled". Doc comment: 'the voice may need to download additional data to be fully functional... Until download is complete, each synthesis request will either report ERROR_NOT_INSTALLED_YET error, or use a different voice to synthesize the request.' Because such a voice IS present in tts.voices, flutter_tts's setVoice loop matches it and returns 1. So the brief's stated mitigation (check the setVoice return value) is necessary but NOT sufficient. The voice_filter must also exclude features.contains('notInstalled'). This is a silent-failure path the brief did not anticipate.
CLAIMED SOURCES: Android SDK android-35 sources: android/speech/tts/TextToSpeech.java:678
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
