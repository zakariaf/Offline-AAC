# flutter-design-capability--impeller-has-no-raster-cache-a-static-ui-is

> Phase: **verify** · Agent `a4e22db73a0af5f0a` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Correct the claim to: "Impeller has no raster cache at all — not just the picture/complexity-scored cache, but the entire flow/raster_cache subsystem including the layer raster cache for RepaintBoundary, opacity, and ImageFilter layers. It is hard-disabled because every Impeller Surface backend returns false from Surface::EnableRasterCache(), and rasterizer.cc sets ignore_raster_cache=true in that case. A static UI is cheap because Flutter schedules no frame when nothing is dirty — not because anything is cached. The moment any frame is produced, it is re-rendered from scratch with zero caching. Partial-repaint/damage-rect scoping exists on iOS/Metal ONLY (and on the legacy Android OpenGL Impeller fallback); Android's default Impeller backend is Vulkan, and gpu_surface_vulkan_impeller.cc never sets FramebufferInfo::supports_partial_repaint, which defaults to false — so on most Android devices there is no damage-rect scoping and every frame is full-surface. Partial repaint is additionally disabled on any platform when platform views (ExternalViewEmbedder) are present, and is opt-out on iOS via FLTDisablePartialRepaint. The observation that a full-screen BackdropFilter defeats damage-rect scoping (it must sample the whole backdrop) is correct but relevant only on iOS; on Android there is no scoping to defeat." Also drop #166184 as a supporting source — it is a tangential vector_graphics feature request — and add flutter/flutter#27677 and #124526 for the BackdropFilter and partial-repaint points respectively.

**Evidence:** CORE THESIS: CONFIRMED at source level, not merely from prose.

1. Raster cache absent under Impeller — VERIFIED IN ENGINE SOURCE. engine/src/flutter/shell/common/rasterizer.cc gates caching on a Surface virtual: "bool ignore_raster_cache = true; if (surface_->EnableRasterCache()) { ignore_raster_cache = false; }". Every Impeller backend returns false: gpu_surface_metal_impeller.mm ("// |Surface| bool GPUSurfaceMetalImpeller::EnableRasterCache() const { return false; }"), gpu_surface_vulkan_impeller.cc (identical), gpu_surface_gl_impeller.cc. Note the claim is UNDERSTATED: it is not only the picture/complexity-scored cache that is absent but the entire flow/raster_cache subsystem, including the LAYER raster cache serving RepaintBoundary, opacity layers, and ImageFilter layers (flow/layers/layer_raster_cache_item.cc, cacheable_layer.cc exist but are unreachable under Impeller).

2. Attribution — VERIFIED VERBATIM. flutter/flutter#131206 ("Consider disabling picture complexity based raster caching in Skia backend", CLOSED/COMPLETED 2024-02-26) body contains, from a Flutter engine team member: "Because of these issues, we've previously decided not to port the raster cache to Impeller." The three defects cited by the researcher are all genuinely in that issue: (a) failure to measure GPU texture-sampling tradeoffs ("texture sampling can be multiple times slower than executing the original shaders") plus tens of MB video memory; (b) unpredictable ping-ponging performance; (c) "Unmaintainable herustics ... developed by a never productionized one time script". flutter/flutter#88832 is genuinely titled "Raster cache heuristics are bad." (CLOSED/COMPLETED, P1).

3. All four claimed sources exist and are not fabricated. #166184 is real ("[vector_graphics] Add support for automatic render strategy selection", CLOSED/COMPLETED) but is TANGENTIAL — a third-party feature request that only mentions Impeller's lack of raster cache in passing; it is the weakest leg and does not independently establish the claim.

4. "Frame only when dirty" mechanism — consistent with Flutter's documented pipeline; nothing contradicts it.

WHAT BROKE — the Android partial-repaint specific is FALSE on the default backend:
flow/surface_frame.h defines "struct FramebufferInfo { bool supports_readback = false; bool supports_partial_repaint = false; int vertical_clip_alignment = 1; int horizontal_clip_alignment = 1; std::optional<DlIRect> existing_damage = std::nullopt; };" — partial repaint defaults OFF. Code search for supports_partial_repaint across flutter/flutter returns only these Impeller paths: gpu_surface_metal_impeller.mm (iOS), android_surface_gl_impeller.cc (legacy GL fallback), embedder_surface_gl_impeller.cc. gpu_surface_vulkan_impeller.cc NEVER sets it — it only sets ".supports_readback = true". Vulkan is Android's DEFAULT Impeller backend on API 29+ (docs.flutter.dev/perf/impeller); GL is only the fallback for pre-API-29 / no-Vulkan devices. Therefore the majority of Android devices get NO damage-rect scoping under Impeller.

Additional qualifiers the claim omits: rasterizer.cc disables partial repaint whenever an ExternalViewEmbedder is active ("ExternalViewEmbedder unconditionally clears the entire surface and also partial repaint with platform view present is something that still need to be figured out") and when leaf layer tracing is enabled. On iOS, partial repaint is defeatable via the FLTDisablePartialRepaint Info.plist key (gpu_surface_metal_impeller.mm gates on disable_partial_repaint_).

Issue #124526 "[Impeller] DRM/ Partial Repaint for Impeller" is CLOSED/COMPLETED (2023-04-26, P3) via flutter/engine#40959 — but the work landed for Metal only; the completion does NOT imply Vulkan coverage, and the source confirms it does not.

BACKDROPFILTER SUB-CLAIM: directionally correct but supported by sources the researcher did not cite (#27677 "BackdropFilter renders offscreen even if not repainted", #32804, #126353) rather than by the four claimed sources. BackdropFilterLayer uses a readback region repainted wholesale if anything within it changes, because blur samples outside clip edges. However this caveat is iOS-scoped in practice — on Android/Vulkan there is no partial repaint to defeat.

DOCS CHECK: docs.flutter.dev/perf/impeller does NOT mention the raster cache, partial repaint, or damage regions at all. It confirms only platform support (iOS: Impeller only, no Skia fallback; Android: default on API 29+, GL fallback below) and offline shader compilation. It does not substantiate the caching claims — those rest on the engine source and #131206.

PRACTICAL IMPACT ON THE DESIGN DECISION: if the decision rests on "damage-rect scoping limits the blast radius on Android", that premise is false — on Android's default Vulkan backend every produced frame is already full-surface with zero caching.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "flutter-design-capability" made this claim, and a design decision depends on it.

CLAIM: Impeller has no raster cache. A static UI is cheap because no frames are scheduled when idle — not because anything is cached.
DETAIL: The Flutter team decided not to port the picture raster cache to Impeller (due to problems with its complexity-based scoring heuristics, flutter/flutter#131206, #88832). Impeller redraws every frame in real time. Consequence: the common claim 'expensive-per-frame effects are free in a static UI' is TRUE but only via a different mechanism — Flutter's pipeline produces a frame only when something is marked dirty. The moment ANY frame is produced, the full damage region is re-rendered from scratch with zero caching. Impeller does support partial-repaint/damage-rect scoping on Android and iOS, which limits the blast radius — but a full-screen BackdropFilter defeats damage-rect scoping because it must sample the whole backdrop.
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/131206, https://github.com/flutter/flutter/issues/166184, https://docs.flutter.dev/perf/impeller, https://docs.flutter.dev/perf/ui-performance
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
