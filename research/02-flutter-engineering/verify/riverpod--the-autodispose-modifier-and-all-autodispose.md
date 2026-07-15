# riverpod--the-autodispose-modifier-and-all-autodispose

> Phase: **verify** · Agent `a01e55b5e4e02e352` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The `.autoDispose` modifier is NOT gone in Riverpod 3.3.2 (current as of 2026-07-15). It survives, undeprecated, as `static const autoDispose = AutoDisposeProviderBuilder();` on Provider (provider.dart line 49), and `AutoDisposeProviderBuilder`/`AutoDisposeProviderFamilyBuilder` still exist in builder.dart marked `@internal` — which is why their dartdoc pages 404 while the symbols remain callable. `Provider.autoDispose((ref) => x)` still compiles and works; it is now sugar forwarding to `Provider(create, isAutoDispose: true)`.

What IS gone is narrower and should be stated precisely: the duplicated *interface clones* — AutoDisposeRef, AutoDisposeNotifier, AutoDisposeProvider, AutoDisposeStateProvider (all 404 on latest docs). 3.0 unified Ref/Notifier into single types.

Everything else in the claim is accurate as written: the exact constructor signature, `isAutoDispose = false` default for manual providers, codegen defaulting to autoDispose ON (opt out via `@Riverpod(keepAlive: true)`), the manual-vs-codegen asymmetry, `ref.keepAlive()` returning a closable link that re-enables on recompute, and the lint rule `avoid_keep_alive_dependency_inside_auto_dispose` (with the added nuance that it is riverpod_generator-only).

PRACTICAL IMPACT ON THE DECISION: if the plan assumes `.autoDispose` call sites will fail to compile on 3.x and force a mechanical codemod, that is backwards. Migrating `.autoDispose` -> `isAutoDispose: true` is OPTIONAL and cosmetic. Only `AutoDisposeRef`/`AutoDisposeNotifier` *type annotations* are breaking and must be rewritten (case-sensitive strip of the `AutoDispose` prefix, per the official migration guide).

**Evidence:** VERIFIED CORRECT (majority of claim):

1. Constructor signature is verbatim exact. Raw HTML of pub.dev/documentation/riverpod/3.3.2/riverpod/Provider-class.html yields: "Provider ( Create < ValueT > _create , { String ? name , Iterable < ProviderOrFamily > ? dependencies , bool isAutoDispose = false , Retry? retry })". Master source packages/riverpod/lib/src/providers/provider.dart line 24 confirms `super.isAutoDispose = false`.

2. AutoDispose* INTERFACE CLONES are genuinely removed. HTTP status checks on latest docs: AutoDisposeRef-class.html => 404, AutoDisposeNotifier-class.html => 404, AutoDisposeProviderBuilder-class.html => 404, Notifier-class.html => 200. Notifier inheritance chain is Object -> AnyNotifier<ValueT,ValueT> -> Notifier with no autoDispose variant. Migration guide states: "AutoDispose interfaces are removed. The auto-dispose feature is simplified. Instead of relying on a clone of all interfaces, interfaces are unified." and "To easily migrate, you can do a case-sensitive replace of `AutoDispose` to (empty string)."

3. The manual-vs-codegen asymmetry is real. riverpod.dev/docs/concepts2/auto_dispose: codegen enabled by default, opt out with @Riverpod(keepAlive: true); manual providers opt in via isAutoDispose: true.

4. ref.keepAlive() returning a link with .close(), and disposal re-enabling on recompute, is confirmed on the auto_dispose page: "If the provider is recomputed, automatic disposal will be re-enabled."

5. Lint rule name is REAL and correctly spelled. riverpod_lint README line 512: "### avoid_keep_alive_dependency_inside_auto_dispose (riverpod_generator only)" — "Warn when a `keepAlive` provider tries to use a non-`keepAlive` provider." Confirmed in riverpod_lint CHANGELOG: "added `avoid_keep_alive_dependency_inside_auto_dispose`".

6. Package is alive, not dead/discontinued. riverpod 3.3.2, publisher dash-overflow.net (verified), published ~35 days before 2026-07-15. No discontinuation marker.

REFUTED SPECIFIC — "The `.autoDispose` modifier ... [is] gone" is FALSE:

Master source packages/riverpod/lib/src/providers/provider.dart lines 48-49:
    /// {@macro riverpod.autoDispose}
    static const autoDispose = AutoDisposeProviderBuilder();

`grep -c -i "deprecated" provider.dart` returns 0 — there is no @Deprecated annotation on it. The current 3.3.2 doc page still lists under "Constants": "autoDispose -> const AutoDisposeProviderBuilder — Marks the provider as automatically disposed when no longer listened to."

Also refutes "all AutoDispose* classes are gone": packages/riverpod/lib/src/builder.dart line 447 still defines `final class AutoDisposeProviderBuilder { const AutoDisposeProviderBuilder(); ... }` (and AutoDisposeProviderFamilyBuilder at line 443), both annotated @internal. The @internal annotation is precisely why the dartdoc page 404s while the symbol remains live in the API surface.

METHODOLOGICAL NOTE: the WebFetch summarizer model gave contradictory answers across calls (asserting both that .autoDispose was removed and that it exists), pattern-matching familiar Riverpod 2.x API names. Only raw HTML grep + master source resolved it. Similarly, a search result surfacing AutoDisposeStateProvider-class.html was a stale 2.x index entry — it 404s on latest. The CLAIMED SOURCES were cited accurately; the error is an over-generalization the researcher drew beyond what the migration guide states (the guide says AutoDispose *interfaces* are removed; the researcher extended that to the *modifier*).

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "riverpod" made this claim, and a project decision depends on it.

CLAIM: The `.autoDispose` modifier and all AutoDispose* classes are gone. Manual providers default to autoDispose OFF via a new `isAutoDispose:` parameter; codegen defaults it ON.
DETAIL: Riverpod 2 duplicated every provider/Ref/Notifier for autoDispose (Ref vs AutoDisposeRef, Notifier vs AutoDisposeNotifier). 3.0 unified them; the old compile-time guard is now a riverpod_lint rule (avoid_keep_alive_dependency_inside_auto_dispose). Verified constructor signature: `Provider(Create<ValueT> _create, {String? name, Iterable<ProviderOrFamily>? dependencies, bool isAutoDispose = false, Retry? retry})`. So `Provider.autoDispose((ref) => x)` becomes `Provider((ref) => x, isAutoDispose: true)`. Note the asymmetry that bites: manual providers default to keeping state alive; `@riverpod`-generated ones default to disposing it. `ref.keepAlive()` returns a link with `.close()`, and disposal re-enables automatically on recompute.
CLAIMED SOURCES: https://pub.dev/documentation/riverpod/latest/riverpod/Provider-class.html, https://riverpod.dev/docs/concepts2/auto_dispose, https://riverpod.dev/docs/3.0_migration
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
