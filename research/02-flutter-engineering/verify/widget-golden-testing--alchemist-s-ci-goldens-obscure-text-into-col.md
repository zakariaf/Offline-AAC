# widget-golden-testing--alchemist-s-ci-goldens-obscure-text-into-col

> Phase: **verify** · Agent `a051ebc8fc7fb2e1d` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim stands as written. Two refinements worth carrying into the project decision:

(a) "Forced Ahem" is conditional on obscureText, not on CI mode. GoldensConfig's own dartdoc: "when [obscureText] is true, tests are always rendered in the 'Ahem' font family to ensure consistent results across platforms. In other words, the font family of the [theme] will be ignored." So Ahem is downstream of obscureText, not a separate CI switch. The claim's phrasing bundles them as three parallel CI properties; mechanically it's obscureText:true -> (colored boxes AND Ahem).

(b) DECISION-RELEVANT: obscureText is a constructor parameter on CiGoldensConfig, so `CiGoldensConfig(obscureText: false)` is a supported configuration — the box-rendering is a DEFAULT, not an inherent property of CI goldens. The claim says "by default" and is therefore accurate, but the headline framing ("destroys the only signal this app would want") could be misread as an unavoidable tradeoff. It is opt-out-able. The honest caveat: opting out re-exposes you to exactly the cross-platform glyph variance the default exists to suppress, so the escape hatch is only viable if the app bundles its own fonts rather than relying on system font fallback. Whether that yields stable goldens on your CI is an empirical question neither the README nor the source settles — test it before betting on it.

Net: for a golden whose question is "does the label still fit and read at 200% text scale," the researcher's conclusion is sound. The default CI golden answers a different question. But the remedy is a config flag plus bundled fonts, not abandoning alchemist.

**Evidence:** Every named parameter, default, and mechanism in this claim verified against alchemist's actual source code (not just the README), and the package is demonstrably alive.

1. PACKAGE IS ALIVE — not a dead-package failure mode. pub.dev shows alchemist 0.14.0, published by VERIFIED publisher betterment.dev, released Mar 13 2026 (~4 months before today's 2026-07-15). Repo github.com/Betterment/alchemist is NOT archived, NOT marked discontinued, 298 stars, 30 open issues, active CI. Co-maintained by Very Good Ventures and Betterment.

2. THE DEFAULTS ARE EXACTLY AS CLAIMED — verified in lib/src/alchemist_config.dart, not inferred from prose:
   CiGoldensConfig:       super.obscureText = true,  super.renderShadows = false,
   PlatformGoldensConfig: super.obscureText = false, super.renderShadows = true,
   This is a 4-for-4 match on the claim's specifics. No version rot: renderShadows landed in 0.3.0 and the changelog shows no changes to obscureText, renderShadows, Ahem, or the CI/platform defaults through 0.14.0.

3. API NAMES ARE REAL — `obscureText`, `renderShadows`, `CiGoldensConfig`, `PlatformGoldensConfig` all exist with those exact names. No invented/LLM-plausible signatures.

4. THE CAUSAL STORY IS THE MAINTAINERS' OWN, quoted verbatim from README: platform tests "generate golden files with human readable text... usually only run on a local machine"; CI tests "look and function the same as platform tests, except that the text blocks are replaced with colored squares." The claim's assertion that CI goldens are platform-stable BECAUSE they discard glyph rendering is not the researcher's editorializing — it is alchemist's stated rationale.

5. AHEM — README: "CI tests are always run using the Ahem font family, which is a font that solely renders square characters."

This is not cargo cult or overstated consensus: the source is the package's own maintainers documenting their own defaults, which is exactly the right authority for a claim about what the package does.

ONE PRECISION REFINEMENT (does not refute, see correction): the Ahem forcing is coupled to obscureText, not to CI-ness independently.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "widget-golden-testing" made this claim, and a project decision depends on it.

CLAIM: alchemist's CI goldens obscure text into colored boxes — which destroys the only signal this app would want from a golden
DETAIL: alchemist splits Platform goldens (readable text, renderShadows: true, only stable on the machine that made them) from CI goldens (obscureText: true by default -> text replaced with opaque colored rectangles; renderShadows: false; forced Ahem). CI goldens are platform-stable precisely BECAUSE they throw away glyph rendering. For an app whose golden question is 'does the label still fit and read at 200% scale', a CI golden answers a question you did not ask.
CLAIMED SOURCES: https://github.com/Betterment/alchemist
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
