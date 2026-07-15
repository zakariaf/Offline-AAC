# dart3-idioms--do-not-use-runzonedguarded-in-flutter-3-10-u

> Phase: **verify** · Agent `ad1f70b49ea480e33` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** The decision stands (two handlers, no zone) but two specifics in the claim's reasoning should be fixed before it enters the corpus:

(1) The claim mischaracterizes Sentry, and the error cuts in the claim's favor. Current Sentry Flutter docs do not use runZonedGuarded — the recommended init is SentryFlutter.init(..., appRunner: () => runApp(SentryWidget(child: MyApp()))). Sentry's usage page states the SDK "runs your init callback on an error handler, such as runZonedGuarded on Flutter versions prior to 3.3, or PlatformDispatcher.onError on Flutter versions 3.3 and higher." Sentry tracked this in getsentry/sentry-dart#988, titled "Use PlatformDispatcher.onError instead of custom zone starting with Flutter 3.3", and their troubleshooting page warns that combining appRunner with your own runZonedGuarded is what CAUSES the zone mismatch. So the claim's rationale "Sentry needs a zone because it wraps init" is outdated (true pre-3.3, false now), and the framing "sources conflict / Sentry says use all three" is false. The real split is Flutter + Sentry on one side vs. SEO "complete guide" blog posts on the other — the blogs are the outlier, not a competing authority. Sentry.runZonedGuarded still exists but is offered only as an optional extra for breadcrumb capture of print(), not as a requirement.

(2) Add a scope caveat the claim omits: PlatformDispatcher.onError only covers the root isolate. Its doc says "A callback that is invoked when an unhandled error occurs in the root isolate" and "This callback is not directly invoked by errors in child isolates of the root isolate." Errors in spawned isolates need Isolate.addErrorListener. This does not change the verdict, since runZonedGuarded does not catch child-isolate errors either — so it is not an argument for adding a zone.

**Evidence:** Attempted refutation on all four failure modes; the claim's actionable recommendation (two handlers, no zone) survives every primary source.

1. docs.flutter.dev/testing/errors — CONFIRMED verbatim. Shows only FlutterError.onError and PlatformDispatcher.instance.onError. Contains no mention of runZonedGuarded, "zone", or "Zone" anywhere on the page. Code samples given are exactly the two-handler pattern.

2. docs.flutter.dev/release/breaking-changes/zone-errors — CONFIRMED verbatim. "Starting with Flutter 3.10, the framework detects mismatches when using Zones and reports them to the console in debug builds." And: "The best way to silence this message is to remove use of Zones from within the application. Zones can be very hard to debug, because they are essentially global variables, and break encapsulation. Best practice is to avoid global variables and zones." The claim's specific footgun is documented: the page's fallback fix is "moving the call to WidgetsFlutterBinding.ensureInitialized() to the same closure as the call to runApp()", and the warning text itself cites "zone-specific configuration will inconsistently use the configuration of the original binding initialization zone or this zone" — matching the claim's "zone-specific config then applies inconsistently" nearly word for word.

3. api.flutter.dev/flutter/dart-async/runZonedGuarded.html — CONFIRMED. No Flutter recommendation either direction, as claimed. Signature is real and current: R? runZonedGuarded<R>(R body(), void onError(Object error, StackTrace stack), {Map<Object?, Object?>? zoneValues, ZoneSpecification? zoneSpecification}).

4. API-existence check (failure mode 3 — invented signatures): both names are real, not LLM-plausible. PlatformDispatcher.onError is "ErrorCallback? get onError" on api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html. FlutterError.onError is "static FlutterExceptionHandler? onError = presentError" on api.flutter.dev/flutter/foundation/FlutterError/onError.html.

5. Version rot check (failure mode 1): none. Guidance is current as of Flutter 3.44.0; nothing in current docs re-endorses zones. The pivot point is Flutter 3.3 (introduction of PlatformDispatcher.onError) and 3.10 (mismatch detection), both older than and consistent with the claim.

6. Consensus check (failure mode 5): the claim's "sources conflict" premise is itself the weakest part — and it is wrong in the claim's own favor. Sentry does NOT say "use all three."

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dart3-idioms" made this claim, and a project decision depends on it.

CLAIM: Do NOT use runZonedGuarded in Flutter 3.10+. Use FlutterError.onError + PlatformDispatcher.instance.onError only. Sources conflict on this; the official Flutter doc is decisive.
DETAIL: ADVERSARIAL CHECK — sources disagree. Sentry's docs and several 2026 'complete guide' posts say 'use all three handlers, you need all three to catch 100% of production errors.' Against that: (1) docs.flutter.dev/testing/errors — the official error-handling page — shows ONLY FlutterError.onError + PlatformDispatcher.instance.onError and does not mention runZonedGuarded at all. (2) docs.flutter.dev/release/breaking-changes/zone-errors states Flutter 3.10+ detects zone mismatch and warns, and that 'the best way to silence this message is to remove use of Zones from within the application.' (3) The dart:async runZonedGuarded API doc carries no Flutter recommendation either way. The 'use all three' advice is crash-SDK advice — Sentry needs a zone because it wraps init. This app has no SDK, so the zone buys nothing and costs a documented footgun: WidgetsFlutterBinding.ensureInitialized() outside the zone triggers the mismatch, and zone-specific config then applies inconsistently. Verdict: two handlers, no zone.
CLAIMED SOURCES: https://docs.flutter.dev/testing/errors, https://docs.flutter.dev/release/breaking-changes/zone-errors, https://api.flutter.dev/flutter/dart-async/runZonedGuarded.html, https://docs.sentry.io/platforms/flutter/usage/
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
