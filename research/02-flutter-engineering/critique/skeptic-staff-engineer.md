# skeptic-staff-engineer

> Phase: **critique** · Agent `ab924e1dd4a985303` · Run `wf_12b14467-451`

## Result

# Memo: What Actually Earns Its Place

You have ~10 working days. This corpus contains maybe 12 hours of genuinely load-bearing work and about 4 days of stuff that will make you feel like a good engineer while your users get nothing.

---

## 1. The cargo cult, named

**Result\<T\> (the Compass one).** The fact-check already killed this. `sealed` makes a *missing switch branch* a compile error; it does nothing about `await repo.load();` discarding the value. You need `@useResult` + analyzer-as-error to get the property you actually want — and even then it's a warning promoted, not a compiler guarantee. Meanwhile the plan has you carrying **two** error types: `Result<T>` for drift and `SpeakOutcome` for speech. Cut `Result<T>` entirely. Drift throws; catch it at three call sites. Keep exactly one sealed type: `SpeakOutcome`, where the failure variants carry `spokenText`. That one is real, because the failure *is* the feature.

**The Compass folder tree.** `lib/ui/board/view_models/board_view_model.dart` is four directory levels to find the only view model in the app. The "a stranger recognizes it from docs.flutter.dev" argument is asserted, never reasoned. A stranger reads 25 files in an afternoon regardless of the tree. Use `lib/data/`, `lib/ui/`, `lib/native/`, flat inside. Directories are free but *depth is not* — depth is a tax on every import and every `find`.

**Repository pattern over 6 tables.** A drift DAO *is* the repository. `BoardRepository.watchSlots()` forwarding to `db.watchSlots()` is a layer whose only content is the word "repository." Keep exactly one class that isn't a forwarder: the thing that owns `voice_filter` + `setVoice` verification. Call it `SpeechRepository` if you like the word. Everything else talks to `AppDatabase` directly.

**Command pattern.** Cut it entirely, including for edit mode. The corpus says "use it for DB writes" — a double-tap guard on a save button is `bool _saving`. You do not need a ChangeNotifier subclass for that.

**Riverpod.** Of its three stated justifications, one was withdrawn (MediaQuery — correctly), one rests on a *refuted* claim (Notifier lifecycle), and one survives (test overrides). It's standing on one leg, and constructor injection does that leg's job. But it's decided, it costs you ~2 hours, and re-litigating costs more than that. **Keep it. Six providers. No families, no scoping, no codegen, no `@riverpod`.** The moment you type `family` you have lost the argument that it was cheap.

**100% coverage + `tool/check_coverage.sh`.** Sixty lines of bash/awk/lcov, plus lcov 2.x on ubuntu-24.04 will fight you over `--ignore-errors unused`. This is a day. The corpus's own fact-check demolished the VGV rationale. Delete the script. Run `flutter test`.

**Golden tests.** The corpus contradicts itself: `widget-golden-testing` says *skip goldens for the MVP*; `ci-release` ships an `update-goldens.yml` workflow, a `flutter_test_config.dart` font loader, and PNG review. The skip verdict is right and the reasoning is good: everything a golden would catch here (text doesn't fit, grid reflowed) is caught by `takeException()` and `getRect()` in ten lines with a readable failure message. Cut all of it.

**Melos, Pigeon, Patrol, Test Lab, deferred components, shader warmup, R8, obfuscation, monorepos, `lib/src/`, barrel files, freezed, equatable, go_router, use-cases, domain models, custom_lint, Renovate, FVM, `.gitattributes`, `release.yml`, ADRs-as-a-directory.** All correctly refused. But notice the *cost of refusing*: the corpus spent roughly six dimensions proving that things you were never going to do shouldn't be done. That research is sunk. Don't let it become a document.

**ADRs.** Six ADRs is two hours and puts the reasoning in a directory nobody opens. The corpus's own best artifact is the `grid_slots` ADR — and its content wants to be a **six-line doc comment on the table definition**, which is where the person about to add a surrogate `id` is actually standing when they get the idea. Comments at the point of temptation beat prose in `docs/`.

---

## 2. Where "best practice" actively hurts

- **A day on migration test scaffolding at `schemaVersion = 1`.** There are no migrations. Zero. The v1→v2 test cannot be written because v2 doesn't exist. The corpus treats migration testing as a day-one gate; it is a day-*two-hundred* gate. **The day-one obligation is the schema dump** — the one artifact you can never reconstruct once you bump the version. That's `build.yaml` + `dart run drift_dev make-migrations` + commit `drift_schemas/`. Twenty minutes. The tests come with v2.
- **A day on the CI pipeline.** `ci.yml` + `update-goldens.yml` + `release.yml` + `renovate.json` + `.fvmrc` + `.gitattributes` + the coverage script. All of it coordinates humans you don't have and guards regressions you'd catch by running the app.
- **A day plumbing `Result<T>` switches** through call sites whose error handling is uniformly "log it, show last known good."
- **The `analysis_options.yaml` debate.** VGA's 212 rules vs flutter_lints' 30 — and the same dimension proved the one lint that would catch your actual bug **does not exist** (`onTap: () => tts.speak(x)` fires nothing). Also: the shipped config's `close_sinks: error` override is a verified **no-op** — `errors:` can't enable a rule VGA never turned on. That's a config file with a broken line, shipped as a recommendation. The lints are decoration around a structural fix.

---

## 3. The minimum that actually protects what matters

Roughly one and a half days total. Everything here is load-bearing.

**Silence (≈4 hours)**
1. `<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>` in the manifest. **One line.** Without it, Android 11+ hides the engine and every voice list is empty. Highest value-per-character in the corpus.
2. `SpeechController.speakNow(String)` returns **void**, internally `unawaited(_speak(p).catchError(...))`. Callbacks never hold a Future — the lint hole becomes unreachable by construction. Verified.
3. `SpeakOutcome` sealed; every failure carries `spokenText`; exhaustive switch with **no `default:`**. Check `setVoice != 1`. Exclude `notInstalled` **and** `network_required == "1"` (string, tab-separated features, absent on iOS).
4. Audio session `.playback`, never `.ambient`.
5. **One parameterized test:** for every `SpeakFailure`, tapping a tile yields recorded speech OR a findable on-screen error. Never neither.

**Data (≈1 hour)**
6. `build.yaml` + `make-migrations` + **commit `drift_schemas/`**. Do this before user data exists.
7. `PRAGMA foreign_keys = ON` unconditionally in `beforeOpen`, plus one test asserting it returns 1.
8. **Copy the .sqlite file before `onUpgrade`, keep the last two, expose "Restore previous board."** ~15 lines. Higher safety-per-line than every migration test you will ever write, because it covers the migration bug you *didn't* enumerate — which, with no telemetry, is the entire invisible category.

**Accessibility (≈3 hours)**
9. Loop `tester.getSize()` over all 12 tiles asserting ≥ your minimum. **Not `meetsGuideline`** — `MinimumTapTargetGuideline` silently skips every node touching the view edge, so on a full-bleed grid it checks two tiles and passes.
10. Per-tile `isSemantics(label: displayLabel, isButton: true)` **plus** assert the label does *not* contain the vocalization.
11. `simulatedAccessibilityTraversal()` pinned to a hard-coded row-major list.
12. TextScaler 1.0/2.0/3.0, **pinned to a real device size** (`tester.view.physicalSize`), one test per tuple, assert `takeException()` is null. The 800×600 default is wider than any phone; unpinned, these tests are green while the shipped UI is broken.
13. The 10-line grep test banning `withClampedTextScaling`.

**Crash log (≈1 hour)**
14. `FlutterError.onError` + `PlatformDispatcher.instance.onError` → sync, size-bounded, self-truncating file writer with a commented bare `catch (_)`. No `runZonedGuarded`. Return `true` and `debugPrint` in debug rather than taking the `false` branch.

**Everything else**
15. Downscale imported images at import (~512px). Makes the OOM unrepresentable.
16. `docs/CHECKLIST.md` — the manual device pass. **This is not a chore, it is the safety net.** Emulators have no TTS engine; no automated test in existence can observe that sound came out.
17. Warm TTS from `addPostFrameCallback`, never awaited.

Note what's absent: coverage gates, goldens, ADRs, Result\<T\>, Commands, use-cases, a CI matrix.

---

## 4. Four documents is over-engineering

Yes. Cut to **one**, and it shouldn't be prose.

The corpus wants: ARCHITECTURE.md, README non-goals, `docs/adr/` ×6, RELEASE.md, RELEASE_CHECKLIST.md, a11y-manual-checklist.md, PRIVACY.md, CHANGELOG.md, CONTRIBUTING.md. Nine documents for 25 files of code. That's a documentation-to-code ratio that signals the project is *about* documentation.

Ship:
- **README.md** — run it, the four counterintuitive decisions in four bullets, non-goals (the no-telemetry promise lives here), license.
- **docs/CHECKLIST.md** — the merged manual device + a11y + release pass. The one artifact automation cannot replace.
- **Doc comments in the code** for `grid_slots`, `label != vocalization`, `.playback`, `setVoice`, `speakNow`'s void return. Put the reasoning where the temptation is.

The real deliverable of this research is not four memos. It is `analysis_options.yaml`, `build.yaml`, `AndroidManifest.xml`, and a `test/` skeleton. If the corpus produces prose instead of those four files, it has failed.

---

## 5. Where the research is just repeating Flutter blogs

- **The whole test-pyramid dimension.** Its own fact-check dismantled the thesis (widget tests are equal on runtime, *higher* on maintenance and dependencies; Flutter's docs never mention the pyramid). It argued at length against 70/20/10 folklore that nobody in this project proposed. Delete the dimension; keep three findings from it.
- **"A Riverpod Notifier IS Google's ViewModel."** Vocabulary mapping with zero code consequence. Pure architecture-blog cadence.
- **"Adopt the official folder shape for handoff."** The benefit is asserted. It's a 25-file app.
- **The `flutter_lints` vs `very_good_analysis` comparison**, complete with a broken override shipped as advice.
- **Six dimensions of correctly refusing melos/Pigeon/Patrol/deferred components/R8/obfuscation.** Right answers, but the questions were generated by the genre, not by the app.

The corpus's genuinely original work is small and excellent, and it all came from **running things instead of reading them**: the arrow-closure lint hole, `MinimumTapTargetGuideline`'s boundary skip, the `network_required == "1"` string, `notInstalled` defeating the setVoice check, the 800×600 default surface, the overflow-reports-once flag, `include_file_not_found` silently disabling 212 rules. Seven findings. Every one of them is a silent failure that the entire architecture apparatus around them would never have caught.

**Spend your two weeks there.**

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


Below is the full engineering research corpus. You are a SKEPTICAL STAFF ENGINEER who has shipped Flutter apps and has strong views about over-engineering.


### DIMENSION: official-architecture
SUMMARY: Flutter's official architecture guide (docs.flutter.dev/app-architecture) is real, current, and explicitly recommends MVVM: a UI layer of Views + ViewModels, a Data layer of Repositories + Services, and an OPTIONAL domain layer of use-cases. Critically, the guide self-scopes in its own first paragraph: "This is a guide for building scalable Flutter applications and was written for teams that have multiple developers contributing to the same code base, who're building a feature-rich application." A solo dev shipping one screen in two weeks is explicitly outside the audience it was written for — so this guidance should be mined, not obeyed. The reference implementation (Compass app, flutter/samples) is 169 files under `lib/` for ~6 screens, with 6 repositories each having 2-3 swappable implementations (local/dev/remote) to demonstrate environment-switching — a rationale that evaporates in an app with no network and one environment. Three things from the guide are load-bearing here and should be adopted verbatim: the sealed `Result<T>` type (which turns constraint #4, silent failure, into a compile-time error), the layer-first/feature-first hybrid folder layout (which is what makes the code legible to the stranger who inherits it — constraint #5), and immutable models with unidirectional data flow. Several things should be actively rejected: the domain/use-case layer (the docs themselves say "in most apps they add unnecessary overhead"), separate API-vs-domain models ("Use in large apps"), `package:provider` for DI (Riverpod already does this, and the docs bless the substitution), and — most importantly — Google's "make fakes for testing" advice as applied to the board repository, where a fake would defeat the migration testing that constraint #2 makes a safety property. There is no genuine conflict between Google's guidance and Riverpod: a Riverpod `Notifier` IS a ViewModel in Google's formulation, and the case study says so explicitly. The one real divergence is that Google's ViewModels are 1:1 with views while Riverpod providers are global and naturally shared — at this size, ignore the 1:1 rule. Finally, the Command pattern is a trap for this specific app: its core behavior is `if (_running) return;`, and silently swallowing a re-tap is exactly the wrong semantic for a speak button.

FINDINGS:
  - (high, LOAD-BEARING) Flutter's official architecture guide explicitly scopes itself to multi-developer teams and feature-rich apps — this project is outside its stated audience.
    docs.flutter.dev/app-architecture opens with: "This is a guide for building scalable Flutter applications and was written for teams that have multiple developers contributing to the same code base, who're building a feature-rich application. If you're writing a Flutter app that has a growing team and codebase, this guidance is for you." It adds: "Some libraries can be swapped out, and very large teams with unique complexity might find that some parts don't apply. In either case, the ideas remain sound." There is no separate 'small app' guide. This is the single most important framing fact for this dimension: nothing in the guide is a rule for a solo dev with one screen — it is a menu.
    sources: https://docs.flutter.dev/app-architecture
  - (high, LOAD-BEARING) Google recommends MVVM with precisely defined roles: View = dumb widgets, ViewModel = where most logic lives, Repository = source of truth, Service = stateless data-source wrapper.
    From /app-architecture/guide: "MVVM is an architectural pattern that separates a feature of an application into three parts: the Model, the ViewModel and the View." View: "views are the widget classes of your application... shouldn't contain any business logic. They should be passed all data they need to render from the view model." ViewModel: "A view model exposes the application data necessary to render a view... most of the logic in your Flutter application lives in view models" — responsibilities are (1) retrieving/transforming data from repositories, (2) maintaining UI state, (3) exposing commands. "Views and view models should have a one-to-one relationship." Repository: "Repository classes are the source of truth for your model data. They're responsible for polling data from services, and transforming that raw data into domain models... There should be a repository class for each different type of data handled in your app." Repos own caching, error handling, retry, refresh, and app-wide session state. Service: "Services are in the lowest layer... They wrap API endpoints and expose asynchronous response objects... They're only used to isolate data-loading, and they hold no state." Explicitly listed service examples include "The underlying platform, like iOS and Android APIs" and "Local files" — which is exactly what SpeechService is.
    sources: https://docs.flutter.dev/app-architecture/guide
  - (high, LOAD-BEARING) The project's existing `SpeechService` abstraction is already exactly what Google calls a Service, and the platform channels (Personal Voice, QS Tile, ControlWidget) are Services too.
    Google's Service definition — "wrap API endpoints", "hold no state", "one service class per data source", examples including "the underlying platform, like iOS and Android APIs" — maps 1:1 onto the already-decided `SpeechService` (speak/stop/voices) wrapping flutter_tts. This is a validation, not a change: the prior research pass independently arrived at Google's layer boundary. The `voice_filter` is the "transforming that raw data" step Google assigns to a Repository, which suggests it belongs one layer up from the raw flutter_tts wrapper rather than inside it.
    sources: https://docs.flutter.dev/app-architecture/guide
  - (high, LOAD-BEARING) Google's domain layer (use-cases) is explicitly conditional and the docs recommend against it for most apps.
    /app-architecture/recommendations rates "Use a domain layer" as **Conditional**: "A domain layer is only needed if your application has exceeding complex logic that crowds your ViewModels, or if you find yourself repeating logic in ViewModels. In very large apps, use-cases are useful, but in most apps they add unnecessary overhead." /app-architecture/concepts adds: "The logic layer is optional, and only needs to be implemented if your application has complex business logic... Many apps are only concerned with presenting data to a user and allowing the user to change that data (colloquially known as CRUD apps). These apps might not need this optional layer." An AAC app with 12 tiles and an edit mode is a CRUD app by this definition. Note that Compass itself only has TWO use-cases (booking_create, booking_share) out of 169 files — even the reference app barely uses the layer it demonstrates.
    sources: https://docs.flutter.dev/app-architecture/recommendations | https://docs.flutter.dev/app-architecture/concepts
  - (high, LOAD-BEARING) The Compass app's `lib/` is 169 files across 6 features, with 6 repositories × 2-3 implementations each — the multi-implementation pattern exists to demonstrate dev/staging/remote environment swapping, which does not exist in this project.
    Actual tree (from GitHub API, flutter/samples main branch, verified 2026-07-15): `lib/config/{assets,dependencies}.dart`; `lib/data/repositories/{activity,auth,booking,continent,destination,itinerary_config,user}/` each with an abstract `X_repository.dart` plus `_local`/`_dev`/`_remote`/`_memory` implementations; `lib/data/services/api/{api_client,auth_api_client}.dart` + `services/api/model/**` + `services/local/local_data_service.dart` + `services/shared_preferences_service.dart`; `lib/domain/models/**` (7 models, each with .freezed.dart + .g.dart) and `lib/domain/use_cases/booking/{booking_create,booking_share}_use_case.dart`; `lib/routing/{router,routes}.dart`; `lib/ui/<feature>/view_models/*_viewmodel.dart` + `lib/ui/<feature>/widgets/*.dart` for activities, auth/login, auth/logout, booking, home, results, search_form; `lib/ui/core/{localization,themes,ui}/`; `lib/utils/{command,result,image_error_listener}.dart`; and three entrypoints `main.dart`, `main_development.dart`, `main_staging.dart`. The README confirms the purpose: "development and production environments... Development mode uses local JSON assets, Staging mode connects to a local HTTP server." The abstract-repository rationale in the docs is explicitly environment-driven: "Creating abstract repository classes allows you to create different implementations, which can be used for different app environments, such as 'development' and 'staging'." This app has ONE environment, no network, no auth, no API models. Roughly 60% of Compass's structure is demonstrating problems this project does not have.
    sources: https://github.com/flutter/samples/tree/main/compass_app | https://docs.flutter.dev/app-architecture/recommendations | https://docs.flutter.dev/app-architecture/case-study
  - (high, LOAD-BEARING) Flutter's official position on folder structure is a documented hybrid: layer-first at the top level, feature-first inside the UI layer.
    From /app-architecture/case-study: "The architecture recommended in this guide lends itself to a combination of the two. Data layer objects (repositories and services) aren't tied to a single feature, while UI layer objects (views and view models) are." The prescribed UI shape is `lib/ui/<feature_name>/view_models/<view_model_class>.dart` and `lib/ui/<feature_name>/widgets/<feature_name>_screen.dart`. Tests mirror `lib/` in `test/`, with shared mocks/utilities in a separate top-level `testing/` directory (confirmed by the Compass tree). Naming is a **Recommend**: "We recommend naming classes for the architectural component they represent. For example... HomeViewModel; HomeScreen; UserRepository; ClientApiService. For clarity, we do not recommend using names that can be confused with objects from the Flutter SDK."
    sources: https://docs.flutter.dev/app-architecture/case-study | https://docs.flutter.dev/app-architecture/recommendations | https://github.com/flutter/samples/tree/main/compass_app
  - (high, LOAD-BEARING) The sealed `Result<T>` type is the single highest-value thing to lift from the official guidance, because it converts this project's worst bug class (silent failure) into a compile-time error.
    Compass's `lib/utils/result.dart` is ~45 lines with no dependencies: `sealed class Result<T>` with `const factory Result.ok(T value) = Ok._` and `const factory Result.error(Exception error) = Error._`, plus `final class Ok<T>` (field `value`) and `final class Error<T>` (field `error`). Because it is `sealed`, Dart's exhaustiveness checker makes `switch (result) { case Ok(): ... case Error(): ... }` a compile error if a branch is missing. This is the mechanism that maps directly onto constraint #4: `flutter_tts.setVoice` returning 0 with only a `Log.d` is precisely a failure the type system cannot see today. If `SpeechService.speak()` returns `Future<Result<void>>`, the compiler will not let the call site ignore the Error branch. Note that `Result.error` is typed to `Exception`, not `Object` — errors that aren't Exceptions need wrapping.
    sources: https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart | https://docs.flutter.dev/app-architecture/design-patterns
  - (high, LOAD-BEARING) The Command pattern's core behavior — silently dropping re-entrant invocations — is actively wrong for a speak action in an AAC app.
    Compass's `lib/utils/command.dart` implements `Command<T> extends ChangeNotifier` whose `_execute` begins: `if (_running) return;` with the comment "Ensure the action can't launch multiple times. e.g. avoid multiple taps on button". The docs rate Commands as **Recommend**: "Commands prevent rendering errors in your app, and standardize how the UI layer sends events to the data layer." But in this app, a user tapping a tile again while TTS is still speaking means "say it again" or "I need this NOW" — dropping that tap produces exactly the silence constraint #4 forbids. The correct speak semantic is stop-then-speak (barge-in), which is the opposite of Command's guard. Command IS appropriate for edit-mode DB writes (save tile, delete tile, import board), where double-execution is a real hazard and a disabled/pending button is honest UI. Adopting Command uniformly because the docs recommend it would be the clearest cargo-cult failure available in this project.
    sources: https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/command.dart | https://docs.flutter.dev/app-architecture/recommendations
  - (high, LOAD-BEARING) Google's guidance does NOT conflict with Riverpod — the docs explicitly bless it, and a Riverpod Notifier is a ViewModel in Google's formulation.
    The ChangeNotifier recommendation is rated **Conditional**, not strongly recommended: "The ChangeNotifier API is part of the Flutter SDK, and is a convenient way to have your widgets observe changes in your ViewModels. There are many options to handle state-management, and ultimately the decision comes down to personal preference." The case study is more direct: "The example in this case-study demonstrates how one application abides by our recommended architectural rules, but there are many other example apps that could've been written... it could've easily been written with streams, or with other libraries such as riverpod, flutter_bloc, and signals." The DI recommendation is where a nominal conflict lives: **Strongly recommend** "Use dependency injection... We recommend you use the provider package" (the DI case-study page recommends `package:provider` and does not mention get_it or Riverpod at all). But Riverpod subsumes this — it IS a DI container, and provider overrides in tests are the direct analogue of Compass's `lib/config/dependencies.dart` MultiProvider. The stated goal of the DI recommendation — "prevents your app from having globally accessible objects" — is satisfied. Do not add `package:provider` alongside Riverpod.
    sources: https://docs.flutter.dev/app-architecture/recommendations | https://docs.flutter.dev/app-architecture/case-study | https://docs.flutter.dev/app-architecture/case-study/dependency-injection
  - (medium, LOAD-BEARING) The one real Google-vs-Riverpod divergence is the 1:1 ViewModel:View rule, which Riverpod's global providers do not naturally enforce — and which this app should ignore.
    Google: "Views and view models should have a one-to-one relationship." Riverpod providers are top-level globals, naturally shared across widgets, and the community pattern is one Notifier per state concern, not per screen. With ONE screen containing a grid + a text field + a show-text mode + an edit mode, forcing a single `HomeViewModel` would create a god object, while forcing one-per-view is meaningless when there's one view. Slice by state concern instead: board state, compose-field state, speech state, settings. This is a case where Google's rule is a team-coordination device (so two devs don't fight over one class) with zero value for a solo dev.
    sources: https://docs.flutter.dev/app-architecture/guide | https://riverpod.dev/docs/concepts2/providers
  - (high, LOAD-BEARING) Google's 'make fakes for testing' recommendation, applied to the board repository, would actively defeat this project's #2 safety property (migration correctness).
    The docs rate **Strongly recommend**: "Make fakes for testing (and write code that takes advantage of fakes.)... Fakes aren't concerned with the inner workings of any given method as much as they're concerned with inputs and outputs." This is sound when the real dependency is a network you can't hit in CI. It is harmful when the real dependency is SQLite: a `FakeBoardRepository` backed by a Map will happily accept a row that the real `PRIMARY KEY (board_id, row, col)` constraint rejects, and will never exercise a drift migration step. Since constraint #1 removes telemetry and constraint #2 makes a bad migration equal to destroying a user's voice, the board repository must be tested against a real in-memory SQLite (`NativeDatabase.memory()`) plus drift's schema-verification/migration test tooling — not a fake. Fake the things that are genuinely un-runnable in a test: `SpeechService` (platform TTS), and the platform channels. Do not fake the database. This is a concrete, defensible departure from a Strongly-recommend.
    sources: https://docs.flutter.dev/app-architecture/recommendations | https://docs.flutter.dev/app-architecture/case-study/testing
  - (high, LOAD-BEARING) Google's per-layer testing recommendation is the one place this project should EXCEED the official guidance rather than trim it.
    The docs say: "Write unit tests for every service, repository and ViewModel class. These tests should test the logic of every method individually. Write widget tests for views. Testing routing and dependency injection are particularly important." This is written for teams that also have Crashlytics as a backstop. With constraint #1 (no telemetry, ever — the developer will never learn the app crashed), tests are the entire safety net, which means the guide's list is a floor, not a target. The guide has nothing at all to say about accessibility testing, which is constraint #3 — there is no official Flutter architecture guidance on enforcing Semantics or TextScaler via tests. That gap must be filled from outside this dimension (flutter_test's `meetsGuideline(textContrastGuideline)`, `SemanticsController`, and pumping with a 200%+ `TextScaler` in `MediaQuery`).
    sources: https://docs.flutter.dev/app-architecture/recommendations | https://docs.flutter.dev/app-architecture/case-study/testing
  - (high) Official guidance on optimistic state exists and is largely irrelevant here — with one exception worth naming.
    /app-architecture/design-patterns/optimistic-state: "Developers can help mitigate this negative perception by presenting a successful UI state before the background task is fully completed." The canonical shape sets the state, notifies, awaits the repository, and reverts on catch. This pattern exists to hide NETWORK latency. This app has no network; a drift write to local SQLite completes in single-digit milliseconds. Applying optimistic state here would add a revert path that can never fire — pure liability. The exception: do NOT apply optimistic reasoning to the speak path. A tile must not render a 'spoken' affordance until the TTS engine has actually accepted the utterance, because optimistically showing success is definitionally the silent-failure bug in constraint #4. Also note optimistic state conflicts with constraint #7 (zero animation / deterministic UI) — a state that appears then reverts is a visual change the user did not cause.
    sources: https://docs.flutter.dev/app-architecture/design-patterns/optimistic-state
  - (high) From the architectural overview, the only correctness-relevant facts for this app are element-tree identity and side-effect-free builds — const and rebuild optimization are NOT load-bearing at 12 tiles.
    /resources/architectural-overview: "During the build phase, Flutter translates the widgets expressed in code into a corresponding element tree, with one element for every widget... the element tree is persistent from frame to frame... By only walking through the widgets that changed, Flutter can rebuild just the parts of the element tree that require reconfiguration." And: "A widget's build function should be free of side effects. Whenever the function is asked to build, the widget should return a new tree of widgets, regardless of what the widget previously returned... it is important that build methods should return quickly, and heavy computational work should be done in some asynchronous manner." Practical translation: (1) NEVER call `speak()` from a `build()` method or a Riverpod `ref.listen` misused as a build-time effect — that is the real, easy-to-hit correctness bug, and it produces repeated/duplicate speech; (2) element reuse means a tile widget at (row,col) keeps its Element and State when `button_id` flips null→set, so if a tile ever holds State, it needs `ValueKey(buttonId)` — but the grid_slots PK design already makes position stable, so a `ValueKey((row, col))` on the slot and stateless tiles sidesteps keys entirely; (3) `const` and rebuild-scoping are performance tools, and with a fixed 3x4 grid and a zero-animation rule there is no performance problem to solve. Spending effort on const-correctness for speed here is misapplied; keep `prefer_const_constructors` on as a free lint and stop thinking about it. Keys are not discussed in the architectural overview at all.
    sources: https://docs.flutter.dev/resources/architectural-overview
  - (medium, LOAD-BEARING) freezed is officially recommended but is likely redundant here because drift already generates immutable data classes.
    Docs rate **Recommend**: "You can use packages to help generate useful functionality in your data models, freezed or built_value. These can generate common model methods like JSON ser/des, deep equality checking and copy methods." Compass uses freezed on all 7 domain models (each has a .freezed.dart and .g.dart). But drift already generates immutable row classes with `copyWith`, `==`/`hashCode`, and `toString` for every table — the exact list of things freezed is recommended FOR. Adding freezed means a second code generator, a second build_runner pass, and a hand-written mapping layer between drift rows and freezed models, which is the "Create separate API models and domain models" recommendation the docs themselves rate **Conditional** with "Using separate models adds verbosity... Use in large apps." With 6 tables and no API, use drift's generated classes as the domain models directly. The one place a hand-written model may be warranted is a `Voice`/`SpeechFailure` type that has no table behind it — write those by hand or as a small sealed class; that's 20 lines, not a code generator.
    sources: https://docs.flutter.dev/app-architecture/recommendations | https://github.com/flutter/samples/tree/main/compass_app
  - (medium) go_router is officially recommended but is not clearly justified for a one-screen app; the decision hinges on Android Quick Settings tile deep-linking, not on navigation complexity.
    Docs rate **Recommend**: "Go_router is the preferred way to write 90% of Flutter applications. There are some specific use-cases that go_router doesn't solve, in which case you can use the Flutter Navigator API directly." This app has one screen plus modes (show-text, edit, settings). Modes are state, not routes — pushing them as routes adds a router config, a routes.dart, and route tests for zero benefit. HOWEVER: the Android QS TileService and the iOS 18 ControlWidget are external entry points, and if either should ever open the app to a specific state, that is a deep link, and deep links are the one thing go_router genuinely earns. Per the already-made decision, the QS tile speaks NATIVELY with no Flutter engine on that path — so it does not deep-link and this justification does not apply. Default to no router: `MaterialApp(home: ...)` with `Navigator.push` for settings/show-text, or plain state flags. Revisit only if an entry point needs to launch into a specific board.
    sources: https://docs.flutter.dev/app-architecture/recommendations
  - (medium, LOAD-BEARING) Following the official folder structure is worth it here for a reason unrelated to correctness: legibility to the stranger who inherits the code.
    Constraint #5 says the developer may abandon this and open-sourcing is the exit plan, so "the code must be READABLE BY A STRANGER." The strongest argument for `lib/data/`, `lib/ui/<feature>/view_models/`, `lib/ui/<feature>/widgets/` is that it is now the structure Flutter's own docs teach, the structure the official sample uses, and therefore the structure a random Flutter dev in 2026 recognizes on sight without reading a CONTRIBUTING.md. That benefit is real and costs nothing at this size — directories are free. This inverts the usual analysis: adopt the SHAPE of the official architecture (cheap, aids handoff) while rejecting its CEREMONY (use-cases, dual models, abstract repos with one impl, Commands everywhere, freezed). The shape is documentation; the ceremony is team coordination the solo dev doesn't need.
    sources: https://docs.flutter.dev/app-architecture/case-study | https://docs.flutter.dev/app-architecture

CODE EXAMPLES:
  --- Result<T> — copy this from Compass verbatim (lib/utils/result.dart) ---
```dart
/// Utility class to wrap result data
///
/// Evaluate the result using a switch statement:
/// ```dart
/// switch (result) {
///   case Ok(): print(result.value);
///   case Error(): print(result.error);
/// }
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok._;
  const factory Result.error(Exception error) = Error._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);
  final T value;
  @override
  String toString() => 'Result<$T>.ok($value)';
}

final class Error<T> extends Result<T> {
  const Error._(this.error);
  final Exception error;
  @override
  String toString() => 'Result<$T>.error($error)';
}
```
  Verbatim from github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart (BSD-licensed, Copyright 2024 The Flutter team). Because Result is `sealed`, omitting the `case Error()` branch in a switch is a COMPILE ERROR, not a lint. Note `Result.error` takes an `Exception`, not `Object` — wrap non-Exception errors. This is the whole defense against constraint #4.
  --- The speak path: Result makes silence impossible to ignore ---
```dart
// lib/data/services/tts_service.dart — the Service. Thin, wraps the platform,
// holds no state. Google: services "wrap API endpoints... hold no state".
abstract class SpeechService {
  Future<Result<void>> speak(String text);
  Future<Result<void>> stop();
  Future<Result<List<Voice>>> voices();
  Future<Result<void>> setVoice(Voice voice);
}

// lib/data/repositories/speech/speech_repository.dart — the Repository.
// Google: repositories own "error handling" and transform raw service data.
// This is where voice_filter belongs — it is testable, the Service is not.
class SpeechRepository {
  SpeechRepository(this._service);
  final SpeechService _service;

  Future<Result<void>> speak(String text) async {
    // Barge-in: a re-tap means "say it again" / "I need this NOW".
    // This is why speak must NOT be a Command — Command's `if (_running) return`
    // would silently swallow the tap and produce exactly the silence we forbid.
    await _service.stop();
    return _service.speak(text);
  }

  Future<Result<void>> selectVoice(Voice voice) async {
    // flutter_tts.setVoice returns 0 with only a Log.d on failure.
    // The Service must convert that into Result.error; here we must handle it.
    final result = await _service.setVoice(voice);
    switch (result) {
      case Ok():
        return result;
      case Error():
        // Do NOT swallow. Fall back to a known-good voice rather than
        // leaving the user with an engine that will not speak.
        return _service.setVoice(await _fallbackVoice());
    }
  }
}
```
  The load-bearing detail: `switch (result)` on a sealed type will not compile if you drop the Error branch. Compare to a `bool` return, which compiles fine when ignored — that is the bug class that leaves a user in crisis with no speech. Also note speak() is stop-then-speak, deliberately NOT wrapped in a Command.
  --- Proposed lib/ structure — official shape, ceremony stripped ---
```text
lib/
  main.dart
  data/
    database/
      database.dart              # drift @DriftDatabase, migrations
      tables.dart                # boards/buttons/grid_slots/images/sounds/settings
    repositories/
      board/board_repository.dart      # CONCRETE. No interface — tested vs real SQLite.
      speech/speech_repository.dart    # voice_filter + setVoice verification lives here
      settings/settings_repository.dart
    services/
      speech/speech_service.dart       # ABSTRACT — platform boundary, must be faked
      speech/flutter_tts_service.dart  # the one real impl
      platform/personal_voice_channel.dart
  ui/
    board/
      view_models/board_view_model.dart
      view_models/compose_view_model.dart
      widgets/board_screen.dart
      widgets/phrase_tile.dart
      widgets/compose_field.dart
    show_text/widgets/show_text_screen.dart
    settings/
      view_models/settings_view_model.dart
      widgets/settings_screen.dart
    core/themes/theme.dart
  utils/
    result.dart
    command.dart                 # used ONLY by edit-mode mutations
test/                            # mirrors lib/
  data/database/migration_test.dart    # drift schema verification — the #2 safety net
testing/                         # shared fakes: FakeSpeechService, test board fixtures

# DELIBERATELY ABSENT vs Compass (169 files, 6 features):
#   domain/use_cases/    — docs: "in most apps they add unnecessary overhead"
#   domain/models/       — drift generates immutable row classes already
#   data/services/api/   — no network, ever
#   routing/             — one screen; modes are state, not routes
#   *_repository_local / _remote / _dev — one environment, so no impls to swap
#   config/dependencies.dart — Riverpod overrides replace MultiProvider
```
  This is Google's documented hybrid ("Data layer objects... aren't tied to a single feature, while UI layer objects... are") at roughly 25 files instead of 169. The shape is kept because it aids handoff (constraint #5); the ceremony is dropped because it exists for teams (constraint #6).
  --- Riverpod Notifier IS Google's ViewModel — and the DI story replaces dependencies.dart ---
```dart
// Google's ViewModel: "exposes the application data necessary to render a view",
// "most of the logic... lives in view models", exposes commands.
// A Riverpod Notifier does all three. The case study explicitly says the app
// "could've easily been written with... riverpod, flutter_bloc, and signals."

@riverpod
class BoardViewModel extends _$BoardViewModel {
  @override
  Future<BoardState> build() async {
    // Retrieving + transforming data from a repository = Google's VM job #1.
    return ref.watch(boardRepositoryProvider).loadBoard();
  }

  // Command in Google's sense ("Dart functions that allow views to execute
  // complex logic without knowledge of its implementation") — but NOT the
  // Command CLASS, whose `if (_running) return` guard is wrong for speech.
  Future<void> speakSlot(int row, int col) async {
    final button = state.requireValue.buttonAt(row, col);
    if (button == null) return; // empty slot: nothing to say

    // label != vocalization: tile SHOWS "Overwhelmed", SPEAKS the full phrase.
    final result = await ref.read(speechRepositoryProvider).speak(button.vocalization);

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        // No telemetry (constraint #1) => this MUST surface to the user and to
        // the on-device exportable crash log. Silence is never acceptable.
        ref.read(crashLogProvider).record(error);
        state = AsyncData(state.requireValue.copyWith(speechFailed: true));
    }
  }
}

// DI: Riverpod overrides are the direct analogue of Compass's
// lib/config/dependencies.dart MultiProvider. Do not add package:provider.
final container = ProviderContainer(
  overrides: [
    speechServiceProvider.overrideWithValue(FakeSpeechService()),  // fake: untestable platform
    // boardRepositoryProvider is NOT overridden — it runs against real
    // NativeDatabase.memory(). A fake would never catch a migration bug,
    // and a migration bug is the loss of someone's voice.
  ],
);
```
  Two things to notice. (1) The Error branch is not optional — the compiler demands it, which is the entire point. (2) The override list is where the fake/real judgment gets made explicit: fake the platform, never fake SQLite. This inverts Google's blanket "make fakes" Strongly-recommend for one specific class, on purpose, because constraint #2 outranks it.

FACT-CHECK:
    - [CONFIRMED] Google recommends MVVM with precisely defined roles: View = dumb widgets, ViewModel = where most logic lives, Repository = source of truth, Service = stateless data-source wrapper.
    - [CONFIRMED] Google's domain layer (use-cases) is explicitly conditional and the docs recommend against it for most apps.
    - [CONFIRMED] Flutter's official position on folder structure is a documented hybrid: layer-first at the top level, feature-first inside the UI layer.
    - [PARTIALLY_TRUE] "Flutter's official architecture guide explicitly scopes itself to multi-developer teams and feature-rich apps — this project is outside its stated audience."
      CORRECTION: The quotes are real, but the conclusion inverts what the guide says. The audience paragraph states who the guide was written for; it does not scope out anyone else. The same guide says "The recommendations in this guide can be applied to most apps" and "This is the recommended way to build a Flutter app" — the latter being the sentence immediately after the "some libraries can be swapped out" quote, which the claim truncates. The "some parts don't apply" escape hatch is extended to VERY LARGE teams with unique complexity, not to solo devs. And "nothing in it is a rule — it is a menu" is contradicted by the Strongly Recommend tier on /app-architecture/recommendations: "You should always implement this recommendation if you're starting to build a new application," covering data/UI layer separation, repository pattern, MVVM, unidirectional data flow, immutable models, and DI — with no team-size condition. The defensible version: the guide is written with growing teams in mind and explicitly invites adaptation ("guidelines, not steadfast rules"), and its Domain/use-case layer is officially optional — so a solo dev with one screen can justifiably skip the optional layers and treat the rest as a strong default to deviate from deliberately. That is NOT the same as "outside its stated audience," and this claim should not be used to justify ignoring the Strongly Recommend items wholesale.
    - [PARTIALLY_TRUE] "The project's existing `SpeechService` abstraction is already exactly what Google calls a Service, and the platform channels (Personal Voice, QS Tile, ControlWidget) are Services too."
      CORRECTION: Correct framing: Google's Service is a stateless, side-effect-free, data-loading wrapper over a data source ("It's stateless, and its functions don't have side effects. Its only job is to wrap an external API"). SpeechService is an actuator with speak/stop plus AVAudioSession state, so only voices() maps cleanly — the mapping is partial, not 1:1, and Google's architecture has no named component for a device-actuating command wrapper. Do not call the QS Tile or the iOS 18 ControlWidget Services: per RESEARCH.md:524-525 they run with "No Flutter engine on this path" and read phrases from SharedPreferences/App Group, so no Dart class wraps them and they sit outside the Flutter architecture entirely as a parallel native app — the real architectural question there is shared-storage contract, not layering. Only the Personal Voice channel (~1 method, requestPersonalVoiceAuthorization) is channel-shaped. Google's only strong recommendation is "Use the repository pattern in the data layer" (Priority: Strongly recommend); Service has no standalone recommendation, so this cannot be a validation. Moving voice_filter up is a reasonable but new decision requiring a VoiceRepository that does not exist in the plan — and its setVoice return check is not transformation and has no home in Google's read-oriented data flow at all.
    - [PARTIALLY_TRUE] "The Compass app's `lib/` is 169 files across 6 features, with 6 repositories × 2-3 implementations each — the multi-implementation pattern exists to demonstrate dev/staging/remote environment swapping, which does not exist in this project."
      CORRECTION: Compass's app/lib/ contains 111 files (89 excluding generated .freezed.dart/.g.dart), not 169. It has 7 repositories, not 6 (activity, auth, booking, continent, destination, itinerary_config, user), each with an abstract class plus 1-2 implementations — not "2-3." Six repos have exactly two implementations (local/dev + remote); itinerary_config has exactly one (memory). No repository has three implementations; there are 13 implementations total. The environment-swapping rationale is quoted correctly from docs.flutter.dev/app-architecture/recommendations and the README, and the dev/staging split is real (main_development.dart + providersLocal vs main_staging.dart + providersRemote). But two caveats undercut the causal framing: (a) ItineraryConfigRepository keeps an abstract class with a single implementation used in BOTH environments, so the abstraction is not purely environment-driven; (b) the docs mark "Use abstract repository classes" as "Strongly recommend," defined as "you should always implement this recommendation if you're starting to build a new application" — it is framed as universal, not as a multi-environment-only technique. The "roughly 60% of Compass's structure" figure is unsupported; network/auth/environment-specific files total roughly 26% (~29/111). The reduction argument for a single-environment offline app is directionally sound but should be made with the real numbers: ~26% of files, not 60%, and 7 repositories, not 6.
    - [PARTIALLY_TRUE] "The sealed `Result<T>` type is the single highest-value thing to lift from the official guidance, because it converts this project's worst bug class (silent failure) into a compile-time error."
      CORRECTION: The Result type is worth lifting, and every fact the researcher states about the file is accurate — but the stated justification does not hold, and the project decision should not rest on it.

Correct mechanism: `sealed` + exhaustiveness makes it a compile error to write a switch that MISSES a branch. It does NOT make it a compile error to ignore the Result entirely. `await speechService.speak('x');` discards the Result silently, with no error and no lint. Result converts "unhandled exception" into "ignorable return value" — a real improvement in discoverability, but NOT the "silent failure becomes a compile-time error" that the claim asserts.

To actually get the claimed property, you must add what Compass omits: annotate with `@useResult` from package:meta (api.flutter.dev/flutter/meta/UseResult-class.html) so the analyzer flags discarded Results. That is a one-line addition (`@useResult` on the returning method, plus `import 'package:meta/meta.dart';`) and it is where the real value against silent failure lives — not in `sealed`. Note this is still an ANALYZER diagnostic, not a compiler error; it is only as strong as your CI treating analyzer warnings as blocking.

Also correct the causal story on constraint #4: Result does not detect `setVoice` returning 0. You must hand-write the check that turns that 0 into a `Result.error`. Result only guarantees the error PROPAGATES once detected. The detection gap is the actual root cause of the bug class, and Result does not close it.

Net: keep the plan, downgrade the rationale from "single highest-value / compile-time error" to "cheap, zero-dependency, improves error propagation — but only pays off combined with @useResult + enforced analyzer warnings + hand-written failure detection at the flutter_tts boundary." Downgrade confidence from high to medium.

RECOMMENDATIONS:
  - [must] Adopt the sealed `Result<T>` type from Compass verbatim (copy `lib/utils/result.dart`, ~45 lines, zero deps) and make `SpeechService.speak/stop/setVoice` return `Future<Result<void>>`. Never return bare `void` or `bool` from any speech-path method. — This is the single mechanism that turns constraint #4 (silent failure is the worst bug class) from a discipline problem into a compiler problem. Dart's exhaustiveness checking on a sealed class makes it a COMPILE ERROR to handle Ok without handling Error. flutter_tts's setVoice returning 0 with only a Log.d is exactly the failure a bool return invites you to ignore. With no telemetry, the compiler is the only reviewer you have.
  - [must] Adopt the official folder shape: `lib/data/repositories/`, `lib/data/services/`, `lib/ui/<feature>/view_models/`, `lib/ui/<feature>/widgets/`, `lib/utils/result.dart`, with `test/` mirroring `lib/` and shared fakes in a top-level `testing/`. — Not for correctness — for handoff. Constraint #5 makes stranger-legibility a requirement, and this is now the structure Flutter's own docs and reference app teach, so a random 2026 Flutter dev recognizes it without reading docs. Directories are free; this costs nothing and buys the exit plan.
  - [avoid] Do NOT create a domain/use-case layer. No `lib/domain/use_cases/`. — The docs rate it Conditional and say plainly: "in very large apps, use-cases are useful, but in most apps they add unnecessary overhead." The concepts page says CRUD apps "might not need this optional layer." Even Compass only has 2 use-cases across 169 files. A 12-tile board editor has no logic that crowds a ViewModel.
  - [must] Test the board repository against real in-memory SQLite (`NativeDatabase.memory()`) plus drift's schema/migration test tooling. Do NOT write a `FakeBoardRepository`. — This is a deliberate departure from a Strongly-recommend ("Make fakes for testing"). A Map-backed fake will accept rows that the real `PRIMARY KEY (board_id, row, col)` rejects and will never execute a migration step. Constraint #2 makes migration correctness a safety property — a fake would give you green tests and a destroyed board. Google's fake advice assumes the real dependency is a network; here it's SQLite, which runs fine in a test.
  - [must] Fake only what cannot run in a test: `SpeechService` and the platform channels (Personal Voice, QS Tile, ControlWidget). Keep `SpeechService` abstract; do NOT add an abstract interface over the drift DAO. — The docs justify abstract repositories with "different implementations... for different app environments, such as 'development' and 'staging'" — a rationale that does not exist in a single-environment offline app. The only surviving reason to abstract is the test seam, so abstract exactly the things you cannot execute in a test and nothing else. One interface with one real impl and one fake is justified; one interface with one impl is not.
  - [must] Use the Command pattern ONLY for edit-mode mutations (save tile, delete tile, import/export board). Never wrap the speak action in a Command. — Command's core is `if (_running) return;` — it silently drops re-entrant taps. For a speak button, a second tap means "say it again" or "I need this NOW," and swallowing it produces exactly the silence constraint #4 forbids. Speak must be stop-then-speak (barge-in). For DB writes, double-execution is a real hazard and Command's guard is correct. Applying it uniformly because it's recommended is the clearest available cargo-cult failure.
  - [avoid] Do not add `package:provider`. Riverpod already satisfies the Strongly-recommend on dependency injection; use provider overrides in tests where Compass uses `lib/config/dependencies.dart`. — The DI case-study page recommends provider and never mentions Riverpod, but the stated GOAL — "prevents your app from having globally accessible objects" — is what Riverpod does. The case study explicitly blesses substitution: the app "could've easily been written with... riverpod, flutter_bloc, and signals." Two DI mechanisms is strictly worse than one.
  - [should] Ignore Google's "Views and view models should have a one-to-one relationship." Slice Riverpod Notifiers by state concern instead: board, compose field, speech, settings. — With one screen, the 1:1 rule either produces a god object or is vacuous. The rule is a team-coordination device — it stops two devs fighting over one class — and has zero value for a solo dev. Riverpod's providers are global by design and don't enforce it anyway.
  - [should] Skip freezed. Use drift's generated row classes as the domain models directly. Hand-write the few non-table types (Voice, SpeechFailure) as small sealed classes. — The docs recommend freezed for "JSON ser/des, deep equality checking and copy methods" — drift already generates all three. Adding freezed means a second generator plus a hand-written drift-row→freezed-model mapping layer, which is the "separate API and domain models" recommendation the docs themselves rate Conditional with "Use in large apps." There is no API here.
  - [should] Skip go_router. Use `MaterialApp(home:)` with `Navigator.push` for settings/show-text, or plain state flags for modes. Revisit only if an external entry point must launch into a specific board. — Modes are state, not routes. The one thing go_router genuinely earns is deep linking, and the already-made decision has the Android QS tile speaking natively with no Flutter engine on that path — so it never deep-links. A router config plus routes.dart plus route tests for one screen is pure overhead.
  - [must] Never call `speak()` — or any side effect — from a `build()` method or from a Riverpod provider's build. Route all speech through an explicit user-event handler. — Flutter's architectural overview: "A widget's build function should be free of side effects. Whenever the function is asked to build, the widget should return a new tree of widgets, regardless of what the widget previously returned." Because the element tree persists and rebuilds are triggered by state changes you don't fully control (MediaQuery a11y flags, TTS voice-availability changes — both of which this app subscribes to), a speak() in build produces duplicated or spontaneous speech. This is the one architectural-overview fact that is a real correctness hazard here.
  - [avoid] Do not apply optimistic state anywhere, and especially not to the speak path — a tile must not indicate success until the TTS engine has accepted the utterance. — Optimistic state exists to hide network latency; a drift write to local SQLite is single-digit ms, so the revert path could never fire and is pure liability. On the speak path it's worse than useless: showing success before the engine confirms IS the silent-failure bug from constraint #4. It also violates constraint #7 — a state that appears then reverts is a visual change the user didn't cause.
  - [must] Treat Google's per-layer testing list as a floor, not a target, and fill the accessibility gap it leaves entirely unaddressed with `meetsGuideline()`, `SemanticsController` assertions on every tile, and widget tests pumped at TextScaler 2.0+. — The docs say "Write unit tests for every service, repository and ViewModel class... Write widget tests for views" — but that's calibrated for teams that also run Crashlytics. Constraint #1 removes the backstop entirely. And the architecture guide says nothing whatsoever about accessibility, which constraint #3 makes correctness — that gap is real and official guidance will not fill it.
  - [avoid] Do not optimize rebuilds or chase const-correctness for performance. Leave `prefer_const_constructors` on as a free lint and spend the effort on tests instead. — A fixed 3x4 grid with a zero-animation rule has no performance problem to solve. The element tree already "walks through only the widgets that changed." Const matters here as a lint-level habit, not as an optimization. Given a 2-week MVP (constraint #6), rebuild-scoping is effort stolen from the migration and accessibility tests that are actually load-bearing.
  - [should] Put the `voice_filter` logic (Android network_required check, setVoice return-value check) in a repository, not in the raw flutter_tts wrapper. — Google's split is explicit: Services "wrap API endpoints... hold no state" and are "only used to isolate data-loading"; Repositories are "responsible for polling data from services, and transforming that raw data into domain models" and own "error handling." The flutter_tts wrapper is the Service (a platform API, which the docs name explicitly as a service example); filtering unusable voices and verifying setVoice actually took effect is transformation + error handling, i.e. repository work. This keeps the untestable platform boundary thin and puts the logic you most need to test in a class you can test.

---

### DIMENSION: project-structure
SUMMARY: For a ONE-screen app whose four "features" (speak/show/edit/settings) all read and write the same five tables, feature-first is the wrong axis — Andrea Bizzotto's own definition ("a feature is a functional requirement that helps the user complete a given task") plus his warning about the "unbalanced" structure you get when models and repositories are genuinely shared describes this app exactly: feature-first here would push ~all real code into a `shared/` folder and leave four thin UI folders. The correct answer is the hybrid the official Flutter architecture guide and its Compass case study already codify: `lib/data/` organized BY TYPE (repositories/services are shared across every surface), `lib/ui/<surface>/` organized BY FEATURE, `lib/ui/core/` for theme + shared widgets. This choice is doubly right for constraint 5 (abandonment/open-sourcing): it is the one tree a stranger has literally read docs.flutter.dev for. Do NOT split into local packages and do NOT use melos — melos itself is described as "a multiplier: without scale it multiplies complexity," and since Melos 7 it just delegates to Dart pub workspaces anyway; with one package there is nothing to multiply. Do NOT federate the native interop into a plugin — federation exists so different *organizations* can own different platform implementations; here the Android QS TileService and iOS ControlWidget are native targets that never appear in `lib/` at all, and only Personal Voice needs a Dart-side channel. Skip barrel files (analyzer cost + circular-import risk, zero benefit at ~40 files) and skip `lib/src/` (a public-API boundary for *packages*; an app has no consumers). Three structural items ARE load-bearing and non-obvious: `drift_schemas/` must be checked into git or migration testing is impossible (constraint 2); a `lib/native/` directory should quarantine every MethodChannel because those are the only untestable-without-a-device paths (constraint 4); and the SharedPreferences keys the Kotlin QS tile reads are a compiler-unenforced contract crossing a language boundary — that is the one real module boundary in this codebase and it needs a single named file on each side. Finally, be honest that "a11y enforced by lints" mostly does not exist: there is no stock lint for "Semantics on every tile," so `test/ui/` with flutter_test's `meetsGuideline(...)` matchers is the enforcement point, not analysis_options.yaml.

FINDINGS:
  - (high, LOAD-BEARING) Feature-first is a poor fit for this app because its 'features' are surfaces over one shared data model, not independent functional requirements.
    Bizzotto defines a feature as 'a functional requirement that helps the user complete a given task' and explicitly describes his own mistake of structuring features around pages (product_page, products_list), which produced an 'unbalanced' structure because models and repositories were genuinely shared. This app's speak/show/edit/settings all operate on boards/buttons/grid_slots/settings — under feature-first, BoardRepository, AppDatabase, SpeechService, voice_filter and the models (i.e. nearly all non-widget code) land in a top-level shared/, leaving four folders of widgets. He also states the pragmatic escape hatch directly: 'if we're building just a single-page app, we can put all files in one folder and call it a day.'
    sources: https://codewithandrea.com/articles/flutter-project-structure/
  - (high, LOAD-BEARING) The official Flutter architecture case study (Compass) prescribes exactly the hybrid this app needs: data-by-type, ui-by-feature.
    Tree: lib/ui/core/{ui,themes}/, lib/ui/<feature>/{view_models,widgets}/, lib/domain/models/, lib/data/{repositories,services,model}/, lib/config/, lib/utils/, lib/routing/, main*.dart; test/ mirrors {data,domain,ui,utils}; plus a top-level testing/{fakes,models}. Stated rationale: 'The data folder organizes code by type, because repositories and services can be used across different features and by multiple view models. The ui folder organizes the code by feature, because each feature has exactly one view and exactly one view model.' Compass is NOT a monorepo of local packages — it is a single app/ package alongside a server/ and docs/.
    sources: https://docs.flutter.dev/app-architecture/case-study | https://github.com/flutter/samples/tree/main/compass_app | https://docs.flutter.dev/app-architecture/guide
  - (high, LOAD-BEARING) Local packages + melos are a net loss for a solo, single-app, two-week MVP.
    2025 community framing: 'For solo developers, Melos feels like an investment, whereas for teams, it feels like relief'; 'Melos is a multiplier — without scale, it multiplies complexity instead of productivity'; benefits arrive 'once they start managing multiple apps or client projects together.' Additionally, since Melos 7.0.0 Melos delegates dependency resolution to Dart pub workspaces (Dart 3.6+, `resolution: workspace`), so its residual value is multi-package versioning/changelogs/publishing — none of which apply. If a split ever becomes necessary, use pub workspaces directly and skip melos entirely.
    sources: https://shahzaibabid.com/when-to-use-flutter-melos-and-monorepo/ | https://melos.invertase.dev/guides/migrations | https://dart.dev/tools/pub/workspaces | https://dart.dev/blog/announcing-dart-3-6
  - (high, LOAD-BEARING) A federated plugin for the native interop is overkill; most of this app's native surface never enters lib/ at all.
    Federated plugins exist to separate platform support into independently-owned packages (app-facing package + platform_interface + per-platform packages) — the motivating case is different orgs/teams owning different platforms. Here one dev owns all of it. Concretely: the Android QS TileService is Kotlin in android/app/src/main/kotlin/ that runs with NO Flutter engine (by design), and the iOS ControlWidget is a separate Swift app-extension target — neither has Dart code. Only Personal Voice needs a MethodChannel. Flutter's own docs note 'Platform channels are usually internal implementation details' — treat them as such: plain files in the app.
    sources: https://docs.flutter.dev/platform-integration/platform-channels | https://docs.flutter.dev/testing/plugins-in-tests
  - (high, LOAD-BEARING) The real module boundary in this codebase is the Dart↔Kotlin SharedPreferences contract the QS tile reads — and nothing in the compiler enforces it.
    The decided design has the Android TileService speak natively from SharedPreferences with no Flutter engine on that path. That means the pref key names, value encoding, and the invariant 'the vocalization text is always present and non-empty' are a cross-language contract with zero type checking. If Dart renames a key, the tile silently speaks nothing — the exact silent-failure class of constraint 4, in the one code path the user reaches mid-shutdown. Structural consequence: exactly one Dart file (lib/native/quick_tile_bridge.dart) may touch those keys, exactly one Kotlin object (QuickTileKeys.kt) may mirror them, and the key strings belong in a doc comment on both.
    sources: https://docs.flutter.dev/platform-integration/platform-channels
  - (high) Barrel files should be skipped: measurable analyzer/build cost and circular-import risk, no benefit at this size.
    2024-2025 consensus: barrel files 'negatively affect the analyzer's performance'; on larger projects they 'cause circular dependencies between files which are dependent on each other' leading to 'runtime errors, hard-to-debug issues, and slower build times.' DCM ships an avoid-barrel-files rule; barrel_file_lints exists to police the pattern (the tell that it needs policing). At ~40 files with IDE auto-import, the ergonomic win is zero.
    sources: https://dcm.dev/docs/rules/common/avoid-barrel-files/ | https://articles.wesionary.team/the-hidden-costs-of-barrel-files-25de560b9f63 | https://pub.dev/packages/barrel_file_lints | https://tkdodo.eu/blog/please-stop-using-barrel-files
  - (high) lib/src/ is a package convention and is meaningless for an application.
    dart.dev: lib/src holds 'internal implementation libraries that should only be imported and used by the package itself' and 'you should never import from another package's lib/src directory. Those files are not part of the package's public API.' An app has no external importers, so lib/src/ buys nothing and adds a path segment to every import. Use it ONLY if a directory ever becomes a published package.
    sources: https://dart.dev/tools/pub/package-layout
  - (high) Effective Dart's actual rules are narrower than folklore: lowercase_with_underscores for files/dirs/packages/import-prefixes, UpperCamelCase for types, lowerCamelCase for constants (not SCREAMING_CAPS), directive ordering dart:/package:/relative with exports last, each section alphabetized.
    Verbatim points from dart.dev/effective-dart/style: constants 'prefer lowerCamelCase in new code' (SCREAMING_CAPS only for consistency with existing/generated code); acronyms >2 letters capitalize as words (Http, Uri) while two-letter ones stay caps (ID, UI), and abbreviations starting a lowerCamelCase identifier stay lowercase (httpConnection). Note prefer_relative_imports and always_use_package_imports are explicitly incompatible per dart.dev — pick one and enforce it; mixing lets the same member be imported two ways.
    sources: https://dart.dev/effective-dart/style | https://dart.dev/tools/linter-rules/prefer_relative_imports | https://dart.dev/tools/linter-rules/always_use_package_imports
  - (medium, LOAD-BEARING) drift_schemas/ and test/generated_migrations/ are structural, must be committed to git, and are the only mechanism that makes constraint 2 testable.
    Commands: `dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/` (one JSON per historical version), `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`, and `dart run drift_dev schema steps drift_schemas/ lib/data/database/schema_versions.dart` for step-by-step migration helpers. Drift's default migration-test directory is test/drift/. Newer drift_dev consolidates these behind `make-migrations`, which requires the database location declared in build.yaml. If drift_schemas/ is gitignored or a dump is skipped for a version, that version can never be tested against again — the schema history is unrecoverable.
    sources: https://drift.simonbinder.eu/migrations/exports/ | https://drift.simonbinder.eu/migrations/tests/ | https://drift.simonbinder.eu/migrations/step_by_step/
  - (medium, LOAD-BEARING) A domain/ layer with hand-written mirror models and mappers is the Clean-Architecture overhead to cut; drift's generated row classes should BE the domain models, with exactly one hand-written value object for the grid.
    The 2025 backlash is specific: developers report 'spending months writing mappers between entities and models, creating use cases for simple API calls'; 'for small applications... clean architecture can introduce unnecessary overhead, especially if the app is limited to a few screens.' Here there is no API and no serialization boundary — the SQLite row IS the truth, so entity↔model mapping maps a type onto itself. The one genuine exception: grid_slots' PK is (board_id,row,col) with a nullable button_id, so the UI wants a materialized fixed 3x4 BoardGrid of Tile? — that shape does not exist in any table and deserves a real hand-written type. Cost accepted: renaming a column ripples into widgets — but as a compile error, not a field bug.
    sources: https://yshean.com/flutter-architecture-patterns-clean-architecture-vs-feature-first | https://leancode.co/glossary/clean-architecture-in-flutter
  - (medium, LOAD-BEARING) Accessibility cannot be enforced by lints — there is no stock lint for 'Semantics on every tile' — so test/ui/ is the enforcement point, using flutter_test's built-in guideline matchers.
    flutter_lints / very_good_analysis contain no a11y rules; the enforceable mechanism is `await expectLater(tester, meetsGuideline(androidTapTargetGuideline))`, `iOSTapTargetGuideline`, `textContrastGuideline`, and `labeledTapTargetGuideline` in widget tests, plus pumping with a MediaQuery TextScaler of 2.0+ to assert no overflow and no clamping. Structural consequence: a shared test/util/a11y.dart helper (e.g. expectAccessible(tester)) invoked from every widget test, because the constraint-3 promise otherwise reduces to discipline — which is what constraint 1 says cannot be relied on.
    sources: https://docs.flutter.dev/testing/overview | https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html
  - (high, LOAD-BEARING) Starter phrase sets should be Dart const data, not a JSON asset — a JSON asset is a cold-start silent-failure surface.
    pubspec asset declaration is non-recursive: a `- assets/` entry bundles only files directly in that directory, and every subdirectory needs its own trailing-slash entry (resolution variants like assets/2.0x/ are the sole exception). A missed entry means rootBundle.loadString throws at first run of a fresh install — i.e. a new user opens the app and has NO board. A const List<SeedTile> in lib/data/seed/starter_phrases.dart is compile-time-checked, cannot fail to load, and costs ~12 entries. Reserve asset+parser work for the later Open Board Format *import* path, where the input is a user file and failure is legitimately runtime.
    sources: https://docs.flutter.dev/ui/assets/assets-and-images
  - (medium) VGV's very_good_cli template encodes team-scale conventions (flavors, l10n, cubit-per-feature, coverage gates) whose per-item value should be re-decided individually here.
    very_good_cli 'encodes VGV's production engineering decisions — folder structure, linting, test configuration, CI setup, coverage thresholds'; the core template is folder-by-feature with view+cubit per feature and ships main_development/main_staging/main_production, l10n/, bootstrap.dart, and a counter feature. Of these, bootstrap.dart (runZonedGuarded + FlutterError.onError) is worth keeping and retargeting at the on-device crash log; three flavor entrypoints are pure cost for an app with no server or environments. very_good_analysis is stricter than flutter_lints; verify whether it enables public_member_api_docs before adopting, since doc-comments on every private widget is team ceremony for a solo MVP.
    sources: https://cli.vgv.dev/docs/templates/core | https://verygood.ventures/blog/very-good-cli-1-0-flutter-testing-mcp-semantic-versioning/ | https://pub.dev/packages/very_good_analysis
  - (medium, LOAD-BEARING) There is no compelling 2026 'small serious Flutter app' exemplar other than flutter/samples/compass_app — and that is itself an argument for copying it.
    compass_app is the app the official architecture docs are written against, is maintained by the Flutter team, is a plain single-package app (not a melos monorepo), and has 'high test coverage.' For constraint 5 (a stranger must pick this up; open-sourcing is the exit plan), matching the tree that docs.flutter.dev teaches means a stranger's onboarding cost is a doc they may have already read. Deviating from it needs a reason; 'I prefer feature-first' is not one for a one-screen app.
    sources: https://github.com/flutter/samples/tree/main/compass_app | https://docs.flutter.dev/app-architecture/recommendations | https://docs.flutter.dev/app-architecture/case-study

CODE EXAMPLES:
  --- Recommended tree for THIS app (single package, official hybrid layout) ---
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
  --- The cross-language contract: sole owner on each side ---
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
  --- Analysis options: what's actually worth turning on for a solo AAC app ---
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
  --- The a11y helper that makes constraint 3 enforceable ---
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

FACT-CHECK:
    - [CONFIRMED] The official Flutter architecture case study (Compass) prescribes exactly the hybrid this app needs: data-by-type, ui-by-feature.
    - [PARTIALLY_TRUE] "Feature-first is a poor fit for this app because its 'features' are surfaces over one shared data model, not independent functional requirements."
      CORRECTION: The quotes are accurate, but they do not support the conclusion. Two specific corrections:

1. Bizzotto attributes the "unbalanced" structure to mixing feature-first (presentation) with layer-first (everything else) — "I cornered myself into a layer-first approach for the remaining layers" — not to models/repositories being genuinely shared. Shared models were the symptom of slicing by page.

2. His fix is to "organize the project structure around the domain layer." A shared data model is the precondition for his approach, not a disqualifier. For this app that means features named `boards`, `buttons`, `settings` (the domain entities), each owning its models and repository, with speak/show/edit as presentation inside them — not four widget folders plus a giant shared/. He explicitly allows one feature to depend on another ("code inside a given feature to depend on code from a different feature") and warns against `shared`/`common` dumping grounds, so the predicted "nearly all non-widget code lands in shared/" is an artifact of slicing by page, which is the very mistake he recounts.

The defensible version of the claim: "Feature-first organized around SCREENS (speak/show/edit) is a poor fit — that's Bizzotto's own documented mistake. Feature-first organized around DOMAIN MODELS (boards/buttons/settings) is what he actually recommends." If the team wants to justify a flat or layer-first structure, that decision must rest on the app's small size, not on this article — and the "single-page app, one folder" line does not apply to a four-surface app with a database, repository, and speech service.
    - [PARTIALLY_TRUE] "Local packages + melos are a net loss for a solo, single-app, two-week MVP."
      CORRECTION: Three corrections. (1) Attribution: this is not "2025 community framing" — all three quotes come from a single blog post by one author (Shahzaib Abid, shahzaibabid.com). Cite it as one practitioner's opinion, not community consensus. (2) Residual value: after Melos 7.0.0's delegation to pub workspaces, Melos retains MORE than versioning/changelogs/publishing — the migration guide also lists cross-package script execution and package filtering/categorization, and lazebny.io notes running CI checks only on changed packages. (These still don't apply to a one-app MVP, so the conclusion stands.) (3) "Use pub workspaces directly and skip melos entirely" is not supported by the cited sources; lazebny.io explicitly presents workspaces and Melos as complementary (workspaces first, Melos layered on top for automation). Accurate framing: for a solo two-week single-app MVP, pub workspaces alone (Dart >=3.6.0, `resolution: workspace`) cover any local-package split, and Melos's remaining features have no addressable use case at that scale — so defer Melos, not "skip it entirely" as a permanent rule. Also note for currency: Melos is at 8.2.2 (Invertase, actively maintained, published within days), not dead; 7.0.0 is correct only as the historical workspace-migration boundary.
    - [PARTIALLY_TRUE] "A federated plugin for the native interop is overkill; most of this app's native surface never enters lib/ at all."
      CORRECTION: Keep the decision, fix the citation. (a) The quote belongs to https://docs.flutter.dev/testing/plugins-in-tests, not platform-channels, and reads "Platform channels are usually internal implementation details OF PLUGINS" — restore "of plugins" and stop using it as structural guidance; it is a testing warning about third-party plugins' unstable contracts. (b) Cite platform-channels instead, for what it actually says: extract to a plugin when "you expect to use your platform-specific code in multiple Flutter apps"; otherwise the docs' own example "adds the platform-specific code inside the main app itself." One app, one owner, no cross-app reuse → in-app is the documented default, and federation (specifically the package-separated variant) is indeed unwarranted. (c) The docs' stated federation benefit is that it "allows a domain expert to extend an existing plugin to work for the platform they know best" — third-party extension of a published plugin, not "different orgs own different platforms." (d) Drop "runs with NO Flutter engine (by design)" as a claim about TileService; TileService can host a background Dart entrypoint via a callback dispatcher (see Apparence-io/quick_settings, @pragma("vm:entry-point")). Say "we chose not to run an engine in the tile" instead. (e) Do not let "plain files in the app" mean bare MethodChannel calls sprinkled through lib/. plugins-in-tests explicitly ranks "wrap the plugin in your own API" first and "mock the platform channel" last, so wrap the Personal Voice channel behind a single Dart interface in lib/ — that buys the testability the federated split would have given you, at ~30 lines instead of three packages.
    - [PARTIALLY_TRUE] "The real module boundary in this codebase is the Dart↔Kotlin SharedPreferences contract the QS tile reads — and nothing in the compiler enforces it."
      CORRECTION: Keep the one-file-per-side discipline; fix the mechanism, the risk story, and the confidence.

MECHANISM: Do not hand-roll a SharedPreferences key contract against shared_preferences. Its Android default is DataStore Preferences (protobuf, FlutterSharedPreferences.preferences_pb), which context.getSharedPreferences() cannot read at all, and native access to it is an open unresolved issue (flutter/flutter#154208, P3). Two correct options:
(a) PREFERRED — use home_widget 0.9.3 (already the doc's chosen package): HomeWidget.saveWidgetData<String>(...) from Dart, and in the TileService read via `import es.antonborri.home_widget.HomeWidgetPlugin` → `HomeWidgetPlugin.getData(context).getString(key, null)`. This is plain SharedPreferences ("HomeWidgetPreferences"), no prefix, and is the package's supported native-read path.
(b) If shared_preferences is required, explicitly opt into the SharedPreferences backend via SharedPreferencesAsyncAndroidOptions with SharedPreferencesAndroidBackendLibrary.SharedPreferences, and account for the `flutter.` key prefix on the legacy API — Kotlin must read "flutter.<key>", not "<key>".

RISK STORY: This boundary fails loudly and deterministically (wrong store or wrong prefix ⇒ every tap speaks nothing, caught by the first manual tap), not silently. It is not an instance of the silent-failure class. The genuinely silent risks on this path are different and worth naming instead: a stale value (tile speaks yesterday's phrase because Dart wrote after the last widget update), an empty-but-present string passing a null check, and encoding drift on List<String>.

ENFORCEMENT: "Zero type checking" is real for key strings but the doc-comment-on-both-sides proposal is the weakest available option. Stronger: one Dart file + one Kotlin object is fine as structure, but enforce it with an integration test that writes from Dart and asserts the Kotlin read path returns the exact value — that catches renames, prefix errors, backend misconfiguration, and encoding drift in one check. A doc comment catches none of them.

STATUS: Downgrade confidence from high to medium-at-best, and label it a proposal, not a description — there is no Dart or Kotlin in this repo yet, and the source doc rates this consequence "medium" while hedging the storage as "SharedPreferences or DataStore".
    - [PARTIALLY_TRUE] "drift_schemas/ and test/generated_migrations/ are structural, must be committed to git, and are the only mechanism that makes constraint 2 testable."
      CORRECTION: Keep the commands as written — all three are verbatim-correct against current drift_dev 2.34.4 docs, and the make-migrations/build.yaml `databases` requirement is real. Fix four things. (1) Drop "unrecoverable": drift_schemas/*.json are derived artifacts. `schema dump` reads the schema from the Dart source (and per /migrations/exports/ also accepts a sqlite3 database file as its first argument), so a missed version is regenerated by checking out that version's commit/tag and re-running the dump. Committing drift_schemas/ buys convenience and review-visible schema diffs, not the existence of the history — the code history is the real backstop. (2) Drop "only mechanism": migration tests from a historical version (SchemaVerifier.startAt, migrateAndValidate, schemaAt) do require the exports, but validateDatabaseSchema verifies a database against the expected schema at runtime with no exports at all. Say "the only documented way to test migrations *from a historical version*". (3) Split the two directories: drift_schemas/ = commit it (checked-in JSON, drift's own repo does this); test/generated_migrations/ = generated output of `schema generate`, regenerable from drift_schemas/, not structural and not required to be committed (committing it is a defensible CI-speed choice, not a drift requirement). (4) Correct the defaults sentence: test/drift/ is the make-migrations `test_dir` default, and make-migrations also defaults the schema dir to drift_schemas/. test/generated_migrations/ is just the manual-flow docs example, not a drift default — if the project adopts make-migrations, prefer the defaults rather than the example paths.
    - [PARTIALLY_TRUE] "A domain/ layer with hand-written mirror models and mappers is the Clean-Architecture overhead to cut; drift's generated row classes should BE the domain models, with exactly one hand-written value object for the grid."
      CORRECTION: Keep the thesis, fix four specifics. (1) Cite the primary source, not the blogs: docs.flutter.dev/app-architecture/case-study/domain-layer says the domain layer "is optional and only needs to be implemented if your application has complex business logic that happens on the client" and CRUD apps "might not need this optional layer." That is Flutter's own vendor guidance and it does the work both blog posts were recruited for. (2) Drop "The 2025 backlash" — leancode.co is dated July 27, 2023, and yshean.com is an undated personal blog from a self-described 5-developer team. Two posts, one three years old, is n=2 anecdote, not a backlash; state it as "individual practitioner reports, consistent with Flutter's official guidance." (3) "Exactly one hand-written value object" is wrong — it is at least two. Drift emits a row class per table and never per join; joins return List<TypedResult> which you unpack with readTable()/readTableOrNull(), and drift's own docs hand-write an EntryWithCategory class for exactly this shape. A displayable tile is grid_slots ⟕ buttons ⟕ images with two nullable FKs, so Tile is a hand-written joined type in addition to BoardGrid. Budget for BoardGrid + Tile. (4) "Fixed 3x4" contradicts the project's own schema — RESEARCH.md:380 gives boards.grid_rows / boards.grid_cols, settings carries a grid_size key, and design-distress.md:219 requires a 2x3 crisis/large layout alongside the 3x4 default. BoardGrid must take its dimensions from the board row; hard-coding 3x4 would ship a bug against the spec. Corrected claim: "Skip the domain/ mirror-model layer — Flutter's official architecture guidance makes the domain layer optional for CRUD apps, and with no API boundary here entity↔model mapping is identity. Use drift's generated row classes as domain models, plus two hand-written types: a joined Tile (grid_slots+buttons+images, since drift generates no class for joins) and a per-board-dimensioned BoardGrid of Tile? materialized from boards.grid_rows × boards.grid_cols."

RECOMMENDATIONS:
  - [must] Use the official Flutter hybrid tree: lib/{data,domain,ui,native}/ with data organized by TYPE and ui organized by SURFACE. Do not adopt feature-first. — All four surfaces read the same five tables; feature-first would hollow out into four widget folders plus a shared/ containing all real code — the exact 'unbalanced' failure Bizzotto documents. The hybrid is also the tree docs.flutter.dev teaches, which is the cheapest possible onboarding for the stranger who inherits this.
  - [must] Ship as ONE package. No packages/core, no packages/db, no melos, no pub workspaces. — Package splits buy enforced dependency direction and independent test runs — both of which a solo dev on 40 files gets from a code review of their own diff. They cost pubspec fan-out, a second analysis_options, generated-code path pain (drift builders per package), and IDE friction. Melos is a multiplier with nothing to multiply; since v7 it just wraps pub workspaces anyway.
  - [must] Put every MethodChannel in lib/native/, one file per channel, each behind an abstract interface with a fake in test/util/. Never construct a MethodChannel outside lib/native/. — These are the only paths that cannot be exercised by flutter test, and with no telemetry they are the paths whose field failures are invisible forever. Quarantining them makes 'what is untested?' answerable by ls.
  - [avoid] Do NOT build a federated plugin (or any plugin) for Personal Voice / QS tile / ControlWidget. — Federation solves multi-org platform ownership. The QS TileService and ControlWidget are native targets with no Dart at all; only Personal Voice needs a channel. A plugin here adds a platform_interface, a version-lockstep problem, and a publishing story in exchange for nothing.
  - [must] Name exactly one Dart file and one Kotlin object as the sole owners of the QS-tile SharedPreferences keys, and document the key strings and the non-empty-vocalization invariant in both. — This is the only true module boundary in the codebase and it crosses a language barrier with zero compiler enforcement. A silent key drift means the crisis-path tile speaks nothing — the worst bug class, in the worst place.
  - [must] Check drift_schemas/ into git and add a dump step to the release checklist BEFORE every schemaVersion bump; keep migration tests in test/drift/ with generated helpers in test/generated_migrations/. — A schema version never dumped can never be migration-tested again, and the failure mode is a user's hand-curated board of months — irreplaceable and unmergeable. This is the cheapest possible insurance against the project's worst outcome.
  - [must] Use drift's generated row classes as the domain models. Write exactly one hand-written domain type — BoardGrid/GridSlot materializing the fixed 3x4 with nullable tiles — and no mappers, no use-case classes, no repository interfaces with a single implementation. — There is no API and no serialization boundary, so mappers would map a type to itself. The grid is the one shape the schema deliberately does not have (position-as-PK with nullable button_id), so it earns a real type. Everything else is the Clean-Architecture tax the 2025 backlash is about.
  - [avoid] No barrel files. No index.dart, no <feature>.dart re-export files. — Documented analyzer slowdown and circular-import hazard, in exchange for import lines your IDE writes for you. At this size there is no upside to trade against.
  - [avoid] No lib/src/ in the app. — lib/src encodes a public-API boundary for package consumers. An app has none; it only lengthens every import path.
  - [should] Pick always_use_package_imports (not prefer_relative_imports) and enable directives_ordering; the two import lints are mutually exclusive by design. — dart.dev states they are incompatible and that mixing lets the same member be imported two ways. For an app that will never be published, package: imports survive file moves and are greppable.
  - [must] Enforce accessibility in test/ui/ via a shared expectAccessible(tester) helper wrapping meetsGuideline(androidTapTargetGuideline / iOSTapTargetGuideline / textContrastGuideline / labeledTapTargetGuideline), plus a TextScaler(2.0) pump per screen. Do not expect analysis_options.yaml to carry any of this. — No stock lint checks for Semantics or text-scale clamping. If a11y is correctness and tests are the only safety net, the a11y assertions must live in the test tree — otherwise 'accessibility is enforced' silently means 'enforced by discipline'.
  - [should] Keep VGV's bootstrap.dart pattern (runZonedGuarded + FlutterError.onError) but wire it to the on-device crash log; drop the three flavor entrypoints and the l10n/ ARB setup for MVP. — The error-trapping wrapper is the only thing standing between an uncaught exception and a user with no voice and no way to report it — it is worth more here than in an app with Crashlytics. Flavors serve environments this app does not have; ~25 chrome strings do not justify ARB tooling in a two-week MVP (revisit before open-sourcing).
  - [must] Ship starter phrases as a const Dart list in lib/data/seed/, not a JSON asset. Reserve assets/ for fonts now and symbols later, and give every asset subdirectory its own trailing-slash pubspec entry. — pubspec asset globs are non-recursive; a missed entry turns first-launch into an empty board via a runtime throw. A const list cannot fail to load and is type-checked at compile time. Colocate font licenses (e.g. assets/fonts/<name>/OFL.txt) so licensing travels with the file when the repo is opened.
  - [should] Skip go_router. Use Navigator.push for show-text/settings/edit, or a state flag. — Four destinations, no deep-link web surface, and the QS-tile/ControlWidget entry can be an intent extra read at startup rather than a route. A router here is configuration in exchange for indirection — and zero-animation is a design rule, so the transition machinery is unwanted too.
  - [should] Mirror lib/ in test/ one-to-one, and keep fakes in test/util/ rather than a top-level testing/ package until integration_test/ actually needs to share them. — Compass uses a top-level testing/ because fakes are shared with integration tests across a package boundary. Promote only when that pressure is real; a mirrored test tree makes 'which file has no test?' a diff of two ls outputs — which matters when tests are the only safety net.
  - [must] Write ARCHITECTURE.md recording the decisions and their REASONS (position-as-PK so reflow is impossible; label != vocalization; setVoice return must be checked; audio session .playback never .ambient; no telemetry by promise), not just the tree. — The exit plan is open-sourcing and the realistic outcome is abandonment. A stranger who does not know WHY grid_slots is keyed by position will 'clean it up' into an ordered list with an index, and reintroduce reflow — silently breaking muscle memory for users who cannot afford it.

---

### DIMENSION: riverpod
SUMMARY: Riverpod 3 is stable and has been since 2025-09-10; current is flutter_riverpod 3.3.2 (2026-06-10), riverpod_lint 3.1.4. This matters more than usual because Riverpod 3 was a redesign, not a point release: essentially every Riverpod tutorial written before late 2025 — including Code With Andrea's canonical "Riverpod 2.0 Ultimate Guide" and the widely-copied `createContainer` + `addTearDown(container.dispose)` test helper — is now describing a dead API. The pinned decision (flutter_riverpod, acknowledged as not load-bearing, chosen for a testable repository/UI seam) survives contact with 3.x and I would keep it. But one of the three stated justifications for it is wrong and should be dropped: MediaQuery accessibility flags should NOT go through Riverpod. They are already an InheritedWidget, they are BuildContext-scoped, and routing them through a provider converts a correct-by-construction rebuild into a staleness bug — in an app where TextScaler handling *is* correctness. Read them at build time in the widget tree. The single most important 3.x finding for THIS app is that automatic retry is ON by default with exponential backoff. In an app with no network, a throwing provider means a corrupt DB or a missing file on disk — a real bug that retry will hide behind a permanent spinner, on a device whose developer will never receive a crash report. Disable it globally. Second most important: Riverpod 3 pauses providers whose only listeners are invisible widgets, so a `ref.listen` safety callback (e.g. "your TTS voice vanished") silently will not fire while the "show text" fullscreen mode covers the grid — a silent-failure vector that maps exactly to constraint #4. On codegen: the official docs explicitly do NOT recommend it as a default ("only if you already use code-generation for other things"). Drift already puts build_runner in the loop so the usual cost argument is weak here, but for six providers the payoff is still near zero and the `.g.dart` noise works against the "readable by a stranger" exit plan. Skip it — with one discipline cost noted below.

FINDINGS:
  - (high, LOAD-BEARING) Riverpod 3 is stable; flutter_riverpod 3.3.2 is current. Any tutorial predating 2025-09-10 describes a superseded API.
    riverpod 3.0.0 stable released 2025-09-10. 3.1.0 (2025-12-26) added AsyncValue.requireValue sync-combining and Override.origin. 3.2.0 (2026-01-17) added Ref.isPaused, fixed Notifiers losing state on dependency change, and deprecated family.overrideWith in favour of family.overrideWith2. 3.3.2 (2026-06-10) is current: fixes unpause assertion errors and AsyncNotifierProvider/StreamNotifierProvider dependency disposal. riverpod_lint is at 3.1.4. Docs were restructured — the old /docs/concepts/* paths are 404 or stale; current content lives under /docs/concepts2/* and /docs/how_to/*.
    sources: https://pub.dev/packages/flutter_riverpod | https://pub.dev/packages/riverpod/changelog | https://pub.dev/packages/riverpod_lint | https://riverpod.dev/docs/whats_new
  - (high, LOAD-BEARING) Automatic retry is ON by default in Riverpod 3 and is actively harmful for this app. Disable it globally.
    Riverpod 3 retries failing providers by default with exponential backoff starting at 200ms and doubling to 6.4s. The rationale is transient network failure — a failure mode this app does not have by construction. Here, a provider that throws means a corrupt DB, a missing image/sound file on disk, or a drift migration that went wrong. Retry converts that loud, diagnosable error into an indefinite loading state, on a device where the developer will never learn it happened (constraint #1). Disable with `retry: (retryCount, error) => null` on ProviderScope; the `Retry` typedef is `Duration? Function(int retryCount, Object error)` and returning null means do not retry. Secondary benefit: retry with a backoff Duration also breaks `tester.pumpAndSettle()` in widget tests, which times out waiting for a scheduler that never settles.
    sources: https://riverpod.dev/docs/concepts2/retry | https://riverpod.dev/docs/3.0_migration | https://github.com/rrousselGit/riverpod/discussions/4431
  - (high, LOAD-BEARING) Riverpod 3 pauses providers whose only listeners are invisible widgets. This is a silent-failure vector for ref.listen-based safety warnings.
    Providers used only by widgets that are not visible are paused by default, detected via Flutter's TickerMode. Pausing cascades: a provider listened to only by paused providers is itself paused. Concretely for this app: when the 'show text' fullscreen route covers the grid, the grid's providers pause. If a voice-availability warning is implemented as `ref.listen(voiceAvailabilityProvider, ...)` on the grid screen, that callback does not fire while paused — the user returns to the grid with a stale/absent warning and taps a tile that produces no speech. This is exactly constraint #4. Mitigation is architectural, not configurational: safety-critical checks belong at the speak() call site inside SpeechService, not in a screen-scoped ref.listen. `Ref.isPaused` (3.2.0+) exists if you need to reason about it; TickerMode can force resume.
    sources: https://riverpod.dev/docs/whats_new | https://riverpod.dev/docs/3.0_migration
  - (high, LOAD-BEARING) StateProvider, StateNotifierProvider and ChangeNotifierProvider are quarantined to a `legacy.dart` import, not deleted. Notifier/AsyncNotifier is the only current idiom.
    In 3.0 these three moved out of the main barrel file into `package:flutter_riverpod/legacy.dart` (and `package:hooks_riverpod/legacy.dart`) and are explicitly discouraged. They still compile if you import legacy.dart — which is the trap: a 2023 tutorial's code will look almost right and the fix will look like 'add an import'. Don't. Use Notifier/AsyncNotifier/StreamNotifier. Related removal: FamilyNotifier, FamilyAsyncNotifier and FamilyStreamNotifier are gone — families now use the base classes with constructor parameters. ScopedProvider is removed (use Provider).
    sources: https://riverpod.dev/docs/3.0_migration | https://riverpod.dev/docs/whats_new
  - (high, LOAD-BEARING) The `.autoDispose` modifier and all AutoDispose* classes are gone. Manual providers default to autoDispose OFF via a new `isAutoDispose:` parameter; codegen defaults it ON.
    Riverpod 2 duplicated every provider/Ref/Notifier for autoDispose (Ref vs AutoDisposeRef, Notifier vs AutoDisposeNotifier). 3.0 unified them; the old compile-time guard is now a riverpod_lint rule (avoid_keep_alive_dependency_inside_auto_dispose). Verified constructor signature: `Provider(Create<ValueT> _create, {String? name, Iterable<ProviderOrFamily>? dependencies, bool isAutoDispose = false, Retry? retry})`. So `Provider.autoDispose((ref) => x)` becomes `Provider((ref) => x, isAutoDispose: true)`. Note the asymmetry that bites: manual providers default to keeping state alive; `@riverpod`-generated ones default to disposing it. `ref.keepAlive()` returns a link with `.close()`, and disposal re-enables automatically on recompute.
    sources: https://pub.dev/documentation/riverpod/latest/riverpod/Provider-class.html | https://riverpod.dev/docs/concepts2/auto_dispose | https://riverpod.dev/docs/3.0_migration
  - (high, LOAD-BEARING) The canonical test idiom changed: `ProviderContainer.test()` self-disposes. `createContainer` + `addTearDown(container.dispose)` is obsolete.
    Added in 3.0.0-dev.12: 'Added ProviderContainer.test(). This is a custom constructor for testing purpose. It is meant to replace the createContainer utility.' The docs state plainly 'No need to dispose the container when the test ends.' This is the highest-traffic stale pattern in existing tutorials — the createContainer/addTearDown helper is copy-pasted across essentially every Riverpod testing article from 2022-2024 and is now pure ceremony. Also added in dev.12: `NotifierProvider.overrideWithBuild`, which mocks a Notifier's build() without replacing the notifier's methods — useful for seeding settings state without a fake class.
    sources: https://riverpod.dev/docs/how_to/testing | https://riverpod.dev/docs/concepts2/containers | https://pub.dev/packages/riverpod/changelog
  - (high) `family.overrideWith` is deprecated as of 3.2.0 in favour of `family.overrideWith2`, and will be renamed back in 4.0.
    Changelog 3.2.0: 'Deprecated family.overrideWith in favour of family.overrideWith2. The behaviour is the same, but the callback now takes the argument as a parameter.' In 4.0.0 overrideWith2 will be renamed to overrideWith. This only matters if a family is used (e.g. a per-slot or per-board provider) AND it is overridden in tests. Given the recommendation below to avoid families entirely for a 12-tile fixed grid, this is likely avoidable — but it is a live deprecation warning if a family sneaks in.
    sources: https://pub.dev/packages/riverpod/changelog
  - (high, LOAD-BEARING) Notifiers are now recreated on every provider rebuild. Holding a TTS controller, timer, or subscription as a Notifier field leaks.
    Changelog 3.0.0-dev.12: 'Notifier and variants are now recreated whenever the provider rebuilds. This enables using Ref.mounted to check dispose.' The 2.x pseudo-singleton behaviour is gone. Directly relevant: SpeechService (flutter_tts wrapper) must NOT be constructed inside or owned by a Notifier — it belongs in a plain `Provider` with `ref.onDispose(() => service.dispose())`, injected via override at the ProviderScope root. `Ref.mounted` (analogous to BuildContext.mounted) now exists to guard post-await state writes.
    sources: https://pub.dev/packages/riverpod/changelog | https://riverpod.dev/docs/whats_new
  - (medium, LOAD-BEARING) All providers now filter updates with `==`, and provider failures are wrapped in `ProviderException`. Both interact with drift.
    3.0 unified update filtering on `==` (2.x was inconsistent, notably for StreamProvider/StreamNotifier); override `Notifier.updateShouldNotify` to opt out. Drift interaction: drift's generated data classes DO override ==, so a settings row provider gets free rebuild suppression (good). But `List<T>` does not override == in Dart, so a `watch()` returning List<GridSlot> always compares unequal and always rebuilds — correct, just not free. Separately, provider failures are rethrown as `ProviderException` wrapping the original; the planned on-device exportable crash log must unwrap `.  ` to record the real error, or every logged entry will read 'ProviderException'.
    sources: https://riverpod.dev/docs/3.0_migration | https://riverpod.dev/docs/whats_new | https://drift.simonbinder.eu/dart_api/streams/
  - (high, LOAD-BEARING) Official docs do NOT recommend code generation as the default — and most riverpod_lint rules are generator-only, which is the real (and only serious) argument for it here.
    riverpod.dev on codegen: adopt it 'only if you already use code-generation for other things' like Freezed or json_serializable, and notes 'code generation is still fairly slow.' The honest tension for this project: drift ALREADY requires build_runner, so the marginal build cost of riverpod_generator is near zero — the usual con doesn't apply. And of riverpod_lint 3.1.4's ~15 rules, roughly 9 are generator-only (provider_dependencies, avoid_build_context_in_providers, unsupported_provider_value, functional_ref, notifier_extends, notifier_build, riverpod_syntax_error, scoped_providers_should_specify_dependencies, avoid_keep_alive_dependency_inside_auto_dispose). Given constraint #3 says enforce by lint not discipline, that's a genuine pull toward codegen. It still loses: those rules police codegen-specific footguns and multi-provider dependency graphs, neither of which a 6-provider hand-written app has. The rules that survive without codegen (missing_provider_scope, avoid_ref_inside_state_dispose, avoid_public_notifier_properties, async_value_nullable_pattern) are the ones that would actually catch a bug here.
    sources: https://riverpod.dev/docs/concepts/about_code_generation | https://pub.dev/packages/riverpod_lint | https://riverpod.dev/docs/whats_new
  - (high, LOAD-BEARING) Routing MediaQuery accessibility flags through Riverpod is wrong, and the prior decision doc names this as a reason to adopt Riverpod. That specific justification should be dropped.
    RESEARCH.md line 361 justifies Riverpod partly by 'clean reaction to MediaQuery a11y flags.' MediaQuery is already an InheritedWidget — it is already a reactive propagation mechanism with correct-by-construction invalidation. To get it into a provider you must either read BuildContext inside a provider (which riverpod_lint bans via avoid_build_context_in_providers, and which the FAQ calls out as putting logic in the UI layer) or push it in from a widget, which introduces a write-then-read ordering hazard and a stale value on the first frame after a settings change. For TextScaler at 200%+ — where being wrong is a total-failure a11y bug, not a cosmetic one — trading a compiler-guaranteed rebuild for a manual sync is a strictly bad trade. Read `MediaQuery.textScalerOf(context)` / `boldTextOf` / `accessibleNavigationOf` at build time in the widget that uses them. Riverpod's other two justifications (testable repository seam, TTS voice-availability changes) are sound and sufficient.
    sources: https://riverpod.dev/docs/root/faq | https://pub.dev/packages/riverpod_lint | https://api.flutter.dev/flutter/widgets/MediaQuery/textScalerOf.html
  - (medium, LOAD-BEARING) For this app Riverpod is mild, affordable ceremony — justified by the test seam alone, but only if usage stays at ~6 plain providers with zero families and zero scoping.
    Honest accounting. What Riverpod actually buys here: (1) override-based dependency injection at the ProviderScope root, which is the whole ballgame given tests are the only safety net — swapping a fake SpeechService and an in-memory drift DB is one line each; (2) AsyncValue's forced loading/error handling, which is a real anti-silent-failure lever; (3) drift .watch() → StreamProvider with caching and multi-listener support without broadcast-stream bookkeeping. What ValueNotifier/InheritedWidget would cost instead: you'd hand-roll a constructor-injected repository (fine, honestly — arguably MORE readable to a stranger), lose AsyncValue and re-derive loading/error by hand (this is where it starts losing), and use StreamBuilder directly (fine). Net: ValueNotifier + constructor injection is a genuinely defensible choice that would cost roughly a day less and read more plainly to a stranger. Riverpod's edge is AsyncValue discipline and override ergonomics in tests. It's close enough that the prior decision's 'don't spend a day on this' is correct — but the decision is only cheap if it stays minimal. Riverpod's cost curve is not in adoption, it's in the family/scoping/codegen/generated-lint stack that teams reach for. A fixed 3x4 grid keyed by (row, col) needs none of it.
    sources: https://riverpod.dev/docs/concepts2/providers | https://riverpod.dev/docs/how_to/testing
  - (high, LOAD-BEARING) The ref.watch/read/listen rules, and the one bug that actually bites in this app.
    Rules: ref.watch in build() and in provider bodies — it subscribes and recomputes. ref.read only inside callbacks (onPressed, Notifier methods) — never in build(), because it takes no subscription and the value goes stale. ref.listen for side effects that are not state (snackbars, navigation, TTS triggers) — it must be called in build()/provider body, not in a callback. The bug that bites here: capturing a value from ref.watch in build() and using it inside an onPressed closure. On a rapid double-tap (plausible under distress — the exact user state this app targets) the closure can hold the pre-rebuild value and speak the previous tile's vocalization. Fix: read the vocalization inside the callback via ref.read at tap time, or better, pass the slot's (row, col) — which is the immutable primary key — into the callback and resolve at speak time. The DB schema already makes this trivial: position IS the key, so a coordinate can never go stale.
    sources: https://github.com/rrousselGit/riverpod/issues/2426 | https://github.com/bizz84/flutter-tips-and-tricks/blob/main/tips/0046-riverpod-difference-between-ref-watch-ref-read-ref-listen/index.md | https://riverpod.dev/docs/root/faq

CODE EXAMPLES:
  --- Root: disable retry, inject the two seams ---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AacDatabase(openConnection());
  final speech = FlutterTtsSpeechService();
  await speech.init(); // audio_session config + voice_filter run here

  runApp(
    ProviderScope(
      // Riverpod 3 retries failing providers by default (200ms -> 6.4s backoff).
      // This app has no network. A provider that throws means a corrupt DB or a
      // missing file on disk -- a real bug. Retrying hides it behind a permanent
      // spinner, on a device that will never send us a crash report. Fail loud.
      retry: (retryCount, error) => null,
      overrides: [
        databaseProvider.overrideWithValue(db),
        speechServiceProvider.overrideWithValue(speech),
      ],
      child: const AacApp(),
    ),
  );
}
```
  `retry` is `Duration? Function(int retryCount, Object error)`; returning null disables. Also settable per-provider. Verified against riverpod.dev/docs/concepts2/retry.
  --- The six providers, hand-written, Riverpod 3 syntax ---
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Seams. Overridden at the root and in every test. -----------------------
// Throwing by default is deliberate: an un-overridden seam fails at the first
// read with a clear message, instead of silently constructing a real DB/TTS
// engine inside a unit test.
final databaseProvider = Provider<AacDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final speechServiceProvider = Provider<SpeechService>(
  (ref) => throw UnimplementedError('speechServiceProvider must be overridden'),
);

// --- Repository -------------------------------------------------------------
final boardRepositoryProvider = Provider<BoardRepository>(
  (ref) => BoardRepository(ref.watch(databaseProvider)),
);

// --- The grid. drift .watch() -> StreamProvider. ----------------------------
// isAutoDispose defaults to FALSE for manual providers in Riverpod 3 (codegen
// defaults it to true -- the asymmetry that bites). False is what we want: the
// grid IS the app, it is never not needed, and rebuilding it on every nav is
// pointless churn on the one screen that must never be slow.
//
// drift streams always emit a current snapshot on subscribe, so watch() alone
// is enough -- no need to combine get() and watch().
final gridSlotsProvider = StreamProvider<List<GridSlot>>(
  (ref) => ref.watch(boardRepositoryProvider).watchSlots(kDefaultBoardId),
);

// --- Settings ---------------------------------------------------------------
class SettingsNotifier extends AsyncNotifier<Settings> {
  @override
  Future<Settings> build() => ref.watch(boardRepositoryProvider).loadSettings();

  // NOTE: In Riverpod 3, Notifiers are recreated on every rebuild. Never cache
  // anything on `this` -- no timers, no controllers, no subscriptions.
  Future<void> setRate(double rate) async {
    await ref.read(boardRepositoryProvider).setRate(rate);
    if (!ref.mounted) return; // Ref.mounted is new in 3.x
    ref.invalidateSelf();
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
```
  Six providers, no families, no scoping, no codegen. `Provider.autoDispose(...)` is gone in 3.x — it's `Provider(..., isAutoDispose: true)`.
  --- Unit test: ProviderContainer.test (no addTearDown) ---
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('a tile speaks its vocalization, never its label', () async {
    final speech = FakeSpeechService();

    // ProviderContainer.test() disposes itself when the test ends.
    // Do NOT write a createContainer helper. Do NOT addTearDown(container.dispose).
    // That pattern is in every 2022-2024 tutorial and is obsolete as of 3.0.
    final container = ProviderContainer.test(
      overrides: [
        speechServiceProvider.overrideWithValue(speech),
        databaseProvider.overrideWithValue(inMemoryDb(seed: [
          GridSlot(row: 0, col: 0, button: Button(
            label: 'Overwhelmed',
            vocalization: "I need to leave, I'm not able to talk right now",
          )),
        ])),
      ],
    );

    final slots = await container.read(gridSlotsProvider.future);
    await container.read(speakSlotProvider)(row: 0, col: 0);

    expect(slots.single.button!.label, 'Overwhelmed');
    expect(speech.spoken, ["I need to leave, I'm not able to talk right now"]);
  });

  test('a provider failure surfaces as an error, and does NOT retry forever', () async {
    final container = ProviderContainer.test(
      overrides: [databaseProvider.overrideWithValue(CorruptDb())],
    );

    // With the root retry disabled this settles into an error immediately.
    // If this test ever hangs, someone re-enabled automatic retry.
    await expectLater(
      container.read(gridSlotsProvider.future),
      throwsA(isA<ProviderException>()),
    );
  });
}
```
  Second test is the load-bearing one: it pins the retry:null decision so a future refactor can't silently undo it. Note failures arrive wrapped in ProviderException.
  --- Widget test: overrides + TextScaler at 200% ---
```dart
testWidgets('tiles are semantic and survive 200% text scale', (tester) async {
  tester.platformDispatcher.textScaleFactorTestValue = 2.0;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(inMemoryDb(seed: kSeedBoard)),
        speechServiceProvider.overrideWithValue(FakeSpeechService()),
      ],
      child: const AacApp(),
    ),
  );
  // Safe only because retry is disabled at the root -- a retrying provider
  // reschedules with a backoff Duration and pumpAndSettle() times out.
  await tester.pumpAndSettle();

  expect(find.bySemanticsLabel('Overwhelmed'), findsOneWidget);
  expect(tester.takeException(), isNull); // no overflow at 2.0x
});
```
  addTearDown IS still correct here — for the test-value cleanup, not for container disposal.
  --- MediaQuery a11y flags stay in the widget tree — not in Riverpod ---
```dart
class PhraseTile extends ConsumerWidget {
  const PhraseTile({super.key, required this.row, required this.col});

  final int row;
  final int col;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A11y flags are read HERE, at build time, from the InheritedWidget that
    // already propagates them correctly. They do not belong in a provider:
    // that would mean either BuildContext inside a provider (lint-banned by
    // avoid_build_context_in_providers) or a manual push-and-sync that is stale
    // for one frame. Never clamp textScaler.
    final textScaler = MediaQuery.textScalerOf(context);
    final boldText = MediaQuery.boldTextOf(context);

    // App state comes from Riverpod. Platform a11y state comes from context.
    final slot = ref.watch(
      gridSlotsProvider.select((a) => a.valueOrNull?.at(row, col)),
    );

    return Semantics(
      button: true,
      label: slot?.button?.label ?? 'Empty tile, row $row column $col',
      child: InkWell(
        // Resolve at TAP time via ref.read, keyed by the immutable (row, col)
        // primary key. Capturing slot.vocalization from build() into this
        // closure would speak a stale sentence on a fast double-tap.
        onTap: slot?.button == null
            ? null
            : () => ref.read(speakSlotProvider)(row: row, col: col),
        child: Text(
          slot?.button?.label ?? '',
          textScaler: textScaler,
          style: TextStyle(
            fontWeight: boldText ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
```
  The split to hold onto: app state via Riverpod, platform/a11y state via BuildContext. This contradicts RESEARCH.md line 361's stated justification for Riverpod.

FACT-CHECK:
    - [CONFIRMED] The canonical test idiom changed: `ProviderContainer.test()` self-disposes. `createContainer` + `addTearDown(container.dispose)` is obsolete.
    - [PARTIALLY_TRUE] "Riverpod 3 is stable; flutter_riverpod 3.3.2 is current. Any tutorial predating 2025-09-10 describes a superseded API."
      CORRECTION: The version and API facts are all accurate and need no correction — riverpod/flutter_riverpod 3.3.2 (2026-06-10), riverpod_lint 3.1.4, 3.0.0 stable on 2025-09-10, and every named API (AsyncValue.requireValue, Override.origin, Ref.isPaused, family.overrideWith2) verifies. The docs restructuring to /docs/concepts2/* and /docs/how_to/* is real; old /docs/concepts/* paths do 404.

The correction is to the final sentence only. Replace "Any tutorial predating 2025-09-10 describes a superseded API" with: "Riverpod 3.0 introduced targeted breaking changes, not a wholesale API replacement. Pre-3.0 tutorials are stale specifically where they use StateProvider/StateNotifierProvider/ChangeNotifierProvider (now behind separate imports), AutoDispose or FamilyNotifier interfaces (removed/consolidated), parameterized Ref types (removed), ProviderObserver (signature now takes ProviderObserverContext), or rely on identical-based update filtering (now ==) or unwrapped provider errors (now ProviderException). Tutorials teaching ConsumerWidget, ref.watch/ref.read, NotifierProvider, FutureProvider, and AsyncValue.when remain valid regardless of date." Screen pre-2025-09 material against that specific list rather than discarding it by publication date.
    - [PARTIALLY_TRUE] "Automatic retry is ON by default in Riverpod 3 and is actively harmful for this app. Disable it globally."
      CORRECTION: Keep the recommendation; fix the reasoning. Correct statement: Riverpod 3 (verified in 3.3.2) retries failing providers by default via `ProviderContainer.defaultRetry`, bounded at `maxRetries = 10` with delays 200ms doubling to a 6400ms ceiling — 38.2 seconds of total added delay, after which the error surfaces as AsyncError. It is NOT indefinite. The error is NOT hidden: during retry the provider exposes `AsyncLoading` carrying `error: (err, stack, retrying: true)`. Retry already skips `Error` subclasses and `ProviderException` (`if (error is ProviderException || error is Error) return null;`), so drift/programmer bugs that throw an `Error` already fail loud and immediate; only `Exception` subclasses (SqliteException, FileSystemException) are retried. The `Retry` typedef and the disable snippet in the claim are exactly correct as written. Drop the pumpAndSettle rationale entirely, or restate it correctly: a pending retry is a `Timer`, and pumpAndSettle waits on scheduled frames, not Timers, so bare `pumpAndSettle()` does not hang — the actual issue (#4431) is that `pumpAndSettle(Duration(seconds: 30))` advances the fake clock, fires the retry timers, and lets retry exceptions escape as unhandled test errors, which the maintainer classified as a Riverpod bug rather than expected behavior.
    - [PARTIALLY_TRUE] "Riverpod 3 pauses providers whose only listeners are invisible widgets. This is a silent-failure vector for ref.listen-based safety warnings."
      CORRECTION: The pause mechanism is described accurately (TickerMode detection, default-on, cascading to upstream providers, Ref.isPaused added in 3.2.0 — all verified exactly), but the claim's central assertion is wrong: this is NOT a silent-failure vector. Riverpod explicitly buffers events emitted while a subscription is paused and replays the LAST one on resume — ProviderSubscription documents "Upon resuming the subscription, if any event was sent while paused, the last event will be sent to the listener," implemented via the `_missedCalled` field in provider_subscription.dart (_notifyData/_notifyError store instead of dropping; resume() replays, then calls _listenedElement.flush()). So a ref.listen(voiceAvailabilityProvider, ...) on the grid screen fires when the fullscreen route pops and the grid resumes; the user does not return to a stale/absent warning, and no speech-less tap results from this mechanism. Accurate statement: pausing DEFERS ref.listen callbacks until resume (coalescing intermediate events to the last one), it does not drop them. The recommendation to put safety-critical checks at the speak() call site in SpeechService rather than a screen-scoped ref.listen is still good engineering — a screen-scoped listener is the wrong home for a call-site invariant, and the deferral does mean no warning shows while the route is covering the grid — but it must not be justified by a silent-failure mechanism that does not exist. Confidence should be downgraded from "high" to moderate, and the decision should not rest on constraint #4 being triggered here.
    - [PARTIALLY_TRUE] "StateProvider, StateNotifierProvider and ChangeNotifierProvider are quarantined to a `legacy.dart` import, not deleted. Notifier/AsyncNotifier is the only current idiom."
      CORRECTION: Two fixes. (1) ScopedProvider was removed in Riverpod 1.0.0 (announced in 1.0.0-dev.2, ~Nov 2021), NOT in 3.0 -- the migration is still "change ScopedProviders to Providers", but it is not a 3.0-related removal and is mentioned in neither claimed source. Anyone on a 2.x codebase already has no ScopedProvider. (2) Notifier/AsyncNotifier/StreamNotifier is not "the only current idiom" -- it is the current idiom for mutable state. Provider, FutureProvider and StreamProvider stay in the main barrel of flutter_riverpod 3.3.2, are not legacy, and remain correct for derived/read-only, async-once, and stream values respectively. Also worth noting: legacy.dart additionally exports StateController, StateNotifier, and the ChangeNotifierProviderFamily/StateNotifierProviderFamily/StateProviderFamily variants.
    - [PARTIALLY_TRUE] "The `.autoDispose` modifier and all AutoDispose* classes are gone. Manual providers default to autoDispose OFF via a new `isAutoDispose:` parameter; codegen defaults it ON."
      CORRECTION: The `.autoDispose` modifier is NOT gone in Riverpod 3.3.2 (current as of 2026-07-15). It survives, undeprecated, as `static const autoDispose = AutoDisposeProviderBuilder();` on Provider (provider.dart line 49), and `AutoDisposeProviderBuilder`/`AutoDisposeProviderFamilyBuilder` still exist in builder.dart marked `@internal` — which is why their dartdoc pages 404 while the symbols remain callable. `Provider.autoDispose((ref) => x)` still compiles and works; it is now sugar forwarding to `Provider(create, isAutoDispose: true)`.

What IS gone is narrower and should be stated precisely: the duplicated *interface clones* — AutoDisposeRef, AutoDisposeNotifier, AutoDisposeProvider, AutoDisposeStateProvider (all 404 on latest docs). 3.0 unified Ref/Notifier into single types.

Everything else in the claim is accurate as written: the exact constructor signature, `isAutoDispose = false` default for manual providers, codegen defaulting to autoDispose ON (opt out via `@Riverpod(keepAlive: true)`), the manual-vs-codegen asymmetry, `ref.keepAlive()` returning a closable link that re-enables on recompute, and the lint rule `avoid_keep_alive_dependency_inside_auto_dispose` (with the added nuance that it is riverpod_generator-only).

PRACTICAL IMPACT ON THE DECISION: if the plan assumes `.autoDispose` call sites will fail to compile on 3.x and force a mechanical codemod, that is backwards. Migrating `.autoDispose` -> `isAutoDispose: true` is OPTIONAL and cosmetic. Only `AutoDisposeRef`/`AutoDisposeNotifier` *type annotations* are breaking and must be rewritten (case-sensitive strip of the `AutoDispose` prefix, per the official migration guide).
    - [REFUTED] "Notifiers are now recreated on every provider rebuild. Holding a TTS controller, timer, or subscription as a Notifier field leaks."
      CORRECTION: Notifiers are NOT recreated on every provider rebuild in any stable Riverpod release. That behaviour existed only transiently during the 3.0 dev cycle (introduced 3.0.0-dev.12, 2025-04-30) and was reverted before stable: "Revert Notifier life-cycle change. They are once again preserved across rebuilds." (3.0.0-dev.16/dev.18, 2025-09-09). Riverpod 3.0.0 stable (2025-09-10) through current 3.3.2 (2026-06-10) all PRESERVE Notifiers across rebuilds — the 2.x pseudo-singleton behaviour the claim calls "gone" was restored.

Consequences for the project decision:
1. The leak premise is void. Holding a TTS controller, timer, or subscription as a Notifier field does NOT leak due to per-rebuild recreation, because that recreation does not occur.
2. `Ref.mounted` IS real and usable (`mounted → bool` on Ref, analogous to BuildContext.mounted), shipped in 3.0.0 stable. Guarding post-await state writes with it is valid advice — it just is not enabled by, nor evidence for, the reverted lifecycle change.
3. The SpeechService recommendation (disposable service in a plain `Provider` with `ref.onDispose(() => service.dispose())`, injected via ProviderScope override) remains a SOUND pattern and is safe to adopt — Notifiers are still disposed on provider disposal (autoDispose, family eviction, scope teardown), so cleanup discipline still matters. But it is sound on ordinary lifecycle grounds, NOT because a breaking change forces it, and no primary source (whats_new or the 3.0 migration guide) mandates it. Treat it as a reasonable team convention, not a documented requirement. Adopting it for the stated reason means reasoning from a false model of Notifier lifecycle.

Confidence should be downgraded from "high" to "refuted on the load-bearing claim; Ref.mounted portion confirmed."

RECOMMENDATIONS:
  - [must] Set `retry: (retryCount, error) => null` on the root ProviderScope, and write a test asserting a throwing provider surfaces AsyncError rather than looping. — Riverpod 3 retries by default with 200ms→6.4s backoff. This app has no network; a throwing provider is a corrupt DB or a missing file — a real bug that must be loud. With no telemetry, a bug hidden behind a permanent spinner is a bug the developer will never learn about. Bonus: retry backoff makes pumpAndSettle() time out in widget tests.
  - [must] Read MediaQuery accessibility flags (textScalerOf, boldTextOf, accessibleNavigationOf, disableAnimationsOf) directly in widget build() methods. Never put them in a provider, and never pass BuildContext to one. — MediaQuery is already an InheritedWidget with correct-by-construction invalidation. Wrapping it in a provider trades a compiler-guaranteed rebuild for a manual sync and a first-frame staleness bug — in the one area (TextScaler at 200%) where being wrong is total failure. Amend RESEARCH.md line 361: this is not a valid justification for Riverpod.
  - [must] Never construct SpeechService, timers, or stream subscriptions inside a Notifier. Put them in a plain `Provider` with `ref.onDispose`, and inject via ProviderScope override at the root. — Riverpod 3 recreates Notifier instances on every provider rebuild (changelog 3.0.0-dev.12). Resources held as Notifier fields leak on each rebuild. A leaked flutter_tts engine is not a memory curiosity — it is a plausible route to a wedged TTS engine and no speech.
  - [must] Use `ProviderContainer.test(overrides: [...])` in unit tests. Do not write a createContainer helper and do not call addTearDown(container.dispose). — ProviderContainer.test self-disposes; the docs say so explicitly. The createContainer + addTearDown pattern is in nearly every Riverpod testing article from 2022-2024 and is now obsolete ceremony. Getting this right at project start avoids propagating a stale idiom through the whole test suite — which, with no telemetry, is the entire safety net.
  - [must] Do not import `package:flutter_riverpod/legacy.dart`. If a tutorial's code needs it, the tutorial is pre-3.0 — port it to Notifier/AsyncNotifier instead. — StateProvider/StateNotifierProvider/ChangeNotifierProvider still compile from legacy.dart, which makes the wrong fix (add an import) look like the right one. Treat the missing import as the API telling you the code is three years old.
  - [should] Skip riverpod_generator and @riverpod. Write the ~6 providers by hand. Add riverpod_lint anyway. — Official docs don't recommend codegen by default. Drift already runs build_runner so the cost argument is weak — but for 6 providers the payoff is near zero, and .g.dart noise works against the open-source-and-abandon exit plan (constraint #5). riverpod_lint still earns its keep: missing_provider_scope, avoid_ref_inside_state_dispose, avoid_public_notifier_properties and async_value_nullable_pattern all work without codegen. Accept one discipline cost: you must remember `isAutoDispose:` explicitly, since manual providers default it to false while codegen defaults it to true.
  - [must] Do not put safety-critical reactions (voice vanished, TTS engine died) in `ref.listen` on a screen-scoped provider. Check at the speak() call site inside SpeechService. — Riverpod 3 pauses providers whose only listeners are invisible widgets. When 'show text' fullscreen covers the grid, a grid-scoped ref.listen stops firing — the user returns and taps a tile into silence. Constraint #4 says silence must be impossible; the only place that can guarantee it is the code path that actually speaks.
  - [should] Expose drift via `StreamProvider` wrapping `.watch()`, with `isAutoDispose: false` for the grid. Do not combine get() and watch(). — Drift streams always emit a current snapshot on subscribe, so watch() alone is sufficient. The grid IS the app — it is never not needed, and tearing it down to rebuild it on every navigation is pointless churn on the one screen that must never be slow (zero-animation/latency rule). Use isAutoDispose: true only for edit-mode-scoped queries.
  - [should] Use no provider families and no provider scoping. Key tile lookups by (row, col) from the already-loaded slot list. — A fixed 3x4 grid is 12 known positions. Families buy per-argument caching that a 12-element list does not need, and they drag in the overrideWith→overrideWith2 deprecation and the scoped_providers_should_specify_dependencies lint (generator-only, so unenforced here). Riverpod's real cost is not adoption, it's this stack. Staying flat is what makes the earlier 'don't spend a day on this' true.
  - [must] Unwrap `ProviderException` before writing to the on-device exportable crash log. — Riverpod 3 rethrows provider failures wrapped in ProviderException. An unwrapped log records the wrapper, not the cause. Since this log is the ONLY channel through which a field failure can ever reach the developer (constraint #1), it recording 'ProviderException' for every entry would be a total loss of the one diagnostic that exists.
  - [avoid] Never capture a ref.watch value in build() and use it inside an onPressed closure. Pass (row, col) into the callback and resolve the vocalization at tap time. — The captured value can be stale on rapid re-taps, causing the previous tile's vocalization to be spoken — the wrong sentence, out loud, to a stranger, on behalf of someone who cannot correct it verbally. The schema already makes the fix free: position is the primary key and can never go stale.
  - [should] Treat any Riverpod source without a visible 2026-era date as wrong until verified against riverpod.dev/docs/concepts2/* and the pub.dev changelog. — Riverpod 3.0 (2025-09-10) was a redesign. Code With Andrea's 'Riverpod 2.0: The Ultimate Guide' and 'Unit Test AsyncNotifier with Riverpod 2.0' are still top search results and still teach createContainer/addTearDown, .autoDispose modifiers, and FamilyNotifier. The docs themselves moved from /docs/concepts/ to /docs/concepts2/ — a stale URL is a reliable staleness signal.

---

### DIMENSION: dart3-idioms
SUMMARY: As of 2026-07-15 the current stable is Dart 3.12 (shipped with Flutter 3.44 at I/O 2026). Macros were cancelled in January 2025 — do not architect around them; augmentations are the replacement direction, and codegen still means build_runner. Two of Dart 3's headline features are genuinely load-bearing for this app and the rest are showing off: sealed classes + exhaustive switch (which is the mechanism that makes silent speech failure a COMPILE ERROR rather than a field bug), and records (for ephemeral multi-returns like grid coordinates). Skip extension types, skip primary constructors (VERIFIED: experimental behind --enable-experiment=primary-constructors in 3.12, NOT shipped — several blog posts claim otherwise and are wrong), and skip freezed — drift already generates data classes with == and copyWith, so freezed on this schema is a build_runner tax for redundant output. On error handling: Flutter's official architecture guide does publish a concrete sealed Result class, and it is the right shape for the drift repository. But for speak() it is the WRONG shape, because its error arm is typed Exception — untyped, non-exhaustive, and unable to carry the fallback payload. The correct model for this app is a domain-specific sealed SpeakOutcome whose failure variants carry the text that must be shown on screen when audio does not happen. For global capture, wire FlutterError.onError + PlatformDispatcher.instance.onError to an on-device log and do NOT use runZonedGuarded — Flutter's own breaking-change doc says the fix for the zone-mismatch warning is to remove zones from the application.

FINDINGS:
  - (high, LOAD-BEARING) Dart macros were cancelled in January 2025 and will never ship; augmentations are the replacement direction.
    The Dart team dropped macros after ~2 years and ~1,400 upvotes on the tracking issue. Stated cause: macros had to re-execute during incremental compilation to detect semantic changes, which degraded hot reload past acceptable latency. The replacement is `augmentations` (splitting a class body across files with the `augment` keyword), which improves the ergonomics of generated code but does NOT remove build_runner. Consequence for this project: any plan premised on 'macros will kill build_runner soon' is dead. Codegen choices (drift, freezed) must be evaluated on their 2026 cost, not on a future that was cancelled.
    sources: https://dart.dev/resources/language/evolution | https://shorebird.dev/blog/dart-macros | https://www.verygood.ventures/blog/the-hard-thing-about-hard-things-macros-in-dart
  - (high, LOAD-BEARING) Primary constructors are EXPERIMENTAL in Dart 3.12, not stable — multiple blog posts claiming Dart 3.12 'adds primary constructors' are misleading.
    VERIFIED against dart.dev: the 3.12 announcement describes primary constructors as an experimental preview gated behind the `primary-constructors` flag (`dart run --enable-experiment=primary-constructors`). dart.dev/resources/language/evolution does NOT list primary constructors as introduced in any version through 3.12; it lists only *private named parameters* for 3.12. Several I/O 2026 recap posts (ecorpit, Medium recaps) flatly state 3.12 'adds primary constructors' — treat as wrong. Do not use in this project: experiments can change shape or be withdrawn, and a stranger picking up an abandoned repo should not need an experiment flag to build it.
    sources: https://dart.dev/blog/announcing-dart-3-12 | https://dart.dev/resources/language/evolution | https://dart.dev/language/primary-constructors
  - (high) Feature-to-version map through 2026: Dart 3.0 = patterns/records/class modifiers/switch expressions/if-case; 3.3 = extension types; 3.8 = null-aware elements; 3.10 = dot shorthands; 3.11 = no new language features; 3.12 (May 18 2026, current stable, ships with Flutter 3.44) = private named parameters + experimental primary constructors.
    Sourced from dart.dev/resources/language/evolution. Practical picks for this app: dot shorthands (3.10) are free readability on enum-typed params (`OutputMode.speaker` -> `.speaker`) and are safe since the floor is already 3.12. Null-aware elements (3.8) let you drop `if (x != null)` inside collection literals — marginal here. Extension types (3.3) are a static-only zero-cost wrapper; the representation type is never a subtype of the extension type, and the underlying object is always reachable at runtime, so it is an *unsafe* abstraction. For typed IDs over drift's `int` it would add ceremony at every drift boundary for no safety this 12-tile app needs. Skip.
    sources: https://dart.dev/resources/language/evolution | https://blog.dart.dev/announcing-dart-3-10-ea8b952b6088 | https://dart.dev/language/extension-types
  - (high, LOAD-BEARING) Flutter's official architecture guide does publish a concrete sealed Result class — but its error arm is typed `Exception` and its variants are named `Ok`/`Error`, which shadows `dart:core.Error`.
    The guide's Result (from the Compass App sample) is: `sealed class Result<T>` with `const factory Result.ok(T value) = Ok._;` and `const factory Result.error(Exception error) = Error._;`, plus `final class Ok<T> extends Result<T>` and `final class Error<T> extends Result<T>`. Two real defects for this project. (1) Naming: the `Error` variant shadows `dart:core.Error` in any file that imports it — and Effective Dart's rule 'DON'T explicitly catch Error or types that implement it' becomes hard to reason about when `Error` means two things. There is an open flutter/website issue (#11606) requesting improvements to this doc. Use `Ok`/`Err` or `Success`/`Failure`. (2) Typing: `Exception` as the error arm gives you zero exhaustiveness — `case Err(:final e)` tells you nothing about WHICH failure, so the compiler cannot force you to handle a new failure mode. That is precisely the guarantee this app needs.
    sources: https://docs.flutter.dev/app-architecture/design-patterns/result | https://github.com/flutter/website/issues/11606
  - (high, LOAD-BEARING) For speak(), a sealed domain outcome beats both throwing and a generic Result<T> — because the failure variants must CARRY the fallback payload, and because exhaustiveness is what makes silence impossible.
    Three properties decide this. (a) speak() failure is EXPECTED, not a bug: a voice can be uninstalled between app launches, an Android voice can be network_required with no network, setVoice can return 0. Effective Dart: throw Error only for programmatic errors/bugs — so these are not Errors. (b) Nothing forces a caller to catch: 'in Dart, methods that throw exceptions don't need to declare them, and calling methods aren't required to catch them' — an uncaught speak() throw in an async tile handler goes to PlatformDispatcher.onError and the user sees NOTHING. That is the exact catastrophic bug class. (c) The failure needs a payload: the fallback is 'show the text full-screen', so the failure value must carry the text. A sealed SpeakFailure with `final String spokenText` makes the fallback a total function of the outcome. Combined with an exhaustive switch and NO `default:`/`case _:`, adding a new failure mode becomes a compile error at every call site.
    sources: https://docs.flutter.dev/app-architecture/design-patterns/result | https://dart.dev/effective-dart/usage | https://codewithandrea.com/articles/flutter-exception-handling-try-catch-result-type/
  - (high, LOAD-BEARING) Do NOT use runZonedGuarded in Flutter 3.10+. Use FlutterError.onError + PlatformDispatcher.instance.onError only. Sources conflict on this; the official Flutter doc is decisive.
    ADVERSARIAL CHECK — sources disagree. Sentry's docs and several 2026 'complete guide' posts say 'use all three handlers, you need all three to catch 100% of production errors.' Against that: (1) docs.flutter.dev/testing/errors — the official error-handling page — shows ONLY FlutterError.onError + PlatformDispatcher.instance.onError and does not mention runZonedGuarded at all. (2) docs.flutter.dev/release/breaking-changes/zone-errors states Flutter 3.10+ detects zone mismatch and warns, and that 'the best way to silence this message is to remove use of Zones from within the application.' (3) The dart:async runZonedGuarded API doc carries no Flutter recommendation either way. The 'use all three' advice is crash-SDK advice — Sentry needs a zone because it wraps init. This app has no SDK, so the zone buys nothing and costs a documented footgun: WidgetsFlutterBinding.ensureInitialized() outside the zone triggers the mismatch, and zone-specific config then applies inconsistently. Verdict: two handlers, no zone.
    sources: https://docs.flutter.dev/testing/errors | https://docs.flutter.dev/release/breaking-changes/zone-errors | https://api.flutter.dev/flutter/dart-async/runZonedGuarded.html | https://docs.sentry.io/platforms/flutter/usage/
  - (medium, LOAD-BEARING) PlatformDispatcher.instance.onError's bool return means 'handled, suppress default reporting' — it does not keep the app alive, and returning true unconditionally will hide errors from you in debug.
    The handler signature is `bool Function(Object error, StackTrace stack)`. Returning true marks the error handled so it is not forwarded to the default handler (which prints to console). Uncaught async errors do not terminate a Flutter app regardless. So the return value is purely a reporting decision: in this app, return `true` in release (log silently to disk, keep the crisis UI up) and `false` in debug so the console still shows it. `return kReleaseMode;` is the whole rule. Corollary that matters more: the log writer itself must never throw, or an error inside the error handler recurses.
    sources: https://docs.flutter.dev/testing/errors
  - (high, LOAD-BEARING) freezed is NOT worth it for this app in 2026. Current version 3.2.5 (published ~Feb 2026); it is alive and maintained, but redundant here because drift already generates == and copyWith.
    VERIFIED on pub.dev: freezed 3.2.5, published ~5 months before 2026-07-15. Freezed 3.0 (Feb 2025, shipped alongside the macros cancellation) added 'mixed mode': plain classes with normal constructors and final fields, no mandatory `_User` private subclass, no mandatory factory. It is healthy. But: this app's persisted types (boards/buttons/grid_slots/images/sounds/settings) are drift row classes, and drift's generator ALREADY emits value-equality, hashCode, toString, and copyWith for them. Putting freezed on top means a second build_runner generator producing overlapping output. The remaining hand-written types are a handful of sealed outcome/state classes — sealed hierarchies with 1-3 final fields, where `@immutable` + `const` constructor + final fields is ~4 lines and needs no equality at all (they are switched on, not compared). Cost avoided: build_runner in the loop, .freezed.dart churn in diffs, and one more thing a stranger must install to build an abandoned repo.
    sources: https://pub.dev/packages/freezed | https://alperenderici.medium.com/dart-macros-discontinued-freezed-3-0-released-why-it-happened-whats-new-and-alternatives-385fc0c571a4
  - (high) equatable is also unnecessary: for the few hand-written value types, use records for ephemeral tuples and manual == with Object.hash for the rare case that needs it.
    Decision rule for this codebase: (1) persisted type -> drift's generated class, already has ==/copyWith, write nothing; (2) ephemeral multi-return -> a record, e.g. `(int row, int col)` for a grid slot coordinate — records have structural equality and hashCode for free, no package, no codegen; (3) sealed state/outcome variant -> plain `final class` with const ctor and final fields, no == needed because you switch on the type, not compare instances; (4) something that must live in a Set/Map key and isn't (1)-(3) -> manual `==` + `Object.hash(...)`, which is ~5 lines. equatable adds a dependency and a runtime props list to replace 5 lines in case (4) only. Skip. Caveat on records: don't let them cross layer boundaries as domain types — no name, no doc comment, no methods, and a positional shape that silently changes meaning if reordered.
    sources: https://www.freecodecamp.org/news/how-to-handle-errors-the-right-way-in-flutter-a-practical-guide-to-sealed-classes-records-and-result-types/ | https://dart.dev/resources/language/evolution
  - (high, LOAD-BEARING) assert is debug-only and stripped in release — so it must never guard the speech path, but it is the right tool for grid-slot invariants.
    Dart asserts are compiled out in release builds (they run only in debug/JIT). Placement rule for this app: assert for invariants that a BUG would violate and that tests exercise in debug — e.g. `assert(row >= 0 && row < kRows)`, `assert(col >= 0 && col < kCols)` in a GridSlot constructor, `assert(vocalization.trim().isNotEmpty)`. NEVER assert for anything the ENVIRONMENT can violate at runtime: voice availability, setVoice's return code, engine liveness, file existence for image paths. Those are real runtime conditions on a user's device in release mode, where the assert does not exist. An `assert(setVoiceResult == 1)` would be the perfect silent-failure bug: green in every test, absent in the field. This maps exactly onto Effective Dart's Error-vs-Exception split — assert covers the same ground as Error (bugs), sealed failures cover Exception ground (environment).
    sources: https://dart.dev/effective-dart/usage | https://dart.dev/language/error-handling
  - (high) The Effective Dart rules this codebase will actually violate are the catch rules — and the crash logger needs a deliberate, commented exemption from one of them.
    Quoted rules that bite here: 'AVOID catches without on clauses' — a bare catch swallows everything thrown in the block. 'DON'T discard errors from catches without on clauses: if you really do feel you need to catch everything... do something with what you catch. Log it, display it to the user or rethrow it, but do not silently discard it.' 'DO throw objects that implement Error only for programmatic errors' — an Error means there is a bug in your code. 'DON'T explicitly catch Error or types that implement it' — catching Error masks bugs. 'DO use rethrow to rethrow a caught exception' — rethrow preserves the original stack trace; `throw e` resets it to the current line. The one place this app must violate the discard rule is inside CrashLog.record's own catch: an error handler that throws recurses. That single `catch (_) { }` needs a comment explaining why, or a future reader (or a lint sweep) will 'fix' it into a recursive crash. Also common and cheap to lint: prefer_final_fields/prefer_const_constructors (matters here — zero animation + const widgets = deterministic rebuilds), lowercase_with_underscores filenames, and doc comments that start with a single-sentence summary.
    sources: https://dart.dev/effective-dart/usage | https://dart.dev/effective-dart/documentation | https://dart.dev/effective-dart/style

CODE EXAMPLES:
  --- SpeechService: sealed outcome where failure carries the fallback payload ---
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
  --- The implementation: every platform return code checked, no assert on the wire ---
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
  --- The call site: exhaustive switch with no default arm ---
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
  --- main(): two handlers, no zone, bindings in the same function body ---
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
  --- CrashLog: synchronous, self-truncating, and structurally unable to throw ---
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
  --- Immutability without freezed: records for coordinates, asserts for invariants, drift for the rest ---
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
  --- Result for the drift repository — renamed variants to avoid shadowing dart:core.Error ---
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

FACT-CHECK:
    - [CONFIRMED] Primary constructors are EXPERIMENTAL in Dart 3.12, not stable — multiple blog posts claiming Dart 3.12 'adds primary constructors' are misleading.
    - [CONFIRMED] Flutter's official architecture guide does publish a concrete sealed Result class — but its error arm is typed `Exception` and its variants are named `Ok`/`Error`, which shadows `dart:core.Error`.
    - [CONFIRMED] Do NOT use runZonedGuarded in Flutter 3.10+. Use FlutterError.onError + PlatformDispatcher.instance.onError only. Sources conflict on this; the official Flutter doc is decisive.
    - [CONFIRMED] freezed is NOT worth it for this app in 2026. Current version 3.2.5 (published ~Feb 2026); it is alive and maintained, but redundant here because drift already generates == and copyWith.
    - [PARTIALLY_TRUE] "Dart macros were cancelled in January 2025 and will never ship; augmentations are the replacement direction."
      CORRECTION: The claim is directionally right but wrong in four specifics. Corrections: (1) The ~1,400 upvotes belong to dart-lang/language#314 "Add data classes," NOT the macros tracking issue (which is #1482). #314 is a data-classes request; the official post cites it as the most-requested issue and the reason for pivoting toward bespoke data features. Do not cite it as demand for macros. (2) The stated cause is not "macros had to re-execute during incremental compilation to detect semantic changes." The official reason is (a) primarily non-convergence — "each time we solved a major technical hurdle, new ones popped up" — and (b) that the implementation "regresses both editing (e.g., static analysis and code completion) and incremental compilation (the first step of a hot reload)" because compile-time semantic introspection carried large compile-time costs. The analyzer/code-completion regression is co-equal with hot reload and must not be dropped; the re-execution mechanism is unsourced. (3) "Will never ship" overstates it — the post says stopping work, not converging "anytime soon," while remaining interested in metaprogramming long-term; #4271 "static enough metaprogramming" is an active successor. Say "cancelled/indefinitely shelved," not "never." (4) Drop dart.dev/resources/language/evolution as a citation — it does not mention macros or augmentations at all. The Shorebird and VGV posts support the cancellation but support NEITHER the upvote figure NOR the augmentations claim; only the official Dart post supports augmentations. Cite https://dart.dev/blog/an-update-on-dart-macros-data-serialization (dart.dev/language/macros now 301-redirects there). ADD: as of Dart 3.12 (2026-05-18, latest stable), augmentations has still not shipped — absent from both dart.dev/changelog and the language evolution page ~18 months after the announcement — and #4256 (closed/Done) scoped the feature down to only what code generators need. This strengthens rather than weakens the project conclusion: build_runner is not going anywhere, and drift/freezed should be evaluated on 2026 cost.
    - [PARTIALLY_TRUE] "For speak(), a sealed domain outcome beats both throwing and a generic Result<T> — because the failure variants must CARRY the fallback payload, and because exhaustiveness is what makes silence impossible."
      CORRECTION: The design conclusion survives, but three specifics must be fixed before it can carry a project decision.

1. Fix the mechanism. For the three failures the claim names, flutter_tts does NOT throw — it returns a status code through `Future<dynamic>`. `setVoice` answers `result.success(0)` on "Voice name not found" (FlutterTtsPlugin.kt:514-526); `speak` likewise resolves 0/1. Re-argue the case as "an untyped status code that is trivially ignored" rather than "an uncaught throw reaching PlatformDispatcher.onError." This makes the argument STRONGER — an ignored `0` produces no stderr line, no onError callback, no trace whatsoever — but the claim as written attacks a failure mode this library doesn't produce.

2. Drop "exhaustiveness makes silence impossible." Exhaustiveness forces a branch, not an action, and does not force the caller to switch at all — `await speak(text);` discarding the outcome compiles clean. The correct claim: exhaustiveness makes FORGETTING A VARIANT a compile error; it does nothing about ignoring the value. To close that second hole you need `@useResult` (package:meta) on speak(), which yields the `unused_result` analyzer WARNING — not a compile error. Enforce it with `unused_result` promoted to error in analysis_options.yaml if the decision depends on it. State the guarantee as "compile-error on new variants + analyzer-error on discarded outcomes," not "silence impossible."

3. Downgrade confidence on the headline and re-cite. The comparative "beats a generic Result<T>" is unsourced; docs.flutter.dev recommends the generic Result<T>, and codewithandrea explicitly hedges toward try/catch for small-to-medium apps. Present the payload-carrying sealed outcome as a defensible team design judgment extending the Flutter Result pattern — not as documented guidance. Sources 1 and 2 support premises (a) and (c); source 3 supports nothing in the claim and should be removed or cited as a counterweight.

One point in the claim's favor, against the consensus: "compile error at every call site" is CORRECT. Widespread secondary sources say non-exhaustive switch statements are mere warnings; the analyzer's messages.yaml marks both nonExhaustiveSwitchStatement and nonExhaustiveSwitchExpression as `type: compileTimeError`. Do not let a reviewer talk you out of this one.
    - [PARTIALLY_TRUE] "PlatformDispatcher.instance.onError's bool return means 'handled, suppress default reporting' — it does not keep the app alive, and returning true unconditionally will hide errors from you in debug."
      CORRECTION: Keep the semantics, drop the universal, and fix the rule.

CORRECT: bool return = "I handled this; skip the embedder's fallback reporting." Returning true unconditionally does suppress the default console print for uncaught async errors in debug.

WRONG: "Uncaught async errors do not terminate a Flutter app regardless" / "purely a reporting decision." api.flutter.dev explicitly says "The VM or the process may exit or become unresponsive after calling this callback," and routes the false path through the embedder-configured Settings::unhandled_exception_callback. It is embedder-dependent, not guaranteed. Stock mobile runners usually survive; the doc does not promise it.

WRONG: `return kReleaseMode;` is not "the whole rule," and docs.flutter.dev/testing/errors does not say it — that page returns `true` unconditionally and never explains the bool at all.

RECOMMENDED RULE for a crisis-UI app — invert it. Return `true` always, and print yourself in debug:

  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      _logToDisk(error, stack);           // must not throw
      if (kDebugMode) {
        debugPrint('$error\n$stack');     // your visibility, not the embedder's
      }
    } catch (_) {
      // swallow: never let the handler throw
    }
    return true;                          // never hand control to the embedder fallback
  };

This gets you the debug console output the researcher wanted WITHOUT ever taking the `false` branch that the doc warns may exit or hang the process. `return kReleaseMode` buys debug visibility at the cost of the one behavior this app cannot tolerate — and it buys it unnecessarily, since debugPrint gives the same visibility for free.

CITATION FIX: cite api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html for the semantics. docs.flutter.dev/testing/errors does not support the claim and should not be cited for it.

SCOPE FIX: this covers uncaught root-isolate async errors only. Pair with FlutterError.onError for widget-tree errors, and note that child isolates must forward their own errors to the root isolate — onError will not see them.

RECOMMENDATIONS:
  - [must] Model speak() as `Future<SpeakOutcome>` where SpeakOutcome is a sealed hierarchy, and make every failure variant carry the text that must be shown on screen. Never let speak() throw for expected failures. — The failure IS the feature: the whole point is that when audio doesn't happen, the text appears. A throw can be forgotten by the caller (Dart requires no declaration and no catch), and an exception can't ergonomically carry the fallback payload. A sealed return makes the fallback a total function of the outcome.
  - [must] Never write `default:` or `case _:` in a switch over a sealed type. Turn on the analyzer and let non-exhaustive switches be compile errors. — Exhaustiveness is the entire mechanism that converts 'a new failure mode was added and nobody handled it' from a field bug (that you will NEVER learn about — no telemetry) into a build break. A default arm silently disables the one safety net you have.
  - [must] Wire FlutterError.onError and PlatformDispatcher.instance.onError to the on-device log inside main(), and call WidgetsFlutterBinding.ensureInitialized() in that same function body. Do not use runZonedGuarded. — docs.flutter.dev/testing/errors shows exactly these two handlers and never mentions zones; the zone-errors breaking-change doc says the fix for zone mismatch is to remove zones from the app. The 'use all three' advice circulating in 2026 is crash-SDK advice — Sentry needs a zone to wrap its init. You have no SDK, so the zone is pure footgun.
  - [must] Make CrashLog.record() synchronous, self-truncating, and incapable of throwing — with a comment on its bare catch explaining that an error handler that throws recurses. — It is the only record that a crash ever happened. If it throws inside FlutterError.onError you get infinite recursion; if it's async you can lose the write on a hard kill. The comment matters because the bare catch violates Effective Dart's 'DON'T discard errors' and a future maintainer will otherwise 'fix' it.
  - [must] Check every flutter_tts return code against `!= 1` and return a typed failure. Never `assert` a platform return value. — setVoice returns 0 with only a Log.d on failure. An assert is stripped in release, so `assert(result == 1)` is green in every test and absent on the user's device — the exact silent-failure bug this app cannot afford.
  - [should] Use Flutter's official Result<T> shape for the drift repository, but rename the variants to Ok/Err and do not reuse it for speak(). — The guide's `Error` variant shadows dart:core.Error, which is genuinely confusing next to the 'DON'T catch Error' rule (flutter/website#11606 is open on this doc). Repository errors are unexpected and generically handled, so a generic Exception arm is fine there. Speech failures are expected, individually actionable, and carry payload — different problem, different type.
  - [avoid] Do not add freezed, equatable, fpdart, dartz, result_dart, or oxidized. Hand-roll the sealed types. — drift already generates ==/hashCode/copyWith for every persisted type, so freezed is redundant codegen on the same classes. The hand-written types are sealed variants with 1-3 final fields that are switched on, not compared. A stranger inheriting an abandoned repo should be able to `flutter run` without learning a functional-programming dependency's combinator vocabulary.
  - [avoid] Do not use primary constructors, and do not enable any Dart experiment flag. — VERIFIED: experimental behind --enable-experiment=primary-constructors in 3.12 despite blog posts saying otherwise. An abandoned repo that needs an experiment flag to build is an abandoned repo that stops building when the experiment changes shape.
  - [avoid] Do not use extension types for IDs, and do not architect anything around macros. — Extension types are an explicitly unsafe abstraction (representation type is never a subtype; the underlying object is always reachable), and they'd add friction at every drift boundary for safety a 12-tile app doesn't need. Macros were cancelled in Jan 2025 — build_runner is not going away, so choose codegen on its 2026 cost.
  - [should] Use records only for ephemeral multi-returns inside a layer — `(int row, int col)` for slot coordinates — never as a domain type that crosses a layer boundary. — Records give free structural equality with no package and no codegen, which is exactly right for a coordinate pair. But they have no name, no doc comment, and a positional shape that silently changes meaning if reordered — a bad fate for anything a stranger has to read at a layer boundary.
  - [must] Reserve `assert` for invariants a bug would violate (grid bounds, non-empty vocalization) and never for conditions the device can violate (voice present, file exists, engine alive). — Asserts are debug-only. This maps cleanly onto Effective Dart's Error-vs-Exception split: assert covers Error ground (bugs in your code), sealed failures cover Exception ground (the environment). Getting this backwards produces bugs that are invisible in exactly the build your users run.
  - [should] Use `rethrow`, never `throw e`, when re-raising inside a catch; and put an `on` clause on every catch except the crash logger's. — rethrow preserves the original stack trace; throw resets it to the rethrow line. With no crash reporting, the stack trace in your on-device log is the entire forensic record — corrupting it costs you the only debugging artifact you'll ever receive from a user.

---

### DIMENSION: testing-strategy
SUMMARY: The classic test pyramid is an economic argument: higher-fidelity tests cost more to run, so you buy fewer. That economics does not hold in Flutter. Flutter's own tradeoff table rates unit tests "Low" confidence and widget tests "Higher" — while rating BOTH "Quick" to execute. The speed cliff in Flutter sits between widget and integration, not between unit and widget, so the pyramid's justification collapses in its upper-middle. The widget test is genuinely the sweet spot, and Flutter's docs pointedly say "many unit and widget tests" without ranking them. The 70/20/10 ratios in circulation are Mike Cohn folklore reprinted by content farms, not Flutter guidance. For THIS app the question is nearly moot: 12 tiles and a text field contain almost no pure logic, so the testable surface is (a) four genuinely dangerous logic files — migrations, voice_filter, grid_slots, settings — and (b) UI. Test shape follows code shape, not a diagram. The no-telemetry constraint is the crux, and the key insight is that telemetry and tests cover different things: tests cover risks you thought of, telemetry covers the ones you didn't. Deleting telemetry deletes your unknown-unknowns channel, and you cannot refill it with more tests of the same kind. Only two things substitute: test techniques that generate cases you didn't author (seeded random loops — not glados, which is 2 years stale), and a-priori enumeration of the hostile-environment matrix that telemetry would otherwise have discovered for you. It does NOT argue for more integration tests: those run on your one emulator and sample nothing about field device diversity. It argues for making failures visible in-app (since you can't observe them remotely) and then testing that visibility — plus treating the crash log as the most safety-critical feature after speech itself.

FINDINGS:
  - (high, LOAD-BEARING) Flutter's own docs rate unit tests LOW confidence and widget tests HIGHER, while rating both 'Quick' — which invalidates the pyramid's core economic argument in Flutter
    The exact tradeoff table at docs.flutter.dev/testing/overview: Confidence — Unit: Low, Widget: Higher, Integration: Highest. Execution speed — Unit: Quick, Widget: Quick, Integration: Slow. Maintenance cost — Low/Higher/Highest. The pyramid exists because fidelity normally trades against speed; here widget tests buy strictly more confidence at the same speed class. The only real cost cliff is integration. Flutter's guidance sentence is 'a well-tested app has many unit and widget tests, tracked by code coverage, plus enough integration tests to cover all the important use cases' — it deliberately does not rank unit above widget.
    sources: https://docs.flutter.dev/testing/overview
  - (high, LOAD-BEARING) The widely-cited 70/20/10 (or 60/25/10/5) Flutter test ratios are folklore with no authoritative source
    Searches surface these numbers only in SEO content-marketing blogs (testsigma, tftus, getautonoma, Medium reposts), each asserting slightly different splits (70/20/10 vs 60/25/10/5) with no citation. None engage with the fact that Flutter widget tests cost roughly the same as unit tests. Flutter's own docs, Very Good Ventures, and the flutter/flutter repo publish no such ratio. Treat any specific percentage split as unsourced.
    sources: https://docs.flutter.dev/testing/overview | https://testsigma.com/blog/flutter-testing/
  - (high, LOAD-BEARING) With zero animation, pumpAndSettle should be BANNED as a wait — and repurposed as an ASSERTION that the zero-animation rule holds
    pumpAndSettle repeatedly pumps until no frames are scheduled, with a 10-minute default timeout; its entire purpose is waiting out animations. Flutter's own API docs say 'it is better practice to figure out exactly why each frame is needed, and then pump exactly as many frames as necessary.' It times out on infinite animations/repeating timers, and flutter/flutter#84966 documents that its stack traces are truncated on timeout — making failures hard to diagnose. In an app with zero animation, every state change settles in ONE frame, so `await tester.pump()` is always sufficient and pumpAndSettle can only add flake. The inversion: after pump(), `tester.binding.hasScheduledFrame` should be false. If it's true, an animation was accidentally introduced. Note Material's InkWell/ripple animates by default — this test would catch a stray InkWell (fix: splashFactory: NoSplash.splashFactory).
    sources: https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html | https://github.com/flutter/flutter/issues/84966 | https://dcm.dev/blog/2025/07/30/navigating-hard-parts-testing-flutter-developers/
  - (high) mocktail is the clear 2026 default: v1.0.5, published ~3 months ago, 2.77M weekly downloads, verified publisher felangel.dev, no build_runner
    mocktail 1.0.5, MIT, deps only on collection/matcher/test_api, 1.2k likes, 160 pub points, Dart 3 compatible. Mockito still works but requires @GenerateMocks annotations plus a build_runner codegen step, which adds a generated .mocks.dart file per test — extra build latency and more generated files polluting coverage. For a solo dev on a 2-week MVP, the build_runner tax is real and buys nothing.
    sources: https://pub.dev/packages/mocktail | https://github.com/felangel/mocktail
  - (high, LOAD-BEARING) For SpeechService, a hand-written FAKE beats a mock — and the decisive reason is that mocks silently absorb interface changes via noSuchMethod, which is the exact failure mode this project cannot tolerate
    A mocktail mock is `class MockSpeechService extends Mock implements SpeechService`. Because Mock implements noSuchMethod, adding a 4th method to SpeechService does NOT break the mock at compile time — the mock silently returns null/throws at runtime, and any un-stubbed call is absorbed. A fake (`class FakeSpeechService implements SpeechService`) fails to COMPILE when the interface grows. In a project whose stated worst bug class is silent failure, adopting a test double whose defining feature is silently absorbing calls is philosophically backwards. Second reason: the risk here isn't 'was speak() called' but 'what happens when the voice vanished / setVoice returned 0 / engine is absent' — those are STATE, and a fake models state naturally where a mock needs whenever+side-effect gymnastics. Third: for the open-source exit plan, the fake IS the executable documentation of the SpeechService contract. Use mocktail only for genuine interaction questions (e.g. does tapping tile B call stop() before speak()) — and even there a fake that records calls (i.e. a spy) is sufficient.
    sources: https://pub.dev/packages/mocktail | https://martinfowler.com/articles/mocksArentStubs.html | https://pro.codewithandrea.com/flutter-foundations/06-testing-part1/12-testing-dependencies-mocktail-package
  - (high, LOAD-BEARING) Correct test-double taxonomy (Meszaros/Fowler) — this project needs FAKES and SPIES, and essentially zero true mocks
    Dummy: passed to satisfy a signature, never used. Stub: returns canned answers, makes no assertions. Spy: a stub that records calls for the test to assert on afterwards. Mock: pre-programmed with expectations that verify themselves and fail the test. Fake: a real working implementation with a shortcut unsuitable for production (in-memory DB). Mapping: FakeSpeechService = fake (+ spy, once it records `spoken`). drift's NativeDatabase.memory() = arguably not even a fake — it is real sqlite3 with in-memory storage, i.e. the real dependency. The DB should NEVER be mocked: 100% of the DB risk lives in SQL/schema/migrations, and a mocked DB tests literally none of it.
    sources: https://martinfowler.com/articles/mocksArentStubs.html | https://drift.simonbinder.eu/testing/
  - (high, LOAD-BEARING) VGV's actual argument for 100% coverage is a TEAM-COORDINATION argument, not a correctness argument — and it therefore does not transfer to a solo dev
    From the primary source (verygood.ventures/blog/road-to-100-test-coverage): VGV concede up front that '100% test coverage doesn't mean 0% bugs.' Their load-bearing reasoning is that any threshold below 100% forces you to DECIDE what to exclude (models? UI? third-party?), and those decisions are subjective and hard to defend. 100% is defensible precisely because it requires no negotiation. That is a mechanism for removing arguments in code review across a consultancy of many engineers on client codebases. A solo dev has no code review and no negotiation, so the benefit VGV is buying does not exist, while the cost (testing trivial code to hit a number, in a 2-week budget) is fully retained. VGV also explicitly permit exceptions for generated code: 'most of them are related to auto generated code... since there is no added value.' Notably their own counter-example — a button test that achieves coverage without verifying the bloc event fired — is an argument that coverage measures the wrong thing.
    sources: https://verygood.ventures/blog/road-to-100-test-coverage/ | https://verygood.ventures/blog/very-good-coverage/
  - (medium, LOAD-BEARING) `flutter test --coverage` omits files that no test imports, silently INFLATING the coverage percentage — the opposite of the safe failure direction
    Tracked as flutter/flutter#27997 ('Flutter test coverage will not report untested files') and related #40948 ('Include untested files in test coverage'). A file with zero tests contributes zero lines to the denominator rather than counting as 0% covered. A codebase with one well-tested file and twenty untested ones can report ~100%. Fixes: (a) `dlcov --include-untested-files=true`, or (b) generate a test/coverage_helper_test.dart that imports every lib/ file. This matters here because a coverage number that lies UPWARD is worse than no number at all in a project with no other safety net.
    sources: https://github.com/flutter/flutter/issues/27997 | https://github.com/flutter/flutter/issues/40948 | https://pub.dev/documentation/dlcov/latest/
  - (high, LOAD-BEARING) drift's generated migration verifier checks schema SHAPE only — it will happily pass a migration that produced the correct schema and destroyed all user data
    `dart run drift_dev schema dump` exports per-version schemas; `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/` generates the verifier. `verifier.migrateAndValidate(db, targetVersion)` works by extracting CREATE statements from sqlite_schema and semantically comparing them to a reference built by Migrator.createAll(). That is a shape comparison — it does not look at rows. To test DATA survival you must pass `--data-classes --companions` to the generate command, then use `verifier.schemaAt(version)` to get a connection, insert rows using the versioned data classes (imported aliased, e.g. `import 'generated_migrations/schema_v1.dart' as v1;`), migrate, and assert the rows survived. Given that a botched migration here is the loss of someone's voice, the shape-only test is the one that gives false confidence.
    sources: https://drift.simonbinder.eu/migrations/tests/ | https://drift.simonbinder.eu/migrations/step_by_step/
  - (high, LOAD-BEARING) Testing only adjacent migration steps (1→2, 2→3) misses the most common real-world path: the user who skipped an update and goes 1→3
    drift's SchemaVerifier lets you startAt(any version) and migrateAndValidate to any target, so N→M for all M>N is cheap to enumerate with a nested loop. Users who install, ignore updates for six months, then update, execute exactly the untested paths. With no telemetry you will never learn this happened — the user just opens the app to an empty board and uninstalls. This is a for-loop over versions, roughly 10 lines, and it is the highest-value test in the codebase.
    sources: https://drift.simonbinder.eu/migrations/tests/
  - (high, LOAD-BEARING) A pre-migration file backup is a cheaper and STRONGER safety net for user data than any quantity of migration tests — and the two are complements, not substitutes
    Copy the .sqlite file to board_backup_v{oldVersion}.sqlite immediately before onUpgrade runs; keep the last 2; expose 'Restore previous board' in settings. ~15 lines. Migration tests protect against bugs you enumerated; the backup protects against the migration bug you did not enumerate — which, with no telemetry, is the entire category you cannot see. This is the single highest safety-per-line item in the project and it is not a test at all. The tests then cover the backup/restore path itself.
    sources: https://drift.simonbinder.eu/migrations/
  - (high, LOAD-BEARING) THE KEY ANSWER: tests and telemetry cover disjoint risk sets — tests cover risks you thought of, telemetry covers the ones you didn't. You cannot refill a deleted discovery channel with more tests of the same kind.
    This is the central reasoning error to avoid. The instinct 'no crash reporting, so write more tests' is half-right: more tests of things you already thought of adds nothing to the unknown-unknowns channel that Crashlytics provided. Only two things genuinely substitute. (1) Techniques that AUTHOR test cases you didn't write — seeded random/property loops over the edit-mode op space and the DB round-trip. (2) A-PRIORI enumeration of the environment matrix that telemetry would otherwise have discovered empirically: in a normal app you learn from Crashlytics that 4% of users have no TTS engine; here you must enumerate it up front. The correct reframe: normally you test the happy path and let telemetry find the environment; with no telemetry, THE ENVIRONMENT IS THE TEST SUITE.
    sources: https://docs.flutter.dev/testing/overview | https://verygood.ventures/blog/guide-to-flutter-testing/
  - (high, LOAD-BEARING) No-telemetry does NOT argue for more integration tests — that instinct is mostly wrong, and acting on it would waste a large fraction of a 2-week budget
    Integration tests run on YOUR emulator or YOUR one physical device: a single configuration. The unknown-unknown that telemetry surfaced was DEVICE AND ENVIRONMENT DIVERSITY, and one emulator samples none of it. Integration tests are also the slowest and most maintenance-heavy row of Flutter's own tradeoff table. They earn their place here for exactly one reason — they are the ONLY level that exercises the real flutter_tts plugin against a real Android TTS engine and real sqlite, i.e. the native boundary that widget tests stub out entirely. That justifies about 2-3 integration tests (tile→real audible speech; DB survives a real app restart), not a suite. The real substitutes for telemetry are: environment-matrix unit tests, a tested crash log with user-initiated export, LOUD in-app failures, and a small physical device matrix checked manually before release — the last being a process answer, not a test answer.
    sources: https://docs.flutter.dev/testing/overview | https://docs.flutter.dev/testing/integration-tests
  - (high, LOAD-BEARING) The crash log is the ONLY field-failure channel, which makes it the most safety-critical feature after speech itself — and it must be tested harder than the tiles
    Concretely test: FlutterError.onError AND PlatformDispatcher.instance.onError are BOTH routed (they catch different things — the latter catches async errors that escape the framework); runZonedGuarded wraps runApp; the log is FLUSHED not buffered (a crash-on-startup must still leave a readable log — an unflushed buffer loses exactly the crash you most need); the log is BOUNDED (ring buffer / size cap, or it grows forever on a device with no telemetry to notice); the export path works even when the app cannot fully start; and critically a RECURSION GUARD — an exception thrown inside the crash logger must not re-enter the logger. Nobody tests their crash logger. Here it is the last line of sight into the field.
    sources: https://docs.flutter.dev/testing/errors | https://api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html
  - (high, LOAD-BEARING) The concrete environment matrix that becomes worth testing here but normally isn't — each entry is a cheap unit test with a fake, and each WILL happen to someone you never hear from
    TTS: no engine installed; engine installed with zero voices; voice list contains ONLY network_required voices (offline promise + network voice = silence); setVoice returns 0 (flutter_tts logs Log.d and returns 0 on failure — the documented silent-failure vector); the stored voice id was uninstalled since last launch (Android GCs TTS voices — this is HIGHLY likely in the field and is the single most probable silent-failure cause); engine returns success but emits no audio; audio focus denied (call in progress); silent switch on with a misconfigured .ambient session; Bluetooth device yanked mid-utterance. Storage: DB file corrupt; DB read-only; disk full during image write; image path exists in DB but the file was deleted by Android's media cleaner (this happens routinely). Each is a state a fake can enter trivially; none require a device.
    sources: https://pub.dev/packages/flutter_tts | https://developer.android.com/reference/android/speech/tts/TextToSpeech
  - (high, LOAD-BEARING) With no remote observability, failures must be made VISIBLE in-app — and the testable invariant is 'never silent': every failure mode yields audible speech OR a visible error, never neither
    This converts constraint 4 (silent failure is the worst bug class) from a principle into a single parameterized widget test that loops over an enum of every SpeechFailure mode and asserts, for each, that tapping a tile produces either recorded speech on the fake or a findable on-screen error. It is one test that structurally cannot be satisfied by a code path that fails silently, and adding a new failure mode to the enum forces the UI to handle it. This is the highest-value single test in the app.
    sources: https://docs.flutter.dev/testing/overview
  - (high, LOAD-BEARING) glados is effectively unmaintained — last published ~2 years ago (v1.1.7) — so do NOT take a property-testing dependency; hand-roll a seeded random loop instead
    glados 1.1.7, last publish ~2 years ago, 50 likes, 27.4k downloads. flutter_glados is a third-party fork last touched June 2025. For a project whose exit plan is 'a stranger picks this up', adding a stale dependency is a liability. A 20-line seeded loop in plain package:test gives you the 80% that matters — generate random op sequences, assert the invariant after each, print the seed on failure so the case is reproducible. What you lose is automatic shrinking; at this scale, printing the seed plus the op list is an adequate substitute, since the op list IS the minimal repro you need to read.
    sources: https://pub.dev/packages/glados | https://github.com/MarcelGarus/glados | https://pub.dev/packages/flutter_glados
  - (medium, LOAD-BEARING) TDD-by-SEMANTICS-FINDER resolves the TDD-in-Flutter-UI problem AND mechanically enforces the accessibility constraint — the best available move for this project
    Honest baseline: TDD is good for pure logic (voice_filter, migrations, grid invariant — knowable APIs, fast tests) and bad for widget layout, because widget tests written against the tree (find.byType, find.byKey) couple to a structure you discover by looking at the screen, so TDD means writing the tree twice and churning tests on every layout iteration. The escape: find.bySemanticsLabel('Overwhelmed') is STABLE across layout refactors — it names behavior, not structure. So you CAN write it first. The convergence: a tile with no semantics label cannot be found, so the test fails, so an unlabeled tile is a BUILD FAILURE rather than a code-review comment. That is exactly constraint 3's demand that a11y be enforced by tests rather than discipline. Corollary rule: ban find.byType/find.byKey for tiles.
    sources: https://api.flutter.dev/flutter/flutter_test/CommonFinders/bySemanticsLabel.html | https://docs.flutter.dev/ui/accessibility/accessibility-testing
  - (high, LOAD-BEARING) Flutter ships four built-in accessibility guideline matchers that turn a11y into a pass/fail assertion — near-zero cost, directly serving 'accessibility is correctness'
    From docs.flutter.dev/ui/accessibility/accessibility-testing: androidTapTargetGuideline (min 48x48), iOSTapTargetGuideline (min 44x44), labeledTapTargetGuideline (tappable nodes must have labels), textContrastGuideline (WCAG; 3:1 for large text 18pt+). Usage requires tester.ensureSemantics() first, `await expectLater(tester, meetsGuideline(...))`, then handle.dispose() (a leaked SemanticsHandle is itself a flake source). labeledTapTargetGuideline is the one that mechanically forbids an unlabeled tile. Caveat: textContrastGuideline is known to produce false positives over images/gradients — this app's flat, animation-free tiles are close to its ideal case.
    sources: https://docs.flutter.dev/ui/accessibility/accessibility-testing | https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html | https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/accessibility.dart
  - (medium, LOAD-BEARING) TextScaler at 200%+ is better tested by asserting no RenderFlex overflow than by a golden — cheaper, more precise, and it fails for the right reason
    Overflow throws a FlutterError in debug builds, so pumping the grid wrapped in MediaQuery with TextScaler.linear(2.0)/(3.0) and asserting `tester.takeException()` is null catches clamping/overflow directly, with a readable failure. A golden at 3.0 catches the same bug but fails as an opaque pixel diff. Use goldens as a supplement for the fixed 3x4 grid only, not as the primary text-scale test.
    sources: https://api.flutter.dev/flutter/widgets/MediaQueryData/textScaler.html | https://api.flutter.dev/flutter/flutter_test/WidgetTester/takeException.html
  - (high) Golden tests are unusually well-suited to THIS app (zero animation, fixed grid, deterministic UI removes their main flake source) but must run in Ahem-font CI mode
    Goldens' standard objection is churn from animation and layout flux — a design rule here has eliminated it. The remaining flake source is font rasterization differing across macOS/Linux/Windows. Betterment's alchemist solves this by generating two sets: platform goldens (human-readable, for local dev) and CI goldens rendered in the Ahem font (square glyphs, platform-agnostic, constant across OS). Alternative without a dependency: matchesGoldenFile pinned to a single CI platform. Proportionate scope for a 2-week MVP: goldens for the 3x4 grid at textScale 1.0/2.0/3.0 and nothing else — they are the only cheap assertion that the grid DID NOT REFLOW.
    sources: https://github.com/Betterment/alchemist | https://verygood.ventures/blog/alchemist-golden-tests-tutorial/ | https://leancode.co/glossary/golden-tests-in-flutter
  - (high, LOAD-BEARING) The Android Quick Settings TileService is a structural test HOLE — by design it runs with NO Flutter engine, so no Flutter test of any level can reach it
    The architecture decision (Kotlin TileService speaks natively from SharedPreferences with no Flutter engine on that path) is correct for latency in a crisis, but it puts that code permanently outside flutter_test, widget tests, AND integration_test. This is the app's crisis path and it has zero Flutter-side coverage — a fact worth stating plainly rather than papering over. Mitigation: one JVM/Robolectric unit test on the Kotlin side for the SharedPreferences read + parse (the part most likely to break when the Dart side changes a key or format), plus a Dart contract test asserting the Dart writer emits exactly the keys/format the Kotlin reader expects. The two sides share a format with no compiler enforcing it — that seam is where it will silently break.
    sources: https://developer.android.com/reference/android/service/quicksettings/TileService | https://docs.flutter.dev/testing/integration-tests
  - (high) Platform channel test APIs moved to TestDefaultBinaryMessenger — the old MethodChannel.setMockMethodCallHandler is gone, and un-torn-down handlers leak across tests
    Current API: TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler), or tester.binding.defaultBinaryMessenger where a WidgetTester exists. Documented as a breaking change at docs.flutter.dev/release/breaking-changes/mock-platform-channels. Must be nulled in tearDown or it leaks into subsequent tests — a classic order-dependent flake. Relevant here only if you test flutter_tts directly; the SpeechService abstraction means you mostly shouldn't (test YOUR wrapper with a fake, not the plugin).
    sources: https://docs.flutter.dev/release/breaking-changes/mock-platform-channels | https://api.flutter.dev/flutter/flutter_test/TestDefaultBinaryMessenger/setMockMethodCallHandler.html
  - (high, LOAD-BEARING) Flutter's flakiness sources are enumerable and nearly all are avoidable by construction in this app
    Ranked: (1) pumpAndSettle over infinite animation/repeating timer — eliminated by the zero-animation rule + a ban; (2) real Timer/Future.delayed — use pump(duration) or FakeAsync; (3) DateTime.now() — inject a clock (crash log timestamps!); (4) unseeded Random — seed it and print the seed; (5) golden font/platform rasterization diffs — Ahem/CI mode; (6) state leaking between tests: drift singletons, SharedPreferences, undisposed ProviderContainer, un-nulled channel handlers, undisposed SemanticsHandle — use addTearDown (co-located with setup, harder to forget than tearDown); (7) order-dependent tests sharing a container; (8) unawaited futures. Note that a solo dev with no CI matrix will experience flake as 'the suite failed once, I re-ran it, it passed, I stopped trusting the suite' — and a distrusted suite in a no-telemetry project is a total loss of the safety net. Flake is not an annoyance here; it is an existential threat to the only thing standing between users and silence.
    sources: https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html | https://dcm.dev/blog/2025/07/30/navigating-hard-parts-testing-flutter-developers/ | https://api.flutter.dev/flutter/flutter_test/WidgetTester/runAsync.html
  - (high) Generated files pollute coverage and must be stripped — for drift specifically the pattern is *.drift.dart as well as *.g.dart
    lcov -r coverage/lcov.info 'lib/**/*.g.dart' 'lib/**/*.drift.dart' 'lib/**/*.freezed.dart' -o coverage/lcov.info. Alternatives: dlcov (--exclude-suffix='.g.dart', and --include-untested-files=true which also fixes the inflation bug) or pcov (pcov.yml exclusion list). VGV's very_good_coverage GitHub Action supports an exclude list and a min_coverage threshold. Note this project won't use freezed necessarily, but drift emits .drift.dart (modern) or .g.dart (legacy part-file style) depending on config — check which your setup emits before writing the pattern.
    sources: https://verygood.ventures/blog/very-good-coverage/ | https://pub.dev/documentation/dlcov/latest/ | https://github.com/rrousselGit/freezed/issues/442
  - (medium, LOAD-BEARING) This app has almost no unit-testable surface, so the pyramid inverts here mechanically rather than as a matter of taste
    Inventory: the pure-logic files are voice_filter, the grid_slots repository invariant, settings serialization, and migrations — four files. Everything else is UI or a thin wrapper over a plugin. Riverpod is explicitly acknowledged as not load-bearing, so testing providers tests the framework. The conclusion is not 'prefer widget tests philosophically' but 'there is nearly nothing else to unit test.' Test shape should follow code shape. Proportionate target: ~120-180 tests total — roughly 40 migration/DB, 30 speech + voice_filter + failure matrix, 50 widget, 10 a11y/textScale, 3 integration, 2-3 goldens — running in under 30 seconds, which is the number that actually determines whether a solo dev keeps running them.
    sources: https://docs.flutter.dev/testing/overview

CODE EXAMPLES:
  --- The single highest-value test: silence is impossible ---
```dart
// test/features/speak/silence_is_impossible_test.dart
void main() {
  for (final failure in SpeechFailure.values) {
    testWidgets('tile tap under $failure: speech OR visible error, never neither',
        (tester) async {
      final speech = FakeSpeechService()..failWith = failure;
      await tester.pumpApp(speech: speech);

      await tester.tap(find.bySemanticsLabel('Overwhelmed'));
      await tester.pump(); // one frame. zero animation. never pumpAndSettle.

      final spoke = speech.spoken.isNotEmpty;
      final showedError = find.byKey(const Key('speech-error-banner')).evaluate().isNotEmpty;

      expect(spoke || showedError, isTrue,
          reason: 'SILENT FAILURE under $failure: user tapped a tile mid-shutdown '
                  'and got neither speech nor an on-screen explanation.');
    });
  }
}

enum SpeechFailure {
  none,
  noEngineInstalled,
  zeroVoices,
  onlyNetworkVoices,      // offline promise + network-required voice
  setVoiceReturnedZero,   // flutter_tts logs Log.d and returns 0
  storedVoiceUninstalled, // Android GC'd the voice since last launch
  reportedSuccessButSilent,
  audioFocusDenied,
}
```
  Parameterized over every failure mode. Cannot be satisfied by a silently-failing path. Adding a value to SpeechFailure forces the UI to handle it or this test goes red.
  --- Enforce the zero-animation rule mechanically ---
```dart
// test/design_rules/nothing_animates_test.dart
testWidgets('no widget schedules a second frame — zero-animation rule holds',
    (tester) async {
  await tester.pumpApp();

  for (final label in kSeedBoardLabels) {
    await tester.tap(find.bySemanticsLabel(label));
    await tester.pump(); // exactly one frame

    expect(tester.binding.hasScheduledFrame, isFalse,
        reason: 'Tapping "$label" scheduled another frame => something animates. '
                'Likely a Material InkWell ripple: set '
                'splashFactory: NoSplash.splashFactory.');
  }
});
```
  Turns pumpAndSettle's failure mode into an assertion. Catches a stray InkWell ripple, an implicit animation, or a repeating timer — each a latency regression AND a future flake source.
  --- FakeSpeechService — a fake, not a mock (and it doubles as a spy) ---
```dart
// test/fakes/fake_speech_service.dart
class FakeSpeechService implements SpeechService {
  SpeechFailure failWith = SpeechFailure.none;
  final List<String> spoken = [];   // recording => this is also a spy
  final List<String> calls = [];    // for barge-in ordering assertions

  @override
  Future<List<Voice>> voices() async => switch (failWith) {
        SpeechFailure.noEngineInstalled => throw const MissingTtsEngineException(),
        SpeechFailure.zeroVoices => const [],
        SpeechFailure.onlyNetworkVoices =>
          const [Voice(id: 'en-us-x-net', networkRequired: true)],
        _ => const [Voice(id: 'en-us-x-local', networkRequired: false)],
      };

  @override
  Future<void> speak(String text) async {
    calls.add('speak');
    switch (failWith) {
      case SpeechFailure.setVoiceReturnedZero:
      case SpeechFailure.storedVoiceUninstalled:
        throw const VoiceUnavailableException();
      case SpeechFailure.reportedSuccessButSilent:
        return; // returns success, records nothing — the nastiest real case
      default:
        spoken.add(text);
    }
  }

  @override
  Future<void> stop() async => calls.add('stop');
}

// Barge-in: tapping a second tile must interrupt the first.
testWidgets('second tap stops before speaking', (tester) async {
  final speech = FakeSpeechService();
  await tester.pumpApp(speech: speech);
  await tester.tap(find.bySemanticsLabel('Overwhelmed'));
  await tester.pump();
  await tester.tap(find.bySemanticsLabel('Yes'));
  await tester.pump();
  expect(speech.calls, ['speak', 'stop', 'speak']);
});
```
  `implements` means adding a method to SpeechService BREAKS THE BUILD. A mocktail mock would absorb it via noSuchMethod and fail silently at runtime — the exact bug class this project cannot tolerate.
  --- Migration test: data survival across EVERY path, not just adjacent steps ---
```dart
// test/db/migration_test.dart
import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;

void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // The user who skipped six months of updates goes 1 -> 3 directly.
  for (var from = 1; from < kLatestSchemaVersion; from++) {
    for (var to = from + 1; to <= kLatestSchemaVersion; to++) {
      test('migrate v$from -> v$to preserves schema AND user boards', () async {
        final conn = await verifier.schemaAt(from);

        // Seed data using the OLD versioned data classes.
        final old = v1.DatabaseAtV1(conn.executor);
        await old.into(old.buttons).insert(v1.ButtonsCompanion.insert(
              id: const Value(1),
              label: 'Overwhelmed',
              vocalization: "I need to leave, I'm not able to talk right now",
            ));
        await old.close();

        final db = AppDatabase(conn.executor);
        await verifier.migrateAndValidate(db, to); // shape only

        // The part that actually matters: is the user's voice still there?
        final buttons = await db.select(db.buttons).get();
        expect(buttons, hasLength(1));
        expect(buttons.single.label, 'Overwhelmed');
        expect(buttons.single.vocalization,
            "I need to leave, I'm not able to talk right now",
            reason: 'v$from->v$to produced a valid schema but LOST the '
                    'vocalization. This is the loss of someone\'s voice.');
        await db.close();
      });
    }
  }
}
```
  migrateAndValidate only compares CREATE statements — it is blind to rows. Requires: dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/generated_migrations/
  --- pumpApp helper + accessibility-as-correctness + TextScaler ---
```dart
// test/helpers/pump_app.dart
extension PumpApp on WidgetTester {
  Future<void> pumpApp({SpeechService? speech, double textScale = 1.0}) {
    return pumpWidget(ProviderScope(
      overrides: [speechServiceProvider.overrideValue(speech ?? FakeSpeechService())],
      child: MediaQuery(
        // Honor TextScaler. Never clamp. This is correctness, not polish.
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const AacApp(),
      ),
    ));
  }
}

// test/a11y/grid_a11y_test.dart
testWidgets('grid meets a11y guidelines', (tester) async {
  final handle = tester.ensureSemantics();
  await tester.pumpApp();

  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));

  handle.dispose(); // a leaked handle is itself a flake source
});

for (final scale in [1.0, 2.0, 3.0]) {
  testWidgets('3x4 grid does not overflow at ${scale}x text', (tester) async {
    await tester.pumpApp(textScale: scale);
    await tester.pump();
    // RenderFlex overflow throws in debug — readable failure naming the widget.
    expect(tester.takeException(), isNull);
  });
}
```
  Semantics finders are stable across layout refactors, so these CAN be written first (TDD). labeledTapTargetGuideline makes an unlabeled tile a build failure. Note textScaler is NOT clamped.
  --- Poor-man's property test — the substitute for the deleted telemetry channel ---
```dart
// test/db/grid_slots_invariant_test.dart
test('no sequence of edit ops ever reflows a tile', () async {
  for (var run = 0; run < 200; run++) {
    final seed = run;
    final rng = Random(seed);
    final ops = <String>[];
    final db = AppDatabase(NativeDatabase.memory());
    final repo = BoardRepository(db);

    try {
      final expected = <(int, int), int?>{};
      for (var i = 0; i < 30; i++) {
        final row = rng.nextInt(4), col = rng.nextInt(3);
        if (rng.nextBool()) {
          final buttonId = rng.nextInt(5) + 1;
          ops.add('place($row,$col,btn$buttonId)');
          await repo.placeButton(row: row, col: col, buttonId: buttonId);
          expected[(row, col)] = buttonId;
        } else {
          ops.add('clear($row,$col)');
          await repo.clearSlot(row: row, col: col);
          expected[(row, col)] = null;
        }

        // Invariant: position is the primary key. Nothing moves unless moved.
        final slots = await repo.slotsFor(boardId: 1);
        for (final entry in expected.entries) {
          expect(slots[entry.key], entry.value,
              reason: 'TILE REFLOWED at ${entry.key}. seed=$seed ops=$ops');
        }
        expect(slots.length, lessThanOrEqualTo(12), reason: 'seed=$seed ops=$ops');
      }
    } finally {
      await db.close();
    }
  }
});
```
  Do NOT add glados (v1.1.7, ~2 years stale). This authors cases you didn't think of, which is the actual thing Crashlytics used to provide. Print the seed so any failure is reproducible.
  --- Coverage: fix the inflation bug, strip generated files, no percentage gate ---
```bash
#!/usr/bin/env bash
set -euo pipefail

# --include-untested-files fixes the upward-lying denominator.
dart run dlcov --include-untested-files=true -- flutter test --coverage

# Strip generated files. drift emits .drift.dart (modern) or .g.dart (part-file).
lcov -r coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.drift.dart' \
  'lib/**/*.freezed.dart' \
  -o coverage/lcov.info

genhtml coverage/lcov.info -o coverage/html

# NO global percentage gate. Gate only the four files where a bug is unrecoverable.
# VGV's 100% rule buys a team-coordination benefit a solo dev cannot collect.
for f in \
  lib/db/migrations.dart \
  lib/speech/voice_filter.dart \
  lib/db/board_repository.dart \
  lib/diagnostics/crash_log.dart
do
  pct=$(lcov --list coverage/lcov.info | grep "$f" | awk '{print $2}' | tr -d '%')
  if (( $(echo "$pct < 100" | bc -l) )); then
    echo "DANGER FILE $f at ${pct}% — must be 100%."
    exit 1
  fi
done
```
  flutter test --coverage OMITS files no test imports (flutter#27997), so untested files leave the denominator and the number lies UPWARD. Check whether your drift setup emits .drift.dart or .g.dart.

FACT-CHECK:
    - [CONFIRMED] Correct test-double taxonomy (Meszaros/Fowler) — this project needs FAKES and SPIES, and essentially zero true mocks
    - [CONFIRMED] `flutter test --coverage` omits files that no test imports, silently INFLATING the coverage percentage — the opposite of the safe failure direction
    - [PARTIALLY_TRUE] "Flutter's own docs rate unit tests LOW confidence and widget tests HIGHER, while rating both 'Quick' — which invalidates the pyramid's core economic argument in Flutter"
      CORRECTION: The table values are exactly as claimed and current — build on them with confidence. Drop the inference. Correct statement: "Flutter's docs rate unit tests Low confidence and widget tests Higher while rating both Quick on execution speed, meaning widget tests do not cost extra RUNTIME for their added confidence. They do cost more on the other two axes: Maintenance cost rises Low→Higher and Dependencies rise Few→More at the unit→widget step. Flutter presents this table as the basis for its advice that a well-tested app has 'many unit and widget tests ... plus enough integration tests to cover all the important use cases' — it groups unit and widget as co-equal bulk rather than ranking unit above widget, but it does not claim widget tests are free relative to unit tests, and it never mentions the test pyramid at all."

For the project decision: the defensible finding is narrower but still useful — Flutter's docs give no runtime-speed reason to prefer unit over widget tests, and treat both as the bulk of a suite. That does NOT license "widget tests are strictly better than unit tests" or "the pyramid doesn't apply to Flutter." If the decision rests on the pyramid being invalidated by this table, the table does not support it. Cite the maintenance-cost and dependencies rows honestly. Also update the source path to sites/docs/src/content/testing/overview.md.
    - [PARTIALLY_TRUE] "The widely-cited 70/20/10 (or 60/25/10/5) Flutter test ratios are folklore with no authoritative source"
      CORRECTION: Do not say the ratios have "no authoritative source." Say instead: the 70/20/10 split originates in Google's Testing Grouplet small/medium/large test-SIZE heuristic (Mike Bland, 2011), whose author states the numbers "essentially were pulled out of a hat" — no empirical basis. It was defined over test size, not Flutter's unit/widget/integration taxonomy, and Google itself later moved to ~80/20 narrow/broad in Software Engineering at Google. Flutter docs, VGV, and flutter/flutter publish no ratio; VGV's actual published standard is 100% line coverage (very_good_coverage), which is a coverage threshold, not a test-type distribution. Also drop the assertion that "Flutter widget tests cost roughly the same as unit tests" — docs.flutter.dev/testing/overview's tradeoff table rates widget tests equal to unit tests on execution speed ("Quick"/"Quick") but explicitly HIGHER on maintenance cost and dependencies. Correct framing: widget tests are cheap to run but not cheap to maintain.
    - [PARTIALLY_TRUE] "With zero animation, pumpAndSettle should be BANNED as a wait — and repurposed as an ASSERTION that the zero-animation rule holds"
      CORRECTION: Keep the practice, fix the reasoning and the specifics. (a) Do not cite dcm.dev for a ban — it says the opposite ("perfect for waiting for finite animations or navigation transitions"). No cited source recommends banning; Flutter's doc says "better practice," so this is a defensible LOCAL team convention for a zero-animation app, not a documented Flutter recommendation. Presenting it as sourced consensus is the error. (b) Drop "pump() is always sufficient." pump() does not advance the fake clock; Timer/Future.delayed/debounce/Timer.periodic still need pump(duration) or fakeAsync. The rule should be "pump() for state changes, pump(duration) for time-based async" — zero animation eliminates animation waits, not asynchrony waits. (c) Downgrade the assertion's claimed power: `expect(tester.binding.hasScheduledFrame, isFalse)` is a valid spot check (it is provably the exact exit condition of pumpAndSettle's own loop) but it is NOT proof the zero-animation rule holds — it misses Timer-driven repaints, at-rest implicit animations, and untapped InkWells. It catches a stray InkWell only if the test taps it. (d) Fix the InkWell remedy: splashFactory: NoSplash.splashFactory disables ONLY the splash. InkResponse.updateHighlight() independently creates an InkHighlight with a 200ms pressed fade (50ms hover/focus per getFadeDurationForType). To actually reach zero animation you must also neutralize the highlight — e.g. overlayColor/highlightColor: Colors.transparent (or WidgetStateProperty.all(Colors.transparent)) — or avoid InkWell entirely and use GestureDetector.
    - [PARTIALLY_TRUE] "For SpeechService, a hand-written FAKE beats a mock — and the decisive reason is that mocks silently absorb interface changes via noSuchMethod, which is the exact failure mode this project cannot tolerate"
      CORRECTION: Keep the decision, replace the reasoning and the citations.

The right justification for a hand-written fake is architectural, and Flutter's own guidance states it directly. docs.flutter.dev/app-architecture/case-study/testing demonstrates exactly this pattern with a bare-implements fake:

  class FakeBookingRepository implements BookingRepository {
    List<Booking> bookings = List.empty(growable: true);
    @override
    Future<Result<void>> createBooking(Booking booking) async { ... }
  }

and reserves package:mocktail for external dependencies (e.g. routers) outside the core layers. That is the same fake-for-owned-services / mock-for-external split the claim advocates, from a primary source that actually says it — cite this instead of Fowler.

Specific corrections:
- DROP the Fowler citation for this argument. His article predates Dart, never mentions noSuchMethod, and his stated objection to mocks is implementation coupling ("Mockist tests are thus more coupled to the implementation of a method"), not silent absorption. If you cite him, cite him for the classicist state-verification preference — which supports reason two, not reason one.
- DROP or flag the Code with Andrea citation: paywalled, unverifiable, and a single course lesson cannot establish community consensus.
- CORRECT the mechanism claim: mocktail does not silently absorb an un-stubbed new method returning Future<void>/Future<bool>/List<Voice>. It throws a TypeError ("type 'Null' is not a subtype of type 'Future<void>'"). Silent absorption applies only to sync void methods. Reason one is therefore weak on the merits, not decisive.
- CORRECT the fake/mock framing: mocktail's Fake class uses noSuchMethod too and throws UnimplementedError on un-overridden members. The compile-time safety you want comes from `implements` without a noSuchMethod superclass — not from the word "fake."
- Demote confidence from HIGH to MEDIUM. The conclusion is right; the argument as written would not survive review.

Current-as-of-2026-07-15 package facts (these were correct in the claim): mocktail 1.0.5, publisher felangel.dev, active, not discontinued. For reference, mockito is 5.7.0, publisher dart.dev, also active — its repo now lives under github.com/dart-lang/build (the old dart-archive/mockito location is the stale one).
    - [PARTIALLY_TRUE] "VGV's actual argument for 100% coverage is a TEAM-COORDINATION argument, not a correctness argument — and it therefore does not transfer to a solo dev"
      CORRECTION: The quotes are real but the attribution of motive is invented. VGV's stated primary rationale is delivery confidence and safe future change ("Your final goal should be to increase confidence in any future code change to deliver fast and safely"), with the exclusion/subjectivity problem offered as a supporting reason, not the load-bearing one. The source contains no mention of code review, negotiation, team size, or multiple developers. Because VGV's actual argument is confidence-under-change, it does NOT self-evidently fail to transfer to a solo dev — a solo dev refactoring their own code is precisely the case VGV describe. The researcher's conclusion (100% is a poor use of a 2-week solo budget) may well be correct on cost-benefit grounds, but it must be argued on its own terms, not sourced to VGV. Accurate restatement: "VGV concede 100% coverage doesn't mean 0% bugs and justify the target primarily by confidence in future change, secondarily because any lower threshold forces subjective decisions about what to exclude. They permit exceptions for auto-generated code. VGV do not address solo development; the judgment that the target is not worth a solo dev's 2-week budget is my own inference, not theirs."

RECOMMENDATIONS:
  - [must] Make the widget test the DEFAULT test type; write unit tests only for the four files that contain real logic (migrations, voice_filter, grid_slots repo, settings). Do not target any published unit/widget ratio. — Flutter's own table rates widget tests higher-confidence than unit tests at the same speed class, so the pyramid's economic premise fails. And this app has ~4 files of pure logic — the shape follows the code, not a diagram. The 70/20/10 numbers are unsourced folklore.
  - [must] Ban pumpAndSettle in this codebase. Use `await tester.pump()`. Add a lint or a grep-based CI check that fails on the string 'pumpAndSettle'. — Zero animation means every state change settles in one frame, so pumpAndSettle can only add a 10-minute-timeout flake vector with truncated stack traces (flutter#84966). Its only purpose is waiting out animations you don't have.
  - [must] Write a 'nothing animates' test: pump the app, tap every tile, and assert tester.binding.hasScheduledFrame is false after a single pump(). — Converts the zero-animation design rule from discipline into a build failure. Catches a stray Material InkWell ripple, an implicit AnimatedContainer, or a repeating timer the moment it's introduced — each of which is both a latency regression for a distressed user and a future flake source.
  - [must] Use a hand-written FakeSpeechService implementing the interface, holding failure-mode state and recording spoken utterances. Reach for mocktail only for genuine call-ordering questions. — A mocktail mock's noSuchMethod silently absorbs interface additions and un-stubbed calls; a fake fails to compile. Adopting a double whose defining feature is silent absorption is backwards in a project whose worst bug class is silent failure. The fake also models voice-vanished state naturally and documents the contract for whoever inherits the repo.
  - [must] Never mock the database. Test drift against NativeDatabase.memory() (real sqlite3). — All the DB risk is in SQL, schema, and migrations. A mocked DB exercises none of it and produces green tests that prove nothing about the one asset that is irreplaceable.
  - [must] Add `--data-classes --companions` to drift schema generation and assert DATA survives every migration, not just that the schema shape matches. — migrateAndValidate compares CREATE statements from sqlite_schema — it is blind to rows. A migration that produces a perfect schema and drops every board passes it. Schema-shape-only testing here gives precisely false confidence about the one thing that must not break.
  - [must] Test every migration path N→M for all M>N with a nested loop, not just adjacent steps. — The user who ignores updates for six months and then upgrades executes 1→3 directly — the untested path. With no telemetry, that user's boards vanish and you never find out; they just uninstall.
  - [must] Back up the .sqlite file before onUpgrade runs, keep the last two, and expose 'Restore previous board' in settings. Test the backup/restore path. — ~15 lines that protect against the migration bug you did NOT enumerate — which with no telemetry is the whole invisible category. Higher safety-per-line than any migration test. Complements the tests rather than replacing them.
  - [must] Write one parameterized 'silence is impossible' widget test that loops over an enum of every SpeechFailure mode and asserts each yields audible speech OR a visible on-screen error — never neither. — The single highest-value test in the app. Structurally cannot be satisfied by a silently-failing code path, and adding a new failure mode to the enum forces the UI to handle it. This is constraint 4 turned into a compiler-adjacent mechanism.
  - [must] Enumerate and unit-test the hostile-environment matrix a priori: no TTS engine; zero voices; only network_required voices; setVoice returns 0; stored voice id uninstalled since last launch; engine reports success but emits nothing; audio focus denied; image file deleted by the OS media cleaner; DB corrupt/read-only; disk full. — This is the direct answer to the no-telemetry problem. Normally Crashlytics discovers these empirically; here you must enumerate them up front because you will never learn. With no telemetry, the environment IS the test suite. 'Stored voice was GC'd by Android' is the most likely real-world silent failure and costs one test.
  - [must] Treat the crash log as the most safety-critical feature after speech. Test: both FlutterError.onError and PlatformDispatcher.instance.onError route to it; runZonedGuarded wraps runApp; writes are flushed not buffered; the log is size-bounded; export works when the app can't fully start; and a recursion guard prevents an error inside the logger from re-entering it. — It is the only remaining line of sight into the field, which makes it load-bearing infrastructure rather than a nice-to-have. An unflushed buffer loses exactly the startup crash you most need; an unbounded log grows forever with no telemetry to notice.
  - [must] Find tiles with find.bySemanticsLabel, never find.byType or find.byKey. Enforce with a CI grep over widget tests. — Two wins at once: semantics finders are stable across layout refactors (so you can genuinely TDD them, unlike tree-coupled finders), and an unlabeled tile becomes a build failure rather than a review comment — mechanically enforcing constraint 3.
  - [must] Add meetsGuideline assertions (androidTapTargetGuideline, iOSTapTargetGuideline, labeledTapTargetGuideline, textContrastGuideline) to the main grid test, and always dispose the SemanticsHandle. — Four lines that turn accessibility into pass/fail. labeledTapTargetGuideline forbids an unlabeled tile outright. A leaked SemanticsHandle is itself a flake source.
  - [must] Test TextScaler at 1.0/2.0/3.0 by asserting tester.takeException() is null (no RenderFlex overflow), rather than relying on a golden. — Overflow throws in debug, so this fails with a readable error naming the widget; a golden fails as an opaque pixel diff. Directly enforces 'honor TextScaler at 200%+, never clamp'.
  - [must] Do NOT set a coverage percentage gate. Require 100% on the four danger files only (migrations, voice_filter, grid_slots repo, crash log) and read coverage elsewhere as a report. — VGV's own stated justification for 100% is that it removes subjective exclusion ARGUMENTS across a team — a benefit a solo dev cannot collect, while retaining the full cost against a 2-week budget. A gate a solo dev sets gets bypassed or gamed; a targeted danger list does not.
  - [should] If you report coverage at all, fix the inflation bug first (dlcov --include-untested-files=true, or a generated coverage_helper_test.dart) and strip lib/**/*.g.dart and lib/**/*.drift.dart. — flutter test --coverage omits files no test imports, so untested files leave the denominator entirely and the number lies UPWARD. A coverage number that overstates safety is worse than none in a project with no other net.
  - [should] Substitute for the lost unknown-unknowns channel with a hand-rolled seeded random loop over edit-mode op sequences asserting the grid_slots invariant. Print the seed and op list on failure. Do NOT add glados. — This is the only technique that authors cases you didn't think of — the actual thing telemetry provided. glados is ~2 years stale (v1.1.7) and a stale dep is a liability for a repo whose exit plan is a stranger picking it up. 20 lines of package:test gets the 80%; you lose shrinking, but the printed op list is already the repro you'd read.
  - [should] Write a contract test asserting the Dart writer emits exactly the SharedPreferences keys and format the Kotlin TileService reader expects, plus one Kotlin JVM/Robolectric test for the read+parse. — The TileService is the crisis path and by design runs with no Flutter engine, so NO Flutter test can reach it. The Dart/Kotlin format seam has no compiler enforcing it and will silently break when a key is renamed — producing exactly the silent failure the architecture exists to prevent.
  - [should] Write exactly 2-3 integration tests: tile tap → real audible speech via the real engine; DB survives a real app restart; Quick Settings tile speaks. No more. — They earn their place ONLY as the sole exercise of the real plugin/native/sqlite boundary. They do not substitute for telemetry: they run on one emulator and sample nothing about field device diversity — the instinct 'no telemetry, so more integration tests' is mostly wrong and would eat the budget.
  - [should] Write one pumpApp helper in test/helpers/, mirror lib/ in test/, use addTearDown over tearDown, and stop there. One helpers file, not a test framework. — addTearDown is co-located with setup so it's harder to forget — the main defense against handler/container/SemanticsHandle leaks that cause order-dependent flake. Beyond one helper file, test infrastructure is team ceremony a solo dev doesn't need.
  - [should] TDD the four logic files. Do not TDD widget layout — write those tests immediately after, at the semantics level. — Honest answer: TDD works where the API is knowable in advance and tests are fast. Widget tests coupled to the tree mean writing the tree twice and churning the test on every layout iteration. The semantics-finder layer is the exception — it names behavior, so it can be written first.
  - [should] Limit goldens to the 3x4 grid at three text scales, rendered in Ahem/CI mode (alchemist) or pinned to one CI platform. — Zero animation removes goldens' usual flake source, and they're the only cheap assertion that the grid DID NOT REFLOW. But font rasterization still differs across OSes, and goldens beyond this scope are pure churn on a 2-week budget.
  - [should] Seed every Random, inject a Clock for crash-log timestamps, and never use real Timer/Future.delayed in tests — use pump(duration) or FakeAsync. — Flake is not an annoyance here. A solo dev who learns to re-run a red suite stops trusting it, and a distrusted suite in a no-telemetry project means nothing at all stands between users and silence.
  - [avoid] Do not test: drift's generated CRUD, Riverpod plumbing, flutter_tts itself, theme/settings UI beyond persist-and-reload, private methods, or 'show text' font rendering. — Each tests a third party or a triviality. Riverpod is explicitly acknowledged as not load-bearing, so testing providers tests the framework. Test YOUR voice_filter, not flutter_tts.
  - [avoid] Do not add Patrol, Appium, or any E2E layer. — No accounts, no network, one screen. E2E exists to cover cross-system flows this app does not have. It is the slowest, flakiest row of Flutter's own tradeoff table bought for zero coverage gain.
  - [avoid] Do not chase 100% coverage, and do not use mockito/build_runner for new test code. — 100% buys a team-coordination benefit that doesn't exist solo. mockito's codegen step adds build latency and generated files that pollute coverage; mocktail (v1.0.5, 2.77M weekly downloads, verified publisher) is the 2026 default and needs neither.

---

### DIMENSION: widget-golden-testing
SUMMARY: Two premises in the brief are inverted, and both matter. (1) RenderFlex overflow DOES fail a widget test by default — it is not merely logged. DebugOverflowIndicatorMixin._reportOverflow calls FlutterError.reportError; the test binding captures it into _pendingExceptionDetails and testWidgets rethrows at test end unless takeException() is called. The entire blog genre on this topic is about how to SUPPRESS overflow failures. So "assert nothing overflows" is free — you just must not silence it. (2) The real trap is the default test surface: 800x600 logical, wider than any phone. An overflow suite that never sets tester.view tests a screen no user owns and passes while the real 360pt phone is broken. Every text-scale test MUST pin a real device size. Corrections: golden_toolkit is confirmed DISCONTINUED on pub.dev (last publish ~3 years ago); alchemist is alive (0.14.0) but is published by Betterment, NOT Very Good Ventures as the brief states — and its CI goldens obscure text into colored boxes, destroying the exact signal this app needs. The default test font is FlutterTest, not Ahem (engine PR #40245) — fluttergoldens.com's docs are stale here. A MediaQuery placed ABOVE MaterialApp now works: useInheritedMediaQuery is gone and MaterialApp never inserts its own MediaQuery — the View does. Verdict: build a text-scale × device × theme overflow matrix (text-based, platform-independent, near-zero maintenance) and SKIP the golden regression suite for the MVP.

FINDINGS:
  - (high, LOAD-BEARING) A RenderFlex overflow FAILS a widget test by default; it does not merely log
    RenderFlex computes _overflow in performLayout (bool get _hasOverflow => _overflow > precisionErrorTolerance) but REPORTS during paint() via DebugOverflowIndicatorMixin.paintOverflowIndicator -> _reportOverflow -> FlutterError.reportError. TestWidgetsFlutterBinding overrides FlutterError.onError, stores FlutterErrorDetails in _pendingExceptionDetails, and rethrows at test completion unless takeException() clears it. Confirmed by reading debug_overflow_indicator.dart, flex.dart and flutter_test/binding.dart, and corroborated by the many blog posts teaching an 'ignoreOverflowErrors' helper (FlutterError.onError = ignoreOverflowErrors) to make tests pass despite overflow.
    sources: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart | https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/binding.dart | https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/flex.dart | https://dev.to/remejuan/widget-testing-dealing-with-renderflex-overflow-errors-hlg
  - (high, LOAD-BEARING) The default widget-test surface is 800x600 logical — bigger than any phone — so an unpinned overflow test is near-worthless
    flutter_test defaults to physicalSize 2400x1800 with devicePixelRatio 3.0 => 800x600 logical. A 3x4 grid at 800 logical width gives ~260pt-wide tiles; at a real 360pt phone the tiles are ~115pt. Text that fits at 200% scale in the default surface overflows on the real device. Every scale test must set tester.view.physicalSize/devicePixelRatio to a real profile (e.g. 320x568 as worst case, 412x915 Pixel).
    sources: https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html | https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding/setSurfaceSize.html
  - (high, LOAD-BEARING) Overflow is reported only ONCE per RenderObject, so looping text scales inside one testWidgets under-reports
    DebugOverflowIndicatorMixin guards with a _overflowReportNeeded flag: set false after the first report, reset only on reassemble(). If a test loops scales 1.0/2.0/3.0 against the same render tree and calls takeException() per iteration to collect failures, only the FIRST overflow reports — later scales silently 'pass'. Fix: generate one testWidgets per (device x scale x theme) so each gets a fresh render tree.
    sources: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart
  - (high, LOAD-BEARING) Overflow only reports if the widget actually PAINTS
    The report fires from paint(), not performLayout(). Anything Offstage, inside a lazy list beyond the viewport, or clipped away never reports. For this app's fixed, fully-painted 3x4 grid this is fine — but it means the 'show text' fullscreen mode and edit mode need their own pumped tests; they will not be covered by a board test.
    sources: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart
  - (high, LOAD-BEARING) golden_toolkit is DISCONTINUED; alchemist is maintained but is Betterment's, not Very Good Ventures'
    pub.dev shows golden_toolkit explicitly marked discontinued, v0.15.0, last published ~3 years ago, with no suggested replacement. alchemist: v0.14.0 published ~4 months ago, verified publisher betterment.dev, 160 pub points, 220 likes, ~305k weekly downloads. The brief's attribution of alchemist to Very Good Ventures is incorrect.
    sources: https://pub.dev/packages/golden_toolkit | https://pub.dev/packages/alchemist | https://github.com/Betterment/alchemist
  - (high, LOAD-BEARING) alchemist's CI goldens obscure text into colored boxes — which destroys the only signal this app would want from a golden
    alchemist splits Platform goldens (readable text, renderShadows: true, only stable on the machine that made them) from CI goldens (obscureText: true by default -> text replaced with opaque colored rectangles; renderShadows: false; forced Ahem). CI goldens are platform-stable precisely BECAUSE they throw away glyph rendering. For an app whose golden question is 'does the label still fit and read at 200% scale', a CI golden answers a question you did not ask.
    sources: https://github.com/Betterment/alchemist
  - (high) The default test font is FlutterTest, not Ahem — most golden docs (incl. fluttergoldens.com) are stale on this
    Engine PR #40245 ('Reland: Make FlutterTest the default test font') made FlutterTest the default when fontFamily is unspecified or unregistered. Ahem remains available if explicitly named. FlutterTest has 1024 units-per-em (a power of 2, less precision loss) and ascent/descent 0.75/0.25em vs Ahem's 0.8/0.2em. Visually both render box glyphs — so the 'goldens show boxes' symptom is unchanged, and loadAppFonts is still the fix, but the metrics differ, which matters if you ever compare against old goldens.
    sources: https://github.com/flutter/engine/pull/40245 | https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Flutter-Test-Fonts.md | https://fluttergoldens.com/flutters-implementation/load-fonts-and-icons/
  - (high, LOAD-BEARING) Font loading in goldens is NOT automatic in 2026; it still requires an explicit FontLoader call in flutter_test_config.dart
    You must call loadAppFonts() (parses FontManifest.json, registers each family via FontLoader) and separately loadMaterialIconsFont() (locates the MaterialIcons font in the Flutter cache) from a testExecutable in test/flutter_test_config.dart. Now that golden_toolkit is discontinued, the maintained sources of loadAppFonts are flutter_test_goldens and alchemist, or ~20 lines of your own FontLoader code.
    sources: https://fluttergoldens.com/flutters-implementation/load-fonts-and-icons/ | https://pub.dev/documentation/golden_toolkit/latest/golden_toolkit/loadAppFonts.html
  - (high, LOAD-BEARING) Flutter officially concedes goldens are platform-dependent once real fonts are loaded
    matchesGoldenFile docs: 'Custom fonts may render differently across different platforms, or between different versions of Flutter' and 'a golden file generated on Windows with fonts will likely differ from the one produced by another operating system.' There is no tolerance threshold in core matchesGoldenFile — comparison is exact by default; fuzzy matching requires a custom GoldenFileComparator (golden_screenshot ships one allowing ~0.1% pixel mismatch).
    sources: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html | https://pub.dev/packages/golden_screenshot
  - (medium) Impeller is NOT a factor for widget-test goldens
    flutter test runs the widget tree in the flutter_tester host shell using software/Skia rasterization, not the on-device Impeller backend. Impeller (default on iOS, rolling out on Android) affects the shipped app, never the `flutter test` golden. Corollary that cuts the other way: goldens therefore CANNOT catch an Impeller-specific rendering regression on device — a real coverage gap that no golden strategy closes.
    sources: https://github.com/flutter/flutter/issues/130633 | https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
  - (high, LOAD-BEARING) A MediaQuery placed ABOVE MaterialApp DOES take effect — the old 'you must use MaterialApp.builder' folk wisdom is obsolete
    useInheritedMediaQuery was deprecated after v3.7.0-29.0.pre and is now ignored: 'MaterialApp never introduces its own MediaQuery; the View widget takes care of that.' In a widget test, pumpWidget wraps the tree in View, which inserts MediaQuery.fromView; a MediaQuery you place below that and above MaterialApp is the nearest ancestor and wins. Separately, MediaQuery.fromView 'is constructed using the platform-specific data of the surrounding MediaQuery and the view-specific data of the provided view' — it composes with, not clobbers, an ancestor.
    sources: https://api.flutter.dev/flutter/material/MaterialApp/useInheritedMediaQuery.html | https://api.flutter.dev/flutter/widgets/MediaQuery/fromView.html | https://api.flutter.dev/flutter/widgets/MediaQuery-class.html
  - (high, LOAD-BEARING) tester.binding.window is deprecated; the replacements are tester.view and tester.platformDispatcher
    Deprecated after v3.9.0-0.1.pre in preparation for multi-window. physicalSizeTestValue -> tester.view.physicalSize; devicePixelRatioTestValue -> tester.view.devicePixelRatio; clearAllTestValues -> tester.platformDispatcher.clearAllTestValues() plus tester.view.reset(). Flutter PR #180840 explicitly cleaned up resetXyz() calls in favour of a single TestFlutterView.reset(), so prefer addTearDown(tester.view.reset) over resetPhysicalSize/resetDevicePixelRatio pairs.
    sources: https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html | https://github.com/flutter/flutter/pull/180840
  - (high, LOAD-BEARING) flutter_test ships four accessibility guideline matchers that directly encode this app's a11y-is-correctness rule
    androidTapTargetGuideline (48x48 min), iOSTapTargetGuideline (44x44 min), labeledTapTargetGuideline (tappable nodes must be labeled), textContrastGuideline (3:1 for >=18pt text, 4.5:1 otherwise). Usage requires tester.ensureSemantics() first, expectLater(tester, meetsGuideline(...)) (async — must be awaited), then handle.dispose(). This turns 'accessibility is correctness' from discipline into a failing test.
    sources: https://docs.flutter.dev/ui/accessibility/accessibility-testing | https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html | https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/accessibility.dart
  - (medium) textContrastGuideline is the weakest of the four matchers and should not be over-trusted
    It samples rendered pixels behind semantic text nodes. With the FlutterTest box-glyph font every 'character' is a solid filled box, so the sampled foreground coverage differs from real glyph antialiasing; it also produces unreliable results over images/gradients. Treat tap-target and labeled-tap-target as hard gates, and textContrast as an advisory check backed by a hand-computed contrast unit test on your 3 theme palettes.
    sources: https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/accessibility.dart | https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Flutter-Test-Fonts.md
  - (high, LOAD-BEARING) flutter test runs in a plain Dart VM — sqlite3_flutter_libs does NOTHING, so drift needs host sqlite3
    Per drift's maintainer: native plugins like sqlite3_flutter_libs only apply to real apps or integration_test with a driver, not `flutter test`. NativeDatabase.memory() resolves sqlite3 from the host: macOS has a system libsqlite3 (older version — a real dev/CI version-skew risk), Linux CI needs libsqlite3-dev (Ubuntu) installed before flutter test, else 'Failed to load dynamic library libsqlite3.so'. Directly relevant to the abandonment/open-source plan: a stranger cloning on Linux gets DB test failures unless you document this.
    sources: https://github.com/simolus3/drift/issues/2314 | https://github.com/simolus3/drift/issues/3702 | https://drift.simonbinder.eu/platforms/vm/
  - (high, LOAD-BEARING) Drift in a WIDGET test needs closeStreamsSynchronously: true or you get cross-test stream leakage
    Drift docs: 'By default, unsubscribing from a query stream created by drift will keep the stream open for one event loop iteration... To avoid issues with Drift in that setup, pass a DatabaseConnection with closeStreamsSynchronously: true to your database.' Widget tests use a FakeAsync-controlled clock, so that deferred event-loop iteration may never run — streams stay open, the test binding complains about pending timers or state leaks into the next test. This is the specific gotcha that makes naive real-drift widget tests flaky.
    sources: https://drift.simonbinder.eu/testing/
  - (high) Riverpod 3.x is stable and changed the test idioms
    flutter_riverpod 3.3.2 published ~35 days ago, ~2.45M downloads. Riverpod 3 adds ProviderContainer.test() (auto-disposes at test end; the docs say you can safely search-and-replace your createContainer helper with it), tester.container() to reach the container from a widget test, and NotifierProvider.overrideWithBuild to mock only Notifier.build rather than the whole notifier. Docs explicitly say: inside tests, never use ProviderContainer directly — use ProviderContainer.test.
    sources: https://pub.dev/packages/flutter_riverpod | https://riverpod.dev/docs/how_to/testing | https://riverpod.dev/docs/whats_new
  - (high, LOAD-BEARING) TextScaler.linear(2.0) does not reproduce what Android 14+ actually does at 200%
    textScaleFactor was deprecated after v3.12.0-2.0.pre specifically to support Android 14's NONLINEAR font scaling: large text scales less than small text. A real device at '200%' supplies a nonlinear TextScaler, so TextScaler.linear(2.0) is a deliberate over-approximation (it scales your big tile labels harder than Android would). That is the right conservatism for this app — but do not claim the test is device-faithful, and do test 1.3/1.5 too, since nonlinear scaling makes mid-range scales non-obvious.
    sources: https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor | https://docs.flutter.dev/release/breaking-changes/android-14-nonlinear-text-scaling-migration
  - (high, LOAD-BEARING) MediaQuery.withClampedTextScaling exists and is the single most dangerous API for this app
    It restricts the scaled text range to prevent UI breakage — i.e. it is the exact violation of constraint #3 (TextScaler honored at 200%+ and never clamped). It is a one-line change any future contributor might add to 'fix' an overflow failure, silently defeating the whole overflow matrix. There is no built-in lint for it; a ~10-line source-grep test is the proportionate enforcement.
    sources: https://api.flutter.dev/flutter/widgets/MediaQuery/withClampedTextScaling.html
  - (high) flutter_test_goldens is the emerging golden_toolkit successor but is too immature to bet a 2-week MVP on
    v0.0.12 (published ~19 days ago), publisher flutterbountyhunters.com, 130 pub points but only 11 likes and ~12.6k downloads. Novel model: 'golden scenes' — it tracks the position of each golden within a scene file and extracts individual images for comparison rather than diffing the whole file. Genuinely interesting, and it ships loadAppFonts/loadMaterialIconsFont. But a 0.0.x version is the wrong dependency for an app whose exit plan is unmaintained longevity.
    sources: https://pub.dev/packages/flutter_test_goldens | https://fluttergoldens.com/golden-scenes/what-is-it/
  - (high) golden_screenshot and spot solve adjacent problems, not this one
    golden_screenshot v11.0.1 (~3 months ago, adil.hanney.org, 25 likes, 18.4k downloads) targets App Store/Play/F-Droid/Flathub store screenshots, with a fuzzy comparator (~0.1% tolerance) and shadow rendering — genuinely useful for the store listing this dev must produce, but not a regression tool. spot v0.18.0 is ~13 months stale, publisher pascalwelsch.com, 110 likes; it is a chainable widget-selector + failure-timeline tool layered on flutter_test, not a golden framework.
    sources: https://pub.dev/packages/golden_screenshot | https://pub.dev/packages/spot

CODE EXAMPLES:
  --- test/support/harness.dart — the pumpApp harness (Riverpod 3 + real device sizes + a11y flags) ---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Logical sizes. `small` is the worst case we promise to support.
class Device {
  const Device(this.name, this.size, this.dpr);
  final String name;
  final Size size;
  final double dpr;

  static const small  = Device('small_360', Size(360, 640), 3.0);
  static const pixel7 = Device('pixel_7',   Size(412, 915), 2.625);
  static const seLike = Device('se_like',   Size(320, 568), 2.0);

  static const all = <Device>[small, pixel7, seLike];
  @override
  String toString() => name;
}

extension AacHarness on WidgetTester {
  /// Pins the test view to a real phone. Without this you are testing
  /// 800x600 logical - wider than any phone - and text-scale tests lie.
  void useDevice(Device d) {
    view.devicePixelRatio = d.dpr;
    view.physicalSize = d.size * d.dpr;
    addTearDown(view.reset); // TestFlutterView.reset(), not the deprecated resetXyz pairs
  }

  Future<void> pumpApp(
    Widget home, {
    List<Override> overrides = const [],
    TextScaler textScaler = TextScaler.noScaling,
    bool boldText = false,
    bool highContrast = false,
    bool accessibleNavigation = false,
    ThemeData? theme,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        // pumpWidget wraps this tree in a View, which inserts
        // MediaQuery.fromView. MaterialApp inserts NO MediaQuery of its own
        // (useInheritedMediaQuery is gone), so this MediaQuery is the nearest
        // ancestor for everything below and wins.
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: textScaler,
              boldText: boldText,
              highContrast: highContrast,
              accessibleNavigation: accessibleNavigation,
              disableAnimations: true, // zero-animation design rule
            ),
            child: MaterialApp(theme: theme, home: home),
          ),
        ),
      ),
    );
  }
}
```
  MediaQuery sits ABOVE MaterialApp deliberately — legal since useInheritedMediaQuery was removed. The Builder + copyWith is load-bearing: constructing MediaQueryData() from scratch would zero out view-derived padding.
  --- test/board/overflow_matrix_test.dart — the real safety net ---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';
import '../support/fakes.dart';

void main() {
  // Android 14+ scales nonlinearly (big text scales less than small text).
  // TextScaler.linear is a deliberate OVER-approximation: it stresses our
  // large tile labels harder than a real device would. That is the
  // conservatism we want. 1.3/1.5 are included precisely because nonlinear
  // scaling makes the mid-range non-obvious.
  const scales = <double>[1.0, 1.3, 1.5, 2.0, 3.0];

  for (final device in Device.all) {
    for (final scale in scales) {
      for (final bold in <bool>[false, true]) {
        // ONE testWidgets per tuple. Do NOT loop scales inside a single test:
        // DebugOverflowIndicatorMixin reports each RenderObject's overflow
        // exactly ONCE (_overflowReportNeeded, reset only on reassemble), so
        // later iterations would silently pass.
        testWidgets(
          'board: no overflow @ $device x${scale}${bold ? " bold" : ""}',
          (tester) async {
            tester.useDevice(device);
            await tester.pumpApp(
              const BoardScreen(),
              overrides: fakeBoardOverrides(longestLabels: true),
              textScaler: TextScaler.linear(scale),
              boldText: bold,
            );
            await tester.pump();

            // A RenderFlex overflow is reported from paint() via
            // FlutterError.reportError; the binding stores it and testWidgets
            // rethrows at test end. Asserting explicitly gives a cleaner
            // failure and documents that we must never suppress it.
            expect(tester.takeException(), isNull,
                reason: 'Tile text must never overflow at $device x$scale');
          },
        );
      }
    }
  }
}
```
  No expect() for overflow is strictly needed: the binding rethrows at test end. The explicit takeException assertion is there to produce a better message AND to document that suppression is forbidden. Note tests are GENERATED per tuple, never looped inside one body.
  --- test/board/grid_invariants_test.dart — layout invariants instead of goldens ---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';
import '../support/fakes.dart';

void main() {
  testWidgets('grid keeps 12 slots in fixed positions at 200%', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: fakeBoardOverrides(),
      textScaler: const TextScaler.linear(2.0),
    );
    await tester.pump();

    expect(find.byType(PhraseTile), findsNWidgets(12));

    Rect slot(int r, int c) =>
        tester.getRect(find.byKey(ValueKey('slot_${r}_$c')));

    // Position IS the primary key: tiles in a row share a top edge, tiles in
    // a column share a left edge. This mirrors PRIMARY KEY (board_id,row,col)
    // at the UI layer - reflow must be structurally impossible here too.
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 3; c++) {
        expect(slot(r, c).top, moreOrLessEquals(slot(r, 0).top, epsilon: 0.5),
            reason: 'row $r reflowed at col $c');
        expect(slot(r, c).left, moreOrLessEquals(slot(0, c).left, epsilon: 0.5),
            reason: 'col $c reflowed at row $r');
      }
    }
  });

  testWidgets('an empty slot still occupies its cell', (tester) async {
    tester.useDevice(Device.small);
    // grid_slots.button_id is NULLABLE - an empty cell must hold its space,
    // never collapse and pull the next tile into its position.
    await tester.pumpApp(
      const BoardScreen(),
      overrides: fakeBoardOverrides(emptySlots: {(1, 1)}),
    );
    await tester.pump();
    expect(tester.getRect(find.byKey(const ValueKey('slot_1_1'))).width,
        greaterThan(0));
  });
}
```
  This is the golden-replacement. It asserts the actual design property (fixed grid, reflow impossible) in plain text, platform-independently, with a readable diff on failure and zero binary artifacts.
  --- test/board/speech_test.dart — asserting a tap SPEAKS, and that failure is never silent ---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';

class FakeSpeechService implements SpeechService {
  final List<String> spoken = <String>[];
  Object? failWith;

  @override
  Future<void> speak(String text) async {
    if (failWith != null) throw failWith!;
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<List<Voice>> voices() async => const <Voice>[];
}

void main() {
  testWidgets('tapping a tile speaks the VOCALIZATION, not the label',
      (tester) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.pixel7);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: [
        speechServiceProvider.overrideWithValue(speech),
        boardRepositoryProvider.overrideWithValue(
          FakeBoardRepository.oneTile(
            row: 0,
            col: 0,
            label: 'Overwhelmed',
            vocalization: "I need to leave, I'm not able to talk right now",
          ),
        ),
      ],
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('slot_0_0')));
    await tester.pump();

    // The tile SHOWS 'Overwhelmed' but must SPEAK the full sentence.
    expect(find.text('Overwhelmed'), findsOneWidget);
    expect(speech.spoken,
        ["I need to leave, I'm not able to talk right now"]);
  });

  testWidgets('speech failure is VISIBLE, never silent', (tester) async {
    final speech = FakeSpeechService()..failWith = SpeechFailure('no voice');
    tester.useDevice(Device.pixel7);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: [
        speechServiceProvider.overrideWithValue(speech),
        boardRepositoryProvider.overrideWithValue(
          FakeBoardRepository.oneTile(
            row: 0, col: 0, label: 'Overwhelmed',
            vocalization: 'I need to leave',
          ),
        ),
      ],
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('slot_0_0')));
    await tester.pump();

    // Constraint #4: a user tapping mid-shutdown must NEVER get nothing.
    // If TTS cannot speak, the text must appear on screen instead.
    expect(find.text('I need to leave'), findsOneWidget);
    expect(tester.takeException(), isNull); // failure handled, not thrown
  });
}
```
  The first test is the single highest-value test in the suite: it pins label != vocalization. The second encodes constraint #4 — a speech failure must produce a visible artifact.
  --- test/board/a11y_test.dart — guideline matchers + semantics, run at 200% ---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';
import '../support/fakes.dart';

void main() {
  testWidgets('board meets a11y guidelines at 200% on the smallest phone',
      (tester) async {
    final handle = tester.ensureSemantics();
    tester.useDevice(Device.seLike);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: fakeBoardOverrides(),
      textScaler: const TextScaler.linear(2.0),
      accessibleNavigation: true, // Switch Access / VoiceOver on
    );
    await tester.pump();

    // Hard gates.
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    // Advisory: the FlutterTest font renders solid box glyphs, so sampled
    // contrast is not glyph-faithful. Back this with a hand-computed
    // contrast unit test over the 3 theme palettes.
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('each tile exposes the LABEL to screen readers, as a button',
      (tester) async {
    final handle = tester.ensureSemantics();
    tester.useDevice(Device.pixel7);
    await tester.pumpApp(const BoardScreen(), overrides: fakeBoardOverrides());
    await tester.pump();

    expect(
      tester.getSemantics(find.byKey(const ValueKey('slot_0_0'))),
      matchesSemantics(
        label: 'Overwhelmed',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });
}
```
  Run the guidelines at the worst-case device AND 200% scale — that is where tap targets shrink. ensureSemantics() is required before meetsGuideline, and each expectLater must be awaited.
  --- test/policy/no_text_clamping_test.dart — enforcing 'never clamp' as a test ---
```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no code clamps or overrides text scaling', () {
    const forbidden = <String>[
      'withClampedTextScaling', // clamps TextScaler - violates a11y contract
      'textScaleFactor',        // deprecated; and usually a clamping hack
      'TextScaler.noScaling',   // must not appear in lib/ (tests may use it)
    ];

    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      for (final bad in forbidden) {
        if (src.contains(bad)) offenders.add('${f.path}: $bad');
      }
    }

    expect(offenders, isEmpty,
        reason: 'TextScaler must be honored at 200%+ and never clamped.\n'
            'Fix the layout, do not clamp the text.\n'
            '${offenders.join("\n")}');
  });
}
```
  Ten lines that make constraint #3 unbreakable by a future contributor (or by you at 2am). There is no lint for withClampedTextScaling; this is the proportionate solo-dev substitute.
  --- Drift in a widget test — the closeStreamsSynchronously requirement ---
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // `flutter test` runs in a plain Dart VM: sqlite3_flutter_libs does
    // NOTHING here. This resolves the HOST sqlite3.
    //   macOS: system libsqlite3 (older than the bundled one - version skew!)
    //   Ubuntu CI: apt-get install -y libsqlite3-dev  BEFORE flutter test
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        // REQUIRED in widget tests. Drift otherwise keeps an unsubscribed
        // query stream open for one event-loop iteration, which never
        // arrives under the widget test's FakeAsync clock -> pending timers
        // and state leaking into the next test.
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() => db.close());

  testWidgets('board renders tiles read from a real drift DB', (tester) async {
    await db.into(db.boards).insert(
        BoardsCompanion.insert(id: const Value(1), name: 'Default'));
    await db.into(db.buttons).insert(ButtonsCompanion.insert(
          id: const Value(1),
          label: 'Overwhelmed',
          vocalization: "I need to leave, I'm not able to talk right now",
        ));
    await db.into(db.gridSlots).insert(GridSlotsCompanion.insert(
          boardId: 1, row: 0, col: 0, buttonId: const Value(1),
        ));

    tester.useDevice(Device.pixel7);
    await tester.pumpApp(
      const BoardScreen(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Overwhelmed'), findsOneWidget);
  });
}
```
  Use this shape ONLY for the 2-3 end-to-end boot tests. Everything else fakes the repository. Without closeStreamsSynchronously: true, drift's one-event-loop-iteration stream teardown never runs under the widget test's FakeAsync clock.
  --- IF you add goldens later: tag-exclude them so a stranger's `flutter test` stays green ---
```yaml
# dart_test.yaml
tags:
  golden:
    # Goldens are platform-dependent once real fonts are loaded (macOS dev vs
    # Linux CI produce different pixels). Excluded by default so that a
    # stranger cloning this repo gets a GREEN `flutter test` on any OS.
    # CI regenerates/verifies them in a pinned Docker image:
    #   flutter test --tags golden
    skip: "run only in the pinned CI container: flutter test --tags golden"

# test/board/board_golden_test.dart
#   @Tags(['golden'])
#   library;
#   ... testWidgets('board canary', (tester) async {
#         await expectLater(find.byType(BoardScreen),
#             matchesGoldenFile('goldens/board.png'));
#       });

# test/flutter_test_config.dart  (only needed if goldens exist)
#   Future<void> testExecutable(FutureOr<void> Function() testMain) async {
#     await loadAppFonts();            // else FlutterTest box glyphs, not Ahem
#     await loadMaterialIconsFont();
#     return testMain();
#   }
```
  dart_test.yaml. Combine with `flutter test --tags golden --update-goldens` inside a pinned Docker image on CI only. This is the ONLY golden setup compatible with the open-source-and-abandon exit plan.

FACT-CHECK:
    - [CONFIRMED] A RenderFlex overflow FAILS a widget test by default; it does not merely log
    - [CONFIRMED] Overflow is reported only ONCE per RenderObject, so looping text scales inside one testWidgets under-reports
    - [CONFIRMED] alchemist's CI goldens obscure text into colored boxes — which destroys the only signal this app would want from a golden
    - [PARTIALLY_TRUE] "The default widget-test surface is 800x600 logical — bigger than any phone — so an unpinned overflow test is near-worthless"
      CORRECTION: Keep the practice, fix three things. (a) Drop "bigger than any phone" — it's wider (800 vs ~440) but SHORTER (600 vs ~915) than a real phone, so the default over-reports vertical overflow and under-reports horizontal; "near-worthless" should be "miscalibrated, axis-dependent". (b) The example is off by DPR: `physicalSize` takes PHYSICAL pixels. Use `tester.view.physicalSize = const Size(360*3, 800*3); tester.view.devicePixelRatio = 3.0;` — or set logical values with `devicePixelRatio = 1.0`. Writing `physicalSize = Size(320,568)` at default DPR 3.0 actually yields a 106.7x189.3 surface. (c) Prefer `tester.view.physicalSize`/`devicePixelRatio` over `setSurfaceSize` and don't present them as equivalent: setSurfaceSize resizes the layout box but leaves `MediaQuery.size` at 800x600. Always reset via `addTearDown(tester.view.reset)` (or `addTearDown(() => binding.setSurfaceSize(null))`) — the docs explicitly warn about leaking state into other tests, which the claim omits. Also soften "320x568 worst case": that's an iPhone SE 1st-gen/iPhone 5 profile and is a team choice, not something any primary source prescribes.
    - [PARTIALLY_TRUE] "Overflow only reports if the widget actually PAINTS"
      CORRECTION: Replace "Anything Offstage, inside a lazy list beyond the viewport, or clipped away never reports" with: "Anything Offstage, or scrolled outside a viewport (lazy OR non-lazy — RenderViewportBase._paintContents culls on child.geometry!.visible, not on whether it was built), never reports. CLIPPED CONTENT STILL REPORTS: RenderClipRect.paint passes super.paint into context.pushClipRect, so the child paints inside the clip layer; and RenderFlex explicitly calls paintOverflowIndicator AFTER pushing its own clip when clipBehavior != Clip.none. Clipping hides the yellow/black stripes' extent, not the console report — see open issue flutter/flutter#100789. The docs' 'clip with a ClipRect' advice works only when applied to the CHILD before it enters the flex, which shrinks the child so no overflow occurs at all; it is not a way to silence an existing overflow."
    - [PARTIALLY_TRUE] "golden_toolkit is DISCONTINUED; alchemist is maintained but is Betterment's, not Very Good Ventures'"
      CORRECTION: Strike the assertion that "the brief's attribution of alchemist to Very Good Ventures is incorrect." Alchemist was co-created by Very Good Ventures and Betterment — released by VGV in association with Betterment in February 2022 — and the README still credits "Developed with 💙 by Very Good Ventures 🦄 and Betterment ☀️" alongside the VGV logo. The accurate phrasing: alchemist's pub.dev verified publisher is betterment.dev and the repo is hosted at github.com/Betterment/alchemist, but it is a joint VGV/Betterment project, so attributing it to VGV is not an error. Everything else in the claim stands verbatim: golden_toolkit v0.15.0 discontinued with no suggested replacement (publisher eBay.com, ~3 years since last publish); alchemist v0.14.0 published ~4 months ago (2026-03-13), 160 pub points, 220 likes, ~305k weekly downloads. Add one nuance: eBay/flutter_glove_box is pub.dev-discontinued and README-declared unmaintained, but is not formally GitHub-archived.
    - [PARTIALLY_TRUE] "Font loading in goldens is NOT automatic in 2026; it still requires an explicit FontLoader call in flutter_test_config.dart"
      CORRECTION: The headline claim is correct and should be kept: font loading in goldens is still not automatic in 2026, FontLoader is still required, and flutter_test_config.dart/testExecutable is still the placement. Fix two specifics before relying on this.

1. The call is TestFonts.loadAppFonts(), not bare loadAppFonts(). In flutter_test_goldens it is a static on the TestFonts class; only loadMaterialIconsFont() is top-level. Correct usage:

   // test/flutter_test_config.dart
   import 'package:flutter_test_goldens/flutter_test_goldens.dart';
   Future<void> testExecutable(FutureOr<void> Function() testMain) async {
     await TestFonts.loadAppFonts();
     await loadMaterialIconsFont();
     await testMain();
   }

2. Drop alchemist from the list of loadAppFonts sources. It has no loadAppFonts — it exposes loadFonts() — and it intentionally forces Ahem for CI goldens, which is the opposite of what the claim cites it for. The accurate statement: the maintained port of golden_toolkit's loadAppFonts is flutter_test_goldens (which literally vendors golden_toolkit's implementation in lib/src/fonts/golden_toolkit_fonts.dart), or roll your own ~20 lines.

Also worth recording: flutter_test_goldens is 0.0.12 (pre-1.0), and loadMaterialIconsFont requires FLUTTER_ROOT to be set in the environment.

RECOMMENDATIONS:
  - [must] Pin a real device size in EVERY layout/text-scale test via tester.view.physicalSize + devicePixelRatio, with addTearDown(tester.view.reset). Never let a layout test run at the default 800x600. — The 800x600 default is wider than any phone, so tiles are ~2x too wide and text fits. An unpinned overflow suite is green while the shipped 360pt phone UI is broken — the worst possible outcome for a project with no telemetry.
  - [must] Never call takeException() to swallow, and never set FlutterError.onError, in any layout test. Add expect(tester.takeException(), isNull) as the explicit assertion instead. — Overflow already fails the test for free via FlutterError.reportError -> _pendingExceptionDetails -> rethrow at test end. The only way to lose this safety net is to suppress it, which is exactly what the popular 'ignoreOverflowErrors' blog helper teaches.
  - [must] Generate one testWidgets per (device x textScale x theme) tuple in nested for-loops OUTSIDE the test body. Never loop scales inside a single test body. — DebugOverflowIndicatorMixin's _overflowReportNeeded flag reports each RenderObject's overflow only once (reset only on reassemble), so a scale loop inside one test silently under-reports the 2nd and 3rd scales.
  - [must] Put the MediaQuery override above MaterialApp, and build its data from MediaQuery.of(context).copyWith(...) via a Builder rather than constructing MediaQueryData() from scratch. — MaterialApp no longer inserts its own MediaQuery (useInheritedMediaQuery is ignored; the View does it), so an ancestor MediaQuery wins. copyWith preserves view-derived padding/size that a raw MediaQueryData() would silently zero out.
  - [must] Assert on a FakeSpeechService that a tile tap speaks the VOCALIZATION string, never the label — one test per seeded tile fixture. — label != vocalization is the core Open Board Format semantic of this app. Swapping them is a silent, plausible-looking regression that no type checker catches and that no user will report because they cannot speak.
  - [must] Write an explicit test that a SpeechService failure (throw, empty voice list, setVoice returning false) renders a VISIBLE fallback, and assert the widget is found. — Constraint #4 says silence is the worst bug class. 'Nothing happens' is the default behaviour of an unasserted error path; only a test that demands a visible artifact makes silence impossible.
  - [must] Gate every screen with tester.ensureSemantics() + meetsGuideline(androidTapTargetGuideline / iOSTapTargetGuideline / labeledTapTargetGuideline), run at 200% text scale on the smallest device. — These four matchers are already in flutter_test — they convert 'accessibility is correctness' from developer discipline into CI failure at zero dependency cost. Running them at 200% on 320pt catches the tap-target shrinkage that the 1.0x test misses.
  - [must] Add a ~10-line test that greps lib/ for 'withClampedTextScaling' and 'textScaleFactor' and fails if either appears. — MediaQuery.withClampedTextScaling is the one-line 'fix' a future contributor will reach for when an overflow test fails, and it silently defeats constraint #3. No lint exists for it; a source-grep test is the proportionate solo-dev enforcement.
  - [should] Fake the repository for the ~50 UI widget tests; use real drift NativeDatabase.memory() only in DAO/repository tests and in 2-3 end-to-end 'boot' widget tests. — Faking keeps the UI matrix fast and host-sqlite3-free. But with no telemetry, the DB->UI seam is precisely what you cannot observe in the field, so a few real-drift widget tests are worth their cost. Migration tests are a separate, non-negotiable suite (constraint #2) and always use real drift.
  - [must] If you use drift in any widget test, pass DatabaseConnection(..., closeStreamsSynchronously: true). — Drift keeps unsubscribed query streams open for one event-loop iteration, which never arrives under the widget test's FakeAsync clock — producing pending-timer failures and state leaking into the next test. This is the specific reason naive real-drift widget tests are flaky.
  - [must] Document the host sqlite3 requirement in README/CONTRIBUTING (macOS: system lib; Ubuntu: apt-get install libsqlite3-dev before flutter test). — flutter test runs in a plain Dart VM where sqlite3_flutter_libs does nothing. Constraint #5 is that a stranger picks this up — a stranger who clones on Linux and sees DB tests fail concludes the repo is broken and walks away.
  - [avoid] Do NOT build a golden regression suite for the MVP. — Every failure mode goldens would catch here (text not fitting, tiles reflowing) is already caught more cheaply and with a readable message by the overflow matrix + getRect layout invariants + semantics assertions. Goldens add binary blobs to git, churn on every padding tweak, and — decisively for constraint #5 — a stranger running flutter test on Linux against macOS-generated goldens sees a wall of red and concludes the repo is broken. Goldens actively sabotage the open-source exit plan.
  - [should] Replace the golden suite with getRect-based layout invariants: assert exactly 12 slots exist and that tiles in the same row share a top edge (moreOrLessEquals, epsilon 0.5) at every scale. — This asserts the actual design property — the grid is fixed and reflow is impossible — in plain text, platform-independently, with a diagnostic failure message and zero maintenance. It mirrors at the UI layer the guarantee that PRIMARY KEY (board_id, row, col) gives at the DB layer.
  - [should] If you later want goldens anyway: exactly ONE golden of the board, tagged @Tags(['golden']) and excluded from the default run via dart_test.yaml, generated only in a pinned Docker image on CI. — Tag-excluding keeps a stranger's bare `flutter test` green (constraint #5) while still giving you a visual tripwire. One golden, not a 3-themes x N-scales matrix — the matrix is the maintenance trap; a single canary catches catastrophic regressions at ~1/30th the churn.
  - [avoid] Do not adopt alchemist for this app's core question, and do not adopt flutter_test_goldens at 0.0.x. — alchemist is maintained (Betterment, 0.14.0) but its CI goldens set obscureText: true, replacing text with colored rectangles — it achieves platform stability by discarding exactly the glyph rendering this app needs to verify. flutter_test_goldens is 0.0.12 with 11 likes; betting an intentionally-unmaintained app on it contradicts the longevity plan.
  - [should] Do use golden_screenshot — but for App Store / Play / F-Droid store listing screenshots, not regression. — It is maintained (v11.0.1) and purpose-built for store screenshots, which this dev must produce anyway. Reframing 'goldens' as a marketing-asset generator captures the real value without any of the regression-suite churn.
  - [should] Test the a11y flags that change layout (boldText, accessibleNavigation, highContrast) as first-class matrix axes, not afterthoughts. Skip disableAnimations/invertColors tests. — boldText widens glyphs and can overflow a tile that passes at the same scale unbolded; accessibleNavigation is what Switch Access/VoiceOver set. disableAnimations is moot given the zero-animation design rule, and invertColors is applied by the OS compositor, not the Flutter tree — testing them spends budget for no signal.
  - [should] Use TextScaler.linear at 1.0/1.3/1.5/2.0/3.0 and document in a comment that this is a deliberate over-approximation of Android 14 nonlinear scaling. — Android 14+ scales large text less than small text, so linear(2.0) stresses big tile labels harder than a real device — the right conservatism. But the mid-range values matter precisely because nonlinear scaling makes 1.3/1.5 non-obvious, and an undocumented linear assumption will mislead the stranger who inherits this.
  - [should] Use Riverpod 3 test idioms: ProviderContainer.test() over a hand-rolled createContainer, and tester.container() to reach the container from a widget test. — flutter_riverpod 3.3.2 is stable and ProviderContainer.test auto-disposes at test end; the docs explicitly say never to use ProviderContainer directly in tests. Since Riverpod was chosen specifically for the testable repository/UI seam, using the seam idiomatically is the whole point of having paid for it.
  - [avoid] Skip: golden diffing across 3 themes x N scales, integration_test/Patrol for the MVP, and any coverage-percentage gate. — Constraint #6 says ceremony a team needs and a solo dev does not is a real cost. Patrol has had recurring CI stability issues through late-2025/early-2026; a coverage gate optimizes a number rather than the two properties that actually matter here (no silence, no data loss), both of which are covered by targeted tests.

---

### DIMENSION: a11y-testing
SUMMARY: Flutter's built-in a11y guideline API is real, current, and cheap to adopt — but it is far weaker than its reputation, and for THIS app's geometry it is close to a no-op unless you know two specific traps. Trap 1: `MinimumTapTargetGuideline` silently SKIPS any node whose paint bounds touch the view boundary (`_isAtBoundary`, gap threshold 0.001) — a full-bleed 3x4 grid means the edge tiles, which is most of them, are never checked and the test passes vacuously. Trap 2: `textContrastGuideline` has a long-standing open false-negative (flutter#103235: white-on-#fafafa PASSES), so it cannot be trusted as the contrast gate. The API itself is confirmed: `final handle = tester.ensureSemantics(); await expectLater(tester, meetsGuideline(androidTapTargetGuideline)); handle.dispose();` is correct and current, with exact thresholds Android 48x48, iOS 44x44, contrast 4.5:1 normal / 3.0:1 large (large = 18px, or 14px bold). The custom 76dp guideline needs NO subclassing — `MinimumTapTargetGuideline` has a public const constructor (`const MinimumTapTargetGuideline({required Size size, required String link})`) and is `@visibleForTesting`, so instantiating it at Size(76,76) inside `test/` is the sanctioned path; `AccessibilityGuideline` is a plain abstract class with a const ctor if you do want a custom one. A live API break matters here: `containsSemantics` is DEPRECATED after v3.40.0-1.0.pre in favor of `isSemantics` — on Flutter 3.44 stable, most tutorials you'll find are already wrong. The highest-value test for this project is not `meetsGuideline` at all: it is `tester.semantics.simulatedAccessibilityTraversal()`, which pins the exact order a screen reader AND a switch scanner visit the 12 tiles — the one automated proxy for Switch Access/Switch Control, which are otherwise manual-only. Espresso `AccessibilityChecks` is useless on Flutter (View-hierarchy-based; Flutter is one FlutterView), while Google's Accessibility Scanner DOES work because it is an accessibility service and reads Flutter's AccessibilityBridge virtual node tree — but it is manual and cannot go in CI. There are no a11y lints in `flutter_lints`; DCM has a handful (`avoid-missing-image-alt`, `prefer-action-button-tooltip`, `prefer-text-rich`) that don't cover what matters here. Deque's 57%-of-issues automation figure is for axe-core's ~100 web rules; Flutter's four guidelines are a small fraction of that, so budget accordingly: automated a11y here is a regression net, and a written manual device checklist is the actual correctness gate.

FINDINGS:
  - (high, LOAD-BEARING) The documented meetsGuideline/ensureSemantics pattern is current and correct on Flutter 3.44.
    `testWidgets('a11y', (tester) async { final SemanticsHandle handle = tester.ensureSemantics(); await tester.pumpWidget(const App()); await expectLater(tester, meetsGuideline(androidTapTargetGuideline)); handle.dispose(); });` — confirmed against docs.flutter.dev/ui/accessibility/accessibility-testing. `ensureSemantics()` is required (semantics tree is off by default in tests) and `handle.dispose()` is required. `meetsGuideline` must be awaited via expectLater because `AccessibilityGuideline.evaluate` returns `FutureOr<Evaluation>` and the contrast guideline is genuinely async (it screenshots the layer).
    sources: https://docs.flutter.dev/ui/accessibility/accessibility-testing | https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html
  - (high, LOAD-BEARING) Exact thresholds: androidTapTargetGuideline = Size(48,48); iOSTapTargetGuideline = Size(44,44); contrast 4.5 normal / 3.0 large; large text = 18px or 14px bold; default assumed font size 12.
    Read from packages/flutter_test/lib/src/accessibility.dart master. `const AccessibilityGuideline androidTapTargetGuideline = MinimumTapTargetGuideline(size: Size(48.0, 48.0), link: 'https://support.google.com/accessibility/android/answer/7101858?hl=en');` and `iOSTapTargetGuideline = MinimumTapTargetGuideline(size: Size(44.0, 44.0), link: <HIG url>)`. In MinimumTextContrastGuideline: `kMinimumRatioNormalText = 4.5`, `kMinimumRatioLargeText = 3.0`, `kLargeTextMinimumSize = 18`, `kBoldTextMinimumSize = 14`, `_kDefaultFontSize = 12.0`, `_tolerance = -0.01`. Sizes are compared in logical pixels (`paintBounds.size / view.devicePixelRatio`), so Size(76,76) means 76dp.
    sources: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart
  - (high, LOAD-BEARING) CRITICAL FOR THIS APP: MinimumTapTargetGuideline silently skips every tappable node whose bounds touch the view edge — a full-bleed 3x4 grid would make the tap-target test pass vacuously on the edge tiles.
    Source: `final Rect viewRect = Offset.zero & view.physicalSize; if (_isAtBoundary(paintBounds, viewRect)) { return result; }` where `_isAtBoundary` returns true unless the child has a gap > `_kMinimumGapToBoundary` (0.001) on ALL four sides. It also skips nodes touching a scrollable ancestor's edge (`current.flagsCollection.hasImplicitScrolling && _isAtBoundary(...)`). In a 3x4 grid that reaches the screen edges, the 10 perimeter tiles are skipped and only the 2 interior tiles are actually measured. The test goes green while checking almost nothing. Additional skips in `shouldSkipNode`: nodes with neither tap nor longPress action, `isHidden` nodes, and `isLink` nodes (per WCAG target-size). Nodes with `isMergedIntoParent` are skipped too (the merged parent gets checked instead, which is the desired behavior for a tile).
    sources: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart
  - (high, LOAD-BEARING) A custom 76dp guideline requires NO subclassing — MinimumTapTargetGuideline's const constructor is public and the class is @visibleForTesting.
    `@visibleForTesting class MinimumTapTargetGuideline extends AccessibilityGuideline { const MinimumTapTargetGuideline({required this.size, required this.link}); final Size size; final String link; ... }`. So `const MinimumTapTargetGuideline(size: Size(76,76), link: '<your docs url>')` works, and because of @visibleForTesting the analyzer accepts it inside test/ with no lint. Contrast: `LabeledTapTargetGuideline` has a PRIVATE constructor (`const LabeledTapTargetGuideline._()`) so it cannot be re-parameterized or subclassed — only the `labeledTapTargetGuideline` const is usable. `AccessibilityGuideline` itself is a public, extendable abstract class: `abstract class AccessibilityGuideline { const AccessibilityGuideline(); FutureOr<Evaluation> evaluate(WidgetTester tester); String get description; }`, with `Evaluation.pass()`, `Evaluation.fail(String reason)`, `final bool passed`, `final String? reason`, and `operator +` that ANDs results and newline-joins reasons.
    sources: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart | https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html
  - (high, LOAD-BEARING) textContrastGuideline has an open, unfixed false-negative and must not be the contrast gate.
    flutter/flutter#103235: `meetsGuideline(textContrastGuideline)` PASSES with white text (0xffffff) on 0xfafafa. Still open, P2. Mechanism: the guideline screenshots the render layer and samples pixels, picking foreground/background from a color histogram over the text's paint bounds (`find.text(text).hitTestable()`), so it mis-attributes which color is 'background' in low-variance regions and on anti-aliased/blended text. It also only evaluates nodes whose label/value text is findable via `find.text`, so text drawn in a CustomPainter or as an image is invisible to it.
    sources: https://github.com/flutter/flutter/issues/103235
  - (high) There is an undocumented-in-blogs WCAG AAA contrast guideline class available.
    `class MinimumTextContrastGuidelineAAA extends MinimumTextContrastGuideline { const MinimumTextContrastGuidelineAAA(); }` with `kAAAMinimumRatioNormalText = 7.0` and `kAAAMinimumRatioLargeText = 4.5`. Usable directly as `meetsGuideline(const MinimumTextContrastGuidelineAAA())`. Relevant for an AAC app used in distress/low-light, but it inherits the same #103235 sampling defect.
    sources: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart
  - (high, LOAD-BEARING) BREAKING/CURRENT: containsSemantics is deprecated after v3.40.0-1.0.pre; use isSemantics. matchesSemantics is NOT deprecated.
    api.flutter.dev for containsSemantics states: 'Migrate to isSemantics instead. This feature was deprecated after v3.40.0-1.0.pre.' Its implementation now just delegates every parameter to `isSemantics()`. Since stable is 3.44.0, this deprecation is live and virtually every tutorial/blog predates it. Semantics: `isSemantics(...)` = partial match, only what you specify is checked. `matchesSemantics(...)` = strict, unspecified flags/actions default to false-expected (so it fails if the node has an extra flag you didn't declare). Both take ~85 named params including label, value, hint, identifier, isButton, isEnabled, hasEnabledState, isFocusable, isFocused, isTextField, isHidden, isImage, isHeader, isLink, hasTapAction, hasLongPressAction, hasFocusAction, onTapHint, onLongPressHint, customActions, rect, size, textDirection, and `List<Matcher>? children`.
    sources: https://api.flutter.dev/flutter/flutter_test/containsSemantics.html | https://api.flutter.dev/flutter/flutter_test/isSemantics.html | https://api.flutter.dev/flutter/flutter_test/matchesSemantics.html
  - (high, LOAD-BEARING) Screen-reader traversal order IS automatable via SemanticsController.simulatedAccessibilityTraversal — and it is the best available proxy for switch-scanning order.
    Accessed as `tester.semantics`. Signature: `Iterable<SemanticsNode> simulatedAccessibilityTraversal({FinderBase<Element>? start, FinderBase<Element>? end, FinderBase<SemanticsNode>? startNode, FinderBase<SemanticsNode>? endNode, FlutterView? view})`. Also `SemanticsNode find(FinderBase<Element> finder)`. It simulates traversal 'as if by assistive technologies'. Because Android Switch Access and iOS Switch Control scan in the same platform traversal order the screen reader uses, pinning this order is the only automated signal you can get about switch scanning.
    sources: https://api.flutter.dev/flutter/flutter_test/SemanticsController-class.html
  - (medium, LOAD-BEARING) Espresso AccessibilityChecks does NOT work usefully on a Flutter app; Google's Accessibility Scanner DOES.
    Flutter renders into a single FlutterView with no child Android Views. Espresso's AccessibilityChecks runs the Accessibility Test Framework over the Android View hierarchy, so it sees one opaque view and finds nothing meaningful. Accessibility Scanner, by contrast, is an installed AccessibilityService and reads AccessibilityNodeInfo — which Flutter's `AccessibilityBridge` populates as a virtual view hierarchy ('AccessibilityBridge causes Android to treat Flutter SemanticsNodes as if they were accessible Android Views', identified by virtual view IDs via AccessibilityNodeProvider). So Scanner works, but it is a manual, on-device, human-driven tool — not CI. Deque axe DevTools Mobile also supports Flutter via the same mechanism (commercial).
    sources: https://api.flutter.dev/javadoc/io/flutter/view/AccessibilityBridge.html | https://developer.android.com/training/testing/espresso/accessibility-checking | https://docs.deque.com/devtools-mobile/2025.7.2/en/flutter/
  - (high, LOAD-BEARING) Flutter's semantics tree is not exposed to the Android platform during flutter drive unless an accessibility service is already running — blocking naive CI a11y automation.
    flutter/flutter#111110, open, P2: 'When using flutter drive, Flutter's semantics tree doesn't produce virtual Android Views.' Reporter confirms 'If TalkBack is enabled, the view hierarchy exists even during flutter drive. But this is an ugly and annoying workaround.' Affects Android 9-13. Consequence: any CI plan that shells out to a native a11y auditor against a driven Flutter app needs an accessibility service force-enabled on the emulator (adb settings put secure enabled_accessibility_services ...), which is fragile. For a solo 2-week MVP this is not worth building.
    sources: https://github.com/flutter/flutter/issues/111110
  - (high, LOAD-BEARING) Switch Access / Switch Control cannot be tested automatically at all. Manual only.
    Flutter publishes no Switch Control/Switch Access support statement, and there is no test API that simulates switch scanning, group selection, or point scanning. The only automatable proxy is traversal order (above). Everything else — whether a tile is reachable, whether the scan highlight is visible against your theme, whether edit mode traps the scanner, whether the type-to-speak field can be exited — is a human-on-device check.
    sources: https://docs.flutter.dev/ui/accessibility/assistive-technologies
  - (high, LOAD-BEARING) There are no accessibility lint rules in flutter_lints. DCM has a few, none of which cover this app's risks.
    flutter_lints / package:lints ship zero a11y rules. DCM (dcm.dev, commercial with a free tier) has `avoid-missing-image-alt` (Image without semanticLabel), `prefer-action-button-tooltip` (FloatingActionButton without tooltip), `prefer-text-rich` (RichText vs Text.rich), `prefer-dedicated-media-query-method`. None enforce 'every tile has a semantic label', 'no clamped TextScaler', or 'no hardcoded tile height'. The pub package `flutter_accessibility_scanner` is a runtime debug-overlay widget, not a linter, and is low-adoption — not a dependency worth taking for a permanence-oriented open-source app.
    sources: https://dcm.dev/blog/2025/06/30/accessibility-flutter-practical-tips-tools-code-youll-actually-use/ | https://pub.dev/packages/flutter_accessibility_scanner
  - (medium, LOAD-BEARING) Automated a11y checking catches a minority of real issues; the best-evidenced figure is 57%, and Flutter's four guidelines are far below that.
    Deque's Automated Accessibility Coverage Report: anonymized data from 2,000+ audits, 13,000+ pages, ~300,000 issues, found automation completely covered 57% of ISSUES (the commonly-cited ~30% figure counts WCAG success criteria instead, which understates it because a few issue types dominate by volume). But that 57% is axe-core's ~100 web rules. Flutter ships FOUR guidelines (tap size, label presence, contrast) — roughly the subset axe would call 'trivially machine-checkable' — and one of them (contrast) is known-broken. Realistic expectation for Flutter's built-ins: well under half of what axe catches, i.e. a small minority of real issues. This is not an argument against them; it is an argument that they are a regression tripwire, not a gate.
    sources: https://www.deque.com/blog/automated-testing-study-identifies-57-percent-of-digital-accessibility-issues/ | https://www.deque.com/automated-accessibility-coverage-report/
  - (high, LOAD-BEARING) Automated guidelines cannot catch the failure modes that would actually hurt this app's users.
    Specifically NOT caught: (1) label CORRECTNESS — labeledTapTargetGuideline only checks a label is non-empty, so a tile labeled 'button1' or a tile whose semantic label leaks the vocalization ('I need to leave, I'm not able to talk right now') instead of the display label ('Overwhelmed') passes; (2) traversal ORDER sanity (order is assertable but no guideline checks it); (3) whether the announced label matches the spoken TTS output — the whole label/vocalization split is semantically invisible to the tooling; (4) reachability/focus traps in edit mode; (5) whether TTS actually produced audio; (6) real screen-reader pronunciation, verbosity, and hint text; (7) overflow/clipping at 200% TextScaler (contrast/tap-size guidelines don't notice text clipped to nothing — you need golden or explicit overflow assertions); (8) color-only meaning; (9) live-region announcement timing.
    sources: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart
  - (high, LOAD-BEARING) Accessibility feature flags (textScaler, boldText, disableAnimations, highContrast) are settable in widget tests two ways, and the MediaQuery-wrapper way is the one to use.
    Preferred and hermetic: wrap the widget under test in `MediaQuery(data: const MediaQueryData(textScaler: TextScaler.linear(2.0), boldText: true, disableAnimations: true, highContrast: true), child: app)`. Global alternative: `tester.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(...)` and `tester.platformDispatcher.textScaleFactorTestValue = 2.0`, which REQUIRE `addTearDown(tester.platformDispatcher.clearAllTestValues)` or they leak into later tests. Note `textScaleFactor` is deprecated framework-wide in favor of `TextScaler` (nonlinear scaling for Android 14); use `TextScaler.linear(2.0)` and `MediaQuery.textScalerOf(context)`. Flutter's own media_query_test.dart covers disableAnimations, boldText, highContrast, onOffSwitchLabels.
    sources: https://api.flutter.dev/flutter/widgets/MediaQueryData-class.html | https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor | https://github.com/flutter/flutter/blob/master/packages/flutter/test/widgets/media_query_test.dart
  - (medium) What the Flutter team itself does: it dogfoods these guidelines in-repo and treats semantics as unit-testable data.
    packages/flutter_test/test/accessibility_test.dart tests the guidelines themselves. Across the framework, widget a11y is asserted with `tester.getSemantics(finder)` + `matchesSemantics(...)`, and with SemanticsTester dumping expected trees — i.e. they assert the semantics NODE CONTENT, not just guideline conformance. Flutter 3.32 (May 2025) rebuilt semantics tree compilation (~80% faster) and fixed TalkBack link recognition, indicating the semantics layer is actively maintained. Notably, the team pairs this with manual screen-reader passes; there is no CI screen-reader automation in the Flutter repo.
    sources: https://github.com/flutter/flutter/blob/master/packages/flutter_test/test/accessibility_test.dart | https://dcm.dev/blog/2025/12/23/top-flutter-features-2025/

CODE EXAMPLES:
  --- The shared harness — deterministic 12-tile board (no animation = no pumpAndSettle races) ---
```dart
// test/a11y/harness.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 12 fixed slots, row-major. Labels are DISPLAY labels; the
/// vocalization is deliberately different (Open Board Format semantics).
const kTestTiles = <({int row, int col, String label, String vocalization})>[
  (row: 0, col: 0, label: 'Overwhelmed', vocalization: "I need to leave, I'm not able to talk right now"),
  (row: 0, col: 1, label: 'Yes',         vocalization: 'Yes'),
  (row: 0, col: 2, label: 'No',          vocalization: 'No'),
  (row: 1, col: 0, label: 'Wait',        vocalization: 'Please give me a moment'),
  (row: 1, col: 1, label: 'Help',        vocalization: 'I need help'),
  (row: 1, col: 2, label: 'Pain',        vocalization: 'I am in pain'),
  (row: 2, col: 0, label: 'Water',       vocalization: 'Can I have some water'),
  (row: 2, col: 1, label: 'Toilet',      vocalization: 'I need the toilet'),
  (row: 2, col: 2, label: 'Thanks',      vocalization: 'Thank you'),
  (row: 3, col: 0, label: 'Repeat',      vocalization: 'Could you repeat that'),
  (row: 3, col: 1, label: 'Slower',      vocalization: 'Please speak more slowly'),
  (row: 3, col: 2, label: 'Write',       vocalization: 'I would rather write it down'),
];

/// Pumps the grid with semantics enabled and a controlled MediaQuery.
/// Returns the SemanticsHandle — caller MUST dispose (use addTearDown).
Future<void> pumpGrid(
  WidgetTester tester, {
  TextScaler textScaler = TextScaler.noScaling,
  bool boldText = false,
  Size surface = const Size(400, 800),
}) async {
  final handle = tester.ensureSemantics();
  addTearDown(handle.dispose);

  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: surface,
        textScaler: textScaler,
        boldText: boldText,
        disableAnimations: true, // matches the zero-animation design rule
      ),
      child: const MaterialApp(home: GridScreen(/* seeded repo */)),
    ),
  );
  // No pumpAndSettle: zero animation means one pump is a settled frame.
}
```
  addTearDown(handle.dispose) is safer than a trailing handle.dispose() — it still runs if an expect() throws, so one failing test doesn't cascade into 'semantics already enabled' errors in the rest of the suite.
  --- Geometry gate — the real 76dp enforcement (does NOT use meetsGuideline) ---
```dart
// test/a11y/geometry_test.dart
// WHY NOT meetsGuideline: MinimumTapTargetGuideline skips any node whose
// paint bounds touch the view edge (_isAtBoundary, gap threshold 0.001).
// A full-bleed 3x4 grid => the 10 perimeter tiles are silently skipped and
// the guideline passes vacuously. This test has no skip logic.

testWidgets('every one of the 12 tiles is at least 76x76 dp', (tester) async {
  await pumpGrid(tester);

  for (final tile in kTestTiles) {
    final finder = find.byKey(ValueKey('tile_${tile.row}_${tile.col}'));
    expect(finder, findsOneWidget, reason: 'slot (${tile.row},${tile.col}) missing');

    final size = tester.getSize(finder);
    expect(
      size.width, greaterThanOrEqualTo(76.0),
      reason: '"${tile.label}" is ${size.width}dp wide; min tap target is 76dp',
    );
    expect(
      size.height, greaterThanOrEqualTo(76.0),
      reason: '"${tile.label}" is ${size.height}dp tall; min tap target is 76dp',
    );
  }
});

// Cheap extra tripwire. Keep it, but never let it be the only check.
testWidgets('meets built-in tap target guidelines (advisory)', (tester) async {
  await pumpGrid(tester);
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline)); // 48x48
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));     // 44x44
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
});
```
  The reason: strings matter enormously here. With no telemetry and possible abandonment, a failure message that names the tile and prints the actual dp is the difference between a stranger fixing it in 30 seconds and giving up.
  --- Custom 76dp AccessibilityGuideline — no subclassing needed ---
```dart
// MinimumTapTargetGuideline has a PUBLIC const ctor and is @visibleForTesting,
// so instantiating it in test/ is the sanctioned path (no lint).
const aacTapTargetGuideline = MinimumTapTargetGuideline(
  size: Size(76.0, 76.0), // logical px (dp): source divides by devicePixelRatio
  link: 'https://github.com/you/offline-aac/blob/main/docs/a11y.md#tap-targets',
);

testWidgets('meets the 76dp AAC tap target guideline', (tester) async {
  await pumpGrid(tester);
  await expectLater(tester, meetsGuideline(aacTapTargetGuideline));
});

// If you ever DO need a real custom guideline, AccessibilityGuideline is a
// plain public abstract class with a const ctor:
class NoTinyLabelGuideline extends AccessibilityGuideline {
  const NoTinyLabelGuideline();

  @override
  String get description => 'Tile semantic labels must be human-readable';

  @override
  FutureOr<Evaluation> evaluate(WidgetTester tester) {
    var result = const Evaluation.pass();
    for (final view in tester.binding.renderViews) {
      result += _walk(view.owner!.semanticsOwner!.rootSemanticsNode!);
    }
    return result; // Evaluation.operator+ ANDs passed, newline-joins reasons
  }

  Evaluation _walk(SemanticsNode node) {
    var result = const Evaluation.pass();
    node.visitChildren((child) { result += _walk(child); return true; });
    final data = node.getSemanticsData();
    if (data.hasAction(ui.SemanticsAction.tap) &&
        RegExp(r'^(button|tile|item)\s*\d+$', caseSensitive: false).hasMatch(data.label)) {
      result += Evaluation.fail('$node: placeholder label "${data.label}"');
    }
    return result;
  }
}
```
  LabeledTapTargetGuideline canNOT be reused this way — its ctor is private (const LabeledTapTargetGuideline._()). Only MinimumTapTargetGuideline, MinimumTextContrastGuideline, MinimumTextContrastGuidelineAAA, and CustomMinimumContrastGuideline have public ctors.
  --- The single highest-value test: traversal order (and the switch-scan proxy) ---
```dart
// test/a11y/traversal_test.dart
testWidgets('screen reader / switch scanner visits the 12 tiles row-major', (tester) async {
  await pumpGrid(tester);

  final traversal = tester.semantics.simulatedAccessibilityTraversal();

  // Keep only the tile nodes (drop app bar, text field, etc.).
  final tileLabels = traversal
      .map((n) => n.label)
      .where((l) => kTestTiles.any((t) => t.label == l))
      .toList();

  expect(
    tileLabels,
    kTestTiles.map((t) => t.label).toList(), // row-major, hard-coded
    reason: 'Tile traversal order changed. This breaks muscle memory for '
            'screen reader AND switch users, who scan in this same order.',
  );
});

// Scope the traversal to just the grid, skipping chrome:
testWidgets('grid traversal is bounded by first and last tile', (tester) async {
  await pumpGrid(tester);

  final ordered = tester.semantics.simulatedAccessibilityTraversal(
    start: find.byKey(const ValueKey('tile_0_0')),
    end:   find.byKey(const ValueKey('tile_3_2')),
  );

  expect(ordered.length, 12, reason: 'expected exactly 12 nodes between first and last tile');
});
```
  Android Switch Access and iOS Switch Control scan in the same platform traversal order the screen reader uses, so this is the ONLY automated signal you can get about switch scanning. Everything else about switches is manual.
  --- Per-tile semantics — with the label/vocalization assertion no guideline can make ---
```dart
// test/a11y/labels_test.dart
testWidgets('every tile is a labeled, enabled button showing the DISPLAY label', (tester) async {
  await pumpGrid(tester);

  for (final tile in kTestTiles) {
    final finder = find.byKey(ValueKey('tile_${tile.row}_${tile.col}'));

    // isSemantics — NOT containsSemantics (deprecated after v3.40.0-1.0.pre).
    expect(
      tester.getSemantics(finder),
      isSemantics(
        label: tile.label,
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        isHidden: false,
      ),
      reason: 'tile "${tile.label}" has wrong semantics',
    );

    // THE CHECK NO GUIDELINE MAKES: the screen reader must announce
    // "Overwhelmed", never the full vocalization sentence.
    final node = tester.getSemantics(finder);
    expect(
      node.label, isNot(contains(tile.vocalization)),
      reason: 'tile "${tile.label}" leaks its vocalization into the semantic '
              'label; a screen reader user would hear the whole sentence while scanning',
    );
  }
});

// Empty grid_slots (button_id IS NULL) must not masquerade as tappable buttons.
testWidgets('empty slots are not announced as buttons', (tester) async {
  await pumpGridWithEmptySlot(tester, row: 2, col: 1);
  final node = tester.getSemantics(find.byKey(const ValueKey('tile_2_1')));
  expect(node, isSemantics(isButton: false, hasTapAction: false));
});
```
  find.bySemanticsLabel('Overwhelmed') also works and reads nicely, but prefer keying off grid position — position IS the primary key in your schema, so ValueKey('tile_r_c') mirrors the data model and a reflow bug would surface as a key/label mismatch.
  --- TextScaler: parameterized, plus the anti-clamping test ---
```dart
// test/a11y/scaling_test.dart
for (final scale in <double>[1.0, 1.3, 2.0, 3.0]) {
  testWidgets('grid is accessible at ${scale}x text scale', (tester) async {
    await pumpGrid(tester, textScaler: TextScaler.linear(scale));

    // No overflow / layout exceptions at any scale.
    expect(tester.takeException(), isNull);

    // Tap targets survive scaling.
    for (final tile in kTestTiles) {
      final size = tester.getSize(find.byKey(ValueKey('tile_${tile.row}_${tile.col}')));
      expect(size.height, greaterThanOrEqualTo(76.0), reason: '"${tile.label}" at ${scale}x');
    }

    // Labels still reachable at every scale.
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}

// THE ANTI-CLAMP TEST: no guideline catches a clamped TextScaler —
// contrast and tap-size both still pass while text stops growing.
testWidgets('text scale is honored, never clamped', (tester) async {
  await pumpGrid(tester, textScaler: TextScaler.noScaling);
  final baseline = tester.getSize(find.text('Overwhelmed')).height;

  await pumpGrid(tester, textScaler: const TextScaler.linear(2.0));
  final scaled = tester.getSize(find.text('Overwhelmed')).height;

  expect(
    scaled, greaterThan(baseline * 1.8),
    reason: 'Text did not actually grow at 2.0x — someone clamped TextScaler '
            'to keep the fixed grid tidy. 200%+ must be honored.',
  );
});

testWidgets('boldText is honored', (tester) async {
  await pumpGrid(tester, boldText: true);
  final style = tester.widget<Text>(find.text('Overwhelmed')).style!;
  expect(style.fontWeight, isNot(FontWeight.w300));
});
```
  The 1.8 factor (not 2.0) tolerates line-height rounding while still failing hard on a clamp. Note textScaleFactor is deprecated framework-wide — always TextScaler.linear, and read via MediaQuery.textScalerOf(context).
  --- Contrast: a deterministic unit test, because textContrastGuideline false-passes ---
```dart
// test/a11y/contrast_test.dart
// flutter#103235 (OPEN): meetsGuideline(textContrastGuideline) PASSES with
// white text on #fafafa. It samples screenshot pixels and mis-picks the
// background in low-variance regions. So compute the ratio ourselves.

double _luminance(Color c) => c.computeLuminance();

double contrastRatio(Color fg, Color bg) {
  final l1 = _luminance(fg), l2 = _luminance(bg);
  final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // AAA (7.0 normal / 4.5 large) — defensible for an app used in distress
  // and in low light. Pure Dart: no screenshots, no sampling, cannot false-pass.
  for (final theme in [aacLightTheme, aacDarkTheme, aacHighContrastTheme]) {
    test('${theme.name}: tile label on tile background meets WCAG AAA', () {
      expect(
        contrastRatio(theme.tileLabelColor, theme.tileBackgroundColor),
        greaterThanOrEqualTo(7.0),
        reason: '${theme.name} tile text contrast is too low',
      );
    });

    test('${theme.name}: show-text mode meets WCAG AAA large text', () {
      expect(
        contrastRatio(theme.showTextColor, theme.showTextBackground),
        greaterThanOrEqualTo(4.5), // large text (>=18px, or >=14px bold)
      );
    });
  }
}

// One line of advisory belt-and-braces in the widget suite:
// await expectLater(tester, meetsGuideline(const MinimumTextContrastGuidelineAAA()));
```
  Flutter's own constants for reference: kMinimumRatioNormalText = 4.5, kMinimumRatioLargeText = 3.0, kLargeTextMinimumSize = 18, kBoldTextMinimumSize = 14, and AAA: kAAAMinimumRatioNormalText = 7.0, kAAAMinimumRatioLargeText = 4.5.
  --- docs/a11y-manual-checklist.md — the actual correctness gate ---
```markdown
# Accessibility release checklist (MANUAL — required before every tag)

Automated tests catch a minority of a11y issues (Deque: 57% even with axe's ~100
web rules; Flutter ships 4 guidelines, one of which is known-broken). Switch
Control / Switch Access have NO automation. There is no telemetry: if this is
wrong in the field, we will never find out. So this pass is the safety net.

Device: __________  OS version: __________  Date: __________  Tester: __________

## TalkBack (Android)
- [ ] Swipe-right through the grid: all 12 tiles reached, row-major, none skipped
- [ ] Each tile announces its DISPLAY label ('Overwhelmed'), NOT the sentence
- [ ] Each tile announces as "button"
- [ ] Double-tap speaks the VOCALIZATION through TTS (audio actually heard)
- [ ] Empty slots are not announced as buttons
- [ ] Type-to-speak field is reachable and exitable
- [ ] Show-text mode: text announced; back-out works
- [ ] Edit mode: reachable, exitable, no focus trap

## VoiceOver (iOS)
- [ ] Same 8 checks as above
- [ ] Personal Voice (if configured) is selectable and speaks

## Switch Access (Android) — NO AUTOMATION EXISTS
- [ ] Every tile reachable by scanning; order matches the traversal test
- [ ] Scan highlight is visible against ALL themes (incl. high contrast)
- [ ] Can exit edit mode using only the switch
- [ ] Can exit the text field using only the switch (no trap)

## Switch Control (iOS) — NO AUTOMATION EXISTS
- [ ] Item scanning reaches all 12 tiles
- [ ] Point scanning can hit every tile
- [ ] Can exit edit mode and text field using only the switch

## Scaling & display
- [ ] System font size at MAX + Display Zoom on: no tile text clipped
- [ ] Bold Text on: layout intact
- [ ] Show-text mode readable at max font size

## Audio (guards the silent-failure class)
- [ ] iOS silent switch ON -> tapping a tile STILL PLAYS AUDIO (.playback, not .ambient)
- [ ] Music playing -> tile speech ducks the music, does not stop it
- [ ] Selected voice uninstalled from system -> app surfaces an error, never silence
- [ ] Airplane mode -> every voice still works (no network_required voice selected)

## Scanners
- [ ] Google Accessibility Scanner run on grid screen (works: reads Flutter's
      AccessibilityBridge virtual nodes) — no new findings
- [ ] Xcode Accessibility Inspector audit on grid screen — no new findings
```
  Ship this file in the repo, not in a wiki. It is the single most valuable a11y artifact for the open-source exit plan: it tells a stranger exactly what 'accessible' means for this app and how to verify it without your devices or your knowledge.

FACT-CHECK:
    - [CONFIRMED] Exact thresholds: androidTapTargetGuideline = Size(48,48); iOSTapTargetGuideline = Size(44,44); contrast 4.5 normal / 3.0 large; large text = 18px or 14px bold; default assumed font size 12.
    - [CONFIRMED] CRITICAL FOR THIS APP: MinimumTapTargetGuideline silently skips every tappable node whose bounds touch the view edge — a full-bleed 3x4 grid would make the tap-target test pass vacuously on the edge tiles.
    - [CONFIRMED] A custom 76dp guideline requires NO subclassing — MinimumTapTargetGuideline's const constructor is public and the class is @visibleForTesting.
    - [CONFIRMED] textContrastGuideline has an open, unfixed false-negative and must not be the contrast gate.
    - [CONFIRMED] BREAKING/CURRENT: containsSemantics is deprecated after v3.40.0-1.0.pre; use isSemantics. matchesSemantics is NOT deprecated.
    - [PARTIALLY_TRUE] "The documented meetsGuideline/ensureSemantics pattern is current and correct on Flutter 3.44."
      CORRECTION: The code snippet is correct and current on Flutter 3.44 — it is the official docs.flutter.dev example verbatim, and nothing in it is deprecated. Correct the RATIONALE, not the code.

WRONG: "ensureSemantics() is required (semantics tree is off by default in tests); handle.dispose() is required."

RIGHT: Semantics is ON by default in widget tests. `testWidgets` takes `bool semanticsEnabled = true`, and when true the framework calls `WidgetTester.ensureSemantics()` for you before the callback and auto-disposes that handle afterward. The manual `ensureSemantics()`/`handle.dispose()` pair in the docs example is a redundant second reference-counted handle — harmless, self-consistent, but optional. This minimal version passes identically:

  testWidgets('a11y', (tester) async {
    await tester.pumpWidget(const App());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

The manual pair is only load-bearing when semantics is NOT already on — i.e. `testWidgets(..., semanticsEnabled: false)`, or in a `test()`/non-testWidgets context. Keeping the docs form is defensible (it matches official docs and is robust to semanticsEnabled: false), but do not enforce it as required or teach the "off by default" reason.

The rest of the claim is accurate and worth keeping: `meetsGuideline` returns `AsyncMatcher`, so `await expectLater(...)` IS mandatory (a plain `expect()` is wrong); `AccessibilityGuideline.evaluate` does return `FutureOr<Evaluation>`; and `textContrastGuideline` genuinely is async — it calls `await layer.toImage(...)` inside `tester.binding.runAsync`, whereas `androidTapTargetGuideline` (the one in the snippet) evaluates synchronously. Note the await requirement comes from the AsyncMatcher return type, not from any individual guideline being async.

Confidence should drop from "high" to "high on the code, corrected on the mechanism."
    - [PARTIALLY_TRUE] "Screen-reader traversal order IS automatable via SemanticsController.simulatedAccessibilityTraversal — and it is the best available proxy for switch-scanning order."
      CORRECTION: Corrected claim: `SemanticsController.simulatedAccessibilityTraversal` is real and current in Flutter 3.44.0, accessed via `tester.semantics`. Use only the non-deprecated signature — `simulatedAccessibilityTraversal({FinderBase<SemanticsNode>? startNode, FinderBase<SemanticsNode>? endNode, FlutterView? view})`; the `start`/`end` FinderBase<Element> params were deprecated after v3.15.0-15.2.pre in favor of `startNode`/`endNode`. `SemanticsNode find(FinderBase<Element> finder)` also exists as claimed.

It automates SEMANTICS traversal order (Flutter's own tree, "as if by assistive technologies"), with a documented caveat that platform edge cases such as the last visible item in a scrollable list may be inconsistent with real platform behavior.

It is NOT a validated proxy for switch-scanning order, and no cited source claims it is:
- Android Switch Access's Point Scan is coordinate-based (no traversal order) and Group Selection is a nested binary narrowing, not a linear order. Only Auto Scan / Step Scanning are linear.
- Switch scanning targets actionable elements; semantics traversal also enumerates non-actionable nodes. Different element sets, not just different sequence.
- It is not the "only" automated signal: `FocusTraversalPolicy`/`FocusTraversalGroup` order, testable via `tester.sendKeyEvent(LogicalKeyboardKey.tab)` (see flutter/flutter's focus_traversal_test.dart), covers actionable-element order and is the closer analogue for switch scanning.

Recommended practice: pin semantics order with `simulatedAccessibilityTraversal(startNode: ..., endNode: ...)` AND pin actionable focus order with Tab-key traversal tests. Treat both as regression guards on ordering intent, not as evidence of switch-access conformance — that still requires manual testing with Switch Access / Switch Control on device. Downgrade confidence from high to low on the switch-scanning portion.

RECOMMENDATIONS:
  - [must] Do NOT rely on meetsGuideline(androidTapTargetGuideline) to enforce the 76dp tiles. Assert tile geometry directly with tester.getSize()/getRect() over all 12 tiles, because the guideline silently skips every tile touching the view edge. — _isAtBoundary skips nodes flush with the view rect. A full-bleed 3x4 grid would check only the 2 interior tiles and pass green. A direct size assertion has no skip logic, no false pass, and gives a better failure message. Keep meetsGuideline as a cheap extra tripwire, not as the gate.
  - [should] Add the custom 76dp guideline as `const aacTapTargetGuideline = MinimumTapTargetGuideline(size: Size(76, 76), link: '<repo docs url>#tap-targets')` in test/, not a hand-rolled subclass. — MinimumTapTargetGuideline's const ctor is public and @visibleForTesting, so this is the sanctioned use and produces no lint. Writing your own subclass duplicates transform/skip logic you'd get wrong. Accept that it inherits the boundary-skip flaw — which is exactly why the direct geometry assertion above is the real gate.
  - [must] Pin the exact screen-reader traversal order of all 12 tiles with tester.semantics.simulatedAccessibilityTraversal() as a hard-coded expected list. — This is the single highest-value a11y test in this project. A 3x4 grid must traverse row-major and predictably; a regression here silently reorders a user's muscle-memory board. It is also the only automated proxy for Switch Access/Switch Control scan order, which is otherwise untestable. With no telemetry, this test is the only thing that will ever tell you the order broke.
  - [must] Assert each tile's semantics with isSemantics(...), not containsSemantics(...). — containsSemantics is deprecated after v3.40.0-1.0.pre and you are on 3.44 stable. isSemantics is the drop-in replacement with identical params. Using the deprecated name in a codebase whose exit plan is open-sourcing hands a stranger a deprecation warning on day one.
  - [must] Assert that each tile's semantic label is the DISPLAY label ('Overwhelmed') and explicitly assert it is NOT the vocalization string. — labeledTapTargetGuideline only checks a label exists and is non-empty. The label!=vocalization split is the heart of this data model, and getting it backwards means a screen-reader user hears a paragraph on every tile while scanning. No automated guideline can catch this; only an explicit per-tile assertion can. Test both directions: label is right AND vocalization is absent from the label.
  - [must] Treat textContrastGuideline as advisory only; enforce contrast with a pure-Dart unit test over your theme's color pairs instead. — flutter#103235 (open) means white-on-#fafafa passes. A tiny unit test computing WCAG contrast ratio from your ThemeData color pairs is deterministic, has no screenshot sampling, runs in milliseconds, and cannot false-pass. For an app used in distress/low-light, target AAA (7.0 normal / 4.5 large) — the ratio math is ~10 lines. Optionally also run meetsGuideline(const MinimumTextContrastGuidelineAAA()) since it's one line, but never let it be the only check.
  - [must] Run the whole a11y suite parameterized over TextScaler.linear(1.0, 1.5, 2.0, 3.0) and boldText true/false, wrapping in MediaQuery rather than mutating platformDispatcher. — TextScaler at 200%+ must be honored and never clamped — a stated correctness property. A for-loop over scale factors turns one test into four with no extra code. MediaQuery wrapping is hermetic; platformDispatcher test values leak across tests unless you addTearDown(clearAllTestValues), which is a footgun for a stranger reading the repo.
  - [should] Add an explicit 'no clamped TextScaler' test: assert that a tile's rendered text height actually grows between 1.0x and 2.0x, and that nothing overflows. — The most likely way to break the 200% promise is a well-meaning MediaQuery override that clamps textScaler to keep the fixed grid tidy. No guideline catches clamping — contrast and tap-size both still pass. Asserting the height genuinely increases catches it. Pair with expecting zero RenderFlex overflow exceptions (tester.takeException()) at 3.0x.
  - [avoid] Skip Espresso AccessibilityChecks and any CI screen-reader automation entirely. — Espresso's ATF reads the Android View hierarchy; Flutter is one FlutterView, so it sees nothing. And flutter#111110 means the virtual node tree isn't even exposed during flutter drive unless an accessibility service is pre-enabled. Building this would consume a large slice of a 2-week MVP and produce near-zero signal. This is the clearest 'skip it' in this dimension.
  - [avoid] Do not add flutter_accessibility_scanner or DCM as dependencies for a11y. — flutter_lints has zero a11y rules, and DCM's four a11y rules (avoid-missing-image-alt, prefer-action-button-tooltip, prefer-text-rich, prefer-dedicated-media-query-method) cover none of this app's actual risks. A commercial linter is also a liability for an open-source exit plan — a stranger can't run your CI. Your per-tile semantics tests already enforce more than these rules would.
  - [must] Write docs/a11y-manual-checklist.md with a dated, device-specific manual pass, and require it before every release tag. — Automated checks catch a minority of issues even with axe's ~100 web rules (Deque: 57% of issues); Flutter's four guidelines catch far less, and Switch Control/Access are 100% manual. With no telemetry you will never learn of a field failure, so the manual pass IS the safety net. Minimum checklist: (1) TalkBack — swipe through all 12 tiles, confirm order + display labels, confirm double-tap speaks the vocalization; (2) VoiceOver same; (3) Android Switch Access — confirm every tile reachable, confirm exit from edit mode and from the text field; (4) iOS Switch Control same, incl. item + point scanning; (5) system font at max — no clipping in tiles or show-text mode; (6) Accessibility Scanner run on the grid screen (it works — it reads AccessibilityBridge virtual nodes); (7) Xcode Accessibility Inspector audit; (8) silent switch ON — confirm audio still plays (guards the .ambient regression).
  - [should] Structure the suite as one shared harness (pumpGrid with seeded 12 tiles) + five test groups: geometry, labels, traversal order, scaling, guidelines. — A stranger picking this up needs the a11y suite to read as an executable spec of the accessibility promise. One helper that pumps a deterministic 12-tile board, then groups named exactly after the properties ('every tile is a labeled button', 'traversal is row-major', 'text scales to 300% without clipping') documents intent better than prose. Zero animation helps here: no pumpAndSettle races, deterministic frames, so these tests will be stable.

---

### DIMENSION: drift-testing
SUMMARY: drift is at 2.34.2 (July 2026) and its migration tooling has consolidated around one command — `dart run drift_dev make-migrations` — driven by a `databases:` block in build.yaml. That command exports schema JSONs, generates `database.steps.dart` (the `stepByStep` helper), AND generates migration tests, replacing the older manual `schema dump` / `schema steps` / `schema generate` triad. Use it; it is the single highest-leverage practice for this dimension. Crucially, drift DOES have first-class data-integrity migration testing, and it is not `migrateAndValidate` — that only checks schema shape. The real mechanism is `verifier.schemaAt(n)` plus `--data-classes --companions`, which generates `DatabaseAtV1`/`DatabaseAtV2` classes so a test can insert real phrase rows at v1, migrate, then read them back at v2 and assert content. For an app where a botched migration is the loss of someone's voice, `migrateAndValidate` alone is insufficient and `schemaAt` is mandatory. The biggest correctness footgun for THIS schema is that SQLite foreign keys are OFF by default and are per-connection — drift does not enable them. Since `grid_slots.button_id` is a nullable FK, `onDelete: KeyAction.setNull` is what makes "delete a button, its slot goes blank but does not reflow" work; with FKs off that silently degrades to a dangling button_id and a blank-or-crashing tile, which is exactly the silent-failure class this project fears. Enable them unconditionally in `beforeOpen` and write a test asserting `PRAGMA foreign_keys` returns 1. Two decisions are v1-only and effectively irreversible-without-pain: DateTime storage mode (`store_date_time_values_as_text`) and committing `drift_schemas/*.json`. On the skip side: DriftIsolate/`computeWithDriftIsolate` is unjustifiable ceremony for 12 tiles — use `drift_flutter`'s `driftDatabase(name:)` one-liner and move on.

FINDINGS:
  - (high, LOAD-BEARING) drift is at 2.34.2 as of July 2026; drift_flutter exists and is at 0.3.1
    drift 2.34.2 published within the last day of research. drift_flutter 0.3.1 is a thin Flutter-only wrapper providing a single `driftDatabase(name: 'app_db')` helper that handles path_provider + platform selection (application documents dir, .sqlite file on native). It exists precisely because core drift is Dart-only and cannot depend on Flutter. Optional `native: DriftNativeOptions(shareAcrossIsolates: true)` for multi-isolate apps.
    sources: https://pub.dev/packages/drift | https://pub.dev/packages/drift_flutter
  - (high, LOAD-BEARING) `make-migrations` is the current recommended workflow and supersedes manually running schema dump/steps/generate
    Requires build.yaml: `targets: $default: builders: drift_dev: options: databases: {my_database: lib/database.dart}, test_dir: test/drift/, schema_dir: drift_schemas/`. Then `dart run drift_dev make-migrations` generates drift_schemas/drift_schema_vX.json, test/drift/ migration tests, and database.steps.dart next to the database class. Docs state plainly: 'Writing migrations manually is error-prone and can lead to data loss.' Workflow: run once for baseline, change schema, bump schemaVersion, run again, implement the generated stepByStep callbacks, run generated tests. `--no-test` disables test generation (do not use it here).
    sources: https://drift.simonbinder.eu/migrations/ | https://drift.simonbinder.eu/migrations/exports/
  - (high, LOAD-BEARING) `migrateAndValidate()` validates SCHEMA SHAPE ONLY — it does not prove the user's data survived
    `verifier.startAt(n)` returns a connection at version n; `verifier.migrateAndValidate(db, target)` runs the migration and asserts the resulting schema matches the exported v-target schema. It says nothing about row contents. A migration that recreates a table correctly but drops every row PASSES migrateAndValidate. For this project that is the difference between a green test suite and a user with an empty board.
    sources: https://drift.simonbinder.eu/migrations/tests/
  - (high, LOAD-BEARING) Data-integrity migration testing DOES exist: `verifier.schemaAt(n)` + `schema generate --data-classes --companions`
    THE mechanism the task asked about. `dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/generated_migrations/` emits schema_v1.dart, schema_v2.dart… each containing a full versioned database class (`DatabaseAtV1`) with era-correct data classes and companions. Test pattern: `final schema = await verifier.schemaAt(1);` then `v1.DatabaseAtV1(schema.newConnection())` to INSERT real rows, close, open the real `AppDatabase(schema.newConnection())`, `migrateAndValidate(db, 2)`, close, then reopen as `v2.DatabaseAtV2(schema.newConnection())` and assert the rows are present AND correct. Note `schemaAt` (not `startAt`) is the entry point — `schema.newConnection()` can be called repeatedly against the same underlying database, which is what lets three different-era database objects see the same bytes.
    sources: https://drift.simonbinder.eu/migrations/tests/
  - (high, LOAD-BEARING) SQLite foreign keys are OFF by default and drift does not turn them on; the setting is per-connection
    `PRAGMA foreign_keys = ON` must be issued on every connection, every open. Drift's `beforeOpen` is the sanctioned place. This is the load-bearing footgun for THIS schema: grid_slots.button_id is a nullable FK whose whole purpose is `onDelete: KeyAction.setNull` (delete a button → its slot blanks, position preserved, no reflow). With FKs off, SQLite silently ignores the action, button_id keeps pointing at a deleted row, and the tile renders blank or throws on join — a silent failure in a no-telemetry app.
    sources: https://drift.simonbinder.eu/migrations/api/ | https://github.com/simolus3/drift/issues/163 | https://nicolaiarocci.com/sqlite-foreign-key-constraints-are-disabled-by-default/
  - (medium, LOAD-BEARING) The official docs' own beforeOpen example is a trap: it shows the FK pragma inside an `if (details.wasCreated)` guard
    The migrations overview page renders `beforeOpen: (details) async { if (details.wasCreated) { await customStatement('PRAGMA foreign_keys = ON'); } }`. The `wasCreated` guard is correct for SEEDING data but wrong for a per-connection pragma — copied verbatim, FKs would be enforced only on the very first app launch and off forever after. Put the pragma unconditionally in beforeOpen; put seeding inside the wasCreated guard.
    sources: https://drift.simonbinder.eu/docs/migrations/ | https://drift.simonbinder.eu/migrations/api/
  - (high, LOAD-BEARING) `PRAGMA foreign_keys` is a silent no-op inside a transaction, so FK-disabling during migration must happen outside it
    SQLite: 'foreign key constraint enforcement may only be enabled or disabled when there is no pending BEGIN or SAVEPOINT.' It does not error — it does nothing. Drift docs' pattern: `await customStatement('PRAGMA foreign_keys = OFF'); await transaction(() async { /* migration */ }); await customStatement('PRAGMA foreign_keys = ON');`. This matters because `alterTable`/TableMigration works by create-copy-drop-rename, which FK enforcement would reject mid-flight. Docs recommend `PRAGMA foreign_key_check` after the migration to assert nothing was corrupted while enforcement was off.
    sources: https://drift.simonbinder.eu/migrations/api/ | https://sqlite.org/forum/info/fd0b2d53bafc73f888069b3a0a3b15f35982c7e3fa910983b47db3e39ccabe18
  - (high, LOAD-BEARING) `stepByStep` / `Migrator.runMigrationSteps` API verified
    Two forms. Terse: `onUpgrade: stepByStep(from1To2: (m, schema) async { await m.addColumn(schema.users, schema.users.birthdate); })`. Controllable: `onUpgrade: (m, from, to) async { ...pragma off...; await m.runMigrationSteps(from: from, to: to, steps: migrationSteps(from1To2: ...)); ...pragma on...; }`. Both from `database.steps.dart`. The second form is required for this project because of the FK-pragma bracket. Each callback receives a `schema` object frozen at that version, so migrations keep compiling even after tables are later deleted — this is why stepByStep beats hand-written onUpgrade for a project that must survive abandonment.
    sources: https://drift.simonbinder.eu/migrations/step_by_step/
  - (high) TableMigration/alterTable handles what SQLite's ALTER TABLE cannot, via columnTransformer and newColumns
    `m.alterTable(TableMigration(schema.todos, columnTransformer: {schema.t.col: <SQL expression>}, newColumns: [schema.t.newCol]))`. columnTransformer maps a column to an expression evaluated against the OLD table during the copy (e.g. `schema.todos.category.cast<int>()`); newColumns declares non-nullable columns with no default that need a value for existing rows (`Constant('value for existing rows')`). Simple cases have direct APIs: `m.addColumn`, `m.createTable`, `m.deleteTable('users')`, `m.renameColumn(schema.t, 'old_name', schema.t.newCol)`.
    sources: https://drift.simonbinder.eu/migrations/api/
  - (high, LOAD-BEARING) DateTime storage mode is a v1-only decision; changing it later is a real data migration
    drift stores DateTime as unix timestamps by default; `store_date_time_values_as_text: true` in build.yaml switches to ISO-8601 text. Docs: toggling it 'is not compatible with existing database schemas' and requires a dedicated migration method + schemaVersion bump. There is even a recent drift_dev bugfix for schema exports ignoring this flag when Dart tables have default constraints — i.e. this option has had tooling sharp edges. Decide at v1 and never touch it.
    sources: https://drift.simonbinder.eu/guides/datetime-migrations/ | https://pub.dev/packages/drift_dev/changelog
  - (high, LOAD-BEARING) In-memory test idiom requires `closeStreamsSynchronously: true` for widget tests
    `AppDatabase(DatabaseConnection(NativeDatabase.memory(logStatements: true), closeStreamsSynchronously: true))` in setUp, `tearDown(() => database.close())`. Docs: 'By default, unsubscribing from a query stream created by drift will keep the stream open for one event loop iteration' — which trips widget tests with pending-timer errors. Stream testing: `expectLater(db.watchX(id).map(...), emitsInOrder(['first', 'changed']))` assigned to a variable BEFORE the mutating call, awaited after. Requires the database constructor to take an explicit QueryExecutor (`AppDatabase(super.e)`) rather than hardcoding one.
    sources: https://drift.simonbinder.eu/testing/
  - (medium, LOAD-BEARING) Opening the real AppDatabase in tests (not a bare connection) is what makes beforeOpen — and therefore FK enforcement — apply in tests
    beforeOpen is part of MigrationStrategy and runs on every open including NativeDatabase.memory(). So constructing the real AppDatabase in tests means tests run with the same FK enforcement as production. Testing against a hand-built raw connection would silently skip it and let FK-violating tests pass. This is a small architectural point with outsized value for a no-telemetry app.
    sources: https://drift.simonbinder.eu/testing/ | https://drift.simonbinder.eu/migrations/api/
  - (medium) `validateDatabaseSchema()` exists for runtime schema checking but importing it into lib/ promotes drift_dev to a real dependency
    Docs show `beforeOpen: (details) async { if (kDebugMode) await validateDatabaseSchema(); }` with `import 'package:drift_dev/api/migrations_native.dart'`. It catches the classic 'I edited tables but forgot to bump schemaVersion' bug. But drift_dev belongs in dev_dependencies; importing it from lib/ (even under kDebugMode, which is a runtime not compile-time guard) makes it a shipped dependency. Prefer asserting this in a test instead.
    sources: https://drift.simonbinder.eu/migrations/tests/
  - (high, LOAD-BEARING) Background isolates are explicitly not warranted at this scale
    `NativeDatabase.createInBackground(file)` is the drop-in DriftIsolate wrapper. But drift's own docs say the tradeoff is real: 'the overall database is going to be slightly slower due to overhead involved in sending data between isolates, and if you're not running into dropped frames because of drift, using a background isolate is probably not necessary.' 12 tiles + a settings row will never drop a frame. Additionally `shareAcrossIsolates: true` is unnecessary here specifically because the Android QS TileService speaks from SharedPreferences with no Flutter engine — it never touches the DB, so there is no second isolate contending for it.
    sources: https://drift.simonbinder.eu/isolates/ | https://pub.dev/packages/drift_flutter
  - (medium, LOAD-BEARING) Storing absolute file paths for images/sounds breaks on iOS reinstall and restore
    The decision to keep images/sounds as files on disk with paths in the DB is right, but the iOS app container directory carries a UUID that changes across reinstall and device restore. An absolute path persisted in v1 becomes a dead path later — a tile with a missing image, silently. Store paths RELATIVE to the application documents directory and resolve against path_provider at read time. Not drift-specific, but it is a data-model decision that drift will faithfully persist forever.
    sources: https://pub.dev/packages/drift_flutter
  - (medium) `row` is a SQLite keyword; naming grid_slots columns `row`/`col` bare invites escaping trouble
    Drift derives snake_case SQL column names from getter names and escapes known keywords, but ROW is a SQLite keyword (FOR EACH ROW) and this column sits in the composite PRIMARY KEY that the entire no-reflow guarantee rests on. The cost of naming them row_index/col_index is zero; the cost of being wrong is a schema you cannot cleanly migrate. Use `late final rowIndex = integer().named('row_index')()`.
    sources: https://drift.simonbinder.eu/dart_api/tables/
  - (high, LOAD-BEARING) `autoIncrement()` implies PRIMARY KEY and cannot be combined with a `primaryKey` override
    Composite PK is expressed as `@override Set<Column> get primaryKey => {boardId, rowIndex, colIndex};` — so GridSlots must NOT have an autoIncrement id. This is exactly what the project wants (position IS the key) but it is a compile-time conflict people hit when they add a surrogate id 'just in case'. Adding one later would destroy the structural no-reflow guarantee.
    sources: https://drift.simonbinder.eu/dart_api/tables/
  - (medium) Class-based Dart table definitions are the right style here over .drift files
    Drift supports Dart classes, .drift SQL files, and mixes. Schema export, make-migrations, stepByStep and SchemaVerifier all work with either. Dart classes win on the project's own stated criterion — readable by a stranger — because a Flutter dev picking this up in 2028 reads Dart fluently and may never have seen drift's SQL dialect. `references(Buttons, #id, onDelete: KeyAction.setNull)` is also more self-documenting than a raw FK clause.
    sources: https://drift.simonbinder.eu/dart_api/tables/

CODE EXAMPLES:
  --- build.yaml — enables make-migrations (do this first) ---
```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/data/database.dart
          test_dir: test/drift/
          schema_dir: drift_schemas/
          # DateTime storage: decide at v1, never change.
          # Omitted = unix timestamps (the default). Correct for this app.
```
  Then: `dart run drift_dev make-migrations`. Commit drift_schemas/ — the v1 JSON can never be regenerated once you bump to v2.
  --- Table definitions matching this project's schema ---
```dart
import 'package:drift/drift.dart';

part 'database.g.dart';

class Boards extends Table {
  late final id = integer().autoIncrement()();
  late final name = text().withLength(min: 1, max: 100)();
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
}

/// Open Board Format semantics: `label` is what the tile SHOWS,
/// `vocalization` is what it SPEAKS. They are deliberately different.
/// Tile shows "Overwhelmed"; TTS says "I need to leave, I'm not able
/// to talk right now." If vocalization is null, speak the label.
class Buttons extends Table {
  late final id = integer().autoIncrement()();
  late final label = text().withLength(min: 1, max: 200)();
  late final vocalization = text().nullable()();
  late final imageId =
      integer().nullable().references(Images, #id, onDelete: KeyAction.setNull)();
  late final soundId =
      integer().nullable().references(Sounds, #id, onDelete: KeyAction.setNull)();
  late final backgroundColor = integer().nullable()();
}

/// Position IS identity. The composite primary key makes it structurally
/// impossible for a tile to move: there is no row identity independent of
/// (board, row, col), so nothing can reflow.
///
/// button_id is NULLABLE + ON DELETE SET NULL: deleting a button empties
/// its slot and leaves every other slot untouched.
/// NOTE: this depends entirely on PRAGMA foreign_keys = ON. See beforeOpen.
class GridSlots extends Table {
  late final boardId =
      integer().references(Boards, #id, onDelete: KeyAction.cascade)();
  // Named explicitly: `row` is a SQLite keyword and these columns are the PK.
  late final rowIndex = integer().named('row_index')();
  late final colIndex = integer().named('col_index')();
  late final buttonId =
      integer().nullable().references(Buttons, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column> get primaryKey => {boardId, rowIndex, colIndex};

  // Fixed 3x4 grid, enforced by the database rather than by discipline.
  @override
  List<String> get customConstraints => [
        'CHECK (row_index >= 0 AND row_index < 4)',
        'CHECK (col_index >= 0 AND col_index < 3)',
      ];
}

/// Files on disk, paths in the DB, never BLOBs.
/// Paths are RELATIVE to the application documents directory: the iOS
/// container UUID changes on reinstall/restore, so an absolute path
/// silently rots into a missing image.
class Images extends Table {
  late final id = integer().autoIncrement()();
  late final relativePath = text()();
  late final contentType = text().nullable()();
}

class Sounds extends Table {
  late final id = integer().autoIncrement()();
  late final relativePath = text()();
  late final durationMs = integer().nullable()();
}

/// Single-row settings table; CHECK pins it to exactly one row.
class AppSettings extends Table {
  late final id = integer().withDefault(const Constant(0))();
  late final voiceId = text().nullable()();
  late final pitch = real().withDefault(const Constant(1.0))();
  late final rate = real().withDefault(const Constant(0.5))();
  late final outputMode = text().withDefault(const Constant('speaker'))();
  late final themeMode = text().withDefault(const Constant('system'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 0)'];
}
```
  GridSlots deliberately has no autoIncrement id — autoIncrement implies PRIMARY KEY and will not compile alongside the primaryKey override. That compile error is the architecture defending itself.
  --- Database class — migration strategy with the FK pragma bracket ---
```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database.steps.dart'; // generated by make-migrations

@DriftDatabase(
  tables: [Boards, Buttons, GridSlots, Images, Sounds, AppSettings],
)
class AppDatabase extends _$AppDatabase {
  /// Explicit executor: this is what makes the DB testable in memory
  /// AND what lets tests run the real MigrationStrategy (and therefore
  /// the real FK enforcement).
  AppDatabase(super.e);

  /// Production. No isolate: 12 tiles will never drop a frame, and drift's
  /// own docs advise against isolates when you aren't janking.
  AppDatabase.defaults() : super(driftDatabase(name: 'aac'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // MUST be outside any transaction: PRAGMA foreign_keys is a silent
          // no-op while a BEGIN/SAVEPOINT is pending. TableMigration works by
          // create-copy-drop-rename, which live FK enforcement would reject.
          await customStatement('PRAGMA foreign_keys = OFF');

          await transaction(() async {
            await m.runMigrationSteps(
              from: from,
              to: to,
              steps: migrationSteps(
                // from1To2: (m, schema) async {
                //   await m.addColumn(schema.buttons, schema.buttons.someCol);
                // },
              ),
            );
          });

          // Prove we didn't corrupt referential integrity while FKs were off.
          // A dangling board_id here is a lost board.
          final violations =
              await customSelect('PRAGMA foreign_key_check').get();
          if (violations.isNotEmpty) {
            throw StateError(
              'Migration $from->$to left FK violations: '
              '${violations.map((r) => r.data).toList()}',
            );
          }

          await customStatement('PRAGMA foreign_keys = ON');
        },
        beforeOpen: (details) async {
          // UNCONDITIONAL. Not inside `if (details.wasCreated)`.
          // FKs are off by default and the setting is PER-CONNECTION, so this
          // must run on every single open. The docs' own example puts this
          // inside a wasCreated guard, which would enforce FKs only on the
          // first-ever launch — and then never again.
          await customStatement('PRAGMA foreign_keys = ON');

          if (details.wasCreated) {
            await _seedDefaultBoard(); // seeding IS correctly wasCreated-gated
          }
        },
      );

  Future<void> _seedDefaultBoard() async {
    final boardId =
        await into(boards).insert(BoardsCompanion.insert(name: 'Home'));
    // Materialize all 12 slots up front, empty. Slots always exist;
    // only their button_id changes. Nothing is ever inserted or deleted
    // at runtime, so nothing can reflow.
    await batch((b) {
      for (var r = 0; r < 4; r++) {
        for (var c = 0; c < 3; c++) {
          b.insert(
            gridSlots,
            GridSlotsCompanion.insert(boardId: boardId, rowIndex: r, colIndex: c),
          );
        }
      }
    });
  }

  Stream<List<GridSlot>> watchSlots(int boardId) {
    return (select(gridSlots)
          ..where((s) => s.boardId.equals(boardId))
          ..orderBy([
            (s) => OrderingTerm(expression: s.rowIndex),
            (s) => OrderingTerm(expression: s.colIndex),
          ]))
        .watch();
  }
}
```
  The pragma bracket is the single most important block in this file. Both halves are load-bearing: OFF-outside-transaction because the pragma is otherwise a silent no-op, and ON-unconditionally-in-beforeOpen because it is per-connection.
  --- Migration test — DATA integrity, not just schema shape (the one that matters) ---
```dart
// test/migration_test.dart
//
// Generate the fixtures with:
//   dart run drift_dev schema generate --data-classes --companions \
//       drift_schemas/ test/drift/generated/
// (make-migrations does this for you.)

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';

import 'package:offline_aac/data/database.dart';

import 'drift/generated/schema.dart';
import 'drift/generated/schema_v1.dart' as v1;
import 'drift/generated/schema_v2.dart' as v2;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  // Schema-shape check for every hop. Necessary but NOT sufficient:
  // a migration that rebuilds the table perfectly and copies zero rows
  // passes this test.
  group('schema shape', () {
    for (final (from, to) in const [(1, 2)]) {
      test('migrates v$from -> v$to', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, to);
        await db.close();
      });
    }
  });

  // THE test. A botched migration here is the loss of someone's voice,
  // and with no telemetry this assertion is the only thing that will
  // ever tell us it broke.
  test('v1 -> v2 preserves hand-curated phrases and their positions', () async {
    final schema = await verifier.schemaAt(1);

    // --- Write real user data using v1-era classes ---
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    final boardId = await oldDb.into(oldDb.boards).insert(
          v1.BoardsCompanion.insert(name: 'Home'),
        );
    final buttonId = await oldDb.into(oldDb.buttons).insert(
          v1.ButtonsCompanion.insert(
            label: 'Overwhelmed',
            vocalization: const Value(
              "I need to leave, I'm not able to talk right now",
            ),
          ),
        );
    await oldDb.into(oldDb.gridSlots).insert(
          v1.GridSlotsCompanion.insert(
            boardId: boardId,
            rowIndex: 2,
            colIndex: 1,
            buttonId: Value(buttonId),
          ),
        );
    await oldDb.close();

    // --- Run the real migration against that data ---
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    await db.close();

    // --- Read it back with v2-era classes and assert it's still CORRECT ---
    final migrated = v2.DatabaseAtV2(schema.newConnection());

    final button = await migrated.select(migrated.buttons).getSingle();
    expect(button.label, 'Overwhelmed');
    expect(
      button.vocalization,
      "I need to leave, I'm not able to talk right now",
      reason: 'The vocalization is the whole point. Losing it is losing speech.',
    );

    final slot = await migrated.select(migrated.gridSlots).getSingle();
    expect(slot.rowIndex, 2, reason: 'A tile that moved is a tile mis-tapped.');
    expect(slot.colIndex, 1);
    expect(slot.buttonId, buttonId);

    await migrated.close();
  });
}
```
  `schemaAt(n)` (not `startAt`) is the entry point for data tests: `schema.newConnection()` can be called repeatedly against the same underlying bytes, which is what lets the v1 writer, the real AppDatabase, and the v2 reader all see the same database.
  --- Query tests — including the invariants that encode the architecture ---
```dart
// test/database_test.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import 'package:test/test.dart';

import 'package:offline_aac/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // The REAL AppDatabase, so beforeOpen (and thus FK enforcement) applies.
    // A bare connection here would silently skip it and let FK bugs pass green.
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true, // avoids pending-timer test failures
      ),
    );
  });

  tearDown(() => db.close());

  test('foreign keys are actually enforced', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(
      row.data.values.first,
      1,
      reason: 'FKs off => ON DELETE SET NULL silently does nothing => '
          'grid_slots.button_id dangles => blank tile, no error, no telemetry.',
    );
  });

  test('seeds exactly 12 empty slots', () async {
    final slots = await db.select(db.gridSlots).get();
    expect(slots, hasLength(12));
    expect(slots.every((s) => s.buttonId == null), isTrue);
  });

  test('a slot cannot be occupied twice — reflow is structurally impossible',
      () async {
    // The 12 slots already exist from seeding; re-inserting (0,0) must fail
    // on the composite primary key.
    await expectLater(
      db.into(db.gridSlots).insert(
            GridSlotsCompanion.insert(boardId: 1, rowIndex: 0, colIndex: 0),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('the 3x4 grid bounds are enforced by the database', () async {
    await expectLater(
      db.into(db.gridSlots).insert(
            GridSlotsCompanion.insert(boardId: 1, rowIndex: 9, colIndex: 9),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a button empties its slot without moving any other tile',
      () async {
    final buttonId = await db.into(db.buttons).insert(
          ButtonsCompanion.insert(
            label: 'Overwhelmed',
            vocalization: const Value("I need to leave"),
          ),
        );
    await (db.update(db.gridSlots)
          ..where((s) => s.rowIndex.equals(2) & s.colIndex.equals(1)))
        .write(GridSlotsCompanion(buttonId: Value(buttonId)));

    await (db.delete(db.buttons)..where((b) => b.id.equals(buttonId))).go();

    final slots = await db.select(db.gridSlots).get();
    expect(slots, hasLength(12), reason: 'The slot must survive its button.');

    final emptied =
        slots.firstWhere((s) => s.rowIndex == 2 && s.colIndex == 1);
    expect(
      emptied.buttonId,
      isNull,
      reason: 'This is ON DELETE SET NULL working. If FKs were off, this '
          'would still be $buttonId — a dangling id pointing at nothing.',
    );
  });

  test('watchSlots emits after an edit', () async {
    final buttonId = await db.into(db.buttons).insert(
          ButtonsCompanion.insert(label: 'Yes'),
        );

    // Set up the expectation BEFORE the mutation, await it after.
    final expectation = expectLater(
      db.watchSlots(1).map(
            (slots) => slots.where((s) => s.buttonId != null).length,
          ),
      emitsInOrder([0, 1]),
    );

    await (db.update(db.gridSlots)
          ..where((s) => s.rowIndex.equals(0) & s.colIndex.equals(0)))
        .write(GridSlotsCompanion(buttonId: Value(buttonId)));

    await expectation;
  });
}
```
  The FK-enforcement test and the delete-button test are a pair: the second one is the behavioural consequence, the first tells you WHY it broke when it does. Both are cheap and both guard a silent failure.

FACT-CHECK:
    - [CONFIRMED] drift is at 2.34.2 as of July 2026; drift_flutter exists and is at 0.3.1
    - [CONFIRMED] `make-migrations` is the current recommended workflow and supersedes manually running schema dump/steps/generate
    - [CONFIRMED] `migrateAndValidate()` validates SCHEMA SHAPE ONLY — it does not prove the user's data survived
    - [CONFIRMED] Data-integrity migration testing DOES exist: `verifier.schemaAt(n)` + `schema generate --data-classes --companions`
    - [CONFIRMED] SQLite foreign keys are OFF by default and drift does not turn them on; the setting is per-connection
    - [REFUTED] "The official docs' own beforeOpen example is a trap: it shows the FK pragma inside an `if (details.wasCreated)` guard"
      CORRECTION: The docs do NOT show the pragma inside the wasCreated guard — they show it OUTSIDE/after the guard (overview page) or with no guard at all (migrator API page), i.e. unconditional per-connection, which is the correct behavior. The migrator API page additionally states outright: "always re-enable foreign keys before using the database, by enabling them in beforeOpen." The claim's prescription (unconditional pragma; seeding inside the wasCreated guard) is correct engineering advice, but it is already the official documented pattern rather than a correction to it. Copying the official example verbatim produces correctly-enforced FKs on every launch, not FKs enforced only on first launch. No project decision should rest on the premise that the drift docs contain this trap.
    - [PARTIALLY_TRUE] "`PRAGMA foreign_keys` is a silent no-op inside a transaction, so FK-disabling during migration must happen outside it"
      CORRECTION: The core claim is correct and the project decision that depends on it (disable FKs outside the transaction) is safe. Two corrections. (1) Replace the second source: the cited SQLite forum post is about connection-level FK enforcement and `.dump` output, not transactions — it does not substantiate the claim. Cite https://sqlite.org/pragma.html#pragma_foreign_keys, which contains the quoted sentence verbatim. (2) The code pattern is wrong as written. Drift's documented pattern is: `PRAGMA foreign_keys = OFF` in `onUpgrade` before the transaction, migration logic inside `transaction(() async {...})`, `PRAGMA foreign_key_check` via `customSelect` in debug mode, and then `PRAGMA foreign_keys = ON` in the `beforeOpen` callback of `MigrationStrategy` — NOT inline after the transaction. `beforeOpen` runs on every open whether or not a migration ran, so it is what actually guarantees enforcement is restored for normal sessions; the inline version only fires on the migration path. Also, drift does not wrap migrations in a transaction automatically — the docs present the `transaction` wrapper as the developer's choice. Verified against drift 2.34.2 (current, actively maintained, verified publisher simonbinder.eu, not discontinued).

RECOMMENDATIONS:
  - [must] Adopt `dart run drift_dev make-migrations` from commit #1, before there is any user data to lose. Add the `databases:`/`test_dir:`/`schema_dir:` block to build.yaml now. — It generates schema exports, the stepByStep helper, AND migration tests in one command. Retrofitting it after v1 ships means reconstructing a v1 schema JSON from memory — drift's own docs call manual migrations 'error-prone and can lead to data loss'. This is a two-minute setup that buys the entire safety net.
  - [must] Commit `drift_schemas/*.json` to git. They are not regenerable from current source — they encode history. — `schema dump` reads the CURRENT database.dart. Once you have bumped to v2, the v1 JSON can never be regenerated from source; it exists only in git. Losing drift_schema_v1.json means you can no longer test the v1→v2 migration, which is the migration that real users on the App Store will actually run.
  - [must] Enable `PRAGMA foreign_keys = ON` unconditionally in `beforeOpen`, NOT inside an `if (details.wasCreated)` guard, and assert it with a test. — FKs are off by default and per-connection. The docs' own example shows the pragma inside a wasCreated guard, which would enforce FKs only on first launch. Without FKs, `onDelete: KeyAction.setNull` on grid_slots.button_id silently does nothing and deleted buttons leave dangling ids — a blank tile with no error, in an app with no telemetry to report it.
  - [must] Test that DATA survives every migration using `verifier.schemaAt(n)` + `--data-classes --companions`, not just `migrateAndValidate`. — migrateAndValidate checks schema shape only. A migration that rebuilds grid_slots perfectly but copies zero rows passes it. Given that hand-curated boards are irreplaceable and unmergeable, the assertion that must be green is 'the phrase text is still there and still correct', which only the schemaAt + versioned-data-class pattern can express.
  - [must] Bracket `runMigrationSteps` with `PRAGMA foreign_keys = OFF` OUTSIDE any transaction, and run `PRAGMA foreign_key_check` afterwards, throwing if it returns rows. — The pragma is a silent no-op inside a transaction, so a naive placement fails invisibly. TableMigration works by create-copy-drop-rename, which live FK enforcement rejects. foreign_key_check is the only thing that proves you did not corrupt referential integrity while enforcement was off — and in this app a broken board_id link is a lost board.
  - [must] Decide DateTime storage mode (`store_date_time_values_as_text`) at v1 and never change it. — Drift docs state toggling it is incompatible with existing schemas and requires a dedicated data migration plus version bump. It is a free decision today and an expensive, data-touching one after ship. Given the app barely needs timestamps at all, pick the default (unix) and stop thinking about it.
  - [must] Give AppDatabase an explicit QueryExecutor constructor (`AppDatabase(super.e)`) and construct the REAL AppDatabase in tests over `NativeDatabase.memory()` with `closeStreamsSynchronously: true`. — Tests must exercise the real MigrationStrategy so beforeOpen — and therefore FK enforcement — applies. Testing against a bare connection would skip beforeOpen and let FK-violating code pass green. closeStreamsSynchronously avoids pending-timer failures in widget tests.
  - [must] Write the three invariant tests that encode this project's architecture: (a) PRAGMA foreign_keys == 1, (b) two buttons cannot occupy one slot, (c) deleting a button nulls its slot without moving any other slot. — These are not hygiene tests, they are the executable statement of 'tile reflow is structurally impossible'. Test (c) in particular fails loudly if FKs are ever off — it converts the worst silent failure in the schema into a red test. With no telemetry, a test is the only thing that will ever tell you.
  - [should] Use `drift_flutter`'s `driftDatabase(name: 'aac')` to open the DB. Skip DriftIsolate, computeWithDriftIsolate, and shareAcrossIsolates entirely. — Drift's own docs say a background isolate is unnecessary if you are not dropping frames because of the DB, and 12 tiles will never drop a frame. shareAcrossIsolates is specifically moot here because the Android QS TileService speaks from SharedPreferences with no Flutter engine and never opens the database. This is ceremony a solo dev on a 2-week MVP should decline.
  - [must] Store image/sound paths RELATIVE to the application documents directory; resolve against path_provider at read time. — The iOS app container UUID changes on reinstall and on device restore, so an absolute path persisted today is a dead path after a user restores their phone. That surfaces as a tile whose image silently vanished — and unlike a crash, nothing about it is recoverable or even noticeable to the developer.
  - [should] Name the grid_slots position columns `row_index`/`col_index`, not `row`/`col`. — ROW is a SQLite keyword, and these columns are the composite PRIMARY KEY the entire no-reflow guarantee rests on. Zero cost to rename now; renaming a PK column later is a TableMigration against live user data.
  - [should] Commit the generated `.g.dart` / `.steps.dart` files rather than gitignoring them. — Standard Dart convention gitignores generated code, but this project's exit plan is abandonment plus open-source. In 2029, `dart run build_runner build` against a stale pubspec may simply not resolve. Committed generated files mean a stranger can clone and build with no codegen step at all. The usual argument against (merge conflicts on a team) does not apply to a solo dev.
  - [should] Put `validateDatabaseSchema()` in a test, not in `beforeOpen` behind kDebugMode. — It catches the 'edited tables, forgot to bump schemaVersion' bug, which is worth catching. But it lives in package:drift_dev, and importing it from lib/ promotes a dev_dependency into a shipped dependency — kDebugMode is a runtime guard, not a compile-time one. A test gets the same signal with none of the dependency creep.
  - [should] Use class-based Dart table definitions; do not introduce .drift SQL files. — All migration tooling works with either, so pick on the project's own criterion: readable by a stranger. A Flutter dev inheriting this reads Dart; they may never have seen drift's SQL dialect. `references(Buttons, #id, onDelete: KeyAction.setNull)` documents the no-reflow intent better than a raw FK clause.
  - [avoid] Do not add a surrogate autoIncrement id to GridSlots. — autoIncrement() implies PRIMARY KEY and cannot coexist with the composite primaryKey override — so it will not even compile. But the deeper reason is that a surrogate key would permit two rows at the same (board_id, row, col), destroying the structural guarantee that position IS identity. The compile error is the architecture defending itself; do not work around it.
  - [avoid] Do not hand-write `onUpgrade` with `if (from < 2)` chains, even though the docs still show that style. — The docs show it, and it works, but each branch references CURRENT table definitions — so deleting a table in v4 breaks the v1→v2 branch's compilation, and developers 'fix' that by editing history, which silently changes what old users' migrations do. stepByStep hands each callback a schema frozen at that version, making old migrations immutable. That property matters most precisely when the developer has stopped paying attention.

---

### DIMENSION: platform-channel-testing
SUMMARY: The current mocking API is confirmed: `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler)` — but it throws "Binding has not yet been initialized" unless you call `TestWidgetsFlutterBinding.ensureInitialized()` first in a plain `test()`. I hit this by running the code, not reading docs. My strong recommendation: do NOT mock flutter_tts's channel across your suite. Fake the existing `SpeechService` instead; channel-level tests earn their keep in exactly one file — a contract test pinning the "returns 0, never throws" behavior. I verified that premise verbatim in the plugin's Kotlin (`result.success(0)` after a `Log.d`), and found three things the brief did not anticipate, all of which I confirmed in source: `network_required` is the STRING `"1"`/`"0"` (a naive truthiness check silently inverts the safety property), `features` is TAB-separated, and iOS omits `network_required` entirely. Worse, Android's `notInstalled` feature flag means `setVoice` returns **1 (success)** while synthesis reports ERROR_NOT_INSTALLED_YET *or substitutes a different voice* — so checking the return value alone does NOT make silence impossible. Two of your three "native surfaces" (QS tile, ControlWidget) have no Dart→native channel at all, so Pigeon buys you almost nothing; I'd skip it for the MVP. Audio output cannot be asserted in any automated test, and the Android emulator ships no TTS engine — so CI can never verify speech, which makes a short manual device checklist a load-bearing artifact, not a nicety. I wrote and ran 21 passing tests; all code below is verified, not sketched.

FINDINGS:
  - (high, LOAD-BEARING) The current channel-mocking API is TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler), and the old MethodChannel.setMockMethodCallHandler was moved out of package:flutter into package:flutter_test.
    Flutter's official breaking-change doc (last updated 2026-05-05) confirms BinaryMessenger.setMockMessageHandler, BasicMessageChannel.setMockMessageHandler, MethodChannel.setMockMethodCallHandler and checkMockMethodCallHandler all moved to flutter_test. Migration: `myMethodChannel.setMockMethodCallHandler(...)` -> `tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(myMethodChannel, ...)`. Outside testWidgets, use TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger. The TestMethodChannelExtension.setMockMethodCallHandler variant is itself now deprecated. Verified working on Flutter 3.41.2 locally.
    sources: https://docs.flutter.dev/release/breaking-changes/mock-platform-channels | https://api.flutter.dev/flutter/flutter_test/TestDefaultBinaryMessenger/setMockMethodCallHandler.html
  - (high, LOAD-BEARING) Calling TestDefaultBinaryMessengerBinding.instance at group() body scope fails at load time; you must call TestWidgetsFlutterBinding.ensureInitialized() first in a plain test().
    Discovered by running, not reading. Error: 'Binding has not yet been initialized. The "instance" getter on the TestDefaultBinaryMessengerBinding binding mixin is only available once that binding has been initialized.' testWidgets() initializes the binding for you; plain test() does not. Fix: TestWidgetsFlutterBinding.ensureInitialized() as the first line of main(). Most blog snippets omit this and fail to load.
    sources: Verified locally: flutter test on Flutter 3.41.2
  - (high, LOAD-BEARING) flutter_tts's Android setVoice returns success(0) after only a Log.d when the voice is not found — it never throws. The project's premise is confirmed verbatim.
    android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt:514-526. On match: `tts!!.voice = ttsVoice; result.success(1)`. On no match: `Log.d(tag, "Voice name not found: $voice"); result.success(0)`. Because it is result.success (not result.error), Dart's `await _channel.invokeMethod('setVoice', voice)` returns 0 and raises nothing. Note the Android package was renamed from com.tundralabs.fluttertts to com.eyedeadevelopment.fluttertts — stale docs/paths will 404.
    sources: https://github.com/dlutton/flutter_tts (android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt)
  - (high, LOAD-BEARING) Android's `notInstalled` voice feature defeats a setVoice-return-value check: setVoice returns 1 (success) and synthesis still fails or silently substitutes a DIFFERENT voice.
    Android SDK 35 source, TextToSpeech.java:678, KEY_FEATURE_NOT_INSTALLED = "notInstalled". Doc comment: 'the voice may need to download additional data to be fully functional... Until download is complete, each synthesis request will either report ERROR_NOT_INSTALLED_YET error, or use a different voice to synthesize the request.' Because such a voice IS present in tts.voices, flutter_tts's setVoice loop matches it and returns 1. So the brief's stated mitigation (check the setVoice return value) is necessary but NOT sufficient. The voice_filter must also exclude features.contains('notInstalled'). This is a silent-failure path the brief did not anticipate.
    sources: Android SDK android-35 sources: android/speech/tts/TextToSpeech.java:678
  - (high, LOAD-BEARING) Android sends network_required as the STRING "1"/"0", features as a TAB-separated string; iOS omits network_required entirely. A naive truthiness or bool check silently inverts the safety property.
    FlutterTtsPlugin.kt readVoiceProperties (:618-626): map["network_required"] = if (voice.isNetworkConnectionRequired) "1" else "0"; map["features"] = voice.features.joinToString(separator = "\t"). Note "0" is a non-empty String and thus survives a null/empty check; and `raw['network_required'] == true` is ALWAYS false since it is a String. iOS (SwiftFlutterTtsPlugin.getVoices :337-357) emits only name/locale/quality/gender/identifier — no network_required — so the parser must treat a missing key as not-network-required. Confirmed KEY_FEATURE_NETWORK_SYNTHESIS = "networkTts" (TextToSpeech.java:636) and Voice.isNetworkConnectionRequired() exist.
    sources: https://github.com/dlutton/flutter_tts | https://developer.android.com/reference/android/speech/tts/Voice | Android SDK android-35 sources
  - (high, LOAD-BEARING) getVoices returns List<Object?> of Map<Object?,Object?> over the channel; casting to List<Map<String,String>> throws TypeError at runtime.
    lib/flutter_tts.dart: `Future<dynamic> get getVoices async { final voices = await _channel.invokeMethod('getVoices'); return voices; }` — untyped. StandardMessageCodec decodes maps as Map<Object?,Object?>. I wrote a passing test asserting `(raw as List).cast<Map<String,String>>().first` throws TypeError. Also FlutterTtsPlugin.getVoices catches NullPointerException and calls result.success(null) — so the Dart side must tolerate a null list, not just an empty one.
    sources: https://github.com/dlutton/flutter_tts (lib/flutter_tts.dart, FlutterTtsPlugin.kt:553-566) | Verified locally by running the test
  - (high, LOAD-BEARING) Pigeon is actively maintained and is the officially recommended approach for NEW platform channels in 2026 — but it buys this project little, because 2 of its 3 native surfaces have no Dart->native channel at all.
    pigeon 27.1.2, published ~2 days before 2026-07-15, verified publisher flutter.dev, ~457k downloads. Supports Kotlin/Java, Swift/Obj-C, C++, GObject. docs.flutter.dev recommends it for type-safe platform code. BUT: the Android QS TileService and the iOS 18 ControlWidget are native-initiated entry points that run with NO Flutter engine — Pigeon generates Dart<->host messaging and is simply not involved. Only Personal Voice (iOS) is a genuine Dart->native call, and it is roughly one method. Pigeon's own docs warn generated code must be version-matched across Dart and host or you get crashes, and 'using Pigeon-generated code in public APIs is strongly discouraged'.
    sources: https://pub.dev/packages/pigeon | https://docs.flutter.dev/platform-integration/platform-channels | https://github.com/flutter/packages/tree/main/packages/pigeon
  - (medium, LOAD-BEARING) If the QS TileService reads Flutter's shared_preferences natively, the modern SharedPreferencesAsync API will silently break it — the data moves to DataStore, not FlutterSharedPreferences.xml.
    Legacy shared_preferences on Android writes to a SharedPreferences file named 'FlutterSharedPreferences' with every key prefixed 'flutter.'. The newer SharedPreferencesAsync/SharedPreferencesWithCache APIs are backed by Jetpack DataStore instead. So Kotlin doing getSharedPreferences("FlutterSharedPreferences", ...).getString("flutter.phrase", null) reads NOTHING if Dart used SharedPreferencesAsync — the QS tile speaks silence, on the exact no-Flutter-engine path no Dart test can cover. Recommendation: do not couple the tile to a plugin's private storage format; own the contract with an explicit versioned JSON file.
    sources: https://pub.dev/packages/shared_preferences | https://github.com/flutter/flutter/issues/165643
  - (high, LOAD-BEARING) No automated test can assert that audio actually played. integration_test cannot verify speech, and the Android emulator ships no TTS engine — so CI can never test speech at all.
    integration_test drives the Flutter app via IntegrationTestWidgetsFlutterBinding on a real device/emulator and can assert widget state and that a channel call was issued — but there is no supported hook to capture or assert PCM output from AVSpeechSynthesizer or Android TextToSpeech. Standard emulator system images commonly ship without a TTS engine/voice data; Google TTS must be installed from Play and voice data downloaded, and that download is itself known to fail in emulated environments. Practical consequence: the highest-severity bug class in this app (silence) is structurally unreachable by CI. Android does offer TextToSpeech.synthesizeToFile() as the only real escape hatch — it writes a WAV you can assert is non-empty/non-silent — but that is a native-side test, not a Dart one.
    sources: https://docs.flutter.dev/testing/integration-tests | https://firebase.google.com/docs/test-lab/flutter/integration-testing-with-flutter | https://developer.android.com/reference/android/speech/tts/TextToSpeech
  - (high, LOAD-BEARING) The audio session category bug (.ambient vs .playback) is not unit-testable, and flutter_tts's own README example uses the dangerous .ambient value.
    flutter_tts 4.2.5 (published ~Jan 2026) documents setIosAudioCategory(category, options, mode); its README example configures the AMBIENT category to let background music continue — precisely the configuration that lets the iOS hardware silent switch mute the app. A Dart test can only assert that YOUR code passed .playback to the wrapper (a value-level assertion); it cannot observe AVAudioSession's real category, nor the silent switch. This is a manual device-checklist item, permanently. Also note awaitSpeakCompletion is iOS-only, so completion semantics differ per platform.
    sources: https://pub.dev/packages/flutter_tts
  - (medium) patrol is real, maintained, and genuinely extends integration_test to native UI — but it solves a problem this app does not have.
    patrol (LeanCode, since 2022) wraps flutter_test + integration_test with a native automator to tap permission dialogs, notifications, WebViews, toggle Wi-Fi/settings. Requires patrol_cli and a custom test runner. This app has no network, no accounts, and no runtime permission prompts (TTS needs none). The one arguable use — driving the Android QS tile shade — is niche, and patrol adds a CLI, a native harness, and version-coupling to your build for it. Not worth it inside a 2-week solo MVP.
    sources: https://pub.dev/packages/patrol | https://patrol.leancode.co/
  - (medium) Firebase Test Lab and device farms are a poor fit here, though for reasons of capability rather than the no-network architecture.
    Test Lab officially supports Flutter integration_test (build APK + run as instrumentation test). Offline-only is not a blocker — the device runs the app locally. The real blockers: farm devices are the same TTS-poor images CI has, farm runs cannot assert audio, and the highest-risk surfaces (QS tile, ControlWidget, Personal Voice, silent switch) are exactly what Robo/instrumentation cannot reach. Test Lab's iOS coverage is also weak. Cost/benefit fails for a solo dev; a physical Android phone and one iPhone beat it outright.
    sources: https://firebase.google.com/docs/test-lab/flutter/integration-testing-with-flutter | https://www.drizz.dev/post/firebase-test-lab-guide
  - (medium, LOAD-BEARING) Robolectric can meaningfully unit-test the QS tile's LOGIC but not TileService's system binding; the responsible minimum is to extract the logic out of the service class.
    Robolectric (current line 4.13+) runs Android unit tests on the JVM without an emulator. However TileService is bound and lifecycled by SystemUI, and Robolectric has no first-class TileService shadow; known Robolectric gaps around click handling on specific API levels reinforce that testing the service shell is low-yield. The high-yield move: TileService.onClick() should be ~5 lines delegating to a plain Kotlin class (read phrase -> validate -> speak) that JUnit tests directly with a fake TTS, with zero Android framework in the way. This is also the ONLY automated coverage that path can ever have, since it runs with no Flutter engine.
    sources: https://robolectric.org/ | https://developer.android.com/training/testing/local-tests/robolectric | https://github.com/robolectric/robolectric/issues/9595

CODE EXAMPLES:
  --- voice_filter: the pure-Dart safety property (VERIFIED — 21 tests pass on Flutter 3.41.2) ---
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
  --- voice_filter tests, using REAL platform payload shapes (all passing) ---
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
  --- The ONE channel-level contract test worth keeping (current 2026 API) ---
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
  --- SpeechService: making silence impossible, and the fake the rest of the suite uses ---
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
  --- MANUAL device checklist — commit as docs/RELEASE_CHECKLIST.md ---
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
  --- If you do adopt Pigeon later: the Personal Voice surface (the only channel-shaped one) ---
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

FACT-CHECK:
    - [CONFIRMED] The current channel-mocking API is TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler), and the old MethodChannel.setMockMethodCallHandler was moved out of package:flutter into package:flutter_test.
    - [CONFIRMED] Calling TestDefaultBinaryMessengerBinding.instance at group() body scope fails at load time; you must call TestWidgetsFlutterBinding.ensureInitialized() first in a plain test().
    - [CONFIRMED] flutter_tts's Android setVoice returns success(0) after only a Log.d when the voice is not found — it never throws. The project's premise is confirmed verbatim.
    - [CONFIRMED] Android's `notInstalled` voice feature defeats a setVoice-return-value check: setVoice returns 1 (success) and synthesis still fails or silently substitutes a DIFFERENT voice.
    - [CONFIRMED] Android sends network_required as the STRING "1"/"0", features as a TAB-separated string; iOS omits network_required entirely. A naive truthiness or bool check silently inverts the safety property.
    - [CONFIRMED] getVoices returns List<Object?> of Map<Object?,Object?> over the channel; casting to List<Map<String,String>> throws TypeError at runtime.
    - [CONFIRMED] Pigeon is actively maintained and is the officially recommended approach for NEW platform channels in 2026 — but it buys this project little, because 2 of its 3 native surfaces have no Dart->native channel at all.
    (no corrections)

RECOMMENDATIONS:
  - [must] Fake the SpeechService interface in ~all tests; do NOT mock the flutter_tts MethodChannel across the suite. Confine channel mocking to ONE contract-test file. — You already own the abstraction — use it. Channel mocks couple every test to flutter_tts's private method-name strings and untyped payloads, so a plugin upgrade breaks 50 tests for reasons unrelated to what they assert, and they still prove nothing about real audio. The fake is faster, typed, and lets you assert the thing that actually matters (the VOCALIZATION was spoken, not the label). The residual value of channel-level tests is real but narrow: one file that pins the plugin's actual wire behavior (setVoice returns 0 and does not throw; getVoices returns untyped nested maps). That file is a canary for plugin upgrades — it is the only thing that will tell you flutter_tts changed its contract, and with no telemetry, nothing else will.
  - [must] Exclude voices where features contains 'notInstalled', not just network_required == "1". — Confirmed in Android SDK 35 source: a notInstalled voice IS in tts.voices, so setVoice matches it and returns 1 — your stated setVoice-return-check passes — yet synthesis reports ERROR_NOT_INSTALLED_YET or silently substitutes a different voice. This is the exact failure mode the whole voice_filter exists to prevent, and the return-value check does not catch it.
  - [must] Compare network_required explicitly against the string "1"; treat a missing key (iOS) as not-network-required; split features on TAB. — Android sends "1"/"0" as Strings. `raw['network_required'] == true` is always false (String vs bool) — every network voice would be classified offline-safe, silently inverting the safety property in the exact direction that hurts a user with no signal. And "0" is non-empty, so it survives truthiness/null checks. iOS omits the key entirely.
  - [must] Parse getVoices defensively with a tryParse that returns null on bad entries; never cast to List<Map<String,String>>, and handle a null result. — The channel yields List<Object?>/Map<Object?,Object?>; the direct cast throws TypeError (I verified this with a passing test). FlutterTtsPlugin.getVoices also catches NPE and returns success(null). With no crash reporting, an uncaught TypeError at voice-load is an unexplained blank board in the field.
  - [must] Call TestWidgetsFlutterBinding.ensureInitialized() as the first line of main() in any test file touching TestDefaultBinaryMessengerBinding.instance. — Otherwise the file fails to LOAD (not fails a test) with 'Binding has not yet been initialized'. testWidgets does this implicitly; plain test() does not. I hit this by running the code.
  - [should] Skip Pigeon for the MVP. Use one hand-written MethodChannel for Personal Voice; revisit Pigeon only if native surface grows. — Pigeon 27.1.2 is healthy, official, and genuinely the right default for NEW channels — but it earns its keep on breadth of typed surface, and you have roughly one method that crosses Dart->native. The QS tile and ControlWidget are native-initiated and run without a Flutter engine, so Pigeon is not even applicable to them. Against that, Pigeon adds a codegen step, a version-lockstep requirement between Dart and host code (mismatches crash), and generated files a stranger must learn. For a 2-week MVP whose exit plan is readability-by-a-stranger, one 20-line hand-written channel is the smaller artifact.
  - [must] Do not have the Kotlin TileService read Flutter's shared_preferences storage. Own the native contract with an explicit versioned JSON file written by Dart. — Legacy shared_preferences writes FlutterSharedPreferences.xml with 'flutter.'-prefixed keys; the modern SharedPreferencesAsync is backed by DataStore instead. Either the prefix or an API migration silently yields null on the native read — and this path has no Flutter engine, no test, and no telemetry, so the failure is invisible to you and total for the user (tap tile, nothing). An explicit file with a schema version is testable from both sides and readable by a stranger.
  - [should] Extract QS tile logic out of TileService into a plain Kotlin class and JUnit-test that with a fake TTS. Do not fight Robolectric to test the service shell. — This path can never be covered by any Dart test — it is the only code in the app with zero Flutter involvement, and it runs at the user's worst moment. onClick() should be a 5-line delegation. Plain JUnit over the extracted class needs no Robolectric at all, runs in milliseconds, and covers the real logic (read phrase, validate non-empty, handle TTS init failure, speak).
  - [must] Write a physical-device manual checklist, commit it to the repo, and run it before every release. Treat it as a deliverable, not a chore. — With no telemetry, no audio assertion possible, and no TTS engine on emulators, the manual pass is not a supplement to automation — for the silence bug class it IS the entire safety net. Committing it is also part of the abandonment plan: it tells a stranger what the machine cannot check.
  - [avoid] Do not adopt patrol, Firebase Test Lab, or a device farm for the MVP. — patrol solves native permission/notification dialogs — this app has none. Test Lab supports Flutter integration_test fine and offline is no blocker, but farm devices have the same missing TTS engines and still cannot assert audio, so it cannot reach any of your top risks. One real Android phone plus one iPhone strictly dominates for a solo dev.
  - [should] Use integration_test for exactly one smoke test: cold start -> tap tile -> assert the SpeechService was asked to speak the right vocalization. Do not try to assert audio. — Its real value here is proving the app boots on a real device with real plugin registration and a real DB — catching plugin/init/migration wiring that widget tests mock away. That is worth one test. Asserting sound is not possible; pretending otherwise buys false confidence, which for this app is worse than no test.
  - [should] If you ever want a machine to verify real audio, do it natively with TextToSpeech.synthesizeToFile() and assert the WAV is non-empty and non-silent. — This is the only honest automated audio check that exists on Android, and it is a native instrumentation test, not a Dart one. It requires a device/image with a real TTS engine. Worth knowing exists; probably not worth building in the 2-week MVP.

---

### DIMENSION: lints-tooling
SUMMARY: I did not just read docs — I built a throwaway Flutter probe project against the SDK actually installed on this machine and ran the proposed config through `flutter analyze`. That caught three things the web sources got wrong, including one that matters a lot. The headline: **`discarded_futures` does NOT catch `onTap: () => tts.speak('...')`** — the arrow closure "returns" the Future so the lint considers it handled, but it is being assigned to a `VoidCallback`, so the Future (and any error) is silently dropped. That is the single most idiomatic way to wire a Flutter tile, it is exactly this project's silence bug, and no lint in the ecosystem catches it. The fix is structural, not disciplinary: `SpeechController` must expose a **void-returning** `speakNow(String)` that internally does `unawaited(_speak(p).catchError(...))`, so a callback never touches a Future and the hole is unreachable by construction. I verified that pattern analyzes clean. Recommendation: **very_good_analysis (212 rules, strict-casts/inference/raw-types already on) over flutter_lints**, with ~20 severity promotions to `error` for the silence/leak/dynamic bug classes, plus two deliberate downgrades (`public_member_api_docs`, `lines_longer_than_80_chars`) for solo-dev proportionality. **Do not adopt custom_lint** — riverpod_lint 3.x already migrated to the first-party `analysis_server_plugin` system (verified: `missing_provider_scope` fires from a plain `flutter analyze` with no second pass), and the legacy plugin system custom_lint is built on is scheduled for deprecation as early as Dart 3.12. dart_code_metrics is confirmed dead as OSS (commercial DCM at dcm.dev). **There is no usable accessibility lint** — the one candidate is abandoned — so a11y must be enforced by tests, which sharpens rather than weakens the accessibility-is-correctness constraint. The shipped file is at /Users/zakariafatahi/50-apps-challenge/Offline-AAC/analysis_options.yaml and analyzes clean.

FINDINGS:
  - (high, LOAD-BEARING) `discarded_futures` and `unawaited_futures` both FAIL to catch the arrow-closure callback idiom `onTap: () => tts.speak('x')`, which is precisely this project's silence bug.
    Verified empirically on Dart 3.11.0 with very_good_analysis 10.2.0. Probe results by line: (A) `GestureDetector(onTap: () => tts.speak('A'))` → NO DIAGNOSTIC. (B) `onTap: () { tts.speak('B'); }` block body → discarded_futures fires. (C) `onTap: () async { tts.speak('C'); }` → unawaited_futures fires. (D) sync method `void _onTapD() { tts.speak('D'); }` → discarded_futures fires. The arrow form escapes because the closure body IS the invocation, so the rule treats the Future as 'returned' — but the target type is VoidCallback, so it is dropped along with any error. Mitigation verified to analyze clean: a void-returning `void speakNow(String p) { unawaited(_speak(p).catchError((Object e, StackTrace s) { /* crash log + visible banner */ })); }` — the callback then never holds a Future.
    sources: local probe: flutter analyze, Dart 3.11.0 / very_good_analysis 10.2.0 | https://dart.dev/tools/linter-rules/discarded_futures
  - (high, LOAD-BEARING) riverpod_lint 3.x has migrated OFF custom_lint onto the first-party `analysis_server_plugin` system; custom_lint should not be added to this project at all.
    riverpod_lint 3.1.4 is latest on pub (3.1.3 resolves on Dart 3.11). It is configured via a TOP-LEVEL `plugins:` block, not `analyzer: plugins:`. Verified: `missing_provider_scope` was reported by a plain `flutter analyze` with no custom_lint dependency and no `dart run custom_lint` second pass. Analyzer plugin support landed in Dart 3.10. The Dart team's tracking issue (dart-lang/sdk#62164) states legacy plugins — whose 'primary client' is explicitly named as custom_lint — will be deprecated 'as early as Dart 3.12' and disabled possibly the following release. custom_lint is still at 0.8.1 (Invertase).
    sources: https://pub.dev/packages/riverpod_lint | https://dart.dev/tools/analyzer-plugins | https://github.com/dart-lang/sdk/issues/62164 | local probe
  - (high, LOAD-BEARING) The `plugins:` block syntax with a pub version requires an explicit `version:` key — the shorthand form is a YAML parse error if you also want `diagnostics:`.
    `plugins:\n  riverpod_lint: ^3.1.3\n    diagnostics:` → `error • Mapping values are not allowed here` (a YAML scalar cannot also have children). Correct: `plugins:\n  riverpod_lint:\n    version: ^3.1.3\n    diagnostics:\n      missing_provider_scope: true`. Per the docs and confirmed by probe: plugin-defined WARNINGS are enabled by default; plugin-defined LINTS are disabled by default and must be opted in under `diagnostics:`. Suppression uses `// ignore: plugin_name/diagnostic_code`.
    sources: local probe | https://dart.dev/tools/analyzer-plugins
  - (high, LOAD-BEARING) very_good_analysis sets `close_sinks: ignore` — a rule this project specifically needs, so the override is load-bearing rather than decorative.
    VGA 10.2.0's own analyzer block: `errors: {close_sinks: ignore, unrelated_type_equality_checks: warning, collection_methods_unrelated_type: warning, missing_return: error, missing_required_param: error, record_literal_one_positional_no_trailing_comma: error}`. This project holds a StreamController for TTS voice-availability changes, so `close_sinks: error` is re-enabled explicitly. VGA also already sets `language: {strict-casts: true, strict-inference: true, strict-raw-types: true}` and `formatter: trailing_commas: preserve`, so those need no restating.
    sources: ~/.pub-cache/hosted/pub.dev/very_good_analysis-10.2.0/lib/analysis_options.10.2.0.yaml
  - (high, LOAD-BEARING) very_good_analysis 10.3.0 CANNOT be used on this machine — it requires Dart 3.12, and a wrong version in the `include:` silently downgrades to a warning and disables all 212 rules.
    VGA 10.2.0 pubspec: `environment: sdk: ^3.11.0`. Machine has Dart 3.11.0, so pub resolves 10.2.0 even though 10.3.0 is latest. My first draft used `include: package:very_good_analysis/analysis_options.10.3.0.yaml` and produced only `warning • The URI ... can't be found ... • include_file_not_found` — analysis silently continued with NO VGA rules. This is a genuinely dangerous failure mode: a warning, not an error, on a project whose entire safety net is static analysis. Verify with `ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/`.
    sources: local probe | VGA 10.2.0 pubspec.yaml
  - (high, LOAD-BEARING) The installed SDK is Flutter 3.41.2 / Dart 3.11.0 — NOT the Flutter 3.44 / Dart 3.12 the brief assumes.
    `dart --version` → 3.11.0 (stable, 2026-02-09). `flutter --version` → 3.41.2, channel [user-branch], revision 90673a4eef (2026-02-18). Flutter 3.44 (Dart 3.12) is indeed current stable as of ~May 2026, so this machine is ~2 releases behind. Every version claim in this report is pinned to what actually resolves at 3.11, not to pub.dev's 'latest'. This drift between assumed and installed SDK is itself the argument for pinning.
    sources: local `dart --version` / `flutter --version` | https://docs.flutter.dev/release/release-notes/release-notes-3.44.0
  - (high, LOAD-BEARING) Non-exhaustive switches over sealed classes are already a COMPILE ERROR — no lint is needed, and this is the strongest argument for modelling failures as sealed classes.
    Verified: omitting a subtype yields `error • The type 'SpeechFailure' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'EngineSilent()' • non_exhaustive_switch_statement` — from the compiler, not the linter, and unsuppressable by lint config. Concrete consequence: model SpeechFailure/OutputMode as `sealed class`, and adding a new failure mode breaks the build at every call site instead of falling through to silence. The `exhaustive_cases` lint (already in VGA) only covers enums and static-const-instance classes.
    sources: local probe
  - (high, LOAD-BEARING) dart_code_metrics is confirmed dead as free OSS; the successor DCM is commercial. Do not plan around it.
    The pub package `dart_code_metrics` was discontinued around July 2023 and its license moved off MIT. The successor is DCM at dcm.dev, requiring a purchased license (dcm.dev/pricing), actively developed (v1.25.0 blog post, Dec 2025). DCM does own the only credible a11y rules (e.g. `avoid-missing-image-alt`), which is the one real loss — but a paid dependency is a poor fit for a solo 2-week MVP whose exit plan is open-sourcing for strangers to build.
    sources: https://github.com/dart-code-checker/dart-code-metrics | https://dcm.dev/blog/2024/12/09/whats-new-in-dcm-1-25-0/ | https://dcm.dev/docs/rules/flutter/avoid-missing-image-alt/
  - (high, LOAD-BEARING) There is NO usable accessibility lint in the free ecosystem. The only candidate, `accessibility_lint`, is abandoned.
    `accessibility_lint` 1.0.0, published 19 months ago, 0 likes, 183 total downloads, 50/160 pub points, unverified publisher, Apache-2.0, and built on custom_lint (i.e. on the plugin system scheduled for deprecation). Its five rules (Icon/Image semanticLabel, IconButton tooltip, min tap size, haptics) are exactly what this project wants, but the package is not a dependency worth taking. dart-lang/sdk#58251 tracks first-party a11y linters — still open. CONSEQUENCE: TextScaler-at-200%, Semantics-on-every-tile, and label-vs-vocalization correctness are UNENFORCEABLE by lint and must be widget tests. No lint config can discharge the accessibility-is-correctness constraint.
    sources: https://pub.dev/packages/accessibility_lint | https://github.com/dart-lang/sdk/issues/58251
  - (high) flutter_lints 5.0.0 REMOVED the `prefer_const_*` rules; very_good_analysis retains them.
    flutter_lints changelog — 5.0.0 removed `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`, `avoid_null_checks_in_equality_operators`. 6.0.0 (latest, ~13 months old) added `strict_top_level_inference` and `unnecessary_underscores`, min SDK Flutter 3.32/Dart 3.8. VGA 10.2.0 still enables all the const rules. Relevant because zero-animation/deterministic-UI is a design rule here: const-ing every tile subtree that can be const removes rebuilds on the crisis path.
    sources: https://pub.dev/packages/flutter_lints/changelog | VGA 10.2.0 rule list
  - (high) The Dart 3.7 'tall style' formatter rewrite needs no opt-in; style is selected by the pubspec language version, and only page_width/trailing_commas are configurable.
    The formatter was rewritten in Dart 3.7 with two styles. Code at language version <=3.6 keeps short style; >=3.7 gets tall style automatically — so on Dart 3.11 there is nothing to enable. Config (verified accepted): top-level `formatter: {page_width: 80, trailing_commas: preserve}`. `trailing_commas` accepts `automate` (default: formatter adds/removes commas and may collapse widget trees onto one line) or `preserve` (a trailing comma forces a split). VGA already sets `preserve`. For a 3x4 grid widget tree a stranger reads cold, `preserve` is worth the vertical space and keeps layout diffs minimal.
    sources: https://github.com/dart-lang/dart_style/wiki/Configuration | https://dart.dev/blog/announcing-dart-3-7 | local probe (config accepted)
  - (high, LOAD-BEARING) `unawaited_futures` and `discarded_futures` are complementary, both already in VGA, and both need promoting to error here.
    unawaited_futures covers unawaited Futures inside ASYNC bodies; discarded_futures covers Future-returning calls in SYNC bodies (dispose(), initState(), onPressed). Both confirmed present in VGA 10.2.0's 212-rule list at info severity — my earlier read that VGA omits discarded_futures was wrong. Escape hatch is `unawaited(...)` from dart:async, which is explicit and greppable.
    sources: VGA 10.2.0 rule list (grep) | https://dart.dev/tools/linter-rules/unawaited_futures
  - (medium) Every diagnostic is reported TWICE under `flutter analyze` when an analysis_server_plugin is active.
    Observed consistently across all probe runs: each issue printed exactly twice (e.g. `use_build_context_synchronously` at probe.dart:26:17 listed twice), and the '15 issues found' count double-counts. Affects both plugin-defined and core diagnostics. Cosmetic, but it will make CI output confusing and any issue-count threshold wrong. Cause unconfirmed — likely a double-registration bug in the plugin host on Dart 3.11.
    sources: local probe (reproduced across 4 runs)
  - (high) very_good_analysis 10.3.0 is latest on pub (published ~June 2026) and enables 212 rules at 10.2.0.
    `grep -cE '^\s+- '` on analysis_options.10.2.0.yaml → 212. VGA ships every historical versioned file (1.0.0 through 10.2.0) plus an unversioned analysis_options.yaml alias. Confirmed present: discarded_futures, unawaited_futures, exhaustive_cases, avoid_catches_without_on_clauses, avoid_dynamic_calls, avoid_slow_async_io, cancel_subscriptions, only_throw_errors, prefer_const_constructors, public_member_api_docs, lines_longer_than_80_chars, require_trailing_commas, flutter_style_todos.
    sources: https://pub.dev/packages/very_good_analysis | local pub-cache inspection
  - (medium, LOAD-BEARING) FVM 4.1.2 is actively maintained and is the pragmatic way to pin Flutter, but pinning matters here for a reason beyond reproducibility.
    fvm 4.1.2 published ~19 days ago, verified publisher (leoafarias.com), 722 likes, 198k weekly downloads. `fvm use stable --pin` resolves 'stable' to a concrete version and writes a committed project config. The argument for THIS project is concrete: the brief asserts Flutter 3.44/Dart 3.12 while the machine runs 3.41.2/Dart 3.11 — that gap already silently changed which very_good_analysis version resolves (10.2.0 vs 10.3.0), which in turn would have silently disabled all 212 lints via include_file_not_found. On a project with no telemetry, an unpinned SDK means the safety net can quietly change under you. Config filename (.fvmrc vs legacy fvm_config.json) not verified.
    sources: https://pub.dev/packages/fvm | https://fvm.app/ | local version comparison

CODE EXAMPLES:
  --- The verified lint hole — what discarded_futures does and does NOT catch ---
```dart
// Probe run against Dart 3.11.0 + very_good_analysis 10.2.0.
// Results are from an actual `flutter analyze`, not from reading the docs.

abstract class SpeechService {
  Future<void> speak(String t);
}

// (A) NO DIAGNOSTIC.  <-- THE BUG. The arrow closure "returns" the Future,
//     so discarded_futures thinks it's handled. But onTap is a VoidCallback,
//     so the Future — and any error inside it — is dropped on the floor.
//     User taps the tile. Nothing is spoken. Nothing is logged. No telemetry.
GestureDetector(onTap: () => tts.speak('A'), child: const Text('A'));

// (B) error • 'Future'-returning calls in a non-'async' function
//     • discarded_futures
GestureDetector(onTap: () { tts.speak('B'); }, child: const Text('B'));

// (C) error • Missing an 'await' for the 'Future' computed by this expression
//     • unawaited_futures
GestureDetector(onTap: () async { tts.speak('C'); }, child: const Text('C'));

// (D) error • 'Future'-returning calls in a non-'async' function
//     • discarded_futures
void _onTapD() {
  tts.speak('D');
}
```
  Case (A) is the most idiomatic way to wire a Flutter tile and is exactly this project's silence bug. No lint in the ecosystem catches it. This is why the mitigation must be structural.
  --- The structural fix — a void-returning seam that makes the hole unreachable ---
```dart
import 'dart:async';

class SpeechController {
  SpeechController(this._speak);
  final Future<void> Function(String) _speak;

  /// Void-returning ON PURPOSE.
  ///
  /// Callbacks must never hold a Future: `onTap: () => c.speakNow(p)` is
  /// safe precisely because there is no Future to drop. This closes the
  /// arrow-closure hole in `discarded_futures` by construction rather than
  /// by discipline — which matters because with no telemetry, a lapse in
  /// discipline is never discovered.
  ///
  /// `unawaited` is the explicit, greppable escape hatch: it documents that
  /// discarding is intended, and `catchError` guarantees a failure is
  /// surfaced rather than swallowed into silence.
  void speakNow(String phrase) {
    unawaited(
      _speak(phrase).catchError((Object e, StackTrace s) {
        // Real impl: append to the on-device exportable crash log AND
        // show a visible banner. A TTS failure must never be silent —
        // the user needs to know to try another channel.
      }),
    );
  }
}

// Verified: analyzes clean under the full config. No discarded_futures,
// no unawaited_futures, no lint hole.
GestureDetector(onTap: () => c.speakNow('hi'), child: const Text('x'));
```
  Verified to analyze clean with `flutter analyze` under the shipped config.
  --- Sealed classes give exhaustiveness as a COMPILE error — stronger than any lint ---
```dart
sealed class SpeechFailure {}
class VoiceUnavailable extends SpeechFailure {}
class EngineSilent extends SpeechFailure {}

String describe(SpeechFailure f) {
  switch (f) {
    case VoiceUnavailable():
      return 'voice gone';
    // EngineSilent omitted ->
    // error • The type 'SpeechFailure' isn't exhaustively matched by the
    //   switch cases since it doesn't match the pattern 'EngineSilent()'
    //   • non_exhaustive_switch_statement
  }
}

// This is a COMPILER error, not a lint: it cannot be suppressed via
// analysis_options, cannot be downgraded to info, and cannot be forgotten.
// Consequence for this project: adding a new TTS failure mode breaks the
// build at every call site instead of silently falling through a `default:`
// and giving the user nothing. Prefer `sealed class` over `enum` for every
// failure/result type. This is the closest thing to telemetry you get.
```
  Verified on Dart 3.11.0. This is why `exhaustive_cases` (a lint) is only needed for enums and static-const-instance classes.
  --- Correct `plugins:` syntax for riverpod_lint — the version-plus-diagnostics form ---
```yaml
# WRONG — YAML parse error:
#   error • Mapping values are not allowed here. Did you miss a colon earlier?
# A scalar (^3.1.3) cannot also have children.
#
# plugins:
#   riverpod_lint: ^3.1.3
#     diagnostics:
#       missing_provider_scope: true

# RIGHT — verified working with a plain `flutter analyze`,
# no custom_lint, no `dart run custom_lint` second pass:
plugins:
  riverpod_lint:
    version: ^3.1.3
    diagnostics:
      # Plugin-defined WARNINGS are on by default;
      # plugin-defined LINTS are OFF by default and need opting in here.
      missing_provider_scope: true        # no ProviderScope => every
                                          # provider read throws on first tap
      avoid_build_context_in_providers: true
      avoid_ref_inside_state_dispose: true
      provider_dependencies: true
      # Off: not using codegen — these are generator-syntax rules.
      functional_ref: false
      notifier_extends: false
      notifier_build: false

# Suppress with:  // ignore: riverpod_lint/missing_provider_scope
```
  `plugins:` is TOP-LEVEL, not nested under `analyzer:`. Requires Dart 3.10+.
  --- The severity promotions that matter — analyzer: errors: block ---
```yaml
analyzer:
  # VGA already sets strict-casts/strict-inference/strict-raw-types,
  # so no `language:` block is needed here.
  exclude:
    - "**/*.g.dart"
    - "**/*.drift.dart"
    - "**/generated_plugin_registrant.dart"
    - "test/.test_coverage.dart"
    # drift's exported schema snapshots: historical artifacts. An autofix
    # touching these would corrupt the migration test baseline.
    - "test/drift/generated/**"

  errors:
    # TIER 1 — dropped Future == phrase never spoken.
    unawaited_futures: error
    discarded_futures: error

    # TIER 2 — swallowed failure. flutter_tts returns 0 with only a Log.d;
    # if we swallow too, the failure is invisible at every layer.
    empty_catches: error
    avoid_catches_without_on_clauses: error
    only_throw_errors: error
    throw_in_finally: error

    # TIER 3 — async-gap BuildContext (await a drift write, then pop).
    use_build_context_synchronously: error

    # TIER 4 — leaks. NOTE: VGA ships `close_sinks: ignore`; we override it
    # because we hold a StreamController for TTS voice-availability changes.
    cancel_subscriptions: error
    close_sinks: error

    # TIER 5 — platform channels hand us Map<Object?, Object?>.
    avoid_dynamic_calls: error
    always_declare_return_types: error
    cast_nullable_to_non_nullable: error

    exhaustive_cases: error
    avoid_print: error
    avoid_slow_async_io: error

    # NOT error: never let a Flutter upgrade block an urgent hotfix.
    deprecated_member_use: warning
    deprecated_member_use_from_same_package: warning

    # Deliberate downgrades — proportionality for a solo dev.
    public_member_api_docs: ignore      # package-author rule; this is an app
    lines_longer_than_80_chars: ignore  # formatter already wraps code
```
  All promoted rules are already present in VGA at info severity — promotion turns grey squiggles a solo dev scrolls past into red build failures.

FACT-CHECK:
    - [CONFIRMED] `discarded_futures` and `unawaited_futures` both FAIL to catch the arrow-closure callback idiom `onTap: () => tts.speak('x')`, which is precisely this project's silence bug.
    - [CONFIRMED] riverpod_lint 3.x has migrated OFF custom_lint onto the first-party `analysis_server_plugin` system; custom_lint should not be added to this project at all.
    - [CONFIRMED] The `plugins:` block syntax with a pub version requires an explicit `version:` key — the shorthand form is a YAML parse error if you also want `diagnostics:`.
    - [CONFIRMED] The installed SDK is Flutter 3.41.2 / Dart 3.11.0 — NOT the Flutter 3.44 / Dart 3.12 the brief assumes.
    - [REFUTED] "very_good_analysis sets `close_sinks: ignore` — a rule this project specifically needs, so the override is load-bearing rather than decorative."
      CORRECTION: VGA 10.2.0 does set `close_sinks: ignore` — the quotation is accurate — but the inference is backwards on three counts.

(a) VGA never enables `close_sinks` in its `linter: rules:` list (210 rules; close_sinks absent), so "re-enabled" has no referent — the rule was never on.

(b) `analyzer: errors: close_sinks: error` CANNOT enable it. `errors:` only changes severity of diagnostics already generated. Verified empirically on Dart 3.11.0: the project's exact config emits nothing on a leaked StreamController. The override is a NO-OP — decorative, precisely what the claim denies. To actually get it, the file must add:
    linter:
      rules:
        - close_sinks
(keeping `errors: close_sinks: error` to promote info→error). This is the only one of the file's 17 `errors:` entries that is broken; the other 16 (including `cancel_subscriptions`) are enabled by VGA and work as written.

(c) Even properly enabled, close_sinks would not flag the described design. It only tracks sinks created and closed within one function ("This rule does not track all patterns of Sink instantiations and closures", sdk#57882); a controller held as a field and closed in `dispose()` yields no diagnostic — confirmed by probe. For a field-held controller the real protection is a `dispose()` plus a test asserting closure, not this lint.

Additionally, the premise is not yet true: the repo contains zero Dart files, so no StreamController exists. RESEARCH.md:363 itself calls the TTS voice-availability reactivity "not load-bearing."

Correct characterization: VGA's `close_sinks: ignore` is vestigial (ignoring a rule it never enables, unchanged 2.3.0→10.3.0), and the project's override is currently decorative. It can be made load-bearing only by enabling the rule under `linter: rules:` — and even then it will not cover the field-held controller the comment describes.
    - [PARTIALLY_TRUE] "very_good_analysis 10.3.0 CANNOT be used on this machine — it requires Dart 3.12, and a wrong version in the `include:` silently downgrades to a warning and disables all 212 rules."
      CORRECTION: Two corrections. (1) It is NOT silent. `flutter analyze` exits 1 and `dart analyze` exits 2 on include_file_not_found — warnings are fatal by default in `dart analyze`, so a normal CI gate catches a wrong versioned include immediately. It only slips through green under `dart analyze --no-fatal-warnings` (measured exit 0), or unnoticed in-IDE. Everything else about the failure mode is accurate: severity really is `warning` rather than `error`, analysis really does continue, and all 212 rules really are disabled (reproduced: identical file, 8 violations → 0). (2) "CANNOT be used on this machine" should be "cannot be used on this machine's current toolchain." VGA 10.3.0 requires `^3.12.0`; the machine has Dart 3.11.0 because it is on Flutter 3.41.2. Flutter 3.44.0 stable ships Dart 3.12.0 (3.44.6 → Dart 3.12.2), so `flutter upgrade` unblocks 10.3.0. Until then, `include: package:very_good_analysis/analysis_options.10.2.0.yaml` is the correct pin — matching the resolved 10.2.0, not the latest published version.
    - [PARTIALLY_TRUE] "Non-exhaustive switches over sealed classes are already a COMPILE ERROR — no lint is needed, and this is the strongest argument for modelling failures as sealed classes."
      CORRECTION: Two specifics are wrong; the conclusion is not. (1) "Unsuppressable by lint config" — not true of the analyzer. `analyzer: errors: {non_exhaustive_switch_statement: ignore}` or a `// ignore:` comment makes `dart analyze`/`flutter analyze` report "No issues found!". The error is unsuppressable only at COMPILE time (`flutter build` / `dart compile`), which still fails regardless of analysis_options. Restate as: "breaks the build, and cannot be silenced from analysis_options — but only if CI actually compiles; an analyze-only gate can be bypassed with one ignore comment." (2) "`exhaustive_cases` only covers enums and static-const-instance classes" — drop "enums". Per dart.dev and a local probe, `exhaustive_cases` covers ONLY enum-like classes (concrete class, private constructors, 2+ static const fields of the enclosing type — the pre-Dart-2.17 hand-rolled enum idiom). Native enums are covered by the compiler's `non_exhaustive_switch_statement`, identically to sealed classes — which actually strengthens the claim's thesis, since it means both enums and sealed types get compiler-grade exhaustiveness and the lint is a legacy-pattern backstop only.

RECOMMENDATIONS:
  - [must] Never call a Future-returning method directly from a widget callback. Route every tile tap through a void-returning `SpeechController.speakNow(String)` that internally does `unawaited(_speak(p).catchError(...))`. — VERIFIED lint hole: `onTap: () => tts.speak('x')` is caught by NEITHER discarded_futures NOR unawaited_futures, because the arrow closure returns the Future into a VoidCallback. This is the exact silence bug the whole project fears and no lint in the ecosystem catches it. A void-returning seam makes the hole unreachable by construction rather than relying on discipline — which matters because with no telemetry, discipline failures are never discovered.
  - [must] Use `include: package:very_good_analysis/analysis_options.10.2.0.yaml` (version-pinned), and re-check the filename exists after any SDK or VGA bump: `ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/`. — A wrong version in the include produces only `warning • include_file_not_found` and silently continues with ZERO lint rules. On a project whose sole safety net is static analysis, silently losing all 212 rules is a catastrophic failure mode that looks like a passing build. Version-pinning (vs the unversioned alias) also ensures `pub upgrade` can never silently redefine what counts as an error on a project that may be abandoned.
  - [must] Adopt very_good_analysis, not flutter_lints, and do not add a `linter: rules:` block — express all customization through `analyzer: errors:`. — VGA gives 212 rules plus strict-casts/strict-inference/strict-raw-types already on, versus flutter_lints' much smaller set which also REMOVED the prefer_const_* rules in 5.0.0. VGA already contains every rule this project wants (discarded_futures, avoid_dynamic_calls, cancel_subscriptions, only_throw_errors, avoid_slow_async_io, exhaustive_cases), so the only work left is severity. Mixing the list form (`- rule`) and map form (`rule: false`) under `linter: rules:` is a config parse error — use `errors: <rule>: ignore` to disable.
  - [must] Explicitly set `close_sinks: error`, overriding VGA. — VGA ships `close_sinks: ignore` in its own analyzer block. This project holds a StreamController for TTS voice-availability changes; a leaked sink firing on a disposed notifier is a fault on the crisis path. This is one of the few places VGA's defaults are actively wrong for this app.
  - [avoid] Do NOT add custom_lint. Configure riverpod_lint through the top-level `plugins:` block using the `version:` + `diagnostics:` map form. — riverpod_lint 3.x already runs on the first-party analysis_server_plugin system — verified working with a plain `flutter analyze`, no second pass, no extra dependency. The legacy plugin system custom_lint is built on is slated for deprecation as early as Dart 3.12 (the very next SDK) and removal soon after. Adopting custom_lint now buys a migration you'd have to undo, on a project that may be abandoned and must keep working unmaintained.
  - [must] Model SpeechFailure, OutputMode, and every TTS/DB result type as `sealed class`, never as an enum + default case. — Verified: non-exhaustive switches on sealed classes are a COMPILE ERROR (non_exhaustive_switch_statement), enforced by the compiler and not suppressable by lint config — strictly stronger than any lint. Adding a new failure mode then breaks the build at every call site instead of falling through a `default:` into silence. This is the cheapest available substitute for the telemetry this app will never have.
  - [avoid] Do not add `accessibility_lint` or any other a11y lint package. Enforce Semantics, TextScaler at 200%+, and label-vs-vocalization with widget tests instead. — The only free a11y lint is abandoned (0 likes, 183 downloads, 19 months stale, unverified publisher, built on the deprecating custom_lint). The only credible a11y rules live in commercial DCM. Since accessibility is correctness here and no lint can enforce it, the entire burden falls on tests — this should raise the a11y test budget, not lower the a11y bar. Taking a dead dependency would create false confidence, which is worse than none.
  - [must] Promote the silence bug classes to `error`: unawaited_futures, discarded_futures, empty_catches, avoid_catches_without_on_clauses, only_throw_errors, throw_in_finally, use_build_context_synchronously, cancel_subscriptions, close_sinks, avoid_dynamic_calls, always_declare_return_types, cast_nullable_to_non_nullable, exhaustive_cases, avoid_print, avoid_slow_async_io. — All are already in VGA at info severity, where they are grey squiggles that a solo dev with no reviewer will scroll past. Promotion turns each into a red build failure. Each maps to a concrete way this app goes silent: a dropped speak(), a swallowed flutter_tts failure (it returns 0 with only a Log.d), a dead BuildContext after awaiting a drift write, an unguarded dynamic from a platform channel (Personal Voice, QS TileService, ControlWidget).
  - [should] Downgrade `public_member_api_docs: ignore` and `lines_longer_than_80_chars: ignore`. — Proportionality — the brief explicitly asks what to SKIP. public_member_api_docs is a rule for PACKAGE authors; this is an app, and a doc comment on every public member costs hours and buys nothing. Readability-for-a-stranger comes from doc comments on the SEAMS (SpeechService, repositories, migration steps), which is a taste/CONTRIBUTING.md matter. lines_longer_than_80_chars only fires on what the formatter cannot split (long strings, URLs in comments) since the formatter already wraps code.
  - [should] Keep `deprecated_member_use` and `deprecated_member_use_from_same_package` at `warning`, never `error`. — The machine is already 2 Flutter releases behind (3.41.2 vs 3.44 stable). Promoting deprecations to error means a routine Flutter upgrade blocks an urgent hotfix. For an app people depend on to speak, shipping a fix must never be gated on cleaning up deprecation churn.
  - [must] Exclude generated code (`**/*.g.dart`, `**/*.drift.dart`, `**/generated_plugin_registrant.dart`) and drift's exported schema snapshots (`test/drift/generated/**`) from analysis. — VGA excludes only test/.test_coverage.dart and lib/generated_plugin_registrant.dart, so drift output is NOT excluded by default and will drown the 212-rule config in noise. Critically, drift's exported schema snapshots are historical artifacts that must never be reformatted or 'fixed' — a lint autofix touching them would corrupt the migration test baseline, and a botched migration is the loss of someone's voice. Excluding generated code is safe precisely because migration correctness lives in schema tests, not lints.
  - [should] Skip pre-commit hooks (lefthook/husky). Run `flutter analyze` + `dart format --output=none --set-exit-if-changed .` + the drift migration tests in CI instead. — Explicitly answering the 'be honest about what to SKIP' constraint. For a solo dev the IDE already surfaces every promoted error as a red squiggle in real time, so a pre-commit hook mostly adds latency and a `--no-verify` habit. The gate that actually earns its keep is CI running migration tests — the irreplaceable-data risk — not a format check that blocks a commit.
  - [should] Pin the Flutter SDK with `fvm use stable --pin` and commit the FVM config. — Not abstract reproducibility: the assumed SDK (3.44/Dart 3.12) and the installed one (3.41.2/Dart 3.11) already differ, and that gap silently changes which VGA version resolves (10.3.0 vs 10.2.0) — which, via include_file_not_found, silently disables all 212 lints. With no telemetry, a safety net that can quietly change under you is a real hazard. Pinning also serves the abandonment exit plan: a stranger cloning the repo in 2028 gets the SDK the lints were written against.

---

### DIMENSION: ci-release
SUMMARY: The 2026 action stack has drifted from what most blog posts say: `subosito/flutter-action` is still **v2** (v2.23.0, March 2026 — there is no v3), but its companions have all moved on (`actions/checkout@v6`, `actions/setup-java@v5`, `actions/upload-artifact@v6`, `codecov/codecov-action@v5`). The single biggest stale-advice trap is **`VeryGoodOpenSource/very_good_coverage` was archived 2026-03-31** and superseded by `very_good_workflows@v1` — for a solo app repo the right move is neither, just ~15 lines of `lcov` in a shell script with no third-party dependency at all. The 2026 answer to Flutter version pinning is `flutter-version-file: .fvmrc` (flutter-action v2 reads `.fvmrc`, `pubspec.yaml`, or `.fvm/fvm_config.json`, exact versions only), which gives you fvm locally and pinned CI without an fvm install step. Three project-specific calls dominate the generic advice: **do not obfuscate** (the exit plan is open-sourcing, so obfuscation protects nothing, and it would render the on-device crash log — your only field signal — unreadable, permanently so once you abandon the project); **skip emulator integration tests** (15+ min, flaky, and a CI emulator cannot verify the one thing that matters, that real TTS actually produced audio); and **leave R8 off for v1** (reflection-driven keep-rule mistakes fail silently at runtime, which is precisely this app's worst bug class, for near-zero size payoff on a 12-tile app). Commit the `.g.dart` files: drift's generated code *is* the schema, so a migration PR diff becomes a reviewable safety artifact, and a stranger cloning the repo gets a working `flutter run` without a build_runner round-trip — guard staleness with a `build_runner build && git diff --exit-code` CI step. For v1 release, build and sign **locally** and upload to the Play internal track by hand: fastlane is not worth it, and CI never needs your keystore. The highest-leverage hygiene artifact for an app whose exit plan is abandonment is not conventional commits or semantic-release — it is ~6 short ADRs recording *why* `grid_slots` is keyed on position and why the audio session is `.playback`, because those are the decisions a stranger will otherwise silently undo.

FINDINGS:
  - (high, LOAD-BEARING) subosito/flutter-action is still on v2 in 2026 — there is no v3, and it is actively maintained
    Latest release v2.23.0, 2026-03-25, maintained by Bartek Pacia; 46 releases. It now uses actions/cache@v5 internally (self-hosted runners need Actions Runner 2.327.1+; irrelevant for GitHub-hosted). Inputs: channel, flutter-version, flutter-version-file, cache, pub-cache, cache-key, pub-cache-key with :os:/:channel:/:version:/:arch:/:hash:/:sha256: placeholders. An alternative, flutter-actions/setup-flutter, does have v3/v4 — do not confuse its version numbers for subosito's.
    sources: https://github.com/subosito/flutter-action | https://github.com/subosito/flutter-action/releases
  - (high, LOAD-BEARING) flutter-action@v2 reads .fvmrc directly — this is the 2026 reproducible-pinning answer, and it removes the need to install fvm in CI
    flutter-version-file accepts 'path to pubspec.yaml or .fvmrc or .fvm/fvm_config.json'. The version must be an exact string: `flutter: 3.44.0` works, `flutter: ">= 3.19.0 <4.0.0"` does not. Using .fvmrc (rather than pubspec.yaml) lets pubspec keep a normal range constraint while CI and local fvm share one exact pin. .fvmrc is committed; .fvm/flutter_sdk (the symlink) is gitignored. fvm_config.json is deprecated in favour of .fvmrc and is auto-migrated.
    sources: https://github.com/subosito/flutter-action | https://fvm.app/documentation/getting-started/configuration
  - (high, LOAD-BEARING) VeryGoodOpenSource/very_good_coverage is ARCHIVED as of 2026-03-31 — most tutorials still recommend it
    Repo archived 2026-03-31, read-only. Last release v3.0.0 (2024-03-05). README: 'Very Good Coverage has been superseded by Very Good Workflows, which provides a comprehensive suite of reusable GitHub Actions workflows — including code coverage enforcement.' Successor is VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v1 (repo active, updated 2026-05-04) — but that workflow is shaped for *packages*, not apps, and pulls in opinionated defaults.
    sources: https://github.com/VeryGoodOpenSource/very_good_coverage | https://github.com/VeryGoodOpenSource/very_good_workflows | https://workflows.vgv.dev/
  - (high) Companion action major versions have all moved past what 2024-2025 Flutter tutorials show
    actions/checkout@v6 (shown in flutter-action's own current README example); actions/setup-java@v5 (v5.5.0, 2026-07-08, adds verify-signature for Temurin); actions/upload-artifact@v6 (2026-02-25, Node 24 by default) with v7 adding non-zipped artifacts (archive: false); codecov/codecov-action@v5.
    sources: https://github.com/subosito/flutter-action | https://github.com/actions/setup-java/releases | https://github.com/actions/upload-artifact/releases | https://github.blog/changelog/2026-02-26-github-actions-now-supports-uploading-and-downloading-non-zipped-artifacts/
  - (medium) Codecov v5 supports tokenless upload for public repos, so it remains free-and-frictionless for an OSS app
    'The v5 release also coincides with the opt-out feature for tokens for public repositories' — tokenless is enabled via org settings. PRs from forks to upstream public repos support tokenless unconditionally (contributors don't need the upstream token). Requires bash/curl/git/gpg on the runner and actions/checkout to run first. For a solo repo, Codecov's value is the PR comment; the enforcement gate is better done locally in the workflow so the build fails without a network round-trip.
    sources: https://github.com/codecov/codecov-action | https://about.codecov.io/blog/tokenless-uploads-for-github-actions/
  - (high, LOAD-BEARING) Flutter's own docs state obfuscation is not a security control, and it breaks runtime type-name matching
    docs.flutter.dev/deployment/obfuscate: 'Obfuscating your code does not encrypt resources nor does it protect against reverse engineering. It only renames symbols with more obscure names.' Caveats: release builds only; `expect(foo.runtimeType.toString(), equals('Foo'))` won't work; enum names are NOT obfuscated; you must back up the SYMBOLS file or you can never de-obfuscate. --obfuscate requires --split-debug-info=<dir>. Supported targets include apk, appbundle, ios, ipa. Symbolization: `flutter symbolize -i <trace-file> -d <app.android-arm64.symbols>` — needs the arch-specific symbols file from the exact build.
    sources: https://docs.flutter.dev/deployment/obfuscate
  - (medium, LOAD-BEARING) Obfuscation is actively harmful for this specific app — it destroys the only field signal and its benefit is nil once the source is public
    The threat model obfuscation addresses (reverse-engineering) is void when the exit plan is publishing the source. Meanwhile the app's only crash signal is a user-exported on-device log; an obfuscated trace requires the developer to still exist, to have retained the per-build per-arch .symbols file, and to run `flutter symbolize`. After abandonment (explicitly planned), every crash report ever filed becomes permanently unreadable. Additionally --obfuscate breaks runtimeType string matching — a silent-failure vector in a codebase whose stated worst bug class is silence. Without --split-debug-info, AOT release stack traces retain Dart function names and are directly readable in the exported log, at a cost of a few MB.
    sources: https://docs.flutter.dev/deployment/obfuscate
  - (medium, LOAD-BEARING) R8 minification failures surface as 'Missing classes detected while running R8' with a generated rules file, and are a runtime-silent-failure risk
    R8 writes suggested keep rules to build/app/outputs/mapping/release/missing_rules.txt. Real Flutter plugin cases exist (flutter/flutter#155458 for camera + google_sign_in_android; flutter_stripe#2139; razorpay-flutter#415). Fixes are broad `-keep class com.x.** { *; }` + `-dontwarn`. Crucially, a *missing* keep rule for a reflectively-loaded class does not fail the build — it fails at runtime, which for this app means a tile tap producing no speech. flutter_tts drives android.speech.tts.TextToSpeech over a platform channel rather than reflection, so risk is lowish, but the payoff on a 12-tile app is also near-zero.
    sources: https://github.com/flutter/flutter/issues/155458 | https://arahimli.medium.com/troubleshooting-r8-minification-errors-in-flutter-my-journey-to-a-solution-ac88cc43fae3 | https://www.devsecopsnow.com/error-missing-classes-detected-while-running-r8/
  - (high, LOAD-BEARING) Golden tests are OS-dependent; the 2026 consensus is to make CI authoritative rather than chase cross-platform tolerance
    macOS applies font smoothing that Linux doesn't; goldens generated on macOS fail on ubuntu-latest runners (flutter/flutter#36667 — goldens are inconsistent across both OS versions and Flutter versions). Options: (a) match CI OS to dev OS, (b) Alchemist's separate CI/local golden folders, (c) per-platform tolerance. The May-2025-onward recommendation is to match environments rather than make tests platform-agnostic. Flutter defaults to the Ahem font (renders boxes) unless you load real fonts via flutter_test_config.dart.
    sources: https://github.com/flutter/flutter/issues/36667 | https://medium.com/@m1nori/flutter-golden-tests-fail-in-github-actions-why-and-how-to-fix-65e3b69ee86e | https://hevawu.github.io/blog/2022/04/13/Run-Flutter-Golden-Tests-Between-MacOS-And-CI
  - (high, LOAD-BEARING) Emulator integration tests in CI are slow and flaky, and cannot verify the thing that actually matters here (real audio)
    ReactiveCircus/android-emulator-runner@v2 is the standard action. Reported Flutter drive runs exceeding 15 minutes (issue #47); 'Connecting to the VM Service timed out' failures (#95837 made the timeout configurable); flutter driver hangs (#35); green-locally/red-in-CI nondeterminism (#183). Mitigation is a two-step AVD snapshot cache (create clean snapshot, then run with no-snapshot-save). Decisive point for this app: a CI emulator's TTS engine is not a real device's TTS engine, so the failure modes that motivate the whole design — setVoice returning 0 with only a Log.d, a network_required voice vanishing, an .ambient audio session muted by the silent switch — are exactly what an emulator cannot reproduce.
    sources: https://github.com/ReactiveCircus/android-emulator-runner | https://github.com/ReactiveCircus/android-emulator-runner/issues/47 | https://github.com/flutter/flutter/issues/95837 | https://github.com/ReactiveCircus/android-emulator-runner/discussions/183
  - (high, LOAD-BEARING) Dependabot does not support pub; Renovate does, including a Flutter SDK datasource
    dependabot-core#2166 ('Support for Dart/Flutter languages', opened 2019-04-07, label T: new-ecosystem) is closed without pub support shipping. Renovate's pub manager matches /(^|/)pubspec\.ya?ml$/ by default and extracts the dart, dart-version, and flutter-version datasources; a dedicated flutter-version datasource (packageName flutter/flutter) can bump the SDK pin in .fvmrc and workflow files via a custom regex manager. dependabot_gen exists on pub.dev but generates config for other ecosystems, not pub itself.
    sources: https://github.com/dependabot/dependabot-core/issues/2166 | https://docs.renovatebot.com/modules/manager/pub/ | https://docs.renovatebot.com/modules/datasource/flutter-version/
  - (high, LOAD-BEARING) The standard github/gitignore Dart template ignores pubspec.lock by default — wrong for an app, and a real footgun
    Dart.gitignore contains `pubspec.lock` preceded by the comment 'If you're building an application, you may want to check-in your pubspec.lock'. It ignores build/ and pub metadata. It does NOT ignore *.g.dart — committing generated code is not fought by the standard template. dart.dev/tools/pub/private-files is the canonical 'what not to commit' reference. For this app the lock file MUST be committed: it is the only thing making a stranger's clone resolve the same flutter_tts/drift versions you tested against.
    sources: https://github.com/github/gitignore/blob/main/Dart.gitignore | https://dart.dev/tools/pub/private-files
  - (high, LOAD-BEARING) drift ships first-class schema export + migration test generation, and the dump is CI-verifiable by diff
    `dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/` writes drift_schema_vX.json named by the current schemaVersion (it must be re-run every time the schema changes and the version is incremented). `dart run drift_dev schema generate` with --data-classes/--companions emits old-version snapshots so migration tests can assert against historical schemas. `make-migrations` requires the database location declared in build.yaml. Drift does not document a dedicated CI 'verify' command — but re-running the dump and asserting `git diff --exit-code drift_schemas/` is an exact equivalent and catches the 'changed schema, forgot to bump schemaVersion' bug that loses a user's board.
    sources: https://drift.simonbinder.eu/migrations/exports/ | https://drift.simonbinder.eu/migrations/tests/ | https://drift.simonbinder.eu/migrations/step_by_step/
  - (medium) lcov 2.x on ubuntu-24.04 runners is strict and will fail builds that worked under lcov 1.x
    ubuntu-24.04 ships lcov 2.x, which promotes previously-benign conditions (unused --remove patterns, mismatched paths, inconsistent counts) to hard errors. `lcov --remove` filtering of *.g.dart/*.freezed.dart needs `--ignore-errors unused` (and often `--ignore-errors inconsistent`) to survive. This is a common silent CI breakage when pinning runners forward.
    sources: https://github.com/linux-test-project/lcov
  - (high, LOAD-BEARING) Play versionCode is monotonic and permanently consumed; deriving it from github.run_number is a common and unrecoverable trap
    flutter build appbundle --build-number=N sets versionCode. Play rejects any AAB whose versionCode is <= one already uploaded to that track, and a versionCode is burned even if the release is deleted/rolled back. github.run_number is per-workflow-file and resets to 1 if the workflow is renamed or recreated — which silently makes every subsequent build unuploadable until you manually jump past the high-water mark. `version: 1.0.0+7` committed in pubspec.yaml is the auditable alternative, and matches the exit plan (a successor reads the repo, not your Actions history).
    sources: https://docs.flutter.dev/deployment/android | https://docs.fastlane.tools/actions/supply/
  - (medium, LOAD-BEARING) For v1 release automation, r0adkll/upload-google-play is materially simpler than fastlane, but manual upload is simpler than both
    fastlane supply/upload_to_play_store handles metadata, screenshots, binaries, track selection and promotion — a real win for teams shipping frequently, at the cost of a Ruby toolchain, a Google Play service account JSON in CI secrets, and a fastlane/metadata tree. r0adkll/upload-google-play@v1 is a single step (serviceAccountJsonPlainText, packageName, releaseFiles, track, status). Neither pays for itself across the ~6 internal-track uploads of a 2-week MVP. Decisive: a successor forking an abandoned open-source app will have their own Play account, their own service account, and their own signing key — your release automation is the one part of the repo they cannot reuse.
    sources: https://docs.fastlane.tools/actions/supply/ | https://github.com/r0adkll/upload-google-play | https://medium.com/@garoono/flutter-ci-cd-with-github-actions-build-test-ship-on-autopilot-1934c698568e
  - (medium, LOAD-BEARING) Committing .g.dart is defensible here specifically because drift's generated code is the schema, and *.g.dart linguist-generated=true removes the usual objection
    The standard objection to committing codegen is diff noise and merge conflicts — merge conflicts are void for a solo dev, and diff noise is solved by a .gitattributes entry `*.g.dart linguist-generated=true`, which collapses those files in PR diffs and excludes them from GitHub language stats. The pro-commit arguments are project-specific and strong: (1) a stranger's `git clone && flutter run` works with no build_runner round-trip; (2) a drift migration PR shows the *actual schema delta* as a reviewable diff, turning migration review into a safety gate rather than a leap of faith; (3) it pins generated output against future drift_dev versions producing different code after abandonment. The staleness risk is fully mitigated by a CI `build_runner build --delete-conflicting-outputs && git diff --exit-code` step.
    sources: https://github.com/github/gitignore/blob/main/Dart.gitignore | https://medium.com/@catzoy/cut-down-on-dart-files-generation-with-a-single-git-attribute-5bcb614f0135
  - (medium, LOAD-BEARING) Apache-2.0 is the license that best fits an app designed to outlive its author; GPL-3.0 actively obstructs the succession path
    The goal is that a stranger can fork the repo and ship it to Play under their own account after abandonment. Apache-2.0 is permissive (no relicensing friction), and unlike MIT includes an express patent grant plus a trademark clause — relevant because the app name/branding should NOT transfer with a fork, while the code should. GPL-3.0 would force forks open but creates well-known friction with app-store distribution (the store's DRM/ToS vs GPLv3 §6 anti-tivoization) and adds a compliance burden that deters exactly the casual maintainer you want. MPL-2.0 is a coherent middle ground: per-file copyleft keeps improvements to the AAC core open while permitting store distribution. Recommend Apache-2.0 + NOTICE; the no-telemetry promise is enforced by the code being readable, not by the license.
    sources: https://www.apache.org/licenses/LICENSE-2.0 | https://choosealicense.com/licenses/apache-2.0/ | https://www.mozilla.org/en-US/MPL/2.0/FAQ/
  - (high, LOAD-BEARING) ADRs are the one piece of team ceremony that is worth more to a solo dev than to a team, given the abandonment plan
    The prior research pass produced decisions whose rationale is invisible in the code and actively counter-intuitive: grid_slots PRIMARY KEY (board_id, row, col) with a NULLABLE button_id looks like a normalization mistake to any competent reviewer, but it is what makes tile reflow structurally impossible; audio_session .playback (not .ambient) looks like an oversight; the voice_filter's setVoice return-value check looks like defensive noise because flutter_tts returns 0 with only a Log.d on failure; Riverpod looks over-engineered for 12 tiles and is documented as deliberately not load-bearing. Every one of these is a decision a stranger (or the author in six months) will 'clean up' and thereby reintroduce the exact failure the design prevents. ADRs cost ~20 min each and are the only durable defense.
    sources: https://adr.github.io/ | https://github.com/joelparkerhenderson/architecture-decision-record
  - (medium) Conventional commits + semantic-release are not worth it for this repo; a handwritten keepachangelog CHANGELOG is
    Conventional commits pay off via automated changelog generation and multi-contributor PR triage — neither applies pre-open-sourcing. The CHANGELOG, by contrast, has two real consumers regardless of contributor count: Play Console release notes (which must be written anyway) and a stranger evaluating whether the project is alive. keepachangelog.com's Added/Changed/Fixed/Removed structure under an Unreleased heading is the low-ceremony fit. If contributors ever arrive, VeryGoodOpenSource/very_good_workflows ships a semantic_pull_request workflow that enforces the convention on PR titles only — adopt it then, not now.
    sources: https://keepachangelog.com/en/1.1.0/ | https://www.conventionalcommits.org/ | https://github.com/VeryGoodOpenSource/very_good_workflows
  - (high, LOAD-BEARING) For an app (unlike a package), caret ranges in pubspec.yaml plus a committed pubspec.lock is correct — pinning exact versions in pubspec is an anti-pattern
    The lock file is what pins; exact pins in pubspec.yaml only break transitive resolution and produce unsolvable version conflicts on the next flutter upgrade. Packages must use wide ranges (they don't ship a lock); apps get reproducibility from the lock. `dart pub outdated` reports resolvable vs latest and is the manual review command. Project-specific caveat: an automated bump of flutter_tts or audio_session can silently change voice availability or session category behaviour — those are the two packages whose Renovate PRs must never merge on green CI alone, because no test in the suite can observe whether a real device produced sound.
    sources: https://dart.dev/tools/pub/dependencies | https://dart.dev/tools/pub/cmd/pub-outdated | https://docs.renovatebot.com/modules/manager/pub/

CODE EXAMPLES:
  --- .github/workflows/ci.yml — the whole PR gate (format, analyze, codegen freshness, schema freshness, test + per-dir coverage, goldens, build) ---
```yaml
name: ci

on:
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: read

jobs:
  verify:
    # Pinned, not -latest: goldens are byte-compared, so the runner image is part
    # of the contract. See docs/adr/0007-goldens-are-ci-authoritative.md
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v6

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          # Exact pin lives in .fvmrc; flutter-action reads it natively, so CI and
          # local fvm can never disagree. Ranges are NOT supported here.
          flutter-version-file: .fvmrc
          cache: true
          pub-cache: true

      - run: flutter --version
      - run: flutter pub get

      # --- Freshness gates -------------------------------------------------
      # Generated code is committed (docs/adr/0005-commit-generated-code.md).
      # These two steps are the entire mitigation for that decision.

      - name: Generated code is up to date
        run: |
          dart run build_runner build --delete-conflicting-outputs
          if ! git diff --exit-code -- '*.g.dart' '*.drift.dart'; then
            echo "::error::Generated code is stale. Run build_runner and commit the result."
            exit 1
          fi

      - name: drift schema dumps are up to date
        run: |
          dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
          if ! git diff --exit-code -- drift_schemas/; then
            echo "::error::drift_schemas/ is stale."
            echo "::error::You changed the schema without bumping schemaVersion + dumping."
            echo "::error::Shipping this means no migration runs and users lose their boards."
            exit 1
          fi

      # --- Static analysis --------------------------------------------------

      - run: dart format --output=none --set-exit-if-changed .

      # --fatal-infos: the a11y lints in analysis_options.yaml are only worth
      # having if they can fail a build.
      - run: flutter analyze --fatal-infos

      # --- Tests ------------------------------------------------------------

      - name: Test
        run: |
          flutter test --coverage \
            --test-randomize-ordering-seed random \
            --reporter expanded

      - name: Coverage floors
        run: |
          sudo apt-get update -qq
          sudo apt-get install -y -qq lcov
          bash tool/check_coverage.sh coverage/lcov.info

      - name: Upload coverage report on failure
        if: failure()
        uses: actions/upload-artifact@v6
        with:
          name: coverage-lcov
          path: coverage/lcov.info
          retention-days: 7

  build-android:
    needs: verify
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v6

      - uses: actions/setup-java@v5
        with:
          distribution: temurin
          java-version: '17'
          cache: gradle

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
          cache: true
          pub-cache: true

      - run: flutter pub get

      # Unsigned. CI proves it compiles; releases are built and signed locally
      # for v1 (docs/RELEASE.md). No keystore in GitHub secrets.
      #
      # No --obfuscate and no --split-debug-info: the on-device exportable crash
      # log is the ONLY field signal this app will ever have, and both flags
      # strip the Dart names it depends on. See docs/adr/0006-no-obfuscation.md
      - name: Build app bundle (unsigned)
        run: flutter build appbundle --release

      - uses: actions/upload-artifact@v6
        with:
          name: app-release-unsigned-aab
          path: build/app/outputs/bundle/release/app-release.aab
          retention-days: 14

```
  Action versions current as of 2026-07. No third-party actions beyond flutter-action. Goldens are pinned to ubuntu-24.04 and are authoritative.
  --- tool/check_coverage.sh — per-directory coverage floors with no third-party action ---
```bash
#!/usr/bin/env bash
# tool/check_coverage.sh — enforce per-directory line-coverage floors.
#
# Why not VeryGoodOpenSource/very_good_coverage? Archived 2026-03-31.
# Why not Codecov's gate? It needs a network round-trip and an account to fail
# a build. This script still works in 2030 with no upstream to rot.
#
# Usage: bash tool/check_coverage.sh [coverage/lcov.info]
set -euo pipefail

LCOV_FILE="${1:-coverage/lcov.info}"

if [[ ! -f "$LCOV_FILE" ]]; then
  echo "::error::$LCOV_FILE not found. Did 'flutter test --coverage' run?"
  exit 1
fi

# Strip generated + non-logic files. lcov 2.x (shipped on ubuntu-24.04) errors
# on unused --remove patterns, hence --ignore-errors unused.
FILTERED="$(mktemp)"
lcov --remove "$LCOV_FILE" \
  '*/*.g.dart' \
  '*/*.drift.dart' \
  '*/*.freezed.dart' \
  '*/generated/*' \
  '*/l10n/*' \
  --output-file "$FILTERED" \
  --ignore-errors unused >/dev/null

# prefix:floor -- ordered most-specific first.
#
# lib/data     100 : a botched migration is the loss of someone's voice. There is
#                    no telemetry and no server backup; the boards are
#                    hand-curated over months and unmergeable.
# lib/speech   100 : voice_filter + SpeechService. flutter_tts returns 0 with only
#                    a Log.d when setVoice fails. A gap here is a user tapping a
#                    tile mid-shutdown and getting silence.
# lib/          70 : presentation. Goldens cover layout; this is a floor, not a goal.
FLOORS=(
  "lib/data/:100"
  "lib/speech/:100"
  "lib/:70"
)

pct_for_prefix() {
  awk -v prefix="$1" '
    /^SF:/ { f = substr($0, 4); keep = (index(f, prefix) == 1); next }
    keep && /^DA:/ {
      split(substr($0, 4), a, ",")
      total++
      if (a[2] + 0 > 0) hit++
    }
    END {
      if (total == 0) { print "NA"; exit }
      printf "%.2f", (hit / total) * 100
    }
  ' "$FILTERED"
}

failed=0
for entry in "${FLOORS[@]}"; do
  prefix="${entry%%:*}"
  floor="${entry##*:}"
  pct="$(pct_for_prefix "$prefix")"

  if [[ "$pct" == "NA" ]]; then
    echo "::warning::no covered lines found under $prefix (floor ${floor}%)"
    continue
  fi

  if awk -v p="$pct" -v f="$floor" 'BEGIN { exit (p + 0 >= f + 0) ? 0 : 1 }'; then
    printf '  ok   %-14s %6s%%  (floor %s%%)\n' "$prefix" "$pct" "$floor"
  else
    printf '  FAIL %-14s %6s%%  (floor %s%%)\n' "$prefix" "$pct" "$floor"
    echo "::error file=$prefix::coverage ${pct}% is below the ${floor}% floor"
    failed=1
  fi
done

rm -f "$FILTERED"
exit "$failed"

```
  Replaces the archived very_good_coverage. A single global percentage would let you pass at 85% with the migration path untested; these floors put 100% where a bug is unrecoverable.
  --- .github/workflows/update-goldens.yml — regenerate goldens on the CI runner, never on your Mac ---
```yaml
name: update-goldens

# macOS applies font smoothing that Linux runners don't, so goldens generated
# locally will fail on CI (flutter/flutter#36667). Rather than chase tolerances,
# goldens are ONLY ever generated on the CI runner. You never run
# --update-goldens on your own machine.
#
# Run this from the Actions tab after an intentional UI change, then review the
# committed PNGs by eye.

on:
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update:
    runs-on: ubuntu-24.04  # must match ci.yml exactly
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v6
        with:
          ref: ${{ github.ref_name }}

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
          cache: true
          pub-cache: true

      - run: flutter pub get

      - name: Regenerate goldens
        run: flutter test --update-goldens --tags golden

      - name: Show what changed
        run: git status --porcelain -- test/

      - name: Commit goldens
        run: |
          if git diff --quiet -- test/; then
            echo "No golden changes."
            exit 0
          fi
          git config user.name  "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add test/
          git commit -m "chore: update goldens (ubuntu-24.04)"
          git push

      - name: Upload goldens for eyeball review
        uses: actions/upload-artifact@v6
        with:
          name: goldens
          path: test/**/goldens/**/*.png
          retention-days: 14

```
  Avoids the macOS-font-smoothing vs Linux golden mismatch entirely, with no Docker and no Alchemist. Run it from the Actions tab after an intentional UI change.
  --- test/flutter_test_config.dart — real fonts, so goldens actually prove text fits ---
```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Flutter's test renderer defaults to the 'Ahem' font, which draws every glyph
// as a filled box. A golden rendered in Ahem cannot tell you whether
// "Overwhelmed" overflows its tile at TextScaler 3.0 -- which is the entire
// reason these goldens exist. Load the real font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await _loadFont('Inter', 'assets/fonts/Inter-Regular.ttf');
  await _loadFont('Inter', 'assets/fonts/Inter-SemiBold.ttf');

  // Fail loudly rather than silently emitting Ahem goldens.
  goldenFileComparator = LocalFileComparator(
    Uri.parse('${Directory.current.path}/test/'),
  );

  await testMain();
}

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
  await loader.load();
}

```
  Without this, Flutter renders the Ahem font (solid boxes) and a passing golden proves nothing about a 200%-scaled label fitting in a tile.
  --- test/ui/board_grid_golden_test.dart — the goldens that make TextScaler a tested property, not a promise ---
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // TextScaler must be honoured at 200%+ and never clamped. That is a
  // correctness requirement, so it needs a gate, not discipline.
  // 3.0 is not paranoia: Android's font size + display size settings compound.
  for (final scale in <double>[1.0, 2.0, 3.0]) {
    testWidgets(
      'board grid at textScale ${scale}x',
      tags: 'golden',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const MaterialApp(home: BoardScreen()),
          ),
        );

        // Zero animation is a design rule, so pump() -- not pumpAndSettle() --
        // is sufficient. If this ever needs pumpAndSettle, something animated
        // and that is itself the bug.
        await tester.pump();

        await expectLater(
          find.byType(BoardScreen),
          matchesGoldenFile('goldens/board_grid_${scale}x.png'),
        );
      },
    );
  }
}

```
  'Accessibility is correctness' only holds if a build can fail on it. This is that mechanism for the 200%+ requirement.
  --- .fvmrc + pubspec.yaml — where the pins live ---
```yaml
# .fvmrc  -- committed. flutter-action@v2 reads this natively.
# Must be an exact version; ranges are not supported by flutter-version-file.
{
  "flutter": "3.44.0"
}

# ---------------------------------------------------------------------------
# pubspec.yaml (excerpt)

name: offline_aac
description: Offline AAC board for situational speech loss. No network, ever.

# 1.0.0 = versionName, +7 = versionCode.
#
# Bumped by hand in the release commit. NOT derived from github.run_number:
# run_number resets if the workflow file is renamed, and a Play versionCode is
# permanently consumed even by a deleted release -- a reset silently makes every
# subsequent build unuploadable. The committed number is also what a successor
# reads; they will not have your Actions history.
version: 1.0.0+7

publish_to: none

environment:
  # Ranges here, exact pin in .fvmrc. Pinning exact versions in pubspec only
  # manufactures unsolvable conflicts on the next SDK upgrade.
  sdk: ^3.9.0
  flutter: '>=3.44.0'

dependencies:
  flutter:
    sdk: flutter
  drift: ^2.28.0
  flutter_riverpod: ^3.0.0
  flutter_tts: ^4.2.0
  audio_session: ^0.2.0
  path_provider: ^2.1.5
  sqlite3_flutter_libs: ^0.5.32

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.15
  drift_dev: ^2.28.0
  flutter_lints: ^6.0.0

# Caret ranges + a COMMITTED pubspec.lock is the app answer (packages ship no
# lock and so need wide ranges; apps get reproducibility from the lock).
# Delete the `pubspec.lock` line that github/gitignore's Dart template ships with.

```
  The exact Flutter pin goes in .fvmrc (read by both fvm and flutter-action). pubspec keeps normal ranges so pub can still solve. versionCode is committed, never derived from run_number.
  --- renovate.json — pub updates, SDK bumps, and a hard block on the two packages CI cannot vouch for ---
```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended", ":semanticCommitsDisabled"],
  "timezone": "Europe/Amsterdam",
  "schedule": ["before 9am on monday"],
  "prConcurrentLimit": 3,
  "labels": ["dependencies"],

  "packageRules": [
    {
      "description": "Batch dev-only bumps; they cannot reach a user.",
      "matchManagers": ["pub"],
      "matchDepTypes": ["dev_dependencies"],
      "groupName": "dev dependencies",
      "automerge": true
    },
    {
      "description": [
        "NEVER automerge the speech surface. flutter_tts returns 0 with only a",
        "Log.d when setVoice fails, and audio_session decides whether the silent",
        "switch mutes the app. A minor bump can change either with no test in the",
        "suite able to observe it -- there is no telemetry, so a regression here",
        "is discovered by a user in crisis tapping a tile and getting silence.",
        "Requires docs/RELEASE_CHECKLIST.md on a real device before merge."
      ],
      "matchManagers": ["pub"],
      "matchPackageNames": ["flutter_tts", "audio_session"],
      "automerge": false,
      "labels": ["dependencies", "needs-device-test"],
      "prBodyNotes": [
        "**Do not merge on green CI alone.** No automated test in this repo can",
        "observe whether a real device produced sound. Run",
        "`docs/RELEASE_CHECKLIST.md` sections 1-3 on hardware, with the ringer",
        "switch OFF, before merging."
      ]
    },
    {
      "description": "drift bumps regenerate committed code and touch the schema.",
      "matchManagers": ["pub"],
      "matchPackageNames": ["drift", "drift_dev", "sqlite3_flutter_libs"],
      "groupName": "drift",
      "automerge": false,
      "labels": ["dependencies", "needs-migration-review"]
    }
  ],

  "customManagers": [
    {
      "description": "Bump the Flutter SDK pin in .fvmrc (Dependabot cannot do this at all).",
      "customType": "regex",
      "managerFilePatterns": ["/^\\.fvmrc$/"],
      "matchStrings": ["\"flutter\"\\s*:\\s*\"(?<currentValue>[^\"]+)\""],
      "datasourceTemplate": "flutter-version",
      "depNameTemplate": "flutter",
      "packageNameTemplate": "flutter/flutter",
      "versioningTemplate": "semver"
    }
  ]
}

```
  Dependabot has never supported pub (dependabot-core#2166, closed). The flutter_tts / audio_session rule is the load-bearing part: green CI is not evidence of audio.
  --- .gitignore and .gitattributes — the two edits that make committed codegen painless ---
```bash
# ---------------------------------------------------------------------------
# .gitattributes
# ---------------------------------------------------------------------------
# Generated code IS committed (docs/adr/0005). These two lines remove the only
# real cost: GitHub collapses these files in diffs by default and drops them
# from the repo's language statistics. A drift migration diff stays readable.
*.g.dart        linguist-generated=true
*.drift.dart    linguist-generated=true
*.freezed.dart  linguist-generated=true

# Goldens are binary and only ever regenerated by CI. Never merge them.
*.png binary -merge

# ---------------------------------------------------------------------------
# .gitignore
# ---------------------------------------------------------------------------
# Based on github/gitignore Dart.gitignore + Flutter template, WITH ONE
# DELIBERATE DEVIATION, see below.

.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
doc/api/

# NOTE: the upstream Dart.gitignore lists `pubspec.lock` here, with the comment
# "If you're building an application, you may want to check-in your
# pubspec.lock". We ARE an application, so the lock is COMMITTED and that line
# is deliberately absent. The lock is the only thing that makes a stranger's
# clone resolve the exact flutter_tts / drift versions that were tested against
# a real device. Do not re-add it.

# fvm: the config is committed, the SDK symlink is not.
.fvm/flutter_sdk
.fvm/versions

# Android
/android/app/debug
/android/app/profile
/android/app/release
/android/key.properties
*.jks
*.keystore

# iOS
/ios/Flutter/Flutter.framework
/ios/Flutter/Flutter.podspec
/ios/Pods/
/ios/.symlinks/

# Coverage
coverage/

# Editors
.idea/
*.iml
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
.DS_Store

```
  The standard github/gitignore Dart template ignores pubspec.lock — wrong for an app. linguist-generated collapses .g.dart in diffs, which removes the main objection to committing them.
  --- android/app/build.gradle.kts — R8 off, on purpose, with the reason in the file ---
```kotlin
android {
    namespace = "dev.example.offline_aac"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "dev.example.offline_aac"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode  // from pubspec `version: x.y.z+N`
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // v1 ships release builds signed with a LOCAL upload key
            // (docs/RELEASE.md). CI builds are unsigned; the keystore is never
            // in GitHub secrets.
            signingConfig = signingConfigs.getByName("upload")

            // R8 IS DELIBERATELY OFF. This is a decision, not an oversight --
            // do not "fix" it. See docs/adr/0008-no-r8-for-v1.md
            //
            // A missing keep rule does not fail the build; it fails at RUNTIME,
            // when a reflectively-resolved class is gone. In this app that means
            // a user taps a tile mid-shutdown and nothing is spoken -- the worst
            // bug class we have, and one we would never learn about because
            // there is no telemetry, by design and by promise.
            //
            // The payoff would be a few hundred KB on a 12-tile app with no
            // heavy dependencies. That is not a trade worth making.
            //
            // If this is ever revisited: R8 writes suggested rules to
            //   build/app/outputs/mapping/release/missing_rules.txt
            // and you MUST archive mapping.txt per release, plus re-run the full
            // on-device checklist -- unit tests cannot catch a stripped class.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

```
  A missing R8 keep rule fails at runtime, not at build time — which in this app means a tile tap producing no speech. Explicit-and-commented beats relying on a template default the next maintainer will 'fix'.
  --- docs/adr/0001-grid-slots-position-is-the-primary-key.md — the ADR template, and the one that matters most ---
```markdown
# 1. grid_slots: position is the primary key

- Status: accepted
- Date: 2026-07-15
- Deciders: @zakariafatahi

## Context

Users hand-curate a 3x4 board of phrase tiles over months. Muscle memory is the
entire point: in a shutdown, the user does not read the grid, they reach for
"the bottom-left one". A tile that MOVES is worse than a tile that is missing,
because the user presses it and says the wrong thing at the worst moment.

The obvious schema -- a `buttons` table with an `order` column, or a
`grid_slots` table with a surrogate `id` -- makes reflow *possible*. Every
ordered-list schema eventually reflows: a delete shifts everything up, a
reordering bug shifts everything sideways, a botched migration renumbers. You
then defend against it with application logic, and the defense is one forgotten
`WHERE` clause from failing silently.

## Decision

`grid_slots` uses `PRIMARY KEY (board_id, row, col)` with a **nullable**
`button_id`.

Position is not an attribute of a tile. Position is the identity of the slot.
An empty cell is a row with `button_id IS NULL`, not an absent row. Deleting a
button nulls a slot; it cannot shift its neighbours, because a neighbour's
identity is its coordinates and nothing can renumber coordinates.

## Consequences

- Tile reflow is structurally impossible. Not "prevented by a test" -- there is
  no schema-legal way to express it. This is the point.
- A nullable FK inside a composite PK **looks like a normalization mistake.** It
  is not. If you are reading this because you were about to introduce a
  surrogate `id` and an `order` column: that change reintroduces the exact
  failure this schema exists to prevent, and no test will catch it because the
  bug only manifests as a real person saying the wrong sentence.
- Grids are fixed-size, so the row count is bounded (12/board). Storing empty
  slots costs nothing.
- Board resize is not supported and is not planned. If it ever is, it is a
  migration that inserts/deletes slot rows, not a reordering.

## Alternatives rejected

- **`buttons.order` integer**: reflow on delete is the default behaviour. Would
  need defending in every query.
- **Surrogate `grid_slots.id`**: permits two rows claiming the same (row, col).
  The DB should not be able to represent an impossible board.

```
  This is the highest-leverage artifact in the repo. The decision looks like a normalization error to any competent reviewer, which is exactly why it needs a written defense that outlives you.
  --- docs/RELEASE.md — the minimum viable v1 release, and why there is no fastlane ---
```markdown
# Releasing

v1 is released **from a laptop**, by hand. This is a deliberate choice, not a
TODO. See "Why not automated" below before adding fastlane.

## Steps

1. `git checkout main && git pull` -- confirm CI is green.
2. Bump `version:` in `pubspec.yaml` (e.g. `1.0.0+7` -> `1.0.1+8`).
   - The `+N` build number is the Play **versionCode**. It must strictly
     increase and is **permanently consumed** even by a deleted release. Never
     reuse one.
3. Update `CHANGELOG.md` (move items out of `## [Unreleased]`). These lines are
   the Play release notes -- write them for a user, not a developer.
4. Commit: `chore(release): 1.0.1+8`. Tag: `git tag v1.0.1 && git push --follow-tags`.
5. `flutter build appbundle --release`
   - **No `--obfuscate`. No `--split-debug-info`.** See
     `docs/adr/0006-no-obfuscation.md`. Both strip the Dart function names that
     the on-device exportable crash log depends on, and that log is the only
     field signal this app will ever have.
6. Run `docs/RELEASE_CHECKLIST.md` on a **real device**, ringer switch OFF.
   Do not skip. No automated test in this repo can observe whether sound came out.
7. Upload `build/app/outputs/bundle/release/app-release.aab` to the Play Console
   **internal testing** track. Paste the changelog entry as release notes.
8. Attach the .aab to the GitHub Release for the tag, so the artifact for any
   version outlives the Play Console account.

## Signing

- Play App Signing is **enrolled**. Google holds the app signing key; this
  keystore is only the *upload* key.
- The upload key is therefore **replaceable** -- if it is lost, Google support
  resets it. Nothing about a user's data depends on it.
- The users' boards are **not** replaceable. There is no server, no account and
  no backup. That asymmetry is the whole reason migration tests are a gate.
- Keystore lives in 1Password + an offline backup. It is NOT in GitHub secrets:
  CI builds unsigned, so there is no signing secret to leak.
- `android/key.properties` is gitignored. Template in `docs/key.properties.example`.

## Why not automated

fastlane `supply` and `r0adkll/upload-google-play` both work fine. Neither is
worth it here:

- The MVP ships to internal testing maybe six times. Automation costs more hours
  than it saves, and every hour spent on the pipeline is an hour not spent on
  the migration tests that are the actual safety net.
- Automating it means putting the keystore and a Play service-account JSON into
  CI secrets -- a real attack surface bought for a two-minute manual step.
- **The succession argument cuts against automation, not for it.** A stranger
  forking this app after it is abandoned will have their own Play account, their
  own service account and their own signing key. Release automation is precisely
  the part of this repo they cannot reuse. A README they can read beats a
  pipeline they must dismantle.

Revisit if releases become frequent enough that step 7 is the bottleneck. It
won't be.

```
  This doubles as the succession document. Note the deliberate reasoning that release automation is the one part of the repo a successor cannot reuse.
  --- docs/RELEASE_CHECKLIST.md — what replaces emulator integration tests ---
```markdown
# Pre-release device checklist

Run on a **real phone**. Every item below is something a CI emulator cannot
verify -- an emulator's TTS is not a device's TTS. This checklist is not a
placeholder for an integration-test suite we haven't written yet; it is the
deliberate replacement for one. See `docs/adr/0009-no-emulator-tests-in-ci.md`.

## 1. Speech actually happens

- [ ] Tap all 12 tiles. **Audible speech** on each. (Not "no exception thrown".)
- [ ] Type in the field, hit speak. Audible.
- [ ] Set the ringer/silent switch to **SILENT**, tap a tile. **Still audible.**
      (If not: the audio session regressed to `.ambient`. This is the bug that
      makes the app useless in the exact meeting where you need it.)
- [ ] Start a YouTube video, then tap a tile. Other audio **ducks**, speech is
      clearly audible over it, other audio resumes.

## 2. Voices did not silently vanish

- [ ] Settings -> voice picker lists only voices that actually work.
- [ ] Pick each listed voice, speak. Audible for **every** one.
      (`flutter_tts` `setVoice` returns 0 with only a `Log.d` on failure --
      a voice can be listed and silently do nothing.)
- [ ] **Turn wifi and mobile data OFF.** Repeat the above. Any network-required
      voice must be gone from the list, not present-and-mute.
- [ ] In Android TTS settings, uninstall a voice the app has selected. Reopen
      the app, tap a tile. Falls back to a working voice **audibly** -- never
      silence.

## 3. Accessibility

- [ ] TalkBack on: swipe through all 12 tiles. Each announces its **label**
      ("Overwhelmed"), not its vocalization.
- [ ] TalkBack double-tap speaks the **vocalization** ("I need to leave...").
- [ ] Switch Access: can reach and activate every tile and the text field.
- [ ] System font size to max + display size to max. Grid still 3x4, no label
      clipped, no overflow stripe.

## 4. Data survives

- [ ] Install the **previous** released version, create/edit tiles, then
      install this build over it. **Every board is intact.**
      (This is the one that matters. There is no backup and no server.)
- [ ] Quick Settings tile speaks with the app force-stopped (no Flutter engine).

## 5. Crash log

- [ ] Trigger a known crash in a debug build; export the log.
- [ ] The stack trace has **readable Dart function names**. If it shows hex
      offsets, `--split-debug-info` or `--obfuscate` crept into the build and
      the only field signal this app has is dead.

```
  This is the honest artifact. Every item here is something a CI emulator structurally cannot verify, which is the argument for not building that CI job at all.
  --- README.md — the structure that lets a stranger pick this up ---
```markdown
# Offline AAC

A one-screen communication board for autistic adults with situational or
part-time speech loss. Twelve phrase tiles and a type-to-speak field. Speaks
on-device. No accounts, no server, no network permission.

A tile **shows** "Overwhelmed" and **speaks** "I need to leave, I'm not able to
talk right now." Those are two different strings, on purpose
(`docs/adr/0002-label-is-not-vocalization.md`).

## Status

Maintained: <yes/no -- keep this line honest>. Licensed Apache-2.0 so that if
it says "no", you can fork it, ship it under your own Play account, and not ask
anyone's permission. That is the intended end state, not a failure mode.

## Run it

```sh
dart pub global activate fvm   # optional; .fvmrc pins the SDK
fvm install && fvm use
flutter pub get
flutter run
```

Generated code (`*.g.dart`, `*.drift.dart`) **is committed**, so this works
without a `build_runner` round-trip (`docs/adr/0005`). If you change the schema:

```sh
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
```

CI fails if you forget either.

## Read this before changing anything

`docs/adr/` -- ~6 short files. Several decisions in this codebase **look wrong**
and are load-bearing:

- `grid_slots` has a nullable FK inside a composite primary key. Not a mistake:
  it makes tile reflow structurally impossible (ADR 0001).
- The audio session is `.playback`, never `.ambient`. Not an oversight: `.ambient`
  lets the silent switch mute the app (ADR 0004).
- `voice_filter` checks `setVoice`'s return value. Not paranoia: `flutter_tts`
  returns 0 with only a `Log.d` on failure (ADR 0003).
- Riverpod is used for twelve tiles and a text field. It is **not** load-bearing;
  it is a testable seam. `ValueNotifier` would work (ADR 0010).

If you "clean up" any of these, you reintroduce the exact failure it prevents,
and **no test and no crash report will tell you** -- see Non-goals.

## Non-goals

These are refused, not un-built:

- **No telemetry, no analytics, no crash reporting.** Not Firebase, not Sentry.
  The audience reads privacy labels adversarially and the promise is the product
  (`docs/PRIVACY.md`). The consequence is deliberate and severe: **nobody will
  ever learn that this app crashed on a user's phone.** That is why the coverage
  floor on `lib/data` and `lib/speech` is 100% and why `docs/RELEASE_CHECKLIST.md`
  is not optional. Tests are the only safety net that exists.
- **No animation.** Latency and distress. The UI is deterministic.
- **No accounts, no sync, no cloud backup.** Boards are irreplaceable *because*
  of this. That is the trade.
- **No network permission at all.** Check the manifest; it is the only claim in
  `docs/PRIVACY.md` a user can verify themselves.

## Layout

```
lib/data/     drift DB, migrations   -- 100% coverage floor, migrations are a safety gate
lib/speech/   SpeechService, voice_filter -- 100% floor, silence is the worst bug
lib/ui/       one screen             -- goldens cover TextScaler 1x/2x/3x
docs/adr/     why things are the way they are
```

## License

Apache-2.0. The name and icon are not covered -- fork the code, pick your own
name.

```
  Non-goals and the ADR pointer are the load-bearing sections. A stranger's first instinct will be to add the things this app deliberately omits.
  --- .github/workflows/release.yml — only if you later decide to sign in CI ---
```yaml
name: release

# NOT USED FOR v1 -- docs/RELEASE.md ships from a laptop on purpose.
# Kept here so the option is a decision rather than a research task.
# Adopting this means accepting a keystore + Play service account in GH secrets.

on:
  push:
    tags: ['v*']

permissions:
  contents: write   # to create the GitHub Release

jobs:
  android:
    runs-on: ubuntu-24.04
    timeout-minutes: 25
    steps:
      - uses: actions/checkout@v6

      - uses: actions/setup-java@v5
        with:
          distribution: temurin
          java-version: '17'
          cache: gradle

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
          cache: true
          pub-cache: true

      - run: flutter pub get

      - name: Decode upload keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: |
          echo "$KEYSTORE_BASE64" | base64 --decode > android/app/upload-keystore.jks
          # Sanity-check the decode; an empty/corrupt file yields an unsigned
          # build that fails only at upload time.
          test -s android/app/upload-keystore.jks

      - name: Write key.properties
        env:
          STORE_PASSWORD: ${{ secrets.ANDROID_STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
        run: |
          cat > android/key.properties <<EOF
          storeFile=upload-keystore.jks
          storePassword=${STORE_PASSWORD}
          keyAlias=${KEY_ALIAS}
          keyPassword=${KEY_PASSWORD}
          EOF

      # versionCode comes from pubspec (`version: 1.0.1+8`), NOT from
      # github.run_number -- run_number resets when a workflow is renamed, and a
      # Play versionCode is permanently consumed even by a deleted release.
      # No --obfuscate / --split-debug-info: see docs/adr/0006.
      - name: Build app bundle
        run: flutter build appbundle --release

      - name: Clean up signing material
        if: always()
        run: rm -f android/app/upload-keystore.jks android/key.properties

      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          gh release create "${{ github.ref_name }}" \
            build/app/outputs/bundle/release/app-release.aab \
            --title "${{ github.ref_name }}" \
            --notes "See CHANGELOG.md"

      # Play upload deliberately NOT automated. Uploading to a live track is the
      # one step where a human should have to look at what they are shipping --
      # there is no telemetry to catch a bad release afterwards, and no server to
      # roll back. Run docs/RELEASE_CHECKLIST.md first, then upload the .aab from
      # the Release page by hand.
      #
      # If that ever changes:
      #   - uses: r0adkll/upload-google-play@v1
      #     with:
      #       serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
      #       packageName: dev.example.offline_aac
      #       releaseFiles: build/app/outputs/bundle/release/app-release.aab
      #       track: internal
      #       status: completed

```
  Provided for completeness; docs/RELEASE.md recommends against it for v1. Includes the keystore-in-secrets pattern and the cleanup step people forget.

FACT-CHECK:
    - [CONFIRMED] subosito/flutter-action is still on v2 in 2026 — there is no v3, and it is actively maintained
    - [CONFIRMED] VeryGoodOpenSource/very_good_coverage is ARCHIVED as of 2026-03-31 — most tutorials still recommend it
    - [CONFIRMED] Flutter's own docs state obfuscation is not a security control, and it breaks runtime type-name matching
    - [CONFIRMED] Obfuscation is actively harmful for this specific app — it destroys the only field signal and its benefit is nil once the source is public
    - [PARTIALLY_TRUE] "flutter-action@v2 reads .fvmrc directly — this is the 2026 reproducible-pinning answer, and it removes the need to install fvm in CI"
      CORRECTION: Keep the recommendation — it holds in 2026 and flutter-action@v2 is still the current major (v2.23.0). Fix the file syntax: .fvmrc is JSON parsed with `jq -r '.flutter'`, so the pin is `{"flutter": "3.44.0"}`, NOT `flutter: 3.44.0`. The `flutter: 3.19.0` vs `flutter: ">= 3.19.0 <4.0.0"` good/bad examples come from pubspec.yaml's `environment:` block (parsed `yq eval '.environment.flutter'`) and do not describe .fvmrc. Also: exact versions are not the only accepted value — `stable`/`beta`/`master`/`main` are special-cased into the channel with VERSION=any. fvm_config.json is deprecated and still readable, but is NOT auto-migrated: FVM 4.1.2 warns "Consider migrating to .fvmrc by running: fvm use <version>" and requires that manual step. And FVM gitignores the entire `.fvm/` directory (under a `# FVM Version Cache` heading), not just the `.fvm/flutter_sdk` symlink; `.fvmrc` sits at project root and is committed. Worth adding to the corpus: picking .fvmrc over pubspec.yaml also skips the `choco install yq` step on Windows runners, since .fvmrc is parsed with jq.
    - [PARTIALLY_TRUE] "R8 minification failures surface as 'Missing classes detected while running R8' with a generated rules file, and are a runtime-silent-failure risk"
      CORRECTION: Correct the flutter_tts rationale only; the decision-relevant conclusion stands. flutter_tts does NOT avoid reflection — FlutterTtsPlugin.kt imports java.lang.reflect.Field and uses declaredFields + isAccessible=true in ismServiceConnectionUsable() to probe the private mServiceConnection field of android.speech.tts.TextToSpeech. The right reason the R8 risk is near-zero is that this reflection targets an Android *framework* class on the boot classpath, which is not in the app's DEX and is therefore never shrunk or renamed by R8 (and the call is try/catch-guarded with a safe default). The plugin ships no consumer-rules.pro and its README documents no keep rules. Also note two path corrections for anyone reading the source: the Android implementation is Kotlin, not Java, and the package is com.eyedeadevelopment.fluttertts (formerly com.tundralabs.fluttertts) — the old Java path no longer exists. Current version is flutter_tts 4.2.5.
    - [PARTIALLY_TRUE] "Golden tests are OS-dependent; the 2026 consensus is to make CI authoritative rather than chase cross-platform tolerance"
      CORRECTION: Replace "Flutter defaults to the Ahem font (renders boxes)" with: "Flutter's default test font has been FlutterTest, not Ahem, since March 2023 (engine PRs #40188/#40352). It still renders boxes, so you must still load real fonts via flutter_test_config.dart — but Ahem is now opt-in via an explicit fontFamily. Alchemist's CI mode is one of the few places Ahem is still pinned deliberately."

Replace the #36667 citation with flutter/flutter#184182, where a Flutter team member states goldens "are generally only reliable when run on a machine with the exact same configuration (OS version, OS settings, etc) as the one used to produce the original image." #36667 is real but CLOSED and dates to 2019.

Downgrade "the 2026 consensus" to "one widely-cited May 2025 blog post recommends." No primary source establishes consensus, and the ecosystem is visibly split: Alchemist (alive, betterment.dev, v0.14.0) implements the opposite strategy — deliberately platform-agnostic CI goldens via box-glyph rendering.

Fix option (b): Alchemist is not "separate CI/local golden folders" — it is two test modes (platform tests with real text vs CI tests with text replaced by colored squares).

Also worth noting for the ci-release decision: OS-matching is necessary but not sufficient. #184182 shows a macOS POINT RELEASE (26.4) invalidated goldens on the same OS family, so "match CI OS to dev OS" still breaks on OS updates unless the runner image is pinned. That strengthens the case for making CI authoritative — but for a reason the claim never gives.

RECOMMENDATIONS:
  - [must] Pin Flutter with a committed .fvmrc containing an exact version, and consume it in CI via `subosito/flutter-action@v2` with `flutter-version-file: .fvmrc`. Do not install fvm in CI. — flutter-action v2 natively reads .fvmrc, so one file pins both the local fvm SDK and CI with zero extra steps. Keeps pubspec's environment constraint a normal range (which pub needs) while the exact pin lives where it belongs. Reproducibility matters more than usual here: after abandonment, the pinned version is the only record of what the app was ever tested against.
  - [must] Use actions/checkout@v6, subosito/flutter-action@v2, actions/setup-java@v5 (temurin 17), actions/upload-artifact@v6. Do not use VeryGoodOpenSource/very_good_coverage. — These are the current majors as of 2026-07. very_good_coverage was archived 2026-03-31 and is still recommended by most Flutter CI tutorials — adopting it means adopting a dead dependency on day one.
  - [must] Enforce the coverage floor with a committed lcov shell script (tool/check_coverage.sh), not a third-party action or service. Use per-directory floors: 100% on lib/data (drift/migrations) and lib/speech (voice_filter/SpeechService), ~70% elsewhere. — A single global percentage is theatre; it lets you hit 85% on widget fluff while the migration path is untested. With no telemetry, tests are the only safety net, and the two directories where a bug is unrecoverable (lost boards, silence) are the two that warrant a hard 100%. A shell script also has no supply-chain or archival risk — it still works in 2030.
  - [must] Add a CI step that runs `dart run build_runner build --delete-conflicting-outputs` and fails on `git diff --exit-code -- '*.g.dart' '*.drift.dart'`. — This is the entire mitigation for the only real downside of committing generated code. Without it, committed codegen silently drifts from its source and the repo lies to the next reader.
  - [must] Add a CI step that re-runs `dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/` and fails on `git diff --exit-code -- drift_schemas/`. — Catches the exact bug that loses a user's voice: changing the schema without incrementing schemaVersion, so no migration ever runs and the next release opens a DB whose shape doesn't match the code. Drift documents no verify command, but the dump-and-diff is equivalent and costs one step.
  - [must] Commit .g.dart / .drift.dart files, add `*.g.dart linguist-generated=true` and `*.drift.dart linguist-generated=true` to .gitattributes, and commit pubspec.lock (delete the `pubspec.lock` line the standard Dart.gitignore ships with). — A stranger's `git clone && flutter run` must work with no build_runner round-trip — that is the exit plan's minimum bar. Drift's generated code is the schema, so migration diffs become reviewable safety artifacts. linguist-generated collapses the noise in diffs. The lock file is what makes a stranger resolve the flutter_tts version you actually tested.
  - [avoid] Do not ship --obfuscate. Do not ship --split-debug-info for v1 either. — Obfuscation protects nothing once the source is public (the exit plan), and Flutter's own docs say it is not a security control. Both flags strip the Dart function names from AOT stack traces, which is the one thing the on-device exportable crash log depends on — and after abandonment nobody will have the per-build .symbols file to run `flutter symbolize`, making every crash report ever filed permanently unreadable. --obfuscate additionally breaks runtimeType string matching, a silent-failure vector. The cost of not obfuscating is a few MB.
  - [should] If app size ever forces the issue, enable --split-debug-info WITHOUT --obfuscate and attach the entire symbols directory to the GitHub Release for that tag. — This resolves the tension honestly rather than choosing a side. Names get stripped from the binary (size win), but the symbols are public and permanent, so any stranger — not just you — can run `flutter symbolize -i trace.txt -d app.android-arm64.symbols` on a user's exported log years after you stop maintaining it. Obfuscation is the part with no upside; split-debug-info's downside is fully repaired by publishing the symbols.
  - [should] Explicitly set `isMinifyEnabled = false` and `isShrinkResources = false` in android/app/build.gradle.kts release buildType for v1, with a comment explaining why. — A missing R8 keep rule does not fail the build — it fails at runtime, meaning a tile tap produces no speech. That is precisely this app's worst bug class, traded against a negligible size win on a 12-tile app with no heavy dependencies. Being explicit (rather than relying on template defaults) also tells the next maintainer this was a decision, not an oversight.
  - [should] Run golden tests only on ubuntu-24.04 and treat CI as authoritative. Provide a workflow_dispatch 'update-goldens' job that regenerates with --update-goldens and commits the PNGs back. — macOS font smoothing makes locally-generated goldens fail on Linux runners. Matching environments is the current consensus fix, and a dispatch job gets you that without Docker or Alchemist — you never generate goldens on your Mac at all. Worth the setup here because the golden's job is to catch the 3x4 grid breaking at TextScaler 2.0/3.0, which is a correctness property, not polish.
  - [must] Load real fonts in test/flutter_test_config.dart before running goldens, and assert the grid at textScaleFactor 1.0, 2.0 and 3.0. — Flutter's default Ahem font renders boxes, so a golden that passes proves nothing about text fitting in a tile. Since TextScaler must be honoured at 200%+ and never clamped, the 2.0/3.0 goldens are the enforcement mechanism for that requirement — otherwise it's discipline, and discipline is what the constraints say cannot be relied on.
  - [avoid] Do not run emulator integration tests in PR CI. Replace them with a committed docs/RELEASE_CHECKLIST.md of manual on-device checks, executed before every internal-track upload. — 15+ minute runs, documented VM-service timeouts and hangs, and green-local/red-CI nondeterminism — for a check that cannot observe the thing that matters. A CI emulator's TTS is not a real device's TTS, so it cannot catch setVoice returning 0 with only a Log.d, a network_required voice vanishing, or an .ambient session muted by the silent switch. Those need a real phone with the ringer switched off, and a checklist is the honest tool for that.
  - [should] For v1, build and sign release AABs locally and upload to the Play internal track by hand. Do not adopt fastlane. Do not put the keystore in GitHub secrets. — Proportionate to ~6 uploads across a 2-week MVP. CI's job is catching regressions, not shipping; keeping the keystore off CI removes an entire secret-management surface. Fastlane's cost (Ruby toolchain, service-account JSON, metadata tree) doesn't amortize, and it is the one part of the repo a successor cannot reuse — they will have their own Play account, service account and signing key.
  - [must] Enroll in Play App Signing, back the upload keystore up offline in two places, and record in docs/RELEASE.md that the upload key is replaceable but the boards are not. — Play App Signing means a lost upload key is recoverable via Google support rather than fatal. The note matters for succession: a stranger forking the app needs to know they generate their own upload key and that nothing about the user's data depends on it.
  - [must] Manage versionCode by committing `version: 1.0.0+N` in pubspec.yaml and bumping it in the release commit. Never derive --build-number from github.run_number. — run_number resets to 1 if the workflow file is renamed or recreated, silently producing unuploadable builds, and a Play versionCode is permanently consumed even by a deleted release. The committed value is auditable and is what a successor reads.
  - [should] Use Renovate (not Dependabot) for pub. Configure the pub manager plus a custom manager using the flutter-version datasource to bump .fvmrc. — Dependabot has never supported pub — dependabot-core#2166 is closed without shipping it. Renovate's pub manager auto-discovers pubspec.yaml and its flutter-version datasource can bump the SDK pin, which is the piece a solo dev otherwise forgets for a year.
  - [must] Add a Renovate package rule that labels any flutter_tts or audio_session update `needs-device-test` and never auto-merges it, regardless of green CI. — Green CI is not evidence of audio. These two packages sit exactly on the silence surface — a minor bump can change voice availability behaviour or session category semantics with no test able to observe it. Encoding that in renovate.json makes the rule survive the developer forgetting it.
  - [must] Keep caret ranges in pubspec.yaml and rely on the committed pubspec.lock for pinning. Do not pin exact versions in pubspec.yaml. — This is the app (not package) answer: the lock pins, the ranges keep resolution solvable. Exact pins in pubspec only manufacture version conflicts on the next SDK upgrade.
  - [must] Write ~6 short ADRs in docs/adr/ before writing the code they describe: grid_slots position-as-PK, label-vs-vocalization, no telemetry, SpeechService + voice_filter, audio session .playback, Riverpod-as-seam (explicitly noting it is not load-bearing). — This is the highest-leverage artifact in the whole dimension, and it is worth more to a solo dev than to a team precisely because of the abandonment plan. Every one of those decisions looks like a mistake to a competent stranger — a nullable FK in a composite PK reads as a normalization error, .playback reads as an oversight, checking a setVoice return reads as paranoia. Without the ADR, the next maintainer 'fixes' them and reintroduces the exact failure the design exists to prevent.
  - [should] License under Apache-2.0 with a NOTICE file, and state in README that the app name/icon are not covered by the code license. — The goal is that a stranger can fork and ship to Play under their own account after you stop. Apache-2.0 is permissive with an express patent grant and a trademark clause — the code transfers, the branding doesn't (which also protects users from a hostile fork trading on the original's privacy reputation). GPL-3.0 would obstruct store distribution and deter the casual maintainer you want; MPL-2.0 is a reasonable middle ground if keeping AAC-core improvements open matters more than adoption.
  - [should] Ship docs/PRIVACY.md from day one as the single source of truth for the no-telemetry promise, and derive the Play Data Safety declaration from it. — The audience reads privacy labels adversarially, so the label and the code must not diverge. One committed file that says 'no network permission, no analytics, no accounts' makes the claim auditable against the manifest by anyone, and makes the Data Safety form a transcription rather than a judgement call each release.
  - [should] Write a handwritten CHANGELOG.md in keepachangelog format. Skip conventional commits, commitlint, and semantic-release. — The changelog has two real consumers regardless of team size: Play release notes (which must be written anyway) and a stranger deciding whether the project is alive. The commit-convention tooling only pays off via changelog automation and multi-contributor triage, neither of which exists pre-open-sourcing. Adopt very_good_workflows' semantic_pull_request check if contributors ever arrive.
  - [avoid] Skip: branch protection, PR-based workflow, CODEOWNERS, Codecov, issue templates, and a staging/beta track — until the repo is public. — All of these coordinate multiple humans. A solo dev on main with green CI gets the same safety at zero friction. They cost ~an hour each to add on the day you open-source, so adding them now is pure prepayment. Codecov specifically: its value is the PR comment, and there are no PRs — keep the local lcov gate instead, which fails the build without a network round-trip or a third-party account.
  - [should] Add `--test-randomize-ordering-seed random` to the CI test command. — Free detection of inter-test state leakage, which matters disproportionately when tests are the only safety net and much of the suite touches a shared in-memory drift database.

---

### DIMENSION: performance-startup
SUMMARY: The honest answer is that ~85% of Flutter performance advice is irrelevant to this app, and the most important performance fact is that Flutter is not the bottleneck. A static 12-tile grid with zero animation has no jank, no list virtualization, no repaint boundary, no shader warmup, and no rebuild-scoping problem — those are all solved by the design, not by engineering. The one metric that matters is time-from-tap-to-audible-speech, and its dominant term is not Flutter's first frame (realistically 700ms–1.8s process-spawn-to-first-frame on a $120 Android phone, well under the 5s Android vitals "excessive" bar) but Android's TextToSpeech service binding, which is documented at 1–5+ seconds on real devices and is entirely outside Flutter's control. This reframes the whole dimension: the performance work is (a) warm the TTS engine off the critical path at startup, (b) never let anything block the first frame, and (c) recognize that the already-decided Quick Settings TileService reading SharedPreferences with no Flutter engine IS the cold-start fix — it is the fastest path to speech in the entire product and should be treated as the primary performance feature, not a convenience. Two non-obvious risks survive the pruning: user-imported images must be downscaled at import time (a 12MP photo × 12 tiles is an OOM kill on a 2GB phone, and with no telemetry an OOM is a permanently invisible bug), and Impeller's OpenGL ES fallback on sub-Vulkan devices has open rendering-corruption bugs, which argues for flat solid-color tiles over gradients/vector art — a rendering-correctness rule, not a speed one. Deferred components should be explicitly refused: they require Play Core and Play delivery, which conflicts with the no-network promise and sideload/F-Droid distribution. Measurement is one command (`flutter run --profile --trace-startup`) plus `adb shell am start -W`, run on the cheapest physical device, once, before release — not a practice, an event.

FINDINGS:
  - (high, LOAD-BEARING) TTS engine binding, not Flutter startup, dominates time-to-first-word on Android
    flutter_tts issue #235 documents 5+ seconds before speech actually starts on real Android devices (not reproducible on emulator) — this is Android TextToSpeech service bind/init, not Flutter. For comparison, Flutter engine init + Dart VM snapshot load + first frame on a low-end device is a few hundred ms to ~1.5s. The TTS term is larger than the entire Flutter term and is invisible to every Flutter profiling tool. Apps targeting Android 11+ must also declare <queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries> in the manifest or engine discovery fails outright.
    sources: https://github.com/dlutton/flutter_tts/issues/235 | https://pub.dev/packages/flutter_tts
  - (high, LOAD-BEARING) The already-decided Quick Settings TileService is the single highest-leverage performance decision in the project
    A Kotlin TileService that reads SharedPreferences and calls Android TextToSpeech natively with NO Flutter engine on that path skips process-spawn-of-Flutter, engine init, Dart VM snapshot load, drift open, and first frame entirely. It is plausibly an order of magnitude faster to speech than the app path. The engineering consequence: the SharedPreferences mirror must be a write-through cache updated on EVERY board edit, and that sync is a testable invariant (edit a tile in Dart → assert the SharedPreferences value changed). A stale mirror means the QS tile speaks the OLD phrase — a silent correctness failure with no telemetry to catch it.
    sources: 
  - (medium, LOAD-BEARING) `flutter run --profile --trace-startup` measures from engine-enter, not from process spawn, and therefore undercounts real cold start
    It writes build/start_up_info.json containing engineEnterTimestampMicros, timeToFrameworkInitMicros, timeAfterFrameworkInitMicros, timeToFirstFrameRasterizedMicros, timeToFirstFrameMicros. All of these begin at engine enter — Android process fork, zygote, Application onCreate, and libflutter.so load happen BEFORE the clock starts. To get the user-perceived number you need `adb shell am start -W -n <pkg>/.MainActivity` (reports ThisTime/TotalTime/WaitTime = time to initial display) and the logcat `ActivityTaskManager: Fully drawn <pkg>/<activity>: +NNNms` line, which corresponds to Flutter's first rendered frame via reportFullyDrawn.
    sources: https://docs.flutter.dev/perf/ui-performance | https://developer.android.com/topic/performance/vitals/launch-time
  - (medium, LOAD-BEARING) Android vitals treats cold start ≥5s as excessive; this app has enormous headroom and does not need cold-start optimization work
    Android vitals thresholds: cold ≥5s, warm ≥2s, hot ≥1.5s are 'excessive', measured as TTID (time to initial display) over a 28-day window. A Flutter app with one screen, no plugins doing work in main(), and a 12-row DB read is realistically 700ms–1.8s cold on a $120–150 device (Snapdragon 4-series / Helio G-series class). The gap between 'realistic' and 'excessive' is ~3s. Cold-start micro-optimization is therefore NOT a good use of the 2-week budget; the only rule needed is 'do not block the first frame'.
    sources: https://developer.android.com/topic/performance/vitals/launch-time | https://support.google.com/googleplay/android-developer/answer/9844486
  - (high, LOAD-BEARING) Deferred components are unusable for this project and should be explicitly refused
    Flutter deferred components on Android require `implementation "com.google.android.play:core"`, FlutterPlayStoreSplitApplication (or manual SplitCompat), a PlayStoreDeferredComponentManager injected via FlutterInjector, and Play Store dynamic-feature delivery — i.e. a network fetch from Google Play at runtime. That contradicts the no-network promise, breaks sideload/F-Droid distribution, and adds ~6 manual config steps. It is also pointless: the entire Dart app is a few hundred KB of the binary.
    sources: https://docs.flutter.dev/perf/deferred-components
  - (high) Shader warmup / SkSL is dead and must not be attempted
    Impeller precompiles shaders at engine-build time, so there is zero runtime shader compilation. `--bundle-sksl-path` and `--cache-sksl-path` were removed (users report 'Could not find an option named --bundle-sksl-path' on Flutter 3.32+). flutter/flutter#132418 tracks removing the old warm-up logic entirely. Any 2021–2023 blog post recommending SkSL warmup is actively wrong in 2026. For a zero-animation app it would have been irrelevant regardless.
    sources: https://github.com/flutter/flutter/issues/171585 | https://github.com/flutter/flutter/issues/132418 | https://docs.flutter.dev/perf/impeller
  - (high, LOAD-BEARING) Impeller is irrelevant to this app's speed but relevant to its rendering correctness on cheap devices
    Impeller is default on Android API 29+ and preferentially uses Vulkan (needs Vulkan 1.1+); API 28 and below, or devices without Vulkan, unconditionally fall back to OpenGL ES. On iOS Impeller is the only renderer — Skia cannot be re-enabled. For a static grid the renderer choice has no measurable perf impact. BUT the GL fallback path has open rendering bugs: flutter/flutter#179268 (gradients rendered incorrectly after Vulkan→GLES fallback) and #177873 (SVG/vector-graphics crash or corruption after GLES fallback). A budget/old device is exactly the population that lands on the fallback.
    sources: https://docs.flutter.dev/perf/impeller | https://github.com/flutter/flutter/issues/179268 | https://github.com/flutter/flutter/issues/177873 | https://github.com/flutter/flutter/issues/151240
  - (high, LOAD-BEARING) Memory is irrelevant EXCEPT for one thing: user-imported tile images must be downscaled at import, not at render
    12 tiles, no lists, no animation → no memory pressure from Flutter. But images are user-supplied files on disk. A 12MP phone photo decodes to ~48MB in RAM (4000×3000×4 bytes). Twelve of those is ~576MB of image cache — an OOM kill on a 2GB device. Flutter's ImageCache default is 1000 entries / 100MB, which does not save you because it evicts by count/bytes AFTER decode. The fix belongs at import time: re-encode the picked image to tile-sized (e.g. max 512px) and write THAT to disk, so the DB path points at a small file forever. Render-time cacheWidth/ResizeImage is a weaker second line of defense. With no telemetry, an OOM kill is a bug the developer will never learn about.
    sources: 
  - (high) const constructors do not matter for performance at 12 tiles, but the lint is still worth enabling for two non-performance reasons
    Mechanism (worth stating correctly since it's a code standard): const expressions are canonicalized at compile time, so two identical const Widget instances are the SAME object. In Element.updateChild, the framework checks `child.widget == newWidget` and, when true, skips rebuilding that subtree entirely — const-ness makes that check true for free via identity. Const objects also live in the AOT snapshot's read-only data rather than being heap-allocated at runtime, a marginal startup/allocation win. At 12 tiles rebuilt approximately never (zero animation!), the runtime saving is unmeasurable. Keep `prefer_const_constructors` anyway because (a) it's zero-effort — the analyzer writes it for you, and (b) const is a readability signal to the stranger who inherits this repo: 'this widget has no dynamic inputs'. Do not spend a single minute hand-tuning const-ness.
    sources: 
  - (medium) Icon-font tree shaking is automatic but silently disabled by dynamically-constructed IconData
    flutter build tree-shakes icon fonts by default (build output prints e.g. 'Font asset MaterialIcons-Regular.otf was tree-shaken, reducing it by 99.4%'). It is disabled by --no-tree-shake-icons, and it BREAKS — the build errors or you must pass --no-tree-shake-icons — if IconData is constructed non-const (e.g. IconData(userSelectedCodePoint)). An edit mode offering an icon picker is exactly the shape of code that trips this, costing ~1.5MB. Mostly moot here since the decision is images-on-disk, but it's the trap to know if an icon picker is ever added.
    sources: https://docs.flutter.dev/perf/app-size
  - (medium, LOAD-BEARING) Baseline Flutter Android release size is ~5–8MB (arm64); the app's own code is noise, and the sherpa_onnx/Kokoro path multiplies total size ~8x
    A minimal Flutter arm64 release APK is roughly 5–8MB (engine + Dart AOT snapshot + ICU data); Play-served download after AAB splitting is smaller. This app's Dart code, drift, and riverpod add maybe 1–2MB. So baseline ≈ 7–10MB. Adding sherpa_onnx + Kokoro-82M (+55MB) takes it to ~65MB — a ~7-8x increase. Critically, ONNX model files are architecture-independent assets, so AAB ABI splitting does NOT reduce them: every user downloads the full 55MB. On the target audience's cheap, storage-constrained phone this is an install-time barrier, and the offline promise forbids downloading it later.
    sources: https://docs.flutter.dev/perf/app-size | https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/index.html | https://github.com/k2-fsa/sherpa-onnx
  - (medium) Battery/thermal is a non-issue for platform TTS and a real-but-bounded issue only for the neural path
    Platform flutter_tts hands synthesis to a system service, often hardware-accelerated, for 2–5 second utterances triggered a few times an hour — energy cost is negligible and not worth measuring. The sherpa_onnx/Kokoro escape hatch runs an 82M-parameter model on CPU per utterance. For short, bursty utterances thermal throttling is not a realistic concern (throttling needs sustained load); the real cost is the ~80MB model resident in memory and a multi-hundred-ms model load on first use, which reintroduces both a memory floor and a warm-up requirement that the platform path doesn't have. sherpa-onnx's own Android guidance recommends ~500MB free storage and ARM64.
    sources: https://github.com/k2-fsa/sherpa-onnx | https://github.com/k2-fsa/sherpa-onnx/discussions/3383
  - (high, LOAD-BEARING) DevTools rebuild profiling, frame charts, and the Timeline are not worth learning for this app
    The Performance view's value is the Flutter frames chart (finding >16ms frames), Frame analysis (jank hints), Track widget builds / Track layouts / Track paints, and rendering-layer toggles (Clip/Opacity/PhysicalShape). Every one of these exists to diagnose jank during animation or scrolling. This app has zero animation, no scrolling, and 12 widgets. There are no frames to analyze after the first one. The ONE DevTools feature with real value here is the App Size tool (a different screen entirely), used to read the --analyze-size JSON.
    sources: https://docs.flutter.dev/tools/devtools/performance | https://docs.flutter.dev/perf/app-size
  - (high, LOAD-BEARING) Debug-mode performance numbers are meaningless and profiling must happen on a physical low-end device
    Flutter docs are explicit: 'Using debug mode, or running apps on simulators or emulators, is generally not indicative of the final behavior of release mode builds.' Debug uses JIT, enables asserts, and skips AOT snapshot loading — the exact mechanism being measured at startup. Profile mode compiles nearly identically to release but retains tracing hooks. Compounding this for THIS app: the flutter_tts startup delay is reported as NOT reproducible on emulator — so the single biggest latency term is invisible on the developer's fastest, most convenient test target.
    sources: https://docs.flutter.dev/perf/ui-performance | https://docs.flutter.dev/testing/build-modes | https://github.com/dlutton/flutter_tts/issues/235
  - (medium, LOAD-BEARING) The drift DB open — not the widget tree — is the only plausible Flutter-side first-frame blocker, and only via migration
    Reading 12 grid_slots rows is sub-10ms and can safely be awaited. The risk is a MIGRATION running on a hand-curated board on first launch after an update: that is unbounded work on the path to first speech, and it is the one startup case that could plausibly cross seconds. This intersects the 'botched migration = loss of voice' constraint. The practice is not 'make migration fast' — it's 'migration must never be on the QS-tile speech path', which the SharedPreferences design already guarantees, and 'the app path shows the grid shell immediately rather than a blank window while migrating'.
    sources: 

CODE EXAMPLES:
  --- Measure cold start correctly (the only perf command this project needs) ---
```bash
# 1) Flutter's own view — clock STARTS at engine enter, so it UNDERCOUNTS.
#    Writes build/start_up_info.json
flutter run --profile --trace-startup

cat build/start_up_info.json
# {
#   "engineEnterTimestampMicros": 1234567,
#   "timeToFrameworkInitMicros": 120000,        # engine enter -> framework ready
#   "timeToFirstFrameRasterizedMicros": 380000, # engine enter -> pixels on GPU
#   "timeToFirstFrameMicros": 350000,           # engine enter -> first frame built
#   "timeAfterFrameworkInitMicros": 230000      # your main()/runApp cost. THIS is the only one you control.
# }

# 2) The user-perceived number — includes process spawn + libflutter.so load.
adb shell am force-stop com.example.aac
adb shell am start -W -n com.example.aac/.MainActivity
# Status: ok
# TotalTime: 842      <- initial display (window bg), ms
# WaitTime: 851

# 3) The REAL first-Flutter-frame number (reportFullyDrawn):
adb logcat -c && adb shell am force-stop com.example.aac \
  && adb shell am start -n com.example.aac/.MainActivity \
  && adb logcat -d | grep -i "Fully drawn"
# ActivityTaskManager: Fully drawn com.example.aac/.MainActivity: +1s102ms

# Run each 5x on a PHYSICAL low-end device. Discard the first (page cache cold).
# Record the median in the README and move on.
```
  timeAfterFrameworkInitMicros is the only field you can influence — it is your main()/runApp work. If it is small, there is no Flutter startup work left to do, and further optimization is someone else's problem (Android, or the TTS engine).
  --- Warm TTS off the critical path — the highest-value perf code in the app ---
```dart
// The point: Android's TextToSpeech service bind can take seconds (flutter_tts#235).
// Pay that cost while the user is looking at the grid, NOT after they tap a tile.
// Rule: warming NEVER blocks the first frame and NEVER throws into the UI.

abstract class SpeechService {
  Future<void> warmUp();
  Future<void> speak(String text);
  Future<void> stop();
}

void main() {
  // Do NOT await anything here. Nothing between here and runApp().
  runApp(const AacApp());
}

class _AacAppState extends State<AacApp> {
  @override
  void initState() {
    super.initState();
    // Fires AFTER the first frame is on screen. The grid is already usable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_warm());
    });
  }

  Future<void> _warm() async {
    try {
      await ref.read(speechServiceProvider).warmUp();
    } catch (e, st) {
      // No telemetry exists. The on-device crash log is the ONLY record.
      await CrashLog.instance.record('tts warmUp failed', e, st);
      // Deliberately swallowed: a failed warm-up must not break the app.
      // The next speak() will retry and surface a VISIBLE failure if it can't speak.
    }
  }
}
```
  Warm-up is best-effort and must fail silently; speak() must fail LOUDLY. Those are opposite error-handling policies on the same service, and that asymmetry is the whole design.
  --- Downscale at import — makes the OOM structurally impossible ---
```dart
// A 12MP photo decodes to ~48MB in RAM. Twelve tiles = ~576MB = OOM kill
// on a 2GB phone. With no telemetry, that crash is NEVER reported to you.
//
// Fix it ONCE at import so the DB path can only ever point at a small file.
// This is the same philosophy as PRIMARY KEY (board_id, row, col):
// make the bad state unrepresentable rather than defending against it at render time.

import 'package:image/image.dart' as img;

const _maxTileEdge = 512; // ~1MB decoded, worst case

/// Returns the on-disk path to store in the images table.
Future<String> importTileImage(File picked, String imagesDir) async {
  final bytes = await picked.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Unsupported image format');
  }

  final resized = (decoded.width > _maxTileEdge || decoded.height > _maxTileEdge)
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? _maxTileEdge : null,
          height: decoded.height > decoded.width ? _maxTileEdge : null,
          interpolation: img.Interpolation.average,
        )
      : decoded;

  final out = File('$imagesDir/${DateTime.now().microsecondsSinceEpoch}.webp');
  await out.writeAsBytes(img.encodeWebP(resized, quality: 85));
  return out.path; // never the original
}

// Worth a test: import a synthetic 4000x3000 image, assert the stored file
// decodes to <= 512px on its long edge. That test is your only OOM safety net.
```
  Do this on a background isolate (Isolate.run) if import feels slow — but import is a rare, explicit, edit-mode action where a brief wait is acceptable. Do not pre-optimize it.
  --- Manifest: TTS engine visibility (Android 11+) ---
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest ...>
  <!-- Without this, package visibility HIDES the TTS engine on Android 11+.
       flutter_tts then returns an empty voice list with only a Log.d.
       Failure mode: user taps a tile mid-shutdown and NOTHING happens. -->
  <queries>
    <intent>
      <action android:name="android.intent.action.TTS_SERVICE" />
    </intent>
  </queries>

  <application ...>
    <!-- Impeller is default on API 29+ (Vulkan, GLES fallback below).
         Do NOT disable it. This meta-data is listed only so a future reader
         knows the escape hatch exists for bisecting a rendering bug:
    <meta-data android:name="io.flutter.embedding.android.EnableImpeller"
               android:value="false" /> -->
  </application>
</manifest>
```
  The <queries> block is a one-line manifest change that prevents a total, silent loss of speech on every Android 11+ device. It is arguably the highest value-per-character code in the project.
  --- App size baseline (run once, record, move on) ---
```bash
flutter build apk --release --analyze-size --target-platform android-arm64

# Terminal summary, roughly:
#   Dart AOT symbols accounted decompressed size: 2.1 MB
#   lib/arm64-v8a/libflutter.so ......... 5.4 MB   <- engine, immovable
#   lib/arm64-v8a/libapp.so ............. 2.1 MB   <- YOUR code + drift + riverpod
#   assets/ ............................. 0.3 MB
#   Total ............................... ~8 MB
#
# Also prints:
#   Font asset MaterialIcons-Regular.otf was tree-shaken, reducing it by 99.4%
#   ^ automatic. Breaks if you ever construct IconData dynamically.

# Deeper view (the ONE DevTools screen worth opening for this app):
dart devtools   # -> "Open app size tool" -> load the emitted
                #    ~/.flutter-devtools/apk-code-size-analysis_01.json

# Record the total in the README. If a future dependency doubles it,
# whoever inherits this repo will notice.
```
  Baseline is ~7-10MB and ~70% of it is the Flutter engine, which you cannot shrink. Do not chase app size; just document it so a regression is visible.
  --- analysis_options.yaml — the const rule, adopted for free ---
```yaml
# Adopt via lint, not via discipline or effort.
# Mechanism (why const is a real thing, even though it doesn't matter HERE):
#   const expressions are canonicalized at compile time -> identical const
#   widgets are the SAME object -> Element.updateChild's `child.widget == newWidget`
#   check is true by identity -> the framework skips rebuilding that subtree.
#   const objects also live in the AOT snapshot's read-only data, not the heap.
#
# Why it does NOT matter here: 12 tiles, zero animation, rebuilt ~never.
# Why we keep it anyway: the analyzer applies it for us (`dart fix --apply`),
# and const tells the stranger inheriting this repo "no dynamic inputs".

include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables

# NOT here on purpose: no custom perf lints. There is no perf problem to lint for.
```
  `dart fix --apply` does the whole job. Budget for const optimization: zero minutes.

FACT-CHECK:
    - [CONFIRMED] Deferred components are unusable for this project and should be explicitly refused
    - [PARTIALLY_TRUE] "TTS engine binding, not Flutter startup, dominates time-to-first-word on Android"
      CORRECTION: Directionally defensible, wrong evidence and overstated. Corrected version:

"Android TextToSpeech engine initialization is a real and often-overlooked cold-start cost that Flutter-side profiling doesn't surface by default. flutter_tts PR #594 (open, unmerged as of 2026-07) documents that binder IPC and voice deserialization run synchronously on the main thread inside `OnInitListener`, producing ANRs and crashes on the cold-start path. Budget for TTS init as a distinct term, initialize the engine eagerly and off the critical path, and await the first `speak()` rather than assuming it's instant."

Do NOT cite issue #235 for this — it was closed by its reporter as non-reproducible with no diagnosis. Cite **PR #594** instead, which contains the actual stack traces and root-cause analysis.

Drop "dominates," "larger than the entire Flutter term," and "invisible to every Flutter profiling tool" — none are sourced, and the last is wrong (measure the awaited channel call from Dart; use Perfetto/systrace for the native side). The "5+ seconds" figure has no methodology behind it; if the project decision depends on magnitude, measure on your actual target hardware rather than relying on a 2021 anecdote.

Keep the manifest requirement verbatim — it is correct and is the one hard, actionable fact in the claim.
    - [PARTIALLY_TRUE] "The already-decided Quick Settings TileService is the single highest-leverage performance decision in the project"
      CORRECTION: The ARCHITECTURE survives; the SUPERLATIVE and every load-bearing SPECIFIC fails. Four corrections, in order of how badly they hurt:

(1) THE TESTABLE INVARIANT AS SPECIFIED IS SELF-DEFEATING — this is the worst error. "Edit a tile in Dart → assert the SharedPreferences value changed" does NOT work as a Dart unit/widget test. `SharedPreferences.setMockInitialValues` is in-memory only and "will not persist values to the usual preference store." The test asserts a fake mutated a fake. It passes green while the Kotlin read path is broken — manufacturing false confidence in EXACTLY the silent failure the claim says it's guarding against. Worse, `setMockInitialValues` doesn't apply to the Async side at all (flutter/flutter#174643); with `SharedPreferencesWithCache` you get "Bad state: The SharedPreferencesAsyncPlatform instance must be set", and the workaround `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData({})` is still in-memory. CORRECT INVARIANT: an `integration_test` on a real device/emulator that writes via Dart and reads back through the actual native store (MethodChannel to Kotlin, or the same DataStore/XML file the TileService reads). Nothing less tests the mirror.

(2) "READS SHAREDPREFERENCES" IS WRONG BY DEFAULT ON CURRENT shared_preferences (2.5.5, flutter.dev, published ~3 months ago). Two independent traps: (a) the legacy `SharedPreferences` API is documented as "a legacy API that will be deprecated in the future"; the recommended `SharedPreferencesAsync` defaults to **DataStore Preferences**, NOT SharedPreferences XML — "In most cases you should use the default option of DataStore Preferences." A Kotlin `getSharedPreferences("FlutterSharedPreferences", ...)` reads NOTHING unless you explicitly opt into the SharedPreferences backend via `SharedPreferencesAsyncAndroidOptions`. (b) The legacy API prefixes EVERY key with `flutter.` — native `getString("phrase")` returns null; the key is `flutter.phrase`. `setPrefix` must be called before any instance is created or it fails. Also note DataStore is Flow/coroutine-based with no synchronous read — it adds latency on the one path that must be instant. Pick the backend deliberately and write it down.

(3) "SKIPS PROCESS-SPAWN-OF-FLUTTER" DESCRIBES A NONEXISTENT THING. There is no separate Flutter process — the engine runs in-process. TileService is a bound service in YOUR app's process, so a cold tile tap still pays zygote fork + ART/dex class load + `Application.onCreate`. (`FlutterApplication` is now a deprecated EMPTY shim, so it adds nothing — which is why the remaining spawn cost is plain-Android cost you cannot skip.) What IS genuinely skipped: FlutterActivity, FlutterEngine init, Dart VM snapshot load, drift open, first frame. Real and worth having — just smaller than "skips process spawn."

(4) "ORDER OF MAGNITUDE" IS UNVERIFIABLE AND THE HIDDEN DOMINANT TERM IS UNSKIPPED. No primary source measures Android `TextToSpeech` cold `onInit`/engine-bind latency — I searched and it is simply not documented. Both paths pay TTS engine bind + onInit, and the tile does NOT skip it. If that term dominates (plausible — it's an IPC bind to a separate TTS engine process, often hundreds of ms), the ratio collapses toward ~1x. This is a measurement, not an assertion: instrument tap→first-audio-frame on real hardware before any roadmap leans on it.

(5) "SINGLE HIGHEST-LEVERAGE" IS REFUTED BY REACH. Android docs are explicit that users must MANUALLY add tiles: swipe down, tap edit, scroll to find yours, hold and drag. `requestAddTileService` (Android 13 / API 33+) only shows a prompt the user can decline, and the docs advise calling it sparingly and in-context. So the tile is an Android-only, opt-in surface reaching a minority of a minority — while the in-app tile grid serves 100% of users on both platforms. A path most users never enable cannot be the highest-leverage performance decision. It's the FASTEST path (the project's own verified platform-integration research supports that), which is not the same claim. The highest-leverage performance decision is almost certainly app cold-start-to-interactive-grid, which every user pays every time.
    - [PARTIALLY_TRUE] "`flutter run --profile --trace-startup` measures from engine-enter, not from process spawn, and therefore undercounts real cold start"
      CORRECTION: The claim is directionally correct and safe to act on: --trace-startup does start its clock at engine enter and does undercount real cold start. Fix four specifics before publishing.

(1) Do not say "all of these begin at engine enter." Correct: engineEnterTimestampMicros is an absolute timeline timestamp; timeToFrameworkInitMicros, timeToFirstFrameMicros, and timeToFirstFrameRasterizedMicros are deltas from engine enter; timeAfterFrameworkInitMicros is firstFrameBuilt − frameworkInit, i.e. based at framework init, and is emitted conditionally.

(2) Replace the docs.flutter.dev/perf/ui-performance citation — it does not mention --trace-startup or start_up_info.json, and no docs.flutter.dev page currently does. Cite packages/flutter_tools/lib/src/tracing.dart in flutter/flutter directly.

(3) The Fully drawn tag is ActivityManager in Android's cited doc; ActivityTaskManager is what Android 10+ devices actually emit. Say so rather than asserting one.

(4) Qualify the reportFullyDrawn linkage: it holds only on API 29+ and only when hosting via FlutterActivity/FlutterFragmentActivity. Below API 29, or in add-to-app / FlutterFragment / custom-Activity setups, no Fully drawn line is emitted unless you call reportFullyDrawn() yourself — so a team relying on that logcat line for TTFD in an add-to-app product will get nothing.

Additional caveat worth adding for a startup-performance decision: `flutter run --trace-startup` launches the app through the tool with an attached VM service, which is not a representative cold start regardless of where the clock starts. For user-perceived numbers, install the profile/release APK and measure with `adb shell am start -W` on a fresh process.
    - [PARTIALLY_TRUE] "Android vitals treats cold start ≥5s as excessive; this app has enormous headroom and does not need cold-start optimization work"
      CORRECTION: Three fixes. (1) The 28-day figure is Google Play's quality-*evaluation* window, not the measurement window — vitals data spans 90 days in Play Console and 3 years in the Play Developer Reporting API; TTID is measured per-session. (2) The 700ms–1.8s cold-start estimate is not supported by any primary source (docs.flutter.dev/add-to-app/performance gives no timing numbers), and flutter/flutter#175577 (OPEN) documents +560–790ms Impeller cold-start regressions concentrated on Cortex-A53 devices — the exact $120–150 class cited — while the upstream fix #166918 was reverted by #167427 on 2025-04-19. Budget ~600–800ms less headroom than claimed. (3) The decisive argument is stronger than the one made: startup time is not a core vital and has no bad behavior threshold, so it cannot affect discoverability at all. The metrics that do are user-perceived ANR rate (≥0.47% overall / ≥8% per-device) and user-perceived crash rate (≥1.09% / ≥8%). Also note TTID measures the first frame — for Flutter that is the Android launch-theme splash, not the Dart UI — so Android's own docs recommend reportFullyDrawn()/TTFD instead; the rule should be "do not block the first Dart frame."
    - [PARTIALLY_TRUE] "Impeller is irrelevant to this app's speed but relevant to its rendering correctness on cheap devices"
      CORRECTION: Directionally right, wrong mechanism and wrong population. Corrections:

1. There are TWO fallback paths, not one. STATIC: API < 29, or Vulkan < 1.1, or missing extensions -> Impeller OpenGL ES from startup. RUNTIME: API 29+ device with Vulkan 1.1 starts on Vulkan, then falls back to GLES because its driver hits the known-bad denylist (android_context_vk_impeller.cc; flutter/flutter#162876) or context init fails.

2. Both cited bugs (#179268, #177873) are defects of the RUNTIME transition only. #179268 explicitly does not reproduce on "OpenGL ES alone" or "Vulkan alone". An old/API-28/no-Vulkan device runs GLES-alone and is therefore NOT the exposed population — it is the configuration those issues report as clean.

3. The actually-exposed population is API 29+ Vulkan-1.1-capable devices with denylisted or buggy drivers (repro hardware: Positivo Q20 / PowerVR / Android 10; Redmi Note 11 / Adreno-KGSL). This overlaps budget hardware but is defined by driver denylist status, not by age or cheapness. Correct framing: "devices whose Vulkan driver is denylisted at runtime", not "old/cheap devices".

4. #177873 is a regression introduced by the Vulkan-fallback patch #177380 (closed by #177747), not a longstanding GLES-backend defect.

5. Drop "no measurable perf impact" as a sourced statement — docs.flutter.dev/perf/impeller does not say it, and no primary source establishes it. If the decision depends on it, benchmark the actual grid; do not cite the Impeller page for it.

6. Decision-relevant addition the claim omits: Android retains an Impeller opt-out (--no-enable-impeller per current docs; also an AndroidManifest flag), so the buggy path has an escape hatch on Android. iOS does not — that half of the claim stands.
    - [PARTIALLY_TRUE] "Memory is irrelevant EXCEPT for one thing: user-imported tile images must be downscaled at import, not at render"
      CORRECTION: Two specifics need fixing. (1) The 100MB ImageCache cap doesn't save you NOT because "it evicts by count/bytes AFTER decode" — a 48MB bitmap is under the 100MB maximumSizeBytes and is cacheable. It doesn't save you because ImageCache separately tracks live images (ImageCache.liveImageCount): an image with an active listener is retained by its ImageStreamCompleter regardless of cache eviction, so 12 mounted tiles = 12 live bitmaps = ~576MB whatever the cache does. Tuning maximumSizeBytes would not help. (Note: only images LARGER than maximumSizeBytes are refused caching outright, per docs.flutter.dev/release/breaking-changes/imagecache-large-images — a 48MB decode isn't one of them.) (2) cacheWidth/ResizeImage is not a "weaker second line of defense" against OOM — per api.flutter.dev, cacheWidth/cacheHeight "indicate to the engine that the image must be decoded at the specified size," so the 48MB bitmap is never allocated; Flutter's own example cites a 100-fold reduction (4K image to 330KB at 384x216). Import-time re-encode is still the right primary fix, but because it's a single chokepoint that avoids per-load disk reads and resampling and shrinks disk usage — not because cacheWidth leaves the full decode exposed. Also: image_picker's pickImage already takes maxWidth/maxHeight/imageQuality, so the import-time downscale is one line at the pick site. Minor: 100 << 20 is 100 MiB, not 100 MB.

RECOMMENDATIONS:
  - [must] Define the ONE performance metric as 'tap → audible speech', not 'time to first frame', and write it in the README. — The product premise is instant speech, not instant pixels. Optimizing first frame while a 3-second TTS bind sits behind it is measuring the wrong thing. Naming the real metric is what stops the developer from doing irrelevant Flutter perf work.
  - [must] Warm the TTS engine asynchronously on app start: fire an init (and optionally a zero-volume or empty-string speak) from the first frame callback, never awaited on the path to rendering. — Android TextToSpeech service binding is documented at 1–5+ seconds on real devices and is the single largest latency term. Warming it during the seconds the user spends looking at the grid moves that cost off the critical path. Must not block first frame — that would trade an invisible delay for a visible one.
  - [must] Add <queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries> to AndroidManifest.xml and add a test/checklist item asserting voices are non-empty on a real device. — Android 11+ package visibility silently hides the TTS engine without this declaration. Combined with flutter_tts's habit of failing with only a Log.d, the failure mode is exactly the 'user taps a tile and nothing happens' class this project treats as the worst bug.
  - [must] Treat the SharedPreferences mirror that the QS TileService reads as a write-through cache, and test that every board edit updates it. — The QS tile is the fastest path to speech in the product because it bypasses the Flutter engine entirely. Its correctness depends on a mirror that can silently drift from the drift DB. With no telemetry, a stale mirror means the tile speaks a phrase the user deleted months ago and no one ever finds out.
  - [must] Downscale user-imported images to tile size (max ~512px) at import time and store the resized file on disk; never store or decode the original. — A 12MP photo decodes to ~48MB; twelve tiles is an OOM kill on a 2GB device. Fixing it at import makes the problem structurally impossible forever, the same way (board_id,row,col) makes reflow impossible. Fixing it at render time (cacheWidth) leaves the original on disk and the bug one refactor away. An OOM crash is invisible without telemetry.
  - [must] Measure cold start exactly once before release, on the cheapest physical Android device available, with: `flutter run --profile --trace-startup` (reads build/start_up_info.json) cross-checked against `adb shell am start -W -n <pkg>/.MainActivity` and the logcat 'Fully drawn' line. Record the numbers in the README and stop. — start_up_info.json starts its clock at engine-enter and misses process spawn + native lib load, so it flatters the result; am start -W and Fully drawn give the user-perceived number. This is a one-time verification event, not an ongoing practice — the Android vitals 'excessive' bar is 5s and this app will land near 1s. Recording it in the README is what lets a stranger notice a future regression.
  - [must] Profile only in --profile mode on a physical device. Never draw a performance conclusion from debug mode or an emulator. — Flutter docs state debug/emulator numbers are not indicative of release behavior — debug uses JIT and skips the AOT snapshot load that startup measurement is entirely about. Worse for this app specifically: the flutter_tts bind delay reportedly does not reproduce on emulator, so the dominant latency term is invisible on the most convenient test target.
  - [should] Use flat, solid-color tiles. Avoid gradients, SVG, and vector graphics in the grid. — Devices below API 29 or without Vulkan 1.1 fall back to Impeller's OpenGL ES backend, which has open bugs for gradient rendering (#179268) and SVG/vector corruption (#177873). That fallback population is exactly the budget-device audience. This is a rendering-correctness rule, not a speed one, and it happens to align with the zero-animation/deterministic-UI design rule at no cost.
  - [should] Enable prefer_const_constructors in analysis_options.yaml, let the analyzer apply it, and never think about const again. — The mechanism is real — const canonicalization makes Element.updateChild's `child.widget == newWidget` check true by identity and prunes the rebuild, and const objects live in the snapshot's read-only data rather than the heap. But at 12 widgets rebuilt essentially never, the runtime saving is unmeasurable. Keep it as a zero-cost lint and a readability signal for the stranger inheriting the repo, not as a performance activity.
  - [should] Run `flutter build apk --analyze-size --target-platform android-arm64` once, load the emitted JSON into DevTools' App Size tool, and record the baseline in the README. — Establishes the ~7–10MB baseline as a documented fact so that any future dependency that doubles it is visible to whoever inherits the project. This is the only DevTools screen with real value for this app; the Performance view exists to diagnose jank that a zero-animation 12-tile grid cannot have.
  - [should] Show the grid shell immediately on launch; never gate the first frame on a drift migration. — A 12-row read is sub-10ms and safe to await, but a migration over a hand-curated board is unbounded work sitting between the user and their voice. The QS-tile/SharedPreferences path already sidesteps this structurally; the app path just needs to not present a blank window while migrating.
  - [should] If the sherpa_onnx/Kokoro path is ever taken, ship it as a separate build/flavor rather than adding 55MB to the default app, and load the model lazily with a warm-up on first launch. — ONNX models are architecture-independent assets, so AAB ABI splitting does not shrink them — every user downloads all 55MB, ~7-8x the baseline, on the storage-constrained phones this audience actually owns. The offline promise forbids fetching it later. The neural path also reintroduces a memory floor and a model-load warm-up that the platform TTS path doesn't have.
  - [avoid] Do NOT use deferred components. — They require Play Core, FlutterPlayStoreSplitApplication, a PlayStoreDeferredComponentManager injection, and runtime delivery from Google Play — a network dependency that contradicts the privacy promise and breaks sideload/F-Droid distribution. The entire Dart app is a few hundred KB; there is nothing worth deferring.
  - [avoid] Do NOT do shader warmup, SkSL caching, or anything involving --bundle-sksl-path / --cache-sksl-path. — Impeller precompiles shaders at engine-build time; runtime shader compilation does not exist. The flags were removed in Flutter 3.32+. Any blog post recommending this is stale — and a zero-animation app had no shader jank to warm up in the first place.
  - [avoid] Do NOT add RepaintBoundary, do NOT hand-scope rebuilds with Consumer/select for performance, do NOT use GridView.builder for 12 tiles, and do NOT learn DevTools' Track Widget Builds / frame charts. — Every one of these is a jank remedy, and a static 12-tile grid with zero animation renders one frame and then stops. There is no frame budget to miss. Riverpod's seam is already justified on testability grounds — do not retroactively justify it on performance grounds or optimize against it. This is the single largest category of wasted time available to this project.
  - [avoid] Do NOT set up continuous performance benchmarking, startup regression tests in CI, or integration_test traceAction/TimelineSummary harnesses. — Proportionality: a solo dev with 2 weeks gets far more safety from migration tests and TTS-failure tests (where bugs are silent and catastrophic) than from guarding a startup number that sits ~3 seconds inside the Android vitals threshold. Startup is a one-command manual check before release. Spend the testing budget where the constraint document says the danger is.
  - [avoid] Do NOT profile or optimize memory, battery, or thermals for the platform-TTS build. — 12 widgets, no lists, no animation, images already capped at import, and synthesis handed to a system service for 2–5 second utterances a few times an hour. There is no signal to find. The only memory rule that matters is the import-time image downscale, which is a data-model decision rather than a profiling activity.


Write the honest memo. Address:
- What in this corpus is CARGO CULT for a one-screen, 6-table, solo-dev, 2-week app? Name names. Clean Architecture? Repository pattern over 6 tables? Riverpod at all? codegen? 100% coverage? melos? Pigeon? ADRs?
- Where does "best practice" actively HURT here — what will the developer spend a day on that returns nothing?
- What is the MINIMUM set of practices that actually protects the things that matter (no telemetry, migration safety, a11y correctness, no silent failures)?
- The corpus will produce four documents. Is that itself over-engineering? What would you cut?
- Where is the research just repeating Flutter-blog conventional wisdom rather than reasoning about THIS app?

Be direct. The developer has 2 weeks. Every practice must earn its place.
````

</details>
