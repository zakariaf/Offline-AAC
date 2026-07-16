# Reed — brand mark

A **bulrush reed** (cattail): slender stalk, the oblong seed head, two strappy
leaves rising from one base. The name carries three meanings and the mark holds
all of them at once:

- the **reed** that vibrates to give a wind instrument its *voice* — an app that
  gives someone their voice;
- the **reed pen** (calamus), one of the oldest writing tools — text, typing,
  "read";
- the calm of the **plant** itself — warm, natural, adult, not clinical.

The amber seed head is the single warm focal point: the spark of voice.

## Palette (from `lib/ui/core/tokens.dart`)

| role | ink build | light build |
|---|---|---|
| ground | `#1A140D` (inkT20) | `#FAF5EC` (warm paper) |
| stalk / spike | `#F4EEE4` | `#241C12` |
| leaves | `#C4B097` / `#B7A489` | `#B79B77` / `#A98C66` |
| seed head (amber) | `#D0863F` | `#B26A3C` |

No gradients, no shadows, no bevels — flat and timeless, matching Reed's own
visual bans. The wordmark is set in **Atkinson Hyperlegible Next** (the app's
typeface), weight ~680.

## Files

| file | use |
|---|---|
| `reed-icon.svg` | vector source (ink build) |
| `reed-icon-1024.png` / `-512` / `-180` | app icon, ink — store + launcher sizes |
| `reed-icon-light-1024.png` | app icon, light background |
| `reed-wordmark-light.png` / `-dark.png` | horizontal lockup, transparent PNG |
| `brand-showcase.png` | one-image overview |
| `*.html` | render sources (edit these, then re-render) |

## Regenerate

Rendered with headless Chrome (only rasteriser on this machine):

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CHROME" --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
  --window-size=1024,1024 --default-background-color=00000000 \
  --screenshot=reed-icon-1024.png reed-icon.html
```

Wordmarks use `--window-size=1200,440`; keep `--default-background-color=00000000`
for the transparent lockups. Resize with `sips -z H W in.png --out out.png`.

## Not yet wired

- **AppLander icon**: `set_app_icon` fetches from a public https URL, so upload
  `reed-icon-1024.png` via the AppLander web UI (or host it and pass the URL).
- **App launcher icon**: not yet generated into `android/` / `ios/` — run
  `flutter_launcher_icons` against `reed-icon-1024.png` when ready.
