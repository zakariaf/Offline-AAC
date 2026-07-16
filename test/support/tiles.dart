import 'package:offline_aac/model/board_grid.dart';

/// A 4x3 board fixture whose traversal priority is deliberately NOT its layout
/// order, so a test can prove the screen reader is driven by priority rather
/// than by where a tile sits.
///
/// The highest-priority phrases (1, 2, 3) live in the BOTTOM row — the
/// lower-centre thumb arc — which is exactly where a naive row-major reader
/// would visit them last. If traversal followed layout, priority-1 would be the
/// tenth tile announced; the sort key is what makes it first.
///
/// One label is long (16 characters, the cap) so a fit test has a real worst
/// case; none is empty here — the empty-slot fixtures build on this.
final List<Tile?> kTestTiles = <Tile?>[
  // Row 0 — lowest priority, visited last.
  _t(0, 0, 'Thank you', 'Thank you.', 10),
  _t(0, 1, 'Yes', 'Yes.', 11),
  _t(0, 2, 'No', 'No.', 12),
  // Row 1.
  _t(1, 0, 'I can hear you', 'I can hear you.', 7),
  _t(1, 1, 'Write it down?', 'Could you write that down?', 8),
  _t(1, 2, 'Too loud', 'It’s too loud in here.', 9),
  // Row 2.
  _t(2, 0, 'I need a break', 'I need a break.', 4),
  _t(2, 1, 'Give me a minute', 'I just need a minute.', 5),
  _t(2, 2, 'I want to go', 'I want to go now.', 6),
  // Row 3 — highest priority, in the thumb arc, read FIRST.
  _t(3, 0, 'I can’t talk', 'I can’t speak right now.', 1),
  _t(3, 1, 'Wrong one', 'Sorry — that wasn’t what I meant.', 2),
  _t(3, 2, 'I need to leave', 'I need to leave now.', 3),
];

/// The same tiles in the order a correct screen reader visits them: by
/// priority, ascending. Not equal to the layout order of [kTestTiles] — the
/// difference is the whole point of the traversal test.
final List<Tile> kByPriority = kTestTiles.whereType<Tile>().toList()
  ..sort((a, b) => a.priority.compareTo(b.priority));

Tile _t(int row, int col, String label, String says, int priority) => Tile(
  buttonId: row * 3 + col + 1,
  row: row,
  col: col,
  label: label,
  vocalization: says,
  displayText: says,
  hidden: false,
  isSystem: false,
  priority: priority,
);

/// A 4x3 grid of the fixture tiles, optionally with one coordinate emptied to a
/// null slot — a socket with nothing installed, for the empty-slot tests.
BoardGrid fixtureGrid({(int, int)? emptyAt}) {
  final tiles = List<Tile?>.from(kTestTiles);
  if (emptyAt != null) {
    final (r, c) = emptyAt;
    tiles[r * 3 + c] = null;
  }
  return BoardGrid(boardId: 1, rows: 4, cols: 3, tiles: tiles);
}

/// The six-tile large layout: a 3x2 board of the six highest-priority phrases.
///
/// At 200% a 20pt label becomes 40pt and twelve tiles arithmetically cannot
/// render on a phone; the 6-tile layout is a legitimate resolution, and the scale
/// matrix must run against it too so it never becomes the escape hatch nobody
/// tests. Carries the 16-character 'Give me a minute' so the worst case is real.
BoardGrid fixtureGrid6() {
  final six = kByPriority.take(6).toList();
  final tiles = <Tile?>[
    for (var i = 0; i < 6; i++)
      Tile(
        buttonId: six[i].buttonId,
        row: i ~/ 2,
        col: i % 2,
        label: six[i].label,
        vocalization: six[i].vocalization,
        displayText: six[i].displayText,
        hidden: false,
        isSystem: false,
        priority: six[i].priority,
      ),
  ];
  return BoardGrid(boardId: 1, rows: 3, cols: 2, tiles: tiles);
}
