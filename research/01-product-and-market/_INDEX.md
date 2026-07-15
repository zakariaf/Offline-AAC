# Product & market research — offline adult AAC

`wf_3a8e3c64-43a` · **100 agents** · every agent's result + the prompt that produced it.

The methodology is in [`_workflow_script.js`](_workflow_script.js) — the fan-out, the schemas,
and the adversarial verification pass. Re-run or adapt it rather than rewriting it.

## research (11)

One agent per dimension, each doing independent web research.

- [aac-clinical](research/aac-clinical.md) — 39,487 chars
- [business-model](research/business-model.md) — 28,450 chars
- [competitive](research/competitive.md) — 23,577 chars
- [data-architecture](research/data-architecture.md) — 23,412 chars
- [design-distress](research/design-distress.md) — 30,647 chars
- [failure-modes](research/failure-modes.md) — 36,667 chars
- [flutter-tts](research/flutter-tts.md) — 26,109 chars
- [flutter-vs-rn](research/flutter-vs-rn.md) — 22,113 chars
- [legal-regulatory](research/legal-regulatory.md) — 31,934 chars
- [platform-integration](research/platform-integration.md) — 23,479 chars
- [user-needs](research/user-needs.md) — 30,083 chars

## verify (85)

Adversarial fact-checkers, one per load-bearing claim, each told to *refute* it.

- [aac-clinical--arasaac-12-909-symbols-is-cc-by-nc-sa-and-le](verify/aac-clinical--arasaac-12-909-symbols-is-cc-by-nc-sa-and-le.md) — 5,347 chars
- [aac-clinical--but-core-vocabulary-is-a-tool-for-building-g](verify/aac-clinical--but-core-vocabulary-is-a-tool-for-building-g.md) — 7,225 chars
- [aac-clinical--core-vocabulary-is-empirically-real-for-adul](verify/aac-clinical--core-vocabulary-is-empirically-real-for-adul.md) — 5,200 chars
- [aac-clinical--dynamic-reordering-most-used-floats-to-top-i](verify/aac-clinical--dynamic-reordering-most-used-floats-to-top-i.md) — 5,676 chars
- [aac-clinical--exact-license-status-of-the-remaining-symbol](verify/aac-clinical--exact-license-status-of-the-remaining-symbol.md) — 5,511 chars
- [aac-clinical--mulberry-symbols-is-the-only-major-symbol-se](verify/aac-clinical--mulberry-symbols-is-the-only-major-symbol-se.md) — 5,215 chars
- [aac-clinical--the-clinical-liability-of-phrase-only-aac-is](verify/aac-clinical--the-clinical-liability-of-phrase-only-aac-is.md) — 7,141 chars
- [aac-clinical--the-correct-design-rule-is-hide-don-t-move-e](verify/aac-clinical--the-correct-design-rule-is-hide-don-t-move-e.md) — 5,999 chars
- [business-model--a-direct-competitor-already-occupies-the-aac](verify/business-model--a-direct-competitor-already-occupies-the-aac.md) — 4,997 chars
- [business-model--a-subscription-model-actively-disqualifies-t](verify/business-model--a-subscription-model-actively-disqualifies-t.md) — 4,704 chars
- [business-model--assistiveware-s-move-to-subscription-with-pr](verify/business-model--assistiveware-s-move-to-subscription-with-pr.md) — 6,219 chars
- [business-model--competitor-price-anchoring-spans-24-99-to-29](verify/business-model--competitor-price-anchoring-spans-24-99-to-29.md) — 4,049 chars
- [business-model--open-sourcing-is-a-disproportionately-strong](verify/business-model--open-sourcing-is-a-disproportionately-strong.md) — 5,082 chars
- [business-model--the-insurance-medicaid-sgd-funding-path-is-c](verify/business-model--the-insurance-medicaid-sgd-funding-path-is-c.md) — 5,499 chars
- [competitive--android-has-no-live-speech-equivalent-this-i](verify/competitive--android-has-no-live-speech-equivalent-this-i.md) — 5,937 chars
- [competitive--insurance-medicaid-funding-structurally-excl](verify/competitive--insurance-medicaid-funding-structurally-excl.md) — 7,135 chars
- [competitive--ios-live-speech-ios-17-already-solves-the-ty](verify/competitive--ios-live-speech-ios-17-already-solves-the-ty.md) — 5,536 chars
- [competitive--peer-reviewed-2024-2025-research-confirms-th](verify/competitive--peer-reviewed-2024-2025-research-confirms-th.md) — 4,735 chars
- [competitive--research-independently-validates-the-shutdow](verify/competitive--research-independently-validates-the-shutdow.md) — 4,918 chars
- [competitive--speech-assistant-aac-already-ships-the-exact](verify/competitive--speech-assistant-aac-already-ships-the-exact.md) — 5,502 chars
- [competitive--spoken-aac-is-a-live-well-funded-competitor](verify/competitive--spoken-aac-is-a-live-well-funded-competitor.md) — 5,508 chars
- [competitive--the-pricing-premise-is-materially-wrong-prol](verify/competitive--the-pricing-premise-is-materially-wrong-prol.md) — 3,781 chars
- [data-architecture--android-auto-backup-is-on-by-default-capped](verify/data-architecture--android-auto-backup-is-on-by-default-capped.md) — 4,780 chars
- [data-architecture--android-offers-a-precise-privacy-lever-back](verify/data-architecture--android-offers-a-precise-privacy-lever-back.md) — 5,619 chars
- [data-architecture--drift-is-the-only-relational-flutter-db-that](verify/data-architecture--drift-is-the-only-relational-flutter-db-that.md) — 3,926 chars
- [data-architecture--isar-is-effectively-unmaintained-and-has-fra](verify/data-architecture--isar-is-effectively-unmaintained-and-has-fra.md) — 3,873 chars
- [data-architecture--obf-adoption-is-real-but-partial-and-specifi](verify/data-architecture--obf-adoption-is-real-but-partial-and-specifi.md) — 4,249 chars
- [data-architecture--on-ios-app-data-is-in-icloud-backup-by-defau](verify/data-architecture--on-ios-app-data-is-in-icloud-backup-by-defau.md) — 3,397 chars
- [data-architecture--open-board-format-obf-obz-is-a-real-mit-lice](verify/data-architecture--open-board-format-obf-obz-is-a-real-mit-lice.md) — 4,264 chars
- [data-architecture--realm-atlas-device-sdk-is-dead-eol-september](verify/data-architecture--realm-atlas-device-sdk-is-dead-eol-september.md) — 4,246 chars
- [design-distress--dark-mode-is-preferred-by-distressed-users-b](verify/design-distress--dark-mode-is-preferred-by-distressed-users-b.md) — 6,542 chars
- [design-distress--dark-theme-backgrounds-must-be-dark-gray-121](verify/design-distress--dark-theme-backgrounds-must-be-dark-gray-121.md) — 7,898 chars
- [design-distress--dyslexia-specific-fonts-have-no-evidentiary](verify/design-distress--dyslexia-specific-fonts-have-no-evidentiary.md) — 7,356 chars
- [design-distress--roughly-half-of-phone-use-is-one-handed-and](verify/design-distress--roughly-half-of-phone-use-is-one-handed-and.md) — 5,680 chars
- [design-distress--serious-aac-apps-prevent-misfires-with-dwell](verify/design-distress--serious-aac-apps-prevent-misfires-with-dwell.md) — 5,995 chars
- [design-distress--the-fitzgerald-key-is-a-grammar-construction](verify/design-distress--the-fitzgerald-key-is-a-grammar-construction.md) — 6,037 chars
- [design-distress--the-thumb-arc-is-mirrored-by-handedness-so-a](verify/design-distress--the-thumb-arc-is-mirrored-by-handedness-so-a.md) — 5,005 chars
- [failure-modes--flutter-is-the-wrong-stack-for-this-specific](verify/failure-modes--flutter-is-the-wrong-stack-for-this-specific.md) — 7,056 chars
- [failure-modes--for-autistic-sensory-shutdown-specifically-t](verify/failure-modes--for-autistic-sensory-shutdown-specifically-t.md) — 5,902 chars
- [failure-modes--monetization-is-close-to-hopeless-and-should](verify/failure-modes--monetization-is-close-to-hopeless-and-should.md) — 6,583 chars
- [failure-modes--the-biggest-unexploited-insight-this-populat](verify/failure-modes--the-biggest-unexploited-insight-this-populat.md) — 6,184 chars
- [failure-modes--the-core-assumption-is-partially-inverted-th](verify/failure-modes--the-core-assumption-is-partially-inverted-th.md) — 5,737 chars
- [failure-modes--the-never-opened-until-crisis-problem-is-clo](verify/failure-modes--the-never-opened-until-crisis-problem-is-clo.md) — 8,530 chars
- [failure-modes--the-stated-competitive-premise-is-factually](verify/failure-modes--the-stated-competitive-premise-is-factually.md) — 6,256 chars
- [failure-modes--yes-shipping-only-os-voices-is-a-dignity-fai](verify/failure-modes--yes-shipping-only-os-voices-is-a-dignity-fai.md) — 6,544 chars
- [flutter-tts--flutter-tts-has-zero-personal-voice-support](verify/flutter-tts--flutter-tts-has-zero-personal-voice-support.md) — 3,896 chars
- [flutter-tts--flutter-tts-is-at-4-2-5-and-is-a-viable-mvp](verify/flutter-tts--flutter-tts-is-at-4-2-5-and-is-a-viable-mvp.md) — 5,761 chars
- [flutter-tts--instant-is-not-achievable-with-live-tts-on-i](verify/flutter-tts--instant-is-not-achievable-with-live-tts-on-i.md) — 6,543 chars
- [flutter-tts--ios-avspeechsynthesizer-is-on-device-by-defa](verify/flutter-tts--ios-avspeechsynthesizer-is-on-device-by-defa.md) — 6,423 chars
- [flutter-tts--ios-default-voices-are-compact-robotic-enhan](verify/flutter-tts--ios-default-voices-are-compact-robotic-enhan.md) — 5,324 chars
- [flutter-tts--on-android-you-can-reliably-force-offline-on](verify/flutter-tts--on-android-you-can-reliably-force-offline-on.md) — 5,747 chars
- [flutter-tts--personal-voice-cannot-be-pre-rendered-to-a-f](verify/flutter-tts--personal-voice-cannot-be-pre-rendered-to-a-f.md) — 5,117 chars
- [flutter-tts--personal-voice-is-usable-by-third-party-aac](verify/flutter-tts--personal-voice-is-usable-by-third-party-aac.md) — 7,052 chars
- [flutter-vs-rn--flutter-beats-react-native-on-cold-start-tim](verify/flutter-vs-rn--flutter-beats-react-native-on-cold-start-tim.md) — 5,552 chars
- [flutter-vs-rn--flutter-cannot-write-home-screen-widgets-in](verify/flutter-vs-rn--flutter-cannot-write-home-screen-widgets-in.md) — 5,346 chars
- [flutter-vs-rn--flutter-has-a-documented-unfixed-bug-where-e](verify/flutter-vs-rn--flutter-has-a-documented-unfixed-bug-where-e.md) — 6,071 chars
- [flutter-vs-rn--flutter-has-no-official-statement-of-ios-swi](verify/flutter-vs-rn--flutter-has-no-official-statement-of-ios-swi.md) — 4,223 chars
- [flutter-vs-rn--flutter-honors-system-text-scaling-by-defaul](verify/flutter-vs-rn--flutter-honors-system-text-scaling-by-defaul.md) — 4,518 chars
- [flutter-vs-rn--flutter-s-custom-text-field-has-a-long-tail](verify/flutter-vs-rn--flutter-s-custom-text-field-has-a-long-tail.md) — 5,163 chars
- [flutter-vs-rn--flutter-s-screen-reader-defaults-are-better](verify/flutter-vs-rn--flutter-s-screen-reader-defaults-are-better.md) — 4,400 chars
- [flutter-vs-rn--the-flutter-paints-to-a-canvas-so-it-s-inacc](verify/flutter-vs-rn--the-flutter-paints-to-a-canvas-so-it-s-inacc.md) — 4,625 chars
- [legal-regulatory--apple-s-macos-sla-bans-recording-redistribut](verify/legal-regulatory--apple-s-macos-sla-bans-recording-redistribut.md) — 4,291 chars
- [legal-regulatory--arasaac-s-nc-clause-is-confirmed-and-does-bl](verify/legal-regulatory--arasaac-s-nc-clause-is-confirmed-and-does-bl.md) — 4,824 chars
- [legal-regulatory--cc-by-sa-on-symbols-does-not-infect-your-flu](verify/legal-regulatory--cc-by-sa-on-symbols-does-not-infect-your-flu.md) — 6,706 chars
- [legal-regulatory--google-play-now-forces-the-medical-device-qu](verify/legal-regulatory--google-play-now-forces-the-medical-device-qu.md) — 4,193 chars
- [legal-regulatory--the-eu-s-official-software-guidance-explicit](verify/legal-regulatory--the-eu-s-official-software-guidance-explicit.md) — 3,579 chars
- [legal-regulatory--the-fda-exemption-is-conditional-on-21-cfr-8](verify/legal-regulatory--the-fda-exemption-is-conditional-on-21-cfr-8.md) — 5,268 chars
- [legal-regulatory--the-mdr-hook-is-compensation-for-a-disabilit](verify/legal-regulatory--the-mdr-hook-is-compensation-for-a-disabilit.md) — 4,987 chars
- [legal-regulatory--us-fda-aac-is-a-class-ii-device-but-is-codif](verify/legal-regulatory--us-fda-aac-is-a-class-ii-device-but-is-codif.md) — 6,263 chars
- [platform-integration--app-store-review-risk-audioplaybackintent-is](verify/platform-integration--app-store-review-risk-audioplaybackintent-is.md) — 5,681 chars
- [platform-integration--ios-18-controls-controlwidget-run-appintents](verify/platform-integration--ios-18-controls-controlwidget-run-appintents.md) — 4,188 chars
- [platform-integration--ios-back-tap-can-run-a-shortcut-double-or-tr](verify/platform-integration--ios-back-tap-can-run-a-shortcut-double-or-tr.md) — 4,908 chars
- [platform-integration--ios-live-speech-is-a-serious-free-built-in-c](verify/platform-integration--ios-live-speech-is-a-serious-free-built-in-c.md) — 5,235 chars
- [platform-integration--ios-lock-screen-widgets-accessorycircular-re](verify/platform-integration--ios-lock-screen-widgets-accessorycircular-re.md) — 4,733 chars
- [platform-integration--ios-widget-extensions-cannot-play-audio-dire](verify/platform-integration--ios-widget-extensions-cannot-play-audio-dire.md) — 5,791 chars
- [platform-integration--the-killer-mechanism-conforming-an-appintent](verify/platform-integration--the-killer-mechanism-conforming-an-appintent.md) — 5,953 chars
- [platform-integration--unverified-whether-a-third-party-lock-screen](verify/platform-integration--unverified-whether-a-third-party-lock-screen.md) — 1,631 chars
- [user-needs--autistic-shutdown-is-a-spectrum-and-in-its-d](verify/user-needs--autistic-shutdown-is-a-spectrum-and-in-its-d.md) — 6,863 chars
- [user-needs--speed-is-the-1-cited-functional-issue-and-sp](verify/user-needs--speed-is-the-1-cited-functional-issue-and-sp.md) — 6,309 chars
- [user-needs--the-bystander-problem-is-real-but-is-primari](verify/user-needs--the-bystander-problem-is-real-but-is-primari.md) — 6,042 chars
- [user-needs--the-infantilization-thesis-is-confirmed-in-u](verify/user-needs--the-infantilization-thesis-is-confirmed-in-u.md) — 4,808 chars
- [user-needs--the-phone-gets-physically-handed-to-other-pe](verify/user-needs--the-phone-gets-physically-handed-to-other-pe.md) — 4,209 chars
- [user-needs--there-is-an-established-low-tech-incumbent-f](verify/user-needs--there-is-an-established-low-tech-incumbent-f.md) — 4,626 chars
- [user-needs--tts-voice-quality-is-an-abandonment-trigger](verify/user-needs--tts-voice-quality-is-an-abandonment-trigger.md) — 5,229 chars
- [user-needs--users-actively-reject-adaptive-learning-pred](verify/user-needs--users-actively-reject-adaptive-learning-pred.md) — 5,115 chars

## critique (3)

Cross-cutting critics reading the whole corpus.

- [completeness-critic](critique/completeness-critic.md) — 12,156 chars
- [skeptic-product-lead](critique/skeptic-product-lead.md) — 9,282 chars
- [slp-clinical-review](critique/slp-clinical-review.md) — 24,200 chars

## author (1)

Synthesis — the final documents.

- [product-brief](author/product-brief.md) — 144,867 chars
