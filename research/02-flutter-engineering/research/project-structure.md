# project-structure

> Phase: **research** · Agent `a4d00968d55fa0461` · Run `wf_12b14467-451`

## Result

## Summary

For a ONE-screen app whose four "features" (speak/show/edit/settings) all read and write the same five tables, feature-first is the wrong axis — Andrea Bizzotto's own definition ("a feature is a functional requirement that helps the user complete a given task") plus his warning about the "unbalanced" structure you get when models and repositories are genuinely shared describes this app exactly: feature-first here would push ~all real code into a `shared/` folder and leave four thin UI folders. The correct answer is the hybrid the official Flutter architecture guide and its Compass case study already codify: `lib/data/` organized BY TYPE (repositories/services are shared across every surface), `lib/ui/<surface>/` organized BY FEATURE, `lib/ui/core/` for theme + shared widgets. This choice is doubly right for constraint 5 (abandonment/open-sourcing): it is the one tree a stranger has literally read docs.flutter.dev for. Do NOT split into local packages and do NOT use melos — melos itself is described as "a multiplier: without scale it multiplies complexity," and since Melos 7 it just delegates to Dart pub workspaces anyway; with one package there is nothing to multiply. Do NOT federate the native interop into a plugin — federation exists so different *organizations* can own different platform implementations; here the Android QS TileService and iOS ControlWidget are native targets that never appear in `lib/` at all, and only Personal Voice needs a Dart-side channel. Skip barrel files (analyzer cost + circular-import risk, zero benefit at ~40 files) and skip `lib/src/` (a public-API boundary for *packages*; an app has no consumers). Three structural items ARE load-bearing and non-obvious: `drift_schemas/` must be checked into git or migration testing is impossible (constraint 2); a `lib/native/` directory should quarantine every MethodChannel because those are the only untestable-without-a-device paths (constraint 4); and the SharedPreferences keys the Kotlin QS tile reads are a compiler-unenforced contract crossing a language boundary — that is the one real module boundary in this codebase and it needs a single named file on each side. Finally, be honest that "a11y enforced by lints" mostly does not exist: there is no stock lint for "Semantics on every tile," so `test/ui/` with flutter_test's `meetsGuideline(...)` matchers is the enforcement point, not analysis_options.yaml.

### Feature-first is a poor fit for this app because its 'features' are surfaces over one shared data model, not independent functional requirements.

*Confidence: high, **LOAD-BEARING***

Bizzotto defines a feature as 'a functional requirement that helps the user complete a given task' and explicitly describes his own mistake of structuring features around pages (product_page, products_list), which produced an 'unbalanced' structure because models and repositories were genuinely shared. This app's speak/show/edit/settings all operate on boards/buttons/grid_slots/settings — under feature-first, BoardRepository, AppDatabase, SpeechService, voice_filter and the models (i.e. nearly all non-widget code) land in a top-level shared/, leaving four folders of widgets. He also states the pragmatic escape hatch directly: 'if we're building just a single-page app, we can put all files in one folder and call it a day.'

- https://codewithandrea.com/articles/flutter-project-structure/

### The official Flutter architecture case study (Compass) prescribes exactly the hybrid this app needs: data-by-type, ui-by-feature.

*Confidence: high, **LOAD-BEARING***

Tree: lib/ui/core/{ui,themes}/, lib/ui/<feature>/{view_models,widgets}/, lib/domain/models/, lib/data/{repositories,services,model}/, lib/config/, lib/utils/, lib/routing/, main*.dart; test/ mirrors {data,domain,ui,utils}; plus a top-level testing/{fakes,models}. Stated rationale: 'The data folder organizes code by type, because repositories and services can be used across different features and by multiple view models. The ui folder organizes the code by feature, because each feature has exactly one view and exactly one view model.' Compass is NOT a monorepo of local packages — it is a single app/ package alongside a server/ and docs/.

- https://docs.flutter.dev/app-architecture/case-study

- https://github.com/flutter/samples/tree/main/compass_app

- https://docs.flutter.dev/app-architecture/guide

### Local packages + melos are a net loss for a solo, single-app, two-week MVP.

*Confidence: high, **LOAD-BEARING***

2025 community framing: 'For solo developers, Melos feels like an investment, whereas for teams, it feels like relief'; 'Melos is a multiplier — without scale, it multiplies complexity instead of productivity'; benefits arrive 'once they start managing multiple apps or client projects together.' Additionally, since Melos 7.0.0 Melos delegates dependency resolution to Dart pub workspaces (Dart 3.6+, `resolution: workspace`), so its residual value is multi-package versioning/changelogs/publishing — none of which apply. If a split ever becomes necessary, use pub workspaces directly and skip melos entirely.

- https://shahzaibabid.com/when-to-use-flutter-melos-and-monorepo/

- https://melos.invertase.dev/guides/migrations

- https://dart.dev/tools/pub/workspaces

- https://dart.dev/blog/announcing-dart-3-6

### A federated plugin for the native interop is overkill; most of this app's native surface never enters lib/ at all.

*Confidence: high, **LOAD-BEARING***

Federated plugins exist to separate platform support into independently-owned packages (app-facing package + platform_interface + per-platform packages) — the motivating case is different orgs/teams owning different platforms. Here one dev owns all of it. Concretely: the Android QS TileService is Kotlin in android/app/src/main/kotlin/ that runs with NO Flutter engine (by design), and the iOS ControlWidget is a separate Swift app-extension target — neither has Dart code. Only Personal Voice needs a MethodChannel. Flutter's own docs note 'Platform channels are usually internal implementation details' — treat them as such: plain files in the app.

- https://docs.flutter.dev/platform-integration/platform-channels

- https://docs.flutter.dev/testing/plugins-in-tests

### The real module boundary in this codebase is the Dart↔Kotlin SharedPreferences contract the QS tile reads — and nothing in the compiler enforces it.

*Confidence: high, **LOAD-BEARING***

The decided design has the Android TileService speak natively from SharedPreferences with no Flutter engine on that path. That means the pref key names, value encoding, and the invariant 'the vocalization text is always present and non-empty' are a cross-language contract with zero type checking. If Dart renames a key, the tile silently speaks nothing — the exact silent-failure class of constraint 4, in the one code path the user reaches mid-shutdown. Structural consequence: exactly one Dart file (lib/native/quick_tile_bridge.dart) may touch those keys, exactly one Kotlin object (QuickTileKeys.kt) may mirror them, and the key strings belong in a doc comment on both.

- https://docs.flutter.dev/platform-integration/platform-channels

### Barrel files should be skipped: measurable analyzer/build cost and circular-import risk, no benefit at this size.

*Confidence: high*

2024-2025 consensus: barrel files 'negatively affect the analyzer's performance'; on larger projects they 'cause circular dependencies between files which are dependent on each other' leading to 'runtime errors, hard-to-debug issues, and slower build times.' DCM ships an avoid-barrel-files rule; barrel_file_lints exists to police the pattern (the tell that it needs policing). At ~40 files with IDE auto-import, the ergonomic win is zero.

- https://dcm.dev/docs/rules/common/avoid-barrel-files/

- https://articles.wesionary.team/the-hidden-costs-of-barrel-files-25de560b9f63

- https://pub.dev/packages/barrel_file_lints

- https://tkdodo.eu/blog/please-stop-using-barrel-files

### lib/src/ is a package convention and is meaningless for an application.

*Confidence: high*

dart.dev: lib/src holds 'internal implementation libraries that should only be imported and used by the package itself' and 'you should never import from another package's lib/src directory. Those files are not part of the package's public API.' An app has no external importers, so lib/src/ buys nothing and adds a path segment to every import. Use it ONLY if a directory ever becomes a published package.

- https://dart.dev/tools/pub/package-layout

### Effective Dart's actual rules are narrower than folklore: lowercase_with_underscores for files/dirs/packages/import-prefixes, UpperCamelCase for types, lowerCamelCase for constants (not SCREAMING_CAPS), directive ordering dart:/package:/relative with exports last, each section alphabetized.

*Confidence: high*

Verbatim points from dart.dev/effective-dart/style: constants 'prefer lowerCamelCase in new code' (SCREAMING_CAPS only for consistency with existing/generated code); acronyms >2 letters capitalize as words (Http, Uri) while two-letter ones stay caps (ID, UI), and abbreviations starting a lowerCamelCase identifier stay lowercase (httpConnection). Note prefer_relative_imports and always_use_package_imports are explicitly incompatible per dart.dev — pick one and enforce it; mixing lets the same member be imported two ways.

- https://dart.dev/effective-dart/style

- https://dart.dev/tools/linter-rules/prefer_relative_imports

- https://dart.dev/tools/linter-rules/always_use_package_imports

### drift_schemas/ and test/generated_migrations/ are structural, must be committed to git, and are the only mechanism that makes constraint 2 testable.

*Confidence: medium, **LOAD-BEARING***

Commands: `dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/` (one JSON per historical version), `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`, and `dart run drift_dev schema steps drift_schemas/ lib/data/database/schema_versions.dart` for step-by-step migration helpers. Drift's default migration-test directory is test/drift/. Newer drift_dev consolidates these behind `make-migrations`, which requires the database location declared in build.yaml. If drift_schemas/ is gitignored or a dump is skipped for a version, that version can never be tested against again — the schema history is unrecoverable.

- https://drift.simonbinder.eu/migrations/exports/

- https://drift.simonbinder.eu/migrations/tests/

- https://drift.simonbinder.eu/migrations/step_by_step/

### A domain/ layer with hand-written mirror models and mappers is the Clean-Architecture overhead to cut; drift's generated row classes should BE the domain models, with exactly one hand-written value object for the grid.

*Confidence: medium, **LOAD-BEARING***

The 2025 backlash is specific: developers report 'spending months writing mappers between entities and models, creating use cases for simple API calls'; 'for small applications... clean architecture can introduce unnecessary overhead, especially if the app is limited to a few screens.' Here there is no API and no serialization boundary — the SQLite row IS the truth, so entity↔model mapping maps a type onto itself. The one genuine exception: grid_slots' PK is (board_id,row,col) with a nullable button_id, so the UI wants a materialized fixed 3x4 BoardGrid of Tile? — that shape does not exist in any table and deserves a real hand-written type. Cost accepted: renaming a column ripples into widgets — but as a compile error, not a field bug.

- https://yshean.com/flutter-architecture-patterns-clean-architecture-vs-feature-first

- https://leancode.co/glossary/clean-architecture-in-flutter

### Accessibility cannot be enforced by lints — there is no stock lint for 'Semantics on every tile' — so test/ui/ is the enforcement point, using flutter_test's built-in guideline matchers.

*Confidence: medium, **LOAD-BEARING***

flutter_lints / very_good_analysis contain no a11y rules; the enforceable mechanism is `await expectLater(tester, meetsGuideline(androidTapTargetGuideline))`, `iOSTapTargetGuideline`, `textContrastGuideline`, and `labeledTapTargetGuideline` in widget tests, plus pumping with a MediaQuery TextScaler of 2.0+ to assert no overflow and no clamping. Structural consequence: a shared test/util/a11y.dart helper (e.g. expectAccessible(tester)) invoked from every widget test, because the constraint-3 promise otherwise reduces to discipline — which is what constraint 1 says cannot be relied on.

- https://docs.flutter.dev/testing/overview

- https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html

### Starter phrase sets should be Dart const data, not a JSON asset — a JSON asset is a cold-start silent-failure surface.

*Confidence: high, **LOAD-BEARING***

pubspec asset declaration is non-recursive: a `- assets/` entry bundles only files directly in that directory, and every subdirectory needs its own trailing-slash entry (resolution variants like assets/2.0x/ are the sole exception). A missed entry means rootBundle.loadString throws at first run of a fresh install — i.e. a new user opens the app and has NO board. A const List<SeedTile> in lib/data/seed/starter_phrases.dart is compile-time-checked, cannot fail to load, and costs ~12 entries. Reserve asset+parser work for the later Open Board Format *import* path, where the input is a user file and failure is legitimately runtime.

- https://docs.flutter.dev/ui/assets/assets-and-images

### VGV's very_good_cli template encodes team-scale conventions (flavors, l10n, cubit-per-feature, coverage gates) whose per-item value should be re-decided individually here.

*Confidence: medium*

very_good_cli 'encodes VGV's production engineering decisions — folder structure, linting, test configuration, CI setup, coverage thresholds'; the core template is folder-by-feature with view+cubit per feature and ships main_development/main_staging/main_production, l10n/, bootstrap.dart, and a counter feature. Of these, bootstrap.dart (runZonedGuarded + FlutterError.onError) is worth keeping and retargeting at the on-device crash log; three flavor entrypoints are pure cost for an app with no server or environments. very_good_analysis is stricter than flutter_lints; verify whether it enables public_member_api_docs before adopting, since doc-comments on every private widget is team ceremony for a solo MVP.

- https://cli.vgv.dev/docs/templates/core

- https://verygood.ventures/blog/very-good-cli-1-0-flutter-testing-mcp-semantic-versioning/

- https://pub.dev/packages/very_good_analysis

### There is no compelling 2026 'small serious Flutter app' exemplar other than flutter/samples/compass_app — and that is itself an argument for copying it.

*Confidence: medium, **LOAD-BEARING***

compass_app is the app the official architecture docs are written against, is maintained by the Flutter team, is a plain single-package app (not a melos monorepo), and has 'high test coverage.' For constraint 5 (a stranger must pick this up; open-sourcing is the exit plan), matching the tree that docs.flutter.dev teaches means a stranger's onboarding cost is a doc they may have already read. Deviating from it needs a reason; 'I prefer feature-first' is not one for a one-screen app.

- https://github.com/flutter/samples/tree/main/compass_app

- https://docs.flutter.dev/app-architecture/recommendations

- https://docs.flutter.dev/app-architecture/case-study

## Recommendations

- **[must]** Use the official Flutter hybrid tree: lib/{data,domain,ui,native}/ with data organized by TYPE and ui organized by SURFACE. Do not adopt feature-first.
  - All four surfaces read the same five tables; feature-first would hollow out into four widget folders plus a shared/ containing all real code — the exact 'unbalanced' failure Bizzotto documents. The hybrid is also the tree docs.flutter.dev teaches, which is the cheapest possible onboarding for the stranger who inherits this.
- **[must]** Ship as ONE package. No packages/core, no packages/db, no melos, no pub workspaces.
  - Package splits buy enforced dependency direction and independent test runs — both of which a solo dev on 40 files gets from a code review of their own diff. They cost pubspec fan-out, a second analysis_options, generated-code path pain (drift builders per package), and IDE friction. Melos is a multiplier with nothing to multiply; since v7 it just wraps pub workspaces anyway.
- **[must]** Put every MethodChannel in lib/native/, one file per channel, each behind an abstract interface with a fake in test/util/. Never construct a MethodChannel outside lib/native/.
  - These are the only paths that cannot be exercised by flutter test, and with no telemetry they are the paths whose field failures are invisible forever. Quarantining them makes 'what is untested?' answerable by ls.
- **[avoid]** Do NOT build a federated plugin (or any plugin) for Personal Voice / QS tile / ControlWidget.
  - Federation solves multi-org platform ownership. The QS TileService and ControlWidget are native targets with no Dart at all; only Personal Voice needs a channel. A plugin here adds a platform_interface, a version-lockstep problem, and a publishing story in exchange for nothing.
- **[must]** Name exactly one Dart file and one Kotlin object as the sole owners of the QS-tile SharedPreferences keys, and document the key strings and the non-empty-vocalization invariant in both.
  - This is the only true module boundary in the codebase and it crosses a language barrier with zero compiler enforcement. A silent key drift means the crisis-path tile speaks nothing — the worst bug class, in the worst place.
- **[must]** Check drift_schemas/ into git and add a dump step to the release checklist BEFORE every schemaVersion bump; keep migration tests in test/drift/ with generated helpers in test/generated_migrations/.
  - A schema version never dumped can never be migration-tested again, and the failure mode is a user's hand-curated board of months — irreplaceable and unmergeable. This is the cheapest possible insurance against the project's worst outcome.
- **[must]** Use drift's generated row classes as the domain models. Write exactly one hand-written domain type — BoardGrid/GridSlot materializing the fixed 3x4 with nullable tiles — and no mappers, no use-case classes, no repository interfaces with a single implementation.
  - There is no API and no serialization boundary, so mappers would map a type to itself. The grid is the one shape the schema deliberately does not have (position-as-PK with nullable button_id), so it earns a real type. Everything else is the Clean-Architecture tax the 2025 backlash is about.
- **[avoid]** No barrel files. No index.dart, no <feature>.dart re-export files.
  - Documented analyzer slowdown and circular-import hazard, in exchange for import lines your IDE writes for you. At this size there is no upside to trade against.
- **[avoid]** No lib/src/ in the app.
  - lib/src encodes a public-API boundary for package consumers. An app has none; it only lengthens every import path.
- **[should]** Pick always_use_package_imports (not prefer_relative_imports) and enable directives_ordering; the two import lints are mutually exclusive by design.
  - dart.dev states they are incompatible and that mixing lets the same member be imported two ways. For an app that will never be published, package: imports survive file moves and are greppable.
- **[must]** Enforce accessibility in test/ui/ via a shared expectAccessible(tester) helper wrapping meetsGuideline(androidTapTargetGuideline / iOSTapTargetGuideline / textContrastGuideline / labeledTapTargetGuideline), plus a TextScaler(2.0) pump per screen. Do not expect analysis_options.yaml to carry any of this.
  - No stock lint checks for Semantics or text-scale clamping. If a11y is correctness and tests are the only safety net, the a11y assertions must live in the test tree — otherwise 'accessibility is enforced' silently means 'enforced by discipline'.
- **[should]** Keep VGV's bootstrap.dart pattern (runZonedGuarded + FlutterError.onError) but wire it to the on-device crash log; drop the three flavor entrypoints and the l10n/ ARB setup for MVP.
  - The error-trapping wrapper is the only thing standing between an uncaught exception and a user with no voice and no way to report it — it is worth more here than in an app with Crashlytics. Flavors serve environments this app does not have; ~25 chrome strings do not justify ARB tooling in a two-week MVP (revisit before open-sourcing).
- **[must]** Ship starter phrases as a const Dart list in lib/data/seed/, not a JSON asset. Reserve assets/ for fonts now and symbols later, and give every asset subdirectory its own trailing-slash pubspec entry.
  - pubspec asset globs are non-recursive; a missed entry turns first-launch into an empty board via a runtime throw. A const list cannot fail to load and is type-checked at compile time. Colocate font licenses (e.g. assets/fonts/<name>/OFL.txt) so licensing travels with the file when the repo is opened.
- **[should]** Skip go_router. Use Navigator.push for show-text/settings/edit, or a state flag.
  - Four destinations, no deep-link web surface, and the QS-tile/ControlWidget entry can be an intent extra read at startup rather than a route. A router here is configuration in exchange for indirection — and zero-animation is a design rule, so the transition machinery is unwanted too.
- **[should]** Mirror lib/ in test/ one-to-one, and keep fakes in test/util/ rather than a top-level testing/ package until integration_test/ actually needs to share them.
  - Compass uses a top-level testing/ because fakes are shared with integration tests across a package boundary. Promote only when that pressure is real; a mirrored test tree makes 'which file has no test?' a diff of two ls outputs — which matters when tests are the only safety net.
- **[must]** Write ARCHITECTURE.md recording the decisions and their REASONS (position-as-PK so reflow is impossible; label != vocalization; setVoice return must be checked; audio session .playback never .ambient; no telemetry by promise), not just the tree.
  - The exit plan is open-sourcing and the realistic outcome is abandonment. A stranger who does not know WHY grid_slots is keyed by position will 'clean it up' into an ordered list with an index, and reintroduce reflow — silently breaking muscle memory for users who cannot afford it.

### Recommended tree for THIS app (single package, official hybrid layout)

```text
offline_aac/
├── analysis_options.yaml          # flutter_lints + always_use_package_imports, directives_ordering
├── build.yaml                     # drift_dev: database path (needed for make-migrations)
├── pubspec.yaml
├── README.md                      # run it / test it / architecture in one page
├── ARCHITECTURE.md                # the decisions AND the reasons (see recommendations)
├── drift_schemas/                 # COMMITTED. one JSON per historical schema version.
│   └── app_database/
│       ├── drift_schema_v1.json
│       └── drift_schema_v2.json
├── assets/
│   └── fonts/
│       └── atkinson_hyperlegible/ # + OFL.txt colocated
├── lib/
│   ├── main.dart                  # ProviderScope + overrides + runApp. ~30 lines.
│   ├── bootstrap.dart             # runZonedGuarded + FlutterError.onError -> CrashLog
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart      # @DriftDatabase, schemaVersion, MigrationStrategy
│   │   │   ├── app_database.g.dart
│   │   │   ├── tables.dart            # boards buttons grid_slots images sounds settings
│   │   │   ├── schema_versions.dart   # generated: drift_dev schema steps
│   │   │   └── connection.dart        # NativeDatabase.createInBackground + db file path
│   │   ├── repositories/
│   │   │   ├── board_repository.dart      # THE seam Riverpod exists to make testable
│   │   │   └── settings_repository.dart
│   │   ├── services/
│   │   │   ├── speech_service.dart            # abstract: speak/stop/voices
│   │   │   ├── flutter_tts_speech_service.dart
│   │   │   ├── voice_filter.dart              # PURE. no plugin import. unit-testable.
│   │   │   ├── audio_session_config.dart
│   │   │   ├── media_file_store.dart          # images/sounds on disk; paths -> DB
│   │   │   └── crash_log.dart                 # on-device only, user-exportable
│   │   └── seed/
│   │       └── starter_phrases.dart           # const List<SeedTile>. NOT a JSON asset.
│   ├── native/                    # every MethodChannel. nothing else may create one.
│   │   ├── personal_voice_channel.dart
│   │   └── quick_tile_bridge.dart # SOLE owner of the QS-tile SharedPreferences keys
│   ├── domain/
│   │   └── models/
│   │       └── board_grid.dart    # the ONE hand-written type: fixed 3x4 of Tile?
│   └── ui/
│       ├── core/
│       │   ├── theme/
│       │   │   ├── app_theme.dart
│       │   │   └── tokens.dart    # sizes, min tap targets, contrast pairs. no magic numbers.
│       │   └── a11y/
│       │       ├── tile_semantics.dart
│       │       └── text_scale.dart            # helpers that never clamp
│       ├── board/                 # the one screen
│       │   ├── board_screen.dart
│       │   ├── board_controller.dart
│       │   └── widgets/
│       │       ├── phrase_grid.dart
│       │       ├── phrase_tile.dart
│       │       └── type_to_speak_field.dart
│       ├── show_text/
│       │   └── show_text_screen.dart
│       ├── edit/
│       │   ├── edit_mode_controller.dart
│       │   └── tile_editor_sheet.dart
│       └── settings/
│           ├── settings_screen.dart
│           └── settings_controller.dart
├── test/                          # mirrors lib/ one-to-one
│   ├── data/
│   ├── ui/
│   ├── native/                    # fakes assert channel contracts
│   ├── drift/                     # migration tests (drift's default dir)
│   ├── generated_migrations/      # generated + COMMITTED
│   └── util/
│       ├── a11y.dart              # expectAccessible(tester)
│       └── fakes.dart
├── integration_test/
│   └── speak_path_test.dart       # real TTS on a real device: the one thing tests can't fake
├── android/app/src/main/kotlin/.../
│   ├── QuickPhraseTileService.kt
│   └── QuickTileKeys.kt           # mirrors quick_tile_bridge.dart. keep in sync BY HAND.
└── ios/
    ├── Runner/PersonalVoicePlugin.swift
    └── AACControl/               # separate ControlWidget extension target

CUT from a "best practice" tree, deliberately:
  packages/ + melos.yaml   -> nothing to multiply; melos 7 just wraps pub workspaces
  lib/src/                 -> package convention; an app has no external importers
  any *.dart barrel file   -> analyzer cost + circular imports, zero benefit at 40 files
  lib/routing/ + go_router -> 4 destinations, no deep-link web surface, no animations
  main_{dev,staging,prod}  -> no server, no environments
  lib/l10n/ + ARB          -> ~25 chrome strings; revisit before open-sourcing
  domain/use_cases/        -> would wrap one repo call each
  data/model/ + mappers    -> no API; drift's row classes ARE the models
  testing/ (top-level)     -> test/util/ until integration_test actually needs sharing
  lib/utils/, constants.dart -> junk drawers; colocate or put in ui/core/theme/tokens.dart
```

The four ui/ subfolders are SURFACES, not features — they are thin on purpose. All the weight is in data/, which is exactly why feature-first would have been the wrong axis.

### The cross-language contract: sole owner on each side

```dart
// lib/native/quick_tile_bridge.dart
//
// SOLE OWNER of the SharedPreferences keys read by the Android Quick Settings
// tile (android/app/src/main/kotlin/.../QuickTileKeys.kt). That TileService speaks
// NATIVELY with no Flutter engine, so nothing here is checked by the compiler or
// reachable from a widget test.
//
// INVARIANT: if [_kVocalization] is present it is non-empty. A present-but-empty
// value makes the tile silently do nothing — the user taps mid-shutdown and gets
// no voice, and with no telemetry we will never find out.
//
// If you rename a key, change QuickTileKeys.kt in the SAME commit.
class QuickTileBridge {
  static const _kVocalization = 'quick_tile_vocalization'; // String, non-empty
  static const _kLabel        = 'quick_tile_label';        // String, may be empty

  Future<void> publish({required String vocalization, required String label}) async {
    // Enforce the invariant HERE rather than trusting callers: publishing an
    // empty phrase is worse than publishing nothing at all.
    if (vocalization.trim().isEmpty) {
      await clear();
      return;
    }
    // ... write both keys ...
  }

  Future<void> clear() async { /* remove both keys atomically */ }
}
```

The doc comment is the enforcement mechanism, because there isn't one. That is worth being explicit about rather than pretending the structure makes it safe.

### Analysis options: what's actually worth turning on for a solo AAC app

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  # Generated code is not yours to lint.
  exclude:
    - "**/*.g.dart"
    - test/generated_migrations/**
  language:
    strict-casts: true
    strict-raw-types: true
  errors:
    # A silent failure is the worst bug class. An ignored Future is a speak()
    # whose error you never see — promote to error, not warning.
    unawaited_futures: error
    # Dead null-aware code often means a nullability assumption already broke.
    invalid_use_of_visible_for_testing_member: error

linter:
  rules:
    # Pick ONE import style. These two lints are mutually exclusive by design.
    always_use_package_imports: true
    directives_ordering: true

    # Silence-prevention: make ignored results and swallowed errors visible.
    unawaited_futures: true
    only_throw_errors: true
    avoid_catches_without_on_clauses: true

    # Readable-by-a-stranger (the exit plan), cheap to satisfy:
    prefer_final_locals: true
    require_trailing_commas: true
    sort_constructors_first: true

    # Deliberately NOT enabled:
    # public_member_api_docs  -> doc-comment ceremony for an app with no consumers
    # prefer_relative_imports -> conflicts with always_use_package_imports above
#
# NOTE: no lint in flutter_lints or very_good_analysis checks Semantics, tap-target
# size, or TextScaler clamping. Accessibility is enforced in test/ui/, not here.
# Do not mistake a green analyzer for an accessible app.
```

very_good_analysis is a reasonable alternative to flutter_lints here, but audit public_member_api_docs before adopting — on a solo app it fires on every widget and trains you to ignore lints, which is a real cost when lints are one of only two safety nets.

### The a11y helper that makes constraint 3 enforceable

```dart
// test/util/a11y.dart
// Accessibility is correctness for this app, and no lint can check it.
// Every widget test calls this. If it's not called, the screen is unverified.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> expectAccessible(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}

/// Pumps [child] at [scale] and fails on any overflow.
/// TextScaler must be HONORED, never clamped — 200%+ is a real user, not an edge case.
Future<void> pumpAtTextScale(
  WidgetTester tester,
  Widget child, {
  double scale = 2.0,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: MaterialApp(home: child),
    ),
  );
  expect(tester.takeException(), isNull, reason: 'overflow at ${scale}x text scale');
}
```

Put this in test/util/ and call it from every screen test. The point of naming it is that a missing call is greppable; an absent Semantics widget is not.

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


YOUR DIMENSION: Project/folder structure and module boundaries for a small-but-serious Flutter app.

Research with WebSearch/WebFetch: Very Good Ventures' conventions and very_good_cli templates, Andrea Bizzotto (codewithandrea) on feature-first vs layer-first, Reso Coder / Clean Architecture in Flutter (and the backlash to it), the Flutter community's 2025-2026 consensus, monorepo tooling (melos), internal packages.

- **Feature-first vs layer-first**: state the actual trade-off with evidence, not vibes. Which wins for a ONE-SCREEN app? Note this app's "features" (speak/show/edit/settings) all operate on the SAME data — does feature-first even make sense?
- Should a solo dev split into local packages (packages/core, packages/db)? What does that BUY and what does it COST? Is melos worth it here? Be honest — most small apps that do this regret it.
- Where do platform-channel wrappers live? Should the native interop surface be its own package/plugin? (This app has: Personal Voice iOS channel, Android QS TileService, iOS ControlWidget.) Is a federated plugin overkill?
- Naming conventions for files/folders/classes in Dart. Effective Dart's actual rules.
- barrel files (index.dart / exports) — good or harmful? Evidence on build times and circular imports.
- Where do the theme tokens, a11y helpers, and constants go?
- `lib/src/` convention — when does it matter (packages) vs not (apps)?
- What does a REAL, well-structured small Flutter app look like in 2026? Find actual open-source examples worth imitating and describe their structure.
- How should assets (starter phrase sets, symbols later, fonts) be organized and declared?

Give a concrete recommended tree for THIS app, and say what you'd cut from a "best practice" tree because it's a solo two-week MVP.
````

</details>
