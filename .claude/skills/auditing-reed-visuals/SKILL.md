---
name: auditing-reed-visuals
description: 'Runs the "does this look ten years old" audit on Reed''s Flutter UI — radius-to-size ratio, elevation/BoxShadow/Card, Material-2 500-series hexes, pure #FFFFFF/#000000, Divider, Icon fonts, ContinuousRectangleBorder, gradients, BackdropFilter, mascots, streaks. Use when reviewing a widget diff for dated design, checking visual compliance before shipping a screen, or asking whether something looks modern or old. Not for durations, curves, ripples, or splashFactory, and not for choosing type sizes, weights, or tracking.'
allowed-tools:
  - Read
  - Grep
  - Bash(bash *)
---

# Auditing Reed visuals

A taste checklist nobody can run is a wish. Most of this audit is greppable — that is the point. Run the script, then judge the hits and do the eyeball pass the script is honest about not doing.

## Run it

```bash
bash .claude/skills/auditing-reed-visuals/scripts/audit-visuals.sh
```

From the repo root. Scans `lib/` only. Exits 1 on any hit (CI gate), 2 if `lib/` is missing, 0 clean. Output groups findings by tell with `file:line`. A hit is not automatically a defect — it is a place a decision has to exist. Never suppress a hit; resolve it or record why the code is right.

## The tells

| # | tell | verdict |
|---|---|---|
| 1 | corner radius < 16dp on an element > 60dp | **The** tell. 4dp on a 105dp tile is 2014, full stop. |
| 2 | `elevation:` > 0, any `BoxShadow`, any `Card` | Depth is tonal steps and the keyline. Nothing else. |
| 3 | grey umbra on a **pure-grey** surface | The real Material-2 tell — not the mere existence of a shadow. |
| 4 | the M2 500-series hexes: `2196F3` `4CAF50` `F44336` `007BFF` | Stock palette. Ships "I picked the default". |
| 5 | pure `#FFFFFF` / `#808080` / `#000000` outside high contrast | Zero-chroma neutrals are the cheapest tell that nobody chose anything. |
| 6 | `letterSpacing` left at 0 above 17pt | Flutter's default is calibrated for ~14pt. Doing nothing is doing the wrong thing. |
| 7 | `FontWeight` below w400; or centred display type | The Roboto Light / Helvetica UltraLight hangover. |
| 8 | type-size spread < 3:1 across the app | The app runs 15 → 140 = 1:9.3. |
| 9 | a 1px `Divider` between siblings | 2026 separates with space and tonal steps. |
| 10 | `ContinuousRectangleBorder` | Not an iOS-grade squircle. |
| 11 | `Border.all()` | 1.0 *logical* px = 3 physical pixels. |
| 12 | a 2-stop lightness-ramped top-to-bottom gradient | All gradients banned. |
| 13 | `BackdropFilter` / `Opacity(` / `ShaderMask` | Translucency deletes the contrast gate. |
| 14 | Corporate Memphis / Alegria illustration | Peaked 2019–21, now actively derided. |
| 15 | uniform density — identical padding everywhere, one 8dp grid | The spacing scale is deliberately non-uniform: `4 · 8 · 12 · 14 · 16 · 22 · 24 · 32 · 48`. |
| 16 | any `Icon` from a font | There are no icons. Chrome is lowercase words. |
| 17 | any ALL-CAPS label | Shouting. |
| 18 | a straight apostrophe in a shipped string | `I can’t talk` reads as made by a person; `I can't talk.` reads as a database dump. |
| 19 | the FAB + hamburger + 4dp AppBar shadow triad | One screen. None of these exist. |
| 20 | a splash screen, an onboarding carousel, a "what's new" | It opens to the grid or it is deleted. |

## Judging each hit

**Radius (tell 1).** The script flags every radius literal under 16 because it cannot see how big the painted element is. Resolve each by finding the element's size. Correct values: tile and type field **20dp**; focus ring **22dp** (= 20 + 2dp gutter offset); any chip nested inside a tile is **computed** as `outer − padding`, never a constant, or it drifts out of concentricity. Radius-to-size of roughly **1:6** reads 2026 — 8dp reads 2014, 12–16dp reads generic M3 card, a pill wastes corner area. A small radius on a genuinely small element (a 6dp tick, a 24dp affordance) is fine. Absence of a hit proves nothing: a 105dp tile at radius 12 with the value pulled from a token will not grep, so check the ratio by hand on anything large.

Shape is `RoundedSuperellipseBorder` with `strokeAlign: BorderSide.strokeAlignInside`. Reject `ContinuousRectangleBorder` on sight: it needs its radius multiplied by ~2.3529 to approximate a squircle, that multiplier makes it degenerate into a "TIE-fighter" shape *earlier*, and it centres strokes regardless of `strokeAlign` — it fails at exactly the radius this app wants. `figma_squircle` and `smooth_corner` are unnecessary; `RoundedSuperellipseBorder`, `ClipRSuperellipse` and `Canvas.drawRSuperellipse` are all in-toolchain.

**Shadows (tells 2 and 3).** Any `elevation:` or `BoxShadow` is a finding — depth comes from tone and edge, never shadow, blur, or motion. Tell 3 is the sharper diagnosis and needs eyes: a grey umbra sitting on a pure-grey surface is what makes something read Material-2 specifically, rather than merely shadowed. When explaining why a shadow looks dated, name the umbra-on-grey, not the shadow.

**Neutrals (tell 5).** Nothing pure. Every neutral carries hue — the ramp runs OKLCH hue **65–85** with chroma rising from 0.006 to 0.012 as lightness rises. High contrast is **not** an exception that unlocks `#FFF`/`#000`: it uses `#FFFCF7` / `#0B0906`, which score 19.43:1 against pure black-and-white's 21.00:1 — a delta of 1.9 Lc out of 108, or 1.8%, to stay recognisably the same app. `Colors.white` and `Colors.black` are the same defect wearing a Material name. The only legitimate zero-chroma value is fully transparent `Color(0x00000000)` for killing splash and highlight.

Colour literals live in `lib/ui/core/tokens.dart` and nowhere else. Every design system that rotted, rotted by someone typing a hex at 11pm. A literal in a widget file is a finding even when the hex is correct.

**Tracking (tell 6).** The script flags any `fontSize:` above 17 with no `letterSpacing` within ±8 lines. The rule is one line each way: **as size rises, weight falls and tracking tightens.** 20pt → w600 / −0.01em (−0.20); 96pt → w500 / −0.02em; 15pt → w500 / **+0.01em** (chrome tightens *nothing* — small type opens up). Never track below −0.02em: past that the typeface's generous sidebearings stop protecting letter separation, which is the thing being paid for. If the dyslexia-font option is on, drop all negative tracking to 0 — that font's proportions assume default spacing.

**Weight (tell 7).** w500–w600 only. `FontWeight.bold` at poster scale is a defect: bold at 100pt closes the counters, and counter size is a real legibility factor. w500 at poster scale is both prettier and more legible. Set weight with `fontWeight:` alone — never also pass `FontVariation('wght', …)`, which is redundant now that `FontWeight` drives the axis. Hold weight identical across all four palettes; `boldText` is the only thing that moves it. Weight is never the halation fix — heavier glyphs at high luminance bloom *more*, and changing `wght` changes advance widths, which can re-wrap a label between themes, and reflow is banned.

**Centred display type (tell 7) and dividers (tell 9).** Tile labels are `TextAlign.start`, bottom-anchored, with `EdgeInsetsDirectional` — never `TextAlign.left`/`EdgeInsets`, so RTL mirrors. Centred text in a box is the universal signal for "button"; start-aligned text on a baseline is the signal for "page". Dividers turn chips into a spreadsheet — the gap is the design, and it is deliberately unequal: **14dp column, 22dp row, 24dp margin.** Equal gutters read as a table.

**Hairlines (tell 11).** `Border.all()` defaults to 1.0 *logical* px = 3 physical pixels on a 3× phone, which is a rule, not a hairline. Use `1.0 / MediaQuery.devicePixelRatioOf(context)` = 0.333dp on a 3×. A true one-physical-pixel line reads as engraved. High contrast promotes it to a solid **3dp** border, where it stops being decoration and *is* the tile.

**Blur (tell 13).** Ban it on the accessibility argument, which does not decay: contrast over arbitrary content is **non-certifiable by construction** — a ratio cannot be asserted against a background nobody controls, so translucency deletes the contrast gate this whole system rests on. Do not lead with the latency argument; the cited perf issues are closed as fixed and the numbers behind it are unsourced.

## The permanent bans

Never present, never negotiable, in any mode: cartoon avatars · mascots · animal characters · puzzle-piece iconography · rainbow and primary palettes · rounded bubbly type · star, sticker and reward motifs · streaks · badges · progress meters · confetti · "Great job!" · any encouragement copy at all · gamification.

And on the surface: blur / `BackdropFilter` · gradients of any kind · grain and noise · neumorphism · glassmorphism · bevels · long shadows.

The register argument in one line, because a rule whose reason is unknown gets cleaned up by the next reader: an adult buys Field Notes *because it is beautiful*, and it has never once told anyone they are doing a good job. The dignity wedge is not won by subtracting childishness one apology at a time — it is won by asserting a register. A progress meter or a badge is the same defect as a mascot in a cooler jacket. Grain is a special case worth naming: it is not banned on sensory grounds (the contrast cost at 2% is 0.6 of a 13:1 budget, a rounding error) but because a flat, opaque, dyed field is simply better, and grain is what gets reached for when the colour is not trusted.

## What the script cannot check — do this by eye, every time

- **Composition.** Gutter inequality; the small four-pointed star of negative space where four tiles meet (pick the gap-to-radius ratio on purpose, roughly 0.6–1.1×); whether one-line and three-line tiles still share a last baseline so a row scans as a line of type.
- **Colour harmony.** Whether the four stocks still read as woven cloth rather than an institutional board. The lightness stagger is what does that — and it is also the colourblind fix, which is why it must never be flattened.
- **Radius-to-size ratio** on anything the grep missed because the value came from a token.
- **Type-size spread.** Measure it across the whole app, not per screen.
- **Copy register.** No grep catches a sentence that talks down to someone.

## Report findings like this

Group by tell, cite `file:line`, state the verdict and the fix value, and say plainly which tells were checked mechanically and which were judged. Never report a clean script run as "the screen passes the audit" — it passed the greppable half.
