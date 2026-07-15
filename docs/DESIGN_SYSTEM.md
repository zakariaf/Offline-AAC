# Reed — Design System

Every hex, ratio, and Lc below was computed, not estimated — the scripts validate against published reference pairs first (`#000/#FFF` = 21.00, `#E0E0E0/#000` = 15.91, APCA `#888`-on-`#FFF` = 63.1) and only then report. Every API was compiled against the installed toolchain (**Flutter 3.41.2 / Dart 3.11**; all APIs used landed ≤3.32 and are present in 3.44). Where a value came from judgment rather than measurement, it says so.

---

## 0. The direction

**Reed is a swatch book.** Twelve chips of dyed paper stock, each printed with one line of type, bound in fixed order behind a fine keyline. Not a keyboard, not a dashboard, not a board of buttons — a specifier. The product is a grid of flat coloured rectangles, and a grid of flat coloured rectangles is only a kindergarten board if you refuse to claim a different lineage for it. Ours is the Pantone specifier, Richter's colour charts, and Field Notes: pick the stock, pick the ink, print the type, add nothing. The dignity wedge is not won by subtracting childishness one apology at a time; it is won by asserting a register. An adult buys Field Notes *because it is beautiful*, and it has never once told anyone they are doing a good job.

Everything is opaque, flat, and still. Depth comes from tone and edge — never shadow, blur, or motion. The grid is quiet on purpose, and it spends its entire expressive budget in one place: **the show screen, which is a poster.** That is the one screen where calm is not the constraint, because the reader is a stranger at arm's length in daylight, and it is the two seconds in which they decide whether they are talking to a competent adult with a temporary problem or to a patient.

Siblings: **Field Notes** (one stock, one ink, no ornament), **Vignelli's 1972 subway signage** (a rigid grid made beautiful by exactness), **Teenage Engineering** (a fixed palette where every colour means one thing, and lowercase everything).

---

## 1. Colour

### 1.1 Neutral temperature: warm, and it is nearly free

Every neutral carries hue. **Pure `#FFFFFF` / `#808080` / `#000000` are banned outside high contrast** — zero-chroma neutrals are the cheapest tell that nobody chose anything. The ramp runs OKLCH hue **65–85**, chroma **0.006 → 0.012**, chroma rising with lightness (shadows desaturate; flat chroma across the ramp is what makes warm darks read as brown). M3's own dark surface `#141218` is not neutral either — it is OKLCH C 0.0124 at hue **300**, i.e. purple. Google already tints its blacks; the only question is which hue, and warm reads as lamplight and paper where cool reads as screen. For an app opened during a shutdown, that connotation is the product.

The corpus argued "warm the ink, not the paper." **Rejected**: it is invented, and it contradicts M3's shipping pattern of deriving ink and paper from one neutral hue at different tones. We warm both, from one hue. `#141210` vs `#141218` is a non-decision either way — 0.03% of the luminance range.

The ink cap is the load-bearing part and it generalises past hex: **cap on-surface text at OKLCH L ≈ 0.885.** `#DCD9D3` is L 0.885 / C 0.009 / H 80. Cost: `#FFFFFF` on `#171411` = 18.35:1 / Lc −107.1 versus `#DCD9D3` = 13.03:1 / Lc −82.9 — 24 Lc (23% of perceptual contrast) spent to eliminate halation bloom. Affordable because −82.9 still clears APCA's Lc 75 body floor and WCAG AAA with room.

### 1.2 `ink` (dark) and `paper` (light)

| role | `ink` | on ground | | `paper` | on ground |
|---|---|---|---|---|---|
| `ground` | `#171411` | — | | `#F4F2EE` | — |
| `container` (type field) | `#25211D` | 1.15:1 | | `#E5E3DD` | 1.15:1 |
| `ink` | `#DCD9D3` | **13.03:1 / Lc −82.9** | | `#27221D` | **14.09:1 / Lc +95.1** |
| `inkDim` (chrome only) | `#AEAAA4` | 7.94:1 / −55.7 | | `#5A544E` | 6.68:1 / +78.3 |
| `keyline` | `#8A857F` | 5.02:1 | | `#6F6A64` | 4.79:1 |
| `focus` | `#FFD9A0` | 13.70:1 | | `#7A4A05` | 6.69:1 |

`inkDim` is **never** a tile label: Lc −55.7 is correctly rated secondary by APCA even though WCAG says 7.94:1.

Two moves keep light from going clinical, and the second is the one people skip: the ground is `#F4F2EE`, not `#FFFFFF` (uncoated paper), **and the ink is `#27221D`, not `#000000`**. Pure black on near-white is the clinical signal; warm-black on warm paper is letterpress. It costs nothing legible — +95.1 exceeds APCA's Lc 90 "preferred for fluent text" bar.

### 1.3 High contrast — and it keeps its warmth for 1.8%

| palette | ink | ground | WCAG | APCA | focus |
|---|---|---|---|---|---|
| `hcInk` | `#FFFCF7` | `#0B0906` | **19.43:1** | −106.0 | `#FFD9A0` (14.85:1) |
| `hcPaper` | `#0B0906` | `#FFFCF7` | **19.43:1** | +104.2 | `#5C3300` (10.64:1) |

Pure `#FFF`/`#000` scores 21.00:1 / Lc ±107.9. Warm scores 19.43:1 / ±106.0 — **a delta of 1.9 Lc out of 108, or 1.8%.** So "is high contrast just black and white?" has a quantified answer: no, it can be recognisably the same app for a rounding error. But HC is a medical accommodation. If a user says warm HC is insufficient, ship a pure `#FFF`/`#000` escape hatch and do not argue.

**HC drops the stocks entirely.** At 19.43:1 the ink cannot afford a tinted ground, and a tone step is exactly what an HC user cannot perceive. The keyline goes to **3dp** and *is* the tile; the lit state becomes a full inversion — the only signal available at that contrast, and the user opted in.

**Switcher: three cycle positions — `paper → ink → high contrast → paper`.** HC polarity is a set-once settings preference (`ink` default), not a fourth position: a shutdown user needs one tap to produce one predictable next state. Four palettes, three positions.

**`MediaQuery.highContrastOf` is iOS-only and always false on Android** (`dart:ui` `AccessibilityFeatures.highContrast`: *"Only supported on iOS"*). The in-app switcher is not a convenience — it is the only mechanism that works on the target platform. Read the flag opportunistically, never gate on it. Persist the choice and restore it **before first paint**: a flash of the wrong polarity is a sudden luminance change, the exact event the animation ban exists to prevent.

### 1.4 The four stocks

Four, not twelve. Named, not numbered. Staggered in lightness **on purpose**.

| stock | dark | L / C / H | ink on it | lit | ink on lit |
|---|---|---|---|---|---|
| `oxblood` | `#2A1A1D` | 0.240 / 0.026 / 8° | 11.80:1 / −81.8 | `#413033` | 8.79:1 / −77.4 |
| `slate` | `#152C42` | 0.285 / 0.050 / 250° | 10.14:1 / −79.7 | `#2C435B` | 7.23:1 / −73.5 |
| `tan` | `#4B2E14` | 0.330 / 0.058 / 60° | 8.77:1 / −77.2 | `#65462C` | 6.05:1 / −69.5 |
| `fir` | `#2E473F` | 0.375 / 0.034 / 172° | 7.14:1 / −73.2 | `#466057` | 4.85:1 / −64.4 |
| `oxblood` | `#DDACB3` | L 0.791 | 7.97:1 / +62.5 | `#C19299` | 5.88:1 / +48.7 |
| `slate` | `#B3CAE2` | L 0.830 | 9.35:1 / +70.6 | `#99AFC6` | 6.98:1 / +56.1 |
| `tan` | `#F2CCAF` | L 0.870 | 10.53:1 / +77.1 | `#D6B194` | 7.93:1 / +62.2 |
| `fir` | `#CCE9DF` | L 0.910 | 12.22:1 / +85.9 | `#B1CDC3` | 9.30:1 / +70.3 |

**Colourblind separation** — minimum pairwise OKLab ΔE ×100, Viénot 1999 simulation:

| palette | normal | protan | deutan | grayscale |
|---|---|---|---|---|
| **Reed dark stocks** | **8.09** | **8.11** | **7.00** | 4.40 |
| **Reed light stocks** | **8.71** | **7.99** | **6.62** | 3.72 |
| isoluminant @ C 0.060 *(rejected)* | 4.65 | 4.68 | **1.06** | 0.41 |
| Okabe-Ito *(at chroma 0.117–0.172)* | 15.6 | 9.1 | 8.0 | — |

**The lightness stagger is the CVD fix and the weave, in one decision** — the rare case where accessibility and beauty are the same move, and worth being explicit about. Protan/deutan destroy the red–green axis; the surviving axis is blue–yellow, which affords about two hues. Hue alone therefore cannot separate four muted stocks: the isoluminant control collapses to deutan ΔE **1.06** — the same tile twice — and it fails at ΔE 4.65 for *normal* vision too. Stagger the lightness across the usable window and deutan separation rises to **7.00 at chroma ≤ 0.058**, within reach of Okabe-Ito's 8.0 at a third of the chroma. Visually, a grid whose chips differ slightly in lightness reads as woven cloth rather than an institutional board.

The window is narrow and its bounds are named: OKLCH **L 0.240 → 0.375** in dark (range 0.135), bounded above by *ink on stock ≥ 7:1* and below by *stock separable from ground*.

**This is not a salience hierarchy, and the distinction is load-bearing.** Four stocks across twelve tiles means each appears about three times, scattered by category, not by rank — a ΔL of 0.135 spread over four repeating stocks reads as texture. Making one tile lighter *because it matters more* would be a hierarchy, and that is banned (§4.4).

**Colour is never the only channel.** Position is the retrieval mechanism and is fixed; the label is always present (WCAG 1.4.1). Category hue is a redundant assist. That is what makes deutan ΔE 7.00 sufficient rather than a gamble, and what lets HC drop the stocks entirely without breaking findability. Assignment is per-category and stable forever; a category's colour must never imply a category's position.

### 1.5 Accent: exactly one, and it is the focus ring

The whole screen is muted tinted neutrals plus four muted stocks. **One element carries a saturated accent: the focus ring** (`#FFD9A0` amber). It is the one place high-luminance yellow earns its keep — a focus indicator is supposed to grab, and it is the signal a keyboard/switch user cannot afford to lose. It is not on the primary path (tiles are found by position and hue), so it cannot pull the eye from the lower-centre arc. **There is no red anywhere.** See §5.

### 1.6 Hand-authored `ColorScheme`, not `fromSeed`

`fromSeed`'s `tonalSpot` pins neutral chroma at HCT 4 and derives hue from the seed: it is a machine for producing the generic Material look, which is the founder's stated enemy. And **its per-role overrides are applied post-hoc and do not propagate** — overriding `surface` does not regenerate `surfaceContainerHigh`, which stays seed-derived. "Seed + override" means owning the ~9 roles you chose *and* every seam with the ~38 you didn't. Owning one thing is cheaper. Hand-author it; keep the M3 role names so Material's `TextField` themes correctly with zero fighting.

Cost: Material You wallpaper theming is forfeited. **That is a feature.** Wallpaper-derived palettes are untestable at build time — every guarantee the CI gate provides evaporates the moment the palette is computed on-device from an image nobody has seen. And a communication tool whose colours shift because the user changed their wallpaper breaks the position/colour learning the product rests on. Colour stability is part of the retrieval mechanism. **`dynamic_color` is rejected.**

---

## 2. Typography

### 2.1 Atkinson Hyperlegible Next — and an honest account of why

Ship **Atkinson Hyperlegible Next**, variable, upright only, SIL OFL 1.1, from `github.com/googlefonts/atkinson-hyperlegible-next` — **never** `brailleinstitute.org`, which gates an open-source font behind email registration and a EULA. Ship `OFL.txt`; register via `LicenseRegistry.addLicense()`.

Verified by probing the shipped TTF, not by reading a blog:

```
upem 1000 | glyphs 392
axis wght  min 200  default 400  max 800    <- ONE axis. No opsz. No GRAD. No ital.
instances  200 300 400 500 600 700 800
a-z total advance 12655 (avg 0.4867 em)
capHeight 668 | ascent 984 | descent -316   <- ascenders sit ABOVE cap height
```

Italic is a **separate file** and we do not ship it — no role here, double the payload, and `FontVariation('ital', 1)` would silently no-op.

**Is it the right call or the institutional-safe one?** Its credential is weaker than its reputation: there is **no independent peer-reviewed validation.** It was developed and tested with low-vision readers and clinicians at the Braille Institute using reading-speed and retention tests; that testing is unpublished and non-independent. **Never write "scientifically proven."** The honest phrasing is *"developed and tested with low-vision readers at the Braille Institute."*

Three grounds survive scrutiny. **Letterform differentiation is its whole design thesis** — a serif on uppercase I but not on T, a much longer F crossbar, angled spurs — and confusing `Il1` / `O0` / `rn`-`m` is precisely the failure mode of someone reading fast in a shutdown; the lesson generalises, in that legibility comes from making characters *different from each other*, not from making each one "clear." **Its width — the thing reviewers criticise — is doing legibility work**: pimpmytype calls Next "chunky and spacious" at display size and ties that space directly to "highly legible, wider characters, such as I, l, and i," which is a virtue scored as a flaw. And **provenance**: a disability institution made a legibility artefact and refused to make it look clinical. That is the thesis in a typeface.

The "institutional" complaint is real *at default settings*, and it is fixed by the setting (§2.3), not a different face. If the founder rejects it on character after seeing it set properly, the backup is **Bricolage Grotesque** (OFL; `opsz 12–96` natively spans tile→poster, the one axis Atkinson lacks) — but its `Il1`/`rn` differentiation is unverified and must be user-tested before it touches an AAC tile.

**One typeface, everywhere.** Not economy — the tile label and the show poster **are the same string**. You tap "Can't talk" and it becomes a poster. Set in two faces, the utterance changes identity as it amplifies. Same voice, just louder.

### 2.2 Bundling — no `google_fonts`

`google_fonts` fetches over HTTP at runtime **by default**. It can be made offline, but that ships an HTTP client and a network code path into an app whose pitch is *"no internet permission — that's not a promise, it's a fact you can check."* Take no dependency:

```yaml
flutter:
  fonts:
    - family: AtkinsonHyperlegibleNext
      fonts: [{ asset: assets/fonts/AtkinsonHyperlegibleNext-VF.ttf }]
```

Subset to Latin + punctuation with `pyftsubset`, **preserving the wght axis** (`--layout-features='*'`; do not let the subsetter instance the font). Flutter tree-shakes *icon* fonts only, never text fonts — subsetting is manual and mandatory. ~80–120KB from ~200–400KB.

### 2.3 The scale — five roles, and the spread is the point

| role | size | wght | tracking | height | align |
|---|---|---|---|---|---|
| `tile` | 20 | **600** | −0.20 (−0.01em) | 1.15 | start, bottom-anchored |
| `show` | **fitted 32–140** | **500** | −0.02em (−1.92 @ 96) | 0.98 | start, ragged right |
| `standing` | 18 | 500 | 0 | 1.30 | start |
| `field` | 22 | 500 | 0 | 1.30 | start |
| `meta` (chrome) | 15 | 500 | +0.15 (+0.01em) | 1.35 | start, lowercase |

**Tile → show is 1:5 at the top end (15 → 140 across the app is 1:9.3).** That scale jump *is* the aesthetic. Posters are beautiful because of scale contrast, and this app cannot use motion, so scale contrast is the loudest instrument available. Resist a sixth role: each erodes the jump that carries the whole thing.

**Hand-built optical sizing.** Atkinson has no `opsz` axis (the probe confirms one axis), so compensation is manual, and the rule is one line each way: **as size rises, weight falls and tracking tightens.** 20pt→w600/−0.01em; 96pt→w500/−0.02em; 15pt→w500/+0.01em. This is exactly what fixes the "chunky at display" critique. **Never w700 in show mode** — bold at 100pt closes the counters, and counter size is a real legibility factor; w500 at poster scale is both prettier *and* more legible than bold.

Never track below −0.02em: past that, Atkinson's generous sidebearings stop protecting letter separation, which is the one thing we are paying for. If the user enables the OpenDyslexic option, drop all negative tracking to 0 — that font's proportions assume default spacing.

`FontWeight` sets the `wght` axis automatically since Flutter 3.41 (breaking change `font-weight-variation`). Use `fontWeight: FontWeight.w600`; do **not** also pass `FontVariation('wght', 600)`. `FontWeight(560)` is legal for an off-step weight.

**Hold weight identical across all four palettes.** `boldText` is the only thing that moves it. Halation is solved with ink luminance (§1.1), never weight: heavier glyphs at high luminance contrast bloom *more*, and `wght` changes advance widths, which could re-wrap a label between themes — and reflow is banned.

### 2.4 Punctuation — the cheapest craft in the system

Real apostrophes (`’` not `'`). Sentence case. **No terminal periods on tile labels** — a period on a button is institutional. Intentional `…` and `—`. Normalise straight quotes to curly **on save only**, never mid-typing.

`I can’t talk right now` at 20pt/w600 reads as made by a person; `I can't talk right now.` reads as a database dump. Zero bytes, zero risk, and most apps get it wrong — which is exactly why getting it right registers as craft.

**Sentence case, never all-caps.** MIT AgeLab found uppercase faster for glance reading of isolated words (lowercase needed 26% more time). We override deliberately: the finding is bounded to 1–2 word phrases and our labels run to four; and **ALL CAPS ON AN AAC UTTERANCE READS AS SHOUTING**, which is catastrophic when the phrase is "I need a minute" and the point is to signal distress calmly. Log the reasoning — this question comes back.

**All chrome is lowercase**: `theme` · `edit` · `show` · `settings`. Democratic, current, adult-indie rather than clinical. Reed's own strings only — force-lowercasing a user's phrases is the precise flavour of condescension this product exists to avoid. Author it lowercase in the string table; never a text transform, or you will eventually lowercase someone's name.

---

## 3. The tile

### 3.1 A chip, not a card

Banned on the tile: `Card`, `elevation`, `BoxShadow`, ripple. A card is the 2014 enterprise grid — shadow + rounded rect + centred content *is* the failure mode.

```
┌──────────────────┐  ← RoundedSuperellipseBorder, r = 20dp
│              ·   │  ← divergence tick (6dp hairline) — only when says ≠ label
│                  │
│ I can’t          │  ← label: start-aligned, BOTTOM-anchored, 20pt / w600
│ talk             │     −0.20 tracking / height 1.15 / max 3 lines
└──────────────────┘     16dp inset · 1 physical px keyline
```

| property | value |
|---|---|
| size | **not fixed** — `(viewport − chrome) / rows`. See §4.1. |
| radius | **20dp**, `RoundedSuperellipseBorder` |
| fill | full opaque category stock |
| keyline | `1.0 / devicePixelRatio` logical px (0.333dp on a 3×), `keyline` colour, `strokeAlignInside` |
| inset | 16dp |
| hit target | the full rect, always — never the painted shape |

**On the 76dp floor: it is invented, and we are deleting it.** WCAG 2.5.8 (AA) is 24×24 CSS px; 2.5.5 Enhanced (AAA) is 44×44. 76dp appears in no standard. It is also non-binding — tiles compute to ~89–106 × 125–146dp on real phones (§4.1) — and at 200% text scale it is the *wrong* constraint, because the label block needs ~124dp. The real constraint is `tileHeight = (viewport − chrome) / rows`, with **CI asserting the label fits inside it at every text scale**. A number that does nothing but sound rigorous is worse than no number.

### 3.2 Shape: `RoundedSuperellipseBorder`, and the workarounds are dead

```dart
const RoundedSuperellipseBorder(
  borderRadius: BorderRadius.all(Radius.circular(Geom.tileRadius)),
  side: BorderSide(color: keyline, width: hairline, strokeAlign: BorderSide.strokeAlignInside),
)
```

Landed in Flutter **3.32** (May 2025) with a GPU implementation in Impeller, alongside `ClipRSuperellipse` and `Canvas.drawRSuperellipse`. Both compile on 3.41.2 (verified here).

**`ContinuousRectangleBorder` is banned.** It is not an iOS-grade squircle: it needs its radius multiplied by ~2.3529 to approximate one, that multiplier makes it degenerate into a "TIE-fighter" *earlier*, and it centres strokes regardless of `strokeAlign`. The hack fails at exactly the radius this app wants. `figma_squircle` and `smooth_corner` are now unnecessary.

Honest caveat: Impeller is default on Android **API 29+** and prefers Vulkan; API 28 and below use OpenGL unconditionally, where the RSuperellipse fast path is undocumented and unmeasured. Verify raster time on a real API 28 device — a disabled-user audience disproportionately carries old hardware. The visual delta versus a plain rounded rect is ~1–2px: polish, not load-bearing. Do not block the MVP on it.

Radius-to-size of roughly **1:6** reads 2026. 8dp reads 2014, 12–16dp reads generic M3 card, pill wastes corner area. **Concentric by construction:** `inner = outer − padding`, computed, never a constant, or it drifts.

### 3.3 The label: start-aligned, bottom-anchored

The corpus contradicted itself (`typography-system` said centred; `tile-grid` said left). **Adjudicated: start-aligned, bottom-anchored.** A swatch chip has its name ranged left at the bottom — that *is* the reference class. Centred text in a box is the universal signal for "button"; start-aligned text on a baseline is the signal for "page." The counter-argument for centring (constant optical centre of gravity across 1- and 2-line tiles) is answered better by bottom-anchoring: 1-line and 3-line tiles share their **last baseline**, so a row scans as a line of type rather than four unrelated widgets. And it reserves the top-right corner, which the divergence tick needs now and a symbol will need in v1+ — a centred label has nowhere to put a symbol later without recomposing the tile.

Use `TextAlign.start` and `EdgeInsetsDirectional`, never `TextAlign.left`/`EdgeInsets`, so RTL mirrors.

Bottom-anchoring also **kills the optical-centring problem outright**. The probe confirms `ascent 984 > capHeight 668`, so Atkinson's em box is top-heavy and mathematically-centred text sits optically low — a real bug we simply do not have. Show mode still needs the fix and gets it **metrically**, never as a hardcoded nudge (which would break at 200% scale and on the dyslexia-font option):

```dart
const TextHeightBehavior(applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false, leadingDistribution: TextLeadingDistribution.even)
```

### 3.4 A 2-word label and a 9-word label: a content problem, not a typography one

**Split the model. Two fields per phrase.**

| field | shown | cap |
|---|---|---|
| `label` | the tile | **16 characters**, hard |
| `says` | TTS + show screen | uncapped; defaults to `label` |

Tile: `Can’t talk`. Says: `I can’t talk right now but I’m okay.` The editor labels them **"What you see"** and **"What it says"**, with `says` collapsed and auto-mirroring `label` until explicitly opened — most users never see it.

No amount of type craft fixes a 2-word tile beside a 9-word tile in a fixed grid, because it is not a typographic problem. The tile is a **handle** for an utterance, not the utterance. That is also the honest AAC model, and it is what makes "never truncate" safe. The rules that follow are load-bearing for each other: **one uniform size for all 12** (variable line count is fine; variable size reads as broken); **never `FittedBox`, never auto-shrink, never ellipsize** — auto-shrink is the obvious move and it is backwards, making the *longest* (most complex) phrase the *smallest*, destroying the grid's rhythm, and defeating the user's own TextScaler setting, while an ellipsis on an AAC utterance is a *different utterance*; **the editor refuses at 16 characters and never silently truncates**; and **hand-set line breaks** — support a literal `\n` in shipped labels (`I need\na minute`), because ragged text strands words and Flutter has no text-balance. Treat `\n` as a **hint**: if scaled text exceeds 3 lines, fall back to natural wrap.

**No ghost line.** The corpus proposed rendering `says` under the label at 13sp / w400 / 55–60% opacity as "the tile's typographic texture." It does not work, and the numbers say so:

| ghost line @ 60% ink | contrast | verdict |
|---|---|---|
| on `ground` | 5.34:1 | **passes WCAG AA — and is Lc −39.0**, i.e. unreadable |
| on `fir` | 4.51:1 | marginal |
| on `slate` | 4.24:1 | **fails AA** |
| on `oxblood` | 3.94:1 | **fails AA** |

It is the WCAG trap in miniature: a ratio test blesses it. Verification of `says` belongs in edit mode, where you are not in a shutdown. **On the grid, divergence gets one 6dp hairline tick, top-right, in `keyline`, only when `says ≠ label`.** A chip has a name on it, not a paragraph.

**Layout is a setting, chosen once.** `Tiles: 12 · 6` in settings, visible from install, **never prompted**. At *first launch only*, lay out the longest starter label with a `TextPainter` at the live `textScaler` and pick 6 tiles if it exceeds 3 lines or overflows. Persist. **Never re-evaluate.** This is not the app noticing something about the user — it is the same "pick a sane default once" as respecting `platformBrightness`. A prompt ("Text is large. Switch to 6 tiles?") is the app offering an accommodation it noticed you need, which is the parental register in indie clothes.

This matters because the alternative is dishonest: at 200% a 20pt label becomes 40pt and 12 tiles **arithmetically cannot render** on a phone (~124dp needed against ~125dp of tile). "Never reflow" absolutism resolves to "never work at 200%." Position-as-retrieval survives fine as **two stable maps the user opts into**, with positions fixed *within* each.

### 3.5 The lit state — press and speech are one signal

There is no separate press state. **Pointer-down lights the tile; it stays lit until TTS completes.** One state, two triggers: the press feedback and the speaking indicator are the same signal.

| | value |
|---|---|
| fill | `stockLit` (OKLCH L ±0.09 toward the ink) |
| keyline | 1 physical px → **2dp**, colour → `ink` |
| duration | **zero**. `NoSplash.splashFactory` at the theme root. |
| minimum hold | **120ms**, so a fast tap is never imperceptible |
| trigger | `Listener.onPointerDown` — **not** `onTap` |
| order | haptic → `setState(lit)` → TTS |

`onTap` fires on pointer *up*, delaying all feedback by the entire press duration. `onPointerDown` plus Android's touch pipeline (~20–40ms) plus one frame (8–16ms) lands feedback at ~30–55ms with no artificial delay. It fires before gesture disambiguation — safe **only because the grid never scrolls**, which makes that rule load-bearing rather than aesthetic.

**The lit state is a luminance step, not a chroma flood.** The corpus proposed flooding the tile with the accent at matched luminance ("change chroma, hold lightness"). Computed: **1.02:1** in colour and **1.015:1 in Android's Grayscale colour-correction mode — literally invisible.** A user with motor imprecision in a shutdown gets no confirmation their tap landed. Banning the ripple was right; replacing it with nothing was not. Our step measures 1.34–1.48:1 and **survives grayscale (1.36–1.48:1) and protan (1.34–1.52:1)**, with the keyline promotion as a second, non-chroma channel. Pair it with `HapticFeedback.selectionClick`. **Feedback is never single-channel and never chroma-only.**

Two-tier contrast floor, stated out loud so nobody "fixes" it: **resting label = WCAG AAA (7:1) and APCA Lc ≥ 60** (text read during a shutdown); **lit label = WCAG AA (4.5:1) and APCA |Lc| ≥ 45** (a 1–3s transient the user triggered on a label they had just finished reading — it must stay *identifiable*, not *readable*).

Guard the latch with a timeout that force-clears it — `flutter_tts` completion-handler reliability varies by OEM, and a stuck-lit tile is a lie about what the app is doing. Expose the lit state through `Semantics`, never colour alone.

### 3.6 Focus — and it goes in the gutter

The corpus specified `#FFD9A0` and checked it against one palette. On light paper it is **1.20:1** — an invisible focus ring. Recolouring the tile's own keyline to amber gives 2.73:1 on changed pixels, failing SC 2.4.13's 3:1.

**Fix: the ring is drawn in the gutter, outside the tile, never on it.** Offset **2dp**, width **3dp**, same superellipse at radius **22dp** (= 20 + 2), colour `focus` per palette.

Changed pixels are therefore `ground → ring`: **13.70:1** (ink), **6.69:1** (paper), **14.85:1** (hcInk), **10.64:1** (hcPaper) — all clearing SC 2.4.13's 3:1 by a wide margin, with area vastly exceeding a 2px perimeter. It never touches a fill, so no per-stock verification is needed. There is 9dp of clear ground between the ring and the next tile.

**Switch Access users do not see this ring.** Switch Access draws its own highlight, user-configurable in colour and thickness, and in group selection the highlighter colours change on every press. Ours serves keyboard and TalkBack. **Touch, switch, and screen reader are three different visual channels and only one of them is ours** — which is also why reserving a colour "absolutely" is impossible.

### 3.7 The empty slot

**Ground. Nothing else.** No fill, no keyline, no target, no ripple, and **no semantics node at all** — `ExcludeSemantics`, not `enabled: false`.

Not a hole and not broken: it is a socket with nothing installed, which is precisely what it is. The surrounding keylines define its shape by negative space. An outlined empty slot fails twice at once — it looks like a broken or disabled tile *and* it invites a tap. Excluding it from the semantics tree (rather than disabling it) means Switch Access and TalkBack **skip** it instead of burning a scan step on nothing; under linear autoscan at 1s/step, every wasted step is real time.

**In edit mode it becomes a full target with a keyline, a `+`, and full semantics.** Different mode, different rules — make the exclusion mode-dependent or the editor is unusable via switch access.

### 3.8 Traversal order is a design decision, and it is currently nobody's

The corpus found one inversion (show mode's polarity) and missed the identical one under its nose. "Highest-value tiles in the lower-centre arc" plus Flutter's default row-major traversal gives:

```
 1   2   3
 4   5   6
 7   8   9     ← lower-centre arc: the tiles that matter most
10  11  12     ← bottom-centre
```

**"I need to leave" is the 8th-to-11th thing TalkBack reads** — 8–11 seconds under Switch Access linear autoscan at 1s/step. The thumb-reach optimisation *actively pessimises* the screen-reader and switch experience. The fix is total and costs one argument:

```dart
Semantics(button: true, label: tile.label,
  sortKey: OrdinalSortKey(tile.priority.toDouble()),  // priority, NOT layout order
  child: ...)
```

`OrdinalSortKey` decouples traversal from visual position: lower-centre thumb placement **and** first-in-traversal. Author it from priority and assert it in CI (§10) — inheriting it from layout by accident is not a decision.

(Switch Access *group* selection reaches any of 12 items in ⌈log₂12⌉ = 4 presses regardless of order, so the arc neither helps nor harms there; only linear scanners depend on `sortKey`. Flutter publishes no Switch Access support statement and no API simulates scanning — the traversal test is a regression guard on intent, never conformance evidence.)

---

## 4. The grid

### 4.1 Geometry

| property | value |
|---|---|
| layout | **uniform 3 × 4** (or 2 × 3), fixed positions, never reflows |
| column gap | **14dp** |
| row gap | **22dp** |
| side margin | **24dp** |
| background plane | **full-bleed**, edge-to-edge, under status and nav bars |
| grid | inset by `SafeArea` + margin |
| dividers | **none** |

Computed tile sizes (status 48 / nav 24 / chrome 44 / field 72):

| device | 3×4 tile | measure | 2×3 tile | measure |
|---|---|---|---|---|
| 393 × 852 (Pixel 8) | 105.7 × 138.5 | 73.7dp | 165.5 × 192.0 | 133.5dp |
| 360 × 800 | 94.7 × 125.5 | 62.7dp | 149.0 × 174.7 | 117.0dp |
| 344 × 882 (cover) | 89.3 × 146.0 | 57.3dp | 141.0 × 202.0 | 109.0dp |

**Gutters are never equal.** Equal gutters in both axes read as a table; unequal gutters read as a designed page and group the grid into **rows**, which is what you want. Cheapest "composed vs. aligned" move that exists; costs two integers.

**Edge-to-edge is forced and the grid is inset — never the same question.** Flutter 3.44 defaults to `targetSdk 36`, and apps targeting Android 16 cannot opt out (`windowOptOutEdgeToEdgeEnforcement` is deprecated and disabled). The *window* is edge-to-edge; the *targets* are inset. The 24dp margin is a design choice on thumb-ergonomic and edge-slop grounds, **not** a platform requirement: Android's ~20dp back-gesture bands pass taps through unharmed, and these tiles are tap-only. (Read `MediaQuery.systemGestureInsets` rather than hardcoding 20dp if that changes; it reports zero on iOS.)

**No dividers.** They read 2014 and turn chips into a spreadsheet. The gap *is* the design. Worth being deliberate: at 20dp radius and a 14/22dp gap, the negative space where four tiles meet forms a small four-pointed star. That recurring shape is a real compositional element — pick the ratio on purpose (gap ≈ 0.6–1.1 × radius).

### 4.2 The type-to-speak field is the 13th cell

Same radius, same keyline, same material, `container` fill, spanning 3 columns, **at the top**.

This is the answer to "two apps stapled together": the field is not an input bolted onto a grid, it is the grid cell that is blank because you fill it. The position is principled, not aesthetic — **the ability to type implies more capacity than the ability to tap.** Tiles are for crisis; typing is for when you are okay. Typing earns the worst position, and the keyboard then covers the grid while leaving the field visible.

**Never autofocus** — a keyboard covering the grid at cold launch is catastrophic for the core use case. Set `resizeToAvoidBottomInset: false`: keyboard insets must not resize or reflow the grid, because reflow breaks the fixed-position guarantee.

Use `ShapedInputBorder(shape: RoundedSuperellipseBorder(...))`. <!-- VERIFY: ShapedInputBorder is 3.44 (PR #177220). Compile-tested here on 3.41.2 and it does NOT exist ("The function 'ShapedInputBorder' isn't defined"). On 3.41.x use OutlineInputBorder at 20dp and swap on upgrade. There is no `RoundedSuperellipseInputBorder` — that name is wrong in the corpus. -->

**Do not go bespoke on `TextField`.** Reimplementing IME and selection is a multi-month trap. The tile is bespoke; the field is Material.

### 4.3 Reachability

The lower-centre arc gets the highest-priority phrases: rows 3–4, centre column weighted. Position is authored, fixed forever, and is the retrieval mechanism. It is decoupled from traversal order (§3.8).

### 4.4 What we killed, and why

**Non-uniform row heights (76/88/100/112) — killed.** The most concrete compositional idea in the corpus, and wrong here for a reason the corpus never reached: **non-uniform tile sizes encode *our* value hierarchy into *their* vocabulary.** Day two the user replaces half the phrases and the beautiful ratio is lying about what matters. Its own risk note conceded the ratio must "compress toward 1.0" at 200% — it designed the thing and designed it away in the same paragraph. And a uniform grid degrades uniformly under text scale where a bento grid fails catastrophically at its smallest cell. **Uniform is not the timid choice here; it is the honest one.**

**Bento / `row_span` as a v1 feature — killed.** Google's own caveat is that expressive design *hurt* usability when it replaced familiar structure (scattered album art vs. a vertical list). Keep `row_span`/`col_span` in the schema — the type field is already a 3-column cell, so the mechanism is needed on day one — but ship uniform, and never expose it as a phrase property.

**Grain — killed.** Four dimensions proposed it and all four killed it in their own risk note ("the move most likely to be cut," "least confident," "LOWEST-CONFIDENCE"). A coin picked up four times and never flipped. Flipped: **no grain.** Not on sensory grounds — the measured contrast cost at 2% is 0.6 of a 13:1 budget, a rounding error. Killed because **a flat, opaque, dyed field is better**, and grain is what you reach for when you do not trust your colour.

**Isoluminant tiles — killed.** §1.4: deutan ΔE 1.06, and it fails for normal vision too. Its goal (no salience winner) is right, and the stagger achieves it without collapsing.

---

## 5. Interrupt and repair — there is no STOP

**We are deleting the STOP control.** The corpus specified a reserved-red emergency bar sourced to **ISO 13850**, the emergency-stop standard for machinery. The fact-check demolished the citation: ISO 3864-4 fixes safety red as a *bounded, high-chroma* region, so "muted red" walks out of the very standard invoked to justify it; "reserved exclusively" is NFPA 79, not ISO 13850; the faster-than-text claim is a committee expectation with no study behind it; and the mushroom head is not mandated. The design move survived the refutation anyway, with nothing put in its place.

It should not have survived, and the reason is not sourcing. **What does STOP actually do? It cancels TTS mid-utterance. That is a cancel.** Coding a cancel as a big red emergency button on someone's communication device designs for a bystander's fear of the user, not for the user's use. It would be the most infantilising element in the product, arriving wearing a safety standard. Reservation cannot work anyway: it depends on a legally-enforced installed base that trained the prior over decades, and an app cannot reserve a colour in a first-time user's head — Switch Access will paint red over the grid regardless.

**The replacement: the speaking tile is the stop control.**

| gesture | result |
|---|---|
| tap the **lit** tile | speech stops. Does not restart. |
| tap a **different** tile | current speech stops, new phrase speaks |
| nothing lit | tap speaks |

The lit tile is unambiguously the thing talking, so tapping the talking thing to stop it needs no learning. Zero screen area, already where the thumb is, and it removes an emergency-coded control from a communication device. There is only ever one utterance in flight; there is no mode.

**Repair is a phrase, not a mechanism.** One of the twelve starters is the repair tile, fixed position, on `oxblood`, replaceable like any other:

> **label:** `Wrong one` · **says:** `Sorry — that wasn’t what I meant to say.`

Repair is something you *say*, not a button the app gives you. That is the dignity-correct answer and it costs one row of the starter list.

**No red anywhere in Reed.** `oxblood` at OKLCH C 0.026 is a stock, not an alarm.

---

## 6. The show screen — a poster, not UI

### 6.1 The one bold move: each line optically justified

Take `says`. Break it into 2–4 lines. **Scale each line independently so it touches both margins exactly.** Flush left *and* flush right — by size, never by tracking. Line one might be 96pt, line two 138pt, line three 71pt.

```dart
// per line, at a probe size of 100:
final tp = TextPainter(text: TextSpan(text: line, style: showStyle.copyWith(fontSize: 100)),
    textDirection: TextDirection.ltr)..layout();
final size = (100 * measure / tp.width).clamp(32.0, 140.0);
```

Choose the break by brute force: for `n` in 1..4, enumerate break points (≤56 combinations for a ≤9-word phrase), score by the largest minimum line size that still fits the height, take the winner. One layout pass, no animation, no assets.

**This is why it is right and not merely nice: the most beautiful setting and the most legible setting are the same computation.** A cashier at arm's length in daylight gets the largest letters physically available for that phrase in that rectangle. Nothing in AAC looks remotely like it — Emergency Chat proved the interaction a decade ago and shipped it in system font on white.

| property | value |
|---|---|
| ground | `#FFFCF7` — **light polarity, always, regardless of theme** |
| ink | `#1A140D` — **17.85:1 / Lc +103.3** |
| type | `show`: fitted 32–140pt / **w500** / −0.02em / height 0.98 |
| align | start, ragged right, 2–4 lines, vertically centred as an optical block |
| margin | 24dp · **chrome:** none |
| exit | **a tap anywhere**, plus the system back gesture |
| orientation | landscape offered (≈2× type size) |

Warm ink on warm paper holds Lc +103.3 against pure `#000`/`#FFF`'s +106.0 — 2.7 Lc to stay in family, affordable because anything past Lc 90 is beyond the fluent-reading bar. If `says` is long enough that six lines at the 32pt floor still overflow, the poster becomes a scrollable block at 32pt — an honest degradation for a user who deliberately wrote a paragraph. Show mode never scrolls otherwise.

### 6.2 The standing line — the thing the corpus dropped

Above the poster: `standing` role, 18pt / w500, in `showStandingLine` (`#5A544E`, **7.29:1 / Lc +84.3** on paper), start-aligned at the top margin.

> **`I can’t speak right now. I can hear you.`**

User-editable in settings, including empty. **Default on.**

This is the design investment show mode actually needs, and it is not the typeface. **The enemy is being misread, not being seen.** Show mode's job is frame control — the two seconds where a stranger decides. A phone held up saying "Thank you" in huge type reads as *weird*; the same phone with the standing line above it reads instantly. This is Emergency Chat's exact move, and Emergency Chat is the closest precedent in existence: built by an autistic adult, validated for a decade, executed with zero design investment. That gap is the wedge.

Pullin is routinely misread as licensing volume here. He is not: *"Fashion can be understated, and discretion does not require invisibility,"* and his ideal is something *"unmistakably, unashamedly and **unremarkably** a hearing aid."* Glasses did not win by being loud; they won by being ordinary, desirable, and well-resolved. The poster is loud because a stranger must read it at arm's length in daylight. That is ergonomics, not swagger.

### 6.3 The flash — decided

Entering show mode from `ink` jumps L 0.19 → 0.98 in one frame. Every dimension flagged it and none decided. **Decided: it flashes. Instantly. No ramp.**

The user deliberately pressed a control and is turning the phone away from their own face at that moment — that *is* the mitigation. A ramp is *longer* exposure to the transition and costs latency in the one moment where latency is a social cost. **This is design judgment, not evidence**: the corpus's justification for the animation ban (Kaaresoja) was demolished by fact-check — it measured feedback *onset*, never tested a no-animation condition, and its guideline has a 30ms *lower* bound. So it ships with an escape hatch:

**Settings: `Show screen: bright · match my theme`.** A user who cannot tolerate the flash chooses `match my theme` and pays the stranger-legibility cost knowingly. That is their call.

**Exit is a tap anywhere, plus back. Never a targeted control.** The user is not looking at the screen — the phone is turned away — and hunting for a dismiss target by feel on a max-luminance surface while photophobic and mid-shutdown is a failure nobody in the corpus named.

**v1 does not touch screen brightness.** 17.85:1 suffices at typical brightness, and `screen_brightness` is a native dependency and another sensory event. Revisit in v1.1 with real users.

---

## 7. Space, shape, depth

**Spacing scale** (4dp base, deliberately non-uniform — uniform density is a 2014 tell): `4 · 8 · 12 · 14 · 16 · 22 · 24 · 32 · 48`

**Shape scale** — the M3 corner ladder, verified: `0 / 4 / 8 / 12 / 16 / 20 / 28 / 32 / 48 / full`.

| element | radius |
|---|---|
| tile, type field | **20dp** (`largeIncreased`) |
| focus ring | 22dp (= 20 + 2 offset) |
| inset chip inside a tile | **`outer − padding`**, computed |
| `full` | `StadiumBorder` — **never** `BorderRadius.circular(9999)`; `full` is 50% of component size, and 9999 is a third-party sentinel |

We take the ladder. We do **not** take M3 Expressive's 35-shape library, shape-morph, or motion physics: the shapes exist to morph, morph is animation, and the vocabulary is *heart, flower, bun, clover, sunny, puffy, cookie* — the banned childish register wearing a Google badge. Flutter ships none of it anyway (`flutter/flutter#168813`), so declining costs nothing. Re-check quarterly rather than treating any read as durable: after a May–July 2025 pause, work resumed in the decoupled `material_ui` package with ~20 tracked proposals as of April 2026.

**Depth, complete:**

| mechanism | status |
|---|---|
| tonal steps (ground → container → stock → stockLit) | **the depth system** |
| the keyline | **the depth system** |
| `BoxShadow` · `elevation:` · `BackdropFilter` · blur · gradients · grain · neumorphism · glassmorphism · bevels · long shadows | **banned** |

**On blur, the argument order matters.** Lead with accessibility: contrast over arbitrary content is **non-certifiable by construction** — you cannot assert a ratio against a background you do not control — and no engine release will fix that. For an app whose CI gate is a contrast matrix, translucency deletes the gate. The latency argument is real but weaker and staler than the corpus claimed: both cited perf issues are **closed as fixed**, the "6–9ms at sigma 20" figure traces to one blog post with no device and no methodology, and `BackdropGroup`/`BackdropFilter.grouped` (3.29+) addresses the multi-blur case. Flutter's own docs call `BackdropFilter` "relatively expensive" and point single-widget blurs at `ImageFiltered`. Ban it on the accessibility argument, which does not decay.

**Hairlines are 1 *physical* pixel**: `1.0 / MediaQuery.devicePixelRatioOf(context)` = 0.333dp on a 3×. **`Border.all()` is banned** — it defaults to 1.0 *logical* px = 3 physical pixels on a modern phone, which is a rule, not a hairline. A true 1-physical-pixel line reads as engraved. Decorative in `paper`/`ink`; in high contrast it is promoted to a solid **3dp** border and stops being decoration.

**The keyline is there because it is beautiful.** Say it out loud. The corpus wanted the hairline, was embarrassed to say why, went looking for WCAG 1.4.11 to hide behind, got fact-checked that 1.4.11 exempts controls identified by their own text label — and then went quiet. That reflex is exactly what produces grey rectangle grids: aesthetic conviction laundered through compliance until it dies. A keyline around a field of colour is how printers have made objects look *made* for five hundred years. It is not compelled by any standard, W3C recommends it as a cognitive-accessibility best practice, and the CI rule that guards it is honestly named `edge findability`, not `1.4.11` (§10).

---

## 8. Iconography

**There are no icons in v1.** Chrome is lowercase words in the `meta` role (15pt / w500 / `inkDim`): `theme` · `edit` · `show` · `settings`.

Three reasons, all specific to this app: the distressed-users research names "abstract, unlabeled icons requiring interpretation effort" as an anti-pattern; a word needs no `semanticLabel` because it *is* one; and it costs zero assets in an app whose pitch is that it ships nothing it does not need. It is also the Teenage Engineering register.

The theme control is labelled with the **current** palette (`theme: ink`) and cycles on tap. `semanticLabel: 'Theme: ink. Tap to change.'` The only non-text mark is the **divergence tick** — a 6dp hairline, top-right, `keyline` colour, `ExcludeSemantics` (divergence is announced in the tile's semantics label, not drawn twice).

**If iconography ever ships:** stroke weight matches type weight numerically (w600 type → 2dp strokes at 24dp; w400 → 1.5dp); icon size **and** stroke scale with `textScaler`, or the match inverts into sloppiness at exactly the accessibility setting that matters most; and `semanticLabel` is mandatory on every one, no exceptions.

---

## 9. The tokens

`lib/ui/core/tokens.dart` — **the only file permitted a colour literal.** Enforce it, do not promise it. Every design system that rotted, rotted by someone typing a hex at 11pm:

```bash
! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'
```

Primitives are `<family><tone>`; tone is a **measured** OKLCH lightness, so the name stays true forever and inverts correctly across themes by construction. Banned naming: `grey700` (rank scales have no room for insertion, and "500 is the main one" is a lie in dark mode), `colorDarkGrey` (appearance names invert catastrophically — `darkGrey` is your *lightest* colour in dark mode), `brandPrimary` (dies with the brand).

```dart
abstract final class Prim {
  // warm neutral ramp — OKLCH hue 65-85, chroma 0.006 -> 0.012.
  static const Color inkT06 = Color(0xFF0B0906); // HC ground
  static const Color inkT10 = Color(0xFF1A140D); // show poster ink
  static const Color inkT19 = Color(0xFF171411); // dark ground
  static const Color inkT25 = Color(0xFF25211D); // dark container
  static const Color inkT27 = Color(0xFF27221D); // light ink
  static const Color inkT58 = Color(0xFF5A544E); // light inkDim / standing line
  static const Color inkT70 = Color(0xFF6F6A64); // light keyline
  static const Color inkT72 = Color(0xFFAEAAA4); // dark inkDim
  static const Color inkT85 = Color(0xFF8A857F); // dark keyline
  static const Color inkT89 = Color(0xFFDCD9D3); // dark ink — the L 0.885 cap
  static const Color inkT92 = Color(0xFFE5E3DD); // light container
  static const Color inkT96 = Color(0xFFF4F2EE); // light ground
  static const Color inkT99 = Color(0xFFFFFCF7); // HC ink / show paper

  static const Color amberT88 = Color(0xFFFFD9A0); // the ONE saturated accent
  static const Color amberT45 = Color(0xFF7A4A05), amberT33 = Color(0xFF5C3300);

  // Four stocks, L-ascending. The stagger is the CVD fix AND the weave (§1.4).
  static const Color oxbloodT24 = Color(0xFF2A1A1D), oxbloodT33 = Color(0xFF413033);
  static const Color slateT29   = Color(0xFF152C42), slateT38   = Color(0xFF2C435B);
  static const Color tanT33     = Color(0xFF4B2E14), tanT42     = Color(0xFF65462C);
  static const Color firT38     = Color(0xFF2E473F), firT47     = Color(0xFF466057);

  static const Color oxbloodT79 = Color(0xFFDDACB3), oxbloodT71 = Color(0xFFC19299);
  static const Color slateT83   = Color(0xFFB3CAE2), slateT75   = Color(0xFF99AFC6);
  static const Color tanT87     = Color(0xFFF2CCAF), tanT79     = Color(0xFFD6B194);
  static const Color firT91     = Color(0xFFCCE9DF), firT83     = Color(0xFFB1CDC3);
}
```

The semantic tier. **`lerp` is a step function** — animation is banned, so ~13 lines of `Color.lerp` boilerplate go away, and with them the bug where someone forgets to lerp a newly-added field. Note it is *not* `return this`: if a theme change ever did animate, `this` would never arrive at the new palette. `t < 0.5` lands on the correct endpoint, and CI asserts it (§10). `copyWith` is still mandatory — it is an abstract interface member and omitting it will not compile.

```dart
enum Stock { oxblood, slate, tan, fir }
enum AacPalette { paper, ink, hcInk, hcPaper }

@immutable
class AacTheme extends ThemeExtension<AacTheme> {
  const AacTheme({required this.name, required this.palette, required this.ground,
    required this.container, required this.ink, required this.inkDim,
    required this.keyline, required this.focus, required this.stocks,
    required this.stocksLit, required this.showGround, required this.showInk,
    required this.showStandingLine, required this.keylineWidth,
    required this.keylineLitWidth, required this.usesStocks});

  final String name;
  final AacPalette palette;
  final Color ground, container, ink, inkDim, keyline, focus;
  final List<Color> stocks, stocksLit;              // indexed by Stock.index
  final Color showGround, showInk, showStandingLine;
  final double keylineWidth, keylineLitWidth;
  final bool usesStocks;             // false in HC: the keyline IS the tile

  Color stock(Stock s)    => usesStocks ? stocks[s.index]    : ground;
  Color stockLit(Stock s) => usesStocks ? stocksLit[s.index] : ink;
  Color inkOn(Stock s, {bool lit = false}) => usesStocks ? ink : (lit ? ground : ink);

  // Asserts rather than falling back. A `?? AacTheme.fallback()` would silently
  // ship a palette no test has verified — the exact failure this exists to prevent.
  static AacTheme of(BuildContext context) {
    final AacTheme? t = Theme.of(context).extension<AacTheme>();
    assert(t != null, 'AacTheme missing. Build ThemeData via aacThemeData().');
    return t!;
  }

  @override
  AacTheme lerp(covariant AacTheme? other, double t) => t < 0.5 ? this : (other ?? this);

  @override
  AacTheme copyWith({/* 16 nullable fields */}) => /* ... */;
}

const AacTheme kInk = AacTheme(
  name: 'ink', palette: AacPalette.ink,
  ground: Prim.inkT19, container: Prim.inkT25, ink: Prim.inkT89,
  inkDim: Prim.inkT72, keyline: Prim.inkT85, focus: Prim.amberT88,
  stocks:    <Color>[Prim.oxbloodT24, Prim.slateT29, Prim.tanT33, Prim.firT38],
  stocksLit: <Color>[Prim.oxbloodT33, Prim.slateT38, Prim.tanT42, Prim.firT47],
  showGround: Prim.inkT99, showInk: Prim.inkT10, showStandingLine: Prim.inkT58,
  keylineWidth: 1.0, keylineLitWidth: 2.0, usesStocks: true,
);
// kPaper likewise, from §1.2. kHcInk / kHcPaper (§1.3) set usesStocks: false,
// keylineWidth: 3.0, and stocks/stocksLit to [ground x4] / [ink x4].

const List<AacTheme> kAllThemes = <AacTheme>[kPaper, kInk, kHcInk, kHcPaper];

class _NoTransitions extends PageTransitionsBuilder {
  const _NoTransitions();
  @override
  Widget buildTransitions<T>(PageRoute<T>? r, BuildContext? c, Animation<double> a,
      Animation<double> s, Widget child) => child;
}

ThemeData aacThemeData(AacTheme t) {
  final Brightness b = switch (t.palette) {
    AacPalette.paper || AacPalette.hcPaper => Brightness.light,
    AacPalette.ink   || AacPalette.hcInk   => Brightness.dark,
  };
  return ThemeData(
    useMaterial3: true, brightness: b, scaffoldBackgroundColor: t.ground,
    // The ink ripple is an animation and is on by default on every InkWell.
    // "We don't animate" is false the moment anyone uses a Material button.
    splashFactory: NoSplash.splashFactory,
    splashColor: const Color(0x00000000), highlightColor: const Color(0x00000000),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: _NoTransitions(), TargetPlatform.iOS: _NoTransitions(),
    }),
    colorScheme: ColorScheme(
      brightness: b,
      primary: t.ink, onPrimary: t.ground,
      secondary: t.inkDim, onSecondary: t.ground,
      error: t.stocks[Stock.oxblood.index], onError: t.ink,
      surface: t.ground, onSurface: t.ink,
      surfaceContainer: t.container, surfaceContainerHighest: t.container,
      onSurfaceVariant: t.inkDim, outline: t.keyline, outlineVariant: t.keyline,
    ),
    extensions: <ThemeExtension<dynamic>>[t],
  );
}

abstract final class Geom {
  static const double tileRadius = 20.0, tileInset = 16.0;
  static const double gapColumn = 14.0, gapRow = 22.0, margin = 24.0;
  static const double focusRingOffset = 2.0, focusRingWidth = 3.0, fieldHeight = 72.0;
  static const int maxLabelChars = 16, maxLabelLines = 3;

  static double innerRadius(double outer, double pad) => (outer - pad).clamp(0.0, outer);
  static double hairline(double dpr) => 1.0 / dpr;
}
```

**Belt and braces on the animation ban.** `MaterialApp` mounts `AnimatedTheme` and interpolates `ThemeData` over `kThemeAnimationDuration` (200ms) by default — the step-function `lerp` alone would produce a *pop* while `ColorScheme` crossfades around it. Kill it at the app level too:

```dart
MaterialApp(theme: aacThemeData(current),
    themeAnimationStyle: AnimationStyle.noAnimation,  // verified on 3.41.2
    home: const BoardScreen())
```

**Skip DTCG / Style Dictionary / Figma.** DTCG 2025.10 is a real, stable, vendor-neutral Community Group Report — but *not* a W3C Recommendation (Community Groups structurally cannot publish one), and its whole purpose is moving tokens across a designer/engineer boundary. Here those are the same person: a JSON → Style Dictionary → Dart codegen step for ~30 colours buys a build step and a `node_modules` to solve a handoff problem that does not exist. Same for Figma — you cannot test `TextScaler` 200% there, you cannot feel tap→TTS latency there, and a mock of a fixed 3×4 grid across four palettes is ~16 frames of immediately-stale manual work. The one thing Figma is genuinely better at, cheap divergent exploration, is better still on paper: thumbnail six directions in thirty minutes, then build the winner in Flutter. Revisit only if a second person joins.

---

## 10. The contrast gate

`test/ui/contrast_test.dart`. Pure Dart, no widget tree, no golden files. **85 tests, ~1s** (measured: `flutter analyze` clean, all green on 3.41.2). A design system verified by CI is the move this project's constraints reward.

**Four channels, because a ratio test is not enough.** The rejected ghost line passed WCAG AA at 5.34:1 and was unreadable at Lc −39.0 — a contrast test would have blessed it. The rejected press flood was 1.02:1 in colour and **1.015:1 in grayscale**. The rejected isoluminant tiles collapse to deutan ΔE 1.06. Each is caught by a different channel.

```dart
double _wcag(Color fg, Color bg) {
  final double a = fg.computeLuminance(), b = bg.computeLuminance();
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}
double _y(Color c) => 0.2126729 * math.pow(c.r, 2.4) +
    0.7151522 * math.pow(c.g, 2.4) + 0.0721750 * math.pow(c.b, 2.4);

/// APCA 0.98G-4g. Validated against published reference pairs below; do not edit.
double _apca(Color txt, Color bg) {
  double ty = _y(txt), by = _y(bg);
  const double blkThrs = 0.022, blkClmp = 1.414;
  if (ty <= blkThrs) ty += math.pow(blkThrs - ty, blkClmp);
  if (by <= blkThrs) by += math.pow(blkThrs - by, blkClmp);
  if ((by - ty).abs() < 0.0005) return 0;
  final double s = by > ty ? (math.pow(by, 0.56) - math.pow(ty, 0.57)) * 1.14
                           : (math.pow(by, 0.65) - math.pow(ty, 0.62)) * 1.14;
  if (by > ty) return s < 0.1 ? 0 : (s - 0.027) * 100;
  return s > -0.1 ? 0 : (s + 0.027) * 100;
}

/// Android ships Settings > Accessibility > Color correction > Grayscale. Every
/// chroma-only signal is IDENTICALLY ZERO in that mode.
Color _gray(Color c) {
  final double y = c.computeLuminance();
  final double v = y <= 0.0031308 ? 12.92 * y : 1.055 * math.pow(y, 1 / 2.4) - 0.055;
  return Color.from(alpha: 1, red: v, green: v, blue: v);
}

typedef Pair = ({String what, Color fg, Color bg, double wcagMin, double lcMin});

List<Pair> _pairs(AacTheme t) {
  final List<Pair> p = <Pair>[
    (what: 'ink/ground',     fg: t.ink,     bg: t.ground,    wcagMin: 7.0, lcMin: 75),
    (what: 'inkDim/ground',  fg: t.inkDim,  bg: t.ground,    wcagMin: 4.5, lcMin: 55),
    (what: 'ink/container',  fg: t.ink,     bg: t.container, wcagMin: 7.0, lcMin: 75),
    (what: 'keyline/ground', fg: t.keyline, bg: t.ground,    wcagMin: 3.0, lcMin: 30),
    // Ring lives in the GUTTER, so changed pixels are ground -> ring (SC 2.4.13).
    (what: 'focus/ground',   fg: t.focus,   bg: t.ground,    wcagMin: 3.0, lcMin: 45),
    (what: 'show',           fg: t.showInk, bg: t.showGround, wcagMin: 7.0, lcMin: 90),
    (what: 'standing', fg: t.showStandingLine, bg: t.showGround, wcagMin: 4.5, lcMin: 60),
  ];
  for (final Stock s in Stock.values) {
    // Resting label AAA (read during a shutdown). Lit label AA / Lc 45: a 1-3s
    // transient on a label just read — identifiable, not readable. Stated here so
    // nobody "fixes" it to 7.0 and flattens the lit state.
    p.add((what: 'ink/${s.name}', fg: t.inkOn(s), bg: t.stock(s), wcagMin: 7.0, lcMin: 60));
    p.add((what: 'ink/${s.name}-lit', fg: t.inkOn(s, lit: true),
           bg: t.stockLit(s), wcagMin: 4.5, lcMin: 45));
  }
  return p;
}

void main() {
  test('APCA implementation matches published reference pairs', () {
    expect(_apca(const Color(0xFF888888), const Color(0xFFFFFFFF)), closeTo(63.1, 0.1));
    expect(_apca(const Color(0xFFFFFFFF), const Color(0xFF888888)), closeTo(-68.5, 0.1));
    expect(_apca(const Color(0xFF000000), const Color(0xFFAAAAAA)), closeTo(58.1, 0.1));
    expect(_wcag(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21.00, 0.01));
  });

  for (final AacTheme t in kAllThemes) {
    group(t.name, () {
      // 1. CONTRAST. WCAG is the compliance floor, APCA the instrument. BOTH.
      for (final Pair p in _pairs(t)) {
        test('contrast ${p.what}', () {
          expect(p.fg.a, 1.0, reason: 'contrast is undefined for a translucent fg');
          expect(p.bg.a, 1.0);
          expect(_wcag(p.fg, p.bg), greaterThanOrEqualTo(p.wcagMin));
          expect(_apca(p.fg, p.bg).abs(), greaterThanOrEqualTo(p.lcMin));
        });
      }

      // 2. GRAYSCALE — the channel the corpus never had. Independently catches the
      // isoluminant collapse, the chroma press flood, and any future chroma-only
      // signal: the entire class of bug this system keeps being offered.
      test('lit state and focus ring survive grayscale', () {
        for (final Stock s in Stock.values) {
          expect(_wcag(_gray(t.stockLit(s)), _gray(t.stock(s))), greaterThanOrEqualTo(1.30),
              reason: '${s.name}: lit is chroma-only and vanishes in grayscale');
        }
        expect(_wcag(_gray(t.focus), _gray(t.ground)), greaterThanOrEqualTo(3.0));
      });

      // 3. EDGE FINDABILITY. NOT a WCAG rule, deliberately not named like one.
      // SC 1.4.11 exempts a control identified by its own text label — a phrase
      // tile carries a 7:1 label, so it is self-identifying and the edge is not
      // compelled. Asserting 3:1 would force a hard rule around all 12 tiles,
      // which IS the 2014 enterprise grid. max() lets the design choose which of
      // fill or keyline carries the edge, requiring only that one does. DO NOT
      // "fix" this to 3.0.
      test('edge findability', () {
        final double floor = t.usesStocks ? 1.5 : 3.0;
        for (final Stock s in Stock.values) {
          expect(math.max(_wcag(t.stock(s), t.ground), _wcag(t.keyline, t.stock(s))),
              greaterThanOrEqualTo(floor));
        }
      });

      // 4. THE PALETTE CONTRACT.
      test('stocks are staggered in lightness, never isoluminant', () {
        if (!t.usesStocks) return;
        final List<double> ls =
            t.stocks.map((Color c) => c.computeLuminance()).toList()..sort();
        expect(ls.last - ls.first, greaterThan(0.02), reason: 'stagger collapsed');
      });
      test('lerp is a hard cut, never a mix', () {
        final AacTheme o = kAllThemes.firstWhere((AacTheme x) => x != t);
        for (final double x in <double>[0, 0.25, 0.49, 0.5, 0.75, 1.0]) {
          expect(identical(t.lerp(o, x), t) || identical(t.lerp(o, x), o), isTrue);
        }
      });
      test('geometry floors hold', () {
        expect(Geom.gapColumn, greaterThanOrEqualTo(12.0));
        expect(Geom.gapRow, greaterThan(Geom.gapColumn),
            reason: 'equal gutters read as a table, not a page');
        expect(Geom.innerRadius(Geom.tileRadius, 12), 8.0);
        expect(Geom.hairline(3.0), closeTo(0.333, 0.001));
      });
    });
  }
}
```

**Two widget tests carry the rest** — where the real MVP bugs are, and neither needs a PNG to bless:

```dart
// GEOMETRY: the honest resolution of "76dp floor" vs "200% TextScaler".
for (final double scale in <double>[1.0, 1.15, 1.3, 1.6, 2.0]) {
  testWidgets('every starter label fits at ${scale}x in its default layout', (t) async {
    await t.pumpWidget(board(textScaler: TextScaler.linear(scale)));
    expect(t.takeException(), isNull);                      // no RenderFlex overflow
    for (final label in kStarterPhrases.map((p) => p.label)) {
      expect(linesOf(t, label), lessThanOrEqualTo(Geom.maxLabelLines));
    }
  });
}
// TRAVERSAL: assert sortKey order == PRIORITY order, not layout order (§3.8).
testWidgets('traversal follows priority, not the lower-centre arc', (t) async {
  await t.pumpWidget(board());
  expect(semanticsOrderOf(t), equals(kStarterPhrases.map((p) => p.label).toList()));
});
```

**Golden tests are a trap here.** 4 palettes × 5 text scales × 2 modes = 40 PNGs, every one invalidated by any padding change, reviewed by a human eyeballing 40 diffs — the review that does not happen at 11pm in week 2. Worse, **a golden cannot assert anything**: one that renders unreadable grey-on-grey passes forever once blessed. Ship **4 goldens total** (one per palette, TextScaler 1.0, grid only) as a coarse did-I-catastrophically-break-layout tripwire. Use **`alchemist`** (Betterment) — `golden_toolkit` is **discontinued**, despite what the tutorials still say.

**The one question that gates every design decision**, because it is the one the corpus never asked:

> **Does this still work for someone who cannot see colour, is at 200% text, and is driving the app with one switch at one second per step?**

Answer it honestly and the isoluminant tiles, the chroma press flood, the ghost line, the 76dp floor, and the row-major traversal order all fall out in the same motion.

---

## 11. The "looks dated" audit

Run against every screen. Most of it is greppable, which is the point — a taste checklist nobody can run is a wish.

| # | tell | check |
|---|---|---|
| 1 | corner radius < 16dp on an element > 60dp | **the** tell. 4dp on a 105dp tile is 2014, full stop. |
| 2 | `elevation:` > 0, or any `BoxShadow` | `grep -rn 'elevation:\|BoxShadow' lib/` |
| 3 | grey umbra on a **pure-grey** surface | the real M2 tell — not the existence of a shadow |
| 4 | the M2 500-series hexes | `grep -rn '2196F3\|4CAF50\|F44336\|007BFF' lib/` |
| 5 | pure `#FFFFFF` / `#808080` / `#000000` outside HC | `grep -rn '0xFFFFFFFF\|0xFF000000\|0xFF808080' lib/` |
| 6 | `letterSpacing` left at 0 above 17pt | Flutter's default is calibrated for ~14pt; doing nothing is doing the wrong thing |
| 7 | weight < 400 anywhere; or centred display type | the Roboto Light / Helvetica UltraLight hangover |
| 8 | type-size spread < 3:1 across the app | ours is 15→140 = 1:9.3 |
| 9 | a 1px divider between siblings | 2026 separates with **space** and tonal steps |
| 10 | `ContinuousRectangleBorder` | `grep -rn 'ContinuousRectangleBorder' lib/` — banned (§3.2) |
| 11 | `Border.all()` | 1.0 *logical* px = 3 physical. `grep -rn 'Border.all(' lib/` |
| 12 | 2-stop lightness-ramped top-to-bottom gradient | banned outright (§7) |
| 13 | `BackdropFilter` / `Opacity` widget / `ShaderMask` | `grep -rn 'BackdropFilter\|Opacity(\|ShaderMask' lib/` |
| 14 | Corporate Memphis / Alegria illustration | peaked 2019–21, now actively derided |
| 15 | uniform density — identical padding everywhere, one 8dp grid | ours is deliberately 14/22 |
| 16 | any `Icon` from a font | there are no icons (§8) |
| 17 | any ALL-CAPS label | shouting (§2.4) |
| 18 | a straight apostrophe in a shipped string | `grep -rn "'" lib/data/starter_phrases.dart` |
| 19 | the FAB + hamburger + 4dp AppBar shadow triad | one screen; none exist |
| 20 | a splash screen, an onboarding carousel, a "what's new" | it opens to the grid or it is deleted |

---

## 12. Banned — permanent, visual, checkable

**The wedge.** Cartoon avatars · mascots · animal characters · puzzle-piece iconography · gamification · streaks · badges · confetti · encouragement copy · "Great job" · any parent/caregiver framing · parental gates · PINs · locked settings · superhero motifs (the *child* market's answer to prosthetics — the mascot ban in a cooler jacket).

**Surface.** Translucency · blur · `BackdropFilter` · Liquid Glass · glassmorphism · neumorphism · drop shadows · `elevation:` · bevels · long shadows · gradients of any kind · grain/noise · mesh gradients · dividers · pure zero-chroma neutrals outside HC.

**Motion.** All of it. Ink ripples · page transitions · theme crossfades · shape morphs · spring physics · M3E's motion system. `MediaQuery.disableAnimationsOf` → `Duration.zero`; `splashFactory: NoSplash.splashFactory`; `themeAnimationStyle: AnimationStyle.noAnimation`. When `material_ui` eventually ships M3E these arrive as tempting defaults with possibly no opt-out flag — **verify at migration time, do not assume.**

**Structure.** Reflow of any kind · scrolling in the grid · auto-shrink / `FittedBox` on a tile · ellipsis on an utterance · variable tile size · bento · non-uniform row heights · context-dependent chrome · anything that appears, vanishes, collapses, or expands. Free non-clinical corroboration, from NN/g on the Microsoft adaptive-menus precedent: *"People hated them because nothing stayed where you left it."*

**Adaptation.** No distress auto-detection. No automatic personalisation. No adaptive layout. No usage-based reordering. 6/12 participants rejected automatic personalisation harder than any other feature tested, and one went further than opt-out — the mere *presence* of the knob was objectionable. **Do not ship distress auto-detection even switched off by default.**

**Tone.** Never narrate the user's emotional state ("Feeling overwhelmed?" — the app does not know, and guessing is presumptuous). The app never says "we." Errors state the fact then the next action, never an apology (an apology implies the user needs soothing — the parental register through the back door). No ellipses in errors. No questions where a statement will do. Never "just" or "simply." Second person, present, active. ≤8 words on the main surface. **No error is ever a modal dialog** — a modal during a shutdown demands a decision from someone whose decision-making is exactly what is impaired, and blocks the one screen they opened the app to use.

**Killed by this document, with the reason recorded so it is not relitigated:**

| killed | why |
|---|---|
| STOP / reserved red | it is a cancel; ISO 13850 refuted; designs for a bystander's fear (§5) |
| `Yours.` byline on edit | a gold star with better kerning |
| "Most people replace half of them in the first week" | pre-authorising the user is the parental register in indie clothes |
| "Text is large. Switch to 6 tiles?" | the app noticing something about you and offering an accommodation (§3.4) |
| the attention button (flashlight strobe) | a *look at the disabled person* button, and a photosensitive-seizure risk |
| the ghost line | 3.94:1 on `oxblood`; Lc −39.0 on ground (§3.4) |
| isoluminant tiles | deutan ΔE 1.06 (§1.4) |
| chroma-only press flood | 1.015:1 in grayscale (§3.5) |
| grain | a flat dyed field is better (§4.4) |
| non-uniform row heights / bento | encodes our hierarchy into their vocabulary (§4.4) |
| `dynamic_color` / Material You | an untestable palette (§1.6) |
| `google_fonts` | it is a network call (§2.2) |
| the 76dp floor | invented; and at 200% it is the wrong constraint (§3.1) |

**Never claim, in store copy or settings:** that Atkinson Hyperlegible is "scientifically proven" (no independent peer-reviewed validation exists); that Google verified our privacy (Play's Data Safety card is developer *self-declared* — only the manifest-derived permissions list is a fact, and *that* is the one to point at); or any number from Google's M3 Expressive marketing. The "4×" is an "up to" best case for one Send button. The peer-reviewed aggregate is **33% faster fixation, 20% faster task completion, n=48** (Bentley et al., CHI '26, DOI 10.1145/3772318.3790373), and its causal story — bigger targets, stronger colour differentiation, back to fundamentals — merely confirms constraints this app already held. **We are not designing from it.** Nothing in this document rests on it, and that is a stronger position than a citation we cannot defend.
