# E10-T05 — The dated-design audit

| | |
|---|---|
| **Epic** | E10 — Verification |
| **Status** | Done |
| **Size** | XS |
| **Depends on** | E05-T01, E06-T02 |
| **Blocks** | E11-T04 |

**Skills:** `auditing-reed-visuals` · `reed-colour-system` · `reed-motion-policy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A taste checklist nobody can run is a wish. Reed's whole dignity argument — an adult board that looks like a swatch book, not a therapy toy — dies quietly the first time someone drops a `Card` with a 4dp radius into `lib/` and no one notices. There is no telemetry and no user will file a bug about it; the script is the only mechanism that catches the drift. It exits non-zero on a hit, so it gates CI instead of relying on someone remembering to look.

## Scope

Wire the existing audit script into the pre-ship routine and into CI.

**Run it from the repo root:**

```bash
bash .claude/skills/auditing-reed-visuals/scripts/audit-visuals.sh
```

It scans `lib/` only. Exit codes: **0** clean · **1** any hit · **2** `lib/` missing. Output groups findings by tell with `file:line`.

**What it greps for** — the 20 tells, of which these are the mechanical ones:

| # | tell | fix value |
|---|---|---|
| 1 | radius literal < 16dp on an element > 60dp | tile and type field **20dp**; focus ring **22dp** (20 + 2dp gutter offset); a chip nested in a tile is **computed** as `outer − padding`, never a constant |
| 2 | `elevation:` > 0, any `BoxShadow`, any `Card` | delete — depth is tonal steps (`ground → container → stock → stockLit`) and the keyline, nothing else |
| 4 | M2 500-series hexes `2196F3` `4CAF50` `F44336` `007BFF` | none of these exist in Reed |
| 5 | pure `#FFFFFF` / `#808080` / `#000000` outside high contrast | HC is **not** an exception unlocking `#FFF`/`#000` — it uses `#FFFCF7` / `#0B0906` (19.43:1 vs pure's 21.00:1). `Colors.white` / `Colors.black` are the same defect wearing a Material name. The only legitimate zero-chroma value is fully transparent `Color(0x00000000)` for killing splash and highlight |
| 6 | `fontSize:` above 17 with no `letterSpacing` within ±8 lines | 20pt → w600 / −0.01em (−0.20); 96pt → w500 / −0.02em; 15pt → w500 / **+0.01em**. Never below −0.02em |
| 7 | `FontWeight` below w400; centred display type | w500–w600 only. Tile labels are `TextAlign.start`, bottom-anchored, `EdgeInsetsDirectional` |
| 9 | 1px `Divider` between siblings | the gap is the design, and it is deliberately unequal: **14dp column, 22dp row, 24dp margin** |
| 10 | `ContinuousRectangleBorder` | reject on sight — use `RoundedSuperellipseBorder` with `strokeAlign: BorderSide.strokeAlignInside` |
| 11 | `Border.all()` | 1.0 logical px = 3 physical px on a 3× phone. Use `1.0 / MediaQuery.devicePixelRatioOf(context)` = 0.333dp. HC promotes it to a solid **3dp** border |
| 12 | 2-stop lightness-ramped gradient | all gradients banned |
| 13 | `BackdropFilter` / `Opacity(` / `ShaderMask` | contrast over arbitrary content is non-certifiable by construction |
| 16 | any `Icon` from a font | there are no icons — chrome is lowercase words |
| 17 | any ALL-CAPS label | shouting |
| 18 | straight apostrophe in a shipped string | `I can’t talk` |

Tells 3 (grey umbra on pure-grey surface), 8 (type-size spread — the app runs 15 → 140 = 1:9.3), 14, 15, 19, 20 are judged, not greppable.

**Resolving a hit.** A hit is not automatically a defect — it is a place a decision has to exist. Resolve it or record why the code is right. **Never suppress a hit.** For radius hits specifically, find the painted element's size: radius-to-size around **1:6** reads 2026; 8dp reads 2014; 12–16dp reads generic M3 card; a pill wastes corner area. A small radius on a genuinely small element (a 6dp tick, a 24dp affordance) is fine.

**The colour-literal guard**, which the audit does not cover — run it alongside:

```bash
! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'
```

Colour literals live in `lib/ui/core/tokens.dart` and nowhere else. A literal in a widget file is a finding even when the hex is correct.

**Add both to the CI job** so a PR that lands a `Card` fails before merge, not after ship.

**Say what the script does not do.** In whatever report or PR comment you produce, state plainly which tells were checked mechanically and which were judged. Never report a clean run as "the screen passes the audit" — it passed the greppable half. The eyeball pass, every time:

- **Composition.** Gutter inequality; the small four-pointed star of negative space where four tiles meet — pick the gap-to-radius ratio on purpose, roughly **0.6–1.1×**; whether one-line and three-line tiles still share a last baseline so a row scans as a line of type.
- **Colour harmony.** Whether the four stocks still read as woven cloth rather than an institutional board. The lightness stagger (dark stocks **OKLCH L 0.240 → 0.375**) is what does that, and it is also the colourblind fix (deutan ΔE ×100 = **7.00** dark, **6.62** light) — never flatten it.
- **Radius-to-size ratio** on anything the grep missed because the value came from a token. A 105dp tile at radius 12 pulled from a token will not grep.
- **Type-size spread**, measured across the whole app, not per screen.
- **Copy register.** No grep catches a sentence that talks down to someone.

**Out of scope:** changing the script's rules or adding tells; fixing the hits it finds (that is the work of whichever screen task owns the file); golden tests; contrast verification via `contrast.py` (that lives with the colour tasks).

## Acceptance criteria

- [ ] `bash .claude/skills/auditing-reed-visuals/scripts/audit-visuals.sh` run from the repo root exits **0** against current `lib/`.
- [ ] `! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'` exits 0 (no literal outside `tokens.dart`).
- [ ] The CI workflow runs both commands and a non-zero exit fails the job. Verify by temporarily adding `elevation: 2` to a widget, pushing, and watching CI go red; then revert.
- [ ] Every hit present at the start of this task is either fixed in code or has a one-line note in the PR saying why the code is right. Zero suppressions, zero `# noqa`-style escapes.
- [ ] The PR body lists which tells were checked mechanically and which were judged by eye, and does not claim a clean script run means the design passes.
- [ ] The eyeball pass is recorded: gap-to-radius ratio at the four-tile junction, whether one- and three-line tiles share a last baseline, and the measured type-size spread across the app.

## Traps

- **Treating a green run as proof.** The script cannot see composition, colour harmony, copy register, or radius-to-size when the radius came from a token. "The audit passes" is a claim about grep, not about the design. This is the single most likely failure of this task.
- **Fixing a hit by suppressing it.** Renaming a variable so the grep misses it, or moving a hex behind a constant that is still in a widget file, converts a finding into an invisible defect. The rule is resolve or justify.
- **Assuming absence of a radius hit means the radius is right.** A 105dp tile at radius 12 read from a token never appears in the output. Check the ratio by hand on anything large.
- **"High contrast needs pure black and white."** It does not: `#FFFCF7` / `#0B0906` is 19.43:1 against pure's 21.00:1 — 1.9 Lc out of 108, a 1.8% delta, to stay recognisably the same app. A pure `#FFF`/`#000` escape hatch exists only if a real user reports warm HC insufficient, and it is not this task's call to pre-emptively ship it.
- **`Colors.white` / `Colors.black` sliding through.** They are the same defect as the hex; make sure the grep or your eyes catch the Material-named form too.
- **Reaching for `ContinuousRectangleBorder` when fixing a shape hit.** It needs its radius multiplied by ~2.3529 to approximate a squircle, that multiplier degenerates into the "TIE-fighter" shape *earlier*, and it centres strokes regardless of `strokeAlign` — it fails at exactly the radius this app wants. `RoundedSuperellipseBorder`, `ClipRSuperellipse` and `Canvas.drawRSuperellipse` are all in-toolchain; `figma_squircle` and `smooth_corner` are unnecessary.
- **Explaining a shadow finding as "shadows are dated."** The sharper diagnosis is tell 3: a grey umbra on a pure-grey surface is what reads Material-2 specifically. Name the umbra-on-grey.
- **Fixing a tracking hit with weight.** As size rises, weight falls *and* tracking tightens — the two move together. And weight is never the halation fix: heavier glyphs at high luminance bloom *more*, and `wght` changes advance widths, which can re-wrap a label between palettes. Reflow is banned. Halation is solved with the ink-luminance cap (OKLCH L ≈ 0.885, `#DCD9D3`), not weight.
- **Killing a splash with `NoSplash.splashFactory` alone.** `InkResponse.updateHighlight()` independently creates an `InkHighlight` with a 200ms pressed fade the splash factory never touches. If the audit surfaces an `InkWell`, replace it with `GestureDetector(behavior: HitTestBehavior.opaque, …)` — do not layer more theme settings on it.
- **CI passing because the script never ran.** Exit code 2 means `lib/` was missing, not that the code is clean. Make sure the job runs from the repo root and that a 2 fails the build as loudly as a 1.
- **Making the flag check the deliverable.** If a hit gets "fixed" by reading `MediaQuery.disableAnimationsOf` to choose between two durations, that path already violates the motion policy. Delete the animation, not add the flag check.

## Files

- `.github/workflows/` — the CI job gains the audit step and the colour-literal guard.
- Any file in `lib/` carrying a hit at the time of the run, fixed in place.
- No new script. `audit-visuals.sh` already exists at `.claude/skills/auditing-reed-visuals/scripts/audit-visuals.sh` and is not modified by this task.

## Done when

The audit script and the colour-literal guard both run in CI and exit 0 against `lib/`, every pre-existing hit is fixed or justified in writing, and the eyeball pass the script cannot do has been done and recorded.
