---
name: reed-speech-service
description: The SpeechService seam in this offline AAC app — flutter_tts speak/stop/getVoices calls, hand-written setVoice return checks, voice_filter's network_required and notInstalled parsing, the .playback audio session, the TTS_SERVICE manifest query. Use when wiring a tile's onTap to speech, selecting or storing a voice, handling a PlatformException, or editing files under lib/data/speech/. Not for defining the failure type or deciding throw-vs-outcome in general, and not for the general no-swallowed-errors audit.
---

# The speech seam

A user taps a tile mid-shutdown. Either words come out of the speaker, or the words go on the screen. There is no third outcome. Nobody will report it if there is — a person who cannot speak does not file bugs, and this app has no telemetry, ever. Every rule here exists because some plausible-looking code produces silence and reports success.

## The interface, and why it is abstract

```dart
// lib/data/speech/speech_service.dart
abstract interface class SpeechService {
  /// Barge-in: stops any in-flight utterance first. A re-tap means "say it
  /// again" / "I need this NOW" — never swallow it.
  @useResult
  Future<SpeakOutcome> speak(String text);

  Future<void> stop();

  /// Already filtered: network_required and notInstalled voices never appear.
  Future<List<Voice>> voices();
}
```

Two reasons, and only two. Do not add a third to justify abstracting something else:

1. **It cannot run in `flutter test`.** Everything else in `data/` can. That is the whole rule for what earns an interface in this codebase: abstract exactly what cannot execute in a test. One interface, one real impl, one fake — justified. One interface, one impl, no fake — delete the interface.
2. **`flutter_tts` is effectively single-maintainer and MIT.** Healthy today. The day it is not, this interface makes vendoring a one-file change. Only four methods are used — `speak`, `stop`, `getVoices`, `setVoice` — plus the iOS audio category. Keep it that way.

Keep the real impl (`FlutterTtsSpeechService`) as thin as physically possible. Everything testable lives one layer up: `voice_filter` and the `setVoice` return check. That is also simply where the bugs are.

## The outcome type

Speech returns a sealed `SpeakOutcome`. Not `bool` (invites ignoring), not a throw (Dart requires no declaration and no catch, so it gets forgotten), not `Result<Exception>` (zero exhaustiveness — `case Err(:final e)` cannot tell the compiler a new failure appeared).

Every failure variant carries `spokenText`, which makes "show the words on screen" a **total function** of the outcome:

```dart
@immutable
sealed class SpeakOutcome { const SpeakOutcome(); }

final class SpokeAloud extends SpeakOutcome { const SpokeAloud(); }

@immutable
sealed class SpeakFailure extends SpeakOutcome {
  const SpeakFailure(this.spokenText);
  final String spokenText;   // the on-screen fallback
  String get logLine;        // one line for the on-device log. Never shown.
}

final class NoVoiceSelected  extends SpeakFailure { ... }
final class VoiceUnavailable extends SpeakFailure { ... }  // setVoice != 1
final class VoiceNotInstalled extends SpeakFailure { ... } // notInstalled flag; setVoice returns 1
final class EngineRejected   extends SpeakFailure { ... }  // speak != 1 / PlatformException
final class EngineTimedOut   extends SpeakFailure { ... }
```

Five variants, and `VoiceNotInstalled` is the one that looks redundant and is not. Android returns **1 (success)** from `setVoice` for a voice carrying the `notInstalled` feature flag, then synthesis either reports `ERROR_NOT_INSTALLED_YET` or silently substitutes a different voice. The `setVoice == 1` check does not catch it. Drop this variant and the exhaustive switch still compiles green while never handling the case — a silent failure hiding inside the mechanism built to make silent failures impossible.

Be precise about what this buys, because over-claiming it leads to skipping the hand-written checks:

| Mechanism | Strength |
|---|---|
| Non-exhaustive switch over a sealed type | **Compile error.** `non_exhaustive_switch_statement` is `type: compileTimeError` in the analyzer's `messages.yaml`. Claims it is "just a warning" are wrong; do not let a reviewer talk this out. |
| A caller discarding the outcome | Not caught by the type system. Closed by `@useResult` + `unused_result: error` in `analysis_options.yaml` — an *analyzer* diagnostic, only as strong as CI blocking on it. |
| `setVoice` returning 0 | **Nothing detects this.** Hand-written, at the wire. |

Honest guarantee: *compile error on a new variant, analyzer error on a discarded outcome, hand-written detection at the wire.* Not "silence is impossible."

**Never write `default:` or `case _:` over `SpeakOutcome`.** One of them silently disables the only alarm system this app has.

**Never `assert` a platform return code.** `assert` is stripped in release, so `assert(await _tts.setVoice(v) == 1)` is green in every test and absent on the user's device — the perfect silent failure. Asserts cover `Error` ground (our bugs); sealed outcomes cover `Exception` ground (the environment).

## The impl: every return code checked by hand

```dart
final class FlutterTtsSpeechService implements SpeechService {
  static const _ttsSuccess = 1;
  static const _speakTimeout = Duration(seconds: 8);

  @override
  @useResult
  Future<SpeakOutcome> speak(String text) async {
    final voice = _settings.voice;
    if (voice == null) return NoVoiceSelected(text);

    // setVoice returns 1 (success) for a notInstalled voice, so the return
    // check below cannot see this. Guard before it, or synthesis silently
    // substitutes another voice — or says nothing at all.
    if (voice.notInstalled) {
      return VoiceNotInstalled(text, voiceName: voice.name);
    }

    // THE bug this app exists to prevent. flutter_tts's Kotlin does:
    //   Log.d(tag, "Voice name not found: $voice"); result.success(0)
    // That is result.success, NOT result.error — it never throws. Unchecked,
    // this is a user in crisis tapping a tile and getting silence, with only a
    // Log.d on a device we will never see.
    final set = await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
    if (set != _ttsSuccess) return VoiceUnavailable(text, voiceName: voice.name);

    final Object? spoke;
    try {
      spoke = await _tts.speak(text).timeout(_speakTimeout);
    } on TimeoutException {
      return EngineTimedOut(text, waited: _speakTimeout);
    } on PlatformException catch (e) {
      return EngineRejected(text, code: e.code);
    }
    if (spoke != _ttsSuccess) return EngineRejected(text, code: spoke);
    return const SpokeAloud();
  }
}
```

The `!= _ttsSuccess` check reads as paranoia to every reviewer. It is the documented behaviour of the plugin. Leave the comment at the point of temptation.

## voice_filter: pure Dart, no plugin import

This file must never `import 'package:flutter_tts/...'`. Purity is what makes it 100% coverable, and this is where the safety actually lives. It takes `Object?` off the wire and returns a `List<Voice>`.

Four wire-format traps, all confirmed in plugin source. **Each one silently inverts the safety property in the direction that hurts** — i.e. a network-only or half-downloaded voice gets classified as usable, and the user gets silence.

```dart
// lib/data/speech/voice_filter.dart
const String kFeatureNotInstalled = 'notInstalled';

/// Android: until voice data finishes downloading, synthesis reports
/// ERROR_NOT_INSTALLED_YET *or substitutes a different voice* — while setVoice
/// still returns 1. The return-value check does not catch this.
bool _isOfflineSafe(Voice v) =>
    !v.networkRequired && !v.features.contains(kFeatureNotInstalled);

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
  final bool networkRequired = nr == '1' || nr == 1 || nr == true;

  // TRAP 3: TAB-separated (voice.features.joinToString(separator = "\t")).
  final Object? f = raw['features'];
  final Set<String> features = (f is String && f.isNotEmpty)
      ? f.split('\t').where((String s) => s.isNotEmpty).toSet()
      : const <String>{};

  return Voice(
    name: name,
    locale: locale,
    networkRequired: networkRequired,
    features: features,
  );
}

/// TRAP 4: getVoices can return NULL — the plugin catches NullPointerException
/// and calls result.success(null). And it hands back List<Object?> of
/// Map<Object?, Object?>: `(raw as List).cast<Map<String, String>>()` throws
/// TypeError at runtime.
List<Voice> offlineSafeVoices(Object? raw) {
  if (raw is! List) return const <Voice>[];
  return raw.map(tryParseVoice).whereType<Voice>().where(_isOfflineSafe).toList();
}
```

Test fixtures must encode the **actual** wire format, or they prove nothing: Android `'network_required': network ? '1' : '0'` (string) and `'features': features.join('\t')` (tab); iOS with **no** `network_required` key at all. Assert the property, not the cases: *no returned voice ever needs the network and none is `notInstalled`*, over a generated list.

## The stored voice vanishes — the most probable real-world silent failure

Android garbage-collects voice data. A voice id stored in settings can be uninstalled between launches. **Re-resolve the stored voice id against `voices()` at startup and fall back audibly** — never keep a dangling id and discover it at tap time.

Startup ordering, which is load-bearing:

```
main()
  WidgetsFlutterBinding.ensureInitialized()
  CrashLog.open()                — first; a crash before this is invisible
  FlutterError.onError / PlatformDispatcher.onError
  AppDatabase open + migration
  audio_session config (.playback)
  runApp(...)
FIRST FRAME — grid visible and tappable
  addPostFrameCallback:
    SpeechService.warmUp()       — NOT awaited, NEVER blocks the frame
    voice_filter → resolve stored voice, fall back audibly if it vanished
```

TTS engine binding runs binder IPC and voice deserialization **synchronously on the main thread** inside `OnInitListener`, which ANRs on the cold-start path. Warm it after the first frame so the cost is paid while the user looks at an already-usable grid.

**Warm-up fails silently; `speak()` fails loudly.** Opposite error policies on the same service, deliberately. Do not unify them.

## The manifest line that outranks the rest

```xml
<!-- Without this, Android 11+ package visibility HIDES the TTS engine.
     flutter_tts returns an empty voice list with only a Log.d. Every Android
     11+ user gets a board that cannot speak, and we will never hear about it. -->
<queries>
  <intent><action android:name="android.intent.action.TTS_SERVICE" /></intent>
</queries>
```

A plain Dart test reads `android/app/src/main/AndroidManifest.xml` and asserts it contains `android.intent.action.TTS_SERVICE`. Keep that test.

## The audio session

`.playback` + `duckOthers` + `setSharedInstance`. **Never `.ambient`.**

`.ambient` lets the hardware silent switch mute the app — a user flips the ringer switch for a meeting and their voice is gone, exactly when they most need it. `flutter_tts`'s own README example uses `.ambient`, so copying the example ships the worst bug in the product. Pin it in `lib/data/speech/audio_session_config.dart` with the reason at the point of temptation, because it reads as an oversight to everyone who has not been bitten.

A Dart test can only assert *the code passed `.playback` to the wrapper* — a value-level assertion, not the real `AVAudioSession` category. The real check is a physical device with the ringer switch OFF.

## Wiring a tap — the lint hole

`onTap: () => service.speak(p)` is caught by **no lint**. Verified: the arrow closure "returns" the Future, so `discarded_futures` considers it handled, but the target type is `VoidCallback`, so the Future *and its error* are dropped. That is the most idiomatic way to wire a Flutter tile and it is exactly this app's silence bug.

The fix is structural, not disciplinary:

```dart
class SpeechController {
  /// speakNow returns void ON PURPOSE. The callback never holds a Future, so
  /// there is nothing to drop — the hole is unreachable by construction.
  /// Do not "fix" this into Future<void>.
  void speakNow(String phrase) {
    unawaited(
      _speak(phrase).catchError((Object e, StackTrace s) {
        // _speak is total, but stop() and the log can still throw. An uncaught
        // error goes to PlatformDispatcher.onError and the user sees nothing.
        _log.record('speakNow threw: $e', s);
        _showText(phrase);
      }),
    );
  }

  Future<void> _speak(String phrase) async {
    await _service.stop();  // barge-in, always, before speak
    final SpeakOutcome outcome = await _service.speak(phrase);
    switch (outcome) {
      case SpokeAloud():
        return;
      case SpeakFailure(:final String spokenText, :final String logLine):
        _log.record('speak failed: $logLine', StackTrace.current);
        _showText(spokenText);  // every failure resolves the same way
    }
  }
}
```

Never wrap speak in a Command pattern. Its `if (_running) return` swallows the re-tap and produces the exact silence this app forbids. Resolve the tile at tap time from `(row, col)`, never from a value captured in `build()` — a stale capture speaks the *previous* phrase aloud to a stranger on behalf of someone who cannot correct it verbally.

Every failure ends at **the full sentence on screen**. Not a toast, not a log line. When audio does not happen, the words must.

## Testing the seam

Fake, never mock. `implements SpeechService` with no `noSuchMethod` superclass means adding a method **breaks the build** rather than failing at runtime. The risk here is not "was speak() called" — it is "what happens when the voice vanished / setVoice returned 0", which is **state**, which a fake models naturally.

Model every way the world breaks as a `SpeechEnv` enum value: `healthy`, `noEngineInstalled`, `zeroVoices`, `onlyNetworkVoices`, `onlyNotInstalledVoices`, `setVoiceReturnsZero`, `storedVoiceUninstalled`, `speakReturnsZero`, `engineTimesOut`, and `reportedSuccessButSilent`. The last one is excluded from the loop via `SpeechEnv.detectable`, because the engine returning 1 with no audio has **no Dart-side signal** — permanently a manual device check.

Then loop the highest-value test in the suite over `SpeechEnv.detectable`: tap a tile, assert `spoke || showedFallback`. It is the only test that is unsatisfiable by a silently-failing code path — every other test asserts a behaviour; this one asserts the absence of a failure class. Adding an env forces the UI to handle it or the build goes red.

Also pin barge-in ordering: two taps must record exactly `['stop', 'speak', 'stop', 'speak']`.

**Do not mock the `MethodChannel('flutter_tts')` across the suite** — you already own the abstraction; fake that. Channel mocks couple dozens of tests to the plugin's private method-name strings and prove nothing about audio. Keep exactly **one** channel contract file as the upgrade canary (with no telemetry, it is the only one): assert `setVoice` returning 0 does not throw, and that the naive `cast<Map<String, String>>()` on `getVoices` throws `TypeError` while `offlineSafeVoices` survives. A plain `test()` touching `TestDefaultBinaryMessengerBinding.instance` requires `TestWidgetsFlutterBinding.ensureInitialized()` first or the file fails to load; tear down mock handlers or they leak into later tests.
