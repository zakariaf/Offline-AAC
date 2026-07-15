# testing-strategy

> Phase: **research** · Agent `ae86d71bb934401ba` · Run `wf_12b14467-451`

## Result

## Summary

The classic test pyramid is an economic argument: higher-fidelity tests cost more to run, so you buy fewer. That economics does not hold in Flutter. Flutter's own tradeoff table rates unit tests "Low" confidence and widget tests "Higher" — while rating BOTH "Quick" to execute. The speed cliff in Flutter sits between widget and integration, not between unit and widget, so the pyramid's justification collapses in its upper-middle. The widget test is genuinely the sweet spot, and Flutter's docs pointedly say "many unit and widget tests" without ranking them. The 70/20/10 ratios in circulation are Mike Cohn folklore reprinted by content farms, not Flutter guidance. For THIS app the question is nearly moot: 12 tiles and a text field contain almost no pure logic, so the testable surface is (a) four genuinely dangerous logic files — migrations, voice_filter, grid_slots, settings — and (b) UI. Test shape follows code shape, not a diagram. The no-telemetry constraint is the crux, and the key insight is that telemetry and tests cover different things: tests cover risks you thought of, telemetry covers the ones you didn't. Deleting telemetry deletes your unknown-unknowns channel, and you cannot refill it with more tests of the same kind. Only two things substitute: test techniques that generate cases you didn't author (seeded random loops — not glados, which is 2 years stale), and a-priori enumeration of the hostile-environment matrix that telemetry would otherwise have discovered for you. It does NOT argue for more integration tests: those run on your one emulator and sample nothing about field device diversity. It argues for making failures visible in-app (since you can't observe them remotely) and then testing that visibility — plus treating the crash log as the most safety-critical feature after speech itself.

### Flutter's own docs rate unit tests LOW confidence and widget tests HIGHER, while rating both 'Quick' — which invalidates the pyramid's core economic argument in Flutter

*Confidence: high, **LOAD-BEARING***

The exact tradeoff table at docs.flutter.dev/testing/overview: Confidence — Unit: Low, Widget: Higher, Integration: Highest. Execution speed — Unit: Quick, Widget: Quick, Integration: Slow. Maintenance cost — Low/Higher/Highest. The pyramid exists because fidelity normally trades against speed; here widget tests buy strictly more confidence at the same speed class. The only real cost cliff is integration. Flutter's guidance sentence is 'a well-tested app has many unit and widget tests, tracked by code coverage, plus enough integration tests to cover all the important use cases' — it deliberately does not rank unit above widget.

- https://docs.flutter.dev/testing/overview

### The widely-cited 70/20/10 (or 60/25/10/5) Flutter test ratios are folklore with no authoritative source

*Confidence: high, **LOAD-BEARING***

Searches surface these numbers only in SEO content-marketing blogs (testsigma, tftus, getautonoma, Medium reposts), each asserting slightly different splits (70/20/10 vs 60/25/10/5) with no citation. None engage with the fact that Flutter widget tests cost roughly the same as unit tests. Flutter's own docs, Very Good Ventures, and the flutter/flutter repo publish no such ratio. Treat any specific percentage split as unsourced.

- https://docs.flutter.dev/testing/overview

- https://testsigma.com/blog/flutter-testing/

### With zero animation, pumpAndSettle should be BANNED as a wait — and repurposed as an ASSERTION that the zero-animation rule holds

*Confidence: high, **LOAD-BEARING***

pumpAndSettle repeatedly pumps until no frames are scheduled, with a 10-minute default timeout; its entire purpose is waiting out animations. Flutter's own API docs say 'it is better practice to figure out exactly why each frame is needed, and then pump exactly as many frames as necessary.' It times out on infinite animations/repeating timers, and flutter/flutter#84966 documents that its stack traces are truncated on timeout — making failures hard to diagnose. In an app with zero animation, every state change settles in ONE frame, so `await tester.pump()` is always sufficient and pumpAndSettle can only add flake. The inversion: after pump(), `tester.binding.hasScheduledFrame` should be false. If it's true, an animation was accidentally introduced. Note Material's InkWell/ripple animates by default — this test would catch a stray InkWell (fix: splashFactory: NoSplash.splashFactory).

- https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html

- https://github.com/flutter/flutter/issues/84966

- https://dcm.dev/blog/2025/07/30/navigating-hard-parts-testing-flutter-developers/

### mocktail is the clear 2026 default: v1.0.5, published ~3 months ago, 2.77M weekly downloads, verified publisher felangel.dev, no build_runner

*Confidence: high*

mocktail 1.0.5, MIT, deps only on collection/matcher/test_api, 1.2k likes, 160 pub points, Dart 3 compatible. Mockito still works but requires @GenerateMocks annotations plus a build_runner codegen step, which adds a generated .mocks.dart file per test — extra build latency and more generated files polluting coverage. For a solo dev on a 2-week MVP, the build_runner tax is real and buys nothing.

- https://pub.dev/packages/mocktail

- https://github.com/felangel/mocktail

### For SpeechService, a hand-written FAKE beats a mock — and the decisive reason is that mocks silently absorb interface changes via noSuchMethod, which is the exact failure mode this project cannot tolerate

*Confidence: high, **LOAD-BEARING***

A mocktail mock is `class MockSpeechService extends Mock implements SpeechService`. Because Mock implements noSuchMethod, adding a 4th method to SpeechService does NOT break the mock at compile time — the mock silently returns null/throws at runtime, and any un-stubbed call is absorbed. A fake (`class FakeSpeechService implements SpeechService`) fails to COMPILE when the interface grows. In a project whose stated worst bug class is silent failure, adopting a test double whose defining feature is silently absorbing calls is philosophically backwards. Second reason: the risk here isn't 'was speak() called' but 'what happens when the voice vanished / setVoice returned 0 / engine is absent' — those are STATE, and a fake models state naturally where a mock needs whenever+side-effect gymnastics. Third: for the open-source exit plan, the fake IS the executable documentation of the SpeechService contract. Use mocktail only for genuine interaction questions (e.g. does tapping tile B call stop() before speak()) — and even there a fake that records calls (i.e. a spy) is sufficient.

- https://pub.dev/packages/mocktail

- https://martinfowler.com/articles/mocksArentStubs.html

- https://pro.codewithandrea.com/flutter-foundations/06-testing-part1/12-testing-dependencies-mocktail-package

### Correct test-double taxonomy (Meszaros/Fowler) — this project needs FAKES and SPIES, and essentially zero true mocks

*Confidence: high, **LOAD-BEARING***

Dummy: passed to satisfy a signature, never used. Stub: returns canned answers, makes no assertions. Spy: a stub that records calls for the test to assert on afterwards. Mock: pre-programmed with expectations that verify themselves and fail the test. Fake: a real working implementation with a shortcut unsuitable for production (in-memory DB). Mapping: FakeSpeechService = fake (+ spy, once it records `spoken`). drift's NativeDatabase.memory() = arguably not even a fake — it is real sqlite3 with in-memory storage, i.e. the real dependency. The DB should NEVER be mocked: 100% of the DB risk lives in SQL/schema/migrations, and a mocked DB tests literally none of it.

- https://martinfowler.com/articles/mocksArentStubs.html

- https://drift.simonbinder.eu/testing/

### VGV's actual argument for 100% coverage is a TEAM-COORDINATION argument, not a correctness argument — and it therefore does not transfer to a solo dev

*Confidence: high, **LOAD-BEARING***

From the primary source (verygood.ventures/blog/road-to-100-test-coverage): VGV concede up front that '100% test coverage doesn't mean 0% bugs.' Their load-bearing reasoning is that any threshold below 100% forces you to DECIDE what to exclude (models? UI? third-party?), and those decisions are subjective and hard to defend. 100% is defensible precisely because it requires no negotiation. That is a mechanism for removing arguments in code review across a consultancy of many engineers on client codebases. A solo dev has no code review and no negotiation, so the benefit VGV is buying does not exist, while the cost (testing trivial code to hit a number, in a 2-week budget) is fully retained. VGV also explicitly permit exceptions for generated code: 'most of them are related to auto generated code... since there is no added value.' Notably their own counter-example — a button test that achieves coverage without verifying the bloc event fired — is an argument that coverage measures the wrong thing.

- https://verygood.ventures/blog/road-to-100-test-coverage/

- https://verygood.ventures/blog/very-good-coverage/

### `flutter test --coverage` omits files that no test imports, silently INFLATING the coverage percentage — the opposite of the safe failure direction

*Confidence: medium, **LOAD-BEARING***

Tracked as flutter/flutter#27997 ('Flutter test coverage will not report untested files') and related #40948 ('Include untested files in test coverage'). A file with zero tests contributes zero lines to the denominator rather than counting as 0% covered. A codebase with one well-tested file and twenty untested ones can report ~100%. Fixes: (a) `dlcov --include-untested-files=true`, or (b) generate a test/coverage_helper_test.dart that imports every lib/ file. This matters here because a coverage number that lies UPWARD is worse than no number at all in a project with no other safety net.

- https://github.com/flutter/flutter/issues/27997

- https://github.com/flutter/flutter/issues/40948

- https://pub.dev/documentation/dlcov/latest/

### drift's generated migration verifier checks schema SHAPE only — it will happily pass a migration that produced the correct schema and destroyed all user data

*Confidence: high, **LOAD-BEARING***

`dart run drift_dev schema dump` exports per-version schemas; `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/` generates the verifier. `verifier.migrateAndValidate(db, targetVersion)` works by extracting CREATE statements from sqlite_schema and semantically comparing them to a reference built by Migrator.createAll(). That is a shape comparison — it does not look at rows. To test DATA survival you must pass `--data-classes --companions` to the generate command, then use `verifier.schemaAt(version)` to get a connection, insert rows using the versioned data classes (imported aliased, e.g. `import 'generated_migrations/schema_v1.dart' as v1;`), migrate, and assert the rows survived. Given that a botched migration here is the loss of someone's voice, the shape-only test is the one that gives false confidence.

- https://drift.simonbinder.eu/migrations/tests/

- https://drift.simonbinder.eu/migrations/step_by_step/

### Testing only adjacent migration steps (1→2, 2→3) misses the most common real-world path: the user who skipped an update and goes 1→3

*Confidence: high, **LOAD-BEARING***

drift's SchemaVerifier lets you startAt(any version) and migrateAndValidate to any target, so N→M for all M>N is cheap to enumerate with a nested loop. Users who install, ignore updates for six months, then update, execute exactly the untested paths. With no telemetry you will never learn this happened — the user just opens the app to an empty board and uninstalls. This is a for-loop over versions, roughly 10 lines, and it is the highest-value test in the codebase.

- https://drift.simonbinder.eu/migrations/tests/

### A pre-migration file backup is a cheaper and STRONGER safety net for user data than any quantity of migration tests — and the two are complements, not substitutes

*Confidence: high, **LOAD-BEARING***

Copy the .sqlite file to board_backup_v{oldVersion}.sqlite immediately before onUpgrade runs; keep the last 2; expose 'Restore previous board' in settings. ~15 lines. Migration tests protect against bugs you enumerated; the backup protects against the migration bug you did not enumerate — which, with no telemetry, is the entire category you cannot see. This is the single highest safety-per-line item in the project and it is not a test at all. The tests then cover the backup/restore path itself.

- https://drift.simonbinder.eu/migrations/

### THE KEY ANSWER: tests and telemetry cover disjoint risk sets — tests cover risks you thought of, telemetry covers the ones you didn't. You cannot refill a deleted discovery channel with more tests of the same kind.

*Confidence: high, **LOAD-BEARING***

This is the central reasoning error to avoid. The instinct 'no crash reporting, so write more tests' is half-right: more tests of things you already thought of adds nothing to the unknown-unknowns channel that Crashlytics provided. Only two things genuinely substitute. (1) Techniques that AUTHOR test cases you didn't write — seeded random/property loops over the edit-mode op space and the DB round-trip. (2) A-PRIORI enumeration of the environment matrix that telemetry would otherwise have discovered empirically: in a normal app you learn from Crashlytics that 4% of users have no TTS engine; here you must enumerate it up front. The correct reframe: normally you test the happy path and let telemetry find the environment; with no telemetry, THE ENVIRONMENT IS THE TEST SUITE.

- https://docs.flutter.dev/testing/overview

- https://verygood.ventures/blog/guide-to-flutter-testing/

### No-telemetry does NOT argue for more integration tests — that instinct is mostly wrong, and acting on it would waste a large fraction of a 2-week budget

*Confidence: high, **LOAD-BEARING***

Integration tests run on YOUR emulator or YOUR one physical device: a single configuration. The unknown-unknown that telemetry surfaced was DEVICE AND ENVIRONMENT DIVERSITY, and one emulator samples none of it. Integration tests are also the slowest and most maintenance-heavy row of Flutter's own tradeoff table. They earn their place here for exactly one reason — they are the ONLY level that exercises the real flutter_tts plugin against a real Android TTS engine and real sqlite, i.e. the native boundary that widget tests stub out entirely. That justifies about 2-3 integration tests (tile→real audible speech; DB survives a real app restart), not a suite. The real substitutes for telemetry are: environment-matrix unit tests, a tested crash log with user-initiated export, LOUD in-app failures, and a small physical device matrix checked manually before release — the last being a process answer, not a test answer.

- https://docs.flutter.dev/testing/overview

- https://docs.flutter.dev/testing/integration-tests

### The crash log is the ONLY field-failure channel, which makes it the most safety-critical feature after speech itself — and it must be tested harder than the tiles

*Confidence: high, **LOAD-BEARING***

Concretely test: FlutterError.onError AND PlatformDispatcher.instance.onError are BOTH routed (they catch different things — the latter catches async errors that escape the framework); runZonedGuarded wraps runApp; the log is FLUSHED not buffered (a crash-on-startup must still leave a readable log — an unflushed buffer loses exactly the crash you most need); the log is BOUNDED (ring buffer / size cap, or it grows forever on a device with no telemetry to notice); the export path works even when the app cannot fully start; and critically a RECURSION GUARD — an exception thrown inside the crash logger must not re-enter the logger. Nobody tests their crash logger. Here it is the last line of sight into the field.

- https://docs.flutter.dev/testing/errors

- https://api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html

### The concrete environment matrix that becomes worth testing here but normally isn't — each entry is a cheap unit test with a fake, and each WILL happen to someone you never hear from

*Confidence: high, **LOAD-BEARING***

TTS: no engine installed; engine installed with zero voices; voice list contains ONLY network_required voices (offline promise + network voice = silence); setVoice returns 0 (flutter_tts logs Log.d and returns 0 on failure — the documented silent-failure vector); the stored voice id was uninstalled since last launch (Android GCs TTS voices — this is HIGHLY likely in the field and is the single most probable silent-failure cause); engine returns success but emits no audio; audio focus denied (call in progress); silent switch on with a misconfigured .ambient session; Bluetooth device yanked mid-utterance. Storage: DB file corrupt; DB read-only; disk full during image write; image path exists in DB but the file was deleted by Android's media cleaner (this happens routinely). Each is a state a fake can enter trivially; none require a device.

- https://pub.dev/packages/flutter_tts

- https://developer.android.com/reference/android/speech/tts/TextToSpeech

### With no remote observability, failures must be made VISIBLE in-app — and the testable invariant is 'never silent': every failure mode yields audible speech OR a visible error, never neither

*Confidence: high, **LOAD-BEARING***

This converts constraint 4 (silent failure is the worst bug class) from a principle into a single parameterized widget test that loops over an enum of every SpeechFailure mode and asserts, for each, that tapping a tile produces either recorded speech on the fake or a findable on-screen error. It is one test that structurally cannot be satisfied by a code path that fails silently, and adding a new failure mode to the enum forces the UI to handle it. This is the highest-value single test in the app.

- https://docs.flutter.dev/testing/overview

### glados is effectively unmaintained — last published ~2 years ago (v1.1.7) — so do NOT take a property-testing dependency; hand-roll a seeded random loop instead

*Confidence: high, **LOAD-BEARING***

glados 1.1.7, last publish ~2 years ago, 50 likes, 27.4k downloads. flutter_glados is a third-party fork last touched June 2025. For a project whose exit plan is 'a stranger picks this up', adding a stale dependency is a liability. A 20-line seeded loop in plain package:test gives you the 80% that matters — generate random op sequences, assert the invariant after each, print the seed on failure so the case is reproducible. What you lose is automatic shrinking; at this scale, printing the seed plus the op list is an adequate substitute, since the op list IS the minimal repro you need to read.

- https://pub.dev/packages/glados

- https://github.com/MarcelGarus/glados

- https://pub.dev/packages/flutter_glados

### TDD-by-SEMANTICS-FINDER resolves the TDD-in-Flutter-UI problem AND mechanically enforces the accessibility constraint — the best available move for this project

*Confidence: medium, **LOAD-BEARING***

Honest baseline: TDD is good for pure logic (voice_filter, migrations, grid invariant — knowable APIs, fast tests) and bad for widget layout, because widget tests written against the tree (find.byType, find.byKey) couple to a structure you discover by looking at the screen, so TDD means writing the tree twice and churning tests on every layout iteration. The escape: find.bySemanticsLabel('Overwhelmed') is STABLE across layout refactors — it names behavior, not structure. So you CAN write it first. The convergence: a tile with no semantics label cannot be found, so the test fails, so an unlabeled tile is a BUILD FAILURE rather than a code-review comment. That is exactly constraint 3's demand that a11y be enforced by tests rather than discipline. Corollary rule: ban find.byType/find.byKey for tiles.

- https://api.flutter.dev/flutter/flutter_test/CommonFinders/bySemanticsLabel.html

- https://docs.flutter.dev/ui/accessibility/accessibility-testing

### Flutter ships four built-in accessibility guideline matchers that turn a11y into a pass/fail assertion — near-zero cost, directly serving 'accessibility is correctness'

*Confidence: high, **LOAD-BEARING***

From docs.flutter.dev/ui/accessibility/accessibility-testing: androidTapTargetGuideline (min 48x48), iOSTapTargetGuideline (min 44x44), labeledTapTargetGuideline (tappable nodes must have labels), textContrastGuideline (WCAG; 3:1 for large text 18pt+). Usage requires tester.ensureSemantics() first, `await expectLater(tester, meetsGuideline(...))`, then handle.dispose() (a leaked SemanticsHandle is itself a flake source). labeledTapTargetGuideline is the one that mechanically forbids an unlabeled tile. Caveat: textContrastGuideline is known to produce false positives over images/gradients — this app's flat, animation-free tiles are close to its ideal case.

- https://docs.flutter.dev/ui/accessibility/accessibility-testing

- https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html

- https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/accessibility.dart

### TextScaler at 200%+ is better tested by asserting no RenderFlex overflow than by a golden — cheaper, more precise, and it fails for the right reason

*Confidence: medium, **LOAD-BEARING***

Overflow throws a FlutterError in debug builds, so pumping the grid wrapped in MediaQuery with TextScaler.linear(2.0)/(3.0) and asserting `tester.takeException()` is null catches clamping/overflow directly, with a readable failure. A golden at 3.0 catches the same bug but fails as an opaque pixel diff. Use goldens as a supplement for the fixed 3x4 grid only, not as the primary text-scale test.

- https://api.flutter.dev/flutter/widgets/MediaQueryData/textScaler.html

- https://api.flutter.dev/flutter/flutter_test/WidgetTester/takeException.html

### Golden tests are unusually well-suited to THIS app (zero animation, fixed grid, deterministic UI removes their main flake source) but must run in Ahem-font CI mode

*Confidence: high*

Goldens' standard objection is churn from animation and layout flux — a design rule here has eliminated it. The remaining flake source is font rasterization differing across macOS/Linux/Windows. Betterment's alchemist solves this by generating two sets: platform goldens (human-readable, for local dev) and CI goldens rendered in the Ahem font (square glyphs, platform-agnostic, constant across OS). Alternative without a dependency: matchesGoldenFile pinned to a single CI platform. Proportionate scope for a 2-week MVP: goldens for the 3x4 grid at textScale 1.0/2.0/3.0 and nothing else — they are the only cheap assertion that the grid DID NOT REFLOW.

- https://github.com/Betterment/alchemist

- https://verygood.ventures/blog/alchemist-golden-tests-tutorial/

- https://leancode.co/glossary/golden-tests-in-flutter

### The Android Quick Settings TileService is a structural test HOLE — by design it runs with NO Flutter engine, so no Flutter test of any level can reach it

*Confidence: high, **LOAD-BEARING***

The architecture decision (Kotlin TileService speaks natively from SharedPreferences with no Flutter engine on that path) is correct for latency in a crisis, but it puts that code permanently outside flutter_test, widget tests, AND integration_test. This is the app's crisis path and it has zero Flutter-side coverage — a fact worth stating plainly rather than papering over. Mitigation: one JVM/Robolectric unit test on the Kotlin side for the SharedPreferences read + parse (the part most likely to break when the Dart side changes a key or format), plus a Dart contract test asserting the Dart writer emits exactly the keys/format the Kotlin reader expects. The two sides share a format with no compiler enforcing it — that seam is where it will silently break.

- https://developer.android.com/reference/android/service/quicksettings/TileService

- https://docs.flutter.dev/testing/integration-tests

### Platform channel test APIs moved to TestDefaultBinaryMessenger — the old MethodChannel.setMockMethodCallHandler is gone, and un-torn-down handlers leak across tests

*Confidence: high*

Current API: TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler), or tester.binding.defaultBinaryMessenger where a WidgetTester exists. Documented as a breaking change at docs.flutter.dev/release/breaking-changes/mock-platform-channels. Must be nulled in tearDown or it leaks into subsequent tests — a classic order-dependent flake. Relevant here only if you test flutter_tts directly; the SpeechService abstraction means you mostly shouldn't (test YOUR wrapper with a fake, not the plugin).

- https://docs.flutter.dev/release/breaking-changes/mock-platform-channels

- https://api.flutter.dev/flutter/flutter_test/TestDefaultBinaryMessenger/setMockMethodCallHandler.html

### Flutter's flakiness sources are enumerable and nearly all are avoidable by construction in this app

*Confidence: high, **LOAD-BEARING***

Ranked: (1) pumpAndSettle over infinite animation/repeating timer — eliminated by the zero-animation rule + a ban; (2) real Timer/Future.delayed — use pump(duration) or FakeAsync; (3) DateTime.now() — inject a clock (crash log timestamps!); (4) unseeded Random — seed it and print the seed; (5) golden font/platform rasterization diffs — Ahem/CI mode; (6) state leaking between tests: drift singletons, SharedPreferences, undisposed ProviderContainer, un-nulled channel handlers, undisposed SemanticsHandle — use addTearDown (co-located with setup, harder to forget than tearDown); (7) order-dependent tests sharing a container; (8) unawaited futures. Note that a solo dev with no CI matrix will experience flake as 'the suite failed once, I re-ran it, it passed, I stopped trusting the suite' — and a distrusted suite in a no-telemetry project is a total loss of the safety net. Flake is not an annoyance here; it is an existential threat to the only thing standing between users and silence.

- https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html

- https://dcm.dev/blog/2025/07/30/navigating-hard-parts-testing-flutter-developers/

- https://api.flutter.dev/flutter/flutter_test/WidgetTester/runAsync.html

### Generated files pollute coverage and must be stripped — for drift specifically the pattern is *.drift.dart as well as *.g.dart

*Confidence: high*

lcov -r coverage/lcov.info 'lib/**/*.g.dart' 'lib/**/*.drift.dart' 'lib/**/*.freezed.dart' -o coverage/lcov.info. Alternatives: dlcov (--exclude-suffix='.g.dart', and --include-untested-files=true which also fixes the inflation bug) or pcov (pcov.yml exclusion list). VGV's very_good_coverage GitHub Action supports an exclude list and a min_coverage threshold. Note this project won't use freezed necessarily, but drift emits .drift.dart (modern) or .g.dart (legacy part-file style) depending on config — check which your setup emits before writing the pattern.

- https://verygood.ventures/blog/very-good-coverage/

- https://pub.dev/documentation/dlcov/latest/

- https://github.com/rrousselGit/freezed/issues/442

### This app has almost no unit-testable surface, so the pyramid inverts here mechanically rather than as a matter of taste

*Confidence: medium, **LOAD-BEARING***

Inventory: the pure-logic files are voice_filter, the grid_slots repository invariant, settings serialization, and migrations — four files. Everything else is UI or a thin wrapper over a plugin. Riverpod is explicitly acknowledged as not load-bearing, so testing providers tests the framework. The conclusion is not 'prefer widget tests philosophically' but 'there is nearly nothing else to unit test.' Test shape should follow code shape. Proportionate target: ~120-180 tests total — roughly 40 migration/DB, 30 speech + voice_filter + failure matrix, 50 widget, 10 a11y/textScale, 3 integration, 2-3 goldens — running in under 30 seconds, which is the number that actually determines whether a solo dev keeps running them.

- https://docs.flutter.dev/testing/overview

## Recommendations

- **[must]** Make the widget test the DEFAULT test type; write unit tests only for the four files that contain real logic (migrations, voice_filter, grid_slots repo, settings). Do not target any published unit/widget ratio.
  - Flutter's own table rates widget tests higher-confidence than unit tests at the same speed class, so the pyramid's economic premise fails. And this app has ~4 files of pure logic — the shape follows the code, not a diagram. The 70/20/10 numbers are unsourced folklore.
- **[must]** Ban pumpAndSettle in this codebase. Use `await tester.pump()`. Add a lint or a grep-based CI check that fails on the string 'pumpAndSettle'.
  - Zero animation means every state change settles in one frame, so pumpAndSettle can only add a 10-minute-timeout flake vector with truncated stack traces (flutter#84966). Its only purpose is waiting out animations you don't have.
- **[must]** Write a 'nothing animates' test: pump the app, tap every tile, and assert tester.binding.hasScheduledFrame is false after a single pump().
  - Converts the zero-animation design rule from discipline into a build failure. Catches a stray Material InkWell ripple, an implicit AnimatedContainer, or a repeating timer the moment it's introduced — each of which is both a latency regression for a distressed user and a future flake source.
- **[must]** Use a hand-written FakeSpeechService implementing the interface, holding failure-mode state and recording spoken utterances. Reach for mocktail only for genuine call-ordering questions.
  - A mocktail mock's noSuchMethod silently absorbs interface additions and un-stubbed calls; a fake fails to compile. Adopting a double whose defining feature is silent absorption is backwards in a project whose worst bug class is silent failure. The fake also models voice-vanished state naturally and documents the contract for whoever inherits the repo.
- **[must]** Never mock the database. Test drift against NativeDatabase.memory() (real sqlite3).
  - All the DB risk is in SQL, schema, and migrations. A mocked DB exercises none of it and produces green tests that prove nothing about the one asset that is irreplaceable.
- **[must]** Add `--data-classes --companions` to drift schema generation and assert DATA survives every migration, not just that the schema shape matches.
  - migrateAndValidate compares CREATE statements from sqlite_schema — it is blind to rows. A migration that produces a perfect schema and drops every board passes it. Schema-shape-only testing here gives precisely false confidence about the one thing that must not break.
- **[must]** Test every migration path N→M for all M>N with a nested loop, not just adjacent steps.
  - The user who ignores updates for six months and then upgrades executes 1→3 directly — the untested path. With no telemetry, that user's boards vanish and you never find out; they just uninstall.
- **[must]** Back up the .sqlite file before onUpgrade runs, keep the last two, and expose 'Restore previous board' in settings. Test the backup/restore path.
  - ~15 lines that protect against the migration bug you did NOT enumerate — which with no telemetry is the whole invisible category. Higher safety-per-line than any migration test. Complements the tests rather than replacing them.
- **[must]** Write one parameterized 'silence is impossible' widget test that loops over an enum of every SpeechFailure mode and asserts each yields audible speech OR a visible on-screen error — never neither.
  - The single highest-value test in the app. Structurally cannot be satisfied by a silently-failing code path, and adding a new failure mode to the enum forces the UI to handle it. This is constraint 4 turned into a compiler-adjacent mechanism.
- **[must]** Enumerate and unit-test the hostile-environment matrix a priori: no TTS engine; zero voices; only network_required voices; setVoice returns 0; stored voice id uninstalled since last launch; engine reports success but emits nothing; audio focus denied; image file deleted by the OS media cleaner; DB corrupt/read-only; disk full.
  - This is the direct answer to the no-telemetry problem. Normally Crashlytics discovers these empirically; here you must enumerate them up front because you will never learn. With no telemetry, the environment IS the test suite. 'Stored voice was GC'd by Android' is the most likely real-world silent failure and costs one test.
- **[must]** Treat the crash log as the most safety-critical feature after speech. Test: both FlutterError.onError and PlatformDispatcher.instance.onError route to it; runZonedGuarded wraps runApp; writes are flushed not buffered; the log is size-bounded; export works when the app can't fully start; and a recursion guard prevents an error inside the logger from re-entering it.
  - It is the only remaining line of sight into the field, which makes it load-bearing infrastructure rather than a nice-to-have. An unflushed buffer loses exactly the startup crash you most need; an unbounded log grows forever with no telemetry to notice.
- **[must]** Find tiles with find.bySemanticsLabel, never find.byType or find.byKey. Enforce with a CI grep over widget tests.
  - Two wins at once: semantics finders are stable across layout refactors (so you can genuinely TDD them, unlike tree-coupled finders), and an unlabeled tile becomes a build failure rather than a review comment — mechanically enforcing constraint 3.
- **[must]** Add meetsGuideline assertions (androidTapTargetGuideline, iOSTapTargetGuideline, labeledTapTargetGuideline, textContrastGuideline) to the main grid test, and always dispose the SemanticsHandle.
  - Four lines that turn accessibility into pass/fail. labeledTapTargetGuideline forbids an unlabeled tile outright. A leaked SemanticsHandle is itself a flake source.
- **[must]** Test TextScaler at 1.0/2.0/3.0 by asserting tester.takeException() is null (no RenderFlex overflow), rather than relying on a golden.
  - Overflow throws in debug, so this fails with a readable error naming the widget; a golden fails as an opaque pixel diff. Directly enforces 'honor TextScaler at 200%+, never clamp'.
- **[must]** Do NOT set a coverage percentage gate. Require 100% on the four danger files only (migrations, voice_filter, grid_slots repo, crash log) and read coverage elsewhere as a report.
  - VGV's own stated justification for 100% is that it removes subjective exclusion ARGUMENTS across a team — a benefit a solo dev cannot collect, while retaining the full cost against a 2-week budget. A gate a solo dev sets gets bypassed or gamed; a targeted danger list does not.
- **[should]** If you report coverage at all, fix the inflation bug first (dlcov --include-untested-files=true, or a generated coverage_helper_test.dart) and strip lib/**/*.g.dart and lib/**/*.drift.dart.
  - flutter test --coverage omits files no test imports, so untested files leave the denominator entirely and the number lies UPWARD. A coverage number that overstates safety is worse than none in a project with no other net.
- **[should]** Substitute for the lost unknown-unknowns channel with a hand-rolled seeded random loop over edit-mode op sequences asserting the grid_slots invariant. Print the seed and op list on failure. Do NOT add glados.
  - This is the only technique that authors cases you didn't think of — the actual thing telemetry provided. glados is ~2 years stale (v1.1.7) and a stale dep is a liability for a repo whose exit plan is a stranger picking it up. 20 lines of package:test gets the 80%; you lose shrinking, but the printed op list is already the repro you'd read.
- **[should]** Write a contract test asserting the Dart writer emits exactly the SharedPreferences keys and format the Kotlin TileService reader expects, plus one Kotlin JVM/Robolectric test for the read+parse.
  - The TileService is the crisis path and by design runs with no Flutter engine, so NO Flutter test can reach it. The Dart/Kotlin format seam has no compiler enforcing it and will silently break when a key is renamed — producing exactly the silent failure the architecture exists to prevent.
- **[should]** Write exactly 2-3 integration tests: tile tap → real audible speech via the real engine; DB survives a real app restart; Quick Settings tile speaks. No more.
  - They earn their place ONLY as the sole exercise of the real plugin/native/sqlite boundary. They do not substitute for telemetry: they run on one emulator and sample nothing about field device diversity — the instinct 'no telemetry, so more integration tests' is mostly wrong and would eat the budget.
- **[should]** Write one pumpApp helper in test/helpers/, mirror lib/ in test/, use addTearDown over tearDown, and stop there. One helpers file, not a test framework.
  - addTearDown is co-located with setup so it's harder to forget — the main defense against handler/container/SemanticsHandle leaks that cause order-dependent flake. Beyond one helper file, test infrastructure is team ceremony a solo dev doesn't need.
- **[should]** TDD the four logic files. Do not TDD widget layout — write those tests immediately after, at the semantics level.
  - Honest answer: TDD works where the API is knowable in advance and tests are fast. Widget tests coupled to the tree mean writing the tree twice and churning the test on every layout iteration. The semantics-finder layer is the exception — it names behavior, so it can be written first.
- **[should]** Limit goldens to the 3x4 grid at three text scales, rendered in Ahem/CI mode (alchemist) or pinned to one CI platform.
  - Zero animation removes goldens' usual flake source, and they're the only cheap assertion that the grid DID NOT REFLOW. But font rasterization still differs across OSes, and goldens beyond this scope are pure churn on a 2-week budget.
- **[should]** Seed every Random, inject a Clock for crash-log timestamps, and never use real Timer/Future.delayed in tests — use pump(duration) or FakeAsync.
  - Flake is not an annoyance here. A solo dev who learns to re-run a red suite stops trusting it, and a distrusted suite in a no-telemetry project means nothing at all stands between users and silence.
- **[avoid]** Do not test: drift's generated CRUD, Riverpod plumbing, flutter_tts itself, theme/settings UI beyond persist-and-reload, private methods, or 'show text' font rendering.
  - Each tests a third party or a triviality. Riverpod is explicitly acknowledged as not load-bearing, so testing providers tests the framework. Test YOUR voice_filter, not flutter_tts.
- **[avoid]** Do not add Patrol, Appium, or any E2E layer.
  - No accounts, no network, one screen. E2E exists to cover cross-system flows this app does not have. It is the slowest, flakiest row of Flutter's own tradeoff table bought for zero coverage gain.
- **[avoid]** Do not chase 100% coverage, and do not use mockito/build_runner for new test code.
  - 100% buys a team-coordination benefit that doesn't exist solo. mockito's codegen step adds build latency and generated files that pollute coverage; mocktail (v1.0.5, 2.77M weekly downloads, verified publisher) is the 2026 default and needs neither.

### The single highest-value test: silence is impossible

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

### Enforce the zero-animation rule mechanically

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

### FakeSpeechService — a fake, not a mock (and it doubles as a spy)

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

### Migration test: data survival across EVERY path, not just adjacent steps

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

### pumpApp helper + accessibility-as-correctness + TextScaler

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

### Poor-man's property test — the substitute for the deleted telemetry channel

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

### Coverage: fix the inflation bug, strip generated files, no percentage gate

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


YOUR DIMENSION: Flutter testing strategy — the overall shape. What to test, what not to, and why.

Research with WebSearch/WebFetch: docs.flutter.dev/testing, Flutter's testing cookbook, the test pyramid debate, Google's testing guidance, Very Good Ventures on testing (they mandate 100% coverage — investigate whether that's actually wise), codewithandrea, Flutter's own repo test conventions.

- The three Flutter test types (unit / widget / integration) — what each is genuinely FOR, real cost/speed of each, and the actual recommended ratio. Does the classic pyramid hold in Flutter, or is the widget test the sweet spot (fast + high fidelity)? Argue with evidence.
- `flutter_test`: WidgetTester, pumpWidget, pump vs pumpAndSettle (**pumpAndSettle is a known flake source and this app has ZERO animation — what follows from that?**), finders (find.byType/byKey/bySemanticsLabel/byTooltip), expectLater, matchers.
- Test organization: mirroring lib/ in test/, naming conventions (`_test.dart`), group/setUp/tearDown, test helpers, `testWidgets` custom wrappers (pumpApp pattern).
- **Mocking**: mocktail vs mockito in 2026 (mockito needs build_runner; mocktail doesn't). Which is the community default now? Verify versions/status. When is a hand-written FAKE better than a mock? (Strong opinion wanted: for a SpeechService with 3 methods, is a fake better?)
- Fake vs stub vs mock vs spy — use the terms correctly and say which this project needs.
- **Coverage**: is 100% coverage wise? VGV mandates it — find the arguments for and against. What's a defensible target for a solo dev? What does coverage MISS? How do you measure it in Flutter (`flutter test --coverage`, lcov, excluding generated files — .g.dart/.freezed.dart pollute coverage, how do you exclude them?)
- **THE KEY QUESTION FOR THIS PROJECT**: with NO crash reporting and NO analytics, the developer never learns about field failures. How should that change the testing strategy vs a normal app? What specifically becomes worth testing that normally isn't? Does it argue for more integration tests? Property-based testing? Be concrete and specific — this is the most important question in your dimension.
- Test flakiness sources in Flutter and how to avoid them.
- What is NOT worth testing (be specific — a solo dev has 2 weeks).
- Is TDD practical in Flutter UI work? Honest answer.
````

</details>
