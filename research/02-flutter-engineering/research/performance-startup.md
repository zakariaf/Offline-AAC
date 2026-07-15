# performance-startup

> Phase: **research** · Agent `a46312241009eb9ba` · Run `wf_12b14467-451`

## Result

## Summary

The honest answer is that ~85% of Flutter performance advice is irrelevant to this app, and the most important performance fact is that Flutter is not the bottleneck. A static 12-tile grid with zero animation has no jank, no list virtualization, no repaint boundary, no shader warmup, and no rebuild-scoping problem — those are all solved by the design, not by engineering. The one metric that matters is time-from-tap-to-audible-speech, and its dominant term is not Flutter's first frame (realistically 700ms–1.8s process-spawn-to-first-frame on a $120 Android phone, well under the 5s Android vitals "excessive" bar) but Android's TextToSpeech service binding, which is documented at 1–5+ seconds on real devices and is entirely outside Flutter's control. This reframes the whole dimension: the performance work is (a) warm the TTS engine off the critical path at startup, (b) never let anything block the first frame, and (c) recognize that the already-decided Quick Settings TileService reading SharedPreferences with no Flutter engine IS the cold-start fix — it is the fastest path to speech in the entire product and should be treated as the primary performance feature, not a convenience. Two non-obvious risks survive the pruning: user-imported images must be downscaled at import time (a 12MP photo × 12 tiles is an OOM kill on a 2GB phone, and with no telemetry an OOM is a permanently invisible bug), and Impeller's OpenGL ES fallback on sub-Vulkan devices has open rendering-corruption bugs, which argues for flat solid-color tiles over gradients/vector art — a rendering-correctness rule, not a speed one. Deferred components should be explicitly refused: they require Play Core and Play delivery, which conflicts with the no-network promise and sideload/F-Droid distribution. Measurement is one command (`flutter run --profile --trace-startup`) plus `adb shell am start -W`, run on the cheapest physical device, once, before release — not a practice, an event.

### TTS engine binding, not Flutter startup, dominates time-to-first-word on Android

*Confidence: high, **LOAD-BEARING***

flutter_tts issue #235 documents 5+ seconds before speech actually starts on real Android devices (not reproducible on emulator) — this is Android TextToSpeech service bind/init, not Flutter. For comparison, Flutter engine init + Dart VM snapshot load + first frame on a low-end device is a few hundred ms to ~1.5s. The TTS term is larger than the entire Flutter term and is invisible to every Flutter profiling tool. Apps targeting Android 11+ must also declare <queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries> in the manifest or engine discovery fails outright.

- https://github.com/dlutton/flutter_tts/issues/235

- https://pub.dev/packages/flutter_tts

### The already-decided Quick Settings TileService is the single highest-leverage performance decision in the project

*Confidence: high, **LOAD-BEARING***

A Kotlin TileService that reads SharedPreferences and calls Android TextToSpeech natively with NO Flutter engine on that path skips process-spawn-of-Flutter, engine init, Dart VM snapshot load, drift open, and first frame entirely. It is plausibly an order of magnitude faster to speech than the app path. The engineering consequence: the SharedPreferences mirror must be a write-through cache updated on EVERY board edit, and that sync is a testable invariant (edit a tile in Dart → assert the SharedPreferences value changed). A stale mirror means the QS tile speaks the OLD phrase — a silent correctness failure with no telemetry to catch it.

### `flutter run --profile --trace-startup` measures from engine-enter, not from process spawn, and therefore undercounts real cold start

*Confidence: medium, **LOAD-BEARING***

It writes build/start_up_info.json containing engineEnterTimestampMicros, timeToFrameworkInitMicros, timeAfterFrameworkInitMicros, timeToFirstFrameRasterizedMicros, timeToFirstFrameMicros. All of these begin at engine enter — Android process fork, zygote, Application onCreate, and libflutter.so load happen BEFORE the clock starts. To get the user-perceived number you need `adb shell am start -W -n <pkg>/.MainActivity` (reports ThisTime/TotalTime/WaitTime = time to initial display) and the logcat `ActivityTaskManager: Fully drawn <pkg>/<activity>: +NNNms` line, which corresponds to Flutter's first rendered frame via reportFullyDrawn.

- https://docs.flutter.dev/perf/ui-performance

- https://developer.android.com/topic/performance/vitals/launch-time

### Android vitals treats cold start ≥5s as excessive; this app has enormous headroom and does not need cold-start optimization work

*Confidence: medium, **LOAD-BEARING***

Android vitals thresholds: cold ≥5s, warm ≥2s, hot ≥1.5s are 'excessive', measured as TTID (time to initial display) over a 28-day window. A Flutter app with one screen, no plugins doing work in main(), and a 12-row DB read is realistically 700ms–1.8s cold on a $120–150 device (Snapdragon 4-series / Helio G-series class). The gap between 'realistic' and 'excessive' is ~3s. Cold-start micro-optimization is therefore NOT a good use of the 2-week budget; the only rule needed is 'do not block the first frame'.

- https://developer.android.com/topic/performance/vitals/launch-time

- https://support.google.com/googleplay/android-developer/answer/9844486

### Deferred components are unusable for this project and should be explicitly refused

*Confidence: high, **LOAD-BEARING***

Flutter deferred components on Android require `implementation "com.google.android.play:core"`, FlutterPlayStoreSplitApplication (or manual SplitCompat), a PlayStoreDeferredComponentManager injected via FlutterInjector, and Play Store dynamic-feature delivery — i.e. a network fetch from Google Play at runtime. That contradicts the no-network promise, breaks sideload/F-Droid distribution, and adds ~6 manual config steps. It is also pointless: the entire Dart app is a few hundred KB of the binary.

- https://docs.flutter.dev/perf/deferred-components

### Shader warmup / SkSL is dead and must not be attempted

*Confidence: high*

Impeller precompiles shaders at engine-build time, so there is zero runtime shader compilation. `--bundle-sksl-path` and `--cache-sksl-path` were removed (users report 'Could not find an option named --bundle-sksl-path' on Flutter 3.32+). flutter/flutter#132418 tracks removing the old warm-up logic entirely. Any 2021–2023 blog post recommending SkSL warmup is actively wrong in 2026. For a zero-animation app it would have been irrelevant regardless.

- https://github.com/flutter/flutter/issues/171585

- https://github.com/flutter/flutter/issues/132418

- https://docs.flutter.dev/perf/impeller

### Impeller is irrelevant to this app's speed but relevant to its rendering correctness on cheap devices

*Confidence: high, **LOAD-BEARING***

Impeller is default on Android API 29+ and preferentially uses Vulkan (needs Vulkan 1.1+); API 28 and below, or devices without Vulkan, unconditionally fall back to OpenGL ES. On iOS Impeller is the only renderer — Skia cannot be re-enabled. For a static grid the renderer choice has no measurable perf impact. BUT the GL fallback path has open rendering bugs: flutter/flutter#179268 (gradients rendered incorrectly after Vulkan→GLES fallback) and #177873 (SVG/vector-graphics crash or corruption after GLES fallback). A budget/old device is exactly the population that lands on the fallback.

- https://docs.flutter.dev/perf/impeller

- https://github.com/flutter/flutter/issues/179268

- https://github.com/flutter/flutter/issues/177873

- https://github.com/flutter/flutter/issues/151240

### Memory is irrelevant EXCEPT for one thing: user-imported tile images must be downscaled at import, not at render

*Confidence: high, **LOAD-BEARING***

12 tiles, no lists, no animation → no memory pressure from Flutter. But images are user-supplied files on disk. A 12MP phone photo decodes to ~48MB in RAM (4000×3000×4 bytes). Twelve of those is ~576MB of image cache — an OOM kill on a 2GB device. Flutter's ImageCache default is 1000 entries / 100MB, which does not save you because it evicts by count/bytes AFTER decode. The fix belongs at import time: re-encode the picked image to tile-sized (e.g. max 512px) and write THAT to disk, so the DB path points at a small file forever. Render-time cacheWidth/ResizeImage is a weaker second line of defense. With no telemetry, an OOM kill is a bug the developer will never learn about.

### const constructors do not matter for performance at 12 tiles, but the lint is still worth enabling for two non-performance reasons

*Confidence: high*

Mechanism (worth stating correctly since it's a code standard): const expressions are canonicalized at compile time, so two identical const Widget instances are the SAME object. In Element.updateChild, the framework checks `child.widget == newWidget` and, when true, skips rebuilding that subtree entirely — const-ness makes that check true for free via identity. Const objects also live in the AOT snapshot's read-only data rather than being heap-allocated at runtime, a marginal startup/allocation win. At 12 tiles rebuilt approximately never (zero animation!), the runtime saving is unmeasurable. Keep `prefer_const_constructors` anyway because (a) it's zero-effort — the analyzer writes it for you, and (b) const is a readability signal to the stranger who inherits this repo: 'this widget has no dynamic inputs'. Do not spend a single minute hand-tuning const-ness.

### Icon-font tree shaking is automatic but silently disabled by dynamically-constructed IconData

*Confidence: medium*

flutter build tree-shakes icon fonts by default (build output prints e.g. 'Font asset MaterialIcons-Regular.otf was tree-shaken, reducing it by 99.4%'). It is disabled by --no-tree-shake-icons, and it BREAKS — the build errors or you must pass --no-tree-shake-icons — if IconData is constructed non-const (e.g. IconData(userSelectedCodePoint)). An edit mode offering an icon picker is exactly the shape of code that trips this, costing ~1.5MB. Mostly moot here since the decision is images-on-disk, but it's the trap to know if an icon picker is ever added.

- https://docs.flutter.dev/perf/app-size

### Baseline Flutter Android release size is ~5–8MB (arm64); the app's own code is noise, and the sherpa_onnx/Kokoro path multiplies total size ~8x

*Confidence: medium, **LOAD-BEARING***

A minimal Flutter arm64 release APK is roughly 5–8MB (engine + Dart AOT snapshot + ICU data); Play-served download after AAB splitting is smaller. This app's Dart code, drift, and riverpod add maybe 1–2MB. So baseline ≈ 7–10MB. Adding sherpa_onnx + Kokoro-82M (+55MB) takes it to ~65MB — a ~7-8x increase. Critically, ONNX model files are architecture-independent assets, so AAB ABI splitting does NOT reduce them: every user downloads the full 55MB. On the target audience's cheap, storage-constrained phone this is an install-time barrier, and the offline promise forbids downloading it later.

- https://docs.flutter.dev/perf/app-size

- https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/index.html

- https://github.com/k2-fsa/sherpa-onnx

### Battery/thermal is a non-issue for platform TTS and a real-but-bounded issue only for the neural path

*Confidence: medium*

Platform flutter_tts hands synthesis to a system service, often hardware-accelerated, for 2–5 second utterances triggered a few times an hour — energy cost is negligible and not worth measuring. The sherpa_onnx/Kokoro escape hatch runs an 82M-parameter model on CPU per utterance. For short, bursty utterances thermal throttling is not a realistic concern (throttling needs sustained load); the real cost is the ~80MB model resident in memory and a multi-hundred-ms model load on first use, which reintroduces both a memory floor and a warm-up requirement that the platform path doesn't have. sherpa-onnx's own Android guidance recommends ~500MB free storage and ARM64.

- https://github.com/k2-fsa/sherpa-onnx

- https://github.com/k2-fsa/sherpa-onnx/discussions/3383

### DevTools rebuild profiling, frame charts, and the Timeline are not worth learning for this app

*Confidence: high, **LOAD-BEARING***

The Performance view's value is the Flutter frames chart (finding >16ms frames), Frame analysis (jank hints), Track widget builds / Track layouts / Track paints, and rendering-layer toggles (Clip/Opacity/PhysicalShape). Every one of these exists to diagnose jank during animation or scrolling. This app has zero animation, no scrolling, and 12 widgets. There are no frames to analyze after the first one. The ONE DevTools feature with real value here is the App Size tool (a different screen entirely), used to read the --analyze-size JSON.

- https://docs.flutter.dev/tools/devtools/performance

- https://docs.flutter.dev/perf/app-size

### Debug-mode performance numbers are meaningless and profiling must happen on a physical low-end device

*Confidence: high, **LOAD-BEARING***

Flutter docs are explicit: 'Using debug mode, or running apps on simulators or emulators, is generally not indicative of the final behavior of release mode builds.' Debug uses JIT, enables asserts, and skips AOT snapshot loading — the exact mechanism being measured at startup. Profile mode compiles nearly identically to release but retains tracing hooks. Compounding this for THIS app: the flutter_tts startup delay is reported as NOT reproducible on emulator — so the single biggest latency term is invisible on the developer's fastest, most convenient test target.

- https://docs.flutter.dev/perf/ui-performance

- https://docs.flutter.dev/testing/build-modes

- https://github.com/dlutton/flutter_tts/issues/235

### The drift DB open — not the widget tree — is the only plausible Flutter-side first-frame blocker, and only via migration

*Confidence: medium, **LOAD-BEARING***

Reading 12 grid_slots rows is sub-10ms and can safely be awaited. The risk is a MIGRATION running on a hand-curated board on first launch after an update: that is unbounded work on the path to first speech, and it is the one startup case that could plausibly cross seconds. This intersects the 'botched migration = loss of voice' constraint. The practice is not 'make migration fast' — it's 'migration must never be on the QS-tile speech path', which the SharedPreferences design already guarantees, and 'the app path shows the grid shell immediately rather than a blank window while migrating'.

## Recommendations

- **[must]** Define the ONE performance metric as 'tap → audible speech', not 'time to first frame', and write it in the README.
  - The product premise is instant speech, not instant pixels. Optimizing first frame while a 3-second TTS bind sits behind it is measuring the wrong thing. Naming the real metric is what stops the developer from doing irrelevant Flutter perf work.
- **[must]** Warm the TTS engine asynchronously on app start: fire an init (and optionally a zero-volume or empty-string speak) from the first frame callback, never awaited on the path to rendering.
  - Android TextToSpeech service binding is documented at 1–5+ seconds on real devices and is the single largest latency term. Warming it during the seconds the user spends looking at the grid moves that cost off the critical path. Must not block first frame — that would trade an invisible delay for a visible one.
- **[must]** Add <queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries> to AndroidManifest.xml and add a test/checklist item asserting voices are non-empty on a real device.
  - Android 11+ package visibility silently hides the TTS engine without this declaration. Combined with flutter_tts's habit of failing with only a Log.d, the failure mode is exactly the 'user taps a tile and nothing happens' class this project treats as the worst bug.
- **[must]** Treat the SharedPreferences mirror that the QS TileService reads as a write-through cache, and test that every board edit updates it.
  - The QS tile is the fastest path to speech in the product because it bypasses the Flutter engine entirely. Its correctness depends on a mirror that can silently drift from the drift DB. With no telemetry, a stale mirror means the tile speaks a phrase the user deleted months ago and no one ever finds out.
- **[must]** Downscale user-imported images to tile size (max ~512px) at import time and store the resized file on disk; never store or decode the original.
  - A 12MP photo decodes to ~48MB; twelve tiles is an OOM kill on a 2GB device. Fixing it at import makes the problem structurally impossible forever, the same way (board_id,row,col) makes reflow impossible. Fixing it at render time (cacheWidth) leaves the original on disk and the bug one refactor away. An OOM crash is invisible without telemetry.
- **[must]** Measure cold start exactly once before release, on the cheapest physical Android device available, with: `flutter run --profile --trace-startup` (reads build/start_up_info.json) cross-checked against `adb shell am start -W -n <pkg>/.MainActivity` and the logcat 'Fully drawn' line. Record the numbers in the README and stop.
  - start_up_info.json starts its clock at engine-enter and misses process spawn + native lib load, so it flatters the result; am start -W and Fully drawn give the user-perceived number. This is a one-time verification event, not an ongoing practice — the Android vitals 'excessive' bar is 5s and this app will land near 1s. Recording it in the README is what lets a stranger notice a future regression.
- **[must]** Profile only in --profile mode on a physical device. Never draw a performance conclusion from debug mode or an emulator.
  - Flutter docs state debug/emulator numbers are not indicative of release behavior — debug uses JIT and skips the AOT snapshot load that startup measurement is entirely about. Worse for this app specifically: the flutter_tts bind delay reportedly does not reproduce on emulator, so the dominant latency term is invisible on the most convenient test target.
- **[should]** Use flat, solid-color tiles. Avoid gradients, SVG, and vector graphics in the grid.
  - Devices below API 29 or without Vulkan 1.1 fall back to Impeller's OpenGL ES backend, which has open bugs for gradient rendering (#179268) and SVG/vector corruption (#177873). That fallback population is exactly the budget-device audience. This is a rendering-correctness rule, not a speed one, and it happens to align with the zero-animation/deterministic-UI design rule at no cost.
- **[should]** Enable prefer_const_constructors in analysis_options.yaml, let the analyzer apply it, and never think about const again.
  - The mechanism is real — const canonicalization makes Element.updateChild's `child.widget == newWidget` check true by identity and prunes the rebuild, and const objects live in the snapshot's read-only data rather than the heap. But at 12 widgets rebuilt essentially never, the runtime saving is unmeasurable. Keep it as a zero-cost lint and a readability signal for the stranger inheriting the repo, not as a performance activity.
- **[should]** Run `flutter build apk --analyze-size --target-platform android-arm64` once, load the emitted JSON into DevTools' App Size tool, and record the baseline in the README.
  - Establishes the ~7–10MB baseline as a documented fact so that any future dependency that doubles it is visible to whoever inherits the project. This is the only DevTools screen with real value for this app; the Performance view exists to diagnose jank that a zero-animation 12-tile grid cannot have.
- **[should]** Show the grid shell immediately on launch; never gate the first frame on a drift migration.
  - A 12-row read is sub-10ms and safe to await, but a migration over a hand-curated board is unbounded work sitting between the user and their voice. The QS-tile/SharedPreferences path already sidesteps this structurally; the app path just needs to not present a blank window while migrating.
- **[should]** If the sherpa_onnx/Kokoro path is ever taken, ship it as a separate build/flavor rather than adding 55MB to the default app, and load the model lazily with a warm-up on first launch.
  - ONNX models are architecture-independent assets, so AAB ABI splitting does not shrink them — every user downloads all 55MB, ~7-8x the baseline, on the storage-constrained phones this audience actually owns. The offline promise forbids fetching it later. The neural path also reintroduces a memory floor and a model-load warm-up that the platform TTS path doesn't have.
- **[avoid]** Do NOT use deferred components.
  - They require Play Core, FlutterPlayStoreSplitApplication, a PlayStoreDeferredComponentManager injection, and runtime delivery from Google Play — a network dependency that contradicts the privacy promise and breaks sideload/F-Droid distribution. The entire Dart app is a few hundred KB; there is nothing worth deferring.
- **[avoid]** Do NOT do shader warmup, SkSL caching, or anything involving --bundle-sksl-path / --cache-sksl-path.
  - Impeller precompiles shaders at engine-build time; runtime shader compilation does not exist. The flags were removed in Flutter 3.32+. Any blog post recommending this is stale — and a zero-animation app had no shader jank to warm up in the first place.
- **[avoid]** Do NOT add RepaintBoundary, do NOT hand-scope rebuilds with Consumer/select for performance, do NOT use GridView.builder for 12 tiles, and do NOT learn DevTools' Track Widget Builds / frame charts.
  - Every one of these is a jank remedy, and a static 12-tile grid with zero animation renders one frame and then stops. There is no frame budget to miss. Riverpod's seam is already justified on testability grounds — do not retroactively justify it on performance grounds or optimize against it. This is the single largest category of wasted time available to this project.
- **[avoid]** Do NOT set up continuous performance benchmarking, startup regression tests in CI, or integration_test traceAction/TimelineSummary harnesses.
  - Proportionality: a solo dev with 2 weeks gets far more safety from migration tests and TTS-failure tests (where bugs are silent and catastrophic) than from guarding a startup number that sits ~3 seconds inside the Android vitals threshold. Startup is a one-command manual check before release. Spend the testing budget where the constraint document says the danger is.
- **[avoid]** Do NOT profile or optimize memory, battery, or thermals for the platform-TTS build.
  - 12 widgets, no lists, no animation, images already capped at import, and synthesis handed to a system service for 2–5 second utterances a few times an hour. There is no signal to find. The only memory rule that matters is the import-time image downscale, which is a data-model decision rather than a profiling activity.

### Measure cold start correctly (the only perf command this project needs)

```bash
# 1) Flutter's own view — clock STARTS at engine enter, so it UNDERCOUNTS.
#    Writes build/start_up_info.json
flutter run --profile --trace-startup

cat build/start_up_info.json
# {
#   "engineEnterTimestampMicros": 1234567,
#   "timeToFrameworkInitMicros": 120000,        # engine enter -> framework ready
#   "timeToFirstFrameRasterizedMicros": 380000, # engine enter -> pixels on GPU
#   "timeToFirstFrameMicros": 350000,           # engine enter -> first frame built
#   "timeAfterFrameworkInitMicros": 230000      # your main()/runApp cost. THIS is the only one you control.
# }

# 2) The user-perceived number — includes process spawn + libflutter.so load.
adb shell am force-stop com.example.aac
adb shell am start -W -n com.example.aac/.MainActivity
# Status: ok
# TotalTime: 842      <- initial display (window bg), ms
# WaitTime: 851

# 3) The REAL first-Flutter-frame number (reportFullyDrawn):
adb logcat -c && adb shell am force-stop com.example.aac \
  && adb shell am start -n com.example.aac/.MainActivity \
  && adb logcat -d | grep -i "Fully drawn"
# ActivityTaskManager: Fully drawn com.example.aac/.MainActivity: +1s102ms

# Run each 5x on a PHYSICAL low-end device. Discard the first (page cache cold).
# Record the median in the README and move on.
```

timeAfterFrameworkInitMicros is the only field you can influence — it is your main()/runApp work. If it is small, there is no Flutter startup work left to do, and further optimization is someone else's problem (Android, or the TTS engine).

### Warm TTS off the critical path — the highest-value perf code in the app

```dart
// The point: Android's TextToSpeech service bind can take seconds (flutter_tts#235).
// Pay that cost while the user is looking at the grid, NOT after they tap a tile.
// Rule: warming NEVER blocks the first frame and NEVER throws into the UI.

abstract class SpeechService {
  Future<void> warmUp();
  Future<void> speak(String text);
  Future<void> stop();
}

void main() {
  // Do NOT await anything here. Nothing between here and runApp().
  runApp(const AacApp());
}

class _AacAppState extends State<AacApp> {
  @override
  void initState() {
    super.initState();
    // Fires AFTER the first frame is on screen. The grid is already usable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_warm());
    });
  }

  Future<void> _warm() async {
    try {
      await ref.read(speechServiceProvider).warmUp();
    } catch (e, st) {
      // No telemetry exists. The on-device crash log is the ONLY record.
      await CrashLog.instance.record('tts warmUp failed', e, st);
      // Deliberately swallowed: a failed warm-up must not break the app.
      // The next speak() will retry and surface a VISIBLE failure if it can't speak.
    }
  }
}
```

Warm-up is best-effort and must fail silently; speak() must fail LOUDLY. Those are opposite error-handling policies on the same service, and that asymmetry is the whole design.

### Downscale at import — makes the OOM structurally impossible

```dart
// A 12MP photo decodes to ~48MB in RAM. Twelve tiles = ~576MB = OOM kill
// on a 2GB phone. With no telemetry, that crash is NEVER reported to you.
//
// Fix it ONCE at import so the DB path can only ever point at a small file.
// This is the same philosophy as PRIMARY KEY (board_id, row, col):
// make the bad state unrepresentable rather than defending against it at render time.

import 'package:image/image.dart' as img;

const _maxTileEdge = 512; // ~1MB decoded, worst case

/// Returns the on-disk path to store in the images table.
Future<String> importTileImage(File picked, String imagesDir) async {
  final bytes = await picked.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Unsupported image format');
  }

  final resized = (decoded.width > _maxTileEdge || decoded.height > _maxTileEdge)
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? _maxTileEdge : null,
          height: decoded.height > decoded.width ? _maxTileEdge : null,
          interpolation: img.Interpolation.average,
        )
      : decoded;

  final out = File('$imagesDir/${DateTime.now().microsecondsSinceEpoch}.webp');
  await out.writeAsBytes(img.encodeWebP(resized, quality: 85));
  return out.path; // never the original
}

// Worth a test: import a synthetic 4000x3000 image, assert the stored file
// decodes to <= 512px on its long edge. That test is your only OOM safety net.
```

Do this on a background isolate (Isolate.run) if import feels slow — but import is a rare, explicit, edit-mode action where a brief wait is acceptable. Do not pre-optimize it.

### Manifest: TTS engine visibility (Android 11+)

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest ...>
  <!-- Without this, package visibility HIDES the TTS engine on Android 11+.
       flutter_tts then returns an empty voice list with only a Log.d.
       Failure mode: user taps a tile mid-shutdown and NOTHING happens. -->
  <queries>
    <intent>
      <action android:name="android.intent.action.TTS_SERVICE" />
    </intent>
  </queries>

  <application ...>
    <!-- Impeller is default on API 29+ (Vulkan, GLES fallback below).
         Do NOT disable it. This meta-data is listed only so a future reader
         knows the escape hatch exists for bisecting a rendering bug:
    <meta-data android:name="io.flutter.embedding.android.EnableImpeller"
               android:value="false" /> -->
  </application>
</manifest>
```

The <queries> block is a one-line manifest change that prevents a total, silent loss of speech on every Android 11+ device. It is arguably the highest value-per-character code in the project.

### App size baseline (run once, record, move on)

```bash
flutter build apk --release --analyze-size --target-platform android-arm64

# Terminal summary, roughly:
#   Dart AOT symbols accounted decompressed size: 2.1 MB
#   lib/arm64-v8a/libflutter.so ......... 5.4 MB   <- engine, immovable
#   lib/arm64-v8a/libapp.so ............. 2.1 MB   <- YOUR code + drift + riverpod
#   assets/ ............................. 0.3 MB
#   Total ............................... ~8 MB
#
# Also prints:
#   Font asset MaterialIcons-Regular.otf was tree-shaken, reducing it by 99.4%
#   ^ automatic. Breaks if you ever construct IconData dynamically.

# Deeper view (the ONE DevTools screen worth opening for this app):
dart devtools   # -> "Open app size tool" -> load the emitted
                #    ~/.flutter-devtools/apk-code-size-analysis_01.json

# Record the total in the README. If a future dependency doubles it,
# whoever inherits this repo will notice.
```

Baseline is ~7-10MB and ~70% of it is the Flutter engine, which you cannot shrink. Do not chase app size; just document it so a regression is visible.

### analysis_options.yaml — the const rule, adopted for free

```yaml
# Adopt via lint, not via discipline or effort.
# Mechanism (why const is a real thing, even though it doesn't matter HERE):
#   const expressions are canonicalized at compile time -> identical const
#   widgets are the SAME object -> Element.updateChild's `child.widget == newWidget`
#   check is true by identity -> the framework skips rebuilding that subtree.
#   const objects also live in the AOT snapshot's read-only data, not the heap.
#
# Why it does NOT matter here: 12 tiles, zero animation, rebuilt ~never.
# Why we keep it anyway: the analyzer applies it for us (`dart fix --apply`),
# and const tells the stranger inheriting this repo "no dynamic inputs".

include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables

# NOT here on purpose: no custom perf lints. There is no perf problem to lint for.
```

`dart fix --apply` does the whole job. Budget for const optimization: zero minutes.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PROJECT THESE PRACTICES ARE FOR ===

An offline AAC (augmentative & alternative communication) app for autistic adults with situational/part-time speech loss. Flutter, Android-first, iOS later. Solo developer. Today is 2026-07-15; Flutter stable is 3.44.0, Dart 3.x.

The app: ONE screen — a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface + on-device TTS. A "show text" full-screen mode. An explicit edit mode. Settings (voice/pitch/rate/output mode/theme). No accounts, no server, no network.

DECISIONS ALREADY MADE (from a prior deep research pass — do not re-litigate these, design practices AROUND them):
- **drift** (SQLite) for local DB. Schema: boards / buttons / grid_slots / images / sounds / settings. Critically, `grid_slots` has PRIMARY KEY (board_id, row, col) with a NULLABLE button_id — position IS the primary key, so tile reflow is structurally impossible. Data model borrows Open Board Format semantics (label != vocalization: the tile SHOWS "Overwhelmed" but SPEAKS "I need to leave, I'm not able to talk right now").
- **flutter_riverpod** for state — explicitly acknowledged as NOT load-bearing (12 tiles and a text field; ValueNotifier would work). Chosen for a testable seam between repository and UI, and to react to MediaQuery a11y flags + TTS voice-availability changes.
- **flutter_tts** wrapped behind an abstract `SpeechService` (speak/stop/voices), with a `voice_filter` (Android network_required check + setVoice return-value check — flutter_tts returns 0 with only a Log.d on failure, which would silently give a user in crisis NO SPEECH) and an `audio_session` config (iOS .playback + duckOthers; NEVER .ambient).
- Native platform channels needed for: Personal Voice (iOS), an Android Quick Settings TileService (Kotlin, speaks natively from SharedPreferences with NO Flutter engine on that path), an iOS 18 ControlWidget (Swift).
- Images/sounds are FILES ON DISK with paths in the DB, never BLOBs.

=== THE CONSTRAINTS THAT MAKE THIS PROJECT'S ENGINEERING UNUSUAL ===

1. **NO TELEMETRY, EVER.** No Firebase, no Crashlytics, no Sentry, no analytics — the privacy promise forbids it and the audience reads privacy labels adversarially. THE DEVELOPER WILL NEVER LEARN THAT THE APP CRASHED IN THE FIELD. Tests are the ONLY safety net. This should raise the bar on testing dramatically and change what is worth testing. There is a planned on-device-only, user-exportable crash log.
2. **A BOTCHED DB MIGRATION IS THE LOSS OF SOMEONE'S VOICE.** Users hand-curate phrase boards over months; that data is irreplaceable and unmergeable. Migration testing is a safety property, not hygiene.
3. **ACCESSIBILITY IS CORRECTNESS, NOT POLISH.** An inaccessible accessibility app is a total failure. Semantics on every tile; iOS Switch Control / Android Switch Access / VoiceOver / TalkBack must work; TextScaler must be honored at 200%+ and never clamped. This must be enforced by TESTS and lints, not by discipline.
4. **A SILENT FAILURE IS THE WORST BUG CLASS.** An unchecked setVoice return, a voice that vanished, an audio session misconfigured to .ambient so the silent switch mutes the app — each means a user taps a tile mid-shutdown and NOTHING happens. Error handling must make silence impossible.
5. **The developer may abandon this** (it is app #N of a 50-app challenge). The offline architecture means it keeps working unmaintained; open-sourcing is the exit plan. So the code must be READABLE BY A STRANGER and the docs must let someone else pick it up.
6. **Solo dev, ~2-week MVP.** Practices must be proportionate. Ceremony that a team needs and a solo dev doesn't is a real cost. Be honest about what to SKIP.
7. Zero animation is a design rule (distress + latency). Deterministic UI.

Today's date: 2026-07-15. Prefer 2025-2026 sources. Flutter and its ecosystem move fast — a 2022 blog post is probably wrong.


YOUR DIMENSION: Flutter performance practices that matter for THIS app, and how to verify them.

Research with WebSearch/WebFetch: docs.flutter.dev/perf, Impeller docs, Flutter DevTools docs, app size docs.

Be RUTHLESS about relevance: this app is a static 12-tile grid with zero animation. Most Flutter perf advice (list virtualization, jank, shader warmup, repaint boundaries) may be irrelevant. Say what's irrelevant and don't pad.

What genuinely matters:
- **Cold start / time-to-first-word.** The product's premise is instant speech. What actually dominates Flutter cold start in 2026 (process spawn, engine init, Dart VM, first frame)? What can a developer actually control? Deferred components? What's the realistic floor on a $120-150 Android phone? How do you MEASURE it properly (`flutter run --trace-startup --profile`, the timeline events `timeToFirstFrameMicros`, DevTools)? Give the actual command and how to read the output.
- Is there anything to be done about TTS engine init latency at app start (warm-up)?
- **const constructors and rebuild scoping** — do they matter at 12 tiles? Honest answer, but explain the mechanism properly since it's a code standard.
- Widget rebuild profiling in DevTools — worth learning here?
- **App size**: `flutter build apk --analyze-size`, what's in a baseline Flutter Android app, tree shaking of icon fonts, and what the sherpa_onnx/Kokoro escape hatch (+55MB) would do to it.
- Impeller: current state on Android in 2026 (default on API 29+? Vulkan fallback?), does it matter for a static grid?
- Battery/thermal — relevant only for the neural TTS path?
- Memory — irrelevant here? Say so.
- **What performance work should this project explicitly NOT do?** Be specific — a solo dev has 2 weeks.
- How do you profile a release build correctly (`--profile` mode, never debug)?
- DevTools features actually worth knowing for this app.

Prioritize hard. The honest answer may be "almost none of this matters except cold start" — if so, say it and go deep on that instead of padding.
````

</details>
