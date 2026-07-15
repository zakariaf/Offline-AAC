# legal-regulatory--arasaac-s-nc-clause-is-confirmed-and-does-bl

> Phase: **verify** · Agent `a9182631d41b6f8b9` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** ARASAAC is confirmed CC BY-NC-SA and does block a paid app (though written authorization from the Government of Aragon is a documented, if impractical, path — "fatal" is marginally strong). Mulberry remains the right answer and is genuinely marketed as adult-oriented, with ~3,116 symbols (not ~3,150) and active maintenance (v3.5.2, Sep 2025) — BUT its license is ambiguous, not settled: the website says CC BY-SA 2.0 UK: England & Wales (c) Steve Lee, while the repo LICENSE.txt says CC BY-SA 4.0 International with TWO copyright holders (Garry Paxton 2008-2017, Steve Lee 2018-2020). Clarify with the maintainer before shipping. Blissymbolics is NOT royalty-blocked and should not be avoided on that basis: BCI's current licensing page places the BCI-AV under CC BY-SA 4.0, explicitly usable "in any project or product, commercial or otherwise" with attribution, with no royalty mentioned — the "royalty based" claim is outdated 3.0-era text. Sclera CC BY-NC (blocked) is correct. SymbolStix Prime is ~$250 CDN/yr (not USD) and is sold as one service-provider access plus up to 15 student licenses (an org seat model), not "personal use only"; it remains proprietary and non-redistributable. Viable commercial-safe sets are therefore Mulberry AND Blissymbolics, not Mulberry alone.

**Evidence:** HEADLINE CONFIRMED: (1) ARASAAC terms-of-use page confirms CC BY-NC-SA and carries the quoted exclusion of "any product or publication for commercial purposes"; attribution to Sergio Palao / Government of Aragon / ARASAAC required. The NC clause does block a paid app. (2) Mulberry's site verbatim: "Adult oriented symbols - most proprietary sets are designed for children" and "While you may charge for your product or added value, you must not charge for the symbols themselves." (3) Sclera confirmed CC BY-NC (blocked) per openaac.org.

THREE SPECIFICS REFUTED:

(1) BLISSYMBOLICS IS NOT ROYALTY-BLOCKED — materially changes the option set. The current blissymbolics.org/index.php/licensing page states the BCI Authorized Vocabulary (BCI-AV) and other BCI Blissymbol products are made available under Creative Commons BY-SA 4.0, usable "in any project or product, commercial or otherwise" with clear attribution to BCI and redistribution under the same license. The page contains NO mention of royalties, fees, or a separate BCI commercial license agreement. The claim's "'royalty based' license from BCI is required for all commercial products (avoid)" is stale CC BY-SA 3.0-era language surviving only in secondary/search-snippet sources; the primary source contradicts it. Bliss should not be on the avoid list.

(2) MULBERRY'S LICENSE VERSION IS CONTRADICTORY, NOT SETTLED. mulberrysymbols.org attribution section says "copyright 2018 to 2026 Steve Lee and licensed under the Creative Commons Attribution-ShareAlike 2.0 UK: England & Wales License." But the repo's LICENSE.txt (raw.githubusercontent.com/mulberrysymbols/mulberry-symbols/master/LICENSE.txt) says CC BY-SA 4.0 International and names TWO copyright holders: Garry Paxton (2008-2017) AND Steve Lee (2018-2020). The researcher reported one side of an unresolved conflict as fact and dropped a co-copyright-holder. This matters legally: 2.0 UK is a ported legacy license with no international scope and no automatic 4.0 upgrade clause. Requires clarification from Steve Lee before shipping.

(3) SYMBOLSTIX PRICE/TERMS OVERSTATED. neilsquire.ca states "approximately $250 CDN per year" (not USD) and describes terms as "each license includes one service provider access, with up 15 student licenses" — an organizational seat model, not the claimed "personal use only."

MINOR: The ~3,150 Mulberry count is unsourced. OpenSymbols lists 3,116 shared symbols; openaac.org says 3,000; mulberrysymbols.org states no count. Directionally close but fabricated precision. Latest Mulberry release is 3.5.2 (2025-09-17), actively maintained — supports the recommendation.

OVERSTATEMENT: "Fatal" for ARASAAC is slightly strong — ARASAAC terms note that uses beyond the license are possible "without the written authorization of the copyright owners," i.e. a documented (if impractical for an indie app) path to commercial authorization from the Government of Aragon exists.

NET: The operative recommendation (avoid ARASAAC, use Mulberry) survives, but the surrounding license map has one flatly wrong entry (Bliss), one unresolved ambiguity presented as settled (Mulberry version/ownership), and one currency/terms error (SymbolStix). Confidence "high" was not warranted. Note also for the product decision: CC BY-SA share-alike binds the symbols and derived symbols, not the Flutter app code (mere aggregation), so a paid app is compatible provided the symbol set itself is not sold and attribution ships.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "legal-regulatory". A product decision depends on it, so it must be right.

CLAIM: ARASAAC's NC clause is confirmed and does block a paid app; Mulberry Symbols is the clean answer and is explicitly designed for adults
THEIR DETAIL: ARASAAC: CC BY-NC-SA. ARASAAC's own terms state 'The use of these resources within any product or publication for commercial purposes is therefore excluded from this permission.' Attribution must name Sergio Palao / Government of Aragon / ARASAAC. The NC clause is fatal for a paid app (and arguably for a free app with IAP). Mulberry Symbols: ~3,150 SVG symbols, © Steve Lee, CC BY-SA 2.0 UK (England & Wales). Its own site markets it on exactly this product's thesis — 'Adult oriented symbols - most proprietary sets are designed for children' — and states you may use symbols in commercial projects with clear attribution, keeping derived symbols under the same license, and that you may 'charge for your product or added value, but you must not charge for the symbols themselves.' Other sets: Sclera CC BY-NC (blocked). Blissymbolics — CC BY-SA for free/copyleft/non-commercial use, but a 'royalty based' license from BCI is required for all commercial products (avoid). SymbolStix (n2y/Everway) and PCS/Boardmaker are proprietary commercial licenses requiring direct negotiation — SymbolStix Prime end-user subscriptions run ~$250/yr and permit personal use only, not redistribution in your app.
THEIR CLAIMED SOURCES: https://aulaabierta.arasaac.org/en/terms-of-use, https://mulberrysymbols.org/, https://github.com/mulberrysymbols/mulberry-symbols, https://www.openaac.org/symbols.html, https://www.blissymbolics.org/index.php/licensing, https://www.neilsquire.ca/symbolstix-prime-an-aac-app-by-everway/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
