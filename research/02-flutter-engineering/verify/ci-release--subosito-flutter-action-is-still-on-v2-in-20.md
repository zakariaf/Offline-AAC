# ci-release--subosito-flutter-action-is-still-on-v2-in-20

> Phase: **verify** · Agent `ad20170a5216fc999` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Release count is 51, not 46 (verified via api.github.com/repos/subosito/flutter-action/releases?per_page=100, which returns 51 objects in a single page). This is the only inaccuracy found and it does not affect the claim's substance or any decision resting on it. Minor completeness note: the claim's input list is accurate but not exhaustive — the action also accepts git-source, cache-path, pub-cache-path, and dry-run.

**Evidence:** Attempted refutation across four primary sources; the claim survives.

NO V3: github.com/subosito/flutter-action/releases shows every release on the v2.x line. README instructs `uses: subosito/flutter-action@v2`. No v3 tag exists.

VERSION/DATE/MAINTAINER: /releases/latest returns tag_name v2.23.0, published_at 2026-03-25T10:34:12Z, author login `bartekpacia` (Bartek Pacia). Exact match to the claim, including the date.

ACTIVELY MAINTAINED: GitHub API for the repo reports archived: false, disabled: false, pushed_at: 2026-04-30T00:12:47Z, updated_at: 2026-07-10T10:06:24Z. Not archived, not discontinued. v2.23.0 shipped a real feature ("feat: fvm support", "Add separate pub-cache boolean flag"), not just maintenance. Commit activity ~2.5 months stale is normal for a mature, stable action.

actions/cache@v5 + RUNNER REQUIREMENT: README states the action uses actions/cache@v5 internally and that self-hosted runners require Actions Runner 2.327.1 or newer. Verbatim match.

INPUTS: All seven named inputs exist (channel, flutter-version, flutter-version-file, cache, pub-cache, cache-key, pub-cache-key). README documents additional inputs the claim omits but does not misname any: git-source, cache-path, pub-cache-path, dry-run. No invented API surface.

PLACEHOLDERS: All six confirmed present: :os:, :channel:, :version:, :arch:, :hash:, :sha256:

CONFUSION WARNING IS VALID: flutter-actions/setup-flutter is a genuinely distinct action (maintainer @socheatsok78) with real v3.x and v4.x lines, latest v4.3. The claim's caution against importing its version numbers onto subosito's is well-founded, not a hedge.

ONE SPECIFIC IS WRONG: the release count. /releases?per_page=100 returns 51 release objects, not 46. Non-load-bearing detail, almost certainly count drift from an earlier reading. Everything decision-relevant is accurate.

Checked for the listed failure modes and found none: no version rot (dates verified against the API, not memory), no dead-package-as-alive (archived: false verified directly), no invented signatures (every input and placeholder verified in the README), no cargo cult or overstated consensus (the claim makes factual repo assertions, not community-practice assertions).

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "ci-release" made this claim, and a project decision depends on it.

CLAIM: subosito/flutter-action is still on v2 in 2026 — there is no v3, and it is actively maintained
DETAIL: Latest release v2.23.0, 2026-03-25, maintained by Bartek Pacia; 46 releases. It now uses actions/cache@v5 internally (self-hosted runners need Actions Runner 2.327.1+; irrelevant for GitHub-hosted). Inputs: channel, flutter-version, flutter-version-file, cache, pub-cache, cache-key, pub-cache-key with :os:/:channel:/:version:/:arch:/:hash:/:sha256: placeholders. An alternative, flutter-actions/setup-flutter, does have v3/v4 — do not confuse its version numbers for subosito's.
CLAIMED SOURCES: https://github.com/subosito/flutter-action, https://github.com/subosito/flutter-action/releases
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
