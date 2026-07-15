# performance-startup--the-already-decided-quick-settings-tileservi

> Phase: **verify** · Agent `ade0d64ba9df95f5d` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The ARCHITECTURE survives; the SUPERLATIVE and every load-bearing SPECIFIC fails. Four corrections, in order of how badly they hurt:

(1) THE TESTABLE INVARIANT AS SPECIFIED IS SELF-DEFEATING — this is the worst error. "Edit a tile in Dart → assert the SharedPreferences value changed" does NOT work as a Dart unit/widget test. `SharedPreferences.setMockInitialValues` is in-memory only and "will not persist values to the usual preference store." The test asserts a fake mutated a fake. It passes green while the Kotlin read path is broken — manufacturing false confidence in EXACTLY the silent failure the claim says it's guarding against. Worse, `setMockInitialValues` doesn't apply to the Async side at all (flutter/flutter#174643); with `SharedPreferencesWithCache` you get "Bad state: The SharedPreferencesAsyncPlatform instance must be set", and the workaround `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData({})` is still in-memory. CORRECT INVARIANT: an `integration_test` on a real device/emulator that writes via Dart and reads back through the actual native store (MethodChannel to Kotlin, or the same DataStore/XML file the TileService reads). Nothing less tests the mirror.

(2) "READS SHAREDPREFERENCES" IS WRONG BY DEFAULT ON CURRENT shared_preferences (2.5.5, flutter.dev, published ~3 months ago). Two independent traps: (a) the legacy `SharedPreferences` API is documented as "a legacy API that will be deprecated in the future"; the recommended `SharedPreferencesAsync` defaults to **DataStore Preferences**, NOT SharedPreferences XML — "In most cases you should use the default option of DataStore Preferences." A Kotlin `getSharedPreferences("FlutterSharedPreferences", ...)` reads NOTHING unless you explicitly opt into the SharedPreferences backend via `SharedPreferencesAsyncAndroidOptions`. (b) The legacy API prefixes EVERY key with `flutter.` — native `getString("phrase")` returns null; the key is `flutter.phrase`. `setPrefix` must be called before any instance is created or it fails. Also note DataStore is Flow/coroutine-based with no synchronous read — it adds latency on the one path that must be instant. Pick the backend deliberately and write it down.

(3) "SKIPS PROCESS-SPAWN-OF-FLUTTER" DESCRIBES A NONEXISTENT THING. There is no separate Flutter process — the engine runs in-process. TileService is a bound service in YOUR app's process, so a cold tile tap still pays zygote fork + ART/dex class load + `Application.onCreate`. (`FlutterApplication` is now a deprecated EMPTY shim, so it adds nothing — which is why the remaining spawn cost is plain-Android cost you cannot skip.) What IS genuinely skipped: FlutterActivity, FlutterEngine init, Dart VM snapshot load, drift open, first frame. Real and worth having — just smaller than "skips process spawn."

(4) "ORDER OF MAGNITUDE" IS UNVERIFIABLE AND THE HIDDEN DOMINANT TERM IS UNSKIPPED. No primary source measures Android `TextToSpeech` cold `onInit`/engine-bind latency — I searched and it is simply not documented. Both paths pay TTS engine bind + onInit, and the tile does NOT skip it. If that term dominates (plausible — it's an IPC bind to a separate TTS engine process, often hundreds of ms), the ratio collapses toward ~1x. This is a measurement, not an assertion: instrument tap→first-audio-frame on real hardware before any roadmap leans on it.

(5) "SINGLE HIGHEST-LEVERAGE" IS REFUTED BY REACH. Android docs are explicit that users must MANUALLY add tiles: swipe down, tap edit, scroll to find yours, hold and drag. `requestAddTileService` (Android 13 / API 33+) only shows a prompt the user can decline, and the docs advise calling it sparingly and in-context. So the tile is an Android-only, opt-in surface reaching a minority of a minority — while the in-app tile grid serves 100% of users on both platforms. A path most users never enable cannot be the highest-leverage performance decision. It's the FASTEST path (the project's own verified platform-integration research supports that), which is not the same claim. The highest-leverage performance decision is almost certainly app cold-start-to-interactive-grid, which every user pays every time.

**Evidence:** Attacked on five fronts. The architecture held; the superlative and all the engineering specifics broke.

WHAT SURVIVES: The native-speak-path design is independently corroborated. developer.android.com confirms TileService is a bound service whose onClick() runs without an Activity, that tiles "may display on top of the lock screen," that isLocked()/isSecure() report state, and that unlockAndRun() is needed only for actions unsafe while locked — speaking a stored phrase isn't one. The project's own platform-integration research already reached this (research/01-product-and-market/research/platform-integration.md:125, and the ARCHITECTURAL CONSEQUENCE section at :173 which already says "phrases persisted to ... SharedPreferences or DataStore (Android); the TileService reads the phrase natively ... with zero Flutter involvement"). Note that prior finding is rated **medium** confidence, and it already flagged the DataStore ambiguity this claim flattened into "SharedPreferences." The claim is largely a restatement of an existing finding at inflated confidence.

BREAK 1 — THE TEST INVARIANT (fatal, and ironic). pub.dev/shared_preferences + flutter/flutter#174643 + #172012: the mock "is in-memory only and will not persist values to the usual preference store," and setMockInitialValues has no Async equivalent ("Bad state: The SharedPreferencesAsyncPlatform instance must be set"). The claim's proposed guard against a silent correctness failure IS a silent correctness failure — a green unit test over a fake, while the Kotlin reader gets null. The claim's own stated stakes ("a stale mirror means the QS tile speaks the OLD phrase — no telemetry to catch it") indict its own test design.

BREAK 2 — THE MIRROR MECHANISM. pub.dev/packages/shared_preferences (2.5.5, flutter.dev verified publisher, published ~3 months ago — package is ALIVE, no rot there): legacy SharedPreferences is "a legacy API that will be deprecated in the future"; SharedPreferencesAsync defaults to DataStore Preferences, and "In most cases you should use the default option of DataStore Preferences." Independently confirmed: keys are stored in FlutterSharedPreferences.xml with an automatic "flutter." prefix, and native access requires either accounting for the prefix or pointing a DataStore instance at name="FlutterSharedPreferences". "Reads SharedPreferences" is underspecified to the point of being a bug.

BREAK 3 — THE PROCESS MODEL. api.flutter.dev/javadoc FlutterApplication: now an "Empty implementation of the Application class, provided to avoid breaking older Flutter projects," pointing at the v1-embedding removal. There is no Flutter process to skip; the engine is in-process. A cold tile tap still spawns the app process. The skipped set (FlutterActivity/engine/Dart VM snapshot/drift/first frame) is real but is not "process spawn."

BREAK 4 — THE QUANTITY. No primary source documents Android TextToSpeech onInit/engine-bind latency. Multiple targeted searches returned only cloud-TTS vendor latency blogs and unrelated patents. "Plausibly an order of magnitude" is a guess with no measurement behind it, and the un-skipped TTS bind sits on both sides of the ratio. UNVERIFIABLE as stated.

BREAK 5 — THE SUPERLATIVE. developer.android.com/develop/ui/views/quicksettings-tiles: users must manually add tiles (swipe → edit → scroll → hold and drag); requestAddTileService is API 33+ and merely prompts, with docs recommending it be called only in-context "to increase discoverability while reducing user burden" — i.e. a decline-able prompt on a subset of Android. Android-only + opt-in cannot outrank the universal app path. Confidence "high" is not warranted; the underlying research said medium.

BOTTOM LINE FOR THE DECISION: keep the native TileService speak path — it's well-founded and the project already committed to it on better evidence. Do NOT keep this claim's three deliverables: the "SharedPreferences" mirror spec (choose and pin the backend explicitly), the "order of magnitude" number (measure tap→first-audio on hardware), and above all the Dart-unit-test invariant (must be integration_test against the real native store, or it is worse than no test).

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "performance-startup" made this claim, and a project decision depends on it.

CLAIM: The already-decided Quick Settings TileService is the single highest-leverage performance decision in the project
DETAIL: A Kotlin TileService that reads SharedPreferences and calls Android TextToSpeech natively with NO Flutter engine on that path skips process-spawn-of-Flutter, engine init, Dart VM snapshot load, drift open, and first frame entirely. It is plausibly an order of magnitude faster to speech than the app path. The engineering consequence: the SharedPreferences mirror must be a write-through cache updated on EVERY board edit, and that sync is a testable invariant (edit a tile in Dart → assert the SharedPreferences value changed). A stale mirror means the QS tile speaks the OLD phrase — a silent correctness failure with no telemetry to catch it.
CLAIMED SOURCES: (none)
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
