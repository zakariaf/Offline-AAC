import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/core/tokens.dart';

/// The most lines a label is ever laid out on.
///
/// Not a clamp on text size — the label wraps as wide and as tall as the user's
/// own `TextScaler` asks for. It is the ceiling on how far a shipped `\n` break
/// hint is honoured before natural wrap takes over.
const int kMaxLabelLines = 3;

/// The tile's stock when the phrase does not name one.
///
/// One fixed value, deliberately: anything derived from (row, col) would make
/// colour a function of position, and colour is a redundant assist while
/// position is the retrieval mechanism. A board of one stock is plain. A board
/// where the dye means something the user never authored is a lie.
const Stock _kFallbackStock = Stock.slate;

/// What a lit tile announces. Lowercase chrome; the state, not an instruction.
const String kSpeakingValue = 'speaking';

/// The paper stock a phrase is dyed with.
///
/// `buttons.background_color` is the only per-phrase colour the schema carries,
/// and it holds a [Stock] name rather than a hex. Reed cannot render an
/// arbitrary colour: contrast over uncontrolled colour is non-certifiable by
/// construction, which is why exactly four stocks exist and every one of them
/// is measured against the ink that sits on it.
///
/// An unknown value — a corrupt row, or a board imported from a format that
/// really does store CSS colours — resolves to [_kFallbackStock] instead of
/// throwing or rendering something unmeasured. A tile whose text is unreadable
/// is worse than a tile whose dye is not the author's first choice, and nothing
/// on the device will report either one.
Stock _stockOf(Tile tile) {
  final name = tile.backgroundColor;
  for (final stock in Stock.values) {
    if (stock.name == name) return stock;
  }
  return _kFallbackStock;
}

/// One cell of the board: a chip of dyed paper stock with one line of type on
/// it, or — when [tile] is null — ground and nothing else.
///
/// This widget does semantics and pointer wiring only. `_TileFace` does paint
/// and type. [lit] is a pure input; `BoardController` owns it.
class PhraseTile extends StatelessWidget {
  const PhraseTile({
    required this.row,
    required this.col,
    required this.tile,
    required this.lit,
    required this.onPressed,
    super.key,
  });

  /// The slot's coordinate. Passed separately from [tile] because an empty cell
  /// has no tile and still has a position — position is what exists first.
  final int row;
  final int col;

  /// Null means the cell is empty: a socket with nothing installed, not a hole
  /// and not a bug.
  final Tile? tile;

  /// Lit means "this tile is the thing talking". Press feedback and the
  /// speaking indicator are one signal, so there is no separate pressed state.
  final bool lit;

  /// Takes the coordinate, never the phrase. The content behind a position can
  /// go stale between build and press; the position cannot.
  ///
  /// Void-returning by contract. A callback that touches a Future drops it —
  /// `onPointerDown: (_) => speech.speak(x)` is reported by no lint, because the
  /// arrow returns the Future and the callback type discards it, along with its
  /// error.
  final void Function(int row, int col) onPressed;

  @override
  Widget build(BuildContext context) {
    final phrase = tile;
    if (phrase == null) {
      // Ground, nothing else. No fill, no keyline, no target, and no semantics
      // node — excluded, not disabled. A disabled node still costs a Switch
      // Access scan step, and at 1s/step every burned step is a real second
      // someone spends unable to speak. The cell still holds its full size: a
      // collapsed cell drags the next tile into a position muscle memory has
      // already claimed.
      //
      // Edit mode turns this same cell into a full target with a keyline, a `+`
      // and full semantics. That is a mode flag through this branch, not a
      // different widget.
      return const ExcludeSemantics(child: SizedBox.expand());
    }

    // Platform accessibility state comes from the tree, at build time.
    // MediaQuery is an InheritedWidget with correct-by-construction
    // invalidation; pushing it through a provider trades a compiler-guaranteed
    // rebuild for a hand-synced one that is stale for a frame, in the one area
    // where being wrong is total failure.
    final boldText = MediaQuery.boldTextOf(context);

    return Semantics(
      container: true,
      button: true,
      // Traversal order is a design decision, and by default it is nobody's.
      // Row-major reading plus the lower-centre thumb arc would make the most
      // important phrase the 8th-to-11th thing announced — eight seconds under
      // linear autoscan. This decouples the order a screen reader visits from
      // the order tiles sit on screen: lowest priority is read first, while the
      // tile stays put. Authored from the button's priority, never inherited
      // from layout by accident.
      sortKey: OrdinalSortKey(phrase.priority.toDouble()),
      // The DISPLAY label. Nothing in the type system tells these three Strings
      // apart, and a scanning user must hear "Overwhelmed" on every step, not
      // the whole sentence.
      label: phrase.label,
      // The non-colour channel for the lit state. The luminance step is
      // invisible under colour inversion, under Android's Grayscale
      // colour-correction mode, and to every screen-reader user — so state is
      // never carried by colour alone.
      value: lit ? kSpeakingValue : null,
      // Screen-reader activation arrives as a semantics action, not as a
      // pointer event, so the Listener below never sees it. Without this,
      // double-tap under TalkBack does nothing at all — silently.
      onTap: () => onPressed(row, col),
      child: Actions(
        actions: <Type, Action<Intent>>{
          // Enter and Space on a focused tile. WidgetsApp already maps both to
          // ActivateIntent; a focus ring with nothing behind it is half a
          // feature.
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onPressed(row, col);
              return null;
            },
          ),
        },
        child: Focus(
          child: Builder(
            builder: (context) {
              final focused = Focus.of(context).hasFocus;
              return Listener(
                // The whole rect is the target, always — never the painted
                // shape. Without this the inset around a short label is dead
                // space, and a near-miss mid-shutdown is silence.
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) {
                  // Dispatch order, not completion order: haptic, then the lit
                  // state, then TTS. Awaiting the haptic would put a
                  // platform-channel round trip in front of every phrase.
                  unawaited(HapticFeedback.selectionClick());
                  // Pointer DOWN. onTap fires on pointer up and delays every
                  // channel of feedback by the whole press. This fires ahead of
                  // gesture disambiguation, which is safe only because nothing
                  // here scrolls — that rule is load-bearing, not aesthetic.
                  onPressed(row, col);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (focused) const FocusRing(),
                    ExcludeSemantics(
                      // The Text below would otherwise publish its own node
                      // under the container above and TalkBack would say the
                      // label twice. Nothing fails; the app just becomes tiring.
                      child: _TileFace(
                        label: phrase.label,
                        stock: _stockOf(phrase),
                        diverges: phrase.vocalization != phrase.label,
                        lit: lit,
                        bold: boldText,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The focus ring, drawn in the gutter — outside the tile, never on it.
///
/// Amber recoloured onto the tile's own keyline changes only 2.73:1 worth of
/// pixels and fails SC 2.4.13's 3:1. In the gutter the changed pixels are
/// ground -> ring, which clears 6.69-14.85:1 across every palette and needs no
/// per-stock verification because it never touches a fill.
///
/// Must be a direct child of a `Stack` whose `clipBehavior` is `Clip.none`: it
/// paints outside its parent's bounds by design, and a cell that clips its tile
/// eats the ring silently — invisible until a keyboard or switch user has no
/// focus indicator at all.
///
/// It lives in this file because the tile is its first user. The type-to-speak
/// field is its second; there is no shared widget file to put it in, and a
/// duplicate would drift.
class FocusRing extends StatelessWidget {
  const FocusRing({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    return Positioned(
      left: -Geom.focusRingOffset,
      top: -Geom.focusRingOffset,
      right: -Geom.focusRingOffset,
      bottom: -Geom.focusRingOffset,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(Geom.focusRingRadius),
              ),
              side: BorderSide(color: t.focus, width: Geom.focusRingWidth),
            ),
          ),
        ),
      ),
    );
  }
}

/// The chip: paint and type, no behaviour.
class _TileFace extends StatelessWidget {
  const _TileFace({
    required this.label,
    required this.stock,
    required this.diverges,
    required this.lit,
    required this.bold,
  });

  final String label;
  final Stock stock;
  final bool diverges;
  final bool lit;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    // One physical pixel at rest. A logical-pixel line is three physical pixels
    // on a modern phone: that is a table border, not an engraved keyline.
    //
    // Lit promotes it to a solid stroke in `ink`. That promotion is the second,
    // non-chroma channel and is not decoration: a fill change alone is one
    // channel, and a matched-luminance chroma flood computes to 1.02:1 in
    // colour and 1.015:1 under Grayscale colour correction — invisible to
    // exactly the user who most needs to know their tap landed.
    final keylineWidth = lit ? t.keylineLitWidth : t.keylineWidthOf(dpr);

    // Read through the accessors, never off the lists and never by branching on
    // the palette here. High contrast drops the stocks entirely — the keyline
    // becomes the tile and lit becomes a full inversion — and the accessors are
    // where that collapse happens, once.
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: lit ? t.stockLit(stock) : t.stock(stock),
        shape: RoundedSuperellipseBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(Geom.tileRadius),
          ),
          side: BorderSide(
            color: lit ? t.ink : t.keyline,
            width: keylineWidth,
            // Stated, not inherited. It is BorderSide's current default, and a
            // stroke that centres itself instead would paint half the keyline
            // outside the shape — the hairline doubles into a table rule at the
            // one radius this design is built on, and nothing would report it.
            // ignore: avoid_redundant_argument_values
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(Geom.tileInset),
        child: Stack(
          children: <Widget>[
            if (diverges)
              // One hairline tick and nothing else. The tile is a handle for the
              // utterance, not the utterance: rendering the spoken text as a
              // second line measures 3.94:1 on oxblood and 4.24:1 on slate, and
              // Lc -39.0 even where the ratio passes. Verifying the spoken text
              // belongs in edit mode, where nobody is in a shutdown.
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: SizedBox(
                  width: Geom.divergenceTick,
                  height: t.keylineWidthOf(dpr),
                  child: ColoredBox(color: t.keyline),
                ),
              ),
            // Bottom-anchored and start-aligned, so a row of tiles shares its
            // last baseline and scans as a line of type. Centred text in a box
            // is the universal signal for "button"; this is a page.
            //
            // It also kills the optical-centring problem outright: the shipped
            // face has ascent 984 against capHeight 668 at upem 1000, so
            // mathematically centred text sits optically low. Anchored to the
            // bottom, that bug cannot exist here.
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: _TileLabel(
                label: label,
                style: AacType.tile.copyWith(
                  color: t.inkOn(stock, lit: lit),
                  // The platform bold-text flag is the only thing permitted to
                  // move weight — not the palette, not the lit state. w800 is
                  // the shipped axis maximum; w600 is the role.
                  fontWeight: bold ? FontWeight.w800 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The label, and the one decision it makes: whether to keep a shipped break
/// hint.
class _TileLabel extends StatelessWidget {
  const _TileLabel({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Text(
        _resolve(context, constraints.maxWidth),
        style: style,
        textAlign: TextAlign.start,
        maxLines: kMaxLabelLines,
        // Never ellipsis: an ellipsis on an AAC utterance is a different
        // utterance. Never auto-shrink either — it makes the longest, most
        // complex phrase the smallest and overrides the user's own TextScaler
        // while every contrast and tap-target check stays green. If a label does
        // not fit, that must be loud, not tidy.
        overflow: TextOverflow.visible,
      ),
    );
  }

  /// A literal `\n` in a shipped label is a break HINT, not a line break:
  /// ragged text strands words and Flutter has no text-balancing. Honour it
  /// while it fits, and fall back to natural wrap once the user's text scale
  /// pushes the hinted layout past [kMaxLabelLines] — otherwise the hint costs
  /// the accessibility user a whole line of their own phrase.
  String _resolve(BuildContext context, double maxWidth) {
    if (!label.contains('\n')) return label;

    // textScaler is read to MEASURE, never to clamp. Text scales itself; the
    // job here is only to notice when the hint stopped fitting.
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final lines = painter.computeLineMetrics().length;
    painter.dispose();

    return lines > kMaxLabelLines ? label.replaceAll('\n', ' ') : label;
  }
}
