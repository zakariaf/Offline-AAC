# tile-grid-design--atkinson-hyperlegible-next-feb-2025-went-fro

> Phase: **verify** · Agent `abc439379e68490c6` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Adopt Atkinson Hyperlegible Next — but not for the stated reason. Correct framing: Next expands from 2 weights (400/700) to 7 (200-800, ExtraLight-ExtraBold), each with italic, plus a variable wght axis and 150+ language support (up from 27), OFL-licensed and available in Flutter via google_fonts 8.1.0 as GoogleFonts.atkinsonHyperlegibleNext(). What this buys is FINER GRADATION and variable interpolation, not the newfound possibility of a two-level hierarchy. The original's 400/700 could already carry a label/ghost hierarchy in a single accessible family; only a prior commitment to 600 specifically made it seem impossible. Therefore: do NOT retire the prior brief's font recommendation on the assumption it was forced into a mixed family by weight scarcity — it was not. Find out the prior brief's actual reason for a mixed family (likely display/heading character: reviewers note Atkinson reads chunky and wide at large sizes and recommend pairing it for headings) before overwriting it, since that rationale is untouched by the Next release.

**Evidence:** EVERY VERIFIABLE FACT CONFIRMED against primary sources; the attached design inference is overstated.

CONFIRMED:
- Release: 10 Feb 2025, Braille Institute, Atkinson Hyperlegible Next + Mono, free via Google Fonts and brailleinstitute.org/freefont (PRNewswire 302371657; Braille Institute newsroom).
- SEVEN weights: Google Fonts ofl/atkinsonhyperlegiblenext/METADATA.pb shows axes { tag: "wght" min_value: 200.0 max_value: 800.0 } = 200/300/400/500/600/700/800 = ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold. The claim's enumeration is CORRECT — and notably more accurate than the foundry's own freefont page, whose prose says "Seven weights—Light to Extrabold" (which enumerates to only six). The 200-800 axis settles it in the claim's favor.
- "Up from two": ofl/atkinsonhyperlegible/METADATA.pb lists exactly four static fonts — 400 normal, 400 italic, 700 normal, 700 italic. Two weights. Confirmed.
- 27 -> 150+ languages: confirmed in press release.
- Variable version: confirmed, AtkinsonHyperlegibleNext[wght].ttf, single wght axis, plus upright+italic per weight.
- LICENSE: OFL (license: "OFL" in METADATA.pb; source repo googlefonts/atkinson-hyperlegible-next; OFL.txt returns HTTP 200). Not a restrictive EULA, though the freefont download path wraps it in an EULA click-through — prefer the Google Fonts/OFL path.
- FLUTTER REACHABILITY (not claimed, but load-bearing for this corpus): google_fonts 8.1.0 (pub.dev, 2026-04-27) exposes GoogleFonts.atkinsonHyperlegibleNext() and atkinsonHyperlegibleNextTextTheme(). No version/API rot — the family is genuinely usable from Flutter stable 3.44.0.

WHERE IT BREAKS — the inference, not the facts:
The load-bearing clause "the ORIGINAL's two weights could not carry a label(600)/ghost(400) hierarchy, forcing a mixed-family compromise" is FALSE as stated. The original shipped 400 AND 700. A 400 ghost / 700 label pairing is a perfectly serviceable — arguably higher-contrast — two-level hierarchy within a single family. The old release never forced a mixed-family compromise for a two-level hierarchy; it only did so if you had independently pre-committed to 600 as the label weight, which makes the argument circular. Likewise "this is what MAKES the hierarchy possible" overstates: Next supplies intermediate steps (200/300/500/600/800), a variable wght axis, and 150+ language coverage — a real and substantial upgrade, but the difference between "coarser" and "finer," not between "impossible" and "possible."

MINOR (immaterial to decision): Google Fonts date_added for Next is 2025-01-07 and for Mono 2024-11-20, both preceding the 10 Feb 2025 "launch" — the announcement date is a marketing milestone, not first-availability.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "tile-grid-design" made this claim, and a design decision depends on it.

CLAIM: Atkinson Hyperlegible Next (Feb 2025) went from 2 weights to 7 — this is what makes the label/ghost typographic hierarchy possible in a single accessible family
DETAIL: Braille Institute released Atkinson Hyperlegible Next and Atkinson Hyperlegible Mono on 10 February 2025, free via Google Fonts and brailleinstitute.org/freefont. Next ships SEVEN weights (ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold), each with upright and italic, plus a variable version, and expands language support from 27 to over 150 languages. This materially changes the typography recommendation: the ORIGINAL Atkinson Hyperlegible's two weights could not carry a label(600)/ghost(400) hierarchy, forcing a mixed-family compromise. Next can. The prior brief's font recommendation was written against the old release.
CLAIMED SOURCES: https://www.brailleinstitute.org/freefont/, https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html, https://pimpmytype.com/font/atkinson-hyperlegible-next/
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
