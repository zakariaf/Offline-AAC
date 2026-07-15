---
name: reed-privacy-claims
description: Governs the exact wording of every privacy, offline, network, and data-collection claim — the banned "nothing leaves your device" sentence, Play Data Safety and App Store privacy label fields, policy, listing, and onboarding copy. Use when writing or reviewing such copy, filling a declaration form, touching allowBackup, dataExtractionRules, isExcludedFromBackup, or network_required voice filtering. Not for whether a package or permission is allowed in the codebase — only what may be said about it.
---

# Privacy claims for Reed

The audience reads privacy labels adversarially. Autistic adults evaluating a disability accommodation fact-check store copy in public, and one caught overclaim is unrecoverable — it costs the product the exact community it needs. Every sentence below is calibrated so that a hostile reader with a decompiler and a packet capture finds nothing to contradict.

The claim is not weaker for being honest. It is the strongest claim in the category *because* it survives audit.

## The banned sentence

**Never write "nothing leaves your device."** Not in the listing, not in onboarding, not in the policy, not in a README, not in a Reddit reply. It is false, and it is false twice.

**Failure one — TTS runs in another app.** Android speech synthesis is not in-process. The framework binds a *separate engine app* over the `android.intent.action.TTS_SERVICE` intent. That engine runs under **its own UID with its own INTERNET permission**. Reed's manifest cannot constrain it, cannot inspect it, and cannot revoke it. Whatever text is passed to `speak()` crosses a process boundary into code Reed does not control and did not ship. Omitting INTERNET from Reed's manifest proves only that *Reed's* code has no network surface — a real and valuable fact, but not the absolutist one.

**Failure two — cloud backup is on by default.** `android:allowBackup` defaults to **true**. With no code written, the SQLite database — every phrase the user has ever curated, the most intimate content they own — is uploaded to Google Drive. iOS is the same story: files in `Documents` and `Library/Application Support` are in iCloud backup by default, and under Standard Data Protection **Apple holds the keys**. A privacy label saying "no network, no server" over a manifest saying `allowBackup="true"` is a trap set for oneself.

## The approved wording

Use this text, or a paraphrase that preserves all three scoping clauses:

> **This app has no network code and no network permission. Speech is synthesized by your device's own system TTS engine, and we only select voices that declare they need no network.**

Each clause is load-bearing and none may be dropped for brevity:

| Clause | Why it cannot be cut |
|---|---|
| "no network code and no network permission" | Scopes the claim to Reed's own binary — the part that is actually provable. |
| "your device's own system TTS engine" | Names the boundary honestly. Does not pretend the engine is Reed's. |
| "only select voices that declare they need no network" | Says *declare*. The engine self-reports; Reed filters on the report. It does not claim to verify. |

Note the verb **declare**. Never upgrade it to "guarantee," "ensure," or "cannot." Reed reads `network_required` from a voice map the engine populated. That is a declaration, not a proof, and the wording must not launder one into the other.

## What may be claimed, ranked by strength

1. **No INTERNET permission.** This is the strongest asset and the reason to say it first. It is **OS-enforced** — the kernel denies the socket, not a policy document — and it is **visible on the Play listing before install**. A prospective user can verify the central privacy claim without trusting Reed, without installing Reed, and without reading a line of code. Nothing else in the category offers that.
2. **No accounts, no server, no analytics SDK, no crash-reporting SDK.** True, and stays true only if nothing is ever added that opens a socket. Any dependency that could is a claim-breaking change, not a routine one.
3. **The app keeps working if the developer stops maintaining it.** Offline and account-free means no entitlement check to expire, no server to shut down. Say this out loud — users building dependence on a disability accommodation are owed it, and it is honest.
4. **Cloud backup is off by default; export is user-initiated.** Only claimable once `allowBackup="false"` and explicit `dataExtractionRules` are actually in the manifest. Verify before writing the sentence.

**iOS asymmetry — state it, do not paper over it.** iOS offers **no equivalent OS-enforced network guarantee**. There is no pre-install, platform-verified "this app cannot reach the network" signal. Any copy shared across both stores must not imply the Android guarantee holds on iOS.

## The backup rules

`allowBackup="false"` plus explicit `dataExtractionRules` — an empty or omitted `<cloud-backup>` and a permissive `<device-transfer>`. That combination buys the sentence *"phrase tiles survive a new phone; nothing ever reaches Google Drive."*

Do not "improve" this by conditioning cloud upload on end-to-end encryption. E2EE backups still leave the device, and still depend on the user having a screen lock — which users in this population may not have. Off is a stronger and simpler promise than encrypted.

Durability is served by making **user-initiated export** obvious in settings, not by an invisible upload the user never asked for. A durability feature the user cannot see is not a trade this app gets to make on their behalf; the privacy promise *is* the product.

**On iOS, word the toggle honestly.** Apple documents `isExcludedFromBackup` as **guidance, not a guarantee** — in Apple's own words it "exists only to provide guidance to the system… it's not a mechanism to guarantee those items never appear in a backup." Copy that says "your board will never be backed up to iCloud" overstates what the API delivers. Say what the app *requests*, not what the platform promises.

## The backup toggle is a safety accommodation

Treat an explicit, plainly-worded **"Keep my board off cloud backup"** control as a safety feature, not a preference — and never bury it, never phrase it as an optimization, never describe it as advanced.

The reasoning: a board holds phrases like *"I am being hurt."* A phrase like that implies an adversary. For disabled adults and for domestic-violence survivors, that adversary is frequently **a caregiver or partner who has access to the user's Google or Apple account** — the exact account the backup lands in. The threat is not a remote attacker; it is someone in the room with the phone and the password.

This is an inference about user threat models, not a measured finding, and it should be held at medium confidence. It is still enough to decide the design, because the cost of the toggle is trivial and the cost of being wrong is a survivor's disclosure sitting in an abuser's Drive.

The same reasoning governs the exportable crash log. `CrashLog.record(message, stack)` will happily capture vocalization text; a user mailing a log to a maintainer could leak *"I need to leave, I'm not able to talk right now"* plus whatever they typed. Never write copy inviting users to send logs until redaction exists and is tested.

## Open source is not the trust lever

The argument "open-source it so people can verify the privacy claim" is wrong on the merits, and it must not be used as a justification in copy, in an issue, or in a decision doc.

- **The claim is not otherwise unfalsifiable.** No INTERNET permission is OS-enforced and pre-install-visible. Publishing source is *weaker*: **source cannot prove the shipped binary matches it.** Trading a kernel-enforced guarantee for a "trust me, this is what I built" is a downgrade dressed as transparency.
- **The precedent runs the other way.** CoughDrop stopped its open-source releases in March 2023 on acquisition and no longer markets itself as open source; the surviving community fork is low-activity. In this category, "we're open source" is a promise that has already been withdrawn once.
- **The evidence base does not ask for it.** What autistic adult AAC users actually asked for is opt-in-by-default, transparent disclosure, and making data practices visible — not source publication. Publishing source answers a question nobody in the population posed.

**The honest counter-argument, which is a different argument entirely:** open-sourcing may be the right **exit plan**. Users build dependence on a disability accommodation, and unresponsive or vanished support is a named abandonment cause in this exact population. Publishing the source is how the app survives its developer. That is an **ethical** reason. Never conflate it with a trust reason, and never let it into privacy copy.

## Where the code has to back the claim

The claim "we only select voices that declare they need no network" is false the moment the filter is wrong, and the filter has traps that fail **silently and in the unsafe direction**:

```dart
// WRONG — Android sends network_required as the STRING "1"/"0".
// This comparison is String-vs-bool: always false. Every voice passes.
voices.where((v) => v['network_required'] == true)

// WRONG — "0" is a non-empty string and survives truthiness.
if (v['network_required'] != null && v['network_required'].isNotEmpty) { ... }

// RIGHT
final safe = voices.where((v) =>
    v['network_required'] == '0' &&
    !((v['features'] as String?) ?? '').contains('notInstalled'));
```

- `features` is **TAB-separated**, not comma-separated.
- **iOS omits `network_required` entirely** — absent must mean not-network-required, or every iOS voice is filtered out and the app is silent.
- A voice carrying the `notInstalled` feature makes `setVoice` return **1 (success)** and then synthesizes silence or substitutes another voice. The return check does not catch it. Filter on the feature.
- Do not reintroduce `KEY_FEATURE_EMBEDDED_SYNTHESIS` / `KEY_FEATURE_NETWORK_SYNTHESIS` — deprecated since API 21; the platform redirects to the per-voice network flag.

Each of those bugs turns the approved sentence into an untrue sentence with no user-visible signal and no telemetry to report it. The filter is a claims-compliance component, not a helper.

Also required, for a different reason with the same consequence: the `<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>` manifest block. Without it, Android 11+ package visibility hides the engine, the voice list comes back empty, and every user gets a board that cannot speak. Assert its presence in a test that reads the manifest.

**For a genuinely provable in-process guarantee,** the only path is bundling a synthesis engine (FFI to a local engine, or an on-device ONNX runtime). That is a real scope decision. Until it is taken, the scoped wording is the ceiling — do not write copy that presumes the stronger architecture.

## Store paperwork

- **"No data" does not mean "no paperwork."** Play requires the Data Safety form and a privacy policy link **even from developers who collect nothing**. Apple requires App Privacy details on every submission plus a privacy policy link in both App Store Connect metadata **and** in the app, and privacy manifests for the app and any third-party SDK. These are submission blockers, not polish.
- The upside: the policy is three honest paragraphs and is the strongest marketing page the product has. Write it as such.
- **A local-only free-text field is not user-generated content.** The store obligations around UGC — filtering, reporting, blocking — all presuppose content being *posted* to somewhere or reaching another user. Nothing in a type-to-speak box does. No moderation surface, no counterparty. **This flips instantly** on adding board sharing, cloud sync, or import-from-URL; any of those reopens every store question here.
- **Describe function, not medical benefit.** *"Tap a tile or type; your phone speaks it aloud or shows it in large type. Offline. No account."* Never "treats," "improves language outcomes," or "clinically proven."
- **Offline is table stakes, not the wedge.** Competitors are already fully offline. Leading with offline as a differentiator invites a correction from someone who knows the category. Privacy — specifically the OS-enforced permission fact — is the differentiated claim. Offline is a feature line.

## Review checklist for any privacy sentence

Reject the sentence if it:

- says or implies "nothing leaves your device," "fully private," "100% offline," "your words never leave the phone," or "we can't see anything"
- claims anything about what the **TTS engine** does with the text
- omits the word *declare* when describing voice selection
- promises iCloud/Google backup exclusion as a certainty rather than a request
- implies the Android permission guarantee holds on iOS
- cites open source as evidence for the privacy claim
- makes a claim the manifest does not currently back — check the manifest before shipping the sentence, not after
