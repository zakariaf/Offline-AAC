# E01 — Foundation

> The scaffold, the analyzer, the codegen loop, the CI workflow, and the source-grep policy tests — the machinery that has to substitute for telemetry, plus the `main()` that boots on top of it.

| | |
|---|---|
| **Status** | Done — all 6 tasks |
| **Tasks** | 6 |
| **Depends on** | E00 (E01-T01 gates on E00-T03). E01-T06 additionally waits on E02-T03 and E04-T03. |

## Why this epic exists

Reed ships with no analytics, no Crashlytics, no Sentry, and no `INTERNET` permission. Nothing will ever report that the app broke on someone's phone, and the users cannot file the report themselves — being unable to speak is the condition the app exists to serve. That leaves exactly three things that can ever notice a defect: the compiler, the analyzer, and the test suite. This epic builds all three into a state where they are worth trusting, before there is any code for them to check.

Getting it wrong is not a slow bleed, it is silent. A `very_good_analysis` include filename that does not exist in the resolved package produces one `include_file_not_found` **warning** and then analyses with zero rules — a green build inspecting nothing. A missing `databases:` block in `build.yaml` makes `drift_dev make-migrations` hard-error, so the schema tooling is unreachable on the day the first migration is due. A `<queries>` element without `android.intent.action.TTS_SERVICE` hides the TTS engine from Android 11+, `flutter_tts` returns an empty voice list with a `Log.d`, and every Android 11+ user gets a board that cannot speak. Each of these is one line, each is invisible in review, and each has no other detector.

## What "done" means

- `flutter analyze --fatal-infos` is clean, and a deliberately introduced violation of a promoted rule (`discarded_futures`, `close_sinks`, `avoid_dynamic_calls`) actually errors — verified by probe, not assumed from a green run.
- `dart run build_runner build --delete-conflicting-outputs && git diff --exit-code -- '*.g.dart' '*.drift.dart'` exits 0.
- `dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/ && git diff --exit-code -- drift_schemas/` exits 0, and `drift_schemas/app_database/` holds a committed snapshot for `schemaVersion = 1`.
- `flutter test test/policy` passes and covers, at minimum: `TTS_SERVICE` inside `<queries>`, `android:allowBackup="false"`, no `android.permission.INTERNET`, no banned import URIs in `lib/`, no `withClampedTextScaling`/`textScaleFactor` in `lib/`, no `pumpAndSettle` in `test/`.
- `.github/workflows/ci.yml` is the only workflow file, and a full run of it is green on `ubuntu-24.04` including `flutter build appbundle --release`.
- `lib/main.dart` is ~40 lines, installs exactly two error handlers, and the app opens straight to a tappable grid — no splash, no onboarding, no dialog.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E01-T01 | Scaffold the project tree | S | E00-T03 |
| E01-T02 | Analyzer and lint configuration | S | E01-T01 |
| E01-T03 | Codegen pipeline | S | E01-T01 |
| E01-T04 | CI workflow | M | E01-T02 |
| E01-T05 | Policy tests | S | E01-T02 |
| E01-T06 | Cold-launch sequence in main() | S | E02-T03, E04-T03 |

**E01-T01 — Scaffold the project tree.** Lays down the directory shape every later task assumes: `lib/data/` by type, `lib/ui/` by surface, `lib/native/` as the MethodChannel quarantine, `lib/model/` for the two types drift cannot generate, `test/` mirroring `lib/` 1:1. Two levels maximum, no barrels, no `lib/src/`, no `lib/utils/`. It also fixes the dependency posture — caret ranges in `pubspec.yaml`, a committed `pubspec.lock`, a JSON `.fvmrc` — and the `.gitattributes` lines that make committed generated code readable. The tree is not decoration: `test/` mirroring `lib/` is what turns *"what has no test?"* into a diff of two `ls` outputs, which matters when nothing else reports a failure.

**E01-T02 — Analyzer and lint configuration.** Turns roughly seventeen diagnostics from squiggles into errors, and every one of them is a bug class that produces silence: dropped Futures, swallowed catches, `use_build_context_synchronously`, `close_sinks`, `avoid_dynamic_calls`, `avoid_print`. It also writes down the two downgrades (`deprecated_member_use` stays a warning; `public_member_api_docs` and `lines_longer_than_80_chars` are off) so the next reader does not "restore" them. It blocks both CI and the policy tests because those two are what enforce everything the analyzer cannot see.

**E01-T03 — Codegen pipeline.** `build.yaml` with the `databases:` block, the two build commands, the `schema dump` ordering discipline, and the decision that `*.g.dart` / `*.drift.dart` / `drift_schemas/` are committed. It blocks E03-T01 because the schema cannot be written until the tooling that snapshots it exists — and the v1 snapshot is due on day one, not when the first migration is.

**E01-T04 — CI workflow.** One file, two jobs. `verify` runs the freshness gates, `dart format`, `flutter analyze --fatal-infos`, and `flutter test`; `build-android` actually compiles a release appbundle, because `dart analyze` can be silenced on a non-exhaustive switch that `dart compile` still rejects. The task is as much about the refusals as the steps: no goldens, no emulator job, no Codecov, no release pipeline. Its most important line is a sentence, not YAML — CI can never prove this app makes a sound, so the manual on-device pass is a release artifact.

**E01-T05 — Policy tests.** Four ~10-line greps under `test/policy/` for invariants that are textually decidable, silent when broken, and one line away from broken. They read source through a comment-stripping helper so a rule's own explanation cannot trip the rule, they accumulate offenders and fail once with the whole list, and each `reason:` names the consequence to the person using the app — because a `reason:` that says "fails the palette check" gets deleted at 2am and one that says "every Android 11+ user gets a board that cannot speak" does not.

**E01-T06 — Cold-launch sequence in main().** The one task in this epic that ships user-visible behaviour, and the reason it sits last: it cannot be written until the database (E02-T03) and the speech service (E04-T03) exist to be wired. `CrashLog.open()` first, both error handlers before the DB open, settings read before `runApp` so the right palette is painted on frame one, `warmUp()` fired from `addPostFrameCallback` and never awaited. It closes the epic by proving the guardrails hold a real boot.

## Skills this epic draws on

**Structure and dependencies**
- `reed-project-structure` — where every file goes: layer-first at the top, surface-first in `lib/ui/`, two levels max, tests mirroring `lib/`.
- `reed-layering-rules` — what not to build: no `lib/domain/`, no `*UseCase`, no abstract repository over `BoardRepository`, no `go_router`, no `freezed`.
- `reed-dependency-hygiene` — caret ranges, the committed lock, the `.fvmrc` JSON string, the transitive audit gate, and the coupled `very_good_analysis` include on any SDK bump.

**Enforcement**
- `reed-lint-config` — the version-pinned include, the promotions to error, the `linter:`-vs-`errors:` distinction that decides whether `close_sinks` runs at all, the excludes.
- `reed-code-bans` — the permanent banned list every gate in this epic exists to enforce, and the greps that enforce what no lint can.
- `reed-no-silent-failures` — the arrow-callback hole (`onTap: () => speak(x)`) that all three Future lints miss, and why the fix is structural.
- `reed-policy-tests` — the three criteria a policy test must meet, the comment-stripping support file, and the exact form of each assertion.
- `reed-ci-workflow` — what `ci.yml` runs, the freshness gates, the pinned action versions, and everything CI is refused.
- `reed-testing-strategy` — the ~135-test / under-30-second budget the suite is being built inside, and the four files held at 100%.

**Data and boot**
- `reed-codegen-workflow` — the two build commands, `build.yaml`'s `databases:` block, `make-migrations`, and the dump-before-bump ordering.
- `reed-drift-schema` — the invariants the codegen pipeline exists to protect, chiefly `grid_slots` keyed by `(board_id, row_index, col_index)`.
- `reed-app-startup` — the exact order of `main()` and what is banned from the launch path.
- `reed-error-model` — the two handlers, no zone, `onError` always `true`, `CrashLog.record` synchronous and unable to throw.
- `reed-theming-code` — restoring the saved palette before first paint and `themeAnimationStyle: AnimationStyle.noAnimation`.
- `reed-speech-service` — why `warmUp()` is fired and never awaited, and why the manifest `<queries>` declaration is a startup concern.

## Sequencing

E01-T01 is the trunk; nothing else in the epic can start before the tree and `pubspec.yaml` exist. It gates on E00-T03 — this epic only begins if E00 did not kill the project.

From T01 the work forks into two independent branches that can run in parallel: **T02 → {T04, T05}** and **T03**. T02 blocks T04 and T05 because both consume its output — CI runs `flutter analyze --fatal-infos` against the config, and the policy tests exist precisely to cover the ground the config cannot reach. T04 and T05 do not block each other; write them in either order, but write T05 first if you want CI's most valuable step to exist on its first run.

T03 is independent of the analyzer branch and blocks E03-T01, which is the real reason it is here rather than in the data epic: the `build.yaml` `databases:` block must exist before there is any user data to lose, or the v1 snapshot has to be reconstructed from git archaeology later.

T06 is the tail and is not a hard chain from anything in this epic. It waits on E02-T03 (the database) and E04-T03 (the speech service). Do not stub either to unblock it early — a `main()` wired to a placeholder DB proves nothing about the sequence it exists to get right.

## Risks specific to this epic

- **The analyzer that inspects nothing.** A `very_good_analysis` include filename absent from the resolved package yields one `include_file_not_found` warning and zero active rules. Green build, no checking. Verify with `ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/` and by confirming a known violation still errors.
- **`errors:` cannot enable a lint.** `analyzer: errors:` only re-ranks diagnostics that are already produced. `close_sinks: error` alone produced **no diagnostic at all** for a never-closed `StreamController` — it needs a `linter: rules:` entry too. Probe with a real leaked controller.
- **Config parse errors are silent nets.** Mixing `- rule: false` under `linter: rules:` with the map form, or writing `riverpod_lint: ^3.1.3` with a nested `diagnostics:`, is a YAML parse error — which is a broken analyzer, which is a green build.
- **Analyze-only CI.** `errors: non_exhaustive_switch_statement: ignore` silences `dart analyze` while `dart compile` still fails. If `build-android` is dropped to save minutes, CI can pass on code that cannot ship.
- **`flutter test` on Linux without `libsqlite3-dev`.** `flutter test` runs in a plain Dart VM where `sqlite3_flutter_libs` does nothing; the entire DB suite fails in a way that looks like a broken repo.
- **The dump-before-bump inversion.** Edit `tables.dart`, forget the `schemaVersion` bump, run `schema dump`: v1's snapshot is overwritten with v2's shape, nothing errors, and on the device `onUpgrade` never runs. Highest-cost bug in the codebase, caused by two shell commands in the wrong order.
- **Vacuous generated migration tests.** `make-migrations` emits `final oldButtonsData = <v1.Button>[];` with a `// TODO: Fill these lists`. Empty lists mean the test asserts `[] == []` and passes — a green tick named "does not corrupt data" that verified nothing.
- **Policy tests that cry wolf.** A whole-file `contains` trips on the comment explaining the ban. Read through `codeOf`/`xmlOf`, anchor to a structure (import URI, class body, XML element), and never grep for taste — a false-positive test gets the whole directory deleted the first time someone is in a hurry.
- **Unverified action majors.** `checkout` v6, `setup-java` v5, `upload-artifact` v6, `flutter-action` v2 (there is no v3). A guessed major silently changes behaviour. Mark unverified versions inline; never invent one.
- **Reporting "analyzer clean" as evidence of speech.** It is not. `onTap: () => speech.speak(p)` is caught by no lint in this config, and no CI job on earth can assert PCM came out of a speaker.

## Out of scope

- **The schema itself** — tables, columns, migrations, and their tests are E03. This epic only builds the tooling that snapshots and regenerates them.
- **The `SpeechService` interface, `SpeakOutcome`, and the `flutter_tts` implementation** — E04. E01-T06 wires them into `main()`; it does not define them.
- **`tokens.dart`, the four palettes, and the contrast matrix** — the theming epic. E01-T06 only restores the saved palette before first paint.
- **The grid, tiles, compose field, and the widget-test harness** — the board epic. The `test/` mirror created in E01-T01 is an empty shape until then.
- **Signing, the release build, the store listing, and the manual on-device checklist** — the release epic. CI here deliberately builds an *unsigned* appbundle and holds no keystore secret.
- **The Quick Settings tile and its contract test** — the native epic. E01-T01 only reserves `lib/native/` as the place a `MethodChannel` is allowed to exist.
