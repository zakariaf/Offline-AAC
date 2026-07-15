# aac-clinical--exact-license-status-of-the-remaining-symbol

> Phase: **verify** · Agent `ac57e43f5c5bba0ee` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Within OpenSymbols' catalog specifically, the license table is exactly correct and the "only a handful are commercially usable" finding holds: Mulberry (CC BY-SA), Twemoji (CC BY), Tawasol (CC BY-SA), and CoughDrop (CC BY) are the clean sets; ARASAAC/Sclera/LanguageCraft are NC; and the three "mixed licenses" sets (Noun Project, IcoMoon, IconArchive) do require per-symbol clearance and are genuinely unsafe to bulk-ship. But four corrections matter for the decision:

(1) The recommended stack is not the ONLY option. OpenMoji (CC BY-SA 4.0, ~3,540 symbols) is commercially usable, actively maintained, and absent from OpenSymbols entirely — it is a stronger Twemoji substitute given that twitter/twemoji is archived. Blissymbolics (CC BY-SA, 5,819) is another. Scope the conclusion to "within OpenSymbols" or survey Global Symbols' 40+ sets.

(2) PCS pricing is partly public: Maker Free / Maker Personal (USD $149) / Maker Business (custom). The applicable tier here is Maker Business, a negotiable commercial path — not "fees not public".

(3) ARASAAC (12,909-15,560 symbols, by far the largest well-designed AAC set) is commercially licensable with written authorization from Gobierno de Aragón. Treating it as categorically unusable while treating PCS as negotiable is inconsistent. For an adult-focused AAC app, an ARASAAC authorization request is worth making — it costs an email.

(4) Mulberry is CC BY-SA 2.0 UK: England & Wales (not 4.0) and is described as unmaintained by OpenAAC itself. Shipping it is legally fine but carries maintenance risk; the ShareAlike obligation attaches to modified symbols, not to your app code (mere aggregation), so bundling unmodified Mulberry/Tawasol/OpenMoji in a paid app is safe with attribution.

Revised practical conclusion: Mulberry + Tawasol + OpenMoji (preferred over Twemoji) is a clean, zero-fee, ship-today stack — but it is one of several, and ARASAAC is worth a licensing request rather than being written off.

**Evidence:** CONFIRMED (verbatim, primary source): Every symbol set, license, and count in the claim matches opensymbols.org exactly — Noun Project mixed 17,165; ARASAAC CC BY-NC-SA 12,909; Sclera CC BY-NC 11,443; Mulberry CC BY-SA 3,116; Twitter Emoji CC BY 2,770; Tawasol CC BY-SA 950; IcoMoon mixed 907; IconArchive mixed 600; LanguageCraft CC BY-NC-SA 205; CoughDrop CC BY 21. All ten rows correct. This is unusually accurate transcription.

CONFIRMED: tobiidynavox.com/pages/pcs-licensing states applications "are reviewed within 10-15 business days", that the tiers "all of which require a Boardmaker subscription first", and that there are three tiers. SymbolStix is owned by n2y LLC; n2y terms state symbols "may not be reproduced for sale", "sale is strictly prohibited", and users "may not rent, lease or sublicense" — so not shippable in a third-party app without a negotiated deal. Twemoji graphics are CC-BY 4.0 (LICENSE-GRAPHICS).

REFUTED — "published fee schedules are not public": Tobii Dynavox publicly lists Maker Personal at USD $149. Only Maker Business is custom-priced. A fee schedule IS partly public.

REFUTED — tier names: the actual tiers are Maker Free (nonprofits/individuals distributing free PCS materials), Maker Personal ($149, selling PCS-based content), and Maker Business (companies developing PCS software/commercial products) — not "no license / free license / paid license". The relevant tier for this product is Maker Business, which is a real negotiable path, not a dead end.

REFUTED — "Mulberry + Tawasol + Twemoji is the ONLY clean, zero-fee, commercially safe stack": the claim silently equates "OpenSymbols' catalog" with "all AAC symbol sets". Global Symbols lists 40+ sets, including OpenMoji — CC BY-SA 4.0, ~3,540 symbols, explicitly commercial-use-permitted, and notably NOT in OpenSymbols' listing. Blissymbolics (5,819) is also CC BY-SA. OpenAAC's own symbols page (openaac.org/symbols.html) lists OpenMoji as CC BY-SA alongside Mulberry.

OVERSTATED — ARASAAC "unusable if monetized": ARASAAC's published conditions of use permit commercial use with prior written authorization from Gobierno de Aragón (copyright holder; author Sergio Palao). It is a permission pathway, not a hard bar — structurally the same as PCS Maker Business, which the claim treats as negotiable while treating ARASAAC as closed.

IMPRECISE — Mulberry license: not generic "CC BY-SA" but specifically Attribution-ShareAlike 2.0 UK: England & Wales (a jurisdiction port, not 4.0 — matters for compatibility). Mulberry also adds a term beyond CC: "you may charge for your product or added value, you must not charge for the symbols themselves."

STALE DATA (decision-relevant): OpenSymbols' counts lag upstream — ARASAAC is 15,560 on Global Symbols vs 12,909 on OpenSymbols; Mulberry 3,150 vs 3,116; Tawasol is 714 on Global Symbols vs 950 on OpenSymbols (a discrepancy in the opposite direction, unexplained). Also, OpenAAC — the organization that runs OpenSymbols — describes Mulberry as "unmaintained". The researcher's recommended stack rests on an unmaintained set and a set whose upstream repo (twitter/twemoji) was archived after the X acquisition, now continued as the community fork jdecked/twemoji. Neither fact appears in the claim.

Two of the five claimed sources do not substantiate what they're cited for: prc-saltillo.com/support-materials and spectronics.com.au concern PRC/Minspeak and general symbol comparison, not the license status asserted.

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

CLAIM: Exact license status of the remaining symbol sets: only a handful are commercially usable
THEIR DETAIL: From OpenSymbols' own repository listing — Commercial use permitted: Mulberry CC BY-SA (3,116); Twitter Emoji CC BY (2,770); Tawasol CC BY-SA (950); CoughDrop Symbols CC BY (21); The Noun Project 'mixed licenses' (17,165); IcoMoon 'mixed' (907); IconArchive 'mixed' (600). NonCommercial only (unusable if monetized): ARASAAC CC BY-NC-SA (12,909); Sclera CC BY-NC (11,443); LanguageCraft CC BY-NC-SA (205). 'Mixed licenses' sets require per-symbol clearance and are unsafe to bulk-ship. Proprietary: PCS is owned by Tobii Dynavox — licensing requires a Boardmaker subscription first, there are three license tiers (no license / free license / paid license), and applications are reviewed in 10-15 business days; published fee schedules are not public. SymbolStix is owned by n2y, LLC; SymbolStix symbols may be distributed for personal use only with a SymbolStix Prime subscription — i.e. not shippable in a third-party app without a negotiated deal. Practical conclusion: Mulberry + Tawasol + Twemoji is the only clean, zero-fee, commercially safe, ship-today stack.
THEIR CLAIMED SOURCES: https://www.opensymbols.org/, https://www.tobiidynavox.com/pages/pcs-licensing, https://touchchatapp.com/symbol-libraries, https://www.prc-saltillo.com/support-materials, https://www.spectronics.com.au/article/symbol-set-comparison/print
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
