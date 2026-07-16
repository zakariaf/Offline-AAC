# Play / App Store listing & declarations (E11-T01)

The answers below are recorded here so they are reviewable in a diff. They are
entered by hand in the Play Console and App Store Connect; this file is the
source they are copied from, not a submission.

## Listing copy

**Title:** Reed

**Short description (≤80):** Offline speech for when your voice comes and goes.

**Full description — describes function, not medical benefit:**

> Tap a phrase tile or type a sentence; your phone speaks it aloud, or shows it
> full-screen in large type. Offline. No account.
>
> Reed is a text-to-speech board for part-time AAC — built for autistic adults
> and teens whose speech is intermittent or unreliable. The vocabulary is yours:
> large tiles you rewrite to your own words, with no fixed vocabulary and no
> content filter. Pick a voice already on your phone and set its pitch and speed.
>
> No accounts, no sign-up, no analytics, no ads. On Android, Reed ships without
> the INTERNET permission — you can confirm that on this page before you install.

**Banned from all listing copy:** treats, therapy, improves language outcomes,
clinically proven, diagnoses, prescribed, medical-grade, emergency. Nothing may
imply a curated or "safe" vocabulary — there is no content filter, and the copy
must not suggest one. Offline is a **feature line, not the wedge**; the
differentiated claim is the OS-enforced permission fact.

Use the field's own vocabulary — *part-time AAC*, *unreliable speech*,
*intermittent speech* — it is what the audience searches and reads as a
credibility signal to referring SLPs.

## Play Data Safety form

- **Data collected:** none.
- **Data shared:** none.
- **Privacy policy URL:** https://reed.applander.io/privacy
- Note in any surrounding copy: the Data Safety card is **developer
  self-declared**. Do not imply Google or Apple verified the privacy claims. The
  manifest-derived permission list is the only fact to point at.

("No data" does not exempt the app from the form — Play requires it and a policy
link even from developers who collect nothing.)

## Play Health apps declaration

Mandatory under **Policy → App content** for every developer with a published
app, **including closed and open testing**. Reed is declared **non-device** and
carries the standard disclaimer — **scoped to non-EU storefronts only** (see
`country-availability.md`):

> Reed is a communication tool and does not, and will never, provide medical
> advice. The material is by no means intended to be a substitute for
> professional medical advice, diagnosis, or treatment.

**Never imply emergency-grade reliability**, and do not add a disclaimer of
emergency failure either — do not invite the reliance in order to disclaim it.

## Category, rating, audience

- **Primarily child-directed:** **No.** Never enrol in Apple's Kids Category or
  Play's Families programme — that declaration ships the exact infantilising
  framing the product exists to reject. COPPA is not triggered regardless: it
  attaches to *collection* of personal information, and there is none.
- **IARC content rating:** answer **No** to user-generated content, to
  interaction, and to messaging. A local-only type-to-speak field is not UGC —
  there is no counterparty and nothing is posted anywhere. Expect Everyone / 4+.
  (This flips instantly if board sharing, cloud sync, or import-from-URL ever
  ships — those reopen every question here.)

## In-app privacy link (Apple 5.1.1(i))

Required in App Store Connect metadata **and** inside the app. In Reed it is
**settings → privacy policy**, which opens the bundled
[`legal/privacy-policy.md`](../legal/privacy-policy.md) offline; the same text is
hosted at https://reed.applander.io/privacy for the store metadata field.
