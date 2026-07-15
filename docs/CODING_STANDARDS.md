# Coding Standards — Offline AAC

Five facts generate every rule in this document. When a rule seems fussy, check it against these:

1. **No telemetry, ever.** We will never learn that the app crashed in the field. Our users are, by definition, unable to speak when the app fails them — nobody will file a bug. The analyzer and the test suite are the entire feedback loop.
2. **A silent failure means a user in crisis gets no speech.** "Nothing happened" is the worst possible outcome and it is the *default* behaviour of an unhandled error path.
3. **A botched migration destroys someone's voice.** Boards are hand-curated over months, unmergeable, and there is no server backup.
4. **An inaccessible accessibility app is a total failure.** Semantics and TextScaler are correctness, not polish.
5. **A stranger may inherit this.** Several decisions here look like mistakes. They are load-bearing. Comment them at the point of temptation.

Everything below was verified against the SDK actually installed: **Dart 3.11.0 / Flutter 3.41.2**. Where a claim was checked by running it, it says `VERIFIED`. Where it wasn't, it says so.

---

## 1. Dart 3 idioms: what earns its place

| Idiom | Verdict | Why |
|---|---|---|
| `sealed class` + exhaustive `switch` | **Use.** The backbone of §2 | A missing branch is a **compile error**, not a lint. It's the only compiler-grade safety net we have |
| Destructuring patterns (`case SpeakFailure(:final spokenText)`) | **Use** | Pulls the fallback payload out at the one place it's needed |
| Records for ephemeral tuples (`(int row, int col)`) | **Use, inside a layer only** | Free structural equality, no package, no codegen |
| `final class` / `abstract interface class` | **Use** | `abstract interface class SpeechService` says "implement me, don't extend me" — exactly the seam contract |
| `@immutable` + `const` ctor + `final` fields | **Use** | 4 lines replaces a code generator |
| `enum` for closed sets with no payload | **Use sparingly** | Native enums get compiler exhaustiveness too — but the moment a variant needs a field, it must become sealed |
| **Extension types** | **Skip** | Explicitly an *unsafe* abstraction: the representation type is never a subtype and the underlying object is always reachable. Ceremony at every drift boundary for safety 12 tiles don't need |
| **Primary constructors** | **Skip** | Experimental behind `--enable-experiment=primary-constructors` in 3.12, despite blog posts saying otherwise ([dart.dev/language/primary-constructors](https://dart.dev/language/primary-constructors)). An abandoned repo must not need an experiment flag to build |
| **Macros** | **Dead** | [Cancelled Jan 2025](https://dart.dev/blog/an-update-on-dart-macros-data-serialization). `build_runner` is not going away — choose codegen on its 2026 cost |
| **freezed / equatable / fpdart / dartz** | **Skip** — see §4 | |

**Records never cross a layer boundary.** They have no name, no doc comment, and a positional shape that silently changes meaning if reordered. `(int, int)` is fine as a coordinate inside the board layer; it is not a domain type.

---

## 2. The error model

### 2.1 Error vs Exception vs assert

| Kind | Means | Where |
|---|---|---|
| `Error` subclass | **A bug in our code.** Never catch it | Programmer errors only |
| `assert` | A bug an invariant would catch, **in debug only** | Grid bounds, non-empty vocalization |
| `Exception` | Something the environment did | drift/SQLite failures |
| **Sealed outcome** | An **expected, individually actionable** failure that carries a payload | `speak()` |

The line that matters: **`assert` is stripped in release.** So `assert(setVoiceResult == 1)` is green in every test and *absent on the user's device* — the perfect silent-failure bug. Asserts cover `Error` ground (our bugs). Sealed outcomes cover `Exception` ground (the environment).

```dart
// RIGHT — assert covers a bug we could make.
GridSlot({required this.row, required this.col})
    : assert(row >= 0 && col >= 0, 'negative coordinate is a bug');

// WRONG — the device can violate this at runtime, in release, where the
// assert does not exist. Voice availability is not our bug; it is a fact.
Future<void> speak(String t) async {
  assert(await _tts.setVoice(v) == 1); // vanishes in release. Total silence.
}
```

### 2.2 Decision: one sealed outcome. No generic `Result<T>`.

Flutter's architecture guide publishes a generic sealed `Result<T>` ([design-patterns/result](https://docs.flutter.dev/app-architecture/design-patterns/result)). **We are not using it.** Two reasons:

- Its error arm is typed `Exception`, so `case Error(:final e)` tells you *nothing about which failure* — zero exhaustiveness, which is the entire property we want.
- It names a variant `Error`, shadowing `dart:core.Error` in every importing file, right next to the rule "DON'T explicitly catch `Error`". There's an [open issue on this doc](https://github.com/flutter/website/issues/11606).

Carrying `Result<T>` *and* `SpeakOutcome` means two error vocabularies for one app. drift throws `SqliteException`; catch it at the three call sites that read the DB. One sealed type, hand-rolled, zero dependencies:

```dart
// lib/speech/speak_outcome.dart
// `sealed` requires every subtype in THIS library. That is the point — the
// file is the closed set, and the compiler enforces it.
import 'package:meta/meta.dart';

/// The result of attempting to vocalize a phrase.
///
/// Every failure variant carries [SpeakFailure.spokenText] so the caller can
/// ALWAYS fall back to showing the phrase on screen. A user who taps a tile
/// must never get nothing. That is the whole product.
@immutable
sealed class SpeakOutcome {
  const SpeakOutcome();
}

/// The engine reported that it finished speaking the phrase aloud.
final class SpokeAloud extends SpeakOutcome {
  const SpokeAloud();
}

/// The phrase was NOT spoken. The caller MUST show [spokenText] instead.
@immutable
sealed class SpeakFailure extends SpeakOutcome {
  const SpeakFailure(this.spokenText);

  /// The text that was supposed to be spoken. The on-screen fallback.
  final String spokenText;

  /// One line for the on-device crash log. Never shown to the user.
  String get logLine;
}

/// Settings hold no voice, or the stored voice id no longer resolves.
/// Android garbage-collects TTS voice data: this is the single most likely
/// real-world silent failure, and it happens between launches.
final class NoVoiceSelected extends SpeakFailure {
  const NoVoiceSelected(super.spokenText);
  @override
  String get logLine => 'no usable voice selected';
}

/// `setVoice` did not return 1.
final class VoiceUnavailable extends SpeakFailure {
  const VoiceUnavailable(super.spokenText, {required this.voiceName});
  final String voiceName;
  @override
  String get logLine => 'setVoice rejected "$voiceName"';
}

/// The voice carries Android's `notInstalled` feature flag.
/// setVoice returns **1 (success)** for these and synthesis still reports
/// ERROR_NOT_INSTALLED_YET *or silently substitutes a different voice*.
/// Checking the setVoice return value does NOT catch this.
final class VoiceNotInstalled extends SpeakFailure {
  const VoiceNotInstalled(super.spokenText, {required this.voiceName});
  final String voiceName;
  @override
  String get logLine => 'voice "$voiceName" is flagged notInstalled';
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
```

The seam:

```dart
// lib/speech/speech_service.dart
abstract interface class SpeechService {
  /// Never throws for an expected failure. Returns a [SpeakFailure] instead.
  ///
  /// `@useResult` is load-bearing: without it, `await speak(text);` discards
  /// the outcome and compiles clean. VERIFIED — see §3.
  @useResult
  Future<SpeakOutcome> speak(String text);

  Future<void> stop();
  Future<List<Voice>> voices();
}
```

### 2.3 The implementation: every platform return code checked by hand

Nothing in the type system detects `setVoice` returning 0. **`flutter_tts` calls `result.success(0)` after only a `Log.d` — it never throws.** The sealed type only guarantees the failure *propagates once detected*. **You must write the detection.**

```dart
final class FlutterTtsSpeechService implements SpeechService {
  static const _ttsSuccess = 1;
  static const _speakTimeout = Duration(seconds: 8);

  @override
  @useResult
  Future<SpeakOutcome> speak(String text) async {
    final voice = _settings.voice;
    if (voice == null) return NoVoiceSelected(text);
    if (voice.notInstalled) {
      return VoiceNotInstalled(text, voiceName: voice.name);
    }

    // THE bug this app exists to prevent. Unchecked, this is a user in crisis
    // tapping a tile and getting silence, with only a Log.d on a device we
    // will never see.
    final set = await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
    if (set != _ttsSuccess) {
      return VoiceUnavailable(text, voiceName: voice.name);
    }

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

### 2.4 The call site

```dart
// No `default:`. No `case _:`. Ever.
Future<void> _speakAndShow(String vocalization) async {
  final outcome = await _speech.speak(vocalization);
  switch (outcome) {
    case SpokeAloud():
      return;
    // Matching the intermediate sealed type IS exhaustive — VERIFIED. Adding a
    // new SpeakFailure variant does not break this switch, which is correct:
    // every failure resolves the same way. The user sees the words.
    case SpeakFailure(:final spokenText, :final logLine):
      _log.record('speak failed: $logLine', StackTrace.current);
      _showText(spokenText);
  }
}
```

**VERIFIED:** dropping a branch is `non_exhaustive_switch_statement`, reported by `dart analyze` **and** by `dart compile` (`Error: AOT compilation failed`). `analyzer: errors: non_exhaustive_switch_statement: ignore` silences `dart analyze` but the **compile still fails** — so CI must actually build, not just analyze.

---

## 3. "No failure may be silent" — as concrete rules

### 3.1 The hole no lint can see (VERIFIED — the most important thing in this file)

I probed all four callback shapes with `discarded_futures`, `unawaited_futures`, **and** `@useResult`/`unused_result` all promoted to `error`:

| Code | Diagnostics |
|---|---|
| `onTap: () => s.speak('A')` | **NONE. Zero. All three miss it.** |
| `onTap: () { s.speak('B'); }` | `discarded_futures` + `unused_result` |
| `onTap: () async { s.speak('C'); }` | `unawaited_futures` + `unused_result` |
| `onTap: () => c.speakNow('D')` | clean — the fix |

The arrow closure *returns* the Future, so every rule considers it used. But the target type is `VoidCallback`, so Dart's void-compatibility silently discards it — **the Future and its error both vanish**. This is the single most idiomatic way to wire a Flutter tile and it is exactly this app's silence bug.

**The fix is structural, not disciplinary. A callback must never touch a Future.**

```dart
// lib/speech/speech_controller.dart
final class SpeechController {
  SpeechController(this._speech, this._log, this._showText);
  final SpeechService _speech;
  final CrashLog _log;
  final void Function(String) _showText;

  /// VOID-RETURNING ON PURPOSE. Do not "improve" this to return a Future.
  ///
  /// `onTap: () => c.speakNow(p)` is safe precisely because there is no Future
  /// to drop. VERIFIED: `onTap: () => speech.speak(p)` is caught by NO lint —
  /// not discarded_futures, not unawaited_futures, not @useResult. This method
  /// makes that hole unreachable by construction.
  void speakNow(String vocalization) {
    unawaited(
      _speakAndShow(vocalization).catchError((Object e, StackTrace s) {
        // _speakAndShow should not throw — speak() returns outcomes. If we
        // land here, the crash log or the fallback UI threw. Show the words
        // anyway; that is the product.
        _log.record('speak path threw: $e', s);
        _showText(vocalization);
      }),
    );
  }

  Future<void> _speakAndShow(String vocalization) async { /* §2.4 */ }
}
```

`unawaited` is the explicit, greppable escape hatch. It documents that discarding is intended and `catchError` guarantees the failure surfaces.

### 3.2 The rule table

| Hazard | Rule | Enforcement |
|---|---|---|
| Dropped Future in an async body | Always `await` or `unawaited(...)` | `unawaited_futures: error` |
| Future-returning call in a sync body | Same | `discarded_futures: error` |
| **Future in an arrow callback** | **`speakNow` returns void** | **Nothing. Structural only.** |
| Discarded outcome (`await speak(x);`) | `@useResult` on the method | `unused_result: error` — VERIFIED, default is only a *warning* |
| New failure variant nobody handles | sealed + no `default:` | **compile error** |
| Swallowed exception | `on` clause on every catch except the crash log | `avoid_catches_without_on_clauses`, `empty_catches: error` |
| Leaked StreamController | close it in `dispose()` | `close_sinks` — **needs `linter: rules:`, see §11** |
| Untyped platform-channel payload | parse via `tryParse`, never cast | `avoid_dynamic_calls: error` |
| Lost stack trace | `rethrow`, never `throw e` | review |

`throw e` resets the stack to the rethrow line. With no crash reporting, the trace in the on-device log is the *entire* forensic record.

### 3.3 The one licensed silent catch

```dart
void record(String message, StackTrace? stack) {
  try {
    // ... bounded, synchronous, flushed write ...
  } catch (_) {
    // INTENTIONAL bare catch, INTENTIONALLY discarded.
    //
    // This runs inside FlutterError.onError and PlatformDispatcher.onError.
    // If it throws, the error handler's error re-enters the error handler and
    // recurses until the app dies.
    //
    // Effective Dart says never silently discard from a bare catch. This is
    // the one place in this codebase where that rule is wrong. Do NOT "fix"
    // this by rethrowing or by logging to the same file.
  }
}
```

The comment is load-bearing. Without it someone converts this into infinite recursion.

---

## 4. Immutability, const, copyWith

**Verdict on freezed: skip it.** freezed 3.2.5 is alive and maintained (~Feb 2026) — this is not a "dead package" argument. It's redundant. drift's generator **already** emits immutable row classes with `==`, `hashCode`, `toString`, and `copyWith` for every table — the exact list freezed is recommended for. Adding it means a second generator producing overlapping output on the same classes, plus a hand-written drift-row→freezed-model mapping layer. That mapping is the "separate API and domain models" pattern Flutter's own docs rate *Conditional* with **"Use in large apps"**. There is no API here.

The decision rule:

| Shape | Use |
|---|---|
| Persisted (boards/buttons/grid_slots/images/sounds/settings) | **drift's generated row class, directly.** It IS the domain model. Write nothing |
| Ephemeral multi-return inside one layer | **a record** — `(int row, int col)` |
| Sealed variant (`SpeakOutcome`, `SpeakFailure`) | **`final class`, `const` ctor, `final` fields.** No `==` needed — you switch on the type, you don't compare instances |
| A joined shape drift generates no class for | **hand-written.** Drift emits a row class per *table*, never per join; a displayable tile is `grid_slots ⟕ buttons ⟕ images`, so `Tile` is hand-written |
| Must be a Map key and isn't the above | manual `==` + `Object.hash(...)` — 5 lines. This is the only thing `equatable` would buy |

**On `const`:** the mechanism is real — const expressions are canonicalized at compile time, so two identical `const` widgets are the *same object*, which makes `Element.updateChild`'s `child.widget == newWidget` check true by identity and prunes the subtree rebuild. At 12 tiles with a zero-animation rule, rebuilt approximately never, the runtime saving is unmeasurable.

Keep `prefer_const_constructors` on anyway, for two non-performance reasons: `dart fix --apply` writes it for you, and `const` tells the stranger "this widget has no dynamic inputs". **Budget for hand-tuning const: zero minutes.**

---

## 5. Widget conventions

### Extract a widget, not a method

```dart
// WRONG — a method. Its output is part of the PARENT's build. The parent
// rebuilds, this rebuilds, and there is no Element boundary to stop it. It
// also cannot be const, and it cannot be found by find.byType in a test.
Widget _buildTile(BuildContext context, GridSlot slot) { ... }

// RIGHT — a widget. Gets its own Element and its own const-ness.
class PhraseTile extends StatelessWidget { ... }
```

The honest framing: at 12 tiles this buys **no measurable performance**. It buys a testable unit, a const-able subtree, and a name a stranger can grep. That's enough. Do not extract widgets *for speed* — there is no frame budget to miss here.

### Keys

Keys matter when the framework must decide whether an Element can be reused for a new Widget at the same position. The classic bug: a tile's `button_id` flips `null → set`, the Element and its State are reused, and stale State leaks into the new tile.

**Our schema sidesteps this entirely.** `PRIMARY KEY (board_id, row, col)` means position is stable and slots never reorder. So: **`ValueKey((row, col))` on the slot, and stateless tiles.** No key-per-button, no `ObjectKey`, no `GlobalKey`. If a tile ever needs `State`, that's the signal to reconsider — not to add a key.

### Gestures

**Tap only.** No long-press, no drag, no swipe, no double-tap, anywhere in the speaking surface.

```dart
// WRONG — InkWell animates. splashFactory: NoSplash.splashFactory kills only
// the SPLASH; InkResponse.updateHighlight() independently creates an
// InkHighlight with a 200ms pressed fade.
InkWell(onTap: onTap, child: face)

// RIGHT — no ink, no animation, no second frame scheduled.
GestureDetector(
  behavior: HitTestBehavior.opaque, // the whole cell is the target
  onTap: onTap,
  child: face,
)
```

Zero animation is a design rule (distress + latency). It is enforced by a test asserting `tester.binding.hasScheduledFrame` is `false` after a single `pump()` following a tap.

---

## 6. Accessibility is a coding standard

Not a checklist item. **There is no lint for any of this** — `flutter_lints` and `very_good_analysis` ship zero a11y rules, and the only free candidate (`accessibility_lint`) is abandoned. So it lives in code review of your own diff, in the widget itself, and in `test/ui/`.

```dart
// ============================ WRONG ============================
class PhraseTile extends StatelessWidget {
  const PhraseTile({super.key, required this.button, required this.onTap});
  final Button? button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(   // (1) BANNED
      maxScaleFactor: 1.3,
      child: InkWell(                            // (2) animates
        onTap: onTap,
        child: Column(
          children: [
            const Icon(Icons.warning),           // (3) no semanticLabel
            Text(
              button?.label ?? '',               // (4) no Semantics: no button
              style: const TextStyle(            //     role, no label for an
                fontSize: 18,                    //     empty slot
                fontWeight: FontWeight.normal,   // (5) ignores boldText
              ),
              overflow: TextOverflow.ellipsis,   // (6) HIDES the overflow bug
            ),
          ],
        ),
      ),
    );
  }
}
```

1. `MediaQuery.withClampedTextScaling` is **the single most dangerous API for this app** — it is the one-line "fix" a future contributor reaches for when an overflow test goes red, and it silently defeats the entire text-scale matrix while contrast and tap-size still pass. Banned; enforced by a source-grep test (§10).
2. Ink ripples are animation.
3. An unlabeled `Icon` is invisible to a screen reader.
4. No `Semantics` → no button role → `labeledTapTargetGuideline` has nothing to check, and an empty slot is announced as tappable.
5. Hardcoding `fontWeight` throws away `boldText`.
6. `ellipsis` turns "the label doesn't fit at 200%" from a loud test failure into **a truncated word a user in crisis cannot read**. Fix the layout; never hide the overflow.

```dart
// ============================ RIGHT ============================
class PhraseTile extends StatelessWidget {
  const PhraseTile({super.key, required this.slot, required this.onSpeak});

  final GridSlot slot;
  final void Function(int row, int col) onSpeak;

  @override
  Widget build(BuildContext context) {
    // Platform a11y state is read HERE, from BuildContext, at build time.
    // MediaQuery is ALREADY an InheritedWidget with correct-by-construction
    // invalidation. It must NEVER go through Riverpod: that would trade a
    // compiler-guaranteed rebuild for a manual push-and-sync that is stale for
    // one frame — in the one area where being wrong is total failure.
    //
    // App state comes from Riverpod. Platform a11y state comes from context.
    final boldText = MediaQuery.boldTextOf(context);
    final highContrast = MediaQuery.highContrastOf(context);
    // NOTE: textScaler is deliberately NOT read and NOT clamped. Text scales
    // itself. Our job is to build a layout that survives it.

    final button = slot.button;

    if (button == null) {
      // grid_slots.button_id is NULLABLE. An empty cell HOLDS ITS SPACE —
      // it never collapses and pulls the next tile into its position.
      // Reflow is the bug this whole schema exists to prevent.
      return Semantics(
        label: 'Empty tile, row ${slot.row + 1}, column ${slot.col + 1}',
        button: false,
        child: const SizedBox.expand(),
      );
    }

    return Semantics(
      container: true,
      button: true,
      // The DISPLAY label. NEVER the vocalization. A screen-reader user
      // scanning the grid must hear "Overwhelmed", not the whole sentence.
      // Nothing in the type system distinguishes these two Strings — this is
      // the assertion the a11y test makes explicitly.
      label: button.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Resolve at TAP time from the immutable (row, col) primary key.
        // Capturing button.vocalization into this closure speaks a STALE
        // sentence on a fast re-tap — the wrong words, out loud, on behalf of
        // someone who cannot verbally correct it.
        onTap: () => onSpeak(slot.row, slot.col),
        child: ExcludeSemantics(
          // The Text below renders the label visually; the Semantics node
          // above already announces it. Without this, it is said twice.
          child: _TileFace(
            label: button.label,
            bold: boldText,
            highContrast: highContrast,
          ),
        ),
      ),
    );
  }
}
```

Non-negotiables, restated as rules:

- **Every interactive node gets `Semantics`** with `button: true` and a label.
- **Every `Icon` and `Image` gets a `semanticLabel`**, or is wrapped in `ExcludeSemantics` because it is decorative. There is no third option.
- **Never clamp `TextScaler`.** Never call `withClampedTextScaling`. Never read `textScaleFactor` (deprecated in favour of `TextScaler` precisely to support Android 14's nonlinear scaling).
- **Never `TextOverflow.ellipsis` on a phrase label.** Let it overflow loudly in tests.
- **Honour `boldText` and `highContrast`.** `disableAnimations` is moot — we have none.
- Assert semantics with **`isSemantics(...)`**, not `containsSemantics(...)` — the latter is deprecated after v3.40.0-1.0.pre and we are past that.

---

## 7. Naming and files

Per [Effective Dart](https://dart.dev/effective-dart/style), narrower than folklore:

- `lowercase_with_underscores` — files, directories, import prefixes.
- `UpperCamelCase` — types and extensions.
- **`lowerCamelCase` for constants**, not `SCREAMING_CAPS`. (`const kRows` is fine; the `k` prefix is a house style, not a rule.)
- Acronyms >2 letters capitalize as words (`Http`, `Uri`); two-letter ones stay caps (`ID`, `UI`); an abbreviation *starting* a lowerCamelCase identifier stays lowercase (`httpConnection`).
- Directive order: `dart:` → `package:` → relative, exports last, each section alphabetized (`directives_ordering`).
- **Pick `always_use_package_imports`.** `prefer_relative_imports` and `always_use_package_imports` are [explicitly incompatible](https://dart.dev/tools/linter-rules/prefer_relative_imports) — mixing them lets the same member be imported two ways, producing two distinct types at runtime. `package:` imports survive file moves and are greppable.
- Name classes for the architectural role: `SpeechService`, `BoardRepository`, `BoardScreen`. Never a name confusable with a Flutter SDK type.

---

## 8. Comments and dartdoc

The exit plan is open-sourcing an app that may be abandoned. Comment accordingly.

**Document these — every one looks like a mistake to a competent reader:**

| Thing | What the comment must say |
|---|---|
| `GridSlots.primaryKey` | Position IS identity. A nullable FK inside a composite PK is **not** a normalization error — it is what makes reflow structurally impossible. Adding a surrogate `id` reintroduces the exact failure this prevents |
| `Buttons.vocalization` | `label` is what the tile SHOWS; `vocalization` is what it SPEAKS. Different on purpose (Open Board Format). "Overwhelmed" / "I need to leave, I'm not able to talk right now" |
| `speakNow`'s void return | The verified lint hole. Do not "improve" this to return a Future |
| The `setVoice != 1` check | Not paranoia. `flutter_tts` returns 0 with only a `Log.d` |
| audio session `.playback` | Not an oversight. `.ambient` lets the hardware silent switch mute the app — and `flutter_tts`'s own README example uses `.ambient` |
| `CrashLog`'s bare catch | Why the Effective Dart violation is correct here |
| The Riverpod providers | Riverpod is **not load-bearing**. It is a test seam. `ValueNotifier` would work |

Put these **at the point of temptation** — a doc comment on the table definition, not prose in `docs/`. The person about to add a surrogate `id` is standing in `tables.dart` when they get the idea.

**Do NOT comment:** what the code already says (`// increment i`), obvious getters, private widget internals, every public member (`public_member_api_docs` is off — it's a *package author's* rule and this is an app). A doc comment starts with a single-sentence summary.

---

## 9. Async rules

### The async-gap `BuildContext` bug

```dart
// WRONG — use_build_context_synchronously
Future<void> _save() async {
  await _repo.saveTile(tile);        // ← the async gap
  Navigator.of(context).pop();       // the widget may be GONE. `context` now
}                                    // points at a defunct Element.

// RIGHT
Future<void> _save() async {
  final navigator = Navigator.of(context); // capture BEFORE the gap
  await _repo.saveTile(tile);
  if (!mounted) return;                    // or use the captured navigator
  navigator.pop();
}
```

`await` yields to the event loop. Anything can happen while suspended — the route pops, the widget is disposed, the Element is defunct. `context` is not a value, it's a *handle into a live tree*. This is a live hazard in edit mode (await a drift write, then pop the dialog) and it is why `use_build_context_synchronously` is promoted to `error`.

`ref.mounted` (Riverpod 3.x) is the same guard for a Notifier writing state after an await.

### Subscriptions and sinks

Every `StreamSubscription` gets cancelled; every `StreamController` gets closed. Enforced by `cancel_subscriptions` and `close_sinks` — **but see §11: `close_sinks` only fires if you enable it under `linter: rules:`.**

### Never call a side effect from `build()`

```dart
// WRONG — Flutter: "A widget's build function should be free of side effects...
// Whenever the function is asked to build, the widget should return a new tree
// of widgets, regardless of what the widget previously returned."
@override
Widget build(BuildContext context) {
  _speech.speak(phrase); // rebuilds are triggered by things you don't control
  return ...;            // (a11y flags, voice-availability). Duplicate speech.
}
```

Route all speech through an explicit user-event handler.

### Zones and global error capture

**No `runZonedGuarded`.** Flutter's own [zone-errors breaking-change doc](https://docs.flutter.dev/release/breaking-changes/zone-errors) says the fix for the zone-mismatch warning is to *remove zones from the application*, and [testing/errors](https://docs.flutter.dev/testing/errors) shows only two handlers. The "use all three" advice circulating in 2026 is **crash-SDK advice** — Sentry needs a zone because it wraps init. We have no SDK, so the zone is pure footgun.

```dart
void main() async {
  // Same function body as runApp(): no zone, no zone-mismatch warning.
  WidgetsFlutterBinding.ensureInitialized();
  final log = await CrashLog.open();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.record(details.exceptionAsString(), details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      log.record(error.toString(), stack);
      if (kDebugMode) debugPrint('$error\n$stack'); // our visibility
    } catch (_) {
      // never let the handler throw
    }
    // ALWAYS true. Returning false routes to the embedder's
    // unhandled_exception_callback, and api.flutter.dev warns "the VM or the
    // process may exit or become unresponsive" — the one behaviour a crisis UI
    // cannot tolerate. debugPrint above gives debug visibility for free, so
    // `return kReleaseMode` buys nothing and costs that risk.
    return true;
  };

  runApp(const AacApp());
}
```

---

## 10. The banned list

| Banned | Why | Enforced by |
|---|---|---|
| Any network call, `http`, `dio`, socket | The privacy promise is the product; there is no network permission | Code review + the manifest has no `INTERNET` |
| Firebase, Crashlytics, Sentry, any analytics | Same. The audience reads privacy labels adversarially | Absent from `pubspec.yaml` |
| `MediaQuery.withClampedTextScaling` | Silently defeats the entire text-scale matrix | **Source-grep test over `lib/`** |
| `textScaleFactor` | Deprecated; and its use is almost always a clamping hack | Same grep |
| `TextOverflow.ellipsis` on a phrase label | Turns a loud test failure into unreadable text | Code review |
| Any animation, ink ripple, implicit `Animated*` | Zero-animation design rule | `hasScheduledFrame == false` test |
| `print` / `debugPrint` in `lib/` (outside the `kDebugMode` error handler) | Use the on-device exportable crash log | `avoid_print: error` |
| `dynamic` calls | Everything from a platform channel is `Map<Object?, Object?>` | `avoid_dynamic_calls: error` |
| `default:` / `case _:` on a sealed type | Disables the only compiler-grade net we have | Code review — a `default:` makes the switch compile |
| `assert` on a platform return value | Stripped in release. Green in tests, absent on the device | Code review |
| `throw e` inside a catch | Resets the stack trace, which is our only forensic record | Use `rethrow` |
| `pumpAndSettle` in tests | Zero animation means one frame settles it. `pumpAndSettle` adds only a 10-min-timeout flake vector with truncated traces. **Caveat: `pump()` does not advance the fake clock — time-based async needs `pump(duration)`** | Grep test over `test/` |
| `overrideValue` | **Does not exist.** It is `overrideWithValue` | compiler |
| `containsSemantics` | Deprecated after v3.40.0-1.0.pre. Use `isSemantics` | `deprecated_member_use: warning` |
| A `FakeBoardRepository` | A Map-backed fake accepts rows the real `PRIMARY KEY (board_id, row, col)` rejects and never runs a migration step. Test against `NativeDatabase.memory()` — real sqlite3 | Code review |
| `package:provider`, `custom_lint`, `freezed`, `equatable`, `go_router`, `melos`, `glados` | See §4 and `ARCHITECTURE.md` | `pubspec.yaml` review |
| Any `--enable-experiment` flag | An abandoned repo that needs an experiment to build stops building | `pubspec.yaml` review |

The three source-grep tests are ~10 lines each and they exist because **no lint can do this**. That is not a workaround; it is the only enforcement available.

---

## 11. `analysis_options.yaml`

The repo's current file has **one verified defect** and **one verified omission**. Both are fixed below.

```yaml
# =============================================================================
# analysis_options.yaml — Offline AAC
#
# This app ships with NO telemetry. We will never learn that it crashed in the
# field, and our users cannot speak to report it. The analyzer and the test
# suite are the ONLY two things between a defect and someone tapping
# "I need to leave" and hearing NOTHING.
#
# Every promotion to `error` below is a bug class that produces SILENCE.
#
# VERIFIED against the SDK installed on this machine:
#   Dart 3.11.0 / Flutter 3.41.2
#   very_good_analysis 10.2.0   riverpod_lint 3.1.4
# This exact file was run through `dart analyze` on a probe project.
# =============================================================================

# VGA already sets strict-casts + strict-inference + strict-raw-types, so
# there is no `language:` block below — it would be redundant.
#
# The VERSION-PINNED include is deliberate. On a project that may be
# abandoned, `pub upgrade` must never silently change what counts as an error.
#
# !! TRAP !! If this filename does not exist in the RESOLVED package you get
# only `warning • include_file_not_found` and analysis continues with ZERO
# rules — a green build that checks nothing. VGA 10.3.0 requires Dart 3.12
# (Flutter 3.44), so bump this include IN THE SAME COMMIT as the SDK bump, and
# verify:  ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/
include: package:very_good_analysis/analysis_options.10.2.0.yaml

# -----------------------------------------------------------------------------
# LINTER — rules VGA does not enable at all.
#
# !! THIS BLOCK IS LOAD-BEARING AND WAS MISSING !!
# `analyzer: errors:` only RE-RANKS diagnostics that are already generated. It
# cannot enable a lint that is off. VGA never lists close_sinks under its
# `linter: rules:` (it only sets `close_sinks: ignore` in its errors block, a
# vestigial no-op). VERIFIED: with `errors: close_sinks: error` alone, a
# never-closed StreamController produced NO diagnostic. With this block, it
# reports as an error for BOTH local and field-held controllers, and correctly
# stays silent when the field is closed in dispose().
# -----------------------------------------------------------------------------
linter:
  rules:
    - close_sinks

analyzer:
  exclude:
    - "**/*.g.dart"          # drift, json_serializable
    - "**/*.drift.dart"      # drift
    - "**/generated_plugin_registrant.dart"
    # drift's exported schema snapshots. Historical artifacts — a lint autofix
    # here would corrupt the migration-test baseline, and a botched migration
    # is the loss of someone's voice. Safe to exclude BECAUSE migration
    # correctness is enforced by drift's schema tests, not by lints.
    - "test/drift/generated/**"

  errors:
    # ---------------------------------------------------------------------
    # TIER 0 — DISCARDED OUTCOMES. The single highest-value line in this file.
    #
    # `@useResult` (package:meta) on SpeechService.speak makes
    # `await speak(text);` — which discards the SpeakOutcome and compiles
    # perfectly clean otherwise — into a build failure.
    #
    # VERIFIED: the default severity is only a WARNING. Without this promotion
    # it is a yellow squiggle a solo dev with no reviewer scrolls past.
    # ---------------------------------------------------------------------
    unused_result: error

    # ---------------------------------------------------------------------
    # TIER 1 — DROPPED FUTURES. A dropped Future is a phrase never spoken.
    #
    # !! THE HOLE THESE DO NOT COVER — VERIFIED !!
    # `onTap: () => tts.speak('x')` is flagged by NONE of the three:
    # not discarded_futures, not unawaited_futures, not unused_result. The
    # arrow closure "returns" the value, so every rule considers it used — but
    # the target type is VoidCallback, so Dart discards it silently.
    #
    # MITIGATION IS STRUCTURAL: SpeechController.speakNow(String) returns VOID
    # and internally does unawaited(_speak(p).catchError(...)). A callback then
    # never holds a Future and the hole is unreachable. Verified clean.
    # ---------------------------------------------------------------------
    unawaited_futures: error       # unawaited Future inside an async body
    discarded_futures: error       # Future-returning call in a SYNC body

    # ---------------------------------------------------------------------
    # TIER 2 — SWALLOWED FAILURE. flutter_tts returns 0 and writes only a
    # Log.d. If we swallow too, failure is invisible at every layer.
    # ---------------------------------------------------------------------
    empty_catches: error
    avoid_catches_without_on_clauses: error
    only_throw_errors: error
    throw_in_finally: error        # silently replaces the real exception

    # ---------------------------------------------------------------------
    # TIER 3 — ASYNC + UI. After an `await` the widget may be disposed and
    # `context` is a handle into a dead tree. Live hazard in edit mode.
    # ---------------------------------------------------------------------
    use_build_context_synchronously: error

    # ---------------------------------------------------------------------
    # TIER 4 — LEAKS. close_sinks is enabled in the `linter:` block above;
    # this only promotes info -> error. Both lines are required.
    # ---------------------------------------------------------------------
    cancel_subscriptions: error
    close_sinks: error

    # ---------------------------------------------------------------------
    # TIER 5 — TYPE HOLES. Personal Voice (iOS), the QS TileService and the
    # ControlWidget all hand us Map<Object?, Object?>. An unguarded dynamic
    # call throws at runtime, on a device, with no telemetry to tell us.
    # ---------------------------------------------------------------------
    avoid_dynamic_calls: error
    always_declare_return_types: error
    cast_nullable_to_non_nullable: error

    # ---------------------------------------------------------------------
    # TIER 6 — EXHAUSTIVENESS.
    # Non-exhaustive switches on SEALED types are already a COMPILE error
    # (non_exhaustive_switch_statement) — VERIFIED at both `dart analyze` and
    # `dart compile`. That is the main reason SpeakOutcome is sealed rather
    # than an enum. NOTE: `errors: non_exhaustive_switch_statement: ignore`
    # CAN silence `dart analyze` — but `dart compile` still fails. CI must
    # BUILD, not just analyze.
    #
    # This lint covers only the legacy enum-like (static-const-instance) case.
    # ---------------------------------------------------------------------
    exhaustive_cases: error

    # ---------------------------------------------------------------------
    # TIER 7 — SHIPPING HYGIENE. No reviewer exists on a solo project.
    # ---------------------------------------------------------------------
    avoid_print: error             # use the on-device exportable crash log
    avoid_slow_async_io: error     # tile images are files read near render

    # NOT error: never let a Flutter upgrade block an urgent hotfix for
    # someone who cannot speak.
    deprecated_member_use: warning
    deprecated_member_use_from_same_package: warning

    # ---------------------------------------------------------------------
    # DELIBERATE DOWNGRADES — proportionality for a solo dev, 2-week MVP.
    # ---------------------------------------------------------------------
    # A PACKAGE author's rule. This is an app with no consumers. A doc comment
    # on every public member costs hours and trains you to ignore lints — a
    # real cost when lints are one of only two safety nets. Readability comes
    # from doc comments on the SEAMS (see §8), enforced by taste.
    public_member_api_docs: ignore
    # The formatter already wraps code; this only fires on things it cannot
    # split — long strings and URLs in comments.
    lines_longer_than_80_chars: ignore

# -----------------------------------------------------------------------------
# ANALYZER PLUGINS — first-party plugin system (Dart 3.10+).
#
# riverpod_lint 3.x runs on `analysis_server_plugin`. Do NOT add custom_lint:
# the legacy plugin system it is built on is scheduled for deprecation as early
# as Dart 3.12 — the next SDK.
#
# Syntax (verified): with a pub version you MUST use the `version:` key.
# `riverpod_lint: ^3.1.4` with nested `diagnostics:` is a YAML parse error.
# Plugin WARNINGS are on by default; plugin LINTS are off and must be opted in.
# Suppress with:  // ignore: riverpod_lint/missing_provider_scope
#
# NOTE: each diagnostic is reported TWICE under `flutter analyze` while a
# plugin is active. Cosmetic, but any CI issue-COUNT threshold will be wrong.
# -----------------------------------------------------------------------------
plugins:
  riverpod_lint:
    version: ^3.1.4
    diagnostics:
      # No ProviderScope => every provider read throws on the first tap.
      missing_provider_scope: true
      avoid_ref_inside_state_dispose: true
      avoid_public_notifier_properties: true
      async_value_nullable_pattern: true
      # Reads BuildContext inside a provider. Note: our MediaQuery rule (§6)
      # rests on Flutter-architecture grounds, NOT on this lint — do not treat
      # this rule as the reason.
      avoid_build_context_in_providers: true

      # OFF — generator-syntax rules; we hand-write our ~6 providers.
      functional_ref: false
      notifier_extends: false
      notifier_build: false
      riverpod_syntax_error: false
      # OFF — grep of riverpod_lint 3.1.4's source shows this rule references
      # riverpod_generator internals; without codegen it is dead config.
      # <!-- VERIFY: probe with a hand-written provider before re-enabling -->
      provider_dependencies: false

# -----------------------------------------------------------------------------
# FORMATTER (Dart 3.7+ "tall style"). Style is chosen by the language version
# in pubspec.yaml, not by config — on Dart 3.11 there is nothing to opt into.
#
# trailing_commas: preserve — a trailing comma forces a split. The default
# ("automate") lets the formatter collapse widget trees onto one line. For a
# grid a stranger must read cold, one-argument-per-line is worth the vertical
# space and keeps layout diffs minimal.
# -----------------------------------------------------------------------------
formatter:
  page_width: 80
  trailing_commas: preserve
```

---

## What this file deliberately does not do

A green analyzer is not an accessible app, is not a surviving migration, and — as §3.1 proves — **is not even proof that a tile speaks**. The three highest-severity failure modes in this codebase (`.ambient` muting on the silent switch, the engine reporting success while emitting no audio, a stale Quick Settings phrase) are invisible to every rule in this file and to every automated test that exists in 2026.

That is what `docs/CHECKLIST.md` is for. It is not a chore; it is the safety net.
