# riverpod--automatic-retry-is-on-by-default-in-riverpod

> Phase: **verify** · Agent `aa49ca27ce21699de` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep the recommendation; fix the reasoning. Correct statement: Riverpod 3 (verified in 3.3.2) retries failing providers by default via `ProviderContainer.defaultRetry`, bounded at `maxRetries = 10` with delays 200ms doubling to a 6400ms ceiling — 38.2 seconds of total added delay, after which the error surfaces as AsyncError. It is NOT indefinite. The error is NOT hidden: during retry the provider exposes `AsyncLoading` carrying `error: (err, stack, retrying: true)`. Retry already skips `Error` subclasses and `ProviderException` (`if (error is ProviderException || error is Error) return null;`), so drift/programmer bugs that throw an `Error` already fail loud and immediate; only `Exception` subclasses (SqliteException, FileSystemException) are retried. The `Retry` typedef and the disable snippet in the claim are exactly correct as written. Drop the pumpAndSettle rationale entirely, or restate it correctly: a pending retry is a `Timer`, and pumpAndSettle waits on scheduled frames, not Timers, so bare `pumpAndSettle()` does not hang — the actual issue (#4431) is that `pumpAndSettle(Duration(seconds: 30))` advances the fake clock, fires the retry timers, and lets retry exceptions escape as unhandled test errors, which the maintainer classified as a Riverpod bug rather than expected behavior.

**Evidence:** I tried to break this claim and mostly failed. Every API detail is exactly right — unusually so. But two load-bearing pieces of the RATIONALE are wrong, and one is backwards.

VERIFIED CORRECT (downloaded riverpod 3.3.2 from pub.dev and read the source):

1. Retry IS on by default. `element.dart:764` — `origin.retry ?? container.retry ?? ProviderContainer.defaultRetry`. No opt-in.
2. Backoff numbers exact. `provider_container.dart:940-954`: `minDelay = 200ms`, `maxDelay = 6400ms`, `delay = minDelay * pow(2, retryCount)`. Claim's "200ms doubling to 6.4s" is verbatim correct.
3. Typedef exact. `provider_container.dart:293`: `typedef Retry = Duration? Function(int retryCount, Object error);` — character-for-character what the claim states. `ProviderContainer({..., Retry? retry})` confirms the named type. Not an invented signature.
4. Disable code correct. `retry: (retryCount, error) => null` on ProviderScope is the documented global disable.
5. Package alive. flutter_riverpod 3.3.2, published ~35 days ago, publisher dash-overflow.net, Flutter Favorite, 140 pub points. Not dead, not discontinued.
6. All three cited sources are real, including discussion #4431 — which really is titled "Automatic retry causes test failures with a duration in pumpAndSettle() in tests".

WHERE IT BREAKS:

A. "indefinite loading state" — FALSE. Retry is hard-bounded. `provider_container.dart:947`: `if (retryCount >= maxRetries) return null;` with `maxRetries = 10`. Delays are [200, 400, 800, 1600, 3200, 6400, 6400, 6400, 6400, 6400] = 38.2 seconds total, then AsyncError surfaces normally. It's a 38-second delay, not an indefinite hang. (Issue #4441 does report a forever-retry loop, but only with `invalidate(asReload: true)`, is labeled "needs triage", and is an unconfirmed bug — not default behavior.)

B. "converts that loud, diagnosable error into a loading state" — FALSE, the error is preserved. `element.dart:786-790`, while retrying, returns:
    AsyncLoading<ValueT>._(..., error: (err: error, stack: stackTrace, retrying: true))
The error and stack ride along on the AsyncLoading with an explicit `retrying: true` flag. Nothing is swallowed; it's inspectable the whole time.

C. The rationale's own examples partly defeat it. `provider_container.dart:948`: `if (error is ProviderException || error is Error) return null;`. Riverpod ALREADY never retries `Error` subclasses (AssertionError, StateError, TypeError) or ProviderException. So the "drift migration that went wrong" / genuine-bug class the claim is most worried about already fails loud and immediate with zero retry. The concern only survives for `Exception` subclasses — which does still cover SqliteException (corrupt DB) and FileSystemException/PathNotFoundException (missing image/sound). So roughly half the stated failure modes are already exempt by design.

D. The pumpAndSettle claim is INVERTED — this is the clearest error. Claim says retry "breaks pumpAndSettle(), which times out waiting for a scheduler that never settles." api.flutter.dev says pumpAndSettle "Repeatedly calls pump ... until there are no longer any frames scheduled" — it waits for FRAMES, not Timers. Riverpod schedules retries with `_pendingRetryTimer = Timer(duration, ...)` (element.dart:791). A pending Timer does not keep the scheduler unsettled, so bare `pumpAndSettle()` returns fine. Discussion #4431 states this explicitly: "Without duration: Tests pass (retries don't complete)." The real failure is the opposite of what's claimed — `pumpAndSettle(Duration(seconds: 30))` advances the fake clock, FIRES the retry timers, and the retry exceptions escape as unhandled test errors. And rrousselGit called that a Riverpod bug ("Looks like there's a bug that cause a silent exception to be allowed"), not intended behavior to design around.

BOTTOM LINE: The action (disable globally) and the exact code are correct and safe to adopt. The justification is inflated — the researcher argued from "indefinite hang + error erased + tests hang," and the true cost is "38s delay on Exception-class failures only, with the error still attached." That's a real annoyance on a device the developer never sees, so the decision can stand, but it should be made on the honest 38-second number, not on a hang that doesn't exist. Confidence "high" was not warranted on the rationale.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "riverpod" made this claim, and a project decision depends on it.

CLAIM: Automatic retry is ON by default in Riverpod 3 and is actively harmful for this app. Disable it globally.
DETAIL: Riverpod 3 retries failing providers by default with exponential backoff starting at 200ms and doubling to 6.4s. The rationale is transient network failure — a failure mode this app does not have by construction. Here, a provider that throws means a corrupt DB, a missing image/sound file on disk, or a drift migration that went wrong. Retry converts that loud, diagnosable error into an indefinite loading state, on a device where the developer will never learn it happened (constraint #1). Disable with `retry: (retryCount, error) => null` on ProviderScope; the `Retry` typedef is `Duration? Function(int retryCount, Object error)` and returning null means do not retry. Secondary benefit: retry with a backoff Duration also breaks `tester.pumpAndSettle()` in widget tests, which times out waiting for a scheduler that never settles.
CLAIMED SOURCES: https://riverpod.dev/docs/concepts2/retry, https://riverpod.dev/docs/3.0_migration, https://github.com/rrousselGit/riverpod/discussions/4431
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
