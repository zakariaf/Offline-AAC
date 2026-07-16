import 'package:flutter/foundation.dart';

/// One displayable cell: `grid_slots` joined to `buttons` joined to `images`.
///
/// drift emits a data class per TABLE and never per JOIN, so this type has no
/// generated equivalent — that, and nothing else, is why it is hand-written.
/// Everything else persisted uses drift's row class directly.
///
/// The three text fields are already RESOLVED. Resolution happens in exactly
/// one place (BoardRepository) because nothing in the type system tells three
/// Strings apart: getting them backwards means a screen-reader user hears a
/// whole paragraph on every scan step, or a stranger hears the wrong sentence
/// on behalf of someone who cannot verbally correct it.
@immutable
final class Tile {
  const Tile({
    required this.buttonId,
    required this.row,
    required this.col,
    required this.label,
    required this.vocalization,
    required this.displayText,
    required this.hidden,
    required this.isSystem,
    required this.priority,
    this.imagePath,
    this.imageAttribution,
    this.backgroundColor,
    this.borderColor,
  });

  final int buttonId;

  /// The slot's coordinate. This is the primary key of the cell, and the only
  /// thing a tap may resolve by — position cannot go stale between build and
  /// tap, whereas a captured Tile can.
  final int row;
  final int col;

  /// What the tile SHOWS. Never null, never ellipsized: an ellipsis on an AAC
  /// utterance is a different utterance.
  final String label;

  /// What is SPOKEN. Already falls back to [label].
  final String vocalization;

  /// What show-text mode RENDERS. Already falls back to `vocalization ?? label`.
  final String displayText;

  /// True only in an edit-mode read. A hidden button resolves to an empty cell
  /// in the speak read — the slot row still exists, so the coordinate holds.
  final bool hidden;

  /// The repair phrase. Undeletable; the repository refuses the delete rather
  /// than trusting the UI not to offer it.
  final bool isSystem;

  /// Screen-reader and switch-scan order — lower is announced first — decoupled
  /// from screen position, so the most-needed phrase in the lower-centre arc is
  /// read first rather than eighth. Drives the tile's `OrdinalSortKey`.
  final int priority;

  /// RELATIVE to the app documents directory, exactly as stored. Never joined
  /// here: the DB file lives in the SUPPORT directory, and a path built from
  /// the wrong base fails silently, permanently, invisibly. Resolve it through
  /// the one helper that owns the documents base.
  final String? imagePath;

  /// Symbol-set attribution travels with the tile, because a licence
  /// obligation that lives only in a README is one refactor from being unmet.
  final String? imageAttribution;

  final String? backgroundColor;
  final String? borderColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile &&
          other.buttonId == buttonId &&
          other.row == row &&
          other.col == col &&
          other.label == label &&
          other.vocalization == vocalization &&
          other.displayText == displayText &&
          other.hidden == hidden &&
          other.isSystem == isSystem &&
          other.priority == priority &&
          other.imagePath == imagePath &&
          other.imageAttribution == imageAttribution &&
          other.backgroundColor == backgroundColor &&
          other.borderColor == borderColor;

  @override
  int get hashCode => Object.hash(
    buttonId,
    row,
    col,
    label,
    vocalization,
    displayText,
    hidden,
    isSystem,
    priority,
    imagePath,
    imageAttribution,
    backgroundColor,
    borderColor,
  );

  Tile copyWith({
    int? buttonId,
    int? row,
    int? col,
    String? label,
    String? vocalization,
    String? displayText,
    bool? hidden,
    bool? isSystem,
    int? priority,
  }) {
    return Tile(
      buttonId: buttonId ?? this.buttonId,
      row: row ?? this.row,
      col: col ?? this.col,
      label: label ?? this.label,
      vocalization: vocalization ?? this.vocalization,
      displayText: displayText ?? this.displayText,
      hidden: hidden ?? this.hidden,
      isSystem: isSystem ?? this.isSystem,
      priority: priority ?? this.priority,
      imagePath: imagePath,
      imageAttribution: imageAttribution,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    );
  }

  @override
  String toString() => 'Tile(#$buttonId at $row,$col: $label)';
}

/// A materialised `rows x cols` of `Tile?`.
///
/// The second and last hand-written model type: dimensions x nullable tiles is
/// a shape the schema deliberately does not have.
///
/// A null cell is a real, addressable, EMPTY cell — never a gap in a list. The
/// grid is allocated at full size and each slot is PLACED at its coordinate,
/// so a slot row that somehow went missing surfaces as one empty tile instead
/// of reflowing every tile after it. A tile that MOVES is worse than a tile
/// that is MISSING: the user presses their muscle-memory cell and says the
/// wrong sentence at the worst possible moment.
@immutable
final class BoardGrid {
  BoardGrid({
    required this.boardId,
    required this.rows,
    required this.cols,
    required List<Tile?> tiles,
  }) : _tiles = List<Tile?>.unmodifiable(tiles) {
    if (rows <= 0 || cols <= 0) {
      throw ArgumentError('Board $boardId has a ${rows}x$cols grid.');
    }
    if (tiles.length != rows * cols) {
      throw ArgumentError(
        'Board $boardId is ${rows}x$cols but got ${tiles.length} cells. '
        'A grid is always exactly rows x cols, empty cells included.',
      );
    }
  }

  final int boardId;
  final int rows;
  final int cols;

  /// Row-major, length `rows * cols`. Private so no caller can index it with
  /// its own arithmetic and get the transpose.
  final List<Tile?> _tiles;

  /// Every cell in row-major order, empty ones included. Length is always
  /// `rows * cols`.
  List<Tile?> get tiles => _tiles;

  int get cellCount => _tiles.length;

  /// Null means the cell is empty (or hidden, in a speak read) — it does not
  /// mean the cell is absent. Out of bounds throws: coordinates come from this
  /// grid, so one that does not fit is a defect, and a defect in an app with no
  /// telemetry must be loud rather than silently null.
  Tile? tileAt(int row, int col) {
    if (row < 0 || row >= rows) {
      throw RangeError.range(row, 0, rows - 1, 'row');
    }
    if (col < 0 || col >= cols) {
      throw RangeError.range(col, 0, cols - 1, 'col');
    }
    return _tiles[row * cols + col];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardGrid &&
          other.boardId == boardId &&
          other.rows == rows &&
          other.cols == cols &&
          listEquals(other._tiles, _tiles);

  @override
  int get hashCode => Object.hash(boardId, rows, cols, Object.hashAll(_tiles));

  @override
  String toString() => 'BoardGrid(#$boardId ${rows}x$cols)';
}
