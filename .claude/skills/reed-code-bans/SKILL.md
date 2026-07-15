---
name: reed-code-bans
description: The permanent banned list for Reed and why each exists — no INTERNET permission or http/dio, no Firebase/Sentry/analytics, no google_fonts or dynamic_color, no Card/elevation/BoxShadow/BackdropFilter, no runZonedGuarded, dynamic, print, pumpAndSettle, or LLM phrase generation. Use when adding a pubspec dependency or import, editing AndroidManifest permissions, reaching for InkWell, or asking whether a construct is allowed. Not for version ranges or lockfiles, analyzer config, authoring the enforcing test, or privacy wording.
---

# Reed — the permanent banned list

Every entry below is decided. None is a style preference; each closes a failure mode that this app cannot survive. When a ban looks like over-caution, read its reason — the reason is what stops the next reader from "cleaning it up."

Bans are permanent. Re-litigating one costs more than obeying it. If a ban must fall, it falls with a written reason at the point of temptation, not silently in a diff.

---

## 1. Network — the promise is the product

| Banned | Enforced by |
|---|---|
| `package:http`, `dio`, `HttpClient`, `Socket`, `WebSocket`, any `Uri` fetch | Review + `pubspec.yaml` review |
| `<uses-permission android:name="android.permission.INTERNET"/>` | The manifest has no `INTERNET` line. Adding one is the review gate |
| Any transitive dependency that opens a socket | `pubspec.lock` review before every merge |

The privacy claim is not marketing copy, it is *"no internet permission — that's not a promise, it's a fact you can check."* A user can verify it from the app listing's permission list. Play's Data Safety card is developer **self-declared** and proves nothing; the manifest-derived permission list is the only fact anyone can point at. One `INTERNET` line deletes the only verifiable claim the product has.

Corollary: never say Google verified the privacy story. Say the manifest has no `INTERNET`.

---

## 2. Telemetry and crash SDKs

| Banned | Enforced by |
|---|---|
| Firebase (any module), `firebase_core`, Crashlytics, Sentry, any analytics SDK | Absent from `pubspec.yaml`; adding it is the review gate |

**Crashlytics-only is worse than Sentry, not better.** Crashlytics cannot be added without `firebase_core`, and Firebase core declares *additional* data categories on its own — so the store nutrition label lists **more** collection with a Crashlytics-only build than with Sentry. Anyone who reasons "just crash reporting, it's minimal" has the ordering backwards.

Sentry is the milder option — diagnostics only, no ad ID, no user ID, no analytics — and it is still banned, because data leaves the device and the no-network claim evaporates the moment it does. The audience reads privacy labels adversarially; that is why they chose this app.

Two consequences that follow and must not be "fixed":

- **`runZonedGuarded` is banned.** The "you need all three error handlers" advice circulating today is *crash-SDK advice* — Sentry needs a zone because it wraps its own init. With no SDK, the zone buys nothing and costs a documented zone-mismatch footgun. Use exactly two handlers: `FlutterError.onError` and `PlatformDispatcher.instance.onError`.
- **The on-device crash log is the entire field signal.** It is synchronous, size-bounded, user-exportable, and incapable of throwing. Nothing replaces it.

---

## 3. Dependencies

| Banned | Why | Enforced by |
|---|---|---|
| `google_fonts` | Fetches over HTTP at runtime **by default**. It can be forced offline, but that still ships an HTTP client and a network code path into an app whose premise is zero network surface. Declare the font under pubspec `fonts:` instead — greppably verifiable, which is the whole point | `pubspec.yaml` review |
| `dynamic_color` / Material You | A wallpaper-derived palette is **untestable at build time**. The contrast matrix in CI is computed against known hexes; a palette derived on-device from an image nobody has seen deletes every guarantee that gate provides. `harmonize` does not save it — it perturbs exactly the tested pairings. Secondary: colour stability is part of the retrieval mechanism; a board whose colours shift because the wallpaper changed breaks position/colour learning | `pubspec.yaml` review |
| `provider`, `custom_lint`, `freezed`, `equatable`, `fpdart`, `dartz`, `go_router`, `melos`, `glados`, `figma_squircle`, `smooth_corner`, `mesh`, `mesh_gradient` | Redundant or dead weight at this size. `freezed` in particular duplicates output drift's generator already emits per table | `pubspec.yaml` review |
| Any `--enable-experiment` flag | An abandoned repo that needs an experiment flag to build stops building | `pubspec.yaml` review |

---

## 4. Motion

**No transition over ~100ms. In practice: none at all.** No page transitions, theme crossfades, ink ripples, shape morphs, spring physics, bounce, parallax, shimmer, skeletons, pulses, or celebration. `MediaQuery.disableAnimationsOf` and `accessibleNavigation` resolve to **zero duration, never "gentler."**

Two reasons, both load-bearing. Animation costs latency in a product whose entire premise is instant speech. And sudden visual movement is named directly by distressed-user and trauma-informed guidance as a fight-or-flight trigger in a sensitized nervous system.

Enforced by a test asserting `tester.binding.hasScheduledFrame == false` after a single `pump()` following a tap. That test is the only thing that catches a stray `InkWell`.

```dart
// WRONG — InkWell animates. splashFactory: NoSplash.splashFactory kills only
// the SPLASH; InkResponse.updateHighlight() independently creates an
// InkHighlight with a 200ms pressed fade.
InkWell(onTap: onTap, child: face)

// RIGHT — no ink, no animation, no second frame scheduled.
GestureDetector(
  behavior: HitTestBehavior.opaque, // the whole cell is the target
  onTap: onTap,
  child: face,
)
```

Belt and braces at the app level, because `MaterialApp` mounts `AnimatedTheme` and interpolates `ThemeData` over the 200ms default: set `themeAnimationStyle: AnimationStyle.noAnimation`, `splashFactory: NoSplash.splashFactory`, and a `PageTransitionsBuilder` whose `buildTransitions` returns `child` unchanged.

---

## 5. Surface and shape

| Banned | Why | Enforced by |
|---|---|---|
| `Card`, `elevation:` > 0, `BoxShadow`, bevels, long shadows, neumorphism, glassmorphism | Depth comes from tonal steps and the keyline. Shadows vanish entirely under the high-contrast theme; tonal steps survive it. A card is the 2014 enterprise grid — shadow + rounded rect + centred content *is* the failure mode | `grep -rn 'elevation:\|BoxShadow\|Card(' lib/` |
| `BackdropFilter`, blur, translucency, `Opacity` widget, `ShaderMask` | Contrast over arbitrary content is **non-certifiable by construction** — a ratio cannot be asserted against a background nobody controls. For an app whose CI gate *is* a contrast matrix, translucency deletes the gate. This argument does not decay with engine releases; the performance argument does, so do not lead with it | `grep -rn 'BackdropFilter\|Opacity(\|ShaderMask' lib/` |
| `ContinuousRectangleBorder` | Not an iOS-grade squircle: its radius must be multiplied by ~2.3529 to approximate one, that multiplier makes it degenerate into a "TIE fighter" *earlier* — at exactly the radii this app wants — and it centres strokes regardless of `strokeAlign`. Use `RoundedSuperellipseBorder`; for the text field use `ShapedInputBorder` (`RoundedSuperellipseInputBorder` does not exist and will not compile) | `grep -rn 'ContinuousRectangleBorder' lib/` |
| `Border.all()` | Defaults to 1.0 *logical* px = 3 physical px on a 3× phone. That is a rule, not a hairline. Use `1.0 / MediaQuery.devicePixelRatioOf(context)` | `grep -rn 'Border.all(' lib/` |
| Gradients of any kind, grain, noise, dividers | Flat opaque dyed fields and space, not lines and ramps | Review |

---

## 6. Code-level bans

| Banned | Why | Enforced by |
|---|---|---|
| `print` / `debugPrint` in `lib/` | Use the on-device exportable crash log. The one exception is the `kDebugMode` branch inside the global error handler | `avoid_print: error` |
| `dynamic` and dynamic calls | Everything from a platform channel arrives as `Map<Object?, Object?>`. An unguarded dynamic call throws at runtime, on a device, with no telemetry to tell anyone. Parse via `tryParse`, never cast | `avoid_dynamic_calls: error`, `cast_nullable_to_non_nullable: error` |
| `pumpAndSettle` in tests | Zero animation means one frame settles it, so `pumpAndSettle`'s only job is waiting out animations that do not exist. It adds a 10-minute-timeout flake vector with truncated traces. **Caveat: `pump()` does not advance the fake clock** — time-based async needs `pump(duration)` | Grep test over `test/` |
| `MediaQuery.withClampedTextScaling`, `textScaleFactor` | The one-line "fix" a future contributor reaches for when an overflow test goes red. It silently defeats the entire text-scale matrix while contrast and tap-size still pass | Source-grep test over `lib/` |
| `TextOverflow.ellipsis` on a phrase label | Turns "the label doesn't fit at 200%" from a loud test failure into a truncated word a user in crisis cannot read. Fix the layout; never hide the overflow | Review |
| `default:` / `case _:` on a sealed type | Disables the only compiler-grade safety net available. A `default:` makes a non-exhaustive switch compile | Review — no lint can see this |
| `assert` on a platform return value | Stripped in release. Green in every test, absent on the user's device — the perfect silent-failure bug | Review |
| `throw e` inside a catch | Resets the stack to the rethrow line. With no crash reporting, the trace in the on-device log is the *entire* forensic record. Use `rethrow` | Review |
| A `Map`-backed `FakeBoardRepository` | It accepts rows the real `PRIMARY KEY (board_id, row, col)` rejects and never runs a migration step. Test against `NativeDatabase.memory()` — real sqlite3 | Review |
| `containsSemantics` | Deprecated. Use `isSemantics` | `deprecated_member_use: warning` |
| `overrideValue` | Does not exist. It is `overrideWithValue` | compiler |

The three source-grep tests are ~10 lines each and exist because **no lint can do this**. That is not a workaround; it is the only enforcement available. Never delete one to make a build green.

**CI must build, not merely analyze.** `analyzer: errors: non_exhaustive_switch_statement: ignore` silences `dart analyze` while `dart compile` still fails — so an analyze-only gate can pass on code that cannot ship.

---

## 7. Product bans — features that are never built

These are not backlog items. They are decided against, permanently.

**LLM phrase generation** (expanding `"hurt loud leave"` into a sentence). It puts words in a disabled person's mouth — the AAC community's oldest and deepest objection; misrepresentation is a worse dignity harm than slowness. Nondeterminism in a crisis tool is terrifying: the user must know **exactly what will be said before it is said**. A plausible-but-wrong sentence in an emergency room is dangerous. And it is a *regulatory* decision, not a feature decision — the speech-generating-device exemption is void for a device that "operates using a different fundamental scientific technology," which tap-a-tile and type-to-speak are not, and generation plausibly is. What the evidence supports is pre-stored conversation scripting, not generation.

**Content filtering on what the user may say.** Filtering a disabled person's own speech is precisely the paternalism the product exists to oppose. The misuse risk is identical to any keyboard, or to the OS's own live-speech feature. Do not add a word list, a profanity guard, or a "are you sure" confirmation on an utterance.

**A caregiver or parent account.** Along with parental gates, PINs, locked settings, and any parent/caregiver framing in copy. The board belongs to the person who speaks with it.

**Cloud sync, board sharing, import-from-URL.** This is **one feature away from importing the whole user-generated-content regime.** Store obligations — filter content posted to the app, provide a reporting mechanism, block abusive users, publish contact information — all presuppose content reaching another user. A local-only free-text field presupposes none of them, which is why the content rating is the lowest tier and the data disclosures are empty. Adding sharing costs moderation + reporting + blocking + published contact info + data disclosures, forever, on a solo project. Durability is served instead by a **user-initiated export in settings** — the user asks for it, sees it, and controls it.

---

## 8. Before merging anything that touches this list

Run the greps. They are the enforcement, not a formality:

```
grep -rn 'http\|dio\|Socket\|HttpClient' lib/ pubspec.yaml
grep -rn 'INTERNET' android/app/src/main/AndroidManifest.xml
grep -rn 'elevation:\|BoxShadow\|BackdropFilter\|ContinuousRectangleBorder\|Border.all(' lib/
grep -rn 'withClampedTextScaling\|textScaleFactor\|TextOverflow.ellipsis' lib/
grep -rn 'pumpAndSettle' test/
```

A green analyzer is not proof of any of this. Nobody will ever report that a ban was broken in the field — a user who cannot speak does not file a bug report.
