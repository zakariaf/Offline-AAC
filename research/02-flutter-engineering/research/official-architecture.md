# official-architecture

> Phase: **research** · Agent `aa86ffd1cc08c07e5` · Run `wf_12b14467-451`

## Result

## Summary

Flutter's official architecture guide (docs.flutter.dev/app-architecture) is real, current, and explicitly recommends MVVM: a UI layer of Views + ViewModels, a Data layer of Repositories + Services, and an OPTIONAL domain layer of use-cases. Critically, the guide self-scopes in its own first paragraph: "This is a guide for building scalable Flutter applications and was written for teams that have multiple developers contributing to the same code base, who're building a feature-rich application." A solo dev shipping one screen in two weeks is explicitly outside the audience it was written for — so this guidance should be mined, not obeyed. The reference implementation (Compass app, flutter/samples) is 169 files under `lib/` for ~6 screens, with 6 repositories each having 2-3 swappable implementations (local/dev/remote) to demonstrate environment-switching — a rationale that evaporates in an app with no network and one environment. Three things from the guide are load-bearing here and should be adopted verbatim: the sealed `Result<T>` type (which turns constraint #4, silent failure, into a compile-time error), the layer-first/feature-first hybrid folder layout (which is what makes the code legible to the stranger who inherits it — constraint #5), and immutable models with unidirectional data flow. Several things should be actively rejected: the domain/use-case layer (the docs themselves say "in most apps they add unnecessary overhead"), separate API-vs-domain models ("Use in large apps"), `package:provider` for DI (Riverpod already does this, and the docs bless the substitution), and — most importantly — Google's "make fakes for testing" advice as applied to the board repository, where a fake would defeat the migration testing that constraint #2 makes a safety property. There is no genuine conflict between Google's guidance and Riverpod: a Riverpod `Notifier` IS a ViewModel in Google's formulation, and the case study says so explicitly. The one real divergence is that Google's ViewModels are 1:1 with views while Riverpod providers are global and naturally shared — at this size, ignore the 1:1 rule. Finally, the Command pattern is a trap for this specific app: its core behavior is `if (_running) return;`, and silently swallowing a re-tap is exactly the wrong semantic for a speak button.

### Flutter's official architecture guide explicitly scopes itself to multi-developer teams and feature-rich apps — this project is outside its stated audience.

*Confidence: high, **LOAD-BEARING***

docs.flutter.dev/app-architecture opens with: "This is a guide for building scalable Flutter applications and was written for teams that have multiple developers contributing to the same code base, who're building a feature-rich application. If you're writing a Flutter app that has a growing team and codebase, this guidance is for you." It adds: "Some libraries can be swapped out, and very large teams with unique complexity might find that some parts don't apply. In either case, the ideas remain sound." There is no separate 'small app' guide. This is the single most important framing fact for this dimension: nothing in the guide is a rule for a solo dev with one screen — it is a menu.

- https://docs.flutter.dev/app-architecture

### Google recommends MVVM with precisely defined roles: View = dumb widgets, ViewModel = where most logic lives, Repository = source of truth, Service = stateless data-source wrapper.

*Confidence: high, **LOAD-BEARING***

From /app-architecture/guide: "MVVM is an architectural pattern that separates a feature of an application into three parts: the Model, the ViewModel and the View." View: "views are the widget classes of your application... shouldn't contain any business logic. They should be passed all data they need to render from the view model." ViewModel: "A view model exposes the application data necessary to render a view... most of the logic in your Flutter application lives in view models" — responsibilities are (1) retrieving/transforming data from repositories, (2) maintaining UI state, (3) exposing commands. "Views and view models should have a one-to-one relationship." Repository: "Repository classes are the source of truth for your model data. They're responsible for polling data from services, and transforming that raw data into domain models... There should be a repository class for each different type of data handled in your app." Repos own caching, error handling, retry, refresh, and app-wide session state. Service: "Services are in the lowest layer... They wrap API endpoints and expose asynchronous response objects... They're only used to isolate data-loading, and they hold no state." Explicitly listed service examples include "The underlying platform, like iOS and Android APIs" and "Local files" — which is exactly what SpeechService is.

- https://docs.flutter.dev/app-architecture/guide

### The project's existing `SpeechService` abstraction is already exactly what Google calls a Service, and the platform channels (Personal Voice, QS Tile, ControlWidget) are Services too.

*Confidence: high, **LOAD-BEARING***

Google's Service definition — "wrap API endpoints", "hold no state", "one service class per data source", examples including "the underlying platform, like iOS and Android APIs" — maps 1:1 onto the already-decided `SpeechService` (speak/stop/voices) wrapping flutter_tts. This is a validation, not a change: the prior research pass independently arrived at Google's layer boundary. The `voice_filter` is the "transforming that raw data" step Google assigns to a Repository, which suggests it belongs one layer up from the raw flutter_tts wrapper rather than inside it.

- https://docs.flutter.dev/app-architecture/guide

### Google's domain layer (use-cases) is explicitly conditional and the docs recommend against it for most apps.

*Confidence: high, **LOAD-BEARING***

/app-architecture/recommendations rates "Use a domain layer" as **Conditional**: "A domain layer is only needed if your application has exceeding complex logic that crowds your ViewModels, or if you find yourself repeating logic in ViewModels. In very large apps, use-cases are useful, but in most apps they add unnecessary overhead." /app-architecture/concepts adds: "The logic layer is optional, and only needs to be implemented if your application has complex business logic... Many apps are only concerned with presenting data to a user and allowing the user to change that data (colloquially known as CRUD apps). These apps might not need this optional layer." An AAC app with 12 tiles and an edit mode is a CRUD app by this definition. Note that Compass itself only has TWO use-cases (booking_create, booking_share) out of 169 files — even the reference app barely uses the layer it demonstrates.

- https://docs.flutter.dev/app-architecture/recommendations

- https://docs.flutter.dev/app-architecture/concepts

### The Compass app's `lib/` is 169 files across 6 features, with 6 repositories × 2-3 implementations each — the multi-implementation pattern exists to demonstrate dev/staging/remote environment swapping, which does not exist in this project.

*Confidence: high, **LOAD-BEARING***

Actual tree (from GitHub API, flutter/samples main branch, verified 2026-07-15): `lib/config/{assets,dependencies}.dart`; `lib/data/repositories/{activity,auth,booking,continent,destination,itinerary_config,user}/` each with an abstract `X_repository.dart` plus `_local`/`_dev`/`_remote`/`_memory` implementations; `lib/data/services/api/{api_client,auth_api_client}.dart` + `services/api/model/**` + `services/local/local_data_service.dart` + `services/shared_preferences_service.dart`; `lib/domain/models/**` (7 models, each with .freezed.dart + .g.dart) and `lib/domain/use_cases/booking/{booking_create,booking_share}_use_case.dart`; `lib/routing/{router,routes}.dart`; `lib/ui/<feature>/view_models/*_viewmodel.dart` + `lib/ui/<feature>/widgets/*.dart` for activities, auth/login, auth/logout, booking, home, results, search_form; `lib/ui/core/{localization,themes,ui}/`; `lib/utils/{command,result,image_error_listener}.dart`; and three entrypoints `main.dart`, `main_development.dart`, `main_staging.dart`. The README confirms the purpose: "development and production environments... Development mode uses local JSON assets, Staging mode connects to a local HTTP server." The abstract-repository rationale in the docs is explicitly environment-driven: "Creating abstract repository classes allows you to create different implementations, which can be used for different app environments, such as 'development' and 'staging'." This app has ONE environment, no network, no auth, no API models. Roughly 60% of Compass's structure is demonstrating problems this project does not have.

- https://github.com/flutter/samples/tree/main/compass_app

- https://docs.flutter.dev/app-architecture/recommendations

- https://docs.flutter.dev/app-architecture/case-study

### Flutter's official position on folder structure is a documented hybrid: layer-first at the top level, feature-first inside the UI layer.

*Confidence: high, **LOAD-BEARING***

From /app-architecture/case-study: "The architecture recommended in this guide lends itself to a combination of the two. Data layer objects (repositories and services) aren't tied to a single feature, while UI layer objects (views and view models) are." The prescribed UI shape is `lib/ui/<feature_name>/view_models/<view_model_class>.dart` and `lib/ui/<feature_name>/widgets/<feature_name>_screen.dart`. Tests mirror `lib/` in `test/`, with shared mocks/utilities in a separate top-level `testing/` directory (confirmed by the Compass tree). Naming is a **Recommend**: "We recommend naming classes for the architectural component they represent. For example... HomeViewModel; HomeScreen; UserRepository; ClientApiService. For clarity, we do not recommend using names that can be confused with objects from the Flutter SDK."

- https://docs.flutter.dev/app-architecture/case-study

- https://docs.flutter.dev/app-architecture/recommendations

- https://github.com/flutter/samples/tree/main/compass_app

### The sealed `Result<T>` type is the single highest-value thing to lift from the official guidance, because it converts this project's worst bug class (silent failure) into a compile-time error.

*Confidence: high, **LOAD-BEARING***

Compass's `lib/utils/result.dart` is ~45 lines with no dependencies: `sealed class Result<T>` with `const factory Result.ok(T value) = Ok._` and `const factory Result.error(Exception error) = Error._`, plus `final class Ok<T>` (field `value`) and `final class Error<T>` (field `error`). Because it is `sealed`, Dart's exhaustiveness checker makes `switch (result) { case Ok(): ... case Error(): ... }` a compile error if a branch is missing. This is the mechanism that maps directly onto constraint #4: `flutter_tts.setVoice` returning 0 with only a `Log.d` is precisely a failure the type system cannot see today. If `SpeechService.speak()` returns `Future<Result<void>>`, the compiler will not let the call site ignore the Error branch. Note that `Result.error` is typed to `Exception`, not `Object` — errors that aren't Exceptions need wrapping.

- https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart

- https://docs.flutter.dev/app-architecture/design-patterns

### The Command pattern's core behavior — silently dropping re-entrant invocations — is actively wrong for a speak action in an AAC app.

*Confidence: high, **LOAD-BEARING***

Compass's `lib/utils/command.dart` implements `Command<T> extends ChangeNotifier` whose `_execute` begins: `if (_running) return;` with the comment "Ensure the action can't launch multiple times. e.g. avoid multiple taps on button". The docs rate Commands as **Recommend**: "Commands prevent rendering errors in your app, and standardize how the UI layer sends events to the data layer." But in this app, a user tapping a tile again while TTS is still speaking means "say it again" or "I need this NOW" — dropping that tap produces exactly the silence constraint #4 forbids. The correct speak semantic is stop-then-speak (barge-in), which is the opposite of Command's guard. Command IS appropriate for edit-mode DB writes (save tile, delete tile, import board), where double-execution is a real hazard and a disabled/pending button is honest UI. Adopting Command uniformly because the docs recommend it would be the clearest cargo-cult failure available in this project.

- https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/command.dart

- https://docs.flutter.dev/app-architecture/recommendations

### Google's guidance does NOT conflict with Riverpod — the docs explicitly bless it, and a Riverpod Notifier is a ViewModel in Google's formulation.

*Confidence: high, **LOAD-BEARING***

The ChangeNotifier recommendation is rated **Conditional**, not strongly recommended: "The ChangeNotifier API is part of the Flutter SDK, and is a convenient way to have your widgets observe changes in your ViewModels. There are many options to handle state-management, and ultimately the decision comes down to personal preference." The case study is more direct: "The example in this case-study demonstrates how one application abides by our recommended architectural rules, but there are many other example apps that could've been written... it could've easily been written with streams, or with other libraries such as riverpod, flutter_bloc, and signals." The DI recommendation is where a nominal conflict lives: **Strongly recommend** "Use dependency injection... We recommend you use the provider package" (the DI case-study page recommends `package:provider` and does not mention get_it or Riverpod at all). But Riverpod subsumes this — it IS a DI container, and provider overrides in tests are the direct analogue of Compass's `lib/config/dependencies.dart` MultiProvider. The stated goal of the DI recommendation — "prevents your app from having globally accessible objects" — is satisfied. Do not add `package:provider` alongside Riverpod.

- https://docs.flutter.dev/app-architecture/recommendations

- https://docs.flutter.dev/app-architecture/case-study

- https://docs.flutter.dev/app-architecture/case-study/dependency-injection

### The one real Google-vs-Riverpod divergence is the 1:1 ViewModel:View rule, which Riverpod's global providers do not naturally enforce — and which this app should ignore.

*Confidence: medium, **LOAD-BEARING***

Google: "Views and view models should have a one-to-one relationship." Riverpod providers are top-level globals, naturally shared across widgets, and the community pattern is one Notifier per state concern, not per screen. With ONE screen containing a grid + a text field + a show-text mode + an edit mode, forcing a single `HomeViewModel` would create a god object, while forcing one-per-view is meaningless when there's one view. Slice by state concern instead: board state, compose-field state, speech state, settings. This is a case where Google's rule is a team-coordination device (so two devs don't fight over one class) with zero value for a solo dev.

- https://docs.flutter.dev/app-architecture/guide

- https://riverpod.dev/docs/concepts2/providers

### Google's 'make fakes for testing' recommendation, applied to the board repository, would actively defeat this project's #2 safety property (migration correctness).

*Confidence: high, **LOAD-BEARING***

The docs rate **Strongly recommend**: "Make fakes for testing (and write code that takes advantage of fakes.)... Fakes aren't concerned with the inner workings of any given method as much as they're concerned with inputs and outputs." This is sound when the real dependency is a network you can't hit in CI. It is harmful when the real dependency is SQLite: a `FakeBoardRepository` backed by a Map will happily accept a row that the real `PRIMARY KEY (board_id, row, col)` constraint rejects, and will never exercise a drift migration step. Since constraint #1 removes telemetry and constraint #2 makes a bad migration equal to destroying a user's voice, the board repository must be tested against a real in-memory SQLite (`NativeDatabase.memory()`) plus drift's schema-verification/migration test tooling — not a fake. Fake the things that are genuinely un-runnable in a test: `SpeechService` (platform TTS), and the platform channels. Do not fake the database. This is a concrete, defensible departure from a Strongly-recommend.

- https://docs.flutter.dev/app-architecture/recommendations

- https://docs.flutter.dev/app-architecture/case-study/testing

### Google's per-layer testing recommendation is the one place this project should EXCEED the official guidance rather than trim it.

*Confidence: high, **LOAD-BEARING***

The docs say: "Write unit tests for every service, repository and ViewModel class. These tests should test the logic of every method individually. Write widget tests for views. Testing routing and dependency injection are particularly important." This is written for teams that also have Crashlytics as a backstop. With constraint #1 (no telemetry, ever — the developer will never learn the app crashed), tests are the entire safety net, which means the guide's list is a floor, not a target. The guide has nothing at all to say about accessibility testing, which is constraint #3 — there is no official Flutter architecture guidance on enforcing Semantics or TextScaler via tests. That gap must be filled from outside this dimension (flutter_test's `meetsGuideline(textContrastGuideline)`, `SemanticsController`, and pumping with a 200%+ `TextScaler` in `MediaQuery`).

- https://docs.flutter.dev/app-architecture/recommendations

- https://docs.flutter.dev/app-architecture/case-study/testing

### Official guidance on optimistic state exists and is largely irrelevant here — with one exception worth naming.

*Confidence: high*

/app-architecture/design-patterns/optimistic-state: "Developers can help mitigate this negative perception by presenting a successful UI state before the background task is fully completed." The canonical shape sets the state, notifies, awaits the repository, and reverts on catch. This pattern exists to hide NETWORK latency. This app has no network; a drift write to local SQLite completes in single-digit milliseconds. Applying optimistic state here would add a revert path that can never fire — pure liability. The exception: do NOT apply optimistic reasoning to the speak path. A tile must not render a 'spoken' affordance until the TTS engine has actually accepted the utterance, because optimistically showing success is definitionally the silent-failure bug in constraint #4. Also note optimistic state conflicts with constraint #7 (zero animation / deterministic UI) — a state that appears then reverts is a visual change the user did not cause.

- https://docs.flutter.dev/app-architecture/design-patterns/optimistic-state

### From the architectural overview, the only correctness-relevant facts for this app are element-tree identity and side-effect-free builds — const and rebuild optimization are NOT load-bearing at 12 tiles.

*Confidence: high*

/resources/architectural-overview: "During the build phase, Flutter translates the widgets expressed in code into a corresponding element tree, with one element for every widget... the element tree is persistent from frame to frame... By only walking through the widgets that changed, Flutter can rebuild just the parts of the element tree that require reconfiguration." And: "A widget's build function should be free of side effects. Whenever the function is asked to build, the widget should return a new tree of widgets, regardless of what the widget previously returned... it is important that build methods should return quickly, and heavy computational work should be done in some asynchronous manner." Practical translation: (1) NEVER call `speak()` from a `build()` method or a Riverpod `ref.listen` misused as a build-time effect — that is the real, easy-to-hit correctness bug, and it produces repeated/duplicate speech; (2) element reuse means a tile widget at (row,col) keeps its Element and State when `button_id` flips null→set, so if a tile ever holds State, it needs `ValueKey(buttonId)` — but the grid_slots PK design already makes position stable, so a `ValueKey((row, col))` on the slot and stateless tiles sidesteps keys entirely; (3) `const` and rebuild-scoping are performance tools, and with a fixed 3x4 grid and a zero-animation rule there is no performance problem to solve. Spending effort on const-correctness for speed here is misapplied; keep `prefer_const_constructors` on as a free lint and stop thinking about it. Keys are not discussed in the architectural overview at all.

- https://docs.flutter.dev/resources/architectural-overview

### freezed is officially recommended but is likely redundant here because drift already generates immutable data classes.

*Confidence: medium, **LOAD-BEARING***

Docs rate **Recommend**: "You can use packages to help generate useful functionality in your data models, freezed or built_value. These can generate common model methods like JSON ser/des, deep equality checking and copy methods." Compass uses freezed on all 7 domain models (each has a .freezed.dart and .g.dart). But drift already generates immutable row classes with `copyWith`, `==`/`hashCode`, and `toString` for every table — the exact list of things freezed is recommended FOR. Adding freezed means a second code generator, a second build_runner pass, and a hand-written mapping layer between drift rows and freezed models, which is the "Create separate API models and domain models" recommendation the docs themselves rate **Conditional** with "Using separate models adds verbosity... Use in large apps." With 6 tables and no API, use drift's generated classes as the domain models directly. The one place a hand-written model may be warranted is a `Voice`/`SpeechFailure` type that has no table behind it — write those by hand or as a small sealed class; that's 20 lines, not a code generator.

- https://docs.flutter.dev/app-architecture/recommendations

- https://github.com/flutter/samples/tree/main/compass_app

### go_router is officially recommended but is not clearly justified for a one-screen app; the decision hinges on Android Quick Settings tile deep-linking, not on navigation complexity.

*Confidence: medium*

Docs rate **Recommend**: "Go_router is the preferred way to write 90% of Flutter applications. There are some specific use-cases that go_router doesn't solve, in which case you can use the Flutter Navigator API directly." This app has one screen plus modes (show-text, edit, settings). Modes are state, not routes — pushing them as routes adds a router config, a routes.dart, and route tests for zero benefit. HOWEVER: the Android QS TileService and the iOS 18 ControlWidget are external entry points, and if either should ever open the app to a specific state, that is a deep link, and deep links are the one thing go_router genuinely earns. Per the already-made decision, the QS tile speaks NATIVELY with no Flutter engine on that path — so it does not deep-link and this justification does not apply. Default to no router: `MaterialApp(home: ...)` with `Navigator.push` for settings/show-text, or plain state flags. Revisit only if an entry point needs to launch into a specific board.

- https://docs.flutter.dev/app-architecture/recommendations

### Following the official folder structure is worth it here for a reason unrelated to correctness: legibility to the stranger who inherits the code.

*Confidence: medium, **LOAD-BEARING***

Constraint #5 says the developer may abandon this and open-sourcing is the exit plan, so "the code must be READABLE BY A STRANGER." The strongest argument for `lib/data/`, `lib/ui/<feature>/view_models/`, `lib/ui/<feature>/widgets/` is that it is now the structure Flutter's own docs teach, the structure the official sample uses, and therefore the structure a random Flutter dev in 2026 recognizes on sight without reading a CONTRIBUTING.md. That benefit is real and costs nothing at this size — directories are free. This inverts the usual analysis: adopt the SHAPE of the official architecture (cheap, aids handoff) while rejecting its CEREMONY (use-cases, dual models, abstract repos with one impl, Commands everywhere, freezed). The shape is documentation; the ceremony is team coordination the solo dev doesn't need.

- https://docs.flutter.dev/app-architecture/case-study

- https://docs.flutter.dev/app-architecture

## Recommendations

- **[must]** Adopt the sealed `Result<T>` type from Compass verbatim (copy `lib/utils/result.dart`, ~45 lines, zero deps) and make `SpeechService.speak/stop/setVoice` return `Future<Result<void>>`. Never return bare `void` or `bool` from any speech-path method.
  - This is the single mechanism that turns constraint #4 (silent failure is the worst bug class) from a discipline problem into a compiler problem. Dart's exhaustiveness checking on a sealed class makes it a COMPILE ERROR to handle Ok without handling Error. flutter_tts's setVoice returning 0 with only a Log.d is exactly the failure a bool return invites you to ignore. With no telemetry, the compiler is the only reviewer you have.
- **[must]** Adopt the official folder shape: `lib/data/repositories/`, `lib/data/services/`, `lib/ui/<feature>/view_models/`, `lib/ui/<feature>/widgets/`, `lib/utils/result.dart`, with `test/` mirroring `lib/` and shared fakes in a top-level `testing/`.
  - Not for correctness — for handoff. Constraint #5 makes stranger-legibility a requirement, and this is now the structure Flutter's own docs and reference app teach, so a random 2026 Flutter dev recognizes it without reading docs. Directories are free; this costs nothing and buys the exit plan.
- **[avoid]** Do NOT create a domain/use-case layer. No `lib/domain/use_cases/`.
  - The docs rate it Conditional and say plainly: "in very large apps, use-cases are useful, but in most apps they add unnecessary overhead." The concepts page says CRUD apps "might not need this optional layer." Even Compass only has 2 use-cases across 169 files. A 12-tile board editor has no logic that crowds a ViewModel.
- **[must]** Test the board repository against real in-memory SQLite (`NativeDatabase.memory()`) plus drift's schema/migration test tooling. Do NOT write a `FakeBoardRepository`.
  - This is a deliberate departure from a Strongly-recommend ("Make fakes for testing"). A Map-backed fake will accept rows that the real `PRIMARY KEY (board_id, row, col)` rejects and will never execute a migration step. Constraint #2 makes migration correctness a safety property — a fake would give you green tests and a destroyed board. Google's fake advice assumes the real dependency is a network; here it's SQLite, which runs fine in a test.
- **[must]** Fake only what cannot run in a test: `SpeechService` and the platform channels (Personal Voice, QS Tile, ControlWidget). Keep `SpeechService` abstract; do NOT add an abstract interface over the drift DAO.
  - The docs justify abstract repositories with "different implementations... for different app environments, such as 'development' and 'staging'" — a rationale that does not exist in a single-environment offline app. The only surviving reason to abstract is the test seam, so abstract exactly the things you cannot execute in a test and nothing else. One interface with one real impl and one fake is justified; one interface with one impl is not.
- **[must]** Use the Command pattern ONLY for edit-mode mutations (save tile, delete tile, import/export board). Never wrap the speak action in a Command.
  - Command's core is `if (_running) return;` — it silently drops re-entrant taps. For a speak button, a second tap means "say it again" or "I need this NOW," and swallowing it produces exactly the silence constraint #4 forbids. Speak must be stop-then-speak (barge-in). For DB writes, double-execution is a real hazard and Command's guard is correct. Applying it uniformly because it's recommended is the clearest available cargo-cult failure.
- **[avoid]** Do not add `package:provider`. Riverpod already satisfies the Strongly-recommend on dependency injection; use provider overrides in tests where Compass uses `lib/config/dependencies.dart`.
  - The DI case-study page recommends provider and never mentions Riverpod, but the stated GOAL — "prevents your app from having globally accessible objects" — is what Riverpod does. The case study explicitly blesses substitution: the app "could've easily been written with... riverpod, flutter_bloc, and signals." Two DI mechanisms is strictly worse than one.
- **[should]** Ignore Google's "Views and view models should have a one-to-one relationship." Slice Riverpod Notifiers by state concern instead: board, compose field, speech, settings.
  - With one screen, the 1:1 rule either produces a god object or is vacuous. The rule is a team-coordination device — it stops two devs fighting over one class — and has zero value for a solo dev. Riverpod's providers are global by design and don't enforce it anyway.
- **[should]** Skip freezed. Use drift's generated row classes as the domain models directly. Hand-write the few non-table types (Voice, SpeechFailure) as small sealed classes.
  - The docs recommend freezed for "JSON ser/des, deep equality checking and copy methods" — drift already generates all three. Adding freezed means a second generator plus a hand-written drift-row→freezed-model mapping layer, which is the "separate API and domain models" recommendation the docs themselves rate Conditional with "Use in large apps." There is no API here.
- **[should]** Skip go_router. Use `MaterialApp(home:)` with `Navigator.push` for settings/show-text, or plain state flags for modes. Revisit only if an external entry point must launch into a specific board.
  - Modes are state, not routes. The one thing go_router genuinely earns is deep linking, and the already-made decision has the Android QS tile speaking natively with no Flutter engine on that path — so it never deep-links. A router config plus routes.dart plus route tests for one screen is pure overhead.
- **[must]** Never call `speak()` — or any side effect — from a `build()` method or from a Riverpod provider's build. Route all speech through an explicit user-event handler.
  - Flutter's architectural overview: "A widget's build function should be free of side effects. Whenever the function is asked to build, the widget should return a new tree of widgets, regardless of what the widget previously returned." Because the element tree persists and rebuilds are triggered by state changes you don't fully control (MediaQuery a11y flags, TTS voice-availability changes — both of which this app subscribes to), a speak() in build produces duplicated or spontaneous speech. This is the one architectural-overview fact that is a real correctness hazard here.
- **[avoid]** Do not apply optimistic state anywhere, and especially not to the speak path — a tile must not indicate success until the TTS engine has accepted the utterance.
  - Optimistic state exists to hide network latency; a drift write to local SQLite is single-digit ms, so the revert path could never fire and is pure liability. On the speak path it's worse than useless: showing success before the engine confirms IS the silent-failure bug from constraint #4. It also violates constraint #7 — a state that appears then reverts is a visual change the user didn't cause.
- **[must]** Treat Google's per-layer testing list as a floor, not a target, and fill the accessibility gap it leaves entirely unaddressed with `meetsGuideline()`, `SemanticsController` assertions on every tile, and widget tests pumped at TextScaler 2.0+.
  - The docs say "Write unit tests for every service, repository and ViewModel class... Write widget tests for views" — but that's calibrated for teams that also run Crashlytics. Constraint #1 removes the backstop entirely. And the architecture guide says nothing whatsoever about accessibility, which constraint #3 makes correctness — that gap is real and official guidance will not fill it.
- **[avoid]** Do not optimize rebuilds or chase const-correctness for performance. Leave `prefer_const_constructors` on as a free lint and spend the effort on tests instead.
  - A fixed 3x4 grid with a zero-animation rule has no performance problem to solve. The element tree already "walks through only the widgets that changed." Const matters here as a lint-level habit, not as an optimization. Given a 2-week MVP (constraint #6), rebuild-scoping is effort stolen from the migration and accessibility tests that are actually load-bearing.
- **[should]** Put the `voice_filter` logic (Android network_required check, setVoice return-value check) in a repository, not in the raw flutter_tts wrapper.
  - Google's split is explicit: Services "wrap API endpoints... hold no state" and are "only used to isolate data-loading"; Repositories are "responsible for polling data from services, and transforming that raw data into domain models" and own "error handling." The flutter_tts wrapper is the Service (a platform API, which the docs name explicitly as a service example); filtering unusable voices and verifying setVoice actually took effect is transformation + error handling, i.e. repository work. This keeps the untestable platform boundary thin and puts the logic you most need to test in a class you can test.

### Result<T> — copy this from Compass verbatim (lib/utils/result.dart)

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

### The speak path: Result makes silence impossible to ignore

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

### Proposed lib/ structure — official shape, ceremony stripped

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

### Riverpod Notifier IS Google's ViewModel — and the DI story replaces dependencies.dart

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


YOUR DIMENSION: Flutter's OFFICIAL architecture guidance, and how much of it applies here.

Research with WebSearch/WebFetch. Flutter published formal architecture docs and a reference app relatively recently — find the CURRENT state.

- docs.flutter.dev/app-architecture — the guide, "Architecture concepts", "Guide to app architecture", "Recommendations", "Case study". What EXACTLY does Google recommend in 2026? They recommend MVVM — verify, and get the specifics: what is a ViewModel in their formulation, what is a Repository, what is a Service, what belongs in each layer?
- The **Compass App** reference implementation (github.com/flutter/samples) — read its actual structure. What does it demonstrate? Is it over-engineered for a small app?
- What is Flutter's official position on: feature-first vs layer-first folder structure? Command pattern for UI actions? Result types? Optimistic state?
- Does Google's guidance conflict with Riverpod's own recommended architecture? Where?
- Flutter's "architectural overview" (widgets/elements/render objects) — what does a dev actually need to know for correctness (e.g., why const matters, when rebuilds happen, keys)?
- Is there official guidance on when NOT to layer? What does Google say about small apps?

Be concrete. Quote the docs. Give the actual folder structure from the Compass app. Then judge honestly: what parts of this apply to a ONE-SCREEN app with 6 tables and a solo dev, and what parts are cargo cult at this size?
````

</details>
