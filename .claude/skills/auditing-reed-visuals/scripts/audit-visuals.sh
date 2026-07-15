#!/usr/bin/env bash
# Reed — "does this look ten years old" visual audit.
# Run from the repo root. Scans lib/ only. Exits 1 on any finding, so it can gate CI.
set -uo pipefail

if [ ! -d lib ]; then
  echo "audit-visuals: no lib/ directory — nothing to scan."
  echo "  (Expected ./lib relative to \$PWD: $PWD)"
  exit 2
fi

HITS=0
GREP=(grep -rnE --include=*.dart --binary-files=text)

# report <tell> <why> <extended-regex> [extra grep args...]
report() {
  local tell="$1" why="$2" re="$3"; shift 3
  local out
  out="$("${GREP[@]}" "$@" -- "$re" lib/ 2>/dev/null || true)"
  [ -z "$out" ] && return 0
  HITS=$((HITS + 1))
  printf '\n=== %s\n    %s\n' "$tell" "$why"
  printf '%s\n' "$out" | sed 's/^/    /'
}

echo "Reed visual audit — scanning lib/"

# ---------------------------------------------------------------- dated tells
report "radius literal < 16dp" \
  "The loudest tell. 4dp on a 105dp tile is 2014. Tile and type field are 20dp; focus ring 22dp; inner chips are computed as outer-minus-padding. Verify each hit is on an element <=60dp; anything larger is a finding." \
  '(circular|elliptical)\( *([0-9]|1[0-5])(\.[0-9]+)? *[,)]|borderRadius: *[0-9]{1,2}(\.[0-9]+)? *[,)]'

report "elevation / BoxShadow / Card" \
  "Depth comes from tonal steps and the keyline. Shadows are banned outright, and a Card is the 2014 enterprise grid: shadow plus rounded rect plus centred content IS the failure mode." \
  'elevation:|BoxShadow|shadowColor:|kElevationToShadow|PhysicalModel|\bCard\(|CardTheme'

report "grey umbra (proxy check)" \
  "The real Material-2 tell is a grey umbra on a pure-grey surface, not the mere existence of a shadow. This greps the umbra half only; judge the surface by eye." \
  'Colors\.(grey|black(12|26|38|45|54|87)?)\b|Color\(0x[0-9A-Fa-f]{2}(000000|9E9E9E|BDBDBD|E0E0E0)\)'

report "Material-2 500-series hex" \
  "The stock M2 palette. Reed's colours live in the token file and nowhere else." \
  '2196F3|4CAF50|F44336|007BFF'

report "pure zero-chroma neutral" \
  "#FFFFFF / #808080 / #000000 are banned outside high contrast — zero-chroma neutrals are the cheapest tell that nobody chose anything. High contrast uses #FFFCF7 and #0B0906 and is still warm." \
  '0xFFFFFFFF|0xFF000000|0xFF808080|Colors\.white\b|Colors\.black\b'

report "ContinuousRectangleBorder" \
  "Not an iOS-grade squircle: it needs its radius multiplied by ~2.3529, degenerates into a TIE-fighter shape earlier for it, and centres strokes regardless of strokeAlign. Use RoundedSuperellipseBorder." \
  'ContinuousRectangleBorder'

report "Border.all()" \
  "Defaults to 1.0 LOGICAL px = 3 physical pixels on a 3x phone. That is a rule, not a hairline. Use 1.0 / devicePixelRatio." \
  'Border\.all\('

report "gradient" \
  "A 2-stop lightness ramp top-to-bottom is the tell; all gradients are banned. A flat, opaque, dyed field is better." \
  'LinearGradient|RadialGradient|SweepGradient|Gradient\(|gradient:'

report "blur / translucency / shader" \
  "Contrast over arbitrary content is non-certifiable by construction — translucency deletes the contrast gate. Opacity() also breaks the opaque-fill rule." \
  'BackdropFilter|ImageFilter\.blur|Opacity\(|FadeTransition|ShaderMask|withOpacity\(|withValues\(.*alpha'

report "divider" \
  "2026 separates with space and tonal steps. Dividers turn chips into a spreadsheet. The 14dp/22dp gap IS the design." \
  '\bDivider\b|VerticalDivider|Divider\.createBorderSide'

report "weight below 400 / bold display type" \
  "The Roboto Light hangover. Reed runs w500-w600, and never w700 at poster scale — bold at 100pt closes the counters." \
  'FontWeight\.(w100|w200|w300|thin|extraLight|light)|FontWeight\.w[89]00|FontWeight\.bold\b'

report "icon from a font" \
  "There are no icons. Chrome is lowercase words: theme, edit, show, settings. A word needs no semanticLabel because it is one." \
  '\bIcon\(|Icons\.|CupertinoIcons\.|IconButton\('

report "auto-shrink / ellipsis on an utterance" \
  "Auto-shrink makes the longest phrase the smallest and defeats the user's own text-scale setting; an ellipsis on an AAC utterance is a different utterance." \
  'FittedBox|TextOverflow\.(ellipsis|fade)|AutoSizeText'

report "motion" \
  "All motion is banned — ripples, page transitions, theme crossfades, spring physics." \
  'AnimatedContainer|AnimatedOpacity|AnimatedSwitcher|AnimationController|Tween\(|CurvedAnimation|Hero\(|InkWell|InkResponse|PageRouteBuilder|SlideTransition|ScaleTransition'

report "ALL-CAPS string or text transform" \
  "All caps on an AAC utterance reads as shouting — catastrophic when the phrase is 'I need a minute'. Chrome is authored lowercase in the string table, never transformed." \
  "toUpperCase\(\)|toLowerCase\(\)|'[A-Z]{4,}[ A-Z]*'|\"[A-Z]{4,}[ A-Z]*\""

report "straight apostrophe in a shipped string" \
  "Real apostrophes. \"I can't talk right now\" set with a typewriter quote reads as a database dump." \
  "[A-Za-z]'[a-z]"

report "colour literal outside the token file" \
  "The token file is the only file permitted a colour literal. Every design system that rotted, rotted by someone typing a hex at 11pm." \
  'Color\(0x|Color\.fromARGB|Color\.from\(' --exclude=tokens.dart

# ------------------------------------------------------- permanent visual bans
report "banned register (mascot / reward / gamification / encouragement)" \
  "The wedge. Reed is a specifier for adults, not a sticker chart. Field Notes has never once told anyone they are doing a good job." \
  'mascot|avatar|puzzle|confetti|streak|badge|reward|sticker|trophy|celebrat|great job|well done|nice work|good job|keep it up|encourage|progress(Bar|Indicator)|LinearProgress|CircularProgress|gamif|rainbow' -i

report "banned surface treatment" \
  "Flat, opaque, still. Depth from tone and edge only." \
  'neumorph|glassmorph|liquid *glass|frosted|bevel|emboss|inner *shadow|long ?shadow|grain|noise *texture|mesh *gradient' -i

# -------------------------------------------- letterSpacing above the 17pt line
DARTS="$(find lib -name '*.dart' 2>/dev/null)"
LS=""
[ -n "$DARTS" ] && LS="$(awk '
  FNR == 1 { for (i in win) delete win[i] }
  { line[FNR] = $0; file[FNR] = FILENAME; n = FNR }
  match($0, /fontSize: *[0-9]+(\.[0-9]+)?/) {
    v = substr($0, RSTART + 10, RLENGTH - 10) + 0
    if (v > 17) { big[FILENAME "\t" FNR] = v }
  }
  { all[FILENAME "\t" FNR] = $0 }
  END {
    for (k in big) {
      split(k, p, "\t"); f = p[1]; ln = p[2] + 0; found = 0
      for (d = -8; d <= 8; d++) {
        key = f "\t" (ln + d)
        if (key in all && all[key] ~ /letterSpacing/) { found = 1; break }
      }
      if (!found) printf "%s:%d: fontSize %s with no letterSpacing in the surrounding style\n", f, ln, big[k]
    }
  }
' $DARTS 2>/dev/null | sort || true)"

if [ -n "$LS" ]; then
  HITS=$((HITS + 1))
  printf '\n=== letterSpacing left at 0 above 17pt\n'
  printf '    Flutter'"'"'s default tracking is calibrated for ~14pt, so doing nothing is doing the wrong thing.\n'
  printf '    As size rises, weight falls and tracking tightens: 20pt -> -0.01em, 96pt -> -0.02em.\n'
  printf '%s\n' "$LS" | sed 's/^/    /'
fi

# ------------------------------------------------------------------- the honest part
cat <<'EOF'

--- NOT checkable here. Review these by eye, every time:
    * Radius-to-size ratio. A hit above is only a finding if the element exceeds 60dp,
      and the absence of a hit does not prove the ratio is right. Target roughly 1:6.
    * Whether a shadow's umbra sits on a pure-grey surface, which is the actual M2 tell.
    * Colour harmony, and whether the four stocks still read as staggered cloth.
    * Composition: gutter inequality (14 vs 22), the four-pointed star of negative space
      where four tiles meet, the shared last baseline across a row of bottom-anchored labels.
    * Type-size spread across the app. Reed runs 15 -> 140, or 1:9.3. Anything under 3:1 is flat.
    * Copy register. No grep catches a sentence that talks down to someone.
EOF

if [ "$HITS" -gt 0 ]; then
  printf '\nFAIL: %d tell(s) hit. Each needs a decision, not a suppression.\n' "$HITS"
  exit 1
fi
printf '\nPASS: no mechanical tells. The eyeball list above is still yours.\n'
exit 0
