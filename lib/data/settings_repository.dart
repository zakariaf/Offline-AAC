import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/aac_palette.dart';

// The seven key strings live here and nowhere else. Kept private to the library
// so no widget can name a preference by a magic string: everything outside this
// file speaks in typed getters and setters.
const String _kTheme = 'theme';
const String _kPitch = 'pitch';
const String _kRate = 'rate';
const String _kOutputMode = 'output_mode';
const String _kGridSize = 'grid_size';
const String _kHaptics = 'haptics';
const String _kVoiceId = 'voice_id';

/// The two shipping layouts: the 3-column phone default and the 2-column large
/// board with roughly 180dp tiles for one-handed use in a shutdown.
enum GridSize { phone, large }

/// A snapshot of every user preference, typed.
///
/// Immutable, with a `defaults()` that is the app's behaviour before the user
/// has touched anything. Nothing outside this file's repository ever holds the
/// raw strings these decode from.
class ReedSettings {
  const ReedSettings({
    required this.palette,
    required this.pitch,
    required this.rate,
    required this.output,
    required this.gridSize,
    required this.haptics,
    required this.voiceId,
  });

  /// The behaviour of a fresh install. Every field here is also the fallback a
  /// corrupt or future-version stored value decodes to, so the app is never
  /// left in an undefined state by a byte on disk.
  const ReedSettings.defaults()
    : palette = AacPalette.ink,
      pitch = kDefaultPitch,
      rate = kDefaultRate,
      output = OutputMode.speak,
      gridSize = GridSize.phone,
      haptics = true,
      voiceId = null;

  final AacPalette palette;
  final double pitch;
  final double rate;
  final OutputMode output;
  final GridSize gridSize;
  final bool haptics;

  /// The stored voice's engine id, or null when none has been chosen. A null
  /// here is normal; the startup path re-resolves it against installed voices.
  final String? voiceId;
}

/// The entire boundary between typed preferences and their stored strings.
///
/// Every key name and every value format lives in this one file. That is not
/// tidiness — it is what keeps a preference from leaking as a magic string into
/// a widget, and it is why adding a preference never touches the migration
/// path: the `settings` table is plain key/value, so growth here is data, not
/// schema.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  /// Load all preferences in one query.
  Future<ReedSettings> load() async {
    final rows = await _db.select(_db.settings).get();
    return _decode({for (final row in rows) row.key: row.value});
  }

  /// React to preference changes — the theme switcher and the voice picker both
  /// write here, and the app must follow without a manual reload.
  Stream<ReedSettings> watch() {
    return _db
        .select(_db.settings)
        .watch()
        .map((rows) => _decode({for (final row in rows) row.key: row.value}));
  }

  Future<void> setPalette(AacPalette value) => _put(_kTheme, value.name);

  Future<void> setOutputMode(OutputMode value) =>
      _put(_kOutputMode, value.name);

  Future<void> setGridSize(GridSize value) => _put(_kGridSize, value.name);

  Future<void> setHaptics({required bool enabled}) =>
      _put(_kHaptics, enabled.toString());

  Future<void> setVoiceId(String value) => _put(_kVoiceId, value);

  /// Stored as a string so a future range change is a decode concern, not a
  /// migration. The value is clamped on read, not here, because the clamp bound
  /// belongs to the synthesizer and may move under a stored value.
  Future<void> setPitch(double value) => _put(_kPitch, value.toString());

  Future<void> setRate(double value) => _put(_kRate, value.toString());

  /// Upsert on the primary key. Never read-then-write (a lost update under a
  /// concurrent write) and never a bare insert that throws on the second call.
  Future<void> _put(String key, String value) {
    return _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  ReedSettings _decode(Map<String, String> raw) {
    const d = ReedSettings.defaults();
    return ReedSettings(
      // Enums persist by NAME, never index: an index is a hidden ordering
      // dependency, so reordering an enum would silently repoint every install.
      palette: _enumByName(AacPalette.values, raw[_kTheme], d.palette),
      output: _enumByName(OutputMode.values, raw[_kOutputMode], d.output),
      gridSize: _enumByName(GridSize.values, raw[_kGridSize], d.gridSize),
      pitch: _clampedDouble(raw[_kPitch], kMinPitch, kMaxPitch, d.pitch),
      rate: _clampedDouble(raw[_kRate], kMinRate, kMaxRate, d.rate),
      haptics: _bool(raw[_kHaptics], d.haptics),
      // A voice id is an opaque engine string; there is nothing to validate here
      // beyond presence. An empty string is treated as absent.
      voiceId: (raw[_kVoiceId]?.isNotEmpty ?? false) ? raw[_kVoiceId] : null,
    );
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? stored,
    T fallback,
  ) {
    for (final v in values) {
      if (v.name == stored) return v;
    }
    return fallback;
  }

  static double _clampedDouble(
    String? stored,
    double min,
    double max,
    double fallback,
  ) {
    final parsed = double.tryParse(stored ?? '');
    if (parsed == null || parsed.isNaN) return fallback;
    // A stored value outside the synthesizer's range is clamped, not rejected:
    // a garbage 99999 must not become a pitch the engine refuses, leaving the
    // user with no voice.
    return parsed.clamp(min, max);
  }

  static bool _bool(String? stored, bool fallback) {
    if (stored == 'true') return true;
    if (stored == 'false') return false;
    return fallback;
  }
}
