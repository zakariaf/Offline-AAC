# lints-tooling

> Phase: **research** · Agent `ae672694512cb1b16` · Run `wf_12b14467-451`

## Result

## Summary

I did not just read docs — I built a throwaway Flutter probe project against the SDK actually installed on this machine and ran the proposed config through `flutter analyze`. That caught three things the web sources got wrong, including one that matters a lot. The headline: **`discarded_futures` does NOT catch `onTap: () => tts.speak('...')`** — the arrow closure "returns" the Future so the lint considers it handled, but it is being assigned to a `VoidCallback`, so the Future (and any error) is silently dropped. That is the single most idiomatic way to wire a Flutter tile, it is exactly this project's silence bug, and no lint in the ecosystem catches it. The fix is structural, not disciplinary: `SpeechController` must expose a **void-returning** `speakNow(String)` that internally does `unawaited(_speak(p).catchError(...))`, so a callback never touches a Future and the hole is unreachable by construction. I verified that pattern analyzes clean. Recommendation: **very_good_analysis (212 rules, strict-casts/inference/raw-types already on) over flutter_lints**, with ~20 severity promotions to `error` for the silence/leak/dynamic bug classes, plus two deliberate downgrades (`public_member_api_docs`, `lines_longer_than_80_chars`) for solo-dev proportionality. **Do not adopt custom_lint** — riverpod_lint 3.x already migrated to the first-party `analysis_server_plugin` system (verified: `missing_provider_scope` fires from a plain `flutter analyze` with no second pass), and the legacy plugin system custom_lint is built on is scheduled for deprecation as early as Dart 3.12. dart_code_metrics is confirmed dead as OSS (commercial DCM at dcm.dev). **There is no usable accessibility lint** — the one candidate is abandoned — so a11y must be enforced by tests, which sharpens rather than weakens the accessibility-is-correctness constraint. The shipped file is at /Users/zakariafatahi/50-apps-challenge/Offline-AAC/analysis_options.yaml and analyzes clean.

### `discarded_futures` and `unawaited_futures` both FAIL to catch the arrow-closure callback idiom `onTap: () => tts.speak('x')`, which is precisely this project's silence bug.

*Confidence: high, **LOAD-BEARING***

Verified empirically on Dart 3.11.0 with very_good_analysis 10.2.0. Probe results by line: (A) `GestureDetector(onTap: () => tts.speak('A'))` → NO DIAGNOSTIC. (B) `onTap: () { tts.speak('B'); }` block body → discarded_futures fires. (C) `onTap: () async { tts.speak('C'); }` → unawaited_futures fires. (D) sync method `void _onTapD() { tts.speak('D'); }` → discarded_futures fires. The arrow form escapes because the closure body IS the invocation, so the rule treats the Future as 'returned' — but the target type is VoidCallback, so it is dropped along with any error. Mitigation verified to analyze clean: a void-returning `void speakNow(String p) { unawaited(_speak(p).catchError((Object e, StackTrace s) { /* crash log + visible banner */ })); }` — the callback then never holds a Future.

- local probe: flutter analyze, Dart 3.11.0 / very_good_analysis 10.2.0

- https://dart.dev/tools/linter-rules/discarded_futures

### riverpod_lint 3.x has migrated OFF custom_lint onto the first-party `analysis_server_plugin` system; custom_lint should not be added to this project at all.

*Confidence: high, **LOAD-BEARING***

riverpod_lint 3.1.4 is latest on pub (3.1.3 resolves on Dart 3.11). It is configured via a TOP-LEVEL `plugins:` block, not `analyzer: plugins:`. Verified: `missing_provider_scope` was reported by a plain `flutter analyze` with no custom_lint dependency and no `dart run custom_lint` second pass. Analyzer plugin support landed in Dart 3.10. The Dart team's tracking issue (dart-lang/sdk#62164) states legacy plugins — whose 'primary client' is explicitly named as custom_lint — will be deprecated 'as early as Dart 3.12' and disabled possibly the following release. custom_lint is still at 0.8.1 (Invertase).

- https://pub.dev/packages/riverpod_lint

- https://dart.dev/tools/analyzer-plugins

- https://github.com/dart-lang/sdk/issues/62164

- local probe

### The `plugins:` block syntax with a pub version requires an explicit `version:` key — the shorthand form is a YAML parse error if you also want `diagnostics:`.

*Confidence: high, **LOAD-BEARING***

`plugins:\n  riverpod_lint: ^3.1.3\n    diagnostics:` → `error • Mapping values are not allowed here` (a YAML scalar cannot also have children). Correct: `plugins:\n  riverpod_lint:\n    version: ^3.1.3\n    diagnostics:\n      missing_provider_scope: true`. Per the docs and confirmed by probe: plugin-defined WARNINGS are enabled by default; plugin-defined LINTS are disabled by default and must be opted in under `diagnostics:`. Suppression uses `// ignore: plugin_name/diagnostic_code`.

- local probe

- https://dart.dev/tools/analyzer-plugins

### very_good_analysis sets `close_sinks: ignore` — a rule this project specifically needs, so the override is load-bearing rather than decorative.

*Confidence: high, **LOAD-BEARING***

VGA 10.2.0's own analyzer block: `errors: {close_sinks: ignore, unrelated_type_equality_checks: warning, collection_methods_unrelated_type: warning, missing_return: error, missing_required_param: error, record_literal_one_positional_no_trailing_comma: error}`. This project holds a StreamController for TTS voice-availability changes, so `close_sinks: error` is re-enabled explicitly. VGA also already sets `language: {strict-casts: true, strict-inference: true, strict-raw-types: true}` and `formatter: trailing_commas: preserve`, so those need no restating.

- ~/.pub-cache/hosted/pub.dev/very_good_analysis-10.2.0/lib/analysis_options.10.2.0.yaml

### very_good_analysis 10.3.0 CANNOT be used on this machine — it requires Dart 3.12, and a wrong version in the `include:` silently downgrades to a warning and disables all 212 rules.

*Confidence: high, **LOAD-BEARING***

VGA 10.2.0 pubspec: `environment: sdk: ^3.11.0`. Machine has Dart 3.11.0, so pub resolves 10.2.0 even though 10.3.0 is latest. My first draft used `include: package:very_good_analysis/analysis_options.10.3.0.yaml` and produced only `warning • The URI ... can't be found ... • include_file_not_found` — analysis silently continued with NO VGA rules. This is a genuinely dangerous failure mode: a warning, not an error, on a project whose entire safety net is static analysis. Verify with `ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/`.

- local probe

- VGA 10.2.0 pubspec.yaml

### The installed SDK is Flutter 3.41.2 / Dart 3.11.0 — NOT the Flutter 3.44 / Dart 3.12 the brief assumes.

*Confidence: high, **LOAD-BEARING***

`dart --version` → 3.11.0 (stable, 2026-02-09). `flutter --version` → 3.41.2, channel [user-branch], revision 90673a4eef (2026-02-18). Flutter 3.44 (Dart 3.12) is indeed current stable as of ~May 2026, so this machine is ~2 releases behind. Every version claim in this report is pinned to what actually resolves at 3.11, not to pub.dev's 'latest'. This drift between assumed and installed SDK is itself the argument for pinning.

- local `dart --version` / `flutter --version`

- https://docs.flutter.dev/release/release-notes/release-notes-3.44.0

### Non-exhaustive switches over sealed classes are already a COMPILE ERROR — no lint is needed, and this is the strongest argument for modelling failures as sealed classes.

*Confidence: high, **LOAD-BEARING***

Verified: omitting a subtype yields `error • The type 'SpeechFailure' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'EngineSilent()' • non_exhaustive_switch_statement` — from the compiler, not the linter, and unsuppressable by lint config. Concrete consequence: model SpeechFailure/OutputMode as `sealed class`, and adding a new failure mode breaks the build at every call site instead of falling through to silence. The `exhaustive_cases` lint (already in VGA) only covers enums and static-const-instance classes.

- local probe

### dart_code_metrics is confirmed dead as free OSS; the successor DCM is commercial. Do not plan around it.

*Confidence: high, **LOAD-BEARING***

The pub package `dart_code_metrics` was discontinued around July 2023 and its license moved off MIT. The successor is DCM at dcm.dev, requiring a purchased license (dcm.dev/pricing), actively developed (v1.25.0 blog post, Dec 2025). DCM does own the only credible a11y rules (e.g. `avoid-missing-image-alt`), which is the one real loss — but a paid dependency is a poor fit for a solo 2-week MVP whose exit plan is open-sourcing for strangers to build.

- https://github.com/dart-code-checker/dart-code-metrics

- https://dcm.dev/blog/2024/12/09/whats-new-in-dcm-1-25-0/

- https://dcm.dev/docs/rules/flutter/avoid-missing-image-alt/

### There is NO usable accessibility lint in the free ecosystem. The only candidate, `accessibility_lint`, is abandoned.

*Confidence: high, **LOAD-BEARING***

`accessibility_lint` 1.0.0, published 19 months ago, 0 likes, 183 total downloads, 50/160 pub points, unverified publisher, Apache-2.0, and built on custom_lint (i.e. on the plugin system scheduled for deprecation). Its five rules (Icon/Image semanticLabel, IconButton tooltip, min tap size, haptics) are exactly what this project wants, but the package is not a dependency worth taking. dart-lang/sdk#58251 tracks first-party a11y linters — still open. CONSEQUENCE: TextScaler-at-200%, Semantics-on-every-tile, and label-vs-vocalization correctness are UNENFORCEABLE by lint and must be widget tests. No lint config can discharge the accessibility-is-correctness constraint.

- https://pub.dev/packages/accessibility_lint

- https://github.com/dart-lang/sdk/issues/58251

### flutter_lints 5.0.0 REMOVED the `prefer_const_*` rules; very_good_analysis retains them.

*Confidence: high*

flutter_lints changelog — 5.0.0 removed `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`, `avoid_null_checks_in_equality_operators`. 6.0.0 (latest, ~13 months old) added `strict_top_level_inference` and `unnecessary_underscores`, min SDK Flutter 3.32/Dart 3.8. VGA 10.2.0 still enables all the const rules. Relevant because zero-animation/deterministic-UI is a design rule here: const-ing every tile subtree that can be const removes rebuilds on the crisis path.

- https://pub.dev/packages/flutter_lints/changelog

- VGA 10.2.0 rule list

### The Dart 3.7 'tall style' formatter rewrite needs no opt-in; style is selected by the pubspec language version, and only page_width/trailing_commas are configurable.

*Confidence: high*

The formatter was rewritten in Dart 3.7 with two styles. Code at language version <=3.6 keeps short style; >=3.7 gets tall style automatically — so on Dart 3.11 there is nothing to enable. Config (verified accepted): top-level `formatter: {page_width: 80, trailing_commas: preserve}`. `trailing_commas` accepts `automate` (default: formatter adds/removes commas and may collapse widget trees onto one line) or `preserve` (a trailing comma forces a split). VGA already sets `preserve`. For a 3x4 grid widget tree a stranger reads cold, `preserve` is worth the vertical space and keeps layout diffs minimal.

- https://github.com/dart-lang/dart_style/wiki/Configuration

- https://dart.dev/blog/announcing-dart-3-7

- local probe (config accepted)

### `unawaited_futures` and `discarded_futures` are complementary, both already in VGA, and both need promoting to error here.

*Confidence: high, **LOAD-BEARING***

unawaited_futures covers unawaited Futures inside ASYNC bodies; discarded_futures covers Future-returning calls in SYNC bodies (dispose(), initState(), onPressed). Both confirmed present in VGA 10.2.0's 212-rule list at info severity — my earlier read that VGA omits discarded_futures was wrong. Escape hatch is `unawaited(...)` from dart:async, which is explicit and greppable.

- VGA 10.2.0 rule list (grep)

- https://dart.dev/tools/linter-rules/unawaited_futures

### Every diagnostic is reported TWICE under `flutter analyze` when an analysis_server_plugin is active.

*Confidence: medium*

Observed consistently across all probe runs: each issue printed exactly twice (e.g. `use_build_context_synchronously` at probe.dart:26:17 listed twice), and the '15 issues found' count double-counts. Affects both plugin-defined and core diagnostics. Cosmetic, but it will make CI output confusing and any issue-count threshold wrong. Cause unconfirmed — likely a double-registration bug in the plugin host on Dart 3.11.

- local probe (reproduced across 4 runs)

### very_good_analysis 10.3.0 is latest on pub (published ~June 2026) and enables 212 rules at 10.2.0.

*Confidence: high*

`grep -cE '^\s+- '` on analysis_options.10.2.0.yaml → 212. VGA ships every historical versioned file (1.0.0 through 10.2.0) plus an unversioned analysis_options.yaml alias. Confirmed present: discarded_futures, unawaited_futures, exhaustive_cases, avoid_catches_without_on_clauses, avoid_dynamic_calls, avoid_slow_async_io, cancel_subscriptions, only_throw_errors, prefer_const_constructors, public_member_api_docs, lines_longer_than_80_chars, require_trailing_commas, flutter_style_todos.

- https://pub.dev/packages/very_good_analysis

- local pub-cache inspection

### FVM 4.1.2 is actively maintained and is the pragmatic way to pin Flutter, but pinning matters here for a reason beyond reproducibility.

*Confidence: medium, **LOAD-BEARING***

fvm 4.1.2 published ~19 days ago, verified publisher (leoafarias.com), 722 likes, 198k weekly downloads. `fvm use stable --pin` resolves 'stable' to a concrete version and writes a committed project config. The argument for THIS project is concrete: the brief asserts Flutter 3.44/Dart 3.12 while the machine runs 3.41.2/Dart 3.11 — that gap already silently changed which very_good_analysis version resolves (10.2.0 vs 10.3.0), which in turn would have silently disabled all 212 lints via include_file_not_found. On a project with no telemetry, an unpinned SDK means the safety net can quietly change under you. Config filename (.fvmrc vs legacy fvm_config.json) not verified.

- https://pub.dev/packages/fvm

- https://fvm.app/

- local version comparison

## Recommendations

- **[must]** Never call a Future-returning method directly from a widget callback. Route every tile tap through a void-returning `SpeechController.speakNow(String)` that internally does `unawaited(_speak(p).catchError(...))`.
  - VERIFIED lint hole: `onTap: () => tts.speak('x')` is caught by NEITHER discarded_futures NOR unawaited_futures, because the arrow closure returns the Future into a VoidCallback. This is the exact silence bug the whole project fears and no lint in the ecosystem catches it. A void-returning seam makes the hole unreachable by construction rather than relying on discipline — which matters because with no telemetry, discipline failures are never discovered.
- **[must]** Use `include: package:very_good_analysis/analysis_options.10.2.0.yaml` (version-pinned), and re-check the filename exists after any SDK or VGA bump: `ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/`.
  - A wrong version in the include produces only `warning • include_file_not_found` and silently continues with ZERO lint rules. On a project whose sole safety net is static analysis, silently losing all 212 rules is a catastrophic failure mode that looks like a passing build. Version-pinning (vs the unversioned alias) also ensures `pub upgrade` can never silently redefine what counts as an error on a project that may be abandoned.
- **[must]** Adopt very_good_analysis, not flutter_lints, and do not add a `linter: rules:` block — express all customization through `analyzer: errors:`.
  - VGA gives 212 rules plus strict-casts/strict-inference/strict-raw-types already on, versus flutter_lints' much smaller set which also REMOVED the prefer_const_* rules in 5.0.0. VGA already contains every rule this project wants (discarded_futures, avoid_dynamic_calls, cancel_subscriptions, only_throw_errors, avoid_slow_async_io, exhaustive_cases), so the only work left is severity. Mixing the list form (`- rule`) and map form (`rule: false`) under `linter: rules:` is a config parse error — use `errors: <rule>: ignore` to disable.
- **[must]** Explicitly set `close_sinks: error`, overriding VGA.
  - VGA ships `close_sinks: ignore` in its own analyzer block. This project holds a StreamController for TTS voice-availability changes; a leaked sink firing on a disposed notifier is a fault on the crisis path. This is one of the few places VGA's defaults are actively wrong for this app.
- **[avoid]** Do NOT add custom_lint. Configure riverpod_lint through the top-level `plugins:` block using the `version:` + `diagnostics:` map form.
  - riverpod_lint 3.x already runs on the first-party analysis_server_plugin system — verified working with a plain `flutter analyze`, no second pass, no extra dependency. The legacy plugin system custom_lint is built on is slated for deprecation as early as Dart 3.12 (the very next SDK) and removal soon after. Adopting custom_lint now buys a migration you'd have to undo, on a project that may be abandoned and must keep working unmaintained.
- **[must]** Model SpeechFailure, OutputMode, and every TTS/DB result type as `sealed class`, never as an enum + default case.
  - Verified: non-exhaustive switches on sealed classes are a COMPILE ERROR (non_exhaustive_switch_statement), enforced by the compiler and not suppressable by lint config — strictly stronger than any lint. Adding a new failure mode then breaks the build at every call site instead of falling through a `default:` into silence. This is the cheapest available substitute for the telemetry this app will never have.
- **[avoid]** Do not add `accessibility_lint` or any other a11y lint package. Enforce Semantics, TextScaler at 200%+, and label-vs-vocalization with widget tests instead.
  - The only free a11y lint is abandoned (0 likes, 183 downloads, 19 months stale, unverified publisher, built on the deprecating custom_lint). The only credible a11y rules live in commercial DCM. Since accessibility is correctness here and no lint can enforce it, the entire burden falls on tests — this should raise the a11y test budget, not lower the a11y bar. Taking a dead dependency would create false confidence, which is worse than none.
- **[must]** Promote the silence bug classes to `error`: unawaited_futures, discarded_futures, empty_catches, avoid_catches_without_on_clauses, only_throw_errors, throw_in_finally, use_build_context_synchronously, cancel_subscriptions, close_sinks, avoid_dynamic_calls, always_declare_return_types, cast_nullable_to_non_nullable, exhaustive_cases, avoid_print, avoid_slow_async_io.
  - All are already in VGA at info severity, where they are grey squiggles that a solo dev with no reviewer will scroll past. Promotion turns each into a red build failure. Each maps to a concrete way this app goes silent: a dropped speak(), a swallowed flutter_tts failure (it returns 0 with only a Log.d), a dead BuildContext after awaiting a drift write, an unguarded dynamic from a platform channel (Personal Voice, QS TileService, ControlWidget).
- **[should]** Downgrade `public_member_api_docs: ignore` and `lines_longer_than_80_chars: ignore`.
  - Proportionality — the brief explicitly asks what to SKIP. public_member_api_docs is a rule for PACKAGE authors; this is an app, and a doc comment on every public member costs hours and buys nothing. Readability-for-a-stranger comes from doc comments on the SEAMS (SpeechService, repositories, migration steps), which is a taste/CONTRIBUTING.md matter. lines_longer_than_80_chars only fires on what the formatter cannot split (long strings, URLs in comments) since the formatter already wraps code.
- **[should]** Keep `deprecated_member_use` and `deprecated_member_use_from_same_package` at `warning`, never `error`.
  - The machine is already 2 Flutter releases behind (3.41.2 vs 3.44 stable). Promoting deprecations to error means a routine Flutter upgrade blocks an urgent hotfix. For an app people depend on to speak, shipping a fix must never be gated on cleaning up deprecation churn.
- **[must]** Exclude generated code (`**/*.g.dart`, `**/*.drift.dart`, `**/generated_plugin_registrant.dart`) and drift's exported schema snapshots (`test/drift/generated/**`) from analysis.
  - VGA excludes only test/.test_coverage.dart and lib/generated_plugin_registrant.dart, so drift output is NOT excluded by default and will drown the 212-rule config in noise. Critically, drift's exported schema snapshots are historical artifacts that must never be reformatted or 'fixed' — a lint autofix touching them would corrupt the migration test baseline, and a botched migration is the loss of someone's voice. Excluding generated code is safe precisely because migration correctness lives in schema tests, not lints.
- **[should]** Skip pre-commit hooks (lefthook/husky). Run `flutter analyze` + `dart format --output=none --set-exit-if-changed .` + the drift migration tests in CI instead.
  - Explicitly answering the 'be honest about what to SKIP' constraint. For a solo dev the IDE already surfaces every promoted error as a red squiggle in real time, so a pre-commit hook mostly adds latency and a `--no-verify` habit. The gate that actually earns its keep is CI running migration tests — the irreplaceable-data risk — not a format check that blocks a commit.
- **[should]** Pin the Flutter SDK with `fvm use stable --pin` and commit the FVM config.
  - Not abstract reproducibility: the assumed SDK (3.44/Dart 3.12) and the installed one (3.41.2/Dart 3.11) already differ, and that gap silently changes which VGA version resolves (10.3.0 vs 10.2.0) — which, via include_file_not_found, silently disables all 212 lints. With no telemetry, a safety net that can quietly change under you is a real hazard. Pinning also serves the abandonment exit plan: a stranger cloning the repo in 2028 gets the SDK the lints were written against.

### The verified lint hole — what discarded_futures does and does NOT catch

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

### The structural fix — a void-returning seam that makes the hole unreachable

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

### Sealed classes give exhaustiveness as a COMPILE error — stronger than any lint

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

### Correct `plugins:` syntax for riverpod_lint — the version-plus-diagnostics form

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

### The severity promotions that matter — analyzer: errors: block

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


YOUR DIMENSION: Lints, static analysis, formatting, and the analysis_options.yaml this project should ship.

Research with WebSearch/WebFetch: dart.dev/tools/linter-rules, pub.dev/packages/flutter_lints, very_good_analysis, lint, dart_code_metrics (VERIFY ITS STATUS — I believe it went commercial/was discontinued as OSS; check), custom_lint, riverpod_lint, the Dart analyzer docs.

- **The lint package landscape in 2026**: flutter_lints (the official baseline, what's in it), very_good_analysis (VGV's stricter set — current version? how many rules?), lints, lint. Which should THIS project use? Argue. Get current versions.
- What is the state of **dart_code_metrics**? (I believe Dart Code Metrics moved to a paid model / was discontinued as free OSS around 2024. VERIFY and report the truth, and say what replaced it if anything.)
- **custom_lint** + **riverpod_lint**: what do they catch? Worth it? Current status/versions.
- Specific high-value lint rules to enable that are NOT in flutter_lints and would catch real bugs here. Be concrete — name rules. Especially:
  - Something that catches unawaited futures (`unawaited_futures`, `discarded_futures`) — critical because `speak()` is async and a dropped future = silence.
  - `avoid_dynamic_calls`, `always_declare_return_types`, `prefer_const_constructors`, `use_build_context_synchronously` (the async-gap BuildContext bug — explain it properly), `avoid_slow_async_io`, `cancel_subscriptions`, `close_sinks`, `only_throw_errors`, `throw_in_finally`.
  - Rules about exhaustive switches on sealed classes.
- Is there a lint that enforces accessibility (semanticLabel on Image/Icon)? Anything at all?
- `analyzer` config: `errors:` severity overrides (promote specific lints to ERROR so CI fails), `exclude:` for generated files, `language: strict-casts / strict-inference / strict-raw-types` — what do those do and should this project turn them on? Get the current syntax.
- `dart format` — the 2026 state. Did the formatter change? (There was a major formatter rewrite / "tall style" in Dart 3.7 — VERIFY. What changed, and does it need config? `formatter: page_width` in analysis_options?)
- Pre-commit hooks for a solo dev: worth it? (lefthook, husky-equivalents, or just CI?)
- **Write the ACTUAL analysis_options.yaml this project should use**, fully commented, with severity promotions.
- fvm / Flutter version pinning — worth it for a solo dev? How do you pin the Flutter version reproducibly in 2026?
````

</details>
