# tile-grid-design--filled-coloured-tiles-are-not-the-kid-aac-si

> Phase: **verify** · Agent `af5cf889d82df5f7f` · Run `wf_f237e8a6-694`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** Apple Shortcuts does not refute the fill hypothesis, and it is not structurally the same product. Correct statement: "Solid-filled coloured tiles appear in mainstream adult software (Apple Shortcuts), so fill alone is not sufficient to read as childish." It does NOT follow that fill is exonerated as a contributing factor, because Shortcuts differs from this app on every variable that would modulate fill's effect: tile count (a handful vs. a dense 50-100+ cell vocabulary page), colour semantics (15 user-chosen decorative swatches with no meaning vs. the Modified Fitzgerald Key, where hue encodes part of speech), and authorship (self-named actions vs. prescribed labels). Additionally, the claim mislabels "the 12-different-hues rainbow" as an infantilizing variable — it is the Modified Fitzgerald Key, an established AAC convention used with adults in which colour carries grammatical information. Removing it on the strength of a Shortcuts analogy (where colour is meaningless) would delete a functional code. Separately: the cited AssistiveWare page contains nothing about Shortcuts, fill, colour, or label alignment and does not support any part of the claim; Apple publishes no specification of Shortcuts tile anatomy (icon placement, label alignment, fill) in the HIG or its support docs, so the "icon top-left / left-aligned label bottom-left" specifics are observational only; and Apple's iOS 26 Liquid Glass direction moves system surfaces toward translucency, undercutting the use of Apple as an authority for solid fill.

**Evidence:** THE CITATION SUPPORTS NOTHING IN THE CLAIM.

The single claimed source — https://www.assistiveware.com/support/proloquo2go/organize/buttons/buttons-actions — was fetched. It contains ZERO mention of Apple Shortcuts, tile fill, colour, rounded corners, label alignment, or grid tile visual design. It is a functional how-to listing Proloquo2Go button actions ("Add Text to Message", "Speak Text Immediately", "Open Folder", etc.) and how to reach them via Edit Mode > On Tap / On Secondary Trigger. It cannot support a claim about Apple Shortcuts' tile anatomy, and it cannot support a claim about what is or is not the "kid-AAC signature." The claim is, in practice, uncited.

APPLE PUBLISHES NO SPEC FOR THE TILE ANATOMY BEING ASSERTED.

I checked Apple primary sources for the specific anatomy ("icon top-left and a LEFT-ALIGNED label bottom-left"):
- https://support.apple.com/guide/shortcuts/change-the-layout-apd873475724/ios — confirms only "By default, the Shortcuts app displays shortcuts in a grid view, in the order you create them," plus a grid/list toggle. It describes NO tile appearance, NO icon placement, NO label positioning.
- https://support.apple.com/guide/shortcuts/modify-shortcut-icons-apd5ad5a2128/ios — confirms shortcuts "display a shortcut icon and one of 15 colors" and that the user taps a colour swatch and a glyph. No statement about fill, corner radius, or label placement.
- The Human Interface Guidelines (developer.apple.com/design/human-interface-guidelines/) contain no Shortcuts tile-anatomy specification.

So the anatomy is an observational description, not a sourced one. It is roughly right for the app as commonly seen, but it is asserted with a precision ("LEFT-ALIGNED label bottom-left") that no primary source establishes — and it is asserted at a moment when the surface is in flux: Apple's June 2025 Liquid Glass redesign (https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/, https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass) explicitly moves system surfaces to a translucent material that "reflects and refracts its surroundings." A claim whose entire force is "Apple ships SOLID FILL, therefore solid fill is adult" is resting on the one property Apple has spent a release cycle moving away from. Notably, Apple's own tile-fill API surface is opt-in and conditional: NSAppIconComplementingColorNames takes an array of colour names, with a *single* entry being the case that renders a solid fill — i.e. solid fill is one configuration, not the platform's design position.

THE LOAD-BEARING PREMISE — "STRUCTURALLY THE SAME PRODUCT" — IS FALSE.

This is where the argument dies, independent of the citation problem. Three structural differences, each of which is exactly the variable under dispute:

1. DENSITY. A Shortcuts grid holds a handful to a few dozen user-authored tiles. An AAC core-word page is a dense prescribed vocabulary grid — Proloquo2Go's Crescendo vocabulary ships pages well into the dozens-to-100+ cells. Fill behaves nonlinearly with density: six saturated tiles read as organized; eighty-four saturated tiles read as a rainbow field. "Apple ships filled tiles" at n=6 says nothing about fill at n=84. The claim silently transports a property across an order of magnitude of density.

2. COLOUR SEMANTICS — AND THIS INVERTS THE CLAIM'S OWN LIST. Shortcuts colour is user-chosen from 15 swatches and carries NO meaning; Apple documents it as pure personalization. AAC colour is the Modified Fitzgerald Key — a clinical convention where hue ENCODES part of speech (green/verbs, orange/nouns, yellow/pronouns, blue/adjectives, purple/questions, pink/prepositions-social, red/negation-urgent, white/conjunctions, brown/adverbs, grey/determiners). The claim lists "the 12-different-hues rainbow" as an infantilizing variable to be removed. That is backwards: the multi-hue grid is a functional grammar code used with adult AAC users, not decoration. The claim proposes stripping the one element that is doing linguistic work while keeping fill, on the authority of a product where colour means nothing. The Shortcuts analogy actively misleads here — it licenses exactly the wrong deletion.

3. AUTHORSHIP AND THE "label != vocalization" EQUIVALENCE. In Shortcuts the label is the user's OWN name for their own action; there is no representational mismatch, because the user authored both sides. The claim's parenthetical treats "a short label fronts a hidden multi-step action" as "precisely" the AAC case, but in AAC the label is typically the word that is spoken, and where it diverges, the divergence is imposed on the user by a vocabulary designer, not chosen. Self-authored labels and prescribed labels are not the same anatomy; they differ in who bears the interpretive cost.

THE ARGUMENT FORM IS ALSO INVALID.

"Nobody describes Shortcuts as childish" is an argument from absence, not evidence. And "fill is exonerated" does not follow even if every premise held: showing that one adult product uses filled coloured tiles shows that fill is not SUFFICIENT for reading as childish. It cannot show fill is not CONTRIBUTORY — which is what "exonerated" asserts and what the design decision needs. Fill could be a perfectly innocent variable at n=6/no-semantics/self-authored and a compounding one at n=84/Fitzgerald-coded/prescribed. The claim needs the strong reading and has only earned the weak one.

Finally, the appeal to "what the prior research already concluded ('the enemy is cartoon avatars and parental gates — not saturation')" is the corpus citing itself. That is not independent corroboration; it is the same claim wearing a second hat.

WHAT SURVIVES: the narrow, weak reading — "filled coloured rounded tiles are not by themselves a kid-AAC tell, since mainstream adult productivity software uses them" — is directionally defensible and worth keeping. Everything the claim adds on top of that ("refutes it directly", "structurally the same product", "fill is exonerated", and the demotion of Fitzgerald colour-coding to an infantilizing variable) is unsupported, and one part of it is affirmatively wrong.

CONFIDENCE NOTE: the researcher's stated "medium" confidence is too high for the conclusion drawn and roughly right for the observation underneath it.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "tile-grid-design" made this claim, and a design decision depends on it.

CLAIM: Filled, coloured tiles are NOT the kid-AAC signature — Apple Shortcuts refutes it directly, and it is structurally the same product as this app
DETAIL: Shortcuts is a grid of solid-filled, coloured, rounded tiles, each with an icon top-left and a LEFT-ALIGNED label bottom-left, where a short label fronts a hidden multi-step action. That is precisely this app's tile anatomy (label != vocalization) and precisely its surface (a grid of coloured rectangles). It is a mainstream adult productivity product and nobody describes it as childish. Therefore the infantilizing variables are elsewhere: (1) centering everything, (2) high saturation, (3) the 12-different-hues rainbow, (4) the symbol set, (5) the vocabulary — which is exactly what the prior research already concluded ('the enemy is cartoon avatars and parental gates — not saturation'). Fill is exonerated.
CLAIMED SOURCES: https://www.assistiveware.com/support/proloquo2go/organize/buttons/buttons-actions
CONFIDENCE: medium

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
