#!/usr/bin/env python3
"""Reed contrast checker — WCAG 2.x ratio + APCA 0.98G-4g Lc for one fg/bg pair.

Usage:
    python3 contrast.py <fg-hex> <bg-hex> [--tier resting|lit|ring|chrome]
    python3 contrast.py --selftest

Tiers (Reed's two-tier floor):
    resting  WCAG >= 7.0  and |Lc| >= 60   (default; tile labels at rest)
    lit      WCAG >= 4.5  and |Lc| >= 45   (label on a lit tile, 1-3s transient)
    ring     WCAG >= 3.0  and |Lc| >= 45   (focus ring vs ground, SC 2.4.13)
    chrome   WCAG >= 3.0  and |Lc| >= 30   (keyline vs ground)

Exit code 0 = PASS, 1 = FAIL, 2 = bad input.
"""

import sys

# --- APCA 0.98G-4g constants. Do not edit; validated by --selftest. ---
_RCO, _GCO, _BCO = 0.2126729, 0.7151522, 0.0721750
_MAIN_TRC = 2.4
_BLK_THRS, _BLK_CLMP = 0.022, 1.414
_NORM_BG, _NORM_TXT = 0.56, 0.57
_REV_BG, _REV_TXT = 0.65, 0.62
_SCALE = 1.14
_LO_OFFSET = 0.027
_LO_CLIP = 0.1
_DELTA_Y_MIN = 0.0005

TIERS = {
    "resting": (7.0, 60.0),
    "lit": (4.5, 45.0),
    "ring": (3.0, 45.0),
    "chrome": (3.0, 30.0),
}


def parse_hex(s):
    h = s.strip().lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    if len(h) == 8:  # 0xAARRGGBB-style input, drop leading alpha
        h = h[2:]
    if len(h) != 6:
        raise ValueError("expected #RGB or #RRGGBB, got %r" % s)
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def _apca_y(rgb):
    r, g, b = rgb
    return _RCO * r ** _MAIN_TRC + _GCO * g ** _MAIN_TRC + _BCO * b ** _MAIN_TRC


def _wcag_lin(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def wcag_ratio(fg, bg):
    def lum(rgb):
        r, g, b = (_wcag_lin(c) for c in rgb)
        return _RCO * r + _GCO * g + _BCO * b
    a, b_ = lum(fg), lum(bg)
    hi, lo = max(a, b_), min(a, b_)
    return (hi + 0.05) / (lo + 0.05)


def apca_lc(fg, bg):
    """Lc of text `fg` on background `bg`. Negative = light text on dark."""
    ty, by = _apca_y(fg), _apca_y(bg)
    if ty <= _BLK_THRS:
        ty += (_BLK_THRS - ty) ** _BLK_CLMP
    if by <= _BLK_THRS:
        by += (_BLK_THRS - by) ** _BLK_CLMP
    if abs(by - ty) < _DELTA_Y_MIN:
        return 0.0
    if by > ty:  # dark text on light bg
        s = (by ** _NORM_BG - ty ** _NORM_TXT) * _SCALE
        return 0.0 if s < _LO_CLIP else (s - _LO_OFFSET) * 100
    s = (by ** _REV_BG - ty ** _REV_TXT) * _SCALE
    return 0.0 if s > -_LO_CLIP else (s + _LO_OFFSET) * 100


def selftest():
    cases = [
        ("#000000", "#FFFFFF", "wcag", 21.00, 0.01),
        ("#E0E0E0", "#000000", "wcag", 15.91, 0.01),
        ("#888888", "#FFFFFF", "apca", 63.1, 0.1),
        ("#FFFFFF", "#000000", "apca", -107.9, 0.1),
    ]
    ok = True
    for fg, bg, kind, want, tol in cases:
        got = (wcag_ratio(parse_hex(fg), parse_hex(bg)) if kind == "wcag"
               else apca_lc(parse_hex(fg), parse_hex(bg)))
        good = abs(got - want) <= tol
        ok &= good
        print("%-4s %s on %s  want %8.2f  got %8.2f  %s"
              % (kind.upper(), fg, bg, want, got, "ok" if good else "MISMATCH"))
    print("selftest:", "PASS" if ok else "FAIL")
    return 0 if ok else 1


def main(argv):
    if "--selftest" in argv:
        return selftest()
    args = [a for a in argv if not a.startswith("--")]
    tier = "resting"
    for a in argv:
        if a.startswith("--tier"):
            tier = a.split("=", 1)[1] if "=" in a else argv[argv.index(a) + 1]
    if tier not in TIERS:
        print("unknown tier %r; pick one of %s" % (tier, ", ".join(TIERS)))
        return 2
    args = [a for a in args if a not in TIERS]
    if len(args) != 2:
        print(__doc__)
        return 2
    try:
        fg, bg = parse_hex(args[0]), parse_hex(args[1])
    except ValueError as e:
        print("error:", e)
        return 2

    ratio, lc = wcag_ratio(fg, bg), apca_lc(fg, bg)
    min_wcag, min_lc = TIERS[tier]
    wcag_ok, lc_ok = ratio >= min_wcag, abs(lc) >= min_lc

    print("fg %s  on  bg %s   tier=%s" % (args[0], args[1], tier))
    print("  WCAG  %6.2f:1   floor %.1f    %s"
          % (ratio, min_wcag, "PASS" if wcag_ok else "FAIL"))
    print("  APCA  Lc %+6.1f  floor %.0f     %s"
          % (lc, min_lc, "PASS" if lc_ok else "FAIL"))
    verdict = wcag_ok and lc_ok
    print("  ->", "PASS" if verdict else "FAIL")
    return 0 if verdict else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
