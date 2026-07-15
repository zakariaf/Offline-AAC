# E11-T03 — The obfuscation decision

| | |
|---|---|
| **Epic** | E11 — Release |
| **Status** | Not started |
| **Size** | XS |
| **Depends on** | E09-T03 |
| **Blocks** | E11-T02 |

**Skills:** `reed-release-android` · `reed-error-model`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

`--obfuscate` and `--split-debug-info` both strip Dart function names out of AOT stack traces. Reed has no telemetry and never will, so the on-device, user-exportable crash log — read by the user, pasted to the developer — is the only field signal that will ever exist. If the traces in that log are hex offsets, the signal is gone, permanently, because recovering names needs `flutter symbolize -i trace -d app.android-arm64.symbols` and therefore needs the developer to still exist and to still hold the exact per-build, per-architecture symbols file. Reed's exit plan is publishing the source under Apache-2.0; obfuscation is protecting code that is going to be given away.

## Scope

Land the decision in the two places it can be re-litigated — the build command and the Gradle release block — and in a form the next reader cannot mistake for an oversight.

**1. The build command is exactly this. No flags.**

```sh
# Right
flutter build appbundle --release

# Wrong — kills the only field signal this app will ever have
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

**2. `android/app/build.gradle.kts` — R8 off, explicitly, with a comment.**

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        // DELIBERATE. Do not enable R8. See "R8/ProGuard" below.
        isMinifyEnabled = false
        isShrinkResources = false
    }
}
```

R8 is refused for the same reason and a sharper one: a missing keep rule does not fail the build, it fails at **runtime**, as a tile tap that produces no speech. The TTS plugin's engine binding, the SQLite native loader, anything reached from a platform channel or a manifest-declared class — those are exactly what R8 strips when nobody wrote a rule, and neither the analyzer nor the test suite can see it. The win is a negligible number of KB on a 12-tile app with almost no Java/Kotlin.

**3. Write the decision down where it will be read at the moment it is questioned.** The refusal is a decision already made, not a gap awaiting automation. Record, in prose a stranger can follow:

- Obfuscation does not encrypt resources and does not prevent reverse engineering — it renames symbols to more obscure names. Against an Apache-2.0 exit plan the protective value is **void**.
- `--obfuscate` additionally breaks `runtimeType.toString()` matching — a silent-failure vector in a codebase whose worst bug class is silence.
- The cost of refusing is a few MB on a ~7–10MB baseline that is ~70% Flutter engine and unshrinkable anyway.
- Abandonment is planned. After the developer stops, nobody holds the symbols file, and **every crash report ever filed becomes permanently unreadable.**

**4. Record the one escape hatch, so a future size crisis does not reach for the wrong half.** If app size ever genuinely forces it: use `--split-debug-info` **without** `--obfuscate`, and attach the **entire symbols directory** to the GitHub Release for that tag. Names leave the binary — that is the whole size win — the symbols are public and permanent, and *any* stranger can symbolise a user's log years later. Obfuscation is the half with no upside; split-debug-info's downside is fully repaired by publishing the symbols. **Never publish one without the other.**

**5. Add the verification step to the manual on-device pass** (that pass is a release artifact; this task adds one item to it): **trigger a crash, export the log, confirm the trace shows readable Dart function names.** Hex offsets where names should be mean a flag crept back in and the field signal is dead — a release blocker, not a nit.

Out of scope: signing config and `key.properties` (E11-T02), the CrashLog implementation and its redaction (E09-T03), the rest of the manual on-device pass, fastlane / Play API automation (refused outright).

## Acceptance criteria

- [ ] `grep -rn 'obfuscate\|split-debug-info' --include='*.md' --include='*.yaml' --include='*.yml' --include='*.sh' --include='*.kts' .` returns no build invocation carrying either flag; any hit is prose explaining the refusal.
- [ ] `android/app/build.gradle.kts` contains `isMinifyEnabled = false` and `isShrinkResources = false` in the `release` block, each reachable from a comment saying the choice was deliberate.
- [ ] No `android/app/proguard-rules.pro` exists. Its presence is the signal this decision is being reversed.
- [ ] `flutter build appbundle --release` produces `build/app/outputs/bundle/release/app-release.aab` with no flags added.
- [ ] The written decision states all four points: obfuscation renames rather than protects; the exit plan is Apache-2.0; symbolizing requires a per-build per-architecture symbols file held by a developer who will not exist; `--obfuscate` breaks `runtimeType.toString()`.
- [ ] The escape hatch is recorded as `--split-debug-info` **without** `--obfuscate` **plus** publishing the whole symbols directory to the GitHub Release — never one without the other.
- [ ] The manual on-device pass has an item: trigger a crash → export the log → assert readable Dart function names, hex offsets block the release.
- [ ] CI still builds (not merely analyzes) — `non_exhaustive_switch_statement` fails `dart compile` but can be silenced for `dart analyze`, so a build-free CI would miss it.

## Traps

- **Reaching for `--split-debug-info` alone for the size win and never publishing the symbols.** This is the trap that looks responsible. The flag is only defensible when the symbols directory ships attached to the GitHub Release for that exact tag. Symbols are per-build and per-architecture — last release's `app.android-arm64.symbols` will not symbolize this release's trace, and there is no error telling you so; you get plausible wrong names or nothing.
- **"Obfuscation is just good practice for a release build."** It renames symbols. It does not encrypt resources and does not prevent reverse engineering. Against a repo whose exit plan is publishing the source, there is nothing being protected and the price is the entire feedback loop.
- **`--obfuscate` breaking `runtimeType.toString()` matching.** Any code that compares a runtime type name silently stops matching in release, in a codebase where the failure mode of a broken match is a tile tap that makes no sound and no one ever reports it.
- **Enabling R8 because a dependency "recommends" it.** Do not enable it globally and hope. Enable it, run the full on-device pass, then run it again after every plugin bump — R8 strips reflective entry points and manifest-declared classes and the build stays green. A `proguard-rules.pro` appearing in a diff requires an explicit stated reason.
- **Treating green CI as evidence.** CI cannot verify that this app speaks. There is no supported hook to capture or assert PCM output from Android `TextToSpeech`; `integration_test` can assert a channel call was issued, not that sound came out. Never automerge a TTS or audio-session dependency bump on a green run.
- **Relitigating this in code review.** The verdict is: ship neither flag, keep R8 off. Point at the recorded decision instead of re-deriving it.
- **Treating a user's exported log as ordinary debug output.** The log can capture vocalization text — a user helping you debug may hand over the sentences they typed during a shutdown. Never paste a received log into an issue, a PR, or a public release thread. That is also why `SpeakFailure.logLine` exists separately from `spokenText`, and why redaction lives inside `CrashLog.record` rather than at the call sites: call-site discipline fails silently the first time someone interpolates an exception whose `toString()` embeds the phrase.
- **`throw e` instead of `rethrow` anywhere on the crash path.** It resets the stack to the rethrow line. With no crash reporting, the trace in the on-device log is the entire forensic record — this task exists to keep that trace readable, and a reset stack destroys it just as thoroughly as a stripped name.
- **Logging a wrapped `ProviderException`.** Riverpod rethrows provider failures wrapped; unwrap to the real cause before `record`, or every entry in the only log you will ever see reads `ProviderException`.

## Files

- `android/app/build.gradle.kts` — release `buildType`: `isMinifyEnabled = false`, `isShrinkResources = false`, with the deliberate-choice comment.
- The release runbook / README release section — the build command with no flags, the recorded decision, the escape hatch.
- The manual on-device pass checklist — the crash-log-readability item.
- `android/app/proguard-rules.pro` — must not exist.

## Done when

`flutter build appbundle --release` is the only sanctioned build command, R8 is off with a comment saying so on purpose, the reasoning and the split-debug-info-plus-published-symbols escape hatch are written down where the next reader will hit them, and the on-device pass blocks any release whose exported crash log shows hex offsets instead of Dart function names.
