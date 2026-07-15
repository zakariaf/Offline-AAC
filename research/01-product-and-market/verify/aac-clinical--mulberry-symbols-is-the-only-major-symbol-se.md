# aac-clinical--mulberry-symbols-is-the-only-major-symbol-se

> Phase: **verify** · Agent `a0faf1d04a5660903` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Mulberry Symbols is the only major adult-oriented AAC symbol set that is commercially usable without seeking permission — but it is not the only one explicitly designed for adults. Sclera states its pictograms "were drawn for adults," but is CC BY-NC and requires explicit consent plus a signed agreement for commercial use; ARASAAC is CC BY-NC-SA. Mulberry's license version is genuinely ambiguous upstream, not settled at 4.0: LICENSE.txt names no version but links to by-sa/4.0/, while the current website and README both instruct attribution as "Creative Commons Attribution-ShareAlike 2.0 UK: England & Wales"; GitHub's detector returns NOASSERTION. Copyright is shared — "2008-2017 Garry Paxton, 2018-2020 Steve Lee" — so attribution should credit Paxton as original author alongside Lee, with a link to mulberrysymbols.org. The live set is ~3,436 SVGs (flat EN/ directory on master, release v3.5.2, Sept 2025), not 3,116 — that figure is OpenSymbols' stale index. The set is maintained but lightly and by a single person (last commit 2026-02-12), despite openaac.org still labeling it "unmaintained." The binding conditions and the ShareAlike scope analysis in the original claim are correct: commercial use is permitted, you must not sell the symbols themselves as a pack, derived symbols must be relicensed BY-SA, and ShareAlike does not reach the app's source code.

**Evidence:** The claim's practical conclusion survives, but three specifics are wrong — including the headline superlative and the license version, which is the part a product decision would rest on.

1) "ONLY major symbol set explicitly designed for adults" — FALSE. Sclera states on its own site that "The pictograms were drawn for adults but are suitable for children." Sclera is unambiguously major (4,700+ per sclera.be; 11,000 per OpenAAC/OpenSymbols). So Mulberry is not the only adult-designed set. What IS true, and what actually drives the decision, is that Sclera is CC BY-NC: its copyright page says commercial use is "not automatically permitted... you will need our explicit consent" plus a signed agreement with Sclera NPO. ARASAAC is CC BY-NC-SA (also NC). So Mulberry is the only major adult-oriented set commercially usable WITHOUT seeking permission — a narrower and defensible claim.

2) License version — INVERTED, and unresolved upstream. The claim asserts 4.0 and waves off 2.0 UK as "older releases." The reverse is closer to true. I pulled the raw LICENSE.txt from master: it says only "Creative Commons Attribution-Share Alike License" with a link to https://creativecommons.org/licenses/by-sa/4.0/ — no version named in the text. But the CURRENT website (copyright "2018 to 2026") and the CURRENT README both instruct users to attribute as "Creative Commons Attribution-ShareAlike 2.0 UK: England & Wales License." That is the live recommended string, not a legacy artifact. GitHub's own license detector returns spdx_id NOASSERTION — it cannot determine the license either. This is a genuine upstream inconsistency, not a settled 4.0. Practically both are BY-SA so the obligations are identical (commercial OK, attribution, ShareAlike on derivatives), but note CC BY-SA 2.0 UK is a jurisdiction port and is not automatically upgradeable to 4.0. Worth an email to Steve Lee before shipping if the version matters.

3) "Copyright Steve Lee" — INCOMPLETE. LICENSE.txt reads: "Copyright 2008-2017 Garry Paxton / Copyright 2018-2020 Steve Lee." Garry Paxton is the original author; Lee took over in 2018. Attribution crediting only Steve Lee under-credits the set.

4) Symbol count 3,116 — STALE, and understated in the product's favor. That is OpenSymbols' index figure. The live master tree has 3,436 .svg files in a flat EN/ directory (no subdirs, no non-SVG files). Latest release v3.5.2, Sept 17 2025.

5) A source the researcher cited contradicts them and they did not reconcile it: openaac.org/symbols.html labels Mulberry an "unmaintained symbol library with 3,000 symbols." I checked — that label is itself stale. Repo is not archived, latest commit 2026-02-12, release v3.5.2 Sept 2025. So Mulberry is maintained, but lightly (small fix releases; the maintainer is one person, which is a real bus-factor risk for a set the product depends on).

CONFIRMED as stated: the adult-orientation differentiator quote ("Adult oriented symbols - most proprietary sets are designed for children" — verified verbatim in README and as the GitHub repo description "Communication symbol set designed for adults with language difficulties"); the "may charge for your product or added value, you must not charge for the symbols themselves" condition (verified verbatim); SVG format; GitHub hosting; and the ShareAlike analysis — CC BY-SA attaches to the artwork and its derivatives and does not make the app's source code copyleft. That last point is correct and is the one people most often get wrong.

Net effect on the product decision: unchanged. Mulberry remains the right pick. But do not ship the string "CC BY-SA 4.0, © Steve Lee" as your attribution on the strength of this claim — both halves are contestable against the project's own current guidance.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
PRODUCT IDEA UNDER RESEARCH — "Dignified offline AAC for adults & teens with situational speech loss"

Who it's for: Autistic adults and teens who go non-speaking during shutdowns/meltdowns/sensory overload, plus people with selective mutism, aphasia, or post-seizure speech loss. Communities: r/autism, r/AutisticAdults, r/selectivemutism, AAC communities.
The problem: Mainstream AAC apps are built for young children — cartoon avatars, "parental" account gates, kiddie vocabulary — infantilizing for adults, so they abandon them. Premium options (Proloquo2Go/TouchChat/LAMP) run ~$299 and are iOS-only.
Why offline is essential: It's a disability accommodation, not a networked service. The user must be able to "speak" instantly — in a shop, an ER, a car with no signal, mid-shutdown — with zero login, zero loading, full privacy.
The core job: Tap a phrase/symbol tile (or type) and the phone speaks it aloud, instantly, offline, adult-appropriate design, no account.
MVP: grid of large customizable phrase tiles + "type to speak" box + on-device TTS. Editable categories. No sign-up. Nothing leaves device. Dark, calm, adult visual design.
Risks: TTS must sound acceptable; design must feel adult without being cold; must be usable one-handed by someone in distress.
Target stack: Flutter (cross-platform iOS + Android; user prefers Flutter over React Native).
Today's date: 2026-07-15. Prefer recent sources (2024-2026).


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "aac-clinical". A product decision depends on it, so it must be right.

CLAIM: Mulberry Symbols is the only major symbol set explicitly designed for adults, and it is CC BY-SA 4.0 — commercially usable, 3,116 symbols
THEIR DETAIL: Mulberry states its own differentiator as: 'Adult oriented symbols - most proprietary sets are designed for children.' License is Creative Commons BY-SA 4.0 (some sources cite CC BY-SA 2.0 UK for older releases), copyright Steve Lee, 3,116 symbols per OpenSymbols, distributed as scalable SVG, hosted on GitHub (mulberrysymbols/mulberry-symbols). Commercial use IS permitted for products/services. Two binding conditions: (1) 'While you may charge for your product or added value, you must not charge for the symbols themselves' — i.e. do not sell a symbol pack as an IAP, but a paid app that includes them is fine; (2) ShareAlike — any DERIVED/edited symbols must be released under the same license, and attribution crediting Steve Lee with a link to mulberrysymbols.org is required. Note ShareAlike attaches to the symbol artwork and its derivatives, NOT virally to the app's source code. This set is a near-exact match for the product thesis.
THEIR CLAIMED SOURCES: https://mulberrysymbols.org/, https://www.opensymbols.org/, https://www.opensymbols.org/repositories/mulberry, https://github.com/mulberrysymbols/mulberry-symbols, https://www.openaac.org/symbols.html
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
