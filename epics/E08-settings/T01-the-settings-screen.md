# E08-T01 — The settings screen

| | |
|---|---|
| **Epic** | E08 — Settings |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E03-T03 |
| **Blocks** | E08-T02, E08-T03, E08-T04 |

**Skills:** `reed-widget-conventions` · `reed-copy-voice` · `reed-a11y-coding` · `reed-riverpod-usage`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Settings is where a user turns off the thing that is currently hurting them. Someone in sensory overload cannot navigate a tree of sections, sub-pages and disclosure triangles to find the switch that stops an irritant — every level of nesting is a decision demanded of the person whose decision-making is exactly what is impaired. It is also where `Keep my board off cloud backup` lives, which for a user whose adversary has access to their phone account is a safety control, not a preference. This screen is flat, adult, and one tap deep.

## Scope

One route, one flat scrollable column of controls. No `ExpansionTile`, no sub-pages, no grouped cards with headers that hide anything, no search. Every control is visible by scrolling and reachable in one tap from settings.

**The controls, with the exact copy.** Names first, prose only where a name is insufficient:

```
theme: ink
Tiles: 12 · 6
Show screen: bright · match my theme
Keep my board off cloud backup
Restore previous board
```

- **`theme: ink`** — shows the *current* palette and cycles on tap. `semanticLabel: 'Theme: ink. Tap to change.'` — sentence case in the semantic label even though the visible chrome is lowercase, because a screen reader speaks a sentence.
- **`Tiles: 12 · 6`** — a segmented choice, both options visible, no dropdown.
- **`Show screen: bright · match my theme`** — same shape.
- **`Keep my board off cloud backup`** — blunt on purpose. Do not soften it to "backup preferences" or "privacy".
- **`Restore previous board`** — a labelled control, not a hidden gesture.

**Chrome case is authored, not computed.** The lowercase strings are lowercase literals in the string table. A `.toLowerCase()` in a widget survives into a code path that eventually renders a user's phrase, and then Reed lowercases someone's name. Zero `.toUpperCase(` / `.toLowerCase(` in this diff.

**One-tap-from-the-grid rule.** Anything a user in overload might need to turn OFF must be operable from the main screen, not from inside settings. The theme cycle is the concrete case: `theme: ink` is main-screen chrome that cycles on tap. Settings mirrors it; settings does not own it. If a control's only home is this screen, ask whether it is something an overloaded user needs to stop — if yes, it belongs in the main-screen chrome and this screen shows the same state.

**Widgets.** Each control is its own `StatelessWidget` class, not a `Widget _buildThemeRow(BuildContext)` method — a method's subtree has no `Element` of its own and `find.byType` cannot reach it in a test, and tests plus the analyzer are the entire feedback loop here. Taps are `GestureDetector` + `HitTestBehavior.opaque`, never `InkWell`/`InkResponse` (`splashFactory: NoSplash.splashFactory` kills only the splash — `InkResponse.updateHighlight()` independently creates an `InkHighlight` with a 200ms pressed fade and schedules a second frame). No `onLongPress`, no `onDoubleTap`, no `Dismissible`, no `Draggable`. No keys — `ValueKey((row, col))` is a grid thing; nothing here is in a reorderable list. No `GlobalKey`, ever.

**Semantics.** Every control: `Semantics(container: true, button: true, label: ...)` around the gesture, with the visual face wrapped in `ExcludeSemantics` so the label is not announced twice. Every `Icon`/`Image` gets a `semanticLabel` or an `ExcludeSemantics` — there is no third option. Assert with `isSemantics(...)`, never `containsSemantics(...)` (deprecated after v3.40.0-1.0.pre).

**Text scale.** `MediaQuery.boldTextOf(context)` and `MediaQuery.highContrastOf(context)` are read from `BuildContext` at build time — never routed through Riverpod. `textScaler` is never read and never clamped. No `MediaQuery.withClampedTextScaling`, no `textScaleFactor`, no `FittedBox`, no `TextOverflow.ellipsis` on any label. Rows are intrinsic height and wrap; the column scrolls.

**Riverpod.** Read the persisted settings row via the existing repository provider chain; `ref.watch` in `build()`, `ref.read` inside `onTap` callbacks. Do not add a provider for this screen if the value can be a constructor argument — provider count going up is a smell, not progress. No `family`, no `StateProvider`, no `@riverpod` codegen. Write handlers are void-returning methods on the controller, never `onTap: () => repo.setTheme(x)` returning a `Future` into a `VoidCallback` — that hole is flagged by neither `discarded_futures` nor `unawaited_futures`, and it is the silence bug.

**Out of scope:** the wiring of what each control actually does (E08-T02), the show screen itself, the editor, any "about"/licences page, any onboarding, any import/export UI.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] Widget test: `find.byType(SettingsScreen)` renders all five controls at `TextScaler.linear(2.0)` with no overflow exception and no `ellipsis`.
- [ ] Widget test asserts each control's node with `isSemantics(button: true, label: ...)`; the theme control's label is exactly `Theme: ink. Tap to change.` when the palette is ink.
- [ ] Widget test: `tester.binding.hasScheduledFrame` is `false` after a single `pump()` following a tap on any control.
- [ ] `grep -rnE "toUpperCase\(|toLowerCase\(|withClampedTextScaling|textScaleFactor|FittedBox|TextOverflow.ellipsis|InkWell|InkResponse|GlobalKey|ExpansionTile" lib/ui/settings/` returns nothing.
- [ ] `grep -rniE "!|sorry|oops|caregiver|parent|guardian|student|learner|please|great|just |simply|we " lib/ui/settings/` — every hit reviewed and justified; no exclamation mark survives in any user-visible string.
- [ ] Every user-facing apostrophe in the diff is `’`, not `'`.
- [ ] Reaching every control from the settings route takes zero navigations: no child route is pushed from this screen.
- [ ] The theme control is operable from the main screen without opening settings.

## Traps

- **Nesting arrives as "organisation".** Five controls look untidy in a flat list, so someone groups them into `ExpansionTile`s. Now the collapsed group holds the control that stops the irritant, and a user in overload has to guess which group. Untidy and reachable beats tidy and buried.
- **`.toLowerCase()` on the chrome labels.** It looks like it enforces the lowercase rule. It is a rule about *all* text, and the same helper eventually renders a user's phrase or someone's name. Author the case in the literal.
- **`InkWell` because it is the Flutter default for a settings row.** It animates. `NoSplash.splashFactory` does not save it — the highlight fade is a separate 200ms animation that schedules a second frame and fails the `hasScheduledFrame` test.
- **The polite exclamation mark.** `Restore previous board` becomes `Board restored!` in a snackbar during T02 review. An exclamation mark directed at an adult mid-shutdown is a pat on the head.
- **Softening `Keep my board off cloud backup`.** It reads blunt, so it becomes "Backup preferences". Euphemism costs the control to the exact user it protects.
- **Prompting an accommodation.** "Text is large. Switch to 6 tiles?" is the app noticing something about the user and offering help — the parental posture in indie clothes. Ship the setting; let them find it.
- **A "caregiver" or "parent" section.** Not a label, not a class name, not a doc comment. There is one user and they own the board.
- **A modal confirm on `Restore previous board`.** No modal dialogs, ever. A modal demands a decision from someone whose decision-making is impaired.
- **Fixing a 200% overflow with `withClampedTextScaling` or `FittedBox`.** It is the one-line fix a red test invites, it defeats the whole text-scale matrix, and contrast and tap-target checks stay green while it does.
- **Pushing `boldText`/`highContrast` through a provider** so the screen "has one source of state". It trades a compiler-guaranteed rebuild for a manual sync that is stale for a frame. Also: `MediaQuery.highContrastOf` is iOS-only and always false on Android — read it opportunistically, never gate anything on it. The in-app theme switcher is the only mechanism that works on the target platform.
- **`Widget _buildRow(...)` helpers.** No `Element` boundary, cannot be `const`, unreachable by `find.byType`. Extract classes.

## Files

- `lib/ui/settings/settings_screen.dart` — new. The flat column.
- `lib/ui/settings/settings_controls.dart` — new. One `StatelessWidget` per control.
- `lib/strings.dart` — add the lowercase chrome literals and the semantic label strings.
- `test/ui/settings_screen_test.dart` — new. Semantics, 200% scale, no-scheduled-frame.

## Done when

Settings is a single flat scrollable screen whose five controls render and announce correctly at `TextScaler.linear(2.0)`, push no child routes, schedule no frames on tap, and the theme cycle is reachable in one tap from the grid.
