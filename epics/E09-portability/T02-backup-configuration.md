# E09-T02 — Backup configuration

| | |
|---|---|
| **Epic** | E09 — Portability and the crash log |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E01-T01 |
| **Blocks** | E11-T01 |

**Skills:** `reed-privacy-claims` · `reed-policy-tests` · `reed-store-and-legal`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

`android:allowBackup` defaults to **true**. With no code written and no decision made, Android uploads the SQLite database — every phrase the user has ever curated — to Google Drive. A board holds phrases like *"I am being hurt."* A phrase like that implies an adversary, and for disabled adults and domestic-violence survivors that adversary is frequently a caregiver or partner who has access to the user's Google account: the exact account the backup lands in. This is a safety accommodation, not a preference, and it is one line of XML away from being silently untrue.

## Scope

Configure the Android manifest and backup rules so that **cloud backup is off and device-transfer works**, then pin both with a policy test.

**1. The manifest.** In `android/app/src/main/AndroidManifest.xml`, on `<application>`:

```xml
android:allowBackup="false"
android:dataExtractionRules="@xml/data_extraction_rules"
```

Both. `allowBackup="false"` is the pre-Android-12 lever; `dataExtractionRules` is what Android 12+ (API 31+) reads. Setting only one leaves a version band uncovered.

**2. The rules file.** Create `android/app/src/main/res/xml/data_extraction_rules.xml` with an **empty or omitted `<cloud-backup>`** and a **permissive `<device-transfer>`**:

```xml
<data-extraction-rules>
  <cloud-backup>
    <exclude domain="root" />
    <exclude domain="database" />
    <exclude domain="sharedpref" />
    <exclude domain="file" />
    <exclude domain="external" />
  </cloud-backup>
  <device-transfer>
    <include domain="database" path="." />
    <include domain="file" path="." />
    <include domain="sharedpref" path="." />
  </device-transfer>
</data-extraction-rules>
```

That combination — and only that combination — buys the sentence *"phrase tiles survive a new phone; nothing ever reaches Google Drive."* Verify the manifest before anyone writes that sentence, not after.

**3. The policy test.** Extend `test/policy/android_manifest_policy_test.dart` (the same file that already asserts `TTS_SERVICE` inside `<queries>` and the absence of `android.permission.INTERNET`) per `reed-policy-tests`: read through `xmlOf()` so a `<!-- -->` explaining the rule cannot satisfy the rule, accumulate offenders, one `expect` at the end. Assert:

- `android:allowBackup="false"` is present in the manifest.
- `android:dataExtractionRules` is present and points at `@xml/data_extraction_rules`.
- `data_extraction_rules.xml` exists, its `<cloud-backup>` element contains no `<include>`, and its `<device-transfer>` element does contain at least one `<include>`.

Every `reason:` string names the consequence to the person using the app — a survivor's disclosure sitting in an abuser's Drive — not the rule. Write it for the stranger at 2am deciding whether to delete the test.

**4. The comment at the point of temptation.** Put the same argument as an XML comment in `AndroidManifest.xml` beside `allowBackup` and at the top of `data_extraction_rules.xml`. The person about to flip this to `true` is standing in that file, not in `test/policy/`.

This earns a policy test on all three criteria from `reed-policy-tests`: textually decidable (it is an XML attribute), silent when broken (the app builds, the suite is green, and the upload happens invisibly), and one line to break (a merge, a template regeneration, a "fix the backup warning" cleanup).

**Explicitly out of scope:**

- **Do not condition cloud upload on end-to-end encryption.** E2EE backups still leave the device and still depend on the user having a screen lock, which users in this population may not have. Off is a stronger and simpler promise than encrypted. Do not "improve" this.
- No iOS `isExcludedFromBackup` work — separate task. If it lands later, word the toggle as what the app *requests*: Apple documents the API as guidance, not a guarantee.
- No in-app "Keep my board off cloud backup" toggle in this task. Cloud backup is off unconditionally; there is nothing to toggle. If a toggle is ever added, it is never buried, never phrased as an optimization, never described as advanced.
- No export/import UI — that is the user-initiated durability path and lives in its own task.
- No listing or policy copy. This task makes the claim *true*; another task writes it.

## Acceptance criteria

- [ ] `flutter test test/policy` passes, including the new backup assertions.
- [ ] Flipping `android:allowBackup` to `"true"` makes `flutter test test/policy` fail with a reason naming the Google Drive consequence.
- [ ] Adding an `<include>` under `<cloud-backup>` makes `flutter test test/policy` fail.
- [ ] Deleting `android/app/src/main/res/xml/data_extraction_rules.xml` makes `flutter test test/policy` fail rather than throwing an unhandled `FileSystemException`.
- [ ] Adding `<!-- never set android:allowBackup="false" here -->` to the manifest does **not** make the test pass or fail spuriously (the assertion reads through `xmlOf()`).
- [ ] `flutter build apk --debug` succeeds — `data_extraction_rules.xml` is a real resource and a malformed one fails at `aapt2`, not at runtime.
- [ ] `flutter analyze` is clean.
- [ ] Manual, on device: `adb shell bmgr backupnow <applicationId>` reports the package is not backup-enabled (or equivalently produces no data set).

## Traps

- **Setting only one of the two attributes.** `allowBackup="false"` alone leaves API 31+ reading a `dataExtractionRules` that does not exist; `dataExtractionRules` alone leaves pre-12 devices on the default `true`. Both, always.
- **Whole-file `contains` instead of a structural anchor.** `reed-policy-tests` is explicit: anchor the needle to a structure. `contains('allowBackup="false"')` over raw text passes on a comment that says "we should set allowBackup=\"false\"". Read through `xmlOf()`.
- **Asserting `<cloud-backup>` exists rather than that it excludes.** An empty `<cloud-backup>` element and a `<cloud-backup>` full of `<include>` both satisfy "the element is present." Assert on the absence of `<include>` inside it.
- **`expect` inside the loop.** Reports offender #1 and hides the rest. Accumulate, fail once with the full list.
- **Building a path from `Platform.script`.** `flutter test` sets the working directory to the package root; relative paths like `android/app/src/main/AndroidManifest.xml` resolve. `Platform.script` does not survive the runner.
- **The E2EE "improvement."** It will be proposed, it will sound sophisticated, and it is a downgrade. Encrypted backups still leave the device. Reject it in review with the screen-lock argument, not with "policy says no."
- **Excluding the database from `<device-transfer>` "to be safe."** That is the failure this configuration exists to avoid: the user's hand-curated board does not survive a new phone, they get an empty grid, and — no telemetry — nobody ever learns. Cloud-backup exclusion and device-transfer inclusion are different lists for a reason.
- **Writing the claim before checking the manifest.** `reed-privacy-claims` ranks "cloud backup is off by default; export is user-initiated" as claimable *only once* `allowBackup="false"` and explicit `dataExtractionRules` are actually in the manifest. The rejection criterion is literal: never make a claim the manifest does not currently back.
- **Treating a durability regression as a reason to reopen cloud backup.** Durability is served by making user-initiated export obvious in settings. A durability feature the user cannot see is not a trade this app gets to make on their behalf.
- **Assuming this stays settled.** Board sharing, cloud sync, or import-from-URL each reopen every store and moderation question in `reed-store-and-legal` and invalidate the promise this task encodes. They are policy features, not sync features.

## Files

- `android/app/src/main/AndroidManifest.xml` — add `android:allowBackup="false"` and `android:dataExtractionRules="@xml/data_extraction_rules"` on `<application>`, plus the comment at the point of temptation.
- `android/app/src/main/res/xml/data_extraction_rules.xml` — new.
- `test/policy/android_manifest_policy_test.dart` — extend with the backup assertions.
- `test/policy/policy_support.dart` — no change expected; `xmlOf()` already exists.

## Done when

`flutter test test/policy` fails the moment anyone re-enables cloud backup, and a restored-from-transfer phone opens with the user's board intact.
