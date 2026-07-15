# riverpod--the-canonical-test-idiom-changed-providercon

> Phase: **verify** · Agent `a16f224d40bf0b145` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Claim stands; two refinements for corpus accuracy, neither contradicting it. (a) Cite riverpod 3.3.2 stable rather than 3.0.0-dev.12 — the dev.12 entry is the correct historical introduction point, but sourcing a live recommendation to a prerelease invites a reader to assume it never shipped; 3.0.0 went stable and current is 3.3.2. (b) Scope caveat: ProviderContainer.test() "works only inside tests, by relying on package:test's addTearDown" — it is not a general-purpose constructor and will not function outside a test context. It also adds an end-of-test assertion that all containers were disposed, making it strictly stronger than the hand-rolled createContainer helper, not merely shorter. (c) Precision: the "No need to dispose the container when the test ends" sentence lives on /docs/concepts2/containers, not /docs/how_to/testing.

**Evidence:** Attempted refutation on all five failure modes; none landed.

1. CHANGELOG QUOTES ARE VERBATIM. pub.dev/packages/riverpod/changelog, version 3.0.0-dev.12 (2025-04-30) contains exactly: "Added `ProviderContainer.test()`. This is a custom constructor for testing purpose. It is meant to replace the `createContainer` utility." and "Added `NotifierProvider.overrideWithBuild`, to override `Notifier.build` without overriding methods of the notifier." Both quotes in the claim match the primary source.

2. VERSION ROT — CHECKED, INVERTED. The claim cites a dev prerelease, normally a red flag for advice that never shipped. But current stable is riverpod 3.3.2, published ~35 days ago (as of 2026-07-15), verified publisher dash-overflow.net (Remi Rousselet, the package author). Not discontinued, actively maintained. Both APIs survived prerelease -> stable.

3. API SIGNATURES VERIFIED against pub.dev/documentation/riverpod/latest (3.3.2) — both real, exact-name matches, no invention:
   - factory ProviderContainer.test({ProviderContainer? parent, List<Override> overrides = const [], List<ProviderObserver>? observers, Retry? retry}) — documented as "An automatically disposed ProviderContainer." Implementation registers addTearDown(container.dispose) internally and "adds an internal check at the end of tests that verifies that all containers were disposed."
   - Override overrideWithBuild(RunNotifierBuild<NotifierT, ValueT> build) on NotifierProvider.

4. NOT CARGO CULT / NOT OVERSTATED CONSENSUS. "createContainer is obsolete" is not a blogger's claim promoted to consensus — it is the package author's own changelog stating the constructor "is meant to replace the createContainer utility." riverpod.dev/docs/how_to/testing now uses `final container = ProviderContainer.test();` and no longer shows the createContainer + addTearDown helper anywhere.

5. DOC QUOTE LOCATED. "No need to dispose the container when the test ends" appears on riverpod.dev/docs/concepts2/containers (a code comment in a note advising ProviderContainer.test() over bare ProviderContainer inside tests), not on how_to/testing. Both pages were cited by the claim, so attribution is sound; only the per-page precision is loose.

MECHANISM NOTE: the addTearDown ceremony did not vanish, it moved inside the constructor — which is why the replacement is safe rather than merely terser.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "riverpod" made this claim, and a project decision depends on it.

CLAIM: The canonical test idiom changed: `ProviderContainer.test()` self-disposes. `createContainer` + `addTearDown(container.dispose)` is obsolete.
DETAIL: Added in 3.0.0-dev.12: 'Added ProviderContainer.test(). This is a custom constructor for testing purpose. It is meant to replace the createContainer utility.' The docs state plainly 'No need to dispose the container when the test ends.' This is the highest-traffic stale pattern in existing tutorials — the createContainer/addTearDown helper is copy-pasted across essentially every Riverpod testing article from 2022-2024 and is now pure ceremony. Also added in dev.12: `NotifierProvider.overrideWithBuild`, which mocks a Notifier's build() without replacing the notifier's methods — useful for seeding settings state without a fake class.
CLAIMED SOURCES: https://riverpod.dev/docs/how_to/testing, https://riverpod.dev/docs/concepts2/containers, https://pub.dev/packages/riverpod/changelog
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
