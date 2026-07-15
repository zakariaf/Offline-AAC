# project-structure--feature-first-is-a-poor-fit-for-this-app-bec

> Phase: **verify** · Agent `ab0ec2d217584c4bd` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The quotes are accurate, but they do not support the conclusion. Two specific corrections:

1. Bizzotto attributes the "unbalanced" structure to mixing feature-first (presentation) with layer-first (everything else) — "I cornered myself into a layer-first approach for the remaining layers" — not to models/repositories being genuinely shared. Shared models were the symptom of slicing by page.

2. His fix is to "organize the project structure around the domain layer." A shared data model is the precondition for his approach, not a disqualifier. For this app that means features named `boards`, `buttons`, `settings` (the domain entities), each owning its models and repository, with speak/show/edit as presentation inside them — not four widget folders plus a giant shared/. He explicitly allows one feature to depend on another ("code inside a given feature to depend on code from a different feature") and warns against `shared`/`common` dumping grounds, so the predicted "nearly all non-widget code lands in shared/" is an artifact of slicing by page, which is the very mistake he recounts.

The defensible version of the claim: "Feature-first organized around SCREENS (speak/show/edit) is a poor fit — that's Bizzotto's own documented mistake. Feature-first organized around DOMAIN MODELS (boards/buttons/settings) is what he actually recommends." If the team wants to justify a flat or layer-first structure, that decision must rest on the app's small size, not on this article — and the "single-page app, one folder" line does not apply to a four-surface app with a database, repository, and speech service.

**Evidence:** All three quotes are accurate and the article (https://codewithandrea.com/articles/flutter-project-structure/) is live, unretracted, and still Bizzotto's canonical piece on the topic. Verified verbatim:

1. "a feature is a functional requirement that helps the user complete a given task" — CONFIRMED.
2. He does describe his own product_page / products_list / leave_review_page structure as "unbalanced" — CONFIRMED that the word and the example exist.
3. "Of course, if we're building just a single-page app, we can put all files in one folder and call it a day." — CONFIRMED verbatim.

But the load-bearing inference — "feature-first is a poor fit BECAUSE features are surfaces over one shared data model" — is not what the source says, and is close to the opposite.

(a) MISATTRIBUTED CAUSE. The claim says the structure was unbalanced "because models and repositories were genuinely shared." Bizzotto gives a different reason in his own words: "I had applied a feature-first approach to the `features` folder, which represented my entire presentation layer. But I cornered myself into a layer-first approach for the remaining layers." The root cause he names is mixing paradigms across layers — feature-first for presentation, layer-first for everything else. Shared models were a symptom of slicing by page, not the diagnosis.

(b) THE PRESCRIPTION IS THE EXACT FIX FOR THIS APP'S SITUATION. His remedy: "I decided to organize the project structure around the domain layer." Features are identified by what the user does, over domain entities — not by screens. The claim's premise (speak/show/edit/settings all operate on boards/buttons/grid_slots/settings) is precisely the input Bizzotto's method consumes: those are domain models, so the features would be `boards`, `buttons`, `settings`, each owning its own repository/models, with speak/show/edit living as presentation inside them. The claim applies his page-first anti-pattern (speak/show/edit ARE surfaces/pages) and then blames feature-first for the resulting mess.

(c) THE "EVERYTHING LANDS IN shared/" STEP IS INVENTED. Bizzotto explicitly permits cross-feature dependency rather than forcing extraction: "with this approach is still possible for code inside a given feature to depend on code from a different feature." In his eCommerce structure the products repository lives inside the `products` feature; orders and reviews depend on it — it is not hoisted into a top-level shared/. He separately warns against `shared`/`common` folders becoming dumping grounds, i.e. the article treats the claim's predicted outcome as a mistake to avoid, not as an inevitable consequence of feature-first. He also says shared-resource placement has "no right or wrong answer" and needs judgment.

(d) THE ESCAPE HATCH IS REAL BUT NARROWER THAN USED. "Single-page app" is a literal bar. An app with speak, show, edit, and settings surfaces plus a database, repository, and speech service is not a single-page app, so that sentence does not license the conclusion for this app. The claim smuggles a genuine quote in to cover a case it does not describe.

CARGO-CULT / CONSENSUS CHECK: the claim does not overstate consensus — it cites one blog post and attributes it to one author, correctly. No version rot, no dead packages, no invented API signatures; this is a pure source-characterization claim and the failure is in the inference, not the citation.

NET: quotes genuine, conclusion unsupported and contrary to the cited source's own recommendation. Bizzotto recommends feature-first for medium/large apps specifically WHEN organized around domain models rather than UI screens.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "project-structure" made this claim, and a project decision depends on it.

CLAIM: Feature-first is a poor fit for this app because its 'features' are surfaces over one shared data model, not independent functional requirements.
DETAIL: Bizzotto defines a feature as 'a functional requirement that helps the user complete a given task' and explicitly describes his own mistake of structuring features around pages (product_page, products_list), which produced an 'unbalanced' structure because models and repositories were genuinely shared. This app's speak/show/edit/settings all operate on boards/buttons/grid_slots/settings — under feature-first, BoardRepository, AppDatabase, SpeechService, voice_filter and the models (i.e. nearly all non-widget code) land in a top-level shared/, leaving four folders of widgets. He also states the pragmatic escape hatch directly: 'if we're building just a single-page app, we can put all files in one folder and call it a day.'
CLAIMED SOURCES: https://codewithandrea.com/articles/flutter-project-structure/
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
