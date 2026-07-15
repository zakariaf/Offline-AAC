---
name: reed-theming-code
description: Wires Reed's four palettes into Flutter — hand-authored ColorScheme, the AacTheme ThemeExtension and its step-function lerp, the palette switcher, and the fromSeed/dynamic_color ban. Use when editing ThemeData or aacThemeData(); adding or renaming a token; wiring palette switching or restoring the saved palette before first paint; touching DynamicColorBuilder or MediaQuery.highContrastOf. Not for choosing which colour a role gets or verifying its contrast — this covers only the wiring that carries an already-chosen value.
---

# Reed theming in Flutter

Four palettes: `paper`, `ink`, `hcInk`, `hcPaper`. One `ThemeExtension` (`AacTheme`) carries every Reed-specific token; a hand-authored `ColorScheme` carries the M3 roles so Material widgets theme themselves. `lib/ui/core/tokens.dart` is the only file permitted a colour literal.

## Never `ColorScheme.fromSeed`

`fromSeed`'s `tonalSpot` scheme pins neutral chroma at HCT 4 and derives every hue from the seed. It is a machine for producing the generic Material look, which is exactly the appearance this product exists to avoid. Reed's neutrals are warm on purpose (OKLCH hue 65–85, chroma 0.006 → 0.012 rising with lightness) — a seed cannot express that, because flat chroma across the ramp is what makes warm darks read as brown.

The decisive failure is mechanical, not aesthetic: **`fromSeed`'s per-role overrides are applied post-hoc and do not propagate.** Overriding `surface` does not regenerate `surfaceContainerHigh` — it stays seed-derived. "Seed plus a few overrides" means owning the ~9 roles chosen *and* every seam with the ~38 not chosen. Owning one thing is cheaper and testable.

```dart
// WRONG — surfaceContainerHigh, surfaceDim, surfaceBright etc. stay seed-derived.
ColorScheme.fromSeed(seedColor: Prim.tanT33, surface: t.ground)

// RIGHT — every role stated. Unstated roles get ColorScheme's own defaults,
// not a seed's opinion, and nothing in the app reads them.
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

**Keep the M3 role names.** Do not invent `ColorScheme` roles or bypass them with a bare colour on a Material widget. The type-to-speak field is a Material `TextField`; it reads `surfaceContainerHighest`, `onSurfaceVariant`, `outline`, and `error` on its own. Naming the roles correctly means the field themes with zero fighting — no per-widget `InputDecoration` colour patching that drifts out of sync with the palette on the next change.

Note `error` maps to the oxblood stock, not red. There is no red anywhere in Reed; `error` still has to be *something*, so it gets the stock nearest in intent.

## `dynamic_color` / Material You is rejected — permanently

Do not add the `dynamic_color` package. Do not call `DynamicColorBuilder`. Do not read `CorePalette.of` or platform wallpaper colours. Two independent reasons, both fatal:

1. **Wallpaper-derived palettes are untestable at build time.** Every contrast guarantee CI provides evaporates the moment the palette is computed on-device from an image nobody has seen. With no telemetry, a palette that fails contrast in the field is never reported by a user who, by definition, cannot speak at the moment it fails.
2. **Colour stability is part of the retrieval mechanism.** Tiles are found by fixed position with category hue as a redundant assist. Colours that shift because the user changed their wallpaper break the position/colour learning the product rests on.

Forfeiting Material You is the feature, not the cost.

## Tokens: two tiers, measured names

`Prim` holds primitives named `<family><tone>`, where tone is the **measured OKLCH lightness ×100** — `Prim.inkT89` is `#DCD9D3` at L 0.885. Measured names stay true forever and invert correctly across themes by construction.

Banned naming, each for a specific reason:

| Bad | Why it rots |
|---|---|
| `grey700` | Rank scales have no room for insertion, and "500 is the main one" is a lie in dark mode |
| `colorDarkGrey` | Appearance names invert catastrophically — `darkGrey` is the *lightest* colour in dark mode |
| `brandPrimary` | Dies with the brand |

`AacTheme` is the semantic tier: `ground`, `container`, `ink`, `inkDim`, `keyline`, `focus`, `stocks`, `stocksLit`, `showGround`, `showInk`, `showStandingLine`, `keylineWidth`, `keylineLitWidth`, `usesStocks`. Widgets read the semantic tier only. A widget that reaches for `Prim.inkT89` has hardcoded the dark palette.

Enforce the literal ban rather than promising it. Every design system that rotted, rotted by someone typing a hex at 11pm:

```bash
! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'
```

`inkDim` is chrome only and is **never** a tile label — at APCA Lc −55.7 it is correctly rated secondary even though WCAG calls it 7.94:1.

## `AacTheme.lerp` is a step function — this is not a bug

```dart
@override
AacTheme lerp(covariant AacTheme? other, double t) => t < 0.5 ? this : (other ?? this);
```

Animation is banned, so there is nothing to interpolate. The step function deletes ~13 lines of `Color.lerp` boilerplate and, with it, the recurring bug where someone adds a field and forgets to lerp it. Leave a comment saying so — it reads as an unfinished implementation to anyone who does not know the ban exists, and the next reader will "fix" it.

**It is deliberately not `return this`.** If a theme change ever did animate, `this` would never arrive at the new palette; `t < 0.5` lands on the correct endpoint at both ends. CI asserts both endpoints.

`copyWith` is still mandatory — it is an abstract interface member and omitting it will not compile.

`of` asserts rather than falling back:

```dart
static AacTheme of(BuildContext context) {
  final AacTheme? t = Theme.of(context).extension<AacTheme>();
  assert(t != null, 'AacTheme missing. Build ThemeData via aacThemeData().');
  return t!;
}
```

A `?? AacTheme.fallback()` would silently ship a palette no test has ever verified — the exact failure the extension exists to prevent. Loud in debug beats wrong in the field.

## High contrast drops the stocks

`hcInk` and `hcPaper` run 19.43:1 (`#FFFCF7` on `#0B0906`, and its inverse). At that contrast the ink cannot afford a tinted ground, and a tone step is precisely what an HC user cannot perceive. So HC sets `usesStocks: false`, `keylineWidth: 3.0` — the keyline *is* the tile — and fills `stocks`/`stocksLit` with `[ground × 4]` / `[ink × 4]`. The lit state becomes a full inversion, the only signal available at that contrast, and the user opted in.

Route every stock read through the accessors so no widget branches on the palette:

```dart
Color stock(Stock s)    => usesStocks ? stocks[s.index]    : ground;
Color stockLit(Stock s) => usesStocks ? stocksLit[s.index] : ink;
Color inkOn(Stock s, {bool lit = false}) => usesStocks ? ink : (lit ? ground : ink);
```

Warm HC costs 1.9 Lc out of 108 versus pure `#FFF`/`#000` (±106.0 vs ±107.9) — 1.8%, for an app that stays recognisably itself. But HC is a medical accommodation: if a user reports warm HC is insufficient, ship a pure `#FFF`/`#000` escape hatch and do not argue.

## Switching: three positions, four palettes

`paper → ink → high contrast → paper`. HC **polarity** is a set-once settings preference (`ink` default), not a fourth cycle position. A shutdown user needs one tap to produce one predictable next state; four positions makes the switcher a puzzle at the worst possible moment.

**`MediaQuery.highContrastOf` is iOS-only and always false on Android** (`dart:ui`'s `AccessibilityFeatures.highContrast` documents *"Only supported on iOS"*). The in-app switcher is therefore not a convenience — on the target platform it is the only mechanism that works. Read the flag opportunistically, never gate on it:

```dart
// WRONG — dead code on Android. HC becomes unreachable for every real user.
if (MediaQuery.highContrastOf(context)) { palette = AacPalette.hcInk; }

// RIGHT — the user's explicit choice wins; the platform flag can only nudge
// the initial default, and only where the platform actually reports it.
final AacPalette effective = savedPalette
    ?? (MediaQuery.highContrastOf(context) ? hcPolarityPref : AacPalette.ink);
```

Read platform a11y flags (`highContrastOf`, `boldTextOf`) from `BuildContext` at build time. `MediaQuery` is already an `InheritedWidget` with correct-by-construction invalidation; pushing those flags through app state trades a compiler-guaranteed rebuild for a manual sync that is stale for one frame, in the one area where being wrong is total failure. App state comes from the state layer; platform a11y state comes from context.

## Restore the palette before first paint

Persist the palette choice and the HC polarity preference, and load them **before the first frame** — `runApp` must receive the restored value, not a default that is corrected a frame later. A flash of the wrong polarity is a sudden large luminance change: exactly the event the animation ban exists to prevent, delivered to a user in a shutdown.

Do not put the palette in `shared_preferences`. It goes in the same versioned JSON settings file the rest of the app's preferences use — a `shared_preferences` read is async and arrives after first paint, and its native storage has traps that make the failure silent rather than loud.

Restoring an unknown or corrupt palette name must fall back to `AacPalette.ink` explicitly and visibly, never to a null that leaves `AacTheme.of` asserting on a device with no debugger attached.

## Belt and braces on the animation ban

Three separate machines animate a theme change by default. The step-function `lerp` only stops one of them; alone, it produces a *pop* while `ColorScheme` crossfades around it.

```dart
MaterialApp(
  theme: aacThemeData(current),
  themeAnimationStyle: AnimationStyle.noAnimation, // MaterialApp mounts
  home: const BoardScreen(),                       // AnimatedTheme and
)                                                  // interpolates ThemeData
                                                   // over kThemeAnimationDuration
                                                   // (200ms) otherwise.
```

And inside `aacThemeData`, because the ink ripple is an animation and is on by default on every `InkWell` — "we don't animate" becomes false the moment anyone uses a Material button:

```dart
splashFactory: NoSplash.splashFactory,
splashColor: const Color(0x00000000),
highlightColor: const Color(0x00000000),
pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
  TargetPlatform.android: _NoTransitions(), TargetPlatform.iOS: _NoTransitions(),
}),
```

Derive `Brightness` from the palette, never from `MediaQuery.platformBrightness` — the palette is the source of truth and the system setting must not silently override an explicit choice:

```dart
final Brightness b = switch (t.palette) {
  AacPalette.paper || AacPalette.hcPaper => Brightness.light,
  AacPalette.ink   || AacPalette.hcInk   => Brightness.dark,
};
```

## Adding a token

1. Add the primitive to `Prim` with its measured OKLCH tone in the name and a comment naming its role.
2. Add the field to `AacTheme`, to the constructor, and to `copyWith`. `lerp` needs no change — that is the point of the step function.
3. Set it in **all four** of `kPaper`, `kInk`, `kHcInk`, `kHcPaper`. `kAllThemes` exists so tests iterate every palette; a token set in three of four is a palette-specific crash waiting for the one user who picked the fourth.
4. If the token is text-on-something, keyline-on-something, or focus-on-something, add its pair to the contrast gate. A new colour with no gate entry is an unverified colour, and nothing in the field will ever report that it failed.

## No token pipeline

Do not add DTCG JSON, Style Dictionary, a codegen step, or a Figma sync. Those solve a designer/engineer handoff; here they are the same person. A JSON → codegen build step and a `node_modules` for ~30 colours buys a build failure mode to solve a problem that does not exist. Revisit only if a second person joins.
