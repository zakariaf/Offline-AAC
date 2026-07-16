import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/board_repository.dart' show databaseProvider;
import 'package:offline_aac/data/settings_repository.dart';

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
}

/// The settings in force.
final NotifierProvider<SettingsController, ReedSettings> settingsProvider =
    NotifierProvider<SettingsController, ReedSettings>(SettingsController.new);
