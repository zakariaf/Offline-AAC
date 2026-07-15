# design-tokens-implementation--the-dtcg-format-reached-a-stable-community-g

> Phase: **verify** · Agent `a9435942dc1f75d26` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Two corrections. (1) FACTUAL ERROR: "Style Dictionary v5 adopted DTCG 2025.10 as its base format" is false and chronologically impossible — v5.0.0 shipped 2025-05-16, five months before DTCG 2025.10 published on 2025-10-28. Style Dictionary gained first-class DTCG support in v4 (against earlier editors' drafts). Support for 2025.10 specifically is still INCOMPLETE and TRACKED IN AN OPEN ISSUE (#1590, opened 2025-11-04, still open 2026-07-15, labeled high priority/5.0): Color/Border/Shadow done; Gradient/Duration in progress; Resolver pending. Current shipping version is 5.5.0 (2026-06-21). The project's own docs say "the latest format 2025.10 does not have full support yet in Style Dictionary." Do not cite Style Dictionary v5 as evidence of 2025.10 adoption. (2) TERMINOLOGY/SOURCING: the correct designation is "Final Community Group Report" (not merely "stable Community Group Report"), and the cited /tr/drafts/format/ URL is an unstable draft that explicitly says "Do not reference this version as authoritative in any way" — replace it with /tr/2025.10/format/, which carries the load-bearing quote "This specification is not a W3C Standard nor is it on the W3C Standards Track." (3) SCOPE NOTE: the "~30 colors" and "hand-authored abstract final class Prim" describe code that does not yet exist — the repo has 0 commits and 0 Dart files. The recommendation is defensible as forward-looking design judgment, but should be stated as a plan rather than a description of the status quo. The central claim — DTCG 2025.10 is a real, stable, vendor-neutral CG report but NOT a W3C Recommendation, and structurally cannot be one without a chartered Working Group — is fully confirmed and unusually precise.

**Evidence:** CORE CLAIM CONFIRMED, ONE SPECIFIC REFUTED.

CONFIRMED (primary sources):
1. Announcement date 2025-10-28, version string 2025.10, URL designtokens.org/tr/2025.10/ — all exact.
2. Formal designation is "Final Community Group Report" (28 October 2025). The spec's own status section states verbatim: "This specification is not a W3C Standard nor is it on the W3C Standards Track." Published under the W3C Community Final Specification Agreement. The claim's "stable Community Group Report" is directionally right; the term of art is "Final Community Group Report."
3. Property names $value / $type / $description confirmed, plus $deprecated, $extensions, $extends. Legacy value/type/comment mapping confirmed on styledictionary.com/info/dtcg/.
4. PROCESS NUANCE IS PRECISELY CORRECT — the strongest part of the claim. W3C's Community Group FAQ states "Community Groups and Business Groups themselves do not create W3C standards" and CG Reports are "not standards-track documents but may become input to the standards process." Groups are told not to call their work "standards work" or "draft standards." A Recommendation requires a chartered Working Group; a CG cannot publish to /TR/. The claim's framing ("it reached a stable vendor-neutral CG report = real industry consensus, not a W3C standard") is accurate and more careful than most secondary coverage.
5. Vendor list confirmed in the announcement: Style Dictionary, Tokens Studio, Terrazzo (reference implementations); Penpot, Figma, Sketch, Framer, Knapsack, Supernova, zeroheight (supporting/implementing). All ten named vendors check out. Contributing orgs include Adobe, Amazon, Google, Microsoft, Meta, Salesforce, Shopify.
6. 2025.10 remains the only report with "Stable" status; no newer stable version exists as of 2026-07-15.

REFUTED — "Style Dictionary v5 adopted DTCG 2025.10 as its base format":
This is chronologically impossible. Per the GitHub releases API, Style Dictionary v5.0.0 was published 2025-05-16T17:12:57Z — FIVE MONTHS BEFORE DTCG 2025.10 published on 2025-10-28. v5 predates the spec it supposedly adopted.
- styledictionary.com/info/dtcg/ states first-class DTCG support arrived in v4, and that "the latest format 2025.10 does not have full support yet in Style Dictionary."
- GitHub issue style-dictionary/style-dictionary#1590 "Support for DTCG v2025.10" was created 2025-11-04T16:08:54Z and remains OPEN as of 2026-07-15 (verified via gh api: state=open, closed_at=null), labeled enhancement / high priority / 5.0. Color, Border, Shadow modules complete; Gradient and Duration in progress; Resolver module pending. The issue author explicitly asks whether 2025.10 support constitutes a breaking major release — confirming it did not exist in the codebase at filing.
- Latest npm "latest" dist-tag is 5.5.0 (released 2026-06-21); 2025.10 support is still incomplete in the current shipping version.
- CAUTION: web search surfaces "the default export format is now DTCG JSON" — this is zeroheight's tokens-automation product documentation, NOT Style Dictionary itself. Secondary sources conflate the two.

SOURCING ERROR:
Claimed source https://www.designtokens.org/tr/drafts/format/ is a Draft Community Group Report (built 2026-06-17) that states verbatim: "Do not attempt to implement this version of the specification. Do not reference this version as authoritative in any way." It cannot support assertions about the stable spec. Correct citation is https://www.designtokens.org/tr/2025.10/format/.

PROJECT-RELEVANCE ARGUMENT — NOT A FACTUAL CLAIM, BUT PREMISE UNVERIFIED:
The "irrelevant to this project" conclusion is a design judgment, not a refutable fact. However, its specifics describe code that does not exist. Inspection of /Users/zakariafatahi/50-apps-challenge/Offline-AAC shows: 0 commits (git rev-list --all --count = 0), 0 tracked files, 0 Dart files, no `Prim` class anywhere, no package.json, no node_modules, no *.tokens.json. The repo contains only RESEARCH.md, idea.md, analysis_options.yaml, and research/. The "~30 colors" and "hand-authored abstract final class Prim" are forward projections, not descriptions of a present codebase.
The underlying reasoning is nonetheless sound: DTCG's purpose is cross-tool/cross-role token interchange, and a solo developer has no designer→engineer handoff boundary for it to bridge. Notably, the refuted Style Dictionary detail does not weaken the conclusion — an incomplete, still-open 2025.10 implementation in the current v5.5.0 release strengthens the case against adopting that toolchain at this scale today.

NO MARKETING-AS-RESEARCH HAZARD: this claim contains no efficacy statistics, no participant counts, no readability or color-psychology assertions, and no Flutter API claims. The checked failure modes (unsourced metrics, design folklore, version/API rot, invented specifics, license claims) do not apply — apart from the version-rot error on Style Dictionary, which is exactly failure mode 3 and is the one thing that broke.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "design-tokens-implementation" made this claim, and a design decision depends on it.

CLAIM: The DTCG format reached a stable Community Group Report (2025.10) in Oct 2025 — but it is NOT a W3C Recommendation, and it is irrelevant to this project regardless.
DETAIL: Announced 2025-10-28 as 'first stable version', spec version string 2025.10, at designtokens.org/tr/2025.10/. Uses $value/$type/$description (vs legacy value/type/comment). Supported by Figma, Penpot, Sketch, Framer, Tokens Studio, Style Dictionary v5, Terrazzo, Knapsack, Supernova, zeroheight. CRITICAL PROCESS NUANCE: W3C Community Groups structurally cannot publish Recommendations — that requires a chartered Working Group. So 'did it reach spec?' = it reached a stable *vendor-neutral CG report*, which is real industry consensus but not a W3C standard. Style Dictionary v5 adopted DTCG 2025.10 as its base format. But: DTCG exists to move tokens BETWEEN a design tool and a codebase, i.e. between a designer and an engineer. Here those are the same person. A JSON→Style Dictionary→Dart codegen step for ~30 colors adds a build step, a node_modules, and a generated-file diff review — to solve a handoff problem that does not exist. Hand-authored `abstract final class Prim` is the right answer at this scale.
CLAIMED SOURCES: https://www.w3.org/community/design-tokens/2025/10/28/design-tokens-specification-reaches-first-stable-version/, https://www.designtokens.org/tr/drafts/format/, https://styledictionary.com/info/dtcg/
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: m3.material.io, developer.apple.com, api.flutter.dev, docs.flutter.dev, the actual type foundry, the actual paper.

Hunt for these failure modes, in order of likelihood:
1. **Marketing repeated as research.** Google's M3 Expressive claims (46 studies, 18,000 participants, "4x faster") and Lexend's readability claims are the specific hazards. Did anyone publish a methodology? Is it peer-reviewed, or is it a blog post? If a number has no methodology behind it, SAY SO — a design direction is being justified with it.
2. **Design folklore presented as evidence.** "Autistic people prefer muted colors", "sans-serif is more legible", "the aesthetic-usability effect", color psychology. Find the actual study, check the sample and whether it replicated, and check whether the popular claim matches what the paper found.
3. **Version/API rot.** Flutter lags the Material spec — a spec feature is NOT a Flutter feature. If the claim says Flutter can do something, VERIFY on api.flutter.dev or the release notes. Check whether a named API exists with that exact name.
4. **Invented specifics** — hex values, token names, type sizes, shape counts, font axes, license terms. If it's specific, verify it's real.
5. **License claims** about typefaces or assets. Verify against the actual foundry/repo.

Default to refuted=true if you cannot substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + correction if directionally right but wrong in the specifics. UNVERIFIABLE if nothing settles it — say so plainly rather than guessing.
````

</details>
