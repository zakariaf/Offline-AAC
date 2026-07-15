# performance-startup--memory-is-irrelevant-except-for-one-thing-us

> Phase: **verify** · Agent `a819cc0c243dd9668` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Two specifics need fixing. (1) The 100MB ImageCache cap doesn't save you NOT because "it evicts by count/bytes AFTER decode" — a 48MB bitmap is under the 100MB maximumSizeBytes and is cacheable. It doesn't save you because ImageCache separately tracks live images (ImageCache.liveImageCount): an image with an active listener is retained by its ImageStreamCompleter regardless of cache eviction, so 12 mounted tiles = 12 live bitmaps = ~576MB whatever the cache does. Tuning maximumSizeBytes would not help. (Note: only images LARGER than maximumSizeBytes are refused caching outright, per docs.flutter.dev/release/breaking-changes/imagecache-large-images — a 48MB decode isn't one of them.) (2) cacheWidth/ResizeImage is not a "weaker second line of defense" against OOM — per api.flutter.dev, cacheWidth/cacheHeight "indicate to the engine that the image must be decoded at the specified size," so the 48MB bitmap is never allocated; Flutter's own example cites a 100-fold reduction (4K image to 330KB at 384x216). Import-time re-encode is still the right primary fix, but because it's a single chokepoint that avoids per-load disk reads and resampling and shrinks disk usage — not because cacheWidth leaves the full decode exposed. Also: image_picker's pickImage already takes maxWidth/maxHeight/imageQuality, so the import-time downscale is one line at the pick site. Minor: 100 << 20 is 100 MiB, not 100 MB.

**Evidence:** I tried to break this claim on version rot, invented APIs, and dead packages. It survived all three. Every named API exists with the exact stated name and semantics on api.flutter.dev today, the numbers are arithmetically correct, and the recommended fix is directly supported by first-party docs. Two mechanism claims are wrong in ways that matter.

WHAT CHECKS OUT (primary sources):

1. ImageCache defaults — EXACT. Flutter stable source, packages/flutter/lib/src/painting/image_cache.dart: `const int _kDefaultSize = 1000;` and `const int _kDefaultSizeBytes = 100 << 20;`. The class doc: "Implements a least-recently-used cache of up to 1000 images, and up to 100 MB." The claim's "1000 entries / 100MB" is verbatim correct. (Pedantic: 100 << 20 is 100 MiB, not 100 MB.)

2. The decode math — CORRECT. 4000x3000x4 = 48,000,000 bytes. Flutter decodes to RGBA8888 (4 bytes/px) by default, so ~48MB per 12MP photo is right, and 12 x 48MB = 576MB.

3. ResizeImage — EXISTS, exact signature per api.flutter.dev: `ResizeImage(ImageProvider<Object> imageProvider, {int? width, int? height, ResizeImagePolicy policy = ResizeImagePolicy.exact, bool allowUpscaling = false})`. Docs: "allows finer control of the size of the image in ImageCache and is generally used to reduce the memory footprint of ImageCache."

4. cacheWidth — EXISTS on Image.file (`int? cacheWidth, int? cacheHeight`), implemented internally as `ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, FileImage(...))`.

5. The import-time fix is first-party guidance. docs.flutter.dev/release/breaking-changes/imagecache-large-images lists "Resize images to guarantee they fit within your chosen maxByteSize" as a migration option. And image_picker (v1.2.3, publisher flutter.dev, published ~2 weeks ago, actively maintained — not a dead package) ships the downscale hook directly: `pickImage({required ImageSource source, double? maxWidth, double? maxHeight, int? imageQuality, ...})`. So the "downscale at import" fix is available in one line at the pick site.

WHERE IT'S WRONG:

A. The eviction reasoning is the wrong mechanism. The claim says the 100MB cap "does not save you because it evicts by count/bytes AFTER decode." The decode-happens-first part is true, but that's not why the cap fails to protect you. A 48MB bitmap is UNDER the 100MB maximumSizeBytes, so it is cacheable — the cache would hold ~2 and evict the rest. The reason you still reach 576MB is that eviction does not free anything for images that are on screen: ImageCache separately tracks "live" images (see ImageCache.liveImageCount), and an image with an active listener is retained by its ImageStreamCompleter regardless of cache state. Twelve simultaneously-mounted tiles means twelve live bitmaps, cache cap or not. The 576MB number is right; the stated cause isn't. This matters practically: a developer who believed the claim's mechanism might "fix" it by raising or lowering maximumSizeBytes, which would do nothing.

B. "Render-time cacheWidth/ResizeImage is a weaker second line of defense" — contradicted in kind by the API docs. cacheWidth/cacheHeight "indicate to the engine that the image must be decoded at the specified size." The full-size 48MB bitmap is never allocated at all; the resample happens in the codec. As an OOM defense that is strong, not weak — it removes the same 48MB the import-time fix removes. Flutter's own doc gives the magnitude: a 4K image rendered at 384x216 "would only use 330KB if those dimensions are specified using the cacheWidth and cacheHeight parameters, a 100-fold reduction."

The import-time fix is still the better primary choice, but for reasons the claim doesn't state: it's applied once at a single chokepoint rather than needing every call site to remember cacheWidth; it avoids re-reading a multi-MB JPEG off disk and resampling on every cold load; and it shrinks disk usage and backup size too. It's better on durability and cost, not because cacheWidth leaves you exposed to the 48MB decode. It doesn't.

C. "Memory is irrelevant EXCEPT for one thing" overstates. The encoded file itself is still read fully into a Uint8List before decode under either approach, and 12 tiles is small enough that this doesn't bite — but the framing is rhetorical, not a load-bearing error.

The unsourced claims (OOM kill on a 2GB device; no telemetry means the developer never learns) are plausible engineering judgment but nothing primary settles them; treat them as reasoning, not fact.

BOTTOM LINE: The decision this depends on — downscale at import, write the small file to disk, point the DB at that — is correct and I could not refute it. Adopt it. But don't adopt the reasoning as stated: the ImageCache cap is irrelevant because on-screen images are live-retained, not because eviction is post-decode, and cacheWidth is a genuine decode-time defense rather than a weak fallback. Belt-and-braces is cheap here: downscale at import AND pass cacheWidth at render.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "performance-startup" made this claim, and a project decision depends on it.

CLAIM: Memory is irrelevant EXCEPT for one thing: user-imported tile images must be downscaled at import, not at render
DETAIL: 12 tiles, no lists, no animation → no memory pressure from Flutter. But images are user-supplied files on disk. A 12MP phone photo decodes to ~48MB in RAM (4000×3000×4 bytes). Twelve of those is ~576MB of image cache — an OOM kill on a 2GB device. Flutter's ImageCache default is 1000 entries / 100MB, which does not save you because it evicts by count/bytes AFTER decode. The fix belongs at import time: re-encode the picked image to tile-sized (e.g. max 512px) and write THAT to disk, so the DB path points at a small file forever. Render-time cacheWidth/ResizeImage is a weaker second line of defense. With no telemetry, an OOM kill is a bug the developer will never learn about.
CLAIMED SOURCES: (none)
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
