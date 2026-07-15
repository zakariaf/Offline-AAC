# Epics

The build order for Reed, from the decision to build it at all through shipping it to twenty people.

Each epic is a directory: `EPIC.md` explains it; `T##-*.md` are its tasks. Every task names the
skills that govern it — read those first, they carry the exact values.

| | |
|---|---|
| **Epics** | 12 |
| **Tasks** | 60 |
| **Rough size** | ~93 day-units, ignoring parallelism |

**Size buckets:** `XS` <1h · `S` <1d · `M` 2–4d · `L` >4d. Sizes are the only estimate in this plan,
and they are buckets on purpose — a solo developer's calendar is not a resource plan.

### This plan is about seven times bigger than "a two-week MVP", and that is the honest number

The build surface (E01–E09) is **71 day-units — about fourteen weeks solo.** The feature list it came
from was called a two-week MVP. Both cannot be true. The gap is not padding; it is the difference
between counting **features** and counting **work**:

- The two-week figure counts ~18 feature rows, several of them free or trivial.
- This plan counts what the same quality bar demands around those features: a ~135-test suite, a
  migration proof that rows survive, an accessibility suite, a contrast gate, policy tests, CI, and
  a design system built before the first screen.

Those are not gold-plating. They are the direct consequence of having no telemetry: the tests are
the only feedback loop, so they are the product's nervous system rather than its polish. A
two-week version of this app exists — it is the one that ships without them, and nobody ever finds
out it broke.

Three honest ways to react, in order of preference:

1. **Cut scope, not rigor.** E06–E08 are ~15d and none is required to prove the core. A grid that
   speaks, with tests, is the thing worth putting in front of twenty people.
2. **Accept fourteen weeks** and stop calling it a two-week MVP anywhere.
3. **Cut the rigor** — and then say out loud that this is app #N of a challenge, not a disability
   accommodation someone will depend on in an emergency room.

Do not resolve it by quietly believing the two-week number.

## The arc

```
E00  de-risking        ← a GATE. Three tasks here can kill the project.
  │
  ├─ E01  foundation ──┬─ E02  design system
  │                    ├─ E03  data layer
  │                    └─ E04  speech  ← the product IS this epic
  │                          │
  │                          └─ E05  speak screen ─┬─ E06  show mode
  │                                                ├─ E07  edit mode
  │                                                └─ E08  settings
  │                                                      │
  └──────────────────── E09  portability ─ E10  verification ─ E11  release
```

## Epics

| Epic | Tasks | Size | What it delivers |
|---|---:|---:|---|
| [E00 — De-risking](E00-de-risking/EPIC.md) | 7 | 10d | Decide build / no-build / pivot before writing shippable code |
| [E01 — Foundation](E01-foundation/EPIC.md) | 6 | 8d | The guardrails that replace telemetry: analyzer, codegen, CI, policy tests |
| [E02 — Design system in code](E02-design-system/EPIC.md) | 4 | 6d | Four palettes and a type scale, with a CI gate proving they are legible |
| [E03 — Data layer](E03-data-layer/EPIC.md) | 6 | 12d | A schema where reflow is unrepresentable, and a migration suite that proves phrases survive |
| [E04 — Speech](E04-speech/EPIC.md) | 6 | 12d | A speak path where no failure mode is silence |
| [E05 — The speak screen](E05-speak-screen/EPIC.md) | 8 | 14d | The one screen: a fixed grid, a type field, instant feedback, no STOP button |
| [E06 — Show mode](E06-show-mode/EPIC.md) | 3 | 5d | A poster a stranger can read at arm's length in daylight |
| [E07 — Edit mode](E07-edit-mode/EPIC.md) | 4 | 4d | The smallest editor that works |
| [E08 — Settings](E08-settings/EPIC.md) | 4 | 6d | Voice, output mode, and theme — never a tree to navigate in overload |
| [E09 — Portability and the crash log](E09-portability/EPIC.md) | 3 | 5d | The board survives a new phone; the only field signal that exists works |
| [E10 — Verification](E10-verification/EPIC.md) | 5 | 6d | The suite that substitutes for telemetry, and an honest account of its limits |
| [E11 — Release](E11-release/EPIC.md) | 4 | 6d | Into the hands of the twenty people from E00 — not the store |

## All tasks

| Task | Size | Depends on | Skills |
|---|---|---|---|
| [E00-T01](E00-de-risking/T01-use-the-incumbents-for-90-minutes.md) — Use the incumbents for 90 minutes | S | Nothing | `reed-aac-audience` · `reed-store-and-legal` |
| [E00-T02](E00-de-risking/T02-ask-twenty-people-three-questions.md) — Ask twenty people three questions | M | E00-T01 | `reed-aac-audience` · `reed-vocabulary-rules` · `reed-copy-voice` |
| [E00-T03](E00-de-risking/T03-tts-quality-probe-on-a-cheap-android.md) — TTS quality probe on a cheap Android | M | E00-T02 | `reed-speech-service` · `reed-speech-testing` · `reed-dependency-hygiene` |
| [E00-T04](E00-de-risking/T04-latency-probe-time-to-first-word.md) — Latency probe: time to first word | S | E00-T03 | `reed-speech-service` · `reed-app-startup` |
| [E00-T05](E00-de-risking/T05-airplane-mode-probe.md) — Airplane-mode probe | XS | E00-T03 | `reed-speech-service` · `reed-privacy-claims` |
| [E00-T06](E00-de-risking/T06-switch-control-and-screen-reader-spike.md) — Switch Control and screen reader spike | S | Nothing | `reed-a11y-coding` · `reed-a11y-testing` · `reed-manual-checklist` · `reed-tile-anatomy` |
| [E00-T07](E00-de-risking/T07-positionality-and-contact-the-aac-user-developer.md) — Positionality, and contact the AAC-user developer | XS | Nothing | `reed-aac-audience` · `reed-copy-voice` · `reed-store-and-legal` |
| [E01-T01](E01-foundation/T01-scaffold-the-project-tree.md) — Scaffold the project tree | S | E00-T03 | `reed-project-structure` · `reed-layering-rules` · `reed-dependency-hygiene` · `reed-code-bans` |
| [E01-T02](E01-foundation/T02-analyzer-and-lint-configuration.md) — Analyzer and lint configuration | S | E01-T01 | `reed-lint-config` · `reed-code-bans` · `reed-no-silent-failures` |
| [E01-T03](E01-foundation/T03-codegen-pipeline.md) — Codegen pipeline | S | E01-T01 | `reed-codegen-workflow` · `reed-drift-schema` |
| [E01-T04](E01-foundation/T04-ci-workflow.md) — CI workflow | M | E01-T02 | `reed-ci-workflow` · `reed-testing-strategy` · `reed-policy-tests` |
| [E01-T05](E01-foundation/T05-policy-tests.md) — Policy tests | S | E01-T02 | `reed-policy-tests` · `reed-code-bans` · `reed-speech-service` |
| [E01-T06](E01-foundation/T06-cold-launch-sequence-in-main.md) — Cold-launch sequence in main() | S | E02-T03, E04-T03, E05-T08 | `reed-app-startup` · `reed-error-model` · `reed-theming-code` · `reed-speech-service` |
| [E02-T01](E02-design-system/T01-colour-tokens-and-the-four-palettes.md) — Colour tokens and the four palettes | S | E01-T01 | `reed-colour-system` · `reed-theming-code` |
| [E02-T02](E02-design-system/T02-typography-and-font-bundling.md) — Typography and font bundling | S | E01-T01 | `reed-typography` · `reed-code-bans` · `reed-dependency-hygiene` |
| [E02-T03](E02-design-system/T03-theme-wiring-and-the-palette-switcher.md) — Theme wiring and the palette switcher | M | E02-T01, E02-T02 | `reed-theming-code` · `reed-colour-system` · `reed-riverpod-usage` · `reed-motion-policy` |
| [E02-T04](E02-design-system/T04-the-contrast-gate-test.md) — The contrast gate test | S | E02-T03 | `reed-golden-testing` · `reed-colour-system` · `reed-testing-strategy` |
| [E03-T01](E03-data-layer/T01-the-drift-schema.md) — The drift schema | M | E01-T03 | `reed-drift-schema` · `reed-dart3-idioms` · `reed-codegen-workflow` |
| [E03-T02](E03-data-layer/T02-boardrepository.md) — BoardRepository | M | E03-T01 | `reed-drift-schema` · `reed-layering-rules` · `reed-riverpod-usage` · `reed-async-rules` |
| [E03-T03](E03-data-layer/T03-settingsrepository.md) — SettingsRepository | S | E03-T01 | `reed-drift-schema` · `reed-riverpod-usage` |
| [E03-T04](E03-data-layer/T04-migration-test-harness.md) — Migration test harness | M | E03-T01 | `reed-migration-testing` · `reed-codegen-workflow` · `reed-drift-schema` |
| [E03-T05](E03-data-layer/T05-database-backup-before-upgrade.md) — Database backup before upgrade | XS | E03-T01 | `reed-migration-testing` · `reed-drift-schema` · `reed-error-model` |
| [E03-T06](E03-data-layer/T06-starter-set-with-visible-provenance.md) — Starter set with visible provenance | S | E03-T02 | `reed-vocabulary-rules` · `reed-copy-voice` · `reed-drift-schema` · `reed-aac-audience` |
| [E04-T01](E04-speech/T01-speechservice-interface-and-the-sealed-outcome.md) — SpeechService interface and the sealed outcome | S | E01-T01 | `reed-speech-service` · `reed-error-model` · `reed-dart3-idioms` · `reed-layering-rules` |
| [E04-T02](E04-speech/T02-the-voice-filter.md) — The voice filter | M | E04-T01 | `reed-speech-service` · `reed-speech-testing` · `reed-no-silent-failures` |
| [E04-T03](E04-speech/T03-the-flutter-tts-implementation.md) — The flutter_tts implementation | M | E04-T02 | `reed-speech-service` · `reed-error-model` · `reed-no-silent-failures` · `reed-async-rules` |
| [E04-T04](E04-speech/T04-audio-session-and-the-manifest.md) — Audio session and the manifest | S | E04-T03 | `reed-speech-service` · `reed-policy-tests` · `reed-manual-checklist` |
| [E04-T05](E04-speech/T05-speechcontroller-close-the-dropped-result-hole.md) — SpeechController: close the dropped-result hole | S | E04-T03 | `reed-no-silent-failures` · `reed-riverpod-usage` · `reed-error-model` · `reed-async-rules` |
| [E04-T06](E04-speech/T06-the-speech-test-suite.md) — The speech test suite | M | E04-T05 | `reed-speech-testing` · `reed-testing-strategy` · `diagnosing-tile-silence` |
| [E05-T01](E05-speak-screen/T01-the-tile-widget.md) — The tile widget | M | E02-T03 | `reed-tile-anatomy` · `reed-typography` · `reed-colour-system` · `reed-a11y-coding` · `reed-widget-conventions` · `reed-motion-policy` |
| [E05-T02](E05-speak-screen/T02-the-grid.md) — The grid | S | E03-T02, E05-T01 | `reed-grid-layout` · `reed-tile-anatomy` · `reed-widget-conventions` |
| [E05-T03](E05-speak-screen/T03-the-type-to-speak-field.md) — The type-to-speak field | S | E05-T02 | `reed-grid-layout` · `reed-typography` · `reed-a11y-coding` · `reed-copy-voice` |
| [E05-T04](E05-speak-screen/T04-the-lit-state-and-stopping-without-a-stop-button.md) — The lit state, and stopping without a STOP button | M | E04-T05, E05-T01 | `reed-tile-anatomy` · `reed-motion-policy` · `reed-speech-service` · `reed-no-silent-failures` |
| [E05-T05](E05-speak-screen/T05-the-empty-slot.md) — The empty slot | XS | E05-T02 | `reed-tile-anatomy` · `reed-a11y-coding` · `reed-drift-schema` |
| [E05-T06](E05-speak-screen/T06-traversal-order.md) — Traversal order | S | E00-T06, E05-T02 | `reed-a11y-coding` · `reed-a11y-testing` · `reed-tile-anatomy` |
| [E05-T07](E05-speak-screen/T07-speak-screen-widget-tests.md) — Speak-screen widget tests | M | E05-T04 | `reed-widget-test-harness` · `reed-text-scale-testing` · `reed-a11y-testing` · `reed-testing-strategy` |
| [E05-T08](E05-speak-screen/T08-wire-the-screen-to-the-repository.md) — Wire the screen to the repository | S | E03-T02, E05-T02 | `reed-riverpod-usage` · `reed-layering-rules` · `reed-async-rules` · `reed-widget-conventions` |
| [E06-T01](E06-show-mode/T01-per-line-optical-fitting.md) — Per-line optical fitting | M | E02-T02 | `reed-show-screen` · `reed-typography` |
| [E06-T02](E06-show-mode/T02-the-show-screen.md) — The show screen | S | E06-T01 | `reed-show-screen` · `reed-colour-system` · `reed-a11y-coding` · `reed-motion-policy` |
| [E06-T03](E06-show-mode/T03-the-standing-line-and-the-flash-setting.md) — The standing line and the flash setting | S | E06-T02 | `reed-show-screen` · `reed-copy-voice` · `reed-motion-policy` |
| [E07-T01](E07-edit-mode/T01-the-edit-mode-toggle.md) — The edit mode toggle | S | E05-T02 | `reed-widget-conventions` · `reed-a11y-coding` · `reed-tile-anatomy` |
| [E07-T02](E07-edit-mode/T02-editing-a-tile-s-text.md) — Editing a tile's text | S | E07-T01 | `reed-vocabulary-rules` · `reed-drift-schema` · `reed-copy-voice` |
| [E07-T03](E07-edit-mode/T03-reorder-and-hide.md) — Reorder and hide | S | E07-T02 | `reed-drift-schema` · `reed-tile-anatomy` · `reed-a11y-coding` · `reed-widget-conventions` |
| [E07-T04](E07-edit-mode/T04-editor-accessibility.md) — Editor accessibility | S | E07-T03 | `reed-a11y-coding` · `reed-a11y-testing` · `reed-tile-anatomy` |
| [E08-T01](E08-settings/T01-the-settings-screen.md) — The settings screen | S | E03-T03 | `reed-widget-conventions` · `reed-copy-voice` · `reed-a11y-coding` · `reed-riverpod-usage` |
| [E08-T02](E08-settings/T02-the-voice-picker.md) — The voice picker | M | E04-T02, E08-T01 | `reed-speech-service` · `reed-copy-voice` · `reed-a11y-coding` |
| [E08-T03](E08-settings/T03-output-mode-and-theme-controls.md) — Output mode and theme controls | S | E02-T03, E08-T01 | `reed-theming-code` · `reed-copy-voice` · `reed-riverpod-usage` |
| [E08-T04](E08-settings/T04-haptics-and-the-low-stimulus-mode.md) — Haptics and the low-stimulus mode | S | E08-T01 | `reed-motion-policy` · `reed-copy-voice` · `reed-riverpod-usage` |
| [E09-T01](E09-portability/T01-export-and-import.md) — Export and import | M | E03-T02 | `reed-drift-schema` · `reed-privacy-claims` · `reed-error-model` · `reed-copy-voice` |
| [E09-T02](E09-portability/T02-backup-configuration.md) — Backup configuration | S | E01-T01 | `reed-privacy-claims` · `reed-policy-tests` · `reed-store-and-legal` |
| [E09-T03](E09-portability/T03-the-on-device-crash-log.md) — The on-device crash log | S | E01-T06 | `reed-error-model` · `reed-privacy-claims` · `reed-no-silent-failures` · `reed-app-startup` |
| [E10-T01](E10-verification/T01-the-accessibility-test-suite.md) — The accessibility test suite | M | E05-T07 | `reed-a11y-testing` · `reed-a11y-coding` · `reed-testing-strategy` |
| [E10-T02](E10-verification/T02-the-text-scale-matrix.md) — The text-scale matrix | S | E05-T07 | `reed-text-scale-testing` · `reed-widget-test-harness` · `reed-typography` |
| [E10-T03](E10-verification/T03-the-manual-device-checklist.md) — The manual device checklist | S | E04-T04 | `reed-manual-checklist` · `diagnosing-tile-silence` · `reed-speech-service` |
| [E10-T04](E10-verification/T04-coverage-and-the-suite-budget.md) — Coverage and the suite budget | S | E05-T07 | `reed-testing-strategy` · `reed-ci-workflow` · `reed-lint-config` |
| [E10-T05](E10-verification/T05-the-dated-design-audit.md) — The dated-design audit | XS | E05-T01, E06-T02 | `auditing-reed-visuals` · `reed-colour-system` · `reed-motion-policy` |
| [E11-T01](E11-release/T01-store-declarations-and-privacy-paperwork.md) — Store declarations and privacy paperwork | M | E09-T02 | `reed-store-and-legal` · `reed-privacy-claims` · `reed-copy-voice` |
| [E11-T02](E11-release/T02-signing-and-the-app-bundle.md) — Signing and the app bundle | S | E01-T04, E11-T03 | `reed-release-android` · `reed-ci-workflow` |
| [E11-T03](E11-release/T03-the-obfuscation-decision.md) — The obfuscation decision | XS | E09-T03 | `reed-release-android` · `reed-error-model` |
| [E11-T04](E11-release/T04-ship-to-the-twenty.md) — Ship to the twenty | S | E10-T03, E10-T05, E11-T01, E11-T02 | `reed-manual-checklist` · `reed-aac-audience` · `reed-copy-voice` |

## The dependency graph is computed, not written

`Blocks` is the inverse of `Depends on`. It is derived, never hand-edited:

```bash
python3 epics/rebuild_graph.py          # recompute every Blocks row
python3 epics/rebuild_graph.py --check  # exit non-zero if stale; CI-safe
```

Authoring both directions by hand produced 43 edges that disagreed with their own inverse,
three of which asserted a sequencing constraint the downstream task had never heard of. The
script also fails on a cycle or a reference to a task that does not exist.

## What is deliberately not planned

**Everything after E11-T04.** The plan stops at shipping to twenty people, because what comes
next is decided by what they say — not by a document written before they touched it. Message
banking, categories, symbols, phrase capture and the printable card are all real candidates and
none of them is scheduled. That is a decision, not an omission.

**The native speak path.** `reed-native-boundary` is the one skill with no task. The Quick
Settings tile exists to help someone whose phone is locked and pocketed, and there is no evidence
that user exists — the launch barrier is an inference with zero direct testimony. E00-T02 asks.
If the answer is "it was already in my hand", the tile is never built.

**iOS.** The reason to build it is not "cross-platform". The reason is someone in E11 saying the
grid matters to them and they are on an iPhone. On iOS this competes with a free, preinstalled
OS feature bound to a shortcut no third-party app can register for.
