import 'package:drift/drift.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/model/stock.dart';

/// How much a starter phrase is grounded in evidence.
///
/// The distinction is on the record because it must never be hidden: a
/// validated adult phrase list does not exist in public research, so all but a
/// few of these are the author's assumption about what someone will need. The
/// UI can surface this, and a future round can replace assumptions with what
/// real users actually reach for.
enum Evidence { attested, assumed }

/// One seeded phrase, with its provenance attached.
///
/// Provenance is not metadata here; it is the point. Pre-filling a stranger's
/// board with sentences they did not write is presumptuous, and the honest
/// answer to that is to say plainly who wrote each line and why — which turns a
/// presumption into a gift the user can keep, edit, or throw away.
class StarterPhrase {
  const StarterPhrase({
    required this.label,
    required this.says,
    required this.stock,
    required this.priority,
    required this.row,
    required this.col,
    required this.evidence,
    required this.note,
    required this.dated,
    this.isSystem = false,
  });

  /// What the tile shows. At most 16 characters — the tile is a handle for the
  /// utterance, never the utterance.
  final String label;

  /// What is spoken and shown large. Curly apostrophes only; no terminal period
  /// on the handle, no exclamation marks anywhere — an AAC utterance in caps or
  /// with a bang reads as shouting, which is the opposite of the signal.
  final String says;

  final Stock stock;

  /// Traversal priority, unique across the set. Decoupled from screen position:
  /// the highest-priority phrases sit in the lower-centre arc for the thumb, but
  /// are read first by a screen reader.
  final int priority;

  /// Fixed placement on the 4-row by 3-column board.
  final int row;
  final int col;

  /// The repair phrase. Exactly one is a system phrase; it is undeletable
  /// because retracting a mis-tap is something the user must always be able to
  /// say, and there is no separate STOP control to fall back on.
  final bool isSystem;

  final Evidence evidence;
  final String note;
  final String dated;
}

/// The starter board: twelve phrases on a 4-row by 3-column grid.
///
/// Laid out so the lower-centre arc — closest to a thumb and read first — holds
/// the phrases someone in a shutdown is most likely to need, and the repair
/// phrase sits bottom-centre where a mis-tap is corrected without hunting.
const List<StarterPhrase> kStarterPhrases = <StarterPhrase>[
  // Row 0 — courtesy and the two words that answer most questions.
  StarterPhrase(
    label: 'Thank you',
    says: 'Thank you.',
    stock: Stock.fir,
    priority: 10,
    row: 0,
    col: 0,
    evidence: Evidence.assumed,
    note:
        'Common courtesy; keeps the top row useful without spending a '
        'high-priority slot on it.',
    dated: '2026-07',
  ),
  StarterPhrase(
    label: 'Yes',
    says: 'Yes.',
    stock: Stock.slate,
    priority: 11,
    row: 0,
    col: 1,
    evidence: Evidence.assumed,
    note: 'A one-tap answer so a closed question does not force typing.',
    dated: '2026-07',
  ),
  StarterPhrase(
    label: 'No',
    says: 'No.',
    stock: Stock.tan,
    priority: 12,
    row: 0,
    col: 2,
    evidence: Evidence.assumed,
    note: 'The pair to Yes. Placed beside it so the two read as one control.',
    dated: '2026-07',
  ),

  // Row 1 — orienting a listener who does not yet understand the situation.
  StarterPhrase(
    label: 'I can hear you',
    says: 'I can hear you. I just can’t speak right now.',
    stock: Stock.slate,
    priority: 4,
    row: 1,
    col: 0,
    evidence: Evidence.assumed,
    note:
        'Separates receptive from expressive language for a listener who '
        'assumes silence means not listening.',
    dated: '2026-07',
  ),
  StarterPhrase(
    label: 'Write it down?',
    says: 'Could you write that down for me?',
    stock: Stock.fir,
    priority: 9,
    row: 1,
    col: 1,
    evidence: Evidence.assumed,
    note: 'Shifts the exchange to a channel that works when speech does not.',
    dated: '2026-07',
  ),
  StarterPhrase(
    label: 'Too loud',
    says: 'It’s too loud in here for me right now.',
    stock: Stock.tan,
    priority: 7,
    row: 1,
    col: 2,
    evidence: Evidence.attested,
    note: 'Reported as an actual one-tap phrase by part-time AAC users.',
    dated: '2026-07',
  ),

  // Row 2 — asking for what the moment needs.
  StarterPhrase(
    label: 'I need a break',
    says: 'I need to take a break for a few minutes.',
    stock: Stock.tan,
    priority: 5,
    row: 2,
    col: 0,
    evidence: Evidence.attested,
    note: 'Reported as an actual one-tap phrase by part-time AAC users.',
    dated: '2026-07',
  ),
  StarterPhrase(
    label: 'Give me a minute',
    says: 'I just need a minute. I’m not ignoring you.',
    stock: Stock.fir,
    priority: 6,
    row: 2,
    col: 1,
    evidence: Evidence.assumed,
    note: 'Names the pause and pre-empts the reading of it as rudeness.',
    dated: '2026-07',
  ),
  StarterPhrase(
    label: 'I want to go',
    says: 'I want to go now.',
    stock: Stock.slate,
    priority: 8,
    row: 2,
    col: 2,
    evidence: Evidence.attested,
    note: 'Reported as an actual one-tap phrase by part-time AAC users.',
    dated: '2026-07',
  ),

  // Row 3 — the lower-centre arc: the highest-stakes phrases and repair.
  StarterPhrase(
    label: 'I can’t talk',
    says: 'I can’t speak right now. This isn’t personal.',
    stock: Stock.oxblood,
    priority: 1,
    row: 3,
    col: 0,
    evidence: Evidence.assumed,
    note:
        'The core disclosure the whole product exists to make possible; '
        'placed first in traversal and under the thumb.',
    dated: '2026-07',
  ),
  StarterPhrase(
    label: 'Wrong one',
    says: 'Sorry — that wasn’t what I meant to say.',
    stock: Stock.oxblood,
    priority: 3,
    row: 3,
    col: 1,
    isSystem: true,
    evidence: Evidence.assumed,
    note:
        'Repair is a phrase, not a button: there is no STOP control, so '
        'retracting a mis-tap has to be something the user can say. '
        'Undeletable for that reason.',
    dated: '2026-07',
  ),
  StarterPhrase(
    label: 'I need to leave',
    says: 'I need to leave now. I’m not able to stay.',
    stock: Stock.oxblood,
    priority: 2,
    row: 3,
    col: 2,
    evidence: Evidence.assumed,
    note: 'The escape phrase, bottom-centre beside the core disclosure.',
    dated: '2026-07',
  ),
];

/// Seeds the starter board into a freshly created database.
///
/// Called from the database's `onCreate`, which fires exactly once in the life
/// of the file, so this never re-runs and never overwrites a board the user has
/// since made their own. A board of twelve phrases is small enough that the
/// batch is more about atomicity than speed: a half-seeded board on first
/// launch is a worse first impression than a slow one.
Future<void> seedStarterBoard(AppDatabase db) async {
  const rows = 4;
  const cols = 3;

  final boardId = await db
      .into(db.boards)
      .insert(
        BoardsCompanion.insert(
          name: 'Home',
          gridRows: rows,
          gridCols: cols,
          isRoot: const Value<bool>(true),
        ),
      );

  await db.batch((batch) {
    // Every coordinate gets a slot, full or empty. A board always holds exactly
    // rows x cols slot rows; the grid never has a missing coordinate, only ones
    // whose button_id is null.
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        batch.insert(
          db.gridSlots,
          GridSlotsCompanion.insert(
            boardId: boardId,
            rowIndex: r,
            colIndex: c,
          ),
        );
      }
    }
  });

  // Insert each button, then point its slot at it. Not batched with the slots
  // above because a button's id is needed to fill its slot, and the ids are not
  // known until the rows are inserted.
  for (final phrase in kStarterPhrases) {
    final buttonId = await db
        .into(db.buttons)
        .insert(
          ButtonsCompanion.insert(
            boardId: boardId,
            label: phrase.label,
            vocalization: Value<String?>(phrase.says),
            backgroundColor: Value<String?>(phrase.stock.name),
            isSystem: Value<bool>(phrase.isSystem),
            priority: Value<int>(phrase.priority),
          ),
        );
    await (db.update(db.gridSlots)..where(
          (s) =>
              s.boardId.equals(boardId) &
              s.rowIndex.equals(phrase.row) &
              s.colIndex.equals(phrase.col),
        ))
        .write(GridSlotsCompanion(buttonId: Value<int?>(buttonId)));
  }
}
