# brand-identity-voice--google-play-semantically-indexes-the-full-4

> Phase: **verify** · Agent `ad5af617d4af393ec` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Keep the Apple half — it is correct and primary-sourced. Discard the Play half's operative conclusion.

Corrected version: Apple indexes Title, Subtitle, the 100-char Keywords field, AND primary category (plus company name is searchable); the App Store description and promotional text are conversion copy and are not indexed — Apple says so explicitly. Google Play does use title, short description, and full description as relevance signals, but they are hierarchically weighted, not a flat ~4,110-char pool: the title carries the most ranking weight of any field, short description is second, and the long description contributes topical context and disambiguation rather than primary rank.

The design consequence inverts. For an Android-first AAC app you SHOULD get your highest-value term into the 30-char name — e.g. "Sprocket: AAC Speech Board" rather than "Sprocket" — because that is the strongest lever you have, and it is the one thing all three of the researcher's own sources agree on. Put the second-tier term in the 80-char short description. Then write the honest 4,000-char prose with "selective mutism," "non-speaking," "autistic shutdown," "meltdown," "sensory overload," "text to speech," "situational mutism" — that prose IS worth writing and Play will use it, just as supporting context rather than as a substitute for the name.

Note the naming decision is not purely an ASO question: "AAC" in the title also serves recognition for the parents, SLPs, and educators who search that exact term, which is an independent argument for including it.

Two framings to drop: (1) "semantic indexing" as a documented Google mechanism — Google documents only synonym matching and query-intent detection, and has never published field-level weights, so no confident mechanism claim is available here; (2) "high confidence" on any of this, since it rests entirely on ASO-vendor content marketing with no primary sourcing and no published methodology. Confidence on the Play-side specifics should be LOW; confidence on the Apple side can remain HIGH because Apple documents it directly.

One correction upward: keyword-stuffing on Play is not merely "counterproductive" — Google Play policy states it can result in app suspension. That is an enforcement risk, which matters more for a small accessibility app with no appeals leverage.

**Evidence:** APPLE HALF — CONFIRMED against primary source. developer.apple.com/app-store/search/ states verbatim: "Search results are based on a number of factors, including text relevance (matches for your app's title, subtitle, keywords, and primary category), as well as user behavior (downloads, ratings and reviews, and more)." The description is absent. developer.apple.com/app-store/product-page/ independently corroborates: "Don't add unnecessary keywords to your description in an attempt to improve search results" and "promotional text doesn't affect your app's search ranking so it should not be used to display keywords." The claim's Apple half stands.

CHARACTER LIMITS — CONFIRMED. Play Console Help (support.google.com/googleplay/android-developer/answer/9859152) confirms app name 30, short description 80, full description 4,000.

GOOGLE HALF — DIRECTIONALLY RIGHT, SPECIFICS REFUTED. Google does use the description as a relevance signal: support.google.com/googleplay/android-developer/answer/9958766 says "metadata (for example, title, description, category) and other signals are used to determine which apps best address the user's query." So the description is not dead weight. But three specifics fail:

1. FLAT-POOL FALLACY. "~4,110 indexable chars" implies the three fields form one equally-weighted keyword pool. No source supports this. The claim's OWN cited source (appfollow.io/blog/google-play-aso-keywords) states the opposite: "Your title carries more ranking weight than any other metadata field" and "Lead with your most important keyword whenever possible. Position matters." The second cited source (jenli.net) likewise says Google "indexes title and short description as primary signals" while the full description merely "provides additional topical context." Fields are weighted hierarchically, not pooled.

2. THE OPERATIVE CONCLUSION IS REFUTED BY ITS OWN CITATIONS. "You do NOT need 'AAC' or 'nonverbal' in the name to rank for them" is the sentence the design decision rests on, and every cited source contradicts it. Title is the single highest-weight Play field.

3. "SEMANTIC/NLP INDEXING" IS UNSOURCED MECHANISM LANGUAGE. No Google primary source uses "NLP" or "semantic indexing." Google documents only synonym identification ("identifying other words, such as synonyms") and query-intent detection (specific app vs. category). That is materially weaker than "write honest prose containing these seven phrases and Google will index it." Google has never published field-level indexing weights or confirmed full-4,000-char semantic parsing; the mechanism claim has no published methodology behind it.

SOURCING FAILURE (failure mode #1 — marketing repeated as research). All three cited sources are ASO vendors/consultants publishing content marketing for ASO products (AppFollow and ASOMobile sell ASO tooling). Not one primary source is cited for a claim rated "high confidence." The one assertion the vendors agree on — title weighting — is the one the researcher discarded.

MINOR: Apple's indexed-field enumeration in the claim is incomplete. Primary category is also indexed ("your app's title, subtitle, keywords, and primary category"), and developer/company name is searchable. Not just "Title, Subtitle, Keywords."

WHAT SURVIVES INTACT: Apple does not index the description; Play does use description text as a signal; keyword-stuffing is counterproductive — and understated, since Google Play policy says repetitive/irrelevant keyword use "can result in an app being suspended on Google Play," an enforcement risk, not just a ranking penalty.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "brand-identity-voice" made this claim, and a design decision depends on it.

CLAIM: Google Play semantically indexes the full 4,000-char long description; Apple indexes no description at all
DETAIL: Google Play indexes title (30), short description (80), and long description (4,000) — ~4,110 indexable chars — using NLP/semantic indexing. Apple indexes only Title, Subtitle, and the hidden 100-char Keywords field; the App Store description is conversion copy only, never indexed. Consequence for an Android-first app: you do NOT need 'AAC' or 'nonverbal' in the name to rank for them. Write honest prose containing 'selective mutism', 'non-speaking', 'autistic shutdown', 'meltdown', 'sensory overload', 'text to speech', 'situational mutism' and Google will index it. Keyword-stuffing is unnecessary and counterproductive under semantic indexing.
CLAIMED SOURCES: https://appfollow.io/blog/google-play-aso-keywords, https://asomobile.net/en/blog/aso-in-2026-the-complete-guide-to-app-optimization/, https://jenli.net/tpost/atx9hpv6n1-app-store-and-google-play-metadata-writi
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
