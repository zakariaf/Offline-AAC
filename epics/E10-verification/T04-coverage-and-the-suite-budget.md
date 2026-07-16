# E10-T04 — Coverage and the suite budget

| | |
|---|---|
| **Epic** | E10 — Verification |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E05-T07 |
| **Blocks** | Nothing |

**Skills:** `reed-testing-strategy` · `reed-ci-workflow` · `reed-lint-config`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Reed has no Crashlytics, no Sentry, no analytics, no network. When a tile fails to speak on someone's phone mid-shutdown, nobody finds out — the user cannot file a bug, because being unable to speak is the condition the app exists to serve. The analyzer and the test suite are the only two feedback loops that will ever exist. This task makes the coverage number honest instead of flattering, and holds the suite under 30 seconds — the number that decides whether a solo dev keeps running it at all. A suite that gets skipped is a suite that gets distrusted, and a distrusted suite means nothing at all stands between users and silence.

## Scope

Three deliverables: a coverage script that does not lie, a documented file-level floor, and a runtime measurement of the suite against its budget.

### 1. The coverage script (`tool/coverage.sh`)

`flutter test --coverage` **omits files that no test imports**. An untested file contributes zero lines to the *denominator* rather than counting as 0%. One well-tested file plus twenty untested ones can report ~100%. **The number lies upward** — the unsafe direction. A coverage number that overstates safety is worse than no number in a project with no other net. Fix the lie before quoting any number.

Two acceptable fixes; pick one and stay with it:

- `dlcov --include-untested-files=true`, or
- a generated `test/coverage_helper_test.dart` that imports every file under `lib/`.

Then strip generated code, mirroring the excludes already in `analysis_options.yaml` (`**/*.g.dart`, `**/*.drift.dart`, `**/generated_plugin_registrant.dart`, `test/.test_coverage.dart`, `test/drift/generated/**`). Generated files otherwise dilute the number until it means nothing:

```bash
lcov --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.drift.dart' \
  -o coverage/lcov.info \
  --ignore-errors unused   # lcov 2.x (ubuntu-24.04) errors on unused patterns
```

**Check which suffix the drift setup actually emits** — `.drift.dart` (modern) vs `.g.dart` (legacy part-file) — before committing either pattern. Do not guess.

### 2. The floor: four files, not a percentage

**No percentage gate.** The 100%-coverage rationale is confidence under change and removing subjective per-file arguments across a team. A solo dev collects none of that benefit and pays the full cost against a two-week budget. A gate one sets on oneself gets bypassed or gamed.

Instead, hold four **files** at 100%, because a bug in each is unrecoverable:

| File | Floor | Why |
|---|---:|---|
| `lib/data/database/` migrations | 100% | A botched migration is the loss of someone's voice — months of hand-curated phrases, irreplaceable and unmergeable |
| `lib/speech/voice_filter.dart` | 100% | Pure Dart; four wire-format traps; a gap here is silence |
| `lib/data/repositories/board_repository.dart` | 100% | The no-reflow guarantee |
| `lib/diagnostics/crash_log.dart` | 100% | The only field signal that will ever exist |

**Files, not directories, and the distinction is load-bearing.** `lib/speech/` also holds the flutter_tts wrapper, which cannot reach 100% while method-channel mocking stays confined to a single channel-contract file. A directory floor on `lib/speech/` is jointly unsatisfiable with the channel rule; an explicit file list is not.

Hold these four **by reading the diff**, not by adding sixty lines of `awk` that count lines for a metric already known to be wrong.

### 3. The suite budget

Record the target in `test/README.md` (or wherever the suite doctrine lives in this repo) as budgets, not floors:

| Suite | Tests |
|---|---:|
| Speech (`voice_filter`, `SpeechService`, the silence loop) | ~35 |
| Database (invariants, migrations, backup) | ~25 |
| Widget (board, overflow matrix, a11y) | ~60 |
| Crash log | 8 |
| Policy (source greps) | 4 |
| Channel contract | 4 |
| Integration (real device) | 3 — not in `flutter test` |
| **Total** | **~135, under 30 s** |

A proposal that pushes the speech suite to 90 tests is spending from a fixed account and must say what it bought. Any test that costs seconds — a real device, a sleep, a network wait, an unbounded `pumpAndSettle` — must justify itself against that budget or move to the manual pre-release pass.

Measure it: time `flutter test --test-randomize-ordering-seed random --reporter expanded` on the dev laptop and write the number down. If it is over 30 s, find the offenders (`--reporter expanded` prints per-test timing) and fix or relocate them rather than raising the budget.

### Explicitly out of scope

- **A coverage percentage gate in CI.** No Codecov, no `VeryGoodOpenSource/very_good_coverage` (archived 2026-03-31, read-only, still the top recommendation in most Flutter CI tutorials), no threshold step. CI measures nothing here — coverage is a local report the dev reads, not a build status.
- Adding a coverage job to `.github/workflows/ci.yml`. The workflow's job list stays as-is.
- Writing new tests to raise the number. If the honest number embarrasses a file, that is E10 triage, not this task.
- Golden tests, emulator/`integration_test` CI, Firebase Test Lab, Patrol — all refused elsewhere for reasons that do not change here.

## Acceptance criteria

- [ ] `tool/coverage.sh` exists, is executable, and runs end-to-end producing `coverage/lcov.info`.
- [ ] The script includes untested files in the denominator — via `dlcov --include-untested-files=true` or a generated `test/coverage_helper_test.dart`. Verify: add a temporary `lib/` file with a function and no test, re-run, and confirm it appears in `lcov.info` with 0-hit lines. Delete the temporary file afterward.
- [ ] `grep -c 'SF:.*\.g\.dart' coverage/lcov.info` and `grep -c 'SF:.*\.drift\.dart' coverage/lcov.info` both return 0 after the script runs.
- [ ] The `lcov --remove` patterns match the suffix drift actually emits in this repo — confirmed by `ls lib/data/database/`, not by assumption.
- [ ] The four 100% files are listed by path in the suite doc, with the reason each is unrecoverable, and with the explicit note that they are files and not directories.
- [ ] No percentage threshold anywhere: `grep -rE 'very_good_coverage|codecov|min_coverage|--min-coverage' .github/ tool/` returns nothing.
- [ ] `.github/workflows/ci.yml` gained no coverage step — `git diff` on that file for this task is empty.
- [ ] The measured wall-clock runtime of `flutter test --test-randomize-ordering-seed random` is recorded, and is under 30 s.
- [ ] `grep -rn 'pumpAndSettle' test/` returns nothing (the existing policy grep already asserts this; the coverage work must not introduce one).
- [ ] `dart format --output=none --set-exit-if-changed .` and `flutter analyze --fatal-infos` both pass.

## Traps

- **Quoting the raw `flutter test --coverage` number.** It omits files no test imports, so it lies *upward*. Publishing 94% when the true figure is 61% is not an inaccuracy, it is a false safety signal in a project whose only other signal is the analyzer. Fix the denominator before the number is ever spoken aloud.
- **Guessing the drift suffix.** `lib/**/*.drift.dart` and `lib/**/*.g.dart` are not interchangeable; the config decides which is emitted. Strip the wrong one and generated code silently pads the numerator forever. Check the directory listing.
- **lcov 2.x erroring on unused patterns.** `ubuntu-24.04` ships lcov 2.x, which fails the whole command when a `--remove` pattern matches nothing. `--ignore-errors unused` is required, not optional garnish.
- **Reaching for a directory floor on `lib/speech/`.** It is jointly unsatisfiable: the same directory holds the flutter_tts wrapper, only reachable through channel mocks confined to one channel-contract file. The floor is a list of four file paths.
- **Building an `awk` coverage enforcer.** Sixty lines that count lines for a metric already known to be wrong, that a solo dev will bypass the first time it goes red on a Friday. A gate one sets on oneself gets gamed. Read the diff instead.
- **Letting the excludes drift apart.** `analysis_options.yaml`'s `exclude:` block and the `lcov --remove` patterns must stay mirrored. When they diverge, generated code is linted-out but coverage-in (or the reverse), and the number stops meaning anything.
- **Touching `test/drift/generated/**`.** Those are drift's exported schema snapshots — historical artifacts, the baseline the migration tests compare against. A reformat or an autofix while "tidying up coverage tooling" corrupts the baseline. Never reformat, never fix, never regenerate an old snapshot. Add new ones only.
- **Raising the budget instead of fixing the test.** The 30 seconds is not vanity. When the suite hits 34 s the instinct is to write "under 40 s"; the correct move is to find the sleep, the real-device dependency, or the unbounded `pumpAndSettle` that bought those seconds and ask what it covers that a widget test does not.
- **`--test-randomize-ordering-seed random` exposing what the timing hid.** Much of the suite shares one in-memory drift database. A coverage helper that imports every file under `lib/` changes what gets constructed at load, and can surface inter-test state leakage that ordering previously masked. That is the flag doing its job — fix the leak, do not drop the flag.
- **Treating the coverage helper as dead code.** `test/coverage_helper_test.dart` is generated and must be regenerated when files are added to `lib/`, or new files quietly fall out of the denominator again and the lie returns by attrition. If that maintenance burden is unacceptable, use `dlcov` instead.
- **Reporting the number as evidence.** A green analyzer is not proof a tile speaks; neither is 100% on four files. The highest-severity failures — an audio session muted by the silent switch, an engine reporting success while emitting no audio — are invisible to every test and every lint. The manual on-device pass remains the check.

## Files

- `tool/coverage.sh` — created.
- `test/coverage_helper_test.dart` — created (generated) if the helper approach is chosen over `dlcov`.
- `pubspec.yaml` — `dev_dependencies` gains `dlcov` if that approach is chosen.
- `test/README.md` — created or updated: the ~135 / under-30 s table, the four 100% files, the explicit no-percentage-gate reasoning.
- `.gitignore` — ensure `coverage/` is ignored.
- `.github/workflows/ci.yml` — **unchanged**, deliberately.

## Done when

`tool/coverage.sh` produces an `lcov.info` with every `lib/` file in the denominator and zero generated files in it, the four unrecoverable files are named as a file-level floor with no percentage gate anywhere in the repo, and the measured `flutter test` runtime is written down and under 30 seconds.
