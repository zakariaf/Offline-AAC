# brand-identity-voice--the-play-store-title-and-the-home-screen-lau

> Phase: **verify** · Agent `ac43f8374e430f8d8` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Corrected version: "The Play Store store-listing title (30-char cap since Sept 29 2021, down from 50, announced April 2021, fully rolled out Dec 15 2021) and the on-device app name are separate fields, and no Play policy requires them to match. The on-device name comes from `android:label` on `<application>` in AndroidManifest.xml — but note that `android:label` on the launcher `<activity>` (MAIN/LAUNCHER intent filter) overrides it, so verify MainActivity carries no label of its own (the default Flutter template does not, so `<application android:label='Reed'>` works out of the box). There is NO `android:shortLabel` attribute in AndroidManifest.xml; launchers have no short-label fallback for the app icon and simply ellipsize `android:label`. (`android:shortcutShortLabel` is a real but unrelated attribute — it sits on `<shortcut>` in res/xml/shortcuts.xml and labels long-press shortcut menu entries.) No documented length limit exists for `android:label`; truncation is launcher-dependent, so keep it short on judgment rather than to a cited number. Ship Play title `Reed: AAC & Text to Speech` (26 chars) and `android:label='Reed'`. Caveat: this secures home-screen discretion only — the full keyword-suffixed title still appears in Play search, the store listing, the user's Play library, and update notifications. Play policy also says 'avoid repetitive or unrelated keywords,' so keyword suffixing is constrained; the proposed title passes because it is descriptive and relevant."

**Evidence:** HEADLINE CLAIM SURVIVES. The two fields are genuinely separate and Play policy does not require them to match.

CONFIRMED against primary sources:
1. 30-character cap — support.google.com/googleplay/android-developer/answer/9898842 states verbatim: "Your app title must be 30 characters or less." Confirmed on the primary policy page, not just the ASO blogs.
2. History (50 -> 30, announced April 2021, enforced Sept 29 2021) — corroborated across multiple independent ASO trade sources. Note one added detail the claim omits: full rollout completed 15 Dec 2021, with Sept 29 2021 as the enforcement start.
3. No matching requirement — the policy page constrains only what CANNOT appear in the title (store performance/ranking, price, promotional info, references to Google Play programs). Nothing anywhere requires the store title to match the on-device name, and the page gives no guidance at all about the on-device name. The absence is real, not an oversight in my search.
4. `android:label` on `<application>` is the on-device name — confirmed on developer.android.com/guide/topics/manifest/application-element: "A user-readable label for the application as a whole and a default label for each of the application's components."
5. Character counts are right: "Reed: AAC & Text to Speech" = 26 chars, under the 30 cap.

THREE DEFECTS, one of them a fabricated API:

DEFECT 1 — `android:shortLabel` DOES NOT EXIST, and the mechanism described is wrong twice over.
I pulled the complete attribute list for the `<application>` element from developer.android.com. All 50 attributes are enumerated; there is no `shortLabel` among them. The claim's supporting mechanism ("`android:shortLabel` used by launchers when space is tight") is fabricated on three counts:
  (a) Wrong name. The real attribute is `android:shortcutShortLabel` (paired with `android:shortcutLongLabel`). Bare `android:shortLabel` is not a valid attribute anywhere in the manifest — it appears to be a garbling of the `ShortcutInfo.Builder.setShortLabel()` Java/Kotlin method name.
  (b) Wrong element and wrong file. `android:shortcutShortLabel` lives on the `<shortcut>` element in res/xml/shortcuts.xml, NOT in AndroidManifest.xml as the claim states.
  (c) Wrong function entirely. It controls the text of app-shortcut entries in the long-press menu — the "Compose", "New note" items. Launchers NEVER consult it for the home-screen app icon label. There is no manifest-level short-label fallback for the app icon; launchers simply ellipsize `android:label`.
The ~10-char guidance the claim seems to be half-remembering is Google's advice for shortcut short labels ("limit to ~10 characters"), which has nothing to do with app labels. This looks like the "<15 chars" number's actual origin.

DEFECT 2 — the claim omits the attribute that actually wins.
`android:label` on the launcher `<activity>` (the one with the MAIN/LAUNCHER intent filter) OVERRIDES the `<application>` label for the home-screen icon. Per developer.android.com/guide/topics/manifest/activity-element: "If this attribute isn't set, the label set for the application as a whole is used instead." So `<application android:label="Reed">` only produces "Reed" on the home screen if MainActivity carries no label of its own. This happens to hold for the default Flutter template (which labels `<application>` and leaves MainActivity unlabeled), so the recommendation works — but it works by accident of the template, not for the reason given. Anyone who has set an activity label will get a silent no-op.

DEFECT 3 — "<15 chars" has no primary source, and "resolves the ENTIRE tension" is an overclaim.
There is no documented character limit or recommended length for `android:label` anywhere in Android's docs. Launcher truncation is launcher-dependent (Pixel Launcher, One UI, and third-party launchers differ in line count and font), so no single number is authoritative. "<15" is a reasonable rule of thumb but must not be cited as a spec — and "Reed" at 4 chars makes it moot here regardless.

The "resolves the entire tension" framing is the part a design decision should not lean on. Two residual leaks remain: (a) Play policy says "Avoid using repetitive or unrelated keywords or references" — keyword suffixing is CONSTRAINED, not unconstrained. "Reed: AAC & Text to Speech" is descriptive and relevant so it passes, but the claim's blanket "keyword-suffixed store titles are standard practice" overstates the latitude. (b) More importantly for an AAC app where discretion is the actual design goal: the 26-char Play title, not the launcher label, is what appears in the Play Store listing, Play search, the user's Play library / "Manage apps" list, and update notifications. A shoulder-surfer looking at the home screen sees "Reed"; one looking at Play Store updates sees "AAC & Text to Speech". The separate-fields fact buys home-screen discretion only — a real and useful win, but a partial one.

BOTTOM LINE: ship the recommendation (Play title "Reed: AAC & Text to Speech", `android:label="Reed"`) — it is sound and the sourcing holds. But strike `android:shortLabel` from the corpus entirely; it is an invented API that would send an implementer chasing a no-op attribute. Verify MainActivity carries no competing label. Stop citing "<15 chars" as spec. And do not let "resolves the entire tension" stand — Play-surface exposure is unaddressed by this fact.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "brand-identity-voice" made this claim, and a design decision depends on it.

CLAIM: The Play Store title and the home-screen launcher label are separate fields and need not match — this single fact resolves the entire discretion-vs-ASO tension
DETAIL: Play Console store-listing title is capped at 30 characters (reduced from 50 in April 2021, effective Sept 29 2021). The home screen label comes from `android:label` in AndroidManifest.xml, with `android:shortLabel` used by launchers when space is tight. Nothing in Play policy requires them to match; keyword-suffixed store titles with short launcher labels are standard practice. Ship Play title `Reed: AAC & Text to Speech` (26 chars) and `android:label="Reed"`. Recommend <15 chars for the label to avoid launcher truncation.
CLAIMED SOURCES: https://support.google.com/googleplay/android-developer/answer/9898842, https://www.apptweak.com/en/aso-blog/how-to-shorten-your-app-name-on-the-play-store, https://www.tutorialpedia.org/blog/what-is-the-maximum-length-for-an-android-application-name/
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: m3.material.io, developer.apple.com, api.flutter.dev, docs.flutter.dev, the actual type foundry, the actual paper.

Hunt for these failure modes, in order of likelihood:
1. **Marketing repeated as research.** Google's M3 Expressive claims (46 studies, 18,000 participants, "4x faster") and Lexend's readability claims are the specific hazards. Did anyone publish a methodology? Is it peer-reviewed, or is it a blog post? If a number has no methodology behind it, SAY SO — a design direction is being justified with it.
2. **Design folklore presented as evidence.** "Autistic people prefer muted colors", "sans-serif is more legible", "the aesthetic-usability effect", color psychology. Find the actual study, check the sample and whether it replicated, and check whether the popular claim matches what the paper found.
3. **Version/API rot.** Flutter lags the Material spec — a spec feature is NOT a Flutter feature. If the claim says Flutter can do something, VERIFY on api.flutter.dev or the release notes. Check whether a named API exists with that exact name.
4. **Invented specifics** — hex values, token names, type sizes, shape counts, font axes, license terms. If it's specific, verify it's real.
5. **License claims** about typefaces or assets. Verify against the actual foundry/repo.

Default to refuted=true if you cannot substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + correction if directionally right but wrong in the specifics. UNVERIFIABLE if nothing settles it — say so plainly rather than guessing.
````

</details>
