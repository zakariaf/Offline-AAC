# project-structure--the-official-flutter-architecture-case-study

> Phase: **verify** · Agent `a0a60170ed35d51f0` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim is accurate as stated and requires no correction to its substance. Three precision notes: (1) lib/data/model/ appears in the docs tree but NOT in the actual repo — real path is lib/data/services/api/model/; lib/data/ contains only repositories/ and services/. (2) The docs tree is an acknowledged simplification; the real repo also has domain/use_cases/ and ui/core/localization/. (3) Of the three cited sources, only docs.flutter.dev/app-architecture/case-study supports the structural claim; docs.flutter.dev/app-architecture/guide does not discuss folder structure at all and should be dropped as a source for this specific claim. Finally, the source scopes this structure to "large Flutter apps" and presents it descriptively as Compass's organization — "exactly the hybrid this app needs" is the researcher's own inference, not a first-party prescription.

**Evidence:** Attempted refutation across all listed failure modes; the claim survived. Every checkable specific verified against primary sources.

1. TREE — VERBATIM MATCH. Rather than trust a scraped render, I pulled the docs' own markdown source: https://raw.githubusercontent.com/flutter/website/main/sites/docs/src/content/app-architecture/case-study/index.md (HTTP 200, 198 lines). The <FileTree> block at lines ~86-121 matches the claimed tree node-for-node: lib/ui/core/{ui,themes}/, lib/ui/<feature_name>/{view_models,widgets}/, lib/domain/models/, lib/data/{repositories,services,model}/, lib/config/, lib/utils/, lib/routing/, main_staging.dart + main_development.dart + main.dart; test/{data,domain,ui,utils}; testing/{fakes,models}.

2. RATIONALE — VERBATIM, NOT MISREMEMBERED. Lines 127-133 of the source read exactly: "The data folder organizes code by type, because repositories and services can be used across different features and by multiple view models. The ui folder organizes the code by feature, because each feature has exactly one view and exactly one view model." The claim's quote is word-for-word correct. Line 80 independently confirms the hybrid framing: "The architecture recommended in this guide lends itself to a combination of the two" (following an explicit by-feature vs by-type contrast at lines 70-78).

3. NOT A MONOREPO — CONFIRMED via GitHub API (gh api repos/flutter/samples/contents/compass_app): exactly README.md, app/, docs/, server/. No root pubspec.yaml, no melos.yaml, no packages/, no workspace. compass_app/app/ has a single pubspec.yaml; compass_app/server/ is a separate Dart package (own pubspec.yaml, bin/, lib/, test/). app/testing/ has NO pubspec.yaml — it is a plain directory inside the app package (the docs call it a "subpackage" at line 145, which is loose language, but the claim does not repeat that error).

4. LIVE REPO — app/ top level contains lib/, test/, testing/ as siblings (confirms the claimed layout). app/lib/ contains exactly config, data, domain, routing, ui, utils + main.dart, main_development.dart, main_staging.dart. app/test/ contains exactly data, domain, ui, utils.

FAILURE MODES CHECKED AND NOT FOUND: no version rot (docs page is live and current, not superseded); no dead-package issue (claim names no packages); no invented API signatures (claim names no APIs — it is purely structural); no overstated consensus (this is first-party Flutter documentation, not a blog post).

TWO REFINEMENTS (do not refute the claim, but matter operationally):
(a) Docs-vs-repo drift on one node: the docs tree shows lib/data/model/<api_model_class>.dart, but the live repo's lib/data/ contains ONLY repositories/ and services/. API models actually live at lib/data/services/api/model/{booking,login_request,login_response,user}/. Since the claim cites both docs and repo, anyone scaffolding from it will find lib/data/model/ absent.
(b) The docs tree is explicitly simplified — the page states "There's additional code in the compass app that doesn't pertain to architecture. For the full package structure, view it on GitHub." The real repo additionally has domain/use_cases/ and ui/core/localization/, omitted from the tree.

SCOPE CAVEAT: the factual content is sound, but "prescribes exactly the hybrid this app needs" imports a judgment the source does not make. Line 52 scopes it as "Effective package structure for LARGE Flutter apps," and line 83 frames it descriptively ("The following is how the code is organized within the Compass application"), not as a universal mandate. The third cited source, /app-architecture/guide, does NOT discuss folder structure at all — it covers layers/components only (UI layer, Data layer, optional Domain layer). So that URL does not support the structural claim, though the case-study URL fully does.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "project-structure" made this claim, and a project decision depends on it.

CLAIM: The official Flutter architecture case study (Compass) prescribes exactly the hybrid this app needs: data-by-type, ui-by-feature.
DETAIL: Tree: lib/ui/core/{ui,themes}/, lib/ui/<feature>/{view_models,widgets}/, lib/domain/models/, lib/data/{repositories,services,model}/, lib/config/, lib/utils/, lib/routing/, main*.dart; test/ mirrors {data,domain,ui,utils}; plus a top-level testing/{fakes,models}. Stated rationale: 'The data folder organizes code by type, because repositories and services can be used across different features and by multiple view models. The ui folder organizes the code by feature, because each feature has exactly one view and exactly one view model.' Compass is NOT a monorepo of local packages — it is a single app/ package alongside a server/ and docs/.
CLAIMED SOURCES: https://docs.flutter.dev/app-architecture/case-study, https://github.com/flutter/samples/tree/main/compass_app, https://docs.flutter.dev/app-architecture/guide
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
