import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:offline_aac/ui/core/tokens.dart';

/// The show-mode poster's one hard problem, as a pure function: given a sentence
/// and the rectangle it has to fill, choose where the lines break and how big
/// each line is so that every line touches both margins and the SMALLEST line is
/// as large as it can be.
///
/// The uniform alternative — one size for the whole block, solved for the
/// longest line — leaves every other line smaller than the rectangle could have
/// given it, and the smallest line is exactly what a stranger at arm's length
/// struggles with. The most legible setting and the most beautiful setting are
/// the same computation; that is the entire reason this exists rather than a
/// `FittedBox`.
///
/// No widgets, no caching. It runs inside a `LayoutBuilder` and is recomputed on
/// every constraint change, because rotation and the platform text scale both
/// change the answer and a cached answer goes silently stale on either.

/// Builds the `show` text style at a given size. The tracking is size-dependent
/// (−0.02em), so the probe MUST rebuild the style at each size rather than
/// `copyWith(fontSize:)` a fixed one — otherwise the probe measures the wrong
/// tracking and the "touch both margins" edge quietly lies. The screen passes
/// [AacType.show]; the OpenDyslexic variant passes a zero-tracking builder.
typedef ShowStyleAt = TextStyle Function(double size);

/// One laid-out line: the exact text and the size it is drawn at.
@immutable
class FittedLine {
  const FittedLine(this.text, this.size);

  final String text;
  final double size;

  @override
  bool operator ==(Object other) =>
      other is FittedLine && other.text == text && other.size == size;

  @override
  int get hashCode => Object.hash(text, size);

  @override
  String toString() => 'FittedLine("$text", ${size.toStringAsFixed(1)})';
}

/// What the fitter decided: either a justified poster of 1–4 per-line-sized
/// lines, or — when the sentence cannot be seated at the floor size within the
/// height — the one honest degradation, a uniform 32pt block the screen scrolls.
sealed class ShowFit {
  const ShowFit();
}

/// The normal result: 1–4 lines, each sized to touch both margins, the block
/// centred as one optical unit. [uniform] is the emphasis-risk escape hatch kept
/// cheap by design (varying line size reads as stress, which is unmeasured) —
/// the same lines flattened to the smallest size, a one-call swap the screen can
/// make without re-running the fit.
final class JustifiedPoster extends ShowFit {
  const JustifiedPoster(this.lines);

  final List<FittedLine> lines;

  JustifiedPoster uniform() {
    final size = lines.map((l) => l.size).reduce(math.min);
    return JustifiedPoster(
      <FittedLine>[for (final l in lines) FittedLine(l.text, size)],
    );
  }

  @override
  String toString() => 'JustifiedPoster($lines)';
}

/// The degradation: the sentence is too long to seat even one candidate at
/// [AacType.showSizeMin] within the height, so it is set uniformly at the floor
/// and the screen scrolls it. Reached by the fit FAILING, never by a character
/// count — a length threshold is wrong at every text scale and orientation.
final class ScrollingBlock extends ShowFit {
  const ScrollingBlock(this.text, this.size);

  final String text;
  final double size;

  @override
  String toString() => 'ScrollingBlock("$text", $size)';
}

const double _probeSize = 100;
const int _maxLines = 4;
const double _epsilon = 0.01;

/// The fitter. See the library doc for the why.
ShowFit fitShowText({
  required String says,
  required double measure,
  required double heightBudget,
  required ShowStyleAt styleAt,
  TextHeightBehavior? textHeightBehavior,
}) {
  final words = _words(says);
  if (words.isEmpty || measure <= 0) {
    return ScrollingBlock(says.trim(), AacType.showSizeMin);
  }

  JustifiedPoster? best;
  var bestMin = -1.0;
  var bestLineCount = _maxLines + 1;

  for (var n = 1; n <= math.min(_maxLines, words.length); n++) {
    for (final grouping in showLineBreakCandidates(words, n)) {
      final lines = <FittedLine>[];
      var seatsAtFloor = true;
      for (final group in grouping) {
        final line = group.join(' ');
        final ideal = _probeSize * measure / _measuredWidth(line, styleAt);
        // Below the floor means the line still overruns the margin at 32pt: this
        // candidate cannot be justified without clipping, so it is out. (Above
        // the ceiling is fine — the line simply under-fills at 140.)
        if (ideal < AacType.showSizeMin - _epsilon) {
          seatsAtFloor = false;
          break;
        }
        lines.add(
          FittedLine(
            line,
            ideal.clamp(AacType.showSizeMin, AacType.showSizeMax),
          ),
        );
      }
      if (!seatsAtFloor) continue;

      final blockHeight = _blockHeight(lines, styleAt, textHeightBehavior);
      if (blockHeight > heightBudget + _epsilon) continue;

      final minSize = lines.map((l) => l.size).reduce(math.min);
      // Maximise the minimum line size; a tie in the minimum breaks toward FEWER
      // lines — fewer fixations at reading distance. Never the mean, never the
      // max: both strand one line tiny next to a huge one, and the small line is
      // the one a stranger reads slowest.
      final wins =
          minSize > bestMin + _epsilon ||
          ((minSize - bestMin).abs() <= _epsilon && n < bestLineCount);
      if (wins) {
        best = JustifiedPoster(lines);
        bestMin = minSize;
        bestLineCount = n;
      }
    }
  }

  return best ?? ScrollingBlock(words.join(' '), AacType.showSizeMin);
}

/// The word sequence, whitespace-normalised. Joining any line grouping's lines
/// with single spaces reproduces this exactly — the break search only ever cuts
/// between these tokens, never inside one.
List<String> _words(String says) =>
    says.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

/// Every way to cut [words] into [lineCount] contiguous, non-empty groups.
///
/// Exposed so a test can brute-force the same candidate set the fitter scores
/// and prove the winner really is the max-of-the-minimum. For a ≤9-word phrase
/// across 1..4 lines this is ≤56 groupings — one layout pass, not a hot loop.
List<List<List<String>>> showLineBreakCandidates(
  List<String> words,
  int lineCount,
) {
  if (lineCount < 1 || lineCount > words.length) return const [];
  if (lineCount == 1) {
    return <List<List<String>>>[
      <List<String>>[List<String>.of(words)],
    ];
  }

  final result = <List<List<String>>>[];
  // Choose lineCount-1 cut points among the words.length-1 gaps between words.
  void recurse(int start, int cutsLeft, List<int> cuts) {
    if (cutsLeft == 0) {
      final groups = <List<String>>[];
      var from = 0;
      for (final cut in cuts) {
        groups.add(words.sublist(from, cut));
        from = cut;
      }
      groups.add(words.sublist(from));
      result.add(groups);
      return;
    }
    // Leave at least one word for each remaining group, including this one.
    for (var cut = start; cut <= words.length - cutsLeft; cut++) {
      recurse(cut + 1, cutsLeft - 1, <int>[...cuts, cut]);
    }
  }

  recurse(1, lineCount - 1, <int>[]);
  return result;
}

/// The unconstrained advance width of [line] at the probe size. UNCONSTRAINED is
/// load-bearing: pass a `maxWidth` and the painter wraps, `width` reports the
/// constraint, every line probes identical, and the whole feature silently
/// collapses to a uniform fit nobody notices in review.
double _measuredWidth(String line, ShowStyleAt styleAt) {
  final painter = TextPainter(
    text: TextSpan(text: line, style: styleAt(_probeSize)),
    textDirection: TextDirection.ltr,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// The painted height of the whole block, per-line sizes and all — measured the
/// same way the screen paints it (one paragraph, a span per line, the show
/// height behaviour), so the budget check matches reality rather than an
/// estimate.
///
/// Laid out UNCONSTRAINED, like the probe: every line is already ≤ measure and
/// the breaks are explicit `\n`, so no wrapping can happen and the height is
/// identical to a measure-width layout — and no `layout()` in this file ever
/// carries a `maxWidth`, so the constrained-probe bug cannot hide here.
double _blockHeight(
  List<FittedLine> lines,
  ShowStyleAt styleAt,
  TextHeightBehavior? textHeightBehavior,
) {
  final painter = TextPainter(
    text: TextSpan(
      children: <TextSpan>[
        for (var i = 0; i < lines.length; i++)
          TextSpan(
            text: i == lines.length - 1 ? lines[i].text : '${lines[i].text}\n',
            style: styleAt(lines[i].size),
          ),
      ],
    ),
    textDirection: TextDirection.ltr,
    textHeightBehavior: textHeightBehavior,
  )..layout();
  final height = painter.height;
  painter.dispose();
  return height;
}
