import 'dart:async';

import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/speak_outcome.dart';

/// A hand-written fake, not a mock.
///
/// The interface has three methods. A fake is shorter than the mock setup would
/// be, survives a rename without a regeneration step, and — the real reason —
/// it lets a test say "the engine reports success and emits nothing" or "the
/// stored voice vanished between launches" as a *state*, which is how those
/// failures actually present. A mock would assert that a method was called; the
/// question here is always what the user heard.
class FakeSpeechService implements SpeechService {
  FakeSpeechService({
    List<Voice>? voices,
    this.outcome = const SpokeAloud(),
    this.warmUpCompletes = true,
  }) : _voices =
           voices ??
           const [
             Voice(
               name: 'v-a',
               locale: 'en-US',
               networkRequired: false,
               features: <String>{},
             ),
           ];

  final List<Voice> _voices;

  /// What [speak] returns. Set it to a failure variant to prove the UI reacts
  /// rather than falling silent.
  SpeakOutcome outcome;

  /// When false, [warmUp] never completes. This is how a test proves the first
  /// frame does not wait on the engine: binder IPC and voice deserialization run
  /// synchronously on the main thread inside the engine's init listener, so a
  /// warm-up that is awaited on the launch path is an ANR no profile surfaces.
  final bool warmUpCompletes;

  /// Every string passed to [speak], in order. The assertion that matters is
  /// usually "the fallback was AUDIBLE" — i.e. something reached here — rather
  /// than "no exception was thrown".
  final List<String> spoken = [];

  int stopCount = 0;
  bool warmUpCalled = false;

  final Completer<void> _warmUp = Completer<void>();

  Future<void> warmUp() {
    warmUpCalled = true;
    if (warmUpCompletes && !_warmUp.isCompleted) _warmUp.complete();
    return _warmUp.future;
  }

  @override
  Future<SpeakOutcome> speak(String text) async {
    spoken.add(text);
    return outcome;
  }

  @override
  Future<void> stop() async => stopCount++;

  @override
  Future<List<Voice>> voices() async => _voices;
}
