# performance-startup--impeller-is-irrelevant-to-this-app-s-speed-b

> Phase: **verify** · Agent `acd3d3cf7b2f39844` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Directionally right, wrong mechanism and wrong population. Corrections:

1. There are TWO fallback paths, not one. STATIC: API < 29, or Vulkan < 1.1, or missing extensions -> Impeller OpenGL ES from startup. RUNTIME: API 29+ device with Vulkan 1.1 starts on Vulkan, then falls back to GLES because its driver hits the known-bad denylist (android_context_vk_impeller.cc; flutter/flutter#162876) or context init fails.

2. Both cited bugs (#179268, #177873) are defects of the RUNTIME transition only. #179268 explicitly does not reproduce on "OpenGL ES alone" or "Vulkan alone". An old/API-28/no-Vulkan device runs GLES-alone and is therefore NOT the exposed population — it is the configuration those issues report as clean.

3. The actually-exposed population is API 29+ Vulkan-1.1-capable devices with denylisted or buggy drivers (repro hardware: Positivo Q20 / PowerVR / Android 10; Redmi Note 11 / Adreno-KGSL). This overlaps budget hardware but is defined by driver denylist status, not by age or cheapness. Correct framing: "devices whose Vulkan driver is denylisted at runtime", not "old/cheap devices".

4. #177873 is a regression introduced by the Vulkan-fallback patch #177380 (closed by #177747), not a longstanding GLES-backend defect.

5. Drop "no measurable perf impact" as a sourced statement — docs.flutter.dev/perf/impeller does not say it, and no primary source establishes it. If the decision depends on it, benchmark the actual grid; do not cite the Impeller page for it.

6. Decision-relevant addition the claim omits: Android retains an Impeller opt-out (--no-enable-impeller per current docs; also an AndroidManifest flag), so the buggy path has an escape hatch on Android. iOS does not — that half of the claim stands.

**Evidence:** Every discrete fact in the claim verifies against primary sources; the inference joining them does not.

CONFIRMED FACTS:
- docs.flutter.dev/perf/impeller, verbatim: "Impeller is available and enabled by default on Android API 29+" and "On devices running lower versions of Android or don't support Vulkan, Impeller falls back to the legacy OpenGL renderer."
- iOS, verbatim: "Impeller is the only supported rendering engine on iOS with no ability to switch to Skia." Claim correct.
- Vulkan 1.1+ requirement CONFIRMED in impeller/docs/android.md: "For Vulkan, Impeller needs at least Vulkan version 1.1", plus required extensions (VK_ANDROID_external_memory_android_hardware_buffer). Backend tree: API < 29 -> unconditionally OpenGL ES; API >= 29 -> Vulkan 1.1 + extensions, else OpenGL ES. The claim's word "unconditionally" is the doc's own.
- flutter/flutter#179268: real, OPEN, exact title "[Android][Impeller OpenGL ES] Gradients rendered incorrectly after Vulkan -> OpenGL ES fallback". P2.
- flutter/flutter#177873: real, OPEN, exact title "[Android][Impeller-OpenGL ES] SVG and VG rendering crash or corruption after Vulkan fallback".
- flutter/flutter#151240: real, "[Impeller] Does Not Fall Back to OpenGL on Android Devices Lacking Vulkan Support", CLOSED as fixed.
No version rot, no invented API names, no dead-package problem. Issue numbers and states are accurate as of 2026-07-15.

THE DEFECT — two distinct mechanisms conflated under one word "fallback":
(1) STATIC capability selection: API < 29, or no Vulkan 1.1, or missing extensions -> Impeller OpenGL ES from process start. This is the old/cheap-device population the claim names.
(2) RUNTIME Vulkan->GLES fallback: an API 29+ device WITH Vulkan 1.1 starts on Vulkan, then drops to GLES mid-flight via the known-bad-driver denylist in android_context_vk_impeller.cc (see flutter/flutter#162876, "Known bad Vulkan driver encountered, falling back to OpenGLES"), or on context-init failure.

Both cited bugs live in mechanism (2). #179268's reporter states explicitly that the bug does NOT reproduce "using OpenGL ES alone", "using Vulkan alone", or with Impeller disabled — only across the Vulkan->GLES transition. A mechanism-(1) device never transitions; it IS the "OpenGL ES alone" configuration that #179268 reports as clean. Repro hardware for both bugs is API 29+ Vulkan-capable: Positivo Q20 (Android 10, PowerVR) and Redmi Note 11 (Adreno/KGSL). #177873 is explicitly a regression introduced BY the fallback patch (#177380, fixed via #177747) — i.e. it is a defect of the transition path, not of GLES rendering as such.

Consequence: "a budget/old device is exactly the population that lands on the fallback" is wrong as stated. An API 28 phone is the population LEAST exposed to #179268/#177873. Real exposure is API 29+ devices with denylisted drivers — which does include budget hardware, so the conclusion lands near the truth via the wrong population and the wrong mechanism. The reasoning does not support the decision it is being used to justify.

UNSUBSTANTIATED: "For a static grid the renderer choice has no measurable perf impact" is cited to docs.flutter.dev/perf/impeller, which does not say this. No primary source settles it. It is an untested assertion about this specific app carrying a citation it has not earned, and it bears half the claim's weight.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "performance-startup" made this claim, and a project decision depends on it.

CLAIM: Impeller is irrelevant to this app's speed but relevant to its rendering correctness on cheap devices
DETAIL: Impeller is default on Android API 29+ and preferentially uses Vulkan (needs Vulkan 1.1+); API 28 and below, or devices without Vulkan, unconditionally fall back to OpenGL ES. On iOS Impeller is the only renderer — Skia cannot be re-enabled. For a static grid the renderer choice has no measurable perf impact. BUT the GL fallback path has open rendering bugs: flutter/flutter#179268 (gradients rendered incorrectly after Vulkan→GLES fallback) and #177873 (SVG/vector-graphics crash or corruption after GLES fallback). A budget/old device is exactly the population that lands on the fallback.
CLAIMED SOURCES: https://docs.flutter.dev/perf/impeller, https://github.com/flutter/flutter/issues/179268, https://github.com/flutter/flutter/issues/177873, https://github.com/flutter/flutter/issues/151240
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
