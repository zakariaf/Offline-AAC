# E04-T03 — The flutter_tts implementation

| | |
|---|---|
| **Epic** | E04 — Speech |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E04-T02 |
| **Blocks** | E01-T06, E04-T04, E04-T05 |

**Skills:** `reed-speech-service` · `reed-error-model` · `reed-no-silent-failures` · `reed-async-rules`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

This is the file where the words either leave the speaker or they do not. `flutter_tts`'s Kotlin, when it cannot find a voice, does `Log.d(tag, "Voice name not found: $voice"); result.success(0)` — `result.success`, not `result.error`. It never throws. Unchecked, a user in a shutdown taps a tile, gets silence, and the only evidence is a `Log.d` on a device nobody will ever see. There is no telemetry, and a person who cannot speak does not file a bug report. Every line below exists because some plausible-looking version of it reports success and emits nothing.

## Scope

Build `FlutterTtsSpeechService`, the one real implementation of the `SpeechService` interface from E04-T02, in `lib/data/speech/flutter_tts_speech_service.dart`.

**As thin as physically possible.** This class cannot run in `flutter test` — that is the entire reason the interface exists. Every line you put here is a line no test can reach. So it does exactly one thing: it calls the plugin and checks what came back. Everything with logic in it lives one layer up (`voice_filter`, `SpeakOutcome`, `SpeechController`) where a plain Dart test can execute it. If you find yourself writing an `if` that is not a return-code check or a guard, it belongs somewhere else.

Only four plugin methods may be used across the whole app — `speak`, `stop`, `getVoices`, `setVoice` — plus the iOS audio category. Keep it that way: `flutter_tts` is effectively single-maintainer and MIT, and a four-method surface makes vendoring a one-file change on the day that matters.

### `speak` — the shape, exactly

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

The guard order is load-bearing and is not stylistic. `notInstalled` **must** be checked *before* the `setVoice` call, because Android returns **1 (success)** from `setVoice` for a voice carrying the `notInstalled` feature flag and then synthesis either reports `ERROR_NOT_INSTALLED_YET` or silently substitutes a different voice. Put the `notInstalled` guard after the return check and it is dead code that never fires, while the case it was written for ships.

The `!= _ttsSuccess` check reads as paranoia to every reviewer. It is the documented behaviour of the plugin. **Leave the comment at the point of temptation** — it is the only thing standing between this check and a future cleanup.

### The rest of the surface

- `stop()` → `Future<void>`, delegates to `_tts.stop()`. Barge-in is the caller's policy (`SpeechController` does `stop()` then `speak()` on every tap); this method just stops.
- `voices()` → `Future<List<Voice>>`. Takes whatever `_tts.getVoices` returns as `Object?` and hands it straight to `offlineSafeVoices(raw)` from `lib/data/speech/voice_filter.dart`. **No cast.** `getVoices` can return `null` (the plugin catches a `NullPointerException` and calls `result.success(null)`), and it hands back `List<Object?>` of `Map<Object?, Object?>` — `(raw as List).cast<Map<String, String>>()` throws `TypeError` at runtime. `offlineSafeVoices` already handles both; do not "help" it with a cast on the way in.
- `warmUp()` → best-effort, **fails silently**. Called from `addPostFrameCallback`, never awaited, never blocks the first frame: the engine binding runs binder IPC and voice deserialization synchronously on the main thread inside `OnInitListener`, which ANRs on the cold-start path. **Warm-up fails silently; `speak()` fails loudly.** That asymmetry on one service is deliberate. Do not unify them in either direction.

### Explicitly OUT of scope

- `voice_filter` / `tryParseVoice` / `offlineSafeVoices` and their wire-format traps — pure Dart, separate file, already covered.
- The `SpeakOutcome` sealed hierarchy — defined in E04-T02.
- `SpeechController`, `speakNow`, the exhaustive switch, the on-screen fallback, the lit-state latch — one layer up (E04-T05).
- The `.playback` audio session in `lib/data/speech/audio_session_config.dart`.
- The `TTS_SERVICE` `<queries>` manifest line and its manifest test.
- Any fake, any channel-mock test file. This class is the part that cannot be tested; the tests live against the interface.

## Acceptance criteria

- [ ] `lib/data/speech/flutter_tts_speech_service.dart` declares `final class FlutterTtsSpeechService implements SpeechService` with `static const _ttsSuccess = 1;` and `static const _speakTimeout = Duration(seconds: 8);`.
- [ ] `speak` is annotated `@override @useResult` and returns `Future<SpeakOutcome>`. Its every exit path returns a `SpeakOutcome` — there is no `throw` in the method.
- [ ] `grep -n 'assert(' lib/data/speech/flutter_tts_speech_service.dart` returns nothing.
- [ ] `grep -c 'as List\|\.cast<' lib/data/speech/flutter_tts_speech_service.dart` returns `0`.
- [ ] `grep -n 'notInstalled' lib/data/speech/flutter_tts_speech_service.dart` reports a line number **lower** than the line of the `_tts.setVoice(` call.
- [ ] The only `flutter_tts` methods referenced anywhere in the file are `speak`, `stop`, `getVoices`, `setVoice`: `grep -o '_tts\.[a-zA-Z]*' lib/data/speech/flutter_tts_speech_service.dart | sort -u` yields exactly those four.
- [ ] Every `catch` in the file carries an `on` clause (`TimeoutException`, `PlatformException`). No bare `catch`, no `catch (e)` without a type.
- [ ] `flutter analyze` is clean with `unused_result`, `discarded_futures`, `unawaited_futures` at `error`.
- [ ] `dart compile` / the release build succeeds — CI must **build**, not just analyze, since `non_exhaustive_switch_statement` can be silenced in the analyzer while `dart compile` still fails.
- [ ] `voices()` passes the raw `Object?` from `getVoices` to `offlineSafeVoices` with no intervening cast or null-check of its own.
- [ ] The `result.success(0)` comment sits immediately above the `setVoice` call and the `notInstalled` comment immediately above its guard. Both are present in the committed file.
- [ ] `warmUp()` returns `Future<void>`, has no `throw` reaching the caller, and is not awaited by anything on the pre-first-frame path.

## Traps

- **`assert(await _tts.setVoice(v) == 1)`.** Asserts are stripped in release. The check is green in every test and *absent on the user's device* — the perfect silent failure: your test suite proves the opposite of what ships. Asserts cover `Error` ground (bugs we could make: negative grid coordinates). Sealed outcomes cover `Exception` ground (things the device did). Voice availability is a fact about the device, not our bug. Never `assert` a platform return code.
- **Checking `setVoice`'s return value and thinking `notInstalled` is now covered.** It returns **1** for a `notInstalled` voice. The return check is structurally incapable of seeing this case. If you reorder the guards, `VoiceNotInstalled` becomes unreachable and the exhaustive switch upstream still compiles green while never handling the case — a silent failure hiding inside the mechanism built to make silent failures impossible.
- **Assuming a plugin failure throws.** It does not. `result.success(0)` after a `Log.d`. There is no exception to catch, no `PlatformException`, nothing on the error channel. If you only wrap calls in try/catch and skip the `!= _ttsSuccess` comparisons, every failure mode here reports success.
- **A reviewer (or you, in three weeks) deleting `if (spoke != _ttsSuccess)` as dead paranoia.** It is documented plugin behaviour. The comment is the defence. Do not move it away from the call it guards.
- **Casting the `getVoices` payload.** Everything crossing a platform channel is `Map<Object?, Object?>`. `(raw as List).cast<Map<String, String>>()` compiles and throws `TypeError` on a real device. `avoid_dynamic_calls` is at `error` for this. Use `tryParse` and null checks — which `voice_filter` already does. Pass the `Object?` through.
- **Fattening this class.** Every branch you add here is a branch no `flutter test` can execute. Retry loops, voice-picking heuristics, caching, "helpful" filtering — all of it belongs one layer up. One interface, one real impl, one fake is only justified because the impl is trivial.
- **Awaiting `warmUp()` before `runApp`.** `OnInitListener` does binder IPC and voice deserialization synchronously on the main thread; on the cold-start path that is an ANR. It goes in `addPostFrameCallback`, unawaited, after the grid is visible and tappable.
- **Making `warmUp()` loud.** It is deliberately the one thing here that swallows its failure — the stored-voice re-resolution and `speak()` handle the consequences audibly. Do not "consistency-fix" it into returning an outcome.
- **Reaching for `MethodChannel('flutter_tts')` mocks to test this class.** You own the abstraction; fake that instead. Channel mocks couple the suite to the plugin's private method-name strings and prove nothing about whether audio came out. Exactly one channel contract file exists as the upgrade canary — this task does not add another.

## Files

- Creates: `lib/data/speech/flutter_tts_speech_service.dart`
- Reads (does not change): `lib/data/speech/speech_service.dart`, `lib/data/speech/voice_filter.dart`, the `SpeakOutcome` library from E04-T02

## Done when

`FlutterTtsSpeechService` implements `SpeechService` with every one of the four plugin return paths checked by hand, no `assert` on any of them, the `notInstalled` guard sitting ahead of the `setVoice` check, and the release build green.
