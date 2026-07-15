# a11y-testing--breaking-current-containssemantics-is-deprec

> Phase: **verify** · Agent `a0b49f62c658645e2` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction needed to any load-bearing element. Two optional refinements: (a) the exact named-parameter count is 83 for isSemantics and 82 for containsSemantics, not "~85" — the claim's tilde hedge makes this immaterial; (b) worth adding for the researcher's purposes: migration is automatable via `dart fix --apply`, and matchesSemantics' strictness applies only to boolean flag/action fields — label, hint, value, textDirection, and rect are still excluded from comparison when omitted, exactly as the claim states.

**Evidence:** Every load-bearing element verified against primary sources; attempted refutation failed on all points.

1. DEPRECATION + VERSION — CONFIRMED. api.flutter.dev/flutter/flutter_test/containsSemantics.html carries the notice verbatim as claimed: "Migrate to isSemantics instead. This feature was deprecated after v3.40.0-1.0.pre." Independently corroborated by docs.flutter.dev/release/breaking-changes, which lists "Deprecate containsSemantics in favor of isSemantics" under "Released in Flutter 3.41", and by the dedicated migration guide (deprecate-contains-semantics): "Landed in version: 3.40.0-1.0.pre; In stable release: 3.41". Stable is 3.44.0, so the deprecation is live in current stable. No version rot.

2. DELEGATION — CONFIRMED. containsSemantics forwards all parameters to isSemantics without modification.

3. matchesSemantics NOT DEPRECATED — CONFIRMED. No deprecation notice on its API page. The migration guide affirmatively positions matchesSemantics as the surviving exact-matcher counterpart to isSemantics, not as deprecated. This was the point most likely to be wrong (plausible error: assuming both matchers were deprecated together); it survives scrutiny.

4. API SIGNATURES — CONFIRMED. All 24 named parameters enumerated in the claim verified present on isSemantics, including the more LLM-plausible-sounding ones that were prime hallucination candidates: hasFocusAction, onTapHint, onLongPressHint, traversalParentIdentifier, and List<Matcher>? children. No invented names.

5. PARTIAL vs STRICT — CONFIRMED, and stated more precisely than required. Migration guide: partial matchers (isSemantics) "match only the properties explicitly provided. Any arguments not provided are ignored." Exact matchers (matchesSemantics) "verify all values. Any arguments not provided are expected to match the object's default values." isSemantics doc: "There are no default expected values, so no unspecified values will be validated." The claim's specific framing — that flags/actions default to false-expected — matches matchesSemantics' own doc exactly: "If either the label, hint, value, textDirection, or rect fields are not provided, then they are not part of the comparison. All of the boolean flag and action fields must match, and default to false." A sloppier claim would have said matchesSemantics is strict about all fields; this one correctly scopes strictness to flags/actions.

MINOR IMPRECISION (non-material): claim says "~85 named params". Actual: 83 for isSemantics, 82 for containsSemantics. The "~" hedge covers this; insufficient to downgrade to PARTIALLY_TRUE.

UNSOURCED EDITORIALIZING (non-material): "virtually every tutorial/blog predates it" is unfalsifiable rhetoric rather than a sourced fact, though directionally plausible for a deprecation this recent. Not load-bearing for the project decision.

BONUS FINDING not in the claim: automated migration is available via `dart fix --apply`, per the migration guide.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "a11y-testing" made this claim, and a project decision depends on it.

CLAIM: BREAKING/CURRENT: containsSemantics is deprecated after v3.40.0-1.0.pre; use isSemantics. matchesSemantics is NOT deprecated.
DETAIL: api.flutter.dev for containsSemantics states: 'Migrate to isSemantics instead. This feature was deprecated after v3.40.0-1.0.pre.' Its implementation now just delegates every parameter to `isSemantics()`. Since stable is 3.44.0, this deprecation is live and virtually every tutorial/blog predates it. Semantics: `isSemantics(...)` = partial match, only what you specify is checked. `matchesSemantics(...)` = strict, unspecified flags/actions default to false-expected (so it fails if the node has an extra flag you didn't declare). Both take ~85 named params including label, value, hint, identifier, isButton, isEnabled, hasEnabledState, isFocusable, isFocused, isTextField, isHidden, isImage, isHeader, isLink, hasTapAction, hasLongPressAction, hasFocusAction, onTapHint, onLongPressHint, customActions, rect, size, textDirection, and `List<Matcher>? children`.
CLAIMED SOURCES: https://api.flutter.dev/flutter/flutter_test/containsSemantics.html, https://api.flutter.dev/flutter/flutter_test/isSemantics.html, https://api.flutter.dev/flutter/flutter_test/matchesSemantics.html
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
