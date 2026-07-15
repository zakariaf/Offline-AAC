# drift-testing--make-migrations-is-the-current-recommended-w

> Phase: **verify** · Agent `a338b210a4ee66e4e` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction required to any load-bearing specific. Optional precision: "supersedes" should be read as "is the recommended replacement for", not "deprecates/removes". The manual commands (`dart run drift_dev schema dump`, `dart run drift_dev schema steps`) remain available and functional in drift_dev 2.34.x; make-migrations combines them into one tool. Also note --no-test (added in drift_dev 2.29.0) is real but is documented in the changelog rather than on the migrations docs page, so a reader verifying only https://drift.simonbinder.eu/migrations/ will not find it.

**Evidence:** Attempted adversarial refutation across all five failure modes; the claim survived every check against primary sources.

1. RECOMMENDATION + SUPERSESSION — CONFIRMED, and it is the maintainer's own language, not community inference. https://drift.simonbinder.eu/migrations/ states verbatim: "Writing migrations manually is error-prone and can lead to data loss. We recommend using the `make-migrations` command to generate migrations and tests." The supersession half is explicit on https://drift.simonbinder.eu/migrations/exports/: "This command is specifically for exporting schemas. If you are using the `make-migrations` command, this is already done for you." This defeats the "overstated consensus" and "cargo cult" hypotheses — the claim's phrasing tracks the docs rather than inflating a blog post.

2. VERSION ROT — REFUTED as a failure mode. `make-migrations` was introduced in drift_dev 2.21.0 ("Add the `make-migrations` command which combines the existing schema commands into a single tool") and remains current. drift 2.34.2 published ~25 hours before checking (as of 2026-07-15). Not a stale 2023-era claim.

3. DEAD PACKAGE — REFUTED as a failure mode. pub.dev/packages/drift: verified publisher simonbinder.eu, 2.43k likes, 998k downloads, 160 pub points, no discontinued/unmaintained marker, repo (simolus3/drift) not archived and actively releasing.

4. INVENTED/MISREMEMBERED API — no fabrications found. Verified verbatim on primary docs: `dart run drift_dev make-migrations`; generated `database.steps.dart` next to the database class; `OnUpgrade get _schemaUpgrade => stepByStep(from1To2: (m, schema) async { await m.createTable(schema.groups); });`; applied via `MigrationStrategy(onUpgrade: _schemaUpgrade)`. The step_by_step page confirms: "The generated file (generated next to your database file) defines a stepByStep utility that can be passed to onUpgrade". Adjacent real APIs: `Migrator.runMigrationSteps`, `migrationSteps`.

5. build.yaml BLOCK — confirmed on the migrations page, matching the claimed keys: `databases: my_database: lib/database.dart`, `test_dir: test/drift/`, `schema_dir: drift_schemas/`.

6. ARTIFACTS + WORKFLOW — confirmed: exports named `drift_schema_vX.json` where X is the schema version; migration tests under test/drift/; workflow = run once for baseline, change schema, MANUALLY bump `schemaVersion`, run again, implement generated stepByStep callbacks, run generated tests. Docs confirm schemaVersion is bumped by the developer, matching the claim.

7. --no-test — the one live refutation lead, since this flag is NOT listed on the migrations narrative page. Settled by the drift_dev changelog: version 2.29.0 — "Make-migrations: Add `--no-test` option to disable generating tests." Real flag, merely under-documented on the prose page. Claim accurate.

NUANCE (does not reduce the verdict): "supersedes" holds as a RECOMMENDATION, not a deprecation. `dart run drift_dev schema dump` and `dart run drift_dev schema steps [input_folder] [output_file]` still exist and function; step_by_step notes "This is part of the make-migrations command, but this step can also be invoked manually." make-migrations combines the older schema commands rather than removing them, so an existing manual pipeline is not force-broken — adopting it is a recommendation to follow, not a required migration. The claim's confidence level (high) is warranted.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "drift-testing" made this claim, and a project decision depends on it.

CLAIM: `make-migrations` is the current recommended workflow and supersedes manually running schema dump/steps/generate
DETAIL: Requires build.yaml: `targets: $default: builders: drift_dev: options: databases: {my_database: lib/database.dart}, test_dir: test/drift/, schema_dir: drift_schemas/`. Then `dart run drift_dev make-migrations` generates drift_schemas/drift_schema_vX.json, test/drift/ migration tests, and database.steps.dart next to the database class. Docs state plainly: 'Writing migrations manually is error-prone and can lead to data loss.' Workflow: run once for baseline, change schema, bump schemaVersion, run again, implement the generated stepByStep callbacks, run generated tests. `--no-test` disables test generation (do not use it here).
CLAIMED SOURCES: https://drift.simonbinder.eu/migrations/, https://drift.simonbinder.eu/migrations/exports/
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
