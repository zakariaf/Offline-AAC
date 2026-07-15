# project-structure--local-packages-melos-are-a-net-loss-for-a-so

> Phase: **verify** · Agent `a7204be8a4f344801` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Three corrections. (1) Attribution: this is not "2025 community framing" — all three quotes come from a single blog post by one author (Shahzaib Abid, shahzaibabid.com). Cite it as one practitioner's opinion, not community consensus. (2) Residual value: after Melos 7.0.0's delegation to pub workspaces, Melos retains MORE than versioning/changelogs/publishing — the migration guide also lists cross-package script execution and package filtering/categorization, and lazebny.io notes running CI checks only on changed packages. (These still don't apply to a one-app MVP, so the conclusion stands.) (3) "Use pub workspaces directly and skip melos entirely" is not supported by the cited sources; lazebny.io explicitly presents workspaces and Melos as complementary (workspaces first, Melos layered on top for automation). Accurate framing: for a solo two-week single-app MVP, pub workspaces alone (Dart >=3.6.0, `resolution: workspace`) cover any local-package split, and Melos's remaining features have no addressable use case at that scale — so defer Melos, not "skip it entirely" as a permanent rule. Also note for currency: Melos is at 8.2.2 (Invertase, actively maintained, published within days), not dead; 7.0.0 is correct only as the historical workspace-migration boundary.

**Evidence:** CORE RECOMMENDATION SUBSTANTIATED; TWO SPECIFICS WRONG + ONE OVERSTATEMENT.

VERIFIED AGAINST PRIMARY SOURCES:
1. Pub workspaces / Dart 3.6: CONFIRMED. dart.dev/tools/pub/workspaces states "Support for pub workspaces was introduced in Dart 3.6.0" and confirms the `resolution: workspace` key in each workspace package's pubspec.yaml. No invented API — the key name and SDK version are exact.
2. Melos 7.0.0 delegation: CONFIRMED. pub.dev/packages/melos/changelog 7.0.0 reads "BREAKING FEAT: Migrate to use the Pub workspaces feature (#816)" and "BREAKING FEAT: Remove melos.yaml in favor of the root pubspec.yaml (#832)". Migration guide: "Since the pub workspaces feature has been released, Melos has been updated to rely on that, instead of creating pubspec_overrides.yaml files." Supporting detail the claim omitted: `melos analyze` was REMOVED because Dart/Flutter analysis now operates on the full workspace natively — this strengthens the claim's direction.
3. Quotes are verbatim real, not fabricated. All three ("investment"/"relief"; "multiplier ... multiplies complexity instead of productivity"; benefits arrive "once they start managing multiple apps or client projects together") were independently recovered from the cited article via search after the source returned HTTP 403 to direct fetch.
4. NO VERSION ROT AND NO DEAD PACKAGE. Melos is alive: v8.2.2, published 2 days ago, publisher Invertase.io (verified), NOT marked discontinued. The claim does not misrepresent this.

DEFECTS FOUND:
A. OVERSTATED CONSENSUS (failure mode #5). "2025 community framing" is a single blog post by one author (Shahzaib Abid). All three quotes trace to that one URL. No independent second voice supports any of the three framings. This is one opinion piece presented as community consensus.
B. RESIDUAL-VALUE LIST INCOMPLETE. The claim asserts residual value is only "multi-package versioning/changelogs/publishing." The Melos migration guide additionally lists SCRIPTS and PACKAGE FILTERING/CATEGORIZATION as surviving features; lazebny.io adds "Optimizing CI/CD by running checks only on packages that have changed." Mitigating: none of these apply to a solo single-app MVP either, so the omission does not reverse the conclusion.
C. "SKIP MELOS ENTIRELY" OVERREACHES ITS SOURCES. lazebny.io (Dart & Flutter Monorepos: Pub Workspaces and Melos) explicitly frames the two as COMPLEMENTARY — set up pub workspaces first, then add Melos config to the root pubspec.yaml for automation — not as one replacing the other. No cited source says to skip Melos entirely; that is the researcher's editorializing.

NET: The project decision (don't adopt Melos for a solo two-week single-app MVP) is safe and technically well-grounded. The justification is weaker than stated: it rests on one blogger, not a community, and it understates Melos's post-7.0.0 feature surface.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "project-structure" made this claim, and a project decision depends on it.

CLAIM: Local packages + melos are a net loss for a solo, single-app, two-week MVP.
DETAIL: 2025 community framing: 'For solo developers, Melos feels like an investment, whereas for teams, it feels like relief'; 'Melos is a multiplier — without scale, it multiplies complexity instead of productivity'; benefits arrive 'once they start managing multiple apps or client projects together.' Additionally, since Melos 7.0.0 Melos delegates dependency resolution to Dart pub workspaces (Dart 3.6+, `resolution: workspace`), so its residual value is multi-package versioning/changelogs/publishing — none of which apply. If a split ever becomes necessary, use pub workspaces directly and skip melos entirely.
CLAIMED SOURCES: https://shahzaibabid.com/when-to-use-flutter-melos-and-monorepo/, https://melos.invertase.dev/guides/migrations, https://dart.dev/tools/pub/workspaces, https://dart.dev/blog/announcing-dart-3-6
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
