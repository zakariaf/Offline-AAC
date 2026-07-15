# dated-vs-current-audit--the-brief-s-date-is-wrong-proloquo-shipped-2

> Phase: **verify** · Agent `aceb2d55905fb1265` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Three corrections. (1) The vocabulary dataset is "anonymous word usage data from TENS OF THOUSANDS of AAC users" (AssistiveWare's wording), not "10,000+". The "10,000+" figure is the newsletter-signup subscriber count on the same page — a marketing metric, not a research sample. Neither figure has any published methodology, sample frame, or peer review; do not cite either as evidence. (2) Apple gave NO vocabulary/cultural-sensitivity rationale. Apple's entire newsroom text is: "An accessibility app pioneer for over a decade, AssistiveWare's Proloquo is creating augmentative and alternative communication (AAC) tools that help the world communicate in new ways." The vocabulary framing is AssistiveWare's own, and the bread/carbs example comes from a separate blog post that never mentions the award. (3) "Won for vocabulary, not visual design" is unsupported in both directions: AssistiveWare's award blog leads with design quotes and its press release cites "intuitive design," while Apple's Cultural Impact category is for societal impact and was never presented as a design award. The defensible version of the audit: Proloquo shipped 2022 and won the 2023 App Store Award for Cultural Impact (first AAC app to do so, per AssistiveWare); Apple published no substantive rationale; AssistiveWare's own retrospective framing mixes design, vocabulary, and impact; and AssistiveWare publishes no hex codes, type specimens, or design-system documentation — only end-user customization docs. That last point alone carries the "never contested on looks" implication. The award analysis does not.

**Evidence:** CONFIRMED against primary sources:
1. Release year 2022 — AssistiveWare's award blog references "a few weeks before we officially released Proloquo" re: February 2022.
2. 2023 App Store Award for Cultural Impact — confirmed on Apple's own newsroom (Proloquo listed among five Cultural Impact winners alongside Pok Pok, Too Good To Go, Unpacking, Finding Hannah) AND on AssistiveWare's blog and press release (all three claimed URLs resolve with real content).
3. "First AAC app with this recognition" — AssistiveWare's own wording; self-asserted, not independently verified by Apple.
4. Eleonora, Design Lead, autistic, quoted exactly: "The goal was to design an interface that is not only functional but also beautiful and up-to-date." VERBATIM MATCH.
5. Rikako, UX Designer: "Our focus was to provide a simple and seamless user experience that hides the complexity and reveals what you need when you need it." Matches the claim's paraphrase.
6. Bread/carbs example is REAL: foods grouped by food group rather than meal, "as not everyone eats bread for breakfast," because breakfast varies by culture.
7. NO PUBLISHED DESIGN SYSTEM — survives adversarial search. Targeted queries for AssistiveWare hex codes, type specimens, color palette, typography, and design-system docs return only end-user customization support pages (change button appearance, color code page background, light/dark mode). The /crescendo page publishes feature counts (4,750 unique words, 7,250 pre-categorized, 20,000+ SymbolStix symbols) but no design tokens. This part of the claim stands.

REFUTED / CORRECTED — two load-bearing specifics:

A) "10,000+ AAC users" IS A CONFLATED MARKETING NUMBER. AssistiveWare's vocabulary blog states the vocabulary was built on "anonymous word usage data from TENS OF THOUSANDS of AAC users" — combining Proloquo2Go (symbol-based) and Proloquo4Text (text-based) users, plus general-education curricula from multiple countries. The string "10,000+" DOES appear on the award blog page — but in the NEWSLETTER SIGNUP WIDGET ("10,000+ AAC users, professionals, parents, and educators"), i.e. a mailing-list subscriber count. The researcher transplanted a marketing subscriber figure into the research dataset by page proximity. Neither figure carries any methodology: no sample frame, no cohort definition, no peer review, no citation. The /crescendo page's only research reference is "the research-based Intermediate Core and Advanced Core levels" with no citation, methodology, or dataset. This is marketing repeated as research.

B) APPLE NEVER GAVE THE CLAIMED RATIONALE. The claim asserts "Apple's AND AssistiveWare's own framing of WHY it won is about the Crescendo Evolution vocabulary... and about cultural/religious sensitivity." Apple's newsroom entry is one generic sentence in full: "An accessibility app pioneer for over a decade, AssistiveWare's Proloquo is creating augmentative and alternative communication (AAC) tools that help the world communicate in new ways." Apple mentions no vocabulary, no Crescendo, no bread/carbs, no cultural or religious categorization. The vocabulary framing is AssistiveWare's alone.

C) THE BREAD/CARBS EXAMPLE IS NOT AN AWARD RATIONALE. It appears in a separate post (designing-a-comprehensive-and-inclusive-vocabulary-for-proloquo) that NEVER MENTIONS THE AWARD. The award blog does not contain the bread example at all. The claim calls it "the cited example" for why it won; no source cites it for that.

D) THE "DESIGN AWARD'S CLOTHES" FRAMING INVERTS THE EVIDENCE. The claim says it won "for vocabulary/cultural sensitivity, NOT visual design." But AssistiveWare's own award blog leads with DESIGN quotes (Eleonora on beautiful/up-to-date, Rikako on hiding complexity), and the press release explicitly cites "intuitive design" plus "a comprehensive and diverse set of words." CEO David Niemeijer's quote is generic impact language. Apple's Cultural Impact category is defined as recognizing apps that "made a significant impact on culture and society" — it is neither a design award nor a vocabulary award. Nobody dressed it as a design award, so there are no design-award clothes to remove. The strongest available reading is that AssistiveWare's own framing is MIXED (design + vocabulary + impact), and Apple's framing is CONTENTLESS.

NET: The audit's factual spine (dates, award, category, quotes, absence of design-system documentation) is sound. The analytical claim built on top of it — that Apple framed the award around vocabulary ethics, evidenced by a bread example, grounded in a 10,000-user dataset — is not supported by any of the three cited sources. The IMPLICATION ("the bar for best-looking AAC app has never been contested on looks") SURVIVES, but on a different basis than the researcher's: it rests on finding (7), the genuine absence of any published design system, NOT on the award analysis. Do not carry the 10,000 figure or the Apple-framing attribution into the brief.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dated-vs-current-audit" made this claim, and a design decision depends on it.

CLAIM: The brief's date is wrong: Proloquo shipped 2022 and won the 2023 App Store Award for Cultural Impact — and it won for vocabulary/cultural sensitivity, not visual design
DETAIL: AssistiveWare released Proloquo in 2022; it earned the 2023 App Store Award for Cultural Impact, the first AAC app to do so. Apple's and AssistiveWare's own framing of WHY it won is about the Crescendo Evolution vocabulary built on anonymous data from 10,000+ AAC users, and about cultural/religious sensitivity in categorization — the cited example is that bread is filed under 'carbs' rather than 'breakfast foods' because not everyone eats bread for breakfast. Design Lead Eleonora (an autistic designer) is quoted saying 'The goal was to design an interface that is not only functional but also beautiful and up-to-date,' and UX Designer Rikako on hiding complexity — but AssistiveWare publishes no hex codes, type specimens, or design system documentation anywhere I could find. The award is a vocabulary/ethics award wearing a design award's clothes. IMPLICATION: the bar for 'best-looking AAC app' has never actually been contested on looks. That is an opening, not a threat.
CLAIMED SOURCES: https://www.assistiveware.com/blog/proloquo-winner-cultural-impact-app-store-award, https://www.assistiveware.com/press-releases/proloquo-wins-2023-app-store-award, https://www.apple.com/newsroom/2023/11/apple-unveils-app-store-award-winners-the-best-apps-and-games-of-2023/
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
