<!-- Thanks for contributing to Reed. Keep the change focused; open an issue first for anything large. -->

## What & why

<!-- What does this change, and who does it help? Link the issue or epic/task (e.g. Closes #12, E07-T02). -->

## How I verified it

<!-- What you ran or drove. For UI, attach a screenshot (light + a high-contrast palette if colour changed). -->

## Checklist

- [ ] `dart format .` clean
- [ ] `flutter analyze --fatal-infos` clean
- [ ] `dart run build_runner build --delete-conflicting-outputs` run; generated output committed and unchanged after
- [ ] `flutter test` green
- [ ] No new dependency, or the dependency audit passes and the addition is justified in the description
- [ ] No privacy/policy regression — no `INTERNET` permission, `allowBackup` stays `false`, no analytics/crash/network SDK; `test/policy/` still green
- [ ] User-facing copy follows `reed-copy-voice` (lowercase chrome, no exclamation marks, curly apostrophes, no "student/parent/caregiver" framing)
- [ ] Accessibility considered — semantics/labels present, survives 200% text (`reed-a11y-coding`)
- [ ] No motion introduced (`reed-motion-policy`)

## Anything reviewers should push back on?

<!-- Trade-offs, a rule you had to bend (say which and why), or an open question. -->

<!-- Reminder: never paste a user's phrases, an exported crash log, or vocalization text anywhere in this PR. Use invented sample phrases. -->
