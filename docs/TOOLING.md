# TOOLING.md

Build, CI, and repo mechanics for Offline AAC. Everything here is subordinate to one fact: **there is no telemetry and there never will be.** No Crashlytics, no Sentry, no analytics. Nobody will file a bug — our users are, by definition, unable to speak when the app fails them. That makes the toolchain one of only two feedback loops we have (the other is the test suite), and it makes most conventional CI/CD ceremony worthless here, because it optimizes for coordinating humans we don't have.

This doc is short on purpose. Where a practice doesn't earn its place, it says so.

---

## 1. SDK pinning

**Verified on this machine (2026-07-15):** Flutter **3.41.2** / Dart **3.11.0**, not the 3.44/Dart 3.12 you may assume. That gap is not cosmetic — it already changes which `very_good_analysis` resolves (10.2.0, because 10.3.0 requires Dart `^3.12.0`), and a versioned `include:` pointing at a file that doesn't exist in the resolved package produces only a `warning • include_file_not_found` while **silently disabling all 212 lints**. On a project where the analyzer is one of two safety nets, a net that reports green while checking nothing is worse than no net.

So: pin. But pin **the record, not the tool**.

Commit `.fvmrc` at the repo root. It is **JSON**, parsed by `jq -r '.flutter'`:

```json
{ "flutter": "3.41.2" }
```

> The commonly-copied `flutter: 3.44.0` YAML form is the **`pubspec.yaml` `environment:`** shape, parsed with `yq eval '.environment.flutter'`. It is wrong in `.fvmrc`. Channel names (`stable`, `beta`, `master`, `main`) are also accepted — it is not exact-versions-only.

**Do not install `fvm`.** You are one developer on one machine; a version manager solves switching between projects you don't have. The file earns its place because CI reads it (§4) and because a stranger reads it. The tool does not. Bump the string by hand when you upgrade, in the same commit as the `flutter upgrade`.

Keep `pubspec.yaml`'s `environment:` a normal range. The `.fvmrc` pins; the range keeps `pub` able to solve.

---

## 2. build_runner and the drift workflow

Two commands. Neither is a daily thing.

```sh
# After changing lib/data/database/tables.dart
dart run build_runner build --delete-conflicting-outputs

# While actively editing tables (a session, not a practice)
dart run build_runner watch --delete-conflicting-outputs
```

**`build.yaml` at the repo root, from commit #1** — before there is any user data to lose:

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

Then:

```sh
dart run drift_dev make-migrations
```

**All of this is verified against `drift_dev` 2.31.0 in the local pub cache** (`lib/src/cli/commands/make_migrations.dart`): the command is named `make-migrations`, it hard-errors with *"No databases found in the build.yaml file"* without the `databases:` block, and `test_dir`/`schema_dir` default to `test/drift/` and `drift_schemas/`. It supersedes running `schema dump` / `schema steps` / `schema generate` by hand.

### The trap in what it generates

`make-migrations` emits a data-integrity test built on `SchemaVerifier.testWithDataIntegrity` — good, and better than the corpus's assumption that you must hand-roll `schemaAt` + versioned data classes. But read the template it writes:

```dart
final oldButtonsData = <v1.Button>[];
final expectedNewButtonsData = <v2.Button>[];
// TODO: Fill these lists
```

**With both lists empty the test passes vacuously.** It inserts nothing, then asserts `[] == []`. You get a green test named *"migration from v1 to v2 does not corrupt data"* that has verified precisely nothing. In this app that green tick stands between a user and a permanently empty board. Fill the lists in the same commit that generates them, or delete the test — a test that lies is worse than an absent one.

(`schema generate --data-classes --companions` — the flags the corpus recommends — do exist; `make-migrations` invokes that path for you.)

### Commit the generated code. Yes, really.

`*.g.dart` and/or `*.drift.dart` go **into git**. This is against Dart convention and it is correct here for three reasons:

1. A stranger's `git clone && flutter run` works with no `build_runner` round-trip. That is the minimum bar for the exit plan.
2. **drift's generated code *is* the schema.** A migration PR then shows the actual schema delta as a reviewable diff, which turns migration review into a safety gate rather than a leap of faith.
3. It pins output against a future `drift_dev` that generates different code — or, in 2029, refuses to resolve at all.

The usual objection (merge conflicts) is void for a solo dev. The diff-noise objection is handled by `.gitattributes`:

```
*.g.dart      linguist-generated=true
*.drift.dart  linguist-generated=true
```

The staleness risk is real and is fully handled by a CI gate (§4). **Coverage and analysis must both exclude generated files** — `analysis_options.yaml` already does; the coverage side is §6. Check which suffix your drift config actually emits (`.drift.dart` modern vs `.g.dart` legacy part-file) before writing either pattern — don't guess.

---

## 3. What CI can and cannot do

### CI can never verify that this app speaks. State this out loud.

Two independent reasons, and the second is the one that matters:

1. Standard Android emulator system images commonly ship **without a TTS engine or voice data**. Google TTS must be installed from Play and its voice data downloaded — a download that is itself unreliable in emulated environments.
2. **Even with a working engine, there is no supported hook to capture or assert PCM output** from Android `TextToSpeech` or iOS `AVSpeechSynthesizer`. `integration_test` can assert that a channel call was issued. It cannot assert that sound came out.

Reason 1 is a bad-luck problem you could theoretically fix with a better image. **Reason 2 is architectural and unfixable.** The single highest-severity bug class in this product — a user taps a tile mid-shutdown and hears nothing — is structurally unreachable by any CI job you could write.

The only honest automated audio check that exists is Android's `TextToSpeech.synthesizeToFile()`, which writes a WAV you can assert is non-empty and non-silent. That is a native instrumentation test on a real device, not a Dart one. It is not worth building in a 2-week MVP.

**The consequence is not "write more tests." It is that `docs/CHECKLIST.md` — the manual on-device pass — is a load-bearing release artifact, not a chore.** Run it on a real phone with the ringer switch OFF before every upload.

### The other two CI can't-dos

- **Goldens.** Platform-dependent once real fonts load; a golden generated on your Mac fails on `ubuntu-latest`. You could pin the runner and make CI authoritative — but then a stranger cloning on Linux sees a wall of red and concludes the repo is broken. **Goldens actively sabotage the exit plan.** Skip them entirely; the overflow matrix and `getRect` layout invariants catch the same regressions with a readable failure message and no binary blobs.
- **Emulator integration tests.** 15+ minute runs, documented VM-service timeouts, green-locally/red-in-CI nondeterminism — bought for a check that cannot observe the thing that matters (above). No emulator job.

---

## 4. The workflow

One file. `.github/workflows/ci.yml`:

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
      # actions/upload-artifact major versions drift. These are the versions the
      # research pass recorded (checkout v6, setup-java v5, upload-artifact v6;
      # upload-artifact v7 exists and adds non-zipped artifacts). subosito/flutter-action
      # is CONFIRMED still v2 (v2.23.0, 2026-03-25) — there is no v3.
      - uses: actions/checkout@v6

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc   # JSON; see §1
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
      # No --obfuscate, no --split-debug-info. See §7.
      - run: flutter build appbundle --release

      - uses: actions/upload-artifact@v6
        with:
          name: app-release-unsigned-aab
          path: build/app/outputs/bundle/release/app-release.aab
          retention-days: 14
```

`--test-randomize-ordering-seed random` is free detection of inter-test state leakage, which matters disproportionately when much of the suite shares an in-memory drift database.

The two freshness gates are the highest-value steps in the file. The schema-dump gate catches *changed the schema, forgot to bump `schemaVersion`* — the bug where no migration runs at all and every user's board silently fails to load. It costs one step and requires you to write zero migration code.

**Do not add `update-goldens.yml` or `release.yml`.** They coordinate humans you don't have and automate a step you'll do six times.

---

## 5. Coverage

`flutter test --coverage`, exclude generated files, read the number as a report. **No gate.**

Three reasons, in order of force:

1. **The number lies upward.** `flutter test --coverage` **omits files that no test imports** ([flutter#27997](https://github.com/flutter/flutter/issues/27997)) — an untested file contributes zero lines to the *denominator* rather than counting as 0%. A codebase with one well-tested file and twenty untested ones can report ~100%. A coverage number that overstates safety is worse than none here. (`dlcov --include-untested-files=true` fixes it if you look at the number at all.)
2. **VGV's 100% argument doesn't transfer.** Their stated case is confidence-under-change; the supporting case is that any lower threshold forces subjective exclusion arguments. Both are worth paying for across a consultancy. Neither is worth a day of a 2-week solo budget, and a gate a solo dev sets is a gate a solo dev bypasses.
3. The corpus's per-directory floor script is **jointly unsatisfiable**: it gates `lib/speech/` at 100% while `lib/speech/` contains the flutter_tts wrapper, which is only reachable via channel mocks that the same corpus (correctly) confines to one file.

The four files where a bug is unrecoverable — migrations, `voice_filter`, the board repository, the crash log — get covered because the test doc says so and because you can read a diff, not because 60 lines of `awk` counted lines for you. **`lcov` isn't even installed on this machine**; adding it to your local loop is friction bought for a number you've just been told is wrong.

Do **not** use `VeryGoodOpenSource/very_good_coverage` — [archived 2026-03-31](https://github.com/VeryGoodOpenSource/very_good_coverage), read-only, and still the top recommendation in most Flutter CI tutorials.

---

## 6. Release

Build and sign **on your laptop**. Upload to Play internal testing **by hand**. This is a decision, not a TODO.

```sh
# 1. Bump `version: 1.0.1+8` in pubspec.yaml. Commit. Tag.
# 2.
flutter build appbundle --release
# 3. Run docs/CHECKLIST.md on a REAL device, ringer switch OFF.
# 4. Upload build/app/outputs/bundle/release/app-release.aab to the internal track.
# 5. Attach the .aab to the GitHub Release so the artifact outlives the Play account.
```

**versionCode comes from `pubspec.yaml`'s `+N`. Never from `github.run_number`.** `run_number` is per-workflow-file and resets to 1 if the workflow is renamed or recreated; a Play versionCode is monotonic and **permanently consumed even by a deleted release**. A reset silently makes every subsequent build unuploadable until you manually jump past the high-water mark. The committed number is also what a successor reads — they will not have your Actions history.

**Enroll in Play App Signing.** Google holds the app signing key; your keystore is only the *upload* key, and a lost upload key is a support ticket, not a catastrophe. Record that asymmetry: the upload key is replaceable, the users' boards are not.

**Fastlane: no.** It works fine and it doesn't pay for itself across ~6 internal-track uploads. It costs a Ruby toolchain, a Play service-account JSON in CI secrets, and a `fastlane/metadata` tree. And the succession argument cuts *against* it: a stranger forking this app has their own Play account, their own service account, their own signing key. **Release automation is the one part of this repo they cannot reuse.** A README they can read beats a pipeline they must dismantle.

---

## 7. Obfuscation: work it through

Three forces pull here, and they resolve cleanly.

| Force | Verdict |
|---|---|
| `--obfuscate` protects the code | Void. [Flutter's own docs](https://docs.flutter.dev/deployment/obfuscate): *"Obfuscating your code does not encrypt resources nor does it protect against reverse engineering. It only renames symbols with more obscure names."* And the exit plan is **publishing the source**. There is nothing to protect. |
| The crash log must be readable | `--obfuscate` and `--split-debug-info` both strip the Dart function names from AOT stack traces. The on-device exportable log is the **only** field signal this app will ever have. Symbolizing requires `flutter symbolize -i trace -d app.android-arm64.symbols` — i.e. the developer still existing and still holding the exact per-build, per-arch symbols file. |
| Abandonment is planned | After you stop, nobody holds that file. **Every crash report ever filed becomes permanently unreadable.** |

**Answer: ship neither flag.** `--obfuscate` additionally breaks `runtimeType.toString()` matching — a silent-failure vector in a codebase whose worst bug class is silence. The cost of refusing is a few MB on a ~7–10MB baseline that is ~70% Flutter engine you can't shrink anyway.

**If app size ever forces the issue:** use `--split-debug-info` **without** `--obfuscate`, and attach the entire symbols directory to the GitHub Release for that tag. Names leave the binary (the size win), the symbols are public and permanent, and *any* stranger — not just you — can symbolize a user's log years later. Obfuscation is the half with no upside; split-debug-info's downside is fully repaired by publishing the symbols.

Add to `docs/CHECKLIST.md`: *trigger a crash, export the log, confirm the trace has readable Dart function names.* Hex offsets mean a flag crept in and the only field signal is dead.

---

## 8. Dependency hygiene

**Caret ranges in `pubspec.yaml`, and commit `pubspec.lock`.** The lock is what pins; ranges keep resolution solvable. Exact pins in `pubspec.yaml` only manufacture unsolvable conflicts on the next SDK upgrade.

> **The standard [`github/gitignore` Dart template ignores `pubspec.lock`.](https://github.com/github/gitignore/blob/main/Dart.gitignore) Delete that line.** It ships with the comment *"If you're building an application, you may want to check-in your pubspec.lock"* — we are an application. The lock is the only thing that makes a stranger's clone resolve the exact `flutter_tts` and `drift` versions you tested against a real device.

Run `dart pub outdated` when you feel like it. **Skip Renovate and Dependabot** — Dependabot [has never supported pub](https://github.com/dependabot/dependabot-core/issues/2166) (closed without shipping it), and Renovate raises PRs on a repo with no PR workflow. Its one genuinely useful feature here (never automerge `flutter_tts`/`audio_session`, because **green CI is not evidence of audio** — see §3) is only meaningful if you have automerge, and you don't.

### Vendoring flutter_tts the day it breaks

`flutter_tts` is bus-factor-1. The mitigation isn't to vendor it now — it's that vendoring is *cheap* because `SpeechService` already abstracts it, and because we only use four methods (`speak`, `stop`, `getVoices`, `setVoice`) plus the iOS audio category.

**Trigger:** it stops building against a Flutter release, or a regression ships and upstream is unresponsive for a few weeks.

**Procedure:**

1. `git clone` upstream at the **last-good tag** into `third_party/flutter_tts/`. Record the exact commit SHA.
2. Point the app at it: `flutter_tts: { path: third_party/flutter_tts }`. Path deps work for plugins with native code; `lib/` does not change at all — that is the payoff of the abstraction.
3. **Keep the LICENSE file.** MIT requires retaining the copyright notice and license text in the redistributed source. Confirm the license text as step one — you are reading the file anyway. <!-- VERIFY: read third_party/flutter_tts/LICENSE at vendor time and confirm MIT before redistributing -->
4. Write `third_party/flutter_tts/VENDORED.md`: upstream URL, vendored SHA, date, why, and every line you changed.
5. **Patch, don't refactor.** Every line you touch is a line you now maintain forever. Fix the break, ship, stop.
6. Re-run `docs/CHECKLIST.md` on a real device. No test in the suite can tell you the vendored copy still makes sound.

If upstream revives, diff your patch against it and go back. If it doesn't, you own ~4 methods over two platform APIs — which was always the real dependency.

---

## 9. Repo hygiene for an app meant to outlive its author

### LICENSE: Apache-2.0

The goal is that a stranger can fork this and ship it to Play under their own account after you stop. Apache-2.0 is permissive (no relicensing friction), carries an express patent grant, and — unlike MIT — has a **trademark clause**: the code transfers, the name and icon don't. That last part matters specifically here, because it stops a hostile fork from trading on the original's privacy reputation.

GPL-3.0 would obstruct exactly the succession you want: §6 anti-tivoization has well-known friction with app-store DRM and ToS, and the compliance burden deters the casual maintainer who is the whole point. MPL-2.0 is a coherent middle if keeping AAC-core improvements open matters more than adoption. **Ship Apache-2.0 + NOTICE**, and say in the README that the name and icon aren't covered. The no-telemetry promise is enforced by the code being readable, not by the license.

### README: what a stranger needs on day one

Four things, and only four:

1. **Run it.** Including — non-negotiably — *"on Linux, `sudo apt-get install libsqlite3-dev` before `flutter test`."* `flutter test` runs in a plain Dart VM where `sqlite3_flutter_libs` does nothing. A stranger who clones, runs the tests, sees the DB suite fail, and concludes the repo is broken is the exit plan dying to a missing README line.
2. **The four decisions that look like mistakes**, in four bullets, with pointers. A nullable FK inside a composite PK reads as a normalization error. `.playback` reads as an oversight. Checking a `setVoice` return reads as paranoia. Riverpod for 12 tiles reads as over-engineering.
3. **Non-goals.** No telemetry, no network permission, no accounts, no animation — framed as *refused*, not *un-built*, with the consequence stated: *nobody will ever learn this app crashed on a user's phone.*
4. **License**, and the name/icon carve-out.

### ADRs: skip the format, keep the reasoning

Not a `docs/adr/` directory of six numbered files with Status/Deciders/Context boilerplate. The failure mode being defended against is *a stranger "cleans up" `grid_slots` into an ordered list with an index and reintroduces tile reflow* — and **that person is standing in `tables.dart`, not in `docs/adr/0001-grid-slots.md`.** A doc comment is read at the moment of temptation. An ADR directory is read never.

So:

- **A doc comment at every point of temptation**, and those are enumerable: the `GridSlots` table, `label` vs `vocalization`, the audio session category, the `setVoice != 1` check, `speakNow`'s void return type, and the deliberate bare `catch (_)` in `CrashLog.record`. Six comments, ~six lines each, in the file where the bad idea occurs.
- **One flat `docs/DECISIONS.md`** for the part a comment can't hold: the *rejected alternatives*. "We considered an `order` column; here's the reflow it produces." That's the content with real value and no home in a header.

Two files of prose (`README.md`, `docs/CHECKLIST.md`) plus one of reasoning (`docs/DECISIONS.md`) for ~25 files of code. Nine documents would signal a project that is *about* documentation.

---

## 10. Skip list

Everything below was considered and refused. The reason column is the point.

| Skip | Because |
|---|---|
| melos, pub workspaces, local packages | One package, one dev. Melos is a multiplier with nothing to multiply; since v7 it mostly wraps pub workspaces anyway. |
| fastlane, `r0adkll/upload-google-play`, `release.yml` | ~6 uploads. Costs a keystore + service-account JSON in CI secrets. The one part a successor can't reuse. |
| Renovate, Dependabot | Dependabot has no pub support at all. Renovate raises PRs on a repo with no PR workflow. |
| `very_good_coverage`, coverage % gates, `tool/check_coverage.sh` | Archived; the number lies upward; the script is a day and is jointly unsatisfiable (§5). |
| Golden CI job, `update-goldens.yml`, alchemist | Platform-dependent pixels turn a stranger's `flutter test` red on Linux. Sabotages the exit plan. |
| Emulator / integration-test CI, Firebase Test Lab, Patrol | Cannot verify audio (§3). 15+ min and flaky for zero coverage of the top risk. |
| `--obfuscate`, `--split-debug-info` | Protects nothing once source is public; destroys the only field signal (§7). |
| R8 / `isMinifyEnabled` | A missing keep rule fails at **runtime** — a tile tap producing no speech — for a negligible size win on a 12-tile app. Set it to `false` **explicitly, with a comment**, so the next maintainer knows it was a decision. |
| Deferred components | Require Play Core + Play delivery — a network fetch. Contradicts the promise, breaks sideload/F-Droid. The whole Dart app is a few hundred KB. |
| Shader warmup, `--bundle-sksl-path` | Impeller precompiles shaders; the flags were removed. Zero animation regardless. Any blog recommending this is stale. |
| Pigeon | Officially right for *new* channels, but ~one method crosses Dart→native (Personal Voice). The QS tile and ControlWidget have no Dart at all. |
| `custom_lint` | `riverpod_lint` 3.x already runs on the first-party `analysis_server_plugin` system. The legacy system `custom_lint` uses is slated for deprecation as early as Dart 3.12 — adopting it buys a migration you'd have to undo. |
| DCM / `dart_code_metrics` | Dead as OSS; successor is commercial. A paid linter a stranger can't run is a liability for an open-source exit. |
| Pre-commit hooks (lefthook/husky) | The IDE already shows every promoted error as a red squiggle in real time. A hook adds latency and a `--no-verify` habit. |
| Conventional commits, semantic-release, commitlint | Pay off via changelog automation and multi-contributor triage. Neither exists pre-open-sourcing. Handwrite `CHANGELOG.md` — Play release notes need writing anyway. |
| Branch protection, PRs, CODEOWNERS, issue templates, Codecov | All coordinate multiple humans. ~1 hour each on the day you open-source; pure prepayment today. |

---

## The two things in this document that actually matter

1. **`build.yaml` + `make-migrations` + committed `drift_schemas/`, before there is user data.** Twenty minutes. Migration *tests* are a v2 problem — there are no migrations at `schemaVersion = 1` — but the schema dump is the one artifact you can never reconstruct after you bump the version, and the CI dump-diff catches the bug that loses every board without your writing a line of migration code.
2. **CI cannot verify speech, and no CI ever will.** Not a gap to close with more automation. Closed by `docs/CHECKLIST.md`, run on hardware with the ringer switch off, before every upload.
