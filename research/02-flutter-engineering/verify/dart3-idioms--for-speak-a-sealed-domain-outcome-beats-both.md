# dart3-idioms--for-speak-a-sealed-domain-outcome-beats-both

> Phase: **verify** · Agent `ab0c2a5a9ed965677` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The design conclusion survives, but three specifics must be fixed before it can carry a project decision.

1. Fix the mechanism. For the three failures the claim names, flutter_tts does NOT throw — it returns a status code through `Future<dynamic>`. `setVoice` answers `result.success(0)` on "Voice name not found" (FlutterTtsPlugin.kt:514-526); `speak` likewise resolves 0/1. Re-argue the case as "an untyped status code that is trivially ignored" rather than "an uncaught throw reaching PlatformDispatcher.onError." This makes the argument STRONGER — an ignored `0` produces no stderr line, no onError callback, no trace whatsoever — but the claim as written attacks a failure mode this library doesn't produce.

2. Drop "exhaustiveness makes silence impossible." Exhaustiveness forces a branch, not an action, and does not force the caller to switch at all — `await speak(text);` discarding the outcome compiles clean. The correct claim: exhaustiveness makes FORGETTING A VARIANT a compile error; it does nothing about ignoring the value. To close that second hole you need `@useResult` (package:meta) on speak(), which yields the `unused_result` analyzer WARNING — not a compile error. Enforce it with `unused_result` promoted to error in analysis_options.yaml if the decision depends on it. State the guarantee as "compile-error on new variants + analyzer-error on discarded outcomes," not "silence impossible."

3. Downgrade confidence on the headline and re-cite. The comparative "beats a generic Result<T>" is unsourced; docs.flutter.dev recommends the generic Result<T>, and codewithandrea explicitly hedges toward try/catch for small-to-medium apps. Present the payload-carrying sealed outcome as a defensible team design judgment extending the Flutter Result pattern — not as documented guidance. Sources 1 and 2 support premises (a) and (c); source 3 supports nothing in the claim and should be removed or cited as a counterweight.

One point in the claim's favor, against the consensus: "compile error at every call site" is CORRECT. Widespread secondary sources say non-exhaustive switch statements are mere warnings; the analyzer's messages.yaml marks both nonExhaustiveSwitchStatement and nonExhaustiveSwitchExpression as `type: compileTimeError`. Do not let a reviewer talk you out of this one.

**Evidence:** VERIFIED (the claim survives more scrutiny than most):

1. Effective Dart quote — VERBATIM ACCURATE. "The Error class is the base class for programmatic errors... it means there is a bug in your code" and "if the exception is some kind of runtime failure that doesn't indicate a bug in the code, then throwing an Error is misleading." Premise (a)'s Error/Exception reasoning is correctly sourced.

2. Flutter Result doc quote — VERBATIM ACCURATE. "Dart's exceptions are unhandled exceptions. This means that methods that throw exceptions don't need to declare them, and calling methods aren't required to catch them either."

3. All three named failure modes are REAL, verified in flutter_tts Kotlin source (android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt @ master):
   - setVoice returning 0 — CONFIRMED, lines 514-526: iterates voices, `result.success(1)` on match, else `Log.d(tag, "Voice name not found: $voice"); result.success(0)`.
   - network_required — CONFIRMED, line 623: `map["network_required"] = if (voice.isNetworkConnectionRequired) "1" else "0"` (note: String "1"/"0", not bool).
   - voice uninstalled — CONFIRMED, line 491: `!features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)`.

4. Package is ALIVE, not a dead-package citation: flutter_tts v4.2.5, verified publisher eyedeadevelopment.com; GitHub dlutton/flutter_tts pushed 2026-01-05, archived=false, disabled=false.

5. Exhaustiveness → compile error — CONFIRMED, and stronger than commonly believed. Multiple secondary sources (and dart-lang/language#2474) claim non-exhaustive switch STATEMENTS are only warnings. That is FALSE in shipped Dart. The analyzer's authoritative pkg/analyzer/messages.yaml lists BOTH `nonExhaustiveSwitchExpression` (line 13271) and `nonExhaustiveSwitchStatement` (line 13340) with `type: compileTimeError`, under the CompileTimeErrorCode class. Premise (c)'s "compile error at every call site" is correct for statements and expressions alike. Adding `default:`/`case _:` does defeat it (dart.dev/language/branches).

6. PlatformDispatcher.onError exists and behaves as described: handles unhandled root-isolate errors; if unset or returning false, "a fallback mechanism such as printing to stderr will be used" — i.e. no user-visible signal.

DEFECTS FOUND:

A. PREMISE (b) IS MECHANICALLY WRONG FOR THE FAILURES NAMED IN (a). flutter_tts does not throw for voice-not-found / setVoice failure / speak failure. The Dart layer is a bare passthrough — `Future<dynamic> setVoice(Map<String,String> voice) async => await _channel.invokeMethod('setVoice', voice);` — and Kotlin answers with `result.success(0)`. A status code, not an exception. So the PlatformDispatcher.onError narrative does not apply to the three failures the claim itself cites. The claim argues against "throwing" that this library never does for these cases — a straw man. (Ironically the truth is worse and helps the conclusion: an ignored `0` leaves NO trace at all, whereas an uncaught throw at least reaches onError/stderr.)

B. "EXHAUSTIVENESS IS WHAT MAKES SILENCE IMPOSSIBLE" IS FALSE AS STATED. Exhaustiveness forces a branch per variant; it does not force the branch to do anything — `case VoiceUnavailable(): break;` compiles clean. Worse, nothing forces the caller to switch at all: `await speak(text);` discarding a returned sealed outcome is NOT a compile error. Exhaustiveness only binds after you've chosen to switch. The claim never names the API that actually addresses this: `@useResult` from package:meta, which makes discarding the value an analyzer diagnostic (`unused_result`) — a WARNING, not an error. So "silence impossible" is unachievable by exhaustiveness alone, and unachievable at compile-error strength at all.

C. SOURCE 3 CONTRADICTS THE CLAIM IT IS CITED FOR. codewithandrea concludes try/catch "is a versatile approach that works well with small-to-medium-sized apps," warns Result forces changing "the return type of all the methods in the call stack," and explicitly advocates pragmatism over dogmatism. It is cited as support for a thesis it declines to endorse. (Failure mode 5: overstated consensus.)

D. THE HEADLINE IS UNSOURCED, AND SOURCE 1 RECOMMENDS ITS OPPOSITE. docs.flutter.dev/app-architecture/design-patterns/result recommends precisely the GENERIC `sealed class Result<T>` (Ok/Error) that the claim calls inferior. NO cited source makes the comparative claim "sealed domain outcome beats a generic Result<T>." That comparative verdict — the actual headline — is the researcher's own design reasoning borrowing three sources' authority. CONFIDENCE: high is unwarranted for it, however reasonable the reasoning is.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dart3-idioms" made this claim, and a project decision depends on it.

CLAIM: For speak(), a sealed domain outcome beats both throwing and a generic Result<T> — because the failure variants must CARRY the fallback payload, and because exhaustiveness is what makes silence impossible.
DETAIL: Three properties decide this. (a) speak() failure is EXPECTED, not a bug: a voice can be uninstalled between app launches, an Android voice can be network_required with no network, setVoice can return 0. Effective Dart: throw Error only for programmatic errors/bugs — so these are not Errors. (b) Nothing forces a caller to catch: 'in Dart, methods that throw exceptions don't need to declare them, and calling methods aren't required to catch them' — an uncaught speak() throw in an async tile handler goes to PlatformDispatcher.onError and the user sees NOTHING. That is the exact catastrophic bug class. (c) The failure needs a payload: the fallback is 'show the text full-screen', so the failure value must carry the text. A sealed SpeakFailure with `final String spokenText` makes the fallback a total function of the outcome. Combined with an exhaustive switch and NO `default:`/`case _:`, adding a new failure mode becomes a compile error at every call site.
CLAIMED SOURCES: https://docs.flutter.dev/app-architecture/design-patterns/result, https://dart.dev/effective-dart/usage, https://codewithandrea.com/articles/flutter-exception-handling-try-catch-result-type/
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
