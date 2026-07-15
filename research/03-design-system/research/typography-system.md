# typography-system

> Phase: **research** · Agent `a0ee458ab563cf091` · Run `wf_f237e8a6-694`

## Result

## Summary

The decision is **Atkinson Hyperlegible Next**, single typeface, variable (wght 200–800), upright only, subset and bundled locally — sourced from the googlefonts OFL repo, never from the Braille Institute EULA download and never via `google_fonts` (which fetches over HTTP by default and is disqualified outright). But the reasoning is not "it's the accessible one." Its credentials are weak: I found **no independent peer-reviewed evidence** for Atkinson's legibility claims — it is designed-with-users and award-winning, not evidence-based, and it must never be marketed as "scientifically proven." It wins on three real grounds: letterform differentiation is its entire design thesis (Il1, O0, rn/m — the exact failure mode for someone reading fast in shutdown); its low, uniform stroke contrast is the one lever the evidence actually supports (Minakata & Beier 2022 — serif-vs-sans is folklore, stroke contrast is the variable); and its much-criticized *width* is an empirical **asset** for show mode, because show mode is a distance-reading task and Beier & Larson found wider letterforms recognized better at distance. The reviewers calling it "institutional" and "chunky at display" are making an aesthetic complaint about a legibility virtue. The founder's "beautiful, not 2014" is not won or lost at the typeface — at 20pt across 3 words you see letterform clarity and text-block shape, not personality. It is won at the **setting**: hand-built optical sizing (Atkinson has no opsz axis, so big type gets *lighter and tighter*, not bolder), a 4-role scale instead of M3's 15, a 1:3–1:6 tile→show scale jump that makes show mode a poster, and real apostrophes. The core typographic problem — a 2-word tile beside a 9-word tile in a fixed grid — is not a typographic problem at all. It's a **content-model** problem: split `label` (what you see, ≤4 words) from `says` (what it speaks/shows). Then one uniform tile size with variable line count reads as designed; variable size reads as broken. Do not use FittedBox on tiles; do use it in show mode. Also verified: M3 Expressive's emphasized type scale is **not in Flutter core** and not planned there — you're hand-rolling TextTheme regardless, which is a gift.

### Atkinson Hyperlegible Next shipped Nov 2024 (v2.001) / announced Feb 2025, is SIL OFL 1.1, and has ONLY wght (200–800) + ital axes — no opsz, no GRAD

*Confidence: high, **LOAD-BEARING***

Braille Institute announced Feb 10 2025; the googlefonts/atkinson-hyperlegible-next repo shows v2.001 'first release' dated Nov 20 2024 under OFL-1.1. Expanded from 2 to 7 weights (ExtraLight–ExtraBold) + matching obliques, 150+ languages (up from 27), ~370 glyphs/style. Fontsource confirms axes: wght 200–800, ital 0–1. Atkinson Hyperlegible Mono also shipped, 7 weights + variable. Next adds taller ascenders (now above cap height), tighter spacing, and a LIGHTENED Bold vs the original.

- https://github.com/googlefonts/atkinson-hyperlegible-next

- https://www.brailleinstitute.org/freefont/

- https://fontsource.org/fonts/atkinson-hyperlegible-next

- https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html

### LICENSING TRAP: brailleinstitute.org gates the OFL font behind email registration + EULA acceptance. Download from the googlefonts repo instead.

*Confidence: high, **LOAD-BEARING***

The font IS SIL OFL 1.1, but the Braille Institute's own download flow requires accepting a EULA and handing over an email — for a font that is open-source. The brailleinstitute.org/freefont page says only 'Free for personal use and all commercial applications' and never names OFL, which is how this gets mis-filed as a custom license. Take it from github.com/googlefonts/atkinson-hyperlegible-next (OFL.txt in repo root), ship OFL.txt, and register it via LicenseRegistry.addLicense().

- https://github.com/googlefonts/atkinson-hyperlegible-next

- https://www.brailleinstitute.org/freefont/

- https://en.wikipedia.org/wiki/Atkinson_Hyperlegible

### Atkinson Hyperlegible has NO independent peer-reviewed evidence for its legibility claims

*Confidence: high, **LOAD-BEARING***

Wikipedia cites design awards (Fast Company 2019 Innovation by Design; Dezeen 2020 shortlist) — not research data. Development was 'in collaboration with' low-vision specialists and a user panel; no formal study. Designer Elliott Scott explicitly said they chose 'to break a lot of rules that a lot of designers will care about.' This does not make it a bad choice — its differentiation strategies are principled (serif on uppercase I but not T; much longer F crossbar; angled spurs; circular forms nodding to braille dots) — but the app must NEVER claim it is scientifically proven. Its credential is craft, not evidence.

- https://en.wikipedia.org/wiki/Atkinson_Hyperlegible

- https://www.maxkohler.com/notes/2021-02-16-atkinson-hyperreadable/

### THE SERIF/SANS DEBATE IS FOLKLORE. The actual evidence-backed lever is LOW, UNIFORM STROKE CONTRAST.

*Confidence: high, **LOAD-BEARING***

Minakata & Beier 2022, 'The dispute about sans serif versus serif fonts: An interaction between the variables of serif and stroke contrast' (Acta Psychologica) built a custom font family varying ONLY serif and stroke contrast, holding all else identical. Normal vision: most legible = low stroke contrast + no serif. But it's an INTERACTION — sans reads at smaller sizes when contrast is LOW; serif reads at smaller sizes when contrast is HIGH. Their follow-up on low-vision (ADOA) readers found serifs + uniform stroke width beat other combinations. Conclusion: 'sans-serif is more legible' is unsupported as a blanket claim; pick low/uniform stroke contrast and the serif question is second-order. Atkinson has near-uniform stroke contrast — this, not its accessibility branding, is its real technical merit.

- https://www.sciencedirect.com/science/article/pii/S000169182200138X

- https://pubmed.ncbi.nlm.nih.gov/36563495/

- https://www.sciencedirect.com/science/article/pii/S0001691822003250

### Atkinson's WIDTH — the thing reviewers criticize — is an empirical asset for show mode, because show mode is a distance-reading task

*Confidence: medium, **LOAD-BEARING***

pimpmytype's review calls Next 'quite chunky and spacious' at display, 'less dynamic or less engaging,' and says it 'remains best suited for body text and UI components,' struggling as display type 'due to its width and legibility-first construction.' But Beier & Larson tested frequently-misrecognized letters at 50cm and 6m and found recognition of narrow letters (f, j, l, t) was GREATER for the WIDER versions. Show mode is a stranger cold-reading at ~50–70cm. The reviewer's complaint is aesthetic; the width is doing legibility work exactly where the stakes are highest. This inverts the main argument against Atkinson.

- https://pimpmytype.com/font/atkinson-hyperlegible-next/

- https://www.researchgate.net/publication/309747272_Designing_legible_fonts_for_distance_reading

- https://readabilitymatters.org/articles/dr-sofie-beier-bringing-together-science-and-typography

### google_fonts package fetches fonts over HTTP AT RUNTIME BY DEFAULT — disqualified for this app

*Confidence: high, **LOAD-BEARING***

pub.dev/packages/google_fonts: 'supports HTTP fetching, caching, and asset bundling'; 'HTTP fetching at runtime is ideal for development and can also be used in production to reduce app size.' It CAN be made offline (bundle matching files in pubspec assets — asset files are prioritized over HTTP — plus GoogleFonts.config.allowRuntimeFetching = false), but that ships an HTTP client and a network code path into an app whose entire premise is 'nothing leaves the device.' For a privacy-first AAC app the correct move is to not take the dependency at all: declare the font under pubspec `fonts:` and have zero network surface, greppably verifiable.

- https://pub.dev/packages/google_fonts

- https://docs.flutter.dev/cookbook/design/fonts

### Flutter 3.41 (stable, early 2026) — FontWeight now sets the wght axis of variable fonts automatically; FontVariation is only for other axes

*Confidence: high, **LOAD-BEARING***

Landed in 3.39.0-0.0.pre, stable in Flutter 3.41. Setting TextStyle.fontWeight now internally applies FontVariation('wght', value) — you no longer pair them. FontWeight accepts arbitrary integers 1–1000 (FontWeight(350) is valid), not just w100–w900 multiples. FontWeight.index is deprecated → use FontWeight.value. Other axes still need fontVariations: [FontVariation('GRAD', 150)]. Gotcha: apps that previously used variable fonts with FontWeight alone will RENDER DIFFERENTLY after upgrade. FontWeight.lerp can produce out-of-range weights.

- https://docs.flutter.dev/release/breaking-changes/font-weight-variation

- https://api.flutter.dev/flutter/dart-ui/FontVariation-class.html

- https://docs.flutter.dev/release/release-notes/release-notes-3.41.0

### M3 Expressive's 15 emphasized type styles are NOT in Flutter core and explicitly not planned there — you hand-roll TextTheme regardless

*Confidence: high, **LOAD-BEARING***

flutter/flutter#168813: 'we are not actively developing Material 3 Expressive, and we will not be accepting contributions for these features at this time.' As of July 2025 Material/Cupertino are being decoupled into standalone packages in flutter/packages; M3E work would happen there, someday. M3 Expressive was announced May 2025 and its emphasized styles (higher weight + minor adjustments, for 'bold, selection, and other areas of emphasis') exist in the spec only. Third-party packages (m3e_design, material_3_expressive) exist but are unofficial. For a 4-text-role app this is liberating, not limiting — don't wait for it, don't adopt an unofficial package for type.

- https://github.com/flutter/flutter/issues/168813

- https://m3.material.io/styles/typography/type-scale-tokens

### GRAD is NOT the fix for dark-mode bloom here — and reaching for it would cost you the typeface

*Confidence: high, **LOAD-BEARING***

Grade alters weight WITHOUT changing metrics, so switching grade causes zero reflow (unlike wght, which changes character widths). Genuinely attractive for a fixed-position no-reflow app. BUT: among realistic OFL candidates only Roboto Flex (GRAD -200..150) and Roboto Serif have a GRAD axis. Atkinson Next has none. Switching to Roboto Flex to gain GRAD means shipping Android's default typeface — maximum institutional invisibility, the exact failure mode the founder named. And it's unnecessary: prior research already established that TEXT LUMINANCE is the dominant halation lever, not weight. Hold wght identical across themes and solve bloom with ink color (~#E8E4DE rather than #FFF on dark). GRAD is a nice-to-have whose price is too high.

- https://m3.material.io/blog/roboto-flex

- https://fontsource.org/fonts/roboto-flex

- https://variablefonts.io/about-variable-fonts/

- https://adobe.design/ideas/keeping-type-consistent-in-changing-conditions

### CHI 2023 (n=459): light polarity is read reliably FASTER than dark; grade effects appeared in light mode; and grade is aesthetically 'free'

*Confidence: high, **LOAD-BEARING***

Gilbert et al., 'How bold can we be? The impact of adjusting font grade on readability in light and dark polarities', CHI 2023, two studies, 459 participants total, using Roboto Flex. Findings: (1) dark-on-light read reliably faster than light-on-dark for both glance and paragraph reading; (2) an effect of grade in Light Mode with heavier grades; (3) notably, paragraph readers do NOT prefer light mode despite its fluency benefit — preference and performance diverge. Authors' implication: 'designers can vary grade across the tested font formats to influence design aesthetics and user preferences without worrying about reducing reading fluency.' This independently corroborates inverting show mode to light polarity, AND validates keeping the user-facing default dark despite the speed cost — preference is legitimate.

- https://dl.acm.org/doi/10.1145/3544548.3581552

- https://readabilitymatters.org/articles/research-highlight-how-bold-can-we-be

### MIT AgeLab: for GLANCE reading of isolated words, UPPERCASE beat lowercase (lowercase needed 26% MORE time) — and I recommend overriding this

*Confidence: high, **LOAD-BEARING***

MIT AgeLab study reported by NN/g tested Frutiger at 3mm vs 4mm. All three variables mattered: larger (4mm) beat smaller; uppercase beat lowercase, with lowercase requiring 26% more time for accurate reading; regular width beat condensed by 11.2%. Crucially bounded: findings apply to ISOLATED WORDS or 1–2 word phrases only, and NN/g explicitly notes the research does not recommend all-caps for longer passages. Override anyway, for reasons the study can't see: (a) tile labels run to 4 words, past the evidence's scope; (b) ALL CAPS on an AAC utterance reads as SHOUTING — semantically catastrophic when the phrase is 'I need a minute'; (c) all-caps is the native visual language of institutional signage. Sentence case. Name the evidence, then beat it with a better reason.

- https://www.nngroup.com/articles/glanceable-fonts/

### Lexend's readability claims are weakly evidenced — reject it

*Confidence: medium*

The headline numbers (2,684 students; 90% better fluency than Times New Roman; 19.8% fluency improvement) trace to Shaver-Troup's own 2019 work, not independent peer review; the underlying dissertation (Azusa Pacific) tested 25 second-graders. A W3C task force literacy expert: 'research doesn't really have a lot of evidence showing that these special fonts help [people] read faster or make fewer mistakes.' The Dyslexie comparison is telling: when Arial's spacing was matched to Dyslexie's, reading efficiency was comparable — implicating LETTER SPACING, not letterform design. If Lexend's real mechanism is spacing, you can get it from letterSpacing on any face. Combined with Lexend's generic geometric look, there is no reason to ship it. (Consistent with prior research's OpenDyslexic finding.)

- https://github.com/googlefonts/lexend

- https://www.teleprompter.com/blog/effectiveness-of-lexend-and-opendyslexic-fonts

- https://eric.ed.gov/?id=ED588975

### Inter is disqualified as a single-face system: its opsz axis caps at 32

*Confidence: high*

Inter v4.1 (Nov 16 2024), OFL, wght 100–900, opsz 14–32, ital. Inter Display (introduced v4.0) is the >20px optical variant with tighter spacing and higher contrast. But opsz topping out at 32 means Inter has no designed instance for a 40–120pt poster — you'd be stretching a 32pt design to 120pt, which is precisely the optical failure Atkinson is accused of. Beyond that, Inter is the default UI face of the 2020s — its ubiquity IS institutionality. It is the grey rectangle of typefaces.

- https://rsms.me/inter/

- https://en.wikipedia.org/wiki/Inter_(typeface)

- https://fontsource.org/fonts/inter

### Verified OFL alternatives, with honest character/legibility tradeoffs

*Confidence: high*

Bricolage Grotesque (Mathieu Triay, OFL, wght 200–800 + wdth 75–100 + opsz 12–96) — the only genuinely expressive candidate whose opsz range natively spans tile→poster; the character pick, but its Il1/rn-m differentiation is unverified and betting shutdown legibility on it is irresponsible without testing. Recursive (Arrow Type, OFL, 5 axes incl. CASL 'casual' 0–1, a literal warmth dial, plus MONO/wght/slnt/CRSV) — characterful and adult; CASL/MONO are UNREGISTERED axes so tags must be uppercase in FontVariation. Geist (Vercel, OFL, wght 100–900) — neutral, reads as dev-tool. Mona Sans (GitHub, OFL, wght/wdth/slnt) — industrial grotesque, good character. Hanken Grotesk (Alfredo Marco Pradil, OFL, wght 100–900) — the best warm-humanist backup, less corporate than Inter, weaker letter differentiation. Roboto Flex (OFL, GRAD/opsz/wght/wdth/slnt) — only realistic GRAD source, maximally institutional. Public Sans/IBM Plex/Source Sans are institutional by construction (US govt / IBM).

- https://github.com/ateliertriay/bricolage

- https://www.recursive.design/

- https://github.com/vercel/geist-font/blob/main/LICENSE.txt

- https://github.com/github/mona-sans

- https://fonts.google.com/specimen/Hanken+Grotesk

### SOURCE HYGIENE: 2026 'best free font' listicles are contaminated with fabricated claims — don't source the typeface decision from them

*Confidence: medium*

A search for 2025–26 OFL releases surfaced content-farm pages claiming 'Klim released Founders Grotesk [as OFL]' and 'Commercial Type released Graphik Compact as an OFL release.' Both are almost certainly false — Founders Grotesk and Graphik are flagship COMMERCIAL retail fonts from those foundries and releasing them under OFL would be industry-shaking news. Same pages assert a 'Hanken Variable' Jan 2026 opsz+italic update and a 'Vela Serif' that I could not corroborate. Every typeface in this report was verified against its own repo, foundry page, or Fontsource. Treat madegooddesigns/freefontzone/cssauthor-class listicles as unciteable.

- https://freefontzone.com/news/best-free-font-releases-early-2026

- https://madegooddesigns.com/font-trends-2026/

### Text fonts are NOT tree-shaken by Flutter — only icon fonts are. Subsetting is manual and mandatory here.

*Confidence: high*

Flutter's --tree-shake-icons removes unused ICON font glyphs (~99.5% reduction observed on MaterialIcons) but does nothing for text fonts; bundled text fonts ship whole. Atkinson Next carries 150+ languages / ~370 glyphs per style — a variable TTF lands roughly 200–400KB, mostly unused. Subset with fonttools pyftsubset to Latin + punctuation while PRESERVING the wght variation axis (do not let the subsetter instance/drop variations). Realistic outcome ~80–120KB. Also: Flutter docs warn that if a font file lacks a real weight, declaring weight makes Flutter SIMULATE it, which 'will look quite different' — a variable file avoids this entirely.

- https://docs.flutter.dev/cookbook/design/fonts

- https://docs.flutter.dev/tools/pubspec

- https://www.technaureus.com/blog-detail/flutter-tree-shaking-and-bundle-optimization-guide

## Design moves

- **SHIP: Atkinson Hyperlegible Next, variable, UPRIGHT ONLY (drop italic), wght axis 200–800, subset to Latin+punctuation via pyftsubset preserving the wght axis. One file, ~80–120KB, at assets/fonts/AtkinsonHyperlegibleNext-VF.ttf, declared under pubspec `fonts:`. No google_fonts dependency. Source from github.com/googlefonts/atkinson-hyperlegible-next; ship OFL.txt via LicenseRegistry.addLicense().**
  - Why: OFL-clean, letter-differentiation is its design thesis (the shutdown failure mode), near-uniform stroke contrast is the one lever the evidence actually supports (Minakata & Beier 2022), and its width is an asset for show mode's distance read (Beier & Larson). Italic has no role in this app and doubles the payload. Zero network code is greppable — that matters to an audience choosing this app for privacy.
  - Risk: Its legibility credential is NOT peer-reviewed — never claim 'scientifically proven' in store copy or settings. It genuinely does look institutional AT DEFAULT SETTINGS; every move below is what stops that. If founder rejects it on character after seeing it set properly, the backup is Hanken Grotesk (warmer, weaker Il1) or Bricolage Grotesque (opsz 12–96 natively solves show mode, but unverified letter differentiation — must be user-tested before it touches an AAC tile).
- **SPLIT THE CONTENT MODEL: every phrase is TWO fields — `label` (what the tile shows, hard cap ~24 chars / 4 words) and `says` (what TTS speaks and show mode displays, uncapped; defaults to label). Tile: 'Can't talk'. Says: 'I can't talk right now but I'm okay.' Edit mode exposes both, labelled 'What you see' and 'What it says'.**
  - Why: THIS IS THE ANSWER TO THE CORE TYPOGRAPHIC PROBLEM. A 2-word tile beside a 9-word tile in a fixed grid is not a typography problem — it is a content problem, and no amount of type craft fixes it downstream. Capping the label makes the grid tractable AND speeds glance reading (MIT AgeLab: glance advantage lives at 1–2 words). It is also the honest AAC model: the tile is a HANDLE for an utterance, not the utterance.
  - Risk: Two fields in edit mode is more cognitive load for a user who may be editing while dysregulated. Mitigate: `says` is collapsed by default and auto-mirrors `label` until explicitly opened — most users never see it. Never let `says` be empty. And never let the cap silently truncate: the editor must refuse/warn, because a truncated AAC utterance is a DIFFERENT utterance.
- **TILE LABELS: ONE uniform size for all 12 — 20pt / w600 / letterSpacing +0.5% / height 1.15 / max 2 lines / centered / sentence case. Variable LINE COUNT across the grid is fine. Variable SIZE is not. Never FittedBox, never auto-shrink, never ellipsize.**
  - Why: Uniform size + variable line count reads as designed; variable size reads as broken. Auto-shrink is the obvious move and it's actively backwards — it makes the LONGEST (most complex) phrase the SMALLEST, destroys the grid's typographic rhythm, and breaks TextScaler honoring. Centered (not left) because a 1–2 line label in a wide box centered reads as a SIGN; left-ragged reads as a list item — and centering keeps optical center of gravity constant across mixed 1- and 2-line tiles, reinforcing 'position IS the phrase'.
  - Risk: Ellipsis on an AAC utterance is catastrophic, so the ~24-char label cap is what makes 'never truncate' safe — the two moves are load-bearing for each other. If the cap is ever relaxed, this whole system fails.
- **HAND-SET LINE BREAKS in the shipped 12 defaults: support a literal \n in the label string and author the breaks by hand ('I need\na minute', not 'I need a / minute'). Expose a 'break line here' affordance in edit mode.**
  - Why: Centered 2-line text strands words ('I can't talk right / now') and Flutter has no native text-balance. Since labels are ≤4 words and authored, hand-setting breaks gives total control at zero algorithmic cost — no binary-search width solver, no layout pass. This is the cheapest craft-per-byte move in the entire system.
  - Risk: A hand-set break can collide with TextScaler at 200% and force an unintended 3rd line. Treat \n as a HINT: if the scaled text exceeds 2 lines, fall back to natural wrap rather than honoring the break.
- **HAND-BUILT OPTICAL SIZING (Atkinson has no opsz axis, so simulate it): BIG TYPE GETS LIGHTER AND TIGHTER. Tile 20pt → w600, +0.5% tracking. Show 40–120pt → w500, −2% tracking. UI meta 15pt → w500, 0%. Never use w700 in show mode.**
  - Why: This single discipline is the whole difference between 'default' and 'designed', and it directly answers the 'chunky and spacious at display' critique — that complaint IS the missing opsz, and negative tracking is a one-line fix. Bold at 100pt closes counters, and counter size is an evidence-backed legibility factor (Beier) — so w500 at poster scale is both prettier AND more legible than bold. Reviewers' aesthetic objection to Atkinson dissolves under correct optical setting.
  - Risk: None to legibility if tracking stays ≥ −2%; past that Atkinson's generous sidebearings stop protecting letter separation, which is the one thing you're paying this typeface for. Do not chase tightness for style.
- **FOUR TEXT ROLES, NOT FIFTEEN: utterance.tile (20/w600/+0.5%/1.15/centered), utterance.show (fitted 40–120/w500/−2%/1.05/left), field.input (22/w500/1.3), meta (15/w500). Hand-roll TextTheme. Delete the other 11 M3 slots.**
  - Why: The app has four text roles. M3's 15-style scale on a 4-element app is cargo cult. And it's moot: M3 Expressive's emphasized scale is not in Flutter core and explicitly not planned there (flutter#168813), so you're hand-rolling regardless — that's a gift, not a burden. The DRAMA is the ratio: tile→show is 1:3 to 1:6. That enormous scale jump IS the beauty. Posters are beautiful because of scale contrast, not decoration — and this app can't use motion, so scale contrast is the loudest instrument available.
  - Risk: Resist adding roles later; each new role erodes the scale jump that carries the whole aesthetic. If a 5th role feels necessary, it's usually meta at a different color, not a different size.
- **SHOW MODE IS A POSTER, AND IT INVERTS EVERYTHING: light polarity (near-black ink on near-white, screen at max brightness) regardless of app theme; FittedBox fitted 40–120pt; w500; −2% tracking; LEFT-aligned ragged-right; 2–4 words per line; offer landscape (≈2x type size).**
  - Why: Two independent confirmations that light polarity is right here: prior research, plus CHI 2023 (n=459) finding dark-on-light read reliably faster for both glance AND paragraph tasks. The user's calm dark theme is optimized for the user's eyes and is WRONG for a stranger's cold read. LEFT-aligned is the deliberate reversal from the centered tiles: at poster scale, centered multi-line text gives a wobbling left edge that forces a cold reader to re-find each line start — a stranger reading 3 lines needs a hard left axis. Tiles are centered because they're 1–2 line signs; the poster is left because it's a cold read. FittedBox is correct here and wrong on tiles because show mode has ONE string and no grid rhythm to preserve.
  - Risk: The polarity flip is a sudden full-screen luminance change fired at a user who may be in sensory overload — the very thing the zero-animation rule protects against. This is a real conflict and the flip is aimed at the stranger, not the user. Mitigate: the user is the one who taps to enter show mode (it's intentional, not ambient), and the phone is being turned AWAY from them at that moment. Do NOT ramp or cross-fade the brightness (that's animation); step it. Consider a settings escape hatch for users who find the flash intolerable, accepting the stranger-legibility cost.
- **DARK MODE: hold wght IDENTICAL across all three themes. Solve halation with ink luminance (~#E8E4DE, not #FFFFFF) — not with weight, not with GRAD.**
  - Why: Prior research already established text luminance as the dominant halation lever. Atkinson has no GRAD axis, and reaching for GRAD means switching to Roboto Flex — shipping Android's default typeface, i.e. maximum institutional invisibility, the exact failure the founder named. Worse, using the wght axis instead would change character widths and could re-wrap a tile label between themes, violating 'no reflow ever'. Holding weight constant and moving color is free, reflow-proof, and already the established answer.
  - Risk: None structurally — this is the constraint-satisfying answer. Note the CHI 2023 wrinkle for the theme default: readers do NOT prefer light mode despite its measured fluency benefit. Preference and performance diverge, so keep the user-facing default dark; don't 'correct' users toward light on speed grounds.
- **TEXTSCALER: honor to 200%+ with NO clamp, NO shrink. Instead, at TextScaler ≳1.6, PROMPT (never auto-switch): 'Text is large. Switch to 6 tiles?' → user opts into the 2x3 layout.**
  - Why: At 200% a 20pt label becomes 40pt and cannot fit 2 lines in a 76dp tile. The only honest resolution is that the GRID responds to text scale, not the text to the grid — clamping or shrinking silently defeats the user's own accessibility setting, which is the deepest insult this app could offer. The 2x3 'large' option already exists in the established design.
  - Risk: Auto-switching would reflow tile positions — and position IS the retrieval mechanism, sacred and never automatic. Hence prompt, not auto. This is a cross-dimension dependency: whoever owns layout must know that TextScaler ≥1.6 is a 2x3 trigger, and must persist the choice.
- **SMART PUNCTUATION IN THE SHIPPED STRINGS: real apostrophes (’ not '), sentence case, NO terminal periods on tile labels, intentional ellipsis (…) and em-dash. Normalize user-typed straight quotes to curly on save.**
  - Why: The highest-leverage 'beauty' move in the entire system, and it costs zero bytes and zero risk. 'I can’t talk right now' at 20pt/w600 reads as MADE BY A PERSON; 'I can't talk right now.' reads as a database dump. A period on a button is institutional. Most apps get this wrong, which is exactly why getting it right registers as craft. This is the register the founder is asking for — and it is available without touching the typeface.
  - Risk: Curly-quote normalization must never mangle the `says` string passed to TTS — verify the engine pronounces ’ identically to ' (it should, but test). Never apply smart-punctuation transforms to user text while they're mid-typing in the type-to-speak field; that's a surprise edit under distress. Normalize on save only.
- **SENTENCE CASE, NOT ALL CAPS — override the MIT AgeLab glance finding deliberately.**
  - Why: AgeLab found uppercase FASTER for glance reading (lowercase needed 26% more time), which is genuinely tempting for tiles. Override for three reasons the study can't see: (a) it's bounded to isolated words / 1–2 word phrases and our labels run to 4; (b) ALL CAPS ON AN AAC UTTERANCE READS AS SHOUTING — semantically catastrophic when the phrase is 'I need a minute' and the user is trying to signal distress calmly; (c) all-caps is the native visual language of institutional signage, which is the founder's stated enemy. Recover the speed elsewhere: AgeLab equally found SIZE and REGULAR WIDTH help, and Atkinson at 20pt/w600 regular-width banks both.
  - Risk: None. But log the reasoning — 'why isn't this all caps, the research says' is a question that will come back, and the answer is that semantics outrank a bounded glance-speed finding.
- **OPTICAL CENTERING: nudge tile labels UP by ~1.5–2% of font size (≈0.3–0.4px at 20pt). Use TextLeadingDistribution.even, then a Transform.translate(Offset(0, -0.02 * fontSize)).**
  - Why: Flutter centers on the line box (full em box, including ascender/descender space), not on visual mass. Because Atkinson Next's ascenders now extend ABOVE cap height, the em box is top-heavy with empty space and mathematically-centered text sits optically LOW in the tile. This is small, real, and precisely the kind of detail that separates 'a person made this' from 'a framework laid this out.'
  - Risk: The nudge must scale with font size and TextScaler, not be a hardcoded px — a fixed −0.4px offset becomes invisible at 200% scale and the labels drift low again. Verify with a 1-line and a 2-line tile side by side.
- **SINGLE TYPEFACE — do NOT pair a display face with a UI workhorse.**
  - Why: The decisive argument is not economy, it's identity: the tile label and the show-mode text are THE SAME STRING. The user taps 'Can't talk' and it becomes a poster. If those are set in different typefaces, the utterance changes identity as it amplifies — the phrase stops being one object. It must be the same voice, just louder. Secondary: pairing across a 4-element app means 50% of your elements are a different face, which reads as inconsistent rather than designed, and doubles the font payload for an offline-first APK.
  - Risk: This is what forces the hand-built optical sizing (a paired display face would have solved show mode for free). Accepted: the tracking/weight compensation is ~6 lines of TextStyle, and identity-continuity of the utterance is worth more than the convenience.

## References

- **Atkinson Hyperlegible Next — googlefonts repo (NOT brailleinstitute.org)** https://github.com/googlefonts/atkinson-hyperlegible-next
  - Steal: The font itself, OFL-clean and EULA-free. Also steal its differentiation strategy as a design principle for the whole app: serif on uppercase I but NOT on T; a much longer F crossbar; angled spurs; circular forms nodding to braille dots. The lesson is that legibility comes from making characters DIFFERENT FROM EACH OTHER, not from making each one 'clear' in isolation.
- **Minakata & Beier 2022, 'The dispute about sans serif versus serif fonts' (Acta Psychologica)** https://www.sciencedirect.com/science/article/pii/S000169182200138X
  - Steal: The single most useful legibility result for this project: build a font family varying ONLY serif and stroke contrast. Steal the conclusion — low/uniform stroke contrast is the real lever; serif-vs-sans is a second-order interaction. Use this to defend the typeface choice on evidence rather than on accessibility branding.
- **Gilbert et al., 'How bold can we be?' CHI 2023 (n=459, Roboto Flex)** https://dl.acm.org/doi/10.1145/3544548.3581552
  - Steal: Two things: (1) light polarity is read reliably faster — the empirical basis for inverting show mode; (2) readers don't PREFER light despite the fluency benefit. Steal that preference/performance split as a general principle for this app: measured speed does not license overriding a distressed user's chosen theme.
- **NN/g, 'Typography for Glanceable Reading: Bigger Is Better' (MIT AgeLab)** https://www.nngroup.com/articles/glanceable-fonts/
  - Steal: The glance-reading frame itself — tile labels are glance reading, not text reading, and the literature for the two diverges. Steal the size and regular-width findings; consciously reject the uppercase finding on semantic grounds.
- **Sofie Beier / Centre for Visibility Design (Ovink, Pyke, Spencer)** https://readabilitymatters.org/articles/dr-sofie-beier-bringing-together-science-and-typography
  - Steal: The distance-reading result — wider forms of narrow letters (f, j, l, t) recognized better at 6m. This is what flips Atkinson's 'too wide' critique into a show-mode asset. Ovink was purpose-built for distance viewing; study its letterform decisions if show mode ever needs its own face.
- **pimpmytype review of Atkinson Hyperlegible Next** https://pimpmytype.com/font/atkinson-hyperlegible-next/
  - Steal: The honest adversarial read — 'chunky and spacious', 'less dynamic or less engaging', 'struggles as display typography due to its width'. Steal it as the spec for what the hand-built optical sizing must fix. If founder looks at v1 and says 'this feels institutional', this review already told you why and the fix is tracking and weight, not a new typeface.
- **Bricolage Grotesque (Atelier Triay, Mathieu Triay)** https://github.com/ateliertriay/bricolage
  - Steal: The fallback if founder rejects Atkinson on character. opsz 12–96 natively spans tile→poster, which is exactly the axis Atkinson lacks; wdth 75–100 could absorb long labels. It is the only verified OFL face that is both genuinely expressive AND optically engineered across this size range. Must be user-tested on Il1/rn-m before it touches an AAC tile.
- **Recursive (Arrow Type, Stephen Nixon)** https://www.recursive.design/
  - Steal: The CASL axis — a literal 0→1 warmth dial from 'sturdy rational Linear' to 'friendly energetic Casual', adjusting stroke curvature, contrast and terminals. Even if you don't ship Recursive, steal the CONCEPT: 'warm but adult' is a dial, not a binary, and this is the founder's brief expressed as a font axis. Note CASL/MONO are unregistered axes — uppercase tags required in FontVariation.
- **Flutter breaking change: FontWeight controls variable font wght (3.39 pre → 3.41 stable)** https://docs.flutter.dev/release/breaking-changes/font-weight-variation
  - Steal: The exact API contract: fontWeight now sets wght automatically; use fontVariations only for other axes; FontWeight(350) is legal; FontWeight.index is deprecated → .value. Read before writing a single TextStyle — apps that previously paired FontWeight with FontVariation('wght') render differently after upgrade.
- **flutter/flutter#168813 — Bring Material 3 Expressive to Flutter** https://github.com/flutter/flutter/issues/168813
  - Steal: The status quote — 'we are not actively developing Material 3 Expressive, and we will not be accepting contributions for these features at this time.' Steal it as permission to stop waiting for the emphasized type scale and hand-roll a 4-role TextTheme today.
- **google_fonts package README (as a cautionary spec)** https://pub.dev/packages/google_fonts
  - Steal: Read it precisely to understand what NOT to depend on: runtime HTTP fetching is the DEFAULT, and offline requires both bundling assets AND setting GoogleFonts.config.allowRuntimeFetching = false. Steal the pubspec `fonts:` pattern from the Flutter cookbook instead and take zero dependency.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PRODUCT ===

An offline AAC (augmentative & alternative communication) app for autistic adults and teens with situational/part-time speech loss — people who can usually speak but go non-speaking during shutdowns, meltdowns, or sensory overload. Flutter, Android-first. Solo developer.

The app is ONE screen: a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface. Tap a tile, the phone speaks it aloud (or shows it in huge text — a co-equal "show mode" where you turn the screen to a stranger). Plus an edit mode and settings. No accounts. No network. Nothing leaves the device.

=== THE DESIGN BRIEF FROM THE FOUNDER (verbatim, and it is the point of this research) ===

"I don't want something like the design of ten years ago. I don't want something formal. I want something creative. I want something beautiful."

Take this seriously and literally. The default failure mode of an "accessible, calm, adult" app is that it becomes a grey rectangle grid that looks like a 2014 enterprise settings screen. That is the thing to avoid. The founder is asking for craft, personality, and beauty — and the research must find how to deliver that WITHOUT breaking the constraints below, not treat the constraints as an excuse to be boring.

=== WHAT PRIOR RESEARCH ESTABLISHED (do not re-litigate; design WITHIN these, or argue explicitly and with evidence where a constraint is softer than it looks) ===

- **The wedge is dignity.** Every mainstream AAC app is designed for children — cartoon avatars, mascots, puzzle pieces, primary-color rainbows, star/reward motifs, "Great job!" copy, parental gates. Adults abandon them. BANNED, permanently: cartoon avatars, mascots, animal characters, puzzle-piece iconography, gamification, streaks, badges, confetti, encouragement copy, any "parent/caregiver" framing.
- **CRITICAL NUANCE, and the opening for this whole research:** the study behind this found infantilization was about **VOCABULARY and being treated as a student — NOT about color**. The prior brief's own conclusion: *"DO NOT confuse 'adult' with 'monochrome and cold.' You can be warm and adult. The enemy is cartoon avatars and parental gates — not saturation."* So "adult" does NOT mandate grey. This is the permission slip. Use it.
- **Zero animation.** Two independent reasons: (a) distress/trauma-informed guidance warns against sudden motion for sensitized nervous systems; (b) animation costs latency in a product whose premise is instant speech. Honor `MediaQuery.disableAnimationsOf` → zero duration. **So beauty here CANNOT come from motion. It must come from composition, type, color, material, and craft. Print has been beautiful for 500 years without moving.**
- **Sensory sensitivity is the audience's defining trait.** Muted, low-saturation, ~2-5 intentional hues; high saturation only as sparing accents. But saturation and contrast are SEPARABLE — muted hues at high luminance contrast is the target.
- **Dark, light, AND high-contrast themes, all switchable in ONE TAP from the main screen.** Dark mode is contested in the research: [While & Sarvghad 2024](https://arxiv.org/pdf/2409.10841) found each polarity benefits comparable proportions and recommends shipping both; observers with cloudy ocular media read 10-15% better in dark. So dark is a choice, not the answer. **The dominant halation lever is TEXT luminance, not background hex** (#FFFFFF→#E0E0E0 drops contrast 21:1→15.91:1, a 24% cut; #000→#121212 only moves 21:1→18.73:1).
- **Material 3 is Flutter's default since 3.16.** M3's baseline dark surface is #141218 (neutral tone 6) with tone-based surface containers, NOT M2's #121212 + elevation overlays. Use `ColorScheme.fromSeed`.
- **Huge targets** (76dp floor, 12dp min gaps), 3x4 grid default with a 2x3 "large" option, **fixed tile positions** (no reflow ever — position IS the retrieval mechanism), highest-value tiles in the **lower-CENTER arc** (not upper-left; not the extreme bottom edge).
- **Typography**: system font or Atkinson Hyperlegible (Braille Institute, OFL). Tile labels min 17pt, default ~20pt, weight 500-600. MUST honor TextScaler to 200%+ without clamping. No dyslexia font as default (OpenDyslexic *decreased* fluency in the studies) but offer it as an option.
- **Show mode is the exception to the calm rule** — a cashier reads it at arm's length in daylight. Dark/low-luminance is right for the user's eyes and WRONG for a stranger reading the screen. Opposite optimizations.
- **Fitzgerald Key part-of-speech coloring is out** (each tile is a whole utterance, so grammar coloring is meaningless). But **category color-coding is fine and useful** for findability — the research explicitly did NOT find color-coding infantilizing.
- Symbols are v1+, text-only for MVP, and text-only stays first-class (for many literate adults the symbol set IS the infantilizing element). If symbols ship: Mulberry, runtime-tinted.
- The user may be in a shutdown: reduced decision-making, possible motor imprecision. One-handed. Phone, not tablet.
- Voice/identity matters: this audience skews trans/nonbinary; 4/12 wanted nonbinary/middle-pitch voices.

Today is 2026-07-15. Prefer 2025-2026 sources. Design moves fast — a 2019 article on "modern mobile design" is describing history.


YOUR DIMENSION: The typographic system — the primary expressive instrument in a motion-less, image-less app.

Research with WebSearch/WebFetch: type foundries and their 2025-2026 releases, variable fonts, OFL/open-licensed typefaces good enough to ship commercially, Atkinson Hyperlegible (including **Atkinson Hyperlegible Next / Mono — the 2025 releases; VERIFY what shipped and when**), Inter (and Inter Variable / Inter Display), and the legibility research literature.

- **The typeface decision.** Requirements: OFL or otherwise commercially shippable; excellent at large sizes AND at 200%+ scaling; distinguishable letterforms (Il1 / O0 / rn-m confusion matters for a user in a shutdown reading a phrase fast); adult and characterful, NOT institutional; supports the weights we need; ideally variable. Evaluate REAL candidates with real names and licenses: Atkinson Hyperlegible (+ Next?), Inter, Lexend (and the Lexend readability research — VERIFY it, I believe the claims are contested), Public Sans, Source Sans, IBM Plex, Work Sans, Manrope, Geist (Vercel's — license?), Instrument Sans, Bricolage Grotesque, Redaction, Newsreader, Literata, Fraunces, Recursive, Commissioner, and any strong 2025-2026 OFL release. For each: license, variable axes, character, and fitness here.
- **Is Atkinson Hyperlegible actually the right call, or is it the "accessible" choice that looks institutional?** Be honest and specific about how it LOOKS, not just its credentials. Is there a typeface that is both genuinely legible AND has character? Does pairing solve it (a characterful display face for the tile labels + a workhorse for UI)? Or is pairing a mistake at this scale?
- **The legibility evidence, rigorously.** What does research ACTUALLY support: x-height, counter size, letter differentiation, weight, tracking, line length, ALL CAPS vs sentence case? What's folklore? (Lexend's claims, OpenDyslexic's failure, the "sans-serif is more legible" claim — check them all.)
- **The type SCALE.** For an app whose entire content is 12 phrase labels + one text field: what's the scale? How much contrast between levels? Is a conventional 6-level type scale even needed for a 4-element app? What's the M3 Expressive "emphasized" scale and is it usable in Flutter?
- **Variable font axes worth using**: weight, optical size, grade (grade is interesting for dark mode — it adjusts weight WITHOUT changing metrics, so text doesn't reflow; is that the fix for dark-mode bloom?), width. What does Flutter support for variable fonts in 2026 (`FontVariation`)? VERIFY the API.
- **Setting the tile label**: one word? a phrase? how does it wrap? centered or left? optical centering? how do you handle a 2-word tile next to a 9-word tile in a fixed grid without it looking broken? THIS IS THE CORE TYPOGRAPHIC PROBLEM OF THE APP — go deep on it.
- **The show-text screen**: a phrase at maximum size, read at arm's length in daylight by a stranger. What's the typographic treatment? This is a poster, not UI. How big, what weight, what measure, what alignment?
- Font loading/bundling in Flutter: size cost, subsetting, `google_fonts` package (does it fetch at runtime? THAT WOULD BE A NETWORK CALL AND IS BANNED — verify how to bundle instead), tree-shaking.

Give a decision with a named typeface, real sizes, real weights, and the reasoning. This is the deliverable.
````

</details>
