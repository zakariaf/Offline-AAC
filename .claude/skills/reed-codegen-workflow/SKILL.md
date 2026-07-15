---
name: reed-codegen-workflow
description: 'Runs the build_runner and drift_dev codegen loop — build/watch commands and the build.yaml `databases:` block. Use when running `dart run build_runner build` or `watch`, invoking `drift_dev make-migrations` or `schema dump`, regenerating after editing tables.dart, excluding `*.g.dart`/`*.drift.dart` from the analyzer or lcov, or hitting "No databases found in the build.yaml file". Not for schema design or migration test content — this is the generation loop and its committed output.'
---

# Reed codegen: build_runner + drift

Codegen here is not a build detail. drift's generated code *is* the schema, and the schema snapshots in `drift_schemas/` are what stand between a migration bug and the permanent loss of a hand-curated board — months of someone's phrases, unmergeable and irreplaceable. There is no telemetry: if a migration eats a board in the field, nobody will ever tell us. Treat every rule below as data-loss prevention, not tidiness.

## The two commands

```sh
# After changing lib/data/database/tables.dart (or app_database.dart)
dart run build_runner build --delete-conflicting-outputs

# While actively editing tables — for a session, not as a habit
dart run build_runner watch --delete-conflicting-outputs
```

Always pass `--delete-conflicting-outputs`. Without it, build_runner refuses to overwrite an output it did not write in this run — which is *every* output, because they are all committed to git. The failure is a wall of "conflicting outputs" text, not a bug; do not go looking for one.

Neither command is a daily thing. Codegen runs when the schema changes, and the schema changes rarely. Do not add either to a pre-commit hook or a run script.

## build.yaml — required, at the repo root, from commit #1

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

The `databases:` block is not optional and not a preference. Without it `dart run drift_dev make-migrations` hard-errors with **"No databases found in the build.yaml file"** — the whole schema tooling chain (dumps, step helpers, migration tests) is unreachable until it exists. `test_dir` and `schema_dir` are already drift's defaults; they are written out only so a stranger reading the file knows where things land. Do not rename them.

This file must exist before there is any user data to lose. Retro-fitting it after v1 ships means the v1 snapshot has to be reconstructed from git archaeology, if it can be reconstructed at all.

## make-migrations supersedes the three hand commands

```sh
dart run drift_dev make-migrations
```

Driven by the `build.yaml` above, this emits the schema JSONs, the `stepByStep` helper (`lib/data/database/schema_versions.dart`), the era-correct data classes under `test/drift/generated/`, and a migration test — in one command. It internally invokes the `schema generate --data-classes --companions` path. Prefer it over hand-running `schema dump` + `schema steps` + `schema generate` in sequence.

**But read what it writes.** The generated data-integrity test uses `SchemaVerifier.testWithDataIntegrity` and leaves this:

```dart
final oldButtonsData = <v1.Button>[];
final expectedNewButtonsData = <v2.Button>[];
// TODO: Fill these lists
```

With both lists empty the test **passes vacuously** — it inserts nothing and asserts `[] == []`. The result is a green test named *"migration from v1 to v2 does not corrupt data"* that verified precisely nothing, and that green tick is the only thing standing between a user and a permanently empty board. Fill the lists in the same commit that generates the test, with hostile realistic rows (apostrophes, non-ASCII, em dashes, emoji labels, embedded quotes and backslashes, whitespace-only vocalizations) — never `test1`/`test2`, which survive every bug. If the lists cannot be filled now, delete the test. A test that lies is worse than an absent one.

Related and worth knowing while you are here: `migrateAndValidate` is blind to rows. It diffs `CREATE` statements out of `sqlite_schema` and compares shapes. A migration that rebuilds a table perfectly and copies **zero rows** passes it green. Row survival is only provable via `verifier.schemaAt(n)` plus the `--data-classes --companions` output.

## The schema dump: every schemaVersion bump, no exceptions

```sh
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
```

`schema dump` reads the Dart source and writes a JSON snapshot for **whatever `schemaVersion` currently says**. That single fact generates both the obligation and the trap.

### Ordering: dump before bump

The snapshot for version N must be written while the source still describes version N. So:

1. **Before touching `tables.dart`**, confirm `drift_schemas/` already holds a snapshot for the current `schemaVersion`. If it does not, dump it *now*, on the unmodified source, and commit that alone.
2. Then edit the tables **and** bump `schemaVersion` — in the same commit. Never one without the other.
3. Then dump again, producing the snapshot for the new version.

The trap is step 2 done halfway. Edit `tables.dart`, forget the bump, run `schema dump`: it overwrites **v1's snapshot with v2's shape**. Nothing errors. `drift_schemas/` now contains a fiction — a file claiming v1 had columns v1 never had — and every migration test from then on validates against that fiction. Worse, on the user's device no migration runs at all, because `schemaVersion` never moved: `onUpgrade` is not called, the old database is opened against new query code, and every board silently fails to load. That is the single highest-cost bug in this codebase, and it is caused by two shell commands in the wrong order.

If a dump ever produces a diff on a snapshot for a version that already shipped, stop. That is not a stale file to commit — it is proof that either `schemaVersion` was not bumped, or the historical snapshot is already wrong. Reconcile the shape before writing anything.

### Why the snapshot cannot be reconstructed

Nominally it can: `schema dump` reads Dart source, so checking out an old tag and re-running it regenerates the file. In practice, treat the snapshot as unreconstructable, because that recovery needs *all* of — a tag existing at exactly that shape, that tag's `pubspec.lock` still resolving years later, and that era's `drift_dev` still running on the current SDK. Once `schemaVersion` has been bumped and the source has moved on, there is no command that recovers the previous shape from the working tree. Everything else in the generated set can be rebuilt from source at any time; the historical snapshot is the one artifact whose input no longer exists. Commit it in the same commit as the bump, always.

Migration *tests* are a v2 problem — at `schemaVersion = 1` there are no migrations to test, and a v1→v2 test cannot be written until v2 exists. The dump is not a v2 problem. It is due on day one.

## Commit the generated code — settled, do not relitigate

`*.g.dart` and `*.drift.dart` go **into git**, alongside `drift_schemas/`. This is against Dart convention and it is correct here:

1. A stranger's `git clone && flutter run` works with no `build_runner` round-trip. That is the minimum bar for this app outliving its author.
2. **drift's generated code is the schema.** A migration commit then shows the real schema delta as a reviewable diff — migration review becomes a safety gate instead of a leap of faith.
3. It pins the output against a future `drift_dev` that generates different code, or, in 2029, refuses to resolve at all. The committed output still compiles.

The merge-conflict objection is void for a solo dev. The diff-noise objection is handled by `.gitattributes`, so GitHub collapses these files in diffs:

```
*.g.dart      linguist-generated=true
*.drift.dart  linguist-generated=true
```

The staleness risk is real and is handled entirely by CI: `dart run build_runner build --delete-conflicting-outputs` followed by `git diff --exit-code -- '*.g.dart' '*.drift.dart'`, plus the same dump-and-diff on `drift_schemas/`. Those two freshness gates are the whole mitigation for committing codegen — if either is removed, committing generated code stops being safe. The dump gate in particular catches *changed the schema, forgot to bump `schemaVersion`* without anyone writing a line of migration code.

### The exclusion consequences

Committing generated code means it is now in scope for every tool that walks the tree, so it must be excluded from two of them:

- **Analyzer** — `analysis_options.yaml` excludes `**/*.g.dart`, `**/*.drift.dart`, `**/generated_plugin_registrant.dart`, and `test/drift/generated/**`. The last one matters most: a lint autofix inside the exported schema snapshots would corrupt the migration-test baseline. It is safe to exclude *because* migration correctness is enforced by drift's schema tests, not by lints.
- **Coverage** — strip generated files before reading any number:

```sh
lcov --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.drift.dart' \
  -o coverage/lcov.info \
  --ignore-errors unused   # lcov 2.x errors on patterns that match nothing
```

**Check which suffix the drift config actually emits before writing either pattern** — modern drift emits `.drift.dart`, legacy part-file setups emit `.g.dart`. Do not guess; an exclude pattern that matches nothing fails silently in the analyzer and loudly in lcov 2.x.

## When codegen and the analyzer disagree

The analyzer reads files on disk; build_runner writes them. A disagreement almost always means the disk is behind, not that the code is wrong.

| Symptom | Do this |
|---|---|
| Analyzer flags an undefined class/getter that codegen should have produced | Run `build_runner build --delete-conflicting-outputs`, then restart the analysis server. Do not "fix" the call site. |
| Errors reported *inside* `.g.dart` / `.drift.dart` | The exclude pattern is wrong or the file is stale. Regenerate first; if errors persist, the excludes do not match the emitted suffix. Never hand-edit generated output — the next build silently reverts it and takes the fix with it. |
| build_runner fails with analyzer errors in hand-written source | Fix the hand-written source. drift's builder reads a resolved AST; it cannot generate from source that does not analyze. Errors elsewhere in `lib/` can block generation of an unrelated table. |
| `flutter analyze --fatal-infos` green but build_runner errors | Trust build_runner. Its input is the same AST plus drift's own semantic checks (column types, FK targets, `@DriftDatabase` wiring) that the analyzer knows nothing about. |
| Both green, but the app misreads the DB at runtime | The schema moved without a `schemaVersion` bump. Check that first, before anything else. |

Never hand-edit generated output, and never commit a `.g.dart` / `.drift.dart` that the current source would not reproduce. The whole value of committing them rests on them being exactly what the checked-in source generates.
