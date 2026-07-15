# platform-channel-testing--flutter-tts-s-android-setvoice-returns-succe

> Phase: **verify** · Agent `acb106da187363138` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the claim as scoped. Two notes for the corpus: (1) cite the commit/ref with the 514-526 line range, since those numbers track master rather than the 4.2.5 release tag; (2) keep the "never throws" assertion scoped to the voice-not-found path — setVoice can still throw on null arguments (`voice!!`, line 421) or an uninitialized engine (`tts!!`, line 515).

**Evidence:** Verified directly against primary source (raw.githubusercontent.com, dlutton/flutter_tts @ master), not from memory.

1. FILE PATH / PACKAGE RENAME — CONFIRMED. android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt returns HTTP 200 (815 lines). The GitHub contents API confirms android/src/main contains only AndroidManifest.xml and a `kotlin` directory (source is Kotlin, not Java). pub.dev shows flutter_tts 4.2.5, verified publisher `eyedeadevelopment.com`, published ~6 months ago, NOT discontinued, repo github.com/dlutton/flutter_tts. The rename from com.tundralabs.fluttertts is real; the claim's warning about stale paths 404ing is correct.

2. KOTLIN CODE AT 514-526 — CONFIRMED VERBATIM:
514: private fun setVoice(voice: HashMap<String?, String>, result: Result) {
515:     for (ttsVoice in tts!!.voices) {
516-518:     if (ttsVoice.name == voice["name"] && ttsVoice.locale.toLanguageTag() == voice["locale"]) {
519:             tts!!.voice = ttsVoice
520:             result.success(1)
521:             return
522:         }
523:     }
524:     Log.d(tag, "Voice name not found: $voice")
525:     result.success(0)
526: }
Dispatch confirmed at line 419-422: "setVoice" -> { val voice: HashMap<String?, String>? = call.arguments(); setVoice(voice!!, result) }

3. DART SIDE IS A BARE PASS-THROUGH — CONFIRMED. lib/flutter_tts.dart:477-478:
  Future<dynamic> setVoice(Map<String, String> voice) async =>
      await _channel.invokeMethod('setVoice', voice);
No try/catch, no error mapping. Because the native side calls result.success(0) rather than result.error(...), the MethodChannel reply envelope is a success envelope, so invokeMethod completes with the value 0 and raises no PlatformException. The claim's causal chain is mechanically correct.

FAILURE MODES CHECKED AND CLEARED: no version rot (line numbers match current master); not a dead/archived package (active, verified publisher, not discontinued); API signatures are real and not LLM-plausible inventions; no cargo-cult or overstated-consensus content (this is a direct source reading, not a practice recommendation).

SCOPE CAVEAT (does not undercut the claim): "it never throws" is verified for the voice-not-found path as claimed. It is not a blanket property of the method — `voice!!` (line 421) throws a Kotlin NPE if arguments are null, and `tts!!` (line 515) throws if the engine is uninitialized; both would be converted by the platform channel into an error reply. A test asserting "setVoice never throws" unconditionally would be wrong; a test asserting "voice-not-found yields 0 and no exception" is correct.

REF CAVEAT: line numbers 514-526 are pinned to current master (2026-07-15), not to a released tag such as 4.2.5. The corpus should cite the ref/commit alongside the line range.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "platform-channel-testing" made this claim, and a project decision depends on it.

CLAIM: flutter_tts's Android setVoice returns success(0) after only a Log.d when the voice is not found — it never throws. The project's premise is confirmed verbatim.
DETAIL: android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt:514-526. On match: `tts!!.voice = ttsVoice; result.success(1)`. On no match: `Log.d(tag, "Voice name not found: $voice"); result.success(0)`. Because it is result.success (not result.error), Dart's `await _channel.invokeMethod('setVoice', voice)` returns 0 and raises nothing. Note the Android package was renamed from com.tundralabs.fluttertts to com.eyedeadevelopment.fluttertts — stale docs/paths will 404.
CLAIMED SOURCES: https://github.com/dlutton/flutter_tts (android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt)
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
