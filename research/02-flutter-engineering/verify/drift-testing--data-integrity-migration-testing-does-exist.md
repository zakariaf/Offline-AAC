# drift-testing--data-integrity-migration-testing-does-exist

> Phase: **verify** · Agent `afdadcaf8ef64436f` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim is substantively correct and needs no correction to its core assertion. Two refinements for precision: (1) `startAt` is NOT superseded by `schemaAt` — both exist in current drift_dev 2.34.4. `startAt(int) → Future<DatabaseConnection>` is the entry point for schema-only validation tests; `schemaAt(int) → Future<InitializedSchema<Database>>` is the entry point for data-integrity tests. The claim's "schemaAt (not startAt)" phrasing should be read as scoped to the data-integrity pattern only. (2) The claim understates the current tooling: `SchemaVerifier.testWithDataIntegrity<OldDatabase, NewDatabase>({...})` is a higher-level helper that encapsulates the insert/migrate/reopen/assert sequence, recently extended with a ValidationOptions parameter, and drift's make-migrations proactively suggests it when a column is added without a default. Teams adopting this should evaluate testWithDataIntegrity before hand-rolling the three-connection pattern.

**Evidence:** Every named API was independently verified against primary sources on 2026-07-15.

pub.dev API docs for SchemaVerifier (drift_dev, migrations_native library) confirm the exact signatures:
- `schemaAt(int version) → Future<InitializedSchema<Database>>` — "Creates a new database and instantiates the schema with the given version." Exact name, exists.
- `migrateAndValidate(GeneratedDatabase db, int expectedVersion, {ValidationOptions options = const ValidationOptions(), bool? validateDropped}) → Future<void>` — exists.
- `InitializedSchema.newConnection()` — exists, and is what allows multiple era-specific database objects to attach to the same underlying database.

The official docs at drift.simonbinder.eu/migrations/tests/ contain the codegen command verbatim as claimed: `dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/generated_migrations/`, and the generated class naming `DatabaseAtV{n}` (DatabaseAtV1, DatabaseAtV2). The documented data-integrity example matches the claimed pattern nearly line-for-line: `final schema = await verifier.schemaAt(1);` → `v1.DatabaseAtV1(schema.newConnection())` → insert via `v1.TodosCompanion.insert(...)` → close → `MyDatabase(schema.newConnection())` → `await verifier.migrateAndValidate(db, 2)` → close → `v2.DatabaseAtV2(schema.newConnection())` → assert rows present and correct.

Package liveness checks (hunting for the "dead package presented as alive" failure mode) came back negative: drift_dev latest is 2.34.4, published approximately 25 hours before the check date, by verified publisher simonbinder.eu, not marked discontinued or unmaintained. No version rot: this is not a 2023 API that was since removed — it is current as of the most recent publish.

No invented API names were found. No overstated consensus — this is first-party documentation of first-party tooling, not a blog post generalized into a community practice.

Two accuracy caveats that do not refute the core claim:
1. The parenthetical "schemaAt (not startAt) is the entry point" is misleading. `startAt(int version) → Future<DatabaseConnection>` also exists and is current ("Creates a DatabaseConnection that contains empty tables created for the known schema version"). The two serve different tests: startAt for schema-only validation, schemaAt for the data-integrity variant. The claim is correct that schemaAt is the entry point for THIS pattern, but the phrasing wrongly implies startAt is stale or nonexistent.
2. The claim omits `testWithDataIntegrity<OldDatabase extends GeneratedDatabase, NewDatabase extends GeneratedDatabase>({...}) → Future<void>`, a higher-level SchemaVerifier helper that wraps the manual pattern. The changelog shows it recently gained a ValidationOptions parameter, and drift's make-migrations now suggests a data-integrity test when adding a column without a default value. The manual pattern remains valid and documented, but is no longer the only or most idiomatic route.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "drift-testing" made this claim, and a project decision depends on it.

CLAIM: Data-integrity migration testing DOES exist: `verifier.schemaAt(n)` + `schema generate --data-classes --companions`
DETAIL: THE mechanism the task asked about. `dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/generated_migrations/` emits schema_v1.dart, schema_v2.dart… each containing a full versioned database class (`DatabaseAtV1`) with era-correct data classes and companions. Test pattern: `final schema = await verifier.schemaAt(1);` then `v1.DatabaseAtV1(schema.newConnection())` to INSERT real rows, close, open the real `AppDatabase(schema.newConnection())`, `migrateAndValidate(db, 2)`, close, then reopen as `v2.DatabaseAtV2(schema.newConnection())` and assert the rows are present AND correct. Note `schemaAt` (not `startAt`) is the entry point — `schema.newConnection()` can be called repeatedly against the same underlying database, which is what lets three different-era database objects see the same bytes.
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
