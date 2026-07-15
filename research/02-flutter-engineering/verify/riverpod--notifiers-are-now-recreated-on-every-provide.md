# riverpod--notifiers-are-now-recreated-on-every-provide

> Phase: **verify** · Agent `ac6bdcf81a0fa0e55` · Run `wf_12b14467-451`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** Notifiers are NOT recreated on every provider rebuild in any stable Riverpod release. That behaviour existed only transiently during the 3.0 dev cycle (introduced 3.0.0-dev.12, 2025-04-30) and was reverted before stable: "Revert Notifier life-cycle change. They are once again preserved across rebuilds." (3.0.0-dev.16/dev.18, 2025-09-09). Riverpod 3.0.0 stable (2025-09-10) through current 3.3.2 (2026-06-10) all PRESERVE Notifiers across rebuilds — the 2.x pseudo-singleton behaviour the claim calls "gone" was restored.

Consequences for the project decision:
1. The leak premise is void. Holding a TTS controller, timer, or subscription as a Notifier field does NOT leak due to per-rebuild recreation, because that recreation does not occur.
2. `Ref.mounted` IS real and usable (`mounted → bool` on Ref, analogous to BuildContext.mounted), shipped in 3.0.0 stable. Guarding post-await state writes with it is valid advice — it just is not enabled by, nor evidence for, the reverted lifecycle change.
3. The SpeechService recommendation (disposable service in a plain `Provider` with `ref.onDispose(() => service.dispose())`, injected via ProviderScope override) remains a SOUND pattern and is safe to adopt — Notifiers are still disposed on provider disposal (autoDispose, family eviction, scope teardown), so cleanup discipline still matters. But it is sound on ordinary lifecycle grounds, NOT because a breaking change forces it, and no primary source (whats_new or the 3.0 migration guide) mandates it. Treat it as a reasonable team convention, not a documented requirement. Adopting it for the stated reason means reasoning from a false model of Notifier lifecycle.

Confidence should be downgraded from "high" to "refuted on the load-bearing claim; Ref.mounted portion confirmed."

**Evidence:** The claim's central assertion is FALSE for current Riverpod. The change was introduced during the 3.0 dev cycle and then REVERTED before 3.0.0 stable shipped.

TIMELINE (from pub.dev changelog + raw GitHub CHANGELOG.md):
1. 3.0.0-dev.12 (2025-04-30): "Breaking: `Notifier` and variants are now recreated whenever the provider rebuilds. This enables using `Ref.mounted` to check dispose." — The researcher's quote is VERBATIM ACCURATE and CORRECTLY ATTRIBUTED to dev.12. Same release: "Added a `Ref.mounted` to simplify dealing with provider disposal".
2. A LATER dev release (dev.16-dev.18 range, 2025-09-09): "Revert Notifier life-cycle change. They are once again preserved across rebuilds." Ordering confirmed by physical position in the reverse-chronological CHANGELOG.md: the revert entry appears HIGHER in the file than dev.12, i.e. it came after. (Summarizer passes disagreed on whether the revert lands in dev.16 or dev.18; the ordering relative to dev.12 was consistent across all passes.)
3. 3.0.0 stable (2025-09-10) shipped WITH the revert in place. No entry in dev.19+, 3.0.0, 3.1.x, 3.2.x, or 3.3.x re-applies the recreation behaviour.

CURRENT STATE: riverpod 3.3.2 (published 2026-06-10), publisher dash-overflow.net (verified), actively maintained, NOT discontinued. Notifiers are PRESERVED across rebuilds — the 2.x behaviour the claim says is "gone" was in fact restored.

CORROBORATION (two primary docs, both silent):
- https://riverpod.dev/docs/whats_new ("What's new in Riverpod 3.0") does NOT mention Notifier recreation on rebuild. It covers Ref.mounted extensively ("The long-awaited Ref.mounted is finally here! It is similar to BuildContext.mounted, but for Ref.") and mentions only "When a provider rebuilds, its previous subscriptions now are kept until the rebuild completes."
- https://riverpod.dev/docs/3.0_migration does NOT mention Notifier recreation, nor fields on Notifiers (timers/subscriptions/services), nor moving disposables into plain Providers.
A change invalidating every field on every Notifier in every Riverpod app would be the headline of both documents. Their silence is consistent with the change never reaching stable.

WHAT IS TRUE (survived the revert):
- `Ref.mounted` is REAL. Verified on package API docs: signature `mounted → bool`, "Whether this Ref is still active." Analogous to BuildContext.mounted. Added dev.12, shipped in stable.
- `ref.onDispose` is REAL: `onDispose(void listener()) → RemoveListener`, "Adds a listener to perform an operation right before the provider is destroyed."

ERROR MODE: Version rot via partial changelog read. The researcher found a real dev-release entry, quoted it correctly, and stopped — missing the revert 4-6 dev releases later. Ref.mounted and the Notifier lifecycle change landed in the SAME release (dev.12), which is why a real API got bundled with a reverted breaking change. Note the error is directional inversion, not a specifics miss: claim says "recreated on every rebuild", reality is "preserved across rebuilds" — the exact opposite. Hence REFUTED, not PARTIALLY_TRUE.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "riverpod" made this claim, and a project decision depends on it.

CLAIM: Notifiers are now recreated on every provider rebuild. Holding a TTS controller, timer, or subscription as a Notifier field leaks.
DETAIL: Changelog 3.0.0-dev.12: 'Notifier and variants are now recreated whenever the provider rebuilds. This enables using Ref.mounted to check dispose.' The 2.x pseudo-singleton behaviour is gone. Directly relevant: SpeechService (flutter_tts wrapper) must NOT be constructed inside or owned by a Notifier — it belongs in a plain `Provider` with `ref.onDispose(() => service.dispose())`, injected via override at the ProviderScope root. `Ref.mounted` (analogous to BuildContext.mounted) now exists to guard post-await state writes.
CLAIMED SOURCES: https://pub.dev/packages/riverpod/changelog, https://riverpod.dev/docs/whats_new
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
