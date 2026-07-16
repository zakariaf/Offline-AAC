import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/model/board_grid.dart';

import '../support/harness.dart';
import '../support/tiles.dart';

/// What these five tests are, and — more importantly — what they are NOT.
///
/// Automated checks catch a SMALL MINORITY of the real accessibility issues on
/// this screen. Flutter ships FOUR accessibility guidelines — roughly the
/// trivially machine-checkable subset — and one of them is known-broken. (Do not
/// quote the "57%" figure that circulates; that is axe-core's ~100 WEB rules, a
/// different tool measuring a different surface.)
///
/// The three defects that make the built-in guidelines untrustworthy here, and
/// why the real gates are hand-written:
///  - `MinimumTapTargetGuideline` skips every node flush with the view edge
///    (`_isAtBoundary`, `_kMinimumGapToBoundary = 0.001`, returns a pass without
///    measuring). On a full-bleed 3x4 grid that is 10 perimeter tiles skipped and
///    only the 2 interior tiles measured — which is exactly why test (1), the
///    hand-measured getSize loop, is the gate and test (5) is only advisory.
///  - `textContrastGuideline` has an open, unfixed false negative: it screenshots
///    the layer and partitions foreground/background by a naive light/dark
///    histogram, so white (0xffffff) on 0xfafafa passes. It is not in this file
///    at all; contrast is asserted on COLOUR VALUES in test/ui/contrast_test.dart.
///  - `labeledTapTargetGuideline` only checks the label is non-empty — a tile
///    labelled `button1` passes, and a tile leaking its whole vocalization passes.
///
/// Switch Access / Switch Control CANNOT be tested automatically at all: no API
/// simulates scanning, group selection, or point scanning. Test (3)'s traversal
/// order is a weak regression guard on intent, not proof any of those work.
///
/// Manual-only, each guarding a top-severity failure, and each lives in
/// docs/CHECKLIST.md: TalkBack/VoiceOver announcing the DISPLAY label and
/// speaking the vocalization only on double-tap; empty slots announced as buttons
/// in edit mode; the scan highlight visible against every theme including high
/// contrast; exiting edit mode and the text field using only a switch.
///
/// This suite does not "test accessibility". It catches four regressions and
/// leaves the rest to the device pass.
void main() {
  Finder slot(Tile t) => find.byKey(ValueKey<String>('slot_${t.row}_${t.col}'));

  // (1) GEOMETRY — the real tap-target gate. Not meetsGuideline, whose boundary
  // skip would measure only 2 of 12 tiles. Hand-measure all twelve.
  testWidgets('every tile is at least 76dp on both axes at 2.0x on an SE', (
    tester,
  ) async {
    tester.useDevice(Device.seLike);
    await tester.pumpApp(textScale: 2);

    for (final t in kTestTiles.whereType<Tile>()) {
      final size = tester.getSize(slot(t));
      expect(
        size.width,
        greaterThanOrEqualTo(76.0),
        reason: 'tile "${t.label}" is ${size.width}dp wide at 2.0x on seLike',
      );
      expect(
        size.height,
        greaterThanOrEqualTo(76.0),
        reason: 'tile "${t.label}" is ${size.height}dp tall at 2.0x on seLike',
      );
    }
  });

  // (2) LABEL CORRECTNESS — the check no guideline makes. The semantic label is
  // the short DISPLAY handle, and it must not leak the whole spoken sentence a
  // scanning user would then hear on every step.
  testWidgets('each tile is a labelled button whose label is not its sentence', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();

    for (final t in kTestTiles.whereType<Tile>()) {
      final node = tester.getSemantics(slot(t));
      expect(
        node,
        isSemantics(
          label: t.label,
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        node.label,
        isNot(contains(t.vocalization)),
        reason:
            'tile "${t.label}" leaks its vocalization into the semantic label; '
            'a screen reader user would hear the whole sentence on every scan '
            'step',
      );
    }
  });

  // (3) TRAVERSAL ORDER — a regression guard on INTENT, not a proof Switch Access
  // works. The lower-centre arc holds the highest-priority phrases for thumb
  // reach; row-major traversal would make "I need to leave" the 8th-to-11th thing
  // TalkBack reads. `sortKey: OrdinalSortKey(priority)` fixes that, and this test
  // exists so nobody silently reverts it. The negative assertion is the point:
  // without it, a layout that happened to equal priority order would pass with
  // the sortKey deleted.
  testWidgets('the screen reader visits tiles by priority, not by layout', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();

    final ordered = tester.semantics.simulatedAccessibilityTraversal(
      startNode: find.semantics.byLabel(kByPriority.first.label),
      endNode: find.semantics.byLabel(kByPriority.last.label),
    );

    expect(
      ordered.map((n) => n.label).toList(),
      kByPriority.map((t) => t.label).toList(),
    );
    expect(
      ordered.map((n) => n.label).toList(),
      isNot(kTestTiles.whereType<Tile>().map((t) => t.label).toList()),
      reason:
          'Traversal collapsed back to row-major layout order. '
          'Someone dropped the sortKey.',
    );
  });

  // (4) ANTI-CLAMP. No guideline catches this: contrast and tap target both stay
  // green while the text quietly stops growing. 'Yes' stays one line at both
  // sizes, so its height is pure scale.
  testWidgets('text grows with the user text size, never clamped', (
    tester,
  ) async {
    tester.useDevice(Device.small);

    await tester.pumpApp();
    final base = tester.getSize(find.text('Yes')).height;

    await tester.pumpApp(textScale: 2);
    final scaled = tester.getSize(find.text('Yes')).height;

    // 1.8, not 2.0: tolerate line-height rounding while failing hard on a clamp.
    expect(
      scaled,
      greaterThan(base * 1.8),
      reason:
          'text did not grow at 2.0x — someone clamped TextScaler to keep '
          'the fixed grid tidy; 200%+ must be honoured',
    );
  });

  // (5) ADVISORY TRIPWIRES. Kept as one-line nets, NOT gates — see the header for
  // why each is weak. `await expectLater`, never `expect`: meetsGuideline returns
  // an AsyncMatcher and a plain expect() checks nothing.
  //
  // The three standards-based guidelines only: labeled (non-empty), Android 48dp,
  // iOS 44dp. There is deliberately NO stricter 76dp whole-screen guideline here,
  // because `MinimumTapTargetGuideline` measures EVERY tappable node and the
  // chrome (theme/settings/edit) and the 72dp compose field are intentionally
  // smaller than a crisis TILE. The 76dp floor is a tile requirement, and test
  // (1) is where it is enforced — hand-measured over all twelve tiles, which is
  // also the only thing that dodges the boundary skip.
  testWidgets('advisory: the built-in tap-target guidelines pass', (
    tester,
  ) async {
    tester.useDevice(Device.seLike);
    await tester.pumpApp(textScale: 2, accessibleNavigation: true);

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });
}
