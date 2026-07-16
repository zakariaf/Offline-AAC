import 'package:flutter/material.dart';
import 'package:offline_aac/model/aac_palette.dart';
import 'package:offline_aac/model/stock.dart';

export 'package:offline_aac/model/aac_palette.dart';
export 'package:offline_aac/model/stock.dart';

/// The four palettes. The switcher shows three positions
/// (`paper -> ink -> high contrast`); HC polarity is a settings preference,
/// not a fourth position — a user mid-shutdown needs one tap to produce one
/// predictable next state.
/// The four paper stocks, L-ascending.
///
/// Four, not twelve. Named, not numbered. The lightness stagger is the
/// colourblind fix: protan/deutan destroy the red-green axis, so hue alone
/// cannot separate four muted stocks. Staggering lightness instead measures
/// deutan OKLab dE x100 of 7.00 against an isoluminant alternative's 1.06 —
/// the same tile twice.
/// Colour primitives, named `<family><tone>` where tone is the **measured**
/// OKLCH lightness x100. `Prim.inkT89` is `#DCD9D3` at L 0.886.
///
/// This is the only file in the app permitted a colour literal. Every design
/// system that rotted, rotted by someone typing a hex at 11pm.
///
/// Measured names, not `grey700` (rank scales have no room for insertion) and
/// not `colorDarkGrey` (appearance names invert catastrophically — `darkGrey`
/// is the *lightest* colour in dark mode). A measured tone stays true forever
/// and inverts correctly across palettes by construction.
///
/// Nothing outside this file may read `Prim`. A widget that reaches for
/// `Prim.inkT89` has hardcoded the dark palette.
abstract final class Prim {
  // ---------------------------------------------------------------------
  // The warm neutral ramp — OKLCH hue 65-85, chroma 0.006 -> 0.012, chroma
  // RISING with lightness. Flat chroma across the ramp is what makes warm
  // darks read as muddy brown; shadows desaturate.
  //
  // Ink and paper are one family at different tones, deliberately. Warm reads
  // as lamplight and paper; cool reads as screen. For an app opened during a
  // shutdown, that connotation is the product.
  // ---------------------------------------------------------------------

  /// hcInk ground / hcPaper ink.
  static const Color inkT14 = Color(0xFF0B0906);

  /// `ink` ground.
  static const Color inkT19 = Color(0xFF171411);

  /// Show-mode ink. Light polarity always — a stranger reads the poster at
  /// arm's length.
  static const Color inkT20 = Color(0xFF1A140D);

  /// `ink` container — the type-to-speak field.
  static const Color inkT25 = Color(0xFF25211D);

  /// `paper` ink. Not `#000000`: warm-black on warm paper is letterpress;
  /// pure black on near-white is the clinical signal. It costs nothing
  /// legible — Lc +95.1 exceeds the Lc 90 "preferred for fluent text" bar.
  static const Color inkT26 = Color(0xFF27221D);

  /// `paper` inkDim, and the show-mode standing line.
  static const Color inkT45 = Color(0xFF5A544E);

  /// `paper` keyline.
  static const Color inkT53 = Color(0xFF6F6A64);

  /// `ink` keyline.
  static const Color inkT62 = Color(0xFF8A857F);

  /// `ink` inkDim.
  static const Color inkT74 = Color(0xFFAEAAA4);

  /// `ink` ink — capped at OKLCH L ~0.885 to eliminate halation bloom.
  ///
  /// The cap costs 24 Lc (23% of perceptual contrast) against `#FFFFFF`, which
  /// scores Lc -107.1 here versus this value's -82.9. Affordable because -82.9
  /// still clears the Lc 75 body-text floor and WCAG AAA with room. Halation is
  /// solved with ink luminance, NEVER with weight — heavier glyphs at high
  /// luminance contrast bloom more, not less.
  static const Color inkT89 = Color(0xFFDCD9D3);

  /// `paper` container — the type-to-speak field.
  static const Color inkT92 = Color(0xFFE5E3DD);

  /// `paper` ground. Not `#FFFFFF`: this is uncoated paper.
  static const Color inkT96 = Color(0xFFF4F2EE);

  /// hcInk ink / hcPaper ground, and the show-mode ground.
  ///
  /// Warm HC scores 19.43:1 / Lc +-106.0 against pure `#FFF`/`#000`'s 21.00:1 /
  /// +-107.9 — 1.9 Lc out of 108, a 1.8% delta, for an app that stays
  /// recognisably itself. HC is still a medical accommodation: if a user reports
  /// warm HC insufficient, ship a pure `#FFF`/`#000` escape hatch and do not
  /// argue.
  static const Color inkT99 = Color(0xFFFFFCF7);

  // ---------------------------------------------------------------------
  // Amber — the focus ring, and the only saturated colour in the app.
  //
  // High-luminance yellow earns its keep exactly once: a focus indicator is
  // supposed to grab, and it is the signal a keyboard or switch user cannot
  // afford to lose. It is not on the primary path — tiles are found by
  // position and hue — so it cannot pull the eye from the lower-centre arc.
  // ---------------------------------------------------------------------

  /// hcPaper focus.
  static const Color amberT36 = Color(0xFF5C3300);

  /// `paper` focus.
  static const Color amberT45 = Color(0xFF7A4A05);

  /// `ink` and hcInk focus.
  static const Color amberT88 = Color(0xFFFFD9A0);

  // ---------------------------------------------------------------------
  // The four stocks, dark polarity. Staggered OKLCH L 0.240 -> 0.375.
  //
  // The window is fully consumed: bounded above by *ink on stock >= 7:1* and
  // below by *stock separable from ground*. Never add a fifth stock or shift
  // one without re-deriving it.
  //
  // Each lit value is its stock stepped OKLCH L +-0.09 toward the ink — a
  // luminance step, never a chroma flood. The rejected chroma-only press state
  // scored 1.02:1 in colour and 1.015:1 in Android's Grayscale colour-
  // correction mode: literally invisible.
  // ---------------------------------------------------------------------

  static const Color oxbloodT24 = Color(0xFF2A1A1D);
  static const Color oxbloodT33 = Color(0xFF413033);
  static const Color slateT29 = Color(0xFF152C42);
  static const Color slateT37 = Color(0xFF2C435B);
  static const Color tanT33 = Color(0xFF4B2E14);
  static const Color tanT42 = Color(0xFF65462C);
  static const Color firT37 = Color(0xFF2E473F);
  static const Color firT47 = Color(0xFF466057);

  // ---------------------------------------------------------------------
  // The four stocks, light polarity. Staggered OKLCH L 0.791 -> 0.910.
  // ---------------------------------------------------------------------

  static const Color oxbloodT79 = Color(0xFFDDACB3);
  static const Color oxbloodT71 = Color(0xFFC19299);
  static const Color slateT83 = Color(0xFFB3CAE2);
  static const Color slateT74 = Color(0xFF99AFC6);
  static const Color tanT87 = Color(0xFFF2CCAF);
  static const Color tanT79 = Color(0xFFD6B194);
  static const Color firT91 = Color(0xFFCCE9DF);
  static const Color firT82 = Color(0xFFB1CDC3);

  /// Fully transparent. Used only to switch off Material's splash and
  /// highlight at the theme root.
  static const Color clear = Color(0x00000000);
}

/// The board plane's fixed geometry, in logical pixels.
///
/// Depth in Reed comes from tone and edge only — never shadow, blur, gradient,
/// or elevation — so these numbers carry compositional weight a shadow would
/// otherwise carry.
abstract final class Geom {
  /// Column gap. Unequal to [gapRow] on purpose.
  static const double gapColumn = 14;

  /// Row gap.
  static const double gapRow = 22;

  /// Side margin. A design choice on thumb-ergonomic and edge-slop grounds,
  /// NOT a platform requirement — Android's back-gesture bands pass taps
  /// through unharmed and these tiles are tap-only.
  static const double margin = 24;

  /// Tile corner radius. Radius-to-size of roughly 1:6 reads current; 8dp reads
  /// 2014 and 12-16dp reads generic Material card.
  ///
  /// At this radius with a 14/22dp gap, the negative space where four tiles
  /// meet forms a small four-pointed star, recurring at each of the six
  /// interior junctions. That is a designed element, not a leftover — which
  /// makes the gap:radius ratio a decision. Keep gap ~ 0.6-1.1 x radius, or the
  /// star degenerates into a slot or a blob.
  static const double tileRadius = 20;

  /// The type-to-speak field's height. It is the 13th cell: same radius, same
  /// keyline, same material, spanning 3 columns at the top.
  static const double fieldHeight = 72;

  /// Padding inside a tile, from its edge to its label.
  static const double tileInset = 16;

  /// The divergence tick's length — one hairline, top-right, drawn only when a
  /// phrase's spoken text differs from its label.
  static const double divergenceTick = 6;

  /// Gap between the tile's edge and the focus ring.
  ///
  /// The ring is drawn in the gutter, OUTSIDE the tile, never on it. Amber
  /// recoloured onto the tile's own keyline gives only 2.73:1 on changed pixels
  /// and fails SC 2.4.13's 3:1; in the gutter the changed pixels are
  /// ground -> ring, which clears 6.69-14.85:1 across every palette and needs
  /// no per-stock verification because it never touches a fill.
  static const double focusRingOffset = 2;

  /// The focus ring's stroke width.
  static const double focusRingWidth = 3;

  /// The focus ring's corner radius — [tileRadius] + [focusRingOffset], so the
  /// ring stays concentric with the tile it surrounds.
  static const double focusRingRadius = tileRadius + focusRingOffset;
}

/// The five type roles, set in Atkinson Hyperlegible Next.
///
/// Resist a sixth. Tile -> show is 1:5 at the top end and 15 -> 140 across the
/// app is 1:9.3. That spread *is* the aesthetic: this app cannot use motion, so
/// scale contrast is the loudest instrument left, and every additional role
/// erodes the jump that carries the whole thing.
///
/// Weight is frozen across all four palettes. Only the platform `boldText` flag
/// may move it. `wght` changes advance widths, so a weight that differs by
/// palette re-wraps a label on a theme switch — a reflow nobody sees and nobody
/// reports.
abstract final class AacType {
  /// The one typeface: variable, upright only, one `wght` axis (200-800). No
  /// `opsz`, no `GRAD`, no `ital`.
  ///
  /// Italic is a separate file and is not shipped, so `FontVariation('ital', 1)`
  /// silently no-ops and a "working" italic is impossible to spot in review.
  /// Never use italic anywhere — emphasise with weight or size, or not at all.
  ///
  /// `FontWeight` drives the `wght` axis on its own; never also pass a
  /// `FontVariation('wght', …)`, which double-drives one axis.
  static const String family = 'AtkinsonHyperlegibleNext';

  /// Tile label. Bottom-anchored, start-aligned.
  ///
  /// One uniform size for all 12 tiles. Variable line count is fine; variable
  /// size reads as broken, and auto-shrink is backwards — it makes the longest
  /// (most complex) phrase the smallest and overrides the user's own
  /// `TextScaler`.
  static const TextStyle tile = TextStyle(
    fontFamily: family,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.20,
    height: 1.15,
  );

  /// The standing line under the show-mode poster.
  static const TextStyle standing = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    // Deliberately 0 at 18pt, unlike every role above 17pt. Flutter's default
    // tracking is calibrated for roughly 14pt, so leaving this unset higher up
    // the scale would be doing the wrong thing rather than the neutral thing.
    letterSpacing: 0,
    height: 1.30,
  );

  /// The type-to-speak field.
  static const TextStyle field = TextStyle(
    fontFamily: family,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.30,
  );

  /// Chrome: `theme` - `edit` - `show` - `settings`.
  ///
  /// Authored lowercase in the string table — never a text transform and never
  /// `toLowerCase()` at render, or someone's name eventually gets lowercased.
  static const TextStyle meta = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.35,
  );

  /// Lower bound of the show-mode fitted size.
  static const double showSizeMin = 32;

  /// Upper bound of the show-mode fitted size.
  static const double showSizeMax = 140;

  /// The show-mode poster, at a size fitted between [showSizeMin] and
  /// [showSizeMax]. Start-aligned, ragged right.
  ///
  /// Never w700 here. Bold at 100pt closes the counters, and counter size is a
  /// real legibility factor — w500 at poster scale is both prettier and more
  /// legible than bold.
  static TextStyle show(double size) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: FontWeight.w500,
    // Hand-built optical sizing: the shipped face has one axis and no `opsz`,
    // so the rule is applied by hand — as size rises, weight falls and tracking
    // tightens. -0.02em is the floor; past it Atkinson's generous sidebearings
    // stop protecting letter separation, which is the single thing being paid
    // for in payload and width.
    letterSpacing: -0.02 * size,
    height: 0.98,
  );
}

/// Reed's semantic colour tier. Widgets read this and never [Prim].
///
/// Reached via [AacTheme.of], which asserts rather than falling back.
@immutable
class AacTheme extends ThemeExtension<AacTheme> {
  const AacTheme({
    required this.palette,
    required this.ground,
    required this.container,
    required this.ink,
    required this.inkDim,
    required this.keyline,
    required this.focus,
    required this.stocks,
    required this.stocksLit,
    required this.showGround,
    required this.showInk,
    required this.showStandingLine,
    required this.keylineWidth,
    required this.keylineLitWidth,
    required this.usesStocks,
  });

  /// Which palette this is. `Brightness` is derived from here, never from
  /// `MediaQuery.platformBrightness` — the palette is the source of truth and a
  /// system setting must not silently override an explicit choice.
  final AacPalette palette;

  /// The page.
  final Color ground;

  /// The type-to-speak field's fill.
  final Color container;

  /// Body ink. The only colour a tile label is ever drawn in.
  final Color ink;

  /// Chrome ink, and never a tile label: at APCA Lc -55.7 it is correctly rated
  /// secondary even though WCAG blesses it at 7.94:1.
  final Color inkDim;

  /// The hairline around a tile.
  final Color keyline;

  /// The focus ring — the app's only saturated colour.
  final Color focus;

  /// Indexed by [Stock.index]. Read through [stock], never directly: the
  /// accessor is what makes HC's [usesStocks] collapse work.
  final List<Color> stocks;

  /// Indexed by [Stock.index]. Read through [stockLit].
  final List<Color> stocksLit;

  /// Show mode is light polarity always, regardless of palette — a stranger
  /// reads the poster at arm's length in daylight. That is why it inverts.
  final Color showGround;

  /// Show-mode ink.
  final Color showInk;

  /// The line under the show-mode poster.
  final Color showStandingLine;

  /// The resting keyline.
  ///
  /// In HC this is a literal dp value: the keyline is promoted to a solid 3dp
  /// and *is* the tile, because the stocks drop out there entirely. Outside HC
  /// it is one *physical* pixel — `Border.all()`'s 1.0 logical px is 3 physical
  /// pixels on a modern phone, which reads as a table border rather than an
  /// engraved line. Call [keylineWidthOf]; it resolves the two cases so no
  /// widget branches on the palette.
  final double keylineWidth;

  /// The lit keyline, in logical pixels. Unlike [keylineWidth] this is dp in
  /// every palette.
  final double keylineLitWidth;

  /// False in HC. At 19.43:1 the ink cannot afford a tinted ground, and a tone
  /// step is precisely what an HC user cannot perceive — so HC drops the stocks
  /// entirely, the keyline becomes the tile, and the lit state becomes a full
  /// inversion. That is the only signal available at that contrast, and the
  /// user opted in.
  final bool usesStocks;

  /// The palette in scope.
  ///
  /// Asserts rather than falling back. A `?? AacTheme.fallback()` would
  /// silently ship a palette no test has ever verified — the exact failure this
  /// extension exists to prevent. Loud in debug beats wrong in the field.
  static AacTheme of(BuildContext context) {
    final t = Theme.of(context).extension<AacTheme>();
    assert(t != null, 'AacTheme missing. Build ThemeData via aacThemeData().');
    return t!;
  }

  /// A stock's resting fill.
  Color stock(Stock s) => usesStocks ? stocks[s.index] : ground;

  /// A stock's lit fill — the stock stepped OKLCH L +-0.09 toward the ink.
  Color stockLit(Stock s) => usesStocks ? stocksLit[s.index] : ink;

  /// The ink a label is drawn in on top of [stock], or of [stockLit] when
  /// [lit].
  Color inkOn(Stock s, {bool lit = false}) =>
      usesStocks ? ink : (lit ? ground : ink);

  /// The resting keyline in logical pixels, once the device pixel ratio is
  /// known: 0.333dp on a 3x device outside HC, a flat 3.0 inside it.
  double keylineWidthOf(double devicePixelRatio) =>
      usesStocks ? keylineWidth / devicePixelRatio : keylineWidth;

  @override
  AacTheme copyWith({
    AacPalette? palette,
    Color? ground,
    Color? container,
    Color? ink,
    Color? inkDim,
    Color? keyline,
    Color? focus,
    List<Color>? stocks,
    List<Color>? stocksLit,
    Color? showGround,
    Color? showInk,
    Color? showStandingLine,
    double? keylineWidth,
    double? keylineLitWidth,
    bool? usesStocks,
  }) => AacTheme(
    palette: palette ?? this.palette,
    ground: ground ?? this.ground,
    container: container ?? this.container,
    ink: ink ?? this.ink,
    inkDim: inkDim ?? this.inkDim,
    keyline: keyline ?? this.keyline,
    focus: focus ?? this.focus,
    stocks: stocks ?? this.stocks,
    stocksLit: stocksLit ?? this.stocksLit,
    showGround: showGround ?? this.showGround,
    showInk: showInk ?? this.showInk,
    showStandingLine: showStandingLine ?? this.showStandingLine,
    keylineWidth: keylineWidth ?? this.keylineWidth,
    keylineLitWidth: keylineLitWidth ?? this.keylineLitWidth,
    usesStocks: usesStocks ?? this.usesStocks,
  );

  /// A step function, and this is not an unfinished implementation.
  ///
  /// Animation is banned here, so there is nothing to interpolate. The step
  /// deletes ~13 lines of `Color.lerp` boilerplate and, with it, the recurring
  /// bug where someone adds a field and forgets to lerp it.
  ///
  /// It is deliberately not `return this`: if a palette change ever did
  /// animate, `this` would never arrive at the new palette. `t < 0.5` lands on
  /// the correct endpoint at both ends.
  @override
  AacTheme lerp(covariant AacTheme? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

/// Dark polarity.
const AacTheme kInk = AacTheme(
  palette: AacPalette.ink,
  ground: Prim.inkT19,
  container: Prim.inkT25,
  ink: Prim.inkT89,
  inkDim: Prim.inkT74,
  keyline: Prim.inkT62,
  focus: Prim.amberT88,
  stocks: <Color>[Prim.oxbloodT24, Prim.slateT29, Prim.tanT33, Prim.firT37],
  stocksLit: <Color>[Prim.oxbloodT33, Prim.slateT37, Prim.tanT42, Prim.firT47],
  showGround: Prim.inkT99,
  showInk: Prim.inkT20,
  showStandingLine: Prim.inkT45,
  keylineWidth: 1,
  keylineLitWidth: 2,
  usesStocks: true,
);

/// Light polarity.
const AacTheme kPaper = AacTheme(
  palette: AacPalette.paper,
  ground: Prim.inkT96,
  container: Prim.inkT92,
  ink: Prim.inkT26,
  inkDim: Prim.inkT45,
  keyline: Prim.inkT53,
  focus: Prim.amberT45,
  stocks: <Color>[Prim.oxbloodT79, Prim.slateT83, Prim.tanT87, Prim.firT91],
  stocksLit: <Color>[Prim.oxbloodT71, Prim.slateT74, Prim.tanT79, Prim.firT82],
  showGround: Prim.inkT99,
  showInk: Prim.inkT20,
  showStandingLine: Prim.inkT45,
  keylineWidth: 1,
  keylineLitWidth: 2,
  usesStocks: true,
);

// HC fills `stocks`/`stocksLit` with [ground x 4] / [ink x 4] rather than
// leaving them empty, so a caller that forgets the accessor gets the right
// colour rather than a range error.
const List<Color> _kHcInkStocks = <Color>[
  Prim.inkT14,
  Prim.inkT14,
  Prim.inkT14,
  Prim.inkT14,
];
const List<Color> _kHcInkStocksLit = <Color>[
  Prim.inkT99,
  Prim.inkT99,
  Prim.inkT99,
  Prim.inkT99,
];
const List<Color> _kHcPaperStocks = <Color>[
  Prim.inkT99,
  Prim.inkT99,
  Prim.inkT99,
  Prim.inkT99,
];
const List<Color> _kHcPaperStocksLit = <Color>[
  Prim.inkT14,
  Prim.inkT14,
  Prim.inkT14,
  Prim.inkT14,
];

/// High contrast, dark polarity — 19.43:1. The default HC polarity.
///
/// `MediaQuery.highContrastOf` is iOS-only and always false on Android, so on
/// the target platform the in-app switcher is not a convenience: it is the only
/// mechanism that reaches this palette at all.
const AacTheme kHcInk = AacTheme(
  palette: AacPalette.hcInk,
  ground: Prim.inkT14,
  container: Prim.inkT14,
  ink: Prim.inkT99,
  inkDim: Prim.inkT99,
  keyline: Prim.inkT99,
  focus: Prim.amberT88,
  stocks: _kHcInkStocks,
  stocksLit: _kHcInkStocksLit,
  showGround: Prim.inkT99,
  showInk: Prim.inkT20,
  showStandingLine: Prim.inkT45,
  // The keyline IS the tile here, so it is a flat 3dp rather than a hairline —
  // and the lit keyline matches it, because the lit signal is carried by the
  // full inversion, not by a thicker edge.
  keylineWidth: 3,
  keylineLitWidth: 3,
  usesStocks: false,
);

/// High contrast, light polarity — 19.43:1. A set-once settings preference,
/// never a fourth switcher position.
const AacTheme kHcPaper = AacTheme(
  palette: AacPalette.hcPaper,
  ground: Prim.inkT99,
  container: Prim.inkT99,
  ink: Prim.inkT14,
  inkDim: Prim.inkT14,
  keyline: Prim.inkT14,
  focus: Prim.amberT36,
  stocks: _kHcPaperStocks,
  stocksLit: _kHcPaperStocksLit,
  showGround: Prim.inkT99,
  showInk: Prim.inkT20,
  showStandingLine: Prim.inkT45,
  keylineWidth: 3,
  keylineLitWidth: 3,
  usesStocks: false,
);

/// Every palette, so tests iterate all four.
///
/// A token set in three palettes out of four is a crash or an unverified colour
/// waiting for the one user who picked the fourth.
const List<AacTheme> kAllThemes = <AacTheme>[kPaper, kInk, kHcInk, kHcPaper];

/// The [AacTheme] carrying [palette]'s values.
AacTheme themeFor(AacPalette palette) => switch (palette) {
  AacPalette.paper => kPaper,
  AacPalette.ink => kInk,
  AacPalette.hcInk => kHcInk,
  AacPalette.hcPaper => kHcPaper,
};
