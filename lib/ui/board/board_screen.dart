import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/board/compose_field.dart';
import 'package:offline_aac/ui/board/edit_mode_button.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/board/responsive_grid.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/edit/tile_editor.dart';

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

    // The editor is a state-driven surface, not a route: no Navigator.push, no
    // PageRoute, so it can never drift from the board it edits. When a slot is
    // open, the screen shows its editor in place — inline and non-blocking, no
    // modal to trap someone whose decision-making is the impaired thing.
    final editingSlot = ref.watch(
      boardControllerProvider.select((s) => s.editingSlot),
    );
    if (editingSlot != null) {
      final (row, col) = editingSlot;
      return Scaffold(
        backgroundColor: t.ground,
        resizeToAvoidBottomInset: true,
        body: TileEditor(row: row, col: col),
      );
    }

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
              // The board chrome. One visible control today — the edit toggle —
              // right-aligned so it does not sit under a thumb reaching for a
              // tile. A hidden gesture would be unreachable by switch and screen
              // reader; a button is not.
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: EditModeButton(),
              ),
              const SizedBox(height: Geom.gapRow),
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

/// The grid of cells.
///
/// The number of COLUMNS is a rendering decision, not a stored one: the board
/// keeps its authored `rows x cols` shape, and this plane reflows those same
/// cells — in their canonical reading order, each carrying its own logical
/// coordinate — into as many columns as the current text size leaves room for.
/// At the default text size that is the authored column count and the layout is
/// the fixed grid it has always been. Turn the system text size up and the
/// columns reduce so a warm multi-word label keeps every word instead of
/// shrinking or clipping; once the taller tiles no longer fit one screen, the
/// plane SCROLLS rather than drop a line. See [chooseColumns] / [minTileHeight].
///
/// Reflowing at a different text size does not fight the muscle-memory rule that
/// [BoardGrid] is built on. Text size is a stable OS setting: a given user sees
/// one layout, launch after launch, and their reach is learned against it. Only
/// a deliberate change to that setting reflows the board, which is exactly when
/// a layout is expected to adapt. Screen-reader and switch-scan ORDER never move
/// at all — that is driven by each tile's priority sort key, not by where it
/// sits — so the reflow is purely visual.
///
/// Tile size still falls out of the division — never hardcoded, never floored.
class _BoardPlane extends StatelessWidget {
  const _BoardPlane({this.grid});

  final BoardGrid? grid;

  @override
  Widget build(BuildContext context) {
    final board = grid;
    // The loading / error shell: the grid's authored shape filled with empty
    // cells, so the plane holds its size and never collapses to a spinner while
    // the board reads. Nothing to measure, so it never scrolls — it is on screen
    // for a frame and must not resize the plane under it.
    if (board == null) {
      return _fixedGrid(
        rows: _kShellRows,
        cols: _kShellCols,
        cellAt: (row, col) =>
            _BoardCell(row: row, col: col, rowCount: _kShellRows, tile: null),
      );
    }

    // A column count is a function of the space and the user's text size, so it
    // is decided here, where both are known, and re-decided when either changes
    // (rotation, keyboard, a settings change) — never per frame.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scaler = MediaQuery.textScalerOf(context);
        final direction = Directionality.of(context);
        // Measure against the weight the tile will actually paint: the platform
        // bold-text flag widens advances, and a column count that ignored it
        // would clip a label the instant bold is on.
        final labelStyle = AacType.tile.copyWith(
          fontWeight: MediaQuery.boldTextOf(context)
              ? FontWeight.w800
              : null,
        );
        final labels = <String>[
          for (final tile in board.tiles)
            if (tile != null) tile.label,
        ];

        final cols = chooseColumns(
          contentWidth: width,
          maxCols: board.cols,
          labels: labels,
          style: labelStyle,
          scaler: scaler,
          direction: direction,
        );

        final cellCount = board.cellCount;
        final rowCount = (cellCount + cols - 1) ~/ cols;

        // The tallest a tile must be for no label to lose a line, versus the
        // height a tile would get if the rows simply divided the viewport. When
        // the division already gives that much, the grid fills the screen and
        // does not scroll — the default-text-size case, unchanged. When it does
        // not, tiles take the height they need and the plane scrolls.
        final needed = labels.isEmpty
            ? 0.0
            : minTileHeight(
                contentWidth: width,
                cols: cols,
                labels: labels,
                style: labelStyle,
                scaler: scaler,
                direction: direction,
              );
        final natural = (height - (rowCount - 1) * Geom.gapRow) / rowCount;
        final scrolls = needed > natural + 0.5;

        // The tile's LOGICAL coordinate travels with it into whatever column it
        // lands in: taps, the lit state, and the key all resolve by (row, col),
        // so the reflow moves the widget without moving its identity.
        Widget cellAt(int visualRow, int visualCol) {
          final index = visualRow * cols + visualCol;
          if (index >= cellCount) return const SizedBox.shrink();
          final logicalRow = index ~/ board.cols;
          final logicalCol = index % board.cols;
          return _BoardCell(
            row: logicalRow,
            col: logicalCol,
            // The board's LOGICAL row count, so a tile knows whether it can move
            // down — the reflow's visual row count is a different number.
            rowCount: board.rows,
            tile: board.tiles[index],
          );
        }

        return scrolls
            ? SingleChildScrollView(
                // Clamping, not bouncing: this is a speech surface, and an
                // overscroll glow or rubber-band on a board of quick phrases
                // reads as a toy. It scrolls only as far as there is content.
                physics: const ClampingScrollPhysics(),
                child: _scrollingGrid(
                  rows: rowCount,
                  cols: cols,
                  rowHeight: math.max(needed, natural),
                  cellAt: cellAt,
                ),
              )
            : _fixedGrid(rows: rowCount, cols: cols, cellAt: cellAt);
      },
    );
  }

  /// Rows that divide the viewport by flex — the grid fills the screen exactly,
  /// with no rounding slack that could overflow a pixel. Used whenever the tiles
  /// already fit, which is every board at the default text size.
  Widget _fixedGrid({
    required int rows,
    required int cols,
    required Widget? Function(int row, int col) cellAt,
  }) {
    return Column(
      children: <Widget>[
        for (var row = 0; row < rows; row++) ...<Widget>[
          if (row > 0) const SizedBox(height: Geom.gapRow),
          Expanded(child: _gridRow(row: row, cols: cols, cellAt: cellAt)),
        ],
      ],
    );
  }

  /// Rows of a fixed height, taller than the viewport share, so the enclosing
  /// scroll view has something to scroll. A scroll view gives its child
  /// unbounded height, so nothing here can flex-overflow.
  Widget _scrollingGrid({
    required int rows,
    required int cols,
    required double rowHeight,
    required Widget? Function(int row, int col) cellAt,
  }) {
    return Column(
      children: <Widget>[
        for (var row = 0; row < rows; row++) ...<Widget>[
          if (row > 0) const SizedBox(height: Geom.gapRow),
          SizedBox(
            height: rowHeight,
            child: _gridRow(row: row, cols: cols, cellAt: cellAt),
          ),
        ],
      ],
    );
  }

  /// One row of `cols` equal cells.
  ///
  /// 14 across, 22 down. The gutters are unequal and that IS the composition:
  /// equal gutters in both axes read as a table, unequal read as a designed page
  /// and group the grid into rows, which is what the eye should find — a row of
  /// tiles shares its last baseline and scans as a line of type. Tidying these
  /// to one constant deletes the design and nothing goes red.
  Widget _gridRow({
    required int row,
    required int cols,
    required Widget? Function(int row, int col) cellAt,
  }) {
    return Row(
      children: <Widget>[
        for (var col = 0; col < cols; col++) ...<Widget>[
          if (col > 0) const SizedBox(width: Geom.gapColumn),
          // Expanded on a null cell too, so a short last row keeps its column
          // widths and the tiles above it stay put.
          Expanded(
            child: cellAt(row, col) ?? const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}

/// One cell: the only thing on the board that watches the lit state, and it
/// watches only its own.
class _BoardCell extends ConsumerWidget {
  const _BoardCell({
    required this.row,
    required this.col,
    required this.rowCount,
    required this.tile,
  });

  final int row;
  final int col;
  final int rowCount;
  final Tile? tile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lit = ref.watch(
      boardControllerProvider.select((s) => s.isLit(row, col)),
    );
    // Edit mode is app state, so it comes from Riverpod. Watched here per-cell
    // rather than threaded down so a mode flip rebuilds only the tiles.
    final editing = ref.watch(
      boardControllerProvider.select((s) => s.editing),
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
      editing: editing,
      rowCount: rowCount,
      // Edit-mode reorder and hide route through the controller, which resolves
      // the board id and writes in one transaction. Coordinates and the button
      // id, never captured content.
      onMoveUp: (r, c) =>
          ref.read(boardControllerProvider.notifier).moveTileUp(r, c),
      onMoveDown: (r, c) =>
          ref.read(boardControllerProvider.notifier).moveTileDown(r, c),
      onHide: (buttonId) =>
          ref.read(boardControllerProvider.notifier).hideTile(buttonId),
      onUnhide: (buttonId) =>
          ref.read(boardControllerProvider.notifier).unhideTile(buttonId),
      // ref.read INSIDE the callback, and coordinates rather than content. The
      // watched value from build() would be the phrase as it was at the last
      // rebuild: a fast re-tap after an edit would speak the previous sentence.
      //
      // The arrow is safe here only because onTilePressed returns void. The
      // same line against an async method drops the Future and its error, and
      // no lint reports it.
      onPressed: (r, c) =>
          ref.read(boardControllerProvider.notifier).onTilePressed(r, c),
      // In edit mode a tap on a filled tile or an empty slot opens the editor
      // for that coordinate instead of speaking. Resolved at tap time from the
      // (row, col) key, never captured content.
      onEdit: (r, c) =>
          ref.read(boardControllerProvider.notifier).onEditPressed(r, c),
    );
  }
}
