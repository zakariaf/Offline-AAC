# ci-release--obfuscation-is-actively-harmful-for-this-spe

> Phase: **verify** · Agent `a50f21333537f9f3e` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Verdict stands; three specifics to tighten, none fatal.

(a) The claim concedes obfuscation addresses a "reverse-engineering" threat model. Flutter's docs are blunter and make the concession unnecessary: obfuscation "does not encrypt resources nor does it protect against reverse engineering. It only renames symbols with more obscure names." The forgone benefit is smaller than the claim allows, strengthening its own conclusion.

(b) The runtimeType breakage is scoped to class/function/library names. Docs add "Enum names are not obfuscated currently," so enum-name matching survives. Does not rescue runtimeType.toString().

(c) "A few MB" is the only unsourced figure and misattributes the cost. The documented ~10-20% AOT snapshot reduction is attributable to --split-debug-info (dart-lang/sdk#50055, #44852), NOT --obfuscate; obfuscation alone buys essentially no size. Since --split-debug-info can be used without --obfuscate, the size win is available independently — obfuscation is pure cost against the legible-trace goal. This reinforces rather than weakens the claim. The "few MB" number should be measured per-app, not asserted.

CONFIDENCE NOTE: stated confidence of "medium" is too low. The mechanics are documented verbatim in the cited primary source and enforced in the tool's source code; this warrants high confidence.

**Evidence:** Attempted refutation on five fronts; all sub-claims survived against primary sources.

1) "--obfuscate requires --split-debug-info" — CONFIRMED in flutter_tools source (getBuildInfo()): `if (dartObfuscation && (splitDebugInfoPath == null || splitDebugInfoPath.isEmpty)) { throwToolExit('"--obfuscate" can only be used in combination with "--split-debug-info"'); }`. Hard tool exit, not a convention. So obfuscating necessarily produces DWARF/non-symbolic traces.

2) Per-build, per-arch symbols — CONFIRMED verbatim: "Find the matching SYMBOLS file. For example, a crash from an Android arm64 device would need `app.android-arm64.symbols`." Docs also instruct "backup the SYMBOLS file... if you lose your original SYMBOLS file". Confirms the retention-dependency argument.

3) Reading a trace requires developer + symbols + tooling — CONFIRMED: `flutter symbolize -i <stack-trace-file> -d <obfuscated-symbols-file>`.

4) runtimeType breakage — CONFIRMED verbatim in Caveat: "Code that relies on matching specific class, function, or library names will fail. For example, the following call to expect() won't work in an obfuscated binary: expect(foo.runtimeType.toString(), equals('Foo'));"

5) THE KEY CHECK — the version-rot hazard that would have refuted this. dart-lang/sdk#50055 "Breaking change: switch PRODUCT builds to use DWARF stack traces by default" returns state=closed, state_reason=completed via the GitHub API, which reads as shipped. Had it shipped, release traces would be non-symbolic by DEFAULT and the claim's central premise ("without --split-debug-info, AOT release stack traces retain Dart function names") would collapse. Reading the comments refutes the label: mraleph 2023-01-18 "we might not be completely ready for this yet. So I would like to punt on this for a bit"; mraleph 2023-02-03 "I will just close this - and the we reopen it when we have a better internal signal." Closed-as-punted, mislabeled completed. Symbolic stack traces remain the release default through Flutter 3.44. Premise holds.

Reasoning chain is sound: obfuscate implies split-debug-info implies DWARF traces implies symbolize-or-nothing implies unreadable after abandonment. Given a user-exported on-device log as the sole crash signal and a planned source-publication exit, the cost/benefit direction is correct.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "ci-release" made this claim, and a project decision depends on it.

CLAIM: Obfuscation is actively harmful for this specific app — it destroys the only field signal and its benefit is nil once the source is public
DETAIL: The threat model obfuscation addresses (reverse-engineering) is void when the exit plan is publishing the source. Meanwhile the app's only crash signal is a user-exported on-device log; an obfuscated trace requires the developer to still exist, to have retained the per-build per-arch .symbols file, and to run `flutter symbolize`. After abandonment (explicitly planned), every crash report ever filed becomes permanently unreadable. Additionally --obfuscate breaks runtimeType string matching — a silent-failure vector in a codebase whose stated worst bug class is silence. Without --split-debug-info, AOT release stack traces retain Dart function names and are directly readable in the exported log, at a cost of a few MB.
CLAIMED SOURCES: https://docs.flutter.dev/deployment/obfuscate
CONFIDENCE: medium

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
