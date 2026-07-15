import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/crash_log.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/model/speak_outcome.dart';

/// The engine. Overridden on the root `ProviderScope` in `main()`, the same way
/// [databaseProvider] is, and overridden with a fake in tests.
///
/// It throws rather than defaulting to a real [SpeechService]: constructing the
/// plugin lazily from inside a widget build would bind the TTS engine on the
/// first tap, on the main thread, in the one moment latency is the product.
final Provider<SpeechService> speechServiceProvider = Provider<SpeechService>(
  (ref) => throw UnimplementedError('speechServiceProvider must be overridden'),
);

/// The on-device log, opened first thing in `main()`.
final Provider<CrashLog> crashLogProvider = Provider<CrashLog>(
  (ref) => throw UnimplementedError('crashLogProvider must be overridden'),
);

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
  yield* repository.watchGrid(await repository.rootBoardId());
});

/// What the board surface renders beyond the grid itself: which tile is lit,
/// and the words that did not make it out of the speaker.
@immutable
final class BoardUiState {
  const BoardUiState({this.litRow, this.litCol, this.fallbackText});

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

  bool isLit(int row, int col) => row == litRow && col == litCol;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardUiState &&
          other.litRow == litRow &&
          other.litCol == litCol &&
          other.fallbackText == fallbackText;

  @override
  int get hashCode => Object.hash(litRow, litCol, fallbackText);
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

  @override
  BoardUiState build() {
    ref.onDispose(() {
      // Riverpod 2.x has no `ref.mounted`; this flag is the guard for every
      // write that crosses an await.
      _disposed = true;
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
      _log('lit latch force-cleared after ${latchGuard.inSeconds}s');
      _holdElapsed = true;
      _outcomeArrived = true;
      _clearIfDone(token);
    });

    // unawaited is the greppable, intentional discard — and it is only honest
    // because of the catchError below it. Without one, the error goes to
    // PlatformDispatcher.onError, detached from the UI, and the user gets
    // nothing.
    unawaited(
      _speakAndSurface(token, text).catchError((Object e, StackTrace s) {
        // _speakAndSurface should not throw: speak() returns outcomes rather
        // than throwing for anything expected. If we land here, the log or the
        // engine seam itself threw. Show the words anyway; that is the product.
        _log('speak path threw: $e', s);
        _fallback = text;
        _outcomeArrived = true;
        _clearIfDone(token);
      }),
    );
  }

  Future<void> _speakAndSurface(int token, String text) async {
    final speech = ref.read(speechServiceProvider);

    // Barge-in, before every speak, unconditionally. This is what makes
    // "tap a different tile" mean "switch" rather than "queue".
    await speech.stop();
    final outcome = await speech.speak(text);

    // A newer press, a stop, or a teardown happened while the engine was busy.
    // This outcome is about an utterance nobody is waiting for any more.
    if (_disposed || token != _utterance) return;

    switch (outcome) {
      case SpokeAloud():
        break;
      // Matching the intermediate sealed type IS exhaustive, and a new
      // SpeakFailure variant will not break it — which is correct: every
      // failure resolves the same way. The user sees the words. There is no
      // `default:` here and there must never be one; it would disable the only
      // compiler-grade net available.
      case SpeakFailure(:final spokenText, :final logLine):
        // logLine only. The log is user-exportable and must never carry their
        // phrases: a user mailing it to a stranger must not mail their voice
        // with it.
        _log('speak failed: $logLine', StackTrace.current);
        _fallback = spokenText;
    }

    _outcomeArrived = true;
    _clearIfDone(token);
  }

  void _stop() {
    // Orphan the in-flight outcome before anything else: its completion must
    // not re-light or re-clear a latch the user just took back.
    _utterance++;
    _holdTimer?.cancel();
    _guardTimer?.cancel();
    state = const BoardUiState();

    unawaited(
      ref.read(speechServiceProvider).stop().catchError((
        Object e,
        StackTrace s,
      ) {
        // The tile is already dark and the engine is the only thing that can
        // still be talking. Nothing here is actionable by the user, but a stop
        // that fails silently is how a phrase keeps playing after they asked it
        // not to — so it lands in the log.
        _log('stop failed: $e', s);
      }),
    );
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
