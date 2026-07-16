# E05-T03 — The type-to-speak field

| | |
|---|---|
| **Epic** | E05 — The speak screen |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E05-T02 |
| **Blocks** | Nothing |

**Skills:** `reed-grid-layout` · `reed-typography` · `reed-a11y-coding` · `reed-copy-voice`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

The board holds twelve phrases; the rest of a life does not fit in twelve phrases. The field is how someone says the thing nobody authored in advance — a name, a dose, a street. It is the thirteenth cell of the same grid, not an input bolted onto one, because the moment it reads as a separate app the screen becomes two products stapled together and the user has to decide which one they are in. And it sits at the top, where it is worst to reach, because the ability to type implies more capacity than the ability to tap: tiles are for crisis, typing is for when you are okay.

## Scope

Build the field as a cell of the board's layout inside the speak screen: **3 columns wide, at the top, 72dp tall (`Geom.fieldHeight`), `container` fill, 20dp radius (`Geom.tileRadius`), the same keyline at `Geom.hairline(dpr)`** — identical shape, material and stroke to a `PhraseTile`. The 22dp row gap (`Geom.gapRow`) below it must be indistinguishable from the gap between grid rows. If a plain `GridView.count` cannot express the span cleanly, use a `Column` of field + grid — but the seam must be invisible, which means the radius, keyline, fill and the 22dp gap are non-negotiable in either construction.

Shape it with `ShapedInputBorder` wrapping a `RoundedSuperellipseBorder`:

```dart
TextField(
  // no autofocus — see traps
  textInputAction: TextInputAction.send,
  onSubmitted: (text) => ref.read(speechProvider).speak(text),
  style: TypeRoles.field, // 22 / w500 / letterSpacing 0 / height 1.30 / TextAlign.start
  decoration: InputDecoration(
    filled: true,
    fillColor: t.container,
    border: ShapedInputBorder(
      shape: RoundedSuperellipseBorder(
        borderRadius: const BorderRadius.all(Radius.circular(Geom.tileRadius)),
        side: BorderSide(color: t.keyline, width: Geom.hairline(dpr)),
      ),
    ),
  ),
)
```

Typography is the `field` role, exactly: **22pt, w500, letterSpacing 0, height 1.30, `TextAlign.start`**. The zero tracking at 22pt is deliberate and is the one exception to "never leave `letterSpacing` at 0 above 17pt" — it is in the table, do not "fix" it to a negative value.

The screen's `Scaffold` carries `resizeToAvoidBottomInset: false`. Content is wrapped in `SafeArea`, with `Geom.margin` (24dp) inside it; the ground plane is full-bleed behind it (`Scaffold(backgroundColor: t.ground)`), no `SafeArea` above it, no status-bar scrim.

Accessibility: the `TextField` already publishes a `textField` semantics node — do not wrap it in `Semantics(button: true)`. Give it a `hintText` / `InputDecoration.labelText` that is real copy in Reed's register. Author the string lowercase in the string table if it is chrome; do not compute case at render. Suggested: `type to speak` — no exclamation, no question, no "just", no tour. Submitting an empty or whitespace-only field does nothing and shows nothing; there is no error string for "you typed nothing" because there is no accusation to make.

Feeding the typed text to TTS is E05-T02's speech path — this task wires `onSubmitted` into it and owns nothing about the engine.

**Out of scope:** any bespoke text editing (IME composition, selection handles, a custom cursor); a send button or icon; suggestions, autocomplete, history, or a recents list; content filtering of any kind; the show-screen handoff for typed text; persisting field contents across launches; the keyboard's own appearance.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] `grep -rn "autofocus" lib/` returns no hit inside the speak screen.
- [ ] `grep -rn "resizeToAvoidBottomInset" lib/` shows `false` on the speak screen's `Scaffold`.
- [ ] `grep -rn "viewInsets" lib/` returns no hit in the speak screen — the grid is never padded up by the IME.
- [ ] `grep -rn "ContinuousRectangleBorder\|RoundedSuperellipseInputBorder\|FittedBox\|withClampedTextScaling\|textScaleFactor" lib/` returns nothing.
- [ ] Widget test: pump the speak screen, assert `tester.testTextInput.isVisible` is `false` at first frame — no keyboard at cold launch.
- [ ] Widget test: enter text, `tester.testTextInput.receiveAction(TextInputAction.send)`, assert the fake speech service received exactly that string, unmodified (no trim of a deliberate `…`, no case change, no added period).
- [ ] Widget test: submit `'   '`, assert the speech service received nothing and no error surface was shown.
- [ ] Widget test at `TextScaler.linear(2.0)`: pump the speak screen, assert no overflow exception and that the twelve tiles are still at their authored (row, col) positions — the field growing must not move the grid.
- [ ] Widget test: show the keyboard (`tester.showKeyboard(find.byType(TextField))`, insert a bottom `viewInsets` of e.g. 300 via `MediaQuery`), and assert the field's top-left global offset is byte-identical before and after. The grid is allowed to be covered; nothing is allowed to move.
- [ ] Golden: the field's rendered radius, keyline colour and fill are indistinguishable from a `PhraseTile` in the same theme; the gap between field and row 1 measures 22dp.
- [ ] Semantics test with `isSemantics(textField: true, ...)` — not `containsSemantics`.
- [ ] Every user-facing literal added passes the copy grep: no `!`, no `'` (straight apostrophe), no `Please`, no `Sorry`, no `just `, no `we `, no `.toUpperCase(`/`.toLowerCase(`.

## Traps

- **`autofocus: true` is the default instinct and it is catastrophic.** Someone opens the app mid-shutdown and the twelve phrases they came for are behind an IME. This is the exact failure mode the whole product exists to prevent, and it costs one word to cause. There is no condition under which it is right — not "only when the board is empty", not "only on return from settings".
- **Padding the grid with `MediaQuery.viewInsets.bottom` to "fix" the overlap.** The overlap is the design. The keyboard covering the grid while leaving the field visible is *why* the field is at the top. Padding it up reflows the board, and position is the retrieval mechanism — a user reaches for "I need to leave" by muscle memory, not by reading. A grid that moves has silently deleted that.
- **`resizeToAvoidBottomInset` defaults to `true`.** Omitting it is not neutral; it is choosing reflow. Set it explicitly to `false` and put the reason in the line above it, or someone deletes it as noise.
- **`RoundedSuperellipseInputBorder` does not exist.** Reaching for it and settling for `ContinuousRectangleBorder` is the predictable next move — that class is banned everywhere: it needs its radius multiplied by ~2.3529 to approximate a squircle, degenerates early at exactly 20dp, and centres strokes regardless of `strokeAlign`. Use `ShapedInputBorder(shape: RoundedSuperellipseBorder(...))`.
- **Going bespoke on `TextField`.** Reimplementing IME composition and selection is a multi-month trap that ends in a field that drops characters in Japanese and loses selection on rotate. The tile is bespoke; the field is Material. Style it, do not rebuild it.
- **Building it as an `AppBar`, a `bottomSheet`, or a sibling with its own spacing.** Any of those makes the seam visible and the screen reads as two apps. It is a cell.
- **Relitigating the position.** "The field should be at the bottom, near the thumb" is correct reasoning applied to the wrong user. Typing earns the worst position. This question comes back; the answer does not change.
- **Transforming what was typed.** No trim beyond nothing, no capitalising the first letter, no appending a period, no lowercasing, no content filter — not on the field, not ever. Straight-to-curly normalisation is a save-time rule for stored phrases and there is nothing being saved here; do not apply it mid-typing, and do not apply it at all. Rewriting a character under someone's cursor is hostile.
- **`Semantics(button: true)` around the field.** It is a text field, and announcing it as a button lies about what happens on activation. `TextField` already owns its node.
- **Making the field's height grow with text scale in a way that eats the grid.** 72dp is the field; at 200% the label block in a tile already needs ~124dp against ~125dp of tile. If you fix a field overflow by clamping text scale, you have defeated the entire accessibility matrix while every contrast and tap-target check still passes green. Let it overflow loudly in a test instead.

## Files

- `lib/ui/speak/speak_screen.dart` — adds the field as the top cell; `resizeToAvoidBottomInset: false`.
- `lib/ui/speak/type_field.dart` — new; the styled `TextField`.
- `lib/ui/strings.dart` — the field's hint literal, authored lowercase.
- `test/ui/type_field_test.dart` — new; no-autofocus, submit, whitespace, semantics.
- `test/ui/speak_screen_layout_test.dart` — adds the keyboard-inset no-move assertion and the 200% scale assertion.

## Done when

Cold launch shows twelve tiles and no keyboard; typing a sentence and hitting send speaks exactly what was typed; and raising the IME covers the grid without moving a single pixel of it.
