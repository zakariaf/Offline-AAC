---
name: reed-ci-workflow
description: Defines what .github/workflows/ci.yml runs and what it cannot prove — dart format, flutter analyze --fatal-infos, flutter test, build appbundle, the build_runner and drift_dev freshness gates, pinned action versions, and ungated coverage. Use when editing the workflow, adding or removing a step or job, proposing an emulator, integration_test, golden, or Codecov job, or claiming CI proves TTS or audio works. Not for what must be verified by hand on a phone.
---

# CI for Reed

One workflow file. It proves the code compiles, is formatted, analyzes clean, passes tests, and that generated code and schema dumps match source. It proves nothing about sound.

## The load-bearing fact: CI can never verify that this app speaks

State this out loud whenever anyone — including a future self — proposes automating the audio path. Two independent reasons:

1. Standard Android emulator system images commonly ship **with no TTS engine and no voice data**. Google TTS must be installed from Play and its voice data downloaded, and that download is itself unreliable in emulated environments.
2. **Even with a working engine, no supported hook captures or asserts PCM output** from Android `TextToSpeech` or iOS `AVSpeechSynthesizer`. `integration_test` can assert a channel call was issued. It cannot assert sound came out.

Reason 1 is bad luck you could theoretically fix with a better image. **Reason 2 is architectural and unfixable.** The highest-severity bug class in this product — a user taps a tile mid-shutdown and hears nothing — is structurally unreachable by any CI job anyone could write.

The only honest automated audio check that exists is Android's `TextToSpeech.synthesizeToFile()`, which writes a WAV you can assert is non-empty and non-silent. That is a native instrumentation test on real hardware, not a Dart one, and it is not worth building.

**The consequence is not "write more tests."** It is that the manual on-device pass is a load-bearing release artifact, not a chore: run it on a real phone with the ringer switch OFF before every upload. When a change touches `flutter_tts`, `audio_session`, `SpeechService`, or voice selection, say plainly that green CI is not evidence of audio and that the device pass is the check.

## The other things CI cannot do

| Refused | Because |
|---|---|
| Golden tests, `update-goldens.yml`, alchemist | Platform-dependent once real fonts load; a golden made on macOS fails on `ubuntu-24.04`. Pinning the runner makes CI authoritative, and then a stranger cloning on Linux sees a wall of red and concludes the repo is broken. Goldens actively sabotage the plan for this app to outlive its author. The overflow matrix and `getRect` layout invariants catch the same regressions with a readable failure message and no binary blobs. |
| Emulator / `integration_test` CI, Firebase Test Lab, Patrol | 15+ minute runs, VM-service timeouts, green-locally/red-in-CI nondeterminism — bought for a check that cannot observe the one thing that matters. |
| Codecov, `VeryGoodOpenSource/very_good_coverage`, coverage % gates | See coverage below. `very_good_coverage` was archived 2026-03-31, is read-only, and is still the top recommendation in most Flutter CI tutorials. |
| `release.yml`, fastlane, `r0adkll/upload-google-play` | Releases are built and signed on the laptop and uploaded by hand — roughly six times. A pipeline is the one part of this repo a successor cannot reuse. |
| Branch protection, PRs, CODEOWNERS, issue templates | All coordinate humans that do not exist. Pure prepayment. |

## The workflow

`.github/workflows/ci.yml`, and it is the only workflow file.

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
          flutter-version-file: .fvmrc   # JSON: { "flutter": "3.41.2" }
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

Rules the YAML encodes, so a future edit does not undo them:

- **Mark unverified action versions inline; never invent one.** A wrong major silently fails or silently changes behaviour. Write `# VERIFY:` next to a version rather than guessing.
- **`flutter-version-file: .fvmrc`.** That file is JSON — `{ "flutter": "3.41.2" }` — parsed with `jq -r '.flutter'`. The `flutter: 3.44.0` YAML form belongs to `pubspec.yaml`'s `environment:`; putting it in `.fvmrc` is wrong.
- **`ubuntu-24.04`, never `ubuntu-latest`.** Image drift moves lcov and toolchain versions under the workflow with no diff to review.
- **`libsqlite3-dev` before `flutter test`.** `flutter test` runs in a plain Dart VM where `sqlite3_flutter_libs` does nothing; without the host library the whole DB suite fails on Linux for a reason that looks like a broken repo.
- **`--test-randomize-ordering-seed random`.** Free detection of inter-test state leakage, which matters disproportionately because much of the suite shares one in-memory drift database.
- **`--fatal-infos`.** The analyzer is one of only two feedback loops. An info left unfixed is a warning that gets ignored next.

## The two checks with the best safety-per-line

**The schema-dump gate.** `drift_dev schema dump` + `git diff --exit-code -- drift_schemas/` catches *changed the schema, forgot to bump `schemaVersion`* — the bug where no migration runs at all and every user's board silently fails to load. Months of hand-curated phrases, unmergeable and irreplaceable. It costs one step and requires zero migration code. Never weaken it to a warning; never let it run only on tags. The dump is also the one artifact that cannot be reconstructed after the version is bumped, so it must be committed.

The build_runner gate beside it is the whole reason committing `*.g.dart` / `*.drift.dart` is safe. Keep both, and check which suffix the drift config actually emits (`.drift.dart` modern vs `.g.dart` legacy part-file) before editing either pattern — do not guess.

**The policy greps.** Roughly ten lines each, they run inside `flutter test` and enforce what no lint can:

- `lib/` contains no `withClampedTextScaling` and no `textScaleFactor`. Clamping is the one-line "fix" a contributor reaches for when the overflow matrix goes red, and it silently defeats the entire text-scale matrix while contrast and tap-target checks still pass.
- `AndroidManifest.xml` declares `android.intent.action.TTS_SERVICE` in `<queries>`. Without it, Android 11+ package visibility hides the TTS engine, `flutter_tts` returns an empty voice list with only a `Log.d`, and every Android 11+ user gets a board that cannot speak — silently, forever.
- `AndroidManifest.xml` contains `android:allowBackup="false"`. The attribute defaults to true; left alone Android uploads the SQLite database — every vocalization the user owns — to Google Drive, contradicting the no-network promise this audience checks adversarially.
- `test/` contains no `pumpAndSettle`. Zero animation means one frame settles; `pumpAndSettle` adds only a ten-minute-timeout flake vector with truncated traces.

These are not workarounds. They are the only enforcement available for constraints whose violation is invisible in review and silent on the device.

## Coverage: measure, do not gate

`flutter test --coverage`, strip generated files, read the number as a report. **No percentage gate, no paid service.**

**Fix the lie before quoting any number.** `flutter test --coverage` omits files that no test imports, so an untested file contributes zero lines to the *denominator* rather than counting as 0%. One well-tested file and twenty untested ones can report ~100%. The number lies upward — the unsafe direction — and a coverage number that overstates safety is worse than none where there is no other net. Fix it with `dlcov --include-untested-files=true`, or a generated `test/coverage_helper_test.dart` that imports every file under `lib/`.

Strip generated code, and match the suffix the drift setup actually emits:

```bash
lcov --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.drift.dart' \
  -o coverage/lcov.info \
  --ignore-errors unused   # lcov 2.x (ubuntu-24.04) errors on unused patterns
```

Instead of a global threshold, hold four **files** — not directories — at 100%, because a bug in each is unrecoverable: the migrations under `lib/data/database/`, `lib/speech/voice_filter.dart`, `lib/data/repositories/board_repository.dart`, and `lib/diagnostics/crash_log.dart`. A directory floor on `lib/speech/` is jointly unsatisfiable, since the same directory holds the `flutter_tts` wrapper that is only reachable through channel mocks confined to one file. Hold those four by reading the diff, not by adding sixty lines of `awk` that count lines for a metric already known to be wrong.
