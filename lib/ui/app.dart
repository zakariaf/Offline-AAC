import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/ui/board/board_screen.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';

/// The palette restored from the versioned JSON settings file, read **before**
/// `runApp` and injected by overriding this provider on the root
/// `ProviderScope`.
///
/// It is an override rather than an async read inside the widget tree because a
/// value that lands one frame late paints the wrong polarity first: a sudden
/// large luminance change, delivered to someone in a shutdown, which is exactly
/// the event the animation ban exists to prevent.
///
/// The default is [AacPalette.ink] — the same value a corrupt or unreadable
/// settings file falls back to.
final Provider<AacPalette> initialPaletteProvider = Provider<AacPalette>(
  (ref) => AacPalette.ink,
);

/// Which polarity the switcher's third position lands on. Overridden from the
/// settings file the same way as [initialPaletteProvider].
final Provider<AacPalette> initialHcPolarityProvider = Provider<AacPalette>(
  (ref) => AacPalette.hcInk,
);

/// [AacPalette] for a persisted name.
///
/// An unknown or corrupt name falls back to [AacPalette.ink] explicitly, never
/// to a null that would leave `AacTheme.of` asserting on a device with no
/// debugger attached.
AacPalette paletteFromName(String? name) => switch (name) {
  'paper' => AacPalette.paper,
  'ink' => AacPalette.ink,
  'hcInk' => AacPalette.hcInk,
  'hcPaper' => AacPalette.hcPaper,
  _ => AacPalette.ink,
};

/// The persisted name for [palette]. Inverse of [paletteFromName].
String paletteName(AacPalette palette) => palette.name;

/// High-contrast polarity: a set-once preference, never a switcher position.
class HcPolarityController extends Notifier<AacPalette> {
  @override
  AacPalette build() => ref.watch(initialHcPolarityProvider);

  /// The polarity in force.
  AacPalette get polarity => state;

  /// Must be one of the two HC palettes — this is a polarity, not a palette
  /// choice.
  set polarity(AacPalette value) {
    assert(
      value == AacPalette.hcInk || value == AacPalette.hcPaper,
      'HC polarity must be hcInk or hcPaper, got $value.',
    );
    state = value;
  }
}

/// The polarity the switcher's "high contrast" position resolves to.
final NotifierProvider<HcPolarityController, AacPalette> hcPolarityProvider =
    NotifierProvider<HcPolarityController, AacPalette>(
      HcPolarityController.new,
    );

/// The live palette. Settings drives it through the `palette` setter; the
/// switcher through [cycle].
class PaletteController extends Notifier<AacPalette> {
  @override
  AacPalette build() => ref.watch(initialPaletteProvider);

  /// Advance the switcher one position: `paper -> ink -> high contrast`.
  ///
  /// Three positions over four palettes, which looks like an oversight and is
  /// not. HC polarity is a settings preference, so the third position resolves
  /// through [hcPolarityProvider]: a shutdown user needs one tap to produce one
  /// predictable next state, and a fourth position makes the switcher a puzzle
  /// at the worst possible moment.
  void cycle() {
    state = switch (state) {
      AacPalette.paper => AacPalette.ink,
      AacPalette.ink => ref.read(hcPolarityProvider),
      AacPalette.hcInk || AacPalette.hcPaper => AacPalette.paper,
    };
  }

  /// The palette in force.
  AacPalette get palette => state;

  /// Set the palette outright — the settings screen's path, and the restore
  /// path's if it ever needs to correct after first paint.
  set palette(AacPalette value) => state = value;
}

/// The palette in force. Everything visual derives from this.
final NotifierProvider<PaletteController, AacPalette> paletteProvider =
    NotifierProvider<PaletteController, AacPalette>(PaletteController.new);

/// The tokens for the palette in force, for code that is off the widget tree.
/// Widgets read `AacTheme.of(context)` instead.
final Provider<AacTheme> aacThemeProvider = Provider<AacTheme>(
  (ref) => themeFor(ref.watch(paletteProvider)),
);

/// Low stimulus DERIVES the theme; it never writes one. `usesStocks: false`
/// collapses every tile to `ground` behind its keyline — the dyed stocks go —
/// and turning the mode off restores them, because nothing was overwritten. A
/// pure function, no provider: provider count going up is a smell, not progress.
AacTheme effectiveTheme(AacTheme base, {required bool lowStimulus}) =>
    lowStimulus ? base.copyWith(usesStocks: false) : base;

/// Low stimulus surfaces the 2-column layout. It DERIVES this from `lowStimulus`
/// and never writes `grid_size`, so a user whose standing preference is already
/// the large layout is not silently reset on the way out.
GridSize effectiveGridSize(ReedSettings settings) =>
    settings.lowStimulus ? GridSize.large : settings.gridSize;

/// Returns the child unchanged. Route transitions are animations.
class _NoTransitions extends PageTransitionsBuilder {
  const _NoTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

/// The five Reed roles mapped onto the M3 slots Material widgets reach for.
///
/// Keeping the standard slot names is what lets the type-to-speak `TextField`
/// find [AacType.field] on `bodyLarge` with no per-widget style patching. Slots
/// Reed has no role for are left to Material's defaults and nothing reads them
/// — adding a sixth role to fill one in would erode the 1:9.3 scale jump that
/// carries the whole aesthetic.
const TextTheme _kTextTheme = TextTheme(
  titleMedium: AacType.tile,
  bodyLarge: AacType.field,
  bodyMedium: AacType.standing,
  labelLarge: AacType.meta,
  labelMedium: AacType.meta,
  labelSmall: AacType.meta,
);

/// The `ThemeData` for [palette].
ThemeData aacThemeData(AacPalette palette) {
  final t = themeFor(palette);

  // Derived from the palette, never from `MediaQuery.platformBrightness`: the
  // palette is the source of truth, and a system setting must not silently
  // override a choice the user made explicitly.
  final brightness = switch (t.palette) {
    AacPalette.paper || AacPalette.hcPaper => Brightness.light,
    AacPalette.ink || AacPalette.hcInk => Brightness.dark,
  };

  // Hand-authored, role by role. Never `ColorScheme.fromSeed`: its per-role
  // overrides are applied post-hoc and do NOT propagate, so overriding
  // `surface` leaves `surfaceContainerHigh` seed-derived — and the TextField
  // reads it. "Seed plus a few overrides" means owning the roles chosen AND
  // every seam with the ones that were not.
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.ink,
    onPrimary: t.ground,
    secondary: t.inkDim,
    onSecondary: t.ground,
    // There is no red anywhere in Reed. `error` still has to be something, so
    // it gets the stock nearest in intent — via the accessor, so HC's
    // stock collapse applies here too.
    error: t.stock(Stock.oxblood),
    onError: t.ink,
    surface: t.ground,
    onSurface: t.ink,
    surfaceContainer: t.container,
    surfaceContainerHigh: t.container,
    surfaceContainerHighest: t.container,
    onSurfaceVariant: t.inkDim,
    outline: t.keyline,
    outlineVariant: t.keyline,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.ground,
    fontFamily: AacType.family,
    textTheme: _kTextTheme,
    focusColor: t.focus,
    // The ink ripple is an animation and is on by default on every InkWell, so
    // "we don't animate" becomes false the moment a Material button lands in
    // settings. NoSplash kills only the splash: InkResponse.updateHighlight()
    // independently creates an InkHighlight with a 200ms pressed fade that the
    // splash factory never touches, which is why the two transparent colours
    // are here as well. None of this is permission to use InkWell — tiles use
    // GestureDetector.
    splashFactory: NoSplash.splashFactory,
    splashColor: Prim.clear,
    highlightColor: Prim.clear,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: _NoTransitions(),
        TargetPlatform.iOS: _NoTransitions(),
      },
    ),
    extensions: <ThemeExtension<dynamic>>[t],
  );
}

/// The app.
class ReedApp extends ConsumerWidget {
  const ReedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    final lowStimulus = ref.watch(
      settingsProvider.select((s) => s.lowStimulus),
    );
    final base = aacThemeData(palette);
    // Apply the low-stimulus desaturation to the AacTheme extension only — the
    // ColorScheme and every other slot stay. On the first frame, restored in
    // main() before runApp, so a board in low stimulus never paints 12 dyed
    // tiles and then reflows to undyed ones.
    final theme = base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        effectiveTheme(themeFor(palette), lowStimulus: lowStimulus),
      ],
    );
    return MaterialApp(
      title: 'Reed',
      theme: theme,
      // `darkTheme` is deliberately unset. With it null, MaterialApp uses
      // `theme` at every platform brightness — which is the point: the palette
      // decides, not the system.
      //
      // MaterialApp mounts an AnimatedTheme and interpolates ThemeData over
      // kThemeAnimationDuration (200ms) otherwise. AacTheme.lerp being a step
      // function is not enough on its own: without this the tiles would snap at
      // the midpoint while the ColorScheme crossfaded around them, which is
      // worse than either behaviour alone.
      themeAnimationStyle: AnimationStyle.noAnimation,
      // BoardScreen is still a stub, so there is nothing to mount yet.
      home: const BoardScreen(),
    );
  }
}
