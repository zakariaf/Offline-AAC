# E05-T01 — The tile widget

| | |
|---|---|
| **Epic** | E05 — The speak screen |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E02-T03 |
| **Blocks** | E05-T02, E05-T04, E10-T05 |

**Skills:** `reed-tile-anatomy` · `reed-typography` · `reed-colour-system` · `reed-a11y-coding` · `reed-widget-conventions` · `reed-motion-policy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

This is the object the entire product is: twelve chips of dyed paper stock, each printed with one line of type. Everything else on the speak screen is arrangement around it. Two things get decided here permanently and are expensive to walk back: the chip is not a card — no elevation, no shadow, no ripple, ever — and every tile carries a real `Semantics` node from the first commit, because a custom-painted grid with raw gesture detectors and no semantics locks out every switch and screen-reader user silently, and it is the cheapest accessibility win available. Get the semantics in now and TalkBack, VoiceOver, Switch Access and Switch Control work for free; bolt them on later and they never quite do.

## Scope

Two classes in `lib/ui/board/phrase_tile.dart`, split the way `reed-widget-conventions` says: the public widget does semantics and gesture wiring, the private `_TileFace` does paint and type.

### 1. `PhraseTile` — semantics and hit target

```dart
class PhraseTile extends StatelessWidget {
  const PhraseTile({
    super.key,                 // ValueKey((row, col)) from the grid. Nothing else.
    required this.slot,
    required this.lit,
    required this.onSpeak,
  });

  final GridSlot slot;                          // the joined Tile? + its (row, col)
  final bool lit;                               // pure input; owner is E05-T04
  final void Function(int row, int col) onSpeak;
```

Empty slot (`slot.button == null`): `return const ExcludeSemantics(child: SizedBox.expand());` — ground, nothing else. No fill, no keyline, no target, no `+`. Not `enabled: false`: excluding it means TalkBack and Switch Access **skip** the cell instead of burning a scan step on nothing, and under linear autoscan at 1s/step every wasted step is real seconds someone spends unable to speak. The cell still holds its space and never collapses.

Filled slot:

```dart
Semantics(
  container: true,
  button: true,
  label: button.label,                                   // DISPLAY label, never `vocalization`
  sortKey: OrdinalSortKey(button.priority.toDouble()),   // authored from priority, not layout
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,                    // the whole rect is the target
    onTap: () => onSpeak(slot.row, slot.col),            // resolve at TAP time
    child: ExcludeSemantics(child: _TileFace(...)),      // or the label is announced twice
  ),
)
```

`HitTestBehavior.opaque` is load-bearing: without it only the painted child is hittable and the padding around a short label is dead space — a near-miss on a tile is silence.

The lit state gets a non-colour semantic channel: a `value` or `hint` saying the tile is speaking, never the luminance step alone. Colour-only state is invisible under `invertColors`, under Android's Grayscale colour-correction mode, and to every screen-reader user.

`boldText` and `highContrast` are read from `BuildContext` at build time — `MediaQuery.boldTextOf(context)`, `MediaQuery.highContrastOf(context)` — never through Riverpod. `textScaler` is neither read nor clamped.

### 2. `_TileFace` — the chip

| property | value |
|---|---|
| size | **not fixed** — the cell gives it `(viewport − chrome) / rows` |
| shape | `RoundedSuperellipseBorder`, radius **20dp** (`Geom.tileRadius`) |
| fill | `t.stock(button.stock)` resting / `t.stockLit(button.stock)` lit — full opaque, never translucent |
| keyline | `Geom.hairline(MediaQuery.devicePixelRatioOf(context))` = `1.0 / dpr` (0.333dp on a 3×), colour `t.keyline`, `strokeAlignInside` |
| keyline, lit | width **2dp**, colour `t.ink` |
| inset | **16dp** (`Geom.tileInset`) |
| label | `t.inkOn(button.stock, lit: lit)` — never `inkDim` |

```dart
ShapeDecoration(
  color: t.stock(s),
  shape: RoundedSuperellipseBorder(
    borderRadius: const BorderRadius.all(Radius.circular(Geom.tileRadius)), // 20.0
    side: BorderSide(
      color: t.keyline,
      width: Geom.hairline(MediaQuery.devicePixelRatioOf(context)),
      strokeAlign: BorderSide.strokeAlignInside,
    ),
  ),
)
```

Banned on the tile, permanently: `Card`, `elevation:`, `BoxShadow`, `BackdropFilter`, gradients, grain, bevels, ripple, `InkWell`, `InkResponse`. Shadow + rounded rect + centred content **is** the 2014 enterprise grid — the exact failure this design exists to avoid. The complete list of depth mechanisms is the tonal ladder (`ground → container → stock → stockLit`) and the keyline.

`Border.all()` is banned: it defaults to 1.0 *logical* px = 3 physical pixels on a modern phone. That is a rule, not a hairline. `ContinuousRectangleBorder` is banned too, along with the workarounds — it is not an iOS-grade squircle (its radius needs a ~2.3529 multiplier, which degenerates into a "TIE fighter" earlier), and it centres its stroke regardless of `strokeAlign`. `figma_squircle` and `smooth_corner` are dead weight: `RoundedSuperellipseBorder` is first-party with an Impeller GPU path. Never `BorderRadius.circular(9999)` — that is a third-party sentinel; `StadiumBorder` exists.

Any chip ever nested inside the tile takes `Geom.innerRadius(Geom.tileRadius, padding)`, computed — never a second constant.

In high contrast (`t.usesStocks == false`) the stocks drop out entirely and the keyline goes to 3dp and *is* the tile. Read colour through `t.stock(s)` / `t.stockLit(s)` / `t.inkOn(s, lit: lit)` — those accessors are what make the HC collapse work. Never index `t.stocks` directly, never branch on the palette in this file.

### 3. The label

Start-aligned, **bottom-anchored**, 20 / w600 / tracking −0.20 / height 1.15 / max 3 lines — the `tile` role from E02-T02, read from the type scale, not retyped here.

```dart
Padding(
  padding: const EdgeInsetsDirectional.all(Geom.tileInset), // 16
  child: Align(
    alignment: AlignmentDirectional.bottomStart,
    child: Text(button.label, textAlign: TextAlign.start, maxLines: 3),
  ),
)
```

`EdgeInsetsDirectional` / `AlignmentDirectional` / `TextAlign.start` always — never `EdgeInsets`, `Alignment.bottomLeft`, `TextAlign.left`, which pin LTR and break Arabic and Hebrew boards.

Bottom-anchored is not taste. A swatch chip has its name ranged left at the bottom — that is the reference class. Centred text in a box is the universal signal for "button"; start-aligned text on a baseline is the signal for "page". Bottom-anchoring makes 1-line and 3-line tiles **share their last baseline**, so a row scans as a line of type rather than four unrelated widgets. It reserves the top-right corner, which the divergence tick needs now and a symbol will need later. And it kills the optical-centring problem outright: the shipped face has `ascent 984` against `capHeight 668` at `upem 1000`, so mathematically-centred text sits optically low — anchored to the bottom, that bug never exists here. (No `TextHeightBehavior` fix on the tile; that is show mode's problem.)

One uniform size for all twelve tiles. Variable line count is fine; variable size reads as broken. **Never `FittedBox`, never auto-shrink, never `TextOverflow.ellipsis`.** Auto-shrink makes the longest, most complex phrase the smallest, destroys the grid's rhythm, and overrides the user's own `TextScaler`. An ellipsis on an AAC utterance is a *different utterance*. A literal `\n` in a label is a hint: honour it, but fall back to natural wrap if scaled text would exceed 3 lines.

`boldText` moves the weight; nothing else may. Do not hardcode `fontWeight` on the label.

### 4. The divergence tick

The tile is a **handle** for an utterance, not the utterance. `label` is capped at 16 characters and shown; `vocalization` is uncapped, spoken, and `null ⇒ label`. When the button diverges (`vocalization != null && vocalization != label`), draw one **6dp hairline tick, top-right, in `t.keyline`**, and nothing else. Wrap it in `ExcludeSemantics` — divergence is announced inside the tile's semantics label, never drawn twice.

Never render `vocalization` as a second line on the tile. At 60% ink it computes to 3.94:1 on `oxblood` and 4.24:1 on `slate` — both fail AA — and even where it clears AA on `ground` at 5.34:1 it is Lc −39.0, unreadable. Verification of the spoken text belongs in edit mode, where nobody is in a shutdown. A chip has a name on it, not a paragraph.

### 5. The focus ring

Drawn **in the gutter, outside the tile, never on it**: offset 2dp, width 3dp, the same superellipse at radius **22dp** (= 20 + 2), colour `t.focus`. Recolouring the tile's own keyline to amber gives 2.73:1 on the changed pixels and fails SC 2.4.13's 3:1; `#FFD9A0` on light paper is 1.20:1, an invisible ring. Ground→ring clears 6.69–14.85:1 across every palette and needs no per-stock verification because it never touches a fill.

The ring paints outside the tile's own bounds, so the tile must not be clipped by its cell. That constraint is this task's to state and E05-T02's to honour.

### Out of scope

- The grid, the gutters (14dp/22dp), the margin, and the cell sizing — E05-T02.
- Wiring `lit`: `Listener.onPointerDown`, the haptic → `setState` → TTS order, the 120ms minimum hold, the TTS-completion latch and its force-clearing timeout — E05-T04. `lit` arrives here as a `bool` and this task proves both renderings.
- Edit mode's version of the empty slot (keyline, `+`, full semantics). Structure the exclusion so it can be made mode-dependent, but do not build the editor here.
- Any new hex, any new geometry constant, and any contrast verification of a new pairing. Every value above is already measured and lives in `tokens.dart`.
- Golden tests — E05 has its own task for those; assert structure and semantics here.

## Acceptance criteria

- [ ] `grep -rniE 'Card\(|elevation|BoxShadow|BackdropFilter|InkWell|InkResponse|ContinuousRectangleBorder|Border\.all|FittedBox|TextOverflow\.ellipsis|withClampedTextScaling|textScaleFactor' lib/ui/board/phrase_tile.dart` returns nothing.
- [ ] `grep -rn 'Color(0x' lib/ui/board/phrase_tile.dart` returns nothing — every colour comes from `AacTheme.of(context)`.
- [ ] `grep -rn 'EdgeInsets\.\|Alignment\.\|TextAlign\.left\|TextAlign\.center' lib/ui/board/phrase_tile.dart` returns nothing (directional variants only).
- [ ] `grep -rn 'stocks\[\|stocksLit\[' lib/ui/board/phrase_tile.dart` returns nothing — reads go through `stock()` / `stockLit()` / `inkOn()`.
- [ ] Test: a filled tile's semantics matches `isSemantics(isButton: true, label: 'I can’t talk', ...)` — `isSemantics`, not the deprecated `containsSemantics`.
- [ ] Test: the semantics `label` equals the button's `label` and **not** its `vocalization`, for a button where the two differ.
- [ ] Test: the semantics node's `sortKey` is `OrdinalSortKey(priority)`, and for a fixture whose priority order is the reverse of its layout order, traversal follows priority.
- [ ] Test: an empty slot produces **no** semantics node in the tree (not a disabled one), and still occupies its full cell size.
- [ ] Test: tapping anywhere in the cell — including a corner 4dp inside the bounds, far from the label glyphs — calls `onSpeak(row, col)` exactly once with the slot's coordinates.
- [ ] Test: `onSpeak` receives `(row, col)`; the widget never captures `vocalization` in a closure. Verified by mutating the fixture's button between build and tap and asserting the callback still reports coordinates only.
- [ ] Test: at `TextScaler.linear(2.0)`, with a 16-character label, a tile sized to the real computed cell renders with no overflow exception and no `RenderFlex` overflow stripe.
- [ ] Test: `boldText: true` in `MediaQueryData` changes the rendered `TextStyle.fontWeight`; the same test at `boldText: false` gives w600.
- [ ] Test: after `tester.tap(...)` and one `pump()`, `expect(tester.binding.hasScheduledFrame, isFalse)` — a scheduled frame means something animates. No `pumpAndSettle()` anywhere in this file's tests.
- [ ] Test: with `lit: true`, the fill is `stockLit`, the keyline width is `2.0`, its colour is `t.ink`, and the semantics node exposes a non-colour speaking signal.
- [ ] Test: across `kAllThemes`, the resting keyline width equals `Geom.hairline(dpr)` for `dpr` of 2.0 and 3.0 — `closeTo(0.333, 0.001)` at 3×.
- [ ] Test: under `hcInk` and `hcPaper`, all four `Stock` values render the same fill (`ground`) and the keyline is 3dp — the tile does not assume a tinted fill exists.
- [ ] Test: the divergence tick renders when `vocalization != label`, is absent when `vocalization == null` or equals `label`, and contributes no semantics node.
- [ ] Test: `vocalization`'s text appears nowhere in the rendered tile — `find.text(longVocalization)` finds nothing.
- [ ] Test: in an RTL `Directionality`, the label's rendered rect hugs the right edge at 16dp.
- [ ] `dart analyze` is clean; `flutter test` is green.

## Traps

- **Reaching for `Card` or a `BoxShadow` when the tile "looks flat".** It is supposed to look flat. Shadow + rounded rect + centred content is the exact 2014 enterprise-grid failure this design exists to avoid. When it feels dead, the tools are tone, weight, scale, and the keyline — never a shadow, and never a comment apologising that we can't animate it.
- **`Border.all(color: t.keyline)`.** Compiles, looks fine on a simulator, ships a 3-physical-pixel table border on a 3× phone. A true single-physical-pixel line reads engraved; anything thicker reads as a spreadsheet. `Geom.hairline(dpr)`, `strokeAlignInside`.
- **`ContinuousRectangleBorder` because it sounds like the squircle.** Its radius needs a ~2.3529 multiplier to approximate one, the multiplier degenerates it into a TIE fighter *earlier*, and it centres its stroke regardless of `strokeAlign` — so the hack fails at exactly 20dp, the radius wanted here.
- **Centring the label** because centred content is what a "button" does. That is the reason not to: centred text in a box says button, start-aligned text on a baseline says page, and the row stops sharing a last baseline the moment one tile wraps to two lines. Bottom-anchoring is also the only reason the `ascent 984 > capHeight 668` optical-centring bug never appears here — centre it and you have quietly created a metrics problem no nudge fixes at 200% scale.
- **`FittedBox` / auto-shrink / `ellipsis` when the 200% test goes red.** All three are the same bug in different clothes: the layout stays tidy, the user's `TextScaler` stops working, and every contrast and tap-target guideline still passes green. `withClampedTextScaling` is the single most dangerous API in this app for exactly this reason. Let the overflow scream in the test and fix the layout.
- **Hardcoding a tile height, or reinstating a "76dp minimum".** There is no 76dp floor — it appears in no standard (WCAG 2.5.8 AA is 24×24 CSS px, 2.5.5 AAA is 44×44), tiles compute to ~89–106 × 125–146dp on real phones, and at 200% scale the label block alone needs ~124dp. A number that only sounds rigorous is worse than no number. If a 76 appears anywhere, delete it.
- **`ExcludeSemantics` forgotten around `_TileFace`.** The `Text` inside it produces its own semantics node under the `Semantics` container, and TalkBack says the label twice. Nothing fails; the app just becomes tiring to use.
- **`enabled: false` on the empty slot** instead of `ExcludeSemantics`. A disabled node still consumes a Switch Access scan step. At 1s/step, four empty slots cost four seconds to someone who cannot speak. And make the exclusion mode-dependent from the start, or edit mode is unusable by switch access and the fix means re-cutting this widget.
- **`sortKey` inherited from layout because "row-major is fine".** It is not: the lower-centre thumb arc makes "I need to leave" the 8th-to-11th thing announced, and 8–11 seconds away under linear autoscan. The thumb optimisation actively pessimises every screen-reader and switch user. One argument fixes it. Know its limit too — Switch Access *group* selection reaches any of 12 items in 4 presses regardless of order, so the test is a regression guard on intent, never conformance evidence.
- **`label: button.vocalization` because "that's what it says".** A scanning user must hear "Overwhelmed", not the whole sentence, on every step. Nothing in the type system distinguishes those two `String`s — this is a review-only defence.
- **`onTap: () => speak(button.vocalization)`.** Captures content into a closure; a fast re-tap after an edit speaks a *stale* sentence — the wrong words, out loud, on behalf of someone who cannot verbally correct them. `(row, col)` is the identity; resolve at tap time.
- **`InkWell` with `NoSplash.splashFactory` believed safe.** The factory kills only the splash. `InkResponse.updateHighlight()` independently creates an `InkHighlight` with a 200ms pressed fade the factory never sees. `GestureDetector` + `HitTestBehavior.opaque`.
- **Dropping `HitTestBehavior.opaque`.** Only the painted child stays hittable, the inset around a short label becomes dead space, and a near-miss mid-shutdown produces silence — the worst outcome this app can generate. It is not a tidiness flag.
- **A chroma-flooded lit state** ("shift the hue, hold the lightness"). It computes to 1.02:1 in colour and 1.015:1 under Android's Grayscale colour-correction mode — literally invisible. The luminance step measures 1.34–1.48:1 and survives grayscale and protan; the keyline promotion is a deliberate second, non-chroma channel. Feedback is never single-channel and never chroma-only.
- **"Fixing" the lit label contrast up to 7:1.** The lit tier is AA 4.5:1 / |Lc| ≥ 45 *on purpose* — a 1–3s transient the user triggered on a label they had just finished reading. Flattening it up erases the lit state, which is the only confirmation a user with motor imprecision gets that their tap landed. Resting stays AAA 7:1 / Lc ≥ 60.
- **`inkDim` on the label** because it looks softer. WCAG blesses it at 7.94:1; APCA rates it Lc −55.7, correctly, as secondary. Chrome only.
- **Rendering `vocalization` as a small second line** so the user can check it. Every variant of this was measured and fails: 3.94:1 on oxblood, 4.24:1 on slate, and Lc −39.0 even where the ratio passes. The tick is the whole disclosure.
- **Indexing `t.stocks` directly, or `if (palette == hcInk)` in this file.** The accessors exist so HC's `usesStocks: false` collapse happens in one place. A tile that assumes a tinted fill exists renders invisible text for the HC user, who is the one person who cannot work around it.
- **A `Widget _buildFace(...)` method instead of `_TileFace`.** A method's subtree has no `Element`, so `updateChild` never gets to short-circuit, it cannot be `const`, and `find.byType` cannot reach it in a test. At 12 tiles the performance argument is worth nothing — the test handle and the greppable name are the point.
- **A `GlobalKey`, an `ObjectKey`, or a key per button.** The composite `(board_id, row, col)` primary key means slots never reorder and there is no `State` to leak. If the tile seems to want `State`, that is the signal to reconsider, not to add a key.
- **Clipping the tile to its cell** in the grid, which silently eats the focus ring — the ring lives in the gutter at offset 2dp / radius 22dp. The failure is invisible until a keyboard or switch user has no focus indicator at all.

## Files

- `lib/ui/board/phrase_tile.dart` — creates `PhraseTile` and `_TileFace`.
- `lib/ui/core/tokens.dart` — only if `Geom.tileInset` (16.0) or `Geom.hairline(dpr)` are not yet present from E02; no new colour and no new geometry beyond these.
- `test/ui/board/phrase_tile_test.dart` — semantics, sortKey, empty slot, hit target, tap identity, 200% scale, boldText, `hasScheduledFrame`, lit rendering, HC collapse, divergence tick, RTL.
- `test/support/` — a `GridSlot` / `Tile` fixture builder if one does not already exist.

## Done when

`flutter test` is green, the bans grep clean, and a tile renders as an opaque 20dp superellipse chip with a one-physical-pixel keyline and a bottom-anchored start-aligned label that TalkBack announces once as a button, in priority order, at 200% text scale, with no frame scheduled after a tap.
