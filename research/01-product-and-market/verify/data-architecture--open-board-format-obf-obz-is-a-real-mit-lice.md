# data-architecture--open-board-format-obf-obz-is-a-real-mit-lice

> Phase: **verify** · Agent `a1eeb016a9dbc9fe8` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** Claim stands. Only wording nitpick: MIT licenses the reference implementation (open-aac/obf) and the spec site repo (open-aac/openboardformat), rather than the spec document itself, which openaac.org calls "open-licensed." Practically no impact on a Flutter reimplementation. Worth noting separately: the Ruby reference impl is effectively dormant (4 stars, last real commits July 2022, only a Ruby-3 compat fix in June 2025), so treat the spec as stable-but-frozen rather than actively maintained — the format itself remains live and is supported by CoughDrop, Sensory Boards, and PiCom.

**Evidence:** I tried to break this claim on six fronts and could not. Every specific verified against primary source.

FIELD LISTS — verified by downloading lib/obf/external.rb (471 lines) and grepping directly, not trusting a summarizer:
- Board (lines 13-40): id, locale, format, name, default_layout, background, url, data_url, default_locale, label_locale, vocalization_locale, description_html, license, buttons, images, sounds, grid. All present, exactly as claimed.
- Button (lines 46-113): id, label, vocalization, action, actions, left, top, width, height, border_color, background_color in the literal hash; then load_board, translations, hidden (l.90), url (l.93), image_id (l.106), sound_id (l.113) added conditionally. All 17 confirmed.
- load_board (lines 60-67): literally {id, url, data_url}, with 'path' added only when zipping ("board_#{id}.obf"). Their "{id, url, data_url, path}" is exactly right including the zip nuance.
- Image (l.152-161) / Sound (l.227): id, width/height or duration, license, protected, url, data, data_url, content_type, path. Confirmed.
- Grid: line 276 is literally `res['grid'] = OBF::Utils.parse_grid(hash['grid'])`. Confirmed.
- OBZ manifest (l.363-375): {'format', 'root' => path to root board, 'paths' => {images, sounds, boards}} each mapping id => path, written via zipper.add('manifest.json', ...). Confirmed exactly.

VOCALIZATION vs LABEL — the load-bearing part for their product decision. Confirmed as genuinely distinct fields: separate keys in the button hash (l.48-49), and independently carried per-locale in translations (l.75: translations[loc]['vocalization']). The board even has a separate vocalization_locale distinct from label_locale (l.24-25), which only makes sense if spoken text is architecturally independent of tile caption. Their "Overwhelmed" -> "I need to leave, I am not able to talk right now" use case is exactly what the field model supports.

LICENSE — checked via GitHub API, not the rendered page. open-aac/obf: spdx_id MIT, LICENSE reads "Copyright (c) 2015 CoughDrop". open-aac/openboardformat (the spec site): also MIT. MIT confirmed.

STILL ALIVE IN 2026 — not a dead format. Currently implemented by CoughDrop, Sensory Boards, and PiCom (iOS App Store) for import/export.

TWO CAVEATS (do not refute the claim, but the product decision should know):
1. Reference implementation is near-dormant. open-aac/obf has 4 stars; last substantive commits are July 2022. The only 2025 activity (pushed_at 2025-06-15) is a community PR fixing URI.escape for Ruby 3 compat. The spec site repo's last push was 2025-01-13. The format is stable and adopted, but nobody should expect an actively evolving upstream — a Flutter implementation is a from-scratch port anyway, so this is low risk.
2. Slight license conflation: MIT covers the Ruby reference implementation and the spec website's source repo. The normative spec document itself is a Google Doc linked from openaac.org, which describes the format as "open-licensed" rather than carrying an MIT header. Practically irrelevant — file formats aren't copyrightable as such, and implementing OBF in Flutter carries no license risk either way — but "MIT-licensed format" is loosely worded; "MIT-licensed reference implementation of an openly-licensed format" is precise.

Their field list omits protected_source, protected_content_user_identifier (l.28), and ext_* extension attributes — omissions, not errors, and they never claimed exhaustiveness. Their stated method (reading external.rb) is exactly what I independently reproduced, and it produced accurate results. Confidence "high" is warranted.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
PRODUCT IDEA UNDER RESEARCH — "Dignified offline AAC for adults & teens with situational speech loss"

Who it's for: Autistic adults and teens who go non-speaking during shutdowns/meltdowns/sensory overload, plus people with selective mutism, aphasia, or post-seizure speech loss. Communities: r/autism, r/AutisticAdults, r/selectivemutism, AAC communities.
The problem: Mainstream AAC apps are built for young children — cartoon avatars, "parental" account gates, kiddie vocabulary — infantilizing for adults, so they abandon them. Premium options (Proloquo2Go/TouchChat/LAMP) run ~$299 and are iOS-only.
Why offline is essential: It's a disability accommodation, not a networked service. The user must be able to "speak" instantly — in a shop, an ER, a car with no signal, mid-shutdown — with zero login, zero loading, full privacy.
The core job: Tap a phrase/symbol tile (or type) and the phone speaks it aloud, instantly, offline, adult-appropriate design, no account.
MVP: grid of large customizable phrase tiles + "type to speak" box + on-device TTS. Editable categories. No sign-up. Nothing leaves device. Dark, calm, adult visual design.
Risks: TTS must sound acceptable; design must feel adult without being cold; must be usable one-handed by someone in distress.
Target stack: Flutter (cross-platform iOS + Android; user prefers Flutter over React Native).
Today's date: 2026-07-15. Prefer recent sources (2024-2026).


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "data-architecture". A product decision depends on it, so it must be right.

CLAIM: Open Board Format (OBF/OBZ) is a real, MIT-licensed, JSON-based AAC interop format whose field model maps almost exactly onto this app's needs
THEIR DETAIL: Confirmed the actual field list by reading the reference implementation source (open-aac/obf lib/obf/external.rb). Board: id, locale, format, name, default_layout, background, url, data_url, default_locale, label_locale, vocalization_locale, description_html, license, buttons, images, sounds, grid. Button: id, label, vocalization, action, actions, left, top, width, height, border_color, background_color, load_board, translations, hidden, url, image_id, sound_id. load_board nests {id, url, data_url, path}. Image/Sound: id, width/height or duration, license, protected, url, data, data_url, content_type, path. Grid parsed via OBF::Utils.parse_grid (rows/columns/order matrix). .obz = ZIP with manifest.json {format, root, paths:{images,sounds,boards}} mapping ids to paths. Critically: 'vocalization' is separate from 'label' — the spoken text differs from the tile caption, which is exactly the adult-AAC need (tile reads 'Overwhelmed', speaks 'I need to leave, I am not able to talk right now').
THEIR CLAIMED SOURCES: https://raw.githubusercontent.com/open-aac/obf/master/lib/obf/external.rb, https://github.com/open-aac/obf, https://www.openaac.org/docs.html
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
