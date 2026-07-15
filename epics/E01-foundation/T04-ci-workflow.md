# E01-T04 — CI workflow

| | |
|---|---|
| **Epic** | E01 — Foundation |
| **Status** | Done |
| **Size** | M |
| **Depends on** | E01-T02 |
| **Blocks** | E11-T02 |

**Skills:** `reed-ci-workflow` · `reed-testing-strategy` · `reed-policy-tests`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

There is no telemetry. Nobody will ever learn that Reed crashed, or went silent, in someone's hands during a shutdown. The analyzer and the test suite are the entire feedback loop, and CI is the thing that runs them when the solo dev is tired and about to commit at 1am anyway. It also carries the schema-dump gate — the one check standing between a forgotten `schemaVersion` bump and every user's hand-curated board failing to load, months of phrases, unmergeable and irreplaceable.

## Scope

Build `.github/workflows/ci.yml`. **It is the only workflow file in this repo.** Two jobs: `verify` and `build-android`.

### The workflow

```yaml
name: ci

on:
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: read

jobs:
  verify:
    runs-on: ubuntu-24.04   # pinned, not -latest: lcov 2.x and image drift are real
    timeout-minutes: 20
    steps:
      # VERIFY before first run: actions/checkout, actions/setup-java and
      # actions/upload-artifact major versions drift. Recorded versions:
      # checkout v6, setup-java v5, upload-artifact v6 (v7 exists and adds
      # non-zipped artifacts). subosito/flutter-action is CONFIRMED still v2
      # (v2.23.0, 2026-03-25) — there is no v3.
      - uses: actions/checkout@v6

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
          cache: true
          pub-cache: true

      - run: flutter --version
      - run: flutter pub get

      # --- Freshness gates. The entire mitigation for committing codegen. ---
      - name: Generated code is up to date
        run: |
          dart run build_runner build --delete-conflicting-outputs
          if ! git diff --exit-code -- '*.g.dart' '*.drift.dart'; then
            echo "::error::Generated code is stale. Run build_runner and commit the result."
            exit 1
          fi

      - name: drift schema dumps are up to date
        run: |
          dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
          if ! git diff --exit-code -- drift_schemas/; then
            echo "::error::drift_schemas/ is stale — you changed the schema without"
            echo "::error::bumping schemaVersion and dumping. Shipping this means NO"
            echo "::error::MIGRATION RUNS and users lose their hand-curated boards."
            exit 1
          fi

      # --- Static analysis ---
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos

      # --- Tests ---
      # Ubuntu runners need host sqlite3: `flutter test` runs in a plain Dart VM
      # where sqlite3_flutter_libs does NOTHING.
      - run: sudo apt-get update -qq && sudo apt-get install -y -qq libsqlite3-dev

      - name: Test
        run: flutter test --test-randomize-ordering-seed random --reporter expanded

  build-android:
    needs: verify
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-java@v5
        with:
          distribution: temurin
          java-version: '17'
          cache: gradle
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
          cache: true
          pub-cache: true
      - run: flutter pub get

      # Unsigned. CI proves it compiles; releases are built and signed locally.
      # No keystore in GitHub secrets — there is no signing secret to leak.
      # No --obfuscate, no --split-debug-info: both strip Dart function names
      # from AOT traces, and the on-device exportable crash log is the only
      # field signal this app will ever have.
      - run: flutter build appbundle --release

      - uses: actions/upload-artifact@v6
        with:
          name: app-release-unsigned-aab
          path: build/app/outputs/bundle/release/app-release.aab
          retention-days: 14
```

### The header comment — state the load-bearing fact in the file

The workflow must open with a comment block, above `name: ci`, saying in plain words that **CI can never verify that this app speaks**, for two independent reasons:

1. Standard Android emulator system images commonly ship with **no TTS engine and no voice data**. Google TTS must be installed from Play and its voice data downloaded, and that download is itself unreliable in emulated environments.
2. Even with a working engine, **no supported hook captures or asserts PCM output** from Android `TextToSpeech` or iOS `AVSpeechSynthesizer`. `integration_test` can assert a channel call was issued. It cannot assert sound came out.

Reason 1 is bad luck a better image could theoretically fix. **Reason 2 is architectural and unfixable.** The comment must say that this is not a gap to close with more automation — it is closed by the manual on-device pass, run on a real phone with the ringer switch OFF before every upload, and that pretending otherwise is how a silent build ships green. Name `flutter_tts`, `audio_session`, `SpeechService` and voice selection as the changes after which green CI is not evidence of audio.

The comment is load-bearing content, not decoration. It is what stops a future self from adding an emulator job.

### The two checks with the best safety-per-line

**The schema-dump gate** (`drift_dev schema dump` + `git diff --exit-code -- drift_schemas/`) catches *changed the schema, forgot to bump `schemaVersion`* — the bug where no migration runs at all and every user's board silently fails to load. One step, zero migration code. Never weaken it to a warning; never let it run only on tags. The dump cannot be reconstructed after the version is bumped, so it must be committed.

The `build_runner` gate beside it is the whole reason committing `*.g.dart` / `*.drift.dart` is safe. Before editing either pattern, **check which suffix the drift config actually emits** — `.drift.dart` (modern) vs `.g.dart` (legacy part-file). Do not guess.

**The policy greps** run inside `flutter test` (they are pure Dart, importing `package:test/test.dart`, under `test/policy/`) and enforce what no lint can. This task's job is to make sure `flutter test` in CI actually reaches them; the four that must be green:

- `lib/` contains no `withClampedTextScaling` and no `textScaleFactor`. Clamping is the one-line "fix" a contributor reaches for when the overflow matrix goes red, and it silently defeats the entire text-scale matrix while contrast and tap-target checks still pass.
- `AndroidManifest.xml` declares `android.intent.action.TTS_SERVICE` **inside `<queries>`** — not merely somewhere in the file. Without it, Android 11+ package visibility hides the TTS engine, `flutter_tts` returns an empty voice list with only a `Log.d`, and every Android 11+ user gets a board that cannot speak, silently, forever.
- `AndroidManifest.xml` contains `android:allowBackup="false"`. The attribute defaults to true; left alone Android uploads the SQLite database — every vocalization the user owns — to Google Drive, contradicting the no-network promise this audience checks adversarially.
- `test/` contains no `pumpAndSettle`. Zero animation means one frame settles; `pumpAndSettle` adds only a ten-minute-timeout flake vector with truncated traces.

### Coverage: measure, do not gate

`flutter test --coverage` locally, strip generated files, read the number as a report. **No percentage gate in CI, no paid service, no `very_good_coverage` step.**

Fix the lie before quoting any number: `flutter test --coverage` **omits files that no test imports**, so an untested file contributes zero lines to the *denominator* rather than counting as 0%. One well-tested file and twenty untested ones can report ~100%. The number lies upward — the unsafe direction. Fix it with `dlcov --include-untested-files=true`, or a generated `test/coverage_helper_test.dart` that imports every file under `lib/`.

Stripping, with the suffix the drift setup actually emits:

```bash
lcov --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.drift.dart' \
  -o coverage/lcov.info \
  --ignore-errors unused   # lcov 2.x (ubuntu-24.04) errors on unused patterns
```

Four **files** — not directories — are held at 100% by reading the diff, not by `awk` in CI: the migrations under `lib/data/database/`, `lib/speech/voice_filter.dart`, `lib/data/repositories/board_repository.dart`, `lib/diagnostics/crash_log.dart`. A directory floor on `lib/speech/` is jointly unsatisfiable — the same directory holds the `flutter_tts` wrapper, reachable only through channel mocks confined to one file.

### Out of scope — refuse these, and restate the reason when refusing

| Refused | Because |
|---|---|
| Emulator / `integration_test` CI, Firebase Test Lab, Patrol | 15+ minute runs, VM-service timeouts, green-locally/red-in-CI nondeterminism — bought for a check that cannot observe the one thing that matters. |
| Golden tests, `update-goldens.yml`, alchemist | Platform-dependent once real fonts load; a macOS golden fails on `ubuntu-24.04`. Pinning the runner makes CI authoritative, and then a stranger cloning on Linux sees a wall of red and concludes the repo is broken. The overflow matrix and `getRect` layout invariants catch the same regressions with a readable message and no binary blobs. |
| Codecov, `VeryGoodOpenSource/very_good_coverage`, coverage % gates | The number lies upward. `very_good_coverage` was archived 2026-03-31 and is read-only, yet is still the top recommendation in most Flutter CI tutorials. |
| `release.yml`, fastlane, `r0adkll/upload-google-play` | Releases are built and signed on the laptop and uploaded by hand — roughly six times. A pipeline is the one part of this repo a successor cannot reuse. |
| Branch protection, PRs, CODEOWNERS, issue templates | All coordinate humans who do not exist. Pure prepayment. |
| A `--coverage` step in `verify` | Coverage is a local report, not a CI signal, and running it in CI invites the gate. |

Writing the policy test files themselves is out of scope here (they live under `test/policy/` with `test/policy/policy_support.dart`); this task owns the workflow and the fact that `flutter test` runs them.

## Acceptance criteria

- [ ] `.github/workflows/ci.yml` exists and is the only file in `.github/workflows/`.
- [ ] The file opens with the comment block stating that CI can never verify that the app speaks, giving both reasons, marking reason 2 as architectural and unfixable, and naming the manual on-device pass (real phone, ringer switch OFF) as the closure.
- [ ] Runner is `ubuntu-24.04` on both jobs. `grep -c 'ubuntu-latest' .github/workflows/ci.yml` returns 0.
- [ ] Both jobs use `flutter-version-file: .fvmrc`; `jq -r '.flutter' .fvmrc` prints a version string (the file is JSON, not the `flutter: 3.44.0` YAML form that belongs in `pubspec.yaml`'s `environment:`).
- [ ] Every `uses:` line either carries a version confirmed against the recorded list (checkout v6, setup-java v5, upload-artifact v6, subosito/flutter-action v2) or carries an inline `# VERIFY:` comment. No invented majors.
- [ ] The build_runner gate fails the job on a stale `*.g.dart` / `*.drift.dart`: verify by touching a source file's annotation, not regenerating, and pushing — the job must go red with the `::error::` message.
- [ ] The schema gate fails the job on a stale dump: verify by editing a table without bumping `schemaVersion` and without dumping — job red, message names the board-loss consequence.
- [ ] `dart format --output=none --set-exit-if-changed .` and `flutter analyze --fatal-infos` both run and both fail the job on violation.
- [ ] `libsqlite3-dev` is installed before `flutter test` in `verify`.
- [ ] Test step uses `--test-randomize-ordering-seed random --reporter expanded`.
- [ ] `build-android` has `needs: verify`, runs `flutter build appbundle --release` with no `--obfuscate` and no `--split-debug-info`, and uploads `build/app/outputs/bundle/release/app-release.aab` with `retention-days: 14`.
- [ ] No keystore, no signing secret, no `secrets.` reference anywhere in the file.
- [ ] `permissions: contents: read` and the `concurrency` group with `cancel-in-progress: true` are present.
- [ ] `timeout-minutes: 20` on both jobs.
- [ ] A full green run completes and the whole `verify` job stays inside the suite budget it wraps (~135 tests, under 30 s of `flutter test`).
- [ ] `grep -rE 'codecov|very_good_coverage|--coverage|emulator|integration_test|golden' .github/workflows/` returns nothing.

## Traps

- **Putting `flutter: 3.44.0` in `.fvmrc`.** That YAML form belongs to `pubspec.yaml`'s `environment:`. `.fvmrc` is JSON, parsed with `jq -r '.flutter'`. Get it wrong and `flutter-action` either errors cryptically or silently resolves a different version than the laptop is running — and then "works on my machine" becomes a version skew nobody looks for.
- **`ubuntu-latest`.** Image drift moves lcov and the toolchain under the workflow with no diff to review. One morning the schema gate starts failing and nothing in the repo changed.
- **Forgetting `libsqlite3-dev`.** `flutter test` runs in a plain Dart VM where `sqlite3_flutter_libs` does *nothing*. Without the host library the whole DB suite fails on Linux, and the failure reads like a broken repo rather than a missing apt package — exactly the impression that makes a stranger close the tab.
- **Guessing an action major.** A wrong major either silently fails or silently changes behaviour. `upload-artifact` v7 exists and changes artifact packaging; `subosito/flutter-action` has no v3 and bumping it to v3 is a fabrication. Write `# VERIFY:` next to anything unconfirmed rather than guessing.
- **Editing the codegen glob to the wrong suffix.** Drift emits `.drift.dart` (modern) or `.g.dart` (legacy part-file) depending on config. Pattern the wrong one and the freshness gate passes on everything forever — a gate that is green because it matches no files is worse than no gate, because it is trusted.
- **Weakening the schema gate to a warning, or moving it behind a tag trigger.** It is the only thing that catches a missing `schemaVersion` bump, and the dump cannot be reconstructed once the version has moved. This is the check that stands between a merge and someone's board never loading again.
- **Dropping `--fatal-infos` because an info is noisy.** The analyzer is one of only two feedback loops. An info left unfixed is a warning that gets ignored next week.
- **Dropping `--test-randomize-ordering-seed random` because a test went red.** That red is the point — much of the suite shares one in-memory drift database, and ordering flake there is real state leakage, not a CI quirk.
- **Adding `--obfuscate` / `--split-debug-info` to the release build "for the store."** Both strip Dart function names from AOT traces, and the on-device exportable crash log is the only field signal this app will ever have. This one is tempting precisely because it looks like a best practice.
- **Adding an emulator job "just to be safe."** The emulator ships no TTS engine and, even with one, nothing can assert PCM came out. It buys a 15-minute nondeterministic job that cannot observe the only thing that matters, and it manufactures the belief that green CI means the app speaks. That belief is how a silent build ships.
- **Adding a coverage gate because the number is right there.** `flutter test --coverage` omits files no test imports, so the number lies upward. A gate on a number that overstates safety, in a project with no other net, is worse than no number.
- **The header comment getting trimmed as "noise" in a cleanup pass.** Write it as a reason a stranger at 2am will not delete: name the consequence to the person using the app, not the rule.

## Files

- Creates `.github/workflows/ci.yml`.
- Reads (must exist, does not create): `.fvmrc`, `pubspec.yaml`, `lib/data/database/app_database.dart`, `drift_schemas/`, `android/app/src/main/AndroidManifest.xml`.

## Done when

A push to `main` runs one workflow that formats, analyzes with `--fatal-infos`, proves generated code and `drift_schemas/` are fresh, runs the full suite with randomized ordering on `ubuntu-24.04`, uploads an unsigned release AAB — and says in its own header, in words, that none of it is evidence the app makes a sound.


---

## What actually happened

Written and validated: the YAML parses, both jobs are `ubuntu-24.04`
(`ubuntu-latest`: 0 hits), every action is pinned to a real major, and both jobs
read the toolchain from `.fvmrc`.

Every gate was run locally with real exit codes before being trusted — and that
mattered: `dart format --set-exit-if-changed . | tail -1` reports the exit of
`tail`, not of `format`. It looked green while six files were unformatted.

The workflow opens by stating that CI can never verify the app speaks, gives
both reasons, marks the second as architectural, and names the on-device pass
with the ringer switch off as the closure.
