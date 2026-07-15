# ci-release

> Phase: **research** · Agent `a88f80728662c8b4c` · Run `wf_12b14467-451`

## Result

## Summary

The 2026 action stack has drifted from what most blog posts say: `subosito/flutter-action` is still **v2** (v2.23.0, March 2026 — there is no v3), but its companions have all moved on (`actions/checkout@v6`, `actions/setup-java@v5`, `actions/upload-artifact@v6`, `codecov/codecov-action@v5`). The single biggest stale-advice trap is **`VeryGoodOpenSource/very_good_coverage` was archived 2026-03-31** and superseded by `very_good_workflows@v1` — for a solo app repo the right move is neither, just ~15 lines of `lcov` in a shell script with no third-party dependency at all. The 2026 answer to Flutter version pinning is `flutter-version-file: .fvmrc` (flutter-action v2 reads `.fvmrc`, `pubspec.yaml`, or `.fvm/fvm_config.json`, exact versions only), which gives you fvm locally and pinned CI without an fvm install step. Three project-specific calls dominate the generic advice: **do not obfuscate** (the exit plan is open-sourcing, so obfuscation protects nothing, and it would render the on-device crash log — your only field signal — unreadable, permanently so once you abandon the project); **skip emulator integration tests** (15+ min, flaky, and a CI emulator cannot verify the one thing that matters, that real TTS actually produced audio); and **leave R8 off for v1** (reflection-driven keep-rule mistakes fail silently at runtime, which is precisely this app's worst bug class, for near-zero size payoff on a 12-tile app). Commit the `.g.dart` files: drift's generated code *is* the schema, so a migration PR diff becomes a reviewable safety artifact, and a stranger cloning the repo gets a working `flutter run` without a build_runner round-trip — guard staleness with a `build_runner build && git diff --exit-code` CI step. For v1 release, build and sign **locally** and upload to the Play internal track by hand: fastlane is not worth it, and CI never needs your keystore. The highest-leverage hygiene artifact for an app whose exit plan is abandonment is not conventional commits or semantic-release — it is ~6 short ADRs recording *why* `grid_slots` is keyed on position and why the audio session is `.playback`, because those are the decisions a stranger will otherwise silently undo.

### subosito/flutter-action is still on v2 in 2026 — there is no v3, and it is actively maintained

*Confidence: high, **LOAD-BEARING***

Latest release v2.23.0, 2026-03-25, maintained by Bartek Pacia; 46 releases. It now uses actions/cache@v5 internally (self-hosted runners need Actions Runner 2.327.1+; irrelevant for GitHub-hosted). Inputs: channel, flutter-version, flutter-version-file, cache, pub-cache, cache-key, pub-cache-key with :os:/:channel:/:version:/:arch:/:hash:/:sha256: placeholders. An alternative, flutter-actions/setup-flutter, does have v3/v4 — do not confuse its version numbers for subosito's.

- https://github.com/subosito/flutter-action

- https://github.com/subosito/flutter-action/releases

### flutter-action@v2 reads .fvmrc directly — this is the 2026 reproducible-pinning answer, and it removes the need to install fvm in CI

*Confidence: high, **LOAD-BEARING***

flutter-version-file accepts 'path to pubspec.yaml or .fvmrc or .fvm/fvm_config.json'. The version must be an exact string: `flutter: 3.44.0` works, `flutter: ">= 3.19.0 <4.0.0"` does not. Using .fvmrc (rather than pubspec.yaml) lets pubspec keep a normal range constraint while CI and local fvm share one exact pin. .fvmrc is committed; .fvm/flutter_sdk (the symlink) is gitignored. fvm_config.json is deprecated in favour of .fvmrc and is auto-migrated.

- https://github.com/subosito/flutter-action

- https://fvm.app/documentation/getting-started/configuration

### VeryGoodOpenSource/very_good_coverage is ARCHIVED as of 2026-03-31 — most tutorials still recommend it

*Confidence: high, **LOAD-BEARING***

Repo archived 2026-03-31, read-only. Last release v3.0.0 (2024-03-05). README: 'Very Good Coverage has been superseded by Very Good Workflows, which provides a comprehensive suite of reusable GitHub Actions workflows — including code coverage enforcement.' Successor is VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v1 (repo active, updated 2026-05-04) — but that workflow is shaped for *packages*, not apps, and pulls in opinionated defaults.

- https://github.com/VeryGoodOpenSource/very_good_coverage

- https://github.com/VeryGoodOpenSource/very_good_workflows

- https://workflows.vgv.dev/

### Companion action major versions have all moved past what 2024-2025 Flutter tutorials show

*Confidence: high*

actions/checkout@v6 (shown in flutter-action's own current README example); actions/setup-java@v5 (v5.5.0, 2026-07-08, adds verify-signature for Temurin); actions/upload-artifact@v6 (2026-02-25, Node 24 by default) with v7 adding non-zipped artifacts (archive: false); codecov/codecov-action@v5.

- https://github.com/subosito/flutter-action

- https://github.com/actions/setup-java/releases

- https://github.com/actions/upload-artifact/releases

- https://github.blog/changelog/2026-02-26-github-actions-now-supports-uploading-and-downloading-non-zipped-artifacts/

### Codecov v5 supports tokenless upload for public repos, so it remains free-and-frictionless for an OSS app

*Confidence: medium*

'The v5 release also coincides with the opt-out feature for tokens for public repositories' — tokenless is enabled via org settings. PRs from forks to upstream public repos support tokenless unconditionally (contributors don't need the upstream token). Requires bash/curl/git/gpg on the runner and actions/checkout to run first. For a solo repo, Codecov's value is the PR comment; the enforcement gate is better done locally in the workflow so the build fails without a network round-trip.

- https://github.com/codecov/codecov-action

- https://about.codecov.io/blog/tokenless-uploads-for-github-actions/

### Flutter's own docs state obfuscation is not a security control, and it breaks runtime type-name matching

*Confidence: high, **LOAD-BEARING***

docs.flutter.dev/deployment/obfuscate: 'Obfuscating your code does not encrypt resources nor does it protect against reverse engineering. It only renames symbols with more obscure names.' Caveats: release builds only; `expect(foo.runtimeType.toString(), equals('Foo'))` won't work; enum names are NOT obfuscated; you must back up the SYMBOLS file or you can never de-obfuscate. --obfuscate requires --split-debug-info=<dir>. Supported targets include apk, appbundle, ios, ipa. Symbolization: `flutter symbolize -i <trace-file> -d <app.android-arm64.symbols>` — needs the arch-specific symbols file from the exact build.

- https://docs.flutter.dev/deployment/obfuscate

### Obfuscation is actively harmful for this specific app — it destroys the only field signal and its benefit is nil once the source is public

*Confidence: medium, **LOAD-BEARING***

The threat model obfuscation addresses (reverse-engineering) is void when the exit plan is publishing the source. Meanwhile the app's only crash signal is a user-exported on-device log; an obfuscated trace requires the developer to still exist, to have retained the per-build per-arch .symbols file, and to run `flutter symbolize`. After abandonment (explicitly planned), every crash report ever filed becomes permanently unreadable. Additionally --obfuscate breaks runtimeType string matching — a silent-failure vector in a codebase whose stated worst bug class is silence. Without --split-debug-info, AOT release stack traces retain Dart function names and are directly readable in the exported log, at a cost of a few MB.

- https://docs.flutter.dev/deployment/obfuscate

### R8 minification failures surface as 'Missing classes detected while running R8' with a generated rules file, and are a runtime-silent-failure risk

*Confidence: medium, **LOAD-BEARING***

R8 writes suggested keep rules to build/app/outputs/mapping/release/missing_rules.txt. Real Flutter plugin cases exist (flutter/flutter#155458 for camera + google_sign_in_android; flutter_stripe#2139; razorpay-flutter#415). Fixes are broad `-keep class com.x.** { *; }` + `-dontwarn`. Crucially, a *missing* keep rule for a reflectively-loaded class does not fail the build — it fails at runtime, which for this app means a tile tap producing no speech. flutter_tts drives android.speech.tts.TextToSpeech over a platform channel rather than reflection, so risk is lowish, but the payoff on a 12-tile app is also near-zero.

- https://github.com/flutter/flutter/issues/155458

- https://arahimli.medium.com/troubleshooting-r8-minification-errors-in-flutter-my-journey-to-a-solution-ac88cc43fae3

- https://www.devsecopsnow.com/error-missing-classes-detected-while-running-r8/

### Golden tests are OS-dependent; the 2026 consensus is to make CI authoritative rather than chase cross-platform tolerance

*Confidence: high, **LOAD-BEARING***

macOS applies font smoothing that Linux doesn't; goldens generated on macOS fail on ubuntu-latest runners (flutter/flutter#36667 — goldens are inconsistent across both OS versions and Flutter versions). Options: (a) match CI OS to dev OS, (b) Alchemist's separate CI/local golden folders, (c) per-platform tolerance. The May-2025-onward recommendation is to match environments rather than make tests platform-agnostic. Flutter defaults to the Ahem font (renders boxes) unless you load real fonts via flutter_test_config.dart.

- https://github.com/flutter/flutter/issues/36667

- https://medium.com/@m1nori/flutter-golden-tests-fail-in-github-actions-why-and-how-to-fix-65e3b69ee86e

- https://hevawu.github.io/blog/2022/04/13/Run-Flutter-Golden-Tests-Between-MacOS-And-CI

### Emulator integration tests in CI are slow and flaky, and cannot verify the thing that actually matters here (real audio)

*Confidence: high, **LOAD-BEARING***

ReactiveCircus/android-emulator-runner@v2 is the standard action. Reported Flutter drive runs exceeding 15 minutes (issue #47); 'Connecting to the VM Service timed out' failures (#95837 made the timeout configurable); flutter driver hangs (#35); green-locally/red-in-CI nondeterminism (#183). Mitigation is a two-step AVD snapshot cache (create clean snapshot, then run with no-snapshot-save). Decisive point for this app: a CI emulator's TTS engine is not a real device's TTS engine, so the failure modes that motivate the whole design — setVoice returning 0 with only a Log.d, a network_required voice vanishing, an .ambient audio session muted by the silent switch — are exactly what an emulator cannot reproduce.

- https://github.com/ReactiveCircus/android-emulator-runner

- https://github.com/ReactiveCircus/android-emulator-runner/issues/47

- https://github.com/flutter/flutter/issues/95837

- https://github.com/ReactiveCircus/android-emulator-runner/discussions/183

### Dependabot does not support pub; Renovate does, including a Flutter SDK datasource

*Confidence: high, **LOAD-BEARING***

dependabot-core#2166 ('Support for Dart/Flutter languages', opened 2019-04-07, label T: new-ecosystem) is closed without pub support shipping. Renovate's pub manager matches /(^|/)pubspec\.ya?ml$/ by default and extracts the dart, dart-version, and flutter-version datasources; a dedicated flutter-version datasource (packageName flutter/flutter) can bump the SDK pin in .fvmrc and workflow files via a custom regex manager. dependabot_gen exists on pub.dev but generates config for other ecosystems, not pub itself.

- https://github.com/dependabot/dependabot-core/issues/2166

- https://docs.renovatebot.com/modules/manager/pub/

- https://docs.renovatebot.com/modules/datasource/flutter-version/

### The standard github/gitignore Dart template ignores pubspec.lock by default — wrong for an app, and a real footgun

*Confidence: high, **LOAD-BEARING***

Dart.gitignore contains `pubspec.lock` preceded by the comment 'If you're building an application, you may want to check-in your pubspec.lock'. It ignores build/ and pub metadata. It does NOT ignore *.g.dart — committing generated code is not fought by the standard template. dart.dev/tools/pub/private-files is the canonical 'what not to commit' reference. For this app the lock file MUST be committed: it is the only thing making a stranger's clone resolve the same flutter_tts/drift versions you tested against.

- https://github.com/github/gitignore/blob/main/Dart.gitignore

- https://dart.dev/tools/pub/private-files

### drift ships first-class schema export + migration test generation, and the dump is CI-verifiable by diff

*Confidence: high, **LOAD-BEARING***

`dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/` writes drift_schema_vX.json named by the current schemaVersion (it must be re-run every time the schema changes and the version is incremented). `dart run drift_dev schema generate` with --data-classes/--companions emits old-version snapshots so migration tests can assert against historical schemas. `make-migrations` requires the database location declared in build.yaml. Drift does not document a dedicated CI 'verify' command — but re-running the dump and asserting `git diff --exit-code drift_schemas/` is an exact equivalent and catches the 'changed schema, forgot to bump schemaVersion' bug that loses a user's board.

- https://drift.simonbinder.eu/migrations/exports/

- https://drift.simonbinder.eu/migrations/tests/

- https://drift.simonbinder.eu/migrations/step_by_step/

### lcov 2.x on ubuntu-24.04 runners is strict and will fail builds that worked under lcov 1.x

*Confidence: medium*

ubuntu-24.04 ships lcov 2.x, which promotes previously-benign conditions (unused --remove patterns, mismatched paths, inconsistent counts) to hard errors. `lcov --remove` filtering of *.g.dart/*.freezed.dart needs `--ignore-errors unused` (and often `--ignore-errors inconsistent`) to survive. This is a common silent CI breakage when pinning runners forward.

- https://github.com/linux-test-project/lcov

### Play versionCode is monotonic and permanently consumed; deriving it from github.run_number is a common and unrecoverable trap

*Confidence: high, **LOAD-BEARING***

flutter build appbundle --build-number=N sets versionCode. Play rejects any AAB whose versionCode is <= one already uploaded to that track, and a versionCode is burned even if the release is deleted/rolled back. github.run_number is per-workflow-file and resets to 1 if the workflow is renamed or recreated — which silently makes every subsequent build unuploadable until you manually jump past the high-water mark. `version: 1.0.0+7` committed in pubspec.yaml is the auditable alternative, and matches the exit plan (a successor reads the repo, not your Actions history).

- https://docs.flutter.dev/deployment/android

- https://docs.fastlane.tools/actions/supply/

### For v1 release automation, r0adkll/upload-google-play is materially simpler than fastlane, but manual upload is simpler than both

*Confidence: medium, **LOAD-BEARING***

fastlane supply/upload_to_play_store handles metadata, screenshots, binaries, track selection and promotion — a real win for teams shipping frequently, at the cost of a Ruby toolchain, a Google Play service account JSON in CI secrets, and a fastlane/metadata tree. r0adkll/upload-google-play@v1 is a single step (serviceAccountJsonPlainText, packageName, releaseFiles, track, status). Neither pays for itself across the ~6 internal-track uploads of a 2-week MVP. Decisive: a successor forking an abandoned open-source app will have their own Play account, their own service account, and their own signing key — your release automation is the one part of the repo they cannot reuse.

- https://docs.fastlane.tools/actions/supply/

- https://github.com/r0adkll/upload-google-play

- https://medium.com/@garoono/flutter-ci-cd-with-github-actions-build-test-ship-on-autopilot-1934c698568e

### Committing .g.dart is defensible here specifically because drift's generated code is the schema, and *.g.dart linguist-generated=true removes the usual objection

*Confidence: medium, **LOAD-BEARING***

The standard objection to committing codegen is diff noise and merge conflicts — merge conflicts are void for a solo dev, and diff noise is solved by a .gitattributes entry `*.g.dart linguist-generated=true`, which collapses those files in PR diffs and excludes them from GitHub language stats. The pro-commit arguments are project-specific and strong: (1) a stranger's `git clone && flutter run` works with no build_runner round-trip; (2) a drift migration PR shows the *actual schema delta* as a reviewable diff, turning migration review into a safety gate rather than a leap of faith; (3) it pins generated output against future drift_dev versions producing different code after abandonment. The staleness risk is fully mitigated by a CI `build_runner build --delete-conflicting-outputs && git diff --exit-code` step.

- https://github.com/github/gitignore/blob/main/Dart.gitignore

- https://medium.com/@catzoy/cut-down-on-dart-files-generation-with-a-single-git-attribute-5bcb614f0135

### Apache-2.0 is the license that best fits an app designed to outlive its author; GPL-3.0 actively obstructs the succession path

*Confidence: medium, **LOAD-BEARING***

The goal is that a stranger can fork the repo and ship it to Play under their own account after abandonment. Apache-2.0 is permissive (no relicensing friction), and unlike MIT includes an express patent grant plus a trademark clause — relevant because the app name/branding should NOT transfer with a fork, while the code should. GPL-3.0 would force forks open but creates well-known friction with app-store distribution (the store's DRM/ToS vs GPLv3 §6 anti-tivoization) and adds a compliance burden that deters exactly the casual maintainer you want. MPL-2.0 is a coherent middle ground: per-file copyleft keeps improvements to the AAC core open while permitting store distribution. Recommend Apache-2.0 + NOTICE; the no-telemetry promise is enforced by the code being readable, not by the license.

- https://www.apache.org/licenses/LICENSE-2.0

- https://choosealicense.com/licenses/apache-2.0/

- https://www.mozilla.org/en-US/MPL/2.0/FAQ/

### ADRs are the one piece of team ceremony that is worth more to a solo dev than to a team, given the abandonment plan

*Confidence: high, **LOAD-BEARING***

The prior research pass produced decisions whose rationale is invisible in the code and actively counter-intuitive: grid_slots PRIMARY KEY (board_id, row, col) with a NULLABLE button_id looks like a normalization mistake to any competent reviewer, but it is what makes tile reflow structurally impossible; audio_session .playback (not .ambient) looks like an oversight; the voice_filter's setVoice return-value check looks like defensive noise because flutter_tts returns 0 with only a Log.d on failure; Riverpod looks over-engineered for 12 tiles and is documented as deliberately not load-bearing. Every one of these is a decision a stranger (or the author in six months) will 'clean up' and thereby reintroduce the exact failure the design prevents. ADRs cost ~20 min each and are the only durable defense.

- https://adr.github.io/

- https://github.com/joelparkerhenderson/architecture-decision-record

### Conventional commits + semantic-release are not worth it for this repo; a handwritten keepachangelog CHANGELOG is

*Confidence: medium*

Conventional commits pay off via automated changelog generation and multi-contributor PR triage — neither applies pre-open-sourcing. The CHANGELOG, by contrast, has two real consumers regardless of contributor count: Play Console release notes (which must be written anyway) and a stranger evaluating whether the project is alive. keepachangelog.com's Added/Changed/Fixed/Removed structure under an Unreleased heading is the low-ceremony fit. If contributors ever arrive, VeryGoodOpenSource/very_good_workflows ships a semantic_pull_request workflow that enforces the convention on PR titles only — adopt it then, not now.

- https://keepachangelog.com/en/1.1.0/

- https://www.conventionalcommits.org/

- https://github.com/VeryGoodOpenSource/very_good_workflows

### For an app (unlike a package), caret ranges in pubspec.yaml plus a committed pubspec.lock is correct — pinning exact versions in pubspec is an anti-pattern

*Confidence: high, **LOAD-BEARING***

The lock file is what pins; exact pins in pubspec.yaml only break transitive resolution and produce unsolvable version conflicts on the next flutter upgrade. Packages must use wide ranges (they don't ship a lock); apps get reproducibility from the lock. `dart pub outdated` reports resolvable vs latest and is the manual review command. Project-specific caveat: an automated bump of flutter_tts or audio_session can silently change voice availability or session category behaviour — those are the two packages whose Renovate PRs must never merge on green CI alone, because no test in the suite can observe whether a real device produced sound.

- https://dart.dev/tools/pub/dependencies

- https://dart.dev/tools/pub/cmd/pub-outdated

- https://docs.renovatebot.com/modules/manager/pub/

## Recommendations

- **[must]** Pin Flutter with a committed .fvmrc containing an exact version, and consume it in CI via `subosito/flutter-action@v2` with `flutter-version-file: .fvmrc`. Do not install fvm in CI.
  - flutter-action v2 natively reads .fvmrc, so one file pins both the local fvm SDK and CI with zero extra steps. Keeps pubspec's environment constraint a normal range (which pub needs) while the exact pin lives where it belongs. Reproducibility matters more than usual here: after abandonment, the pinned version is the only record of what the app was ever tested against.
- **[must]** Use actions/checkout@v6, subosito/flutter-action@v2, actions/setup-java@v5 (temurin 17), actions/upload-artifact@v6. Do not use VeryGoodOpenSource/very_good_coverage.
  - These are the current majors as of 2026-07. very_good_coverage was archived 2026-03-31 and is still recommended by most Flutter CI tutorials — adopting it means adopting a dead dependency on day one.
- **[must]** Enforce the coverage floor with a committed lcov shell script (tool/check_coverage.sh), not a third-party action or service. Use per-directory floors: 100% on lib/data (drift/migrations) and lib/speech (voice_filter/SpeechService), ~70% elsewhere.
  - A single global percentage is theatre; it lets you hit 85% on widget fluff while the migration path is untested. With no telemetry, tests are the only safety net, and the two directories where a bug is unrecoverable (lost boards, silence) are the two that warrant a hard 100%. A shell script also has no supply-chain or archival risk — it still works in 2030.
- **[must]** Add a CI step that runs `dart run build_runner build --delete-conflicting-outputs` and fails on `git diff --exit-code -- '*.g.dart' '*.drift.dart'`.
  - This is the entire mitigation for the only real downside of committing generated code. Without it, committed codegen silently drifts from its source and the repo lies to the next reader.
- **[must]** Add a CI step that re-runs `dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/` and fails on `git diff --exit-code -- drift_schemas/`.
  - Catches the exact bug that loses a user's voice: changing the schema without incrementing schemaVersion, so no migration ever runs and the next release opens a DB whose shape doesn't match the code. Drift documents no verify command, but the dump-and-diff is equivalent and costs one step.
- **[must]** Commit .g.dart / .drift.dart files, add `*.g.dart linguist-generated=true` and `*.drift.dart linguist-generated=true` to .gitattributes, and commit pubspec.lock (delete the `pubspec.lock` line the standard Dart.gitignore ships with).
  - A stranger's `git clone && flutter run` must work with no build_runner round-trip — that is the exit plan's minimum bar. Drift's generated code is the schema, so migration diffs become reviewable safety artifacts. linguist-generated collapses the noise in diffs. The lock file is what makes a stranger resolve the flutter_tts version you actually tested.
- **[avoid]** Do not ship --obfuscate. Do not ship --split-debug-info for v1 either.
  - Obfuscation protects nothing once the source is public (the exit plan), and Flutter's own docs say it is not a security control. Both flags strip the Dart function names from AOT stack traces, which is the one thing the on-device exportable crash log depends on — and after abandonment nobody will have the per-build .symbols file to run `flutter symbolize`, making every crash report ever filed permanently unreadable. --obfuscate additionally breaks runtimeType string matching, a silent-failure vector. The cost of not obfuscating is a few MB.
- **[should]** If app size ever forces the issue, enable --split-debug-info WITHOUT --obfuscate and attach the entire symbols directory to the GitHub Release for that tag.
  - This resolves the tension honestly rather than choosing a side. Names get stripped from the binary (size win), but the symbols are public and permanent, so any stranger — not just you — can run `flutter symbolize -i trace.txt -d app.android-arm64.symbols` on a user's exported log years after you stop maintaining it. Obfuscation is the part with no upside; split-debug-info's downside is fully repaired by publishing the symbols.
- **[should]** Explicitly set `isMinifyEnabled = false` and `isShrinkResources = false` in android/app/build.gradle.kts release buildType for v1, with a comment explaining why.
  - A missing R8 keep rule does not fail the build — it fails at runtime, meaning a tile tap produces no speech. That is precisely this app's worst bug class, traded against a negligible size win on a 12-tile app with no heavy dependencies. Being explicit (rather than relying on template defaults) also tells the next maintainer this was a decision, not an oversight.
- **[should]** Run golden tests only on ubuntu-24.04 and treat CI as authoritative. Provide a workflow_dispatch 'update-goldens' job that regenerates with --update-goldens and commits the PNGs back.
  - macOS font smoothing makes locally-generated goldens fail on Linux runners. Matching environments is the current consensus fix, and a dispatch job gets you that without Docker or Alchemist — you never generate goldens on your Mac at all. Worth the setup here because the golden's job is to catch the 3x4 grid breaking at TextScaler 2.0/3.0, which is a correctness property, not polish.
- **[must]** Load real fonts in test/flutter_test_config.dart before running goldens, and assert the grid at textScaleFactor 1.0, 2.0 and 3.0.
  - Flutter's default Ahem font renders boxes, so a golden that passes proves nothing about text fitting in a tile. Since TextScaler must be honoured at 200%+ and never clamped, the 2.0/3.0 goldens are the enforcement mechanism for that requirement — otherwise it's discipline, and discipline is what the constraints say cannot be relied on.
- **[avoid]** Do not run emulator integration tests in PR CI. Replace them with a committed docs/RELEASE_CHECKLIST.md of manual on-device checks, executed before every internal-track upload.
  - 15+ minute runs, documented VM-service timeouts and hangs, and green-local/red-CI nondeterminism — for a check that cannot observe the thing that matters. A CI emulator's TTS is not a real device's TTS, so it cannot catch setVoice returning 0 with only a Log.d, a network_required voice vanishing, or an .ambient session muted by the silent switch. Those need a real phone with the ringer switched off, and a checklist is the honest tool for that.
- **[should]** For v1, build and sign release AABs locally and upload to the Play internal track by hand. Do not adopt fastlane. Do not put the keystore in GitHub secrets.
  - Proportionate to ~6 uploads across a 2-week MVP. CI's job is catching regressions, not shipping; keeping the keystore off CI removes an entire secret-management surface. Fastlane's cost (Ruby toolchain, service-account JSON, metadata tree) doesn't amortize, and it is the one part of the repo a successor cannot reuse — they will have their own Play account, service account and signing key.
- **[must]** Enroll in Play App Signing, back the upload keystore up offline in two places, and record in docs/RELEASE.md that the upload key is replaceable but the boards are not.
  - Play App Signing means a lost upload key is recoverable via Google support rather than fatal. The note matters for succession: a stranger forking the app needs to know they generate their own upload key and that nothing about the user's data depends on it.
- **[must]** Manage versionCode by committing `version: 1.0.0+N` in pubspec.yaml and bumping it in the release commit. Never derive --build-number from github.run_number.
  - run_number resets to 1 if the workflow file is renamed or recreated, silently producing unuploadable builds, and a Play versionCode is permanently consumed even by a deleted release. The committed value is auditable and is what a successor reads.
- **[should]** Use Renovate (not Dependabot) for pub. Configure the pub manager plus a custom manager using the flutter-version datasource to bump .fvmrc.
  - Dependabot has never supported pub — dependabot-core#2166 is closed without shipping it. Renovate's pub manager auto-discovers pubspec.yaml and its flutter-version datasource can bump the SDK pin, which is the piece a solo dev otherwise forgets for a year.
- **[must]** Add a Renovate package rule that labels any flutter_tts or audio_session update `needs-device-test` and never auto-merges it, regardless of green CI.
  - Green CI is not evidence of audio. These two packages sit exactly on the silence surface — a minor bump can change voice availability behaviour or session category semantics with no test able to observe it. Encoding that in renovate.json makes the rule survive the developer forgetting it.
- **[must]** Keep caret ranges in pubspec.yaml and rely on the committed pubspec.lock for pinning. Do not pin exact versions in pubspec.yaml.
  - This is the app (not package) answer: the lock pins, the ranges keep resolution solvable. Exact pins in pubspec only manufacture version conflicts on the next SDK upgrade.
- **[must]** Write ~6 short ADRs in docs/adr/ before writing the code they describe: grid_slots position-as-PK, label-vs-vocalization, no telemetry, SpeechService + voice_filter, audio session .playback, Riverpod-as-seam (explicitly noting it is not load-bearing).
  - This is the highest-leverage artifact in the whole dimension, and it is worth more to a solo dev than to a team precisely because of the abandonment plan. Every one of those decisions looks like a mistake to a competent stranger — a nullable FK in a composite PK reads as a normalization error, .playback reads as an oversight, checking a setVoice return reads as paranoia. Without the ADR, the next maintainer 'fixes' them and reintroduces the exact failure the design exists to prevent.
- **[should]** License under Apache-2.0 with a NOTICE file, and state in README that the app name/icon are not covered by the code license.
  - The goal is that a stranger can fork and ship to Play under their own account after you stop. Apache-2.0 is permissive with an express patent grant and a trademark clause — the code transfers, the branding doesn't (which also protects users from a hostile fork trading on the original's privacy reputation). GPL-3.0 would obstruct store distribution and deter the casual maintainer you want; MPL-2.0 is a reasonable middle ground if keeping AAC-core improvements open matters more than adoption.
- **[should]** Ship docs/PRIVACY.md from day one as the single source of truth for the no-telemetry promise, and derive the Play Data Safety declaration from it.
  - The audience reads privacy labels adversarially, so the label and the code must not diverge. One committed file that says 'no network permission, no analytics, no accounts' makes the claim auditable against the manifest by anyone, and makes the Data Safety form a transcription rather than a judgement call each release.
- **[should]** Write a handwritten CHANGELOG.md in keepachangelog format. Skip conventional commits, commitlint, and semantic-release.
  - The changelog has two real consumers regardless of team size: Play release notes (which must be written anyway) and a stranger deciding whether the project is alive. The commit-convention tooling only pays off via changelog automation and multi-contributor triage, neither of which exists pre-open-sourcing. Adopt very_good_workflows' semantic_pull_request check if contributors ever arrive.
- **[avoid]** Skip: branch protection, PR-based workflow, CODEOWNERS, Codecov, issue templates, and a staging/beta track — until the repo is public.
  - All of these coordinate multiple humans. A solo dev on main with green CI gets the same safety at zero friction. They cost ~an hour each to add on the day you open-source, so adding them now is pure prepayment. Codecov specifically: its value is the PR comment, and there are no PRs — keep the local lcov gate instead, which fails the build without a network round-trip or a third-party account.
- **[should]** Add `--test-randomize-ordering-seed random` to the CI test command.
  - Free detection of inter-test state leakage, which matters disproportionately when tests are the only safety net and much of the suite touches a shared in-memory drift database.

### .github/workflows/ci.yml — the whole PR gate (format, analyze, codegen freshness, schema freshness, test + per-dir coverage, goldens, build)

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
    # Pinned, not -latest: goldens are byte-compared, so the runner image is part
    # of the contract. See docs/adr/0007-goldens-are-ci-authoritative.md
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v6

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          # Exact pin lives in .fvmrc; flutter-action reads it natively, so CI and
          # local fvm can never disagree. Ranges are NOT supported here.
          flutter-version-file: .fvmrc
          cache: true
          pub-cache: true

      - run: flutter --version
      - run: flutter pub get

      # --- Freshness gates -------------------------------------------------
      # Generated code is committed (docs/adr/0005-commit-generated-code.md).
      # These two steps are the entire mitigation for that decision.

      - name: Generated code is up to date
        run: |
          dart run build_runner build --delete-conflicting-outputs
          if ! git diff --exit-code -- '*.g.dart' '*.drift.dart'; then
            echo "::error::Generated code is stale. Run build_runner and commit the result."
            exit 1
          fi

      - name: drift schema dumps are up to date
        run: |
          dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
          if ! git diff --exit-code -- drift_schemas/; then
            echo "::error::drift_schemas/ is stale."
            echo "::error::You changed the schema without bumping schemaVersion + dumping."
            echo "::error::Shipping this means no migration runs and users lose their boards."
            exit 1
          fi

      # --- Static analysis --------------------------------------------------

      - run: dart format --output=none --set-exit-if-changed .

      # --fatal-infos: the a11y lints in analysis_options.yaml are only worth
      # having if they can fail a build.
      - run: flutter analyze --fatal-infos

      # --- Tests ------------------------------------------------------------

      - name: Test
        run: |
          flutter test --coverage \
            --test-randomize-ordering-seed random \
            --reporter expanded

      - name: Coverage floors
        run: |
          sudo apt-get update -qq
          sudo apt-get install -y -qq lcov
          bash tool/check_coverage.sh coverage/lcov.info

      - name: Upload coverage report on failure
        if: failure()
        uses: actions/upload-artifact@v6
        with:
          name: coverage-lcov
          path: coverage/lcov.info
          retention-days: 7

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

      # Unsigned. CI proves it compiles; releases are built and signed locally
      # for v1 (docs/RELEASE.md). No keystore in GitHub secrets.
      #
      # No --obfuscate and no --split-debug-info: the on-device exportable crash
      # log is the ONLY field signal this app will ever have, and both flags
      # strip the Dart names it depends on. See docs/adr/0006-no-obfuscation.md
      - name: Build app bundle (unsigned)
        run: flutter build appbundle --release

      - uses: actions/upload-artifact@v6
        with:
          name: app-release-unsigned-aab
          path: build/app/outputs/bundle/release/app-release.aab
          retention-days: 14

```

Action versions current as of 2026-07. No third-party actions beyond flutter-action. Goldens are pinned to ubuntu-24.04 and are authoritative.

### tool/check_coverage.sh — per-directory coverage floors with no third-party action

```bash
#!/usr/bin/env bash
# tool/check_coverage.sh — enforce per-directory line-coverage floors.
#
# Why not VeryGoodOpenSource/very_good_coverage? Archived 2026-03-31.
# Why not Codecov's gate? It needs a network round-trip and an account to fail
# a build. This script still works in 2030 with no upstream to rot.
#
# Usage: bash tool/check_coverage.sh [coverage/lcov.info]
set -euo pipefail

LCOV_FILE="${1:-coverage/lcov.info}"

if [[ ! -f "$LCOV_FILE" ]]; then
  echo "::error::$LCOV_FILE not found. Did 'flutter test --coverage' run?"
  exit 1
fi

# Strip generated + non-logic files. lcov 2.x (shipped on ubuntu-24.04) errors
# on unused --remove patterns, hence --ignore-errors unused.
FILTERED="$(mktemp)"
lcov --remove "$LCOV_FILE" \
  '*/*.g.dart' \
  '*/*.drift.dart' \
  '*/*.freezed.dart' \
  '*/generated/*' \
  '*/l10n/*' \
  --output-file "$FILTERED" \
  --ignore-errors unused >/dev/null

# prefix:floor -- ordered most-specific first.
#
# lib/data     100 : a botched migration is the loss of someone's voice. There is
#                    no telemetry and no server backup; the boards are
#                    hand-curated over months and unmergeable.
# lib/speech   100 : voice_filter + SpeechService. flutter_tts returns 0 with only
#                    a Log.d when setVoice fails. A gap here is a user tapping a
#                    tile mid-shutdown and getting silence.
# lib/          70 : presentation. Goldens cover layout; this is a floor, not a goal.
FLOORS=(
  "lib/data/:100"
  "lib/speech/:100"
  "lib/:70"
)

pct_for_prefix() {
  awk -v prefix="$1" '
    /^SF:/ { f = substr($0, 4); keep = (index(f, prefix) == 1); next }
    keep && /^DA:/ {
      split(substr($0, 4), a, ",")
      total++
      if (a[2] + 0 > 0) hit++
    }
    END {
      if (total == 0) { print "NA"; exit }
      printf "%.2f", (hit / total) * 100
    }
  ' "$FILTERED"
}

failed=0
for entry in "${FLOORS[@]}"; do
  prefix="${entry%%:*}"
  floor="${entry##*:}"
  pct="$(pct_for_prefix "$prefix")"

  if [[ "$pct" == "NA" ]]; then
    echo "::warning::no covered lines found under $prefix (floor ${floor}%)"
    continue
  fi

  if awk -v p="$pct" -v f="$floor" 'BEGIN { exit (p + 0 >= f + 0) ? 0 : 1 }'; then
    printf '  ok   %-14s %6s%%  (floor %s%%)\n' "$prefix" "$pct" "$floor"
  else
    printf '  FAIL %-14s %6s%%  (floor %s%%)\n' "$prefix" "$pct" "$floor"
    echo "::error file=$prefix::coverage ${pct}% is below the ${floor}% floor"
    failed=1
  fi
done

rm -f "$FILTERED"
exit "$failed"

```

Replaces the archived very_good_coverage. A single global percentage would let you pass at 85% with the migration path untested; these floors put 100% where a bug is unrecoverable.

### .github/workflows/update-goldens.yml — regenerate goldens on the CI runner, never on your Mac

```yaml
name: update-goldens

# macOS applies font smoothing that Linux runners don't, so goldens generated
# locally will fail on CI (flutter/flutter#36667). Rather than chase tolerances,
# goldens are ONLY ever generated on the CI runner. You never run
# --update-goldens on your own machine.
#
# Run this from the Actions tab after an intentional UI change, then review the
# committed PNGs by eye.

on:
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update:
    runs-on: ubuntu-24.04  # must match ci.yml exactly
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v6
        with:
          ref: ${{ github.ref_name }}

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
          cache: true
          pub-cache: true

      - run: flutter pub get

      - name: Regenerate goldens
        run: flutter test --update-goldens --tags golden

      - name: Show what changed
        run: git status --porcelain -- test/

      - name: Commit goldens
        run: |
          if git diff --quiet -- test/; then
            echo "No golden changes."
            exit 0
          fi
          git config user.name  "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add test/
          git commit -m "chore: update goldens (ubuntu-24.04)"
          git push

      - name: Upload goldens for eyeball review
        uses: actions/upload-artifact@v6
        with:
          name: goldens
          path: test/**/goldens/**/*.png
          retention-days: 14

```

Avoids the macOS-font-smoothing vs Linux golden mismatch entirely, with no Docker and no Alchemist. Run it from the Actions tab after an intentional UI change.

### test/flutter_test_config.dart — real fonts, so goldens actually prove text fits

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Flutter's test renderer defaults to the 'Ahem' font, which draws every glyph
// as a filled box. A golden rendered in Ahem cannot tell you whether
// "Overwhelmed" overflows its tile at TextScaler 3.0 -- which is the entire
// reason these goldens exist. Load the real font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await _loadFont('Inter', 'assets/fonts/Inter-Regular.ttf');
  await _loadFont('Inter', 'assets/fonts/Inter-SemiBold.ttf');

  // Fail loudly rather than silently emitting Ahem goldens.
  goldenFileComparator = LocalFileComparator(
    Uri.parse('${Directory.current.path}/test/'),
  );

  await testMain();
}

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
  await loader.load();
}

```

Without this, Flutter renders the Ahem font (solid boxes) and a passing golden proves nothing about a 200%-scaled label fitting in a tile.

### test/ui/board_grid_golden_test.dart — the goldens that make TextScaler a tested property, not a promise

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // TextScaler must be honoured at 200%+ and never clamped. That is a
  // correctness requirement, so it needs a gate, not discipline.
  // 3.0 is not paranoia: Android's font size + display size settings compound.
  for (final scale in <double>[1.0, 2.0, 3.0]) {
    testWidgets(
      'board grid at textScale ${scale}x',
      tags: 'golden',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const MaterialApp(home: BoardScreen()),
          ),
        );

        // Zero animation is a design rule, so pump() -- not pumpAndSettle() --
        // is sufficient. If this ever needs pumpAndSettle, something animated
        // and that is itself the bug.
        await tester.pump();

        await expectLater(
          find.byType(BoardScreen),
          matchesGoldenFile('goldens/board_grid_${scale}x.png'),
        );
      },
    );
  }
}

```

'Accessibility is correctness' only holds if a build can fail on it. This is that mechanism for the 200%+ requirement.

### .fvmrc + pubspec.yaml — where the pins live

```yaml
# .fvmrc  -- committed. flutter-action@v2 reads this natively.
# Must be an exact version; ranges are not supported by flutter-version-file.
{
  "flutter": "3.44.0"
}

# ---------------------------------------------------------------------------
# pubspec.yaml (excerpt)

name: offline_aac
description: Offline AAC board for situational speech loss. No network, ever.

# 1.0.0 = versionName, +7 = versionCode.
#
# Bumped by hand in the release commit. NOT derived from github.run_number:
# run_number resets if the workflow file is renamed, and a Play versionCode is
# permanently consumed even by a deleted release -- a reset silently makes every
# subsequent build unuploadable. The committed number is also what a successor
# reads; they will not have your Actions history.
version: 1.0.0+7

publish_to: none

environment:
  # Ranges here, exact pin in .fvmrc. Pinning exact versions in pubspec only
  # manufactures unsolvable conflicts on the next SDK upgrade.
  sdk: ^3.9.0
  flutter: '>=3.44.0'

dependencies:
  flutter:
    sdk: flutter
  drift: ^2.28.0
  flutter_riverpod: ^3.0.0
  flutter_tts: ^4.2.0
  audio_session: ^0.2.0
  path_provider: ^2.1.5
  sqlite3_flutter_libs: ^0.5.32

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.15
  drift_dev: ^2.28.0
  flutter_lints: ^6.0.0

# Caret ranges + a COMMITTED pubspec.lock is the app answer (packages ship no
# lock and so need wide ranges; apps get reproducibility from the lock).
# Delete the `pubspec.lock` line that github/gitignore's Dart template ships with.

```

The exact Flutter pin goes in .fvmrc (read by both fvm and flutter-action). pubspec keeps normal ranges so pub can still solve. versionCode is committed, never derived from run_number.

### renovate.json — pub updates, SDK bumps, and a hard block on the two packages CI cannot vouch for

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended", ":semanticCommitsDisabled"],
  "timezone": "Europe/Amsterdam",
  "schedule": ["before 9am on monday"],
  "prConcurrentLimit": 3,
  "labels": ["dependencies"],

  "packageRules": [
    {
      "description": "Batch dev-only bumps; they cannot reach a user.",
      "matchManagers": ["pub"],
      "matchDepTypes": ["dev_dependencies"],
      "groupName": "dev dependencies",
      "automerge": true
    },
    {
      "description": [
        "NEVER automerge the speech surface. flutter_tts returns 0 with only a",
        "Log.d when setVoice fails, and audio_session decides whether the silent",
        "switch mutes the app. A minor bump can change either with no test in the",
        "suite able to observe it -- there is no telemetry, so a regression here",
        "is discovered by a user in crisis tapping a tile and getting silence.",
        "Requires docs/RELEASE_CHECKLIST.md on a real device before merge."
      ],
      "matchManagers": ["pub"],
      "matchPackageNames": ["flutter_tts", "audio_session"],
      "automerge": false,
      "labels": ["dependencies", "needs-device-test"],
      "prBodyNotes": [
        "**Do not merge on green CI alone.** No automated test in this repo can",
        "observe whether a real device produced sound. Run",
        "`docs/RELEASE_CHECKLIST.md` sections 1-3 on hardware, with the ringer",
        "switch OFF, before merging."
      ]
    },
    {
      "description": "drift bumps regenerate committed code and touch the schema.",
      "matchManagers": ["pub"],
      "matchPackageNames": ["drift", "drift_dev", "sqlite3_flutter_libs"],
      "groupName": "drift",
      "automerge": false,
      "labels": ["dependencies", "needs-migration-review"]
    }
  ],

  "customManagers": [
    {
      "description": "Bump the Flutter SDK pin in .fvmrc (Dependabot cannot do this at all).",
      "customType": "regex",
      "managerFilePatterns": ["/^\\.fvmrc$/"],
      "matchStrings": ["\"flutter\"\\s*:\\s*\"(?<currentValue>[^\"]+)\""],
      "datasourceTemplate": "flutter-version",
      "depNameTemplate": "flutter",
      "packageNameTemplate": "flutter/flutter",
      "versioningTemplate": "semver"
    }
  ]
}

```

Dependabot has never supported pub (dependabot-core#2166, closed). The flutter_tts / audio_session rule is the load-bearing part: green CI is not evidence of audio.

### .gitignore and .gitattributes — the two edits that make committed codegen painless

```bash
# ---------------------------------------------------------------------------
# .gitattributes
# ---------------------------------------------------------------------------
# Generated code IS committed (docs/adr/0005). These two lines remove the only
# real cost: GitHub collapses these files in diffs by default and drops them
# from the repo's language statistics. A drift migration diff stays readable.
*.g.dart        linguist-generated=true
*.drift.dart    linguist-generated=true
*.freezed.dart  linguist-generated=true

# Goldens are binary and only ever regenerated by CI. Never merge them.
*.png binary -merge

# ---------------------------------------------------------------------------
# .gitignore
# ---------------------------------------------------------------------------
# Based on github/gitignore Dart.gitignore + Flutter template, WITH ONE
# DELIBERATE DEVIATION, see below.

.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
doc/api/

# NOTE: the upstream Dart.gitignore lists `pubspec.lock` here, with the comment
# "If you're building an application, you may want to check-in your
# pubspec.lock". We ARE an application, so the lock is COMMITTED and that line
# is deliberately absent. The lock is the only thing that makes a stranger's
# clone resolve the exact flutter_tts / drift versions that were tested against
# a real device. Do not re-add it.

# fvm: the config is committed, the SDK symlink is not.
.fvm/flutter_sdk
.fvm/versions

# Android
/android/app/debug
/android/app/profile
/android/app/release
/android/key.properties
*.jks
*.keystore

# iOS
/ios/Flutter/Flutter.framework
/ios/Flutter/Flutter.podspec
/ios/Pods/
/ios/.symlinks/

# Coverage
coverage/

# Editors
.idea/
*.iml
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
.DS_Store

```

The standard github/gitignore Dart template ignores pubspec.lock — wrong for an app. linguist-generated collapses .g.dart in diffs, which removes the main objection to committing them.

### android/app/build.gradle.kts — R8 off, on purpose, with the reason in the file

```kotlin
android {
    namespace = "dev.example.offline_aac"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "dev.example.offline_aac"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode  // from pubspec `version: x.y.z+N`
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // v1 ships release builds signed with a LOCAL upload key
            // (docs/RELEASE.md). CI builds are unsigned; the keystore is never
            // in GitHub secrets.
            signingConfig = signingConfigs.getByName("upload")

            // R8 IS DELIBERATELY OFF. This is a decision, not an oversight --
            // do not "fix" it. See docs/adr/0008-no-r8-for-v1.md
            //
            // A missing keep rule does not fail the build; it fails at RUNTIME,
            // when a reflectively-resolved class is gone. In this app that means
            // a user taps a tile mid-shutdown and nothing is spoken -- the worst
            // bug class we have, and one we would never learn about because
            // there is no telemetry, by design and by promise.
            //
            // The payoff would be a few hundred KB on a 12-tile app with no
            // heavy dependencies. That is not a trade worth making.
            //
            // If this is ever revisited: R8 writes suggested rules to
            //   build/app/outputs/mapping/release/missing_rules.txt
            // and you MUST archive mapping.txt per release, plus re-run the full
            // on-device checklist -- unit tests cannot catch a stripped class.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

```

A missing R8 keep rule fails at runtime, not at build time — which in this app means a tile tap producing no speech. Explicit-and-commented beats relying on a template default the next maintainer will 'fix'.

### docs/adr/0001-grid-slots-position-is-the-primary-key.md — the ADR template, and the one that matters most

```markdown
# 1. grid_slots: position is the primary key

- Status: accepted
- Date: 2026-07-15
- Deciders: @zakariafatahi

## Context

Users hand-curate a 3x4 board of phrase tiles over months. Muscle memory is the
entire point: in a shutdown, the user does not read the grid, they reach for
"the bottom-left one". A tile that MOVES is worse than a tile that is missing,
because the user presses it and says the wrong thing at the worst moment.

The obvious schema -- a `buttons` table with an `order` column, or a
`grid_slots` table with a surrogate `id` -- makes reflow *possible*. Every
ordered-list schema eventually reflows: a delete shifts everything up, a
reordering bug shifts everything sideways, a botched migration renumbers. You
then defend against it with application logic, and the defense is one forgotten
`WHERE` clause from failing silently.

## Decision

`grid_slots` uses `PRIMARY KEY (board_id, row, col)` with a **nullable**
`button_id`.

Position is not an attribute of a tile. Position is the identity of the slot.
An empty cell is a row with `button_id IS NULL`, not an absent row. Deleting a
button nulls a slot; it cannot shift its neighbours, because a neighbour's
identity is its coordinates and nothing can renumber coordinates.

## Consequences

- Tile reflow is structurally impossible. Not "prevented by a test" -- there is
  no schema-legal way to express it. This is the point.
- A nullable FK inside a composite PK **looks like a normalization mistake.** It
  is not. If you are reading this because you were about to introduce a
  surrogate `id` and an `order` column: that change reintroduces the exact
  failure this schema exists to prevent, and no test will catch it because the
  bug only manifests as a real person saying the wrong sentence.
- Grids are fixed-size, so the row count is bounded (12/board). Storing empty
  slots costs nothing.
- Board resize is not supported and is not planned. If it ever is, it is a
  migration that inserts/deletes slot rows, not a reordering.

## Alternatives rejected

- **`buttons.order` integer**: reflow on delete is the default behaviour. Would
  need defending in every query.
- **Surrogate `grid_slots.id`**: permits two rows claiming the same (row, col).
  The DB should not be able to represent an impossible board.

```

This is the highest-leverage artifact in the repo. The decision looks like a normalization error to any competent reviewer, which is exactly why it needs a written defense that outlives you.

### docs/RELEASE.md — the minimum viable v1 release, and why there is no fastlane

```markdown
# Releasing

v1 is released **from a laptop**, by hand. This is a deliberate choice, not a
TODO. See "Why not automated" below before adding fastlane.

## Steps

1. `git checkout main && git pull` -- confirm CI is green.
2. Bump `version:` in `pubspec.yaml` (e.g. `1.0.0+7` -> `1.0.1+8`).
   - The `+N` build number is the Play **versionCode**. It must strictly
     increase and is **permanently consumed** even by a deleted release. Never
     reuse one.
3. Update `CHANGELOG.md` (move items out of `## [Unreleased]`). These lines are
   the Play release notes -- write them for a user, not a developer.
4. Commit: `chore(release): 1.0.1+8`. Tag: `git tag v1.0.1 && git push --follow-tags`.
5. `flutter build appbundle --release`
   - **No `--obfuscate`. No `--split-debug-info`.** See
     `docs/adr/0006-no-obfuscation.md`. Both strip the Dart function names that
     the on-device exportable crash log depends on, and that log is the only
     field signal this app will ever have.
6. Run `docs/RELEASE_CHECKLIST.md` on a **real device**, ringer switch OFF.
   Do not skip. No automated test in this repo can observe whether sound came out.
7. Upload `build/app/outputs/bundle/release/app-release.aab` to the Play Console
   **internal testing** track. Paste the changelog entry as release notes.
8. Attach the .aab to the GitHub Release for the tag, so the artifact for any
   version outlives the Play Console account.

## Signing

- Play App Signing is **enrolled**. Google holds the app signing key; this
  keystore is only the *upload* key.
- The upload key is therefore **replaceable** -- if it is lost, Google support
  resets it. Nothing about a user's data depends on it.
- The users' boards are **not** replaceable. There is no server, no account and
  no backup. That asymmetry is the whole reason migration tests are a gate.
- Keystore lives in 1Password + an offline backup. It is NOT in GitHub secrets:
  CI builds unsigned, so there is no signing secret to leak.
- `android/key.properties` is gitignored. Template in `docs/key.properties.example`.

## Why not automated

fastlane `supply` and `r0adkll/upload-google-play` both work fine. Neither is
worth it here:

- The MVP ships to internal testing maybe six times. Automation costs more hours
  than it saves, and every hour spent on the pipeline is an hour not spent on
  the migration tests that are the actual safety net.
- Automating it means putting the keystore and a Play service-account JSON into
  CI secrets -- a real attack surface bought for a two-minute manual step.
- **The succession argument cuts against automation, not for it.** A stranger
  forking this app after it is abandoned will have their own Play account, their
  own service account and their own signing key. Release automation is precisely
  the part of this repo they cannot reuse. A README they can read beats a
  pipeline they must dismantle.

Revisit if releases become frequent enough that step 7 is the bottleneck. It
won't be.

```

This doubles as the succession document. Note the deliberate reasoning that release automation is the one part of the repo a successor cannot reuse.

### docs/RELEASE_CHECKLIST.md — what replaces emulator integration tests

```markdown
# Pre-release device checklist

Run on a **real phone**. Every item below is something a CI emulator cannot
verify -- an emulator's TTS is not a device's TTS. This checklist is not a
placeholder for an integration-test suite we haven't written yet; it is the
deliberate replacement for one. See `docs/adr/0009-no-emulator-tests-in-ci.md`.

## 1. Speech actually happens

- [ ] Tap all 12 tiles. **Audible speech** on each. (Not "no exception thrown".)
- [ ] Type in the field, hit speak. Audible.
- [ ] Set the ringer/silent switch to **SILENT**, tap a tile. **Still audible.**
      (If not: the audio session regressed to `.ambient`. This is the bug that
      makes the app useless in the exact meeting where you need it.)
- [ ] Start a YouTube video, then tap a tile. Other audio **ducks**, speech is
      clearly audible over it, other audio resumes.

## 2. Voices did not silently vanish

- [ ] Settings -> voice picker lists only voices that actually work.
- [ ] Pick each listed voice, speak. Audible for **every** one.
      (`flutter_tts` `setVoice` returns 0 with only a `Log.d` on failure --
      a voice can be listed and silently do nothing.)
- [ ] **Turn wifi and mobile data OFF.** Repeat the above. Any network-required
      voice must be gone from the list, not present-and-mute.
- [ ] In Android TTS settings, uninstall a voice the app has selected. Reopen
      the app, tap a tile. Falls back to a working voice **audibly** -- never
      silence.

## 3. Accessibility

- [ ] TalkBack on: swipe through all 12 tiles. Each announces its **label**
      ("Overwhelmed"), not its vocalization.
- [ ] TalkBack double-tap speaks the **vocalization** ("I need to leave...").
- [ ] Switch Access: can reach and activate every tile and the text field.
- [ ] System font size to max + display size to max. Grid still 3x4, no label
      clipped, no overflow stripe.

## 4. Data survives

- [ ] Install the **previous** released version, create/edit tiles, then
      install this build over it. **Every board is intact.**
      (This is the one that matters. There is no backup and no server.)
- [ ] Quick Settings tile speaks with the app force-stopped (no Flutter engine).

## 5. Crash log

- [ ] Trigger a known crash in a debug build; export the log.
- [ ] The stack trace has **readable Dart function names**. If it shows hex
      offsets, `--split-debug-info` or `--obfuscate` crept into the build and
      the only field signal this app has is dead.

```

This is the honest artifact. Every item here is something a CI emulator structurally cannot verify, which is the argument for not building that CI job at all.

### README.md — the structure that lets a stranger pick this up

```markdown
# Offline AAC

A one-screen communication board for autistic adults with situational or
part-time speech loss. Twelve phrase tiles and a type-to-speak field. Speaks
on-device. No accounts, no server, no network permission.

A tile **shows** "Overwhelmed" and **speaks** "I need to leave, I'm not able to
talk right now." Those are two different strings, on purpose
(`docs/adr/0002-label-is-not-vocalization.md`).

## Status

Maintained: <yes/no -- keep this line honest>. Licensed Apache-2.0 so that if
it says "no", you can fork it, ship it under your own Play account, and not ask
anyone's permission. That is the intended end state, not a failure mode.

## Run it

```sh
dart pub global activate fvm   # optional; .fvmrc pins the SDK
fvm install && fvm use
flutter pub get
flutter run
```

Generated code (`*.g.dart`, `*.drift.dart`) **is committed**, so this works
without a `build_runner` round-trip (`docs/adr/0005`). If you change the schema:

```sh
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
```

CI fails if you forget either.

## Read this before changing anything

`docs/adr/` -- ~6 short files. Several decisions in this codebase **look wrong**
and are load-bearing:

- `grid_slots` has a nullable FK inside a composite primary key. Not a mistake:
  it makes tile reflow structurally impossible (ADR 0001).
- The audio session is `.playback`, never `.ambient`. Not an oversight: `.ambient`
  lets the silent switch mute the app (ADR 0004).
- `voice_filter` checks `setVoice`'s return value. Not paranoia: `flutter_tts`
  returns 0 with only a `Log.d` on failure (ADR 0003).
- Riverpod is used for twelve tiles and a text field. It is **not** load-bearing;
  it is a testable seam. `ValueNotifier` would work (ADR 0010).

If you "clean up" any of these, you reintroduce the exact failure it prevents,
and **no test and no crash report will tell you** -- see Non-goals.

## Non-goals

These are refused, not un-built:

- **No telemetry, no analytics, no crash reporting.** Not Firebase, not Sentry.
  The audience reads privacy labels adversarially and the promise is the product
  (`docs/PRIVACY.md`). The consequence is deliberate and severe: **nobody will
  ever learn that this app crashed on a user's phone.** That is why the coverage
  floor on `lib/data` and `lib/speech` is 100% and why `docs/RELEASE_CHECKLIST.md`
  is not optional. Tests are the only safety net that exists.
- **No animation.** Latency and distress. The UI is deterministic.
- **No accounts, no sync, no cloud backup.** Boards are irreplaceable *because*
  of this. That is the trade.
- **No network permission at all.** Check the manifest; it is the only claim in
  `docs/PRIVACY.md` a user can verify themselves.

## Layout

```
lib/data/     drift DB, migrations   -- 100% coverage floor, migrations are a safety gate
lib/speech/   SpeechService, voice_filter -- 100% floor, silence is the worst bug
lib/ui/       one screen             -- goldens cover TextScaler 1x/2x/3x
docs/adr/     why things are the way they are
```

## License

Apache-2.0. The name and icon are not covered -- fork the code, pick your own
name.

```

Non-goals and the ADR pointer are the load-bearing sections. A stranger's first instinct will be to add the things this app deliberately omits.

### .github/workflows/release.yml — only if you later decide to sign in CI

```yaml
name: release

# NOT USED FOR v1 -- docs/RELEASE.md ships from a laptop on purpose.
# Kept here so the option is a decision rather than a research task.
# Adopting this means accepting a keystore + Play service account in GH secrets.

on:
  push:
    tags: ['v*']

permissions:
  contents: write   # to create the GitHub Release

jobs:
  android:
    runs-on: ubuntu-24.04
    timeout-minutes: 25
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

      - name: Decode upload keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: |
          echo "$KEYSTORE_BASE64" | base64 --decode > android/app/upload-keystore.jks
          # Sanity-check the decode; an empty/corrupt file yields an unsigned
          # build that fails only at upload time.
          test -s android/app/upload-keystore.jks

      - name: Write key.properties
        env:
          STORE_PASSWORD: ${{ secrets.ANDROID_STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
        run: |
          cat > android/key.properties <<EOF
          storeFile=upload-keystore.jks
          storePassword=${STORE_PASSWORD}
          keyAlias=${KEY_ALIAS}
          keyPassword=${KEY_PASSWORD}
          EOF

      # versionCode comes from pubspec (`version: 1.0.1+8`), NOT from
      # github.run_number -- run_number resets when a workflow is renamed, and a
      # Play versionCode is permanently consumed even by a deleted release.
      # No --obfuscate / --split-debug-info: see docs/adr/0006.
      - name: Build app bundle
        run: flutter build appbundle --release

      - name: Clean up signing material
        if: always()
        run: rm -f android/app/upload-keystore.jks android/key.properties

      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          gh release create "${{ github.ref_name }}" \
            build/app/outputs/bundle/release/app-release.aab \
            --title "${{ github.ref_name }}" \
            --notes "See CHANGELOG.md"

      # Play upload deliberately NOT automated. Uploading to a live track is the
      # one step where a human should have to look at what they are shipping --
      # there is no telemetry to catch a bad release afterwards, and no server to
      # roll back. Run docs/RELEASE_CHECKLIST.md first, then upload the .aab from
      # the Release page by hand.
      #
      # If that ever changes:
      #   - uses: r0adkll/upload-google-play@v1
      #     with:
      #       serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
      #       packageName: dev.example.offline_aac
      #       releaseFiles: build/app/outputs/bundle/release/app-release.aab
      #       track: internal
      #       status: completed

```

Provided for completeness; docs/RELEASE.md recommends against it for v1. Includes the keystore-in-secrets pattern and the cleanup step people forget.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PROJECT THESE PRACTICES ARE FOR ===

An offline AAC (augmentative & alternative communication) app for autistic adults with situational/part-time speech loss. Flutter, Android-first, iOS later. Solo developer. Today is 2026-07-15; Flutter stable is 3.44.0, Dart 3.x.

The app: ONE screen — a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface + on-device TTS. A "show text" full-screen mode. An explicit edit mode. Settings (voice/pitch/rate/output mode/theme). No accounts, no server, no network.

DECISIONS ALREADY MADE (from a prior deep research pass — do not re-litigate these, design practices AROUND them):
- **drift** (SQLite) for local DB. Schema: boards / buttons / grid_slots / images / sounds / settings. Critically, `grid_slots` has PRIMARY KEY (board_id, row, col) with a NULLABLE button_id — position IS the primary key, so tile reflow is structurally impossible. Data model borrows Open Board Format semantics (label != vocalization: the tile SHOWS "Overwhelmed" but SPEAKS "I need to leave, I'm not able to talk right now").
- **flutter_riverpod** for state — explicitly acknowledged as NOT load-bearing (12 tiles and a text field; ValueNotifier would work). Chosen for a testable seam between repository and UI, and to react to MediaQuery a11y flags + TTS voice-availability changes.
- **flutter_tts** wrapped behind an abstract `SpeechService` (speak/stop/voices), with a `voice_filter` (Android network_required check + setVoice return-value check — flutter_tts returns 0 with only a Log.d on failure, which would silently give a user in crisis NO SPEECH) and an `audio_session` config (iOS .playback + duckOthers; NEVER .ambient).
- Native platform channels needed for: Personal Voice (iOS), an Android Quick Settings TileService (Kotlin, speaks natively from SharedPreferences with NO Flutter engine on that path), an iOS 18 ControlWidget (Swift).
- Images/sounds are FILES ON DISK with paths in the DB, never BLOBs.

=== THE CONSTRAINTS THAT MAKE THIS PROJECT'S ENGINEERING UNUSUAL ===

1. **NO TELEMETRY, EVER.** No Firebase, no Crashlytics, no Sentry, no analytics — the privacy promise forbids it and the audience reads privacy labels adversarially. THE DEVELOPER WILL NEVER LEARN THAT THE APP CRASHED IN THE FIELD. Tests are the ONLY safety net. This should raise the bar on testing dramatically and change what is worth testing. There is a planned on-device-only, user-exportable crash log.
2. **A BOTCHED DB MIGRATION IS THE LOSS OF SOMEONE'S VOICE.** Users hand-curate phrase boards over months; that data is irreplaceable and unmergeable. Migration testing is a safety property, not hygiene.
3. **ACCESSIBILITY IS CORRECTNESS, NOT POLISH.** An inaccessible accessibility app is a total failure. Semantics on every tile; iOS Switch Control / Android Switch Access / VoiceOver / TalkBack must work; TextScaler must be honored at 200%+ and never clamped. This must be enforced by TESTS and lints, not by discipline.
4. **A SILENT FAILURE IS THE WORST BUG CLASS.** An unchecked setVoice return, a voice that vanished, an audio session misconfigured to .ambient so the silent switch mutes the app — each means a user taps a tile mid-shutdown and NOTHING happens. Error handling must make silence impossible.
5. **The developer may abandon this** (it is app #N of a 50-app challenge). The offline architecture means it keeps working unmaintained; open-sourcing is the exit plan. So the code must be READABLE BY A STRANGER and the docs must let someone else pick it up.
6. **Solo dev, ~2-week MVP.** Practices must be proportionate. Ceremony that a team needs and a solo dev doesn't is a real cost. Be honest about what to SKIP.
7. Zero animation is a design rule (distress + latency). Deterministic UI.

Today's date: 2026-07-15. Prefer 2025-2026 sources. Flutter and its ecosystem move fast — a 2022 blog post is probably wrong.


YOUR DIMENSION: CI, release process, and repo hygiene for a solo Flutter dev.

Research with WebSearch/WebFetch: GitHub Actions for Flutter (subosito/flutter-action — current version/status), Codemagic, fastlane, Very Good Workflows, Flutter's own CI docs, Play Console / App Store Connect automation.

- **A concrete GitHub Actions workflow for a Flutter app in 2026**: format check, analyze, test with coverage, build. Get the CURRENT action versions (actions/checkout@v?, subosito/flutter-action@v?) and caching approach. Write the actual YAML.
- Can CI run: unit tests (yes), widget tests (yes), golden tests (platform issues — how?), integration tests (needs an emulator — reasonable in CI? which action? how slow? worth it?)
- Coverage reporting without a paid service: lcov, genhtml, excluding generated files, GitHub Actions coverage comment actions. Is Codecov still free for OSS?
- **Release**: Android signing (keystore, upload key, Play App Signing), `flutter build appbundle`, version/build number management (pubspec version, `--build-number`), Play Console internal testing track. What's the minimum viable release pipeline for a solo dev? Is fastlane worth it or is manual upload fine for v1?
- `--obfuscate --split-debug-info` — should this app obfuscate? (Consider: open-sourcing is the exit plan, and stack traces from the on-device crash log must be readable. That's a real tension — argue it.)
- R8/ProGuard issues with Flutter plugins.
- Reproducible builds / Flutter version pinning in CI (fvm? .fvmrc? the flutter-action version input? What's the 2026 answer?)
- **Repo hygiene**: .gitignore for Flutter (what's actually in the standard one, and should generated .g.dart files be committed? argue both sides — note drift/riverpod codegen), README structure, CHANGELOG (keepachangelog?), conventional commits — worth it for a solo dev? ADRs (architecture decision records) — worth it for a solo dev whose exit plan is open-sourcing?
- Dependency hygiene: `dart pub outdated`, Dependabot/Renovate for pub, pinning vs caret ranges in pubspec. What's right for an app (vs a package)?
- **Given the exit plan is open-sourcing**: what must be in the repo from day one so a stranger can pick it up? (LICENSE choice, CONTRIBUTING, docs?) What license fits an app whose goal is to outlive the author?

Write real, current YAML and real file contents.
````

</details>
