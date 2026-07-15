# lints-tooling--the-plugins-block-syntax-with-a-pub-version

> Phase: **verify** · Agent `a9d70169c9a20a42e` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Two refinements, neither refuting the claim:

(a) SOURCING OVERSTATED: "Per the docs" is inaccurate for the `version:` + `diagnostics:` combination specifically. Neither dart.dev/tools/analyzer-plugins nor the SDK's using_plugins.md ever shows `version:` in ANY example — all three documented `plugins:` examples use either the bare shorthand (`my_plugin: ^1.0.0`) or `path: /path/to/my_plugin`, and the `diagnostics:` example uses `path:`. Further, dart.dev/tools/pub/dependencies presents `version:` as a modifier to `hosted:`/`git:`/`path:`, never standalone. The claim is correct ONLY because the analyzer source allowlist independently substantiates it. A reader checking the docs would not find this and could wrongly conclude the claim is false. Cite the SDK source, not the docs, for this point.

(b) HEADLINE CLAUSE OVER-BROAD: "The plugins: block syntax with a pub version requires an explicit version: key" is false standing alone — the shorthand `riverpod_lint: ^3.1.3` is the documented form and is what riverpod_lint's own README recommends ("plugins:\n  riverpod_lint: <version number>"). The `version:` key is required ONLY when adding `diagnostics:`, which the em-dash clause does correctly qualify. Phrase as: "the shorthand form cannot carry a `diagnostics:` block; expand to `version:` when you need one."

Additional context for the project decision (not in the claim): analyzer plugins require Dart 3.10 / Flutter 3.38+; `plugins:` is TOP-LEVEL in the new system (it was nested under `analyzer:` in the legacy system); plugins cannot be enabled/configured in a nested analysis_options file; and the analysis server must be restarted after any change to the `plugins:` section. Also riverpod_lint 3.1.x requires Flutter >= 3.38.0 / SDK >= 3.10.0.

Minor: latest riverpod_lint is 3.1.4, not 3.1.3, but `^3.1.3` resolves to it correctly.

**Evidence:** Every technical assertion checks out against primary sources; attempted refutation failed.

1. `version:` IS a supported key in the plugins block — CONFIRMED via SDK source, pkg/analyzer/lib/src/analysis_options/analysis_options_file.dart:
   static const Set<String> pluginsOptions = { diagnostics, git, path, version, hosted };
   analysis_options_parse_model.dart iterates plugin map entries and reports `unsupportedPluginOption` for any key NOT in that set, so `version:` + `diagnostics:` parses cleanly. This was the hardest part of the claim to substantiate because NO published doc shows it.

2. YAML parse error — CONFIRMED by YAML semantics. `riverpod_lint: ^3.1.3` followed by a more-indented `diagnostics:` causes YAML to attempt continuing `^3.1.3` as a multi-line plain scalar; the `:` in the continuation line is illegal, producing exactly "Mapping values are not allowed here". A scalar cannot also have children.

3. Warnings vs lints defaults — CONFIRMED verbatim, sdk/pkg/analysis_server_plugin/doc/using_plugins.md: "Any warnings that a plugin defines are enabled by default (like analyzer warnings). Any lint rules that a plugin defines are disabled by default (like analyzer lint rules), and must be explicitly enabled in analysis options."

4. Suppression syntax — CONFIRMED verbatim: "// ignore: some_plugin/some_code" and "// ignore_for_file: some_plugin/some_code".

5. `missing_provider_scope` — real riverpod_lint rule, verified on pub.dev API docs. Not an invented/LLM-plausible name.

6. riverpod_lint — ALIVE. Latest 3.1.4, published ~35 days ago. Not discontinued, MIT, active repo. `^3.1.3` resolves fine. No dead-package failure mode.

7. Shorthand form `my_plugin: ^1.0.0` is documented and valid: "The value can be a package version constraint, in which case the package is downloaded from https://pub.dev".

No version rot, no dead package, no invented API, no cargo cult, no overstated consensus.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "lints-tooling" made this claim, and a project decision depends on it.

CLAIM: The `plugins:` block syntax with a pub version requires an explicit `version:` key — the shorthand form is a YAML parse error if you also want `diagnostics:`.
DETAIL: `plugins:\n  riverpod_lint: ^3.1.3\n    diagnostics:` → `error • Mapping values are not allowed here` (a YAML scalar cannot also have children). Correct: `plugins:\n  riverpod_lint:\n    version: ^3.1.3\n    diagnostics:\n      missing_provider_scope: true`. Per the docs and confirmed by probe: plugin-defined WARNINGS are enabled by default; plugin-defined LINTS are disabled by default and must be opted in under `diagnostics:`. Suppression uses `// ignore: plugin_name/diagnostic_code`.
CLAIMED SOURCES: local probe, https://dart.dev/tools/analyzer-plugins
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
