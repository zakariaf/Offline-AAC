---
name: reed-colour-system
description: The Reed colour system — the four palettes (paper/ink/hcInk/hcPaper), every role hex, the four stocks and their lit variants, the warm-neutral rule, the ink-luminance cap, and the two-tier contrast floor. Use when typing a hex or Color(0x…) literal, checking WCAG or APCA contrast, picking a stock or category colour, editing tokens.dart or a Prim/role value, choosing a lit or pressed colour, or weighing ColorScheme.fromSeed or dynamic_color.
allowed-tools:
  - Read
  - Edit
  - Grep
  - Bash(python3 *)
---

# Reed colour

Reed is a swatch book: flat, opaque, dyed paper stock behind a fine keyline. Depth comes from **tone and edge only** — never shadow, blur, gradient, or motion. Colour therefore carries more weight here than in an app that can move, and every value below was measured, not chosen by eye.

## Non-negotiables, up front

- **Never type a hex outside `lib/ui/core/tokens.dart`.** It is the only file permitted a colour literal. Every design system that rotted, rotted by someone typing a hex at 11pm. The guard: `! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'`
- **Never invent a hex.** Every value in this skill is measured. To introduce a new pairing, compute it with `scripts/contrast.py` — never estimate, never recall a ratio.
- **Pure `#FFFFFF`, `#808080`, `#000000` are banned outside high contrast.** Zero-chroma neutrals are the cheapest tell that nobody chose anything.
- **There is no red anywhere.** `oxblood` at OKLCH C 0.026 is a stock, not an alarm.
- **Colour is never the only channel.** Position and label carry meaning; hue is a redundant assist.

## The warm neutral rule

Every neutral carries hue: the ramp runs **OKLCH hue 65–85, chroma 0.006 → 0.012, chroma rising with lightness**. Chroma must rise with lightness — shadows desaturate, and flat chroma across the ramp is what makes warm darks read as muddy brown.

Warm both ink and paper from **one hue**. Do not warm only the ink — ink and paper derive from one neutral hue at different tones, as Material's own neutrals do. Warm reads as lamplight and paper; cool reads as screen. For an app opened during a shutdown, that connotation is the product.

## Palettes: four, switcher shows three

`enum AacPalette { paper, ink, hcInk, hcPaper }`. The switcher cycles **`paper → ink → high contrast → paper`** — three positions. HC polarity is a set-once settings preference (`ink` default), never a fourth cycle position: a shutdown user needs one tap to produce one predictable next state.

### `ink` (dark) and `paper` (light)

| role | `ink` | on ground | `paper` | on ground |
|---|---|---|---|---|
| `ground` | `#171411` | — | `#F4F2EE` | — |
| `container` (type field) | `#25211D` | 1.15:1 | `#E5E3DD` | 1.15:1 |
| `ink` | `#DCD9D3` | **13.03:1 / Lc −82.9** | `#27221D` | **14.09:1 / Lc +95.1** |
| `inkDim` (chrome only) | `#AEAAA4` | 7.94:1 / −55.7 | `#5A544E` | 6.68:1 / +78.3 |
| `keyline` | `#8A857F` | 5.02:1 | `#6F6A64` | 4.79:1 |
| `focus` | `#FFD9A0` | 13.70:1 | `#7A4A05` | 6.69:1 |

**`inkDim` is never a tile label.** Lc −55.7 is correctly rated secondary by APCA even though WCAG blesses it at 7.94:1. Chrome only.

Light polarity keeps two moves, and the second is the one people skip: the ground is `#F4F2EE`, not `#FFFFFF` (uncoated paper), **and the ink is `#27221D`, not `#000000`**. Pure black on near-white is the clinical signal; warm-black on warm paper is letterpress. It costs nothing legible — Lc +95.1 exceeds the Lc 90 "preferred for fluent text" bar.

### High contrast — warm, for 1.8%

| palette | ink | ground | WCAG | APCA | focus |
|---|---|---|---|---|---|
| `hcInk` | `#FFFCF7` | `#0B0906` | **19.43:1** | −106.0 | `#FFD9A0` (14.85:1) |
| `hcPaper` | `#0B0906` | `#FFFCF7` | **19.43:1** | +104.2 | `#5C3300` (10.64:1) |

Pure `#FFF`/`#000` scores 21.00:1 / Lc ±107.9; warm scores 19.43:1 / ±106.0 — **1.9 Lc out of 108, a 1.8% delta.** HC stays recognisably the same app for a rounding error. But HC is a medical accommodation: if a user reports warm HC insufficient, ship a pure `#FFF`/`#000` escape hatch and do not argue.

**HC drops the stocks entirely** (`usesStocks: false`). At 19.43:1 the ink cannot afford a tinted ground, and a tone step is exactly what an HC user cannot perceive. The keyline goes to **3dp** and *is* the tile; the lit state becomes a **full inversion** — the only signal available at that contrast, and the user opted in.

**`MediaQuery.highContrastOf` is iOS-only and always false on Android.** The in-app switcher is not a convenience — it is the only mechanism that works on the target platform. Read the flag opportunistically, never gate on it. Persist the choice and restore it **before first paint**: a flash of the wrong polarity is a sudden luminance change, the exact event the animation ban exists to prevent.

## The ink-luminance cap

**Cap on-surface text at OKLCH L ≈ 0.885.** `#DCD9D3` is L 0.885 / C 0.009 / H 80. The cost is real: `#FFFFFF` on `#171411` scores 18.35:1 / Lc −107.1 versus `#DCD9D3`'s 13.03:1 / Lc −82.9 — **24 Lc, 23% of perceptual contrast, spent to eliminate halation bloom.** Affordable because −82.9 still clears the Lc 75 body-text floor and WCAG AAA with room.

**Halation is solved with ink luminance, never weight.** Heavier glyphs at high luminance contrast bloom *more*, not less; and `wght` changes advance widths, which could re-wrap a label between palettes — and reflow is banned. **Hold type weight identical across all four palettes.** Only the platform `boldText` flag moves weight.

## The four stocks

Four, not twelve. Named, not numbered. Staggered in lightness **on purpose**. `enum Stock { oxblood, slate, tan, fir }`, L-ascending.

| stock | dark | L / C / H | ink on it | lit | ink on lit |
|---|---|---|---|---|---|
| `oxblood` | `#2A1A1D` | 0.240 / 0.026 / 8° | 11.80:1 / −81.8 | `#413033` | 8.79:1 / −77.4 |
| `slate` | `#152C42` | 0.285 / 0.050 / 250° | 10.14:1 / −79.7 | `#2C435B` | 7.23:1 / −73.5 |
| `tan` | `#4B2E14` | 0.330 / 0.058 / 60° | 8.77:1 / −77.2 | `#65462C` | 6.05:1 / −69.5 |
| `fir` | `#2E473F` | 0.375 / 0.034 / 172° | 7.14:1 / −73.2 | `#466057` | 4.85:1 / −64.4 |

| stock | light | L | ink on it | lit | ink on lit |
|---|---|---|---|---|---|
| `oxblood` | `#DDACB3` | 0.791 | 7.97:1 / +62.5 | `#C19299` | 5.88:1 / +48.7 |
| `slate` | `#B3CAE2` | 0.830 | 9.35:1 / +70.6 | `#99AFC6` | 6.98:1 / +56.1 |
| `tan` | `#F2CCAF` | 0.870 | 10.53:1 / +77.1 | `#D6B194` | 7.93:1 / +62.2 |
| `fir` | `#CCE9DF` | 0.910 | 12.22:1 / +85.9 | `#B1CDC3` | 9.30:1 / +70.3 |

The lit variant is the stock stepped **OKLCH L ±0.09 toward the ink** — a luminance step, never a chroma flood.

### The stagger is the colourblind fix

Protan/deutan destroy the red–green axis; the surviving blue–yellow axis affords about two hues. **Hue alone therefore cannot separate four muted stocks.** The isoluminant alternative (matched lightness, chroma 0.060) collapses to deutan ΔE ×100 of **1.06** — the same tile twice — and fails at ΔE 4.65 for *normal* vision too. Staggering lightness across the usable window instead gives deutan **7.00** at chroma ≤ 0.058, within reach of Okabe-Ito's 8.0 at a third of the chroma. Reed's measured minimum pairwise OKLab ΔE ×100 (Viénot 1999):

| palette | normal | protan | deutan | grayscale |
|---|---|---|---|---|
| dark stocks | 8.09 | 8.11 | **7.00** | 4.40 |
| light stocks | 8.71 | 7.99 | **6.62** | 3.72 |

The window is narrow and its bounds are named: **OKLCH L 0.240 → 0.375** in dark (range 0.135), bounded above by *ink on stock ≥ 7:1* and below by *stock separable from ground*. Never add a fifth stock or shift one without re-deriving this window — the range is fully consumed.

The same decision is the weave: a grid whose chips differ slightly in lightness reads as woven cloth rather than an institutional board. Accessibility and beauty are the same move here.

**This is not a salience hierarchy, and the distinction is load-bearing.** Four stocks across twelve tiles means each appears about three times, scattered by category, not by rank — ΔL 0.135 over four repeating stocks reads as texture. Making one tile lighter *because it matters more* is banned.

**Category hue is a redundant assist, never the only channel.** Position is the retrieval mechanism and is fixed; the label is always present. That is what makes deutan ΔE 7.00 sufficient rather than a gamble, and what lets HC drop the stocks entirely without breaking findability. Assignment is per-category and stable forever; a category's colour must never imply a category's position.

## The two-tier contrast floor

State it out loud so nobody "fixes" it:

| tier | WCAG | APCA | why |
|---|---|---|---|
| **resting label** | AAA **7:1** | **Lc ≥ 60** | read during a shutdown |
| **lit label** | AA **4.5:1** | **\|Lc\| ≥ 45** | a 1–3s transient the user triggered on a label they just read — must stay *identifiable*, not *readable* |

Do not flatten the lit tier up to 7.0; that erases the lit state, which is the only confirmation a user with motor imprecision gets that their tap landed. Do not relax the resting tier either.

**WCAG is the compliance floor; APCA is the instrument. Check both.** A ratio test alone blesses unreadable text: the rejected "ghost line" passed AA at 5.34:1 while scoring **Lc −39.0** — unreadable — and 3.94:1 on `oxblood`. The rejected chroma-only press state scored **1.02:1** in colour and **1.015:1 in Android's Grayscale colour-correction mode — literally invisible.** Feedback is never single-channel and never chroma-only; Reed's luminance step measures 1.34–1.48:1 and survives grayscale (1.36–1.48:1) and protan (1.34–1.52:1).

Adjacent floors: keyline vs ground ≥ 3:1 / Lc 30; focus ring vs ground ≥ 3:1 / Lc 45.

## The one accent

**The focus ring is the only saturated colour in the app** (`#FFD9A0` amber, `focus` per palette). High-luminance yellow earns its keep exactly once: a focus indicator is supposed to grab, and it is the signal a keyboard or switch user cannot afford to lose. It is not on the primary path — tiles are found by position and hue — so it cannot pull the eye from the lower-centre arc.

**The ring is drawn in the gutter, outside the tile, never on it.** Offset 2dp, width 3dp. Amber recoloured onto the tile's own keyline gives only 2.73:1 on changed pixels, failing the 3:1 requirement; `#FFD9A0` on light paper is **1.20:1**, an invisible ring. In the gutter the changed pixels are `ground → ring`: 13.70:1 (ink), 6.69:1 (paper), 14.85:1 (hcInk), 10.64:1 (hcPaper) — and it never touches a fill, so no per-stock verification is needed.

## Show mode

The poster is **light polarity always, regardless of theme**: ground `#FFFCF7`, ink `#1A140D` (**17.85:1 / Lc +103.3**), standing line `#5A544E` (7.29:1 / Lc +84.3). Warm ink on warm paper costs 2.7 Lc against pure `#000`/`#FFF` — affordable, because anything past Lc 90 is beyond the fluent-reading bar. A stranger reads this at arm's length in daylight; that is why it inverts.

## Hand-author the `ColorScheme`

**Never `ColorScheme.fromSeed`.** Its `tonalSpot` scheme pins neutral chroma at HCT 4 and derives hue from the seed — a machine for producing the generic Material look. Worse, **its per-role overrides are applied post-hoc and do not propagate**: overriding `surface` does not regenerate `surfaceContainerHigh`, which stays seed-derived. "Seed + override" means owning the ~9 roles chosen *and* every seam with the ~38 not chosen. Hand-author it, and keep the M3 role names so Material's `TextField` themes correctly with zero fighting.

**`dynamic_color` is rejected.** Wallpaper-derived palettes are untestable at build time — every guarantee the CI contrast gate provides evaporates the moment the palette is computed on-device from an image nobody has seen. And colours that shift when the user changes their wallpaper break the position/colour learning the product rests on. **Colour stability is part of the retrieval mechanism.**

## Token naming

Primitives are `<family><tone>` where tone is a **measured** OKLCH lightness — `inkT89`, `oxbloodT24`, `amberT88`. The name then stays true forever and inverts correctly across palettes by construction.

Banned naming, with the reason each dies:

| banned | why |
|---|---|
| `grey700` | rank scales have no room for insertion, and "500 is the main one" is a lie in dark mode |
| `colorDarkGrey` | appearance names invert catastrophically — `darkGrey` is the *lightest* colour in dark mode |
| `brandPrimary` | dies with the brand |

The semantic tier is `AacTheme extends ThemeExtension<AacTheme>`, reached via `AacTheme.of(context)`, which **asserts rather than falling back** — a `?? AacTheme.fallback()` would silently ship a palette no test has verified. Read stocks through `stock(Stock s)` / `stockLit(Stock s)` / `inkOn(Stock s, {bool lit})`, never by indexing the list directly: those accessors are what make HC's `usesStocks: false` collapse work.

**`lerp` is a step function**, because animation is banned: `t < 0.5 ? this : (other ?? this)`. Not `return this` — if a palette change ever did animate, `this` would never arrive at the new palette.

## Checking a pairing

Never hand-math a ratio and never recall one. Run:

```bash
python3 .claude/skills/reed-colour-system/scripts/contrast.py '#DCD9D3' '#171411'
python3 .claude/skills/reed-colour-system/scripts/contrast.py '#DCD9D3' '#466057' --tier lit
python3 .claude/skills/reed-colour-system/scripts/contrast.py --selftest
```

It prints the WCAG ratio and APCA Lc, checks both against the named tier (`resting` default, `lit`, `ring`, `chrome`), and exits non-zero on FAIL. `--selftest` validates the implementation against published reference pairs (`#000`/`#FFF` = 21.00, `#E0E0E0`/`#000` = 15.91, APCA `#888`-on-`#FFF` = 63.1) before any number is trusted.
