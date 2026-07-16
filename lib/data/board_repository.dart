import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/model/board_grid.dart';

/// The only thing the UI may ask about boards.
///
/// Concrete, on purpose. There is one environment, no network, no auth, and
/// drift runs inside `flutter test` against real in-memory sqlite3 — so an
/// interface over it would abstract something that already runs in a test. A
/// Map-backed fake would be worse than none: it would accept a row the real
/// PRIMARY KEY (board_id, row_index, col_index) rejects. The test seam is one
/// `databaseProvider.overrideWithValue(db)`.
///
/// What this class does earn is a home for two things that must not live in a
/// widget: unpacking `List<TypedResult>` (drift emits a row class per table and
/// never per join), and enforcing grid bounds — the schema deliberately carries
/// no CHECK, because a 2x3 layout ships alongside the 3x4 default and a CHECK
/// would make that a database-level insert failure at v2.
final class BoardRepository {
  BoardRepository(this._db);

  final AppDatabase _db;

  /// `boards.is_root`. The board the app opens on.
  Future<int> rootBoardId() async {
    final board =
        await (_db.select(_db.boards)
              ..where((b) => b.isRoot.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (board == null) {
      throw StateError(
        'No board has is_root set. The seed did not run, or it ran and wrote '
        'no root — either way there is nothing to show and nothing on this '
        'device will report it. Fail loudly.',
      );
    }
    return board.id;
  }

  /// The reactive read the whole board surface hangs off.
  ///
  /// `gridProvider` is a StreamProvider over this, so Riverpod owns the
  /// subscription lifecycle and this class hand-manages no StreamSubscription
  /// and no StreamController.
  ///
  /// [includeHidden] is a parameter rather than a baked policy because speak
  /// mode and edit mode disagree: a hidden button is an empty cell to the
  /// former and a present, un-hideable-again tile to the latter.
  Stream<BoardGrid> watchGrid(int boardId, {bool includeHidden = false}) =>
      _gridQuery(boardId).watch().map(
        (rows) => _materialize(boardId, rows, includeHidden: includeHidden),
      );

  /// The one-shot form of [watchGrid].
  Future<BoardGrid> readGrid(int boardId, {bool includeHidden = false}) async {
    final rows = await _gridQuery(boardId).get();
    return _materialize(boardId, rows, includeHidden: includeHidden);
  }

  /// The point read the tap path uses.
  ///
  /// Keyed by POSITION, because (board_id, row_index, col_index) is the primary
  /// key and position is the one thing that cannot go stale between the frame
  /// that built the tile and the finger that pressed it. Resolving by a
  /// captured Tile means a fast re-tap can speak the previous tile's sentence:
  /// the wrong words, out loud, to a stranger.
  ///
  /// Null means empty (or hidden, when [includeHidden] is false).
  Future<Tile?> tileAt(
    int boardId,
    int row,
    int col, {
    bool includeHidden = false,
  }) async {
    final board = await _requireBoard(boardId);
    _checkBounds(board, row, col);

    final q = _gridQuery(boardId)
      ..where(
        _db.gridSlots.rowIndex.equals(row) & _db.gridSlots.colIndex.equals(col),
      );
    final result = await q.getSingleOrNull();
    if (result == null) {
      // The slot row is gone. That is a lost coordinate, not an empty cell —
      // and the difference matters enough to say out loud.
      throw StateError(
        'Board $boardId has no slot at ($row, $col), but its grid is '
        '${board.gridRows}x${board.gridCols}. A coordinate has been lost.',
      );
    }
    return _tileFrom(result, includeHidden: includeHidden);
  }

  // --- writes ---------------------------------------------------------------

  /// Put a new button in a slot.
  ///
  /// Two statements, one transaction: insert the button, then point the
  /// EXISTING slot row at it. Never an insert of a second slot row — the
  /// composite PK makes a duplicate coordinate a constraint failure, and that
  /// failure is a signal, not something to `insertOnConflictUpdate` past.
  ///
  /// Returns the new button's id.
  Future<int> placeTile(
    int boardId,
    int row,
    int col, {
    required String label,
    String? vocalization,
    String? displayText,
  }) async {
    final board = await _requireBoard(boardId);
    _checkBounds(board, row, col);
    _checkLabel(label);

    return _db.transaction(() async {
      final buttonId = await _db
          .into(_db.buttons)
          .insert(
            ButtonsCompanion.insert(
              boardId: boardId,
              label: label,
              vocalization: Value<String?>(vocalization),
              displayText: Value<String?>(displayText),
              // The user placed it, so it is theirs from birth: no future seed
              // step, default-set update, or migration may ever touch it.
              userEdited: const Value<bool>(true),
            ),
          );

      final updated =
          await (_db.update(_db.gridSlots)..where(
                (s) =>
                    s.boardId.equals(boardId) &
                    s.rowIndex.equals(row) &
                    s.colIndex.equals(col),
              ))
              .write(GridSlotsCompanion(buttonId: Value<int?>(buttonId)));
      if (updated != 1) {
        throw StateError(
          'Board $boardId has no slot at ($row, $col) to place into. A board '
          'always holds exactly grid_rows x grid_cols slot rows.',
        );
      }
      return buttonId;
    });
  }

  /// Edit what a tile shows, speaks, and renders.
  ///
  /// All three arrive together because they are one editor submission, and
  /// because passing them one at a time is how two of them get swapped. Null
  /// [vocalization] / [displayText] mean "fall back", which is the schema's own
  /// meaning for NULL — not "leave unchanged".
  Future<void> editTileText(
    int buttonId, {
    required String label,
    String? vocalization,
    String? displayText,
  }) async {
    _checkLabel(label);
    final updated =
        await (_db.update(
          _db.buttons,
        )..where((b) => b.id.equals(buttonId))).write(
          ButtonsCompanion(
            label: Value<String>(label),
            vocalization: Value<String?>(vocalization),
            displayText: Value<String?>(displayText),
            userEdited: const Value<bool>(true),
            updatedAt: Value<DateTime>(DateTime.now()),
          ),
        );
    if (updated != 1) {
      throw StateError('No button #$buttonId to edit.');
    }
  }

  /// Hide, never delete. Removing content from view is not a reason to destroy
  /// it — the row survives and un-hiding is free.
  Future<void> setHidden(int buttonId, {required bool hidden}) async {
    final updated =
        await (_db.update(
          _db.buttons,
        )..where((b) => b.id.equals(buttonId))).write(
          ButtonsCompanion(
            hidden: Value<bool>(hidden),
            userEdited: const Value<bool>(true),
            updatedAt: Value<DateTime>(DateTime.now()),
          ),
        );
    if (updated != 1) {
      throw StateError('No button #$buttonId to hide.');
    }
  }

  /// Delete a tile = delete the BUTTON.
  ///
  /// Never `delete(gridSlots)`. Deleting the slot row removes the coordinate,
  /// and the next write reflows the board: the user presses their muscle-memory
  /// tile and says the wrong sentence to a stranger, mid-shutdown, with no way
  /// to verbally correct it. Deleting the button lets `onDelete: setNull` write
  /// NULL into `button_id`, so the slot survives — empty, in place, nothing
  /// moves.
  ///
  /// That FK action is silently a no-op unless `PRAGMA foreign_keys = ON` ran
  /// on this connection. AppDatabase does it unconditionally in beforeOpen; if
  /// that ever regresses, this method quietly leaves a dangling reference and a
  /// blank tile forever.
  Future<void> deleteTile(int buttonId) async {
    final button = await (_db.select(
      _db.buttons,
    )..where((b) => b.id.equals(buttonId))).getSingleOrNull();
    if (button == null) {
      throw StateError('No button #$buttonId to delete.');
    }
    if (button.isSystem) {
      // The repair phrase. Refused here rather than merely not offered by the
      // UI: a rule enforced only by a widget is a rule one screen away from
      // being gone.
      throw StateError(
        'Button #$buttonId is a system button (the repair phrase) and cannot '
        'be deleted. Hide it instead.',
      );
    }
    await (_db.delete(
      _db.buttons,
    )..where((b) => b.id.equals(buttonId))).go();
  }

  // --- internals ------------------------------------------------------------

  /// grid_slots ⟕ buttons ⟕ images, with boards joined in too.
  ///
  /// The driving table is grid_slots: an empty cell is a real row with
  /// `button_id IS NULL`, so buttons must be a LEFT join, and images must be
  /// one because `buttons.image_id` is nullable.
  ///
  /// boards is joined rather than read separately for one reason: drift's
  /// `.watch()` only re-fires for tables named in the query, and a board whose
  /// grid_rows changed under a stream that never noticed is a grid drawn at the
  /// wrong size.
  ///
  /// Note what is NOT here: `WHERE buttons.hidden = 0`. On a left join that
  /// also drops the slot row for every empty cell (NULL is not 0), silently
  /// returning fewer than rows x cols coordinates. Hidden is resolved after the
  /// read, on the button.
  JoinedSelectStatement<HasResultSet, dynamic> _gridQuery(int boardId) =>
      _db.select(_db.gridSlots).join(<Join<HasResultSet, dynamic>>[
        innerJoin(_db.boards, _db.boards.id.equalsExp(_db.gridSlots.boardId)),
        leftOuterJoin(
          _db.buttons,
          _db.buttons.id.equalsExp(_db.gridSlots.buttonId),
        ),
        leftOuterJoin(_db.images, _db.images.id.equalsExp(_db.buttons.imageId)),
      ])..where(_db.gridSlots.boardId.equals(boardId));

  BoardGrid _materialize(
    int boardId,
    List<TypedResult> rows, {
    required bool includeHidden,
  }) {
    if (rows.isEmpty) {
      throw StateError(
        'Board $boardId returned no slot rows. Either the board does not '
        'exist or every one of its coordinates is gone.',
      );
    }

    // Dimensions come from the boards row, never a const. `const kRows = 4`
    // here would make the 2x3 large layout a v2 migration.
    final board = rows.first.readTable(_db.boards);
    final gridRows = board.gridRows;
    final gridCols = board.gridCols;

    // Allocate the full grid and PLACE each slot at its coordinate. Building it
    // by appending would let a missing slot row shift every later tile up one
    // cell — the exact reflow this schema exists to make unrepresentable.
    final tiles = List<Tile?>.filled(gridRows * gridCols, null);

    for (final result in rows) {
      // Safe with readTable ONLY because grid_slots is the driving table. On
      // the joined tables it throws at runtime, with no compile error and no
      // analyzer warning — and the first report would be a person whose board
      // went blank.
      final slot = result.readTable(_db.gridSlots);
      if (slot.rowIndex < 0 ||
          slot.rowIndex >= gridRows ||
          slot.colIndex < 0 ||
          slot.colIndex >= gridCols) {
        throw StateError(
          'Board $boardId is ${gridRows}x$gridCols but holds a slot at '
          '(${slot.rowIndex}, ${slot.colIndex}). Dropping it silently would '
          'hide real corruption.',
        );
      }

      // A null button is an EMPTY CELL, not a row to skip. Filtering these out
      // looks like a tidy guard and collapses the grid.
      final tile = _tileFrom(result, includeHidden: includeHidden);
      tiles[slot.rowIndex * gridCols + slot.colIndex] = tile;
    }

    return BoardGrid(
      boardId: boardId,
      rows: gridRows,
      cols: gridCols,
      tiles: tiles,
    );
  }

  /// The one place the three Strings are resolved. Exactly one, deliberately:
  /// label / vocalization / display_text are indistinguishable to the type
  /// system, so a second resolution site is a second chance to swap them.
  Tile? _tileFrom(TypedResult result, {required bool includeHidden}) {
    final slot = result.readTable(_db.gridSlots);
    final button = result.readTableOrNull(_db.buttons);
    if (button == null) {
      return null;
    }
    if (button.hidden && !includeHidden) {
      // Resolves to an empty cell. The slot row is untouched, so the
      // coordinate — and every tile after it — stays exactly where it was.
      return null;
    }

    final image = result.readTableOrNull(_db.images);

    return Tile(
      buttonId: button.id,
      row: slot.rowIndex,
      col: slot.colIndex,
      label: button.label,
      vocalization: button.vocalization ?? button.label,
      displayText: button.displayText ?? (button.vocalization ?? button.label),
      hidden: button.hidden,
      isSystem: button.isSystem,
      priority: button.priority,
      // Handed on RELATIVE, exactly as stored. The DB lives in the support
      // directory and media lives under documents; joining a media path against
      // the wrong base fails silently, permanently, invisibly. The helper that
      // owns the documents base does that, and nothing else may.
      imagePath: image?.path,
      imageAttribution: image?.attribution,
      backgroundColor: button.backgroundColor,
      borderColor: button.borderColor,
    );
  }

  Future<Board> _requireBoard(int boardId) async {
    final board = await (_db.select(
      _db.boards,
    )..where((b) => b.id.equals(boardId))).getSingleOrNull();
    if (board == null) {
      throw StateError('No board #$boardId.');
    }
    return board;
  }

  /// Bounds live here because SQLite CHECK cannot reference another table, and
  /// because a CHECK would bake the 3x4 phone layout into the primary key's own
  /// table — making the 2x3 large layout an insert failure at v2.
  void _checkBounds(Board board, int row, int col) {
    if (row < 0 || row >= board.gridRows) {
      throw RangeError.range(row, 0, board.gridRows - 1, 'row');
    }
    if (col < 0 || col >= board.gridCols) {
      throw RangeError.range(col, 0, board.gridCols - 1, 'col');
    }
  }

  /// The tile is a HANDLE for an utterance, not the utterance — which is what
  /// makes a cap safe at all. Refuse at the cap; never silently truncate, since
  /// an ellipsis on an AAC utterance is a different utterance.
  void _checkLabel(String label) {
    if (label.isEmpty || label.length > _labelMaxChars) {
      throw ArgumentError.value(
        label,
        'label',
        'must be 1..$_labelMaxChars characters',
      );
    }
  }

  static const int _labelMaxChars = 16;
}

/// The seam. Throwing by default is deliberate: an un-overridden seam fails at
/// first read with a clear message instead of silently constructing a second
/// database. The real one is built in main() before runApp and injected via
/// ProviderScope(overrides:), so tests get the app's wiring minus the platform.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final Provider<BoardRepository> boardRepositoryProvider =
    Provider<BoardRepository>(
      (ref) => BoardRepository(ref.watch(databaseProvider)),
    );
