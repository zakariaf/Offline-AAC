# lints-tooling--the-installed-sdk-is-flutter-3-41-2-dart-3-1

> Phase: **verify** · Agent `a795e38d22510ffe3` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Two corrections, neither of which affects the claim's argument:

1. "~2 releases behind" is wrong — it is ONE stable release behind. Flutter's 2026 release train is quarterly: 3.41 (Feb 2026), 3.44 (May 2026), 3.47 (Aug 2026), 3.50 (Nov 2026). There is no 3.42 or 3.43; per docs.flutter.dev/install/archive the minor version increments by 3 each cycle. So 3.41.2 -> 3.44 is exactly one stable cycle. (In patch terms the gap is wider: 3.41.2 -> 3.41.9 -> 3.44.0 -> 3.44.6.)

2. Current stable is Flutter 3.44.6 / Dart 3.12.2 (released 2026-07-09), not 3.44.0 / Dart 3.12.0. The brief's "Flutter stable is 3.44.0" is stale at the patch level. This does not change any pinning conclusion, since pub SDK constraints resolve against the Dart minor (3.12.x) and 3.12.0 vs 3.12.2 resolve identically.

Also note: 3.41.2's manifest release date is 2026-02-19, one day after the 2026-02-18 framework commit timestamp the claim cites. Both figures are correct; they measure different events (commit vs. publish).

**Evidence:** Attempted refutation on every axis; the claim survives. VERIFIED BY DIRECT EXECUTION: `dart --version` returns "Dart SDK version: 3.11.0 (stable) (Mon Feb 9 00:38:07 2026 -0800) on macos_arm64" — matches the claimed 3.11.0 stable / 2026-02-09 exactly. `flutter --version` returns "Flutter 3.41.2 • channel [user-branch] • unknown source / Framework • revision 90673a4eef (5 months ago) • 2026-02-18 13:54:59 -0800 / Tools • Dart 3.11.0 • DevTools 2.54.1" — matches the claimed version, channel, revision, and date exactly. SDK at /Users/zakariafatahi/development/flutter/bin/.

CROSS-CHECKED AGAINST PRIMARY MANIFEST (storage.googleapis.com/flutter_infra_release/releases/releases_macos.json, the source flutter upgrade itself consumes): 3.41.2 -> Dart 3.11.0, revision 90673a4eef275d1a6692c26ac80d6d746d41a73a, released 2026-02-19. The local revision 90673a4eef is the authentic 3.41.2 hash, not an LLM-plausible fabrication. 3.44.0 -> Dart 3.12.0, released 2026-05-18, confirming the claim's "Flutter 3.44 (Dart 3.12) is current stable as of ~May 2026". The cited release-notes URL (docs.flutter.dev/release/release-notes/release-notes-3.44.0) resolves and is genuine.

NO FAILURE MODES FOUND: no version rot (claim is pinned to today, 2026-07-15, and reflects live manifest data); no dead packages named; no invented API signatures (the claim names no APIs); no cargo cult; no overstated consensus. The methodological conclusion — pin version claims to what resolves at Dart 3.11 rather than pub.dev "latest" — is sound and is strengthened by the finding: any package published after 2026-05-18 declaring `sdk: '>=3.12.0'` will fail to resolve on this machine.

TWO MINOR SPECIFICS ARE OFF, neither load-bearing (see correction): the "~2 releases behind" arithmetic, and the brief's stale patch-level "stable is 3.44.0".

FLAG FOR RESEARCHER (not part of the claim, but decision-relevant): channel is [user-branch], NOT stable. This is a detached checkout at the 3.41.2 tag; `flutter upgrade` will not advance it. Closing the gap requires `flutter channel stable && flutter upgrade` or a reinstall.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "lints-tooling" made this claim, and a project decision depends on it.

CLAIM: The installed SDK is Flutter 3.41.2 / Dart 3.11.0 — NOT the Flutter 3.44 / Dart 3.12 the brief assumes.
DETAIL: `dart --version` → 3.11.0 (stable, 2026-02-09). `flutter --version` → 3.41.2, channel [user-branch], revision 90673a4eef (2026-02-18). Flutter 3.44 (Dart 3.12) is indeed current stable as of ~May 2026, so this machine is ~2 releases behind. Every version claim in this report is pinned to what actually resolves at 3.11, not to pub.dev's 'latest'. This drift between assumed and installed SDK is itself the argument for pinning.
CLAIMED SOURCES: local `dart --version` / `flutter --version`, https://docs.flutter.dev/release/release-notes/release-notes-3.44.0
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
