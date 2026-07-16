import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/board_repository.dart' show databaseProvider;
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/data/speech/speech_service.dart' show OutputMode;
import 'package:offline_aac/model/aac_palette.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/board/board_controller.dart'
    show crashLogProvider;

/// The repository that owns every preference key and format.
final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
      (ref) => SettingsRepository(ref.watch(databaseProvider)),
    );

/// The settings loaded once before first paint, overridden at the root from the
/// startup read — the same shape as `initialPaletteProvider`. Its default is the
/// fresh-install behaviour, which is also what a corrupt file decodes to, so the
/// app is never left undefined by a byte on disk.
final Provider<ReedSettings> initialSettingsProvider = Provider<ReedSettings>(
  (ref) => const ReedSettings.defaults(),
);

/// The live settings. Reads start from [initialSettingsProvider]; each setter
/// persists through the repository AND advances the in-memory state, so a screen
/// watching this follows a preference change without a manual reload.
///
/// This is the slice show mode needs (polarity, the standing line); the full
/// settings screen and the rest of the preferences are E08's to wire onto the
/// same provider.
class SettingsController extends Notifier<ReedSettings> {
  @override
  ReedSettings build() => ref.watch(initialSettingsProvider);

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> setShowPolarity(ShowPolarity value) async {
    await _repo.setShowPolarity(value);
    state = state.copyWith(showPolarity: value);
  }

  Future<void> setStandingLineEnabled({required bool enabled}) async {
    await _repo.setStandingLineEnabled(enabled: enabled);
    state = state.copyWith(standingLineEnabled: enabled);
  }

  /// Stored verbatim, empty included. The empty string is a deliberate choice,
  /// not invalid input; nothing here re-fills it with the default.
  Future<void> setStandingLineText(String value) async {
    await _repo.setStandingLineText(value);
    state = state.copyWith(standingLineText: value);
  }

  // The E08 controls. VOID, deliberately: `onTap: () => notifier.setX(v)` is
  // flagged by NEITHER discarded_futures NOR unawaited_futures — the arrow
  // "returns" the Future so the lint thinks it is handled, but the target type
  // is VoidCallback, so the Future and its error vanish. Void makes that hole
  // unreachable. The in-memory state advances IMMEDIATELY and is never reverted
  // on a failed write: a value that appears then undoes itself is a visual
  // change the user did not cause, which the animation ban forbids. The disk
  // write is unawaited with a catchError that logs the diagnostic.

  /// Persist the palette the theme cycle just moved to. The live palette is
  /// [paletteProvider]; this keeps the on-disk snapshot in step so it survives a
  /// restart.
  void setPalette(AacPalette value) {
    state = state.copyWith(palette: value);
    _persist(_repo.setPalette(value), 'palette');
  }

  void setOutputMode(OutputMode value) {
    state = state.copyWith(output: value);
    _persist(_repo.setOutputMode(value), 'output mode');
  }

  void setGridSize(GridSize value) {
    state = state.copyWith(gridSize: value);
    _persist(_repo.setGridSize(value), 'grid size');
  }

  void setHaptics({required bool enabled}) {
    state = state.copyWith(haptics: enabled);
    _persist(_repo.setHaptics(enabled: enabled), 'haptic');
  }

  void setLowStimulus({required bool enabled}) {
    state = state.copyWith(lowStimulus: enabled);
    _persist(_repo.setLowStimulus(enabled: enabled), 'low stimulus');
  }

  void setPitch(double value) {
    state = state.copyWith(pitch: value);
    _persist(_repo.setPitch(value), 'pitch');
  }

  void setRate(double value) {
    state = state.copyWith(rate: value);
    _persist(_repo.setRate(value), 'rate');
  }

  void setVoiceId(String value) {
    state = state.copyWith(voiceId: value);
    _persist(_repo.setVoiceId(value), 'voice');
  }

  /// The high-contrast polarity preference. Updates the live [hcPolarityProvider]
  /// the switcher reads for its third position, applies immediately ONLY when the
  /// palette in force is already high contrast (changing it while on paper stores
  /// the value and touches nothing on screen), and persists.
  void setHcPolarity(AacPalette value) {
    ref.read(hcPolarityProvider.notifier).polarity = value;
    final palette = ref.read(paletteProvider.notifier);
    if (palette.palette == AacPalette.hcInk ||
        palette.palette == AacPalette.hcPaper) {
      palette.palette = value;
    }
    state = state.copyWith(hcPolarity: value);
    _persist(_repo.setHcPolarity(value), 'hc polarity');
  }

  void _persist(Future<void> write, String key) {
    unawaited(
      write.catchError((Object error, StackTrace stack) {
        ref
            .read(crashLogProvider)
            .record('settings write $key failed: $error', stack);
      }),
    );
  }
}

/// The settings in force.
final NotifierProvider<SettingsController, ReedSettings> settingsProvider =
    NotifierProvider<SettingsController, ReedSettings>(SettingsController.new);
