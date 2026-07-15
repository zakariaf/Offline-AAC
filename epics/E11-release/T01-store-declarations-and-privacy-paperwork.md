# E11-T01 — Store declarations and privacy paperwork

| | |
|---|---|
| **Epic** | E11 — Release |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E09-T02 |
| **Blocks** | E11-T04 |

**Skills:** `reed-store-and-legal` · `reed-privacy-claims` · `reed-copy-voice`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Play will not accept a submission — including **closed and open testing** — without the Health apps declaration and a completed Data Safety form with a privacy policy link, and it requires both from developers who collect nothing at all. Ship to the EU without noticing that MDCG 2019-11 Rev.1 names autism and aphasia AAC apps as Class I medical devices and the first EU install attaches a technical file, a QMS, a PRRC, an EU Authorised Representative and EUDAMED registration — months and five figures, triggered by a checkbox nobody read. And the audience fact-checks privacy copy in public: one overclaimed sentence ("nothing leaves your device") is caught by a hostile reader with a decompiler and costs the product the exact community it needs. This is not paperwork you do at submission. It is a design constraint with a deadline.

## Scope

Four deliverables: the privacy policy (hosted + in-app), the Play Data Safety form, the Play Health apps declaration, and the country/category/rating configuration.

### 1. Privacy policy — the document

Three honest paragraphs. It is the strongest marketing page the product has; write it as one, not as a legal dump. It must be reachable at a stable public URL **and** from inside the app (Apple 5.1.1(i) requires the link in App Store Connect metadata **AND** in the app; do both on Android too rather than maintaining two surfaces).

The network/speech claim is fixed text. Use this, or a paraphrase that keeps all three scoping clauses:

> This app has no network code and no network permission. Speech is synthesized by your device's own system TTS engine, and we only select voices that declare they need no network.

Every clause is load-bearing:

| Clause | Why it cannot be cut |
|---|---|
| "no network code and no network permission" | Scopes the claim to Reed's own binary — the provable part. |
| "your device's own system TTS engine" | Names the process boundary honestly. Android binds a **separate engine app** over `android.intent.action.TTS_SERVICE`, running under **its own UID with its own INTERNET permission**. Reed's manifest cannot constrain, inspect or revoke it. |
| "only select voices that declare they need no network" | The verb is **declare**. Reed reads `network_required` from a map the engine populated. Never upgrade to "guarantee", "ensure", or "cannot". |

Claims permitted in the policy and listing, strongest first:

1. **No INTERNET permission.** Lead with this. It is OS-enforced — the kernel denies the socket — and visible on the Play listing *before install*. A user verifies the central claim without trusting Reed, installing Reed, or reading code. Nothing else in the category offers that.
2. No accounts, no server, no analytics SDK, no crash-reporting SDK.
3. The app keeps working if the developer stops maintaining it. No entitlement check to expire, no server to shut down. Say it out loud.
4. **Cloud backup is off by default; export is user-initiated.** Only writable once `allowBackup="false"` and explicit `dataExtractionRules` are actually in the manifest — that is E09-T02, which is why this task depends on it. Open the manifest and confirm before the sentence is typed.

Register (this is user-visible copy and obeys `reed-copy-voice`): second person, present, active. No "we" narrating a team — the approved sentence's "we" is the manufacturer speaking in a legal document, and it is the only place it is permitted; nowhere in app chrome. No exclamation marks. Curly apostrophes. No "just" or "simply".

### 2. In-app link

A settings entry that opens the policy. Copy at chrome register, name-first, no prose:

```
✓  Privacy policy
✗  Learn more about how we protect your privacy!
```

Do not gate it behind a dialog and do not put it in an onboarding modal — there is no onboarding gate.

### 3. Play Data Safety form

Complete it declaring **no data collected, no data shared**, and attach the privacy policy URL. "No data" does not exempt you from the form. Note in the listing copy that the Data Safety card is **developer self-declared** — do not write copy anywhere implying Google or Apple *verified* the privacy claims. The manifest-derived permissions list is the only fact, and it is the thing to point at.

### 4. Play Health apps declaration

Mandatory under **Policy > App content** for every developer with a published app, testing tracks included. Reed is not being marketed as a medical device in the shipped storefronts, so declare it non-device and carry the required disclaimer — **scoped to non-EU storefronts only** (see below). Use the category leader's pattern: as-is + limitation of liability + "does not, and will never, provide medical advice. The Material is by no means intended to be a substitute for professional medical advice, diagnosis, or treatment."

**Never imply emergency-grade reliability.** No disclaimer of emergency failure either — do not invite the reliance in order to disclaim it.

### 5. Country, category, rating

- **Geo-restrict: exclude all EU countries at launch.** In Play Console country availability and App Store Connect availability. MDCG 2019-11 Rev.1 (17 June 2025) p.35 classifies "MDSW app intended to assist persons with a communication disorder (e.g. cerebral palsy, **autism (ASD), selective mutism**, MS, MND, Down's syndrome, **aphasia**…) talk by converting a set of selected symbols into spoken language" as **class I per Rule 11c**. The example was added in Rev.1; the 2019 original has zero hits for autism, aphasia, mutism or symbol. This is settled, not arguable. Do not attempt to write around it — MDR Art. 2(12) defines intended purpose by the manufacturer's own promotional materials, and compensating for a disability **is** the medical purpose in the EU. Treat "add EU countries" as a project, never a config change.
- **Declare the app not primarily child-directed** in Play. Never enrol in Apple's Kids Category. Extra restrictions, and it ships the exact infantilizing framing the product exists to reject. COPPA is not triggered regardless — it attaches to *collection* of personal information, and there is none.
- **IARC / content rating: answer no to UGC, interaction and messaging.** A local-only free-text field is not user-generated content: Apple 1.2's obligations (filter before posting, reporting mechanism, block abusive users, publish contact info) all presuppose content reaching another user. Nothing typed into the speak field leaves the device. Expect Everyone / 4+.

### 6. Listing copy

Describe function, not medical benefit:

> Tap a tile or type; your phone speaks it aloud or shows it in large type. Offline. No account.

**Banned words:** treats, therapy, improves language outcomes, clinically proven, diagnoses, prescribed, medical-grade, emergency.

Use the field's own vocabulary — **part-time AAC**, **unreliable speech**, **intermittent speech**. That is what the audience searches and it reads as a credibility signal to the SLPs who refer.

**Offline is a feature line, not the wedge.** Competitors are already fully offline; leading on it invites a correction from someone who knows the category. Privacy — specifically the OS-enforced permission fact — is the differentiated claim.

Nothing in the listing may imply a curated or safe vocabulary. There is no content filter and the copy must not suggest one.

### Out of scope

- Keystore, version codes, upload mechanics, signing (E11-T04).
- The `allowBackup="false"` / `dataExtractionRules` manifest work and the "Keep my board off cloud backup" control itself (E09-T02) — this task only *verifies* they landed and then writes the sentence.
- The `network_required` voice filter implementation. This task depends on it being correct; it does not build it.
- iOS submission. Capture the iOS asymmetry in the policy wording now so the text does not have to be rewritten later, but App Store Connect work is not here.
- Any VPAT. Voluntary, and a commercial door-opener, not a submission blocker.

## Acceptance criteria

- [ ] `grep -c 'android.permission.INTERNET' android/app/src/main/AndroidManifest.xml` returns 0. The lead privacy claim is backed by the manifest that actually ships.
- [ ] `grep 'android:allowBackup' android/app/src/main/AndroidManifest.xml` shows `"false"` and `android:dataExtractionRules` is present and points at a rules file with no `<cloud-backup>` content. If either is missing, criterion 4 of the claims list is struck from the policy — the sentence does not ship ahead of the manifest.
- [ ] The privacy policy text contains the exact three-clause network sentence, including the word **declare**.
- [ ] A test greps the policy source for each banned string and fails on any hit: `nothing leaves your device`, `fully private`, `100% offline`, `never leave`, `we can't see`, `guarantee`, `treats`, `therapy`, `clinically proven`, `medical-grade`, `emergency`, `open source`.
- [ ] A widget test taps the settings entry and asserts the policy destination is reachable — the in-app link exists and is not dead. Apple 5.1.1(i) requires the in-app link, and a link that 404s is worse than absent.
- [ ] The policy URL resolves over HTTPS and is entered in both the Data Safety form and the store listing's privacy policy field.
- [ ] Play Console screenshot or checklist entry showing Data Safety = no data collected, no data shared, policy URL attached.
- [ ] Play Console Health apps declaration submitted; non-device disclaimer text present in the listing for non-EU storefronts only.
- [ ] Play Console country availability shows every EU member state excluded. Verified by reading the list, not by remembering the checkbox.
- [ ] Play "primarily child-directed" = no; not enrolled in Families.
- [ ] IARC questionnaire answers recorded: UGC no, interaction no, messaging no.
- [ ] `reed-copy-voice` review checklist run over the policy and listing copy: grep for `!` in a string, `'` straight apostrophes, `caregiver`, `parent`, `student`, `learner`, `Sorry`, `Oops`, `just `, `simply`, `Please`, `Great`. Every hit resolved.

## Traps

- **Writing the backup sentence before the manifest backs it.** "Cloud backup is off by default" is false until `allowBackup="false"` is actually in the shipped manifest — and `android:allowBackup` **defaults to true**. With no code written, the SQLite database of every phrase the user ever curated is uploaded to Google Drive. A privacy label saying "no server" over a manifest saying `allowBackup="true"` is a trap set for yourself, and the person who springs it is a hostile reader with a decompiler.
- **Softening "declare" to "ensure" during a copy edit.** It reads better. It is a lie. The engine self-reports `network_required`; Reed filters on the report and cannot verify it. This is the single most likely regression in this document and it will arrive disguised as polish.
- **The absolutist sentence sneaking back in.** "Nothing leaves your device" is false twice: TTS crosses a process boundary into an app with its own INTERNET permission, and backup defaults on. It will feel like the natural summary of everything else in the policy. It is banned in the listing, the policy, onboarding, the README, and a Reddit reply.
- **Shipping the "not a medical device" disclaimer globally.** Play pushes non-device health apps to say it. Asserting it to EU users contradicts the Commission's own classification example and could become evidence of a false statement. Scope it to non-EU storefronts.
- **Treating EU exclusion as reversible later.** It is one checkbox now. Re-adding it is a technical file, clinical evaluation, Art. 10(9) QMS, a PRRC under Art. 15, UDI, EUDAMED registration (mandatory since 28 May 2026), post-market surveillance, CE marking and an EU Authorised Representative. Do not let anyone scope "we'll open the EU next sprint".
- **Forgetting the testing tracks.** The Health apps declaration is mandatory for closed and open testing too. Discovering it at the internal-test upload is a schedule hit at the worst moment.
- **Claiming the stores verified anything.** A Data Safety card is developer self-declared. Copy implying Google vetted it is false and will be corrected in public by someone who knows.
- **Reaching for open source as the trust argument.** It is a downgrade: source cannot prove the shipped binary matches it, and you would be trading a kernel-enforced guarantee for "trust me". CoughDrop already withdrew its open-source promise on acquisition in March 2023. Open-sourcing may be the right *exit plan* — an ethical argument, kept entirely out of privacy copy.
- **Carrying the Android permission claim into shared iOS copy.** iOS offers no equivalent OS-enforced, pre-install network guarantee. `isExcludedFromBackup` is documented by Apple as **guidance, not a guarantee** — "it's not a mechanism to guarantee those items never appear in a backup." Say what the app *requests*, never what the platform promises.
- **Inviting users to send crash logs.** `CrashLog.record(message, stack)` will happily capture vocalization text — a user mailing a log could leak "I need to leave, I'm not able to talk right now" plus whatever they typed. No copy inviting log submission until redaction exists and is tested.
- **Answering the IARC UGC question yes because "users type text".** They type text to themselves. There is no counterparty and no moderation surface. This flips instantly if board sharing, cloud sync or import-from-URL ever ships — those are policy features, not sync features, and they reopen every question on this page.

## Files

- `legal/privacy-policy.md` — the policy source of truth, and the body of the hosted page.
- `lib/src/settings/` — the settings entry that opens the policy (name-first chrome copy, lowercase).
- `test/policy/privacy_copy_test.dart` — banned-string grep over the policy and listing copy.
- `test/policy/manifest_claims_test.dart` — asserts no INTERNET permission, `allowBackup="false"`, `dataExtractionRules` present; fails the build if the manifest stops backing the sentence.
- `store/play-listing.md` — listing copy, non-EU disclaimer block, Data Safety and Health apps answers recorded as text so they are reviewable in a diff.
- `store/country-availability.md` — the EU exclusion list and the reason, so the next person does not "tidy it up".

## Done when

The Play Console shows a completed Data Safety form and Health apps declaration with every EU country excluded, and the privacy policy — containing the exact three-clause network sentence — is live at a URL linked from both the store metadata and a settings entry in the app, with tests failing the build if the manifest ever stops backing what the policy says.
