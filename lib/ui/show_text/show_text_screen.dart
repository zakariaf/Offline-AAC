import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/settings_repository.dart' show ShowPolarity;
import 'package:offline_aac/ui/core/instant_route.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';
import 'package:offline_aac/ui/show_text/line_fitter.dart';
import 'package:offline_aac/ui/strings.dart';

/// The one surface in Reed the user is not looking at.
///
/// The phone is turned away from their face and a stranger has about two seconds
/// to decide whether they are talking to a competent adult with a temporary
/// problem. Every rule here is either "the stranger can read it" or "the user
/// can get out of it without looking", and those two are the whole screen: warm
/// light regardless of the app's palette, per-line-justified poster type, a
/// standing line above it that does the actual social work, no chrome, and exit
/// on a tap anywhere or the system back gesture.
class ShowTextScreen extends ConsumerWidget {
  const ShowTextScreen({required this.says, super.key});

  /// The sentence to display. Show mode receives a resolved string; how a tap
  /// produced it is not this screen's concern.
  final String says;

  /// A hard cut, so entering flashes L 0.19 → 0.98 in one frame — the decision,
  /// not a bug. [InstantPageRoute] is a plain `MaterialPageRoute` with the
  /// transition duration zeroed; the app-root `_NoTransitions` removes the
  /// transition widget and the zero duration removes the frames it would still
  /// tick. Never a `PageRouteBuilder`, `fullscreenDialog`, or
  /// `showGeneralDialog`; each reintroduces the transition the flash refuses.
  static Route<void> route(String says) =>
      InstantPageRoute<void>(builder: (_) => ShowTextScreen(says: says));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AacTheme.of(context);
    final settings = ref.watch(settingsProvider);

    // The polarity is decided ONCE, here, not sprinkled as a ternary at each
    // colour site — that is how one site ends up inverted and no test notices.
    // `bright` is the always-light poster a stranger reads; `matchTheme` is the
    // single condition under which show mode is not #FFFCF7, and it is the
    // user's knowing call. Never t.ground/t.ink on the bright path: those invert
    // with the palette and hand a stranger a dark screen in daylight.
    final bright = settings.showPolarity == ShowPolarity.bright;
    final ground = bright ? t.showGround : t.ground;
    final ink = bright ? t.showInk : t.ink;
    // showStandingLine is verified 7.29:1 on #FFFCF7 only; on the palette's own
    // ground that number is meaningless, so matchTheme uses inkDim, which the
    // contrast gate already walks per palette.
    final standingColour = bright ? t.showStandingLine : t.inkDim;

    // Off OR empty both mean "no line" — and an empty line is a deliberate,
    // honoured choice, not invalid input. Either way the widget is not built,
    // so it reserves no line box and the fitter gets the full height back.
    final standingText =
        settings.standingLineEnabled ? settings.standingLineText : '';
    final hasStanding = standingText.isNotEmpty;

    return Semantics(
      // The whole poster is one dismiss button. Unlabelled, a full-bleed
      // GestureDetector is a screen a switch user cannot leave. container +
      // explicitChildNodes make this its OWN node, labelled exactly "Close";
      // without explicitChildNodes the standing line and the phrase merge into
      // the label and the dismiss target reads as the whole poster. They stay
      // separate, reachable child nodes instead.
      container: true,
      explicitChildNodes: true,
      button: true,
      label: showDismissLabel,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        // Full-bleed: every pixel — margins, standing line, and type — is exit
        // surface, so there is no dead zone to hunt for by feel. The Semantics
        // above owns the a11y node; this handles the pointer only.
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => Navigator.of(context).pop(),
        child: ColoredBox(
          color: ground,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(Geom.margin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (hasStanding) ...<Widget>[
                    Text(
                      standingText,
                      style: AacType.standing.copyWith(color: standingColour),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: _standingGap),
                  ],
                  // Expanded is the height-budget subtraction: whatever the
                  // standing line and the gap took, the poster fits into what is
                  // left, measured rather than assumed. Off ⇒ the poster gets the
                  // full column height.
                  Expanded(child: _Poster(says: says, ink: ink)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The breathing room between the standing line and the poster. Part of the
/// height the fitter does not get, alongside the standing line's own.
const double _standingGap = 24;

/// Atkinson's em box is top-heavy (ascent 984 > capHeight 668), so
/// mathematically-centred display type sits optically low. This is the metric
/// fix — never a hardcoded `Padding(top: -6)`, which is wrong at every size the
/// fitter produces and breaks outright at 200% scale and on the dyslexia font.
const TextHeightBehavior _showHeightBehaviour = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
  leadingDistribution: TextLeadingDistribution.even,
);

/// The phrase, fit and painted. Recomputes on every constraint change — rotation
/// and the platform text scale both change the answer — with no cache, because a
/// cached answer goes silently stale on either.
class _Poster extends StatelessWidget {
  const _Poster({required this.says, required this.ink});

  final String says;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // measure and budget come from the SAME constraints the poster paints
        // in, so the "flush both margins" edge is honest rather than solved for a
        // width the text is never given.
        final fit = fitShowText(
          says: says,
          measure: constraints.maxWidth,
          heightBudget: constraints.maxHeight,
          styleAt: AacType.show,
          textHeightBehavior: _showHeightBehaviour,
        );

        return switch (fit) {
          JustifiedPoster(:final lines) => _JustifiedBlock(
            lines: lines,
            ink: ink,
          ),
          // The one honest degradation: a paragraph the floor size cannot seat
          // scrolls at a uniform 32pt. The scroll view is wrapped by the
          // screen's GestureDetector, not wrapping it, so the overscroll area
          // stays exit surface.
          ScrollingBlock(:final text, :final size) => SingleChildScrollView(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                text,
                style: AacType.show(size).copyWith(color: ink),
                textAlign: TextAlign.start,
                textHeightBehavior: _showHeightBehaviour,
              ),
            ),
          ),
        };
      },
    );
  }
}

/// The justified block: one paragraph, a span per line at its own size, centred
/// vertically as a single optical unit and start-aligned so it ragged-rights and
/// mirrors under RTL.
class _JustifiedBlock extends StatelessWidget {
  const _JustifiedBlock({required this.lines, required this.ink});

  final List<FittedLine> lines;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            for (var i = 0; i < lines.length; i++)
              TextSpan(
                text: i == lines.length - 1
                    ? lines[i].text
                    : '${lines[i].text}\n',
                style: AacType.show(lines[i].size).copyWith(color: ink),
              ),
          ],
        ),
        textAlign: TextAlign.start,
        textHeightBehavior: _showHeightBehaviour,
      ),
    );
  }
}
