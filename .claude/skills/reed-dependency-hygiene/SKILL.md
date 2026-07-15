---
name: reed-dependency-hygiene
description: pubspec.yaml and pubspec.lock mechanics for Reed — caret ranges, the committed lock, the .fvmrc SDK string, the versioned very_good_analysis include, and vendoring flutter_tts into third_party/. Use when adding, upgrading, or removing a package, running dart pub add/get/outdated/deps, bumping the Flutter SDK, or auditing the transitive tree. Not for whether a package or construct is permanently banned, and not for what may be said publicly about privacy.
allowed-tools:
  - Read
  - Edit
  - Bash(dart pub *)
  - Bash(python3 *)
---

# Dependency hygiene

This app has no telemetry and never will. Nobody will ever learn it crashed in the field — a user who cannot speak does not file a bug report. Every dependency is therefore a permanent liability the author will not be around to service, and the whole exit plan is that a stranger can `git clone && flutter run` years after the author stops. Optimise for *resolves in 2029*, not for *latest*.

## Ranges in pubspec, pins in the lock

| Do | Never |
|---|---|
| Caret ranges in `pubspec.yaml`: `drift: ^2.31.0` | Exact pins in `pubspec.yaml` (`drift: 2.31.0`) |
| Commit `pubspec.lock` | Gitignore `pubspec.lock` |
| `environment: sdk: ^3.11.0` — a real range | An exact `sdk:` version |

The lock is what pins. Ranges only keep resolution *solvable*. Exact pins in `pubspec.yaml` manufacture unsolvable conflicts on the next SDK upgrade and buy nothing the lock is not already delivering.

This is an application, not a package — the asymmetry that makes the whole rule flip. The standard `github/gitignore` Dart template contains a `pubspec.lock` line and even comments that applications may want to check it in. **Delete that line.** The committed lock is the only thing that makes a stranger's clone resolve the exact `flutter_tts` and `drift` versions that were tested against a real device — and a real device is the only thing that has ever verified this app makes sound.

If `pubspec.lock` is absent from a diff that changes `pubspec.yaml`, the change is incomplete.

## The SDK pin: pin the record, not the tool

Commit `.fvmrc` at the repo root. It is **JSON**, read with `jq -r '.flutter'`:

```json
{ "flutter": "3.41.2" }
```

The `flutter: 3.44.0` YAML form that gets copied around is the shape of `pubspec.yaml`'s `environment:` block (`yq eval '.environment.flutter'`). It is wrong in `.fvmrc`. Channel names (`stable`, `beta`, `master`, `main`) are also valid values there — it is not exact-versions-only.

**Do not install `fvm`.** One developer, one machine; a version manager solves switching between projects that do not exist. The *file* earns its place because CI reads it (`subosito/flutter-action` with `flutter-version-file: .fvmrc`) and because a stranger reads it. The tool does not. Bump the string by hand, in the same commit as the `flutter upgrade`.

Keep `pubspec.yaml`'s `environment:` a normal range regardless. `.fvmrc` pins; the range keeps `pub` able to solve.

### The SDK bump has one coupled edit that fails silently

The resolved Flutter/Dart version decides which `very_good_analysis` resolves. `very_good_analysis` 10.3.0 requires Dart `^3.12.0`; on Dart 3.11.0 the resolver lands on 10.2.0, so the lint include must read:

```yaml
include: package:very_good_analysis/analysis_options.10.2.0.yaml
```

If that filename does not exist inside the *resolved* package, the analyzer emits only `warning • include_file_not_found` and **continues with zero rules** — all 212 lints silently off, build green, checking nothing. On a project where the analyzer is one of only two safety nets, a net that reports green while inspecting nothing is worse than no net.

So on any SDK bump, in the same commit: edit `.fvmrc`, run `flutter pub get`, then confirm the versioned include actually exists in the cache before pushing:

```sh
ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/
```

## The gate every new dependency must pass

Refuse a package outright if it — or **anything in its transitive tree** — does any of:

- **Opens a network path.** `http`, `dio`, sockets, gRPC. The privacy promise is the product, and the Android manifest has no `INTERNET` permission. A package that needs it is a package that changes what this app *is*.
- **Reports crashes or usage.** Crashlytics, Sentry, analytics of any brand. Refused, not un-built.
- **Drags in Firebase.** Not only the obvious `firebase_*` names — a crash SDK's *core* pulls in data categories that make the store privacy label worse, and the audience for this app reads privacy labels adversarially. The label must stay "no network, no server" and be true down to the last transitive package.
- **Collects device identifiers** for a feature that is not shipped.
- **Requires an `--enable-experiment` flag.** An abandoned repo that needs an experiment to build stops building.

Also weigh, and usually refuse: anything with one maintainer that is *not* behind an interface; anything whose function is a few hundred lines of first-party Dart; anything that only exists to save typing.

### Check the tree, not the pubspec

A direct read of `pubspec.yaml` cannot see the second hop, which is exactly where Firebase arrives. Before adding anything, run:

```sh
dart pub add --dry-run <package>          # see what would resolve
dart pub deps --json > /tmp/deps.json
python3 .claude/skills/reed-dependency-hygiene/scripts/audit_deps.py /tmp/deps.json
```

The script walks the full resolved set, matches banned patterns, and marks each hit `direct` or `TRANSITIVE`. Exit 1 means refuse the dependency or find one that does not pull those in. To learn who introduced a package: `dart pub deps | grep -B4 <name>`.

Then check the rest by hand: pub.dev popularity is irrelevant, but **maintainer count, last publish date, and licence are not.** Record the licence — a permissive one (MIT, BSD, Apache-2.0) is a precondition for the vendoring escape hatch below. A copyleft dependency removes that option permanently.

## Upgrading

Run `dart pub outdated` when the mood strikes. There is no schedule and no bot.

**Skip Renovate and Dependabot.** Dependabot has never supported pub — the request was closed without shipping. Renovate raises pull requests against a repo that has no pull-request workflow. Their one genuinely useful feature here — never automerge `flutter_tts` or `audio_session` — only means something if automerge exists, and it does not.

Keep the rule anyway, by hand: **green CI is not evidence of audio.** No CI job can assert that this app makes a sound. Standard emulator images ship without a TTS engine or voice data, and there is no supported hook to capture PCM output from Android `TextToSpeech` or iOS `AVSpeechSynthesizer` — `integration_test` can assert a channel call was issued, nothing more. So after any bump to `flutter_tts`, `audio_session`, or the SDK itself, run the manual device pass on a real phone with the ringer switch off. A `flutter_tts` upgrade that is green in CI and mute on hardware is the single worst outcome this project has.

After any upgrade touching `drift` or `drift_dev`, regenerate and commit — generated code is committed here, and stale generated code is caught by CI, not by the analyzer.

## Vendoring flutter_tts

`flutter_tts` is bus-factor-1 and MIT-licensed. It is healthy today (~285k weekly downloads). **Do not vendor it now.** Vendoring pre-emptively buys a maintenance burden against a break that has not happened. The mitigation is that vendoring is *cheap*, because the `SpeechService` interface already absorbs it and because only four `flutter_tts` methods are ever called — `speak`, `stop`, `getVoices`, `setVoice` — plus the iOS audio category.

**Trigger — vendor when either is true:**
- it stops building against a Flutter release, or
- a regression ships and upstream is unresponsive for a few weeks.

**Procedure:**

1. `git clone` upstream at the **last-good tag** into `third_party/flutter_tts/`. Record the exact commit SHA.
2. Point the app at it:
   ```yaml
   flutter_tts:
     path: third_party/flutter_tts
   ```
   Path dependencies work for plugins with native code. **`lib/` does not change at all** — that is the entire payoff of the abstraction.
3. **Read `third_party/flutter_tts/LICENSE` and confirm it is MIT before redistributing.** Keep the file. MIT requires retaining the copyright notice and licence text in redistributed source. Make this step one — the file is open anyway.
4. Write `third_party/flutter_tts/VENDORED.md`: upstream URL, vendored SHA, date, why, and every line changed.
5. **Patch, don't refactor.** Every line touched is a line owned forever. Fix the break, ship, stop. Do not tidy the plugin's Kotlin, do not rename anything, do not "modernise" its API.
6. Re-run the manual device pass on a real phone. No test in the suite can establish that the vendored copy still makes sound.

**What must not move:** the `SpeechService` interface — `Future<SpeakOutcome> speak(String text)`, `Future<void> stop()`, `Future<List<Voice>> voices()` — and everything above it. If a vendoring diff touches anything outside `third_party/` and the one thin implementation file, it has gone wrong: the surrounding code (the pure `voice_filter`, the `setVoice` return check, the audio session config) exists precisely so the plugin can be swapped underneath it without moving.

If upstream revives, diff the patch against it and go back. If it does not, the app now owns roughly four methods over two platform APIs — which was always the real dependency.

## Removing a dependency

Delete the entry, run `flutter pub get`, and commit the `pubspec.lock` delta in the same commit. Then grep `lib/` for the import — a dependency removed from `pubspec.yaml` while still transitively resolvable keeps compiling today and breaks on the clone that matters. The analyzer catches an unresolved import; it does not catch an import that resolves only by accident.
