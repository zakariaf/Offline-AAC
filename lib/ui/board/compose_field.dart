import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/core/tokens.dart';

/// The field's placeholder. Lowercase chrome, authored here rather than
/// case-transformed at render — compute case once and someone's name eventually
/// gets lowercased with it.
const String kComposeHint = 'type to speak';

/// The thirteenth cell: type what nobody authored in advance.
///
/// It is a cell of the board's own layout — same radius, same keyline, same
/// material, `container` fill, three columns wide, 72dp tall — and not an input
/// bolted onto a grid. The moment it reads as a separate surface the screen is
/// two products stapled together and the user has to work out which one they
/// are in.
///
/// It sits at the TOP, in the worst position on the screen, and that is not up
/// for relitigation: the ability to type implies more capacity than the ability
/// to tap. Tiles are for crisis; typing is for when you are okay. The bonus is
/// that the keyboard then covers the grid and leaves the field visible, which is
/// the correct thing to cover — and only works because it is at the top.
class ComposeField extends ConsumerStatefulWidget {
  const ComposeField({super.key});

  @override
  ConsumerState<ComposeField> createState() => _ComposeFieldState();
}

class _ComposeFieldState extends ConsumerState<ComposeField> {
  final TextEditingController _text = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChanged)
      ..dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    // When speech fails, the words land here. This is the screen's only text
    // surface and it is fixed-height, so nothing on the board moves to make
    // room — the user can hand the phone over, or press send to try again.
    //
    // It overwrites a draft, which is a real cost. It is paid only when the
    // alternative is silence, which is the one outcome worse than losing what
    // was typed.
    ref.listen<String?>(boardControllerProvider.select((s) => s.fallbackText), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      _text.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    });

    // 72dp, held. At 200% text scale this overflows, loudly, in a test — which
    // is the correct failure. Growing the field eats the grid, and clamping the
    // text scale to stop it would defeat the whole accessibility matrix while
    // every contrast and tap-target check stayed green.
    return SizedBox(
      height: Geom.fieldHeight,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: <Widget>[
          if (_focus.hasFocus) const FocusRing(),
          TextField(
            controller: _text,
            focusNode: _focus,
            // No auto-focus, under any condition. A keyboard covering the grid
            // at cold launch buries the twelve phrases someone opened the app
            // mid-shutdown to reach — the exact failure the product exists to
            // prevent, one word away.
            textInputAction: TextInputAction.send,
            // ref.read inside the callback. The arrow is safe only because
            // speakText returns void: a callback must never touch a Future, and
            // no lint reports one dropped here.
            onSubmitted: (text) =>
                ref.read(boardControllerProvider.notifier).speakText(text),
            style: AacType.field.copyWith(
              color: t.ink,
              fontWeight: MediaQuery.boldTextOf(context)
                  ? FontWeight.w800
                  : null,
            ),
            cursorColor: t.ink,
            decoration: InputDecoration(
              filled: true,
              fillColor: t.container,
              hintText: kComposeHint,
              // inkDim is chrome ink, and a placeholder is chrome. It is never
              // a phrase label: APCA rates it Lc -55.7, i.e. secondary, even
              // though WCAG blesses it at 7.94:1.
              hintStyle: AacType.field.copyWith(color: t.inkDim),
              contentPadding: const EdgeInsetsDirectional.all(Geom.tileInset),
              // A WidgetState border is returned as-is by InputDecorator. A
              // plain one is not: with Material 3 and `filled`, the decorator
              // substitutes its own side from the theme via copyWith, and the
              // keyline silently becomes Material's indicator instead of the
              // tile's. Resolving to one border for every state also keeps
              // focus off the field's own edge — the ring in the gutter is the
              // focus signal, here exactly as on a tile.
              border: WidgetStateInputBorder.resolveWith(
                (states) => ShapedInputBorder(
                  // There is no superellipse input border class — that name does
                  // not exist. This is the seam that gives the field the tile's
                  // exact shape without reaching for a banned approximation of
                  // one.
                  shape: const RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(Geom.tileRadius),
                    ),
                  ),
                  borderSide: BorderSide(
                    color: t.keyline,
                    width: t.keylineWidthOf(dpr),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
