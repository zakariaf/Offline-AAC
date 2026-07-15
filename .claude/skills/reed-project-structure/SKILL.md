---
name: reed-project-structure
description: File placement and naming in the Reed AAC app — layer-first lib/data/, lib/native/, lib/model/, surface-first lib/ui/ (board/, show_text/, edit/, settings/, core/), two levels maximum, no barrels, no lib/src/. Use when creating any .dart file or directory, deciding where a repository, Notifier, MethodChannel, or token belongs, naming a file or class (board_repository.dart, phrase_tile.dart, tokens.dart), mirroring a test under test/ or integration_test/, writing an import directive, or reviewing a diff for organisation.
---

# Reed — file placement

One screen, six tables, ~25 source files, one developer, two weeks. That size decides everything below. There is no telemetry: the analyzer and the test suite are the entire feedback loop, so structure exists to make defects visible, not to look enterprise.

## The top-level rule

**Layer-first at the top. Surface-first inside `lib/ui/`. Two directory levels, maximum.**

The four "features" — speak, show-text, edit, settings — are **not features. They are four surfaces over one dataset.** All four read and write the same six tables. Slice feature-first-by-screen and `AppDatabase`, `BoardRepository`, `SpeechService`, and `voice_filter` — nearly every non-widget file — land in a top-level `shared/`, leaving four thin folders of widgets. Feature-first organised around domain *entities* (`boards/`, `buttons/`) fails for a different reason: the six tables are one tightly-joined graph (a displayable tile is `grid_slots ⟕ buttons ⟕ images`), so "the boards feature" and "the buttons feature" cannot separate without a `shared/` for the join anyway. **At this size the entity graph *is* the data layer.**

Directories are free; **depth is a tax on every import**. `lib/ui/board/view_models/board_controller.dart` is four levels to reach the only view model in the app. Never create a third level under `lib/`.

## The tree

```
├── analysis_options.yaml     # the other safety net; ~17 diagnostics promoted to error
├── build.yaml                # drift_dev `databases:` — required by make-migrations
├── pubspec.yaml              # pubspec.lock is COMMITTED (this is an app, not a package)
├── drift_schemas/            # COMMITTED. One JSON per historical schema version, so a
│   └── app_database/         # schema delta is a reviewable diff. drift's default name.
├── lib/
│   ├── main.dart             # error handlers, CrashLog.open, DB open, ProviderScope,
│   │                         # runApp. ~40 lines. Nothing else lives at lib/ root.
│   ├── data/                 # BY TYPE — every surface uses all of it.
│   │   ├── database/
│   │   │   ├── app_database.dart      # @DriftDatabase, schemaVersion, MigrationStrategy
│   │   │   ├── app_database.g.dart    # COMMITTED — see "Generated code" below
│   │   │   ├── tables.dart            # boards buttons grid_slots images sounds settings
│   │   │   ├── schema_versions.dart   # generated stepByStep helper
│   │   │   ├── connection.dart        # getApplicationSupportDirectory, NOT documents
│   │   │   └── backup.dart            # copy the .sqlite before onUpgrade. ~15 lines.
│   │   ├── board_repository.dart      # the ONLY thing UI may ask about boards
│   │   ├── settings_repository.dart
│   │   ├── speech/
│   │   │   ├── speech_service.dart              # abstract interface. The seam.
│   │   │   ├── flutter_tts_speech_service.dart  # the one real impl. Thin. Untestable.
│   │   │   ├── voice_filter.dart                # PURE. No plugin import. 100% covered.
│   │   │   └── audio_session_config.dart        # .playback, NEVER .ambient.
│   │   ├── media_store.dart      # image import: downscale to ≤512px AT IMPORT
│   │   ├── crash_log.dart        # on-device, exportable. The only field signal, ever.
│   │   └── seed/
│   │       └── starter_phrases.dart  # a const Dart list, NOT a JSON asset
│   ├── native/               # EVERY MethodChannel. Nothing else may create one.
│   │   ├── personal_voice_channel.dart  # iOS only. Progressive enhancement.
│   │   └── quick_tile_bridge.dart       # SOLE writer of the QS-tile contract file
│   ├── model/
│   │   ├── board_grid.dart       # the joined Tile + the rows × cols grid of Tile?
│   │   └── speak_outcome.dart    # the sealed TTS outcome
│   └── ui/                   # BY SURFACE — thin on purpose. The weight is in data/.
│       ├── app.dart
│       ├── board/
│       │   ├── board_screen.dart
│       │   ├── board_controller.dart   # the ViewModel. A Riverpod Notifier.
│       │   ├── phrase_tile.dart
│       │   └── compose_field.dart
│       ├── show_text/show_text_screen.dart
│       ├── edit/edit_screen.dart
│       ├── settings/settings_screen.dart
│       └── core/
│           └── tokens.dart   # the ONLY file permitted a colour literal
├── test/                     # mirrors lib/ 1:1 — "what has no test?" is a diff of two ls
├── integration_test/         # ~3 tests. The QS-tile contract round-trip lives here.
└── android/app/src/main/kotlin/.../
    ├── QuickPhraseTileService.kt   # ~5 lines. Delegates immediately.
    ├── QuickTileSpeaker.kt         # the real logic. Plain JUnit tests it.
    └── QuickTileContract.kt        # mirrors quick_tile_bridge.dart BY HAND
```

## Why each directory earns its line

| Directory | Justification |
|---|---|
| `lib/data/` | The one boundary that genuinely earns its keep. Organised by type because no file in it belongs to a single surface. |
| `lib/data/database/` | drift artifacts + the file-system concerns (`connection.dart`, `backup.dart`) that only exist because the DB is a file on disk. |
| `lib/data/speech/` | The only untestable dependency plus the pure logic hoisted out of it. Four files, one concept. |
| `lib/data/seed/` | Isolates the first-launch content so it is greppable. |
| `lib/native/` | The platform-channel quarantine. One `grep -r MethodChannel lib/` outside this directory is a review failure. |
| `lib/model/` | Exactly the types drift cannot generate. |
| `lib/ui/` | Organised by surface because views and view models *are* tied to one surface — the one place feature-first is right. |
| `lib/ui/core/` | The cross-surface UI vocabulary. One file today. |
| `drift_schemas/` | Committed history; makes migrations reviewable rather than an act of faith. |

## Placement decision rules

- **A new class goes in the layer whose failure it owns.** Talks to SQLite → `data/`. Talks to a platform channel → `native/`. Is a type drift cannot generate → `model/`. Everything else → the surface that renders it.
- **`SpeechService` is abstract; `BoardRepository` is concrete.** The rule for what gets an interface: **abstract exactly what cannot run in `flutter test`.** That is `SpeechService` and the Personal Voice channel — nothing else. `BoardRepository` is tested against real in-memory SQLite (`NativeDatabase.memory()` — actual sqlite3), so a fake would defeat the point: a Map-backed fake happily accepts a row the real `PRIMARY KEY (board_id, row_index, col_index)` rejects, and never executes a migration step. Do not add `board_repository_interface.dart`.
- **Widgets never import `package:drift`.** If a widget needs a row, the repository owes it a `Tile` or a `BoardGrid`. Unpacking `List<TypedResult>` via `readTable()`/`readTableOrNull()` happens in `board_repository.dart` and nowhere else.
- **Every `MethodChannel` construction lives in `lib/native/`.** A channel created inside a widget or a repository cannot be faked and cannot be found in review.
- **A new UI surface gets its own directory under `lib/ui/`** — even for one file, like `show_text/`. Consistency beats saving a line.
- **A file shared by exactly two surfaces goes in `lib/ui/core/`,** not in either surface's folder and not in a new `lib/ui/shared/`.

## Where tokens, a11y, and constants live

- **`lib/ui/core/tokens.dart` is the only file permitted a colour literal.** Enforce it in CI, do not promise it:
  ```bash
  ! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'
  ```
  Every design system that rotted, rotted by someone typing a hex at 11pm. `tokens.dart` also owns the contrast pairs and the tap-target floor, so no widget carries a magic number.
- **There is no a11y helper file, and there must not be one.** Platform accessibility state is read **at build time, in the widget**, from `BuildContext`: `MediaQuery.textScalerOf(context)`, `MediaQuery.boldTextOf(context)`. `MediaQuery` is already an `InheritedWidget` — already a reactive propagation mechanism with correct-by-construction invalidation. Routing it through a provider or a helper means either `BuildContext` inside a provider or a manual push-and-sync that is stale for one frame, and at 200% text scale being wrong is total failure, not a cosmetic bug. **App state via Riverpod; platform/a11y state via `BuildContext`.**
- **Constants live next to the thing they constrain.** `kDefaultBoardId` sits with the providers; TTS magic numbers (`_ttsSuccess = 1`, the speak timeout) are private statics on the service that reads them. There is no `lib/constants.dart`.
- **The grid is not a constant.** Never write `const kRows = 4` or a `CHECK (row_index < 4)`. `boards.grid_rows` and `boards.grid_cols` are real columns and a 2×3 crisis layout is a requirement; a hardcoded bound turns it into a database-level insert failure baked into the primary key's own table.

## Naming and file conventions

| Rule | Value |
|---|---|
| Files, directories, import prefixes | `lowercase_with_underscores` |
| Types and extensions | `UpperCamelCase` |
| Constants | `lowerCamelCase`, never `SCREAMING_CAPS`. A `k` prefix is house style, not a rule. |
| Acronyms | >2 letters capitalise as words (`Http`, `Uri`); two-letter stay caps (`ID`, `UI`); an abbreviation *starting* a lowerCamelCase identifier stays lowercase (`httpConnection`) |
| Imports | **`always_use_package_imports`** everywhere |
| Directive order | `dart:` → `package:` → relative, exports last, each section alphabetised |
| Class names | Named for the architectural role: `SpeechService`, `BoardRepository`, `BoardScreen`. Never a name confusable with a Flutter SDK type. |

`always_use_package_imports` and `prefer_relative_imports` are mutually incompatible: mixing them lets the same member be imported two ways, producing **two distinct types at runtime**. Pick package imports — they survive file moves and are greppable.

One primary type per file, and the filename is the type in snake_case: `board_controller.dart` holds `BoardController`. Exception: a sealed hierarchy lives in one file, because the file *is* the closed set the compiler enforces — all of `SpeakOutcome`'s variants stay in `speak_outcome.dart`.

## Tests mirror `lib/` 1:1

`test/data/speech/voice_filter_test.dart` for `lib/data/speech/voice_filter.dart`. The payoff is mechanical: **"what has no test?" becomes a diff of two `ls` outputs**, which matters when nothing else will ever report a failure. Shared fakes and harnesses go in `test/support/`. Cross-cutting assertions that belong to no source file get their own folder — `test/policy/` for things like "the Android manifest declares the TTS_SERVICE query" and "no widget clamps text scaling". Generated drift migration tests land in `test/drift/`.

`integration_test/` is reserved for what no unit or widget test can reach — chiefly the Quick Settings tile contract round-trip, where a Dart-side mock would assert that a fake mutated a fake while the real Kotlin read path is broken.

## Generated code is committed

`.g.dart` files are in git, with `*.g.dart linguist-generated=true` in `.gitattributes` so GitHub collapses them in diffs. The merge-conflict objection is void for a solo dev. The arguments for are specific: a stranger's `git clone && flutter run` must work with no `build_runner` round-trip, and **drift's generated code is the schema**, so a migration diff shows the actual schema delta rather than a leap of faith. Staleness is fully mitigated by one CI step:

```bash
dart run build_runner build --delete-conflicting-outputs && git diff --exit-code
```

## Deliberately absent — do not add these

| Absent | Why |
|---|---|
| `lib/src/` | A package convention. An app has no external importers. |
| Barrel files (`data.dart`, `ui.dart`) | Measurable analyzer cost, circular-import risk, zero benefit at 25 files. |
| `lib/utils/` or `lib/helpers/` | A junk drawer. Every candidate belongs beside its owner. |
| `lib/domain/`, `use_cases/` | Every use-case here would wrap exactly one repository call. |
| `lib/routing/` + `go_router` | Four destinations, no deep links, no web surface, zero animation. Modes are state, not routes. |
| `packages/` + melos | Nothing to multiply. It buys nothing and costs a day. |
| `main_dev.dart` / `main_staging.dart` | One environment. No network, no auth. |
| `lib/l10n/` | ~25 chrome strings. Revisit before open-sourcing, not before v1. |
| `lib/ui/shared/` | The tell that the split went wrong. `data/` already is the shared layer. |
| A `Result<T>` type in `model/` | Drift throws; catch at the repository boundary. `SpeakOutcome` is the one error vocabulary. Two in a 25-file app is cost with no payoff. |
