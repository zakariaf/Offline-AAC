# riverpod--riverpod-3-is-stable-flutter-riverpod-3-3-2

> Phase: **verify** · Agent `a10ee8181e4024d94` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The version and API facts are all accurate and need no correction — riverpod/flutter_riverpod 3.3.2 (2026-06-10), riverpod_lint 3.1.4, 3.0.0 stable on 2025-09-10, and every named API (AsyncValue.requireValue, Override.origin, Ref.isPaused, family.overrideWith2) verifies. The docs restructuring to /docs/concepts2/* and /docs/how_to/* is real; old /docs/concepts/* paths do 404.

The correction is to the final sentence only. Replace "Any tutorial predating 2025-09-10 describes a superseded API" with: "Riverpod 3.0 introduced targeted breaking changes, not a wholesale API replacement. Pre-3.0 tutorials are stale specifically where they use StateProvider/StateNotifierProvider/ChangeNotifierProvider (now behind separate imports), AutoDispose or FamilyNotifier interfaces (removed/consolidated), parameterized Ref types (removed), ProviderObserver (signature now takes ProviderObserverContext), or rely on identical-based update filtering (now ==) or unwrapped provider errors (now ProviderException). Tutorials teaching ConsumerWidget, ref.watch/ref.read, NotifierProvider, FutureProvider, and AsyncValue.when remain valid regardless of date." Screen pre-2025-09 material against that specific list rather than discarding it by publication date.

**Evidence:** Attempted to refute; the factual core survived verification against primary sources.

VERIFIED CORRECT (all of it):
- pub.dev/packages/riverpod and pub.dev/packages/flutter_riverpod both show 3.3.2 as latest, published ~35 days ago (consistent with 2026-06-10). Publisher: dash-overflow.net (verified publisher). Flutter Favorite. NOT discontinued.
- pub.dev/packages/riverpod_lint shows 3.1.4 — matches claim exactly.
- github.com/rrousselGit/riverpod is NOT archived: 2,507 commits, 158 open issues, 11 open PRs, active CI. Actively maintained.
- Changelog confirms release dates: 3.0.0 (2025-09-10), 3.1.0 (2025-12-26), 3.2.0 (2026-01-17), 3.3.2 (2026-06-10). Also 3.2.1 (2026-02-03).
- Every named API EXISTS with the exact name given (specifically hunted for LLM-plausible invented signatures; found none):
  * AsyncValue.requireValue for synchronously combining async providers — 3.1.0 (confirmed)
  * Override.origin — 3.1.0 (confirmed)
  * Ref.isPaused — 3.2.0 (confirmed)
  * family.overrideWith deprecated in favour of family.overrideWith2 — 3.2.0 (confirmed)
  * 3.2.0 fixed Notifiers losing state on dependency change (confirmed)
  * 3.3.2 fixes unpause assertion errors and AsyncNotifierProvider/StreamNotifierProvider dependency disposal after async gaps (confirmed)
- Docs restructuring is REAL: https://riverpod.dev/docs/concepts/code_generation returns HTTP 404. Current content lives under /docs/concepts2/* (providers, consumers, containers, refs, auto_dispose, family, mutations, offline, retry, observers, overrides, scoping) and /docs/how_to/* (testing, select, eager_initialization, pull_to_refresh, cancel), per riverpod.dev/docs/whats_new.

THE OVERREACH — the single unsupported sentence:
"Any tutorial predating 2025-09-10 describes a superseded API." This is the researcher's inference, not something any source states, and it is the load-bearing sentence for the project decision. The /docs/3.0_migration guide lists TARGETED breaking changes, not a wholesale API replacement: legacy providers (StateProvider, StateNotifierProvider, ChangeNotifierProvider) moved to separate imports; AutoDispose interfaces consolidated and FamilyNotifier variants removed; Ref type parameters removed and Ref subclasses eliminated; provider failures wrapped as ProviderException; all providers now use == instead of identical for update filtering; ProviderObserver signature now takes ProviderObserverContext. The guide states migration "is supposed to be smooth."

Consequence: the everyday surface — ConsumerWidget, ref.watch/ref.read, NotifierProvider, FutureProvider, AsyncValue.when — is UNCHANGED across the 2->3 boundary. A pre-2025-09-10 tutorial teaching those is still accurate. A pre-3.0 tutorial built on StateNotifierProvider, custom ProviderObserver, or AutoDispose*/FamilyNotifier interfaces IS genuinely stale. The claim flattens that distinction, and acting on it would discard a large body of still-correct material.

MINOR CAVEAT (weakly sourced, not treated as a finding): the riverpod_lint pub.dev page rendered as "unverified uploader" while riverpod/flutter_riverpod show the verified dash-overflow.net publisher. Plausibly a fetch/render artifact rather than a real provenance difference; worth a direct look only if publisher provenance matters to the decision.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "riverpod" made this claim, and a project decision depends on it.

CLAIM: Riverpod 3 is stable; flutter_riverpod 3.3.2 is current. Any tutorial predating 2025-09-10 describes a superseded API.
DETAIL: riverpod 3.0.0 stable released 2025-09-10. 3.1.0 (2025-12-26) added AsyncValue.requireValue sync-combining and Override.origin. 3.2.0 (2026-01-17) added Ref.isPaused, fixed Notifiers losing state on dependency change, and deprecated family.overrideWith in favour of family.overrideWith2. 3.3.2 (2026-06-10) is current: fixes unpause assertion errors and AsyncNotifierProvider/StreamNotifierProvider dependency disposal. riverpod_lint is at 3.1.4. Docs were restructured — the old /docs/concepts/* paths are 404 or stale; current content lives under /docs/concepts2/* and /docs/how_to/*.
CLAIMED SOURCES: https://pub.dev/packages/flutter_riverpod, https://pub.dev/packages/riverpod/changelog, https://pub.dev/packages/riverpod_lint, https://riverpod.dev/docs/whats_new
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
