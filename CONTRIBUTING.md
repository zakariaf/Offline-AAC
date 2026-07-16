# Contributing to Reed

Thank you for considering a contribution. Reed is a communication aid for autistic adults and teens whose speech is intermittent or unreliable, and the bar for changes is set by whether they serve that person — not by whether they are clever.

**Contributions from people who use AAC are especially welcome.** The field's own position is that AAC users must be leaders and co-creators in anything about them. If you use AAC, your review of a phrase, a flow, or a default carries weight here that a maintainer's cannot.

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to help

- **Report a bug** — but read the privacy note below first.
- **Propose a feature** — tie it to who it helps and how; see the issue form.
- **Improve docs, copy, or accessibility.**
- **Code** — pick up something from [`epics/`](epics/) or a `good first issue`.

Before a large change, open an issue so we can agree on the shape. Reed says no to a lot on purpose (see [`.claude/skills/`](.claude/skills/)); a rejected PR after days of work helps no one.

## A privacy note that is not optional

Reed stores the phrases a person writes — sometimes phrases like *"I am being hurt"* — and its exported crash log can contain the exact text a user typed. **Never paste a user's phrases, an exported log, or vocalization text into an issue, a PR, a comment, or a test fixture.** Every one of those is sensitive personal data. Use invented, neutral sample phrases in bug reports and tests.

## Development setup

Reed targets **Flutter 3.44.6** (pinned in [`.fvmrc`](.fvmrc)). `fvm` is convenient but not required.

```bash
fvm install && fvm use          # optional; or use a matching system Flutter
flutter pub get

# drift + build_runner output is committed, but regenerate after schema/table edits:
dart run build_runner build --delete-conflicting-outputs

flutter run                     # a device or simulator
flutter test                    # the whole suite, ~135 tests, under 30s
```

## Before you open a PR

Run what CI runs, so review is about the change and not the mechanics:

```bash
dart format .
flutter analyze --fatal-infos
dart run build_runner build --delete-conflicting-outputs   # then check nothing changed
flutter test
```

CI (`.github/workflows/ci.yml`) additionally checks that generated output and the drift schema snapshot are current, runs the dependency audit, and greps for colour literals outside the token file. Green CI is required to merge.

## The standards, in short

The long form lives in [`docs/CODING_STANDARDS.md`](docs/CODING_STANDARDS.md), [`docs/TESTING.md`](docs/TESTING.md), and the per-topic skills under [`.claude/skills/`](.claude/skills/). The load-bearing ones:

- **No silent failures.** A tile tap must never yield silence with no signal. When speech fails, the words go on screen. Handlers are `await`ed and honest — see `reed-no-silent-failures`.
- **The privacy invariants don't regress.** No `INTERNET` permission, `allowBackup="false"`, no analytics/crash/network SDKs, no `package:http`/Firebase/Sentry in `lib/`. Policy tests under `test/policy/` fail the build if any of these slip. See `reed-code-bans` and `reed-privacy-claims`.
- **Copy has a register.** Lowercase chrome, sentence case, curly apostrophes, no exclamation marks, no praise, no "student/parent/caregiver" framing, never transform a user's own words. See `reed-copy-voice`.
- **Accessibility is authored in, not bolted on.** `Semantics(button: true)`, real `semanticLabel`s, survival at 200% text. See `reed-a11y-coding`.
- **Zero motion.** No `Duration`, `Curve`, `Tween`, ripple, or transition. See `reed-motion-policy`.
- **Adding a dependency is a decision, not a reflex.** Run the dependency audit (see the comment in [`pubspec.yaml`](pubspec.yaml)); a package that opens a network path or drags in telemetry breaks the product's core claim.

If a change needs to relax one of these, say so explicitly in the PR and explain why — don't route around the test.

## Commits and PRs

- Small, focused commits with a present-tense summary line. Reference the epic/task where relevant (e.g. `E07-T02: …`).
- Fill in the [pull request template](.github/PULL_REQUEST_TEMPLATE.md).
- Include a screenshot for any UI change (both light and a high-contrast palette if you touched colour).
- Sign your work under the project's [MIT license](LICENSE); by contributing you agree your contribution is licensed under it.

## How decisions are made

Reed is planned in epics (`epics/E01`–`E11`) with an explicit rationale for each. The design and refusals are recorded in `docs/` and `.claude/skills/` so they can be reviewed and argued with — not so they can't be changed. If you think a rule is wrong, the skill that states it is the place to make the case.
