import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/model/speak_outcome.dart';
import 'package:offline_aac/speech/speech_controller.dart';

/// The engine. Overridden on the root `ProviderScope` in `main()`, the same way
/// [databaseProvider] is, and overridden with a fake in tests.
///
/// It throws rather than defaulting to a real [SpeechService]: constructing the
/// plugin lazily from inside a widget build would bind the TTS engine on the
/// first tap, on the main thread, in the one moment latency is the product.
final Provider<SpeechService> speechServiceProvider = Provider<SpeechService>(
  (ref) => throw UnimplementedError('speechServiceProvider must be overridden'),
);

/// A mutable holder for the live voice the engine speaks with.
///
/// Shared between the speech service — which reads it at speak time, never
/// caches it, because Android garbage-collects voice data — and the voice
/// picker, which sets it when a preview succeeds so the very next tile tap uses
/// the chosen voice. Not a Notifier: the picker's own SELECTION highlight tracks
/// `settings.voiceId`, which is reactive; this holder only feeds the engine.
class CurrentVoice {
  Voice? value;
}

/// The [CurrentVoice] in force. Overridden at the root with the one instance the
/// speech service was constructed against, so a write here reaches the engine.
final Provider<CurrentVoice> currentVoiceProvider = Provider<CurrentVoice>(
  (ref) => CurrentVoice(),
);

/// The on-device log, opened first thing in `main()`.
final Provider<CrashLog> crashLogProvider = Provider<CrashLog>(
  (ref) => throw UnimplementedError('crashLogProvider must be overridden'),
);

/// The set of phrases the log's redaction net scrubs, kept in step with the live
/// board by `BoardScreen`. Defaults to an empty registry rather than throwing —
/// unlike [crashLogProvider], a test that never touches redaction should not have
/// to override it, and an empty net is a safe no-op. `main()` overrides it with
/// the one instance the [CrashLog] was pointed at.
final Provider<RedactionRegistry> redactionRegistryProvider =
    Provider<RedactionRegistry>((ref) => RedactionRegistry());

/// The board, live from disk.
///
/// Riverpod owns the subscription lifecycle, so nothing here or downstream
/// holds a subscription field, an `initState`, or a `dispose` to cancel one in.
///
/// Not auto-disposed, and that is the right default here: the grid IS the app.
final StreamProvider<BoardGrid> gridProvider = StreamProvider<BoardGrid>((
  ref,
) async* {
  final repository = ref.watch(boardRepositoryProvider);
  // includeHidden: a hidden tile stays IN the grid so edit mode can show it and
  // offer Unhide. The tile carries its `hidden` flag; PhraseTile renders it as
  // an empty cell in speak mode and as a visible, unhide-able tile in edit mode.
  // Resolving hidden->empty at read time here would make Unhide unreachable.
  yield* repository.watchGrid(
    await repository.rootBoardId(),
    includeHidden: true,
  );
});

/// What the board surface renders beyond the grid itself: which tile is lit,
/// and the words that did not make it out of the speaker.
@immutable
final class BoardUiState {
  const BoardUiState({
    this.litRow,
    this.litCol,
    this.fallbackText,
    this.editing = false,
    this.editingSlot,
  });

  /// The coordinate of the tile that is currently speaking, or null.
  ///
  /// Null for typed text: there is no tile to light, because the phrase is not
  /// on the board.
  final int? litRow;
  final int? litCol;

  /// The phrase that was NOT spoken, for the screen to show instead.
  ///
  /// Every [SpeakFailure] carries the text it failed to say precisely so this
  /// can never be null when speech failed. Silence with nothing on screen is
  /// the worst outcome this app can produce, and no user will report it.
  final String? fallbackText;

  /// Whether the board is in edit mode. State, not a route: a mode duplicated
  /// into a second navigator entry drifts from the board it edits.
  ///
  /// Starts false on every launch and is NEVER persisted — a board that reopens
  /// in edit mode is a board that silently does not speak when tapped, and the
  /// user has no way to know why.
  final bool editing;

  /// The `(row, col)` whose editor is open, or null when the grid is showing.
  /// A coordinate, never a captured tile: the editor resolves the phrase from
  /// the live grid so a fast re-open after a save never edits stale content.
  final (int row, int col)? editingSlot;

  bool isLit(int row, int col) => row == litRow && col == litCol;

  BoardUiState copyWith({
    int? litRow,
    int? litCol,
    String? fallbackText,
    bool? editing,
    (int, int)? editingSlot,
  }) {
    return BoardUiState(
      litRow: litRow ?? this.litRow,
      litCol: litCol ?? this.litCol,
      fallbackText: fallbackText ?? this.fallbackText,
      editing: editing ?? this.editing,
      editingSlot: editingSlot ?? this.editingSlot,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardUiState &&
          other.litRow == litRow &&
          other.litCol == litCol &&
          other.fallbackText == fallbackText &&
          other.editing == editing &&
          other.editingSlot == editingSlot;

  @override
  int get hashCode =>
      Object.hash(litRow, litCol, fallbackText, editing, editingSlot);
}

/// The board's behaviour: press, speak, stop, and the lit latch.
///
/// This class exists to make the app's worst bug unrepresentable rather than
/// merely forbidden. Every method a widget may call returns `void`, so there is
/// no Future at a tap site to drop.
class BoardController extends Notifier<BoardUiState> {
  /// The floor on how long the lit state persists, so a fast tap is never
  /// imperceptible.
  ///
  /// It is a boolean and a `Timer`, never a fade and never a curve. Snapping is
  /// the design.
  static const Duration minimumHold = Duration(milliseconds: 120);

  /// The independent guard that force-clears the latch.
  ///
  /// The speech seam already gives up on the engine call at 8s, but that covers
  /// the CALL, not the utterance: an engine that accepts and then never reports
  /// completion sails past it entirely, and `flutter_tts` completion-handler
  /// reliability varies by OEM. A tile lit forever is the app lying about what
  /// it is doing, and nobody will ever report it.
  ///
  /// The 8s seam plus headroom. It is a judgment call, not a measured value —
  /// it only has to be longer than any real utterance and short enough that a
  /// stuck tile recovers on its own.
  static const Duration latchGuard = Duration(seconds: 10);

  Timer? _holdTimer;
  Timer? _guardTimer;

  /// Monotonic id of the utterance in flight. Every new press, and every stop,
  /// bumps it — which orphans the previous speak's outcome instead of letting
  /// it clear a latch that now belongs to a different tile.
  int _utterance = 0;

  bool _holdElapsed = false;
  bool _outcomeArrived = false;
  String? _fallback;
  bool _disposed = false;

  /// The speak path lives here, not in this class. This controller only owns the
  /// lit latch — the visible confirmation that a tap landed — and delegates the
  /// actual barge-in-speak-or-show-the-words to a widget-free [SpeechController]
  /// that is unit-tested against every way the engine can fail.
  late final SpeechController _speech;

  @override
  BoardUiState build() {
    _speech = SpeechController(
      speech: ref.read(speechServiceProvider),
      log: ref.read(crashLogProvider),
      // The words that did not leave the speaker go on screen. This is the
      // whole point of the sealed outcome carrying its text.
      showText: (words) {
        _fallback = words;
      },
      // The utterance resolved — spoke or failed. Half of the latch clear; the
      // other half is the minimum hold, so a fast tap is never imperceptible.
      onSettled: () {
        if (_disposed) return;
        _outcomeArrived = true;
        _clearIfDone(_utterance);
      },
    );
    ref.onDispose(() {
      // Riverpod 2.x has no `ref.mounted`; this flag is the guard for every
      // write that crosses an await.
      _disposed = true;
      _speech.dispose();
      _holdTimer?.cancel();
      _guardTimer?.cancel();
    });
    return const BoardUiState();
  }

  /// A tile was pressed. VOID-RETURNING ON PURPOSE — do not "improve" this to
  /// `Future<void>`.
  ///
  /// `onPointerDown: (_) => c.onTilePressed(r, c)` is safe precisely because
  /// there is no Future to drop. Verified: `onPointerDown: (_) => s.speak(x)` is
  /// caught by NO lint — not `discarded_futures`, not `unawaited_futures`, not
  /// `@useResult`. The arrow closure returns the Future so every rule considers
  /// it used, and the callback's void target type discards it, and its error
  /// with it. A void return makes that hole unreachable.
  ///
  /// There is no `if (_speaking) return` here and there must never be one. A
  /// re-tap means "stop" or "say it again, NOW". Both become silence the moment
  /// a busy-guard swallows them.
  void onTilePressed(int row, int col) {
    // Pressing the lit tile stops it. That IS the stop control: there is no
    // STOP button, no red bar, no cancel affordance. An emergency control on
    // someone's board is a design about a bystander's fear of them.
    if (state.isLit(row, col)) {
      _stop();
      return;
    }

    // Resolved NOW, from the coordinate, never from a value the widget captured
    // in build(). A stale capture speaks the previous phrase out loud to a
    // stranger, on behalf of someone who cannot verbally correct it.
    final tile = ref.read(gridProvider).valueOrNull?.tileAt(row, col);
    if (tile == null) return;

    _speak(tile.vocalization, litRow: row, litCol: col);
  }

  /// Flip edit mode. A tap on a labelled, visible button, never a hidden
  /// long-press: long-press collides with dwell-style assistive input, where
  /// holding IS ordinary activation, and it is an invisible state machine
  /// nothing on screen describes.
  ///
  /// Any in-flight utterance is stopped as part of the switch — the lit latch
  /// belongs to speak mode, and a tile left lit into the editor is a lie about
  /// what the board is doing.
  void toggleEditing() {
    final next = !state.editing;
    if (state.litRow != null) {
      // _stop() resets the whole state to a resting speak-mode default, so the
      // new editing flag is re-applied on the clean state below.
      _stop();
    }
    state = state.copyWith(editing: next);
  }

  /// A tile or empty slot was tapped IN EDIT MODE. Opens the editor for that
  /// coordinate rather than speaking.
  ///
  /// The coordinate is the primary key and cannot go stale; the editor resolves
  /// the tile from it at open time. The editor surface itself is E07-T02; this
  /// is the routing seam the tile taps into.
  void onEditPressed(int row, int col) {
    state = state.copyWith(editingSlot: (row, col));
  }

  /// Close the editor and return to the grid. Editing stays on — closing one
  /// tile's editor does not leave edit mode.
  void closeEditor() {
    if (state.editingSlot == null) return;
    state = BoardUiState(editing: state.editing);
  }

  /// Move the tile at `(row, col)` up / down one row. Void, and the failure goes
  /// to the crash log rather than being dropped silently — the drift stream
  /// re-emits the new board, so there is no UI state to roll back here.
  void moveTileUp(int row, int col) =>
      _runEdit((repo, boardId) => repo.moveUp(boardId, row, col));

  void moveTileDown(int row, int col) =>
      _runEdit((repo, boardId) => repo.moveDown(boardId, row, col));

  /// Hide / unhide a button. Hide is the undo for removal; nothing is deleted.
  void hideTile(int buttonId) =>
      _runEdit((repo, _) => repo.setHidden(buttonId, hidden: true));

  void unhideTile(int buttonId) =>
      _runEdit((repo, _) => repo.setHidden(buttonId, hidden: false));

  void _runEdit(
    Future<void> Function(BoardRepository repo, int boardId) op,
  ) {
    final grid = ref.read(gridProvider).valueOrNull;
    if (grid == null) return;
    final repo = ref.read(boardRepositoryProvider);
    unawaited(
      op(repo, grid.boardId).catchError((Object error, StackTrace stack) {
        _log('board edit failed: $error', stack);
      }),
    );
  }

  /// The type-to-speak field was submitted. Void, for the same reason.
  ///
  /// The text is spoken EXACTLY as typed: no trim, no capitalisation, no
  /// appended period, no straight-to-curly rewrite. Rewriting a character under
  /// someone's cursor is hostile, and this is their sentence.
  void speakText(String text) {
    // Nothing typed, nothing said, and nothing shown. There is no error string
    // for "you typed nothing" because there is no accusation to make.
    if (text.trim().isEmpty) return;
    _speak(text);
  }

  void _speak(String text, {int? litRow, int? litCol}) {
    final token = ++_utterance;
    _holdTimer?.cancel();
    _guardTimer?.cancel();
    _holdElapsed = false;
    _outcomeArrived = false;
    _fallback = null;

    // Zero duration. The step is the feedback.
    state = BoardUiState(litRow: litRow, litCol: litCol);

    _holdTimer = Timer(minimumHold, () {
      _holdElapsed = true;
      _clearIfDone(token);
    });
    _guardTimer = Timer(latchGuard, () {
      // An engine that accepts and never reports completion sails past the
      // seam's own 8s call timeout; this force-clears the tile so it stops
      // lying about what it is doing.
      _log('lit latch force-cleared after ${latchGuard.inSeconds}s');
      _holdElapsed = true;
      _outcomeArrived = true;
      _clearIfDone(token);
    });

    // The speak path is the controller's job: barge-in, speak, and on any
    // failure put the words on screen and log the reason. It calls back
    // `showText`/`onSettled`, wired in `build`. No Future is returned here to
    // drop, which is the whole design.
    _speech.speakNow(text);
  }

  void _stop() {
    // Orphan the in-flight outcome before anything else: its completion must
    // not re-light or re-clear a latch the user just took back.
    _utterance++;
    _holdTimer?.cancel();
    _guardTimer?.cancel();
    state = const BoardUiState();
    _speech.stopNow();
  }

  /// Clears the latch once BOTH the minimum hold has elapsed and the utterance
  /// has resolved. Either alone is a lie: clearing early makes a fast tap
  /// imperceptible, and clearing late leaves a tile claiming to speak.
  void _clearIfDone(int token) {
    if (_disposed || token != _utterance) return;
    if (!_holdElapsed || !_outcomeArrived) return;
    _holdTimer?.cancel();
    _guardTimer?.cancel();
    state = BoardUiState(fallbackText: _fallback);
  }

  void _log(String message, [StackTrace? stack]) =>
      ref.read(crashLogProvider).record(message, stack);
}

/// The board's behaviour. Twelve tiles read one state; there is no family here
/// and there must not be one.
final NotifierProvider<BoardController, BoardUiState> boardControllerProvider =
    NotifierProvider<BoardController, BoardUiState>(BoardController.new);
