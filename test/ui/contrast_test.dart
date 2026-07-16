import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/core/tokens.dart';

/// The contrast gate.
///
/// This is the test that lets the app ship no golden, screenshot, or pixel-diff
/// suite. A fixed grid across four palettes and several text scales is a
/// maintenance trap for one developer; a pure-Dart assertion that every colour
/// pairing clears its legibility floor is deterministic, has no platform
/// variance, and verifies the design system in CI — which is exactly the move a
/// no-telemetry project rewards.
///
/// The two-tier floor is deliberate and must not be flattened:
///   resting label — WCAG AAA 7:1 and APCA |Lc| >= 60. Read during a shutdown.
///   lit label     — WCAG AA  4.5:1 and APCA |Lc| >= 45. A 1-3s transient the
///                   user triggered on a label they just read; it must stay
///                   identifiable, not readable. Raising it to 7:1 erases the
///                   lit state — the only confirmation a user with motor
///                   imprecision gets that a tap landed.
///
/// The maths is ported verbatim from the palette validator and pinned by the
/// same published reference pairs, so a green gate here means the same numbers
/// the palette was designed against, not a second implementation that drifted.

// --- APCA 0.98G-4g. Constants are not editable; the self-test pins them. ---
const double _rCo = 0.2126729;
const double _gCo = 0.7151522;
const double _bCo = 0.0721750;
const double _mainTrc = 2.4;
const double _blkThrs = 0.022;
const double _blkClmp = 1.414;
const double _normBg = 0.56;
const double _normTxt = 0.57;
const double _revBg = 0.65;
const double _revTxt = 0.62;
const double _scale = 1.14;
const double _loOffset = 0.027;
const double _loClip = 0.1;
const double _deltaYMin = 0.0005;

double _apcaY(Color c) =>
    _rCo * math.pow(c.r, _mainTrc) +
    _gCo * math.pow(c.g, _mainTrc) +
    _bCo * math.pow(c.b, _mainTrc);

double _wcagLin(double c) =>
    c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _relLum(Color c) =>
    _rCo * _wcagLin(c.r) + _gCo * _wcagLin(c.g) + _bCo * _wcagLin(c.b);

/// WCAG 2.x contrast ratio. Depends only on relative luminance, which is why it
/// doubles as the grayscale metric below: grayscaling by luminance leaves this
/// number unchanged, so a chroma-only "feedback" that is invisible in grayscale
/// scores 1.0 here.
double _wcag(Color fg, Color bg) {
  final a = _relLum(fg);
  final b = _relLum(bg);
  final hi = math.max(a, b);
  final lo = math.min(a, b);
  return (hi + 0.05) / (lo + 0.05);
}

/// APCA Lc of text [fg] on background [bg]. Negative = light text on dark.
double _apca(Color fg, Color bg) {
  var ty = _apcaY(fg);
  var by = _apcaY(bg);
  if (ty <= _blkThrs) ty += math.pow(_blkThrs - ty, _blkClmp);
  if (by <= _blkThrs) by += math.pow(_blkThrs - by, _blkClmp);
  if ((by - ty).abs() < _deltaYMin) return 0;
  if (by > ty) {
    final s = (math.pow(by, _normBg) - math.pow(ty, _normTxt)) * _scale;
    return s < _loClip ? 0 : (s - _loOffset) * 100;
  }
  final s = (math.pow(by, _revBg) - math.pow(ty, _revTxt)) * _scale;
  return s > -_loClip ? 0 : (s + _loOffset) * 100;
}

/// Grayscale is not a separate computation: WCAG contrast is luminance-only, so
/// the grayscale contrast of two colours equals [_wcag] of the colours. The
/// stock/lit step must clear this on its own, because colour is never the only
/// channel of feedback and a user in Android's grayscale correction mode gets
/// nothing else.
const double _grayFloor = 1.30;

/// A named pairing under test, resolved to its tier's floors.
class _Pair {
  const _Pair(this.name, this.fg, this.bg, this.wcagMin, this.lcMin);
  final String name;
  final Color fg;
  final Color bg;
  final double wcagMin;
  final double lcMin;
}

const double _restingWcag = 7;
const double _restingLc = 60;
const double _litWcag = 4.5;
const double _litLc = 45;
const double _ringWcag = 3;
const double _ringLc = 45;
const double _chromeWcag = 3;
const double _chromeLc = 30;

/// Every legibility-relevant pairing in one palette.
List<_Pair> _pairsFor(AacTheme t) {
  final pairs = <_Pair>[
    // The tile label at rest, on the surface behind an empty tile.
    _Pair('ink on ground', t.ink, t.ground, _restingWcag, _restingLc),
    // The focus ring is drawn in the gutter, over ground, never on a fill.
    _Pair('focus on ground', t.focus, t.ground, _ringWcag, _ringLc),
    // Chrome text and the hairline keyline. inkDim is chrome ONLY — never a
    // tile label — so it is held to the chrome floor, not the resting one.
    _Pair('inkDim on ground', t.inkDim, t.ground, _chromeWcag, _chromeLc),
    _Pair('keyline on ground', t.keyline, t.ground, _chromeWcag, _chromeLc),
    // Show mode is a poster a stranger reads at arm's length: resting strength.
    _Pair(
      'showInk on showGround',
      t.showInk,
      t.showGround,
      _restingWcag,
      _restingLc,
    ),
    _Pair(
      'standing on showGround',
      t.showStandingLine,
      t.showGround,
      _restingWcag,
      _restingLc,
    ),
  ];

  // High-contrast palettes drop the stocks entirely — the keyline is the tile
  // and the lit state is a full inversion, both already covered by ink-on-ground
  // above. Only the coloured palettes carry per-stock label contrast.
  if (t.usesStocks) {
    for (final s in Stock.values) {
      pairs
        ..add(
          _Pair(
            'ink on ${s.name}',
            t.inkOn(s),
            t.stock(s),
            _restingWcag,
            _restingLc,
          ),
        )
        ..add(
          _Pair(
            'ink on ${s.name} lit',
            t.inkOn(s, lit: true),
            t.stockLit(s),
            _litWcag,
            _litLc,
          ),
        );
    }
  }
  return pairs;
}

void main() {
  // Nothing downstream is trusted until the maths reproduces the published
  // anchors. A drifted implementation would pass a palette it should fail.
  group('reference pairs', () {
    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);
    const gray = Color(0xFF888888);
    const lightGray = Color(0xFFAAAAAA);

    test('WCAG black on white is 21.00', () {
      expect(_wcag(black, white), closeTo(21.00, 0.01));
    });
    test('APCA #888 on #FFF is 63.1', () {
      expect(_apca(gray, white), closeTo(63.1, 0.1));
    });
    test('APCA #FFF on #888 is -68.5', () {
      expect(_apca(white, gray), closeTo(-68.5, 0.1));
    });
    test('APCA #000 on #AAA is 58.1', () {
      expect(_apca(black, lightGray), closeTo(58.1, 0.1));
    });
  });

  // One group per palette, so `paper`, `ink`, `hcInk`, `hcPaper` each appear in
  // the output and a failure names the palette it broke.
  for (final theme in kAllThemes) {
    group('palette ${theme.palette.name}', () {
      for (final p in _pairsFor(theme)) {
        test('${p.name} clears its floor', () {
          final wcag = _wcag(p.fg, p.bg);
          final lc = _apca(p.fg, p.bg).abs();
          // BOTH must hold. WCAG 2.x is known to be wrong for dark surfaces, so
          // APCA is not decoration here — dropping it silently weakens the gate.
          expect(
            wcag,
            greaterThanOrEqualTo(p.wcagMin),
            reason:
                '${p.name}: WCAG $wcag < ${p.wcagMin} '
                'in ${theme.palette.name}',
          );
          expect(
            lc,
            greaterThanOrEqualTo(p.lcMin),
            reason:
                '${p.name}: APCA Lc $lc < ${p.lcMin} '
                'in ${theme.palette.name}',
          );
        });
      }
    });
  }

  // Separate from the contrast tests on purpose: this is a different failure.
  // It catches the whole class of feedback that encodes state in chroma alone —
  // the proposed "flood the tile with accent at matched luminance" lit state
  // measures ~1.0 here and is invisible to a colourblind user or anyone in
  // grayscale mode, giving someone with motor imprecision no confirmation their
  // tap landed.
  group('lit state survives grayscale', () {
    for (final theme in kAllThemes.where((t) => t.usesStocks)) {
      for (final s in Stock.values) {
        test('${theme.palette.name} ${s.name} lit differs in grayscale', () {
          final ratio = _wcag(theme.stock(s), theme.stockLit(s));
          expect(
            ratio,
            greaterThanOrEqualTo(_grayFloor),
            reason:
                '${theme.palette.name} ${s.name}: stock and lit differ by '
                'only $ratio in grayscale — a chroma-only step is invisible '
                'without colour.',
          );
        });
      }
    }
  });
}
