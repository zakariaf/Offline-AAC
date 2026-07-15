# E02-T01 — Colour tokens and the four palettes

| | |
|---|---|
| **Epic** | E02 — Design system in code |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E01-T01 |
| **Blocks** | E02-T03 |

**Skills:** `reed-colour-system` · `reed-theming-code`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Every colour a user in a shutdown will ever see comes out of one file. If a hex is transcribed one digit wrong, no one finds out — there is no telemetry, and the person who cannot read the label is the person who cannot report it. This task lands all four palettes as measured tokens, verified by the contrast script rather than by eye, so that every later widget reads a value that has already been proven against the two-tier floor.

## Scope

Create `lib/ui/core/tokens.dart`. It is the **only** file in the repo permitted a `Color(0x…)` literal. Two tiers live here: `Prim` (primitives) and `AacTheme` (semantic). This task delivers the values and the four palette instances; the `ThemeData` wiring, the switcher, and persistence are **out of scope** (E02-T03 and later).

### Enums

```dart
enum AacPalette { paper, ink, hcInk, hcPaper }
enum Stock { oxblood, slate, tan, fir } // L-ascending, not alphabetical
```

### `Prim` — primitives, named `<family><tone>` where tone is measured OKLCH L ×100

`Prim.inkT89` is `#DCD9D3` at L 0.885. `Prim.oxbloodT24` is `#2A1A1D` at L 0.240. `Prim.tanT33` is `#4B2E14` at L 0.330. `Prim.amberT88` is the focus amber. Derive every other primitive's name the same way from the measured L in the tables below — do not guess a tone number, and put the L/C/H in a comment beside each.

Banned names, no exceptions: `grey700` (rank scales have no room for insertion, and "500 is the main one" is a lie in dark mode), `colorDarkGrey` (`darkGrey` is the *lightest* colour in dark mode), `brandPrimary` (dies with the brand).

### The role hexes — `ink` (dark) and `paper` (light)

| role | `ink` | on ground | `paper` | on ground |
|---|---|---|---|---|
| `ground` | `#171411` | — | `#F4F2EE` | — |
| `container` (type field) | `#25211D` | 1.15:1 | `#E5E3DD` | 1.15:1 |
| `ink` | `#DCD9D3` | 13.03:1 / Lc −82.9 | `#27221D` | 14.09:1 / Lc +95.1 |
| `inkDim` (chrome only) | `#AEAAA4` | 7.94:1 / −55.7 | `#5A544E` | 6.68:1 / +78.3 |
| `keyline` | `#8A857F` | 5.02:1 | `#6F6A64` | 4.79:1 |
| `focus` | `#FFD9A0` | 13.70:1 | `#7A4A05` | 6.69:1 |

### High contrast

| palette | ink | ground | WCAG | APCA | focus |
|---|---|---|---|---|---|
| `hcInk` | `#FFFCF7` | `#0B0906` | 19.43:1 | −106.0 | `#FFD9A0` (14.85:1) |
| `hcPaper` | `#0B0906` | `#FFFCF7` | 19.43:1 | +104.2 | `#5C3300` (10.64:1) |

`hcInk` / `hcPaper` set `usesStocks: false`, `keylineWidth: 3.0`, and fill `stocks` with `[ground × 4]` and `stocksLit` with `[ink × 4]` — the keyline *is* the tile and the lit state is a full inversion. `kPaper` / `kInk` set `usesStocks: true`.

### The four stocks and their lit variants — both polarities

Dark (`ink` palette):

| stock | dark | L / C / H | ink on it | lit | ink on lit |
|---|---|---|---|---|---|
| `oxblood` | `#2A1A1D` | 0.240 / 0.026 / 8° | 11.80:1 / −81.8 | `#413033` | 8.79:1 / −77.4 |
| `slate` | `#152C42` | 0.285 / 0.050 / 250° | 10.14:1 / −79.7 | `#2C435B` | 7.23:1 / −73.5 |
| `tan` | `#4B2E14` | 0.330 / 0.058 / 60° | 8.77:1 / −77.2 | `#65462C` | 6.05:1 / −69.5 |
| `fir` | `#2E473F` | 0.375 / 0.034 / 172° | 7.14:1 / −73.2 | `#466057` | 4.85:1 / −64.4 |

Light (`paper` palette):

| stock | light | L | ink on it | lit | ink on lit |
|---|---|---|---|---|---|
| `oxblood` | `#DDACB3` | 0.791 | 7.97:1 / +62.5 | `#C19299` | 5.88:1 / +48.7 |
| `slate` | `#B3CAE2` | 0.830 | 9.35:1 / +70.6 | `#99AFC6` | 6.98:1 / +56.1 |
| `tan` | `#F2CCAF` | 0.870 | 10.53:1 / +77.1 | `#D6B194` | 7.93:1 / +62.2 |
| `fir` | `#CCE9DF` | 0.910 | 12.22:1 / +85.9 | `#B1CDC3` | 9.30:1 / +70.3 |

The lit variant is the stock stepped **OKLCH L ±0.09 toward the ink** — a luminance step, never a chroma flood. Order `stocks` and `stocksLit` by `Stock.index` so `stocks[Stock.tan.index]` is correct.

### Show mode tokens

Poster is light polarity always, regardless of palette — set the same values in all four palettes: `showGround` `#FFFCF7`, `showInk` `#1A140D` (17.85:1 / Lc +103.3), `showStandingLine` `#5A544E` (7.29:1 / Lc +84.3).

### `AacTheme extends ThemeExtension<AacTheme>`

Fields, exactly: `ground`, `container`, `ink`, `inkDim`, `keyline`, `focus`, `stocks`, `stocksLit`, `showGround`, `showInk`, `showStandingLine`, `keylineWidth`, `keylineLitWidth`, `usesStocks`. Carry `palette` so `Brightness` can be derived downstream. `copyWith` is mandatory — it is an abstract interface member and omitting it will not compile.

```dart
// A step function on purpose. Animation is banned, so there is nothing to
// interpolate. Deliberately not `return this`: if a theme change ever did
// animate, `this` would never arrive at the new palette.
@override
AacTheme lerp(covariant AacTheme? other, double t) => t < 0.5 ? this : (other ?? this);

static AacTheme of(BuildContext context) {
  final AacTheme? t = Theme.of(context).extension<AacTheme>();
  assert(t != null, 'AacTheme missing. Build ThemeData via aacThemeData().');
  return t!;
}

Color stock(Stock s)    => usesStocks ? stocks[s.index]    : ground;
Color stockLit(Stock s) => usesStocks ? stocksLit[s.index] : ink;
Color inkOn(Stock s, {bool lit = false}) => usesStocks ? ink : (lit ? ground : ink);
```

No `AacTheme.fallback()` and no `?? fallback` in `of` — that silently ships a palette no test has verified.

Export the four instances `kPaper`, `kInk`, `kHcInk`, `kHcPaper`, plus `const kAllThemes = <AacPalette, AacTheme>{…}` (all four entries) so tests can iterate every palette.

### Verification, not transcription

Every pairing in this file gets checked by the script that ships with the colour skill, never hand-mathed and never recalled:

```bash
python3 .claude/skills/reed-colour-system/scripts/contrast.py --selftest
python3 .claude/skills/reed-colour-system/scripts/contrast.py '#DCD9D3' '#171411'
python3 .claude/skills/reed-colour-system/scripts/contrast.py '#DCD9D3' '#466057' --tier lit
```

Run `--selftest` first — it validates the implementation against published reference pairs (`#000`/`#FFF` = 21.00, `#E0E0E0`/`#000` = 15.91, APCA `#888`-on-`#FFF` = 63.1) before any number is trusted. Tiers: `resting` (default), `lit`, `ring`, `chrome`. Non-zero exit is a FAIL.

Pairings to run, at minimum: ink-on-ground for all four palettes (`resting`); ink-on-each-stock, both polarities (`resting`, 8 pairs); ink-on-each-stock-lit, both polarities (`lit`, 8 pairs); keyline-on-ground both polarities (`chrome`, ≥ 3:1 / Lc 30); focus-on-ground all four (`ring`, ≥ 3:1 / Lc 45); `showInk` and `showStandingLine` on `showGround`.

### Out of scope

`aacThemeData()` / the hand-authored `ColorScheme` / `themeAnimationStyle` / splash suppression (E02-T03). The palette switcher, persistence, and restore-before-first-paint. The CI contrast gate as a test file — this task runs the script by hand; wiring it into CI is later work. Any widget that consumes these tokens.

## Acceptance criteria

- [ ] `python3 .claude/skills/reed-colour-system/scripts/contrast.py --selftest` exits 0.
- [ ] Every pairing listed under "Pairings to run" exits 0 against its named tier, and the printed WCAG/APCA figures match the tables above.
- [ ] `! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'` exits 0.
- [ ] `grep -rniE '0xFFFFFFFF|0xFF808080|0xFF000000' lib/ui/core/tokens.dart` returns only lines inside `kHcInk`/`kHcPaper` — and after this task, returns nothing at all, since even HC is warm (`#FFFCF7` / `#0B0906`).
- [ ] `grep -rniE 'fromSeed|dynamic_color|DynamicColorBuilder|CorePalette' lib/ pubspec.yaml` returns nothing.
- [ ] A test asserts `kAllThemes.length == 4` and that every `AacPalette` value is a key.
- [ ] A test iterates `kAllThemes` and asserts, for each: `stocks.length == 4`, `stocksLit.length == 4`, and no field is null.
- [ ] A test asserts `kHcInk.usesStocks == false`, `kHcInk.keylineWidth == 3.0`, and that `kHcInk.stock(Stock.tan) == kHcInk.ground` and `kHcInk.stockLit(Stock.tan) == kHcInk.ink` for all four `Stock` values.
- [ ] A test asserts `kInk.lerp(kPaper, 0.0) == kInk` and `kInk.lerp(kPaper, 1.0) == kPaper` — both endpoints.
- [ ] A test asserts `showGround`/`showInk`/`showStandingLine` are identical across all four palettes.
- [ ] `dart analyze` is clean.

## Traps

- **Transcribing instead of computing.** The hexes here are measured, but a typo is invisible: `#DCD9D3` vs `#DCD9D8` looks the same and no user will report it. The script is the only proof. Run it on the values *as they appear in `tokens.dart`*, not as they appear in this file.
- **Skipping `--selftest`.** A contrast checker that is itself wrong blesses everything. Run it first, every session.
- **Trusting WCAG alone.** A ratio test passes text that is unreadable: the rejected "ghost line" cleared AA at 5.34:1 while scoring Lc −39.0. WCAG is the compliance floor; APCA is the instrument. Check both.
- **"Fixing" the lit tier up to 7:1.** The lit tier is deliberately AA 4.5:1 / |Lc| ≥ 45 — a 1–3s transient on a label the user just read, which must stay *identifiable*, not *readable*. `fir` lit in dark is 4.85:1 / −64.4 and that is correct. Raising it erases the lit state, the only confirmation a user with motor imprecision gets that their tap landed.
- **Using `inkDim` as a tile label.** Lc −55.7 is correctly rated secondary by APCA even though WCAG says 7.94:1. Chrome only.
- **Reaching for pure neutrals in light polarity.** Ground is `#F4F2EE`, not `#FFFFFF`, **and** ink is `#27221D`, not `#000000`. The second move is the one people skip. Lc +95.1 already exceeds the Lc 90 fluent-text bar, so black buys nothing.
- **Warming only the ink.** Ink and paper derive from **one** neutral hue at different tones — OKLCH hue 65–85, chroma 0.006 → 0.012, chroma *rising with lightness*. Flat chroma across the ramp is what makes warm darks read as muddy brown.
- **Making the lit variant a chroma flood.** It is L ±0.09 toward the ink. The rejected chroma-only press state scored 1.02:1 in colour and 1.015:1 in Android's Grayscale colour-correction mode — literally invisible. Reed's luminance step measures 1.34–1.48:1 and survives grayscale and protan.
- **Reordering `Stock` alphabetically.** It is L-ascending on purpose and every `stocks[s.index]` lookup depends on it. The stagger is the colourblind fix: isoluminant stocks collapse to deutan ΔE ×100 of 1.06; Reed's stagger gives 7.00 (dark) / 6.62 (light). Never add a fifth stock or shift one without re-deriving the L 0.240 → 0.375 window — the range is fully consumed.
- **Treating stock lightness as rank.** Four stocks over twelve tiles means each appears ~3 times, scattered by category. Making one tile lighter *because it matters more* is banned.
- **Adding a token to three palettes.** A token set in three of four is a palette-specific crash waiting for the one user who picked the fourth. Set it in all four of `kPaper`, `kInk`, `kHcInk`, `kHcPaper`, and add it to `copyWith` — `lerp` needs no change, that is the point of the step function.
- **A reviewer "fixing" the step-function `lerp`.** It reads as unfinished to anyone who does not know the animation ban exists. Leave the comment. And it is not `return this` — `this` would never arrive at the new palette.
- **Adding a fallback to `AacTheme.of`.** `?? AacTheme.fallback()` silently ships an unverified palette. Loud in debug beats wrong in the field.
- **Reaching for a `Prim.*` from a widget.** A widget that reads `Prim.inkT89` has hardcoded the dark palette. Widgets read the semantic tier only; stocks go through `stock()` / `stockLit()` / `inkOn()`, which is what makes HC's `usesStocks: false` collapse work.
- **A token pipeline.** No DTCG JSON, no Style Dictionary, no codegen, no Figma sync. Those solve a designer/engineer handoff; here they are the same person, and a `node_modules` for ~30 colours buys a build failure mode for a problem that does not exist.

## Files

- `lib/ui/core/tokens.dart` — created. `Prim`, `AacPalette`, `Stock`, `AacTheme`, `kPaper`, `kInk`, `kHcInk`, `kHcPaper`, `kAllThemes`. The only file with a colour literal.
- `test/ui/core/tokens_test.dart` — created. Palette completeness, HC collapse, lerp endpoints, show-mode invariance.

## Done when

`tokens.dart` holds all four palettes with every role, stock, lit variant and show-mode value, the literal-ban grep and `dart analyze` are clean, `tokens_test.dart` passes, and every pairing in the file has been re-verified by `contrast.py` at its named tier rather than trusted from a table.
