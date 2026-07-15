# m3-expressive-deep--the-material-library-is-frozen-and-being-ext

> Phase: **verify** · Agent `affde0d0c3b7c2da1` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The freeze and the eventual extraction are real and accurately described — but two framing claims are wrong.

(1) The freeze is not why M3E stalled. M3E was paused May 14, 2025 (#168813), eleven months before the April 7, 2026 freeze, originally citing design-consistency and rollout planning — not decoupling. Decoupling was only "re-evaluated" in June 2025 and adopted in July 2025, partly IN RESPONSE to architecture problems the M3 migration exposed. The freeze is a downstream milestone of decoupling, not the cause of the stall. Decoupling is a fair description of what currently blocks M3E; the freeze (#184093) is not.

(2) It is not a live migration risk for an app starting today. Per the same sources: the freeze binds contributors only; "nothing should change for you"; app developers "can stop reading now. This won't affect you… yet"; deprecation no earlier than the stable after 3.44; removal "not within the next year or so"; no ship date for the replacements. Score it as a deferred, first-party-managed migration on a 1+ year runway, not a current risk.

(3) Canonical development home is the flutter/packages repo, not pub.dev (pub.dev is distribution).

(4) Drop the 3.44.0 release notes as a source — they say nothing about the freeze, the packages, or M3E, and still ship pre-cutoff Material work.

Practical inversion for the design decision: the real constraint is not migration urgency but M3E unavailability. Material 3 Expressive is not in Flutter today, has no announced ship date, and its arrival is gated behind material_ui shipping. Any design direction assuming in-SDK Expressive widgets is the thing that's actually blocked.

**Evidence:** Every verifiable specific in DETAIL checks out verbatim against primary sources; the two framing claims do not.

CONFIRMED verbatim from flutter/flutter#184093 ("[Decoupling] Material and Cupertino are now frozen. Resume contributions in flutter/packages"):
- "For now nothing should change for you and Material and Cupertino should continue working as usual"
- "Some time after the 3.44 stable release, the new material_ui and cupertino_ui packages will be available"
- "we don't anticipate removing the old code within the next year or so"
- Freeze begins at the 3.44 stable cutoff, April 7th; stable expected May 2026. Exceptions allowed via `override: code freeze` label.

CONFIRMED from the Flutter blog ("Flutter's Material and Cupertino code freeze", Justin McCandless):
- "The old Material and Cupertino code will be deprecated in the stable release *after* 3.44 and deleted some time after that."
- "If you write Flutter apps or plugins, but don't contribute to Material or Cupertino itself, you can stop reading now. This won't affect you… yet."

CONFIRMED from pub.dev/packages/material_ui: v0.0.1, publisher flutter.dev (verified), published ~4 months ago, README "Coming soon", and "Once landed and published, look forward to updates from Material 3 Expressive!"

CONFIRMED: Flutter 3.44.0 stable announced May 20, 2026, alongside Google I/O 2026.

FAILURE 1 — causal inversion (the load-bearing error). Claim: the freeze is "the reason M3E work stalled." Issue #168813 ("Bring Material 3 Expressive to Flutter") opened May 14, 2025 — eleven months BEFORE the April 2026 freeze — with the team stating they were "not actively developing Material 3 Expressive" and "will not be accepting contributions for Expressive features or updates at this time," citing the need to "align with a consistent design pattern and a planned rollout." Decoupling was NOT the reason at that point: on June 10, 2025 the team was still only "re-evaluating the long-requested idea of moving the Material and Cupertino libraries out of the core framework" in response to architecture concerns raised during the M3 migration. Decoupling became the stated path only on July 29, 2025. The arrow runs the other way: M3 migration problems motivated decoupling; the freeze is a late milestone of that project, not the cause of a stall that predates it by a year.

FAILURE 2 — "live migration risk for any app starting today" contradicts the sources cited for it. The freeze binds contributors, not consumers. Nothing is deprecated in 3.44; deprecation lands no earlier than the stable AFTER 3.44; removal "not within the next year or so"; the replacement packages have no ship date. A migration is eventually certain for anyone wanting Material updates, but it is deferred, long-runway, and first-party-managed — not live.

PRECISION ERRORS:
- "Canonical home becomes two pub.dev packages" — the canonical development home is the flutter/packages REPO; pub.dev is the distribution channel.
- Cited source docs.flutter.dev/release/release-notes/release-notes-3.44.0 does NOT support the claim: it contains no mention of the decoupling, the freeze, material_ui, cupertino_ui, or Material 3 Expressive, and no Material/Cupertino deprecations. It still ships new Material work that landed before the cutoff (RoundedSuperellipseInputBorder #177220, MenuAnchor animations #176494, CupertinoMenuAnchor #182036, infinite carousel #175710). One of three claimed sources is non-supporting.

No fabrication detected; no marketing-statistic or folklore hazard present in this claim. The researcher's stated CONFIDENCE: high is warranted for the facts and unwarranted for the two inferences drawn from them.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "m3-expressive-deep" made this claim, and a design decision depends on it.

CLAIM: The Material library is frozen and being extracted from the Flutter SDK — the reason M3E work stalled, and a live migration risk for any app starting today.
DETAIL: flutter/flutter#184093: as of 2026-04-07 (the 3.44 cutoff) all contributions to Material and Cupertino in flutter/flutter are frozen. Canonical home becomes two pub.dev packages, material_ui and cupertino_ui. Flutter 3.44 stable shipped May 2026 (Google I/O 2026). New packages ship 'some time after the 3.44 stable release' — no date. In-SDK copies get a long deprecation window: deprecated in the stable release after 3.44, deleted later, 'not within the next year'. Team reassurance: 'For now nothing should change for you and Material and Cupertino should continue working as usual before and after the freeze.' material_ui on pub.dev is v0.0.1, publisher flutter.dev (verified), published ~4 months ago, README says 'Coming soon' and 'Once landed and published, look forward to updates from Material 3 Expressive!'
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/184093, https://pub.dev/packages/material_ui, https://docs.flutter.dev/release/release-notes/release-notes-3.44.0
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
