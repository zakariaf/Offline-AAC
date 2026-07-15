# platform-channel-testing--android-sends-network-required-as-the-string

> Phase: **verify** · Agent `aa7107cd1b77722ad` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the claim itself; all specifics verified exact. Two additions worth folding into the corpus: (1) KEY_FEATURE_NETWORK_SYNTHESIS is @Deprecated in AOSP (TextToSpeech.java:635) — parsers should key off the network_required field rather than substring-scanning the tab-joined features for "networkTts"; the plugin already uses the non-deprecated Voice.isNetworkConnectionRequired(). (2) The Android package path is now com.eyedeadevelopment.fluttertts, not com.tundralabs.fluttertts. Correct parse for flutter_tts 4.2.5: treat the value as String, `raw['network_required'] == '1'` (NOT `== true`, NOT truthiness — "0" is a non-empty String), and treat a MISSING key as not-network-required for iOS/macOS. Features: `(raw['features'] as String? ?? '').split('\t')`.

**Evidence:** Attempted refutation failed on every axis. Verified against the PUBLISHED pub.dev artifact (flutter_tts 4.2.5 tarball), not merely master — so this is not a master-vs-release drift artifact.

PACKAGE HEALTH (rules out failure mode 2 "dead package"): pub.dev API reports latest 4.2.5, published 2026-01-05T17:54:55Z, isDiscontinued=false, replacedBy=null, 81 versions. GitHub API: dlutton/flutter_tts archived=false, default_branch=master, pushed_at=2026-01-05. Alive and current as of today (2026-07-15).

ANDROID — exact, from published 4.2.5 pkg/android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt:
  618: fun readVoiceProperties(map: MutableMap<String, String>, voice: Voice) {
  623:     map["network_required"] = if (voice.isNetworkConnectionRequired) "1" else "0"
  624:     map["features"] = voice.features.joinToString(separator = "\t")
Function spans 618-626 exactly as claimed. Line numbers cited are precisely correct.

STRONGER THAN CLAIMED (1): The parameter type is MutableMap<String, String> and the caller builds HashMap<String, String> (line 557, inside getVoices at 554: `val voices = ArrayList<HashMap<String, String>>()`). The map is String-typed BY CONSTRUCTION, not incidentally. So `raw['network_required'] == true` is a String==bool comparison: legal Dart, no analyzer warning, evaluates false for EVERY Android voice. The safety inversion is exactly as described — a bool check reads every network-dependent voice as offline-safe.

STRONGER THAN CLAIMED (2): lib/flutter_tts.dart:523-526 — `Future<dynamic> get getVoices async { final voices = await _channel.invokeMethod('getVoices'); return voices; }`. Zero parsing/coercion. No layer sits between the raw platform map and caller code, so the hazard propagates unmodified. Its own doc comment (521) even says "For iOS specifically, it also includes quality, gender, and identifier" — confirming the platform key asymmetry is acknowledged upstream.

iOS — published 4.2.5 pkg/ios/Classes/SwiftFlutterTtsPlugin.swift, getVoices body emits ONLY: voiceDict["name"], ["locale"], ["quality"], ["gender"] (gated #available(iOS 13.0)), ["identifier"]. No network_required key. Confirms parser MUST treat missing key as not-network-required.

ANDROID SDK (AOSP frameworks/base, refs/heads/main):
  core/java/android/speech/tts/TextToSpeech.java:636 — `public static final String KEY_FEATURE_NETWORK_SYNTHESIS = "networkTts";` — value AND line number both exactly as claimed.
  core/java/android/speech/tts/Voice.java:157 — `public boolean isNetworkConnectionRequired() {` exists, returns boolean, no @Deprecated.
  (Also Voice.java:182 `public Set<String> getFeatures()` returns Set<String>, consistent with the joinToString on line 624; and plugin line 491 uses TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED = "notInstalled", TextToSpeech.java:678.)

NUANCE THAT DOES NOT UNDERMINE THE CLAIM: KEY_FEATURE_NETWORK_SYNTHESIS carries @Deprecated (TextToSpeech.java:635, immediately above the constant), with docs steering to setVoice(Voice)/Voice inspection. The claim asserted only the constant's value and existence, which is correct. The deprecation actually REINFORCES the plugin's design, since the plugin already uses the non-deprecated Voice.isNetworkConnectionRequired() as the authoritative signal. A parser should prefer network_required over scanning the features string for "networkTts".

INCIDENTAL FINDING (outside claim scope, relevant to parser authors): iOS declares `var voiceDict: [String: String] = [:]` OUTSIDE the for-loop and never resets it between iterations. Stale keys from a prior voice leak forward into any later voice missing that key (e.g. gender on iOS<13). Swift value-type copy semantics on `voices.add(voiceDict)` means each entry is a snapshot, but the snapshot may carry contaminated fields.

STALE-DETAIL NOTE: the Android package path moved from com.tundralabs.fluttertts to com.eyedeadevelopment.fluttertts (my first fetch at the old path 404'd). The claim never asserted the package path, so this is not an error in the claim — but any tooling pinning the old path will break.

Bottom line: high confidence is warranted. Line numbers, string literals, separator, key sets, and SDK constants all verified exact against primary sources.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "platform-channel-testing" made this claim, and a project decision depends on it.

CLAIM: Android sends network_required as the STRING "1"/"0", features as a TAB-separated string; iOS omits network_required entirely. A naive truthiness or bool check silently inverts the safety property.
DETAIL: FlutterTtsPlugin.kt readVoiceProperties (:618-626): map["network_required"] = if (voice.isNetworkConnectionRequired) "1" else "0"; map["features"] = voice.features.joinToString(separator = "\t"). Note "0" is a non-empty String and thus survives a null/empty check; and `raw['network_required'] == true` is ALWAYS false since it is a String. iOS (SwiftFlutterTtsPlugin.getVoices :337-357) emits only name/locale/quality/gender/identifier — no network_required — so the parser must treat a missing key as not-network-required. Confirmed KEY_FEATURE_NETWORK_SYNTHESIS = "networkTts" (TextToSpeech.java:636) and Voice.isNetworkConnectionRequired() exist.
CLAIMED SOURCES: https://github.com/dlutton/flutter_tts, https://developer.android.com/reference/android/speech/tts/Voice, Android SDK android-35 sources
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
