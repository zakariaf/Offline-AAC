# failure-modes--for-autistic-sensory-shutdown-specifically-t

> Phase: **verify** · Agent `a9d7a4a96b157389b` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The product recommendation (ship a silent/text-display mode) survives, but the stated justification does not. Corrected claim:

"Silent output modes (text display, haptic-only confirmation) are a well-supported requirement, justified by observed user behavior rather than sensory-harm mechanism. Evidence: (a) 8 of 12 autistic adults in Martin & Nagalakshmi (2024) already use their AAC app's text display instead of, or alongside, TTS; (b) 11 of 12 report AAC use is contingent on environmental and SOCIAL safety — comfort with the setting and the conversation partner, i.e. fear of being perceived; (c) for selective mutism, CALL Scotland (2019, a practitioner blog, not a study) reports anecdotal cases where speech-output AAC went unused in anxiety-triggering settings because anxiety is associated with the act of speaking, and recommends text-based solutions.

The specific mechanism 'TTS injects audio into an already-overloaded auditory channel and can worsen autistic shutdown' is an inference no source states, and the available literature leans the other way: AssistiveWare and shutdown guidance describe AAC as reducing the cognitive load of speaking and helping avert escalation, with symbol-based AAC reported as usable during shutdown. The only audio complaint in the cited paper is that device voices are too QUIET to carry over background noise. No participant described speech output as 'infantilizing' — that word was applied to childish app aesthetics and vocabulary; the separate word-by-word speech-output complaint was about distraction during composition ('It messes me up a lot and distracts me').

Design implication changes accordingly: evidence supports audio being user-toggleable with text display as a co-equal first-class output (and possibly a per-context memory of the last mode), NOT audio being suppressed or de-emphasized by default on sensory-harm grounds."

**Evidence:** Both cited sources are real and were fetched directly, but the claim's load-bearing mechanism and two of its three supporting citations do not hold.

CONFIRMED PARTS:
- arXiv 2404.17730v1 is real: "Bridging the Social & Technical Divide in AAC Applications for Autistic Adults," Martin & Nagalakshmi, 24 Apr 2024, n=12 autistic adults.
- The 11/12 statistic is accurate as a number: "Nearly all of our participants (11) spoke about how using AAC depended on whether the environment is safe, what the comfort level is with the person they are speaking to, and social safety."
- CALL Scotland post exists and frames SM as anxiety-driven: "Selective mutism is primarily related to feelings of extreme stress and anxiety, so these are the issues that need to be addressed."
- Text-based recommendation for SM is present: "as she is obviously comfortable with text, a text-based solution would probably be the best route for her."
- Practitioner anecdote about non-use in anxiety-triggering environments is present: "he would not utilize the device in the gen ed room or the community, supposedly based on his anxiety" and "In uncomfortable environments the opposite was true. So, in these two cases AAC did not help augment their communication..."

BREAKS:

1. MISREAD — the "infantilizing" attribution conflates two separate quotes. "Infantilizing" in the paper refers to kid-aesthetic apps/vocabulary: "Many AAC apps feel like they're made for kids or students, and it feels infantilizing." The word-by-word speech-output complaint is a DIFFERENT quote with a DIFFERENT complaint: "I also hate apps that speak every word as you hit the button or speaks each sentence as you type it. It messes me up a lot and distracts me." That is cognitive interference during composition — not infantilization, not sensory overload. No participant called speech output "infantilizing."

2. MISAPPROPRIATED — the 11/12 stat is explicitly about SOCIAL safety (environment safe, comfort level with the person, social safety), i.e. fear of judgment/being perceived. It does not converge on an auditory-sensory-channel mechanism.

3. MECHANISM UNSUPPORTED, AND LITERATURE LEANS OPPOSITE — the paper nowhere claims TTS audio worsens sensory overload or shutdown. Its only audio-related complaints run the other way: "Voices from the device can get masked by background noise because they simply can't become loud enough (4)." Independent sources (AssistiveWare part-time AAC; autistic shutdown literature) describe AAC as REDUCING the cognitive load of speaking and helping express need before escalation to shutdown/meltdown, with some users reporting symbol-based AAC as easiest to use DURING a shutdown. Autistic auditory overload is characteristically about uncontrolled, unpredictable ambient noise — not a single self-initiated, expected, volume-controlled utterance. "Startle of one's own device speaking" is unsupported.

4. DATE + FABRICATED WORDING — the CALL Scotland post is dated 24 May 2019, outside the preferred 2024-2026 window. The attributed quote ("might increase stress rather than help if the person associates speaking (even through a device) with their anxiety triggers") does NOT appear. Actual text: "if she is uncomfortable with it and use might lead to an increase in stress, then I wouldn't go down this route." Its mechanism is anxiety ASSOCIATION WITH SPEAKING, not sensory/auditory load — a different mechanism, so it does not converge on the claim either. It is a blog post with informal practitioner comments (n=1-2 anecdotes), not a clinical study; "clinical requirement" overstates it.

5. MISSED STRONGER EVIDENCE IN THEIR OWN SOURCE — the paper states: "Many participants (8) use the text display feature of their AAC app instead of, or in conjunction with, the TTS." This is direct observed evidence of silent-mode demand (8/12) and supports the product decision without requiring the sensory-harm inference at all.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "failure-modes". A product decision depends on it, so it must be right.

CLAIM: For autistic sensory shutdown specifically, TTS output is an auditory stimulus injected into the exact sensory channel that is already overloaded — the core action can worsen the state it treats
THEIR DETAIL: This is a reasoned inference the founder has not made and no reviewed source states outright, but it follows directly from the mechanism: shutdown is frequently triggered or sustained by sensory overload including auditory load, and the product's core interaction is 'the phone speaks it aloud' in a shop or ER — adding noise, plus the social attention that follows the noise, plus the startle of one's own device speaking. Converging evidence: 11/12 only use AAC where they feel safe; one participant called automatic word-by-word speech output 'infantilizing'. For selective mutism the same logic is documented rather than inferred — CALL Scotland notes SM is anxiety-driven, that a speech-producing device 'might increase stress rather than help if the person associates speaking (even through a device) with their anxiety triggers', and that one practitioner found AAC with speech output didn't help because individuals wouldn't use devices in anxiety-triggering environments. Their recommendation for SM is text-based solutions. Silent modes (screen display, haptics-only confirmation) are therefore a clinical requirement, not a preference.
THEIR CLAIMED SOURCES: https://www.callscotland.org.uk/blog/selective-mutism-and-technology/, https://arxiv.org/html/2404.17730v1
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
