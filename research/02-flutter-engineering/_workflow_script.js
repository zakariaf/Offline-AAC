export const meta = {
  name: 'flutter-eng-practices',
  description: 'Research Flutter app structure, coding standards, and testing practices; author the project docs',
  phases: [
    { title: 'Research', detail: '12 parallel researchers across architecture/testing/tooling' },
    { title: 'Verify', detail: 'adversarially fact-check load-bearing claims' },
    { title: 'Critique', detail: 'completeness + skeptical staff-engineer review' },
    { title: 'Author', detail: 'write ARCHITECTURE / CODING_STANDARDS / TESTING / TOOLING' },
  ],
}

const FINDINGS_SCHEMA = {
  type: 'object',
  properties: {
    dimension: { type: 'string' },
    summary: { type: 'string', description: '4-8 sentence executive summary' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          claim: { type: 'string', description: 'A specific, falsifiable claim' },
          detail: { type: 'string', description: 'Specifics: package names, versions, API names, code shape, numbers' },
          sources: { type: 'array', items: { type: 'string' } },
          confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
          loadBearing: { type: 'boolean', description: 'True if a project decision hinges on this' },
        },
        required: ['claim', 'detail', 'confidence', 'loadBearing'],
      },
    },
    codeExamples: {
      type: 'array',
      description: 'Concrete, correct, copy-pasteable code snippets that illustrate the recommended practice',
      items: {
        type: 'object',
        properties: {
          title: { type: 'string' },
          language: { type: 'string' },
          code: { type: 'string' },
          note: { type: 'string' },
        },
        required: ['title', 'code'],
      },
    },
    recommendations: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          rule: { type: 'string', description: 'An imperative, checkable rule for this project' },
          priority: { type: 'string', enum: ['must', 'should', 'avoid'] },
          rationale: { type: 'string' },
        },
        required: ['rule', 'priority', 'rationale'],
      },
    },
  },
  required: ['dimension', 'summary', 'findings', 'recommendations'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    refuted: { type: 'boolean' },
    verdict: { type: 'string', enum: ['CONFIRMED', 'PARTIALLY_TRUE', 'REFUTED', 'UNVERIFIABLE'] },
    correction: { type: 'string' },
    evidence: { type: 'string' },
    sources: { type: 'array', items: { type: 'string' } },
  },
  required: ['refuted', 'verdict', 'evidence'],
}

const PROJECT = `
=== THE PROJECT THESE PRACTICES ARE FOR ===

An offline AAC (augmentative & alternative communication) app for autistic adults with situational/part-time speech loss. Flutter, Android-first, iOS later. Solo developer. Today is 2026-07-15; Flutter stable is 3.44.0, Dart 3.x.

The app: ONE screen — a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface + on-device TTS. A "show text" full-screen mode. An explicit edit mode. Settings (voice/pitch/rate/output mode/theme). No accounts, no server, no network.

DECISIONS ALREADY MADE (from a prior deep research pass — do not re-litigate these, design practices AROUND them):
- **drift** (SQLite) for local DB. Schema: boards / buttons / grid_slots / images / sounds / settings. Critically, \`grid_slots\` has PRIMARY KEY (board_id, row, col) with a NULLABLE button_id — position IS the primary key, so tile reflow is structurally impossible. Data model borrows Open Board Format semantics (label != vocalization: the tile SHOWS "Overwhelmed" but SPEAKS "I need to leave, I'm not able to talk right now").
- **flutter_riverpod** for state — explicitly acknowledged as NOT load-bearing (12 tiles and a text field; ValueNotifier would work). Chosen for a testable seam between repository and UI, and to react to MediaQuery a11y flags + TTS voice-availability changes.
- **flutter_tts** wrapped behind an abstract \`SpeechService\` (speak/stop/voices), with a \`voice_filter\` (Android network_required check + setVoice return-value check — flutter_tts returns 0 with only a Log.d on failure, which would silently give a user in crisis NO SPEECH) and an \`audio_session\` config (iOS .playback + duckOthers; NEVER .ambient).
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
`

const DIMENSIONS = [
  {
    key: 'official-architecture',
    prompt: `${PROJECT}

YOUR DIMENSION: Flutter's OFFICIAL architecture guidance, and how much of it applies here.

Research with WebSearch/WebFetch. Flutter published formal architecture docs and a reference app relatively recently — find the CURRENT state.

- docs.flutter.dev/app-architecture — the guide, "Architecture concepts", "Guide to app architecture", "Recommendations", "Case study". What EXACTLY does Google recommend in 2026? They recommend MVVM — verify, and get the specifics: what is a ViewModel in their formulation, what is a Repository, what is a Service, what belongs in each layer?
- The **Compass App** reference implementation (github.com/flutter/samples) — read its actual structure. What does it demonstrate? Is it over-engineered for a small app?
- What is Flutter's official position on: feature-first vs layer-first folder structure? Command pattern for UI actions? Result types? Optimistic state?
- Does Google's guidance conflict with Riverpod's own recommended architecture? Where?
- Flutter's "architectural overview" (widgets/elements/render objects) — what does a dev actually need to know for correctness (e.g., why const matters, when rebuilds happen, keys)?
- Is there official guidance on when NOT to layer? What does Google say about small apps?

Be concrete. Quote the docs. Give the actual folder structure from the Compass app. Then judge honestly: what parts of this apply to a ONE-SCREEN app with 6 tables and a solo dev, and what parts are cargo cult at this size?`,
  },
  {
    key: 'project-structure',
    prompt: `${PROJECT}

YOUR DIMENSION: Project/folder structure and module boundaries for a small-but-serious Flutter app.

Research with WebSearch/WebFetch: Very Good Ventures' conventions and very_good_cli templates, Andrea Bizzotto (codewithandrea) on feature-first vs layer-first, Reso Coder / Clean Architecture in Flutter (and the backlash to it), the Flutter community's 2025-2026 consensus, monorepo tooling (melos), internal packages.

- **Feature-first vs layer-first**: state the actual trade-off with evidence, not vibes. Which wins for a ONE-SCREEN app? Note this app's "features" (speak/show/edit/settings) all operate on the SAME data — does feature-first even make sense?
- Should a solo dev split into local packages (packages/core, packages/db)? What does that BUY and what does it COST? Is melos worth it here? Be honest — most small apps that do this regret it.
- Where do platform-channel wrappers live? Should the native interop surface be its own package/plugin? (This app has: Personal Voice iOS channel, Android QS TileService, iOS ControlWidget.) Is a federated plugin overkill?
- Naming conventions for files/folders/classes in Dart. Effective Dart's actual rules.
- barrel files (index.dart / exports) — good or harmful? Evidence on build times and circular imports.
- Where do the theme tokens, a11y helpers, and constants go?
- \`lib/src/\` convention — when does it matter (packages) vs not (apps)?
- What does a REAL, well-structured small Flutter app look like in 2026? Find actual open-source examples worth imitating and describe their structure.
- How should assets (starter phrase sets, symbols later, fonts) be organized and declared?

Give a concrete recommended tree for THIS app, and say what you'd cut from a "best practice" tree because it's a solo two-week MVP.`,
  },
  {
    key: 'riverpod',
    prompt: `${PROJECT}

YOUR DIMENSION: Riverpod in 2026 — correct, current usage, and testing.

Research with WebSearch/WebFetch: riverpod.dev, pub.dev/packages/flutter_riverpod, Remi Rousselet's repo + changelogs, codewithandrea's Riverpod articles (check dates!), migration guides.

CRITICAL — establish the CURRENT VERSION and API. Riverpod 3.0 was in development; is it stable in 2026? What changed from 2.x → 3.x? What is DEPRECATED? Specifically:
- Is \`StateProvider\` / \`StateNotifierProvider\` / \`ChangeNotifierProvider\` deprecated or legacy now? What replaced them?
- \`Notifier\` / \`AsyncNotifier\` — current idiom?
- **riverpod_generator + @riverpod annotation vs manual providers** — is code generation now the recommended default? What does it cost (build_runner in the loop)? For a solo dev on a 6-provider app, is codegen worth it? Be honest.
- \`ref.watch\` vs \`ref.read\` vs \`ref.listen\` — the actual rules and the common bugs.
- Provider lifecycle: autoDispose (is it default in 3.x?), keepAlive, ref.onDispose.
- **Overriding providers in tests** — the exact idiom (ProviderContainer, ProviderScope overrides, container.read, addTearDown(container.dispose)). Give real test code.
- How to expose a Stream from drift into Riverpod correctly (drift's .watch() → StreamProvider).
- How to react to MediaQuery accessibility flags — should those go through Riverpod at all, or stay in the widget tree? Argue it.
- Common Riverpod anti-patterns and how they bite.
- Honest challenge: for THIS app (12 tiles, a text field, settings), is Riverpod justified, or is it ceremony? What is the minimal correct usage? What would ValueNotifier/InheritedWidget cost/save?

Give real, current, compiling code. Flag anything where 2023-era tutorials are now wrong.`,
  },
  {
    key: 'dart3-idioms',
    prompt: `${PROJECT}

YOUR DIMENSION: Modern Dart 3.x language idioms and error-handling patterns.

Research with WebSearch/WebFetch: dart.dev/effective-dart, dart.dev language docs, Dart 3.x release notes and what landed in each version through 2026, Dart team blog posts.

- **Dart 3 features and when to use them**: sealed classes + exhaustive switch, pattern matching, records, class modifiers (final/base/interface/sealed/mixin), switch expressions, if-case, destructuring. Which genuinely improve code here, and which are showing off?
- What landed in Dart 3.3-3.9+ (extension types? macros — did macros ship or get cancelled? VERIFY, this was contentious), null-aware elements, dot shorthands? Get the CURRENT state of the language in 2026.
- **Error handling**: exceptions vs Result/Either types. The Dart team's actual position (dart.dev has guidance on Error vs Exception). Flutter's official architecture guide recommends a Result class — verify and show it. Is \`fpdart\`/\`dartz\`/\`result_dart\`/\`oxidized\` worth a dependency, or hand-roll a sealed Result? For THIS app, where a silent failure means a user in crisis gets no speech, what is the right error model? Argue concretely — e.g. \`speak()\` can fail (voice missing, engine dead, setVoice returned 0). Should it throw or return a Result?
- Where should errors be caught? What does Flutter's FlutterError.onError / PlatformDispatcher.instance.onError do, and how do you use them WITHOUT a crash-reporting SDK? (This app writes an on-device log instead — what's the correct wiring?)
- Zone-based error capture (runZonedGuarded) — still recommended in 2026, or superseded by PlatformDispatcher.onError?
- Immutability: how much? const constructors, final fields, copyWith. Is \`freezed\` worth it in 2026 (it needs build_runner)? What about the new Dart features that reduce the need for it? Verify freezed's current version and status.
- equatable vs freezed vs manual == vs records.
- Assertions and \`assert\` in Flutter — debug-only; where do they belong in a safety-critical-ish app?
- Effective Dart's actual naming/doc/style rules that people commonly violate.

Give real, compiling, current code.`,
  },
  {
    key: 'testing-strategy',
    prompt: `${PROJECT}

YOUR DIMENSION: Flutter testing strategy — the overall shape. What to test, what not to, and why.

Research with WebSearch/WebFetch: docs.flutter.dev/testing, Flutter's testing cookbook, the test pyramid debate, Google's testing guidance, Very Good Ventures on testing (they mandate 100% coverage — investigate whether that's actually wise), codewithandrea, Flutter's own repo test conventions.

- The three Flutter test types (unit / widget / integration) — what each is genuinely FOR, real cost/speed of each, and the actual recommended ratio. Does the classic pyramid hold in Flutter, or is the widget test the sweet spot (fast + high fidelity)? Argue with evidence.
- \`flutter_test\`: WidgetTester, pumpWidget, pump vs pumpAndSettle (**pumpAndSettle is a known flake source and this app has ZERO animation — what follows from that?**), finders (find.byType/byKey/bySemanticsLabel/byTooltip), expectLater, matchers.
- Test organization: mirroring lib/ in test/, naming conventions (\`_test.dart\`), group/setUp/tearDown, test helpers, \`testWidgets\` custom wrappers (pumpApp pattern).
- **Mocking**: mocktail vs mockito in 2026 (mockito needs build_runner; mocktail doesn't). Which is the community default now? Verify versions/status. When is a hand-written FAKE better than a mock? (Strong opinion wanted: for a SpeechService with 3 methods, is a fake better?)
- Fake vs stub vs mock vs spy — use the terms correctly and say which this project needs.
- **Coverage**: is 100% coverage wise? VGV mandates it — find the arguments for and against. What's a defensible target for a solo dev? What does coverage MISS? How do you measure it in Flutter (\`flutter test --coverage\`, lcov, excluding generated files — .g.dart/.freezed.dart pollute coverage, how do you exclude them?)
- **THE KEY QUESTION FOR THIS PROJECT**: with NO crash reporting and NO analytics, the developer never learns about field failures. How should that change the testing strategy vs a normal app? What specifically becomes worth testing that normally isn't? Does it argue for more integration tests? Property-based testing? Be concrete and specific — this is the most important question in your dimension.
- Test flakiness sources in Flutter and how to avoid them.
- What is NOT worth testing (be specific — a solo dev has 2 weeks).
- Is TDD practical in Flutter UI work? Honest answer.`,
  },
  {
    key: 'widget-golden-testing',
    prompt: `${PROJECT}

YOUR DIMENSION: Widget testing depth + golden/screenshot testing.

Research with WebSearch/WebFetch.

**Widget testing:**
- The pumpApp/testHarness pattern — wrapping with MaterialApp + ProviderScope + MediaQuery overrides. Show a real, current implementation.
- **Testing at different text scales**: how do you drive \`TextScaler\` in a widget test? (MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(2.0)))) — show it. How do you assert nothing overflows? (Does a RenderFlex overflow FAIL a test, or just log? VERIFY — this matters enormously: if overflow only prints to console, the test passes while the UI is broken. How do you make overflow fail the test?)
- Testing different screen sizes (tester.view.physicalSize / devicePixelRatio, addTearDown(tester.view.reset)). Current API — \`tester.binding.window\` is deprecated; what replaced it?
- Testing MediaQuery a11y flags: boldText, highContrast, disableAnimations, invertColors, accessibleNavigation.
- Testing that a tap SPEAKS: how do you assert on a faked SpeechService?
- Testing the drift-backed UI: in-memory DB (NativeDatabase.memory()) in widget tests — is that a good idea or should the repo be faked? Argue.

**Golden testing:**
- Current state 2026: \`matchesGoldenFile\`, \`flutter test --update-goldens\`, golden_toolkit (VERIFY — I believe it was DISCONTINUED/archived by eBay; check!), alchemist (Very Good Ventures), golden_screenshot, spot. What is actually maintained and recommended NOW?
- The font problem: goldens render boxes instead of text unless you load fonts — the actual fix in 2026 (loadAppFonts, FontLoader, or is it now automatic?).
- The platform problem: goldens differ between macOS/Linux/CI. How do teams solve it (CI-only goldens, Docker, tolerance thresholds, alchemist's CI vs platform goldens)? Is Impeller vs Skia a factor?
- **Honest verdict for THIS app**: it has a rigidly fixed grid, zero animation, and 3 themes × N text scales. Is that the ideal golden-test case, or a maintenance trap for a solo dev? Argue both sides and commit to an answer.

Give real, current, compiling code.`,
  },
  {
    key: 'a11y-testing',
    prompt: `${PROJECT}

YOUR DIMENSION: Automated accessibility testing in Flutter. THIS IS THE MOST IMPORTANT DIMENSION for this project — a11y is a correctness property here, not polish.

Research with WebSearch/WebFetch: docs.flutter.dev accessibility docs, the flutter_test accessibility API, api.flutter.dev for AccessibilityGuideline, Flutter's own accessibility tests, community articles (check dates).

- **\`meetsGuideline()\` and the built-in guidelines**: \`androidTapTargetGuideline\`, \`iOSTapTargetGuideline\`, \`textContrastGuideline\`, \`labeledTapTargetGuideline\`. Get the EXACT API, the exact thresholds each enforces (Android 48x48? iOS 44x44? contrast 4.5:1?), and how to use them: \`final handle = tester.ensureSemantics(); await expectLater(tester, meetsGuideline(...)); handle.dispose();\` — verify this is current and correct.
- What do these guidelines NOT catch? (Be specific and honest — automated a11y checks famously catch a minority of real issues. What percentage? Any evidence?)
- Can you write a CUSTOM AccessibilityGuideline? This project wants a 76dp minimum target — show how to subclass/implement AccessibilityGuideline to enforce a custom size. Is that API public and stable?
- **Testing semantics**: \`find.bySemanticsLabel\`, \`tester.getSemantics()\`, \`matchesSemantics()\` / \`containsSemantics()\` matchers — the full current API and how to assert a tile is labeled, is a button, is enabled, has the right action. Show real code.
- \`SemanticsController\`, semantic traversal order testing — can you assert the ORDER a screen reader visits tiles? (This matters: a 3x4 grid must be traversed in a predictable order.) Show how.
- Testing that the app respects textScaler / boldText / disableAnimations.
- **Switch Control / Switch Access**: can they be tested automatically AT ALL, or is it manual-only? Honest answer. If manual, what is the actual manual checklist? (Flutter publishes no Switch Control support statement — how do you verify it yourself?)
- Screen reader testing: is there any automation? (TalkBack/VoiceOver in CI — possible? Espresso/XCUITest accessibility audits? Android's Accessibility Scanner / Espresso AccessibilityChecks — do those work on a Flutter app given it's a single canvas view? THIS IS A KEY QUESTION.)
- Are there a11y lints? (flutter_lints? any package?)
- What does the Flutter team itself do to test accessibility?

Be rigorous, get exact API signatures, and give a concrete a11y test suite design for a 12-tile grid.`,
  },
  {
    key: 'drift-testing',
    prompt: `${PROJECT}

YOUR DIMENSION: drift — correct usage, and testing DB code + migrations. A botched migration here loses someone's irreplaceable hand-curated phrase board.

Research with WebSearch/WebFetch: drift.simonbinder.eu (the official docs), pub.dev/packages/drift, the drift GitHub repo, migration docs specifically.

- Current drift version and the 2026 API. Table definition styles (class-based vs .drift files vs \`drift_dev\` codegen). Which for this project?
- \`build_runner\` workflow: \`dart run build_runner build --delete-conflicting-outputs\`, watch mode, what's generated (.g.dart), .gitignore or commit generated files? (argue)
- **Migrations, in depth**: \`schemaVersion\`, \`MigrationStrategy\`, \`onCreate\`, \`onUpgrade\`, \`beforeOpen\`, \`stepByStep\` / \`Migrator.stepByStep\` (verify this API), \`m.addColumn\`, \`m.createTable\`, \`m.alterTable\`/TableMigration for changes SQLite can't do natively.
- **Schema snapshot testing — the crown jewel**: \`drift_dev schema dump\`, \`drift_dev schema generate\`, \`drift_dev schema steps\`, the generated \`schema_v1.dart\`... files, \`SchemaVerifier\`, \`verifier.migrateAndValidate()\`, \`verifier.startAt(n)\`, \`expectedSchema\`. Get the EXACT current commands and test code. Show a complete, real migration test.
- Does drift have a way to test that DATA survives a migration (not just the schema shape)? (I believe there's something about validating data integrity — find it.) THIS IS THE ONE THAT MATTERS: schema correctness is not enough; the user's phrases must still be there and still be correct afterward.
- Testing queries: \`NativeDatabase.memory()\`, in-memory DB in tests, \`setUp\`/\`tearDown\`, logStatements. Show the idiom.
- Is there a \`drift_flutter\` package now? What's the current recommended way to open a DB in a Flutter app (path_provider + NativeDatabase.createInBackground?)? Isolates/background — \`DriftIsolate\`, \`computeWithDriftIsolate\`? Is it worth it for 12 tiles?
- Reactive queries: \`.watch()\`, \`.watchSingle()\`. Correct usage and testing them (expectLater with emitsInOrder).
- Constraints/indexes: how to express the (board_id,row,col) PK and FK constraints in drift. Are FKs even ON by default in SQLite? (\`PRAGMA foreign_keys\` — VERIFY, drift may not enable them by default; that's a real footgun.)
- Transactions and batch.
- What are drift's known footguns?

Give complete, current, compiling code for: table defs matching this project's schema, a migration test, a query test.`,
  },
  {
    key: 'platform-channel-testing',
    prompt: `${PROJECT}

YOUR DIMENSION: Testing platform channels, TTS, and native code.

Research with WebSearch/WebFetch: Flutter docs on plugin/channel testing, flutter_tts source, Pigeon, the current TestDefaultBinaryMessengerBinding API.

- **Mocking a MethodChannel in a Dart test**: the CURRENT API. \`TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler)\` — verify this is right for 2026 (the old \`channel.setMockMethodCallHandler\` was deprecated then removed). Show real code mocking flutter_tts's channel.
- Better: should you mock the channel at all, or wrap flutter_tts behind your own \`SpeechService\` interface and fake THAT? Argue strongly. (The project already has this abstraction.) What's the actual value of channel-level tests then — is there any?
- **Pigeon**: what is it, is it recommended in 2026 for new platform channels, and should this project use it for its 3 native surfaces (Personal Voice, QS tile, ControlWidget)? What does it buy (type safety, generated code, no string method names)? What does it cost? Verify current version/status.
- Testing the NATIVE side: unit tests for the Kotlin \`TileService\` (JUnit/Robolectric) and the Swift bits (XCTest). Is this worth it for a solo dev? Note the QS TileService speaks WITHOUT a Flutter engine — so no Dart test can ever cover it. What's the minimum responsible verification?
- **integration_test** package: what it's for, how it differs from widget tests, running on a real device/emulator, \`IntegrationTestWidgetsFlutterBinding\`. Can it test REAL TTS (assert audio actually played)? Can you assert audio output at all in an automated test? (Honest answer — probably not; say so and give the alternative.)
- **patrol** — the package for native-interaction integration tests (permissions dialogs, notifications). Current status/version. Worth it here?
- How do you test the audio session config (.playback vs .ambient) — the bug where the silent switch mutes the app? Is that testable at all, or is it a manual device checklist item? Be honest and give the manual checklist if so.
- How do you test the voice_filter logic (Android network_required, setVoice returning 0)? That IS pure Dart logic over a data structure — show the test.
- Testing on real devices vs emulators for TTS: does the emulator even have TTS voices? (Big practical question — if the Android emulator has no TTS engine, CI can never test speech.)
- Firebase Test Lab / device farms — relevant for a no-network app?

Be concrete and honest about the limits of automation here.`,
  },
  {
    key: 'lints-tooling',
    prompt: `${PROJECT}

YOUR DIMENSION: Lints, static analysis, formatting, and the analysis_options.yaml this project should ship.

Research with WebSearch/WebFetch: dart.dev/tools/linter-rules, pub.dev/packages/flutter_lints, very_good_analysis, lint, dart_code_metrics (VERIFY ITS STATUS — I believe it went commercial/was discontinued as OSS; check), custom_lint, riverpod_lint, the Dart analyzer docs.

- **The lint package landscape in 2026**: flutter_lints (the official baseline, what's in it), very_good_analysis (VGV's stricter set — current version? how many rules?), lints, lint. Which should THIS project use? Argue. Get current versions.
- What is the state of **dart_code_metrics**? (I believe Dart Code Metrics moved to a paid model / was discontinued as free OSS around 2024. VERIFY and report the truth, and say what replaced it if anything.)
- **custom_lint** + **riverpod_lint**: what do they catch? Worth it? Current status/versions.
- Specific high-value lint rules to enable that are NOT in flutter_lints and would catch real bugs here. Be concrete — name rules. Especially:
  - Something that catches unawaited futures (\`unawaited_futures\`, \`discarded_futures\`) — critical because \`speak()\` is async and a dropped future = silence.
  - \`avoid_dynamic_calls\`, \`always_declare_return_types\`, \`prefer_const_constructors\`, \`use_build_context_synchronously\` (the async-gap BuildContext bug — explain it properly), \`avoid_slow_async_io\`, \`cancel_subscriptions\`, \`close_sinks\`, \`only_throw_errors\`, \`throw_in_finally\`.
  - Rules about exhaustive switches on sealed classes.
- Is there a lint that enforces accessibility (semanticLabel on Image/Icon)? Anything at all?
- \`analyzer\` config: \`errors:\` severity overrides (promote specific lints to ERROR so CI fails), \`exclude:\` for generated files, \`language: strict-casts / strict-inference / strict-raw-types\` — what do those do and should this project turn them on? Get the current syntax.
- \`dart format\` — the 2026 state. Did the formatter change? (There was a major formatter rewrite / "tall style" in Dart 3.7 — VERIFY. What changed, and does it need config? \`formatter: page_width\` in analysis_options?)
- Pre-commit hooks for a solo dev: worth it? (lefthook, husky-equivalents, or just CI?)
- **Write the ACTUAL analysis_options.yaml this project should use**, fully commented, with severity promotions.
- fvm / Flutter version pinning — worth it for a solo dev? How do you pin the Flutter version reproducibly in 2026?`,
  },
  {
    key: 'ci-release',
    prompt: `${PROJECT}

YOUR DIMENSION: CI, release process, and repo hygiene for a solo Flutter dev.

Research with WebSearch/WebFetch: GitHub Actions for Flutter (subosito/flutter-action — current version/status), Codemagic, fastlane, Very Good Workflows, Flutter's own CI docs, Play Console / App Store Connect automation.

- **A concrete GitHub Actions workflow for a Flutter app in 2026**: format check, analyze, test with coverage, build. Get the CURRENT action versions (actions/checkout@v?, subosito/flutter-action@v?) and caching approach. Write the actual YAML.
- Can CI run: unit tests (yes), widget tests (yes), golden tests (platform issues — how?), integration tests (needs an emulator — reasonable in CI? which action? how slow? worth it?)
- Coverage reporting without a paid service: lcov, genhtml, excluding generated files, GitHub Actions coverage comment actions. Is Codecov still free for OSS?
- **Release**: Android signing (keystore, upload key, Play App Signing), \`flutter build appbundle\`, version/build number management (pubspec version, \`--build-number\`), Play Console internal testing track. What's the minimum viable release pipeline for a solo dev? Is fastlane worth it or is manual upload fine for v1?
- \`--obfuscate --split-debug-info\` — should this app obfuscate? (Consider: open-sourcing is the exit plan, and stack traces from the on-device crash log must be readable. That's a real tension — argue it.)
- R8/ProGuard issues with Flutter plugins.
- Reproducible builds / Flutter version pinning in CI (fvm? .fvmrc? the flutter-action version input? What's the 2026 answer?)
- **Repo hygiene**: .gitignore for Flutter (what's actually in the standard one, and should generated .g.dart files be committed? argue both sides — note drift/riverpod codegen), README structure, CHANGELOG (keepachangelog?), conventional commits — worth it for a solo dev? ADRs (architecture decision records) — worth it for a solo dev whose exit plan is open-sourcing?
- Dependency hygiene: \`dart pub outdated\`, Dependabot/Renovate for pub, pinning vs caret ranges in pubspec. What's right for an app (vs a package)?
- **Given the exit plan is open-sourcing**: what must be in the repo from day one so a stranger can pick it up? (LICENSE choice, CONTRIBUTING, docs?) What license fits an app whose goal is to outlive the author?

Write real, current YAML and real file contents.`,
  },
  {
    key: 'performance-startup',
    prompt: `${PROJECT}

YOUR DIMENSION: Flutter performance practices that matter for THIS app, and how to verify them.

Research with WebSearch/WebFetch: docs.flutter.dev/perf, Impeller docs, Flutter DevTools docs, app size docs.

Be RUTHLESS about relevance: this app is a static 12-tile grid with zero animation. Most Flutter perf advice (list virtualization, jank, shader warmup, repaint boundaries) may be irrelevant. Say what's irrelevant and don't pad.

What genuinely matters:
- **Cold start / time-to-first-word.** The product's premise is instant speech. What actually dominates Flutter cold start in 2026 (process spawn, engine init, Dart VM, first frame)? What can a developer actually control? Deferred components? What's the realistic floor on a $120-150 Android phone? How do you MEASURE it properly (\`flutter run --trace-startup --profile\`, the timeline events \`timeToFirstFrameMicros\`, DevTools)? Give the actual command and how to read the output.
- Is there anything to be done about TTS engine init latency at app start (warm-up)?
- **const constructors and rebuild scoping** — do they matter at 12 tiles? Honest answer, but explain the mechanism properly since it's a code standard.
- Widget rebuild profiling in DevTools — worth learning here?
- **App size**: \`flutter build apk --analyze-size\`, what's in a baseline Flutter Android app, tree shaking of icon fonts, and what the sherpa_onnx/Kokoro escape hatch (+55MB) would do to it.
- Impeller: current state on Android in 2026 (default on API 29+? Vulkan fallback?), does it matter for a static grid?
- Battery/thermal — relevant only for the neural TTS path?
- Memory — irrelevant here? Say so.
- **What performance work should this project explicitly NOT do?** Be specific — a solo dev has 2 weeks.
- How do you profile a release build correctly (\`--profile\` mode, never debug)?
- DevTools features actually worth knowing for this app.

Prioritize hard. The honest answer may be "almost none of this matters except cold start" — if so, say it and go deep on that instead of padding.`,
  },
]

phase('Research')
log(`Researching ${DIMENSIONS.length} engineering dimensions, then fact-checking every load-bearing claim (versions/APIs/package status rot fastest).`)

const researched = await pipeline(
  DIMENSIONS,
  (d) => agent(d.prompt, { label: `research:${d.key}`, phase: 'Research', schema: FINDINGS_SCHEMA, effort: 'high' }),
  (res, d) => {
    if (!res) return null
    const lb = (res.findings || []).filter((f) => f.loadBearing)
    if (!lb.length) return { dimension: d.key, research: res, verdicts: [] }
    return parallel(
      lb.slice(0, 7).map((f) => () =>
        agent(
          `You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "${d.key}" made this claim, and a project decision depends on it.

CLAIM: ${f.claim}
DETAIL: ${f.detail}
CLAIMED SOURCES: ${(f.sources || []).join(', ') || '(none)'}
CONFIDENCE: ${f.confidence}

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: pub.dev package pages (for real current versions, publisher, and maintenance status), api.flutter.dev (for real API signatures), dart.dev, docs.flutter.dev, and the actual GitHub repos (for whether something is archived/discontinued).

The failure modes you are hunting for, in order of likelihood:
1. **Version rot** — the claim was true in 2023. APIs get deprecated and removed; \`setMockMethodCallHandler\` moved; \`window\` was deprecated; formatters changed.
2. **Dead packages presented as alive** — golden_toolkit, dart_code_metrics, isar, hive, mockito-vs-mocktail. CHECK THE REPO: is it archived? When was the last publish? Does pub.dev show it as discontinued?
3. **Invented or misremembered API signatures.** If the claim names a method, class, or parameter, VERIFY IT EXISTS with that exact name on api.flutter.dev or the package docs. LLM-plausible API names are a specific hazard here.
4. **Cargo cult** — presenting a team practice or a large-app practice as universal, when the actual source doesn't say that.
5. **Overstated consensus** — "the community recommends X" when it's one blog post.

Default to refuted=true if you cannot independently substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + a correction if directionally right but wrong in specifics (name the exact right version/API). UNVERIFIABLE if no source settles it — and say that plainly rather than guessing.`,
          { label: `verify:${d.key}`, phase: 'Verify', schema: VERDICT_SCHEMA, effort: 'high' }
        ).then((v) => ({ claim: f.claim, ...(v || { refuted: true, verdict: 'UNVERIFIABLE', evidence: 'verifier failed' }) }))
      )
    ).then((verdicts) => ({ dimension: d.key, research: res, verdicts: verdicts.filter(Boolean) }))
  }
)

const ok = researched.filter(Boolean)
log(`${ok.length}/${DIMENSIONS.length} dimensions researched and fact-checked.`)

const digest = ok
  .map((r) => {
    const corr = r.verdicts.filter((v) => v.verdict !== 'CONFIRMED')
      .map((v) => `    - [${v.verdict}] "${v.claim}"\n      CORRECTION: ${v.correction || v.evidence}`).join('\n')
    const conf = r.verdicts.filter((v) => v.verdict === 'CONFIRMED')
      .map((v) => `    - [CONFIRMED] ${v.claim}`).join('\n')
    const code = (r.research.codeExamples || [])
      .map((c) => `  --- ${c.title} ---\n\`\`\`${c.language || 'dart'}\n${c.code}\n\`\`\`\n  ${c.note || ''}`).join('\n')
    return `
### DIMENSION: ${r.dimension}
SUMMARY: ${r.research.summary}

FINDINGS:
${(r.research.findings || []).map((f) => `  - (${f.confidence}${f.loadBearing ? ', LOAD-BEARING' : ''}) ${f.claim}\n    ${f.detail}\n    sources: ${(f.sources || []).join(' | ')}`).join('\n')}

CODE EXAMPLES:
${code || '  (none)'}

FACT-CHECK:
${conf || '    (none confirmed)'}
${corr || '    (no corrections)'}

RECOMMENDATIONS:
${(r.research.recommendations || []).map((p) => `  - [${p.priority}] ${p.rule} — ${p.rationale}`).join('\n')}
`
  }).join('\n---\n')

phase('Critique')
const critiques = await parallel([
  () => agent(`${PROJECT}

Below is the full engineering research corpus (12 dimensions + adversarial fact-checks). You are the COMPLETENESS CRITIC.

${digest}

Identify:
1. CONTRADICTIONS BETWEEN DIMENSIONS — list them explicitly and resolve each with evidence (e.g. does the riverpod dimension's codegen advice conflict with the tooling dimension's build_runner stance? does testing-strategy's coverage advice conflict with what's testable per platform-channel-testing?).
2. Questions a staff engineer would ask that nobody answered.
3. Any API signature, package version, or command in the corpus that is still UNVERIFIED but would be copy-pasted into a doc and fail. Flag every one — a doc that ships a hallucinated API is worse than no doc.
4. Anything entirely unexplored.

Use WebSearch/WebFetch to settle the most important gaps and contradictions YOURSELF. Return prose with specifics.`, { label: 'completeness-critic', phase: 'Critique', effort: 'high' }),

  () => agent(`${PROJECT}

Below is the full engineering research corpus. You are a SKEPTICAL STAFF ENGINEER who has shipped Flutter apps and has strong views about over-engineering.

${digest}

Write the honest memo. Address:
- What in this corpus is CARGO CULT for a one-screen, 6-table, solo-dev, 2-week app? Name names. Clean Architecture? Repository pattern over 6 tables? Riverpod at all? codegen? 100% coverage? melos? Pigeon? ADRs?
- Where does "best practice" actively HURT here — what will the developer spend a day on that returns nothing?
- What is the MINIMUM set of practices that actually protects the things that matter (no telemetry, migration safety, a11y correctness, no silent failures)?
- The corpus will produce four documents. Is that itself over-engineering? What would you cut?
- Where is the research just repeating Flutter-blog conventional wisdom rather than reasoning about THIS app?

Be direct. The developer has 2 weeks. Every practice must earn its place.`, { label: 'skeptic-memo', phase: 'Critique', effort: 'high' }),

  () => agent(`${PROJECT}

Below is the full engineering research corpus. You are a TEST ENGINEER specializing in safety-relevant and accessibility software.

${digest}

Design the actual test strategy for this app, given the hard constraint that **the developer will NEVER receive a crash report or an analytics event — tests are the only feedback loop that exists.**

Specifically:
- Enumerate the SILENT FAILURE modes (user taps a tile mid-shutdown and nothing happens / the wrong thing happens). For each: is it testable in Dart? in a widget test? only on a device? not at all? What is the actual mitigation for the untestable ones?
- What is the minimum test suite that would let a solo dev sleep at night? Be specific about test COUNT and what each covers.
- Migration testing: what does "the user's phrases survive" actually require beyond drift's SchemaVerifier? Design it.
- A11y testing: what does the automated suite genuinely cover vs. what MUST be a manual device checklist? Write the manual checklist.
- What's the highest-value test in the whole app? What's the most over-rated?

Use WebSearch/WebFetch to verify any API you propose. Be concrete — real test names, real code.`, { label: 'test-engineer-review', phase: 'Critique', effort: 'high' }),
])

const critiqueText = critiques.filter(Boolean).map((c, i) => `\n### CRITIQUE ${i + 1}\n${c}`).join('\n')

const AUTHOR_PREAMBLE = `${PROJECT}

You are authoring one of four engineering documents for this project's repo, based on the research corpus and critiques below.

=== RESEARCH CORPUS (12 dimensions, adversarially fact-checked) ===
${digest}

=== CRITIQUES (completeness critic, skeptical staff engineer, test engineer) ===
${critiqueText}

=== AUTHORING RULES — these are strict ===
1. **Output raw GitHub-flavored Markdown. No code fence around the whole document. No preamble, no "Here is the document". Your entire response IS the file contents, starting with the H1.**
2. **NEVER ship an unverified API.** If the corpus's fact-checkers corrected a claim, use the CORRECTED version. If an API, version, or command was flagged UNVERIFIABLE or was never verified, either omit it or mark it inline as \`<!-- VERIFY -->\` with what to check. A hallucinated API in a doc is worse than no doc — the developer will copy-paste it and lose an hour.
3. **Take the skeptical staff engineer seriously.** This is a one-screen, 6-table, solo-dev, 2-week app. Where a practice does not earn its place, SAY SO and say what to do instead. A doc that says "you don't need this" is more valuable than one that hedges. Prefer a short, opinionated doc over a comprehensive one.
4. **Every rule must have a WHY, tied to this app** — not "best practice says so". The good whys here are: no telemetry means tests are the only feedback loop; a botched migration destroys someone's voice; a silent failure means a user in crisis gets no speech; an inaccessible accessibility app is a total failure; a stranger may inherit this code.
5. **Code must compile.** Use real, current (2026, Flutter 3.44 / Dart 3.x) APIs. Prefer showing the real thing over describing it.
6. Be decisive. Where the research contradicted itself, pick a side and say why, or state plainly that it's unresolved. Don't paper over it.
7. Write in prose and tables for humans. Don't pad. Don't restate the project back at the reader.
8. Cite sources as inline markdown links for load-bearing claims.
`

phase('Author')
const [architecture, standards, testing, tooling] = await parallel([
  () => agent(`${AUTHOR_PREAMBLE}

=== YOUR DOCUMENT: docs/ARCHITECTURE.md ===

The structural doc. What goes where and why. Cover:
- The layering decision (and honestly: how much layering does a one-screen app deserve? Google's official MVVM guidance vs. reality at this size — commit to an answer).
- Feature-first vs layer-first for THIS app, decided, with the reasoning. Note these "features" all share one dataset.
- The complete, concrete file tree, annotated — every directory earns a one-line justification.
- Data flow: from a tile tap to audio out, and from an edit to the DB. Draw it (a mermaid diagram is good here — artifacts and GitHub both render \`\`\`mermaid fences).
- The layer boundaries that are LOAD-BEARING here and why: SpeechService as an interface (so it can be faked, and because flutter_tts is a bus-factor-1 MIT package you may vendor), the repository seam (so the UI never touches drift directly), and the native interop boundary (the QS tile speaks with NO Flutter engine — this is an architectural fact, not an implementation detail: the speak path is native and reads shared storage).
- State management: the minimal correct Riverpod usage, current 2026 API. Be honest that it isn't load-bearing at this size and say what it actually buys.
- Error handling architecture: where errors are caught, the Result-vs-exceptions decision for \`speak()\`, and how errors reach the on-device crash log with NO Sentry.
- The data model (the drift schema) and why grid_slots' composite PK is the architectural enforcement of the fixed-position product rule — explain that this makes a product decision structural rather than a discipline.
- What is deliberately NOT abstracted, and why (name the abstractions you're refusing).
- Startup sequence: what happens on cold launch, in order, and the latency budget.

Target 300-500 lines. Opinionated and concrete over comprehensive.`, { label: 'author:ARCHITECTURE', phase: 'Author', effort: 'max' }),

  () => agent(`${AUTHOR_PREAMBLE}

=== YOUR DOCUMENT: docs/CODING_STANDARDS.md ===

How to write the code. Cover:
- Dart 3.x idioms worth using here (sealed classes + exhaustive switch, pattern matching, records, class modifiers) and the ones that are showing off. Only what earns its place.
- The error model, concretely: Error vs Exception, when to throw, when to return a Result, and the sealed Result type this project should use (hand-rolled vs a package — decide). The driving case: \`speak()\` can fail via missing voice / dead engine / setVoice returning 0, and a silent failure means a user in crisis gets NO SPEECH. Show the actual type and the actual call site.
- **The rule that "no failure may be silent"** expressed as concrete coding rules: unawaited futures, swallowed catches, ignored return values. Which lints enforce each.
- Immutability, const, copyWith. The honest verdict on freezed vs manual vs records for a 6-entity app (verify freezed's 2026 status before recommending it).
- Widget conventions: composition over long build methods, when to extract a widget vs a method (and the real rebuild/const reason, explained properly), keys (when they actually matter), no long-press/gesture rules from the product spec.
- **Accessibility as a coding standard, not a checklist**: Semantics on every interactive node, semanticLabel on every Icon/Image, never clamping TextScaler, honoring boldText/highContrast/disableAnimations. Show the right and wrong version of a tile widget side by side.
- Naming and file conventions per Effective Dart.
- Comments and dartdoc: what to document when a stranger may inherit this. Be specific about what NOT to comment.
- Async rules: use_build_context_synchronously and the async-gap bug explained properly, mounted checks, cancelling subscriptions.
- The banned list: what must never appear in this codebase (network calls, analytics, animation >100ms, dynamic, print, pumpAndSettle in tests, etc.) and how each is enforced.
- The complete, fully-commented \`analysis_options.yaml\` this project ships, with severity promotions that make CI fail on the rules that map to real hazards here.

Target 300-500 lines. Show right-vs-wrong code pairs — they teach faster than prose.`, { label: 'author:CODING_STANDARDS', phase: 'Author', effort: 'max' }),

  () => agent(`${AUTHOR_PREAMBLE}

=== YOUR DOCUMENT: docs/TESTING.md ===

**This is the most important of the four documents.** The developer will never receive a crash report or an analytics event. Tests are the only feedback loop that exists. Write it that way — this is not a generic Flutter testing doc, it's a strategy for a codebase that flies blind.

Cover:
- The strategy, derived from the no-telemetry constraint: what that changes vs a normal app, what becomes worth testing that normally isn't, and the honest ratio of unit/widget/integration for THIS app (the test engineer's critique has views — use them).
- **The silent-failure catalogue**: enumerate every way a user taps a tile and gets nothing or the wrong thing. For each: the failure, whether it's testable in Dart / only on a device / not at all, and the actual test or the manual mitigation. This table is the spine of the document.
- The test harness: the \`pumpApp\` pattern with ProviderScope + MediaQuery overrides. Real code.
- Widget tests: the real ones worth writing for a 12-tile grid. Include testing at TextScaler 2.0+ and the RenderFlex-overflow question — **if overflow only logs instead of failing the test, say so and show how to make it fail**, since a silently-overflowing tile at 200% text is exactly this app's failure mode.
- **Accessibility tests**: \`meetsGuideline\` with the real guideline names and thresholds, \`tester.ensureSemantics()\` + \`handle.dispose()\`, semantics matchers, traversal order for a 3x4 grid. Be honest about the fraction of real a11y issues automation catches, and follow it with the **manual device checklist** (Switch Control, VoiceOver, TalkBack, Switch Access) — because Flutter publishes no Switch Control support statement, so the developer must verify it themselves.
- **Migration tests**: the drift SchemaVerifier workflow with the exact current commands, plus the thing that actually matters — proving the user's PHRASES survive, not just that the schema shape is right. Design that test explicitly; schema correctness is not the safety property here.
- Faking the SpeechService (argue fake-over-mock for a 3-method interface), and what channel-level tests are worth (probably nothing — say so if so).
- Golden tests: the honest verdict for a fixed grid × 3 themes × N text scales. Decide, don't hedge. Name only maintained tooling — verify status before recommending anything.
- What is NOT worth testing, explicitly. A solo dev has 2 weeks.
- Coverage: a defensible target and why 100% is or isn't right here; excluding generated files.
- The manual pre-release checklist for everything automation cannot reach (audio session/silent switch, real TTS on a cheap Android, offline/airplane mode, voice deleted mid-session).

Target 400-600 lines. Real, current, compiling test code throughout.`, { label: 'author:TESTING', phase: 'Author', effort: 'max' }),

  () => agent(`${AUTHOR_PREAMBLE}

=== YOUR DOCUMENT: docs/TOOLING.md ===

The build, CI, and repo doc. The shortest of the four — resist padding. Cover:
- Flutter/Dart version pinning: how, and whether a solo dev should bother (decide).
- build_runner: the drift codegen workflow, the real commands, watch mode, and the commit-generated-files question (decide and justify — note it affects coverage and CI).
- The complete GitHub Actions workflow as real YAML, with CURRENT action versions — and mark anything you could not verify inline rather than guessing a version number.
- What CI can and cannot run here (goldens across platforms; integration tests needing an emulator; **and the big one: does an Android emulator even have a TTS engine? If not, speech can never be verified in CI and that must be stated loudly**).
- Coverage tooling without a paid service; excluding generated files.
- Release: Android signing, appbundle, versioning, Play internal testing. Minimum viable for a solo dev — is fastlane worth it? Decide.
- The obfuscation tension: \`--obfuscate --split-debug-info\` vs an on-device crash log that must produce readable stack traces vs open-sourcing as the exit plan. Work it through and give an answer.
- Dependency hygiene: caret ranges vs pinning for an app, \`dart pub outdated\`, and the flutter_tts bus-factor-1 vendoring plan (MIT — what does "vendor it the day it breaks" actually look like as a procedure?).
- Repo hygiene for an app whose exit plan is open-sourcing: LICENSE choice (argue it — the goal is that the app outlives the author), README, what a stranger needs on day one. Are ADRs worth it for a solo dev? Decide.
- Explicitly: what tooling to SKIP and why.

Target 200-350 lines.`, { label: 'author:TOOLING', phase: 'Author', effort: 'max' }),
])

return {
  dimensions: ok.length,
  docs: {
    'docs/ARCHITECTURE.md': architecture,
    'docs/CODING_STANDARDS.md': standards,
    'docs/TESTING.md': testing,
    'docs/TOOLING.md': tooling,
  },
}
