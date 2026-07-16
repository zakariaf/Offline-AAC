# E10 — Verification

> The suite that stands in for telemetry, and a written account of the four failures it will never reach.

| | |
|---|---|
| **Status** | Done |
| **Tasks** | 5 |
| **Depends on** | E04 (speech), E05 (speak screen), E06 (show mode) |

## Why this epic exists

Reed ships with no Firebase, no Sentry, no Crashlytics, no analytics. That is not an oversight to be corrected later — it is the promise, and this audience reads privacy labels adversarially. The consequence is exact: when Reed breaks in the field, nobody finds out. A user in shutdown taps a tile, hears nothing, and uninstalls. There is no bug report, because a user who cannot speak does not file one.

So the suite is not a quality practice. It is the only instrument that exists, and it has two jobs that are usually one. First, catch the enumerated failures — the 28 ways a tap produces silence, the label/vocalization inversion, the clipped tile at 200%. Second, and harder: **state honestly what it cannot catch**, because the gap is where the top-severity bugs live. `.ambient` muting the app on the hardware silent switch, the engine returning success with no audio leaving the speaker, a Quick Settings tile speaking a phrase deleted months ago, a Switch Access focus trap in edit mode — every one is unreachable by every automated means anyone could build, and every one ends with a person mid-shutdown getting nothing.

The failure mode of this epic is not "too few tests". It is a green suite that feels like coverage. Four `meetsGuideline` calls pass while skipping 10 of 12 tiles and accepting a tile labelled `button1`. A coverage number reports ~100% because untested files were omitted from the denominator. An overflow matrix looping scales inside one `testWidgets` under-reports every scale after the first. Each of those ships an inaccessible accessibility app with a green badge on it.

## What "done" means

- `flutter test` passes, runs in **under 30 seconds**, and totals roughly **135 tests** across the whole repo.
- `test/ui/a11y_test.dart` exists and its gates are the explicit ones: a `getSize` loop over all 12 tiles at `TextScaler.linear(2.0)` on `Device.seLike`, a per-tile `isSemantics` assertion that the label is the display label and does not contain the vocalization, a `simulatedAccessibilityTraversal` order assertion, and the anti-clamp check. `meetsGuideline` appears only under a test named advisory.
- `test/ui/contrast_test.dart` asserts contrast ratios on **colour values** from `kAllThemes`, not on rendered pixels.
- The overflow matrix generates one `testWidgets` per `(device, scale, bold)` tuple — 3 × 5 × 2 = 30 for the board, plus separate pumped runs for show mode, edit mode, and the type-to-speak field.
- `CHECKLIST.md` is tracked in the repo, ordered audio → screen reader → switch → scaling → native → data → crash log, and has been run to completion on a physical budget Android phone with the ringer off against a release build.
- `bash .claude/skills/auditing-reed-visuals/scripts/audit-visuals.sh` exits 0, and every judged tell — radius-to-size, gutter inequality, colour harmony, copy register — has a written verdict.
- Coverage is *reported*, not gated, with the denominator lie fixed. The four unrecoverable files sit at 100% by diff review.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E10-T01 | The accessibility test suite | M | E05-T07 |
| E10-T02 | The text-scale matrix | S | E05-T07 |
| E10-T03 | The manual device checklist | S | E04-T04 |
| E10-T04 | Coverage and the suite budget | S | E05-T07 |
| E10-T05 | The dated-design audit | XS | E05-T01, E06-T02 |

**E10-T01 — The accessibility test suite** is the epic's centre of gravity, because accessibility here is correctness and no lint enforces one line of it: `flutter_lints` and `very_good_analysis` ship zero a11y rules and `accessibility_lint` is abandoned. The task's real work is refusing the easy version. Flutter ships four guidelines; one silently skips every node flush with the view edge, one false-passes white on `#fafafa`, one accepts any non-empty label. T01 keeps all four as one-line tripwires and builds the actual gates beside them — geometry measured by hand, labels asserted per tile, traversal pinned to priority so the lower-centre arc does not cost a TalkBack user 8–11 scan steps to reach "I need to leave".

**E10-T02 — The text-scale matrix** covers the axis where the target audience lives. Users at 200%+ are not an edge case, and a clipped label is this product failing the exact person it exists for. The task inverts the usual instinct: `RenderFlex` overflow already fails a widget test, so the work is never losing that net, and the whole popular genre of suppression helpers is banned. The silent class — a clipped `Text` inside a fixed box, which reports nothing ever — is why the fit assertion, not `takeException`, is the gate.

**E10-T03 — The manual device checklist** is where this epic gets honest. It is not a chore and not a placeholder for tests not yet written; it is the deliberate replacement for tests that cannot exist. The emulator ships no TTS engine and no API on either platform captures synthesized PCM, so "audio came out" is unassertable forever. T03 turns that into a tracked artifact with a hardware spec (physical, cheap, ringer off, release build) and an order chosen because sections 5–7 are destructive.

**E10-T04 — Coverage and the suite budget** exists to stop two specific lies. The coverage number lies **upward** — untested files are omitted from the denominator rather than counted as 0% — and an overstated safety number is worse than none where there is no other net. And the 30-second budget is not vanity: it decides whether a solo dev keeps running the suite at all. T04 sets no percentage gate, fixes the denominator, and holds four *files* at 100% by reading the diff.

**E10-T05 — The dated-design audit** is the smallest task and the only one that ends in judgment. The script greps what greps — radius under 16dp on large elements, any `elevation:`/`BoxShadow`/`Card`, the M2 500-series hexes, pure `#FFFFFF`/`#000000`, `Border.all()`, `BackdropFilter`. Then a human checks what no script can: gutter inequality (14dp column, 22dp row, 24dp margin), whether the four stocks still read as woven cloth, the 1:9.3 type spread, and copy register. A clean script run is never "the screen passes the audit" — it passed the greppable half.

## Skills this epic draws on

**Accessibility**
- `reed-a11y-testing` — the four guidelines and their three defects, `isSemantics` over the deprecated `containsSemantics`, `startNode:`/`endNode:`, `await expectLater` on `meetsGuideline`, the 76×76 `getSize` loop.
- `reed-a11y-coding` — the authoring side T01 asserts against: `Semantics(button: true)`, display label never vocalization, `OrdinalSortKey` from priority.

**Scale and layout**
- `reed-text-scale-testing` — the device × scale × bold matrix, the loud/silent overflow split, the four banned fixes for a red matrix.
- `reed-widget-test-harness` — `pumpApp`, the `Device` presets and their DPR multiplication, `pump()` never `pumpAndSettle`, `find.byKey` for geometry / `find.bySemanticsLabel` for behaviour.
- `reed-typography` — the five fixed roles and the one variable face the matrix is measuring.

**Budget and enforcement**
- `reed-testing-strategy` — the ~135-test / under-30s budget, the per-suite allocation, the four 100% files, the skip table and its reasons.
- `reed-ci-workflow` — what CI runs, the schema-dump and build_runner freshness gates, and the standing refusal of emulator, golden, and Codecov jobs.
- `reed-lint-config` — `--fatal-infos`, and which rules are promoted to error so the analyzer stays the second feedback loop.

**The manual gap**
- `reed-manual-checklist` — the hardware, the section order, and what each check actually catches.
- `diagnosing-tile-silence` — the 28-way enumeration and its D/I/M/X tags; the tags decide which task owns which failure.
- `reed-speech-service` — the wire traps the checklist probes by ear: `setVoice` returning 0, `notInstalled` returning 1, tab-separated features, the string `"1"`.

**Visual**
- `auditing-reed-visuals` — the 20 tells, the script, and the line between mechanical and judged.
- `reed-colour-system` — the role hexes and the two-tier contrast floor the pure-Dart ratio test asserts against.
- `reed-motion-policy` — zero motion, which is why `hasScheduledFrame` is assertable and `pumpAndSettle` is banned.

## Sequencing

T01, T02 and T04 all wait on **E05-T07** and on nothing else, so they can run in parallel once the speak screen is complete. They share one hard constraint: all three read `test/support/harness.dart`. Whoever starts first owns it, and the other two must not fork a second `pumpApp`.

T03 waits on **E04-T04** — the speech path has to exist before there is anything to hear — and is otherwise independent of the widget suite. It blocks **E11-T04**, and that edge is the real one: a tag cannot happen until a fresh copy of the checklist has been ticked off on hardware.

T05 waits on **E05-T01** and **E06-T02**, since the audit needs the tile and the show-mode poster to look at. It also blocks **E11-T04**. It is XS and can be done in an afternoon, but do not batch it with the tag — a judged tell that turns up a defect needs time to fix.

There is no chain inside this epic. The parallelism is genuine, and the two release-blocking edges (T03, T05 → E11-T04) are the only sequencing that matters.

## Risks specific to this epic

- **The advisory tests get promoted to gates.** Four green `expectLater`s produce a strong feeling that accessibility is tested. Someone deletes the `getSize` loop as redundant. Ten of twelve tiles go unmeasured and nothing goes red.
- **A `takeException()` lands in a global `tearDown`.** It clears `_pendingExceptionDetails` before `testWidgets` rethrows, converting the entire overflow matrix into a no-op with no failing test to show for it.
- **A red matrix gets fixed with a clamp.** `withClampedTextScaling` at 2am turns the matrix green, overrides the user's own OS setting, and leaves contrast and tap-target passing. The policy grep over `lib/` is the only thing that catches it.
- **A loop inside one `testWidgets`.** Overflow reports once per `RenderObject`; `_overflowReportNeeded` resets only on `reassemble()`. Scales 2..n are silently unchecked and the test count still looks right.
- **The device surface is left at 800×600.** Wider than any phone. Tiles come out ~2× too wide, everything fits, the suite is green, and the shipped 360dp phone is broken.
- **The coverage number gets quoted.** With untested files omitted from the denominator, one well-tested file plus twenty untested ones reports ~100%. Somebody puts that in a README.
- **The checklist gets run from memory.** "Basically did this last time" is how `.ambient` ships. Ticking a fresh copy per tag is the whole mechanism.
- **The suite creeps past 30 seconds.** A slow suite gets skipped, a skipped suite gets distrusted, and a distrusted suite means literally nothing stands between users and silence.
- **The script's clean exit gets reported as a pass.** Radius from a token does not grep. A 105dp tile at radius 12 passes the script and reads 2014.

## Out of scope

- **Writing the app's tests.** Each epic tests its own code — the speech suite lives in E04, the migration tests in E03, the show-mode and edit-mode tests with their screens. E10 owns the cross-cutting suites (a11y, scale matrix), the budget, and the honest account of the gap.
- **The CI workflow file.** `.github/workflows/ci.yml`, the schema-dump gate and the build_runner freshness gate belong to E01. T04 spends against the budget CI enforces; it does not edit the YAML.
- **Goldens.** Decided, repeatedly, and not reopened here: no golden suite, no `update-goldens.yml`, no `alchemist`. Everything a golden catches is caught by the overflow matrix and the `getRect` invariants, with a readable failure and no binary blobs — and a stranger cloning on Linux against macOS goldens sees red and walks away.
- **Emulator, `integration_test`, Firebase Test Lab, Patrol.** Three integration tests exist and they live with the Quick Settings work in E09. Device farms run the same TTS-poor images and cannot assert audio; one real phone strictly dominates.
- **The release tag itself.** E11 owns tagging. E10 hands it two blocking artifacts: a ticked checklist and a resolved audit.
