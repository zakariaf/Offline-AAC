---
name: reed-dart3-idioms
description: "Which Dart 3 construct a declaration earns — sealed vs enum, `final class` vs `abstract interface class` seams, records as intra-layer tuples only, switch expressions, if-case, Effective Dart naming. Use when writing any type or class declaration, choosing between class/enum/record/typedef, reaching for `extension type`, `freezed`, `equatable`, `fpdart` or `dartz`, adding `default:` or `case _:`, or naming a constant, file or import prefix. Not for the speech failure set or its handlers."
---

# Dart 3 idioms in Reed

Reed is an offline AAC app: one 3x4 grid of phrase tiles, on-device TTS, no network, no telemetry, no crash reporting. Nobody will ever tell us the app failed — the user is non-speaking at exactly the moment it matters. The analyzer, the compiler and the test suite are the entire feedback loop. That single fact decides which language features are worth their weight: a feature earns its place here if it converts a runtime silence into a **compile error**. Everything else is decoration.

## The verdict table

| Feature | Verdict | Why |
|---|---|---|
| `sealed class` + exhaustive `switch` | **Use.** The backbone | A missing branch is a compile error, not a lint. The only compiler-grade safety net in the codebase |
| Destructuring patterns (`case SpeakFailure(:final spokenText)`) | **Use** | Pulls the payload out at the one place it is needed, with no getter chain |
| Records for ephemeral tuples (`(int row, int col)`) | **Use, inside one layer only** | Free structural equality, no package, no codegen |
| `final class` for sealed variants | **Use** | Closes the hierarchy; the variant list is the file |
| `abstract interface class` for seams | **Use** | Says "implement me, don't extend me" — exactly the contract a test fake needs |
| `@immutable` + `const` ctor + `final` fields | **Use** | Four lines replaces a code generator |
| `enum` for closed sets with **no** payload | **Use sparingly** | Enums get compiler exhaustiveness too — but the moment a variant needs a field, convert to sealed |
| `base class` | **Skip** | Reed has no library-boundary inheritance to police. `final` or `sealed` covers every real case |
| Extension types | **Skip** | Explicitly an *unsafe* abstraction — the representation type is never a subtype and the underlying object stays reachable. Ceremony at every boundary for safety twelve tiles do not need |
| Primary constructors | **Skip** | Still behind `--enable-experiment=primary-constructors`, despite blog posts saying otherwise. An abandoned repo must never need an experiment flag to build |
| Macros | **Dead** | Cancelled. Not coming. `build_runner` is not going away |
| `freezed`, `equatable`, `fpdart`, `dartz` | **Skip** | See "What not to reach for" |

## Sealed classes: the load-bearing idiom

Model a closed set of *individually actionable* failures as one sealed hierarchy in one file. `sealed` requires every subtype to live in the same library — that is the point: the file **is** the closed set and the compiler enforces it.

```dart
@immutable
sealed class SpeakOutcome {
  const SpeakOutcome();
}

final class SpokeAloud extends SpeakOutcome {
  const SpokeAloud();
}

/// The phrase was NOT spoken. The caller MUST show [spokenText] instead.
@immutable
sealed class SpeakFailure extends SpeakOutcome {
  const SpeakFailure(this.spokenText);
  final String spokenText;
  String get logLine; // one line for the on-device log; never shown to the user
}

final class VoiceUnavailable extends SpeakFailure {
  const VoiceUnavailable(super.spokenText, {required this.voiceName});
  final String voiceName;
  @override
  String get logLine => 'setVoice rejected "$voiceName"';
}
```

Rules that make this work:

- **Every failure variant carries the payload the caller needs to recover.** Here that is `spokenText`, so a failed `speak()` can always fall back to showing the words. A variant that says only "it broke" buys nothing over a bool.
- **Intermediate sealed types are legitimate.** Matching `case SpeakFailure(...)` is exhaustive on its own, and adding a new `SpeakFailure` subtype does not break that switch. That is correct when every failure resolves identically. Reach for an intermediate sealed layer exactly when a group of variants shares a uniform response — not to save typing.
- Sealed variants need no `==`/`hashCode`. Switching on the type is the whole interface; instances are never compared.

### Never write `default:` or `case _:` on a sealed type

A wildcard branch makes the switch compile forever, which discards the only compile-time guarantee the type exists for. Adding a variant then produces a *runtime* fall-through — silence, on a device nobody can report from.

```dart
// RIGHT — no default. Adding a variant is a compile error until handled.
switch (outcome) {
  case SpokeAloud():
    return;
  case SpeakFailure(:final spokenText, :final logLine):
    _log.record('speak failed: $logLine', StackTrace.current);
    _showText(spokenText);
}
```

Dropping a branch reports as `non_exhaustive_switch_statement` from `dart analyze` **and** fails `dart compile` with `AOT compilation failed`. Suppressing the analyzer diagnostic via `analyzer: errors:` does *not* make the build pass — so CI must actually build, not merely analyze. Never suppress it either way.

### No generic `Result<T>`

Do not introduce a generic sealed result type, including the one Flutter's architecture guide publishes. Its error arm is typed `Exception`, so matching it tells you *nothing about which failure occurred* — zero exhaustiveness, which is the entire property being bought. It also names a variant `Error`, shadowing `dart:core.Error` in every importing file. Carrying both a generic result and a domain outcome means two error vocabularies for one app. One hand-rolled sealed type per real decision point, zero dependencies.

## Class modifiers: reach for three, ignore the rest

Dart 3 ships `base`, `interface`, `final`, `sealed`, `mixin`, and their combinations. Reed uses three, and the choice is mechanical:

| Intent | Declaration |
|---|---|
| A closed set of variants the compiler must exhaust | `sealed class` (implicitly abstract, cannot be constructed or implemented outside the library) |
| A concrete leaf — a variant, a service impl, a controller | `final class` |
| A seam a test fake must satisfy | `abstract interface class` |

Default to `final class` for every concrete type. It blocks extension *and* implementation, which means a subclass can never silently inherit half a behaviour and no test can accidentally `implements` a concrete class and pick up its fields. When something genuinely needs subclassing, that is a design decision worth writing down — the compiler forces the conversation.

`abstract interface class SpeechService` is the seam contract: implementers must supply everything, and nobody can extend the interface to inherit a partial default. That is exactly what a swappable TTS layer and its in-memory fake want. Do not use a bare `abstract class` for a seam — it permits `extends`, and an inherited default on a service interface is how a fake ends up quietly calling the real engine.

Skip `base` entirely. It exists to force subclasses to preserve an implementation invariant across library boundaries. Reed publishes no library and has no such invariant; `final` or `sealed` covers every real case, and `base` mostly propagates itself virally down the hierarchy for nothing.

### Enum or sealed

Start with an `enum` when the set is closed and every member is genuinely payload-free — a display category, a mode. Enums get the same compiler exhaustiveness in a switch, and they cost one line each.

Convert to `sealed` + `final class` the moment **any** member needs a field. Do not bolt data onto an enum with a parallel `switch` returning strings, or an enum constructor plus nullable fields that only apply to some members — that shape makes every access a null check the compiler cannot reason about, and null-checks-that-are-really-variant-checks are how a failure path goes quiet.

## Records: where they win, where they cost

Use a record for an ephemeral multi-value return **inside a single layer**: `(int row, int col)` as a grid coordinate is ideal — structural equality free, no class, no codegen.

**Records never cross a layer boundary.** They have no name, no doc comment, and a positional shape that silently changes meaning when reordered. `(int, int)` is a coordinate inside the board layer; it is not a domain type. The moment a shape is returned from a repository, stored, passed to a widget constructor, or documented, it is a class.

Name record fields whenever the record survives more than a few lines: `({int row, int col})` reads at the use site; `(int, int)` does not. A positional record with two same-typed fields is a swap bug the compiler cannot see.

## What not to reach for

- **`freezed`** — redundant, not dead. drift's generator already emits immutable row classes with `==`, `hashCode`, `toString` and `copyWith` for every table. Adding freezed means a second generator on overlapping classes plus a hand-written row→model mapping layer. Persisted shapes use drift's generated row class *directly*; it is the domain model.
- **`equatable`** — the only thing it buys is `==` + `hashCode` on a type that must be a Map key. That is five lines: manual `==` plus `Object.hash(...)`.
- **`fpdart` / `dartz`** — an `Either` is a generic result type by another name, with the same loss of exhaustiveness plus an unfamiliar vocabulary.
- **Any `--enable-experiment` flag** — a repo that needs an experiment to build stops building the moment it is abandoned.

For a shape drift generates no class for — a join, e.g. a displayable tile assembled from grid slots, buttons and images — hand-write the class. Drift emits a row class per *table*, never per join.

## Switch expressions and if-case

Prefer a switch **expression** when every arm produces a value and no arm has a statement body. It is exhaustive by construction and cannot fall through:

```dart
final tone = switch (slot.category) {
  Category.need => palette.need,
  Category.state => palette.state,
  Category.exit => palette.exit,
};
```

Use a switch **statement** when arms perform effects (logging, showing text). Do not contort effects into an expression with a `void` sink.

Use `if (x case Pattern)` for a single interesting shape where a switch would be one real branch plus a dead one:

```dart
if (settings.voice case final Voice v when !v.notInstalled) {
  await _tts.setVoice({'name': v.name, 'locale': v.locale});
}
```

Do **not** use `if-case` on a sealed type — it silently reintroduces the non-exhaustive hole a switch would have caught.

## Naming: the rules actually violated

- `lowercase_with_underscores` — files, directories, **and import prefixes**.
- `UpperCamelCase` — types and extensions.
- **`lowerCamelCase` for constants, not `SCREAMING_CAPS`.** `const kRows = 4;` is fine; the `k` prefix is house style, not a rule. `const MAX_ROWS` is wrong.
- Acronyms longer than two letters capitalize as words: `Http`, `Uri`, `Tts` — not `HTTP`, `URI`, `TTS`. Two-letter ones stay caps: `ID`, `UI`. An abbreviation *starting* a lowerCamelCase identifier stays lowercase: `httpConnection`, `ttsEngine`.
- Directive order: `dart:` → `package:` → relative, exports last, each section alphabetized.
- **Always use `package:` imports.** `prefer_relative_imports` and `always_use_package_imports` are explicitly incompatible; mixing them lets the same member be imported two ways, producing two distinct types at runtime — a class that is not itself. `package:` imports also survive file moves and are greppable.
- Name a class for its architectural role: `SpeechService`, `BoardRepository`, `BoardScreen`. Never pick a name confusable with a Flutter SDK type.
- Do not `typedef` a record shape into existence to dodge the class decision. A named shape used across files wants a class.
