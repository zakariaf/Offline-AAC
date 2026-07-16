# E02 — Design system in code

> Four palettes, one variable typeface, five type roles, and a pure-Dart contrast gate that proves every colour pairing is legible — all of it standing before the first screen exists.

| | |
|---|---|
| **Status** | Done — all 4 tasks |
| **Tasks** | 4 |
| **Depends on** | E01 (both E02-T01 and E02-T02 gate on E01-T01) |

## Why this epic exists

Reed cannot animate, cannot use shadow, blur, gradient, or elevation, and has exactly one screen. Everything that makes the app comprehensible is colour, tone, edge, and type. Those are not decoration here — a tile whose label drops below its contrast floor is a phrase a person cannot find during a shutdown, and nothing will ever report that it happened. There is no telemetry, and the user cannot file the bug: not speaking is the condition the app serves.

Built after the UI, this epic becomes archaeology. A screen written against a placeholder `Colors.grey` and a guessed `fontSize: 18` accretes per-widget colour patches, hardcoded nudges, and `InkWell`s, and every one of them has to be found and removed later by a developer who no longer remembers which values were provisional. Built before the UI, there is no placeholder to move: `tokens.dart` is the only file permitted a `Color(0x…)` literal from the first commit, and the contrast gate is red before it is green.

Getting it wrong is quiet. `ColorScheme.fromSeed(seedColor: …, surface: t.ground)` compiles, looks plausible, and leaves `surfaceContainerHigh` seed-derived — a role the `TextField` reads. `pyftsubset` will happily instance the variable font down to a static w400; the app looks identical until the one user who turns on platform bold text finds their labels never thicken. A `wght` that differs by palette re-wraps a label on a theme switch, which is a reflow nobody sees and nobody reports.

## What "done" means

- `! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'` exits 0.
- `flutter test test/ui/contrast_test.dart` passes: WCAG **and** APCA on every pair across all four of `kPaper`, `kInk`, `kHcInk`, `kHcPaper`, plus the grayscale, edge-findability, stagger, and step-function-`lerp` groups. It runs in about a second with no widget tree and no PNG.
- The gate's own self-test passes first: `_apca(#888, #FFF) == 63.1`, `_apca(#FFF, #888) == −68.5`, `_apca(#000, #AAA) == 58.1`, `_wcag(#000, #FFF) == 21.00`. An unverified instrument measures nothing.
- `grep -rn 'google_fonts\|dynamic_color\|ColorScheme.fromSeed\|DynamicColorBuilder' lib/ pubspec.yaml` returns nothing.
- The shipped TTF still reports `wght min 200 default 400 max 800` after subsetting, and `assets/fonts/OFL.txt` is registered via `LicenseRegistry.addLicense()`.
- `aacThemeData()` sets all three animation switches (`splashFactory: NoSplash.splashFactory`, transparent splash/highlight, a `PageTransitionsBuilder` returning `child`), and `MaterialApp` passes `themeAnimationStyle: AnimationStyle.noAnimation`.
- The switcher cycles `paper → ink → high contrast → paper` — three positions, not four. HC polarity is a settings preference defaulting to `ink`.
- `AacTheme.of(context)` asserts on a missing extension. There is no `AacTheme.fallback()`.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E02-T01 | Colour tokens and the four palettes | S | E01-T01 |
| E02-T02 | Typography and font bundling | S | E01-T01 |
| E02-T03 | Theme wiring and the palette switcher | M | E02-T01, E02-T02 |
| E02-T04 | The contrast gate test | S | E02-T03 |

**E02-T01 — Colour tokens and the four palettes.** Writes `lib/ui/core/tokens.dart`: the `Prim` primitives named `<family><tone>` by measured OKLCH lightness (`inkT89` is `#DCD9D3` at L 0.885), the `AacTheme` `ThemeExtension` semantic tier, and the four palette constants plus `kAllThemes`. Every hex is transcribed from `reed-colour-system`, never estimated — the warm-neutral ramp at OKLCH hue 65–85 with chroma rising 0.006 → 0.012, the four stocks staggered L 0.240 → 0.375, `#FFD9A0` as the app's only saturated colour. It is an S because nothing here is invented; it is first because it is the vocabulary every later value is expressed in.

**E02-T02 — Typography and font bundling.** Atkinson Hyperlegible Next from `github.com/googlefonts/atkinson-hyperlegible-next`, subset with `pyftsubset` preserving the `wght` axis, declared under pubspec `fonts:` and never through `google_fonts`. Then the five roles — `tile` 20/w600/−0.20, `show` fitted 32–140/w500, `standing` 18/w500, `field` 22/w500, `meta` 15/w500/+0.15 lowercase — with the hand-built optical sizing rule (as size rises, weight falls and tracking tightens), because the shipped face has one axis and no `opsz`. Parallel with T01: colour and type touch no shared file.

**E02-T03 — Theme wiring and the palette switcher.** The M that joins the two S's. Hand-authors the `ColorScheme` role by role over `AacTheme`'s values, installs all three animation switches, derives `Brightness` from the palette rather than `MediaQuery.platformBrightness`, and builds the three-position switcher over four palettes. It also owns the restore path: the palette and the HC polarity preference load from the versioned JSON settings file **before** `runApp`, never from `shared_preferences`, because an async read that lands a frame late paints the wrong polarity at someone in a shutdown. It blocks E05-T01 — the board cannot be built against a theme that does not resolve.

**E02-T04 — The contrast gate test.** `test/ui/contrast_test.dart`, pure Dart, ~85 tests in about a second. Four channels: WCAG as the compliance floor, APCA as the instrument, grayscale because Android ships a Grayscale colour-correction mode in which every chroma-only signal is identically zero, and the palette-contract assertions (stagger, step-function `lerp`, geometry floors). It depends on T03 because it iterates `kAllThemes` through the accessors `stock`/`stockLit`/`inkOn`, which are what make `usesStocks: false` collapse correctly under HC. It blocks nothing and is the reason the epic exists.

## Skills this epic draws on

**Colour**
- `reed-colour-system` — every role hex, the four stocks and their lit variants, the warm-neutral rule, the ink-luminance cap at L ≈ 0.885, the two-tier contrast floor, and `scripts/contrast.py` for any pairing not already listed.
- `reed-theming-code` — the wiring that carries an already-chosen value: hand-authored `ColorScheme`, `AacTheme` and its step-function `lerp`, `copyWith`, the asserting `of`, the switcher, the before-first-paint restore.

**Type**
- `reed-typography` — the typeface, the probed TTF facts, the five roles, hand-built optical sizing, `FontWeight` not `FontVariation`, the pubspec `fonts:` block and the subsetting procedure.
- `reed-code-bans` — why `google_fonts`, `dynamic_color`, `ColorScheme.fromSeed`, `Card`/`elevation`/`BoxShadow`/`BackdropFilter`, and `InkWell` are permanently out.
- `reed-dependency-hygiene` — the gate any new package must pass, and the transitive audit that catches `google_fonts` arriving on the second hop.

**Wiring and motion**
- `reed-riverpod-usage` — the palette lives in app state and goes through a provider; `boldTextOf`/`highContrastOf`/`textScalerOf` are read from `BuildContext` at build time and must never reach a provider.
- `reed-motion-policy` — the three theme-root switches, why `themeAnimationStyle` is required even with a step-function `lerp`, and why the show-mode flash is deliberate.

**Verification**
- `reed-golden-testing` — the golden refusal, the contrast gate source, and the rules for extending it.
- `reed-testing-strategy` — the ~135-test / under-30-second budget this gate's ~85 tests are drawn against, and why `meetsGuideline` is never the gate.

## Sequencing

T01 and T02 are genuinely parallel: one writes `tokens.dart`, the other writes `assets/fonts/`, `pubspec.yaml`, and the type roles, and neither reads the other. Both need only E01-T01's tree to have somewhere to land.

T03 is a hard join — it cannot start until both exist, because it hand-authors a `ColorScheme` out of `AacTheme` fields and a `TextTheme` out of the five roles. T04 is a hard follow, not because a test needs the app but because the gate iterates `kAllThemes` and calls the `stock`/`stockLit`/`inkOn` accessors that T03's HC collapse defines.

The chain outward is what makes this a gate: **T03 blocks E05-T01.** Nothing in `lib/ui/board/` should be written while `AacTheme.of(context)` still asserts. E01-T06 additionally waits on T03, because `main()` cannot restore a palette before first paint until there is a palette to restore.

## Risks specific to this epic

- **Transcription drift.** Every hex here is measured, and a single mistyped digit is a value that passes review, passes the eye, and fails a floor nobody re-runs. Copy from `reed-colour-system`; when a pairing is not listed, compute it with `scripts/contrast.py`, never by hand-math and never from memory.
- **The subsetter instances the font.** `pyftsubset` without `--layout-features='*'` and axis preservation emits a static w400 that renders identically at rest and silently ignores the platform `boldText` flag. Verify the axis after subsetting; nothing downstream can see this.
- **`fromSeed` looks like it works.** Its per-role overrides are post-hoc and do not propagate — override `surface` and `surfaceContainerHigh` stays seed-derived. The `TextField` reads it. The failure is a wrong-tone container in one palette, which reads as a design opinion rather than a bug.
- **A token set in three palettes out of four.** `kAllThemes` exists so tests iterate every palette; a field added to `kPaper`, `kInk`, and `kHcInk` is a crash or an unverified colour waiting for the one user who picked the fourth. The gate catches it only if the token has a `Pair` in `_pairs` — added in the same commit, or it is an untested colour.
- **Someone "fixes" the deliberate values.** The step-function `lerp` reads as unfinished. The lit-label tier at AA/Lc 45 reads as a mistake next to the resting tier's AAA/Lc 75 — raising it flattens the lit state, which is the only tap confirmation a user with motor imprecision gets. Edge findability at 1.5 reads as a broken 3:1 — raising it forces a hard rule around all twelve tiles and produces the 2014 enterprise grid. Each needs a comment at the point of temptation.
- **A floor lowered to make a test pass.** Change the colour, never the floor. A floor edited to go green is the test deleting itself, in the only suite that will ever notice.
- **The switcher grows a fourth position.** Four palettes and three positions looks like an oversight. It is not: a shutdown user needs one tap to produce one predictable next state.

## Out of scope

- **Geometry.** The 3×4 grid, the 14dp column gap, the tile radius, tap-target floors, and `Geom` live with the grid work in E05 — the contrast gate asserts the geometry floors it can see, but does not define them. `reed-grid-layout` and `reed-tile-anatomy` govern there.
- **The lit state's behaviour.** This epic ships the `stockLit` colours and proves they survive grayscale. The `Listener.onPointerDown` trigger, the 120ms minimum hold, the ordering (haptic → `setState` → TTS), and the stuck-lit timeout are tile work in E05.
- **Show mode.** `showGround`, `showInk`, and `showStandingLine` are tokens here and are in the gate. The poster screen, the fitted 32–140 sizing, and the `TextHeightBehavior` metric fix are E06.
- **The settings screen.** T03 owns reading and writing the palette and HC polarity preference; the UI that presents them is settings work, and the versioned JSON settings file itself belongs to the data layer.
- **Goldens.** Deliberately absent, permanently. Nothing in E02 or anywhere else adds `matchesGoldenFile`, `--update-goldens`, or a golden package — `reed-golden-testing` carries the full argument, and the contrast gate is the replacement.
