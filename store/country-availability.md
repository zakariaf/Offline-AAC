# Country availability (E11-T01)

## The EU / EEA is excluded at launch. Do not "tidy this up."

In both Play Console country availability and App Store Connect availability,
**every EU / EEA member state is deselected.**

### Why — this is settled, not arguable

MDCG 2019-11 Rev.1 (17 June 2025), p.35, classifies:

> "MDSW app intended to assist persons with a communication disorder (e.g.
> cerebral palsy, **autism (ASD), selective mutism**, MS, MND, Down's syndrome,
> **aphasia**…) talk by converting a set of selected symbols into spoken
> language"

as a **Class I medical device under Rule 11c**. The autism/aphasia/mutism
example was **added in Rev.1**; the 2019 original has zero hits for those terms.
MDR Art. 2(12) defines intended purpose by the manufacturer's own promotional
materials, so compensating for a disability **is** the medical purpose in the EU.
There is no wording that writes around it.

### Re-adding the EU is a project, never a config change

The first EU install attaches: a technical file, a clinical evaluation, an
Art. 10(9) QMS, a PRRC under Art. 15, UDI, EUDAMED registration (mandatory since
28 May 2026), post-market surveillance, CE marking, and an EU Authorised
Representative. Months and five figures. Treat "we'll open the EU next sprint" as
out of scope, full stop.

### Consequence for copy

The "not a medical device" disclaimer (see `play-listing.md`) is scoped to
**non-EU storefronts only**. Asserting it to EU users would contradict the
Commission's own classification example and could become evidence of a false
statement.

## Excluded (EU / EEA)

Austria, Belgium, Bulgaria, Croatia, Cyprus, Czechia, Denmark, Estonia, Finland,
France, Germany, Greece, Hungary, Ireland, Italy, Latvia, Lithuania, Luxembourg,
Malta, Netherlands, Poland, Portugal, Romania, Slovakia, Slovenia, Spain, Sweden
— plus Iceland, Liechtenstein, and Norway (EEA).

Verify by **reading the list** in the console, not by remembering the checkbox.

## Launch markets

Non-EU English-speaking markets first (United States, United Kingdom, Canada,
Australia, New Zealand, Ireland is EU→excluded). Expand deliberately, checking
each market's assistive-tech / medical-device posture before adding it.
