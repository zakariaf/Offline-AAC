# flutter-vs-rn--flutter-s-custom-text-field-has-a-long-tail

> Phase: **verify** · Agent `a64f0f18a47d8d839` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Flutter's text field does have a real, current long tail of IME/dictation/autocorrect bugs relevant to a type-to-speak box — in fact larger than stated (1,044 open "a: text input" issues; live examples include #182876, filed Feb 2026). But the specifics need three corrections. (1) Two of the six cited issues are CLOSED, not open: #134881 was fixed on 2023-09-22 by engine PR #46144 and locked — iOS spell-check/auto-suggest CAN be disabled since Flutter 3.14, so that bullet is stale and backwards; #22828 was closed in 2019. The four live citations are #171955 (open, P2, filed 2025-07-10), #133034 (open, P2, Gboard+SwiftKey detail verbatim correct), #84419 (open, P2), #139143 (open, P2). Better current additions: #156691 and #182876. (2) #139143 and #22828 are Android TYPE_TEXT_FLAG_NO_SUGGESTIONS / Gboard platform-flag issues — #139143 was retitled by triage to "[Documentation]" — and would reproduce on a native EditText, so they don't evidence "Flutter reimplements the text field." Only #171955, #133034 and #84419 actually implicate Flutter's platform-channel IME bridge. (3) RN's TextInput is genuinely native-backed but is not a clean escape: see RN #33139 (Samsung Keyboard predictive text crashes TextInput), #30453/#18457 (autoCorrect={false} broken on Android), #30503. Treat this as a "test dictation and Gboard/SwiftKey/Samsung early on whichever stack you pick" risk, not a Flutter-vs-RN differentiator. The TextInputFormatter mitigation is worth taking (it is the thread in #171955 and #133034, the two wrong-text bugs) but does not cover #84419, so it is not a complete guard. Net: this should not move a Flutter-vs-RN decision on its own; confidence should drop from high to moderate.

**Evidence:** Verified all six cited issues directly via the GitHub API (gh api repos/flutter/flutter/issues/N), not search snippets.

HEADLINE CLAIM CONFIRMED, AND UNDERSTATED. Flutter has 1,044 open issues labeled "a: text input". The IME/dictation/autocorrect long tail is real, ongoing, and extends beyond the cited set: #156691 (TextInputFormatter + iOS 18 multilingual keyboard, Oct 2024) and #182876 (filed 2026-02-25, OPEN, P2, "[Windows] External voice dictation tools cannot detect Flutter TextFields"). So the risk flag for the type-to-speak box is justified.

4 OF 6 CITATIONS ACCURATE:
- #171955: OPEN, P2. Title verbatim match. created_at 2025-07-10 — date correct. Labels: a: text input, e: samsung, platform-android, triaged-text-input, found in release 3.32/3.33.
- #133034: OPEN since 2023-08-22, P2. Body states verbatim "I've tested with GBoard and SwiftKey and found the same issue" — the Gboard/SwiftKey detail is exactly right. No activity since 2023-09-12.
- #84419: OPEN since 2021-06-11, P2. iOS dictation + clear(). Correct.
- #139143: OPEN since 2023-11-28, P2. Body confirms Gboard disabling Chinese/Korean/Cantonese.

2 OF 6 ARE WRONG — presented as "concrete open issues" but CLOSED:
- #134881: CLOSED 2023-09-22, state_reason "completed", labeled "r: fixed", locked 2023-10-06. Timeline shows it was closed by auto-submit[bot] after engine PR flutter/engine#46144 (cross-referenced 2023-09-21) and labeled r: fixed by bleroux. The exact mechanism the researcher describes ("iOS spellCheckingType is always forced to .default, so the auto-suggest bar can't be disabled") is precisely what that PR FIXED, ~3 years ago in Flutter 3.14. Stale and reversed.
- #22828: CLOSED 2019-10-28 (first closed 2019-04-01 by Piinks), filed 2018-10-08. Eight years old, no P-label, not a live signal.

TWO FRAMING ERRORS THE CITATIONS DON'T SUPPORT:
1. #139143 and #22828 are NOT evidence of Flutter's custom text field. Both concern Android's TYPE_TEXT_FLAG_NO_SUGGESTIONS and Gboard's interpretation of it. #139143 was retitled by triage to "[Documentation] enableSuggestions: false breaks non-English keyboards..." — it asks Flutter to document platform behavior; its body explicitly frames it as ambiguity in the Android docs. In #22828, Flutter team member justinmc states: "Gboard ignores the TYPE_TEXT_FLAG_NO_SUGGESTIONS flag in some situations... which is what is controlled by the enableSuggestions parameter in Flutter." A native Android EditText setting that flag hits identical behavior. These do not support the "Flutter reimplements the text field" causal thesis.
2. The implied "RN is safer" contrast is undercut. RN's TextInput is genuinely backed by UITextField/EditText (architecturally true), but has its own peer bugs: facebook/react-native #33139 (TextInput CRASHES with Samsung Keyboard predictive text), #30453 and #18457 (autoCorrect={false} not working on Android), #30503 (duplicate words on Android), #20063 (autoCorrect default differs Android vs iOS). Native backing does not immunize against this bug class.

MITIGATION OVERSOLD: "do NOT use TextInputFormatter — it's the common thread in the worst bugs" holds for only 2 of 6 (#171955, #133034). #84419 is a clear()/dictation race with no formatter involved, so the mitigation does not cover it. Advice is directionally sound (formatters are implicated in the wrong-text bugs) but is not a complete guard.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "flutter-vs-rn". A product decision depends on it, so it must be right.

CLAIM: Flutter's custom text field has a long tail of real IME/dictation/autocorrect bugs — directly relevant to the 'type to speak' box
THEIR DETAIL: Concrete open issues: #171955 (TextInputFormatter + Samsung Keyboard autocorrect race condition producing wrong text, filed 2025-07-10); #133034 (TextInputFormatter breaks dictation on Android, reproduced on Gboard and SwiftKey); #84419 (iOS dictation: onChanged fires after clear()); #134881 (iOS spellCheckingType is always forced to .default — FlutterTextInputView ignores the field's spell-check config, so the auto-suggest bar can't be disabled); #139143 (enableSuggestions:false makes Gboard disable Chinese/Korean/Cantonese entirely); #22828 (autocorrect:false still shows keyboard suggestions). Flutter reimplements the text field and talks to the IME through a platform channel; RN uses the real UITextField/EditText. The mitigation is cheap: do NOT use TextInputFormatter on the type-to-speak field (it's the common thread in the worst bugs) and test dictation + Gboard/SwiftKey/Samsung early.
THEIR CLAIMED SOURCES: https://github.com/flutter/flutter/issues/171955, https://github.com/flutter/flutter/issues/133034, https://github.com/flutter/flutter/issues/84419, https://github.com/flutter/flutter/issues/134881, https://github.com/flutter/flutter/issues/139143, https://github.com/flutter/flutter/issues/22828
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
