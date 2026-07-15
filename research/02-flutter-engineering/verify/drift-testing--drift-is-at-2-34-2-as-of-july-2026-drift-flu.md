# drift-testing--drift-is-at-2-34-2-as-of-july-2026-drift-flu

> Phase: **verify** · Agent `ad163e6bee7f9a63b` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction needed to the substance. Optional precision for the corpus: drift_flutter is cross-platform (driftDatabase also takes DriftWebOptions; web uses FileSystem API/IndexedDB), not native-only; and DriftNativeOptions exposes isolateDebugLog, databasePath(), databaseDirectory(), tempDirectoryPath(), isolateSetup(), and setup() in addition to shareAcrossIsolates (bool, default false). Record drift 2.34.2 as a timestamped observation as of 2026-07-15 rather than a stable version pin.

**Evidence:** All claimed facts independently verified against pub.dev primary sources on 2026-07-15.

VERSIONS: pub.dev/packages/drift shows latest version 2.34.2, published ~25 hours prior (matches "within the last day"), publisher simonbinder.eu (verified), NOT discontinued, actively maintained (2.43k likes, 160 pub points). pub.dev/packages/drift_flutter exists, latest version 0.3.1, published 4 days prior, same verified publisher simonbinder.eu, not discontinued. No version rot; no dead-package issue.

API SIGNATURE (the highest-risk element — verified exactly, not invented): dartdoc for drift_flutter gives:
  DatabaseConnection driftDatabase({required String name, DriftWebOptions? web, DriftNativeOptions? native})
So driftDatabase(name: 'app_db') is a valid, correctly-named call.

NATIVE STORAGE BEHAVIOR: dartdoc states verbatim "On native platforms, a file called $name.sqlite in getApplicationDocumentsDirectory() will be used for the database." This substantiates both the .sqlite extension and the application-documents-directory claim.

DriftNativeOptions.shareAcrossIsolates: confirmed to exist with that exact name, type bool, default false. The "optional ... for multi-isolate apps" characterization is accurate.

RATIONALE: package description "Easily set up drift databases across platforms in Flutter apps" and its stated purpose ("This package provides a single method: driftDatabase, which returns a drift database implementation suitable for the current platform") match the researcher's framing of a thin wrapper handling path_provider + platform selection, existing because core drift is Dart-only.

TWO MINOR REFINEMENTS (do not undermine the verdict):
1. Calling it a "Flutter-only wrapper ... (application documents dir, .sqlite file on native)" slightly undersells scope: driftDatabase also accepts DriftWebOptions; on web the name maps to a FileSystem API path or IndexedDB identifier. It is cross-platform, not native-only.
2. "A single driftDatabase helper" is the package's own wording, but DriftNativeOptions has more surface than shareAcrossIsolates alone: isolateDebugLog (bool, default false), databasePath(), databaseDirectory(), tempDirectoryPath(), isolateSetup(), setup().

DURABILITY CAVEAT (accuracy is fine; perishability is the risk): a version published 25 hours ago is the most perishable fact type in this corpus. drift ships frequently, so 2.34.2 should be recorded as a timestamped observation (as of 2026-07-15), not treated as a stable pin.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "drift-testing" made this claim, and a project decision depends on it.

CLAIM: drift is at 2.34.2 as of July 2026; drift_flutter exists and is at 0.3.1
DETAIL: drift 2.34.2 published within the last day of research. drift_flutter 0.3.1 is a thin Flutter-only wrapper providing a single `driftDatabase(name: 'app_db')` helper that handles path_provider + platform selection (application documents dir, .sqlite file on native). It exists precisely because core drift is Dart-only and cannot depend on Flutter. Optional `native: DriftNativeOptions(shareAcrossIsolates: true)` for multi-isolate apps.
CLAIMED SOURCES: https://pub.dev/packages/drift, https://pub.dev/packages/drift_flutter
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
