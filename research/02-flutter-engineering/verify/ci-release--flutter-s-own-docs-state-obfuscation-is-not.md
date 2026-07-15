# ci-release--flutter-s-own-docs-state-obfuscation-is-not

> Phase: **verify** · Agent `a8702e476b68ca12c` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Evidence:** Attempted refutation failed; every specific in the claim matched the primary source verbatim.

1. SECURITY QUOTE — EXACT. docs.flutter.dev/deployment/obfuscate, "Limitations and warnings" section, reads verbatim: "Obfuscating your code does _not_ encrypt resources nor does it protect against reverse engineering. It only renames symbols with more obscure names." Preceded by a warning admonition: "It is a **poor security practice** to store secrets in an app." The claim's quotation is character-accurate.

2. RELEASE BUILDS ONLY — CONFIRMED. Bolded in source: "**Flutter's code obfuscation works only on a [release build][].**" (links to /testing/build-modes#release). Doc also notes web apps don't support obfuscation (minification instead).

3. runtimeType CAVEAT — CONFIRMED, EXACT CODE MATCH. "Caveat" section: "Code that relies on matching specific class, function, or library names will fail. For example, the following call to `expect()` won't work in an obfuscated binary:" followed by the code excerpt `expect(foo.runtimeType.toString(), equals('Foo'));` — identical to the claim.

4. ENUM NAMES — CONFIRMED, EXACT. "Enum names are not obfuscated currently."

5. SYMBOLS BACKUP — CONFIRMED. "Once you've obfuscated your binary, **backup the SYMBOLS file**. You might need this if you lose your original SYMBOLS file and you want to de-obfuscate a stack trace."

6. --obfuscate + --split-debug-info — CONFIRMED. Documented command: `flutter build <build-target> --obfuscate --split-debug-info=/<symbols-directory>`. Doc: "To obfuscate your app and create a symbol map, use the `flutter build` command in release mode with the `--obfuscate` and `--split-debug-info` options."

7. SUPPORTED TARGETS — CONFIRMED. Claim says targets "include apk, appbundle, ios, ipa" — correctly hedged. Full documented list: aar, apk, appbundle, ios, ios-framework, ipa, linux, macos, macos-framework, windows.

8. SYMBOLIZE — CONFIRMED. "Read an obfuscated stack trace": "Find the matching SYMBOLS file. For example, a crash from an Android arm64 device would need `app.android-arm64.symbols`." Command: `flutter symbolize -i <stack-trace-file> -d <obfuscated-symbols-file>`, with example path `out/android/app.android-arm64.symbols`. The claim's "needs the arch-specific symbols file from the exact build" is an accurate paraphrase.

VERSION ROT CHECK — NEGATIVE. The page is live on flutter/website main branch as of 2026-07-15. No flags renamed/deprecated in Flutter 3.44.0. No package dependencies involved (no dead-package or archived-repo hazard). No invented API names: `flutter symbolize`, `--obfuscate`, `--split-debug-info`, and `--extra-gen-snapshot-options=--save-obfuscation-map` all exist as stated.

MINOR CAVEAT (not an error in the claim, but relevant to how it gets used): the Flutter doc is internally in mild tension. Its intro paragraph says obfuscation replaces symbols "making it difficult for an attacker to reverse engineer your proprietary app," while the Limitations section says it does "not protect against reverse engineering." The claim tracks the Limitations section, which is the operative normative statement — so the researcher read the doc correctly. Anyone quoting the intro back in a design review is cherry-picking the weaker sentence.

CARGO-CULT / CONSENSUS CHECK — NEGATIVE. The claim attributes statements only to Flutter's own docs and does not overstate community consensus or generalize a team practice. Each attributed statement is present in that source.

The claim is safe to rely on for a ci-release decision as written.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "ci-release" made this claim, and a project decision depends on it.

CLAIM: Flutter's own docs state obfuscation is not a security control, and it breaks runtime type-name matching
DETAIL: docs.flutter.dev/deployment/obfuscate: 'Obfuscating your code does not encrypt resources nor does it protect against reverse engineering. It only renames symbols with more obscure names.' Caveats: release builds only; `expect(foo.runtimeType.toString(), equals('Foo'))` won't work; enum names are NOT obfuscated; you must back up the SYMBOLS file or you can never de-obfuscate. --obfuscate requires --split-debug-info=<dir>. Supported targets include apk, appbundle, ios, ipa. Symbolization: `flutter symbolize -i <trace-file> -d <app.android-arm64.symbols>` — needs the arch-specific symbols file from the exact build.
CLAIMED SOURCES: https://docs.flutter.dev/deployment/obfuscate
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
