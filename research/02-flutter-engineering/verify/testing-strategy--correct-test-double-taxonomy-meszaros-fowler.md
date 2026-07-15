# testing-strategy--correct-test-double-taxonomy-meszaros-fowler

> Phase: **verify** · Agent `a036d660913a34978` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Verdict is CONFIRMED; the following are refinements, not refutations, and neither changes the project decision.

1. "drift's NativeDatabase.memory() = arguably not even a fake" runs against Fowler's LITERAL text. Fowler names "an in memory database" as THE canonical example of a Fake ("take some shortcut which makes them not suitable for production (an in memory database is a good example)"). By Fowler's letter, non-persistence IS exactly such a shortcut, so NativeDatabase.memory() IS a fake. The claim's contrarian reading is still defensible — Fowler's 2007-era example means an in-memory SUBSTITUTE implementation, whereas NativeDatabase.memory() is the identical sqlite3 engine differing only in storage medium (same SQL dialect, same schema, same migration path). The claim hedges with "arguably," which keeps this a nuance rather than an error. One genuine asterisk on the "it is the real dependency" framing: tests run against the HOST machine's sqlite3, which can be a different sqlite3 version than the device-bundled library (sqlite3_flutter_libs), so it is not bit-identical to production.

2. "100% of the DB risk lives in SQL/schema/migrations" is rhetorical overstatement. DB risk also includes transaction/concurrency handling, drift's stream reactivity/invalidation, and error handling. However this does not rescue mocking: a mocked DB tests none of THOSE either, so the claim's operative conclusion — never mock the DB, use NativeDatabase.memory() plus SchemaVerifier for migrations — survives fully intact.

**Evidence:** Attempted refutation on all five hazard axes; the claim survives.

TAXONOMY — matches Fowler verbatim, not paraphrase-drift. Dummy: "objects are passed around but never actually used. Usually they are just used to fill parameter lists." Stub: "provide canned answers to calls made during the test, usually not responding at all to anything outside what's programmed in for the test." Spy: "are stubs that also record some information based on how they were called" — confirms the claim's "a stub that records calls," including the stub-subtype relationship. Mock: "objects pre-programmed with expectations which form a specification of the calls they are expected to receive," which self-verify and fail the test. Fake: "actually have working implementations, but usually take some shortcut which makes them not suitable for production (an in memory database is a good example)." All five map exactly to the claim's DETAIL.

API VERIFICATION (hazard #3, invented/misremembered signatures) — NativeDatabase.memory() is REAL and CURRENT, not an LLM-plausible name. Exact signature from pub.dev generated docs, package:drift/native.dart:
  factory NativeDatabase.memory({bool logStatements = false, SqliteResolver sqlite3 = _NativeDelegate._defaultResolver, DatabaseSetup? setup, bool cachePreparedStatements = _cacheStatementsByDefault})
Documented as "creates an in-memory database won't persist its changes on disk."

PACKAGE HEALTH (hazard #2, dead packages) — drift is emphatically alive. Latest version 2.34.2, published ~25 hours before 2026-07-15. Verified publisher simonbinder.eu. Flutter Favorite. 2.4k likes, ~973k weekly downloads, 160 pub points. No discontinued or unmaintained marker.

VERSION ROT (hazard #1) — none found. The API name and the docs URL both resolve current.

CARGO CULT (hazard #4) — the do-not-mock-the-DB position is the vendor's OWN documented guidance, not a blog post. drift testing docs: "We can create an in-memory version of the database by using a NativeDatabase.memory() instead of a FlutterQueryExecutor or other implementations," with example passing closeStreamsSynchronously: true to DatabaseConnection for widget tests. The migration-risk argument is backed by real first-party tooling verified on the migrations/tests page: SchemaVerifier, migrateAndValidate(db, version), startAt(version), schemaAt(version) (returns "a raw Database from the sqlite3 package"), validateDatabaseSchema() (native + web since drift 2.22), generated via `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`. The verifier "will extract all CREATE statement from the sqlite_schema table and semantically compare them" — real SQLite throughout.

OVERSTATED CONSENSUS (hazard #5) — the taxonomy is Meszaros/xUnit Test Patterns popularised by Fowler, i.e. the actual canonical source, correctly attributed.

The project-specific mappings (FakeSpeechService = fake + spy) are internal design judgments, not externally checkable facts, but they apply the verified taxonomy correctly: a working in-memory implementation that additionally records `spoken` for later assertion is precisely fake + spy under Fowler's definitions.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "testing-strategy" made this claim, and a project decision depends on it.

CLAIM: Correct test-double taxonomy (Meszaros/Fowler) — this project needs FAKES and SPIES, and essentially zero true mocks
DETAIL: Dummy: passed to satisfy a signature, never used. Stub: returns canned answers, makes no assertions. Spy: a stub that records calls for the test to assert on afterwards. Mock: pre-programmed with expectations that verify themselves and fail the test. Fake: a real working implementation with a shortcut unsuitable for production (in-memory DB). Mapping: FakeSpeechService = fake (+ spy, once it records `spoken`). drift's NativeDatabase.memory() = arguably not even a fake — it is real sqlite3 with in-memory storage, i.e. the real dependency. The DB should NEVER be mocked: 100% of the DB risk lives in SQL/schema/migrations, and a mocked DB tests literally none of it.
CLAIMED SOURCES: https://martinfowler.com/articles/mocksArentStubs.html, https://drift.simonbinder.eu/testing/
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
