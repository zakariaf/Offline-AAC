# E02-T03 — Theme wiring and the palette switcher

| | |
|---|---|
| **Epic** | E02 — Design system in code |
| **Status** | Done |
| **Size** | M |
| **Depends on** | E02-T01, E02-T02 |
| **Blocks** | E01-T06, E02-T04, E05-T01, E08-T03 |

**Skills:** `reed-theming-code` · `reed-colour-system` · `reed-riverpod-usage` · `reed-motion-policy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

The four palettes exist as measured values after E02-T01 and E02-T02; nothing on screen reads them yet. This task is the wiring that carries an already-chosen colour to a pixel — and the switcher that lets a user reach high contrast at all. `MediaQuery.highContrastOf` is iOS-only and always false on Android (`dart:ui`'s `AccessibilityFeatures.highContrast` documents *"Only supported on iOS"*), so on the target platform the in-app switcher is not a convenience: it is the only mechanism that works. Get this wrong and an HC user has no HC, and nobody will ever tell you — a user who cannot speak does not file a bug report.

## Scope

### 1. `AacTheme extends ThemeExtension<AacTheme>`

The semantic tier. Fields, exactly these names: `ground`, `container`, `ink`, `inkDim`, `keyline`, `focus`, `stocks`, `stocksLit`, `showGround`, `showInk`, `showStandingLine`, `keylineWidth`, `keylineLitWidth`, `usesStocks`, plus the `palette` the theme was built from. Widgets read the semantic tier only; a widget that reaches for `Prim.inkT89` has hardcoded the dark palette.

Stock reads go through accessors so no widget ever branches on the palette:

```dart
Color stock(Stock s)    => usesStocks ? stocks[s.index]    : ground;
Color stockLit(Stock s) => usesStocks ? stocksLit[s.index] : ink;
Color inkOn(Stock s, {bool lit = false}) => usesStocks ? ink : (lit ? ground : ink);
```

`of` asserts, never falls back:

```dart
static AacTheme of(BuildContext context) {
  final AacTheme? t = Theme.of(context).extension<AacTheme>();
  assert(t != null, 'AacTheme missing. Build ThemeData via aacThemeData().');
  return t!;
}
```

A `?? AacTheme.fallback()` would silently ship a palette no test has verified — the exact failure the extension exists to prevent.

`lerp` is a step function, with the comment, because it reads as an unfinished implementation and the next reader will "fix" it:

```dart
// Step function, deliberately. Reed animates nothing (see reed-motion-policy), so
// there is nothing to interpolate. Not `return this`: if a theme change ever did
// animate, `this` would never arrive at the new palette; `t < 0.5` lands on the
// correct endpoint at both ends.
@override
AacTheme lerp(covariant AacTheme? other, double t) => t < 0.5 ? this : (other ?? this);
```

`copyWith` is still mandatory — it is an abstract interface member and omitting it will not compile.

The four instances: `kPaper`, `kInk`, `kHcInk`, `kHcPaper`, plus `kAllThemes` so tests iterate every palette. HC sets `usesStocks: false`, `keylineWidth: 3.0` (the keyline *is* the tile), and fills `stocks` / `stocksLit` with `[ground × 4]` / `[ink × 4]` — the lit state becomes a full inversion, the only signal available at 19.43:1, and the user opted in.

### 2. `aacThemeData(AacPalette palette) → ThemeData`

Hand-author the `ColorScheme`. **Never `ColorScheme.fromSeed`.** Its per-role overrides are applied post-hoc and do not propagate: overriding `surface` does not regenerate `surfaceContainerHigh`, which stays seed-derived. Keep the standard M3 role names so Material widgets theme themselves — the type-to-speak field is a Material `TextField` and reads `surfaceContainerHighest`, `onSurfaceVariant`, `outline`, and `error` on its own.

```dart
final Brightness b = switch (t.palette) {
  AacPalette.paper || AacPalette.hcPaper => Brightness.light,
  AacPalette.ink   || AacPalette.hcInk   => Brightness.dark,
};

ColorScheme(
  brightness: b,
  primary: t.ink, onPrimary: t.ground,
  secondary: t.inkDim, onSecondary: t.ground,
  error: t.stocks[Stock.oxblood.index], onError: t.ink,
  surface: t.ground, onSurface: t.ink,
  surfaceContainer: t.container, surfaceContainerHighest: t.container,
  onSurfaceVariant: t.inkDim, outline: t.keyline, outlineVariant: t.keyline,
)
```

`error` maps to the oxblood stock, not red. There is no red anywhere in Reed; `error` still has to be *something*, so it gets the stock nearest in intent.

`Brightness` comes from the palette, never from `MediaQuery.platformBrightness` — the palette is the source of truth and the system setting must not silently override an explicit choice.

Motion switches inside `aacThemeData`, all of them:

```dart
splashFactory: NoSplash.splashFactory,
splashColor: const Color(0x00000000),
highlightColor: const Color(0x00000000),
pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
  TargetPlatform.android: _NoTransitions(), TargetPlatform.iOS: _NoTransitions(),
}),
```

### 3. `MaterialApp` wiring

```dart
MaterialApp(
  theme: aacThemeData(current),
  themeAnimationStyle: AnimationStyle.noAnimation,
  home: const BoardScreen(),
)
```

`MaterialApp` mounts an `AnimatedTheme` and interpolates `ThemeData` over `kThemeAnimationDuration` (200ms) by default. The step-function `lerp` only stops one of three machines: without `themeAnimationStyle`, the tiles *snap* at the midpoint while the `ColorScheme` crossfades around them — worse than either behaviour alone.

### 4. The switcher

Three positions, four palettes: `paper → ink → high contrast → paper`. HC **polarity** (`hcInk` / `hcPaper`) is a set-once settings preference, `ink` default — never a fourth cycle position. A shutdown user needs one tap to produce one predictable next state; four positions makes the switcher a puzzle at the worst possible moment.

One tap from the main screen. The control is a `GestureDetector`, not an `InkWell` — `InkResponse.updateHighlight()` independently creates an `InkHighlight` with a 200ms pressed fade that `NoSplash.splashFactory` never touches.

State: a plain `Notifier<...>` behind a `NotifierProvider` in `lib/providers.dart`, writing through the same versioned JSON settings file the rest of the app's preferences use. No `StateProvider`, no `family`, no `@riverpod` codegen. Provider count going up is a smell, not progress.

The platform flag is read opportunistically, from `BuildContext`, never gated on:

```dart
// WRONG — dead code on Android. HC becomes unreachable for every real user.
if (MediaQuery.highContrastOf(context)) { palette = AacPalette.hcInk; }

// RIGHT — the user's explicit choice wins; the platform flag can only nudge
// the initial default, and only where the platform actually reports it.
final AacPalette effective = savedPalette
    ?? (MediaQuery.highContrastOf(context) ? hcPolarityPref : AacPalette.ink);
```

`highContrastOf` / `boldTextOf` / `textScalerOf` are read at build time in the widget and never routed through Riverpod. `MediaQuery` is already an `InheritedWidget` with correct-by-construction invalidation; pushing those through app state trades a compiler-guaranteed rebuild for a manual sync that is stale for one frame. **App state via Riverpod; platform/a11y state via `BuildContext`.**

### 5. Restore before first paint

Load the saved palette and the HC polarity preference **before the first frame** — `runApp` receives the restored value, not a default corrected a frame later. A flash of the wrong polarity is a sudden large luminance change: exactly the event the animation ban exists to prevent, delivered to a user in a shutdown. Not `shared_preferences` — its read is async and arrives after first paint, and its native storage fails silently rather than loudly.

An unknown or corrupt palette name falls back to `AacPalette.ink` explicitly and visibly, never to a null that leaves `AacTheme.of` asserting on a device with no debugger attached.

### Out of scope

- Choosing or re-deriving any hex, and any contrast verification of a new pairing (E02-T01/E02-T02 own the values; `scripts/contrast.py` owns the check).
- Typography and the type scale.
- The settings screen itself — this task only needs the HC-polarity value readable and a place to persist the palette.
- Show mode's poster theme (`showGround` / `showInk` / `showStandingLine` are carried as tokens here; the screen that uses them is E05).
- `dynamic_color`, `DynamicColorBuilder`, `CorePalette.of`, a DTCG/Style Dictionary token pipeline. All permanently rejected; do not add them "just to try".

## Acceptance criteria

- [ ] `grep -rn 'fromSeed\|dynamic_color\|DynamicColorBuilder\|CorePalette' lib/` returns nothing.
- [ ] `! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'` passes — the only literals outside `tokens.dart` are the transparent `0x00000000` splash/highlight values, which live in `tokens.dart`'s theme builder or are excluded by that same path.
- [ ] A test iterates `kAllThemes` and asserts every field is non-null and every `stocks` / `stocksLit` list has length 4.
- [ ] A test asserts both `lerp` endpoints: `kInk.lerp(kPaper, 0.0) == kInk`, `kInk.lerp(kPaper, 1.0) == kPaper`, and `kInk.lerp(null, 1.0) == kInk`.
- [ ] A test asserts `aacThemeData(AacPalette.paper).brightness == Brightness.light` and `aacThemeData(AacPalette.hcInk).brightness == Brightness.dark`, with `platformBrightness` overridden to the opposite in the harness — the palette wins.
- [ ] A test asserts `aacThemeData(p).colorScheme.surfaceContainerHighest == AacTheme.of(...).container` for all four palettes, and that `error` equals the oxblood stock value.
- [ ] `AacTheme.of` on a context with no extension trips its assert in debug (`expect(() => AacTheme.of(ctx), throwsAssertionError)`).
- [ ] A widget test taps the switcher three times from `paper` and observes `paper → ink → hc(polarity) → paper`, using `pump()` only — never `pumpAndSettle()`.
- [ ] After each switcher tap and one `pump()`, `expect(tester.binding.hasScheduledFrame, isFalse)` — a scheduled frame means something animates.
- [ ] A widget test with `highContrast: true` in `MediaQueryData` and a saved palette of `paper` renders `paper`, not HC: the platform flag never overrides an explicit choice.
- [ ] A test asserts `hcInk` / `hcPaper` have `usesStocks: false`, `keylineWidth == 3.0`, and that `stock(Stock.tan) == ground` / `stockLit(Stock.tan) == ink` for both.
- [ ] A test feeds a corrupt palette name to the settings loader and asserts the result is `AacPalette.ink`, not null and not a throw.
- [ ] `dart analyze` is clean; `flutter test` is green.

## Traps

- **`fromSeed` with "just a couple of overrides."** The overrides are post-hoc and do not propagate — `surface: t.ground` leaves `surfaceContainerHigh`, `surfaceDim`, `surfaceBright` seed-derived, and half the roles quietly fight the other half. There is no partial version of this decision. State every role or own the seams with the ~38 you didn't.
- **Inventing `ColorScheme` roles, or bypassing them with a bare colour on a Material widget.** Then the `TextField` needs a hand-patched `InputDecoration` that drifts out of sync with the palette on the next change. Correct role names mean zero fighting.
- **The step-function `lerp` reads as unfinished.** Someone — possibly you, in six weeks — will "complete" it into a `Color.lerp` cascade, and re-open the boilerplate bug where a new field is added and not lerped. The comment is not optional. And do not simplify it to `return this`: if a theme change ever did animate, `this` never arrives at the new palette.
- **`themeAnimationStyle` omitted.** The step `lerp` alone gives you the worst of both: tiles snap at t=0.5 while `AnimatedTheme` crossfades the `ColorScheme` around them for 200ms. Three machines animate a theme change by default; you must kill all three.
- **`NoSplash.splashFactory` believed to be enough.** It kills the splash only. `InkResponse.updateHighlight()` makes its own `InkHighlight` with a 200ms fade the factory never sees. Use `GestureDetector`, not `InkWell` — the theme-root transparencies are belt-and-braces for Material widgets that slip through elsewhere, not permission.
- **Gating HC on `MediaQuery.highContrastOf`.** It is always false on Android. The branch is dead code, HC is unreachable for every real user, and the tester on an iPhone will never see it. Read the flag only to nudge the *initial* default.
- **Routing `highContrast` / `boldText` / `textScaler` through a provider.** One frame of staleness in the one area where being wrong is total failure, in exchange for losing a compiler-guaranteed rebuild. If a provider is about to expose one of these, stop.
- **`shared_preferences` for the palette.** Async read → first paint happens on the default → the polarity flashes one frame later. That flash is precisely the sudden luminance change the animation ban exists to prevent, and it lands on someone mid-shutdown.
- **Deriving `Brightness` from `MediaQuery.platformBrightness`.** The system dark-mode setting then silently overrides an explicit palette choice, and the user's tap appears to do nothing.
- **A token set in three of four palettes.** `kHcPaper` is the one nobody exercises by hand. That is a palette-specific crash waiting for the one user who picked it — add the field to all four and let `kAllThemes` prove it.
- **`inkDim` creeping onto a tile label.** WCAG blesses it at 7.94:1; APCA rates it Lc −55.7, correctly, as secondary. Chrome only.
- **Adding a fourth switcher position for HC polarity** because it "feels more discoverable". It makes the one control a shutdown user needs into a puzzle. Polarity is a set-once settings preference.
- **`pumpAndSettle()` in the switcher test.** It waits out animations that must not exist, carries a 10-minute default timeout, and truncates its stack trace — so it converts a real animation bug into flake with an unreadable failure. `pump()`.
- **A `?? AacTheme.fallback()` added to silence a red test.** It ships a palette no test has ever verified to a device with no debugger and no telemetry. Loud in debug beats wrong in the field.

## Files

- `lib/ui/core/tokens.dart` — adds `AacTheme`, `kPaper` / `kInk` / `kHcInk` / `kHcPaper`, `kAllThemes`, `aacThemeData()`, `_NoTransitions`. The only file permitted a colour literal.
- `lib/providers.dart` — the palette `NotifierProvider` and its settings-file read/write.
- `lib/main.dart` — restore before `runApp`; `MaterialApp` with `theme:` and `themeAnimationStyle: AnimationStyle.noAnimation`.
- `lib/ui/widgets/palette_switcher.dart` — the three-position control.
- `test/ui/theme_test.dart` — `kAllThemes` iteration, `lerp` endpoints, `ColorScheme` role mapping, brightness, HC collapse, `of` assert.
- `test/ui/palette_switcher_test.dart` — the cycle, `hasScheduledFrame`, the `highContrast: true` non-override, corrupt-name fallback.

## Done when

`flutter test` is green, the `Color(0x` and `fromSeed` greps return nothing, and three taps on the switcher from a cold start walk `paper → ink → high contrast → paper` with the choice surviving a restart and no frame scheduled after any of them.


---

## What actually happened

Built: hand-authored ColorScheme (never fromSeed), the AacTheme ThemeExtension with a step-lerp, the three-position cycle, and NoSplash at the theme root. highContrastOf is read opportunistically, never gated on. Covered by the startup tests.
