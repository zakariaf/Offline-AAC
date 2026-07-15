import 'package:offline_aac/data/speech/speech_service.dart';

/// [kFeatureNotInstalled] is declared beside [Voice], but it belongs to the
/// filter's vocabulary too — re-exported so a caller reasoning about wire flags
/// need not know which of the two files it came from.
export 'package:offline_aac/data/speech/speech_service.dart'
    show kFeatureNotInstalled;

/// Turns the raw `getVoices` payload into voices that can actually speak.
///
/// PURE DART, ON PURPOSE. Nothing here may import the TTS plugin — that
/// purity is what makes this file executable in a plain `test()` and coverable
/// to 100%, and this file is where the safety actually lives. Everything below
/// takes `Object?` straight off the channel and trusts none of it.
///
/// Android: until voice data finishes downloading, synthesis reports
/// ERROR_NOT_INSTALLED_YET *or substitutes a different voice* — while setVoice
/// still returns 1. The return-value check does not catch this.
bool _isOfflineSafe(Voice v) =>
    !v.networkRequired && !v.features.contains(kFeatureNotInstalled);

/// Parses one wire map into a [Voice], or null if it is not a usable voice.
///
/// Every trap below inverts the safety property *in the direction that hurts*:
/// get one wrong and a network-only or half-downloaded voice is classified
/// usable, reaches `setVoice`, is accepted, and the user gets silence.
Voice? tryParseVoice(Object? raw) {
  if (raw is! Map) return null;
  final Object? name = raw['name'];
  final Object? locale = raw['locale'];
  if (name is! String || name.isEmpty) return null;
  if (locale is! String || locale.isEmpty) return null;

  // TRAP 1: Android sends the STRING "1"/"0". "0" is non-empty, so it survives
  //         a truthiness/null check. `raw['network_required'] == true` is
  //         ALWAYS false (String vs bool) — every network voice would be
  //         classified offline-safe.
  // TRAP 2: iOS OMITS this key entirely. Absent means not-network-required.
  final Object? nr = raw['network_required'];
  final networkRequired = nr == '1' || nr == 1 || nr == true;

  // TRAP 3: TAB-separated (voice.features.joinToString(separator = "\t")).
  final Object? f = raw['features'];
  final features = (f is String && f.isNotEmpty)
      ? f.split('\t').where((s) => s.isNotEmpty).toSet()
      : const <String>{};

  return Voice(
    name: name,
    locale: locale,
    networkRequired: networkRequired,
    features: features,
  );
}

/// Every voice that can speak with no network and is fully installed.
///
/// TRAP 4: getVoices can return NULL — the plugin catches NullPointerException
/// and calls result.success(null). And it hands back `List<Object?>` of
/// `Map<Object?, Object?>`: `(raw as List).cast<Map<String, String>>()` throws
/// TypeError at runtime. The `is! List` guard is the whole defence; never
/// replace it with a cast.
///
/// An empty result is a legitimate answer (no engine, no voices, only network
/// voices) and becomes NoVoiceSelected downstream — words on screen, not
/// silence.
List<Voice> offlineSafeVoices(Object? raw) {
  if (raw is! List) return const <Voice>[];
  return raw
      .map(tryParseVoice)
      .whereType<Voice>()
      .where(_isOfflineSafe)
      .toList();
}
