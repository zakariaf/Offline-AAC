# drift-testing--sqlite-foreign-keys-are-off-by-default-and-d

> Phase: **verify** · Agent `aadcd89d5d21a1a28` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Verdict stands as CONFIRMED; the following are refinements, not defects in the claim.

(a) Citation quality — the claim's own sources are the weakest part of it. Source 3 (nicolaiarocci.com) is a personal blog and should be replaced by the actual primary source, https://sqlite.org/foreignkeys.html, which states the OFF-by-default + per-connection rule verbatim. Source 2 (drift issue #163) is genuinely titled "Foreign Keys not working as it should" and is FK-related, so it is not fabricated — but it is a 2020 user support thread about a leftOuterJoin returning null with customConstraint, closed with no visible authoritative resolution. It does not establish "drift does not enable FKs" and should not be cited as if it does. The correct primary citation for the drift half is https://drift.simonbinder.eu/dart_api/tables/. Right conclusion, under-powered sourcing.

(b) "beforeOpen is THE sanctioned place" is slightly too exclusive. It is the sanctioned place for the migration-strategy path and is correct here. But NativeDatabase also exposes a `setup:` callback (documented on drift.simonbinder.eu/platforms/vm/, e.g. `setup: (database) { database.execute('pragma journal_mode = WAL;'); }`) which runs per underlying connection and is the appropriate hook when using `NativeDatabase.createInBackground` / multi-isolate setups. Since the pragma is per-connection, teams using background isolates should confirm the pragma lands on every physical connection, not assume beforeOpen alone covers it. Use beforeOpen; know setup exists.

(c) Minor imprecision in the stated consequence. With FKs off and a dangling button_id, a LEFT JOIN yields a null-hydrated row (tile renders blank — correct as claimed). "Or throws on join" only happens if generated mapping code hits a non-nullable expectation; an INNER JOIN would instead silently drop the slot row entirely. The blank-tile outcome is the well-founded one; "throws" is situational.

**Evidence:** I tried to refute this on all five failure modes and could not. The claim survives.

1. SQLite half — CONFIRMED verbatim by the primary source. sqlite.org/foreignkeys.html states: "Foreign key constraints are disabled by default (for backwards compatibility), so must be enabled separately for each database connection." That single sentence establishes both halves of the claim's first assertion: OFF by default AND per-connection. Not version-rotted — this is a permanent backwards-compatibility decision in SQLite, not an API that drifts.

2. Drift half — CONFIRMED by drift's OWN docs, not a blog. drift.simonbinder.eu/dart_api/tables/ says: "in sqlite3, foreign key references aren't enabled by default. They need to be enabled with `PRAGMA foreign_keys = ON`. A suitable place to issue that pragma with drift is in a post-migration callback." This is drift's first-party admission that it does not turn them on for you. drift.simonbinder.eu/migrations/api/ confirms the sanctioned location: "always re-enable foreign keys before using the database, by enabling them in beforeOpen", with the exact code `beforeOpen: (details) async { await customStatement('PRAGMA foreign_keys = ON'); }`.

3. Dead-package check — NEGATIVE (package is alive). pub.dev/packages/drift: latest 2.34.2, published ~25 hours before checking, verified publisher simonbinder.eu, 2.43k likes, ~998k weekly downloads, NOT discontinued/unmaintained. No version rot: the beforeOpen guidance is in the current live docs, not an archived 2023 page.

4. Invented-API check — NEGATIVE (the API is real). This was my best shot at a refutation, since `KeyAction.setNull` is exactly the kind of LLM-plausible name that turns out fake. It is real. pub.dev/documentation/drift/latest/drift/KeyAction.html confirms the enum exists with exactly five values: setNull, setDefault, cascade, restrict, noAction. `setNull` is documented as "Set the column to null when the referenced column changes", used on a `BuildColumn.references()` clause with onUpdate/onDelete. The claim's `onDelete: KeyAction.setNull` is correct drift API as of 2.34.2.

5. Cargo-cult / overstated-consensus check — NEGATIVE. This is not one blog post generalized into a practice. The normative statement comes from the vendor's own documentation and the SQLite project's own documentation. The blog is redundant to, not load-bearing for, the claim.

The underlying mechanism is also right: SQLite silently ignores FK actions when the pragma is off — it does not error. This is corroborated by sqlite.org's related note that attempting to toggle the pragma mid-transaction "does not return an error; it simply has no effect" — silent-failure semantics are the house style here. So the researcher's "silent failure in a no-telemetry app" risk framing is sound, and for a nullable FK whose entire purpose is setNull, FKs-off means the feature silently does nothing.

Bonus find that STRENGTHENS the claim beyond what was argued: drift's migration docs note that foreign_keys cannot be changed inside a transaction, and that migrations run in a transaction — which is precisely WHY beforeOpen (outside the migration transaction) is the sanctioned place rather than an arbitrary stylistic preference. The researcher asserted beforeOpen is sanctioned but did not supply this reason; it is the actual mechanical justification.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "drift-testing" made this claim, and a project decision depends on it.

CLAIM: SQLite foreign keys are OFF by default and drift does not turn them on; the setting is per-connection
DETAIL: `PRAGMA foreign_keys = ON` must be issued on every connection, every open. Drift's `beforeOpen` is the sanctioned place. This is the load-bearing footgun for THIS schema: grid_slots.button_id is a nullable FK whose whole purpose is `onDelete: KeyAction.setNull` (delete a button → its slot blanks, position preserved, no reflow). With FKs off, SQLite silently ignores the action, button_id keeps pointing at a deleted row, and the tile renders blank or throws on join — a silent failure in a no-telemetry app.
CLAIMED SOURCES: https://drift.simonbinder.eu/migrations/api/, https://github.com/simolus3/drift/issues/163, https://nicolaiarocci.com/sqlite-foreign-key-constraints-are-disabled-by-default/
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
