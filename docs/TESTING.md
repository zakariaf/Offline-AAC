# Testing

This app will never send you a crash report. It will never send you an analytics
event. There is no Firebase, no Sentry, no Crashlytics, and there never will be —
the privacy promise forbids it and the audience reads privacy labels
adversarially.

So: **when this app fails in the field, you will not find out.** A user in
shutdown taps a tile, gets silence, and uninstalls. That is the entire feedback
loop.

Tests are not a quality practice here. They are the only instrument you have.

---

## 1. The strategy, and the thing most people get wrong

The instinct is *"no crash reporting, so write more tests."* That is half right,
and acting on the wrong half will eat your two weeks.

**Tests and telemetry cover disjoint risk sets.**

- Tests cover the risks **you thought of**.
- Telemetry covered the risks **you didn't** — device diversity, engine
  variants, the 4% of users with no TTS engine installed.

You cannot refill a deleted discovery channel with more of the same tests. Only
three things substitute:

1. **A-priori enumeration of the hostile environment.** Normally you test the
   happy path and let Crashlytics find the environment empirically. Here,
   **the environment IS the test suite.** §2 is that enumeration, and it is the
   spine of this document.
2. **One technique that authors cases you didn't write** — a seeded random loop
   over the edit-op space (§7). Not `glados`: v1.1.7, last published ~2 years
   ago. A stale dependency is a liability for a repo whose exit plan is a
   stranger picking it up.
3. **Making failure loud in-app**, then testing the loudness. If you can't
   observe remotely, the user must observe locally and hand you the log.

### What this does NOT argue for

**More integration tests.** That instinct is wrong and expensive. Integration
tests run on *your one emulator* — a single configuration that samples zero
device diversity. Worse: **the Android emulator ships no TTS engine**, so CI can
never verify speech at all. Budget **3** integration tests, not a suite.

### The honest ratio

Forget 70/20/10 — that number traces to Google's 2011 test-*size* heuristic
whose own author said the numbers "essentially were pulled out of a hat," and it
was never about Flutter's unit/widget/integration taxonomy. Flutter's docs
publish no ratio and [never mention the pyramid][testing-overview].

Test shape follows **code** shape, and this app's shape is unusual: 12 tiles and
a text field contain almost no pure logic. The entire unit-testable surface is
four files — migrations, `voice_filter`, the board repository, the crash log.
Everything else is UI or a thin wrapper over a plugin.

| Suite | Tests | Runtime |
|---|---:|---|
| Speech (`voice_filter`, `SpeechService`, silence loop) | ~35 | |
| Database (invariants, migrations, backup) | ~25 | |
| Widget (board, overflow matrix, a11y) | ~60 | |
| Crash log | 8 | |
| Policy (source greps) | 4 | |
| Channel contract | 4 | |
| Integration (device) | 3 | not in `flutter test` |
| **Total** | **~135** | **< 30 s** |

The 30 seconds is not vanity. It's the number that determines whether a solo dev
keeps running the suite — and a suite you stop trusting, in a project with no
telemetry, means nothing at all stands between users and silence.

[testing-overview]: https://docs.flutter.dev/testing/overview

---

## 2. The silent-failure catalogue

Every way a user taps a tile and gets nothing, or the wrong thing.

**D** = Dart test · **I** = integration (real device) · **M** = manual only ·
**X** = structurally untestable

### 2.1 Speech never happens

| # | Failure | Where | Mitigation |
|---|---|---|---|
| 1 | Android 11+ package visibility hides the TTS engine | **D** | Missing `<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>` → empty voice list, total silence, **every Android 11+ device**. A Dart test can read the manifest. §8.2 |
| 2 | No TTS engine installed at all | **D** | Fake returns `[]` → assert visible fallback |
| 3 | Engine present, zero voices | **D** | Same |
| 4 | Only `network_required` voices (offline app + network voice = silence) | **D** | `voice_filter`. **Android sends the STRING `"1"`/`"0"`.** `raw['network_required'] == true` is *always* false (String vs bool), and `"0"` is non-empty so it survives truthiness checks — a naive check **silently inverts the safety property** in the direction that hurts |
| 5 | `setVoice` returns 0 | **D** + 1 contract test | Confirmed verbatim in `FlutterTtsPlugin.kt`: `Log.d(tag, "Voice name not found: $voice"); result.success(0)`. It is `result.success`, **not** `result.error` — it never throws. Check `== 1` |
| 6 | Voice has the `notInstalled` feature | **D** (filter) / **M** (behaviour) | `setVoice` returns **1 (success)** and synthesis reports `ERROR_NOT_INSTALLED_YET` *or silently substitutes a different voice*. **The return-value check does not catch this.** Filter on `features.contains('notInstalled')`. Features are **TAB-separated** |
| 7 | Stored voice uninstalled since last launch (Android GCs voice data) | **D** | The **most probable real-world silent failure.** Re-resolve the stored voice id against `voices()` at startup; fall back audibly |
| 8 | `speak()` returns 0 | **D** | Check `== 1` |
| 9 | `onTap: () => service.speak(p)` drops the Future | **structural** | Caught by **no lint**. Verified: the arrow closure "returns" the Future so `discarded_futures` considers it handled — but the target is `VoidCallback`, so the Future *and its error* hit the floor. This is the most idiomatic way to wire a tile in Flutter. Fix by construction: §4.3 |
| 10 | Engine reports success, emits no audio | **X** | No hook exists to capture PCM from `AVSpeechSynthesizer` / Android TTS. **Manual, permanently.** Checklist §11 |
| 11 | `.ambient` audio session → hardware silent switch mutes the app | **M** | **flutter_tts's own README example uses `.ambient`.** A Dart test can only assert *your code passed `.playback` to the wrapper* — a value-level assertion, not the real `AVAudioSession` category |
| 12 | Audio focus denied (call in progress) | **M** | Checklist |
| 13 | Bluetooth yanked mid-utterance | **M** | Checklist |
| 14 | TTS bind latency reads as silence | **M** | Warm from `addPostFrameCallback`, never awaited. flutter_tts PR #594 documents binder IPC + voice deserialization running **synchronously on the main thread** inside `OnInitListener` |

### 2.2 The wrong thing is spoken

| # | Failure | Where | Mitigation |
|---|---|---|---|
| 15 | Tile speaks its **label** instead of its **vocalization** | **D** | The core Open Board Format semantic. Nothing in the type system distinguishes two `String`s. §5.1 |
| 16 | Stale closure: a fast re-tap speaks the *previous* tile's phrase | **D** | Never capture a `ref.watch` value in `build()` into an `onTap` closure. Pass `(row, col)` — position is the PK and cannot go stale |
| 17 | Tile reflow → muscle memory hits the wrong tile | **D** | `PRIMARY KEY (board_id, row, col)` makes it structurally impossible. Pin it anyway: §6.1, §7 |
| 18 | QS tile speaks a phrase deleted months ago | **I only** | §9 |

### 2.3 The board is gone

| # | Failure | Where | Mitigation |
|---|---|---|---|
| 19 | Migration produces the right schema and drops every row | **D** | `migrateAndValidate` is **blind to rows**. §6 |
| 20 | User skipped 6 months of updates: v1→v3 never tested | **D** | Nested loop, ~10 lines |
| 21 | Schema changed without bumping `schemaVersion` → no migration runs | **CI** | `schema dump` + `git diff --exit-code` |
| 22 | **SQLite FKs are OFF by default and are per-connection** | **D** | `grid_slots.button_id` is a nullable FK whose entire purpose is `onDelete: KeyAction.setNull`. With FKs off, SQLite **silently ignores the action** → dangling `button_id` → blank-or-crashing tile |
| 23 | Absolute image path dies on iOS reinstall/restore (container UUID changes) | **D** | Store paths **relative** to the app documents dir |
| 24 | 12MP photo × 12 tiles → OOM kill on a 2GB phone | **D** | Downscale **at import** (≤512px). An OOM is permanently invisible without telemetry |

### 2.4 The failure exists but is not surfaced

| # | Failure | Where | Mitigation |
|---|---|---|---|
| 25 | Error caught and swallowed | **D** | §4.4 — the parameterized test |
| 26 | Crash log throws inside the error handler → recursion | **D** | §10 |
| 27 | Crash log buffered, not flushed → you lose exactly the startup crash you need | **D** | Synchronous, `flush: true` |
| 28 | Crash log leaks the user's vocalizations to whoever they email it to | **D** | It's user-exportable and `record(msg, stack)` will happily capture phrase text. Redact, and test the redaction |

---

## 3. The harness

One file. Not a framework.

```dart
// test/support/harness.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:offline_aac/app.dart';
import 'package:offline_aac/speech/speech_service.dart';
import 'package:offline_aac/providers.dart';

import 'fake_speech_service.dart';

/// `physicalSize` is in PHYSICAL pixels. `view.physicalSize = Size(320, 568)`
/// at the default DPR of 3.0 gives you a 107x189 surface, not an iPhone SE.
class Device {
  const Device(this.name, this.logicalSize, this.dpr);

  final String name;
  final Size logicalSize;
  final double dpr;

  static const seLike = Device('se_like_320', Size(320, 568), 2.0);
  static const small = Device('small_360', Size(360, 800), 3.0);
  static const pixel7 = Device('pixel_7', Size(412, 915), 2.625);

  static const all = <Device>[seLike, small, pixel7];

  @override
  String toString() => name;
}

extension AacHarness on WidgetTester {
  /// The default widget-test surface is 800x600 LOGICAL — wider than any phone
  /// (and shorter than most). Unpinned, a layout test measures a screen nobody
  /// owns: tiles come out ~2x too wide, the text fits, the suite is green, and
  /// the shipped 360pt phone is broken. Pin EVERY layout test.
  void useDevice(Device d) {
    view.devicePixelRatio = d.dpr;
    view.physicalSize = d.logicalSize * d.dpr;
    // TestFlutterView.reset() — prefer it over the resetPhysicalSize /
    // resetDevicePixelRatio pairs. A leaked view size poisons the next test.
    addTearDown(view.reset);
  }

  Future<void> pumpApp({
    SpeechService? speech,
    List<Override> overrides = const <Override>[],
    TextScaler textScaler = TextScaler.noScaling,
    bool boldText = false,
    bool accessibleNavigation = false,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: <Override>[
          // overrideWithValue — NOT overrideValue, which does not exist.
          speechServiceProvider.overrideWithValue(speech ?? FakeSpeechService()),
          ...overrides,
        ],
        // The MediaQuery goes ABOVE MaterialApp on purpose. pumpWidget wraps the
        // tree in a View, which inserts MediaQuery.fromView; MaterialApp inserts
        // none of its own (useInheritedMediaQuery is gone), so this one is the
        // nearest ancestor and wins.
        //
        // Builder + copyWith is load-bearing: a bare MediaQueryData() would zero
        // out the view-derived size and padding useDevice() just pinned.
        child: Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: textScaler,
              boldText: boldText,
              accessibleNavigation: accessibleNavigation,
            ),
            child: const AacApp(),
          ),
        ),
      ),
    );
    // One frame. Zero animation is a design rule, so there is nothing to settle.
    await pump();
  }
}
```

### On `pumpAndSettle`

Zero animation means state changes settle in one frame, and `pumpAndSettle`'s
only job is waiting out animations you don't have. It carries a 10-minute
default timeout and [truncates its stack trace on timeout][84966], so it can only
add flake here.

**But do not overstate the rule.** `pump()` does *not* advance the fake clock —
`Timer`, `Future.delayed`, and debounces still need `pump(duration)` or
`fakeAsync`. The honest convention, which is **local to this repo and not
something Flutter recommends**:

> Ban `pumpAndSettle` as an *animation* wait. Use `pump()` for state changes and
> `pump(duration)` for time-based async.

[84966]: https://github.com/flutter/flutter/issues/84966

---

## 4. Speech: the one thing that must never fail quietly

### 4.1 The outcome type

There are five different `SpeechService` shapes floating around the research.
Here is the one that ships. The others are wrong for a specific reason: a
`bool` return invites you to ignore it, a throw can be forgotten (Dart requires
no declaration and no catch), and `Result<Exception>` gives zero exhaustiveness —
`case Err(:final e)` tells you nothing about *which* failure, so the compiler
cannot force you to handle a new one.

```dart
// lib/speech/speak_outcome.dart
import 'package:meta/meta.dart';

/// The result of trying to vocalize a phrase.
///
/// Every failure variant carries [SpeakFailure.spokenText], which makes showing
/// the phrase on screen a TOTAL function of the outcome. A user who taps a tile
/// must never get nothing.
@immutable
sealed class SpeakOutcome {
  const SpeakOutcome();
}

final class SpokeAloud extends SpeakOutcome {
  const SpokeAloud();
}

@immutable
sealed class SpeakFailure extends SpeakOutcome {
  const SpeakFailure(this.spokenText);

  /// The text that was supposed to be spoken. The on-screen fallback.
  final String spokenText;

  /// One line for the on-device crash log. Never shown to the user.
  String get logLine;
}

final class NoVoiceSelected extends SpeakFailure {
  const NoVoiceSelected(super.spokenText);

  @override
  String get logLine =>
      'no usable voice: settings hold none, or voice_filter removed all candidates';
}

final class VoiceUnavailable extends SpeakFailure {
  const VoiceUnavailable(super.spokenText, {required this.voiceName});

  final String voiceName;

  @override
  String get logLine => 'setVoice rejected "$voiceName" (returned != 1)';
}

final class EngineRejected extends SpeakFailure {
  const EngineRejected(super.spokenText, {required this.code});

  final Object? code;

  @override
  String get logLine => 'engine rejected speak(), code=$code';
}

final class EngineTimedOut extends SpeakFailure {
  const EngineTimedOut(super.spokenText, {required this.waited});

  final Duration waited;

  @override
  String get logLine => 'engine timed out after ${waited.inMilliseconds}ms';
}
```

**Be precise about what this buys you.** A non-exhaustive switch over a sealed
type is a **compile error** (`non_exhaustive_switch_statement` is
`type: compileTimeError` in the analyzer's `messages.yaml` — widespread claims
that it's a warning are wrong; don't let a reviewer talk you out of this). But
exhaustiveness forces a *branch*, not an *action*, and does **not** force the
caller to switch at all: `await speak(text);` discarding the outcome compiles
clean.

To close that second hole, annotate with `@useResult` from `package:meta` and
promote `unused_result` to `error` in `analysis_options.yaml`. The honest
guarantee is *"compile-error on new variants + analyzer-error on discarded
outcomes"* — not "silence is impossible."

And nothing in the type system detects `setVoice` returning 0. **You hand-write
that check.** The sealed type only guarantees the failure *propagates* once
detected. The detection gap is the actual root cause.

```dart
// lib/speech/speech_service.dart
import 'package:meta/meta.dart';

import 'speak_outcome.dart';
import 'voice.dart';

abstract interface class SpeechService {
  @useResult
  Future<SpeakOutcome> speak(String text);

  Future<void> stop();

  /// Already filtered: network_required and notInstalled voices never appear.
  Future<List<Voice>> voices();
}
```

### 4.2 The fake — and why not a mock

Use a hand-written fake. **Not** because mocks "silently absorb" interface
changes — that's overstated: mocktail throws a `TypeError` on an un-stubbed
`Future`-returning method, and its own `Fake` class uses `noSuchMethod` too. The
real reasons:

1. `implements` **without** a `noSuchMethod` superclass means adding a method to
   `SpeechService` **breaks the build**, not a runtime assertion.
2. The risk here isn't *"was `speak()` called"* — it's *"what happens when the
   voice vanished / `setVoice` returned 0."* Those are **state**. A fake models
   state naturally where a mock needs `when` + side-effect gymnastics.
3. The fake **is** the executable documentation of the contract for whoever
   inherits this repo.

This is also what [Flutter's own architecture docs demonstrate][fake-docs]: a
bare-`implements` fake for your own services, `package:mocktail` reserved for
external dependencies. Both packages are alive (mocktail 1.0.5, publisher
`felangel.dev`; mockito 5.7.0, publisher `dart.dev`) — mocktail wins here only
because it needs no `build_runner` step.

[fake-docs]: https://docs.flutter.dev/app-architecture/case-study/testing

```dart
// test/support/fake_speech_service.dart
import 'package:offline_aac/speech/speak_outcome.dart';
import 'package:offline_aac/speech/speech_service.dart';
import 'package:offline_aac/speech/voice.dart';

/// Every way the world breaks, as a value.
enum SpeechEnv {
  healthy,
  noEngineInstalled,
  zeroVoices,
  onlyNetworkVoices,
  onlyNotInstalledVoices,
  setVoiceReturnsZero,
  storedVoiceUninstalled,
  speakReturnsZero,
  engineTimesOut,

  /// The engine returns 1 and NO AUDIO COMES OUT.
  ///
  /// There is no Dart-side signal for this. It is excluded from the silence
  /// loop below because no test can assert it — it is a manual device check,
  /// permanently. That single exclusion is the entire argument for
  /// docs/CHECKLIST.md.
  reportedSuccessButSilent;

  /// The environments the app can actually detect, and must therefore handle.
  static Iterable<SpeechEnv> get detectable =>
      values.where((SpeechEnv e) => e != SpeechEnv.reportedSuccessButSilent);
}

class FakeSpeechService implements SpeechService {
  FakeSpeechService({this.env = SpeechEnv.healthy});

  SpeechEnv env;

  /// Recording => this is also a spy. Assert on WHAT was spoken.
  final List<String> spoken = <String>[];
  final List<String> calls = <String>[];

  static const Voice _local = Voice(
    name: 'en-us-x-local',
    locale: 'en-US',
    networkRequired: false,
    features: <String>{},
  );

  @override
  Future<List<Voice>> voices() async {
    calls.add('voices');
    switch (env) {
      // voice_filter has already run by the time voices reach us, so the
      // network-required and notInstalled worlds present as "no usable voice" —
      // which is exactly the state the UI must handle.
      case SpeechEnv.noEngineInstalled:
      case SpeechEnv.zeroVoices:
      case SpeechEnv.onlyNetworkVoices:
      case SpeechEnv.onlyNotInstalledVoices:
        return const <Voice>[];
      default:
        return const <Voice>[_local];
    }
  }

  @override
  Future<SpeakOutcome> speak(String text) async {
    calls.add('speak');
    switch (env) {
      case SpeechEnv.healthy:
        spoken.add(text);
        return const SpokeAloud();
      case SpeechEnv.reportedSuccessButSilent:
        return const SpokeAloud(); // we believe we spoke. we did not.
      case SpeechEnv.noEngineInstalled:
      case SpeechEnv.zeroVoices:
      case SpeechEnv.onlyNetworkVoices:
      case SpeechEnv.onlyNotInstalledVoices:
        return NoVoiceSelected(text);
      case SpeechEnv.setVoiceReturnsZero:
      case SpeechEnv.storedVoiceUninstalled:
        return VoiceUnavailable(text, voiceName: _local.name);
      case SpeechEnv.speakReturnsZero:
        return EngineRejected(text, code: 0);
      case SpeechEnv.engineTimesOut:
        return EngineTimedOut(text, waited: const Duration(seconds: 8));
    }
  }

  @override
  Future<void> stop() async => calls.add('stop');
}
```

### 4.3 The seam that closes the lint hole

```dart
// lib/speech/speech_controller.dart
import 'dart:async';

import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:offline_aac/speech/speak_outcome.dart';
import 'package:offline_aac/speech/speech_service.dart';

/// [speakNow] returns void ON PURPOSE.
///
/// `onTap: () => service.speak(p)` is caught by NO lint. Verified empirically:
/// the arrow closure "returns" the Future, so `discarded_futures` considers it
/// handled — but the target type is VoidCallback, so the Future and its error
/// are dropped. That is the most idiomatic way to wire a tile in Flutter, and
/// it is exactly this app's silence bug.
///
/// A void-returning seam makes the hole unreachable BY CONSTRUCTION: the
/// callback never holds a Future, so there is nothing to drop. Do not "fix"
/// this into `Future<void>`.
class SpeechController {
  SpeechController(this._service, this._log, this._showText);

  final SpeechService _service;
  final CrashLog _log;
  final void Function(String text) _showText;

  void speakNow(String phrase) {
    unawaited(
      _speak(phrase).catchError((Object e, StackTrace s) {
        // _speak is total, but stop() and the log can still throw. An uncaught
        // error here goes to PlatformDispatcher.onError and the user sees
        // nothing — the exact bug this class exists to prevent.
        _log.record('speakNow threw: $e', s);
        _showText(phrase);
      }),
    );
  }

  Future<void> _speak(String phrase) async {
    // Barge-in. A re-tap means "say it again" / "I need this NOW". This is why
    // speak is NOT wrapped in the Command pattern, whose `if (_running) return`
    // would silently swallow the tap and produce the silence we forbid.
    await _service.stop();

    final SpeakOutcome outcome = await _service.speak(phrase);

    // No `default:`, no `case _:`. Adding a SpeakFailure variant this cannot
    // handle must break the build.
    switch (outcome) {
      case SpokeAloud():
        return;
      case SpeakFailure(:final String spokenText, :final String logLine):
        _log.record('speak failed: $logLine', StackTrace.current);
        _showText(spokenText); // every failure resolves the same way
    }
  }
}
```

### 4.4 THE test

```dart
// test/speech/silence_is_impossible_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_speech_service.dart';
import '../support/harness.dart';

const String _kVocalization = "I need to leave, I'm not able to talk right now";

void main() {
  for (final SpeechEnv env in SpeechEnv.detectable) {
    testWidgets('$env: a tile tap yields speech OR visible text, never neither',
        (WidgetTester tester) async {
      final FakeSpeechService speech = FakeSpeechService(env: env);
      tester.useDevice(Device.small);
      await tester.pumpApp(speech: speech);

      await tester.tap(find.bySemanticsLabel('Overwhelmed'));
      await tester.pump();

      final bool spoke = speech.spoken.isNotEmpty;
      final bool showedFallback =
          find.text(_kVocalization).evaluate().isNotEmpty;

      expect(
        spoke || showedFallback,
        isTrue,
        reason: 'SILENT FAILURE under $env. A user tapped a tile mid-shutdown '
            'and got neither speech nor the phrase on screen. Nobody will ever '
            'report this to you.',
      );
      expect(tester.takeException(), isNull,
          reason: 'the failure must be handled, not thrown');
    });
  }
}
```

**This is the highest-value test in the app**, and the reason is structural: it
is the only test in the suite that is **unsatisfiable by a code path that fails
silently**. Every other test asserts a specific behaviour; this one asserts the
absence of a whole failure class. Adding a value to `SpeechEnv` forces the UI to
handle it or the build goes red — which turns *"I thought of a new way it can go
silent"* into a compiler-adjacent obligation rather than a backlog note.

The `reportedSuccessButSilent` exclusion is the honest part. Read it as the
justification for §11.

### 4.5 Barge-in ordering

```dart
testWidgets('a second tap stops the first utterance before speaking',
    (WidgetTester tester) async {
  final FakeSpeechService speech = FakeSpeechService();
  await tester.pumpApp(speech: speech);

  await tester.tap(find.bySemanticsLabel('Overwhelmed'));
  await tester.pump();
  await tester.tap(find.bySemanticsLabel('Yes'));
  await tester.pump();

  expect(speech.calls, <String>['stop', 'speak', 'stop', 'speak']);
});
```

### 4.6 `voice_filter` — the four wire-format traps

All four confirmed in plugin source. **Any one of them silently inverts the
safety property.**

```dart
// lib/speech/voice_filter.dart
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

```dart
// test/speech/voice_filter_test.dart — fixtures encode the ACTUAL wire format.
Map<Object?, Object?> androidVoice(
  String name,
  String locale, {
  bool network = false,
  List<String> features = const <String>[],
}) =>
    <Object?, Object?>{
      'name': name,
      'locale': locale,
      'quality': 'normal',
      'network_required': network ? '1' : '0', // STRING
      'features': features.join('\t'), // TAB
    };

Map<Object?, Object?> iosVoice(String name, String locale) => <Object?, Object?>{
      'name': name,
      'locale': locale,
      'quality': 'default',
      // NO network_required key at all.
    };

void main() {
  test('android "0" network_required is NOT truthy', () {
    expect(offlineSafeVoices(<Object?>[androidVoice('v', 'en-US')]), hasLength(1));
  });

  test('iOS voice with no network_required key defaults to offline-safe', () {
    expect(offlineSafeVoices(<Object?>[iosVoice('Samantha', 'en-US')]),
        hasLength(1));
  });

  test('a notInstalled voice is NOT offline-safe even though not network', () {
    // setVoice would return 1 for this voice, and it would STILL not speak.
    final List<Voice> safe = offlineSafeVoices(<Object?>[
      androidVoice('half-downloaded', 'en-GB',
          features: <String>[kFeatureNotInstalled]),
    ]);
    expect(safe, isEmpty);
  });

  test('null from a failed getVoices yields empty, not a crash', () {
    expect(offlineSafeVoices(null), isEmpty);
  });

  test('THE SAFETY PROPERTY: no returned voice ever needs the network', () {
    final List<Object?> raw = <Object?>[
      for (int i = 0; i < 50; i++)
        androidVoice('v$i', 'en-US',
            network: i.isEven,
            features: i % 3 == 0
                ? <String>[kFeatureNotInstalled]
                : const <String>[]),
    ];
    final List<Voice> safe = offlineSafeVoices(raw);
    expect(safe, isNotEmpty);
    expect(
      safe.every((Voice v) =>
          !v.networkRequired && !v.features.contains(kFeatureNotInstalled)),
      isTrue,
    );
  });
}
```

---

## 5. Widget tests

**Finder rule.** Use `find.bySemanticsLabel` for *behaviour* (tap, speak) — it
names behaviour, not tree structure, so it survives layout refactors and can
genuinely be written first. Use `ValueKey('slot_r_c')` for *geometry* — you are
asserting position, and position IS the primary key. Never `find.byType` for a
tile.

### 5.1 The core semantic

```dart
testWidgets('tapping a tile speaks the VOCALIZATION, never the label',
    (WidgetTester tester) async {
  final FakeSpeechService speech = FakeSpeechService();
  await tester.pumpApp(speech: speech);

  await tester.tap(find.bySemanticsLabel('Overwhelmed'));
  await tester.pump();

  // The tile SHOWS "Overwhelmed" and must SAY the whole sentence.
  expect(find.text('Overwhelmed'), findsOneWidget);
  expect(speech.spoken, <String>[_kVocalization]);
});
```

Swapping these two `String`s is a silent, plausible-looking regression that no
type checker catches — and that no user will report, because they cannot speak.

### 5.2 Overflow: it already fails, so don't break it

**A `RenderFlex` overflow FAILS a widget test by default.** It is not merely
logged. `DebugOverflowIndicatorMixin._reportOverflow` calls
`FlutterError.reportError`; `TestWidgetsFlutterBinding` captures it into
`_pendingExceptionDetails` and `testWidgets` rethrows at test end unless
`takeException()` clears it. The entire blog genre on this topic is about how to
**suppress** overflow failures.

So the rule is inverted from what you'd expect:

> **Never call `takeException()` to swallow, and never set `FlutterError.onError`,
> in a layout test.** The popular `ignoreOverflowErrors` helper is exactly how
> you lose this net.

Three traps that make an overflow suite pass while checking nothing:

1. **The 800×600 default surface** (§3). Pin a real device.
2. **Overflow is reported ONCE per RenderObject.** `_overflowReportNeeded` is
   set false after the first report and reset only on `reassemble()`. Looping
   scales inside one `testWidgets` silently under-reports scales 2..n.
   → **Generate one `testWidgets` per tuple.**
3. **It only reports if the widget PAINTS.** `Offstage` and content scrolled
   outside a viewport never report. (Clipped content *does* still report —
   `RenderFlex` calls `paintOverflowIndicator` after pushing its own clip.) The
   fixed grid is fine, but **show-text mode and edit mode need their own pumped
   tests** — they will not be covered by a board test.

```dart
// test/ui/overflow_matrix_test.dart
void main() {
  // TextScaler.linear is a deliberate OVER-approximation: Android 14+ scales
  // large text LESS than small text, so linear stresses our big tile labels
  // harder than a real device would. That is the conservatism we want — but do
  // not claim these tests are device-faithful. 1.3/1.5 are here precisely
  // because nonlinear scaling makes the mid-range non-obvious.
  const List<double> scales = <double>[1.0, 1.3, 1.5, 2.0, 3.0];

  for (final Device device in Device.all) {
    for (final double scale in scales) {
      for (final bool bold in <bool>[false, true]) {
        testWidgets('board: no overflow @ $device x$scale${bold ? ' bold' : ''}',
            (WidgetTester tester) async {
          tester.useDevice(device);
          await tester.pumpApp(
            textScaler: TextScaler.linear(scale),
            boldText: bold,
          );

          // Not strictly required — the binding rethrows at test end. Explicit
          // for a better message, and to document that suppression is banned.
          expect(tester.takeException(), isNull,
              reason: 'tile text overflowed at $device x$scale');
        });
      }
    }
  }
}
```

`boldText` is a first-class axis, not an afterthought: it widens glyphs and can
overflow a tile that passes unbolded at the same scale.

### 5.3 The grid invariant — this replaces goldens

```dart
testWidgets('the grid keeps 12 slots in fixed positions at 200%',
    (WidgetTester tester) async {
  tester.useDevice(Device.seLike);
  await tester.pumpApp(textScaler: const TextScaler.linear(2.0));

  Rect slot(int r, int c) => tester.getRect(find.byKey(ValueKey<String>('slot_${r}_$c')));

  // Position IS the primary key. Tiles in a row share a top edge; tiles in a
  // column share a left edge. This mirrors PRIMARY KEY (board_id, row, col) at
  // the UI layer — reflow must be structurally impossible here too.
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 3; c++) {
      expect(slot(r, c).top, moreOrLessEquals(slot(r, 0).top, epsilon: 0.5),
          reason: 'row $r reflowed at col $c');
      expect(slot(r, c).left, moreOrLessEquals(slot(0, c).left, epsilon: 0.5),
          reason: 'col $c reflowed at row $r');
    }
  }
});

testWidgets('an empty slot still occupies its cell', (WidgetTester tester) async {
  tester.useDevice(Device.small);
  // grid_slots.button_id is NULLABLE. An empty cell must hold its space, never
  // collapse and pull the next tile into its position.
  await tester.pumpApp(overrides: <Override>[emptySlotAt(1, 1)]);

  expect(tester.getRect(find.byKey(const ValueKey<String>('slot_1_1'))).width,
      greaterThan(0));
});
```

> ⚠️ **Unresolved, decide before v1.** These tests hard-code 12 slots and 3×4.
> The schema carries `boards.grid_rows` / `boards.grid_cols`, settings carries a
> grid-size key, and the design docs call for a 2×3 crisis layout. A
> `CHECK (row_index < 4 AND col_index < 3)` constraint would make 2×3 a
> **database-level insert failure** — inside the primary key's own table. Pick
> one before there is user data, because the alternative is a v2 migration on
> the PK.

---

## 6. Accessibility

An inaccessible accessibility app is a total failure. And there is **no lint for
any of this** — `flutter_lints` and `very_good_analysis` ship zero a11y rules,
the one free candidate (`accessibility_lint`) is abandoned (0 likes, 183
downloads, 19 months stale, built on the deprecating `custom_lint`), and the
credible rules live in commercial DCM, which a stranger cannot run.

So the accessibility promise is enforced in `test/` or it is enforced by
discipline — and discipline is what the no-telemetry constraint says cannot be
relied on.

### 6.1 Three uncomfortable truths about `meetsGuideline`

`meetsGuideline` is what everyone reaches for to say "we test accessibility." On
this app's geometry it is close to a no-op.

**(a) `MinimumTapTargetGuideline` silently skips every tile touching the view
edge.** From `packages/flutter_test/lib/src/accessibility.dart`:
`if (_isAtBoundary(paintBounds, viewRect)) { return result; }` — with a gap
threshold of 0.001 on all four sides. **On a full-bleed 3×4 grid, the 10
perimeter tiles are skipped and only the 2 interior tiles are measured.** The
test goes green while checking almost nothing.

**(b) `textContrastGuideline` has an open, unfixed false negative.**
[flutter#103235][103235]: white text (`0xffffff`) on `0xfafafa` **PASSES**. It
screenshots the layer and picks foreground/background from a colour histogram,
mis-attributing background in low-variance regions. It also only sees text
findable via `find.text` — a `CustomPainter` label is invisible to it.

**(c) `labeledTapTargetGuideline` only checks the label is non-empty.**
`button1` passes. A tile leaking its whole vocalization passes.

Four green `expectLater`s buy roughly **one** real property while producing a
strong false sense that accessibility is tested. Keep them — one line each, they
catch catastrophic regressions — but **they are not the gate.**

[103235]: https://github.com/flutter/flutter/issues/103235

### 6.2 A correction on `ensureSemantics`

The official docs example is:

```dart
final SemanticsHandle handle = tester.ensureSemantics();
// ...
handle.dispose();
```

That code is correct and current, but **the usual explanation for it is wrong**.
Semantics is **ON by default** in widget tests: `testWidgets` takes
`bool semanticsEnabled = true`, and when true the framework calls
`ensureSemantics()` for you and auto-disposes the handle. The manual pair is a
redundant second reference-counted handle — harmless, optional.

It is only load-bearing with `semanticsEnabled: false`, or in a plain `test()`.
If you do use it, use `addTearDown(handle.dispose)` — it survives a throwing
`expect()`, where a trailing `handle.dispose()` does not, and a leaked
`SemanticsHandle` is itself a flake source.

`meetsGuideline` returns an `AsyncMatcher`, so **`await expectLater(...)` is
mandatory** — a plain `expect()` is wrong.

### 6.3 The tests that are actually the gate

```dart
// test/ui/a11y_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';
import '../support/tiles.dart'; // kTestTiles: the 12 (row, col, label, vocalization)

/// MinimumTapTargetGuideline has a PUBLIC const constructor and is
/// @visibleForTesting, so instantiating it in test/ is the sanctioned path —
/// no subclass needed, no lint. It inherits the boundary-skip flaw, which is
/// exactly why the geometry test below is the real gate.
const AccessibilityGuideline aacTapTargetGuideline = MinimumTapTargetGuideline(
  size: Size(76, 76), // logical px: the source divides by devicePixelRatio
  link: 'https://github.com/you/offline-aac/blob/main/docs/CHECKLIST.md',
);

void main() {
  // (1) GEOMETRY — the real gate. Deliberately NOT meetsGuideline: it skips
  //     every tile flush with the view edge, i.e. 10 of our 12.
  testWidgets('every tile is >= 76x76 dp at 200% on the smallest phone',
      (WidgetTester tester) async {
    tester.useDevice(Device.seLike);
    await tester.pumpApp(textScaler: const TextScaler.linear(2.0));

    for (final TestTile t in kTestTiles) {
      final Size size =
          tester.getSize(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')));
      expect(size.width, greaterThanOrEqualTo(76.0),
          reason: '"${t.label}" is ${size.width}dp wide; minimum is 76dp');
      expect(size.height, greaterThanOrEqualTo(76.0),
          reason: '"${t.label}" is ${size.height}dp tall; minimum is 76dp');
    }
  });

  // (2) LABEL CORRECTNESS — the check NO guideline makes.
  testWidgets('every tile announces its DISPLAY label, never its vocalization',
      (WidgetTester tester) async {
    await tester.pumpApp();

    for (final TestTile t in kTestTiles) {
      final SemanticsNode node =
          tester.getSemantics(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')));

      // isSemantics — NOT containsSemantics, which is deprecated after
      // v3.40.0-1.0.pre. Virtually every tutorial predates this.
      expect(
        node,
        isSemantics(
          label: t.label,
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );

      expect(
        node.label,
        isNot(contains(t.vocalization)),
        reason: 'tile "${t.label}" leaks its vocalization into the semantic '
            'label; a screen reader user would hear the whole sentence on '
            'every scan step',
      );
    }
  });

  // (3) TRAVERSAL ORDER.
  testWidgets('the screen reader visits the 12 tiles row-major',
      (WidgetTester tester) async {
    await tester.pumpApp();

    // start:/end: are DEPRECATED after v3.15.0-15.2.pre. Use startNode:/endNode:,
    // which take FinderBase<SemanticsNode> — hence find.semantics.byLabel.
    final Iterable<SemanticsNode> ordered =
        tester.semantics.simulatedAccessibilityTraversal(
      startNode: find.semantics.byLabel('Overwhelmed'),
      endNode: find.semantics.byLabel('Write'),
    );

    expect(
      ordered.map((SemanticsNode n) => n.label).toList(),
      kTestTiles.map((TestTile t) => t.label).toList(),
      reason: 'Tile traversal order changed. This rewires muscle memory for '
          'people who cannot correct it verbally.',
    );
  });

  // (4) ANTI-CLAMP. No guideline catches this: contrast and tap-target both
  //     still pass while the text stops growing.
  testWidgets('text scale is honored, never clamped', (WidgetTester tester) async {
    tester.useDevice(Device.small);

    await tester.pumpApp();
    final double base = tester.getSize(find.text('Overwhelmed')).height;

    await tester.pumpApp(textScaler: const TextScaler.linear(2.0));
    final double scaled = tester.getSize(find.text('Overwhelmed')).height;

    // 1.8, not 2.0: tolerate line-height rounding, still fail hard on a clamp.
    expect(scaled, greaterThan(base * 1.8),
        reason: 'Text did not grow at 2.0x. Someone clamped TextScaler to keep '
            'the fixed grid tidy. 200%+ must be honored.');
  });

  // (5) ADVISORY. Cheap tripwire. Never the gate.
  testWidgets('meets built-in guidelines (advisory)', (WidgetTester tester) async {
    tester.useDevice(Device.seLike);
    await tester.pumpApp(
      textScaler: const TextScaler.linear(2.0),
      accessibleNavigation: true, // Switch Access / VoiceOver on
    );

    // Thresholds, read from flutter_test/lib/src/accessibility.dart:
    //   androidTapTargetGuideline = Size(48, 48)
    //   iOSTapTargetGuideline     = Size(44, 44)
    // Both skip edge-flush nodes — see (1).
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(aacTapTargetGuideline));
  });
}
```

### 6.4 Contrast: a pure-Dart unit test, because the guideline false-passes

```dart
// test/ui/contrast_test.dart
import 'dart:ui';

import 'package:test/test.dart';

double contrastRatio(Color fg, Color bg) {
  final double l1 = fg.computeLuminance();
  final double l2 = bg.computeLuminance();
  final double hi = l1 > l2 ? l1 : l2;
  final double lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // Flutter's own constants: 4.5 normal / 3.0 large; large = 18px, or 14px bold.
  // AAA is 7.0 / 4.5 — defensible for an app used in distress and low light.
  // MinimumTextContrastGuidelineAAA exists in flutter_test and is one line, but
  // it inherits the #103235 sampling defect. This does not: no screenshots, no
  // histogram, cannot false-pass.
  for (final AacTheme theme in kAllThemes) {
    test('${theme.name}: tile label on tile background meets WCAG AAA', () {
      expect(contrastRatio(theme.tileLabel, theme.tileBackground),
          greaterThanOrEqualTo(7.0));
    });

    test('${theme.name}: show-text mode meets WCAG AAA for large text', () {
      expect(contrastRatio(theme.showText, theme.showTextBackground),
          greaterThanOrEqualTo(4.5));
    });
  }
}
```

### 6.5 What automation genuinely cannot cover

Deque's much-quoted **57%** figure is for [axe-core's ~100 web rules][deque].
Flutter ships **four** guidelines — roughly the trivially machine-checkable
subset — and one of them is known-broken. Realistic expectation: a small
minority of real issues.

**Switch Access / Switch Control cannot be tested automatically at all.** Flutter
publishes no support statement, and no API simulates scanning, group selection,
or point scanning. Traversal order is the only proxy, and it is a *weak* one:
Point Scan is coordinate-based (no order at all), Group Selection is a nested
binary narrowing, and scanning targets *actionable* elements while semantics
traversal enumerates non-actionable nodes too. Pair the traversal test with a
`Tab`-key `FocusTraversalPolicy` test if you like, but treat both as regression
guards on *intent*, never as conformance evidence.

Also useless here, so don't build it:

- **Espresso `AccessibilityChecks`** walks the Android **View** hierarchy.
  Flutter is one opaque `FlutterView`. It finds nothing.
- **CI a11y automation via `flutter drive`.** [flutter#111110][111110]: the
  semantics tree isn't exposed to the platform during `flutter drive` unless an
  accessibility service is already running. The workaround is force-enabling one
  via `adb settings put secure`. Not worth a day of a two-week MVP.

**Google's Accessibility Scanner DOES work** — it's an `AccessibilityService`
and reads Flutter's `AccessibilityBridge` virtual node tree. But it is manual,
on-device, human-driven. It goes in the checklist, not CI.

[deque]: https://www.deque.com/blog/automated-testing-study-identifies-57-percent-of-digital-accessibility-issues/
[111110]: https://github.com/flutter/flutter/issues/111110

---

## 7. Migration tests: the phrases, not the schema

### 7.1 The gap nobody mentions

> **`migrateAndValidate` extracts `CREATE` statements from `sqlite_schema` and
> compares them to a reference built by `Migrator.createAll`. It is a SHAPE
> comparison. It does not look at rows.**

A migration that rebuilds `grid_slots` perfectly and copies **zero rows** passes
it, green. For an app where hand-curated boards are irreplaceable and
unmergeable, that is the test that gives you false confidence about the one thing
that must not break.

### 7.2 Setup — do this at commit #1, before there is data to lose

```yaml
# build.yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/data/database/app_database.dart
          test_dir: test/drift/
          schema_dir: drift_schemas/
```

```bash
# Export the schema for the CURRENT schemaVersion. Re-run on EVERY version bump.
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/

# --data-classes --companions is the load-bearing part: it emits DatabaseAtV1 /
# DatabaseAtV2 classes with era-correct data classes, which is what lets a test
# WRITE rows at v1 and READ them at v2.
dart run drift_dev schema generate --data-classes --companions \
  drift_schemas/ test/drift/generated/

# Step-by-step migration helpers, so each callback gets a schema FROZEN at its
# version. Old migrations keep compiling after you delete a table in v4 — which
# matters most precisely when the developer has stopped paying attention.
dart run drift_dev schema steps drift_schemas/ lib/data/database/schema_versions.dart
```

<!-- VERIFY: newer drift_dev consolidates all three behind `dart run drift_dev
     make-migrations`, driven by the build.yaml above. Confirmed as the
     recommended workflow in drift's docs; not independently verified on 2.34.x.
     The three explicit commands above are verified and work on 2.31+. -->

**Commit `drift_schemas/`.** Not because the history is otherwise unrecoverable
— it isn't; `schema dump` reads the Dart source, so you can check out the tag and
regenerate. Commit it because it makes schema deltas a **reviewable diff** and
removes a git-archaeology step from every future migration.

**CI gate.** This catches the bug that loses boards without touching a line of
migration code:

```bash
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
if ! git diff --exit-code -- drift_schemas/; then
  echo "::error::You changed the schema without bumping schemaVersion + dumping."
  echo "::error::Shipping this means NO MIGRATION RUNS and users lose their boards."
  exit 1
fi
```

### 7.3 The test that actually matters

```dart
// test/drift/migration_test.dart
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';

import 'package:offline_aac/data/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// A hostile, realistic board. NOT "test1"/"test2" — those survive everything.
const List<(String, String)> _torture = <(String, String)>[
  ('Overwhelmed', "I need to leave, I'm not able to talk right now"), // apostrophe
  ('Nej', 'Nej tack — jag kan inte prata just nu'), // non-ASCII + em dash
  ('🚻', 'I need the toilet'), // emoji label
  ('Quote', 'She said "no" — and I agree; see: a\\b'), // quotes + backslash
  ('Blank-ish', ' '), // whitespace-only
];

void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // Shape, EVERY hop — not just adjacent steps. The user who ignored updates
  // for six months goes v1 -> v3 directly: the untested path. With no telemetry
  // their boards vanish and you never find out; they just uninstall.
  // Necessary. NOT sufficient.
  group('schema shape', () {
    for (int from = 1; from < kLatestSchemaVersion; from++) {
      for (int to = from + 1; to <= kLatestSchemaVersion; to++) {
        test('v$from -> v$to', () async {
          final DatabaseConnection connection = await verifier.startAt(from);
          final AppDatabase db = AppDatabase(connection);
          await verifier.migrateAndValidate(db, to);
          await db.close();
        });
      }
    }
  });

  test('v1 -> v2 preserves every phrase, byte for byte, in place', () async {
    final InitializedSchema schema = await verifier.schemaAt(1);

    // --- Write real user data with v1-era classes -------------------------
    // schema.newConnection() may be called repeatedly against the SAME bytes,
    // which is what lets three different-era database objects see one database.
    final v1.DatabaseAtV1 old = v1.DatabaseAtV1(schema.newConnection());
    final int boardId =
        await old.into(old.boards).insert(v1.BoardsCompanion.insert(name: 'Home'));

    for (int i = 0; i < _torture.length; i++) {
      final (String label, String vocalization) = _torture[i];
      final int buttonId = await old.into(old.buttons).insert(
            v1.ButtonsCompanion.insert(
              label: label,
              vocalization: Value<String>(vocalization),
            ),
          );
      await old.into(old.gridSlots).insert(
            v1.GridSlotsCompanion.insert(
              boardId: boardId,
              rowIndex: i ~/ 3,
              colIndex: i % 3,
              buttonId: Value<int>(buttonId),
            ),
          );
    }
    // An EMPTY slot must survive as an empty slot — not vanish, not collapse,
    // not pull the next tile into its position.
    await old.into(old.gridSlots).insert(
          v1.GridSlotsCompanion.insert(boardId: boardId, rowIndex: 3, colIndex: 2),
        );
    await old.close();

    // --- Run the REAL migration against that data -------------------------
    final AppDatabase db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2); // shape only

    // Prove we did not corrupt referential integrity while FKs were off during
    // the migration. A dangling board_id is a lost board.
    final List<QueryRow> violations =
        await db.customSelect('PRAGMA foreign_key_check').get();
    expect(violations, isEmpty,
        reason: 'migration left FK violations: '
            '${violations.map((QueryRow r) => r.data).toList()}');
    await db.close();

    // --- Read back with v2-era classes and assert CONTENT ------------------
    final v2.DatabaseAtV2 now = v2.DatabaseAtV2(schema.newConnection());
    final List<v2.Button> buttons = await now.select(now.buttons).get();
    final List<v2.GridSlot> slots = await now.select(now.gridSlots).get();

    expect(slots, hasLength(_torture.length + 1), reason: 'a slot disappeared');
    expect(slots.where((v2.GridSlot s) => s.buttonId == null), hasLength(1),
        reason: 'the empty slot must survive as an empty slot');

    for (int i = 0; i < _torture.length; i++) {
      final (String label, String vocalization) = _torture[i];
      final v2.GridSlot slot = slots.firstWhere(
          (v2.GridSlot s) => s.rowIndex == i ~/ 3 && s.colIndex == i % 3);
      final v2.Button button =
          buttons.firstWhere((v2.Button b) => b.id == slot.buttonId);

      expect(button.label, label);
      expect(
        button.vocalization,
        vocalization,
        reason: 'The vocalization is the whole point. Losing it is losing '
            'speech. Truncation, re-encoding and quote-mangling all land here.',
      );
    }
    await now.close();
  });
}
```

The torture fixture is doing real work. Apostrophes, em dashes, emoji, quotes and
backslashes are where a `columnTransformer` expression or a hand-rolled
`INSERT ... SELECT` silently mangles someone's sentence — and a mangled sentence
passes every shape check.

### 7.4 The thing that beats every migration test

```dart
/// Copy the .sqlite file to board_backup_v{oldVersion}.sqlite immediately BEFORE
/// onUpgrade runs. Keep the last two. Expose "Restore previous board" in
/// settings.
///
/// ~15 lines. The highest safety-per-line item in the project, and it is not a
/// test at all. Migration tests protect against bugs you enumerated; the backup
/// protects against the migration bug you did NOT — which, with no telemetry, is
/// the entire category you cannot see.
```

They are complements, not substitutes. Then test the backup path itself — four
tests: backup happens strictly before `onUpgrade`; last-two retention; restore
round-trip; restore when the live DB is corrupt.

### 7.5 Database invariants — the architecture, executable

```dart
// test/drift/database_test.dart
late AppDatabase db;

setUp(() {
  // The REAL AppDatabase, so beforeOpen — and therefore FK enforcement —
  // applies. A bare connection would skip it and let FK-violating code pass
  // green. NativeDatabase.memory() is real sqlite3; it is not even a fake.
  db = AppDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      // REQUIRED. drift keeps an unsubscribed query stream open for one event
      // loop iteration, which never arrives under a widget test's FakeAsync
      // clock -> pending timers and state leaking into the next test.
      closeStreamsSynchronously: true,
    ),
  );
});
tearDown(() => db.close());

test('foreign keys are actually enforced', () async {
  final QueryRow row = await db.customSelect('PRAGMA foreign_keys').getSingle();
  expect(
    row.data.values.first,
    1,
    reason: 'FKs off => ON DELETE SET NULL silently does nothing => '
        'grid_slots.button_id dangles => blank tile, no error, no telemetry.',
  );
});

test('deleting a button empties its slot without moving any other tile', () async {
  final int id = await db.into(db.buttons).insert(
        ButtonsCompanion.insert(
          label: 'Overwhelmed',
          vocalization: const Value<String>(
              "I need to leave, I'm not able to talk right now"),
        ),
      );
  await (db.update(db.gridSlots)
        ..where((GridSlots s) => s.rowIndex.equals(2) & s.colIndex.equals(1)))
      .write(GridSlotsCompanion(buttonId: Value<int>(id)));

  await (db.delete(db.buttons)..where((Buttons b) => b.id.equals(id))).go();

  final List<GridSlot> slots = await db.select(db.gridSlots).get();
  expect(slots, hasLength(12), reason: 'the slot must survive its button');
  expect(
    slots.firstWhere((GridSlot s) => s.rowIndex == 2 && s.colIndex == 1).buttonId,
    isNull,
    reason: 'This is ON DELETE SET NULL working. If FKs were off it would still '
        'be $id — a dangling id pointing at nothing.',
  );
});

test('a slot cannot be occupied twice — reflow is structurally impossible',
    () async {
  // The 12 slots already exist from seeding; re-inserting (0,0) must fail on
  // the composite primary key.
  await expectLater(
    db.into(db.gridSlots).insert(
        GridSlotsCompanion.insert(boardId: 1, rowIndex: 0, colIndex: 0)),
    throwsA(isA<SqliteException>()),
  );
});
```

The FK test and the delete test are a **pair**: the delete test is the
behavioural consequence, the PRAGMA test tells you *why* it broke when it does.

Two migration mechanics worth encoding, because getting them wrong is silent:
`PRAGMA foreign_keys` **is a no-op inside a transaction** — it does not error, it
does nothing. So disable it *outside* the transaction in `onUpgrade`, run
`PRAGMA foreign_key_check` after, and re-enable **unconditionally in
`beforeOpen`** (the pragma is per-connection and must run on every open; seeding
is what belongs inside `if (details.wasCreated)`).

> **README requirement.** `flutter test` runs in a plain Dart VM —
> `sqlite3_flutter_libs` does **nothing** there. macOS has a system libsqlite3
> (older than the bundled one: real version-skew risk); Ubuntu needs
> `apt-get install -y libsqlite3-dev` **before** `flutter test`. A stranger who
> clones on Linux and sees every DB test fail concludes the repo is broken and
> walks away. That is the exit plan dying to a missing README line.

### 7.6 The substitute for unknown-unknowns

```dart
// test/drift/grid_invariant_test.dart
test('no sequence of edit ops ever reflows a tile', () async {
  for (int seed = 0; seed < 200; seed++) {
    final Random rng = Random(seed);
    final List<String> ops = <String>[];
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    final BoardRepository repo = BoardRepository(db);
    try {
      final Map<(int, int), int?> expected = <(int, int), int?>{};
      for (int i = 0; i < 30; i++) {
        final int r = rng.nextInt(4);
        final int c = rng.nextInt(3);
        if (rng.nextBool()) {
          final int b = rng.nextInt(5) + 1;
          ops.add('place($r,$c,btn$b)');
          await repo.placeButton(row: r, col: c, buttonId: b);
          expected[(r, c)] = b;
        } else {
          ops.add('clear($r,$c)');
          await repo.clearSlot(row: r, col: c);
          expected[(r, c)] = null;
        }

        final Map<(int, int), int?> slots = await repo.slotsFor(boardId: 1);
        for (final MapEntry<(int, int), int?> e in expected.entries) {
          expect(slots[e.key], e.value,
              reason: 'TILE REFLOWED at ${e.key}. seed=$seed ops=$ops');
        }
        expect(slots.length, 12, reason: 'seed=$seed ops=$ops');
      }
    } finally {
      await db.close();
    }
  }
});
```

This is the only technique that authors cases *you didn't write* — the actual
thing Crashlytics provided. You lose automatic shrinking; the printed op list
**is** the minimal repro you would have read anyway.

---

## 8. Policy tests: enforcing what no lint can

Ten lines each. They make the constraints unbreakable by a future contributor —
or by you at 2am, staring at a red overflow test.

### 8.1 No text clamping

```dart
// test/policy/no_text_clamping_test.dart
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('lib/ never clamps or overrides text scaling', () {
    const List<String> forbidden = <String>[
      'withClampedTextScaling', // clamps TextScaler — violates the a11y contract
      'textScaleFactor', // deprecated, and almost always a clamping hack
    ];

    final List<String> offenders = <String>[];
    for (final FileSystemEntity f
        in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final String src = f.readAsStringSync();
      for (final String bad in forbidden) {
        if (src.contains(bad)) offenders.add('${f.path}: $bad');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'TextScaler must be honored at 200%+ and never clamped.\n'
          'Fix the layout; do not clamp the text.\n${offenders.join('\n')}',
    );
  });
}
```

`MediaQuery.withClampedTextScaling` is the **one-line "fix" a future contributor
reaches for when the overflow matrix fails** — and it silently defeats the whole
matrix while contrast and tap-target still pass.

### 8.2 The manifest

```dart
// test/policy/android_manifest_test.dart
void main() {
  final String xml =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('TTS_SERVICE is declared in <queries>', () {
    expect(
      xml,
      contains('android.intent.action.TTS_SERVICE'),
      reason: 'Without this, Android 11+ package visibility HIDES the TTS '
          'engine. flutter_tts returns an empty voice list with only a Log.d. '
          'Every Android 11+ user gets a board that cannot speak, and you will '
          'never hear about it.',
    );
  });

  test('auto-backup is disabled', () {
    // android:allowBackup defaults to TRUE. Left alone, Android silently
    // uploads the SQLite database — including every vocalization, the most
    // intimate content the user owns — to Google Drive. The privacy label says
    // "no network, no server". The manifest would say otherwise, and this
    // audience checks.
    //
    // This is a genuine tension, not just a bug: auto-backup is also the only
    // thing that would save a user's board when they lose their phone. Resolve
    // it deliberately (an explicit user-initiated export), then pin it here.
    expect(xml, contains('android:allowBackup="false"'));
  });
}
```

### 8.3 Nothing animates

```dart
testWidgets('no widget schedules a second frame', (WidgetTester tester) async {
  await tester.pumpApp();

  for (final TestTile t in kTestTiles) {
    await tester.tap(find.bySemanticsLabel(t.label));
    await tester.pump();

    expect(tester.binding.hasScheduledFrame, isFalse,
        reason: 'Tapping "${t.label}" scheduled another frame => something '
            'animates.');
  }
});
```

**Honest scope:** this is a spot check, not proof. It misses `Timer`-driven
repaints and at-rest implicit animations, and it catches a stray `InkWell` only
on tiles you actually tap. And the remedy is bigger than the folklore:
`splashFactory: NoSplash.splashFactory` kills only the *splash* —
`InkResponse.updateHighlight()` independently creates an `InkHighlight` with a
200ms pressed fade. You must also set `overlayColor`/`highlightColor` to
transparent, or just use `GestureDetector`.

---

## 9. Channel tests and the QS tile

### 9.1 One channel test file. That's it.

**Do not mock the flutter_tts channel across the suite.** You already own the
`SpeechService` abstraction — fake that. Channel mocks couple 50 tests to the
plugin's private method-name strings and untyped payloads, so a plugin upgrade
breaks 50 tests for reasons unrelated to what they assert — and they still prove
nothing about audio.

The residual value is real but narrow: **one file that pins the plugin's actual
wire behaviour**, so an upgrade that changes it fails loudly. With no telemetry,
this is your only upgrade canary.

```dart
// test/native/tts_channel_contract_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:offline_aac/speech/voice_filter.dart';

void main() {
  // REQUIRED before touching TestDefaultBinaryMessengerBinding.instance in a
  // plain test(). testWidgets initializes the binding for you; test() does not.
  // Omit this and the FILE FAILS TO LOAD:
  //   "Binding has not yet been initialized."
  // Most blog snippets omit it.
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_tts');
  late TestDefaultBinaryMessenger messenger;

  setUp(() => messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger);
  // Un-torn-down handlers leak into subsequent tests — a classic
  // order-dependent flake.
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('setVoice returning 0 does NOT throw — it silently succeeds', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async => call.method == 'setVoice' ? 0 : null,
    );

    final Object? result = await channel.invokeMethod<dynamic>(
        'setVoice', <String, String>{'name': 'ghost', 'locale': 'en-US'});

    // The entire bug in one line: no exception, just a 0.
    expect(result, 0);
  });

  test('getVoices is untyped — the naive cast is a runtime crash', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async => <Object?>[
        <Object?, Object?>{'name': 'a', 'locale': 'en-US'},
      ],
    );

    final Object? raw = await channel.invokeMethod<dynamic>('getVoices');
    expect(() => (raw as List<Object?>).cast<Map<String, String>>().first,
        throwsA(isA<TypeError>()));
    expect(offlineSafeVoices(raw).single.name, 'a');
  });
}
```

### 9.2 The Quick Settings tile is a structural hole. Say so.

The QS `TileService` runs with **no Flutter engine** — that's the point, it's the
fastest path to speech in the product. It also means **no Flutter test of any
level can reach it.** This is the crisis path and it has zero Dart-side coverage.

And the obvious contract test **does not work**:

> `SharedPreferences.setMockInitialValues` is **in-memory only** — it "will not
> persist values to the usual preference store." A Dart test asserting *"edit a
> tile → the pref changed"* asserts **a fake mutated a fake**. It passes green
> while the Kotlin read path is broken, manufacturing false confidence in exactly
> the failure it claims to guard.

Two more landmines on this path, both verified against shared_preferences 2.5.5:

- The modern `SharedPreferencesAsync` is backed by **Jetpack DataStore**, not
  `FlutterSharedPreferences.xml`. Kotlin's `getSharedPreferences(...)` reads
  **nothing**.
- The legacy API prefixes every key with `flutter.` — native `getString("phrase")`
  returns null; the key is `flutter.phrase`.

**Mitigation, all three parts required:**

1. **Own the contract.** Don't couple the tile to a plugin's private storage
   format. Write an explicit **versioned JSON file** from Dart; read that file
   from Kotlin. One Dart file and one Kotlin object are the sole owners, and the
   key strings live in a doc comment on both sides.
2. **An `integration_test` round-trip** — write from Dart, read back through the
   *real* native path, assert exact equality. This is the only thing that catches
   renames, prefix errors, backend misconfiguration and encoding drift.
3. **Extract the logic out of `TileService`.** `onClick()` should be ~5 lines
   delegating to a plain Kotlin class (read → validate non-empty → speak) that
   plain JUnit tests with a fake TTS. No Robolectric: `TileService` is bound and
   lifecycled by SystemUI and has no first-class shadow, so testing the service
   shell is low-yield.

---

## 10. The crash log

It is the only line of sight into the field that will ever exist. That makes it
load-bearing infrastructure, not a nice-to-have. **Nobody tests their crash
logger.** Test this one harder than the tiles.

```dart
test('an error inside the logger does not re-enter the logger', () { /* ... */ });
test('a crash on the first frame still leaves a readable log', () { /* flushed */ });
test('the log is bounded and never fills the disk', () { /* size cap */ });
test('vocalization text is redacted before it hits the file', () { /* §2.4 #28 */ });
test('ProviderException is unwrapped to the real cause', () { /* ... */ });
test('export works when the app cannot fully start', () { /* ... */ });
```

The wiring, which contradicts a lot of circulating advice:

```dart
void main() async {
  // Same function body as runApp(): no zone, so no zone-mismatch warning and no
  // inconsistent zone-specific configuration.
  WidgetsFlutterBinding.ensureInitialized();
  final CrashLog log = await CrashLog.open();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log.record(details.exceptionAsString(), details.stack);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    try {
      log.record(error.toString(), stack);
      if (kDebugMode) debugPrint('$error\n$stack');
    } catch (_) {
      // never let the handler throw
    }
    return true;
  };

  runApp(const AacApp());
}
```

**No `runZonedGuarded`.** Flutter's [zone-errors breaking-change doc][zones] says
the fix for the zone-mismatch warning is to *remove zones from the application*,
and [the official error-handling page][errors] shows only these two handlers. The
"use all three" advice circulating in 2026 is **crash-SDK advice** — Sentry needs
a zone because it wraps its own init. You have no SDK, so the zone is pure
footgun.

**Return `true` always, not `kReleaseMode`.** [api.flutter.dev][pd-onerror]
explicitly warns that the `false` path routes through the embedder's
`unhandled_exception_callback` and "the VM or the process may exit or become
unresponsive." `kReleaseMode` buys debug visibility at the cost of the one
behaviour a crisis UI cannot tolerate — and buys it unnecessarily, since
`debugPrint` gives the same visibility for free.

The bare `catch (_)` inside `CrashLog.record` **deliberately violates** Effective
Dart's "DON'T discard errors" rule. **The comment explaining why is
load-bearing** — without it, someone "fixes" it into infinite recursion.

[zones]: https://docs.flutter.dev/release/breaking-changes/zone-errors
[errors]: https://docs.flutter.dev/testing/errors
[pd-onerror]: https://api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html

---

## 11. What is NOT worth testing

A solo dev has two weeks. Every item here is a "no", with the reason.

| Skip | Why |
|---|---|
| **A golden regression suite** | **Decided: no goldens for the MVP.** Everything a golden would catch here (text not fitting, tiles reflowing) is caught more cheaply, with a *readable failure message*, by the overflow matrix (§5.2) and the `getRect` invariants (§5.3). Goldens add binary blobs to git, churn on every padding tweak, and — decisively — **a stranger running `flutter test` on Linux against macOS-generated goldens sees a wall of red and concludes the repo is broken.** Goldens actively sabotage the open-source exit plan. |
| Golden *tooling* | If you ignore the above: `golden_toolkit` is **discontinued** (v0.15.0, ~3 years stale, no suggested replacement). `alchemist` (v0.14.0, Betterment + VGV, alive) sets `obscureText: true` for CI goldens — it achieves platform stability by **replacing text with coloured rectangles**, discarding the exact signal this app needs. `flutter_test_goldens` is at 0.0.12 with 11 likes. There is no good option. |
| `glados` / property-testing packages | v1.1.7, ~2 years stale. §7.6 is 20 lines of `package:test` and gets the 80%. |
| Riverpod plumbing | Explicitly acknowledged as **not load-bearing**. Testing providers tests the framework. |
| drift's generated CRUD | Third party. |
| flutter_tts itself | Test **your** `voice_filter`, not the plugin. |
| Patrol / Appium / any E2E | No accounts, no network, one screen, no runtime permission prompts. Patrol exists to tap native permission dialogs you don't have. |
| Firebase Test Lab / device farms | Farm devices run the same TTS-poor images. They cannot assert audio. One real phone strictly dominates. |
| CI a11y automation | flutter#111110 — the semantics tree isn't even exposed during `flutter drive` without a pre-enabled accessibility service. Days of work, near-zero signal. |
| A coverage **percentage** gate | §12. |
| Theme/settings UI beyond persist-and-reload | Triviality. |
| DevTools rebuild profiling, frame charts, `RepaintBoundary` | Every one of these is a **jank** remedy. A static 12-tile grid with zero animation renders one frame and stops. There is no frame budget to miss. This is the single largest category of wasted time available to this project. |

---

## 12. Coverage

**No percentage gate.** VGV's own stated rationale for 100% is confidence under
change, and the target is defensible for a consultancy — it removes subjective
arguments about what to exclude across a team. A solo dev collects none of that
benefit while paying the full cost against a two-week budget. And a gate a solo
dev sets on themselves gets bypassed or gamed.

**Gate the four files where a bug is unrecoverable, not a directory:**

| File | Floor | Why |
|---|---:|---|
| `lib/data/database/` migrations | 100% | A botched migration is the loss of someone's voice |
| `lib/speech/voice_filter.dart` | 100% | Pure; four wire traps; a gap here is silence |
| `lib/data/repositories/board_repository.dart` | 100% | The reflow guarantee |
| `lib/diagnostics/crash_log.dart` | 100% | The only field signal that will ever exist |

**Files, not directories** — and this matters. `lib/speech/` also contains the
flutter_tts wrapper, which cannot reach 100% while channel mocking is confined to
one file (§9.1). A directory floor there is jointly unsatisfiable with the
channel-mock rule; a file list is not.

**If you report coverage at all, fix the lie first.** `flutter test --coverage`
**omits files that no test imports** ([flutter#27997][27997]) — a file with zero
tests contributes zero lines to the *denominator* rather than counting as 0%. A
codebase with one well-tested file and twenty untested ones can report ~100%.
**The number lies upward**, which is the unsafe direction, and a coverage number
that overstates safety is worse than none in a project with no other net. Fix
with `dlcov --include-untested-files=true`, or a generated
`test/coverage_helper_test.dart` importing every `lib/` file.

Strip generated code — and check which your drift setup emits:

```bash
lcov --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.drift.dart' \
  -o coverage/lcov.info \
  --ignore-errors unused   # lcov 2.x (ubuntu-24.04) errors on unused patterns
```

---

## 13. The manual pre-release checklist

Commit this as `docs/CHECKLIST.md` and run it before every tag. **This is not a
chore and it is not a placeholder for tests you haven't written yet.** It is the
deliberate replacement for tests that cannot exist: the emulator has no TTS
engine, no API captures audio, and Switch Control has no automation at all.

Four of the highest-severity failures in this app are unreachable by every
automated means available in 2026: **`.ambient` muting on the silent switch**,
**engine reports success but emits no audio**, **the QS tile speaking a stale
phrase**, and **Switch Access focus traps**.

```markdown
# Pre-release checklist — PHYSICAL DEVICE, ringer switch OFF

Device: ______  OS: ______  Date: ______

## 1. Audio — guards the silent-failure class
- [ ] iPhone: HARDWARE SILENT SWITCH ON, tap a tile -> **AUDIO STILL PLAYS**
      (silent => audio session is .ambient, not .playback. Top-severity bug.)
- [ ] Music playing -> tile speech DUCKS it; music resumes after
- [ ] AIRPLANE MODE ON, tap every tile -> all speak
      (catches a network_required voice slipping past voice_filter)
- [ ] Settings > select EACH offered voice > tap a tile -> each ACTUALLY speaks
      (catches `notInstalled`: setVoice returns 1, audio is silent or wrong voice)
- [ ] Android: uninstall/disable the TTS engine entirely. Launch, tap a tile
      -> a VISIBLE error appears. Never silence.
- [ ] Bluetooth headphones -> speech routes to them, not the speaker
- [ ] Incoming call during speech -> speech stops; after the call, app still speaks

## 2. TalkBack (Android) / VoiceOver (iOS)
- [ ] Swipe through the grid: all 12 tiles, row-major, none skipped
- [ ] Each tile announces its DISPLAY label ("Overwhelmed"), NOT the sentence
- [ ] Each tile announces as "button"
- [ ] Double-tap speaks the VOCALIZATION — audio ACTUALLY HEARD
- [ ] Empty slots are not announced as buttons
- [ ] Type-to-speak field is reachable AND exitable
- [ ] Show-text mode: announced; back-out works
- [ ] Edit mode: reachable, exitable, no focus trap
- [ ] iOS: TTS output and VoiceOver do not deadlock each other
- [ ] iOS: Personal Voice permission DENIED -> graceful fallback, never silence

## 3. Switch Access (Android) / Switch Control (iOS) — NO AUTOMATION EXISTS
- [ ] Every tile reachable by scanning; order matches the traversal test
- [ ] Scan highlight is visible against ALL themes (incl. high contrast)
- [ ] Can exit edit mode using ONLY the switch
- [ ] Can exit the text field using ONLY the switch (no trap)
- [ ] iOS: point scanning can hit every tile

## 4. Scaling
- [ ] System font size at MAX + Display Zoom on: no tile text clipped
- [ ] Bold Text on: layout intact
- [ ] Show-text mode readable at max font size

## 5. Native surfaces — zero Dart coverage BY DESIGN
- [ ] QS tile: add to shade. FORCE-STOP the app. Tap tile -> speaks.
- [ ] QS tile: edit the phrase in-app, force-stop, tap tile -> speaks the NEW
      phrase (catches the storage-contract break)
- [ ] QS tile, screen LOCKED -> speaks, or prompts unlock predictably
- [ ] iOS ControlWidget: same three checks

## 6. Data — irreplaceable
- [ ] Install the PREVIOUS release, create/edit tiles, upgrade in place
      -> EVERY board intact
- [ ] Settings > "Restore previous board" recovers the pre-migration backup

## 7. Crash log — the only field signal
- [ ] Trigger a known crash in a debug build; export the log
- [ ] Stack trace has READABLE Dart function names. Hex offsets mean
      --obfuscate or --split-debug-info crept in and the only field signal
      this app has is dead.
- [ ] The exported log contains NO vocalization text

## 8. Scanners
- [ ] Google Accessibility Scanner on the grid screen — no new findings
      (it works: it reads Flutter's AccessibilityBridge virtual node tree)
- [ ] Xcode Accessibility Inspector audit on the grid screen — no new findings
```

---

## 14. Highest value, most over-rated

**Highest value:** `test/speech/silence_is_impossible_test.dart` (§4.4). It is
the only test in the suite that is unsatisfiable by a code path that fails
silently, and it is the closest thing to telemetry this app will ever have.

**Runner-up, and it isn't a test:** the pre-migration file backup (§7.4). Fifteen
lines that cover the migration bug you didn't enumerate — which, with no
telemetry, is the entire invisible category.

**Most over-rated:** `meetsGuideline` as an accessibility gate (§6.1). Four green
`expectLater`s that skip 10 of your 12 tiles, false-pass white-on-`#fafafa`, and
accept a tile labelled `button1` — while producing a strong feeling that
accessibility is tested. **Keep them; do not trust them.** The gates are
`getSize` over all 12 tiles, per-tile `isSemantics` label assertions, a pure-Dart
contrast unit test, and §13.

**Runner-up:** a coverage percentage gate. The number lies upward.

---

## 15. The part that isn't engineering

The decisions that prevent these failures all **look like mistakes**:

- A nullable FK inside a composite primary key reads as a normalization error.
  It is what makes tile reflow structurally impossible.
- `.playback` instead of `.ambient` reads as an oversight. It is what stops the
  silent switch from muting a person's voice.
- Checking a `setVoice` return value reads as paranoia. It is the documented
  silent-failure path.
- `speakNow` returning `void` reads as sloppy. It is the only thing closing a
  lint hole that no lint closes.

A stranger — or you, in six months — will clean up every one of them, reintroduce
the exact failure it prevents, and **no test and no crash report will say so.**

Put the reasoning where the temptation is: a doc comment on the table definition,
on the audio session config, on `speakNow`. Not in a `docs/` directory nobody
opens. The person about to add a surrogate `id` to `grid_slots` is standing in
`tables.dart` when they get the idea.
