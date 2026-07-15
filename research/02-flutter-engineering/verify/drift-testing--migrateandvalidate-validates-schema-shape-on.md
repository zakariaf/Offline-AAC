# drift-testing--migrateandvalidate-validates-schema-shape-on

> Phase: **verify** · Agent `a7a720c8e00e76e45` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the claim as stated; it is accurate. One constructive supplement: the claim implies the only recourse is knowing about the gap. drift_dev ships `testWithDataIntegrity` (used by generated migration tests, params: createOld, createNew, openTestedDatabase, createItems, validateItems, oldVersion, newVersion), which closes the gap directly. The docs' manual alternative is `verifier.schemaAt(version)` -> `Future<InitializedSchema<Database>>` plus versioned data classes from `drift_dev schema generate --data-classes --companions`. Also note migrateAndValidate's `ValidationOptions`/`validateDropped` params tune SCHEMA strictness only and should not be mistaken for data validation. Versions verified current as of 2026-07-15: drift 2.34.2, drift_dev 2.34.4.

**Evidence:** I tried to break this claim on version rot, dead-package status, invented API names, and overstated scope. It survived all four.

1. API NAMES EXIST, VERBATIM, WITH THE CLAIMED SEMANTICS. Verified against pub.dev's generated API docs for SchemaVerifier (migrations_native library), not just prose docs:
   - `Future<DatabaseConnection> startAt(int version)` — matches the claim's "returns a connection at version n" exactly.
   - `Future<void> migrateAndValidate(GeneratedDatabase db, int expectedVersion, {ValidationOptions options = const ValidationOptions(), bool? validateDropped})` — the claim's `migrateAndValidate(db, target)` is the correct positional shape.
   - Doc text: "Runs a schema migration and verifies that it transforms the database into a correct state." No mention of data.
   No LLM-plausible invented names here. These are real.

2. THE SCHEMA-ONLY SCOPE IS SUBSTANTIATED BY MECHANISM, NOT JUST BY OMISSION. The drift docs state migrateAndValidate extracts "all CREATE statement[s] from the sqlite_schema table and semantically compare[s] them." That is a definitionally structural check — sqlite_schema holds DDL, not rows. A migration that recreates a table with identical DDL and drops every row produces an identical sqlite_schema and therefore PASSES. The claim's specific failure scenario is mechanically correct, not merely rhetorically plausible.

3. NOT VERSION ROT. drift 2.34.2 and drift_dev 2.34.4, both published ~25 hours before checking (2026-07-14), publisher simonbinder.eu (verified). Neither is discontinued or unmaintained. This is a live, actively released package and the API is current, not a 2023 artifact.

4. THE DOCS AFFIRMATIVELY TREAT DATA SURVIVAL AS A SEPARATE PROBLEM. The cited page has a distinct section for verifying data persists, requiring a different workflow: generate versioned snapshots via `drift_dev schema generate --data-classes --companions`, obtain a raw connection via `verifier.schemaAt(version)` (returns `Future<InitializedSchema<Database>>`), insert data through versioned classes (e.g. v1.DatabaseAtV1), migrate, then read back through post-migration classes. The docs would not document a separate data-integrity workflow if migrateAndValidate already covered it. This corroborates the claim rather than contradicting it.

NUANCE THAT DOES NOT REFUTE (flagged for accuracy): migrateAndValidate does take a `ValidationOptions` parameter, which could superficially look like a data-validation hook. It is not — it governs schema validation strictness (e.g. validateDropped / dropped-entity handling). It does not inspect row contents, so it does not weaken the claim.

ONE ADDITION THE CLAIM OMITS (not an error, a gap): drift_dev also ships `testWithDataIntegrity`, the utility the *generated* migration tests use, taking createOld/createNew, openTestedDatabase, createItems, validateItems, oldVersion, newVersion. It also received a ValidationOptions parameter in recent drift_dev versions. This is the packaged answer to exactly the gap the claim identifies. The researcher's claim is correct that migrateAndValidate alone is insufficient; they may not know a first-party remedy already exists and does not require hand-rolling the schemaAt approach.

CONFIDENCE: high, matching the researcher's stated confidence. The claim is accurate in mechanism, in API naming, and in current-version applicability. The project decision it supports — that a green migrateAndValidate suite does not entitle you to believe user rows survived — is sound.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "drift-testing" made this claim, and a project decision depends on it.

CLAIM: `migrateAndValidate()` validates SCHEMA SHAPE ONLY — it does not prove the user's data survived
DETAIL: `verifier.startAt(n)` returns a connection at version n; `verifier.migrateAndValidate(db, target)` runs the migration and asserts the resulting schema matches the exported v-target schema. It says nothing about row contents. A migration that recreates a table correctly but drops every row PASSES migrateAndValidate. For this project that is the difference between a green test suite and a user with an empty board.
CLAIMED SOURCES: https://drift.simonbinder.eu/migrations/tests/
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
