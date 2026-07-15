# platform-channel-testing--getvoices-returns-list-object-of-map-object

> Phase: **verify** · Agent `a6a847996c58fa580` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Claim stands; two precision refinements for the corpus, neither refuting it.

(a) LAZINESS — the claim's headline "casting to List<Map<String,String>> throws TypeError at runtime" is imprecise, though its test expression is correct. Verified by local run: `.cast<Map<String,String>>()` ALONE DOES NOT THROW — it returns a lazy `CastList<Object?, Map<String,String>>`. The TypeError fires only on element access, which is why the claim's `.first` is load-bearing. A direct `raw as List<Map<String,String>>` throws immediately. Consequence for the researcher: a test asserting a throw on `.cast()` WITHOUT a subsequent element access would pass vacuously / fail to throw. Keep the `.first`.

(b) PACKAGE PATH DRIFT — the Android package is now com.eyedeadevelopment.fluttertts, NOT com.tundralabs.fluttertts (ownership moved to publisher eyedeadevelopment.com). The claim cited only the filename + line numbers (both exactly right), but the correct full path is android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt — the legacy tundralabs path 404s.

(c) Pin the claim to flutter_tts 4.2.5 (current stable as of 2026-07-15) so it is falsifiable against future refactors of this untyped getter.

**Evidence:** Attempted refutation on all five failure modes; claim survives every one.

1. DART SOURCE — verbatim match. lib/flutter_tts.dart @ master is exactly as quoted: `Future<dynamic> get getVoices async { final voices = await _channel.invokeMethod('getVoices'); return voices; }`. Untyped, as claimed. (getLanguages/getEngines are likewise Future<dynamic>.)

2. CODEC CONTRACT — confirmed on primary source. api.flutter.dev StandardMessageCodec class page states verbatim: "Decoded values will use List<Object?> and Map<Object?, Object?> irrespective of content."

3. KOTLIN SIDE — exact line range correct. FlutterTtsPlugin.kt:553-566 is precisely getVoices:
    553  private fun getVoices(result: Result) {
    554      val voices = ArrayList<HashMap<String, String>>()
    555      try { for (voice in tts!!.voices) { ... voices.add(voiceMap) }
    561          result.success(voices)
    562      } catch (e: NullPointerException) {
    563          Log.d(tag, "getVoices: " + e.message)
    564          result.success(null)
    565      }
    566  }
   So the "Dart must tolerate a null list, not just empty" point holds (Android path).

4. INDEPENDENTLY EXECUTED, not merely reasoned (Dart SDK 3.11.0 stable, local run):
   raw = <Object?>[<Object?,Object?>{'name':..., 'locale':...}]  // runtimeType List<Object?>
   (raw as List).cast<Map<String,String>>().first
   -> threw: _TypeError | isTypeError=true |
      "type '_Map<Object?, Object?>' is not a subtype of type 'Map<String, String>' in type cast"
   Null case: (null as List) also throws _TypeError (isTypeError=true).

5. NO VERSION ROT / NOT A DEAD PACKAGE. pub.dev flutter_tts: latest 4.2.5, published ~6 months ago, verified publisher eyedeadevelopment.com, NOT marked discontinued/unmaintained. GitHub dlutton/flutter_tts: archived=false, default_branch=master, pushed_at=2026-01-05. No invented API names — every named symbol exists with that exact name.

SCOPE CAVEAT: verified against the Android implementation. iOS/macOS getVoices returns richer maps (quality, gender, identifier per the doc comment), which reinforces the cast failure rather than undermining it, but the null-on-failure behavior was not separately confirmed for iOS.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "platform-channel-testing" made this claim, and a project decision depends on it.

CLAIM: getVoices returns List<Object?> of Map<Object?,Object?> over the channel; casting to List<Map<String,String>> throws TypeError at runtime.
DETAIL: lib/flutter_tts.dart: `Future<dynamic> get getVoices async { final voices = await _channel.invokeMethod('getVoices'); return voices; }` — untyped. StandardMessageCodec decodes maps as Map<Object?,Object?>. I wrote a passing test asserting `(raw as List).cast<Map<String,String>>().first` throws TypeError. Also FlutterTtsPlugin.getVoices catches NullPointerException and calls result.success(null) — so the Dart side must tolerate a null list, not just an empty one.
CLAIMED SOURCES: https://github.com/dlutton/flutter_tts (lib/flutter_tts.dart, FlutterTtsPlugin.kt:553-566), Verified locally by running the test
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
