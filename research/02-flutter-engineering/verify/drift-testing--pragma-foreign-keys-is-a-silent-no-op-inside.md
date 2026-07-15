# drift-testing--pragma-foreign-keys-is-a-silent-no-op-inside

> Phase: **verify** · Agent `ac16d50fcd3499241` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The core claim is correct and the project decision that depends on it (disable FKs outside the transaction) is safe. Two corrections. (1) Replace the second source: the cited SQLite forum post is about connection-level FK enforcement and `.dump` output, not transactions — it does not substantiate the claim. Cite https://sqlite.org/pragma.html#pragma_foreign_keys, which contains the quoted sentence verbatim. (2) The code pattern is wrong as written. Drift's documented pattern is: `PRAGMA foreign_keys = OFF` in `onUpgrade` before the transaction, migration logic inside `transaction(() async {...})`, `PRAGMA foreign_key_check` via `customSelect` in debug mode, and then `PRAGMA foreign_keys = ON` in the `beforeOpen` callback of `MigrationStrategy` — NOT inline after the transaction. `beforeOpen` runs on every open whether or not a migration ran, so it is what actually guarantees enforcement is restored for normal sessions; the inline version only fires on the migration path. Also, drift does not wrap migrations in a transaction automatically — the docs present the `transaction` wrapper as the developer's choice. Verified against drift 2.34.2 (current, actively maintained, verified publisher simonbinder.eu, not discontinued).

**Evidence:** CORE CLAIM CONFIRMED. sqlite.org/pragma.html#pragma_foreign_keys states verbatim: "This pragma is a no-op within a transaction; foreign key constraint enforcement may only be enabled or disabled when there is no pending BEGIN or SAVEPOINT." The "silent no-op, does not error" characterization is exactly correct. The operative engineering conclusion — FK-disabling must happen outside the transaction — holds.

SUPPORTING SPECIFICS CONFIRMED. drift's migrator API docs (drift.simonbinder.eu/migrations/api/) confirm: (a) `m.alterTable(TableMigration(schema.todos, columnTransformer: {...}))` exists with that exact signature; (b) it is documented as implementing SQLite's 12-step ALTER TABLE procedure, i.e. create-copy-drop-rename, which FK enforcement would reject mid-flight; (c) `PRAGMA foreign_key_check` IS recommended post-migration (shown as `final wrongForeignKeys = await customSelect('PRAGMA foreign_key_check').get();`, in debug mode); (d) the docs explicitly say "some pragmas (including `foreign_keys`) can't be changed inside transactions."

PACKAGE LIVENESS CONFIRMED (not version rot / not a dead package). drift is v2.34.2, last published ~25 hours before check, publisher simonbinder.eu (verified publisher), NOT discontinued. No API in the claim is invented or deprecated.

FAILURE 1 — BAD CITATION. The second claimed source (sqlite.org/forum/info/fd0b2d53...abe18) does NOT support the claim. That post is about foreign key enforcement being a connection-level property and why `.dump` emits `PRAGMA foreign_keys=OFF`; David Raymond answers: "Foreign key enforcement is only at the connection level. It's not a property of the database itself." It never addresses transaction behavior. The correct primary citation is https://sqlite.org/pragma.html#pragma_foreign_keys.

FAILURE 2 — CODE PATTERN WRONG IN A LOAD-BEARING WAY. The claim's snippet re-enables FKs inline after the transaction. Drift's actually-documented pattern re-enables in the `beforeOpen` callback of `MigrationStrategy`, not inline after `onUpgrade`. This is not stylistic: `beforeOpen` runs on every database open regardless of whether a migration ran, guaranteeing enforcement is on for normal sessions; the inline form only re-enables on the migration code path.

FAILURE 3 — MINOR. The claim implies drift wraps migrations in a transaction for you. The docs frame `transaction(() async {...})` as an optional wrapper the developer chooses ("you can wrap it in a `transaction` block"), not automatic behavior.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "drift-testing" made this claim, and a project decision depends on it.

CLAIM: `PRAGMA foreign_keys` is a silent no-op inside a transaction, so FK-disabling during migration must happen outside it
DETAIL: SQLite: 'foreign key constraint enforcement may only be enabled or disabled when there is no pending BEGIN or SAVEPOINT.' It does not error — it does nothing. Drift docs' pattern: `await customStatement('PRAGMA foreign_keys = OFF'); await transaction(() async { /* migration */ }); await customStatement('PRAGMA foreign_keys = ON');`. This matters because `alterTable`/TableMigration works by create-copy-drop-rename, which FK enforcement would reject mid-flight. Docs recommend `PRAGMA foreign_key_check` after the migration to assert nothing was corrupted while enforcement was off.
CLAIMED SOURCES: https://drift.simonbinder.eu/migrations/api/, https://sqlite.org/forum/info/fd0b2d53bafc73f888069b3a0a3b15f35982c7e3fa910983b47db3e39ccabe18
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
