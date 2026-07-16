# Dated-design audit (E10-T05)

The visual audit has two halves: what a script can grep, and what only an eye
can judge. This records both. **A clean grep is never "the screen passes the
audit" — it passed the greppable half.**

Run from the repo root:

```bash
bash .claude/skills/auditing-reed-visuals/scripts/audit-visuals.sh   # the 20 tells
! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'
```

## Mechanical half — verdict on every hit

The colour-literal guard is **clean**: every `Color(0x…)` literal lives in
`lib/ui/core/tokens.dart` and nowhere else. It is wired into CI as a hard gate.

`audit-visuals.sh` exits 1, because it greps raw source and this codebase both
**documents its own anti-patterns** and **uses icons by design**. Every hit was
reviewed; none is a new defect. By category:

| Category | Count | Verdict |
|---|---|---|
| Comments naming a banned pattern (e.g. `// never Border.all()`, `// not ContinuousRectangleBorder`) | the large majority | **Documentation, not usage.** These warn the next contributor. Rewording them so the grep misses would be suppression, which the audit rules forbid. Left as-is. |
| `FontWeight.w800` behind the platform bold flag (`MediaQuery.boldTextOf` / `bold ? w800 : null`) | ~12 | **Correct.** Per `reed-typography`, `boldText` is the ONLY thing permitted to move weight, and w800 is the shipped axis maximum. This is the accessibility bold setting, not decorative bold display type. |
| `FontWeight.w800` for a selected voice row (`voice_picker.dart`) | 1 | **Correct.** A non-colour selection channel (bold = chosen), the same idiom as the settings value rows; survives colour inversion and Grayscale. |
| `Icon(...)` from MaterialIcons — chrome (theme/settings/edit), edit-mode controls (move/hide/remove/+), voice radio buttons, the settings back arrow | ~15 | **Established design from E05–E08**, unchanged by E09/E10 (`edit_mode_button.dart` shipped in E07, `voice_picker.dart` in E08). Tell 16 ("there are no icons") is stricter than the shipped product, which pairs a lowercase word with a small glyph in chrome and uses compact glyphs for edit-mode affordances. Relitigating that is a design decision owned by those screens, not an E10 change. |
| `BorderRadius.all(Radius.circular(8))` on the edit-control chip (`phrase_tile.dart:676`) | 1 | **Fine.** The chip is a ~28dp affordance; the radius-<16 tell applies to elements **>60dp**. A small radius on a genuinely small element is explicitly allowed. |
| `Color(0x00000000)` (`tokens.dart` `clear`) | 1 | **The one sanctioned zero-chroma value** — fully transparent, for killing splash/highlight. Named as legitimate by tell 5 itself. |
| Straight-`'`/apostrophe greps in `strings.dart` | several | **False positives** on Dart's own string delimiters; the shipped copy uses curly `’` (verified in the copy policy tests). |

**Conclusion:** zero dated-design defects. The script over-reports on this
mature codebase, so it is a **manual pre-ship review tool**, not a hard CI gate;
the colour-literal guard — which is decidable and clean — is the CI gate.

## Judged half — the eyeball pass (recorded 2026-07-16)

- **Gutter inequality holds.** 14dp column, 22dp row, 24dp margin (`Geom`), so a
  row scans as a line of type rather than a table. Verified on device
  (Android + iOS screenshots this session).
- **The four-tile junction** reads as a small star of negative space; the
  gap-to-radius ratio (≈14–22dp gap against the 20dp tile radius, ~0.7–1.1×)
  sits in the intended band — the corners meet without the tiles fusing.
- **Baseline sharing:** one-line tiles ("Yes", "No") and three-line tiles share
  their last baseline within a row, because labels are bottom-anchored — a row
  scans as type, confirmed in the board screenshots.
- **Colour harmony:** the four stocks still read as woven cloth, not an
  institutional board; the OKLCH lightness stagger is intact (it is also the
  colourblind fix and must never be flattened).
- **Type-size spread across the whole app:** 15pt meta → 140pt show poster ≈
  1:9.3, unchanged.
- **Copy register:** the strings added this cycle (export/import results, the
  back control, the remove affordance) state the fact then the next action, no
  apology, no talking down — checked against the copy policy tests.

## What the audit cannot see

Composition, colour harmony, copy register, and radius-to-size when the radius
came from a token (a 105dp tile at a tokenised radius never greps). Those are the
eyeball pass above, and the device screenshots are the record.
