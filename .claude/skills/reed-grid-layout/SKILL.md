---
name: reed-grid-layout
description: Reed's board plane — the fixed 3x4 grid, unequal 14dp/22dp gutters, 24dp side margin, full-bleed edge-to-edge, and the type-to-speak field as the 13th cell. Use when editing BoardScreen, writing GridView/Wrap/LayoutBuilder, setting mainAxisSpacing/crossAxisSpacing/padding/spacing, touching Geom.gapColumn/gapRow/margin/fieldHeight, handling SafeArea/MediaQuery.viewInsets/resizeToAvoidBottomInset, or changing rows, columns, or where a phrase sits. Not for a tile's own shape, fill, keyline, or label.
---

# Reed grid layout

The board is a swatch book: twelve chips of dyed paper in fixed order behind a fine keyline. The grid's job is to look composed and to never move.

## Geometry — the numbers, exact

| property | value | token |
|---|---|---|
| layout | uniform **3 x 4** (or **2 x 3**), fixed positions, never reflows | — |
| column gap | **14dp** | `Geom.gapColumn` |
| row gap | **22dp** | `Geom.gapRow` |
| side margin | **24dp** | `Geom.margin` |
| tile radius | **20dp** | `Geom.tileRadius` |
| type field height | **72dp** | `Geom.fieldHeight` |
| background plane | full-bleed, edge-to-edge, under status and nav bars | — |
| grid | inset by `SafeArea` + margin | — |
| dividers | **none** |

Tile size is **not fixed**. It is `(viewport − chrome) / rows`, computed. On a Pixel 8 (393x852) that lands at 105.7 x 138.5dp for 3x4 and 165.5 x 192.0 for 2x3; on a 360x800 phone, 94.7 x 125.5 / 149.0 x 174.7; on a 344x882 cover display, 89.3 x 146.0 / 141.0 x 202.0. Never hardcode a tile dimension and never assert a minimum one — at 200% text scale the label block needs ~124dp against ~125dp of tile, so a size floor is the wrong constraint and would fire exactly where accessibility matters most. The real constraint is that the label fits, and a test asserts that at every text scale.

Never write a spacing value outside the scale `4 · 8 · 12 · 14 · 16 · 22 · 24 · 32 · 48`. It is deliberately non-uniform; uniform density reads 2014.

## Gutters are never equal

14 across, 22 down. Not 16/16, not 18/18, not `spacing: 16`.

Equal gutters in both axes read as a **table**. Unequal gutters read as a **designed page** and group the grid into rows — which is what the eye should find, because a row of tiles sharing a last baseline scans as a line of type. This is the cheapest "composed vs. aligned" move in the system and it costs two integers. Anyone "tidying" them to one constant has deleted the composition.

```dart
// Wrong — reads as a spreadsheet.
GridView.count(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16)

// Right.
GridView.count(
  crossAxisCount: 3,
  crossAxisSpacing: Geom.gapColumn, // 14
  mainAxisSpacing: Geom.gapRow,     // 22
)
```

Note the axis trap: in a vertical `GridView`, `crossAxisSpacing` is the **column** gap (14) and `mainAxisSpacing` is the **row** gap (22). Getting these backwards is silent and looks almost right.

## No dividers — the gap is the design

A divider turns chips into a spreadsheet. Never add one, never add a `Border` between cells, never add a background stripe behind a row.

The gap carries real compositional weight: at 20dp radius with a 14/22dp gap, the negative space where four tiles meet forms a small four-pointed star. On a 3 x 4 grid that shape recurs at each interior junction — six of them — and it is a designed element, not a leftover. Which means the gap:radius ratio is a decision — keep **gap ≈ 0.6–1.1 x radius**. Change the radius and the gaps must be re-picked against that band, or the star degenerates into a slot or a blob.

Depth comes from tonal steps (ground → container → stock → stockLit) and the keyline. Never `BoxShadow`, `elevation:`, `BackdropFilter`, blur, gradients, or grain anywhere in the board. Contrast over uncontrolled content is non-certifiable by construction, which is why translucency is out permanently rather than pending a perf fix.

## Edge-to-edge is forced; the inset is a separate decision

The window is edge-to-edge and there is no opting out: the app targets SDK 36, and apps targeting Android 16 cannot opt out (`windowOptOutEdgeToEdgeEnforcement` is deprecated and disabled). Do not attempt to. Do not add a status-bar scrim.

**The window is edge-to-edge; the targets are inset.** These are never the same question:

- Paint the ground plane full-bleed, behind the system bars — `Scaffold(backgroundColor: theme.ground)` with no `SafeArea` above it.
- Wrap the *content* in `SafeArea`, then add the 24dp margin inside it.

The 24dp margin is a design choice on thumb-ergonomic and edge-slop grounds, **not** a platform requirement. Android's ~20dp back-gesture bands pass taps through unharmed and these tiles are tap-only, so no exclusion rects are needed. If that ever needs revisiting, read `MediaQuery.systemGestureInsets` rather than hardcoding 20dp — and know it reports zero on iOS.

```dart
Scaffold(
  backgroundColor: t.ground,
  resizeToAvoidBottomInset: false, // the grid must not reflow under the IME
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(Geom.margin), // 24
      child: ...,
    ),
  ),
)
```

Use `EdgeInsetsDirectional` wherever a value is start/end-specific so RTL mirrors. `EdgeInsets.all` is fine when all four are equal.

## The type-to-speak field is the 13th cell

Same radius, same keyline, same material, `container` fill, spanning 3 columns, **at the top**, 72dp tall.

This is the answer to "two apps stapled together": the field is not an input bolted onto a grid, it is the grid cell that is blank because you fill it. Build it as a cell of the same layout, not as an `AppBar`, a `bottomSheet`, or a sibling above the grid with its own spacing rules.

**Its position is principled and is not up for relitigation.** The ability to type implies more capacity than the ability to tap. Tiles are for crisis; typing is for when you are okay. Typing therefore earns the **worst** position on the screen. The bonus is that the keyboard then covers the grid while leaving the field visible — which is the correct thing to cover, and only because the field is at the top.

Two rules that are load-bearing, not preferences:

- **Never `autofocus: true`.** A keyboard covering the grid at cold launch is catastrophic for the core use case: someone opens the app mid-shutdown and the twelve phrases they came for are behind an IME.
- **`resizeToAvoidBottomInset: false`.** Keyboard insets must not resize or reflow the grid — reflow breaks the fixed-position guarantee that makes position-as-retrieval work. Do not "fix" the resulting overlap by padding with `MediaQuery.viewInsets.bottom`; the overlap is the design.

Shape the field with `ShapedInputBorder`, which is present in stable and takes the same superellipse the tile uses:

```dart
TextField(
  // no autofocus
  decoration: InputDecoration(
    filled: true,
    fillColor: t.container,
    border: ShapedInputBorder(
      shape: RoundedSuperellipseBorder(
        borderRadius: const BorderRadius.all(Radius.circular(Geom.tileRadius)),
        side: BorderSide(color: t.keyline, width: Geom.hairline(dpr)),
      ),
    ),
  ),
)
```

There is no `RoundedSuperellipseInputBorder` — that name does not exist. `ContinuousRectangleBorder` is banned everywhere: it needs its radius multiplied by ~2.3529 to approximate a squircle, degenerates early at exactly this radius, and centres strokes regardless of `strokeAlign`.

**Do not go bespoke on `TextField`.** Reimplementing IME composition and selection is a multi-month trap. The tile is bespoke; the field is Material. Style it, do not rebuild it.

## Spanning, and the schema

The field is a 3-column cell on day one, so `row_span` / `col_span` exist in the schema and the layout engine must honour them. **Ship uniform anyway.** Never expose span as a phrase property and never render a spanning tile. If a plain `GridView.count` cannot express the field's span cleanly, use a `Column` of the field plus the grid — but keep the field's radius, keyline, fill and the 22dp row gap below it identical to a grid row's, so the seam is invisible.

## Reachability, and why it is not traversal

The lower-centre arc gets the highest-priority phrases: rows 3–4, centre column weighted. Position is authored, fixed forever, and **is** the retrieval mechanism — a user reaches for "I need to leave" by muscle memory, not by reading.

That arc is a thumb optimisation and it **pessimises** screen readers if traversal is inherited from layout. Row-major default order makes the most important tile the 8th-to-11th thing TalkBack reads — 8–11 seconds under Switch Access linear autoscan at 1s/step. Decouple them explicitly:

```dart
Semantics(
  button: true,
  label: tile.label,
  sortKey: OrdinalSortKey(tile.priority.toDouble()), // priority, NOT layout index
  child: ...,
)
```

Never pass the grid index, the row, or the position as the sort key. Lower-centre placement **and** first-in-traversal — the two are independent and both are required.

Empty slots are ground and nothing else: no fill, no keyline, no target, and `ExcludeSemantics` rather than `enabled: false`, so scanners skip them instead of burning a 1s step on nothing. In edit mode they become full targets with keyline, `+`, and full semantics.

## Layout choice: 12 or 6

`Tiles: 12 · 6` is a setting, visible from install, **never prompted**. At first launch only, lay out the longest starter label with a `TextPainter` at the live `textScaler` and pick 6 if it exceeds 3 lines or overflows. Persist it. **Never re-evaluate.** Positions are fixed *within* each map. An app that notices your text is large and offers to help is the parental register in indie clothes.

## Never, and why

| banned | reason |
|---|---|
| non-uniform row heights (76/88/100/112) | encodes our value hierarchy into their vocabulary; day two they replace half the phrases and the ratio is lying |
| bento / visible spans | expressive structure measurably hurts usability when it displaces familiar structure; a bento grid fails catastrophically at its smallest cell under text scale, a uniform grid degrades uniformly |
| grain / noise on the plane | a flat, opaque, dyed field is better; grain is what a designer reaches for when the colour is not trusted |
| scrolling in the grid | pointer-down feedback fires before gesture disambiguation and is only safe because nothing scrolls |
| reflow of any kind | nothing may appear, vanish, collapse, or expand; position is the retrieval mechanism |
| equal gutters | reads as a table |
