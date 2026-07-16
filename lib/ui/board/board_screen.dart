import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/board/compose_field.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/core/tokens.dart';

/// The board plane's shape before the board itself has arrived.
///
/// Dimensions come from the `boards` row, always. These two exist so the
/// loading and error arms can render a grid-SHAPED shell instead of a spinner
/// that collapses the layout — nothing on this screen may appear, vanish, or
/// resize, and a shell that is the wrong shape is a reflow with extra steps.
const int _kShellRows = 4;
const int _kShellCols = 3;

/// The speak screen. The product.
class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AacTheme.of(context);

    // The board failing to load is a real failure with no other channel: no
    // telemetry, and a user staring at twelve empty cells does not file a bug.
    // listen, not read — a side effect in a build body is a side effect per
    // rebuild.
    ref.listen<AsyncValue<BoardGrid>>(gridProvider, (previous, next) {
      final error = next.error;
      if (error == null) return;
      ref
          .read(crashLogProvider)
          .record('board read failed: $error', next.stackTrace);
    });

    // Every arm, named. `when` rather than a switch because AsyncValue's
    // subtypes are not an exhaustively-matchable set here — a switch over them
    // needs a wildcard, and a wildcard over a result type is how an arm goes
    // missing without the compiler saying so.
    //
    // Loading and error are the same picture as data on purpose: the cells,
    // holding their positions. A spinner would collapse the layout, and
    // whatever was already read stays on screen through a refresh — a grid that
    // blanks and refills is a change the user did not cause.
    final plane = ref
        .watch(gridProvider)
        .when(
          data: (grid) => _BoardPlane(grid: grid),
          error: (_, _) => const _BoardPlane(),
          loading: () => const _BoardPlane(),
          skipLoadingOnReload: true,
          skipError: true,
        );

    return Scaffold(
      // Full-bleed, behind the system bars. The window is edge-to-edge and the
      // TARGETS are inset — never the same question. No SafeArea above this, and
      // no status-bar scrim.
      backgroundColor: t.ground,
      // Explicit, because omitting it is not neutral: it chooses reflow. The
      // keyboard covering the grid is the design — that is why the field is at
      // the top — and padding the board up by the IME insets would move tiles a
      // user reaches for by muscle memory.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Geom.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // The compose field doubles as the fallback surface: when speech
              // fails, it fills with the words that did not leave the speaker,
              // so a tap always yields speech OR visible text, never neither.
              const ComposeField(),
              // The seam. This gap is a grid row gap, so the field reads as the
              // thirteenth cell rather than a header sitting above a grid.
              const SizedBox(height: Geom.gapRow),
              Expanded(child: plane),
            ],
          ),
        ),
      ),
    );
  }
}

/// The fixed grid of cells.
///
/// Laid out with no scrollable anywhere, and not merely with scrolling
/// disabled. The tile's pointer-down feedback fires before gesture
/// disambiguation and is legal only because nothing here can claim the pointer
/// for a drag. Tile size falls out of the division — `(viewport - chrome) /
/// rows` — and is never hardcoded, never floored.
class _BoardPlane extends StatelessWidget {
  const _BoardPlane({this.grid});

  final BoardGrid? grid;

  @override
  Widget build(BuildContext context) {
    final board = grid;
    final rows = board?.rows ?? _kShellRows;
    final cols = board?.cols ?? _kShellCols;

    // 14 across, 22 down. The gutters are unequal and that IS the composition:
    // equal gutters in both axes read as a table, unequal read as a designed
    // page and group the grid into rows, which is what the eye should find —
    // a row of tiles shares its last baseline and scans as a line of type.
    // Tidying these to one constant deletes the design and nothing goes red.
    return Column(
      children: <Widget>[
        for (var row = 0; row < rows; row++) ...<Widget>[
          if (row > 0) const SizedBox(height: Geom.gapRow),
          Expanded(
            child: Row(
              children: <Widget>[
                for (var col = 0; col < cols; col++) ...<Widget>[
                  if (col > 0) const SizedBox(width: Geom.gapColumn),
                  Expanded(
                    child: _BoardCell(
                      row: row,
                      col: col,
                      tile: board?.tileAt(row, col),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One cell: the only thing on the board that watches the lit state, and it
/// watches only its own.
class _BoardCell extends ConsumerWidget {
  const _BoardCell({required this.row, required this.col, required this.tile});

  final int row;
  final int col;
  final Tile? tile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lit = ref.watch(
      boardControllerProvider.select((s) => s.isLit(row, col)),
    );
    return PhraseTile(
      // Cheap, and it makes the intent legible. The composite (board_id, row,
      // col) primary key means slots never reorder and no State can leak across
      // one, so this is the whole key policy: nothing else on this path gets a
      // key, and never a GlobalKey.
      key: ValueKey<(int, int)>((row, col)),
      row: row,
      col: col,
      tile: tile,
      lit: lit,
      // ref.read INSIDE the callback, and coordinates rather than content. The
      // watched value from build() would be the phrase as it was at the last
      // rebuild: a fast re-tap after an edit would speak the previous sentence.
      //
      // The arrow is safe here only because onTilePressed returns void. The
      // same line against an async method drops the Future and its error, and
      // no lint reports it.
      onPressed: (r, c) =>
          ref.read(boardControllerProvider.notifier).onTilePressed(r, c),
    );
  }
}
