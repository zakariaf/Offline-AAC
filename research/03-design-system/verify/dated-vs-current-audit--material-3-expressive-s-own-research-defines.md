# dated-vs-current-audit--material-3-expressive-s-own-research-defines

> Phase: **verify** · Agent `a836dfd8cfeb89d0a` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Use this instead: "Google's M3 Expressive blog names five fundamental parts of expressive design — color, shape, size, motion, containment — and its usability page credits attention and navigation gains specifically to 'color, size, shape, and containment,' omitting motion. The flagship eye-tracking result (a Send button spotted faster when made larger and given secondary-color emphasis) turns on static levers. So a zero-animation constraint is consistent with Google's own account of where expressive usability comes from."

Three things to drop or hedge before this goes in the brief:
- Drop "20% of the expressive toolkit." Google never weights the levers. The number is our own, and stating it as Google's definition is the kind of error this audit exists to catch. Argue "most of the named levers remain available," not a percentage.
- Soften "four of five are static." Shape and containment in M3 Expressive are partly motion-defined (the 35-shape library's premise is that every shape morphs into another). Zero-animation keeps the static readings of those levers, not Google's full sense of them.
- Stop calling this "validated at scale" or "research." It is an unpublished corporate blog post with no methodology, no per-study Ns, and no effect sizes; "4x" and "87%" are "up to" ceilings. Cite it as Google's stated design rationale — which is genuinely useful, since Google's rationale is what a Material-aligned brief needs to align with — not as empirical validation. The design decision is defensible on the qualitative framing alone; it does not need the statistics, and it gets weaker by leaning on them.

**Evidence:** EVERY QUOTED FACT SURVIVED. THE ARITHMETIC BUILT ON TOP OF THEM DID NOT.

VERIFIED VERBATIM (design.google/library/expressive-material-design-google-research):
- "The fundamental parts of expressive design are the use of color, shape, size, motion, and containment." — the five levers are real and named exactly as claimed.
- "46 separate research studies," "hundreds of designs," "more than 18,000 participants from around the world" — exact.
- "participants were able to spot key UI elements up to four times faster in the M3 Expressive designs" — exact.
- "The time it takes to tap on key actions, for example, decreased by seconds" — exact.
- "34% boost in modernity" (claim says "perceived modernity" — immaterial gloss). Also "32% increase in subculture perception," "30% jump in rebelliousness."
- Preference "particularly strong — up to 87% — among 18-to-24-year-olds" — exact, but note "up to."

THE CLAIM'S STRONGEST SUPPORT IS ONE THE RESEARCHER DIDN'T CITE. m3.material.io/foundations/usability/overview states: "M3 Expressive's strategic use of color, size, shape, and containment follows from long-standing design principles and best practices, drawing attention to key elements and helping users navigate more quickly." Google itself attributes the attention/navigation payload to the four non-motion levers, motion excluded from that sentence. The eye-tracking example behind "4x faster" is a Send button made larger with secondary-color emphasis — size plus color, both static. The conclusion is better supported than the researcher's own reasoning for it.

THREE DEFECTS:

1. "20% of the expressive toolkit" IS INVENTED. Google assigns no weight, percentage, or relative contribution to any of the five attributes, and never presents them as a partition of a measured effect. It is a list of five things, not five equal shares. 5 items → "each is 20%" is the researcher's arithmetic wearing Google's authority. Nothing in either source licenses it. Delete the number.

2. "FOUR OF THE FIVE ARE STATIC" IS SHAKY ON TWO OF THE FOUR. Shape in M3 Expressive is substantially *defined* by motion: the 35-shape library's headline property is that "every shape can morph into another in the set." Containment in M3 Expressive is heavily expressed through animated container transforms. Under zero-animation you keep static shape and static containment, but you are not keeping what Google means by those levers. The static/animated split is not a clean 4/1.

3. THE WHOLE EVIDENCE BASE IS AN UNPUBLISHED MARKETING BLOG POST. This is the fact-check's main finding and it applies to the claim's own citations. There is no paper, no preprint, no peer review, no protocol, no per-study sample sizes, no effect sizes, no confidence intervals, no breakdown of which of the 46 studies produced which number. The only external citation on the page is Caleb Warren et al. (2019) on product desirability — unrelated to these results. "Up to four times faster" and "up to 87%" are ceiling figures from unspecified subsets, not mean effects; "decreased by seconds" has no baseline. None of it is falsifiable as published. "Validated at scale" in the claim's DETAIL overstates what a corporate design blog with no methodology can establish — 18,000 participants you cannot audit is a large number, not evidence.

CAVEAT ON "THE FIVE": the list is not a closed taxonomy. The same usability page gives a non-exhaustive variant — "design tactics like containment, size, shape, color, and typography" — which drops motion and adds typography. "Five levers" is a phrasing in one blog paragraph, not a canonical spec.

NOT CHECKED: no Flutter API claim was made, so no api.flutter.dev verification was required. Note that m3.material.io is JS-rendered and returns titles only to direct fetch; the usability-page quotes above come via search-engine extraction of that page, a slightly weaker chain than the design.google quotes, which I pulled directly.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dated-vs-current-audit" made this claim, and a design decision depends on it.

CLAIM: Material 3 Expressive's own research defines expressiveness as five levers — color, shape, size, motion, containment — and FOUR of the five are static. The zero-animation constraint costs you 20% of the expressive toolkit, not 100%
DETAIL: Google ran 46 separate research studies with hundreds of designs and 18,000+ participants. Reported results: participants spotted key UI elements up to 4x faster in M3 Expressive designs vs standard M3; time-to-tap on key actions decreased by seconds; 34% boost in perceived modernity; 87% preference among 18-24s. The five named attributes of expressive design are color, shape, size, motion, and containment. This is the single most useful finding for this brief: 'beauty must come from composition, type, color, material, craft' is not a compromise position — it is 4/5 of Google's own definition of expressive, validated at scale.
CLAIMED SOURCES: https://design.google/library/expressive-material-design-google-research, https://m3.material.io/blog/building-with-m3-expressive
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
