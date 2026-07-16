# Releasing Reed

Reed ships to Google Play Android-first, by hand, to an internal testing track.
There is **no release automation** — no fastlane, no `release.yml`, no Play API,
no service-account JSON — on purpose (see `reed-release-android`): roughly six
manual uploads is not worth reintroducing the exact signing secret that building
locally eliminates.

This document is the runbook and the record of two decisions a future reader
must not relitigate: **the obfuscation decision** and **the versioning rule**.

---

## The obfuscation decision (E11-T03)

**The build command is exactly this — no flags:**

```sh
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

`--obfuscate` and `--split-debug-info` and R8 (`isMinifyEnabled`) are all **off,
deliberately**, and `android/app/build.gradle.kts` says so in a comment. Why:

1. **Obfuscation renames symbols; it does not protect anything.** It does not
   encrypt resources and does not prevent reverse engineering. Reed's exit plan
   is publishing this source under **MIT** — there is nothing to protect, and
   the price is the entire feedback loop.
2. **There is no telemetry and never will be.** The only field signal that will
   ever exist is the on-device, user-exported crash log. If its traces are hex
   offsets instead of Dart function names, the signal is gone.
3. **Symbolizing needs a file nobody will hold.** Recovering names needs
   `flutter symbolize -i trace -d app.android-arm64.symbols` — the exact
   per-build, per-architecture symbols file. Abandonment is planned; after the
   developer stops, that file is gone and **every crash report ever filed
   becomes permanently unreadable.**
4. **`--obfuscate` breaks `runtimeType.toString()` matching** — a silent-failure
   vector in a codebase whose worst bug class is silence (a tile tap that makes
   no sound and no one reports).

**R8 is off for a sharper reason:** a missing keep rule does not fail the build,
it fails at runtime, as a tile tap that produces no speech — the TTS engine
binding, the SQLite native loader, anything reached through a platform channel.
The analyzer and the test suite cannot see an R8 strip. The saving is a few KB on
a ~7–10 MB app that is mostly Flutter engine. A `proguard-rules.pro` appearing in
a diff means this decision is being reversed silently.

**The one escape hatch, if app size ever genuinely forces it:** use
`--split-debug-info` **without** `--obfuscate`, and attach the **entire symbols
directory** to the GitHub Release for that tag. Names leave the binary (the size
win); the symbols are public and permanent, and any stranger can symbolize a
user's log years later. **Never publish one without the other.**

---

## Signing (E11-T02)

Reed uses **Play App Signing**: Google holds the app signing key; the local
`.jks` is only the **upload** key. A lost upload key is a support ticket; a lost
board is months of someone's hand-curated phrases. Optimise for the boards.

### One-time: create the upload keystore (you do this, not CI)

```sh
keytool -genkey -v -keystore ~/reed-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep the `.jks` **outside the repo tree** with an offline backup, then:

```sh
cp android/key.properties.example android/key.properties
# edit android/key.properties with the passwords and the absolute storeFile path
```

`android/key.properties` and `*.jks` are git-ignored (verify:
`git check-ignore android/key.properties`). Never put the keystore in CI secrets
— CI proves it compiles, and a repo with no signing secret has none to leak. The
`keystorePropertiesFile.exists()` guard in `build.gradle.kts` is what lets CI
build the (unsigned) bundle without a keystore; do not remove it.

Enrol the app in **Play App Signing** in the Play Console on the first upload.

---

## Versioning (E11-T02)

`version: x.y.z+N` in `pubspec.yaml` is the whole system: `+N` → `versionCode`,
`x.y.z` → `versionName`.

- Bump `+N` by **exactly 1 per upload attempt, including rejected ones.** Play
  burns the `versionCode` on the attempt, not the success.
- The number is **committed, never computed.** Never derive it from
  `github.run_number` (per-workflow-file, resets on rename), a timestamp, or a
  commit count. A burned `versionCode` is consumed permanently, even by a
  release that is later deleted, and nothing tells you until an upload is
  rejected.

---

## The release sequence (E11-T04)

1. Tick a **fresh copy of [`docs/CHECKLIST.md`](docs/CHECKLIST.md)** on the cheap
   physical phone, ringer switch **off**, on a **release** build. This is
   load-bearing: CI cannot verify that the app speaks (no supported hook
   captures PCM output from Android `TextToSpeech`), and sections 5–7 are
   destructive. Green CI is not a green release.
   - Includes the crash-log check: trigger a crash, export the log, confirm the
     trace shows **readable Dart function names**. Hex offsets mean a
     symbol-stripping flag crept back in — a release blocker, not a nit.
2. Bump `+N` in `pubspec.yaml`, commit, and tag (`v0.1.0+1`).
3. `flutter build appbundle --release` (no flags).
4. Upload the `.aab` by hand to the Play **internal testing** track.
5. Attach the **same `.aab`, byte-for-byte**, to the GitHub Release for the tag.
   The Play account is mortal; the git repo is the succession plan.
6. Send the testers the message in [`store/tester-message.md`](store/tester-message.md).

If the device pass fails: fix it, bump `+N` by 1, cut a new tag, and run the
pass again **from the top**. A tag is not a gate you can move.

---

## Store paperwork (E11-T01)

The completed answers are recorded, reviewable in a diff, under [`store/`](store/):

- [`store/play-listing.md`](store/play-listing.md) — listing copy, Data Safety
  answers, Health-apps declaration, IARC answers, the non-EU disclaimer.
- [`store/country-availability.md`](store/country-availability.md) — the EU
  exclusion and why it is not a config change to reverse.

The privacy policy source of truth is [`legal/privacy-policy.md`](legal/privacy-policy.md),
hosted at <https://reed.applander.io/privacy> and reachable from inside the app
(settings → *privacy policy*).

---

## Out of scope, refused

fastlane · `r0adkll/upload-google-play` · a `release.yml` · any Play Console API
or service-account JSON · `proguard-rules.pro` · deferred components · a crash or
analytics SDK "just for releases" · the EU (see `store/country-availability.md`).
