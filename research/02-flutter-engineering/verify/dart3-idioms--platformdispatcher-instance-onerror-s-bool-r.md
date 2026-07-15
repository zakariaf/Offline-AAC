# dart3-idioms--platformdispatcher-instance-onerror-s-bool-r

> Phase: **verify** · Agent `aec07255056cdeaf6` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep the semantics, drop the universal, and fix the rule.

CORRECT: bool return = "I handled this; skip the embedder's fallback reporting." Returning true unconditionally does suppress the default console print for uncaught async errors in debug.

WRONG: "Uncaught async errors do not terminate a Flutter app regardless" / "purely a reporting decision." api.flutter.dev explicitly says "The VM or the process may exit or become unresponsive after calling this callback," and routes the false path through the embedder-configured Settings::unhandled_exception_callback. It is embedder-dependent, not guaranteed. Stock mobile runners usually survive; the doc does not promise it.

WRONG: `return kReleaseMode;` is not "the whole rule," and docs.flutter.dev/testing/errors does not say it — that page returns `true` unconditionally and never explains the bool at all.

RECOMMENDED RULE for a crisis-UI app — invert it. Return `true` always, and print yourself in debug:

  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      _logToDisk(error, stack);           // must not throw
      if (kDebugMode) {
        debugPrint('$error\n$stack');     // your visibility, not the embedder's
      }
    } catch (_) {
      // swallow: never let the handler throw
    }
    return true;                          // never hand control to the embedder fallback
  };

This gets you the debug console output the researcher wanted WITHOUT ever taking the `false` branch that the doc warns may exit or hang the process. `return kReleaseMode` buys debug visibility at the cost of the one behavior this app cannot tolerate — and it buys it unnecessarily, since debugPrint gives the same visibility for free.

CITATION FIX: cite api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html for the semantics. docs.flutter.dev/testing/errors does not support the claim and should not be cited for it.

SCOPE FIX: this covers uncaught root-isolate async errors only. Pair with FlutterError.onError for widget-tree errors, and note that child isolates must forward their own errors to the root isolate — onError will not see them.

**Evidence:** HEADLINE CLAIM: CONFIRMED VERBATIM. api.flutter.dev states: "This callback must return `true` if it has handled the error. Otherwise, it must return `false` and a fallback mechanism such as printing to stderr will be used, as configured by the specific platform embedding via `Settings::unhandled_exception_callback`." So bool = "handled, suppress default reporting" is exactly right, and the corollary that returning true unconditionally suppresses the default console print in debug follows directly.

NO VERSION ROT. PlatformDispatcher.instance.onError is current and non-deprecated in Flutter 3.44. This is the correct modern API (the deprecated-and-removed `window` accessor was the thing that rotted; the claim is already on the right side of that). Signature is real, not invented: `typedef ErrorCallback = bool Function(Object exception, StackTrace stackTrace)` on api.flutter.dev/flutter/dart-ui/ErrorCallback.html. The claim writes `(Object error, StackTrace stack)` — parameter names differ from the typedef, but these are positional params, so this is cosmetic and NOT a defect.

DEFECT 1 — "it does not keep the app alive... regardless" and "purely a reporting decision" is OVERSTATED, and the same doc page explicitly contradicts it. Two sentences later: "The VM or the process may exit or become unresponsive after calling this callback." The doc routes the false path through `Settings::unhandled_exception_callback`, which is configured by "the specific platform embedding" — i.e. it is embedder-dependent by construction, which is the opposite of "purely a reporting decision" and the opposite of "regardless." On stock Flutter mobile runners the process does typically survive (the engine logs "Unhandled exception:" via dart_isolate.cc and continues), so the claim is directionally defensible for the common case. But it states as a universal invariant something the primary doc explicitly declines to guarantee. For a crisis-UI app whose whole point is staying up, betting on an embedder-dependent behavior that the doc warns may "exit or become unresponsive" is exactly the wrong risk to take.

DEFECT 2 — `return kReleaseMode;` IS NOT IN THE CLAIMED SOURCE. This is the real problem. I fetched https://docs.flutter.dev/testing/errors, the only cited source. It shows:

  PlatformDispatcher.instance.onError = (error, stack) {
    myErrorsHandler.sendError(error, stack);
    return true;
  };

It returns `true` unconditionally, and the page contains NO explanation of the bool return value at all — no mention of kReleaseMode, no debug/release split, nothing. The cited source therefore supports neither the prescription nor even the semantics the researcher attributes to it (those come from api.flutter.dev, which was not cited). This is a team practice presented as sourced guidance. Cargo cult, confirmed by direct fetch. Flutter's own issue #117623 ("Clarify that 'Handling errors in Flutter' is about Dart reports") is open precisely because this page is underspecified — nobody from the Flutter team has clarified return-value semantics there.

SCOPE NUANCE the claim omits: "hide errors from you in debug" applies only to uncaught root-isolate/async errors. FlutterError.onError (widget build/layout errors) is a separate channel entirely and is unaffected by this return value. Also per the doc, onError "is not directly invoked by errors in child isolates of the root isolate."

CORROLARY ON RECURSION: UNVERIFIABLE from primary sources. Plausible and mechanically sensible (a throw inside the handler re-enters as another unhandled error), but I found no api.flutter.dev or docs.flutter.dev text stating it. Treat as sound engineering instinct, not documented behavior. It should not be presented with a citation.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dart3-idioms" made this claim, and a project decision depends on it.

CLAIM: PlatformDispatcher.instance.onError's bool return means 'handled, suppress default reporting' — it does not keep the app alive, and returning true unconditionally will hide errors from you in debug.
DETAIL: The handler signature is `bool Function(Object error, StackTrace stack)`. Returning true marks the error handled so it is not forwarded to the default handler (which prints to console). Uncaught async errors do not terminate a Flutter app regardless. So the return value is purely a reporting decision: in this app, return `true` in release (log silently to disk, keep the crisis UI up) and `false` in debug so the console still shows it. `return kReleaseMode;` is the whole rule. Corollary that matters more: the log writer itself must never throw, or an error inside the error handler recurses.
CLAIMED SOURCES: https://docs.flutter.dev/testing/errors
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
