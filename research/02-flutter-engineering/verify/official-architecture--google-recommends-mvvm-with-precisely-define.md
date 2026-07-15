# official-architecture--google-recommends-mvvm-with-precisely-define

> Phase: **verify** · Agent `a07bd9564a97b6399` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the substance; all quotations are accurate and current. Two scope refinements: (1) The guide describes itself as "guidelines, not steadfast rules, and you should adapt them to your unique requirements" — so the claim's roles are recommended defaults, not mandates, and a project decision should not be framed as compliance. (2) The assertion that "SpeechService is exactly what the guide's service examples describe" is an application of the rule to the researcher's codebase, not something the documentation states; the doc-side claim is confirmed, but that specific classification was not independently verified here.

**Evidence:** Fetched the primary source (https://docs.flutter.dev/app-architecture/guide) twice, targeting each quoted string. Every quotation in the claim is verbatim-accurate and currently live. Page last updated 2026-05-05; no deprecation, archive, or supersession notice — the "version rot" failure mode does not apply.

Verified verbatim:
- "MVVM is an architectural pattern that separates a feature of an application into three parts: the Model, the ViewModel and the View."
- Views "shouldn't contain any business logic. They should be passed all data they need to render from the view model." (Guide also lists narrow view-permissible logic: simple if-statements for show/hide, animation logic, layout logic based on device info, simple routing. "All logic related to data should be handled in the view model.")
- "most of the logic in your Flutter application lives in view models." All three responsibilities confirmed: (1) retrieving app data from repositories and transforming for presentation, (2) maintaining current view state, (3) exposing callbacks called commands.
- "Views and view models should have a one-to-one relationship."
- "Repository classes are the source of truth for your model data." / "There should be a repository class for each different type of data handled in your app." Repo responsibilities confirmed to include caching, error handling, retry logic, refreshing data, polling services, and managing app-wide lifecycle state (user sessions, in-memory caches, transient settings).
- "Services are in the lowest layer of your application. They wrap API endpoints and expose asynchronous response objects, such as Future and Stream objects... they hold no state." and "They're only used to isolate data-loading, and they hold no state."
- Service examples confirmed to include "The underlying platform, like iOS and Android APIs", "REST endpoints", and "Local files".
- Framing as recommendation confirmed: page presents "The recommended way to architect a Flutter app."
- Layer mapping confirmed: "Views and view models make up the UI layer of an application. Repositories and services represent the data of an application, or the model layer of MVVM." The guide itself reconciles the MVVM three-part vocabulary with the four-component (view/viewmodel/repository/service) breakdown, so the claim's four-role framing is not a distortion.

Two calibration notes that qualify but do not refute:
1. The guide explicitly self-labels as non-binding: "The recommendations in this guide can be applied to most apps... However, they're guidelines, not steadfast rules, and you should adapt them to your unique requirements." The optional Domain layer is likewise described as optional "because not all applications or features within an application have these requirements." So "Google recommends" is accurate; "Google mandates / compliance is required" would overstate the source. If the dependent project decision is framed as compliance rather than as a default worth deviating from with reason, that framing exceeds the source.
2. The DETAIL's closing inference — "Explicitly listed service examples include 'The underlying platform, like iOS and Android APIs' and 'Local files' — which is exactly what SpeechService is" — is the researcher's application to their own codebase, not a doc statement. The doc side is fully verified; the SpeechService classification was not independently inspected and its confidence is borrowed rather than sourced. It is a reasonable application of the stated rule.

No invented or misremembered API names, no dead packages, no overstated consensus (this is first-party Google/Flutter documentation, not a blog post), and no cargo-culting of a team practice as universal — the source genuinely says what is attributed to it.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "official-architecture" made this claim, and a project decision depends on it.

CLAIM: Google recommends MVVM with precisely defined roles: View = dumb widgets, ViewModel = where most logic lives, Repository = source of truth, Service = stateless data-source wrapper.
DETAIL: From /app-architecture/guide: "MVVM is an architectural pattern that separates a feature of an application into three parts: the Model, the ViewModel and the View." View: "views are the widget classes of your application... shouldn't contain any business logic. They should be passed all data they need to render from the view model." ViewModel: "A view model exposes the application data necessary to render a view... most of the logic in your Flutter application lives in view models" — responsibilities are (1) retrieving/transforming data from repositories, (2) maintaining UI state, (3) exposing commands. "Views and view models should have a one-to-one relationship." Repository: "Repository classes are the source of truth for your model data. They're responsible for polling data from services, and transforming that raw data into domain models... There should be a repository class for each different type of data handled in your app." Repos own caching, error handling, retry, refresh, and app-wide session state. Service: "Services are in the lowest layer... They wrap API endpoints and expose asynchronous response objects... They're only used to isolate data-loading, and they hold no state." Explicitly listed service examples include "The underlying platform, like iOS and Android APIs" and "Local files" — which is exactly what SpeechService is.
CLAIMED SOURCES: https://docs.flutter.dev/app-architecture/guide
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
