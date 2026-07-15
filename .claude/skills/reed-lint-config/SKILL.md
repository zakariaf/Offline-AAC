---
name: reed-lint-config
description: Reed's analysis_options.yaml — the version-pinned very_good_analysis include, promotions to error, generated-file excludes, riverpod_lint plugin diagnostics, and the formatter block. Use when editing analysis_options.yaml, adding or disabling a lint, writing an `// ignore:` or `// ignore_for_file:` comment, bumping the Dart SDK or the very_good_analysis version, or explaining why discarded_futures, use_build_context_synchronously, close_sinks, avoid_dynamic_calls or missing_provider_scope fires.
---

# Analyzer configuration

A ready-to-copy, fully commented `analysis_options.yaml` ships at
`assets/analysis_options.yaml`. It is verified against the installed SDK. Copy
it into a package root rather than composing a new one from memory. This file
explains the reasoning so the config survives contact with a future maintainer
who would otherwise "clean it up".

## Why this config is stricter than a normal Flutter app

The app has no telemetry. No Crashlytics, no Sentry, no analytics, no network
at all. Nothing will ever report that it crashed on someone's phone, and the
users cannot file a bug — being unable to speak is the condition the app exists
to serve. The analyzer and the test suite are the only two things standing
between a defect and someone tapping "I need to leave" and hearing nothing.

That is the whole justification. Every promotion to `error` is a **bug class
that produces silence**, not a style preference. Treat a downgrade request the
way a downgrade to a memory-safety check would be treated elsewhere.

## Verified stack

| Component | Version | Note |
|---|---|---|
| Dart | 3.12.2 | tall-style formatter is automatic |
| Flutter | 3.44.6 stable | |
| very_good_analysis (VGA) | 10.3.0 | requires Dart `^3.12.0` |
| riverpod_lint | 3.1.3 | runs on the first-party plugin system |

VGA 10.3.0's current major needs Dart `^3.12.0`. Dart 3.12.2 satisfies it. An
earlier 10.2.0 pin existed only while the project was on Dart 3.11 — do not
reintroduce it.

## The include, and the trap that silently disables everything

```yaml
include: package:very_good_analysis/analysis_options.10.3.0.yaml
```

Pin the version-numbered file, never the bare `analysis_options.yaml`. This
project may be abandoned with someone depending on it; a `pub upgrade` must
never silently change what counts as an error.

**The trap:** if that filename does not exist in the *resolved* package, the
result is a single `warning • include_file_not_found` and analysis continues
with **zero rules**. A green build that checks nothing looks exactly like a
green build that checks everything. Bump the include filename **in the same
commit** as the SDK/VGA bump, and verify the file exists:

```
ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/
```

After any bump, confirm the rules are live by checking that a known violation
still errors — not by observing that analysis is green.

## strict-casts / strict-inference / strict-raw-types

All three are already on, set by VGA. Do **not** add a `language:` block to
restate them — redundant config drifts and then contradicts. If any of those
three ever needs to be relaxed, that is a design problem, not a config problem:
everything crossing a platform channel is `dynamic`, and strict mode is what
forces the guard at the boundary.

## The promotions, as bug classes

### Dropped Futures — a phrase never spoken

```yaml
unawaited_futures: error   # unawaited Future inside an async body
discarded_futures: error   # Future-returning call in a SYNC body
```

VGA has both at info level. At info they are a squiggle a solo dev with no
reviewer scrolls past. Promoted, they mean: a TTS call whose Future is dropped
takes its errors with it, and the user gets silence with no exception anywhere.

### Swallowed failure

```yaml
empty_catches: error
avoid_catches_without_on_clauses: error
only_throw_errors: error
throw_in_finally: error
```

`flutter_tts` already fails quietly — it returns `0` and writes a log line.
That is one layer swallowing failure. A bare `catch` above it makes the failure
invisible at *every* layer. `throw_in_finally` silently replaces the real
exception with a bystander, destroying the only evidence that exists.

### Async + UI

```yaml
use_build_context_synchronously: error
```

After an `await` the widget may be disposed and `context` is a handle into a
dead tree. This is a live hazard in edit mode: await a drift write, then pop the
dialog.

### Resource leaks

```yaml
cancel_subscriptions: error
close_sinks: error
```

A `StreamController` for TTS voice-availability changes that fires on a disposed
notifier is a real fault on the crisis path, so VGA's own `close_sinks: ignore`
is overridden here on purpose.

**Know this before trusting `close_sinks`:** `analyzer: errors:` only *re-ranks
diagnostics that are already produced*. It cannot turn on a lint that is off. If
a probe shows a never-closed `StreamController` producing no diagnostic at all,
the rule is not running, and the fix is to also list it under `linter: rules:`:

```yaml
linter:
  rules:
    - close_sinks
```

Both lines are then required — the `linter:` entry enables, the `errors:` entry
promotes info → error. Verify with an actual leaked controller; never assume.

### Type holes

```yaml
avoid_dynamic_calls: error
always_declare_return_types: error
cast_nullable_to_non_nullable: error
```

Platform channels hand back `Map<Object?, Object?>` — Personal Voice on iOS, the
Android Quick Settings `TileService`, the iOS ControlWidget. An unguarded
dynamic call there throws at runtime, on a device, with nothing to report it.

### Exhaustiveness

```yaml
exhaustive_cases: error
```

This lint only covers the legacy enum-like case (static const instances). A
non-exhaustive switch on a **sealed** class is already a compile error
(`non_exhaustive_switch_statement`) — no lint involved. That is the main reason
failure and mode types are modelled as sealed classes rather than enums: adding
a new failure mode then breaks the build at every call site instead of falling
through a `default` into silence. Prefer sealed classes for anything a switch
must handle completely.

Note the escape hatch and close it: `errors: non_exhaustive_switch_statement:
ignore` *can* silence `dart analyze`, while `dart compile` still fails. CI must
therefore **build**, not merely analyze.

### Shipping hygiene

```yaml
avoid_print: error          # use the on-device exportable crash log
avoid_slow_async_io: error  # tile images are files read near the render path
```

`avoid_print` is an error because stdout logging reaches nobody — there is no
device to read it from. Diagnostics belong in the on-device exportable log.

### Deliberately *not* errors

```yaml
deprecated_member_use: warning
deprecated_member_use_from_same_package: warning
```

A Flutter upgrade must never block an urgent hotfix for someone who cannot
speak. Deprecations are noise on the wrong day. Keep them at `warning`.

### Deliberate downgrades

```yaml
public_member_api_docs: ignore
lines_longer_than_80_chars: ignore
```

`public_member_api_docs` is a package-author rule; this is an app with no
consumers. Requiring a doc comment on every public member costs hours and trains
the reader to ignore lints — an unacceptable cost when lints are one of only two
safety nets. Document the **seams** instead (the speech service, repositories,
migration steps) because taste, not lint, is what makes those readable.

`lines_longer_than_80_chars` only fires on what the formatter cannot split —
long string literals and URLs in comments — so it produces pure noise.

## The excludes, and why they matter for coverage

```yaml
exclude:
  - "**/*.g.dart"
  - "**/*.drift.dart"
  - "**/generated_plugin_registrant.dart"
  - "test/.test_coverage.dart"
  - "test/drift/generated/**"
```

Generated code is not owned here and drift regenerates it on every schema
change; linting it produces findings nobody can act on. It is safe to exclude
**because** migration correctness is enforced by drift's schema tests, not by
lints.

`test/drift/generated/**` is the load-bearing one. Those are drift's exported
schema snapshots — historical artifacts, the baseline the migration tests
compare against. A lint autofix or a reformat there corrupts the baseline, and a
botched migration destroys a hand-curated board: months of someone's phrases,
irreplaceable and unmergeable. Never reformat, never "fix", never regenerate an
old snapshot. Add new snapshots; never edit old ones.

The same excludes must be mirrored in coverage filtering. Generated files
otherwise dilute the coverage number until it stops meaning anything, and
coverage is one of the only two feedback signals that exist.

## No `linter: rules:` block for enabling VGA rules

VGA 10.3.0 already enables everything wanted here, including
`discarded_futures`, `prefer_const_constructors`, `cancel_subscriptions`,
`only_throw_errors`, `avoid_slow_async_io` and `exhaustive_cases`.
(`flutter_lints` 5.0.0 *removed* the `prefer_const_*` rules; VGA keeps them —
one more reason to prefer VGA, since zero animation is a design rule and every
const-able tile subtree should therefore be const.)

To **disable** a VGA rule, write `analyzer: errors: <rule>: ignore`. Never write
`- rule: false` under `linter: rules:` — mixing the list form and the map form
is a config parse error, which is a broken analyzer, which is a green build.

## Plugins

riverpod_lint 3.x runs on the first-party `analysis_server_plugin` system
(Dart 3.10+). `missing_provider_scope` is reported by a plain `flutter analyze`
with no `custom_lint` dependency and no `dart run custom_lint` second pass.

**Never add `custom_lint`.** The legacy plugin system it is built on is
scheduled for deprecation as early as Dart 3.12 — that is the current SDK.

```yaml
plugins:
  riverpod_lint:
    version: ^3.1.3
    diagnostics:
      missing_provider_scope: true
      avoid_build_context_in_providers: true
      avoid_ref_inside_state_dispose: true
      provider_dependencies: true
      functional_ref: false
      notifier_extends: false
      notifier_build: false
```

Syntax rule: with a pub version, the `version:` key is mandatory.
`riverpod_lint: ^3.1.3` with a nested `diagnostics:` is a YAML parse error — a
scalar cannot also have children.

Plugin-defined **warnings** are on by default; plugin-defined **lints** are off
by default and must be opted into explicitly. Missing `ProviderScope` means
every provider read throws on the first tap — hence `missing_provider_scope`.
The codegen-syntax rules are off because the handful of providers here are
hand-written.

Suppress a plugin diagnostic with the namespaced form:
`// ignore: riverpod_lint/missing_provider_scope`.

Each plugin diagnostic is reported **twice** under `flutter analyze` while a
plugin is active. Cosmetic — but any CI threshold based on an issue *count* will
be wrong. Gate on severity, not count.

## Formatter

```yaml
formatter:
  page_width: 80
  trailing_commas: preserve
```

Tall style is selected by the language version in `pubspec.yaml`, not by config.
On Dart 3.12 there is nothing to opt into.

`trailing_commas: preserve` (VGA already sets it; it is restated for the reader)
matters because a trailing comma forces a split. The default, `automate`, lets
the formatter add and remove commas and collapse widget trees onto one line. For
a widget tree describing a fixed 3x4 grid that a stranger must read cold,
one-argument-per-line is worth the vertical space and keeps grid-layout diffs
minimal.

## Suppressions

An `// ignore:` on a promoted rule is a claim that a silence bug is acceptable
here. Write the reason on the line above, naming the mechanism that makes it
safe. Never use `// ignore_for_file:` for a promoted rule — file scope means the
next edit to that file is unprotected and nobody will notice.

## The hole: a green analyzer is not proof a tile speaks

The single most idiomatic way to wire a tile is invisible to every rule above:

```dart
// WRONG — flagged by nothing.
onTap: () => tts.speak('I need to leave'),
```

Not `discarded_futures`, not `unawaited_futures`, not `unused_result`. The arrow
closure *returns* the Future, so every rule considers it used — but the target
type is `VoidCallback`, so Dart discards it silently. The speak fails, the error
evaporates, the user hears nothing, and the analyzer is green.

The mitigation is **structural, never disciplinary** — discipline is what a
solo dev runs out of at 2am:

```dart
// RIGHT — a void-returning method the callback can hold safely.
class SpeechController {
  void speakNow(String phrase) {
    unawaited(_speak(phrase).catchError(_report));
  }
}
// onTap: () => controller.speakNow('I need to leave'),
```

`speakNow` returns `void` and swallows nothing — it routes the failure to the
reporting path. A callback then never holds a Future and the hole is unreachable
by construction. **Never call a Future-returning method directly from a
callback.**

Generalise the lesson. A green analyzer is not an accessible app, is not a
surviving migration, and is not proof that a tile speaks. The highest-severity
failure modes here — an audio session muted by the silent switch, the engine
reporting success while emitting no audio, a stale Quick Settings phrase — are
invisible to every rule in this file and to every automated test that exists.
Those need a manual on-device pass. Never report "analyzer clean" as evidence
that speech works.
