# E07-T04 — Editor accessibility

| | |
|---|---|
| **Epic** | E07 — Edit mode |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E07-T03 |
| **Blocks** | Nothing |

**Skills:** `reed-a11y-coding` · `reed-a11y-testing` · `reed-tile-anatomy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

The editor is where a user configures their own voice. An editor that a screen-reader or switch user cannot drive means someone else configures it for them — a caregiver picking the words that will come out of their mouth. That is the exact dynamic this product exists to refuse, so an inaccessible editor is not a lesser failure than an inaccessible board; it is the same failure one level up. And because these users speak most of the time, the fastest authoring path is the one the editor must not break: talk into the keyboard's dictation key and get a phrase.

## Scope

Bring every interactive node the editor added in E07-T03 up to the same standard the speak screen already meets, and keep the dictation path open. This is a hardening pass over existing widgets plus the tests that hold it, not new product surface.

### 1. The empty slot flips mode

On the speak screen the empty slot is **ground, nothing else** — no fill, no keyline, no target, and `ExcludeSemantics`, not `enabled: false`, so TalkBack and Switch Access **skip** it rather than burn a scan step on nothing (at 1s/step under linear autoscan that is real seconds someone spends unable to speak).

**In edit mode the same cell becomes a full target: keyline, a `+`, full semantics.** The exclusion is mode-dependent or the editor is unusable by switch access — a switch user would have no way to reach any empty slot and could never add a phrase.

```dart
if (button == null) {
  if (!editing) return const ExcludeSemantics(child: SizedBox.expand());
  return Semantics(
    container: true,
    button: true,
    label: 'Add phrase',            // never 'plus', never ''
    sortKey: OrdinalSortKey(slot.priority.toDouble()),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onAdd(slot.row, slot.col),
      child: const ExcludeSemantics(child: _EmptySlotEditFace()), // draws the +
    ),
  );
}
```

The `+` glyph is `ExcludeSemantics`'d inside a labelled parent — an `Icon` gets a `semanticLabel` **or** is wrapped in `ExcludeSemantics` because it is decorative. There is no third option, and an unlabelled `Icon` is invisible to a screen reader.

### 2. Every editor control gets a semantics node

Every icon-only affordance E07-T03 introduced — the done/exit control, per-tile edit and delete, the reorder handle if there is one — needs `Semantics(button: true, label: ...)` with a label that says what it does to *which* phrase. `'Delete'` twelve times is a scan through twelve identical announcements. `'Delete "Overwhelmed"'` is one.

- Every `Icon`/`Image` in the editor: `semanticLabel`, or `ExcludeSemantics` because it is decorative.
- Destructive controls carry a `hint` describing the consequence, not the gesture.
- Tile faces reused inside the editor keep their `ExcludeSemantics` wrapper — the parent node already announces the label, and without it it is said twice.

### 3. Editor traversal is authored, not inherited

Traversal order is a design decision; inheriting it from layout is an accident. The grid tiles keep `sortKey: OrdinalSortKey(priority.toDouble())` in edit mode — the same key, so the board a switch user learned by ear does not silently reorder the moment they enter the editor. Editor chrome that must be reachable first (exit/done) is authored with its own `OrdinalSortKey`, not left to row-major luck.

### 4. Text scale and boldText in the editor form

The bans are global, not speak-screen-local:

- Never `MediaQuery.withClampedTextScaling`. Never `textScaleFactor`. A source-grep test over `lib/` enforces it, and `lib/` includes the editor.
- Never `FittedBox` / auto-shrink to make an editor label fit.
- Never `TextOverflow.ellipsis` on a phrase label — including the preview of `label` or `says` shown inside the editor. An ellipsis on an AAC utterance is a *different utterance*.
- `boldText` comes from `MediaQuery.boldTextOf(context)` at build time; no hardcoded `fontWeight` on user-facing text. Platform a11y state comes from context, never Riverpod — `MediaQuery` is an `InheritedWidget` with correct-by-construction invalidation; pushing it through a provider trades a compiler-guaranteed rebuild for a manual sync that is stale for one frame.
- `MediaQuery.highContrastOf(context)` is read opportunistically and gates nothing: it is **iOS-only and always false on Android**, so on the target platform the in-app palette switcher is the only mechanism that works.

The editor form must lay out at `TextScaler.linear(2.0)` on `Device.seLike` with no overflow. Let text wrap; build intrinsic and flexible heights. Let overflow scream in tests — a red-and-yellow stripe in a widget test is the feedback loop; truncated text on a device is a failure nobody will report.

### 5. The dictation path

The `label` and `says` fields must remain **plain `TextField`s that the platform IME can dictate into**. The mic key belongs to the user's own keyboard app; our job is to not suppress it.

- No custom text input client, no `RawKeyboard` interception, no `TextInputType` or `inputFormatters` combination that hides or disables the IME mic key.
- The 16-character cap on `label` is enforced at the **model/validation boundary with a visible, announced counter** — not by an `inputFormatters` hard truncate that silently eats the tail of a dictated phrase mid-word. `says` is uncapped and defaults to `label`.
- Each field gets a persistent visible label and a `Semantics` label that says which field it is and what it is for: the tile label is the **handle** ("what you see on the tile, up to 16 characters"); `says` is **what is spoken** ("what the app says out loud"). Nothing in the type system distinguishes these two `String`s, so the announcement is the only thing that does.
- Do not advertise dictation as an offline feature anywhere in copy or store text. The app makes no network calls; the user's IME is a separate app whose recognition may be cloud-backed and is outside our sandbox. Silence on it is honest; a claim is not.

**Out of scope:** adding a `speech_to_text` (or any STT) dependency or an in-app mic button; any new editor screen or control; changing the editor's visual design; the four-palette contrast gate (asserted on colour values in `test/ui/contrast_test.dart`, already covered elsewhere); `flutter drive` or Espresso a11y automation — both find nothing here.

### 6. The tests

Extend `test/ui/a11y_test.dart` (or add `test/ui/editor_a11y_test.dart` alongside it) using the existing harness:

```dart
testWidgets('an empty slot is a labelled button in edit mode and absent from '
    'the tree on the speak screen', (WidgetTester tester) async {
  await tester.pumpApp();
  expect(find.semantics.byLabel('Add phrase'), findsNothing);

  await tester.pumpApp(editing: true);
  expect(
    tester.getSemantics(find.byKey(const ValueKey<String>('slot_0_2'))),
    isSemantics(
      label: 'Add phrase',
      isButton: true,
      hasEnabledState: true,
      isEnabled: true,
      isFocusable: true,
      hasTapAction: true,
    ),
  );
});
```

`isSemantics`, never `containsSemantics` — the latter is deprecated after v3.40.0-1.0.pre and virtually every tutorial predates this. `find.bySemanticsLabel` for behaviour (tap, edit, delete); `ValueKey('slot_r_c')` for geometry, because position IS the primary key. Never `find.byType` for a tile.

Also required:

- The editor renders at `TextScaler.linear(2.0)` on `tester.useDevice(Device.seLike)` with no overflow. Any geometry test calls `useDevice` first — the default 800×600 logical surface is wider than any phone and hides real breakage.
- An anti-clamp assertion for an editor field label mirroring the speak-screen one: measure at 1.0, measure at 2.0, `expect(scaled, greaterThan(base * 1.8))` — 1.8 not 2.0, to tolerate line-height rounding while still failing hard on a clamp.
- A `label`-vs-`says` test: the editor's tile preview node's `label` must not `contain` the `says` string when the two diverge.
- Advisory tripwires only, one line each, on the edit-mode pump: `await expectLater(tester, meetsGuideline(labeledTapTargetGuideline))` and the tap-target ones. `meetsGuideline` returns an `AsyncMatcher` — `await expectLater` is mandatory; a plain `expect()` will not do what it looks like it does.

Semantics is **ON by default** in widget tests (`testWidgets` takes `semanticsEnabled = true` and calls `ensureSemantics()` for you). Do not add a manual handle. If one is ever genuinely needed, `addTearDown(handle.dispose)` — never a trailing `handle.dispose()`, which does not survive a throwing `expect()`.

### 7. What automation cannot cover — write it into the manual checklist

State the ceiling and do not overclaim. Flutter ships four guidelines, roughly the trivially machine-checkable subset, and they are worth almost nothing here: `MinimumTapTargetGuideline` returns `Evaluation.pass()` without measuring for any node flush with the view edge (`_kMinimumGapToBoundary = 0.001`, all four sides), `textContrastGuideline` has an open false negative (white on `0xfafafa` passes), and `labeledTapTargetGuideline` only checks the label is non-empty — `button1` passes it.

**Switch Access cannot be tested automatically at all.** Flutter publishes no support statement and no API simulates scanning, group selection, or point scanning. Add these to the pre-release manual checklist, each guarding a top-severity failure:

- Enter edit mode, add a phrase to an empty slot, dictate into `label` and `says`, save, and exit — **using only a switch**. Focus traps in edit mode and in the text field are verified by hand or not at all.
- Same run with TalkBack: every control announces what it does; nothing announces twice; empty slots are buttons here and silent on the speak screen.
- Google's Accessibility Scanner over edit mode. It is an `AccessibilityService` and reads Flutter's `AccessibilityBridge` virtual node tree, so it genuinely works — manual, on-device, human-driven, pre-release, not CI.

## Acceptance criteria

- [ ] `flutter test test/ui/` passes, including the new edit-mode semantics, anti-clamp, and label-vs-`says` tests.
- [ ] `flutter analyze` is clean.
- [ ] The source-grep ban test passes with the editor in `lib/`: zero hits for `withClampedTextScaling`, `textScaleFactor`, `FittedBox`, and `TextOverflow.ellipsis` on a phrase label.
- [ ] A test asserts `find.semantics.byLabel('Add phrase')` is `findsNothing` on the speak screen and resolves to a node satisfying `isSemantics(isButton: true, hasTapAction: true, ...)` in edit mode.
- [ ] A test pumps the editor at `TextScaler.linear(2.0)` on `Device.seLike` and no overflow exception is thrown.
- [ ] Grep the editor diff: every `Icon`/`Image` has a `semanticLabel` or an `ExcludeSemantics` ancestor. No exceptions, no third option.
- [ ] Every editor `GestureDetector`/tap target has a `Semantics(button: true, label: ...)` node with a label naming the phrase it acts on.
- [ ] Typing a 20-character `label` shows an announced counter and a validation message; it is not silently truncated at 16.
- [ ] Manual, on a device: add and save a phrase in edit mode using only Switch Access; repeat with TalkBack. Recorded in the manual checklist.
- [ ] No commit message, comment, or store copy claims the suite "tests accessibility", and none claims dictation is offline.

## Traps

- **Reusing the speak screen's `ExcludeSemantics` empty slot verbatim.** It is correct there and it locks switch users out of the editor here. The exclusion must be mode-dependent. This is the single highest-severity failure in this task and it is invisible to every automated check — an excluded node cannot fail a guideline, it simply is not there.
- **Announcing the empty slot as `enabled: false` instead of excluding it on the speak screen.** A disabled node still burns a scan step; excluded skips it.
- **Labelling the `+` icon and the parent node both.** The user hears "Add phrase, add phrase". Face widgets go inside `ExcludeSemantics`; the container announces.
- **`inputFormatters: [LengthLimitingTextInputFormatter(16)]` on `label`.** Dictation arrives as one large insertion; the formatter eats the tail with no message. The user says "I need to leave now" and the field holds "I need to leave " with no indication anything was lost.
- **Reaching for `withClampedTextScaling` when the editor form overflows at 200%.** It is the single most dangerous API in this app: it is the one-line fix a future contributor reaches for when an overflow test goes red, and it silently defeats the entire text-scale matrix while contrast and tap-target guidelines still pass green. `FittedBox`, a computed `fontSize`, and `maxLines` + `ellipsis` are the same bug wearing a disguise.
- **Ellipsising the `says` preview in the editor.** The editor is precisely where `says` must be verifiable in full — that is the reason `says` is not rendered on the tile at all. Truncating it here removes the only place it can be checked while nobody is in a shutdown.
- **Leaning on `meetsGuideline` for tap targets in the editor.** On a full-bleed grid the 10 perimeter tiles are skipped and only the 2 interior ones are measured; the test goes green while checking almost nothing. It also skips any node that is hidden, a link, or has neither a tap nor a long-press action.
- **Importing "76dp" as an editor design constraint.** `reed-tile-anatomy` is explicit: there is no 76dp minimum tile size, it appears in no standard, and if a 76dp floor appears anywhere, delete it. `aacTapTargetGuideline` exists in `test/ui/a11y_test.dart` as an advisory tripwire, not a spec to design editor chrome against.
- **`expect(tester, meetsGuideline(...))` without `await expectLater`.** It returns an `AsyncMatcher`; the plain form silently does not assert.
- **`containsSemantics`, or `start:`/`end:` on `simulatedAccessibilityTraversal`.** Both deprecated (after v3.40.0-1.0.pre and v3.15.0-15.2.pre). Copied from a tutorial that predates the change.
- **A geometry test with no `tester.useDevice(...)`.** The 800×600 default is wider than any phone; the editor fits there and overflows on hardware.
- **Assuming a tinted fill exists in high contrast.** The stocks drop out entirely; the keyline is promoted to a solid 3dp and *is* the tile. Editor chrome that leans on stock tints to distinguish states disappears there.
- **Encoding editor state in colour alone** — the selected tile, the dirty field, the invalid field. Invisible under `invertColors`, under Android's Grayscale colour-correction mode, and to every screen-reader user. Never reimplement `invertColors`; just never encode meaning in colour alone.
- **Claiming the editor "is accessible" because `test/ui/` is green.** Automated checks catch a small minority of real issues here. Overclaiming is precisely how an inaccessible accessibility app ships green.

## Files

- `lib/ui/edit/` — the editor widgets from E07-T03: semantics nodes, icon labels, `sortKey`s, the mode-dependent empty slot, field labels and the counter.
- `lib/ui/speak/` — the tile/empty-slot widget, if the edit-mode branch lives there.
- `test/ui/editor_a11y_test.dart` — new, or the equivalent additions to `test/ui/a11y_test.dart`.
- `test/support/harness.dart` — an `editing:` flag on `pumpApp` if one does not exist yet.
- The manual pre-release checklist — the Switch Access, TalkBack, and Accessibility Scanner passes over edit mode.

## Done when

A switch user can enter edit mode, reach an empty slot, dictate a phrase into it with their own keyboard, and save — verified once on a device and guarded thereafter by tests that assert the mode-dependent semantics rather than a guideline that skips them.
