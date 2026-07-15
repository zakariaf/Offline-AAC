# riverpod--stateprovider-statenotifierprovider-and-chan

> Phase: **verify** · Agent `ada532c6b9df9f88b` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Two fixes. (1) ScopedProvider was removed in Riverpod 1.0.0 (announced in 1.0.0-dev.2, ~Nov 2021), NOT in 3.0 -- the migration is still "change ScopedProviders to Providers", but it is not a 3.0-related removal and is mentioned in neither claimed source. Anyone on a 2.x codebase already has no ScopedProvider. (2) Notifier/AsyncNotifier/StreamNotifier is not "the only current idiom" -- it is the current idiom for mutable state. Provider, FutureProvider and StreamProvider stay in the main barrel of flutter_riverpod 3.3.2, are not legacy, and remain correct for derived/read-only, async-once, and stream values respectively. Also worth noting: legacy.dart additionally exports StateController, StateNotifier, and the ChangeNotifierProviderFamily/StateNotifierProviderFamily/StateProviderFamily variants.

**Evidence:** CORE CLAIM CONFIRMED against primary sources.

1. Quarantine-not-deletion: riverpod CHANGELOG 3.0.0 states verbatim: "Breaking: ChangeNotifierProvider, StateProvider and StateNotifierProvider are moved out of package:hooks_riverpod/hooks_riverpod.dart to package:hooks_riverpod/legacy.dart" and "Breaking: StateProvider and StateNotifierProvider are moved out of package:flutter_riverpod/flutter_riverpod.dart to package:flutter_riverpod/legacy.dart".

2. riverpod.dev/docs/whats_new: "[StateProvider]/[StateNotifierProvider] and [ChangeNotifierProvider] are discouraged and moved to a different import" and "Those providers are not removed, but simply moved to a different import." The 3.0_migration guide: "They are not removed, but are no longer part of the main API. This is to discourage their use in favor of the new Notifier API." Valid imports listed: package:flutter_riverpod/legacy.dart, package:hooks_riverpod/legacy.dart, package:riverpod/legacy.dart -- exactly as claimed.

3. API surface verified live, not from memory: pub.dev/documentation/flutter_riverpod/latest/legacy/ for 3.3.2 exports ChangeNotifierProvider, ChangeNotifierProviderFamily, StateController, StateNotifier, StateNotifierProvider, StateNotifierProviderFamily, StateProvider, StateProviderFamily. All three named providers genuinely exist there. (Claim omits StateController/StateNotifier, an omission not an error.)

4. Family notifier removal CONFIRMED: 3.0_migration guide gives FamilyNotifier -> Notifier, FamilyAsyncNotifier -> AsyncNotifier, FamilyStreamNotifier -> StreamNotifier, and states you remove the build() parameter and add a constructor to accept the argument. Matches the claim precisely.

5. NO VERSION ROT / NOT A DEAD PACKAGE: flutter_riverpod latest is 3.3.2, publisher dash-overflow.net (verified publisher), last published ~35 days ago, no discontinued marker. Actively maintained.

TWO SPECIFICS ARE WRONG:

A. ScopedProvider version rot. It was NOT removed in 3.0. riverpod changelog shows removal announced in 1.0.0-dev.2 and 1.0.0 (~Nov 2021): "Breaking: ScopedProvider is removed. To migrate, change ScopedProviders to Providers." That is four years and two major versions before 3.0. Neither claimed source supports it: the 3.0_migration guide does not mention ScopedProvider, whats_new does not mention ScopedProvider, and the 0.14.0_to_1.0.0 migration guide also does not mention it (it covers ScopedReader -> WidgetRef and useProvider -> HookConsumerWidget, which are different APIs and a plausible source of the confusion). The substance ("use Provider") is right; the 3.0 framing is not.

B. "Notifier/AsyncNotifier is the only current idiom" is overstated (cargo-cult/overreach). Only the three legacy providers were quarantined. Provider, FutureProvider and StreamProvider remain in the main barrel, were never legacy, and are current. Notifier/AsyncNotifier/StreamNotifier is the current idiom for mutable/user-driven state specifically, not the only current idiom overall.

The operational warning at the heart of the claim -- that 2023 tutorial code still compiles once you add the legacy import, and that "add an import" is the trap rather than the fix -- is accurate and directly supported by the primary docs' own "discouraged" language.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "riverpod" made this claim, and a project decision depends on it.

CLAIM: StateProvider, StateNotifierProvider and ChangeNotifierProvider are quarantined to a `legacy.dart` import, not deleted. Notifier/AsyncNotifier is the only current idiom.
DETAIL: In 3.0 these three moved out of the main barrel file into `package:flutter_riverpod/legacy.dart` (and `package:hooks_riverpod/legacy.dart`) and are explicitly discouraged. They still compile if you import legacy.dart — which is the trap: a 2023 tutorial's code will look almost right and the fix will look like 'add an import'. Don't. Use Notifier/AsyncNotifier/StreamNotifier. Related removal: FamilyNotifier, FamilyAsyncNotifier and FamilyStreamNotifier are gone — families now use the base classes with constructor parameters. ScopedProvider is removed (use Provider).
CLAIMED SOURCES: https://riverpod.dev/docs/3.0_migration, https://riverpod.dev/docs/whats_new
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
