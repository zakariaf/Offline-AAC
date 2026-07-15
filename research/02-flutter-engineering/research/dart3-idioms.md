# dart3-idioms

> Phase: **research** · Agent `a1fa8531ab549bf4e` · Run `wf_12b14467-451`

## Result

## Summary

As of 2026-07-15 the current stable is Dart 3.12 (shipped with Flutter 3.44 at I/O 2026). Macros were cancelled in January 2025 — do not architect around them; augmentations are the replacement direction, and codegen still means build_runner. Two of Dart 3's headline features are genuinely load-bearing for this app and the rest are showing off: sealed classes + exhaustive switch (which is the mechanism that makes silent speech failure a COMPILE ERROR rather than a field bug), and records (for ephemeral multi-returns like grid coordinates). Skip extension types, skip primary constructors (VERIFIED: experimental behind --enable-experiment=primary-constructors in 3.12, NOT shipped — several blog posts claim otherwise and are wrong), and skip freezed — drift already generates data classes with == and copyWith, so freezed on this schema is a build_runner tax for redundant output. On error handling: Flutter's official architecture guide does publish a concrete sealed Result class, and it is the right shape for the drift repository. But for speak() it is the WRONG shape, because its error arm is typed Exception — untyped, non-exhaustive, and unable to carry the fallback payload. The correct model for this app is a domain-specific sealed SpeakOutcome whose failure variants carry the text that must be shown on screen when audio does not happen. For global capture, wire FlutterError.onError + PlatformDispatcher.instance.onError to an on-device log and do NOT use runZonedGuarded — Flutter's own breaking-change doc says the fix for the zone-mismatch warning is to remove zones from the application.

### Dart macros were cancelled in January 2025 and will never ship; augmentations are the replacement direction.

*Confidence: high, **LOAD-BEARING***

The Dart team dropped macros after ~2 years and ~1,400 upvotes on the tracking issue. Stated cause: macros had to re-execute during incremental compilation to detect semantic changes, which degraded hot reload past acceptable latency. The replacement is `augmentations` (splitting a class body across files with the `augment` keyword), which improves the ergonomics of generated code but does NOT remove build_runner. Consequence for this project: any plan premised on 'macros will kill build_runner soon' is dead. Codegen choices (drift, freezed) must be evaluated on their 2026 cost, not on a future that was cancelled.

- https://dart.dev/resources/language/evolution

- https://shorebird.dev/blog/dart-macros

- https://www.verygood.ventures/blog/the-hard-thing-about-hard-things-macros-in-dart

### Primary constructors are EXPERIMENTAL in Dart 3.12, not stable — multiple blog posts claiming Dart 3.12 'adds primary constructors' are misleading.

*Confidence: high, **LOAD-BEARING***

VERIFIED against dart.dev: the 3.12 announcement describes primary constructors as an experimental preview gated behind the `primary-constructors` flag (`dart run --enable-experiment=primary-constructors`). dart.dev/resources/language/evolution does NOT list primary constructors as introduced in any version through 3.12; it lists only *private named parameters* for 3.12. Several I/O 2026 recap posts (ecorpit, Medium recaps) flatly state 3.12 'adds primary constructors' — treat as wrong. Do not use in this project: experiments can change shape or be withdrawn, and a stranger picking up an abandoned repo should not need an experiment flag to build it.

- https://dart.dev/blog/announcing-dart-3-12

- https://dart.dev/resources/language/evolution

- https://dart.dev/language/primary-constructors

### Feature-to-version map through 2026: Dart 3.0 = patterns/records/class modifiers/switch expressions/if-case; 3.3 = extension types; 3.8 = null-aware elements; 3.10 = dot shorthands; 3.11 = no new language features; 3.12 (May 18 2026, current stable, ships with Flutter 3.44) = private named parameters + experimental primary constructors.

*Confidence: high*

Sourced from dart.dev/resources/language/evolution. Practical picks for this app: dot shorthands (3.10) are free readability on enum-typed params (`OutputMode.speaker` -> `.speaker`) and are safe since the floor is already 3.12. Null-aware elements (3.8) let you drop `if (x != null)` inside collection literals — marginal here. Extension types (3.3) are a static-only zero-cost wrapper; the representation type is never a subtype of the extension type, and the underlying object is always reachable at runtime, so it is an *unsafe* abstraction. For typed IDs over drift's `int` it would add ceremony at every drift boundary for no safety this 12-tile app needs. Skip.

- https://dart.dev/resources/language/evolution

- https://blog.dart.dev/announcing-dart-3-10-ea8b952b6088

- https://dart.dev/language/extension-types

### Flutter's official architecture guide does publish a concrete sealed Result class — but its error arm is typed `Exception` and its variants are named `Ok`/`Error`, which shadows `dart:core.Error`.

*Confidence: high, **LOAD-BEARING***

The guide's Result (from the Compass App sample) is: `sealed class Result<T>` with `const factory Result.ok(T value) = Ok._;` and `const factory Result.error(Exception error) = Error._;`, plus `final class Ok<T> extends Result<T>` and `final class Error<T> extends Result<T>`. Two real defects for this project. (1) Naming: the `Error` variant shadows `dart:core.Error` in any file that imports it — and Effective Dart's rule 'DON'T explicitly catch Error or types that implement it' becomes hard to reason about when `Error` means two things. There is an open flutter/website issue (#11606) requesting improvements to this doc. Use `Ok`/`Err` or `Success`/`Failure`. (2) Typing: `Exception` as the error arm gives you zero exhaustiveness — `case Err(:final e)` tells you nothing about WHICH failure, so the compiler cannot force you to handle a new failure mode. That is precisely the guarantee this app needs.

- https://docs.flutter.dev/app-architecture/design-patterns/result

- https://github.com/flutter/website/issues/11606

### For speak(), a sealed domain outcome beats both throwing and a generic Result<T> — because the failure variants must CARRY the fallback payload, and because exhaustiveness is what makes silence impossible.

*Confidence: high, **LOAD-BEARING***

Three properties decide this. (a) speak() failure is EXPECTED, not a bug: a voice can be uninstalled between app launches, an Android voice can be network_required with no network, setVoice can return 0. Effective Dart: throw Error only for programmatic errors/bugs — so these are not Errors. (b) Nothing forces a caller to catch: 'in Dart, methods that throw exceptions don't need to declare them, and calling methods aren't required to catch them' — an uncaught speak() throw in an async tile handler goes to PlatformDispatcher.onError and the user sees NOTHING. That is the exact catastrophic bug class. (c) The failure needs a payload: the fallback is 'show the text full-screen', so the failure value must carry the text. A sealed SpeakFailure with `final String spokenText` makes the fallback a total function of the outcome. Combined with an exhaustive switch and NO `default:`/`case _:`, adding a new failure mode becomes a compile error at every call site.

- https://docs.flutter.dev/app-architecture/design-patterns/result

- https://dart.dev/effective-dart/usage

- https://codewithandrea.com/articles/flutter-exception-handling-try-catch-result-type/

### Do NOT use runZonedGuarded in Flutter 3.10+. Use FlutterError.onError + PlatformDispatcher.instance.onError only. Sources conflict on this; the official Flutter doc is decisive.

*Confidence: high, **LOAD-BEARING***

ADVERSARIAL CHECK — sources disagree. Sentry's docs and several 2026 'complete guide' posts say 'use all three handlers, you need all three to catch 100% of production errors.' Against that: (1) docs.flutter.dev/testing/errors — the official error-handling page — shows ONLY FlutterError.onError + PlatformDispatcher.instance.onError and does not mention runZonedGuarded at all. (2) docs.flutter.dev/release/breaking-changes/zone-errors states Flutter 3.10+ detects zone mismatch and warns, and that 'the best way to silence this message is to remove use of Zones from within the application.' (3) The dart:async runZonedGuarded API doc carries no Flutter recommendation either way. The 'use all three' advice is crash-SDK advice — Sentry needs a zone because it wraps init. This app has no SDK, so the zone buys nothing and costs a documented footgun: WidgetsFlutterBinding.ensureInitialized() outside the zone triggers the mismatch, and zone-specific config then applies inconsistently. Verdict: two handlers, no zone.

- https://docs.flutter.dev/testing/errors

- https://docs.flutter.dev/release/breaking-changes/zone-errors

- https://api.flutter.dev/flutter/dart-async/runZonedGuarded.html

- https://docs.sentry.io/platforms/flutter/usage/

### PlatformDispatcher.instance.onError's bool return means 'handled, suppress default reporting' — it does not keep the app alive, and returning true unconditionally will hide errors from you in debug.

*Confidence: medium, **LOAD-BEARING***

The handler signature is `bool Function(Object error, StackTrace stack)`. Returning true marks the error handled so it is not forwarded to the default handler (which prints to console). Uncaught async errors do not terminate a Flutter app regardless. So the return value is purely a reporting decision: in this app, return `true` in release (log silently to disk, keep the crisis UI up) and `false` in debug so the console still shows it. `return kReleaseMode;` is the whole rule. Corollary that matters more: the log writer itself must never throw, or an error inside the error handler recurses.

- https://docs.flutter.dev/testing/errors

### freezed is NOT worth it for this app in 2026. Current version 3.2.5 (published ~Feb 2026); it is alive and maintained, but redundant here because drift already generates == and copyWith.

*Confidence: high, **LOAD-BEARING***

VERIFIED on pub.dev: freezed 3.2.5, published ~5 months before 2026-07-15. Freezed 3.0 (Feb 2025, shipped alongside the macros cancellation) added 'mixed mode': plain classes with normal constructors and final fields, no mandatory `_User` private subclass, no mandatory factory. It is healthy. But: this app's persisted types (boards/buttons/grid_slots/images/sounds/settings) are drift row classes, and drift's generator ALREADY emits value-equality, hashCode, toString, and copyWith for them. Putting freezed on top means a second build_runner generator producing overlapping output. The remaining hand-written types are a handful of sealed outcome/state classes — sealed hierarchies with 1-3 final fields, where `@immutable` + `const` constructor + final fields is ~4 lines and needs no equality at all (they are switched on, not compared). Cost avoided: build_runner in the loop, .freezed.dart churn in diffs, and one more thing a stranger must install to build an abandoned repo.

- https://pub.dev/packages/freezed

- https://alperenderici.medium.com/dart-macros-discontinued-freezed-3-0-released-why-it-happened-whats-new-and-alternatives-385fc0c571a4

### equatable is also unnecessary: for the few hand-written value types, use records for ephemeral tuples and manual == with Object.hash for the rare case that needs it.

*Confidence: high*

Decision rule for this codebase: (1) persisted type -> drift's generated class, already has ==/copyWith, write nothing; (2) ephemeral multi-return -> a record, e.g. `(int row, int col)` for a grid slot coordinate — records have structural equality and hashCode for free, no package, no codegen; (3) sealed state/outcome variant -> plain `final class` with const ctor and final fields, no == needed because you switch on the type, not compare instances; (4) something that must live in a Set/Map key and isn't (1)-(3) -> manual `==` + `Object.hash(...)`, which is ~5 lines. equatable adds a dependency and a runtime props list to replace 5 lines in case (4) only. Skip. Caveat on records: don't let them cross layer boundaries as domain types — no name, no doc comment, no methods, and a positional shape that silently changes meaning if reordered.

- https://www.freecodecamp.org/news/how-to-handle-errors-the-right-way-in-flutter-a-practical-guide-to-sealed-classes-records-and-result-types/

- https://dart.dev/resources/language/evolution

### assert is debug-only and stripped in release — so it must never guard the speech path, but it is the right tool for grid-slot invariants.

*Confidence: high, **LOAD-BEARING***

Dart asserts are compiled out in release builds (they run only in debug/JIT). Placement rule for this app: assert for invariants that a BUG would violate and that tests exercise in debug — e.g. `assert(row >= 0 && row < kRows)`, `assert(col >= 0 && col < kCols)` in a GridSlot constructor, `assert(vocalization.trim().isNotEmpty)`. NEVER assert for anything the ENVIRONMENT can violate at runtime: voice availability, setVoice's return code, engine liveness, file existence for image paths. Those are real runtime conditions on a user's device in release mode, where the assert does not exist. An `assert(setVoiceResult == 1)` would be the perfect silent-failure bug: green in every test, absent in the field. This maps exactly onto Effective Dart's Error-vs-Exception split — assert covers the same ground as Error (bugs), sealed failures cover Exception ground (environment).

- https://dart.dev/effective-dart/usage

- https://dart.dev/language/error-handling

### The Effective Dart rules this codebase will actually violate are the catch rules — and the crash logger needs a deliberate, commented exemption from one of them.

*Confidence: high*

Quoted rules that bite here: 'AVOID catches without on clauses' — a bare catch swallows everything thrown in the block. 'DON'T discard errors from catches without on clauses: if you really do feel you need to catch everything... do something with what you catch. Log it, display it to the user or rethrow it, but do not silently discard it.' 'DO throw objects that implement Error only for programmatic errors' — an Error means there is a bug in your code. 'DON'T explicitly catch Error or types that implement it' — catching Error masks bugs. 'DO use rethrow to rethrow a caught exception' — rethrow preserves the original stack trace; `throw e` resets it to the current line. The one place this app must violate the discard rule is inside CrashLog.record's own catch: an error handler that throws recurses. That single `catch (_) { }` needs a comment explaining why, or a future reader (or a lint sweep) will 'fix' it into a recursive crash. Also common and cheap to lint: prefer_final_fields/prefer_const_constructors (matters here — zero animation + const widgets = deterministic rebuilds), lowercase_with_underscores filenames, and doc comments that start with a single-sentence summary.

- https://dart.dev/effective-dart/usage

- https://dart.dev/effective-dart/documentation

- https://dart.dev/effective-dart/style

## Recommendations

- **[must]** Model speak() as `Future<SpeakOutcome>` where SpeakOutcome is a sealed hierarchy, and make every failure variant carry the text that must be shown on screen. Never let speak() throw for expected failures.
  - The failure IS the feature: the whole point is that when audio doesn't happen, the text appears. A throw can be forgotten by the caller (Dart requires no declaration and no catch), and an exception can't ergonomically carry the fallback payload. A sealed return makes the fallback a total function of the outcome.
- **[must]** Never write `default:` or `case _:` in a switch over a sealed type. Turn on the analyzer and let non-exhaustive switches be compile errors.
  - Exhaustiveness is the entire mechanism that converts 'a new failure mode was added and nobody handled it' from a field bug (that you will NEVER learn about — no telemetry) into a build break. A default arm silently disables the one safety net you have.
- **[must]** Wire FlutterError.onError and PlatformDispatcher.instance.onError to the on-device log inside main(), and call WidgetsFlutterBinding.ensureInitialized() in that same function body. Do not use runZonedGuarded.
  - docs.flutter.dev/testing/errors shows exactly these two handlers and never mentions zones; the zone-errors breaking-change doc says the fix for zone mismatch is to remove zones from the app. The 'use all three' advice circulating in 2026 is crash-SDK advice — Sentry needs a zone to wrap its init. You have no SDK, so the zone is pure footgun.
- **[must]** Make CrashLog.record() synchronous, self-truncating, and incapable of throwing — with a comment on its bare catch explaining that an error handler that throws recurses.
  - It is the only record that a crash ever happened. If it throws inside FlutterError.onError you get infinite recursion; if it's async you can lose the write on a hard kill. The comment matters because the bare catch violates Effective Dart's 'DON'T discard errors' and a future maintainer will otherwise 'fix' it.
- **[must]** Check every flutter_tts return code against `!= 1` and return a typed failure. Never `assert` a platform return value.
  - setVoice returns 0 with only a Log.d on failure. An assert is stripped in release, so `assert(result == 1)` is green in every test and absent on the user's device — the exact silent-failure bug this app cannot afford.
- **[should]** Use Flutter's official Result<T> shape for the drift repository, but rename the variants to Ok/Err and do not reuse it for speak().
  - The guide's `Error` variant shadows dart:core.Error, which is genuinely confusing next to the 'DON'T catch Error' rule (flutter/website#11606 is open on this doc). Repository errors are unexpected and generically handled, so a generic Exception arm is fine there. Speech failures are expected, individually actionable, and carry payload — different problem, different type.
- **[avoid]** Do not add freezed, equatable, fpdart, dartz, result_dart, or oxidized. Hand-roll the sealed types.
  - drift already generates ==/hashCode/copyWith for every persisted type, so freezed is redundant codegen on the same classes. The hand-written types are sealed variants with 1-3 final fields that are switched on, not compared. A stranger inheriting an abandoned repo should be able to `flutter run` without learning a functional-programming dependency's combinator vocabulary.
- **[avoid]** Do not use primary constructors, and do not enable any Dart experiment flag.
  - VERIFIED: experimental behind --enable-experiment=primary-constructors in 3.12 despite blog posts saying otherwise. An abandoned repo that needs an experiment flag to build is an abandoned repo that stops building when the experiment changes shape.
- **[avoid]** Do not use extension types for IDs, and do not architect anything around macros.
  - Extension types are an explicitly unsafe abstraction (representation type is never a subtype; the underlying object is always reachable), and they'd add friction at every drift boundary for safety a 12-tile app doesn't need. Macros were cancelled in Jan 2025 — build_runner is not going away, so choose codegen on its 2026 cost.
- **[should]** Use records only for ephemeral multi-returns inside a layer — `(int row, int col)` for slot coordinates — never as a domain type that crosses a layer boundary.
  - Records give free structural equality with no package and no codegen, which is exactly right for a coordinate pair. But they have no name, no doc comment, and a positional shape that silently changes meaning if reordered — a bad fate for anything a stranger has to read at a layer boundary.
- **[must]** Reserve `assert` for invariants a bug would violate (grid bounds, non-empty vocalization) and never for conditions the device can violate (voice present, file exists, engine alive).
  - Asserts are debug-only. This maps cleanly onto Effective Dart's Error-vs-Exception split: assert covers Error ground (bugs in your code), sealed failures cover Exception ground (the environment). Getting this backwards produces bugs that are invisible in exactly the build your users run.
- **[should]** Use `rethrow`, never `throw e`, when re-raising inside a catch; and put an `on` clause on every catch except the crash logger's.
  - rethrow preserves the original stack trace; throw resets it to the rethrow line. With no crash reporting, the stack trace in your on-device log is the entire forensic record — corrupting it costs you the only debugging artifact you'll ever receive from a user.

### SpeechService: sealed outcome where failure carries the fallback payload

```dart
import 'package:meta/meta.dart';

/// The result of attempting to vocalize a phrase.
///
/// Every failure variant carries [SpeakFailure.spokenText] so that the caller
/// can always fall back to showing the phrase on screen. A user who taps a tile
/// must never get nothing.
@immutable
sealed class SpeakOutcome {
  const SpeakOutcome();
}

/// The engine reported that it finished speaking the phrase aloud.
final class SpokeAloud extends SpeakOutcome {
  const SpokeAloud();
}

/// The phrase was not spoken. The caller MUST show [spokenText] instead.
@immutable
sealed class SpeakFailure extends SpeakOutcome {
  const SpeakFailure(this.spokenText);

  /// The text that was supposed to be spoken, for the on-screen fallback.
  final String spokenText;

  /// A short, non-blaming line for the crash log. Not shown to the user.
  String get logLine;
}

/// Settings hold no voice, or the stored voice was never resolved.
final class NoVoiceSelected extends SpeakFailure {
  const NoVoiceSelected(super.spokenText);

  @override
  String get logLine => 'no voice selected in settings';
}

/// `setVoice` did not return 1. flutter_tts logs this and returns 0 with no
/// throw, so an unchecked call here is silent, total speech loss.
final class VoiceUnavailable extends SpeakFailure {
  const VoiceUnavailable(super.spokenText, {required this.voiceName});

  final String voiceName;

  @override
  String get logLine => 'setVoice rejected voice "$voiceName"';
}

/// The voice exists but is marked network_required and we are offline
/// (this app is offline by design, so this voice is permanently unusable).
final class VoiceRequiresNetwork extends SpeakFailure {
  const VoiceRequiresNetwork(super.spokenText, {required this.voiceName});

  final String voiceName;

  @override
  String get logLine => 'voice "$voiceName" requires network; app is offline';
}

/// `speak` returned a non-success code.
final class EngineRejected extends SpeakFailure {
  const EngineRejected(super.spokenText, {required this.code});

  final Object? code;

  @override
  String get logLine => 'engine rejected speak(), code=$code';
}

/// `speak` never completed. The engine is wedged.
final class EngineTimedOut extends SpeakFailure {
  const EngineTimedOut(super.spokenText, {required this.waited});

  final Duration waited;

  @override
  String get logLine => 'engine timed out after ${waited.inMilliseconds}ms';
}

/// The seam the UI depends on. Fake this in widget tests.
abstract interface class SpeechService {
  Future<SpeakOutcome> speak(String text);
  Future<void> stop();
  Future<List<VoiceDescriptor>> voices();
}

@immutable
final class VoiceDescriptor {
  const VoiceDescriptor({
    required this.name,
    required this.locale,
    required this.requiresNetwork,
  });

  final String name;
  final String locale;
  final bool requiresNetwork;

  @override
  bool operator ==(Object other) =>
      other is VoiceDescriptor &&
      other.name == name &&
      other.locale == locale &&
      other.requiresNetwork == requiresNetwork;

  @override
  int get hashCode => Object.hash(name, locale, requiresNetwork);
}
```

The core pattern. Note NoVoiceSelected/VoiceUnavailable/etc. all extend SpeakFailure, which carries `spokenText` — so the show-text fallback is a total function of the outcome. Nothing here throws for an expected failure.

### The implementation: every platform return code checked, no assert on the wire

```dart
import 'package:flutter_tts/flutter_tts.dart';

final class FlutterTtsSpeechService implements SpeechService {
  FlutterTtsSpeechService(this._tts, this._settings);

  final FlutterTts _tts;
  final SettingsSnapshot _settings;

  static const _speakTimeout = Duration(seconds: 8);
  static const _ttsSuccess = 1;

  @override
  Future<SpeakOutcome> speak(String text) async {
    final voice = _settings.voice;
    if (voice == null) return NoVoiceSelected(text);

    // Offline-by-design: a network voice can never work here.
    if (voice.requiresNetwork) {
      return VoiceRequiresNetwork(text, voiceName: voice.name);
    }

    // flutter_tts returns 0 and only writes a Log.d on failure. Unchecked,
    // this is a user in crisis tapping a tile and getting silence.
    final setResult = await _tts.setVoice({
      'name': voice.name,
      'locale': voice.locale,
    });
    if (setResult != _ttsSuccess) {
      return VoiceUnavailable(text, voiceName: voice.name);
    }

    // With awaitSpeakCompletion(true) set at init, speak() resolves when the
    // utterance finishes, so a 1 here means audio actually came out.
    Object? speakResult;
    try {
      speakResult = await _tts.speak(text).timeout(_speakTimeout);
    } on TimeoutException {
      return EngineTimedOut(text, waited: _speakTimeout);
    } on PlatformException catch (e) {
      return EngineRejected(text, code: e.code);
    }

    if (speakResult != _ttsSuccess) {
      return EngineRejected(text, code: speakResult);
    }
    return const SpokeAloud();
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  Future<List<VoiceDescriptor>> voices() async { /* voice_filter lives here */
    throw UnimplementedError();
  }
}
```

`setVoice` returning 0 is the documented silent-failure path in flutter_tts. This checks it as a runtime value and returns a typed failure — an `assert` here would vanish in release.

### The call site: exhaustive switch with no default arm

```dart
final class TileController {
  TileController(this._speech, this._log, this._showText);

  final SpeechService _speech;
  final CrashLog _log;
  final void Function(String text) _showText;

  Future<void> onTilePressed(String vocalization) async {
    final outcome = await _speech.speak(vocalization);

    // No `default:`, no `case _:`. Adding a SpeakOutcome variant that isn't
    // covered here must break the build.
    switch (outcome) {
      case SpokeAloud():
        return;

      // Every failure resolves the same way: the user sees the words.
      case SpeakFailure(:final spokenText, :final logLine):
        _log.record('speak failed: $logLine', StackTrace.current);
        _showText(spokenText);
    }
  }
}
```

This is where the guarantee lands. There is no `default:` and no `case _:`, so adding a variant to SpeakFailure that this switch cannot handle is a compile error — the only alarm system an app with no telemetry has.

### main(): two handlers, no zone, bindings in the same function body

```dart
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

void main() async {
  // Same function body as runApp(): no zone, so no zone-mismatch warning and
  // no inconsistent zone-specific configuration.
  WidgetsFlutterBinding.ensureInitialized();

  final log = await CrashLog.open();

  // Errors thrown inside Flutter's build/layout/paint callbacks.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.record(details.exceptionAsString(), details.stack);
  };

  // Uncaught async errors outside the framework's callbacks.
  PlatformDispatcher.instance.onError = (error, stack) {
    log.record(error.toString(), stack);
    // true = handled, suppress default console reporting. Suppress only in
    // release; in debug we still want it printed.
    return kReleaseMode;
  };

  runApp(const AacApp());
}
```

No runZonedGuarded — Flutter's zone-errors breaking-change doc says the fix for zone mismatch is to remove zones. `return kReleaseMode` means: log silently in release, still print in debug.

### CrashLog: synchronous, self-truncating, and structurally unable to throw

```dart
import 'dart:io';

/// An on-device, user-exportable crash log. This is the ONLY record that a
/// crash ever happened: there is no telemetry and there never will be.
final class CrashLog {
  CrashLog(this._file);

  final File _file;
  static const _maxBytes = 256 * 1024;

  static Future<CrashLog> open() async {
    // ...resolve to the app support dir; never external storage.
    throw UnimplementedError();
  }

  /// Appends an entry. Synchronous so an entry survives a hard kill, and
  /// total so it can be called from an error handler.
  void record(String message, StackTrace? stack) {
    try {
      if (_file.existsSync() && _file.lengthSync() > _maxBytes) {
        _file.writeAsStringSync('', flush: true); // Bounded: never fill a disk.
      }
      final entry = StringBuffer()
        ..writeln('--- ${DateTime.now().toIso8601String()} ---')
        ..writeln(message)
        ..writeln(stack?.toString() ?? '<no stack>')
        ..writeln();
      _file.writeAsStringSync(
        entry.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // INTENTIONAL bare catch, and INTENTIONALLY discarded.
      //
      // This runs inside FlutterError.onError and
      // PlatformDispatcher.onError. If it throws, the error handler's error
      // re-enters the error handler and recurses until the app dies.
      //
      // Effective Dart says never silently discard from a bare catch. This is
      // the one place in this codebase where that rule is wrong. Do not
      // "fix" this by rethrowing or by logging to the same file.
    }
  }
}
```

The bare `catch (_)` deliberately violates Effective Dart's 'DON'T discard errors' rule. The comment is load-bearing — without it, someone will 'fix' this into an infinite recursion.

### Immutability without freezed: records for coordinates, asserts for invariants, drift for the rest

```dart
import 'package:flutter/foundation.dart';

const kRows = 4;
const kCols = 3; // Fixed 3x4 = 12 tiles. Never derived from data.

/// A grid coordinate. A record: ephemeral, structurally equal for free,
/// never crosses a layer boundary.
typedef SlotCoord = (int row, int col);

Iterable<SlotCoord> allSlots() sync* {
  for (var row = 0; row < kRows; row++) {
    for (var col = 0; col < kCols; col++) {
      yield (row, col);
    }
  }
}

/// A tile as the UI needs it. Hand-written, const, no codegen.
///
/// [label] is what the tile SHOWS; [vocalization] is what it SPEAKS.
/// They are different on purpose (Open Board Format semantics): the tile reads
/// "Overwhelmed" and says "I need to leave, I'm not able to talk right now".
@immutable
final class TileView {
  const TileView({
    required this.coord,
    required this.label,
    required this.vocalization,
  })  : assert(vocalization != '', 'a tile that speaks nothing is a bug');

  final SlotCoord coord;
  final String label;
  final String vocalization;

  /// An empty slot. Position is the primary key, so a slot always exists even
  /// when no button occupies it — this is what makes reflow impossible.
  const TileView.empty(this.coord)
      : label = '',
        vocalization = '';

  bool get isEmpty => vocalization.isEmpty;

  TileView copyWith({String? label, String? vocalization}) => TileView(
        coord: coord,
        label: label ?? this.label,
        vocalization: vocalization ?? this.vocalization,
      );
}

/// Debug-only bounds check. Correct here because an out-of-range coordinate is
/// a BUG in our code, not a condition a device can produce.
void debugCheckCoord(SlotCoord c) {
  assert(c.$1 >= 0 && c.$1 < kRows, 'row ${c.$1} out of range');
  assert(c.$2 >= 0 && c.$2 < kCols, 'col ${c.$2} out of range');
}
```

Contrast with freezed: this whole file is zero generated lines. The `assert`s cover bugs (bad coordinates); they deliberately do NOT cover anything the device can violate at runtime.

### Result for the drift repository — renamed variants to avoid shadowing dart:core.Error

```dart
import 'package:meta/meta.dart';

/// Flutter's official Result (docs.flutter.dev/app-architecture/design-patterns/result)
/// with the `Error` variant renamed to `Err` so it does not shadow
/// `dart:core`'s `Error` — which, per Effective Dart, means "a bug in your
/// code" and must never be caught.
@immutable
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>._;
  const factory Result.err(Exception error) = Err<T>._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

final class Err<T> extends Result<T> {
  const Err._(this.error);
  final Exception error;

  @override
  String toString() => 'Result<$T>.err($error)';
}

// Usage. Repository errors are unexpected and uniformly handled, so a generic
// Exception arm is fine here — unlike speak(), where each failure is expected
// and individually actionable.
Future<void> loadBoard(BoardRepository repo, CrashLog log) async {
  final result = await repo.activeBoard();
  switch (result) {
    case Ok(:final value):
      // ...render value
      break;
    case Err(:final error):
      log.record('board load failed: $error', StackTrace.current);
      // ...render the last-known-good board; never an empty grid.
      break;
  }
}
```

Flutter's official guide names these Ok/Error; `Error` shadows dart:core.Error in every importing file, which is actively confusing next to the 'DON'T catch Error' rule. Same shape, safer names.

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


YOUR DIMENSION: Modern Dart 3.x language idioms and error-handling patterns.

Research with WebSearch/WebFetch: dart.dev/effective-dart, dart.dev language docs, Dart 3.x release notes and what landed in each version through 2026, Dart team blog posts.

- **Dart 3 features and when to use them**: sealed classes + exhaustive switch, pattern matching, records, class modifiers (final/base/interface/sealed/mixin), switch expressions, if-case, destructuring. Which genuinely improve code here, and which are showing off?
- What landed in Dart 3.3-3.9+ (extension types? macros — did macros ship or get cancelled? VERIFY, this was contentious), null-aware elements, dot shorthands? Get the CURRENT state of the language in 2026.
- **Error handling**: exceptions vs Result/Either types. The Dart team's actual position (dart.dev has guidance on Error vs Exception). Flutter's official architecture guide recommends a Result class — verify and show it. Is `fpdart`/`dartz`/`result_dart`/`oxidized` worth a dependency, or hand-roll a sealed Result? For THIS app, where a silent failure means a user in crisis gets no speech, what is the right error model? Argue concretely — e.g. `speak()` can fail (voice missing, engine dead, setVoice returned 0). Should it throw or return a Result?
- Where should errors be caught? What does Flutter's FlutterError.onError / PlatformDispatcher.instance.onError do, and how do you use them WITHOUT a crash-reporting SDK? (This app writes an on-device log instead — what's the correct wiring?)
- Zone-based error capture (runZonedGuarded) — still recommended in 2026, or superseded by PlatformDispatcher.onError?
- Immutability: how much? const constructors, final fields, copyWith. Is `freezed` worth it in 2026 (it needs build_runner)? What about the new Dart features that reduce the need for it? Verify freezed's current version and status.
- equatable vs freezed vs manual == vs records.
- Assertions and `assert` in Flutter — debug-only; where do they belong in a safety-critical-ish app?
- Effective Dart's actual naming/doc/style rules that people commonly violate.

Give real, compiling, current code.
````

</details>
