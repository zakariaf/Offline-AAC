# performance-startup--flutter-run-profile-trace-startup-measures-f

> Phase: **verify** · Agent `a98e88dd1055f059a` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The claim is directionally correct and safe to act on: --trace-startup does start its clock at engine enter and does undercount real cold start. Fix four specifics before publishing.

(1) Do not say "all of these begin at engine enter." Correct: engineEnterTimestampMicros is an absolute timeline timestamp; timeToFrameworkInitMicros, timeToFirstFrameMicros, and timeToFirstFrameRasterizedMicros are deltas from engine enter; timeAfterFrameworkInitMicros is firstFrameBuilt − frameworkInit, i.e. based at framework init, and is emitted conditionally.

(2) Replace the docs.flutter.dev/perf/ui-performance citation — it does not mention --trace-startup or start_up_info.json, and no docs.flutter.dev page currently does. Cite packages/flutter_tools/lib/src/tracing.dart in flutter/flutter directly.

(3) The Fully drawn tag is ActivityManager in Android's cited doc; ActivityTaskManager is what Android 10+ devices actually emit. Say so rather than asserting one.

(4) Qualify the reportFullyDrawn linkage: it holds only on API 29+ and only when hosting via FlutterActivity/FlutterFragmentActivity. Below API 29, or in add-to-app / FlutterFragment / custom-Activity setups, no Fully drawn line is emitted unless you call reportFullyDrawn() yourself — so a team relying on that logcat line for TTFD in an add-to-app product will get nothing.

Additional caveat worth adding for a startup-performance decision: `flutter run --trace-startup` launches the app through the tool with an attached VM service, which is not a representative cold start regardless of where the clock starts. For user-perceived numbers, install the profile/release APK and measure with `adb shell am start -W` on a fresh process.

**Evidence:** CORE MECHANISM — CONFIRMED against primary source (flutter_tools/lib/src/tracing.dart on flutter/flutter master). The file names and the base timestamps are real, and the direction of the claim is right: the clock starts at the `FlutterEngineMainEnter` timeline event, so Android process fork/zygote, Application.onCreate, and libflutter.so load all precede it and are NOT counted. `flutter run --profile --trace-startup` does undercount user-perceived cold start. All five field names exist verbatim — including `timeAfterFrameworkInitMicros`, which I specifically expected to be invented and is not.

ERROR 1 — "All of these begin at engine enter" is FALSE. Per tracing.dart:
  - timeToFrameworkInitMicros = frameworkInit − engineEnter  (engine enter base)
  - timeToFirstFrameMicros = firstFrameBuilt − engineEnter  (engine enter base)
  - timeToFirstFrameRasterizedMicros = firstFrameRasterized − engineEnter  (engine enter base)
  - timeAfterFrameworkInitMicros = firstFrameBuilt − frameworkInit  ← base is FRAMEWORK INIT, not engine enter
  - engineEnterTimestampMicros is an absolute timeline timestamp, not a duration from anything.
So 3 of 5 are engine-enter-relative; one is framework-init-relative and one is the base itself. Also note timeAfterFrameworkInitMicros is only emitted when framework-init data exists and first-frame awaiting is enabled — it is not unconditionally present.

ERROR 2 — BOTH CITATIONS FAIL FOR THE FLUTTER HALF. I fetched https://docs.flutter.dev/perf/ui-performance: it does not contain "--trace-startup", "start_up_info.json", or any of the five field names. It covers the performance overlay, DevTools Performance view, and dart:developer timeline. A site-restricted search for "trace-startup" on docs.flutter.dev returns no page documenting it. `--trace-startup` is currently documented nowhere on docs.flutter.dev — it lives only in `flutter run --help` and the flutter_tools source. The old debugging.md section that carried this content is gone from the restructured docs (/testing/code-debugging, the successor page, has no mention). Cite the source file, not the docs site.

ERROR 3 — WRONG LOGCAT TAG PER THE CLAIM'S OWN CITED SOURCE. https://developer.android.com/topic/performance/vitals/launch-time shows the tag as ActivityManager, not ActivityTaskManager:
  "system_process I/ActivityManager: Fully drawn {package}/.MainActivity: +1s54ms"
Real devices on Android 10+ do emit ActivityTaskManager, so the claim is defensible in practice but does not match the source it cites. Minor.

ERROR 4 — reportFullyDrawn LINKAGE IS TRUE BUT LOAD-BEARINGLY INCOMPLETE. This is the one that could break a project decision. FlutterActivity.onFlutterUiDisplayed() does call reportFullyDrawn(), so "Fully drawn" genuinely tracks Flutter's first rendered frame — but it is gated:
  if (Build.VERSION.SDK_INT >= API_LEVELS.API_29) { reportFullyDrawn(); }
Below API 29 Flutter emits no Fully drawn line at all, and the guard only lives in FlutterActivity (and FlutterFragmentActivity, which extends it). A custom host Activity or a FlutterFragment/add-to-app embedding does not get this for free — you must call reportFullyDrawn() yourself. The claim states the correspondence as unconditional.

STALENESS NOTE — the engine source path in the claim's implied lineage has moved. github.com/flutter/engine was archived by the owner on Feb 25, 2025 and is read-only; FlutterActivity.java now lives at flutter/flutter under engine/src/flutter/shell/platform/android/io/flutter/embedding/android/. Anything in this corpus pointing at flutter/engine is a dead link.

NOT CHECKED / UNRESOLVED: the claim asserts am start -W's ThisTime/TotalTime/WaitTime "= time to initial display". Android's doc defines TTID as the `Displayed` logcat line and gives the three -W values distinct meanings (ThisTime = last activity, TotalTime = from process start, WaitTime = incl. system overhead). TotalTime approximates TTID; equating all three to TTID is sloppy but not materially wrong for a cold-start measurement.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "performance-startup" made this claim, and a project decision depends on it.

CLAIM: `flutter run --profile --trace-startup` measures from engine-enter, not from process spawn, and therefore undercounts real cold start
DETAIL: It writes build/start_up_info.json containing engineEnterTimestampMicros, timeToFrameworkInitMicros, timeAfterFrameworkInitMicros, timeToFirstFrameRasterizedMicros, timeToFirstFrameMicros. All of these begin at engine enter — Android process fork, zygote, Application onCreate, and libflutter.so load happen BEFORE the clock starts. To get the user-perceived number you need `adb shell am start -W -n <pkg>/.MainActivity` (reports ThisTime/TotalTime/WaitTime = time to initial display) and the logcat `ActivityTaskManager: Fully drawn <pkg>/<activity>: +NNNms` line, which corresponds to Flutter's first rendered frame via reportFullyDrawn.
CLAIMED SOURCES: https://docs.flutter.dev/perf/ui-performance, https://developer.android.com/topic/performance/vitals/launch-time
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
