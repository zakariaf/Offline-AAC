# E01-T01 — Scaffold the project tree

| | |
|---|---|
| **Epic** | E01 — Foundation |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E00-T03 |
| **Blocks** | E01-T02, E01-T03, E02-T01, E02-T02, E04-T01, E09-T02 |

**Skills:** `reed-project-structure` · `reed-layering-rules` · `reed-dependency-hygiene` · `reed-code-bans`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Every later task lands a file somewhere, and the place it lands is decided once — here. Get it wrong and `BoardRepository` ends up behind an interface nobody can justify, `MethodChannel` gets constructed inside a widget where no review will find it, and a `firebase_core` arrives on the second hop of a package nobody audited. This app has no telemetry: the analyzer and the test suite are the entire feedback loop, so the tree exists to make "what has no test?" and "who talks to the platform?" answerable with `ls` and `grep`. A dependency added today is a liability with no maintainer in 2029, and the exit plan is that a stranger's `git clone && flutter run` still works.

## Scope

Create the Flutter project, then build the tree below exactly. **Layer-first at the top, surface-first inside `lib/ui/`, two directory levels under `lib/` maximum.** Directories are free; depth is a tax on every import line.

Files may be created empty or as stubs — this task owns *placement and pubspec*, not implementations. Every path below is a real path a later task will fill.

```
├── analysis_options.yaml     # E01-T02 owns its contents
├── build.yaml                # drift_dev `databases:` — required by make-migrations
├── pubspec.yaml
├── pubspec.lock              # COMMITTED. This is an app, not a package.
├── .fvmrc                    # JSON: { "flutter": "3.44.6" }
├── .gitattributes            # *.g.dart linguist-generated=true
├── drift_schemas/
│   └── app_database/         # drift's default name. Committed, one JSON per version.
├── lib/
│   ├── main.dart             # ~40 lines. Nothing else lives at lib/ root.
│   ├── data/                 # BY TYPE — every surface uses all of it.
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── tables.dart
│   │   │   ├── connection.dart        # getApplicationSupportDirectory, NOT documents
│   │   │   └── backup.dart
│   │   ├── board_repository.dart
│   │   ├── settings_repository.dart
│   │   ├── speech/
│   │   │   ├── speech_service.dart              # abstract interface. The seam.
│   │   │   ├── flutter_tts_speech_service.dart  # the one real impl. Thin.
│   │   │   ├── voice_filter.dart                # PURE. No plugin import.
│   │   │   └── audio_session_config.dart        # .playback, NEVER .ambient.
│   │   ├── media_store.dart
│   │   ├── crash_log.dart
│   │   └── seed/
│   │       └── starter_phrases.dart  # a const Dart list, NOT a JSON asset
│   ├── native/               # EVERY MethodChannel. Nothing else may create one.
│   │   ├── personal_voice_channel.dart
│   │   └── quick_tile_bridge.dart
│   ├── model/
│   │   ├── board_grid.dart       # the joined Tile + the rows × cols grid of Tile?
│   │   └── speak_outcome.dart    # the sealed TTS outcome
│   └── ui/                   # BY SURFACE — thin on purpose.
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
├── test/                     # mirrors lib/ 1:1
│   ├── support/              # shared fakes and harnesses
│   ├── policy/               # cross-cutting assertions owned by no source file
│   └── drift/                # generated migration tests
└── integration_test/
```

`app_database.g.dart` and `schema_versions.dart` are generated and committed, but they arrive with the schema task — do not hand-write them here.

### Naming, exactly

| Rule | Value |
|---|---|
| Files, directories, import prefixes | `lowercase_with_underscores` |
| Types and extensions | `UpperCamelCase` |
| Constants | `lowerCamelCase`, never `SCREAMING_CAPS`; `k` prefix is house style, not a rule |
| Acronyms | >2 letters capitalise as words (`Http`, `Uri`); two-letter stay caps (`ID`, `UI`); an abbreviation starting a lowerCamelCase identifier stays lowercase (`httpConnection`) |
| Imports | `always_use_package_imports` everywhere — never `prefer_relative_imports` |
| Directive order | `dart:` → `package:` → relative, exports last, each section alphabetised |

One primary type per file; the filename is the type in snake_case (`board_controller.dart` holds `BoardController`). The one exception is a sealed hierarchy: all of `SpeakOutcome`'s variants live in `speak_outcome.dart`, because the file *is* the closed set the compiler enforces.

### Dependencies

Caret ranges in `pubspec.yaml`, pins in the committed lock. `environment: sdk:` is a real range — never an exact version. `.fvmrc` is **JSON** (`{ "flutter": "3.44.6" }`, read with `jq -r '.flutter'`), not the `flutter: 3.44.6` YAML form that gets copied around — that shape belongs to `pubspec.yaml`'s `environment:` block. Do **not** install `fvm`; the file earns its place because CI (`subosito/flutter-action` with `flutter-version-file: .fvmrc`) and a stranger read it. The tool does not.

Direct deps, and nothing else:

- `drift: ^2.31.0` — the data layer
- `sqlite3_flutter_libs` — the bundled sqlite3 the app runs against on device
- `path_provider` — `getApplicationSupportDirectory` in `connection.dart`
- `flutter_riverpod` — six plain providers. No families, no scoping, no `@riverpod`, no codegen
- `flutter_tts` — the one real `SpeechService` impl
- `audio_session` — `.playback`

Dev deps: `drift_dev`, `build_runner`, `very_good_analysis`, `flutter_test` (SDK). The versioned `include:` line for `very_good_analysis` belongs to E01-T02 — but note the coupling now: `very_good_analysis` 10.3.0 requires Dart `^3.12.0`, so on Dart 3.12.2 the include is `analysis_options.10.3.0.yaml`; on Dart 3.11.0 the resolver lands on 10.2.0 and the include must read `analysis_options.10.2.0.yaml`.

**Before adding any package**, check the tree — not the pubspec, because the second hop is exactly where Firebase arrives:

```sh
dart pub add --dry-run <package>
dart pub deps --json > /tmp/deps.json
python3 .claude/skills/reed-dependency-hygiene/scripts/audit_deps.py /tmp/deps.json
```

Exit 1 means refuse the package or find one that does not drag those in. Then check by hand: maintainer count, last publish date, and licence (record it — a permissive licence is a precondition for the `flutter_tts` vendoring escape hatch; copyleft removes that option permanently). pub.dev popularity is irrelevant.

Refuse outright anything that — directly or transitively — opens a network path, reports crashes or usage, drags in Firebase, collects device identifiers, or requires `--enable-experiment`.

Delete the `pubspec.lock` line from the `github/gitignore` Dart template. The committed lock is the only thing that makes a stranger's clone resolve the exact `flutter_tts` and `audio_session` versions that were tested against a real device — and a real device is the only thing that has ever verified this app makes sound.

Add `*.g.dart linguist-generated=true` to `.gitattributes` so GitHub collapses generated diffs.

### Explicitly out of scope — and a reviewer will propose several of these

Do not create any of the following. Each has a written reason; do not re-open one without an argument specific to this app.

| Not built | Why |
|---|---|
| `lib/domain/`, `use_cases/`, any `*UseCase` | Every use-case here wraps exactly one repository call. `SpeakSlotUseCase` calling `boardRepository.tileAt(row, col)` is a rename, not a boundary. Flutter's own guidance rates the domain layer *Conditional*. |
| `board_repository_interface.dart`, `abstract interface class BoardRepository`, a DAO interface over `AppDatabase` | Abstract exactly what cannot run in a test. `BoardRepository` is tested against real `NativeDatabase.memory()` — actual sqlite3. A Map-backed fake happily accepts a row the real `PRIMARY KEY (board_id, row_index, col_index)` rejects and never executes a migration step. drift's generated API *is* the interface. |
| `lib/routing/` + `go_router` | Modes are state, not routes. Four destinations, no deep links, no web surface, zero animation. The QS tile deliberately never launches Flutter — there is no link to deep. |
| `freezed` | drift already generates `==`, `hashCode`, `copyWith`, `toString` per table. A second generator emitting overlapping output plus a hand-written mapping layer doubles the build_runner surface for nothing. Hand-write `@immutable` + `sealed`/`final class` for the two model types. |
| `package:provider` | Riverpod is already a DI container; `overrideWithValue` is the direct analogue of a scoped `Provider`. Two DI mechanisms is strictly worse than one. |
| `lib/src/` | A package convention. An app has no external importers. |
| Barrel files (`data.dart`, `ui.dart`) | Measurable analyzer cost, circular-import risk, zero benefit at 25 files. |
| `lib/utils/`, `lib/helpers/`, `lib/constants.dart` | A junk drawer. `voice_filter.dart`, not `tts_utils.dart`. Constants live next to what they constrain. |
| `lib/ui/shared/` | The tell that the split went wrong. `data/` already is the shared layer. |
| `lib/l10n/` | ~25 chrome strings. Revisit before open-sourcing, not before v1. |
| `packages/` + melos, `main_dev.dart` / `main_staging.dart` | Nothing to multiply. One environment, no network, no auth. |
| A `Result<T>` type in `model/` | drift throws; catch at the repository boundary. `SpeakOutcome` is the one error vocabulary. |
| An a11y helper file | Platform a11y state is read at build time in the widget from `BuildContext` — `MediaQuery.textScalerOf(context)`, `MediaQuery.boldTextOf(context)`. App state via Riverpod; platform/a11y state via `BuildContext`. |
| `google_fonts`, `dynamic_color`, `custom_lint`, `equatable`, `fpdart`, `dartz`, `glados`, `figma_squircle`, `smooth_corner`, `mesh` | Banned permanently. `google_fonts` ships an HTTP client into an app whose premise is zero network surface — declare the font under pubspec `fonts:` instead. |

Also out of scope for this task: `analysis_options.yaml` contents (E01-T02), the Android manifest and Kotlin sources, any drift table or generated file, and the contents of every stub listed above.

## Acceptance criteria

- [ ] `flutter pub get` succeeds and `dart analyze` reports no errors.
- [ ] `git ls-files pubspec.lock` prints `pubspec.lock`, and `grep -n 'pubspec.lock' .gitignore` returns nothing.
- [ ] `jq -r '.flutter' .fvmrc` prints `3.44.6` (a bare string, not `null`).
- [ ] `find lib -mindepth 3 -type d` prints nothing — no third directory level under `lib/`.
- [ ] `ls lib` prints exactly `main.dart data native model ui` (in any order) and nothing else.
- [ ] `test/` and `integration_test/` exist; `test/support/`, `test/policy/`, `test/drift/` exist.
- [ ] `drift_schemas/app_database/` exists and is tracked (add a `.gitkeep` if empty).
- [ ] `grep -n 'linguist-generated' .gitattributes` matches `*.g.dart`.
- [ ] `dart pub deps --json > /tmp/deps.json && python3 .claude/skills/reed-dependency-hygiene/scripts/audit_deps.py /tmp/deps.json` exits 0.
- [ ] `grep -rn 'http\|dio\|Socket\|HttpClient' pubspec.yaml` returns nothing.
- [ ] `grep -rniE 'firebase|sentry|crashlytics|google_fonts|dynamic_color|provider:|freezed|go_router|equatable|fpdart|dartz|melos|custom_lint' pubspec.yaml` returns nothing (`flutter_riverpod` must not match — check the regex, `provider:` with the colon is deliberate).
- [ ] `! find lib -name '*_interface.dart'` and `! grep -rn 'abstract interface class' lib/data/board_repository.dart lib/data/settings_repository.dart`.
- [ ] `! find lib -type d \( -name domain -o -name use_cases -o -name utils -o -name helpers -o -name routing -o -name src -o -path 'lib/ui/shared' \)`.
- [ ] `grep -rn 'MethodChannel' lib/ --include='*.dart' | grep -v '^lib/native/'` returns nothing.
- [ ] `pubspec.yaml` has `environment: sdk: ^3.12.0` (a range) and every dependency uses a caret range — `grep -nE '^\s+\w+: [0-9]' pubspec.yaml` returns nothing.
- [ ] Every `.dart` file created imports via `package:` — `grep -rn "import '\.\./" lib/` returns nothing.

## Traps

- **`flutter create` leaves litter.** The default template writes a counter app into `lib/main.dart`, a `test/widget_test.dart` that tests it, and a `.gitignore` with a `pubspec.lock` line in it. The lock line is the dangerous one: it is silent, and its cost only lands years later on the clone that matters. Delete it in the same commit.
- **`.fvmrc` written as YAML.** `flutter: 3.44.6` in `.fvmrc` is the shape of `pubspec.yaml`'s `environment:` block, not `.fvmrc`'s. `jq` returns nothing useful and `subosito/flutter-action` silently falls back. Channel names (`stable`, `beta`) are also valid values — it is not exact-versions-only.
- **Auditing `pubspec.yaml` instead of the resolved tree.** A direct read cannot see the second hop, which is exactly where Firebase arrives. `dart pub deps --json` is the only view that sees it. `dart pub deps | grep -B4 <name>` tells you who introduced a package.
- **Mixing `always_use_package_imports` and `prefer_relative_imports`.** They are mutually incompatible: mixing them lets the same member be imported two ways, producing **two distinct types at runtime**. Package imports win — they survive file moves and are greppable.
- **The "just one interface" review comment.** Somebody — possibly you, at 2am, three weeks in — will propose `abstract interface class BoardRepository`. Adding an abstraction requires naming what it makes testable that was not testable before. "It's cleaner" is a no. The two justified abstractions are `SpeechService` and the Personal Voice channel, and only because they cannot execute in `flutter test`.
- **A third level "just for this one file."** `lib/ui/board/view_models/board_controller.dart` is four levels to reach the only view model in the app. A new UI surface gets its own directory even for one file (`show_text/`); a file shared by exactly two surfaces goes in `lib/ui/core/`, never in a new `lib/ui/shared/`.
- **`getApplicationDocumentsDirectory` in `connection.dart`.** It is `getApplicationSupportDirectory`. The stub's comment exists so the wrong one is not typed on autopilot later.
- **Baking the grid in.** Do not create a `lib/constants.dart` to hold `kRows = 4`, and do not stub one. `boards.grid_rows` and `boards.grid_cols` are real columns; a 2×3 crisis layout is a requirement.
- **A hex outside `tokens.dart`.** `lib/ui/core/tokens.dart` is the only file permitted a colour literal. Every design system that rotted, rotted by someone typing a hex at 11pm.

## Files

Creates: `pubspec.yaml`, `pubspec.lock`, `.fvmrc`, `.gitattributes`, `.gitignore` (edited — the `pubspec.lock` line removed), `build.yaml`, `drift_schemas/app_database/`, every `lib/` path in the tree above as an empty file or stub, `test/support/`, `test/policy/`, `test/drift/`, `integration_test/`.

Does not touch: `analysis_options.yaml` contents (E01-T02), `android/`, any `.g.dart`.

## Done when

`flutter pub get` and `dart analyze` are clean, the dependency audit script exits 0, and every grep and `find` in the acceptance criteria returns exactly what it should — including the ones asserting the deliberately-absent directories are still absent.
