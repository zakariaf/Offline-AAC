import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/aac_palette.dart';
import 'package:offline_aac/ui/strings.dart';

// The key strings live here and nowhere else. Kept private to the library so no
// widget can name a preference by a magic string: everything outside this file
// speaks in typed getters and setters.
const String _kTheme = 'theme';
const String _kPitch = 'pitch';
const String _kRate = 'rate';
const String _kOutputMode = 'output_mode';
const String _kGridSize = 'grid_size';
const String _kHaptics = 'haptics';
const String _kVoiceId = 'voice_id';
const String _kStandingEnabled = 'standing_line_enabled';
const String _kStandingText = 'standing_line_text';
const String _kShowPolarity = 'show_polarity';
const String _kHcPolarity = 'hc_polarity';
const String _kLowStimulus = 'low_stimulus';

/// The two shipping layouts: the 3-column phone default and the 2-column large
/// board with roughly 180dp tiles for one-handed use in a shutdown.
enum GridSize { phone, large }

/// The show screen's polarity. [bright] is the always-light poster a stranger
/// reads; [matchTheme] hands the user their own palette at poster scale — the
/// one condition under which show mode is not `#FFFCF7`, and their call to make.
enum ShowPolarity { bright, matchTheme }

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
    required this.showPolarity,
    required this.standingLineEnabled,
    required this.standingLineText,
    required this.hcPolarity,
    required this.lowStimulus,
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
      voiceId = null,
      showPolarity = ShowPolarity.bright,
      standingLineEnabled = true,
      standingLineText = defaultStandingLine,
      hcPolarity = AacPalette.hcInk,
      lowStimulus = false;

  final AacPalette palette;
  final double pitch;
  final double rate;
  final OutputMode output;
  final GridSize gridSize;
  final bool haptics;

  /// The stored voice's engine id, or null when none has been chosen. A null
  /// here is normal; the startup path re-resolves it against installed voices.
  final String? voiceId;

  /// The show screen's polarity; [ShowPolarity.bright] by default.
  final ShowPolarity showPolarity;

  /// Whether the standing line sits above the poster. Default on — this line,
  /// not the type size, is what keeps the phone from reading as *weird*.
  final bool standingLineEnabled;

  /// The standing line's text. An empty string is a valid, deliberate choice and
  /// is preserved as such — it is NOT the same state as "the user never set one",
  /// which resolves to [defaultStandingLine].
  final String standingLineText;

  /// The high-contrast polarity the switcher's third position lands on: a
  /// set-once preference ([AacPalette.hcInk] default), never a fourth cycle
  /// stop. Always one of the two HC palettes.
  final AacPalette hcPolarity;

  /// Low-stimulus mode: undyed tiles and the 2-column layout. State-dependent,
  /// but persisted — someone the OS kills mid-episode comes back in it.
  final bool lowStimulus;

  ReedSettings copyWith({
    AacPalette? palette,
    double? pitch,
    double? rate,
    OutputMode? output,
    GridSize? gridSize,
    bool? haptics,
    String? voiceId,
    ShowPolarity? showPolarity,
    bool? standingLineEnabled,
    String? standingLineText,
    AacPalette? hcPolarity,
    bool? lowStimulus,
  }) {
    return ReedSettings(
      palette: palette ?? this.palette,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
      output: output ?? this.output,
      gridSize: gridSize ?? this.gridSize,
      haptics: haptics ?? this.haptics,
      voiceId: voiceId ?? this.voiceId,
      showPolarity: showPolarity ?? this.showPolarity,
      standingLineEnabled: standingLineEnabled ?? this.standingLineEnabled,
      standingLineText: standingLineText ?? this.standingLineText,
      hcPolarity: hcPolarity ?? this.hcPolarity,
      lowStimulus: lowStimulus ?? this.lowStimulus,
    );
  }
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

  Future<void> setShowPolarity(ShowPolarity value) =>
      _put(_kShowPolarity, value.name);

  Future<void> setStandingLineEnabled({required bool enabled}) =>
      _put(_kStandingEnabled, enabled.toString());

  /// The standing line is a user string: stored EXACTLY as given. No trim, no
  /// capitalisation, no appended period, no re-fill of an empty value with the
  /// default — an empty line is a choice the editor must honour, not correct.
  Future<void> setStandingLineText(String value) => _put(_kStandingText, value);

  /// The high-contrast polarity preference. Must be one of the two HC palettes.
  Future<void> setHcPolarity(AacPalette value) {
    assert(
      value == AacPalette.hcInk || value == AacPalette.hcPaper,
      'HC polarity must be hcInk or hcPaper, got $value.',
    );
    return _put(_kHcPolarity, value.name);
  }

  /// Low-stimulus mode on/off.
  ///
  /// NOTHING but a finger toggles this. There is no heuristic on tap rate, no
  /// time-of-day, no failed-speech counter, no sensor, no first-launch guess,
  /// and no prompt ("Text is large. Switch to 6 tiles?"). The app does not know
  /// what state anyone is in, and guessing at it out loud is the parental
  /// posture. The absence of automation here is a decision, not an omission.
  Future<void> setLowStimulus({required bool enabled}) =>
      _put(_kLowStimulus, enabled.toString());

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
      showPolarity: _enumByName(
        ShowPolarity.values,
        raw[_kShowPolarity],
        d.showPolarity,
      ),
      standingLineEnabled: _bool(raw[_kStandingEnabled], d.standingLineEnabled),
      // ABSENT and EMPTY are two different states and must not collapse. A
      // missing row means the user never chose, so the default sentence stands;
      // a present row holding '' means they deliberately cleared it, and `??`
      // over the empty string would silently overwrite that choice.
      standingLineText: raw.containsKey(_kStandingText)
          ? raw[_kStandingText]!
          : d.standingLineText,
      // Only the two HC palettes are valid here; any other name (a corrupt row,
      // a light-palette name that leaked in) falls back to the default polarity.
      hcPolarity: switch (raw[_kHcPolarity]) {
        'hcInk' => AacPalette.hcInk,
        'hcPaper' => AacPalette.hcPaper,
        _ => d.hcPolarity,
      },
      lowStimulus: _bool(raw[_kLowStimulus], d.lowStimulus),
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
