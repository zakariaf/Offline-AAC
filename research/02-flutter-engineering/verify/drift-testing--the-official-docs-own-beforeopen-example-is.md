# drift-testing--the-official-docs-own-beforeopen-example-is

> Phase: **verify** · Agent `a93792918246bbe1e` · Run `wf_12b14467-451`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** The docs do NOT show the pragma inside the wasCreated guard — they show it OUTSIDE/after the guard (overview page) or with no guard at all (migrator API page), i.e. unconditional per-connection, which is the correct behavior. The migrator API page additionally states outright: "always re-enable foreign keys before using the database, by enabling them in beforeOpen." The claim's prescription (unconditional pragma; seeding inside the wasCreated guard) is correct engineering advice, but it is already the official documented pattern rather than a correction to it. Copying the official example verbatim produces correctly-enforced FKs on every launch, not FKs enforced only on first launch. No project decision should rest on the premise that the drift docs contain this trap.

**Evidence:** The claim's central factual assertion — that the official drift migrations overview page renders the FK pragma INSIDE an `if (details.wasCreated)` guard — is false on all three cited/related pages.

1. https://drift.simonbinder.eu/docs/migrations/ renders:
   beforeOpen: (details) async {
     if (details.wasCreated) {
       // ...
     }
     await customStatement('PRAGMA foreign_keys = ON');
   }
   The pragma is AFTER and OUTSIDE the wasCreated block — unconditional, runs on every open.

2. https://drift.simonbinder.eu/migrations/api/ (the second claimed source) shows the pragma unconditionally as the first statement, with no guard at all:
   beforeOpen: (details) async {
     await customStatement('PRAGMA foreign_keys = ON');
     // ....
   },
   and explicitly instructs: "always re-enable foreign keys before using the database, by enabling them in beforeOpen."

3. https://drift.simonbinder.eu/docs/advanced-features/migrations/ (legacy path) shows the identical unconditional structure.

API-surface check (not a failure mode here): `MigrationStrategy.beforeOpen`, `OpeningDetails`, `details.wasCreated`, and `customStatement` are all real, correctly named drift APIs. The defect is not an invented signature — it is an invented characterization of the source document.

The claim's underlying engineering advice ("pragma unconditional in beforeOpen; seeding inside the wasCreated guard") is technically CORRECT, but it is non-novel: it is exactly the pattern the official docs already demonstrate. The claim inverts authorship, manufacturing a documentation defect to justify advice the documentation itself is the source of. There is no "trap" and no copied-verbatim hazard — copying the docs verbatim yields the correct behavior.

This is not version rot: the unconditional-pragma pattern is what the docs show as of 2026-07-15, and no evidence was found that a guarded version was ever rendered on these pages.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "drift-testing" made this claim, and a project decision depends on it.

CLAIM: The official docs' own beforeOpen example is a trap: it shows the FK pragma inside an `if (details.wasCreated)` guard
DETAIL: The migrations overview page renders `beforeOpen: (details) async { if (details.wasCreated) { await customStatement('PRAGMA foreign_keys = ON'); } }`. The `wasCreated` guard is correct for SEEDING data but wrong for a per-connection pragma — copied verbatim, FKs would be enforced only on the very first app launch and off forever after. Put the pragma unconditionally in beforeOpen; put seeding inside the wasCreated guard.
CLAIMED SOURCES: https://drift.simonbinder.eu/docs/migrations/, https://drift.simonbinder.eu/migrations/api/
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
