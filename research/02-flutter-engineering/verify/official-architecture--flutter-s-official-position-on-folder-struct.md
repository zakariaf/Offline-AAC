# official-architecture--flutter-s-official-position-on-folder-struct

> Phase: **verify** · Agent `a59ef094471efca26` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Evidence:** Attempted refutation on all five failure modes; all negative.

1. HYBRID FRAMING — VERIFIED VERBATIM. docs.flutter.dev/app-architecture/case-study currently contains, word for word: "The architecture recommended in this guide lends itself to a combination of the two. Data layer objects (repositories and services) aren't tied to a single feature, while UI layer objects (views and view models) are." The page presents the tree with lib/data/{repositories,services,model} (layer-organized) and lib/ui/<feature_name>/{view_models,widgets} (feature-organized).

2. PRESCRIBED UI SHAPE — VERIFIED. The doc's tree shows lib/ui/<feature_name>/view_models/<view_model_class>.dart and lib/ui/<feature_name>/widgets/<feature_name>_screen.dart, plus lib/ui/core/{ui,themes} and lib/domain/models/.

3. COMPASS TREE — VERIFIED INDEPENDENTLY VIA GITHUB API, not by trusting the doc's rendering. GET /repos/flutter/samples/contents/compass_app/app/lib/ui returns feature dirs: activities, auth, booking, home, results, search_form, plus core. GET .../lib/ui/home returns both view_models/ and widgets/ subdirs. GET .../compass_app/app confirms a testing/ directory alongside lib/ and test/ (and integration_test/). The case study describes testing/ precisely as "a subpackage that contains mocks and other testing utilities which can be used in other packages' test code."

4. NAMING PRIORITY LABEL — VERIFIED, AND CORRECTLY NOT INFLATED. docs.flutter.dev/app-architecture/recommendations lists "Use standardized naming conventions for classes, files and directories" at priority "Recommend" (NOT "Strongly recommend"), with examples HomeViewModel, HomeScreen, UserRepository, ClientApiService, and the SDK-confusion guidance: "For clarity, we do not recommend using names that can be confused with objects from the Flutter SDK. For example, you should put your shared widgets in a directory called ui/core/, rather than a directory called /widgets."

5. CURRENCY / DEAD-SOURCE CHECK. flutter/samples: archived=false, disabled=false, owner=flutter (org), pushed_at=2026-07-09, updated_at=2026-07-15. Both docs pages live today with the quoted text intact — not a 2023/2024 artifact.

NOT APPLICABLE: The claim names no pub.dev packages (no dead-package risk) and no SDK methods/classes/parameters (no invented-signature risk). The only names are the doc's own illustrative example class names, confirmed verbatim.

CARGO-CULT CHECK (best refutation angle, failed): this is not a team/blog practice laundered as official — it is on docs.flutter.dev under the official app-architecture guide, and the researcher preserved the doc's hedge ("lends itself to") rather than upgrading it to a mandate.

MINOR PRECISION NOTE (does not affect verdict): "layer-first at the top level, feature-first inside the UI layer" is the researcher's accurate synthesis of the resulting tree, not the doc's wording. The doc justifies the hybrid by object nature (data objects aren't feature-bound; UI objects are). Quote the doc's rationale rather than the paraphrase.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "official-architecture" made this claim, and a project decision depends on it.

CLAIM: Flutter's official position on folder structure is a documented hybrid: layer-first at the top level, feature-first inside the UI layer.
DETAIL: From /app-architecture/case-study: "The architecture recommended in this guide lends itself to a combination of the two. Data layer objects (repositories and services) aren't tied to a single feature, while UI layer objects (views and view models) are." The prescribed UI shape is `lib/ui/<feature_name>/view_models/<view_model_class>.dart` and `lib/ui/<feature_name>/widgets/<feature_name>_screen.dart`. Tests mirror `lib/` in `test/`, with shared mocks/utilities in a separate top-level `testing/` directory (confirmed by the Compass tree). Naming is a **Recommend**: "We recommend naming classes for the architectural component they represent. For example... HomeViewModel; HomeScreen; UserRepository; ClientApiService. For clarity, we do not recommend using names that can be confused with objects from the Flutter SDK."
CLAIMED SOURCES: https://docs.flutter.dev/app-architecture/case-study, https://docs.flutter.dev/app-architecture/recommendations, https://github.com/flutter/samples/tree/main/compass_app
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
