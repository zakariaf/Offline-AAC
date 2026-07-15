# design-distress--serious-aac-apps-prevent-misfires-with-dwell

> Phase: **verify** · Agent `a84b13c3a8a699603` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Corrected claim: Major AAC apps (Proloquo2Go, TouchChat, TD Snap) guard against misfires with NON-MODAL timing gates rather than confirmation dialogs — Proloquo2Go's Hold Duration (minimum press, up to 5.0s, documented for hand tremors), Repeat Delay, Allow Repeat OFF, and Select on Release; TouchChat's dwell time and release time; TD Snap's Touch Enter / Touch Exit. Critically, these are error PREVENTION mechanisms, not error tolerance — the correct contrast is non-modal prevention (zero extra decisions) vs. modal prevention (dialogs), with recovery as a separate second layer. Separately, Proloquo2Go offers "Stop Speaking" and "Clear Message" as assignable button ACTIONS; there is no documented evidence that a Stop Speaking button is persistent or present by default, and the built-in stop is the configurable message-window Repeated Tap behavior whose default is undocumented. Also note these timing gates are opt-in alternative-access accommodations aimed at tremor, not defaults, and not aimed at the shutdown population. Product implication for this brief: adopt non-modal prevention over dialogs (the directional call is right), but ship timing gates OFF or near-zero by default and expose them in settings — a 5s hold contradicts the "speak instantly" requirement — and treat an always-visible Stop control as your own design decision to validate in testing, not as an established AAC convention.

**Evidence:** All three cited AssistiveWare URLs resolve and the mechanism details are quoted with unusual accuracy — this is not an invented claim. Confirmed verbatim:

1. HOLD DURATION — CONFIRMED EXACTLY. Access Method Options documents "Hold Duration": a minimum hold before a button activates, max 5.0 seconds, with the literal sentence "This can be helpful for users with hand tremors who may accidentally brush buttons." The researcher's paraphrase is faithful. Same page also documents "Select on Release" (First Finger Up default / First Finger Down) and "Prevent Accidental Repeats", which the researcher omitted but which support the pattern.

2. REPEAT DELAY / ALLOW REPEAT — CONFIRMED. Repeated-taps page: Repeat Delay "ignores taps that happen within a set time after the last tap" (message window) and for grid buttons is "the time you have to wait from when you first select a button until you can select it again." Allow Repeat OFF: "after selecting one button, you must select another button before you can select the first button again." Exactly as claimed. Note: no numeric range is documented for Repeat Delay (the 5.0s max belongs to Hold Duration only — the researcher got this attribution right).

3. STOP SPEAKING / CLEAR MESSAGE EXIST — CONFIRMED as button ACTIONS. "Stop Speaking — stops any message currently being spoken"; "Clear Message — erases everything in the message window."

4. GENERALIZATION TO "SERIOUS AAC APPS" — HOLDS for the timing half, n=3. TouchChat documents dwell time (button press accepted only after the timer counts down while the finger stays inside the button) plus a "release time" explicitly "intended to help prevent accidental double button activations." TD Snap ships six access methods including Touch Enter (touch and hold for a set period) and Touch Exit (selection on release). No mainstream AAC app surfaced that gates utterances behind confirmation dialogs.

WHAT FAILS:

A. "PERSISTENT Stop Speaking control" — UNSUPPORTED. The word "persistent" is the researcher's invention, not the docs'. AssistiveWare documents Stop Speaking as an action you can ASSIGN to a button in Edit Mode; the page is silent on whether any default vocabulary (Crescendo) ships such a button, or whether it is always visible. I could not substantiate it from any primary source. The actual built-in stop affordance is different: tapping the message window during speech triggers the configurable Repeated Tap behavior (Restart Speech / Stop Speech / Pause-Continue / Ignore) — and the docs do not state which is default, with "Restart Speech" listed first. So the documented default may not stop speech at all. The claim asserts as fact something the sources do not say.

B. THE PREVENTION/TOLERANCE FRAMING IS INVERTED — this is the sharpest error, and the researcher's own evidence contradicts it. Hold Duration and Repeat Delay are error PREVENTION, not error tolerance: they stop the misfire from ever firing. Stop Speaking / Clear Message are the tolerance/recovery half. The claim says these apps choose "error TOLERANCE rather than error PREVENTION" while citing two prevention mechanisms as the proof. The real dichotomy Proloquo2Go demonstrates is NON-MODAL prevention (invisible timing gates that cost the user zero decisions) versus MODAL prevention (dialogs), plus recovery as a backstop. That is a different design lesson and it changes what to build.

C. POPULATION MISMATCH — a product-decision trap. Hold Duration and Repeat Delay live under ALTERNATIVE ACCESS and are documented for hand tremors / involuntary repeated tapping — motor impairment. They are opt-in accommodations, presumably defaulting to 0. The brief's population is autistic adults mid-shutdown, whose failure mode is cognitive/decisional, not tremor. Shipping a 5.0s hold as a DEFAULT would directly sabotage the brief's own requirement to "speak instantly" — a 5s gate on every tile is a severe cost for a user in distress. The sources do not support porting these as defaults.

D. The "doubles the decision count when decision capacity is lowest" rationale is plausible UX reasoning (NN/g supports that confirmations add cognitive load and that users reflexively dismiss them, sometimes increasing errors) but it is unsourced argument, not an AAC or distress-specific finding. No evidence tested confirmation dialogs on AAC users mid-shutdown.

Stated confidence of "high" is too high given (A) is asserted-as-documented but absent from the docs, and (B) misdescribes the mechanism it cites.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "design-distress". A product decision depends on it, so it must be right.

CLAIM: Serious AAC apps prevent misfires with dwell time and repeat-delay, not confirmation dialogs, and pair this with a persistent Stop Speaking control
THEIR DETAIL: Proloquo2Go's Access Method Options expose 'Hold Duration' — a minimum press time before a button activates, settable up to 5.0 seconds, explicitly documented as helpful for users with hand tremors who brush buttons accidentally. 'Repeat Delay' ignores taps within a set window after the last tap; with 'Allow Repeat' OFF, the same button cannot re-fire until another is selected. Separately, button actions include 'Stop Speaking' (halts the current utterance) and 'Clear Message'. This resolves the big-target-vs-misfire tension in the brief: error TOLERANCE (instant recovery) rather than error PREVENTION (confirmation), because a confirmation dialog doubles the decision count in exactly the moment decision capacity is lowest.
THEIR CLAIMED SOURCES: https://www.assistiveware.com/support/proloquo2go/alternative-access/access-method, https://www.assistiveware.com/support/proloquo2go/alternative-access/repeated-taps, https://www.assistiveware.com/support/proloquo2go/organize/buttons/buttons-actions
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
