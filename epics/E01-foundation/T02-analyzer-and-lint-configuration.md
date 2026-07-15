# E01-T02 — Analyzer and lint configuration

| | |
|---|---|
| **Epic** | E01 — Foundation |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E01-T01 |
| **Blocks** | E01-T04, E01-T05 |

**Skills:** `reed-lint-config` · `reed-code-bans` · `reed-no-silent-failures`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

There is no telemetry. Nobody will ever learn the app crashed on someone's phone, and the user cannot file a bug — being unable to speak is the condition the app exists to serve. The analyzer and the test suite are the only two things between a defect and a person tapping "I need to leave" and hearing nothing. Every promotion to `error` in this file is a bug class that produces silence, so it gets treated the way a memory-safety check gets treated elsewhere.

## Scope

Ship `analysis_options.yaml` at the package root. A ready-to-copy, fully commented, SDK-verified file exists in the `reed-lint-config` skill at `assets/analysis_options.yaml`. **Copy it. Do not compose a new one from memory.** The rest of this section is what you must be able to defend about the file you just copied.

### The include — pinned, and it fails open

```yaml
include: package:very_good_analysis/analysis_options.10.3.0.yaml
```

Version-numbered file, never the bare `analysis_options.yaml`. This project may be abandoned with someone depending on it; a `pub upgrade` must never silently change what counts as an error.

Verified stack: Dart **3.12.2**, Flutter **3.44.6 stable**, very_good_analysis **10.3.0** (requires Dart `^3.12.0`), riverpod_lint **3.1.3**. The earlier **10.2.0** pin existed only while the project was on Dart 3.11 — do not reintroduce it.

No `language:` block. VGA 10.3.0 already sets `strict-casts`, `strict-inference` and `strict-raw-types`; restating them is redundant config that drifts and then contradicts.

### The promotions, each as its bug class

```yaml
analyzer:
  errors:
    # Dropped Futures — a phrase never spoken
    unawaited_futures: error       # unawaited Future inside an async body
    discarded_futures: error       # Future-returning call in a SYNC body

    # Swallowed failure
    empty_catches: error
    avoid_catches_without_on_clauses: error
    only_throw_errors: error
    throw_in_finally: error

    # Async + UI
    use_build_context_synchronously: error

    # Resource leaks
    cancel_subscriptions: error
    close_sinks: error

    # Type holes
    avoid_dynamic_calls: error
    always_declare_return_types: error
    cast_nullable_to_non_nullable: error

    # Exhaustiveness
    exhaustive_cases: error

    # Shipping hygiene
    avoid_print: error
    avoid_slow_async_io: error

    # Deliberately NOT errors — a Flutter upgrade must never block a hotfix
    # for someone who cannot speak.
    deprecated_member_use: warning
    deprecated_member_use_from_same_package: warning

    # Deliberate downgrades
    public_member_api_docs: ignore
    lines_longer_than_80_chars: ignore
```

Reasons, in the file's own comments, not as folklore:

- `unawaited_futures` / `discarded_futures` are at **info** in VGA. Info is a squiggle a solo dev with no reviewer scrolls past. Promoted, they mean a TTS call whose Future is dropped takes its errors with it.
- `flutter_tts` already fails quietly — it returns `0` and writes a `Log.d`. That is one layer swallowing failure. A bare `catch` above it makes the failure invisible at *every* layer. `throw_in_finally` replaces the real exception with a bystander, destroying the only evidence that exists.
- `use_build_context_synchronously`: after an `await` the widget may be disposed and `context` is a handle into a dead tree. Live hazard in edit mode — await a drift write, then pop the dialog.
- `close_sinks` overrides VGA's own `close_sinks: ignore` on purpose: a `StreamController` for TTS voice-availability changes that fires on a disposed notifier is a real fault on the crisis path.
- `avoid_dynamic_calls` / `cast_nullable_to_non_nullable`: platform channels hand back `Map<Object?, Object?>` — Personal Voice on iOS, the Android Quick Settings `TileService`, the iOS ControlWidget. Parse via `tryParse`, never cast.
- `exhaustive_cases` only covers the legacy enum-like case (static const instances). A non-exhaustive switch on a **sealed** class is already a compile error (`non_exhaustive_switch_statement`) — no lint involved. That is why failure and mode types are sealed classes, not enums.
- `avoid_print`: stdout logging reaches nobody — there is no device to read it from. Diagnostics go to the on-device exportable crash log.
- `public_member_api_docs` is a package-author rule; this is an app with no consumers. A doc comment on every public member costs hours and trains the reader to ignore lints — unacceptable when lints are one of only two safety nets. Document the **seams** instead.
- `lines_longer_than_80_chars` only fires on what the formatter cannot split — long string literals and URLs in comments. Pure noise.

### Excludes

```yaml
  exclude:
    - "**/*.g.dart"
    - "**/*.drift.dart"
    - "**/generated_plugin_registrant.dart"
    - "test/.test_coverage.dart"
    - "test/drift/generated/**"
```

`test/drift/generated/**` is the load-bearing one: those are drift's exported schema snapshots — historical artifacts, the baseline the migration tests compare against. A lint autofix or a reformat there corrupts the baseline. Never reformat, never "fix", never regenerate an old snapshot; add new ones only. These same excludes must be mirrored in coverage filtering, or generated files dilute the coverage number until it stops meaning anything.

### Plugins

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

riverpod_lint 3.x runs on the first-party `analysis_server_plugin` system (Dart 3.10+); `missing_provider_scope` is reported by a plain `flutter analyze` with no `custom_lint` dependency and no second pass. **Never add `custom_lint`** — the legacy plugin system it is built on is scheduled for deprecation as early as Dart 3.12, which is the current SDK. Missing `ProviderScope` means every provider read throws on the first tap. The codegen-syntax rules are off because the handful of providers here are hand-written. Suppress a plugin diagnostic with the namespaced form: `// ignore: riverpod_lint/missing_provider_scope`.

### Formatter

```yaml
formatter:
  page_width: 80
  trailing_commas: preserve
```

Tall style is selected by the language version in `pubspec.yaml`, not by config — on Dart 3.12 there is nothing to opt into. `trailing_commas: preserve` (VGA already sets it; restated for the reader) matters because a trailing comma forces a split. The default, `automate`, lets the formatter collapse widget trees onto one line. For a widget tree describing a fixed 3x4 grid that a stranger must read cold, one-argument-per-line is worth the vertical space and keeps grid-layout diffs minimal.

### State the hole at the point of temptation

The file must carry, in a comment beside the `unawaited_futures` / `discarded_futures` block, the fact that the most idiomatic way to wire a tile is invisible to every rule in the file. Verified: all four callback shapes probed with `discarded_futures`, `unawaited_futures` and `@useResult`/`unused_result` **all promoted to `error`**:

| Code | Diagnostics reported |
|---|---|
| `onTap: () => s.speak('A')` | **NONE. Zero. All three miss it.** |
| `onTap: () { s.speak('B'); }` | `discarded_futures` + `unused_result` |
| `onTap: () async { s.speak('C'); }` | `unawaited_futures` + `unused_result` |
| `onTap: () => c.speakNow('D')` | clean — the fix |

The mechanism: the arrow closure *returns* the Future, so every rule considers it used — but the target type is `VoidCallback`, so Dart's void-compatibility silently discards it. The Future and its error both hit the floor.

The mitigation named in the comment is **structural, never disciplinary** — discipline is what a solo dev runs out of at 2am. A void-returning `speakNow(String)` that internally does `unawaited(_speak(p).catchError(_report))` means a callback never holds a Future and the hole is unreachable by construction. Never call a Future-returning method directly from a callback.

The comment must end where the skill ends: **a green analyzer is not proof that a tile speaks.**

### Out of scope

- Writing `SpeechController` or `speakNow` — this task only states the hole in a comment.
- The CI workflow that runs the analyzer, and the requirement that CI **build** rather than merely analyze (that is E01-T04).
- The three source-grep ban tests (`withClampedTextScaling`/`textScaleFactor`, `pumpAndSettle`, network imports). No lint can do those; they are separate.
- Coverage configuration itself — this task only fixes the exclude list the coverage filter must mirror.

## Acceptance criteria

- [ ] `analysis_options.yaml` exists at the package root and is byte-equivalent in rule content to the `reed-lint-config` skill's `assets/analysis_options.yaml`.
- [ ] `flutter analyze` exits 0 on the freshly generated project from E01-T01.
- [ ] `ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/` lists `analysis_options.10.3.0.yaml` — the included filename resolves.
- [ ] `flutter analyze` output contains **no** `include_file_not_found` warning. Grep for it explicitly; it is a warning, not an error, and the build stays green without it.
- [ ] Positive control for the promotions: temporarily add a file containing `void f() { Future<void>.value(); }` and confirm `flutter analyze` reports `discarded_futures` at **error** severity, then delete the file. Green is not evidence; a known violation erroring is.
- [ ] Positive control for `close_sinks`: temporarily add a class holding a `StreamController` that is never closed and confirm a diagnostic is produced at **error**. If **no diagnostic at all** appears, the rule is not running — add it under `linter: rules:` as well and re-verify.
- [ ] Positive control for the plugin: a widget test app or `main()` without a `ProviderScope` reports `riverpod_lint/missing_provider_scope` under a plain `flutter analyze`, with no `custom_lint` in `pubspec.yaml` and no `dart run custom_lint` pass.
- [ ] `grep -n 'VoidCallback' analysis_options.yaml` hits the comment documenting the arrow-callback hole next to the `discarded_futures` promotion.
- [ ] `grep -rn 'custom_lint' pubspec.yaml analysis_options.yaml` returns nothing.
- [ ] `dart format --output=none --set-exit-if-changed lib/ test/` exits 0 and does not touch anything under `test/drift/generated/`.

## Traps

- **The include fails open, not closed.** If `analysis_options.10.3.0.yaml` does not exist in the *resolved* package, you get a single `warning • include_file_not_found` and analysis continues with **zero rules**. A green build that checks nothing looks exactly like a green build that checks everything. Bump the include filename **in the same commit** as any SDK/VGA bump, and confirm afterwards by checking a known violation still errors — never by observing that analysis is green.
- **`errors:` cannot enable a lint that is off.** It only *re-ranks diagnostics that are already produced*. Verified: with `errors: close_sinks: error` alone and no `linter: rules:` entry, a never-closed `StreamController` produced **no diagnostic at all**. VGA sets `close_sinks: ignore`, so this one is live. If the probe is silent, add the `linter: rules:` entry too — both lines are then required.
- **Mixing the list form and the map form is a config parse error**, which is a broken analyzer, which is a green build. To disable a VGA rule write `analyzer: errors: <rule>: ignore`. Never write `- rule: false` under `linter: rules:`.
- **The plugin `version:` key is mandatory.** `riverpod_lint: ^3.1.3` with a nested `diagnostics:` is a YAML parse error — a scalar cannot also have children.
- **Plugin diagnostics are reported twice** under `flutter analyze` while a plugin is active. Cosmetic, but any CI threshold based on an issue *count* will be wrong. Gate on severity, not count.
- **`exhaustive_cases: error` buys less than it looks like.** It does not cover sealed classes at all. The real net there is the compiler, and `errors: non_exhaustive_switch_statement: ignore` can silence `dart analyze` while `dart compile` still fails — which is why the gate must build. Do not let this promotion create the impression that switches are covered.
- **Reintroducing the 10.2.0 pin.** It looks like the safe conservative choice and it is the wrong one — it existed only for Dart 3.11, and VGA 10.3.0's current major needs Dart `^3.12.0`, which 3.12.2 satisfies.
- **Adding a `language:` block to "be explicit"** about strict-casts / strict-inference / strict-raw-types. Redundant config drifts and then contradicts VGA. If any of the three ever needs relaxing, that is a design problem — everything crossing a platform channel is `dynamic`, and strict mode is what forces the guard at the boundary.
- **An autofix or a reformat inside `test/drift/generated/**`.** That corrupts the migration baseline, and a botched migration destroys a hand-curated board — months of someone's phrases, irreplaceable and unmergeable.
- **`// ignore_for_file:` on a promoted rule.** File scope means the next edit to that file is unprotected and nobody will notice. An `// ignore:` on a promoted rule is a claim that a silence bug is acceptable *here* — write the reason on the line above, naming the mechanism that makes it safe.
- **Believing the file.** The highest-severity failure modes — an audio session muted by the hardware silent switch, the engine reporting success while emitting no audio, a stale Quick Settings phrase — are invisible to every rule in this file and to every automated test that exists. Never report "analyzer clean" as evidence that speech works.

## Files

- Creates `analysis_options.yaml` at the package root (copied from the `reed-lint-config` skill's `assets/analysis_options.yaml`).
- Touches `pubspec.yaml` only to add `very_good_analysis: ^10.3.0` and `riverpod_lint: ^3.1.3` under `dev_dependencies`. Nothing else, and never `custom_lint`.

## Done when

`flutter analyze` exits 0 with no `include_file_not_found` warning, each promoted rule has been proven live by a deliberate violation that errors, and the arrow-callback hole is documented in a comment next to the rules that cannot see it.
