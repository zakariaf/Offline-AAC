---
name: reed-release-android
description: Ships a Reed release to Google Play — `flutter build appbundle --release`, the upload keystore and Play App Signing, the `version: x.y.z+N` versionCode rule, the internal testing track, and the standing refusal of `--obfuscate`, `--split-debug-info`, R8, and fastlane. Use when editing `android/app/build.gradle.kts` signingConfigs or minifyEnabled, creating `key.properties` or a `.jks`, bumping the build number in `pubspec.yaml`, tagging a release, or uploading an `.aab` to the internal track.
---

# Releasing Reed to Android

Build and sign on the laptop. Upload by hand. This is a decision that has already been made, not a gap waiting for automation.

Reed has **no telemetry and never will** — no Crashlytics, no Sentry, no analytics. Nobody will ever learn the app crashed in the field, because a user who cannot speak does not file a bug report. That single fact decides most of what follows. The only field signal that will ever exist is the on-device, user-exportable crash log, read by the user and pasted to the developer. Anything that makes that log unreadable is a total loss of the feedback loop.

## The release sequence

Run in this order, every time. Steps 3 and 5 are not optional.

```sh
# 1. Bump `version: 1.0.1+8` in pubspec.yaml. Commit. Tag (e.g. v1.0.1).
# 2. Build the bundle.
flutter build appbundle --release
# 3. Run the manual on-device pass on a REAL phone, ringer switch OFF.
# 4. Upload build/app/outputs/bundle/release/app-release.aab to the Play internal track.
# 5. Attach the same .aab to the GitHub Release for the tag.
```

Step 5 exists because the Play account is mortal and the git repo is the succession plan. An artifact that lives only in the Play Console dies with the account.

## Versioning

`version: 1.0.1+8` in `pubspec.yaml` is the whole system. The `+N` becomes `versionCode`; the `1.0.1` becomes `versionName`.

**Never derive versionCode from `github.run_number`, a timestamp, or a git commit count.** `run_number` is per-workflow-file and resets to 1 when the workflow is renamed or recreated. A Play `versionCode` is monotonic and is **permanently consumed even by a release that is later deleted** — a reset silently makes every subsequent build unuploadable until the number is manually jumped past the high-water mark, and nothing tells you until the upload is rejected. The committed number is also the one a successor reads; they will not have the Actions history.

Bump `+N` by exactly 1 per upload attempt, including uploads that are rejected. Burned numbers stay burned.

## Signing

**Enrol in Play App Signing.** Google holds the app signing key; the local keystore is only the **upload** key. Record the asymmetry and act on it: a lost upload key is a support ticket, a hand-curated board is months of someone's phrases and is irreplaceable. Optimise the process for the boards, not for the key.

Standard shape, both files **git-ignored**:

```properties
# android/key.properties — NEVER committed
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

```kotlin
// android/app/build.gradle.kts
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
            // DELIBERATE. Do not enable R8. See "R8/ProGuard" below.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}
```

Keep the keystore and `key.properties` outside the repo tree entirely, plus a copy in an offline backup. Do **not** put the keystore in GitHub secrets. CI builds unsigned — CI proves it compiles, and a repo with no signing secret has no signing secret to leak.

## Obfuscation: the answer is neither flag

This tension resolves cleanly, and the resolution must not be relitigated in a code review.

| Force | Verdict |
|---|---|
| `--obfuscate` protects the code | **Void.** Obfuscation does not encrypt resources and does not prevent reverse engineering — it renames symbols to more obscure names. Reed's exit plan is *publishing the source under Apache-2.0*. There is nothing to protect. |
| The crash log must stay readable | Both `--obfuscate` and `--split-debug-info` strip Dart function names from AOT stack traces. Recovering them requires `flutter symbolize -i trace -d app.android-arm64.symbols` — i.e. the developer still existing and still holding the exact per-build, per-architecture symbols file. |
| Abandonment is planned | After the developer stops, nobody holds that file. **Every crash report ever filed becomes permanently unreadable.** |

**Ship neither flag.** `--obfuscate` additionally breaks `runtimeType.toString()` matching, which is a silent-failure vector in a codebase whose worst bug class is silence: the user taps a tile mid-shutdown and nothing happens. The cost of refusing is a few MB on a ~7–10MB baseline that is ~70% Flutter engine and unshrinkable anyway.

```sh
# Right
flutter build appbundle --release

# Wrong — kills the only field signal this app will ever have
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

**The one escape hatch, if app size ever genuinely forces it:** use `--split-debug-info` **without** `--obfuscate`, and attach the entire symbols directory to the GitHub Release for that tag. Names leave the binary (that is the whole size win), the symbols are public and permanent, and *any* stranger — not only the original author — can symbolise a user's log years later. Obfuscation is the half with no upside; split-debug-info's downside is fully repaired by publishing the symbols. Never publish one without the other.

The on-device pass must include: **trigger a crash, export the log, confirm the trace shows readable Dart function names.** Hex offsets where names should be mean a flag crept back in and the field signal is dead — treat it as a release blocker, not a nit.

## R8 / ProGuard

`isMinifyEnabled = false`, `isShrinkResources = false`, **explicitly, with a comment**, so the next reader knows it was decided rather than forgotten.

R8's failure mode is exactly the failure mode this app cannot tolerate: a missing keep rule does not fail the build, it fails at **runtime**, as a tile tap that produces no speech. Flutter plugins with native code and reflective entry points — the TTS plugin's engine binding, the SQLite native loader, anything reached from a platform channel or an Android manifest-declared class — are precisely what R8 strips when nobody wrote a rule. The win is a negligible number of KB on a 12-tile app with almost no Java/Kotlin. The trade is a silent product failure against a rounding error.

If a future dependency hard-requires minification, do not enable it globally and hope. Enable it, then run the full on-device pass, then run it again after every plugin bump — because the analyzer and the test suite cannot see an R8 strip. Adding `proguard-rules.pro` is a signal that this decision is being reversed; require an explicit reason.

## The manual on-device pass is a release artifact

CI **cannot verify that this app speaks**, and no CI ever will. Two independent reasons; the second is the one that matters:

1. Standard Android emulator images commonly ship without a TTS engine or voice data, and fetching Google TTS voice data in an emulator is itself unreliable.
2. There is **no supported hook to capture or assert PCM output** from Android `TextToSpeech`. `integration_test` can assert a channel call was issued. It cannot assert that sound came out.

Reason 1 is bad luck you could fix with a better image. Reason 2 is architectural and unfixable. So the highest-severity bug class in the product is structurally unreachable by any CI job that could be written. The consequence is not "write more tests" — it is that the manual pass on real hardware, ringer switch **off**, is load-bearing infrastructure. Never upload a build that has not had one. Never substitute a green CI run for one.

Never automerge a TTS or audio-session dependency bump: **green CI is not evidence of audio.**

## Fastlane: no

It works fine, and it does not pay for itself across roughly six internal-track uploads. It costs a Ruby toolchain, a Play service-account JSON in CI secrets, and a `fastlane/metadata` tree — and the service-account JSON reintroduces exactly the secret that building locally eliminates.

The succession argument cuts against it hardest: a stranger forking Reed has their own Play account, their own service account, their own signing key. **Release automation is the one part of this repo they cannot reuse.** A README section they can read beats a pipeline they must dismantle.

Same verdict, same reasoning, for `r0adkll/upload-google-play`, a `release.yml` workflow, and any Play Console API wiring. Do not add them. Revisit only if uploads become weekly and multiple people hold the keys — neither is true.

Also refused, for the record, so they are not re-proposed at release time:

| Refused | Because |
|---|---|
| Deferred components / Play Feature Delivery | Requires Play Core and a network fetch at runtime. Contradicts the offline promise and breaks sideload and F-Droid. The Dart app is a few hundred KB. |
| `--bundle-sksl-path`, shader warmup | Impeller precompiles shaders and the flags were removed. Reed has zero animation regardless. |
| Crash/analytics SDK "just for releases" | Non-negotiable. The privacy promise is the product. |

## Release-notes and privacy caveats

Play release notes are handwritten — that work exists whether or not a changelog is automated, which is why there is no semantic-release here.

One live hazard when a user sends a log: the exported crash log can capture vocalization text, so a user helping debug may hand over the sentences they typed during a shutdown. Treat every received log as sensitive personal data — never paste one into an issue, a PR, or a public release thread.
