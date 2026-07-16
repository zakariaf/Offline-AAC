# The test suite — doctrine

Reed ships with **no Crashlytics, no Sentry, no analytics, no network**. When a
tile fails to speak on someone's phone mid-shutdown, nobody finds out — the
user cannot file a bug, because being unable to speak is the condition the app
exists to serve. The analyzer and this suite are the **only two feedback loops
that will ever exist**. Everything below follows from that.

## Two numbers that matter

1. **The suite runs in under 30 seconds.** This is the load-bearing constraint.
   A suite that takes long enough to skip is a suite that gets skipped, and a
   skipped suite is a distrusted suite — and a distrusted suite means nothing
   at all stands between users and silence.
2. **Coverage is honest, not flattering.** `flutter test --coverage` omits
   every file no test imports, so untested files vanish from the denominator
   and the number lies *upward* — the unsafe direction. `tool/coverage.sh`
   fixes that (see below) before any number is quoted.

## Runtime — measured, not aspirational

Measured on the dev laptop (Apple Silicon, Flutter 3.44.6 / Dart 3.12.2),
`flutter test --test-randomize-ordering-seed random`:

| Run | Seed | Wall clock | Result |
|---|---|---:|---|
| 1 | random | **13.19 s** | 498 pass, 1 skipped |
| 2 | random | **13.02 s** | 498 pass, 1 skipped |

**~13 s against a 30 s budget.** Randomized ordering is kept on deliberately:
much of the suite shares one in-memory drift database, and a random seed is
what surfaces inter-test state leakage that a fixed order would mask. If the
suite ever crosses 30 s, run `flutter test --reporter expanded` to find the
offender — a real-device dependency, a `sleep`, a network wait, an unbounded
`pumpAndSettle` — and fix or relocate it. **Do not raise the budget.** The 30 s
is not vanity; it is the number that decides whether a solo dev keeps running
the suite at all.

## The budget — targets, not floors

These were the original per-suite budgets. They are **budgets, not floors**: a
proposal that pushes the speech suite to 90 tests is spending from a fixed
account and must say what it bought.

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

**The shipped suite has grown well past ~135.** Through E06–E09 it is now
roughly **500 tests** (measured: 498 passing + 1 skipped, across 55 test
files). That growth is fine: **the load-bearing constraint was never the test
count — it is the 30-second wall clock**, and that still holds with headroom
(~13 s). The per-suite rows above remain the sizing intuition for *new* work;
the 30 s is the hard line.

## The floor: four files, not a percentage

**There is no percentage gate — not here, not in CI, deliberately.** The
100%-coverage rationale is confidence under change and removing subjective
per-file arguments across a *team*. A solo dev on a two-week budget collects
none of that benefit and pays the full cost. A gate one sets on oneself gets
bypassed or gamed the first Friday it goes red. So the floor is held **by
reading the diff**, not by an `awk` line-counter enforcing a metric already
known to be wrong.

Four **files** are held at 100%, because a bug in each is unrecoverable:

| File | Why it is unrecoverable |
|---|---|
| `lib/data/database/` migrations (`app_database.steps.dart`, `schema_versions.dart`, `backup.dart`) | A botched migration is the loss of someone's voice — months of hand-curated phrases, irreplaceable and unmergeable. |
| `lib/data/speech/voice_filter.dart` | Pure Dart with four wire-format traps; a gap here is silence. |
| `lib/data/board_repository.dart` | The no-reflow guarantee — the board must never reshuffle under a user who navigates by muscle memory. |
| `lib/diagnostics/crash_log.dart` | The only field signal that will ever exist; if it is wrong, the app is truly blind. |

**These are files, and the distinction is load-bearing.** A directory floor on
`lib/data/speech/` would be **unsatisfiable**: that same directory holds the
flutter_tts wrapper (`flutter_tts_speech_service.dart`), which cannot reach
100% while method-channel mocking stays confined to a single channel-contract
file. A directory floor is jointly unsatisfiable with the channel rule; an
explicit list of four file paths is not.

## Running coverage

```bash
tool/coverage.sh
```

It (1) generates `test/coverage_helper_test.dart`, which imports every
non-generated library under `lib/` so untested files re-enter the denominator;
(2) runs `flutter test --coverage`; and (3) strips generated code
(`*.g.dart`, `*.drift.dart`, `generated_plugin_registrant.dart`) from
`coverage/lcov.info`, using `lcov --remove` where lcov is installed and an
`awk` fallback where it is not (a stock macOS box has no lcov). Those strip
patterns **mirror the `analyzer.exclude` block in `analysis_options.yaml`** —
keep the two in sync, or generated code is linted-out but coverage-in and the
number stops meaning anything.

`coverage/` is git-ignored. `test/coverage_helper_test.dart` is **generated**
and must be regenerated (re-run the script) whenever a file is added to or
removed from `lib/`, or new files quietly fall out of the denominator and the
lie returns by attrition.

## What no test and no lint can prove

A green analyzer is not proof a tile speaks; neither is 100% on four files. The
highest-severity failures — an audio session muted by the hardware silent
switch, an engine reporting success while emitting no audio — are invisible to
every widget test and every lint. **The manual on-device pre-release pass
remains the real check.** Coverage is a local report the dev reads, not a build
status and not a safety guarantee.
