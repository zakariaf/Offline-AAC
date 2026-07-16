import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/data/speech/audio_session_config.dart';
import 'package:offline_aac/data/speech/flutter_tts_speech_service.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';

/// The cold-launch sequence.
///
/// The order is the whole file. Every step sits where it sits because moving it
/// produces a specific field failure that nobody will ever report: this app has
/// no telemetry and its users cannot speak. Read the comments before reordering
/// anything.
///
/// Deliberately NOT wrapped in a guarded error zone. The two handlers below are
/// Flutter's own guidance; a zone here would put `main()`'s body in a different
/// zone from `runApp()`, and the documented fix for the resulting mismatch
/// warning is to remove the zone again. The "you need all three" advice is
/// crash-SDK advice, and there is no SDK here — the privacy promise is the
/// product.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIRST, before anything that can throw. There is no crash reporting and
  // there never will be, so an error thrown with no handler installed is
  // invisible forever.
  final log = await CrashLog.open();

  // Errors inside Flutter's build/layout/paint callbacks. Unwrapped first: a
  // provider failure arrives wrapped, and logging the wrapper flattens every
  // entry to the same useless line.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.record(unwrapError(details.exception).toString(), details.stack);
  };

  // Uncaught async errors outside the framework's callbacks — including
  // anything thrown by the awaits below, which is why both handlers are
  // installed before the database is touched.
  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      log.record(unwrapError(error).toString(), stack);
      if (kDebugMode) debugPrint('$error\n$stack');
      // The reason is the block below; the suppression stays with it.
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      // Never let the error handler throw: its own error re-enters it.
    }
    // ALWAYS true. `false` routes to the embedder's fallback, where the VM or
    // the process may exit or become unresponsive — the one behaviour a crisis
    // UI cannot tolerate. `return kReleaseMode` buys debug visibility at that
    // price; the debugPrint above gives it for free.
    return true;
  };

  final db = AppDatabase();
  // The one read before first paint. It cannot throw — a settings read that
  // kills launch is a blank window in front of someone who needs words — so a
  // failure falls back to defaults, loudly in the log and silently on screen.
  final settings = await _loadSettings(db, log);
  await configureAudioSession();

  // The redaction net's live source: every phrase on the board, so an exception
  // whose toString() smuggles one into a log line is scrubbed before it reaches
  // a file the user might mail out. Wired HERE — after the DB is open — because
  // CrashLog.open() ran before it, deliberately, with an empty source; a crash
  // during DB open has nothing loaded to leak. The board surface keeps this in
  // step with edits via redactionRegistryProvider.
  final redactions = RedactionRegistry();
  log.redactWith(redactions.snapshot);

  // Read at speak time, never captured: Android garbage-collects voice data, so
  // the answer changes under us. It stays null until the post-frame re-resolve
  // below, and speak() reports null as words on screen rather than silence. The
  // same holder is exposed via currentVoiceProvider so the voice picker can
  // point the engine at a newly chosen voice without a restart.
  final currentVoice = CurrentVoice();
  final speech = FlutterTtsSpeechService(() => currentVoice.value);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        speechServiceProvider.overrideWithValue(speech),
        currentVoiceProvider.overrideWithValue(currentVoice),
        crashLogProvider.overrideWithValue(log),
        // The one registry the log's net reads, so the board surface's updates
        // reach the same instance record() scrubs against.
        redactionRegistryProvider.overrideWithValue(redactions),
        // Restored BEFORE first paint, not corrected on frame 2. A flash of the
        // wrong polarity is a sudden luminance change delivered to someone in a
        // shutdown — the exact event the animation ban exists to prevent.
        initialPaletteProvider.overrideWithValue(settings.palette),
        // The HC polarity the switcher's third position lands on, restored so
        // the first cycle into high contrast lands on the user's choice.
        initialHcPolarityProvider.overrideWithValue(settings.hcPolarity),
        // The whole settings snapshot, so the show screen reads the user's
        // polarity and standing line from the first time it is opened.
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const ReedApp(),
    ),
  );

  // FIRST FRAME lands here: the grid is visible and tappable before either call
  // below starts. Both are fired, neither is awaited.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Binder IPC and voice deserialization run synchronously on the main thread
    // inside the engine's init listener. Awaiting this in main() is an ANR that
    // no Flutter profile surfaces.
    unawaited(speech.warmUp());
    unawaited(
      _restoreVoice(speech, settings.voiceId, (v) => currentVoice.value = v),
    );
  });
}

/// Loads every preference before first paint, through the one component that
/// owns the settings keys and their formats.
///
/// It cannot throw. A settings read that kills launch is a blank window in front
/// of someone who needs words, so a failure falls back to [ReedSettings.defaults]
/// — every field of which is also the value a corrupt entry decodes to — logged
/// once, silent on screen.
Future<ReedSettings> _loadSettings(AppDatabase db, CrashLog log) async {
  try {
    return await SettingsRepository(db).load();
  } on Exception {
    // The exception is deliberately not interpolated. This log is exported by
    // users, a stored value can be anything, and a redaction slip here mails
    // someone's phrases to a stranger.
    log.record(
      'settings read failed; launching on defaults',
      StackTrace.current,
    );
    return const ReedSettings.defaults();
  }
}

/// Re-resolves the stored voice against the voices the engine actually has.
///
/// Android garbage-collects voice data between launches, so a voice present at
/// last launch may be gone — the most probable real-world silent failure in the
/// app. The fallback is another installed voice, which is AUDIBLE: a log line
/// here would be silence that the user cannot hear about and will not report.
///
/// Off the first-frame path on purpose. `voices()` binds the engine, which is
/// the same cost [FlutterTtsSpeechService.warmUp] is paying behind the grid.
Future<void> _restoreVoice(
  FlutterTtsSpeechService speech,
  String? storedVoiceId,
  void Function(Voice) onResolved,
) async {
  final List<Voice> available;
  try {
    // Already filtered to voices that need no network and are fully installed.
    available = await speech.voices();
  } on Exception {
    // Leaves the voice null, which speak() reports as NoVoiceSelected: the
    // words go on screen. Never a crash on the launch path.
    return;
  }
  if (available.isEmpty) return;
  onResolved(
    available.firstWhere(
      (v) => v.name == storedVoiceId,
      orElse: () => available.first,
    ),
  );
}
