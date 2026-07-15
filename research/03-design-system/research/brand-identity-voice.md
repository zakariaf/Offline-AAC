# brand-identity-voice

> Phase: **research** · Agent `ab284f8b9ae18dc32` · Run `wf_f237e8a6-694`

## Result

## Summary

The central finding is that findable-vs-discreet is a false tension, and it dissolves twice. First: findability is pre-attentive (color + silhouette, ~13ms) while outing is semantic (requires decoding a pictogram). An abstract, non-representational mark is therefore MAXIMALLY findable AND maximally discreet — the two goals only conflict if you assume findability requires depiction. Second, and bigger: the real outing risk is not the icon at all, it's the LABEL under it. Android renders `android:label` at ~12sp directly beneath every icon, and stock launchers don't let users rename apps. A stranger glancing at "Speech Assistant AAC" learns everything; at "Reed" they learn nothing. And because the Play Store title is a completely separate field from `android:label`, you can ship Play title "Reed: AAC & Text to Speech" for ASO while the home screen says only "Reed" — 100% of the searchability, 100% of the discretion, zero compromise. Reinforcing this: Google Play indexes the full 4,000-char long description semantically (Apple does not index descriptions at all), so you can rank for "nonverbal", "selective mutism", "autistic shutdown" in honest prose without those words ever touching the user's home screen. On the icon, 2026 has handed the project a gift: iOS 26's six icon modes (Default/Dark/Clear-Light/Clear-Dark/Tinted-Light/Tinted-Dark, composed via Icon Composer) and Android's themed icons — auto-derived since Android 16 QPR2 even if you don't supply a monochrome layer — both now flatten your icon to a single-color silhouette outside your control. "Must survive as pure monochrome" is no longer taste; it's a platform requirement. Baked gradients and baked shadows (the 2015 look) now actively fight the OS. The platform trend and the discretion need point at the identical answer: one bold silhouette, one hue, no baked depth. On tone, the positive register the brief is missing is matter-of-fact warmth — the voice of a capable friend who doesn't make a thing of it (steal GOV.UK's method, Signal's privacy register, Tapbots' dryness). The load-bearing rule that falls out: no error in this app is ever a modal dialog, because a modal during shutdown is a trap demanding a decision from someone who has none available. The "no voice available" error is not a message at all — it's a silent fallback to show mode with one quiet line underneath. Finally, privacy should not ask for trust, it should hand over a receipt: "no internet permission" is a fact checkable pre-install in the manifest-derived permissions list — but NOT via Play's Data Safety card, which is self-declared and would be dishonest to cite as verification.

### The Play Store title and the home-screen launcher label are separate fields and need not match — this single fact resolves the entire discretion-vs-ASO tension

*Confidence: high, **LOAD-BEARING***

Play Console store-listing title is capped at 30 characters (reduced from 50 in April 2021, effective Sept 29 2021). The home screen label comes from `android:label` in AndroidManifest.xml, with `android:shortLabel` used by launchers when space is tight. Nothing in Play policy requires them to match; keyword-suffixed store titles with short launcher labels are standard practice. Ship Play title `Reed: AAC & Text to Speech` (26 chars) and `android:label="Reed"`. Recommend <15 chars for the label to avoid launcher truncation.

- https://support.google.com/googleplay/android-developer/answer/9898842

- https://www.apptweak.com/en/aso-blog/how-to-shorten-your-app-name-on-the-play-store

- https://www.tutorialpedia.org/blog/what-is-the-maximum-length-for-an-android-application-name/

### The launcher LABEL, not the icon, is the actual outing surface — discretion is ~80% a naming problem

*Confidence: high, **LOAD-BEARING***

Android home screens display the app label by default at ~12sp immediately under a ~60x60dp icon. Stock launchers (Pixel) provide no rename; only third-party launchers (Nova) do. Given 11/12 use AAC only where they feel safe and 4/12 avoid situations to dodge device reactions, the text string is far more semantically legible to a glancing bystander than any 60x60 mark. This inverts the brief's framing: agonizing over icon discretion while shipping a name containing 'AAC' or 'Speech' is optimizing the wrong surface.

### Google Play semantically indexes the full 4,000-char long description; Apple indexes no description at all

*Confidence: high, **LOAD-BEARING***

Google Play indexes title (30), short description (80), and long description (4,000) — ~4,110 indexable chars — using NLP/semantic indexing. Apple indexes only Title, Subtitle, and the hidden 100-char Keywords field; the App Store description is conversion copy only, never indexed. Consequence for an Android-first app: you do NOT need 'AAC' or 'nonverbal' in the name to rank for them. Write honest prose containing 'selective mutism', 'non-speaking', 'autistic shutdown', 'meltdown', 'sensory overload', 'text to speech', 'situational mutism' and Google will index it. Keyword-stuffing is unnecessary and counterproductive under semantic indexing.

- https://appfollow.io/blog/google-play-aso-keywords

- https://asomobile.net/en/blog/aso-in-2026-the-complete-guide-to-app-optimization/

- https://jenli.net/tpost/atx9hpv6n1-app-store-and-google-play-metadata-writi

### Android 16 QPR2 auto-themes icons that lack a monochrome layer — shipping one is now a control move, not an enhancement

*Confidence: high, **LOAD-BEARING***

Themed icons landed in Android 13 (API 33): if the user enables themed icons and the launcher supports it, the system tints the `<monochrome>` drawable from wallpaper. Per Android docs: 'Starting with Android 16 QPR 2, Android automatically themes app icons for apps that don't provide their own.' So on QPR2+ the OS will DERIVE a monochrome silhouette from your foreground — badly — if you don't author one. Supplying a hand-tuned `<monochrome>` layer is the only way to control what a large share of users actually see.

- https://developer.android.com/develop/ui/compose/system/icon_design_adaptive

- https://developer.android.com/distribute/aep/aep-req-theme-app-icons

### Android adaptive icon geometry — exact specs

*Confidence: high, **LOAD-BEARING***

All layers 108x108dp (foreground, background, monochrome). Safe zone 66x66dp centered. 18dp reserved on each of four sides for masking/visual effects. Logo/artwork min 48x48dp, max 66x66dp. Vectors preferred over bitmaps. Defined via `<adaptive-icon>` with `<background>`, `<foreground>`, `<monochrome>` children.

- https://developer.android.com/develop/ui/compose/system/icon_design_adaptive

### iOS 26 ships six icon modes and composes effects itself via Icon Composer — baked gradients and shadows are now actively wrong

*Confidence: high, **LOAD-BEARING***

iOS 26 modes: Default, Dark, Clear Light, Clear Dark, Tinted Light, Tinted Dark. Tinted applies a single user-chosen color overlay across all icons (color slider, or auto-match to iPhone body/MagSafe case color). Clear renders icons semi-transparent over wallpaper. Icon Composer ships with Xcode 26, exports a single `.icon` file, previews across iPhone/iPad/Mac/Watch and across modes, and the system applies Liquid Glass specular highlights, blur and shadow at render time. You supply layered flat artwork; you do not control final pixels. Any gradient or drop shadow you bake in will double up against the system's.

- https://www.createwithswift.com/crafting-liquid-glass-app-icons-with-icon-composer/

- https://www.macobserver.com/tips/how-to/customize-app-icons-in-ios-26-complete-guide/

- https://medium.com/@foks.wang/adapting-app-icons-for-ios-26s-liquid-glass-style-5bde00f565fa

### CONVERGENCE: both platforms in 2026 force the icon through a single-color flattening, so silhouette-first is a requirement, not a style — and it happens to be exactly what discretion wants

*Confidence: high, **LOAD-BEARING***

Apple's Tinted Light/Tinted Dark and Android's themed icons both reduce the mark to one tint + shape. An icon that survives that test is an icon whose SHAPE carries identity — which is precisely the pre-attentive property that makes it findable, and precisely the absence of pictorial detail that makes it non-decodable by a bystander. The 2026 platform direction and the product's dignity requirement point at the identical artifact. This is the strongest available argument against a speech-bubble/mouth/person glyph, and it's a technical one rather than an aesthetic preference.

### Findability and discretion are separable because findability is pre-attentive and outing is semantic

*Confidence: medium, **LOAD-BEARING***

Basic shape recognition occurs in ~13ms; the brain categorizes every icon on a glanced-at home screen in ~100-200ms. That process runs on pre-attentive features — color, curvature, orientation, size (cf. Treisman feature-integration theory) — in parallel and without semantic access. YOU find your icon by hue + silhouette + grid position, needing zero legibility. A STRANGER needs semantics (a speech bubble, a mouth, a waveform) to decode it as AAC. Therefore an abstract non-representational mark maximizes both. The tension in the brief only exists if findability is assumed to require depiction.

- https://thisisglance.com/learning-centre/what-makes-app-icons-instantly-recognisable-to-users

### Eye-tracking evidence: rounded-square icon borders beat circular/mixed; varied color beats uniform color for visual search

*Confidence: medium, **LOAD-BEARING***

Chen et al., Displays (ScienceDirect S0169814121000780): rounded-square icons yielded faster identification and fewer eye fixations than circular or mixed-shape icons; icons with varied colors improved search efficiency, reducing cognitive load, fixation duration and task completion time vs uniform-colored icon sets. NOTE: full text returned HTTP 403 — I could not verify participant count, effect sizes, or significance levels. Treat the direction as indicative, not the magnitudes. Practical read: your icon should be a color POP-OUT against the user's other icons, and the Android rounded-square mask is working in your favor.

- https://www.sciencedirect.com/science/article/abs/pii/S0169814121000780

### Name collision: 'Ebb' is dead — and it dies on a direct category hit

*Confidence: high, **LOAD-BEARING***

`works.ebb.v4` on Google Play is described as an app that 'helps you talk about what's important to you in life using images that resonate with you or that you've created yourself' — an AAC-adjacent communication app, i.e. a same-category collision. Separately, Headspace's AI meditation companion is named Ebb (major brand, adjacent mental-health space), plus 5+ 'Ebb & Flow' yoga studio apps. Despite Ebb being metaphorically ideal (speech that recedes with the certainty of return, 3 letters, beautiful set in type, neutral on a home screen), it is unusable.

- https://play.google.com/store/apps/details?id=works.ebb.v4

### Name collisions: 'Sotto' and 'Understudy' are both taken on Google Play

*Confidence: high, **LOAD-BEARING***

`com.sotto.app` — 'Sotto', a dating app. `com.understudy.off_book_native_v2` — 'Understudy: For actors', a line-memorization tool (thematically adjacent to a speech app, which worsens it), plus `com.understudy.app` 'The Understudy'. 'Aloud' is not taken as an exact name but sits in a dense field of 'Read Aloud' TTS apps in the same store category — ASO poison and user confusion. All three weakened or eliminated.

- https://play.google.com/store/apps/details?id=com.sotto.app

- https://play.google.com/store/apps/details?id=com.understudy.off_book_native_v2

### Play's Data Safety card is developer-SELF-DECLARED and must not be cited as verification — the permissions list is the honest, manifest-derived proof

*Confidence: high, **LOAD-BEARING***

Google requires a Data Safety form even for apps collecting nothing, and defines 'collecting' as transmitting data off-device. But the section is developer-attested; the 'Verified' badge for Data Safety transparency exists only for VPN apps. By contrast, Play's 'App permissions → See more' list is generated from the manifest and 'is based on technical information that describes how the developer's app works' — explicitly distinct from Data Safety. An app omitting `android.permission.INTERNET` cannot show 'has full network access', and that absence is checkable BEFORE install. Claiming 'Google verified our privacy' would be false; pointing at the permissions list is true and rarer.

- https://support.google.com/googleplay/answer/11416267

- https://support.google.com/googleplay/android-developer/answer/10787469

### Emergency Chat (Leonard Elezi) is the closest precedent and validates both the show-mode thesis and the first-person-author provenance move

*Confidence: high, **LOAD-BEARING***

Built by an autistic man after a meltdown where friends stood by helplessly; default text targets autistic meltdown 'where speech centres stay non-functional for a while even after recovery' — i.e. situational, not permanent, exactly this app's thesis. Core interaction is hand-the-phone-to-a-stranger with an explanatory screen; title and text are user-editable in settings. Free, iOS + Android + Windows + Ubuntu Touch. Its authority comes entirely from a named autistic author with standing — direct evidence that first-person authorship, not clinical credentialing, is what makes pre-written words acceptable in this category.

- https://leonardelezi.com/emergencychat/

- https://apps.apple.com/us/app/emergency-chat/id1024194363

### Screenshot mechanics: the first 2-3 carry nearly all the weight and are shown in search results without a tap

*Confidence: medium, **LOAD-BEARING***

Both App Store and Google Play surface the first 2-3 portrait screenshots directly in search results. ~90% of App Store visitors never scroll the full set. Place headline text in the upper portion (most visible in search-result crops). 2026 guidance favors 'Screenshot Story Flows' — a linear problem→solution→trust narrative rather than a feature list. Consequence: screenshot 1 must survive as a thumbnail, and it must do the filtering work.

- https://appilot.ai/blog/app-store-screenshot-best-practices

- https://appscreenshotstudio.com/blog/screenshot-story-flows-the-2026-framework-for-high-conversio

### System UI fonts fail at marketing-headline sizes; 2026 practice is a display sans at 60-90px, weight 700-900, tight tracking

*Confidence: medium*

SF Pro Display and Roboto are optimized for 13-17px legibility, not 80px impact, and read weak at headline size; 2026 indie practice is Inter/Manrope/DM Sans at 60-90px, weight 700-900, tight letter-spacing. Most common failure: a headline that reads fine at full size and vanishes at thumbnail — the test is 'if you can fit headline + subtitle + body comfortably, the headline is too small.' NOTE: this app should deliberately break this advice by setting screenshots in Atkinson Hyperlegible (the product's own face) — its disambiguated letterforms turn characterful at display size, and 'our marketing is set in a legibility typeface' is itself the pitch. I did not verify the status of Atkinson Hyperlegible Next / Mono (believed released by Braille Institute in 2025, expanded weights) — confirm before committing to a weight range.

- https://screenshototter.com/blog/best-fonts-app-store-screenshots

- https://dev.to/appscreenshotstudio/app-store-screenshots-that-convert-the-2026-design-guide-1d94

### Category naming conventions cluster into four registers, three of which are unusable for a dignity-thesis product

*Confidence: high, **LOAD-BEARING***

(1) Descriptive-clinical: 'Speech Assistant AAC', 'Snap Core First', 'TD Snap', 'LAMP Words for Life' — announces disability on the home screen, reads as durable medical equipment. (2) Latin-professional: 'Proloquo2Go' (proloquor, 'to speak out') — signals expensive clinical product, and the '2Go' suffix is dated 2009. (3) Verb-compound: 'TouchChat', 'GoTalk', 'CoughDrop' — reads as children's software. (4) Plain-word indie: 'Spoken', 'Emergency Chat' — the only register compatible with this thesis. The dignity-correct target is the register of adult indie tools (Things, Bear, Overcast, Halide, Ivory, Kagi, Arc): a short concrete noun that names nothing about the user.

## Design moves

- **Ship `android:label="Reed"` and Play store title `Reed: AAC & Text to Speech` (26/30 chars). Two different strings, two different surfaces, deliberately.**
  - Why: This is the whole discretion/ASO resolution in one line of manifest. The store title is read once, by a user who typed 'AAC' into search and wants confirmation they found the right thing. The launcher label is read a thousand times, in public, by everyone who glances at the phone. Optimizing both to the same string forces a loss on one; they're separate fields, so don't.
  - Risk: Play policy forbids misleading store titles; keyword-suffixing a real product name is standard and safe, but avoid stuffing beyond one descriptor pair. Also verify `shortLabel` is set — some launchers prefer it and an unset one can fall back to a longer string.
- **Name: **Reed**. Fallbacks in priority order: **Aside**, then a surname-class name (**Marlow**, **Wren**). Reject: Ebb, Sotto, Understudy, Aloud, Vox, Cue, Relay, Parley, Talkback, Echo.**
  - Why: A reed is the part that vibrates to make voice — the metaphor is for the founder, not the user. Four letters, sets beautifully (the ascender rhythm of 'Reed' is genuinely good in type), and critically it reads as a surname on a home screen: total discretion, because a bystander parses it as a contact or a notes app. 'Aside' is the runner-up (a theatrical aside is speech delivered differently; neutral, 5 letters). Rejections are evidence-based: Ebb collides with `works.ebb.v4`, a same-category communication app, plus Headspace's Ebb. Sotto and Understudy are taken on Play. Talkback is an Android accessibility service — a hard collision. Parley is phonetically adjacent to Parler. Aloud drowns in 'Read Aloud' TTS apps.
  - Risk: 'Reed' is a common word and surname → weak trademark, and Reed.co.uk (UK jobs) exists in a different class. For a solo dev on a 50-app challenge, beauty + discretion + no same-category collision beats TM strength — but if the app grows, this is the constraint that bites. I verified Ebb/Sotto/Understudy collisions directly; I did NOT run a Play/USPTO check on Reed, Aside, Marlow or Wren. Do that before committing. Wren additionally invites a bird mark, which walks straight into the banned animal-character territory — if you pick it, the icon must stay abstract.
- **Icon: a solid rounded-square field in ONE muted hue, with a single vertical slot cut clean out of it, slightly off-center. Nothing else. Working name: 'the kerf'.**
  - Why: Non-representational, so a bystander decodes nothing — but it's a strong asymmetric silhouette with a distinct hue, which is exactly the pre-attentive pop-out that makes it findable in ~200ms without any semantics. It survives Tinted/Clear/themed flattening natively because the identity IS the silhouette. And it means something to the owner: it's the text cursor of the type-to-speak field, and it's the gap where speech should be. Formally it's a Swiss-modernist move — one field, one cut — which is how you get beauty without motion, gradients, or a glyph.
  - Risk: An off-center vertical bar in a colored square can read as generic/branding-agnostic — it risks being forgettable rather than discreet. Mitigate with an unusual, ownable hue and an unmistakable slot proportion, and test it at 60x60 in a real home-screen grid alongside the user's actual apps, not on a white artboard. Also: a vertical slot at small size can look like a rendering artifact or a cracked screen. Prototype before committing.
- **Author the `<monochrome>` layer by hand. Do not let the OS derive it. Build to spec: 108x108dp layers, artwork inside the 66x66dp safe zone (48dp min), 18dp margins each side, vectors not bitmaps.**
  - Why: Since Android 16 QPR2 the system auto-themes icons that don't ship a monochrome layer — meaning if you skip it, the OS invents a silhouette from your foreground and it will be wrong. A large fraction of Android users run themed icons. This is the icon a lot of people actually see, so it deserves as much craft as the color one.
  - Risk: Themed icons are tinted from wallpaper, so you lose your hue entirely — the pre-attentive color channel disappears and silhouette must carry 100% of findability. This is a hard argument that the silhouette must be strong enough to work alone, which is a real test the 'kerf' mark has to pass.
- **Bake no gradients, no drop shadows, no gloss, no long shadows. Supply flat layered artwork only. For any future iOS build, author in Icon Composer and export a `.icon` file.**
  - Why: This is the single clearest 2015-vs-2026 delta and it's now technical, not aesthetic. iOS 26 composites Liquid Glass specular highlights, blur and shadow at render time across six modes (Default, Dark, Clear Light, Clear Dark, Tinted Light, Tinted Dark); Android tints from wallpaper. Both platforms took surface treatment away from the designer. A baked corner-to-corner blue→purple gradient with a centered white glyph — the 2015 house style — now double-composites against the system's own effects and looks broken, not dated.
  - Risk: Android-first means Icon Composer is not urgent; don't let iOS tooling drive the Android artifact. But design the layer separation NOW (background field / foreground slot) so an iOS port is a re-export rather than a redraw.
- **Argue it explicitly: the icon should be deliberately NEUTRAL, not legible-as-AAC. The counter-argument — 'a speech bubble makes it findable in a shutdown' — is empirically wrong, not just impolite.**
  - Why: The case FOR legible-as-AAC is that semantic clarity aids retrieval under cognitive load. But retrieval on a home screen doesn't run through semantics; it runs pre-attentively on color and silhouette in 100-200ms. A speech bubble buys zero findability the abstract mark doesn't already provide, and costs the user the thing 4/12 of them reorganize their life around: not being read. The case FOR legibility only holds for a first-time user who has forgotten what they installed — a one-time cost, paid once, against a permanent public exposure. Neutral wins on both counts.
  - Risk: One genuine exception: a caregiver or a paramedic trying to find the app on someone else's locked-out phone during a crisis. If that scenario matters, solve it with a lock-screen shortcut or a Quick Settings tile — NOT by making the home-screen icon self-describing. Don't let an edge case set the default.
- **Tone: 'matter-of-fact warmth' — a capable friend who doesn't make a thing of it. Enforce eight rules beyond the existing DON'Ts: (1) never narrate the user's emotional state; (2) the app never says 'we'; (3) errors state the fact, then the next action, never an apology; (4) no ellipses in errors; (5) no questions where a statement will do; (6) never 'just'; (7) second person, present, active; (8) ≤8 words for any string on the main surface.**
  - Why: The brief has a list of DON'Ts and no register. These convert it to a positive one. 'Never narrate emotional state' kills 'Feeling overwhelmed?' — the app does not know and guessing is presumptuous. 'No we' matters because 'we' implies a company in the room; there isn't one, and the only place a person should appear is the provenance page, where it becomes 'I'. 'Never apologize' is the subtle one: an apology implies the user needs soothing, which is the parental register arriving through the back door.
  - Risk: Dry can tip into cold, which the prior research explicitly warns against ('do not confuse adult with monochrome and cold'). The warmth has to come from what you choose to say — 'fix this later', 'that's the intended use' — not from adjectives or softeners. Read every string aloud; if it sounds like a form, rewrite it.
- **NO ERROR IS EVER A MODAL DIALOG. All errors are inline, non-blocking, and leave the app fully operable.**
  - Why: This is the highest-leverage finding in the tone work and it's architectural, not copy. A modal during a shutdown is a trap: it demands a decision from someone whose decision-making is exactly what's impaired, and it blocks the one screen they opened the app to use. Every AAC app that throws a 'TTS Engine Not Found — OK/Cancel' dialog has, at the worst moment of someone's day, replaced their voice with a form.
  - Risk: Some errors genuinely need acknowledgment (import about to overwrite everything). Handle those with inline two-button confirmation on the surface itself — `Clear this tile? [Clear] [Keep]` — never a system dialog, and never 'Are you sure?', which is a parental gate in disguise.
- **The 'no voice available' error is not a message. It is a silent fallback to show mode: render the phrase huge on screen, and put one quiet line beneath it — `No voice installed. This screen still works.` The repair instruction lives in Settings, not in the moment: `No voice installed. Android needs a speech engine. Fix this later — showing still works.`**
  - Why: This is the app's worst moment: someone cannot speak, taps a tile, and nothing happens. The error message's job is NOT to explain the error — it's to prove the product still does its job. Falling back to show mode means the tap still communicates; the failure becomes a mode change instead of a dead end. 'Fix this later' is the dignity line: it explicitly deprioritizes the chore and refuses to make the user do admin during a crisis. Nothing else in software says that.
  - Risk: Silent fallback can confuse a user who expected audio and is in a loud room where showing won't work. The one-line notice is what prevents that, so it must be present and legible in all three themes — but it must never take focus or block the phrase. Also: show mode is optimized for a stranger at arm's length while the app's theme may be dark/low-luminance for the user's eyes — the fallback must adopt show mode's luminance, not the ambient theme's.
- **Voice picker: never surface the OS's gender labels. Re-label neutrally and sort by measured fundamental frequency, low→high. Copy: `Voice` / `Android names its voices by code. These are sorted low to high.` / `Pitch` `Speed` sliders / `Every voice here plays a sample. Tap to hear it.`**
  - Why: This audience skews trans/nonbinary and 4/12 explicitly wanted nonbinary/middle-pitch voices. Android TTS exposes voices with opaque locale IDs (`en-us-x-tpd-network`) plus gender metadata. Every AAC app pipes that metadata straight through as Male/Female radio buttons, which forces a person choosing their own voice through someone else's binary. Sorting by pitch instead is more useful (pitch is what you're actually choosing), more honest (it's what the metadata approximates anyway), and it makes the middle of the range a first-class destination rather than an absence.
  - Risk: Measuring F0 per voice requires synthesizing a sample and analyzing it, or shipping a lookup table — real engineering cost for a solo dev, and it breaks when users install third-party engines. Cheap fallback: keep OS ordering but strip the gender labels and let the pitch slider do the work, with samples on tap. Ship that in v1 and measure later.
- **Per-tile provenance: in EDIT MODE only, every starter tile carries a maker's mark above the text field — `STARTER PHRASE · [NAME]` at 11sp, +0.08em tracking, weight 400, 60% opacity. The moment you change the text, that line becomes a single word: `Yours.`**
  - Why: This is the answer to 'how do you DESIGN provenance rather than write it.' It's a colophon distributed across twelve tiles. Pre-filling someone's voice is presumptuous because it arrives anonymous and therefore authoritative — it reads as correct, and deviating from it reads as error. A byline makes it a person's suggestion instead of a system default, and the `Yours.` state change turns editing from correction into authorship. Small caps rather than italic because italic hurts dyslexic readers.
  - Risk: Must NOT appear in speak mode — the grid stays chrome-free, and provenance is irrelevant when you're mid-shutdown trying to talk. Also 60% opacity on an 11sp string will fail contrast; treat it as decorative-adjacent and verify it still clears 4.5:1 in all three themes, or raise the opacity and lose the whisper.
- **Provenance page, titled `Where these phrases came from` (not 'About'). First person singular, named author, with standing declared. Copy: `I'm [name]. I go non-speaking a few times a month — usually in shops, sometimes at work.` / `These twelve phrases are the ones I actually needed. Nine came from me. Three came from people who tested this: [x], [y], [z].` / `They're a starting point, not a prescription. Most people replace half of them in the first week. That's the intended use.` / `Hold any tile to make it yours.`**
  - Why: Four moves are doing the work. (1) 'I' not 'we' — a named person, not a company; this is the only authored surface in the app and that's what makes it a gift. (2) Declared standing — the author is in the group; this is the entire difference between a gift and a clinician's word list, and it's exactly where Emergency Chat's authority comes from. (3) Per-source attribution — 'nine from me, three from [names]' — specificity is credibility. (4) 'Most people replace half of them in the first week. That's the intended use.' is the killer line: it pre-authorizes deletion, inverting the default presumption so that erasing the founder's words becomes compliance rather than rejection.
  - Risk: Requires the founder to disclose their own diagnosis publicly and permanently. That is a real, irreversible personal cost and it must be a free choice, not a growth tactic. If they won't, the honest fallback is to attribute solely to named testers who consented — do NOT fake standing, and do NOT retreat to an anonymous 'we', which forfeits the whole mechanism.
- **Privacy page: hand over a receipt, don't ask for trust. `This app has no internet permission.` / `That's not a promise — it's a fact you can check. Android won't let it connect even if it tried.` / `Settings → Apps → Reed → Permissions.` / `No accounts. No analytics. No crash reports. Nothing to opt out of, because there's nothing collected.`**
  - Why: 'That's not a promise — it's a fact you can check' is the line the whole privacy story turns on. Every app claims privacy and users have correctly learned to discount claims. Omitting `android.permission.INTERNET` converts a trust claim into a verifiable property of the binary — the app is technically incapable of exfiltration, and Play's permissions list (manifest-derived, unlike the self-declared Data Safety card) lets someone confirm it BEFORE installing. This is beautiful rather than legalese because it's short, checkable, and slightly defiant.
  - Risk: Never cite Play's Data Safety card as verification — it is developer-attested, and the 'Verified' badge exists only for VPN apps. Claiming Google verified it would be false and would poison the one credible thing you have. Also: no INTERNET permission permanently forecloses cloud voices, crash reporting and remote config — that's the trade, and it's the right one, but it's irreversible in users' minds the moment you ship the claim.
- **Screenshot 1: the real app grid, unretouched, no device bezel, no gradient background, headline at top: `For adults whose speech comes and goes.` Set in Atkinson Hyperlegible, the product's own face.**
  - Why: Screenshot 1's job is NOT explaining what the app does — this user already knows what AAC is, they've installed three and deleted them. The decision is 'is this one of THOSE.' So screenshot 1 must fire a single negative proof, and the most efficient one is a raw, adult, beautiful product screenshot where every competitor shows a marketing composite with a mascot: the medium is the message, this listing is not selling to your mum. The headline does audience + situational thesis in six words. Setting it in the app's legibility face rather than Inter/Manrope makes listing and app one object, and 'our marketing is set in a legibility typeface' is itself the pitch.
  - Risk: This deliberately breaks 2026 ASO convention (display sans, 60-90px, weight 700-900) and convention exists because it converts. Test at thumbnail size — the standard failure is a headline that reads at full size and vanishes in the search-result crop. Atkinson Hyperlegible may not have the weight range for 800+ display use; verify whether Atkinson Hyperlegible Next (believed 2025) ships heavier weights before committing. If it doesn't hold, keep the raw screenshot and reconsider only the typeface.
- **Screenshot 3 is the Android permissions screen showing no network access, headline `No internet permission. Check for yourself.`**
  - Why: Nobody in any category ships a screenshot of an OS settings page, which is exactly why it works — it's unfakeable-looking, verifiable, and it lands in the first three that Play shows in search results without a tap. For an audience that has been burned, a checkable fact outperforms any promise. It's also stark and typographically clean, which is on-brand.
  - Risk: A screenshot of a settings screen is visually inert and may read as a mistake or a broken asset at thumbnail size, hurting the first-three impression that carries ~90% of the weight. A/B it against a designed treatment of the same fact. Also, Play permission-screen UI changes across versions — this asset will need re-shooting.
- **Play short description (80 chars, indexed): `AAC for adults with situational speech loss. Offline, private, no cartoons.` (74). Long description: honest prose, no keyword stuffing, containing 'selective mutism', 'non-speaking', 'autistic shutdown', 'meltdown', 'sensory overload', 'text to speech', 'situational mutism'.**
  - Why: 'no cartoons' plants the flag in the one field a burned user sees in search results before tapping anything — it's the fastest possible negative proof and it costs 11 characters. And because Play semantically indexes all 4,000 chars of the long description (Apple indexes none), you can rank for 'nonverbal' and 'selective mutism' in real sentences without those words ever touching the home screen. The ASO tension the brief worries about is a real problem on iOS and a solved one on Android-first.
  - Risk: 'no cartoons' can read as bitter or as punching down at users who like symbols — and the prior research is clear that symbols are legitimate for many people and text-only is a v1 scope call, not a values statement. If it reads as contempt rather than relief, swap to `Offline, private, and not designed for children.` Also confirm current Play metadata policy on promotional/negative phrasing in the short description before shipping.

## References

- **Emergency Chat (Leonard Elezi)** https://leonardelezi.com/emergencychat/
  - Steal: The whole authority model: a named autistic author with declared standing, no institution, no clinical framing. Steal the hand-the-phone-to-a-stranger flow (it validates show mode), the user-editable explanation text, and the plainly declarative default copy. Study its App Store listing for how a dignity-first AAC product presents itself. Closest precedent in existence — read it before writing a single string.
- **GOV.UK content style guide / NHS digital service manual** https://www.gov.uk/guidance/style-guide
  - Steal: The single best steal for error copy. Say the thing, no adjectives, no apology, no ellipsis. 'Fact, then next action' is their house rule. Also steal their evidence-based word bans (never 'just', never 'simply' — both imply the user should have found it easy). This is the closest existing thing to the register the brief is groping for.
- **Signal** https://signal.org/
  - Steal: The privacy register: plain, unornamented, factual, zero marketing adjectives. Signal never says 'we take your privacy seriously' — it describes the mechanism and lets you check. Direct model for 'That's not a promise — it's a fact you can check.'
- **Mailchimp Voice & Tone guide** https://styleguide.mailchimp.com/voice-and-tone/
  - Steal: Not the voice (too chatty). Steal the METHOD: a matrix of tone-by-emotional-state, with the rule that you may be playful in success and never in failure. This app needs the same artifact with different values — a table mapping user state (calm / editing / shutdown / erroring) to permitted register, so the copy isn't tone-consistent-but-situationally-wrong.
- **Tapbots (Ivory) and Cultured Code (Things)** https://culturedcode.com/things/
  - Steal: Proof that adult indie tone sells: dry, precise, no exclamation marks, quietly confident, and warm anyway. Things in particular treats the user as competent without being cold — the exact needle this brief is threading. Study their empty states, which are the hardest case.
- **Museum wall labels and book colophons** 
  - Steal: The provenance treatment. A wall label is small, set quietly, positioned beside rather than on the work, and states maker + date + provenance without editorializing. It confers value precisely by being understated. This is the visual register for `STARTER PHRASE · [NAME]` — and the colophon is the model for the full provenance page.
- **Apple Icon Composer (Xcode 26) + HIG app icon guidance** https://www.createwithswift.com/crafting-liquid-glass-app-icons-with-icon-composer/
  - Steal: Not for the Android build — for the mental model. Open it, load a flat layered mark, and flip through Default/Dark/Clear-Light/Clear-Dark/Tinted-Light/Tinted-Dark. Watching your icon get flattened to a tint is the fastest way to internalize why silhouette-first is now mandatory and why baked gradients are dead. It's a free stress test for the kerf mark.
- **Massimo Vignelli / Unimark** 
  - Steal: The formal vocabulary for beauty without motion, gradient, or illustration: one field, one cut, one hue, ruthless reduction, and typography doing the emotional work. Print has been beautiful for 500 years without moving — Vignelli is the shortest path to how. Directly applicable to both the icon and the store screenshots.
- **Braille Institute — Atkinson Hyperlegible** https://www.brailleinstitute.org/freefont/
  - Steal: The typeface, and the story. Verify the status and weight range of Atkinson Hyperlegible Next / Mono (believed released 2025) before committing to display use in screenshots — the marketing headline plan depends on weights the original family may not have.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PRODUCT ===

An offline AAC (augmentative & alternative communication) app for autistic adults and teens with situational/part-time speech loss — people who can usually speak but go non-speaking during shutdowns, meltdowns, or sensory overload. Flutter, Android-first. Solo developer.

The app is ONE screen: a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface. Tap a tile, the phone speaks it aloud (or shows it in huge text — a co-equal "show mode" where you turn the screen to a stranger). Plus an edit mode and settings. No accounts. No network. Nothing leaves the device.

=== THE DESIGN BRIEF FROM THE FOUNDER (verbatim, and it is the point of this research) ===

"I don't want something like the design of ten years ago. I don't want something formal. I want something creative. I want something beautiful."

Take this seriously and literally. The default failure mode of an "accessible, calm, adult" app is that it becomes a grey rectangle grid that looks like a 2014 enterprise settings screen. That is the thing to avoid. The founder is asking for craft, personality, and beauty — and the research must find how to deliver that WITHOUT breaking the constraints below, not treat the constraints as an excuse to be boring.

=== WHAT PRIOR RESEARCH ESTABLISHED (do not re-litigate; design WITHIN these, or argue explicitly and with evidence where a constraint is softer than it looks) ===

- **The wedge is dignity.** Every mainstream AAC app is designed for children — cartoon avatars, mascots, puzzle pieces, primary-color rainbows, star/reward motifs, "Great job!" copy, parental gates. Adults abandon them. BANNED, permanently: cartoon avatars, mascots, animal characters, puzzle-piece iconography, gamification, streaks, badges, confetti, encouragement copy, any "parent/caregiver" framing.
- **CRITICAL NUANCE, and the opening for this whole research:** the study behind this found infantilization was about **VOCABULARY and being treated as a student — NOT about color**. The prior brief's own conclusion: *"DO NOT confuse 'adult' with 'monochrome and cold.' You can be warm and adult. The enemy is cartoon avatars and parental gates — not saturation."* So "adult" does NOT mandate grey. This is the permission slip. Use it.
- **Zero animation.** Two independent reasons: (a) distress/trauma-informed guidance warns against sudden motion for sensitized nervous systems; (b) animation costs latency in a product whose premise is instant speech. Honor `MediaQuery.disableAnimationsOf` → zero duration. **So beauty here CANNOT come from motion. It must come from composition, type, color, material, and craft. Print has been beautiful for 500 years without moving.**
- **Sensory sensitivity is the audience's defining trait.** Muted, low-saturation, ~2-5 intentional hues; high saturation only as sparing accents. But saturation and contrast are SEPARABLE — muted hues at high luminance contrast is the target.
- **Dark, light, AND high-contrast themes, all switchable in ONE TAP from the main screen.** Dark mode is contested in the research: [While & Sarvghad 2024](https://arxiv.org/pdf/2409.10841) found each polarity benefits comparable proportions and recommends shipping both; observers with cloudy ocular media read 10-15% better in dark. So dark is a choice, not the answer. **The dominant halation lever is TEXT luminance, not background hex** (#FFFFFF→#E0E0E0 drops contrast 21:1→15.91:1, a 24% cut; #000→#121212 only moves 21:1→18.73:1).
- **Material 3 is Flutter's default since 3.16.** M3's baseline dark surface is #141218 (neutral tone 6) with tone-based surface containers, NOT M2's #121212 + elevation overlays. Use `ColorScheme.fromSeed`.
- **Huge targets** (76dp floor, 12dp min gaps), 3x4 grid default with a 2x3 "large" option, **fixed tile positions** (no reflow ever — position IS the retrieval mechanism), highest-value tiles in the **lower-CENTER arc** (not upper-left; not the extreme bottom edge).
- **Typography**: system font or Atkinson Hyperlegible (Braille Institute, OFL). Tile labels min 17pt, default ~20pt, weight 500-600. MUST honor TextScaler to 200%+ without clamping. No dyslexia font as default (OpenDyslexic *decreased* fluency in the studies) but offer it as an option.
- **Show mode is the exception to the calm rule** — a cashier reads it at arm's length in daylight. Dark/low-luminance is right for the user's eyes and WRONG for a stranger reading the screen. Opposite optimizations.
- **Fitzgerald Key part-of-speech coloring is out** (each tile is a whole utterance, so grammar coloring is meaningless). But **category color-coding is fine and useful** for findability — the research explicitly did NOT find color-coding infantilizing.
- Symbols are v1+, text-only for MVP, and text-only stays first-class (for many literate adults the symbol set IS the infantilizing element). If symbols ship: Mulberry, runtime-tinted.
- The user may be in a shutdown: reduced decision-making, possible motor imprecision. One-handed. Phone, not tablet.
- Voice/identity matters: this audience skews trans/nonbinary; 4/12 wanted nonbinary/middle-pitch voices.

Today is 2026-07-15. Prefer 2025-2026 sources. Design moves fast — a 2019 article on "modern mobile design" is describing history.


YOUR DIMENSION: Identity — name, icon, tone of voice, and the App Store presence. The parts of "design" that aren't the UI.

- **The app icon.** It sits on a home screen among the user's other apps, and it may need to be findable INSTANTLY during a shutdown. It also announces what the app IS to anyone who glances at the phone — which matters, because 11/12 use AAC only where they feel safe and 4/12 avoid situations to dodge reactions to their device. **So there's a real tension: findable vs discreet.** Research: what makes an icon findable at 60x60? (Shape? Color? Contrast? Not detail.) What do beautiful 2026 app icons look like vs 2015 ones (gradients? glyphs? depth? iOS 26 introduced icon modes — clear/tinted/dark; VERIFY what Apple shipped and what it means for icon design; Android adaptive icons + themed icons)? Should this app's icon be legible-as-AAC or deliberately neutral? Argue both. Can it be beautiful AND discreet AND findable?
- **The name.** Not chosen yet. What are the naming conventions in this category (descriptive: "Speech Assistant AAC", "Proloquo2Go" — Latin, meaning "speak out loud"; "TouchChat"; "Spoken"; "Emergency Chat")? For a product whose thesis is dignity, what naming register works? Should "AAC" be in the name (findability/ASO) or not (dignity/discretion)? Note the ASO tension: users search "AAC", "text to speech", "nonverbal", "selective mutism". Give real, specific name candidates with reasoning — not just criteria. Check obvious collisions.
- **Tone of voice.** Every string in the app. The research says: second-person adult copy, no exclamation marks, no encouragement, no "Great job!", no student/learner framing. But that's a list of DON'Ts — what's the positive register? Warm? Dry? Neutral? Matter-of-fact? Find examples of products with a tone worth stealing. Write actual example strings for: first launch, empty tile, edit mode, the voice picker, an error ("no voice available"), the export screen, the privacy explanation. **The error strings matter most** — this app's errors happen at the worst moment of someone's day. What does a good error message sound like here?
- **The starter phrase set as a design artifact**: the research says starter phrases need VISIBLE PROVENANCE — who wrote them and why — because pre-filling someone's voice is presumptuous, and provenance converts presumption into a gift. How do you DESIGN that? What does it look like on screen? What does the copy say? This is a design problem, not just a content problem.
- **App Store presence**: screenshots, the listing. What do beautiful 2026 app store screenshots look like? What does this app's first screenshot need to communicate in 2 seconds to an autistic adult who has been burned by kiddie AAC apps? (This may be the single highest-leverage design surface in the whole project — it's what decides whether they install at all.)
- **The privacy story as a design surface**: "no network permission" is verifiable pre-install on the Play listing. How do you SHOW that? Nutrition labels, the listing, an in-app page. Can it be beautiful and credible rather than legalese?

Give real, specific, opinionated output: actual name candidates, actual strings, actual icon directions.
````

</details>
