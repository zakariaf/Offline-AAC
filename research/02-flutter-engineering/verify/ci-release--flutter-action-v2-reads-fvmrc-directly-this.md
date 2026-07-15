# ci-release--flutter-action-v2-reads-fvmrc-directly-this

> Phase: **verify** · Agent `a3f68abad651e163c` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep the recommendation — it holds in 2026 and flutter-action@v2 is still the current major (v2.23.0). Fix the file syntax: .fvmrc is JSON parsed with `jq -r '.flutter'`, so the pin is `{"flutter": "3.44.0"}`, NOT `flutter: 3.44.0`. The `flutter: 3.19.0` vs `flutter: ">= 3.19.0 <4.0.0"` good/bad examples come from pubspec.yaml's `environment:` block (parsed `yq eval '.environment.flutter'`) and do not describe .fvmrc. Also: exact versions are not the only accepted value — `stable`/`beta`/`master`/`main` are special-cased into the channel with VERSION=any. fvm_config.json is deprecated and still readable, but is NOT auto-migrated: FVM 4.1.2 warns "Consider migrating to .fvmrc by running: fvm use <version>" and requires that manual step. And FVM gitignores the entire `.fvm/` directory (under a `# FVM Version Cache` heading), not just the `.fvm/flutter_sdk` symlink; `.fvmrc` sits at project root and is committed. Worth adding to the corpus: picking .fvmrc over pubspec.yaml also skips the `choco install yq` step on Windows runners, since .fvmrc is parsed with jq.

**Evidence:** CORE THESIS CONFIRMED, NO VERSION ROT. subosito/flutter-action is alive (not archived, pushed_at 2026-04-30) and v2 IS still the current major tag — latest release v2.23.0 (2026-03-25). README verbatim: `flutter-version-file: pubspec.yaml # path to pubspec.yaml or .fvmrc or .fvm/fvm_config.json`, matching the claim's quoted string exactly. action.yaml input description: "The pubspec.yaml or FVM config file with exact Flutter version defined". So .fvmrc IS read directly, no fvm install needed in CI, and pubspec can keep a range while .fvmrc holds the exact pin. leoafarias/fvm also alive (4.1.2, 2026-06-25).

BUT four specifics in DETAIL are wrong, verified against actual source:

(1) BREAKING ERROR — `flutter: 3.44.0` is pubspec.yaml syntax, NOT .fvmrc syntax. setup.sh parses each file differently: `.fvmrc` -> `jq -r '.flutter'` (JSON), `fvm_config.json` -> `jq -r '.flutterSdkVersion // .flutter'`, pubspec.yaml -> `yq eval '.environment.flutter'` (YAML). The README's good/bad examples (`flutter: 3.19.0` vs `flutter: ">= 3.19.0 <4.0.0"`) are nested under pubspec's `environment:` key — the claim reproduces them as a top-level `flutter:` and then attaches them to the .fvmrc recommendation. .fvmrc is JSON: `{"flutter": "3.44.0"}`. Writing `flutter: 3.44.0` into .fvmrc yields a jq parse failure. Confirmed FVM 4 writes the `flutter` key to .fvmrc (config_model.dart toMap), while `toLegacyMap()` writes `flutterSdkVersion` for legacy fvm_config.json — so flutter-action's two jq expressions are correctly matched to each file.

(2) "The version must be an exact string" is overstated. setup.sh explicitly special-cases channel names: if VERSION is `stable`, `beta`, `master`, or `main`, it sets CHANNEL=$VERSION and VERSION=any. Channel names work, not only exact versions.

(3) "fvm_config.json ... is auto-migrated" is FALSE. FVM 4.1.2 reads the legacy file for backward compatibility only and emits a warning (project_service.dart:44): "Using legacy config at ${result.legacyConfigPath}. Consider migrating to .fvmrc by running: fvm use <version>". Migration is manual.

(4) ".fvm/flutter_sdk (the symlink) is gitignored" is imprecise. FVM ignores the whole directory: SetupGitIgnoreWorkflow writes `kFvmPathToAdd = '$kFvmDirName/'` i.e. `.fvm/` under the heading `# FVM Version Cache`. The `flutter_sdk` symlink does exist (update_project_references.workflow.dart: `flutterSdkLink = 'flutter_sdk'`) and is ignored, but as part of `.fvm/`. ".fvmrc is committed" is correct — it lives at project root, outside `.fvm/`.

BONUS, in the claim's favour and unstated: the README's yq caveat does not apply to the .fvmrc path. action.yaml gates the Windows yq install on `!endsWith(inputs.flutter-version-file, '.fvmrc') && !endsWith(inputs.flutter-version-file, 'fvm_config.json')` — .fvmrc is parsed with jq, so choosing .fvmrc over pubspec.yaml actually avoids a Windows dependency.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "ci-release" made this claim, and a project decision depends on it.

CLAIM: flutter-action@v2 reads .fvmrc directly — this is the 2026 reproducible-pinning answer, and it removes the need to install fvm in CI
DETAIL: flutter-version-file accepts 'path to pubspec.yaml or .fvmrc or .fvm/fvm_config.json'. The version must be an exact string: `flutter: 3.44.0` works, `flutter: ">= 3.19.0 <4.0.0"` does not. Using .fvmrc (rather than pubspec.yaml) lets pubspec keep a normal range constraint while CI and local fvm share one exact pin. .fvmrc is committed; .fvm/flutter_sdk (the symlink) is gitignored. fvm_config.json is deprecated in favour of .fvmrc and is auto-migrated.
CLAIMED SOURCES: https://github.com/subosito/flutter-action, https://fvm.app/documentation/getting-started/configuration
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
