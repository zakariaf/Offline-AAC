# project-structure--a-domain-layer-with-hand-written-mirror-mode

> Phase: **verify** · Agent `a3bbaada8e9c9c5d5` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep the thesis, fix four specifics. (1) Cite the primary source, not the blogs: docs.flutter.dev/app-architecture/case-study/domain-layer says the domain layer "is optional and only needs to be implemented if your application has complex business logic that happens on the client" and CRUD apps "might not need this optional layer." That is Flutter's own vendor guidance and it does the work both blog posts were recruited for. (2) Drop "The 2025 backlash" — leancode.co is dated July 27, 2023, and yshean.com is an undated personal blog from a self-described 5-developer team. Two posts, one three years old, is n=2 anecdote, not a backlash; state it as "individual practitioner reports, consistent with Flutter's official guidance." (3) "Exactly one hand-written value object" is wrong — it is at least two. Drift emits a row class per table and never per join; joins return List<TypedResult> which you unpack with readTable()/readTableOrNull(), and drift's own docs hand-write an EntryWithCategory class for exactly this shape. A displayable tile is grid_slots ⟕ buttons ⟕ images with two nullable FKs, so Tile is a hand-written joined type in addition to BoardGrid. Budget for BoardGrid + Tile. (4) "Fixed 3x4" contradicts the project's own schema — RESEARCH.md:380 gives boards.grid_rows / boards.grid_cols, settings carries a grid_size key, and design-distress.md:219 requires a 2x3 crisis/large layout alongside the 3x4 default. BoardGrid must take its dimensions from the board row; hard-coding 3x4 would ship a bug against the spec. Corrected claim: "Skip the domain/ mirror-model layer — Flutter's official architecture guidance makes the domain layer optional for CRUD apps, and with no API boundary here entity↔model mapping is identity. Use drift's generated row classes as domain models, plus two hand-written types: a joined Tile (grid_slots+buttons+images, since drift generates no class for joins) and a per-board-dimensioned BoardGrid of Tile? materialized from boards.grid_rows × boards.grid_cols."

**Evidence:** SOURCES VERIFIED — both cited URLs exist and roughly carry the quoted text. yshean.com contains "After months of writing mappers between entities and models, creating use cases for simple API calls..." and "For most apps, it's overkill." leancode.co contains "For small applications, prototypes, or experiments, clean Architecture can introduce unnecessary overhead."

NO DEAD-PACKAGE PROBLEM: drift is at 2.34.2, publisher simonbinder.eu (verified), last published ~25 hours ago, 2.43k likes, 973k downloads. Actively maintained.

SCHEMA CLAIM VERIFIED against the repo itself: /Users/zakariafatahi/50-apps-challenge/Offline-AAC/RESEARCH.md:402-407 confirms grid_slots has PRIMARY KEY (board_id, row, col) with "button_id TEXT NULL FK -- NULL = empty slot."

ERROR 1 — "fixed 3x4" contradicted by the researcher's own schema. RESEARCH.md:380 defines boards with "grid_rows INT · grid_cols INT", and the settings k/v table (RESEARCH.md:417) includes a "grid_size" key. Design docs (research/01-product-and-market/research/design-distress.md:219) specify "3x4 grid (12 tiles) default on a phone; offer 2x3 (6 tiles, ~180dp) as a 'crisis/large' layout." The grid is per-board dimensioned and user-configurable, not fixed 3x4.

ERROR 2 — "exactly one hand-written value object" undercounts. Drift generates a row class per TABLE, never per JOIN. Per drift docs (drift.simonbinder.eu/docs/getting-started/writing_queries/): "Calling get() or watch on a select statement with join returns a Future or Stream of List<TypedResult>", unpacked via readTable() / readTableOrNull(). The drift docs' own example hand-writes an EntryWithCategory class for precisely this. A displayable tile is grid_slots ⟕ buttons ⟕ images (button_id and image_id both nullable → left outer joins), so the "Tile" named inside the claim's own "BoardGrid of Tile?" is itself a hand-written joined type the claim failed to count. Minimum two hand-written types, not one.

ERROR 3 — "The 2025 backlash" is a date error (failure mode #1 + #5). leancode.co/glossary/clean-architecture-in-flutter is dated July 27, 2023 — three years old, not 2025. yshean.com is an undated, unattributed personal blog explicitly scoped to n=1 ("I've been building Flutter apps for a team of around 5 developers"; "For my team of 5 developers, we use Feature-First"). Two blog posts, one from 2023, is not a "backlash" — this is overstated consensus built on a single developer's retrospective.

ERROR 4 — misquotation. The claim renders leancode as "for small applications... clean architecture can introduce unnecessary overhead, especially if the app is limited to a few screens." The trailing clause "especially if the app is limited to a few screens" does not appear in the source as quoted; it is paraphrase of adjacent context presented inside quotation marks.

UNCITED STRONGER SUPPORT: Flutter's official architecture guidance (docs.flutter.dev/app-architecture/case-study/domain-layer and /concepts) states the domain layer "is optional and only needs to be implemented if your application has complex business logic that happens on the client" and that CRUD apps "might not need this optional layer." This is a first-party vendor source that substantiates the claim's core thesis far better than either blog cited.

CORE REASONING SOUND: the argument that with no API and no serialization boundary the entity↔model mapping maps a type onto itself is valid, and is endorsed in substance by Flutter's own docs. The direction is right; the specifics (count, grid dimensions, dating, quotation fidelity) are wrong.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "project-structure" made this claim, and a project decision depends on it.

CLAIM: A domain/ layer with hand-written mirror models and mappers is the Clean-Architecture overhead to cut; drift's generated row classes should BE the domain models, with exactly one hand-written value object for the grid.
DETAIL: The 2025 backlash is specific: developers report 'spending months writing mappers between entities and models, creating use cases for simple API calls'; 'for small applications... clean architecture can introduce unnecessary overhead, especially if the app is limited to a few screens.' Here there is no API and no serialization boundary — the SQLite row IS the truth, so entity↔model mapping maps a type onto itself. The one genuine exception: grid_slots' PK is (board_id,row,col) with a nullable button_id, so the UI wants a materialized fixed 3x4 BoardGrid of Tile? — that shape does not exist in any table and deserves a real hand-written type. Cost accepted: renaming a column ripples into widgets — but as a compile error, not a field bug.
CLAIMED SOURCES: https://yshean.com/flutter-architecture-patterns-clean-architecture-vs-feature-first, https://leancode.co/glossary/clean-architecture-in-flutter
CONFIDENCE: medium

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
