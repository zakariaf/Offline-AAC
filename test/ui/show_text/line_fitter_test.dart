import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/show_text/line_fitter.dart';

import '../../support/fonts.dart';

/// The fitter is a pure function measured against the real font — its answers
/// ARE Atkinson's glyph advances, so Ahem would make every assertion here a lie.
/// Nothing below has a widget tree; the algorithm is separated from the screen
/// precisely so it can be proven at this level.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  // The show style at a size, exactly as the screen builds it.
  TextStyle styleAt(double size) => AacType.show(size);

  // A local, independent probe — the same unconstrained measurement the fitter
  // uses, re-implemented here so the reference tests do not trust the code they
  // are checking.
  double probeWidth(String line) {
    final tp = TextPainter(
      text: TextSpan(text: line, style: styleAt(100)),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = tp.width;
    tp.dispose();
    return w;
  }

  double idealSize(String line, double measure) => 100 * measure / probeWidth(line);

  const tallBudget = 5000.0; // so the height never constrains these fits

  test('a real phrase fits to DIFFERENT per-line sizes', () {
    // If this passed with every line equal, the whole per-line feature would be
    // dead and nothing else would notice.
    final fit = fitShowText(
      says: 'I can’t talk right now but I’m okay.',
      measure: 360,
      heightBudget: tallBudget,
      styleAt: styleAt,
    );
    final poster = fit as JustifiedPoster;
    final sizes = poster.lines.map((l) => l.size).toSet();
    expect(sizes.length, greaterThan(1), reason: 'a uniform fit means dead');
  });

  test('every non-clamped line touches both margins (width == measure)', () {
    const measure = 340.0;
    final poster =
        fitShowText(
              says: 'I can’t talk right now but I’m okay.',
              measure: measure,
              heightBudget: tallBudget,
              styleAt: styleAt,
            )
            as JustifiedPoster;

    for (final line in poster.lines) {
      if (line.size >= AacType.showSizeMax - 0.5) continue; // clamped: under-fills
      final tp = TextPainter(
        text: TextSpan(text: line.text, style: styleAt(line.size)),
        textDirection: TextDirection.ltr,
      )..layout();
      expect(
        tp.width,
        moreOrLessEquals(measure, epsilon: 1),
        reason: '"${line.text}" at ${line.size} does not reach the margins',
      );
      tp.dispose();
    }
  });

  test('every returned size is within [32, 140]', () {
    final poster =
        fitShowText(
              says: 'I can’t talk right now but I’m okay.',
              measure: 300,
              heightBudget: tallBudget,
              styleAt: styleAt,
            )
            as JustifiedPoster;
    for (final line in poster.lines) {
      expect(line.size, inInclusiveRange(AacType.showSizeMin, AacType.showSizeMax));
    }
  });

  test('no line ever splits a word; the words come back in order', () {
    const says = 'Please give me a moment to find the words.';
    final poster =
        fitShowText(
              says: says,
              measure: 320,
              heightBudget: tallBudget,
              styleAt: styleAt,
            )
            as JustifiedPoster;
    final rejoined = poster.lines.map((l) => l.text).join(' ');
    expect(rejoined, says);
  });

  test('line count is always in 1..4 on the fitted path', () {
    final poster =
        fitShowText(
              says: 'I can’t talk right now but I’m okay.',
              measure: 300,
              heightBudget: tallBudget,
              styleAt: styleAt,
            )
            as JustifiedPoster;
    expect(poster.lines.length, inInclusiveRange(1, 4));
  });

  test('the winner maximises the minimum line size (vs brute force)', () {
    const says = 'I can’t talk right now but I’m okay.';
    const measure = 330.0;
    final words = says.split(' ');

    // Independent reference: the best achievable minimum size over ALL valid
    // candidates, height ignored (budget is tall), replicating only the sizing.
    var referenceMax = -1.0;
    for (var n = 1; n <= math.min(4, words.length); n++) {
      for (final grouping in showLineBreakCandidates(words, n)) {
        final sizes = <double>[];
        var valid = true;
        for (final group in grouping) {
          final ideal = idealSize(group.join(' '), measure);
          if (ideal < AacType.showSizeMin - 0.01) {
            valid = false;
            break;
          }
          sizes.add(ideal.clamp(AacType.showSizeMin, AacType.showSizeMax));
        }
        if (!valid) continue;
        final minSize = sizes.reduce(math.min);
        if (minSize > referenceMax) referenceMax = minSize;
      }
    }

    final poster =
        fitShowText(
              says: says,
              measure: measure,
              heightBudget: tallBudget,
              styleAt: styleAt,
            )
            as JustifiedPoster;
    final winnerMin = poster.lines.map((l) => l.size).reduce(math.min);
    expect(winnerMin, moreOrLessEquals(referenceMax, epsilon: 0.5));
  });

  test('a tie in the minimum size breaks toward fewer lines', () {
    // "wonderful" is the longest token, so it is the minimum line in every
    // sensible break and it lands well inside [32,140]. Isolating it as its own
    // line gives the same minimum at 2 lines and at 3 — the short remainder
    // clamps at the ceiling either way — so the tie-break, and only the
    // tie-break, decides 2 over 3.
    const says = 'wonderful and me';
    const measure = 340.0;
    final words = says.split(' ');

    double bestMinAt(int n) {
      var best = -1.0;
      for (final grouping in showLineBreakCandidates(words, n)) {
        final sizes = grouping
            .map((g) => idealSize(g.join(' '), measure).clamp(32.0, 140.0))
            .toList();
        final m = sizes.reduce(math.min);
        if (m > best) best = m;
      }
      return best;
    }

    // Precondition of the test itself: 2 and 3 lines really do tie.
    expect(bestMinAt(2), moreOrLessEquals(bestMinAt(3), epsilon: 0.5));

    final poster =
        fitShowText(
              says: says,
              measure: measure,
              heightBudget: tallBudget,
              styleAt: styleAt,
            )
            as JustifiedPoster;
    expect(poster.lines.length, 2, reason: 'the tie must resolve to fewer lines');
  });

  test('a wider measure (landscape) never returns smaller type', () {
    const says = 'I can’t talk right now but I’m okay.';
    final portrait =
        fitShowText(
              says: says,
              measure: 320,
              heightBudget: tallBudget,
              styleAt: styleAt,
            )
            as JustifiedPoster;
    final landscape =
        fitShowText(
              says: says,
              measure: 680,
              heightBudget: tallBudget,
              styleAt: styleAt,
            )
            as JustifiedPoster;
    final pMin = portrait.lines.map((l) => l.size).reduce(math.min);
    final lMin = landscape.lines.map((l) => l.size).reduce(math.min);
    expect(lMin, greaterThanOrEqualTo(pMin - 0.5));
  });

  test('a paragraph that cannot seat at the floor degrades to a 32pt scroll', () {
    const paragraph =
        'There is a great deal I would like to say to you right now and none '
        'of the words are arriving in the order that I need them to arrive in '
        'so please bear with me for a little while longer than usual today.';
    final fit = fitShowText(
      says: paragraph,
      measure: 340,
      heightBudget: 700,
      styleAt: styleAt,
    );
    expect(fit, isA<ScrollingBlock>());
    final block = fit as ScrollingBlock;
    expect(block.size, AacType.showSizeMin);
    // The trigger is the fit failing, not a length threshold: the same text at a
    // huge measure fits fine.
    final wide = fitShowText(
      says: paragraph,
      measure: 4000,
      heightBudget: 5000,
      styleAt: styleAt,
    );
    expect(wide, isA<JustifiedPoster>());
  });

  test('the winning block fits within the height budget', () {
    const says = 'I can’t talk right now but I’m okay.';
    const measure = 330.0;
    const viewportH = 720.0;
    const standingH = 30.0;
    const budget = viewportH - 48 - standingH;

    final poster =
        fitShowText(
              says: says,
              measure: measure,
              heightBudget: budget,
              styleAt: styleAt,
            )
            as JustifiedPoster;

    final tp = TextPainter(
      text: TextSpan(
        children: <TextSpan>[
          for (var i = 0; i < poster.lines.length; i++)
            TextSpan(
              text: i == poster.lines.length - 1
                  ? poster.lines[i].text
                  : '${poster.lines[i].text}\n',
              style: styleAt(poster.lines[i].size),
            ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: measure);

    expect(tp.height + standingH + 48, lessThanOrEqualTo(viewportH + 0.5));
    tp.dispose();
  });
}
