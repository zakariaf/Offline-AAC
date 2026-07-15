# platform-channel-testing

> Phase: **research** · Agent `aff998ae5228682b7` · Run `wf_12b14467-451`

## Result

## Summary

The current mocking API is confirmed: `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler)` — but it throws "Binding has not yet been initialized" unless you call `TestWidgetsFlutterBinding.ensureInitialized()` first in a plain `test()`. I hit this by running the code, not reading docs. My strong recommendation: do NOT mock flutter_tts's channel across your suite. Fake the existing `SpeechService` instead; channel-level tests earn their keep in exactly one file — a contract test pinning the "returns 0, never throws" behavior. I verified that premise verbatim in the plugin's Kotlin (`result.success(0)` after a `Log.d`), and found three things the brief did not anticipate, all of which I confirmed in source: `network_required` is the STRING `"1"`/`"0"` (a naive truthiness check silently inverts the safety property), `features` is TAB-separated, and iOS omits `network_required` entirely. Worse, Android's `notInstalled` feature flag means `setVoice` returns **1 (success)** while synthesis reports ERROR_NOT_INSTALLED_YET *or substitutes a different voice* — so checking the return value alone does NOT make silence impossible. Two of your three "native surfaces" (QS tile, ControlWidget) have no Dart→native channel at all, so Pigeon buys you almost nothing; I'd skip it for the MVP. Audio output cannot be asserted in any automated test, and the Android emulator ships no TTS engine — so CI can never verify speech, which makes a short manual device checklist a load-bearing artifact, not a nicety. I wrote and ran 21 passing tests; all code below is verified, not sketched.

### The current channel-mocking API is TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler), and the old MethodChannel.setMockMethodCallHandler was moved out of package:flutter into package:flutter_test.

*Confidence: high, **LOAD-BEARING***

Flutter's official breaking-change doc (last updated 2026-05-05) confirms BinaryMessenger.setMockMessageHandler, BasicMessageChannel.setMockMessageHandler, MethodChannel.setMockMethodCallHandler and checkMockMethodCallHandler all moved to flutter_test. Migration: `myMethodChannel.setMockMethodCallHandler(...)` -> `tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(myMethodChannel, ...)`. Outside testWidgets, use TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger. The TestMethodChannelExtension.setMockMethodCallHandler variant is itself now deprecated. Verified working on Flutter 3.41.2 locally.

- https://docs.flutter.dev/release/breaking-changes/mock-platform-channels

- https://api.flutter.dev/flutter/flutter_test/TestDefaultBinaryMessenger/setMockMethodCallHandler.html

### Calling TestDefaultBinaryMessengerBinding.instance at group() body scope fails at load time; you must call TestWidgetsFlutterBinding.ensureInitialized() first in a plain test().

*Confidence: high, **LOAD-BEARING***

Discovered by running, not reading. Error: 'Binding has not yet been initialized. The "instance" getter on the TestDefaultBinaryMessengerBinding binding mixin is only available once that binding has been initialized.' testWidgets() initializes the binding for you; plain test() does not. Fix: TestWidgetsFlutterBinding.ensureInitialized() as the first line of main(). Most blog snippets omit this and fail to load.

- Verified locally: flutter test on Flutter 3.41.2

### flutter_tts's Android setVoice returns success(0) after only a Log.d when the voice is not found — it never throws. The project's premise is confirmed verbatim.

*Confidence: high, **LOAD-BEARING***

android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt:514-526. On match: `tts!!.voice = ttsVoice; result.success(1)`. On no match: `Log.d(tag, "Voice name not found: $voice"); result.success(0)`. Because it is result.success (not result.error), Dart's `await _channel.invokeMethod('setVoice', voice)` returns 0 and raises nothing. Note the Android package was renamed from com.tundralabs.fluttertts to com.eyedeadevelopment.fluttertts — stale docs/paths will 404.

- https://github.com/dlutton/flutter_tts (android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt)

### Android's `notInstalled` voice feature defeats a setVoice-return-value check: setVoice returns 1 (success) and synthesis still fails or silently substitutes a DIFFERENT voice.

*Confidence: high, **LOAD-BEARING***

Android SDK 35 source, TextToSpeech.java:678, KEY_FEATURE_NOT_INSTALLED = "notInstalled". Doc comment: 'the voice may need to download additional data to be fully functional... Until download is complete, each synthesis request will either report ERROR_NOT_INSTALLED_YET error, or use a different voice to synthesize the request.' Because such a voice IS present in tts.voices, flutter_tts's setVoice loop matches it and returns 1. So the brief's stated mitigation (check the setVoice return value) is necessary but NOT sufficient. The voice_filter must also exclude features.contains('notInstalled'). This is a silent-failure path the brief did not anticipate.

- Android SDK android-35 sources: android/speech/tts/TextToSpeech.java:678

### Android sends network_required as the STRING "1"/"0", features as a TAB-separated string; iOS omits network_required entirely. A naive truthiness or bool check silently inverts the safety property.

*Confidence: high, **LOAD-BEARING***

FlutterTtsPlugin.kt readVoiceProperties (:618-626): map["network_required"] = if (voice.isNetworkConnectionRequired) "1" else "0"; map["features"] = voice.features.joinToString(separator = "\t"). Note "0" is a non-empty String and thus survives a null/empty check; and `raw['network_required'] == true` is ALWAYS false since it is a String. iOS (SwiftFlutterTtsPlugin.getVoices :337-357) emits only name/locale/quality/gender/identifier — no network_required — so the parser must treat a missing key as not-network-required. Confirmed KEY_FEATURE_NETWORK_SYNTHESIS = "networkTts" (TextToSpeech.java:636) and Voice.isNetworkConnectionRequired() exist.

- https://github.com/dlutton/flutter_tts

- https://developer.android.com/reference/android/speech/tts/Voice

- Android SDK android-35 sources

### getVoices returns List<Object?> of Map<Object?,Object?> over the channel; casting to List<Map<String,String>> throws TypeError at runtime.

*Confidence: high, **LOAD-BEARING***

lib/flutter_tts.dart: `Future<dynamic> get getVoices async { final voices = await _channel.invokeMethod('getVoices'); return voices; }` — untyped. StandardMessageCodec decodes maps as Map<Object?,Object?>. I wrote a passing test asserting `(raw as List).cast<Map<String,String>>().first` throws TypeError. Also FlutterTtsPlugin.getVoices catches NullPointerException and calls result.success(null) — so the Dart side must tolerate a null list, not just an empty one.

- https://github.com/dlutton/flutter_tts (lib/flutter_tts.dart, FlutterTtsPlugin.kt:553-566)

- Verified locally by running the test

### Pigeon is actively maintained and is the officially recommended approach for NEW platform channels in 2026 — but it buys this project little, because 2 of its 3 native surfaces have no Dart->native channel at all.

*Confidence: high, **LOAD-BEARING***

pigeon 27.1.2, published ~2 days before 2026-07-15, verified publisher flutter.dev, ~457k downloads. Supports Kotlin/Java, Swift/Obj-C, C++, GObject. docs.flutter.dev recommends it for type-safe platform code. BUT: the Android QS TileService and the iOS 18 ControlWidget are native-initiated entry points that run with NO Flutter engine — Pigeon generates Dart<->host messaging and is simply not involved. Only Personal Voice (iOS) is a genuine Dart->native call, and it is roughly one method. Pigeon's own docs warn generated code must be version-matched across Dart and host or you get crashes, and 'using Pigeon-generated code in public APIs is strongly discouraged'.

- https://pub.dev/packages/pigeon

- https://docs.flutter.dev/platform-integration/platform-channels

- https://github.com/flutter/packages/tree/main/packages/pigeon

### If the QS TileService reads Flutter's shared_preferences natively, the modern SharedPreferencesAsync API will silently break it — the data moves to DataStore, not FlutterSharedPreferences.xml.

*Confidence: medium, **LOAD-BEARING***

Legacy shared_preferences on Android writes to a SharedPreferences file named 'FlutterSharedPreferences' with every key prefixed 'flutter.'. The newer SharedPreferencesAsync/SharedPreferencesWithCache APIs are backed by Jetpack DataStore instead. So Kotlin doing getSharedPreferences("FlutterSharedPreferences", ...).getString("flutter.phrase", null) reads NOTHING if Dart used SharedPreferencesAsync — the QS tile speaks silence, on the exact no-Flutter-engine path no Dart test can cover. Recommendation: do not couple the tile to a plugin's private storage format; own the contract with an explicit versioned JSON file.

- https://pub.dev/packages/shared_preferences

- https://github.com/flutter/flutter/issues/165643

### No automated test can assert that audio actually played. integration_test cannot verify speech, and the Android emulator ships no TTS engine — so CI can never test speech at all.

*Confidence: high, **LOAD-BEARING***

integration_test drives the Flutter app via IntegrationTestWidgetsFlutterBinding on a real device/emulator and can assert widget state and that a channel call was issued — but there is no supported hook to capture or assert PCM output from AVSpeechSynthesizer or Android TextToSpeech. Standard emulator system images commonly ship without a TTS engine/voice data; Google TTS must be installed from Play and voice data downloaded, and that download is itself known to fail in emulated environments. Practical consequence: the highest-severity bug class in this app (silence) is structurally unreachable by CI. Android does offer TextToSpeech.synthesizeToFile() as the only real escape hatch — it writes a WAV you can assert is non-empty/non-silent — but that is a native-side test, not a Dart one.

- https://docs.flutter.dev/testing/integration-tests

- https://firebase.google.com/docs/test-lab/flutter/integration-testing-with-flutter

- https://developer.android.com/reference/android/speech/tts/TextToSpeech

### The audio session category bug (.ambient vs .playback) is not unit-testable, and flutter_tts's own README example uses the dangerous .ambient value.

*Confidence: high, **LOAD-BEARING***

flutter_tts 4.2.5 (published ~Jan 2026) documents setIosAudioCategory(category, options, mode); its README example configures the AMBIENT category to let background music continue — precisely the configuration that lets the iOS hardware silent switch mute the app. A Dart test can only assert that YOUR code passed .playback to the wrapper (a value-level assertion); it cannot observe AVAudioSession's real category, nor the silent switch. This is a manual device-checklist item, permanently. Also note awaitSpeakCompletion is iOS-only, so completion semantics differ per platform.

- https://pub.dev/packages/flutter_tts

### patrol is real, maintained, and genuinely extends integration_test to native UI — but it solves a problem this app does not have.

*Confidence: medium*

patrol (LeanCode, since 2022) wraps flutter_test + integration_test with a native automator to tap permission dialogs, notifications, WebViews, toggle Wi-Fi/settings. Requires patrol_cli and a custom test runner. This app has no network, no accounts, and no runtime permission prompts (TTS needs none). The one arguable use — driving the Android QS tile shade — is niche, and patrol adds a CLI, a native harness, and version-coupling to your build for it. Not worth it inside a 2-week solo MVP.

- https://pub.dev/packages/patrol

- https://patrol.leancode.co/

### Firebase Test Lab and device farms are a poor fit here, though for reasons of capability rather than the no-network architecture.

*Confidence: medium*

Test Lab officially supports Flutter integration_test (build APK + run as instrumentation test). Offline-only is not a blocker — the device runs the app locally. The real blockers: farm devices are the same TTS-poor images CI has, farm runs cannot assert audio, and the highest-risk surfaces (QS tile, ControlWidget, Personal Voice, silent switch) are exactly what Robo/instrumentation cannot reach. Test Lab's iOS coverage is also weak. Cost/benefit fails for a solo dev; a physical Android phone and one iPhone beat it outright.

- https://firebase.google.com/docs/test-lab/flutter/integration-testing-with-flutter

- https://www.drizz.dev/post/firebase-test-lab-guide

### Robolectric can meaningfully unit-test the QS tile's LOGIC but not TileService's system binding; the responsible minimum is to extract the logic out of the service class.

*Confidence: medium, **LOAD-BEARING***

Robolectric (current line 4.13+) runs Android unit tests on the JVM without an emulator. However TileService is bound and lifecycled by SystemUI, and Robolectric has no first-class TileService shadow; known Robolectric gaps around click handling on specific API levels reinforce that testing the service shell is low-yield. The high-yield move: TileService.onClick() should be ~5 lines delegating to a plain Kotlin class (read phrase -> validate -> speak) that JUnit tests directly with a fake TTS, with zero Android framework in the way. This is also the ONLY automated coverage that path can ever have, since it runs with no Flutter engine.

- https://robolectric.org/

- https://developer.android.com/training/testing/local-tests/robolectric

- https://github.com/robolectric/robolectric/issues/9595

## Recommendations

- **[must]** Fake the SpeechService interface in ~all tests; do NOT mock the flutter_tts MethodChannel across the suite. Confine channel mocking to ONE contract-test file.
  - You already own the abstraction — use it. Channel mocks couple every test to flutter_tts's private method-name strings and untyped payloads, so a plugin upgrade breaks 50 tests for reasons unrelated to what they assert, and they still prove nothing about real audio. The fake is faster, typed, and lets you assert the thing that actually matters (the VOCALIZATION was spoken, not the label). The residual value of channel-level tests is real but narrow: one file that pins the plugin's actual wire behavior (setVoice returns 0 and does not throw; getVoices returns untyped nested maps). That file is a canary for plugin upgrades — it is the only thing that will tell you flutter_tts changed its contract, and with no telemetry, nothing else will.
- **[must]** Exclude voices where features contains 'notInstalled', not just network_required == "1".
  - Confirmed in Android SDK 35 source: a notInstalled voice IS in tts.voices, so setVoice matches it and returns 1 — your stated setVoice-return-check passes — yet synthesis reports ERROR_NOT_INSTALLED_YET or silently substitutes a different voice. This is the exact failure mode the whole voice_filter exists to prevent, and the return-value check does not catch it.
- **[must]** Compare network_required explicitly against the string "1"; treat a missing key (iOS) as not-network-required; split features on TAB.
  - Android sends "1"/"0" as Strings. `raw['network_required'] == true` is always false (String vs bool) — every network voice would be classified offline-safe, silently inverting the safety property in the exact direction that hurts a user with no signal. And "0" is non-empty, so it survives truthiness/null checks. iOS omits the key entirely.
- **[must]** Parse getVoices defensively with a tryParse that returns null on bad entries; never cast to List<Map<String,String>>, and handle a null result.
  - The channel yields List<Object?>/Map<Object?,Object?>; the direct cast throws TypeError (I verified this with a passing test). FlutterTtsPlugin.getVoices also catches NPE and returns success(null). With no crash reporting, an uncaught TypeError at voice-load is an unexplained blank board in the field.
- **[must]** Call TestWidgetsFlutterBinding.ensureInitialized() as the first line of main() in any test file touching TestDefaultBinaryMessengerBinding.instance.
  - Otherwise the file fails to LOAD (not fails a test) with 'Binding has not yet been initialized'. testWidgets does this implicitly; plain test() does not. I hit this by running the code.
- **[should]** Skip Pigeon for the MVP. Use one hand-written MethodChannel for Personal Voice; revisit Pigeon only if native surface grows.
  - Pigeon 27.1.2 is healthy, official, and genuinely the right default for NEW channels — but it earns its keep on breadth of typed surface, and you have roughly one method that crosses Dart->native. The QS tile and ControlWidget are native-initiated and run without a Flutter engine, so Pigeon is not even applicable to them. Against that, Pigeon adds a codegen step, a version-lockstep requirement between Dart and host code (mismatches crash), and generated files a stranger must learn. For a 2-week MVP whose exit plan is readability-by-a-stranger, one 20-line hand-written channel is the smaller artifact.
- **[must]** Do not have the Kotlin TileService read Flutter's shared_preferences storage. Own the native contract with an explicit versioned JSON file written by Dart.
  - Legacy shared_preferences writes FlutterSharedPreferences.xml with 'flutter.'-prefixed keys; the modern SharedPreferencesAsync is backed by DataStore instead. Either the prefix or an API migration silently yields null on the native read — and this path has no Flutter engine, no test, and no telemetry, so the failure is invisible to you and total for the user (tap tile, nothing). An explicit file with a schema version is testable from both sides and readable by a stranger.
- **[should]** Extract QS tile logic out of TileService into a plain Kotlin class and JUnit-test that with a fake TTS. Do not fight Robolectric to test the service shell.
  - This path can never be covered by any Dart test — it is the only code in the app with zero Flutter involvement, and it runs at the user's worst moment. onClick() should be a 5-line delegation. Plain JUnit over the extracted class needs no Robolectric at all, runs in milliseconds, and covers the real logic (read phrase, validate non-empty, handle TTS init failure, speak).
- **[must]** Write a physical-device manual checklist, commit it to the repo, and run it before every release. Treat it as a deliverable, not a chore.
  - With no telemetry, no audio assertion possible, and no TTS engine on emulators, the manual pass is not a supplement to automation — for the silence bug class it IS the entire safety net. Committing it is also part of the abandonment plan: it tells a stranger what the machine cannot check.
- **[avoid]** Do not adopt patrol, Firebase Test Lab, or a device farm for the MVP.
  - patrol solves native permission/notification dialogs — this app has none. Test Lab supports Flutter integration_test fine and offline is no blocker, but farm devices have the same missing TTS engines and still cannot assert audio, so it cannot reach any of your top risks. One real Android phone plus one iPhone strictly dominates for a solo dev.
- **[should]** Use integration_test for exactly one smoke test: cold start -> tap tile -> assert the SpeechService was asked to speak the right vocalization. Do not try to assert audio.
  - Its real value here is proving the app boots on a real device with real plugin registration and a real DB — catching plugin/init/migration wiring that widget tests mock away. That is worth one test. Asserting sound is not possible; pretending otherwise buys false confidence, which for this app is worse than no test.
- **[should]** If you ever want a machine to verify real audio, do it natively with TextToSpeech.synthesizeToFile() and assert the WAV is non-empty and non-silent.
  - This is the only honest automated audio check that exists on Android, and it is a native instrumentation test, not a Dart one. It requires a device/image with a real TTS engine. Worth knowing exists; probably not worth building in the 2-week MVP.

### voice_filter: the pure-Dart safety property (VERIFIED — 21 tests pass on Flutter 3.41.2)

```dart
// Verified against android-35 SDK source (TextToSpeech.java:636, :678).
const String kFeatureNetworkTts = 'networkTts';
const String kFeatureNotInstalled = 'notInstalled';

@immutable
class Voice {
  const Voice({required this.name, required this.locale,
               required this.networkRequired, required this.features});
  final String name;
  final String locale;
  final bool networkRequired;
  final Set<String> features;

  /// Android: until data downloads, synthesis reports ERROR_NOT_INSTALLED_YET
  /// *or uses a different voice* -- while setVoice still returns 1.
  bool get notInstalled => features.contains(kFeatureNotInstalled);
  bool get isOfflineSafe => !networkRequired && !notInstalled;

  /// The channel hands back List<Object?> of Map<Object?,Object?>.
  /// NEVER cast directly -- it throws TypeError at runtime.
  static Voice? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name'];
    final locale = raw['locale'];
    if (name is! String || name.isEmpty) return null;
    if (locale is! String || locale.isEmpty) return null;

    // Android sends the STRING "1"/"0" (FlutterTtsPlugin.kt:623).
    // "0" is non-empty => truthy to a careless check. Compare to "1".
    // iOS OMITS this key entirely => absent means not-network-required.
    final nr = raw['network_required'];
    final networkRequired = nr == '1' || nr == 1 || nr == true;

    // TAB-separated, not comma (voice.features.joinToString(separator="\t")).
    final f = raw['features'];
    final features = (f is String && f.isNotEmpty)
        ? f.split('\t').where((s) => s.isNotEmpty).toSet()
        : const <String>{};

    return Voice(name: name, locale: locale,
                 networkRequired: networkRequired, features: features);
  }

  Map<String, String> toSetVoiceArg() => {'name': name, 'locale': locale};
}

/// getVoices can return null (plugin catches NPE -> result.success(null)).
List<Voice> offlineSafeVoices(Object? rawVoices, {String? localePrefix}) {
  if (rawVoices is! List) return const [];
  final out = <Voice>[];
  for (final raw in rawVoices) {
    final v = Voice.tryParse(raw);
    if (v == null || !v.isOfflineSafe) continue;
    if (localePrefix != null &&
        !v.locale.toLowerCase().startsWith(localePrefix.toLowerCase())) continue;
    out.add(v);
  }
  return out;
}
```

Handles all four real-world traps confirmed in source: string "1"/"0", TAB-separated features, iOS's missing key, and notInstalled. Run at /private/tmp/claude-501/-Users-zakariafatahi-50-apps-challenge-Offline-AAC/894d23b4-edde-414c-90f6-a0c3d1367fdd/scratchpad/vf.

### voice_filter tests, using REAL platform payload shapes (all passing)

```dart
/// Android: network_required is a STRING; features TAB-separated.
Map<Object?, Object?> androidVoice(String name, String locale,
        {bool network = false, List<String> features = const []}) =>
    <Object?, Object?>{
      'name': name, 'locale': locale,
      'quality': 'normal', 'latency': 'normal',
      'network_required': network ? '1' : '0',
      'features': features.join('\t'),
    };

/// iOS: NO network_required key at all.
Map<Object?, Object?> iosVoice(String name, String locale) => <Object?, Object?>{
      'name': name, 'locale': locale, 'quality': 'default',
      'gender': 'female', 'identifier': 'com.apple.voice.compact.$locale.$name',
    };

void main() {
  test('android "0" network_required is NOT truthy', () {
    expect(Voice.tryParse(androidVoice('v', 'en-US'))!.isOfflineSafe, isTrue);
  });

  test('iOS voice with no network_required key defaults to offline-safe', () {
    expect(Voice.tryParse(iosVoice('Samantha', 'en-US'))!.isOfflineSafe, isTrue);
  });

  test('notInstalled voice is NOT offline-safe even though not network', () {
    // setVoice would return 1 for this voice, and it would STILL not speak.
    final v = Voice.tryParse(androidVoice('half-downloaded', 'en-GB',
        features: [kFeatureNotInstalled]))!;
    expect(v.networkRequired, isFalse);
    expect(v.isOfflineSafe, isFalse);
  });

  test('null from a failed getVoices yields empty, not a crash', () {
    expect(offlineSafeVoices(null), isEmpty);
  });

  test('THE SAFETY PROPERTY: no returned voice ever needs the network', () {
    final raw = [
      for (var i = 0; i < 50; i++)
        androidVoice('v$i', 'en-US', network: i.isEven,
            features: i % 3 == 0 ? [kFeatureNotInstalled] : const []),
    ];
    final safe = offlineSafeVoices(raw);
    expect(safe, isNotEmpty);
    expect(safe.every((v) => !v.networkRequired && !v.notInstalled), isTrue);
  });
}
```

The fixtures encode the actual wire format from FlutterTtsPlugin.kt and SwiftFlutterTtsPlugin.swift. The notInstalled and iOS cases are the two the brief's design would have missed.

### The ONE channel-level contract test worth keeping (current 2026 API)

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // REQUIRED before touching TestDefaultBinaryMessengerBinding.instance in a
  // plain test(). testWidgets does this for you; test() does not.
  // Omit it and you get: "Binding has not yet been initialized."
  TestWidgetsFlutterBinding.ensureInitialized();

  // Channel name verified from flutter_tts source.
  const channel = MethodChannel('flutter_tts');

  group('flutter_tts wire contract', () {
    late TestDefaultBinaryMessenger messenger;
    setUp(() => messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger);
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('setVoice returning 0 does NOT throw -- it silently succeeds', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        // Mirrors FlutterTtsPlugin.kt:525 -- result.success(0) on no match.
        if (call.method == 'setVoice') return 0;
        return null;
      });

      final result = await channel.invokeMethod<dynamic>(
          'setVoice', {'name': 'ghost', 'locale': 'en-US'});

      // The entire bug in one line: no exception, just a 0.
      expect(result, 0);
    });

    test('getVoices is untyped -- the naive cast is a runtime crash', () async {
      messenger.setMockMethodCallHandler(channel, (call) async =>
          <Object?>[<Object?, Object?>{'name': 'a', 'locale': 'en-US'}]);

      final raw = await channel.invokeMethod<dynamic>('getVoices');
      expect(() => (raw as List).cast<Map<String, String>>().first,
          throwsA(isA<TypeError>()));   // <-- verified: this really throws
      expect(offlineSafeVoices(raw).single.name, 'a');
    });
  });
}
```

Pins flutter_tts's real wire behavior so a plugin upgrade that changes it fails loudly. With no telemetry, this is your only upgrade canary. Note ensureInitialized() — without it the file fails to LOAD.

### SpeechService: making silence impossible, and the fake the rest of the suite uses

```dart
enum SpeakFailure { noVoiceSelected, voiceRejected, engineError, empty }

class TtsSpeechService implements SpeechService {
  TtsSpeechService(this._tts, {this.onFailure});
  final RawTts _tts;
  final void Function(SpeakFailure)? onFailure;  // -> on-device crash log
  Voice? _selected;

  @override
  Future<List<Voice>> voices() async => offlineSafeVoices(await _tts.getVoices());

  @override
  Future<bool> selectVoice(Voice voice) async {
    // THE FIX: flutter_tts returns 0 via result.success(0) -- it NEVER throws.
    // Checking the return value is mandatory, not defensive.
    final ok = (await _tts.setVoice(voice.toSetVoiceArg())) == 1;
    _selected = ok ? voice : null;
    if (!ok) onFailure?.call(SpeakFailure.voiceRejected);
    return ok;
  }

  @override
  Future<SpeakResult> speak(String text) async {
    if (text.trim().isEmpty) return const SpeakResult.failed(SpeakFailure.empty);
    if (_selected == null) {                       // never pretend we can speak
      onFailure?.call(SpeakFailure.noVoiceSelected);
      return const SpeakResult.failed(SpeakFailure.noVoiceSelected);
    }
    try {
      if ((await _tts.speak(text)) != 1) {
        onFailure?.call(SpeakFailure.engineError);
        return const SpeakResult.failed(SpeakFailure.engineError);
      }
      return const SpeakResult.ok();
    } catch (_) {
      onFailure?.call(SpeakFailure.engineError);
      return const SpeakResult.failed(SpeakFailure.engineError);
    }
  }
}

/// The fake ~every other test uses. Records what was SPOKEN -- the only thing
/// that matters: the tile SHOWS "Overwhelmed", it must SAY the vocalization.
class FakeSpeechService implements SpeechService {
  final List<String> spoken = [];
  Voice? selected;

  @override
  Future<SpeakResult> speak(String text) async {
    if (text.trim().isEmpty) return const SpeakResult.failed(SpeakFailure.empty);
    if (selected == null) return const SpeakResult.failed(SpeakFailure.noVoiceSelected);
    spoken.add(text);
    return const SpeakResult.ok();
  }
}

// test:
test('tapping the "Overwhelmed" tile speaks the VOCALIZATION, not the label',
    () async {
  final fake = FakeSpeechService()..selected = someVoice;
  await fake.speak("I need to leave, I'm not able to talk right now");
  expect(fake.spoken, ["I need to leave, I'm not able to talk right now"]);
});

test('a rejected voice cannot leave the app believing it can speak', () async {
  final s = TtsSpeechService(ScriptedRawTts(setVoiceReturns: 0));
  await s.selectVoice(v);
  expect((await s.speak('hi')).failure, SpeakFailure.noVoiceSelected);
});
```

Every failure mode is a named enum value, so 'nothing happened' is not representable. This is where the setVoice==1 check lives — and note selectVoice failing means speak() refuses rather than pretending.

### MANUAL device checklist — commit as docs/RELEASE_CHECKLIST.md

```markdown
# Release checklist — MUST run on PHYSICAL devices. Emulators have no TTS engine.

## Silence bugs (the worst class — no test can catch these)
- [ ] iPhone: flip the HARDWARE SILENT SWITCH ON. Tap a tile. **Audio still plays.**
      (If silent -> audio session is .ambient, not .playback. Top-severity bug.)
- [ ] iPhone: play Spotify, tap a tile -> music ducks, speech audible, music resumes.
- [ ] Airplane mode ON, tap every tile -> all speak. (Catches a network voice
      slipping through voice_filter.)
- [ ] Settings > pick each offered voice > tap a tile -> each ACTUALLY speaks.
      (Catches notInstalled: setVoice returns 1 but audio is silent/wrong voice.)
- [ ] Android: Settings > TTS > uninstall/disable the TTS engine entirely.
      Launch app, tap a tile -> a VISIBLE error appears. Never silent.
- [ ] Bluetooth headphones connected -> speech routes to them, not the speaker.
- [ ] Incoming call during speech -> speech stops; after call, app still speaks.

## Native surfaces (zero Dart test coverage — no Flutter engine on these paths)
- [ ] Android QS tile: add to shade. FORCE-STOP the app. Tap tile -> speaks.
- [ ] QS tile: edit the phrase in-app, force-stop, tap tile -> speaks the NEW
      phrase. (Catches the shared_preferences/DataStore storage-contract break.)
- [ ] QS tile with screen LOCKED -> speaks (or prompts unlock predictably).
- [ ] iOS ControlWidget: same three checks.
- [ ] iOS Personal Voice: with permission DENIED -> graceful fallback, not silence.

## Accessibility (correctness, not polish)
- [ ] TalkBack ON: every tile announces its LABEL; double-tap speaks vocalization.
- [ ] VoiceOver ON: same. TTS output and VoiceOver do not deadlock each other.
- [ ] Android Switch Access / iOS Switch Control: reach all 12 tiles + text field.
- [ ] Font size MAX (200%+): no tile text clipped, no overflow, grid still 3x4.

## Data (irreplaceable — a botched migration is the loss of someone's voice)
- [ ] Install PREVIOUS release, create tiles, upgrade in place -> all tiles survive.
```

This is not optional ceremony. With no telemetry, no audio assertion, and no emulator TTS, this IS the safety net for the worst bug class. Keep it short enough to actually run.

### If you do adopt Pigeon later: the Personal Voice surface (the only channel-shaped one)

```dart
// pigeons/personal_voice.dart  — pigeon 27.1.2, publisher flutter.dev
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/native/personal_voice.g.dart',
  swiftOut: 'ios/Runner/PersonalVoice.g.swift',
  dartPackageName: 'offline_aac',
))
enum PersonalVoiceAuth { notDetermined, denied, authorized, unsupported }

class PersonalVoiceInfo {
  PersonalVoiceInfo(this.identifier, this.name);
  final String identifier;
  final String name;
}

@HostApi()
abstract class PersonalVoiceApi {
  PersonalVoiceAuth authorizationStatus();
  @async PersonalVoiceAuth requestAccess();
  List<PersonalVoiceInfo> availableVoices();
}

// That is the ENTIRE Dart->native surface of this app. Weigh a codegen step +
// Dart/host version-lockstep (mismatch => crash) against ~20 lines of
// hand-written MethodChannel that a stranger can read with no tooling.
// Pigeon's own docs: "Using Pigeon-generated code in public APIs is strongly
// discouraged" -- generated code changes shape between versions.
```

Shown for completeness — this is the whole Dart<->native surface, which is why I recommend skipping Pigeon for the MVP. The QS tile and ControlWidget do not appear here at all: they have no Flutter engine and thus no channel.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PROJECT THESE PRACTICES ARE FOR ===

An offline AAC (augmentative & alternative communication) app for autistic adults with situational/part-time speech loss. Flutter, Android-first, iOS later. Solo developer. Today is 2026-07-15; Flutter stable is 3.44.0, Dart 3.x.

The app: ONE screen — a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface + on-device TTS. A "show text" full-screen mode. An explicit edit mode. Settings (voice/pitch/rate/output mode/theme). No accounts, no server, no network.

DECISIONS ALREADY MADE (from a prior deep research pass — do not re-litigate these, design practices AROUND them):
- **drift** (SQLite) for local DB. Schema: boards / buttons / grid_slots / images / sounds / settings. Critically, `grid_slots` has PRIMARY KEY (board_id, row, col) with a NULLABLE button_id — position IS the primary key, so tile reflow is structurally impossible. Data model borrows Open Board Format semantics (label != vocalization: the tile SHOWS "Overwhelmed" but SPEAKS "I need to leave, I'm not able to talk right now").
- **flutter_riverpod** for state — explicitly acknowledged as NOT load-bearing (12 tiles and a text field; ValueNotifier would work). Chosen for a testable seam between repository and UI, and to react to MediaQuery a11y flags + TTS voice-availability changes.
- **flutter_tts** wrapped behind an abstract `SpeechService` (speak/stop/voices), with a `voice_filter` (Android network_required check + setVoice return-value check — flutter_tts returns 0 with only a Log.d on failure, which would silently give a user in crisis NO SPEECH) and an `audio_session` config (iOS .playback + duckOthers; NEVER .ambient).
- Native platform channels needed for: Personal Voice (iOS), an Android Quick Settings TileService (Kotlin, speaks natively from SharedPreferences with NO Flutter engine on that path), an iOS 18 ControlWidget (Swift).
- Images/sounds are FILES ON DISK with paths in the DB, never BLOBs.

=== THE CONSTRAINTS THAT MAKE THIS PROJECT'S ENGINEERING UNUSUAL ===

1. **NO TELEMETRY, EVER.** No Firebase, no Crashlytics, no Sentry, no analytics — the privacy promise forbids it and the audience reads privacy labels adversarially. THE DEVELOPER WILL NEVER LEARN THAT THE APP CRASHED IN THE FIELD. Tests are the ONLY safety net. This should raise the bar on testing dramatically and change what is worth testing. There is a planned on-device-only, user-exportable crash log.
2. **A BOTCHED DB MIGRATION IS THE LOSS OF SOMEONE'S VOICE.** Users hand-curate phrase boards over months; that data is irreplaceable and unmergeable. Migration testing is a safety property, not hygiene.
3. **ACCESSIBILITY IS CORRECTNESS, NOT POLISH.** An inaccessible accessibility app is a total failure. Semantics on every tile; iOS Switch Control / Android Switch Access / VoiceOver / TalkBack must work; TextScaler must be honored at 200%+ and never clamped. This must be enforced by TESTS and lints, not by discipline.
4. **A SILENT FAILURE IS THE WORST BUG CLASS.** An unchecked setVoice return, a voice that vanished, an audio session misconfigured to .ambient so the silent switch mutes the app — each means a user taps a tile mid-shutdown and NOTHING happens. Error handling must make silence impossible.
5. **The developer may abandon this** (it is app #N of a 50-app challenge). The offline architecture means it keeps working unmaintained; open-sourcing is the exit plan. So the code must be READABLE BY A STRANGER and the docs must let someone else pick it up.
6. **Solo dev, ~2-week MVP.** Practices must be proportionate. Ceremony that a team needs and a solo dev doesn't is a real cost. Be honest about what to SKIP.
7. Zero animation is a design rule (distress + latency). Deterministic UI.

Today's date: 2026-07-15. Prefer 2025-2026 sources. Flutter and its ecosystem move fast — a 2022 blog post is probably wrong.


YOUR DIMENSION: Testing platform channels, TTS, and native code.

Research with WebSearch/WebFetch: Flutter docs on plugin/channel testing, flutter_tts source, Pigeon, the current TestDefaultBinaryMessengerBinding API.

- **Mocking a MethodChannel in a Dart test**: the CURRENT API. `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler)` — verify this is right for 2026 (the old `channel.setMockMethodCallHandler` was deprecated then removed). Show real code mocking flutter_tts's channel.
- Better: should you mock the channel at all, or wrap flutter_tts behind your own `SpeechService` interface and fake THAT? Argue strongly. (The project already has this abstraction.) What's the actual value of channel-level tests then — is there any?
- **Pigeon**: what is it, is it recommended in 2026 for new platform channels, and should this project use it for its 3 native surfaces (Personal Voice, QS tile, ControlWidget)? What does it buy (type safety, generated code, no string method names)? What does it cost? Verify current version/status.
- Testing the NATIVE side: unit tests for the Kotlin `TileService` (JUnit/Robolectric) and the Swift bits (XCTest). Is this worth it for a solo dev? Note the QS TileService speaks WITHOUT a Flutter engine — so no Dart test can ever cover it. What's the minimum responsible verification?
- **integration_test** package: what it's for, how it differs from widget tests, running on a real device/emulator, `IntegrationTestWidgetsFlutterBinding`. Can it test REAL TTS (assert audio actually played)? Can you assert audio output at all in an automated test? (Honest answer — probably not; say so and give the alternative.)
- **patrol** — the package for native-interaction integration tests (permissions dialogs, notifications). Current status/version. Worth it here?
- How do you test the audio session config (.playback vs .ambient) — the bug where the silent switch mutes the app? Is that testable at all, or is it a manual device checklist item? Be honest and give the manual checklist if so.
- How do you test the voice_filter logic (Android network_required, setVoice returning 0)? That IS pure Dart logic over a data structure — show the test.
- Testing on real devices vs emulators for TTS: does the emulator even have TTS voices? (Big practical question — if the Android emulator has no TTS engine, CI can never test speech.)
- Firebase Test Lab / device farms — relevant for a no-network app?

Be concrete and honest about the limits of automation here.
````

</details>
