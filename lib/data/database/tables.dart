import 'package:drift/drift.dart';

/// The six tables.
///
/// The schema is not storage. It is where three product rules are made
/// unrepresentable rather than merely policed:
///
///  1. A tile never moves.            -> position is the primary key.
///  2. Shown text is not spoken text. -> three separate columns.
///  3. User edits are never lost.     -> hidden and userEdited, never DELETE.
///
/// Preserve them in that spirit. Nothing here will ever be corrected by a bug
/// report: a user who cannot speak does not file one, and this app has no
/// telemetry.
@DataClassName('Board')
class Boards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get locale => text().withDefault(const Constant('en'))();

  /// The grid is NOT hardcoded 3x4. A 2x3 large layout ships alongside it, so
  /// bounds live here as data and are enforced in BoardRepository — never as a
  /// SQL CHECK, which would make the 2x3 layout an insert failure at v2.
  IntColumn get gridRows => integer().named('grid_rows')();
  IntColumn get gridCols => integer().named('grid_cols')();

  BoolColumn get isRoot =>
      boolean().named('is_root').withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}

@DataClassName('Button')
class Buttons extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get boardId => integer()
      .named('board_id')
      .references(Boards, #id, onDelete: KeyAction.cascade)();

  /// What the tile SHOWS. Capped at 16 characters — the editor refuses at the
  /// cap and never silently truncates, because an ellipsis on an AAC utterance
  /// is a *different utterance*. The cap is safe only because the tile is a
  /// handle for the phrase, not the phrase.
  TextColumn get label => text().withLength(min: 1, max: 16)();

  /// What is SPOKEN. Uncapped. NULL falls back to [label].
  ///
  /// The tile shows "Overwhelmed"; it speaks "I need to leave, I'm not able to
  /// talk right now". Nothing in the type system distinguishes three Strings,
  /// so getting these backwards means a screen-reader user hears a paragraph on
  /// every scan step, or a stranger hears the wrong sentence.
  TextColumn get vocalization => text().nullable()();

  /// What show-text mode RENDERS. NULL falls back to `vocalization ?? label`.
  TextColumn get displayText => text().named('display_text').nullable()();

  /// Hide, never delete. Removing content is not a reason to destroy it.
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();

  /// The repair phrase. Undeletable. There is no STOP tile — the lit tile is
  /// the stop control, and repair is a phrase the user says, not a button the
  /// app supplies.
  BoolColumn get isSystem =>
      boolean().named('is_system').withDefault(const Constant(false))();

  /// Set to true the moment the user touches a tile. A HARD STOP: never
  /// overwrite, "upgrade", or reconcile a tile the user has touched — not in a
  /// migration, not in a seed step, not in a default-set update. User data is
  /// unmergeable ground truth.
  BoolColumn get userEdited =>
      boolean().named('user_edited').withDefault(const Constant(false))();

  /// Screen-reader and switch-scan order, decoupled from screen position.
  ///
  /// The highest-value phrases sit in the lower-centre arc for the thumb, but a
  /// linear scanner reads top-to-bottom, so without this the most important
  /// phrase is the 8th-to-11th thing announced — eight seconds under autoscan
  /// for someone who needs to say "I need to leave". This is the sort key that
  /// puts it first in traversal while it stays put on screen. Lower is earlier.
  IntColumn get priority => integer().withDefault(const Constant(1000))();

  TextColumn get backgroundColor =>
      text().named('background_color').nullable()();
  TextColumn get borderColor => text().named('border_color').nullable()();
  IntColumn get imageId => integer()
      .named('image_id')
      .nullable()
      .references(Images, #id, onDelete: KeyAction.setNull)();
  IntColumn get soundId => integer()
      .named('sound_id')
      .nullable()
      .references(Sounds, #id, onDelete: KeyAction.setNull)();

  /// One level only. Never a tree.
  IntColumn get loadBoardId => integer().named('load_board_id').nullable()();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}

/// POSITION IS THE PRIMARY KEY.
///
/// An empty cell is a row with `button_id IS NULL` — not an absent row.
/// Deleting a tile writes NULL into its slot.
///
/// Why this is not a normalization mistake: position-based muscle memory is the
/// retrieval channel most likely to survive a shutdown. A tile that MOVES is
/// worse than a tile that is MISSING — the user presses it and says the wrong
/// sentence at the worst possible moment. Every ordered-list schema eventually
/// reflows: a delete shifts everything up, and the defence is application logic
/// one forgotten WHERE clause away from failing silently. With position as the
/// key there is no ordering to recompute, so reflow is not prevented — it is
/// UNREPRESENTABLE. That is the only kind of guarantee that survives 2am.
///
/// NEVER add a surrogate `id` here. Never add an `order`, `position`, or
/// `index` column. That single change permits two rows claiming the same
/// (row_index, col_index) and quietly re-enables the exact failure this table
/// exists to prevent. No test and no crash report will surface it; it manifests
/// only as a real person saying the wrong sentence out loud.
class GridSlots extends Table {
  IntColumn get boardId => integer()
      .named('board_id')
      .references(Boards, #id, onDelete: KeyAction.cascade)();

  // `row` is a SQLite keyword, and these are primary-key columns. Renaming a PK
  // column later is a TableMigration against live data. Name them right now.
  IntColumn get rowIndex => integer().named('row_index')();
  IntColumn get colIndex => integer().named('col_index')();

  IntColumn get buttonId => integer()
      .named('button_id')
      .nullable()
      .references(Buttons, #id, onDelete: KeyAction.setNull)();

  /// autoIncrement() implies PRIMARY KEY and will not compile alongside this
  /// override. That compile error is the architecture defending itself — do not
  /// work around it by dropping the override.
  @override
  Set<Column<Object>> get primaryKey => {boardId, rowIndex, colIndex};
}

/// Files on disk, paths in the DB. Never BLOBs.
///
/// Paths are stored RELATIVE to the app documents directory. An absolute path
/// dies on reinstall or restore when the container identifier changes: the row
/// survives, the file survives, and the tile renders blank forever with no
/// error and no telemetry.
@DataClassName('MediaImage')
class Images extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text()();
  TextColumn get contentType => text().named('content_type')();
  IntColumn get width => integer()();
  IntColumn get height => integer()();

  /// Symbol-set attribution lives here, per image, because a licence obligation
  /// that lives only in a README is one refactor from being unmet.
  TextColumn get license => text().nullable()();
  TextColumn get attribution => text().nullable()();
}

@DataClassName('MediaSound')
class Sounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text()();
  TextColumn get contentType => text().named('content_type')();
  IntColumn get durationMs => integer().named('duration_ms')();
}

/// Plain key/value. Restored before first paint — the theme especially, because
/// a flash of the wrong polarity is a sudden luminance change in an app that
/// bans them.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
