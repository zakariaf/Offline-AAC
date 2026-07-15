# lints-tooling--very-good-analysis-10-3-0-cannot-be-used-on

> Phase: **verify** · Agent `a2cebab1846b381df` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Two corrections. (1) It is NOT silent. `flutter analyze` exits 1 and `dart analyze` exits 2 on include_file_not_found — warnings are fatal by default in `dart analyze`, so a normal CI gate catches a wrong versioned include immediately. It only slips through green under `dart analyze --no-fatal-warnings` (measured exit 0), or unnoticed in-IDE. Everything else about the failure mode is accurate: severity really is `warning` rather than `error`, analysis really does continue, and all 212 rules really are disabled (reproduced: identical file, 8 violations → 0). (2) "CANNOT be used on this machine" should be "cannot be used on this machine's current toolchain." VGA 10.3.0 requires `^3.12.0`; the machine has Dart 3.11.0 because it is on Flutter 3.41.2. Flutter 3.44.0 stable ships Dart 3.12.0 (3.44.6 → Dart 3.12.2), so `flutter upgrade` unblocks 10.3.0. Until then, `include: package:very_good_analysis/analysis_options.10.2.0.yaml` is the correct pin — matching the resolved 10.2.0, not the latest published version.

**Evidence:** I tried to break this claim on every axis and the mechanism held up under direct reproduction. Verified, each independently:

1. VGA 10.3.0 IS the latest (published ~27 days ago) and its pubspec really is `environment: sdk: ^3.12.0` — confirmed from the pub.dev API (primary source), not just the web page. Not invented, not version rot.
2. VGA 10.2.0 really is `sdk: ^3.11.0` — confirmed in /Users/zakariafatahi/.pub-cache/hosted/pub.dev/very_good_analysis-10.2.0/pubspec.yaml.
3. Machine is Dart 3.11.0 (stable, 2026-02-09) / Flutter 3.41.2. Only very_good_analysis-10.2.0 is in pub-cache.
4. Pub really does resolve to 10.2.0 despite 10.3.0 being latest — I built a probe project with `very_good_analysis: any`; pubspec.lock pinned `version: "10.2.0"` and pub emitted "1 package has newer versions incompatible with dependency constraints."
5. "212 rules" is exactly right, not a round-numbered guess: `grep -cE "^\s{4}- "` on analysis_options.10.2.0.yaml returns exactly 212.
6. The rule-disabling is real and total. Same source file, two runs: with `include: .../analysis_options.10.2.0.yaml` → 8 violations (avoid_print, prefer_single_quotes, prefer_is_empty, public_member_api_docs, type_annotate_public_apis). With `include: .../analysis_options.10.3.0.yaml` → 0 lint violations, only the include_file_not_found warning. All 212 rules are genuinely inert.

WHERE THE CLAIM BREAKS: the word "silently." It is not silent, and this is the specific that the project decision hinges on. I measured exit codes:
- `dart analyze` with the bad include → exit 2
- `flutter analyze` with the bad include → exit 1
- `dart analyze --fatal-warnings` → exit 2
- `dart analyze --no-fatal-warnings` → exit 0

`dart analyze` treats warnings as fatal by default. A standard CI gate running `flutter analyze` or `dart analyze` DOES fail red on this. The researcher's own quoted output ("warning • The URI ... • include_file_not_found") is flutter analyze format — the command that returned it exited 1. So the framing "a genuinely dangerous failure mode ... on a project whose entire safety net is static analysis" is overstated: the safety net's gate trips. The real (narrower) exposure is (a) teams who pass `--no-fatal-warnings`, which goes green with zero rules active, and (b) the IDE, where you'd just see no squiggles and might not notice.

SECOND OVERSTATEMENT: "CANNOT be used on this machine" is true only of the machine's current, stale toolchain. Flutter 3.44.0 stable ships Dart 3.12.0 (confirmed via the official releases_macos.json manifest; 3.44.6 ships 3.12.2). This machine is on Flutter 3.41.2 (Dart 3.11.0), a ~5-month-old build. `flutter upgrade` to current stable satisfies ^3.12.0 and makes 10.3.0 resolvable. It's "not until you upgrade," not a hard capability block.

Package health checks (hunting for a dead-package failure mode): very_good_analysis is NOT discontinued, published by the verified publisher Very Good Ventures, latest release ~27 days ago, 41 versions with a cadence tracking each Dart SDK bump (10.0.0→3.9, 10.1.0→3.10, 10.2.0→3.11, 10.3.0→3.12). Actively maintained.

Probe project preserved at /private/tmp/claude-501/-Users-zakariafatahi-50-apps-challenge-Offline-AAC/894d23b4-edde-414c-90f6-a0c3d1367fdd/scratchpad/vgaprobe

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "lints-tooling" made this claim, and a project decision depends on it.

CLAIM: very_good_analysis 10.3.0 CANNOT be used on this machine — it requires Dart 3.12, and a wrong version in the `include:` silently downgrades to a warning and disables all 212 rules.
DETAIL: VGA 10.2.0 pubspec: `environment: sdk: ^3.11.0`. Machine has Dart 3.11.0, so pub resolves 10.2.0 even though 10.3.0 is latest. My first draft used `include: package:very_good_analysis/analysis_options.10.3.0.yaml` and produced only `warning • The URI ... can't be found ... • include_file_not_found` — analysis silently continued with NO VGA rules. This is a genuinely dangerous failure mode: a warning, not an error, on a project whose entire safety net is static analysis. Verify with `ls ~/.pub-cache/hosted/pub.dev/very_good_analysis-*/lib/`.
CLAIMED SOURCES: local probe, VGA 10.2.0 pubspec.yaml
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
