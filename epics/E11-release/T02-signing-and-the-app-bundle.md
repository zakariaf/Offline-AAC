# E11-T02 — Signing and the app bundle

| | |
|---|---|
| **Epic** | E11 — Release |
| **Status** | In progress — repo config landed (signingConfigs from git-ignored key.properties, minify off, versioning rule, key.properties.example, RELEASE.md). Manual, off-repo: create the upload keystore, enrol in Play App Signing, build + sign + upload the .aab, attach it to the GitHub Release. |
| **Size** | S |
| **Depends on** | E01-T04, E11-T03 |
| **Blocks** | E11-T04 |

**Skills:** `reed-release-android` · `reed-ci-workflow`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Reed cannot ship without a signed `.aab`, and the way it gets signed decides whether anyone can ever read a crash log from the field. There is no telemetry and there never will be — the only field signal that will ever exist is the on-device, user-exportable crash log, pasted to the developer by a user who could not speak when the app failed them. `--obfuscate`, `--split-debug-info` and R8 each destroy that signal, and R8 destroys it in the exact shape this app cannot tolerate: a tile tap that produces no speech, at runtime, with a green build. This task sets the signing and bundle configuration once so those flags cannot creep back in by accident.

## Scope

**Play App Signing.** Enrol. Google holds the app signing key; the local `.jks` is only the **upload** key. Act on the asymmetry: a lost upload key is a support ticket to Google; a lost board is months of someone's hand-curated phrases and is irreplaceable. Optimise the process for the boards, not for the key.

**The keystore and `key.properties`.** Both git-ignored, both kept **outside the repo tree entirely**, plus a copy in an offline backup.

```properties
# android/key.properties — NEVER committed
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

**`android/app/build.gradle.kts`.** Load the properties, wire the release `signingConfig`, and pin minification off with a comment that says it was decided:

```kotlin
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // DELIBERATE. Do not enable R8: a missing keep rule does not fail
            // the build, it fails at runtime as a tile tap that makes no sound.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}
```

Note the `if (keystorePropertiesFile.exists())` guard is what lets CI's `build-android` job build unsigned without a keystore. Do not remove it, and do not put the keystore in GitHub secrets — CI proves it compiles, and a repo with no signing secret has no signing secret to leak.

**Versioning.** `version: 1.0.1+8` in `pubspec.yaml` is the whole system: `+N` becomes `versionCode`, `1.0.1` becomes `versionName`. Bump `+N` by exactly **1 per upload attempt**, including attempts Play rejects. Burned numbers stay burned. Never derive `versionCode` from `github.run_number`, a timestamp, or a git commit count.

**The build command.** Exactly this, no flags:

```sh
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

**The internal testing track.** Upload the `.aab` by hand to the Play internal track. Then attach **the same `.aab`** to the GitHub Release for the tag — the Play account is mortal and the git repo is the succession plan; an artifact that lives only in the Play Console dies with the account.

**Explicitly OUT of scope:** fastlane, `r0adkll/upload-google-play`, a `release.yml` workflow, any Play Console API wiring, a Play service-account JSON, `proguard-rules.pro`, deferred components / Play Feature Delivery, `--bundle-sksl-path` or shader warmup, and any crash/analytics SDK "just for releases". All refused, with reasons, in `reed-release-android`. The full manual on-device pass and the release-notes/store copy are separate tasks; this task only makes a correctly signed, correctly versioned bundle exist.

## Acceptance criteria

- [ ] `git check-ignore android/key.properties` and `git check-ignore` on the `.jks` path both exit 0; `git log --all -- android/key.properties '*.jks'` returns nothing.
- [ ] `grep -c jks .gitignore` — the keystore pattern is present, and the actual `.jks` file lives outside the repo tree (verify: `ls` its path, confirm it is not under the repo root).
- [ ] `flutter build appbundle --release` produces `build/app/outputs/bundle/release/app-release.aab`.
- [ ] The bundle is signed with the upload key, not a debug key: `jarsigner -verify -verbose -certs` (or `bundletool`) on the `.aab` shows the `upload` alias, not `CN=Android Debug`.
- [ ] `android/app/build.gradle.kts` contains `isMinifyEnabled = false` and `isShrinkResources = false` with the explanatory comment; `android/app/proguard-rules.pro` does not exist.
- [ ] `pubspec.yaml` has a `version: x.y.z+N` line with an explicit `+N`; the number is committed, not computed.
- [ ] No `--obfuscate` and no `--split-debug-info` appear anywhere: `grep -rn -- '--obfuscate\|--split-debug-info' . --exclude-dir=.git` returns only the comments that forbid them.
- [ ] The Play Console shows the app enrolled in Play App Signing and the build live on the internal track.
- [ ] The same `.aab` byte-for-byte is attached to the GitHub Release for the tag.
- [ ] CI still passes with no keystore present — the `build-android` job in `.github/workflows/ci.yml` completes `flutter build appbundle --release` and uploads `app-release-unsigned-aab`.

## Traps

- **Deriving `versionCode` from `github.run_number`.** It is per-workflow-file and resets to 1 when the workflow is renamed or recreated. A Play `versionCode` is monotonic and is **permanently consumed even by a release that is later deleted** — after a reset every subsequent build is unuploadable until you manually jump past the high-water mark, and nothing tells you until Play rejects the upload. The committed number is also the one a successor reads; they will not have your Actions history.
- **Not bumping after a rejected upload.** Play burns the `versionCode` on the attempt, not on the success. Reusing it fails the next upload for a reason that reads like a Console bug.
- **Enabling R8 "for size".** A missing keep rule does not fail the build. It fails at runtime, silently: the TTS plugin's engine binding, the SQLite native loader, anything reached through a platform channel or declared in the manifest — precisely what R8 strips when nobody wrote a rule. The analyzer and the test suite cannot see an R8 strip. The win is a negligible number of KB on a 12-tile app with almost no Java/Kotlin.
- **Adding `--obfuscate` because it sounds like hardening.** It does not encrypt resources and does not prevent reverse engineering — it renames symbols. Reed's exit plan is publishing the source under Apache-2.0; there is nothing to protect. It also breaks `runtimeType.toString()` matching, a silent-failure vector in a codebase whose worst bug class is silence.
- **Adding `--split-debug-info` alone and not publishing the symbols.** Recovering names needs `flutter symbolize -i trace -d app.android-arm64.symbols` — the exact per-build, per-architecture file. After the developer stops, nobody holds it, and every crash report ever filed becomes permanently unreadable. The one escape hatch, if size ever genuinely forces it: `--split-debug-info` **without** `--obfuscate`, with the entire symbols directory attached to the GitHub Release for that tag. Never publish one without the other.
- **Putting the keystore in GitHub secrets so CI can sign.** CI's job is to prove it compiles. Signing in CI adds a leakable secret and buys nothing, since the upload is manual anyway.
- **Committing `key.properties` in the first Android commit and deleting it later.** It stays in the history. Check `git log --all` before assuming it is clean.
- **Removing the `keystorePropertiesFile.exists()` guard** while tidying the Gradle file. CI has no `key.properties`; the guard is the only reason `build-android` compiles.
- **Treating a green CI run as clearance to upload.** CI cannot verify that this app speaks. Emulator images commonly ship with no TTS engine or voice data, and — the reason that actually matters — there is **no supported hook to capture or assert PCM output** from Android `TextToSpeech`. `integration_test` can assert a channel call was issued; it cannot assert sound came out. The manual pass on a real phone, ringer switch **off**, is load-bearing infrastructure, not a chore.
- **Skipping the readable-trace check on device.** The on-device pass must trigger a crash, export the log, and confirm the trace shows readable Dart function names. Hex offsets where names should be mean a flag crept back in and the field signal is dead — a release blocker, not a nit.
- **Pasting a user's crash log anywhere public.** The exported log can capture vocalization text — the sentences someone typed during a shutdown. Treat every received log as sensitive personal data: never into an issue, a PR, or a release thread.

## Files

- `android/app/build.gradle.kts` — `signingConfigs`, release `buildType`, `isMinifyEnabled = false`, `isShrinkResources = false`.
- `android/key.properties` — created locally, never committed.
- `.gitignore` — patterns for `key.properties` and `*.jks`.
- `pubspec.yaml` — the `version: x.y.z+N` line.
- The upload keystore `.jks` — created outside the repo tree, backed up offline.
- `README` release section — the sequence, the version rule, and why there is no automation. (Not a workflow file: `.github/workflows/ci.yml` is the only workflow and is not touched by this task.)

## Done when

A locally built, upload-key-signed `app-release.aab` with a committed `x.y.z+N` version is live on the Play internal track, the same file is attached to the GitHub Release for its tag, and nothing in the repo can enable obfuscation, split-debug-info, or R8 without deleting a comment that says not to.
