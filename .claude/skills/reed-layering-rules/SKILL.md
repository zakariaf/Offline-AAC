---
name: reed-layering-rules
description: Refuses the abstractions Reed deliberately rejects — lib/domain/, *UseCase, abstract repositories over BoardRepository or AppDatabase, the Command pattern's if (_running) return, package:provider, go_router, lib/routing/, freezed, barrel files, lib/src/, lib/utils/, 1:1 view-models, depth past two levels. Use when adding an abstract interface class, a Repository/Manager/Mapper wrapper, a DI/routing package, or proposing Clean Architecture. Not for which directory a permitted file goes in, or the Riverpod API surface itself.
---

# Reed layering: adopt the shape, refuse the ceremony

Reed is one screen, six tables, ~25 source files, one developer. Almost every abstraction that reads as "good architecture" was written for a team of ten and a network. This skill is a list of things **not** to build, each with the reason, so the reason survives contact with the next reader.

## The one rule everything else derives from

**Abstract exactly what cannot run in a test. Nothing else.**

Two things in this app qualify: `SpeechService` (the TTS platform cannot execute in `flutter test`) and the Personal Voice method channel. Everything else — drift, SQLite, the repositories, the crash log, the theme — runs inside `flutter test` against real `NativeDatabase.memory()` (actual sqlite3, not a fake). An interface over something that already executes in a test is a layer to read past on the way to the code.

There is no telemetry and there never will be. A user who cannot speak does not file a bug report. The compiler, the analyzer, and the test suite are the entire feedback loop — so every layer added is another place a bug hides from the only three things that can see it.

## The shape that is adopted

Three layers, named the way Flutter's own guidance names them, because it costs nothing and a stranger recognises `data/` and `ui/` on sight:

| Directory | Organised | Contents |
|---|---|---|
| `lib/data/` | **by type** | `AppDatabase`, `BoardRepository`, `SettingsRepository`, `speech/`, `media_store.dart`, `crash_log.dart`, `seed/` |
| `lib/ui/` | **by surface** | `board/`, `show_text/`, `edit/`, `settings/`, `core/tokens.dart` |
| `lib/native/` | by channel | every `MethodChannel` in the app; nothing else may create one |
| `lib/model/` | flat | exactly two hand-written types: the joined `Tile` and `BoardGrid` |

A Riverpod `Notifier` **is** the ViewModel — `BoardController` is the only one. Do not introduce a second concept.

**Layer-first at the top, surface-first inside `ui/`.** The four "features" (speak, show-text, edit, settings) are not features — they are four surfaces over one dataset. All four read and write the same tables. Slicing top-level by screen pushes `AppDatabase`, `BoardRepository`, `SpeechService`, and `voice_filter` — nearly every non-widget file — into a `shared/`, leaving four thin folders of widgets. At six tables in one tightly-joined graph, the entity graph *is* the data layer.

**Two directory levels, maximum.** `ui/board/view_models/board_controller.dart` is four levels to reach the only view model in the app. Directories are free; depth is a tax on every import line.

## The refusals

Each entry below is a decision, not an omission. Do not re-open one without a reason that is specific to this app.

### Domain layer / use-cases — never

Do not create `lib/domain/`, `lib/domain/use_cases/`, or a `*UseCase` class. Flutter's own guidance rates the domain layer *Conditional* and says outright that in most apps use-cases add unnecessary overhead, and that CRUD apps might not need the layer at all; its reference app has 2 use-cases across ~111 files. Every use-case here would wrap exactly one repository call. `SpeakSlotUseCase` calling `boardRepository.tileAt(row, col)` is a rename, not a boundary.

### Separate API models + domain models — never

There is no API. There is no network, no JSON over the wire, no server DTO. Mapping a drift row class to a hand-written mirror class maps a type onto itself, and the mapping function is a new place for `label`, `vocalization`, and `displayText` to get swapped — three `String`s the type system cannot tell apart, where getting them backwards means a stranger hears the wrong sentence on behalf of someone who cannot correct it verbally.

The only two hand-written model types are justified because drift **cannot** generate them: drift emits a class per table and never per join, so the joined `Tile` (`grid_slots ⟕ buttons ⟕ images`, two nullable FKs) has no generated equivalent; and `BoardGrid` — dimensions × nullable tiles — is a materialized shape the schema deliberately does not have.

### Abstract repositories with one implementation — never

`BoardRepository`, `SettingsRepository`, `CrashLog`, and `AppDatabase` are **concrete**. No `abstract interface class BoardRepository` with a single `DriftBoardRepository` under it.

```dart
// WRONG — an interface whose only content is the word "repository"
abstract interface class BoardRepository { Stream<BoardGrid> watchGrid(int id); }
final class DriftBoardRepository implements BoardRepository { /* ... */ }

// RIGHT — one concrete class, tested against real in-memory sqlite3
final class BoardRepository {
  BoardRepository(this._db);
  final AppDatabase _db;
  Stream<BoardGrid> watchGrid(int boardId) { /* ... */ }
}
```

The pattern's usual justification is swapping dev / staging / remote environments. There is one environment, no network, no auth. The test seam already exists and is one Riverpod `overrideWithValue`.

Worse, a fake would be actively harmful: a Map-backed `FakeBoardRepository` happily accepts a row that the real `PRIMARY KEY (board_id, row_index, col_index)` rejects, and never executes a migration step. A botched migration destroys a hand-curated board — months of someone's phrases, irreplaceable and unmergeable. That outranks the general advice to make fakes, which assumes the real dependency is a network. Here it is SQLite, and SQLite runs fine in a test.

Do not wrap `AppDatabase` in a DAO interface either: drift's generated API *is* the interface.

### The `Command` pattern — never

Its core is `if (_running) return;`. For a speak button, a re-tap means "say it again" / "I need this NOW". Swallowing it **is** the silence bug — the worst bug class in this app is a tap that produces nothing. `SpeechService.speak` already barges in: it stops any in-flight utterance and starts the new one.

```dart
// WRONG — the guard IS the bug
if (_running) return;

// RIGHT — barge-in. A re-tap always speaks.
await _speech.stop();
final outcome = await _speech.speak(text);
```

For an edit-mode DB write, a double-tap guard is one field — `bool _saving` — not a `ChangeNotifier` subclass with `running`, `error`, and `completed`.

### `package:provider` for DI — never

Riverpod is already a DI container, and `overrideWithValue` is the direct analogue of a scoped `Provider`. Two DI mechanisms is strictly worse than one: every reader must now learn which seam a given dependency travels through. Keep the six plain providers. No families, no scoping, no `@riverpod`, no codegen — Riverpod's cost curve is not in adoption, it is in that stack.

### `go_router` — never

Modes are **state, not routes**. Four destinations, no web surface, no animation. `Navigator.push` or a state flag covers it. The one thing a router would earn is deep linking, and the Android Quick Settings tile deliberately never launches Flutter — it calls Android's `TextToSpeech` directly, skipping FlutterActivity, engine init, Dart VM snapshot load, drift open, and first frame. There is no link to deep.

Do not create `lib/routing/`.

### `freezed` — never

drift already generates `==`, `hashCode`, `copyWith`, and `toString` for every row class. A second generator producing overlapping output — plus the hand-written mapping layer needed to feed it — buys nothing and doubles the build_runner surface. Use `@immutable` + `sealed`/`final class` by hand for the two model types; the sealed `SpeakOutcome` hierarchy is written by hand for the same reason.

### "Views and view models 1:1" — never

One screen. The rule either produces a god object or is vacuous. It is a team-coordination device: it stops two developers fighting over one class. There is one developer.

### Also deliberately absent

| Not built | Why |
|---|---|
| `lib/src/` | A package convention. An app has no external importers. |
| Barrel files | Measurable analyzer cost, circular-import risk, zero benefit at 25 files. |
| `lib/utils/` | A junk drawer. Name the thing after what it does — `voice_filter.dart`, not `tts_utils.dart`. |
| `packages/` + melos | Nothing to multiply. |
| `main_dev` / `main_staging` / `main_prod` | No environments. |
| A `SettingsService` | It is a key/value read from a table. `SettingsRepository` is already generous. |
| A theming abstraction | One `ThemeData` plus `ui/core/tokens.dart`. |
| A logger interface | If the logger needs a test double, the logger is too complicated to be a logger. |
| A QS-tile plugin / federated plugin | Federation exists so a domain expert can extend someone else's published plugin. One dev owns all of it, and the tile has no Dart at all. A plugin adds a platform_interface, version lockstep, and a publishing story in exchange for nothing. |

## The abstractions that ARE justified — and why, precisely

`SpeechService` is an `abstract interface class` with one real impl (`FlutterTtsSpeechService`) and one fake. It earns the 8 lines for exactly two reasons, and no others:

1. It cannot run in `flutter test`. Everything else in `data/` can.
2. `flutter_tts` is a bus-factor-1 MIT package. Healthy today; the day it is not, this interface makes vendoring it a one-file change instead of a refactor.

Note the shape this forces: the real impl is **as thin as possible**, and everything testable lives one layer up. `voice_filter` is a pure function over the raw voice list, no plugin import, 100% covered. That is where the bugs are — so that is where the tests must be able to reach.

The repository seam is real too, but be honest about what it buys: not swappable storage. It buys a one-line test override, a home for the join (somebody must unpack `List<TypedResult>` via `readTable()` / `readTableOrNull()`, and it must not be a widget), and a home for `BoardGrid`. That is why it exists as a class — not as an interface.

## When someone proposes "proper layering"

Answer with the size and the reason, not with taste. Reed is not under-architected; it is architected to the size it is. Every layer that does not carry a load is a place where a silent failure — a tap that speaks nothing, a migration that copies zero rows — can hide from the compiler, the analyzer, and the tests, which are the only three things that will ever notice. An inaccessible or silent AAC app is a total failure, not a code smell.

Adding an abstraction requires naming what it makes testable that was not testable before. If the answer is "it's cleaner", the answer is no.
