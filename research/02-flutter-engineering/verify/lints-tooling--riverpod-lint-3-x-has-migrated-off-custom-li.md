# lints-tooling--riverpod-lint-3-x-has-migrated-off-custom-li

> Phase: **verify** · Agent `a393574c7e7c231a3` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** The operative recommendation stands: do not add custom_lint. Two precision fixes for the corpus. (1) Attribute the migration to riverpod_lint 3.1.0 (2025-12-26), not "3.x" broadly — 3.0.0–3.0.1 still used custom_lint. (2) Do not state that custom_lint is dead or discontinued; it is at 0.8.1, actively published by verified publisher Invertase ~10 months ago, and is NOT marked discontinued on pub.dev. The correct argument is prospective, not retrospective: legacy-plugin deprecation is scheduled "as early as Dart 3.12" per dart-lang/sdk#62164 and has not yet landed. This matters if the project ever wants a rule package that is still custom_lint-only — the calculus would change, though the deprecation makes such a dependency a poor long-term bet regardless. Separately, the `version:` key in analysis_options.yaml is marked "verified" but appears in no primary source; verify it empirically, since a wrong key means the plugin silently does not load and missing_provider_scope stops firing with no error.

**Evidence:** Every load-bearing specific verified against primary sources; nothing refuted.

1) MIGRATION OFF custom_lint — CONFIRMED. pub.dev/packages/riverpod_lint/changelog, v3.1.0 (2025-12-26), verbatim: "riverpod_lint is no-longer implemented using custom_lint, but instead analysis_server_plugin". The pub.dev page for 3.1.4 lists dependencies analysis_server_plugin ^0.3.0, riverpod 3.3.2, riverpod_analyzer_utils 1.0.0-dev.10 — NO custom_lint dependency. README states it is "implemented using analysis_server_plugin".

2) 3.1.4 IS LATEST — CONFIRMED. Published ~2026-06-10 (35 days before 2026-07-15).

3) TOP-LEVEL plugins: BLOCK — CONFIRMED. dart.dev/tools/analyzer-plugins: "To enable an analyzer plugin, add it to the top-level plugins section of your analysis_options.yaml file." Distinct from the analyzer: block. riverpod_lint README concurs.

4) ANALYZER PLUGIN SUPPORT IN DART 3.10 — CONFIRMED verbatim: "Support for analyzer plugins was added in Dart 3.10."

5) sdk#62164 — CONFIRMED verbatim on all three points. Title: "Deprecating the legacy analyzer plugin system". Names custom_lint as primary client: "we should be able to deprecate the legacy analyzer plugin system, whose primary client was ... custom_lint." Timeline: "In some Dart SDK release (as early as Dart 3.12), deprecate use of legacy plugins."

6) custom_lint 0.8.1 / Invertase — CONFIRMED. Verified publisher Invertase.io, last publish ~10 months ago, NOT marked discontinued.

7) missing_provider_scope IS A REAL DIAGNOSTIC — CONFIRMED via pub.dev/documentation/riverpod_lint/latest/. Critically it is classified a WARNING, and dart.dev states "Warnings that a plugin defines are enabled by default ... Lint rules that a plugin defines are disabled by default" — this is the mechanism that makes the researcher's plain-`flutter analyze` probe result coherent rather than suspicious.

ENVIRONMENT NOTE: The task prompt asserts Flutter stable is 3.44.0, but the local machine is Dart 3.11.0 (stable, 2026-02-09) / Flutter 3.41.2. This strengthens rather than weakens the claim — "3.1.3 resolves on Dart 3.11" is a genuine local-toolchain observation, not version rot.

THREE CAVEATS (none refuting):
(a) "3.x" is imprecise — migration landed specifically at 3.1.0; 3.0.0–3.0.1 were still custom_lint-based. Immaterial to the decision since the project pins ^3.1.3.
(b) The `version:` key is UNDOCUMENTED. /Users/zakariafatahi/50-apps-challenge/Offline-AAC/analysis_options.yaml asserts as "verified" that a pub version requires `version: ^3.1.3` nested alongside `diagnostics:`. Neither dart.dev/tools/analyzer-plugins nor the SDK's own pkg/analysis_server_plugin/doc/using_plugins.md documents any `version:` key — both show only the scalar form (`my_plugin: ^1.0.0`) or `path:` + `diagnostics:`. No primary source shows a version constraint combined with diagnostics. The underlying reasoning is sound (a YAML scalar cannot also have children), but this is the one unsubstantiated detail and it is load-bearing: if wrong, the plugin silently fails to load. Recommend empirical re-check.
(c) The local probe is not reproducible from this repo — there is no pubspec.yaml and no lib/; the directory contains only RESEARCH.md, analysis_options.yaml, idea.md, research/. The file's own comment says the probe ran "on a probe project" elsewhere, so this is uncontradicted but not independently checkable here.

3.1.3-vs-3.1.4 minor gap: pub lists Min Dart SDK 3.10 for BOTH 3.1.3 and 3.1.4, so 3.1.4's exclusion on Dart 3.11 is presumably a transitive pin (riverpod 3.3.2). I could not confirm that constraint; it does not affect the recommendation.

Hunted failure modes, none found: no version rot (all versions current as of 2026-07-15); no dead-package-as-alive (custom_lint is not discontinued, and the claim does not assert it is — it argues from scheduled deprecation, which is accurate); no invented API (missing_provider_scope verified real, analysis_server_plugin verified real); no cargo cult (the deprecation is a first-party Dart team position, not a blog post); no overstated consensus (sourced to the SDK tracking issue and official docs).

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "lints-tooling" made this claim, and a project decision depends on it.

CLAIM: riverpod_lint 3.x has migrated OFF custom_lint onto the first-party `analysis_server_plugin` system; custom_lint should not be added to this project at all.
DETAIL: riverpod_lint 3.1.4 is latest on pub (3.1.3 resolves on Dart 3.11). It is configured via a TOP-LEVEL `plugins:` block, not `analyzer: plugins:`. Verified: `missing_provider_scope` was reported by a plain `flutter analyze` with no custom_lint dependency and no `dart run custom_lint` second pass. Analyzer plugin support landed in Dart 3.10. The Dart team's tracking issue (dart-lang/sdk#62164) states legacy plugins — whose 'primary client' is explicitly named as custom_lint — will be deprecated 'as early as Dart 3.12' and disabled possibly the following release. custom_lint is still at 0.8.1 (Invertase).
CLAIMED SOURCES: https://pub.dev/packages/riverpod_lint, https://dart.dev/tools/analyzer-plugins, https://github.com/dart-lang/sdk/issues/62164, local probe
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: pub.dev package pages (for real current versions, publisher, and maintenance status), api.flutter.dev (for real API signatures), dart.dev, docs.flutter.dev, and the actual GitHub repos (for whether something is archived/discontinued).

The failure modes you are hunting for, in order of likelihood:
1. **Version rot** — the claim was true in 2023. APIs get deprecated and removed; `setMockMethodCallHandler` moved; `window` was deprecated; formatters changed.
2. **Dead packages presented as alive** — golden_toolkit, dart_code_metrics, isar, hive, mockito-vs-mocktail. CHECK THE REPO: is it archived? When was the last publish? Does pub.dev show it as discontinued?
3. **Invented or misremembered API signatures.** If the claim names a method, class, or parameter, VERIFY IT EXISTS with that exact name on api.flutter.dev or the package docs. LLM-plausible API names are a specific hazard here.
4. **Cargo cult** — presenting a team practice or a large-app practice as universal, when the actual source doesn't say that.
5. **Overstated consensus** — "the community recommends X" when it's one blog post.

Default to refuted=true if you cannot independently substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + a correction if directionally right but wrong in specifics (name the exact right version/API). UNVERIFIABLE if no source settles it — and say that plainly rather than guessing.
````

</details>
