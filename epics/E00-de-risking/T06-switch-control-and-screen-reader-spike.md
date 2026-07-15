# E00-T06 — Switch Control and screen reader spike

| | |
|---|---|
| **Epic** | E00 — De-risking |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | Nothing |
| **Blocks** | E05-T06 |

**Skills:** `reed-a11y-coding` · `reed-a11y-testing` · `reed-manual-checklist` · `reed-tile-anatomy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Flutter publishes **no support statement for Switch Access or Switch Control**. Its own accessibility engineer says support exists; there is no documentation to lean on, no API simulates scanning or group selection or point scanning, and no automated test will ever cover it. So the only verification that will ever exist for this app is a human holding a real phone with the service switched on — and this spike is where that human finds out, while the grid is 60 lines of throwaway code instead of the shipped product.

A switch user who cannot reach a tile cannot speak. If the answer is "Flutter's semantics tree does not drive scanning the way we assumed," the fix is a rewrite of every interactive widget. That costs a day now and a month at week six.

## Scope

Build a 12-tile grid in the throwaway spike app (`spike/lib/main.dart` — create the spike app if this is the first E00 task you run), then run it on real hardware against four services and write down what actually happened.

### The grid

3×4, fixed, no scrollable ancestor anywhere in the tree. Do not port the real tile — reproduce only the parts that affect a11y and the parts a scan highlight has to sit on top of.

Each tile carries the structure from `reed-a11y-coding`:

```dart
Semantics(
  container: true,
  button: true,
  label: tile.label,                                    // display label, 16-char cap,
                                                        // NEVER the `says` string
  sortKey: OrdinalSortKey(tile.priority.toDouble()),    // priority, not layout order
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,                   // whole cell is the target
    onTap: () => _activate(tile.row, tile.col),         // resolve from (row, col)
    child: ExcludeSemantics(child: _TileFace(...)),     // face is already announced above
  ),
)
```

Give every tile `key: ValueKey('slot_${row}_${col}')` so geometry is addressable later.

### The face, enough of it to matter

The scan highlight has to be visible against this, so the visual has to be honest. From `reed-tile-anatomy`:

- `RoundedSuperellipseBorder`, radius **20dp**. Not `ContinuousRectangleBorder` — it is banned and its ~2.3529 radius hack degenerates at exactly this radius.
- Full **opaque** category stock fill. Flat. No `Card`, no `elevation:`, no `BoxShadow`, no gradient.
- Keyline: `1.0 / MediaQuery.devicePixelRatioOf(context)` (0.333dp on a 3× phone), `strokeAlign: BorderSide.strokeAlignInside`. Never `Border.all()` — its 1.0 *logical* px is 3 physical pixels, a rule rather than a hairline.
- 16dp inset (`EdgeInsetsDirectional.all`), label bottom-anchored and start-aligned via `AlignmentDirectional.bottomStart` + `TextAlign.start`, **20 / w600**, tracking −0.20, height 1.15, max 3 lines.
- Tile size is **not fixed**: `tileHeight = (viewport − chrome) / rows`. There is no 76dp floor on the tile — do not add one.
- Lit state: `Listener.onPointerDown` → `HapticFeedback.selectionClick` → `setState(lit)`, minimum hold **120ms**, luminance step (`stockLit`, OKLCH L ±0.09 toward the ink) plus keyline promoted to **2dp** in `ink`. Zero duration; `splashFactory: NoSplash.splashFactory` at the theme root.

Include a **focus ring** as specified: drawn in the gutter, **outside** the tile, offset 2dp, width 3dp, same superellipse at radius **22dp** (= 20 + 2), `focus` colour. You need it in the spike to find out whether it collides with or is redundant to the service's own highlight.

### Two board states, toggled by a button in the app bar

1. **All 12 filled** — the traversal and activation case.
2. **9 filled, 3 empty** — the empty slot is `ExcludeSemantics(child: SizedBox.expand())`: ground, no fill, no keyline, no target, no semantics node at all. It still **holds its space** and never collapses. This state answers "does scanning skip it, or burn a step on it?" Under linear autoscan at 1s/step, three wasted steps are three real seconds someone spends unable to speak.

### Activation must be observable without TTS

No `flutter_tts` in this spike. Instead, `_activate` appends a timestamped line to an on-screen log list at the bottom of the screen: `HH:MM:SS.mmm  tap  (row,col)  "label"`. Also log every `Listener.onPointerDown`, distinctly: `HH:MM:SS.mmm  pointerDown  (row,col)`.

**Logging both is the point of the spike, not bookkeeping.** A switch or screen-reader activation dispatches a `SemanticsAction.tap` — it does not synthesize pointer events. If the log shows `tap` with no preceding `pointerDown`, then the real app's lit state (which is triggered from `onPointerDown`) never fires for switch or TalkBack users, and Reed's only press-confirmation channel is dead for the exact audience that needs it most. Find that out here.

### The runs

Physical phones only, per `reed-manual-checklist`. Use the **cheap** Android device — budget silicon, ~2GB RAM. That is the target hardware, not a degraded case. Never an emulator.

For each of the four services, for **both** board states, traverse and activate **every** tile:

| Platform | Service | Modes to exercise |
|---|---|---|
| Android | TalkBack | swipe traversal + double-tap to activate; explore-by-touch |
| Android | Switch Access | linear autoscan (**set 1s/step**) **and** group selection |
| iOS | VoiceOver | swipe traversal + double-tap to activate |
| iOS | Switch Control | **item scanning** and **point scanning** — both, separately |

Record, per run: order tiles were visited in; whether that order matched `priority` order or collapsed to row-major layout order; whether the service's highlight was visible against every stock and against the focus ring; whether activation produced a `tap` log line; whether empty slots consumed a scan step.

Finish the Android pass by running **Google's Accessibility Scanner** on the grid. It works — it is an `AccessibilityService` and reads the framework's `AccessibilityBridge` virtual node tree. On iOS, do the same with Xcode's **Accessibility Inspector**. Both are manual and human-driven. A clean scan is a tripwire that did not trip, never evidence.

### Deliverable

`spike/SWITCH_FINDINGS.md`: the table above, filled in, one row per (service, board state), device model and OS version at the top. Plus a short list of **structural consequences for the real widget** — each one a sentence a developer can act on. That list is the input to E05-T06.

### Out of scope

- Real palettes, real theming, the four-palette contrast gate, real data/Drift, TTS, edit mode, show-text mode.
- Any automated test. `test/ui/a11y_test.dart` and the traversal assertion belong to the real app, not here.
- Fixing anything you find. This spike produces findings, not patches. If the finding is large, it becomes a task.
- **Espresso `AccessibilityChecks`** — it walks the Android *View* hierarchy; Flutter is one opaque `FlutterView` rendering to a single canvas, so it sees zero tiles. Do not spend an hour discovering this.
- **CI a11y automation via `flutter drive`** — the semantics tree is not exposed to the platform during `flutter drive` unless an accessibility service is already running, and the workaround is force-enabling one via `adb settings put secure`. Not worth the day.

## Acceptance criteria

- [ ] `cd spike && flutter analyze` exits 0; `flutter run --release` puts a 3×4 grid on a physical Android phone.
- [ ] Every filled tile is announced by TalkBack with its **display label** and the word "button" — and the announcement contains no part of the `says` string.
- [ ] Under Switch Access **linear autoscan at 1s/step**, all 12 tiles are reachable, and the visit order is written down and compared against `priority` order in `spike/SWITCH_FINDINGS.md`.
- [ ] Under Switch Access **group selection**, every tile is reachable; the recorded press count to reach an arbitrary tile is compared against the ⌈log₂12⌉ = 4 that group selection should give **regardless of order**.
- [ ] Under iOS Switch Control **item scanning**, all 12 tiles are reachable and activatable.
- [ ] Under iOS Switch Control **point scanning**, all 12 tiles are activatable — every tile, not a sample. Point scanning is coordinate-based and has no order at all, so this is a pure geometry check.
- [ ] Activating a tile via each of the four services appends a `tap` line to the on-screen log. Whether a `pointerDown` line accompanied it is recorded per service — this answer, yes or no, is written explicitly in the findings.
- [ ] In the 9-filled board state, every service **skips** the 3 empty slots — no scan step, no announcement, no highlight — and the 9 tiles stay in their original cells (the empty cell held its space).
- [ ] The Switch Access highlight and the Switch Control cursor are confirmed visible against every stock colour used in the spike, at the service's default highlight colour, with a photo or screenshot in the findings.
- [ ] Accessibility Scanner (Android) and Accessibility Inspector (iOS) have both been run over the grid; any issues raised are listed verbatim, unfiltered.
- [ ] `spike/SWITCH_FINDINGS.md` exists, names the device model and OS version for every run, and ends with a list of structural consequences for the real tile widget.

## Traps

- **The lit state is invisible to every user this spike is about.** `Listener.onPointerDown` fires on a real finger. A switch or screen-reader activation dispatches `SemanticsAction.tap`; no pointer event is synthesized. If you only log `onTap`, you will never notice, and the app ships with its sole press-confirmation channel silently dead for switch users. Log both. This is the single highest-value thing this spike can return.
- **Believing the traversal test proves scanning works.** Semantics traversal order is a *weak* proxy: point scanning is coordinate-based with no order; group selection is a nested binary narrowing that reaches any of 12 items in 4 presses regardless of order; and scanning targets only *actionable* elements while semantics traversal enumerates non-actionable nodes too. Only linear autoscan depends on `sortKey`. Do not write "traversal order verified, Switch Access covered."
- **Testing on a flagship.** The audience is cost-constrained; budget silicon *is* the target. A raster stall on the RSuperellipse path or a scan-highlight repaint cost only shows up on the real device. Note also that Impeller is default on Android API 29+ and prefers Vulkan, while API 28 and below run OpenGL unconditionally where the RSuperellipse fast path is unmeasured.
- **Testing on an emulator.** Switch Access on an emulator with no hardware switch and no real touch pipeline is not the thing. Set up on-screen or hardware switches on a physical phone.
- **`enabled: false` instead of `ExcludeSemantics` on the empty slot.** A disabled node is still a node: the service focuses it, announces it, burns the scan step. It will look "handled" and be broken. Exclusion is the only correct answer — and it must be **mode-dependent**, because in edit mode that same cell becomes a full target with a keyline, a `+` and full semantics.
- **The face announcing itself twice.** Forgetting `ExcludeSemantics` around `_TileFace` gives you the label twice on every scan step. This is invisible in code review and deafening on a device.
- **Leaking `says` into `label`.** `label` and `says` are both `String`; nothing in the type system separates them. A scanning user must hear "Overwhelmed", not the whole sentence, on every single step. No guideline catches this — `labeledTapTargetGuideline` only checks the label is non-empty.
- **The highlight you cannot see.** The palette is flat, opaque, dyed-paper chips with a fine keyline and no shadow. Switch Access draws its **own** highlight, user-configurable in colour and thickness, and in group selection the highlighter colours **change on every press**. A highlight that reads by elevation contrast will vanish here. Check at the service's defaults, not at a colour you picked.
- **Confusing the focus ring with the scan highlight.** Touch, switch, and screen reader are three different channels. The focus ring (gutter, 2dp offset, 3dp wide, 22dp radius) serves keyboard and TalkBack only — Switch Access ignores it entirely and draws its own. Do not "fix" the scan highlight by adjusting the focus ring.
- **`MediaQuery.highContrastOf` on Android.** It is iOS-only and always `false` on Android — `AccessibilityFeatures.highContrast` is documented "Only supported on iOS". If you gate the spike's high-contrast variant on it, the Android run silently tests the wrong palette. Android-first means the in-app switcher is the only mechanism that works.
- **Reaching for `withClampedTextScaling` when the spike grid overflows.** It is the single most dangerous API in this app and it is banned. Let it overflow; the stripe is information.
- **Introducing a scrollable ancestor** to make the throwaway grid fit. `onPointerDown` fires before gesture disambiguation, which is safe **only because the grid never scrolls**. The no-scroll rule is load-bearing, not aesthetic — and a spike that scrolls proves nothing about the app that does not.
- **Turning the spike into a product.** It is throwaway. Its output is `spike/SWITCH_FINDINGS.md` and the consequences list. Do not port code out of it; port *conclusions*.

## Files

- `spike/pubspec.yaml`, `spike/lib/main.dart` — creates: the throwaway 12-tile grid, the two board states, the on-screen `tap`/`pointerDown` log.
- `spike/SWITCH_FINDINGS.md` — creates: the filled-in run table, device/OS headers, screenshots, and the structural-consequences list that feeds E05-T06.

## Done when

Every tile in the 12-tile spike grid has been traversed and activated by hand under TalkBack, Switch Access (linear autoscan at 1s/step and group selection), VoiceOver, and iOS Switch Control (item scanning and point scanning) on physical phones, and `spike/SWITCH_FINDINGS.md` records — per service — the visit order, whether activation produced a `pointerDown` as well as a `tap`, whether empty slots were skipped, and what each of those answers forces the real tile widget to do.
