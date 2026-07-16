import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/strings.dart';

/// The edit-mode toggle: a visible, labelled, focusable button — the whole point
/// of the control, because every other AAC board hides editing behind a
/// long-press, and long-press collides head-on with dwell-style assistive input
/// (where holding IS the ordinary way to activate) and is an invisible state
/// machine nothing on screen describes.
///
/// A `StatelessWidget`, not a `_buildEditButton` method: a method's subtree has
/// no `Element` of its own and `find.byType` cannot reach it in a test — and
/// tests are this app's only feedback loop.
class EditModeButton extends ConsumerWidget {
  const EditModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editing = ref.watch(
      boardControllerProvider.select((s) => s.editing),
    );
    final t = AacTheme.of(context);
    // Platform a11y state from context, never Riverpod: MediaQuery is an
    // InheritedWidget with correct-by-construction invalidation; a provider
    // would be stale for a frame in the one place being wrong is total failure.
    final bold = MediaQuery.boldTextOf(context);

    return Semantics(
      container: true,
      button: true,
      // The label names the mode the tap PUTS you in and changes with state — a
      // fixed label is a lie to a screen reader about what the button does.
      label: editing ? doneEditingLabel : editBoardLabel,
      child: GestureDetector(
        // Never InkWell: NoSplash kills the splash, but InkResponse still mounts
        // an InkHighlight with a 200ms pressed fade and schedules a second frame.
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(boardControllerProvider.notifier).toggleEditing(),
        // The visible content is decorative to a screen reader — the container
        // above announces the mode. Excluding it keeps the node's label exactly
        // "Edit board" / "Done editing" instead of merging the lowercase chrome
        // word in. The two non-colour state channels are still here for a
        // sighted user: the icon SHAPE (pencil vs check) and the word, so the
        // state survives invertColors and Android Grayscale colour-correction
        // where a tint alone would vanish.
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  editing ? Icons.check_rounded : Icons.edit_outlined,
                  size: 20,
                  color: t.ink,
                ),
                const SizedBox(width: 6),
                Text(
                  editing ? editModeExitChrome : editModeEnterChrome,
                  style: AacType.meta.copyWith(
                    color: t.ink,
                    fontWeight: bold ? FontWeight.w800 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
