---
name: reed-testing-strategy
description: Reed's testing doctrine — what gets tested and at what level, the ~135-test / under-30-second suite budget, and coverage floors on migrations, voice_filter.dart and board_repository.dart. Use when triaging what to test, choosing unit vs widget vs integration, proposing Patrol, glados, Firebase Test Lab or integration_test/ cases, running flutter test --coverage or lcov/dlcov, or arguing the test pyramid. Not for the contrast gate or the golden/screenshot refusal, and not for the on-device pre-release pass.
---

# Reed testing strategy

Reed ships with no Firebase, no Sentry, no Crashlytics, and no analytics — the privacy promise forbids it and this audience reads privacy labels adversarially. When Reed fails in the field, nobody finds out. A user in shutdown taps a tile, gets silence, and uninstalls. Tests are not a quality practice here; they are the only instrument.

That fact does NOT mean "write more tests." Reason from the paragraphs below before writing a single test file.

## 1. The correction that has to land first

The instinct is *"no crash reporting, so write more tests."* Half right. Acting on the wrong half eats the whole schedule.

**Tests and telemetry cover disjoint risk sets.**

| Channel | Covers |
|---|---|
| Tests | The risks someone thought of |
| Telemetry (deleted) | The risks nobody thought of — device diversity, OEM engine variants, the ~4% of users with no TTS engine installed |

More of the same tests cannot refill a deleted discovery channel. Only three things substitute:

1. **A-priori enumeration of the hostile environment.** Normally the happy path gets tested and crash reporting discovers the environment empirically. Here the enumeration must be written up front, and **the environment IS the test suite**: no engine installed, engine with zero voices, only `network_required` voices, `setVoice` returning 0, the stored voice garbage-collected by Android since last launch, audio focus denied, Bluetooth yanked mid-utterance. Enumerate first; the list is the spine, and the tests are its shadow.
2. **One technique that authors cases nobody wrote** — a seeded loop over the edit-op space (`for (int seed = 0; seed < 200; seed++)`, `Random(seed)`, 30 random `placeButton`/`clearSlot` ops, asserting no tile ever reflowed and `slots.length == 12`, with the accumulated op list printed in the `reason:`). Twenty lines of `package:test`. This is the actual thing crash reporting provided. Do not reach for a property-testing package to get it (see the skip table below).
3. **Making failure loud in-app, then testing the loudness.** If failure cannot be observed remotely, the user must observe it locally and hand over the log. A caught-and-swallowed error is the defining bug of this codebase.

### What this does NOT argue for

**More integration tests.** That instinct is wrong and expensive:

- Integration tests run on *one emulator* — a single configuration sampling **zero** device diversity. The variance they claim to cover is exactly the variance they do not have.
- **The Android emulator ships no TTS engine.** CI can never verify speech at all. An integration suite that cannot assert audio is not covering the risk class it appears to cover.

Budget **3** integration tests, not a suite. Anything a widget test can assert belongs in a widget test, where it runs in milliseconds and prints a readable failure.

## 2. Ignore the pyramid; follow the code shape

70/20/10 traces to a 2011 test-*size* heuristic whose own author said the numbers "essentially were pulled out of a hat," and it never described Flutter's unit/widget/integration taxonomy. Flutter's own documentation publishes no ratio and never mentions the pyramid. Citing it here is cargo cult.

Test shape follows **code** shape, and Reed's shape is unusual: twelve tiles and a text field contain almost no pure logic. The entire unit-testable surface is four files — the migrations, the voice filter, the board repository, the crash log. Everything else is UI, or a thin wrapper over a plugin whose channel is faked.

So the suite skews to widget tests not by preference but because that is where the code is. Do not "rebalance" it toward units. There are no units to write; manufacturing them means testing Riverpod, drift's generated CRUD, or flutter_tts — all third-party, all covered by their owners.

## 3. The target suite

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

Treat these as budgets, not floors. A proposal that pushes the speech suite to 90 tests is spending from a fixed account and must say what it bought.

**The 30 seconds is not vanity.** It is the number that decides whether a solo dev keeps running the suite. A suite that gets skipped is a suite that gets distrusted, and in a project with no telemetry a distrusted suite means *nothing at all* stands between users and silence. Any test that costs seconds — a real device, a sleep, a network wait, an unbounded `pumpAndSettle` — must justify itself against that budget or move to the manual pre-release pass.

## 4. Coverage

**No percentage gate.** The 100%-coverage rationale is confidence under change, and it is defensible for a consultancy — it removes subjective per-file arguments across a team. A solo dev collects none of that benefit and pays the full cost against a two-week budget. A gate one sets on oneself gets bypassed or gamed.

**Gate the four files where a bug is unrecoverable — files, not directories:**

| File | Floor | Why |
|---|---:|---|
| `lib/data/database/` migrations | 100% | A botched migration is the loss of someone's voice — months of hand-curated phrases, irreplaceable and unmergeable |
| `lib/speech/voice_filter.dart` | 100% | Pure Dart; four wire-format traps; a gap here is silence |
| `lib/data/repositories/board_repository.dart` | 100% | The no-reflow guarantee |
| `lib/diagnostics/crash_log.dart` | 100% | The only field signal that will ever exist |

Files, not directories, and the distinction is load-bearing: `lib/speech/` also holds the flutter_tts wrapper, which cannot reach 100% while method-channel mocking stays confined to a single channel-contract file. A directory floor there is jointly unsatisfiable with the channel rule; an explicit file list is not.

**If coverage gets reported at all, fix the lie first.** `flutter test --coverage` **omits files that no test imports** — a file with zero tests contributes zero lines to the *denominator* rather than counting as 0%. One well-tested file plus twenty untested ones can report ~100%. **The number lies upward**, which is the unsafe direction; a coverage number that overstates safety is worse than no number in a project with no other net. Fix it with `dlcov --include-untested-files=true`, or a generated `test/coverage_helper_test.dart` that imports every file under `lib/`.

Strip generated code, and check which extensions the drift setup actually emits:

```bash
lcov --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.drift.dart' \
  -o coverage/lcov.info \
  --ignore-errors unused   # lcov 2.x (ubuntu-24.04) errors on unused patterns
```

## 5. What is NOT worth testing

Every row is a "no" with its reason. Restate the reason when refusing; a "no" whose reason is unknown gets re-litigated next week.

| Skip | Why |
|---|---|
| **A golden regression suite** | Decided: no goldens. Everything a golden catches here — text not fitting, tiles reflowing — is caught more cheaply and with a *readable* failure message by the overflow matrix and by `getRect`/`getSize` invariants over all 12 tiles. Goldens add binary blobs to git, churn on every padding tweak, and decisively: a stranger running `flutter test` on Linux against macOS-generated goldens sees a wall of red and concludes the repo is broken. Goldens sabotage the open-source exit plan. |
| Golden *tooling* | `golden_toolkit` is discontinued (v0.15.0, ~3 years stale, no suggested replacement). `alchemist` (v0.14.0, alive) achieves CI stability by setting `obscureText: true` — it **replaces text with coloured rectangles**, discarding the exact signal this app needs. `flutter_test_goldens` is at 0.0.12 with 11 likes. There is no good option. |
| `glados` / property-testing packages | v1.1.7, ~2 years stale. A stale dependency is a liability for a repo whose exit plan is a stranger picking it up. The seeded loop described above is 20 lines and gets the 80%; the printed op list **is** the minimal repro that shrinking would have produced. |
| Riverpod plumbing | Not load-bearing. Testing providers tests the framework. |
| drift's generated CRUD | Third party. |
| flutter_tts itself | Test the `voice_filter`, not the plugin. |
| Patrol / Appium / any E2E | No accounts, no network, one screen, no runtime permission prompts. Patrol exists to tap native permission dialogs that do not exist here. |
| Firebase Test Lab / device farms | Farm devices run the same TTS-poor images and cannot assert audio. One real phone strictly dominates. |
| CI accessibility automation | The semantics tree is not exposed during `flutter drive` without a pre-enabled accessibility service. Days of work, near-zero signal. |
| A coverage percentage gate | See the coverage section above. |
| Theme/settings UI beyond persist-and-reload | Triviality. |
| DevTools rebuild profiling, frame charts, `RepaintBoundary` | Every one is a **jank** remedy. A static 12-tile grid with zero animation renders one frame and stops. There is no frame budget to miss. This is the single largest category of wasted time available to this project. |

## 6. Highest value, most over-rated

**Highest value: `test/speech/silence_is_impossible_test.dart`.** A parameterized loop over every detectable speech environment, asserting that a tile tap yields speech **OR** the phrase visibly on screen — never neither. It is the only test in the suite that is *unsatisfiable by a code path that fails silently*, and it is the closest thing to telemetry this app will ever have. Protect it. Never let it be softened into "assert speak was called."

**Runner-up, and it is not a test:** the pre-migration file backup — copy the `.sqlite` file to `board_backup_v{oldVersion}.sqlite` immediately before `onUpgrade` runs, keep the last two, expose "Restore previous board" in settings. Fifteen lines; the highest safety-per-line item in the project. Migration tests protect against enumerated bugs; the backup protects against the migration bug nobody enumerated — with no telemetry, the entire invisible category. Complements, not substitutes. Then test the backup itself: backup happens strictly before `onUpgrade`; last-two retention; restore round-trip; restore when the live DB is corrupt.

**Most over-rated: `meetsGuideline` as an accessibility gate.** Four green `expectLater`s that skip 10 of the 12 tiles, false-pass white-on-`#fafafa`, and accept a tile labelled `button1` — while producing a strong feeling that accessibility is tested. Keep them; do not trust them. The real gates are `getSize` over all 12 tiles, per-tile `isSemantics` label assertions, a pure-Dart contrast unit test, and the manual pass on a physical device with TalkBack and Switch Access.

**Runner-up over-rated:** a coverage percentage gate. The number lies upward.

## 7. When refusing a test, say what replaces it

Never answer "not worth testing" and stop. Every refusal above hands the risk to something else: to the overflow matrix, to a policy grep over source, to the pre-migration backup, to the physical-device checklist. Name the replacement. An unowned risk in this app is a person who taps a tile mid-shutdown and gets nothing.
