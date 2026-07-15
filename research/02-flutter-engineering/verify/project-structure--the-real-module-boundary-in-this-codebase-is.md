# project-structure--the-real-module-boundary-in-this-codebase-is

> Phase: **verify** · Agent `a892e90fd8d9ca3fd` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Keep the one-file-per-side discipline; fix the mechanism, the risk story, and the confidence.

MECHANISM: Do not hand-roll a SharedPreferences key contract against shared_preferences. Its Android default is DataStore Preferences (protobuf, FlutterSharedPreferences.preferences_pb), which context.getSharedPreferences() cannot read at all, and native access to it is an open unresolved issue (flutter/flutter#154208, P3). Two correct options:
(a) PREFERRED — use home_widget 0.9.3 (already the doc's chosen package): HomeWidget.saveWidgetData<String>(...) from Dart, and in the TileService read via `import es.antonborri.home_widget.HomeWidgetPlugin` → `HomeWidgetPlugin.getData(context).getString(key, null)`. This is plain SharedPreferences ("HomeWidgetPreferences"), no prefix, and is the package's supported native-read path.
(b) If shared_preferences is required, explicitly opt into the SharedPreferences backend via SharedPreferencesAsyncAndroidOptions with SharedPreferencesAndroidBackendLibrary.SharedPreferences, and account for the `flutter.` key prefix on the legacy API — Kotlin must read "flutter.<key>", not "<key>".

RISK STORY: This boundary fails loudly and deterministically (wrong store or wrong prefix ⇒ every tap speaks nothing, caught by the first manual tap), not silently. It is not an instance of the silent-failure class. The genuinely silent risks on this path are different and worth naming instead: a stale value (tile speaks yesterday's phrase because Dart wrote after the last widget update), an empty-but-present string passing a null check, and encoding drift on List<String>.

ENFORCEMENT: "Zero type checking" is real for key strings but the doc-comment-on-both-sides proposal is the weakest available option. Stronger: one Dart file + one Kotlin object is fine as structure, but enforce it with an integration test that writes from Dart and asserts the Kotlin read path returns the exact value — that catches renames, prefix errors, backend misconfiguration, and encoding drift in one check. A doc comment catches none of them.

STATUS: Downgrade confidence from high to medium-at-best, and label it a proposal, not a description — there is no Dart or Kotlin in this repo yet, and the source doc rates this consequence "medium" while hedging the storage as "SharedPreferences or DataStore".

**Evidence:** The abstract point — a cross-language key/encoding contract is unenforced and should be isolated to one file per side — is directionally sound and follows from the repo's own design doc. But every load-bearing specific is wrong, and the cited source supports none of it.

1. THE CITED SOURCE IS OFF-TARGET. https://docs.flutter.dev/platform-integration/platform-channels is exclusively about MethodChannel / BasicMessageChannel / EventChannel, the standard message codec, threading, background isolates, and Pigeon. It never mentions SharedPreferences, shared storage, key-naming contracts, QuickSettings, or TileService. The claim's own design has NO platform channel on the tile path — so the single cited source documents the exact mechanism the design excludes. Zero support for the claim.

2. "SHAREDPREFERENCES CONTRACT" NAMES THE WRONG BACKEND. shared_preferences 2.5.5 (publisher flutter.dev) / shared_preferences_android 2.4.27 (published ~2 days ago, actively maintained): for SharedPreferencesAsync and SharedPreferencesWithCache, **DataStore Preferences is the default Android backend, not SharedPreferences**. Data lands at /data/user/0/<pkg>/files/datastore/FlutterSharedPreferences.preferences_pb in DataStore's protobuf format. A Kotlin TileService calling context.getSharedPreferences(...) reads NOTHING — no key name will save it. flutter/flutter#154208 (OPEN, P3) is literally a request to expose that DataStore to native code, and notes that opening a second DataStore instance on the same file is a runtime error. Native access to Flutter's default prefs store is an unresolved request, not a contract.

3. THE KEYS AREN'T EVEN THE SAME STRINGS. Per the shared_preferences README: "By default, the SharedPreferences class will only read (and write) preferences that begin with the prefix `flutter.`" So on the legacy/SharedPreferences backend, Dart's "vocalization_text" is stored as "flutter.vocalization_text". The claim's premise that one Dart file and one Kotlin object "mirror" the same key strings is incorrect as written.

4. THE SILENT-FAILURE ARGUMENT INVERTS. Given (2) and (3), the realistic failure is not a slow silent drift from a Dart rename — it is a total, deterministic, day-one, every-single-tap failure caught by one manual tile tap. A key rename is caught by that same first tap. This is the LOUD failure class, not the silent one. The claim's core risk argument (constraint 4, silent failure on the mid-shutdown path) does not hold for this boundary.

5. THE BOUNDARY ALREADY EXISTS IN THE NAMED PACKAGE. home_widget 0.9.3 (antonborri.es, verified, published ~37 days ago, active) — the package the repo's own doc names — ships the accessor: `private const val PREFERENCES = "HomeWidgetPreferences"` and `fun getData(context: Context): SharedPreferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)`. Plain SharedPreferences, no prefix, natively readable. Pigeon (documented on the very page cited) is Flutter's type-safe Dart↔native codegen. "Nothing in the compiler enforces it" is trivially true of any string key but presents a hand-rolled contract as the situation when the named package supplies the accessor.

6. THERE IS NO CODEBASE. "The real module boundary in this codebase" — the repo contains only idea.md, RESEARCH.md, analysis_options.yaml, and research/. No lib/, no pubspec.yaml, no .dart file, no .kt file anywhere. lib/native/quick_tile_bridge.dart and QuickTileKeys.kt do not exist and are proposals. The source doc's own rating for the native-storage-boundary consequence is "Confidence: medium", and it hedges the mechanism as "SharedPreferences or DataStore (Android)" — the claim hardened a medium-confidence hedge into a settled fact.

Repo files examined (absolute paths): /Users/zakariafatahi/50-apps-challenge/Offline-AAC/idea.md, /Users/zakariafatahi/50-apps-challenge/Offline-AAC/research/01-product-and-market/research/platform-integration.md

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "project-structure" made this claim, and a project decision depends on it.

CLAIM: The real module boundary in this codebase is the Dart↔Kotlin SharedPreferences contract the QS tile reads — and nothing in the compiler enforces it.
DETAIL: The decided design has the Android TileService speak natively from SharedPreferences with no Flutter engine on that path. That means the pref key names, value encoding, and the invariant 'the vocalization text is always present and non-empty' are a cross-language contract with zero type checking. If Dart renames a key, the tile silently speaks nothing — the exact silent-failure class of constraint 4, in the one code path the user reaches mid-shutdown. Structural consequence: exactly one Dart file (lib/native/quick_tile_bridge.dart) may touch those keys, exactly one Kotlin object (QuickTileKeys.kt) may mirror them, and the key strings belong in a doc comment on both.
CLAIMED SOURCES: https://docs.flutter.dev/platform-integration/platform-channels
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
