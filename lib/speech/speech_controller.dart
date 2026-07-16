import 'dart:async';

import 'package:offline_aac/data/crash_log.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/speak_outcome.dart';

/// The speak path, with the app's worst bug made unrepresentable.
///
/// A tile tap must produce speech OR the words on screen — never neither. The
/// hole this closes is specific and catches no lint: wiring a tap straight to
/// `speech.speak(text)` drops the returned Future, and its failure with it,
/// because the arrow closure "returns" the Future so every rule considers it
/// used while the `void` callback target discards it. [speakNow] is `void` and
/// consumes its own outcome, so there is no Future at a call site to drop.
///
/// Deliberately free of Flutter: no widget context, no widget, no provider. That
/// is what lets every way the world breaks be driven through it in a plain unit
/// test, which — with no telemetry and no user who can file a bug — is the only
/// place these failures are ever observed before a person hits them.
final class SpeechController {
  // The private initializing formals expose bare argument names (`speech:`,
  // `showText:`, `log:`, `onSettled:`) to callers, which is the intended API.
  SpeechController({
    required this._speech,
    required this._showText,
    required this._log,
    this._onSettled,
  });

  final SpeechService _speech;

  /// Called with the exact words that did NOT leave the speaker, so the screen
  /// can show them. Every [SpeakFailure] carries its `spokenText` precisely so
  /// this is never empty when speech fails.
  final void Function(String words) _showText;

  final CrashLog _log;

  /// Fires when the live utterance resolves — spoke or failed. The lit-state
  /// latch hangs off this; an orphaned utterance never fires it.
  final void Function()? _onSettled;

  /// Monotonic id of the utterance in flight. Every [speakNow] and every
  /// [stopNow] bumps it, which orphans a previous speak's outcome instead of
  /// letting a stale result drive the UI after the user has moved on.
  int _live = 0;
  bool _disposed = false;

  /// Speak [text] now. Barge-in first: any in-flight utterance is stopped, so a
  /// re-tap means "say it again / I need this NOW" rather than "queue". There is
  /// no `if (_speaking) return` here and there must never be one — a busy-guard
  /// turns exactly that re-tap into silence.
  void speakNow(String text) {
    final token = ++_live;
    // unawaited is the greppable, intentional discard, and it is only honest
    // because of the catchError. Without one, a throw goes to
    // PlatformDispatcher.onError — detached from the UI — and the user gets
    // nothing on screen and nothing from the speaker.
    unawaited(
      _run(token, text).catchError((Object e, StackTrace s) {
        if (_disposed || token != _live) return;
        // _run should not throw: speak() returns outcomes rather than throwing
        // for anything expected. Landing here means the engine seam itself
        // threw. Show the words anyway; that is the product.
        _log.record('speak path threw: $e', s);
        _show(text);
        _onSettled?.call();
      }),
    );
  }

  /// Shows [words], and if the UI callback itself throws, records that and
  /// carries on. `showText` reaches into a widget tree that can be mid-teardown;
  /// a throw there must not take the speak path down, or a failure to *render*
  /// the fallback becomes the very silence the fallback exists to prevent.
  void _show(String words) {
    try {
      _showText(words);
    } on Object catch (e, s) {
      _log.record('speak path threw: $e', s);
    }
  }

  /// Stop any in-flight utterance. This is the stop control — there is no STOP
  /// button — so it must never itself fail silently: a stop that throws is how a
  /// phrase keeps playing after the user asked it not to.
  void stopNow() {
    _live++;
    unawaited(
      _speech.stop().catchError((Object e, StackTrace s) {
        _log.record('stop failed: $e', s);
      }),
    );
  }

  void dispose() => _disposed = true;

  Future<void> _run(int token, String text) async {
    await _speech.stop();
    final outcome = await _speech.speak(text);

    // A newer press, a stop, or a teardown happened while the engine was busy.
    // This outcome is about an utterance nobody is waiting for any more.
    if (_disposed || token != _live) return;

    switch (outcome) {
      case SpokeAloud():
        break;
      // Matching the intermediate sealed type IS exhaustive: a new SpeakFailure
      // variant resolves here the same way, which is correct — every failure
      // shows the words. There is no `default:` and there must never be one; it
      // would disable the only compiler-grade net this path has.
      case SpeakFailure(:final spokenText, :final logLine):
        // logLine only. The log is user-exportable and must never carry a
        // phrase: a user mailing it to a stranger must not mail their voice.
        _log.record('speak failed: $logLine', StackTrace.current);
        _show(spokenText);
    }

    _onSettled?.call();
  }
}
