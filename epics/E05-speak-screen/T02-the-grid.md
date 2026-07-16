# E05-T02 — The grid

| | |
|---|---|
| **Epic** | E05 — The speak screen |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E03-T02, E05-T01 |
| **Blocks** | E05-T03, E05-T05, E05-T06, E05-T08, E07-T01 |

**Skills:** `reed-grid-layout` · `reed-tile-anatomy` · `reed-widget-conventions`

> Read these skills first. They carry the exact values this task must hit.

> **Superseded on the no-scroll rule — see EPIC.md "Design update — 2026-07-16".** The plane now reflows to fewer, wider columns as the text size grows and **scrolls vertically** once the taller tiles exceed one screen, so warm labels keep every word instead of being silently clipped. Column count and tile height are measured in `lib/ui/board/responsive_grid.dart`. At the default text size the layout is still the fixed 3-column grid described below; the unequal gutters, no dividers, computed tile size, and `resizeToAvoidBottomInset: false` all stand.

## Why this exists

Position is the retrieval mechanism. A user mid-shutdown reaches for "I need to leave" by muscle memory, not by reading — so the grid's whole job is to look composed and to never move. Anything that reflows, reorders, or shifts a tile by a pixel between launches breaks the one thing the board is for. This task lays the plane the tiles sit on and fixes their positions forever.

## Scope

Build the board plane inside `BoardScreen`: a uniform **3 x 4** grid (or **2 x 3** under the 12/6 layout setting), fixed positions, never reflows.

**Geometry — exact, from `Geom`:**

| property | value | token |
|---|---|---|
| column gap | **14dp** | `Geom.gapColumn` |
| row gap | **22dp** | `Geom.gapRow` |
| side margin | **24dp** | `Geom.margin` |
| tile radius | **20dp** | `Geom.tileRadius` |
| type field height | **72dp** | `Geom.fieldHeight` |
| dividers | **none** | — |

**The gutters are unequal and that is the design.** 14 across, 22 down. Not 16/16, not 18/18, not `spacing: 16`. Equal gutters in both axes read as a **table**; unequal gutters read as a **designed page** and group the grid into rows — which is what the eye should find, because a row of tiles sharing a last baseline scans as a line of type. This is the cheapest "composed vs. aligned" move in the system and it costs two integers. Anyone "tidying" them to one constant has deleted the composition.

```dart
// Wrong — reads as a spreadsheet.
GridView.count(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16)

// Right.
GridView.count(
  crossAxisCount: 3,
  crossAxisSpacing: Geom.gapColumn, // 14 — the COLUMN gap
  mainAxisSpacing: Geom.gapRow,     // 22 — the ROW gap
)
```

Never write a spacing value outside the scale `4 · 8 · 12 · 14 · 16 · 22 · 24 · 32 · 48`. It is deliberately non-uniform; uniform density reads 2014.

**Full-bleed plane, inset targets — never the same question.** Paint the ground full-bleed behind the system bars; inset the *content*.

```dart
Scaffold(
  backgroundColor: t.ground,           // no SafeArea above this
  resizeToAvoidBottomInset: false,     // the grid must not reflow under the IME
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(Geom.margin), // 24
      child: ...,
    ),
  ),
)
```

Edge-to-edge is forced — the app targets SDK 36 and apps targeting Android 16 cannot opt out (`windowOptOutEdgeToEdgeEnforcement` is deprecated and disabled). Do not attempt to. Do not add a status-bar scrim. The 24dp margin is a design choice on thumb-ergonomic and edge-slop grounds, **not** a platform requirement — Android's ~20dp back-gesture bands pass taps through unharmed and these tiles are tap-only, so no exclusion rects. If that ever needs revisiting, read `MediaQuery.systemGestureInsets`; never hardcode 20dp.

Use `EdgeInsetsDirectional` wherever a value is start/end-specific so RTL mirrors. `EdgeInsets.all` is fine when all four are equal.

**No dividers. The gap is the design.** Never a `Divider`, never a `Border` between cells, never a background stripe behind a row. At 20dp radius with a 14/22dp gap, the negative space where four tiles meet forms a small four-pointed star, recurring at each of the six interior junctions of a 3x4 grid — a designed element, not a leftover. The gap:radius ratio is therefore a decision: keep **gap ≈ 0.6–1.1 x radius**. Change the radius and the gaps must be re-picked against that band.

Depth is the tonal ladder (`ground → container → stock → stockLit`) plus the keyline. Never `BoxShadow`, `elevation:`, `BackdropFilter`, blur, gradients, or grain anywhere on the board.

**Tile size is computed, never fixed.** `(viewport − chrome) / rows`. On a Pixel 8 (393x852) that lands at 105.7 x 138.5dp for 3x4 and 165.5 x 192.0 for 2x3; on a 360x800 phone, 94.7 x 125.5 / 149.0 x 174.7; on a 344x882 cover display, 89.3 x 146.0 / 141.0 x 202.0. Never hardcode a tile dimension and never assert a minimum one. There is no 76dp minimum — if a 76dp floor appears anywhere, delete it. At 200% text scale the label block needs ~124dp against ~125dp of tile, so a size floor would fire exactly where accessibility matters most. The real constraint is that the label fits, asserted at every text scale.

**The type-to-speak field is the 13th cell**, and it is E05-T03's build. This task must leave the seam correct for it: same radius, same keyline, same material, `container` fill, spanning 3 columns, **at the top**, 72dp tall. If a plain `GridView.count` cannot express that span cleanly, use a `Column` of the field plus the grid — but keep the field's radius, keyline, fill and the **22dp row gap below it** identical to a grid row's, so the seam is invisible. `row_span` / `col_span` exist in the schema and the layout engine must honour them; **ship uniform anyway** — never expose span as a phrase property, never render a spanning phrase tile.

**Reachability and traversal are independent, and both are required.** The lower-centre arc — rows 3–4, centre column weighted — carries the highest-priority phrases. That is a thumb optimisation and it *pessimises* screen readers if traversal is inherited from layout: row-major default order makes the most important tile the 8th-to-11th thing TalkBack reads, which is 8–11 seconds under Switch Access linear autoscan at 1s/step. Decouple explicitly:

```dart
Semantics(
  button: true,
  label: tile.label,
  sortKey: OrdinalSortKey(tile.priority.toDouble()), // priority, NOT layout index
  child: ...,
)
```

Never pass the grid index, the row, or the position as the sort key.

**Empty slots are ground and nothing else** — no fill, no keyline, no target, and `ExcludeSemantics` rather than `enabled: false`, so scanners skip them instead of burning a 1s step on nothing. Make the exclusion mode-dependent: in edit mode the same slot becomes a full target with keyline, `+`, and full semantics.

**Widget structure.** Each slot is a `StatelessWidget`, not a `Widget _buildTile(...)` method — a method's subtree has no `Element` of its own and `find.byType` cannot reach it. Key each slot `ValueKey((row, col))`; never `GlobalKey`, never `ObjectKey`. Resolve content at tap time from the `(row, col)` primary key, never capture it into a closure at build time.

**Out of scope:** the tile's own interior (shape, fill, keyline, label, divergence tick, lit state) — that is E05-T01 and this task consumes it. The type-to-speak field's construction and IME behaviour — E05-T03. The 12/6 first-launch `TextPainter` decision. Poster mode, edit mode, settings.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] A widget test asserts the rendered grid is exactly 12 slots at 3x4 (and 6 at 2x3), in fixed row-major slot order.
- [ ] A test reads the grid's spacing and asserts `crossAxisSpacing == Geom.gapColumn` (14) and `mainAxisSpacing == Geom.gapRow` (22) — asserting the two are **not** equal to each other, so a "tidy" to 16/16 fails the suite.
- [ ] A test asserts the content padding is `Geom.margin` (24) on all four sides and that the `Scaffold.backgroundColor` is `theme.ground` with no `SafeArea` above it.
- [ ] A test asserts `resizeToAvoidBottomInset == false` on the `Scaffold`.
- [ ] A test pumps at textScaleFactor 1.0, 1.3, 2.0 and asserts no overflow and that every label fits within its tile — with **no** assertion on any tile dimension or minimum size.
- [ ] A test asserts each tile's `SemanticsSortKey` is `OrdinalSortKey(priority)` and that the highest-priority tile is first in traversal, while sitting in rows 3–4.
- [ ] A test asserts an empty slot produces **no** semantics node in speak mode, and a full node in edit mode.
- [ ] A test asserts no `Divider`, `BoxShadow`, `Card`, or non-zero `elevation` exists anywhere in the board subtree.
- [ ] A test asserts `tester.binding.hasScheduledFrame == false` after a single `pump()` following a tap — no scrollable ancestor, no animation.
- [ ] Golden at 3x4 and 2x3 on a 393x852 viewport matches.

## Traps

- **The axis trap.** In a vertical `GridView`, `crossAxisSpacing` is the **column** gap (14) and `mainAxisSpacing` is the **row** gap (22). Getting these backwards is silent and looks almost right. This is the single most likely defect in this task.
- **Tidying the gutters.** 14/22 looks like a typo to a reviewer and to a future you. It is the composition. A test that asserts the two values differ is the only thing standing between the board and a spreadsheet.
- **Wrapping the `Scaffold` in `SafeArea`.** That insets the ground plane and you get a coloured bar under the status bar instead of a full-bleed field. `SafeArea` goes *inside* `body`, never around the `Scaffold`.
- **"Fixing" the keyboard overlap.** Padding the grid with `MediaQuery.viewInsets.bottom`, or letting `resizeToAvoidBottomInset` default to `true`, reflows the grid under the IME and destroys the fixed-position guarantee that makes position-as-retrieval work. The overlap is the design.
- **Making the grid scrollable.** `GridView` scrolls by default; the tile's `Listener.onPointerDown` feedback fires *before* gesture disambiguation and is only safe because nothing scrolls. A scrollable ancestor turns every tap into a possible drag and re-introduces the latency the tile spent its whole design avoiding. Use `physics: NeverScrollableScrollPhysics()` + `shrinkWrap`, or lay out without a scrollable at all.
- **Asserting a minimum tile size.** A 76dp floor is invented — it appears in no standard (WCAG 2.5.8 AA is 24x24 CSS px; 2.5.5 AAA is 44x44), tiles compute to ~89–106 x 125–146dp on real phones anyway, and at 200% text scale the label block alone needs ~124dp against ~125dp of tile. A size floor would fail exactly where accessibility matters most. Assert the label fits, not the box.
- **Inheriting traversal from layout.** Lower-centre placement is a thumb win and a screen-reader loss unless `OrdinalSortKey` is authored from `priority`. Passing the grid index there is the subtle version of this bug: it compiles, it reads fine, and it costs a switch-access user 8–11 seconds per utterance.
- **`enabled: false` on an empty slot.** It still occupies a scan step. `ExcludeSemantics`, and only in speak mode — leave it excluded in edit mode and the editor becomes unusable by switch access.
- **Reflow of any kind.** Nothing may appear, vanish, collapse, or expand. Non-uniform row heights, bento spans, and rendering the field's span as a visible variation are all the same bug wearing different clothes.
- **`_buildTile` methods and closures over content.** A method's subtree has no `Element` boundary and no test can address it by type. A closure capturing `button.vocalization` at build time speaks a **stale sentence** after an edit — resolve from `(row, col)` at tap time.
- **Adding grain, gradient, or a scrim to the plane.** A flat, opaque, dyed field is better. Grain is what a designer reaches for when the colour is not trusted, and contrast over uncontrolled content is non-certifiable by construction — which is why translucency is out permanently, not pending a perf fix.

## Files

- `lib/features/board/board_screen.dart` — the `Scaffold`, ground plane, `SafeArea` + 24dp margin, the grid.
- `lib/features/board/widgets/board_grid.dart` — the 3x4 / 2x3 layout, gutters, slot ordering, `ValueKey((row, col))`.
- `lib/features/board/widgets/empty_slot.dart` — ground + mode-dependent `ExcludeSemantics`.
- `lib/design/geom.dart` — confirm `gapColumn`, `gapRow`, `margin`, `tileRadius`, `fieldHeight` exist with the values above; add only what is missing.
- `test/features/board/board_grid_test.dart` — new.
- `test/features/board/board_grid_golden_test.dart` — new.

## Done when

Twelve tiles sit at fixed positions on a full-bleed ground with 14dp column gaps and 22dp row gaps, the grid does not move under the IME or at 200% text scale, and the suite fails if anyone equalises the gutters.
