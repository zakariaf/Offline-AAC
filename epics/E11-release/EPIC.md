# E11 — Release

> A signed, readable-crashing `.aab` in the hands of the twenty people from E00-T02 — plus the store paperwork that is a submission blocker whether or not the store is the destination.

| | |
|---|---|
| **Status** | Not started |
| **Tasks** | 4 |
| **Depends on** | E01 (foundation), E09 (portability), E10 (verification) |

## Why this epic exists

The twenty people who answered three questions in E00-T02 are the only humans who have ever told this project anything. They are also the only ones who ever will, because there is no telemetry and there never will be: a user who cannot speak does not file a bug report. Shipping to a store first means the next signal after E00-T02 is a one-star review months later, or nothing at all — which is what "nothing" looks like when the failure mode is silence.

The paperwork is not deferred by shipping narrow. Play's Health apps declaration is mandatory for **every developer with a published app, including closed and open testing**, and the Data Safety form is required **even from developers who collect nothing**. An internal-track upload to twenty testers trips both. So the honest sequence is: do the paperwork, sign the build, hand it to the twenty, and let the store come after they have said whether it speaks.

Getting the declarations wrong costs a rejected submission or a regulatory obligation measured in months. Getting the build wrong is worse and quieter: `--obfuscate` or an R8 keep-rule miss produces an app that passes every test, uploads clean, and fails on a stranger's phone as a tile tap that makes no sound — with a crash log nobody can read.

## What "done" means

- `flutter build appbundle --release` produces `build/app/outputs/bundle/release/app-release.aab`, signed with the upload key from a git-ignored `android/key.properties`; `git check-ignore android/key.properties` exits 0 and `git log --all -- android/key.properties '*.jks'` is empty.
- `android/app/build.gradle.kts` has `isMinifyEnabled = false` and `isShrinkResources = false` with the comment saying it was decided; no `--obfuscate` and no `--split-debug-info` appear in any build command, script, or workflow.
- The build number in `pubspec.yaml` is `version: x.y.z+N`, committed, tagged, and the same `.aab` is attached to the GitHub Release for that tag.
- A fresh copy of `CHECKLIST.md` is ticked off against **this** build, on the cheap phone from E00-T03, ringer switch off — including the check that a deliberately-triggered crash exports a log with readable Dart function names and no vocalization text in it.
- The Play Health apps declaration and the Data Safety form are submitted; the privacy policy page exists, is linked from Play, and is reachable **from inside the app**; EU countries are deselected in the country targeting.
- Twenty testers are on the internal track and each has been sent a message that says what the app does and what to send back, in Reed's register.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E11-T01 | Store declarations and privacy paperwork | M | E09-T02 |
| E11-T02 | Signing and the app bundle | S | E01-T04 |
| E11-T03 | The obfuscation decision | XS | E09-T03 |
| E11-T04 | Ship to the twenty | S | E11-T01, E11-T02, E10-T03, E10-T05 |

**E11-T01** is the epic's long pole and the only one with an external reviewer. It writes the three honest paragraphs of the privacy policy, wires the in-app link, fills the Data Safety form, answers the Health apps declaration, and deselects the EU. It depends on E09-T02 for a reason that is not bureaucratic: the sentence *"cloud backup is off; export is user-initiated"* is only claimable once `allowBackup="false"` and explicit `dataExtractionRules` are actually in the manifest. Writing the claim before the manifest backs it is how a privacy-promising app ends up with an overclaim in front of an audience that reads adversarially, and one caught overclaim costs the product the exact community it needs.

**E11-T02** creates the upload keystore, enrols in Play App Signing, wires `signingConfigs` from a git-ignored `key.properties`, pins `isMinifyEnabled = false` with its comment, and establishes the versioning rule: `+N` bumps by exactly 1 per upload attempt, including rejected ones, and is never derived from `github.run_number`, a timestamp, or a commit count. It depends on E01-T04 because CI already builds the bundle unsigned — this task adds the local half without adding a signing secret to the repo.

**E11-T03** is fifteen minutes of writing and the highest leverage in the epic. It records, in the build config and in a comment a reviewer will hit, that neither `--obfuscate` nor `--split-debug-info` ships, and why — so the decision is not relitigated at 11pm before a tag by someone who read a blog post about app size. It depends on E09-T03 because the argument only lands once the crash log exists and is visibly the only field signal there is. It blocks E11-T02 so the flags are never in the build command in the first place.

**E11-T04** is the point of the epic. It runs the tagged release sequence end to end, ticks a fresh checklist on real hardware, uploads to the internal track, attaches the `.aab` to the GitHub Release, and writes the message to the twenty. It depends on E10-T03 for the checklist itself and on E10-T05 because a board that reads as a 2016 Material demo tells the twenty that the app was not made for adults before they tap anything.

## Skills this epic draws on

**Release mechanics**
- `reed-release-android` — the five-step sequence, the `version: x.y.z+N` → versionCode rule and why a reset burns numbers permanently, Play App Signing vs the local upload key, the standing refusal of `--obfuscate`/`--split-debug-info`/R8/fastlane, and the rule that the `.aab` is attached to the GitHub Release because the Play account is mortal. Governs T02 and T03; T04 executes it.
- `reed-ci-workflow` — what CI already proves (compiles, formats, analyzes, tests, codegen and schema dumps fresh, unsigned bundle builds) and the load-bearing fact it can never prove: that the app speaks. T02 reads it to avoid re-adding a release pipeline CI deliberately refuses.

**Claims and paperwork**
- `reed-store-and-legal` — the Play Health apps declaration, the Data Safety form, the 5.1.1(i) in-app privacy link, the EU MDR Class I verdict (geo-restrict at launch; treat "add EU countries" as a project), the scoping of any "not a medical device" language to non-EU storefronts, and the not-child-directed declaration. T01 is this skill made concrete.
- `reed-privacy-claims` — the banned sentence, the approved three-clause wording, the verb *declare*, the ranking that puts the OS-enforced absence of INTERNET first, and the rule that a claim may not ship ahead of the manifest that backs it. T01 writes nothing this skill has not sanctioned.
- `reed-copy-voice` — the register for the policy, the listing, and the message to the twenty: no "we," no exclamation marks, no praise, no caregiver framing, function not medical benefit, and the field's own terms — *part-time AAC*, *unreliable speech*, *intermittent speech*. Governs T01 and T04.

**Verification and diagnostics**
- `reed-manual-checklist` — the hardware rules (physical phone, cheap phone, ringer switch off, release build), the section order and why 5–7 are destructive, and the four failures unreachable by every automated means. T04 runs it; it is a release artifact, not a chore.
- `reed-aac-audience` — who the twenty are and how to write to them: identity-first, *non-speaking* not *non-verbal*, no "backup plan" framing, counts never presented as rates. Governs T04's message.
- `reed-error-model` — why the crash log is the only line of sight into the field and why redaction lives inside `record`. It is the evidentiary basis for T03's refusal.

## Sequencing

Two tracks, and they only meet at T04.

**Track A — the build chain: T03 → T02 → T04.** T03 first, because the flags are cheaper to never add than to remove: once `--obfuscate` is in a script it survives on the grounds that it is already there. T02 then writes the config with the decision already made. Both are short; the chain is a day.

**Track B — T01, starting immediately, in parallel.** It is the long pole for reasons outside the developer's control: Play's Data Safety and Health apps declarations go through review, and a rejected declaration is a round trip measured in days, not minutes. It gates nothing in Track A, so start it the moment E09-T02 lands and let it sit.

**T04 is the join, and it does not compress.** It needs both tracks plus E10-T03 (the checklist) and E10-T05 (the audit). The checklist itself is hours of hands-on device work, and sections 5–7 are destructive — a failure in the crash-log section means reinstalling and redoing sections 1–4 after the fix. Budget a full day for T04 and never overlap it with the fix for something it found.

**A tag is not a gate you can move.** If T04's device pass fails, the fix lands, `+N` bumps by 1, a new tag is cut, and the pass runs again from the top. There is no "we already checked that part last time."

## Risks specific to this epic

- **Green CI read as a green release.** CI cannot verify that this app speaks — the emulator ships no TTS engine, and no supported hook captures PCM output from Android `TextToSpeech` on any platform. The second reason is architectural and permanent. A green `ci.yml` on the release commit is evidence the code compiles. It is not evidence of audio, and the temptation to skip the device pass is highest on the build that is already tagged.
- **A flag creeping back into the build command.** `--obfuscate` and `--split-debug-info` both strip Dart function names from AOT traces. After the developer stops, nobody holds the per-build, per-architecture symbols file, and every crash report ever filed becomes permanently unreadable — while every test still passes. The tripwire is the checklist's crash-log check: hex offsets where names should be is a release blocker, not a nit.
- **R8 arriving with a dependency.** A missing keep rule does not fail the build; it fails at runtime, as a tile tap that produces no speech, in exactly the plugins with reflective entry points — the TTS engine binding, the SQLite native loader, anything reached from a platform channel. The analyzer and the test suite cannot see an R8 strip. A new `proguard-rules.pro` in a diff means this decision is being reversed silently.
- **A burned versionCode.** A Play `versionCode` is monotonic and is **permanently consumed even by a release that is later deleted**. Nothing tells you until an upload is rejected. Deriving it from `github.run_number` — which is per-workflow-file and resets when the file is renamed — makes every subsequent build unuploadable.
- **Writing the privacy claim before the manifest backs it.** The policy is drafted on a laptop; `allowBackup="false"` lives in a file someone could still change. The order is manifest first, sentence second. Check the manifest before shipping the sentence, not after.
- **The disclaimer that contradicts the classification.** Play pushes non-device health apps toward "not a medical device." MDCG 2019-11 Rev.1 names this exact app — autism, aphasia, symbol-to-speech — as Class I under Rule 11c. Asserting the disclaimer to EU users could become evidence of a false statement. Scope the language to non-EU storefronts, and deselect the EU at launch.
- **The `.aab` living only in the Play Console.** The account is mortal; the git repo is the succession plan. An artifact attached to no tag dies with the account, and step 5 of the release sequence is the cheapest insurance in the project.
- **A tester's log arriving with their words in it.** The exported crash log can capture vocalization text. A user helping debug may hand over the sentences they typed during a shutdown. Every received log is sensitive personal data: never paste one into an issue, a PR, or a public thread. Do not invite logs at all until the redaction test in E09-T03 is green.
- **Writing to the twenty in the wrong register.** These are the people who gave the project its only real input, and the message is copy. No "we," no exclamation marks, no praise for testing, no "just." A count is a count — "17 of 20" — never a percentage.

## Out of scope

- **A public store launch.** Production track, listing screenshots, a launch post, and the EU are all after the twenty have replied. "Add EU countries" is a project with MDR Class I obligations attached — technical file, clinical evaluation, PRRC, UDI, EUDAMED, PMS, CE marking, an EU Authorised Representative — never a config change.
- **Any release automation.** No `release.yml`, no fastlane, no `r0adkll/upload-google-play`, no Play Console API. Refused in `reed-ci-workflow` and `reed-release-android` for roughly six manual uploads, and because a service-account JSON in CI secrets reintroduces the exact secret that building locally eliminates.
- **The manual checklist itself.** E11-T04 runs a fresh copy of it; authoring `CHECKLIST.md` is E10-T03.
- **The crash log implementation.** `CrashLog.record`, its redaction, and the size bound are E09-T03. E11-T03 only cites the log as the reason the flags stay off.
- **The backup manifest work.** `allowBackup="false"` and `dataExtractionRules` are E09-T02. E11-T01 checks they are there before writing the sentence that depends on them.
- **Export and import.** E09-T01. The checklist's phone-migration rehearsal exercises it; this epic does not build it.
- **iOS.** No App Store Connect, no App Privacy details, no privacy manifests, no Personal Voice question. Android-first is the plan; the iOS asymmetry — no OS-enforced network guarantee — is recorded in `reed-privacy-claims` for when it matters.
- **Symbols, fonts, and voice licensing.** Reed ships text-only, which dodges the licence question entirely. The Mulberry version problem and the ARASAAC NonCommercial bar live in `reed-store-and-legal` against a future that has not been scoped.
