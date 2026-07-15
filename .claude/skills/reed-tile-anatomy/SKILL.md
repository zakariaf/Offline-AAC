---
name: reed-tile-anatomy
description: The phrase tile's interior — RoundedSuperellipseBorder r=20dp, opaque stock fill, 1-physical-px keyline at strokeAlignInside, 16dp inset, bottom-anchored start-aligned 20/w600 label, the says≠label divergence tick, the pointer-down lit state, and the empty slot. Use when building or reviewing the tile widget or its painter, setting a corner radius, Card, elevation, or BoxShadow, wiring lit/pressed feedback, or rendering an unfilled slot. Not for the motion or splash policy behind the press state.
---

# The tile

Twelve chips of dyed paper stock behind a fine keyline. Flat, opaque, still. Depth comes from tone and edge only.

## A chip, not a card

Banned on the tile, permanently: `Card`, `elevation:`, `BoxShadow`, `BackdropFilter`, gradients, grain, bevels, ripple. Shadow + rounded rect + centred content **is** the 2014 enterprise grid — the exact failure mode this design exists to avoid. The depth system is the tonal ladder (`ground → container → stock → stockLit`) plus the keyline. That is the complete list of depth mechanisms.

```
┌──────────────────┐  ← RoundedSuperellipseBorder, r = 20dp
│              ·   │  ← divergence tick (6dp hairline) — only when says ≠ label
│                  │
│ I can’t          │  ← label: start-aligned, BOTTOM-anchored, 20 / w600
│ talk             │     tracking −0.20 / height 1.15 / max 3 lines
└──────────────────┘     16dp inset · 1 physical px keyline
```

| property | value |
|---|---|
| size | **not fixed** — `(viewport − chrome) / rows` |
| radius | **20dp**, `RoundedSuperellipseBorder` |
| fill | full opaque category stock — never translucent |
| keyline | `1.0 / MediaQuery.devicePixelRatioOf(context)` (0.333dp on a 3×), `keyline` colour, `strokeAlignInside` |
| inset | 16dp (`Geom.tileInset`) |
| hit target | the full rect, always — never the painted shape |

`Border.all()` is banned: it defaults to 1.0 *logical* px = 3 physical pixels on a modern phone. That is a rule, not a hairline. A true single-physical-pixel line reads as engraved; anything thicker reads as a table border. In high contrast the keyline is promoted to a solid **3dp** and *is* the tile — the stocks drop out entirely there, so never assume a tinted fill exists.

**There is no 76dp minimum tile size.** If a 76dp floor appears anywhere, delete it. It is invented — it appears in no standard (WCAG 2.5.8 AA is 24×24 CSS px; 2.5.5 AAA is 44×44), it is non-binding because tiles compute to ~89–106 × 125–146dp on real phones, and at 200% text scale it is the wrong constraint because the label block alone needs ~124dp. The real constraint is `tileHeight = (viewport − chrome) / rows`, with a test asserting the label fits at every text scale. A number that only sounds rigorous is worse than no number.

## Shape

```dart
const RoundedSuperellipseBorder(
  borderRadius: BorderRadius.all(Radius.circular(Geom.tileRadius)), // 20.0
  side: BorderSide(color: keyline, width: hairline,
      strokeAlign: BorderSide.strokeAlignInside),
)
```

**`ContinuousRectangleBorder` is banned, and the workarounds with it.** It is not an iOS-grade squircle: its radius must be multiplied by ~2.3529 to approximate one, that multiplier makes it degenerate into a "TIE fighter" *earlier*, and it centres its stroke regardless of `strokeAlign`. The hack fails at exactly the radius wanted here. `figma_squircle` and `smooth_corner` are dead weight — `RoundedSuperellipseBorder`, `ClipRSuperellipse`, and `Canvas.drawRSuperellipse` are first-party with a GPU path in Impeller.

Radius-to-size of roughly **1:6** reads current. 8dp reads 2014; 12–16dp reads generic Material card; a pill wastes corner area. Never `BorderRadius.circular(9999)` for a full round — use `StadiumBorder`; 9999 is a third-party sentinel.

**Concentric by construction.** Any chip nested inside a tile takes `inner = outer − padding`, computed (`Geom.innerRadius`), never a second constant — constants drift apart and the nesting stops looking machined.

Caveat worth knowing: Impeller is default on Android API 29+ and prefers Vulkan; API 28 and below run OpenGL unconditionally, where the RSuperellipse fast path is unmeasured. A disabled-user audience disproportionately carries old hardware, so check raster time on a real API 28 device — but the visual delta versus a plain rounded rect is ~1–2px. Polish, not load-bearing. Never block shipping on it.

## The label

Start-aligned, **bottom-anchored**, 20 / w600 / tracking −0.20 / height 1.15 / max 3 lines.

```dart
// right
Padding(
  padding: const EdgeInsetsDirectional.all(Geom.tileInset),
  child: Align(
    alignment: AlignmentDirectional.bottomStart,
    child: Text(tile.label, textAlign: TextAlign.start, maxLines: 3),
  ),
)

// wrong — pins LTR, breaks Arabic/Hebrew boards
Padding(padding: EdgeInsets.all(16),
  child: Align(alignment: Alignment.bottomLeft,
    child: Text(tile.label, textAlign: TextAlign.left)))
```

Always `TextAlign.start` + `EdgeInsetsDirectional` / `AlignmentDirectional`. Never `.left`, never `EdgeInsets`, so RTL mirrors for free.

Why bottom-anchored, not centred: a swatch chip has its name ranged left at the bottom — that is the reference class. Centred text in a box is the universal signal for "button"; start-aligned text on a baseline is the signal for "page." Bottom-anchoring makes 1-line and 3-line tiles **share their last baseline**, so a row scans as a line of type rather than four unrelated widgets. It also reserves the top-right corner, which the divergence tick needs now and a symbol will need later — a centred label has nowhere to put one without recomposing the tile.

Bottom-anchoring **kills the optical-centring problem outright**, which is why it is not merely taste. The shipped face has `ascent 984` against `capHeight 668` at `upem 1000`: the em box is top-heavy, so mathematically-centred text sits optically low. Anchoring to the bottom means that bug never exists on the tile. (Where optical centring *is* unavoidable, fix it metrically with `TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false, leadingDistribution: TextLeadingDistribution.even)` — never a hardcoded nudge, which breaks at 200% scale and under the alternate-font option.)

One uniform size for all twelve tiles. Variable line count is fine; variable size reads as broken. **Never `FittedBox`, never auto-shrink, never ellipsize.** Auto-shrink is the obvious move and it is backwards: it makes the longest, most complex phrase the smallest, destroys the grid's rhythm, and overrides the user's own `TextScaler` setting. An ellipsis on an AAC utterance is a *different utterance*. `\n` in a shipped label is a hint: honour it, but fall back to natural wrap if scaled text would exceed 3 lines.

Never set the label in `inkDim` — it is chrome-only. Resting label contrast floor is **WCAG AAA 7:1 and APCA Lc ≥ 60**; a ratio test alone will bless text that is unreadable in practice.

## The divergence tick

Each phrase has two fields: `label` (on the tile, hard-capped at 16 characters) and `says` (spoken and postered, uncapped, defaults to `label`). The tile is a **handle** for an utterance, not the utterance — that is what makes "never truncate" safe.

When `says != label`, draw one **6dp hairline tick, top-right, in `keyline`**, and nothing else. `ExcludeSemantics` it — divergence is announced inside the tile's semantics label, never drawn twice. Never render `says` as a second line on the tile: at 60% ink it computes to 3.94:1 on `oxblood` and 4.24:1 on `slate` (both fail AA), and even where it passes AA on `ground` at 5.34:1 it is Lc −39.0, i.e. unreadable. Verification of `says` belongs in edit mode, where nobody is in a shutdown. A chip has a name on it, not a paragraph.

## The lit state — press and speech are one signal

There is **no separate press state**. Pointer-down lights the tile; it stays lit until TTS completes. One state, two triggers: press feedback and the speaking indicator are the same thing.

| | value |
|---|---|
| fill | `stockLit` — OKLCH L ±0.09 toward the ink |
| keyline | 1 physical px → **2dp**, colour → `ink` |
| duration | **zero**; `splashFactory: NoSplash.splashFactory` at the theme root |
| minimum hold | **120ms**, so a fast tap is never imperceptible |
| trigger | `Listener.onPointerDown` — **not** `onTap` |
| order | haptic (`HapticFeedback.selectionClick`) → `setState(lit)` → TTS |

`onTap` fires on pointer *up*, delaying every channel of feedback by the entire press duration. `onPointerDown` plus Android's touch pipeline (~20–40ms) plus one frame (8–16ms) lands feedback at ~30–55ms with no artificial delay. It fires before gesture disambiguation, which is safe **only because the grid never scrolls** — that makes the no-scroll rule load-bearing, not aesthetic. Do not introduce a scrollable ancestor around the grid.

**The lit state is a luminance step, not a chroma flood.** Flooding the tile with accent at matched luminance ("change chroma, hold lightness") computes to 1.02:1 in colour and **1.015:1 under Android's Grayscale colour-correction mode — literally invisible.** A user with motor imprecision mid-shutdown would get no confirmation their tap landed, and silence is the worst bug this app can ship. The luminance step measures 1.34–1.48:1 and survives grayscale (1.36–1.48:1) and protan (1.34–1.52:1). The keyline promotion is a deliberate second, non-chroma channel. **Feedback is never single-channel and never chroma-only.** Expose lit through `Semantics`, never colour alone.

Lit label floor is **WCAG AA 4.5:1 and APCA |Lc| ≥ 45** — lower than resting on purpose: it is a 1–3s transient the user triggered on a label they had just finished reading, so it must stay *identifiable*, not *readable*. Do not "fix" it upward.

**Guard the latch with a timeout that force-clears it.** `flutter_tts` completion-handler reliability varies by OEM; a stuck-lit tile is a lie about what the app is doing, and nobody will ever report it — there is no telemetry and a user who cannot speak does not file bugs.

In high contrast the lit state becomes a full inversion. It is the only signal available at 19.43:1, and the user opted in.

## Focus

The focus ring is drawn **in the gutter, outside the tile, never on it**: offset 2dp, width 3dp, same superellipse at radius **22dp** (= 20 + 2), colour `focus`. Recolouring the tile's own keyline to amber yields 2.73:1 on changed pixels and fails SC 2.4.13's 3:1; ground→ring clears it 6.69–14.85:1 across every palette and needs no per-stock verification because it never touches a fill.

## The empty slot

**Ground. Nothing else.** No fill, no keyline, no target, no ripple, and **no semantics node at all** — `ExcludeSemantics`, not `enabled: false`.

It is not a hole and not broken: it is a socket with nothing installed, which is exactly what it is. The surrounding tiles' keylines define its shape by negative space. An outlined empty slot fails twice at once — it looks like a broken or disabled tile *and* it invites a tap. Excluding it from the semantics tree rather than disabling it means TalkBack and Switch Access **skip** it instead of burning a scan step on nothing; under linear autoscan at 1s/step, every wasted step is real seconds someone spends unable to speak.

**In edit mode the same slot becomes a full target: keyline, a `+`, full semantics.** Make the exclusion mode-dependent, or the editor is unusable by switch access.

## Traversal

Give every tile `sortKey: OrdinalSortKey(tile.priority.toDouble())` — authored from priority, never inherited from layout order. High-value tiles sit in the lower-centre arc for thumb reach, which under Flutter's default row-major traversal makes "I need to leave" the 8th-to-11th thing announced: 8–11 seconds under linear autoscan. `OrdinalSortKey` buys lower-centre placement *and* first-in-traversal for one argument.
