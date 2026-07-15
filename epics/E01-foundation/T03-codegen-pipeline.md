# E01-T03 — Codegen pipeline

| | |
|---|---|
| **Epic** | E01 — Foundation |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E01-T01 |
| **Blocks** | E03-T01 |

**Skills:** `reed-codegen-workflow` · `reed-drift-schema`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

drift's generated code *is* the schema, and `drift_schemas/` is the only record of what the schema looked like at a version that has already shipped to someone's phone. Without the `databases:` block in `build.yaml`, `dart run drift_dev make-migrations` hard-errors with **"No databases found in the build.yaml file"** and the entire schema tooling chain — dumps, `stepByStep`, migration tests — is unreachable. Retro-fitting this after v1 ships means reconstructing the v1 snapshot from git archaeology, if it can be reconstructed at all. This task lands the pipeline before there is any user data to lose.

## Scope

**1. `build.yaml` at the repo root.** Exactly this block:

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/data/database/app_database.dart
          test_dir: test/drift/          # default
          schema_dir: drift_schemas/     # default
```

`test_dir` and `schema_dir` are already drift's defaults; they are written out only so a stranger reading the file knows where things land. Do not rename them. `databases:` is not a preference — nothing in the schema chain runs without it.

**2. Commit generated files.** `*.g.dart` and `*.drift.dart` go into git, alongside `drift_schemas/`. Settled; do not relitigate. A stranger's `git clone && flutter run` must work with no `build_runner` round-trip, migration commits must show the schema delta as a reviewable diff, and the committed output must still compile against a future `drift_dev` that generates different code or refuses to resolve at all.

Add `.gitattributes` at the repo root so GitHub collapses them:

```
*.g.dart      linguist-generated=true
*.drift.dart  linguist-generated=true
```

**3. Exclusions — the consequence of committing codegen.** Generated code is now in scope for every tool that walks the tree.

- `analysis_options.yaml` excludes `**/*.g.dart`, `**/*.drift.dart`, `**/generated_plugin_registrant.dart`, and `test/drift/generated/**`. The last one matters most: a lint autofix inside the exported schema snapshots would corrupt the migration-test baseline. It is safe to exclude *because* migration correctness is enforced by drift's schema tests, not by lints.
- Coverage strips generated files before any number is read:

```sh
lcov --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.drift.dart' \
  -o coverage/lcov.info \
  --ignore-errors unused   # lcov 2.x errors on patterns that match nothing
```

**Check which suffix this drift config actually emits before writing either pattern.** Modern drift emits `.drift.dart`; legacy part-file setups emit `.g.dart`. Do not guess — an exclude pattern that matches nothing fails silently in the analyzer and loudly in lcov 2.x.

**4. The commands, in the README.** A short "Codegen" section carrying these verbatim:

```sh
# After changing lib/data/database/tables.dart (or app_database.dart)
dart run build_runner build --delete-conflicting-outputs

# While actively editing tables — for a session, not as a habit
dart run build_runner watch --delete-conflicting-outputs

# Schema snapshot — every schemaVersion bump, no exceptions
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/

# Supersedes hand-running schema dump + steps + generate
dart run drift_dev make-migrations
```

`--delete-conflicting-outputs` is always passed. Without it build_runner refuses to overwrite an output it did not write in this run — which is *every* output, because they are all committed. The failure is a wall of "conflicting outputs" text, not a bug. Neither build command belongs in a pre-commit hook or a run script; codegen runs when the schema changes, and the schema changes rarely.

**5. The ordering rule, written down in the README next to the commands.** `schema dump` writes a JSON snapshot for **whatever `schemaVersion` currently says**. So:

1. **Before touching `tables.dart`**, confirm `drift_schemas/` already holds a snapshot for the current `schemaVersion`. If it does not, dump it *now*, on the unmodified source, and commit that alone.
2. Then edit the tables **and** bump `schemaVersion` — in the same commit. Never one without the other.
3. Then dump again, producing the snapshot for the new version.

Add the stop rule too: **if a dump ever produces a diff on a snapshot for a version that already shipped, stop.** That is not a stale file to commit — it is proof that either `schemaVersion` was not bumped or the historical snapshot is already wrong. Reconcile the shape before writing anything.

**6. Dump v1 now.** Run the dump against `lib/data/database/app_database.dart` at `schemaVersion = 1` and commit `drift_schemas/`. Migration *tests* are a v2 problem — at `schemaVersion = 1` there are no migrations to test. The dump is not a v2 problem; it is due on day one.

**Out of scope:** the CI freshness gates (build-and-`git diff --exit-code`, dump-and-diff) — those land with the CI workflow task, but note here that they are the whole mitigation for committing generated code; if either is removed, committing codegen stops being safe. Also out of scope: schema design (E01-T01 owns `tables.dart`), migration test content, and anything touching `backup.dart`.

## Acceptance criteria

- [ ] `build.yaml` exists at the repo root with the `databases:` block naming `app_database: lib/data/database/app_database.dart`.
- [ ] `dart run drift_dev make-migrations` runs without emitting **"No databases found in the build.yaml file"**.
- [ ] `dart run build_runner build --delete-conflicting-outputs` exits 0 on a clean tree.
- [ ] Running that build twice in a row leaves `git diff --exit-code -- '*.g.dart' '*.drift.dart'` green — the committed output is exactly what the checked-in source generates.
- [ ] `drift_schemas/` contains a snapshot for `schemaVersion = 1` and it is committed.
- [ ] Re-running `dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/` produces no diff.
- [ ] `.gitattributes` marks `*.g.dart` and `*.drift.dart` as `linguist-generated=true`.
- [ ] `analysis_options.yaml` excludes `**/*.g.dart`, `**/*.drift.dart`, `**/generated_plugin_registrant.dart`, `test/drift/generated/**`; `flutter analyze --fatal-infos` is green and reports nothing inside a generated file.
- [ ] The lcov `--remove` invocation runs with `--ignore-errors unused` and the patterns match the suffix drift actually emits here (verify by listing the generated files, not by assumption).
- [ ] The README's Codegen section contains the four commands verbatim and the three-step dump-before-bump ordering rule.

## Traps

- **Dump after bump.** Edit `tables.dart`, forget the `schemaVersion` bump, run `schema dump`: it overwrites **v1's snapshot with v2's shape**. Nothing errors. `drift_schemas/` now contains a fiction — a file claiming v1 had columns v1 never had — and every migration test from then on validates against that fiction. Worse, on the user's device no migration runs at all, because `schemaVersion` never moved: `onUpgrade` is not called, the old database is opened against new query code, and every board silently fails to load. Highest-cost bug in the codebase, caused by two shell commands in the wrong order.
- **Believing the snapshot is reconstructable.** Nominally it is — `schema dump` reads Dart source, so check out an old tag and re-run. In practice that recovery needs *all* of: a tag existing at exactly that shape, that tag's `pubspec.lock` still resolving years later, and that era's `drift_dev` still running on the current SDK. Once `schemaVersion` has moved on, no command recovers the previous shape from the working tree. Commit the snapshot in the same commit as the bump, always.
- **Guessing the emitted suffix.** `.drift.dart` (modern) vs `.g.dart` (legacy part files). A wrong exclude pattern is silent in the analyzer — you get lint errors reported inside generated code and start hand-editing output — and loud in lcov 2.x, which errors on patterns matching nothing.
- **Hand-editing generated output.** The next build silently reverts it and takes the fix with it. If the analyzer flags an undefined class or getter that codegen should have produced, the disk is behind: run the build, restart the analysis server, do not "fix" the call site.
- **Adding build_runner to a hook or run script.** It is not a daily command. A pre-commit codegen step turns every commit into a slow lottery and makes it easy to commit output whose source you did not intend to regenerate against.
- **Dropping `--delete-conflicting-outputs`.** Because everything is committed, *every* output conflicts on a fresh checkout. The wall of text is expected behaviour, not a bug to investigate.
- **build_runner errors while `flutter analyze --fatal-infos` is green.** Trust build_runner. Its input is the same AST plus drift's own semantic checks (column types, FK targets, `@DriftDatabase` wiring) that the analyzer knows nothing about. Conversely, an analyzer error anywhere in hand-written `lib/` can block generation of a completely unrelated table — drift's builder needs a resolved AST.
- **Both tools green, app misreads the DB at runtime.** The schema moved without a `schemaVersion` bump. Check that first, before anything else.
- **Shipping `make-migrations` output unread (relevant the moment E03 lands, note it now).** The generated data-integrity test leaves `final oldButtonsData = <v1.Button>[];` / `final expectedNewButtonsData = <v2.Button>[];` with a `// TODO: Fill these lists`. Both empty, the test **passes vacuously** — it inserts nothing and asserts `[] == []`, under a name like *"migration from v1 to v2 does not corrupt data"*. Fill them in the same commit that generates the test, or delete the test. A test that lies is worse than an absent one.

## Files

- `build.yaml` — created (repo root)
- `.gitattributes` — created (repo root)
- `analysis_options.yaml` — changed (exclude list)
- `README.md` — changed (Codegen section: commands + dump-before-bump ordering rule)
- `drift_schemas/` — created, v1 snapshot committed
- `lib/data/database/*.g.dart` / `*.drift.dart` — generated and committed
- `lib/data/database/schema_versions.dart` — generated when `make-migrations` first runs

## Done when

`dart run drift_dev make-migrations` runs without the "No databases found" error, a v1 snapshot sits committed in `drift_schemas/`, a repeat build and a repeat dump both produce zero diff, and the README carries the four commands plus the dump-before-bump rule.


---

## What actually happened

Three things in this task's own instructions had rotted.

**`--delete-conflicting-outputs` no longer exists.** build_runner now reports
`These options have been removed and were ignored`. The correct command is just
`dart run build_runner build`.

**`tools:` is not a valid `build.yaml` key.** build.yaml accepts only `builders`,
`post_process_builders`, `targets`, `global_options`, `additional_public_assets`,
`triggers`. `databases` is a drift_dev **builder option** and belongs under
`targets: $default: builders: drift_dev: options:`.

**drift_dev 2.34.0 cannot run `make-migrations` against drift 2.34.2.** It calls
`reference.allSchemaEntities`, which does not exist on the `GeneratedDatabase`
that drift 2.34.2 exports (it now comes from a `drift3_preview` path). Fixed in
**drift_dev 2.34.4** — pinned there. Note `flutter pub upgrade drift_dev` would
NOT move it off 2.34.0; the version had to be requested explicitly.

**Verified:** codegen exits 0; running it twice leaves `git diff --exit-code`
green; `make-migrations` emits `drift_schema_v1.json`; re-dumping produces no
diff; `flutter analyze --fatal-infos` is clean and reports nothing from a
generated file.
