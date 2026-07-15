# ci-release--verygoodopensource-very-good-coverage-is-arc

> Phase: **verify** · Agent `a137af658c09e8190` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Claim is safe to rely on. Two minor imprecisions, neither decision-changing, and both err in the claim's own disfavor:

(1) DATE: The claim says very_good_workflows was "updated 2026-05-04". Actual pushed_at is 2026-07-14T23:32:20Z (updated_at 2026-06-30T11:15:36Z). Neither field is 2026-05-04. The successor is MORE actively maintained than claimed — this strengthens rather than weakens the migration recommendation.

(2) "SHAPED FOR PACKAGES, NOT APPS" IS OVERSTATED. Reading flutter_package.yml (rather than inferring from its filename): it accepts min_coverage, coverage_excludes, working_directory, analyze_directories, format_directories, collect_coverage_from, flutter_channel, platform, report_on, runs_on, test_optimization, and defaults to operating on lib/ and test/. It does NOT require pub publish, pana, or package scoring — those are separate workflow files (flutter_pub_publish.yml, pana.yml). The filename is package-oriented and there is no flutter_app.yml, but the workflow itself is generic enough for app repos. The claim's package/app incompatibility framing is not supported.

The "pulls in opinionated defaults" caveat IS fair and worth acting on: min_coverage defaults to 100, and the reusable workflow additionally runs formatting, analysis, and test optimization. Replacing a single coverage-check step with this workflow is a broader change than like-for-like — a real migration cost, but a different one than the claim describes.

**Evidence:** All load-bearing assertions verified against primary sources; attempted refutation failed.

1. ARCHIVAL CONFIRMED. GitHub API /repos/VeryGoodOpenSource/very_good_coverage returns archived: true, disabled: false, pushed_at: "2026-03-31T13:19:22Z". The 2026-03-31 archive date is exact.

2. LAST RELEASE CONFIRMED. /releases/latest returns tag_name "v3.0.0", name "v3.0.0", published_at "2024-03-05T17:24:47Z". Exactly as claimed.

3. README WORDING CONFIRMED VERBATIM. raw.githubusercontent.com .../very_good_coverage/main/README.md contains a "> [!WARNING]" block: "**This project is deprecated.** Very Good Coverage has been superseded by [Very Good Workflows], which provides a comprehensive suite of reusable GitHub Actions workflows — including code coverage enforcement." The claim's quotation matches word for word.

4. SUCCESSOR CONFIRMED. /repos/VeryGoodOpenSource/very_good_workflows returns archived: false. .github/workflows/ contains flutter_package.yml (alongside dart_package.yml, pana.yml, etc.). The coverage README's Migration Guide names exactly "VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v1" and documents the rename of `exclude` -> `coverage_excludes`.

5. THE @v1 REF EXISTS — a near-miss I ran down. /tags listed only v1.1.0 through v1.19.2 with no standalone "v1", which would have made the migration guide point at a nonexistent ref. But that endpoint paginates; /git/refs/tags/v1 resolves to refs/tags/v1, sha 76d76db67e801f325e7683952130821a8cad3c9d. The floating tag is real. Absence from page one was not proof.

6. "MOST TUTORIALS STILL RECOMMEND IT" — SUPPORTED, not overstated consensus. A web search for very_good_coverage CI tutorials returns results dominated by guides still instructing `uses: VeryGoodOpenSource/very_good_coverage@v2`, none of which note the deprecation. Directionally correct.

FAILURE MODES CHECKED AND NOT FOUND: no version rot (dates are current, not stale-2023); the "dead package presented as alive" mode is inverted here — the claim correctly identifies the death; no invented API names (every named ref, file, and input verified to exist).

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "ci-release" made this claim, and a project decision depends on it.

CLAIM: VeryGoodOpenSource/very_good_coverage is ARCHIVED as of 2026-03-31 — most tutorials still recommend it
DETAIL: Repo archived 2026-03-31, read-only. Last release v3.0.0 (2024-03-05). README: 'Very Good Coverage has been superseded by Very Good Workflows, which provides a comprehensive suite of reusable GitHub Actions workflows — including code coverage enforcement.' Successor is VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v1 (repo active, updated 2026-05-04) — but that workflow is shaped for *packages*, not apps, and pulls in opinionated defaults.
CLAIMED SOURCES: https://github.com/VeryGoodOpenSource/very_good_coverage, https://github.com/VeryGoodOpenSource/very_good_workflows, https://workflows.vgv.dev/
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
