import 'package:flutter/rendering.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/core/tokens.dart';

/// How many columns the board should render at, and how tall each tile must be,
/// as a function of the space it has and the text size the user chose.
///
/// This is the whole responsive contract in one place: the label is never
/// shrunk, ellipsized, or truncated (those decisions live in [PhraseTile] and
/// are load-bearing accessibility rules), so the ONLY free variables when a
/// user turns their system text size up are the column count and the tile
/// height. Fewer columns make each tile wider; a taller tile holds more lines.
/// Between them, a warm multi-word label keeps every word at every supported
/// scale — the price is that the board scrolls once the tiles no longer fit one
/// screen, which is the honest trade for never dropping a word.
///
/// Both functions MEASURE with the real [TextPainter], so they answer for the
/// actual shipped font and the user's actual [TextScaler] rather than a
/// heuristic that drifts from what the tile really renders. A board layout runs
/// them once per constraint change (rotation, keyboard, a settings change) —
/// never per frame — so the handful of extra text layouts are free.

/// The largest column count in `[1, maxCols]` at which EVERY label wraps to at
/// most [kMaxLabelLines] lines in the resulting tile width.
///
/// Falls back to 1, and 1 is always safe: a full-width tile on the narrowest
/// supported phone holds a 16-character label — the editor's hard cap — within
/// three lines at every scale the app supports, verified by the label-fit
/// suite. So this never returns a column count that would truncate a label; the
/// board scrolls instead.
int chooseColumns({
  required double contentWidth,
  required int maxCols,
  required Iterable<String> labels,
  required TextStyle style,
  required TextScaler scaler,
  required TextDirection direction,
}) {
  for (var cols = maxCols; cols > 1; cols--) {
    final textWidth = _textWidthFor(contentWidth, cols);
    if (textWidth <= 0) continue;
    final everyLabelFits = labels.every(
      (label) =>
          _lineCount(label, style, scaler, textWidth, direction) <=
          kMaxLabelLines,
    );
    if (everyLabelFits) return cols;
  }
  return 1;
}

/// The height every tile must be so that no label loses a line: the tallest
/// [kMaxLabelLines]-capped label across the board, at this scale and the chosen
/// column's text width, plus the tile's top and bottom insets.
///
/// One height for all tiles, not per-tile, because a grid of uneven tile
/// heights reads as broken where uneven line COUNTS read as fine — the label is
/// bottom-anchored, so a one-line and a three-line tile of equal height share a
/// baseline and scan as a row of type.
double minTileHeight({
  required double contentWidth,
  required int cols,
  required Iterable<String> labels,
  required TextStyle style,
  required TextScaler scaler,
  required TextDirection direction,
}) {
  final textWidth = _textWidthFor(contentWidth, cols);
  var tallestLabel = 0.0;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: kMaxLabelLines,
    )..layout(maxWidth: textWidth > 0 ? textWidth : 0);
    if (painter.size.height > tallestLabel) tallestLabel = painter.size.height;
    painter.dispose();
  }
  return tallestLabel + 2 * Geom.tileInset;
}

/// The width available to a label inside one tile of a `cols`-wide row: the row
/// split into columns with [Geom.gapColumn] between them, less the tile's inset
/// on each side. The single source of the tile-width arithmetic both functions
/// depend on, so they can never disagree about how wide a tile actually is.
double _textWidthFor(double contentWidth, int cols) =>
    (contentWidth - (cols - 1) * Geom.gapColumn) / cols - 2 * Geom.tileInset;

int _lineCount(
  String text,
  TextStyle style,
  TextScaler scaler,
  double maxWidth,
  TextDirection direction,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: direction,
    textScaler: scaler,
  )..layout(maxWidth: maxWidth);
  final lines = painter.computeLineMetrics().length;
  painter.dispose();
  return lines;
}
