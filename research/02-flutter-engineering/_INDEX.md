# Flutter architecture, coding standards & testing

`wf_12b14467-451` · **103 agents** · every agent's result + the prompt that produced it.

The methodology is in [`_workflow_script.js`](_workflow_script.js) — the fan-out, the schemas,
and the adversarial verification pass. Re-run or adapt it rather than rewriting it.

## research (12)

One agent per dimension, each doing independent web research.

- [a11y-testing](research/a11y-testing.md) — 40,890 chars
- [ci-release](research/ci-release.md) — 69,123 chars
- [dart3-idioms](research/dart3-idioms.md) — 33,883 chars
- [drift-testing](research/drift-testing.md) — 37,717 chars
- [lints-tooling](research/lints-tooling.md) — 29,087 chars
- [official-architecture](research/official-architecture.md) — 41,316 chars
- [performance-startup](research/performance-startup.md) — 30,988 chars
- [platform-channel-testing](research/platform-channel-testing.md) — 33,688 chars
- [project-structure](research/project-structure.md) — 32,211 chars
- [riverpod](research/riverpod.md) — 30,714 chars
- [testing-strategy](research/testing-strategy.md) — 49,764 chars
- [widget-golden-testing](research/widget-golden-testing.md) — 41,743 chars

## verify (84)

Adversarial fact-checkers, one per load-bearing claim, each told to *refute* it.

- [a11y-testing--a-custom-76dp-guideline-requires-no-subclass](verify/a11y-testing--a-custom-76dp-guideline-requires-no-subclass.md) — 5,036 chars
- [a11y-testing--breaking-current-containssemantics-is-deprec](verify/a11y-testing--breaking-current-containssemantics-is-deprec.md) — 3,532 chars
- [a11y-testing--critical-for-this-app-minimumtaptargetguidel](verify/a11y-testing--critical-for-this-app-minimumtaptargetguidel.md) — 4,331 chars
- [a11y-testing--exact-thresholds-androidtaptargetguideline-s](verify/a11y-testing--exact-thresholds-androidtaptargetguideline-s.md) — 3,239 chars
- [a11y-testing--screen-reader-traversal-order-is-automatable](verify/a11y-testing--screen-reader-traversal-order-is-automatable.md) — 5,717 chars
- [a11y-testing--textcontrastguideline-has-an-open-unfixed-fa](verify/a11y-testing--textcontrastguideline-has-an-open-unfixed-fa.md) — 3,181 chars
- [a11y-testing--the-documented-meetsguideline-ensuresemantic](verify/a11y-testing--the-documented-meetsguideline-ensuresemantic.md) — 5,629 chars
- [ci-release--flutter-action-v2-reads-fvmrc-directly-this](verify/ci-release--flutter-action-v2-reads-fvmrc-directly-this.md) — 4,035 chars
- [ci-release--flutter-s-own-docs-state-obfuscation-is-not](verify/ci-release--flutter-s-own-docs-state-obfuscation-is-not.md) — 3,604 chars
- [ci-release--golden-tests-are-os-dependent-the-2026-conse](verify/ci-release--golden-tests-are-os-dependent-the-2026-conse.md) — 5,476 chars
- [ci-release--obfuscation-is-actively-harmful-for-this-spe](verify/ci-release--obfuscation-is-actively-harmful-for-this-spe.md) — 3,715 chars
- [ci-release--r8-minification-failures-surface-as-missing](verify/ci-release--r8-minification-failures-surface-as-missing.md) — 5,252 chars
- [ci-release--subosito-flutter-action-is-still-on-v2-in-20](verify/ci-release--subosito-flutter-action-is-still-on-v2-in-20.md) — 2,698 chars
- [ci-release--verygoodopensource-very-good-coverage-is-arc](verify/ci-release--verygoodopensource-very-good-coverage-is-arc.md) — 3,654 chars
- [dart3-idioms--dart-macros-were-cancelled-in-january-2025-a](verify/dart3-idioms--dart-macros-were-cancelled-in-january-2025-a.md) — 6,006 chars
- [dart3-idioms--do-not-use-runzonedguarded-in-flutter-3-10-u](verify/dart3-idioms--do-not-use-runzonedguarded-in-flutter-3-10-u.md) — 4,331 chars
- [dart3-idioms--flutter-s-official-architecture-guide-does-p](verify/dart3-idioms--flutter-s-official-architecture-guide-does-p.md) — 3,059 chars
- [dart3-idioms--for-speak-a-sealed-domain-outcome-beats-both](verify/dart3-idioms--for-speak-a-sealed-domain-outcome-beats-both.md) — 7,064 chars
- [dart3-idioms--freezed-is-not-worth-it-for-this-app-in-2026](verify/dart3-idioms--freezed-is-not-worth-it-for-this-app-in-2026.md) — 3,775 chars
- [dart3-idioms--platformdispatcher-instance-onerror-s-bool-r](verify/dart3-idioms--platformdispatcher-instance-onerror-s-bool-r.md) — 5,941 chars
- [dart3-idioms--primary-constructors-are-experimental-in-dar](verify/dart3-idioms--primary-constructors-are-experimental-in-dar.md) — 3,022 chars
- [drift-testing--data-integrity-migration-testing-does-exist](verify/drift-testing--data-integrity-migration-testing-does-exist.md) — 3,997 chars
- [drift-testing--drift-is-at-2-34-2-as-of-july-2026-drift-flu](verify/drift-testing--drift-is-at-2-34-2-as-of-july-2026-drift-flu.md) — 3,039 chars
- [drift-testing--make-migrations-is-the-current-recommended-w](verify/drift-testing--make-migrations-is-the-current-recommended-w.md) — 4,030 chars
- [drift-testing--migrateandvalidate-validates-schema-shape-on](verify/drift-testing--migrateandvalidate-validates-schema-shape-on.md) — 4,351 chars
- [drift-testing--pragma-foreign-keys-is-a-silent-no-op-inside](verify/drift-testing--pragma-foreign-keys-is-a-silent-no-op-inside.md) — 3,807 chars
- [drift-testing--sqlite-foreign-keys-are-off-by-default-and-d](verify/drift-testing--sqlite-foreign-keys-are-off-by-default-and-d.md) — 5,357 chars
- [drift-testing--the-official-docs-own-beforeopen-example-is](verify/drift-testing--the-official-docs-own-beforeopen-example-is.md) — 2,780 chars
- [lints-tooling--discarded-futures-and-unawaited-futures-both](verify/lints-tooling--discarded-futures-and-unawaited-futures-both.md) — 3,544 chars
- [lints-tooling--non-exhaustive-switches-over-sealed-classes](verify/lints-tooling--non-exhaustive-switches-over-sealed-classes.md) — 4,605 chars
- [lints-tooling--riverpod-lint-3-x-has-migrated-off-custom-li](verify/lints-tooling--riverpod-lint-3-x-has-migrated-off-custom-li.md) — 5,193 chars
- [lints-tooling--the-installed-sdk-is-flutter-3-41-2-dart-3-1](verify/lints-tooling--the-installed-sdk-is-flutter-3-41-2-dart-3-1.md) — 3,162 chars
- [lints-tooling--the-plugins-block-syntax-with-a-pub-version](verify/lints-tooling--the-plugins-block-syntax-with-a-pub-version.md) — 3,848 chars
- [lints-tooling--very-good-analysis-10-3-0-cannot-be-used-on](verify/lints-tooling--very-good-analysis-10-3-0-cannot-be-used-on.md) — 4,345 chars
- [lints-tooling--very-good-analysis-sets-close-sinks-ignore-a](verify/lints-tooling--very-good-analysis-sets-close-sinks-ignore-a.md) — 5,796 chars
- [official-architecture--flutter-s-official-architecture-guide-explic](verify/official-architecture--flutter-s-official-architecture-guide-explic.md) — 5,181 chars
- [official-architecture--flutter-s-official-position-on-folder-struct](verify/official-architecture--flutter-s-official-position-on-folder-struct.md) — 3,076 chars
- [official-architecture--google-recommends-mvvm-with-precisely-define](verify/official-architecture--google-recommends-mvvm-with-precisely-define.md) — 4,469 chars
- [official-architecture--google-s-domain-layer-use-cases-is-explicitl](verify/official-architecture--google-s-domain-layer-use-cases-is-explicitl.md) — 4,062 chars
- [official-architecture--the-compass-app-s-lib-is-169-files-across-6](verify/official-architecture--the-compass-app-s-lib-is-169-files-across-6.md) — 5,919 chars
- [official-architecture--the-project-s-existing-speechservice-abstrac](verify/official-architecture--the-project-s-existing-speechservice-abstrac.md) — 6,414 chars
- [official-architecture--the-sealed-result-t-type-is-the-single-highe](verify/official-architecture--the-sealed-result-t-type-is-the-single-highe.md) — 5,743 chars
- [performance-startup--android-vitals-treats-cold-start-5s-as-exces](verify/performance-startup--android-vitals-treats-cold-start-5s-as-exces.md) — 5,522 chars
- [performance-startup--deferred-components-are-unusable-for-this-pr](verify/performance-startup--deferred-components-are-unusable-for-this-pr.md) — 4,568 chars
- [performance-startup--flutter-run-profile-trace-startup-measures-f](verify/performance-startup--flutter-run-profile-trace-startup-measures-f.md) — 5,794 chars
- [performance-startup--impeller-is-irrelevant-to-this-app-s-speed-b](verify/performance-startup--impeller-is-irrelevant-to-this-app-s-speed-b.md) — 5,167 chars
- [performance-startup--memory-is-irrelevant-except-for-one-thing-us](verify/performance-startup--memory-is-irrelevant-except-for-one-thing-us.md) — 6,429 chars
- [performance-startup--the-already-decided-quick-settings-tileservi](verify/performance-startup--the-already-decided-quick-settings-tileservi.md) — 8,453 chars
- [performance-startup--tts-engine-binding-not-flutter-startup-domin](verify/performance-startup--tts-engine-binding-not-flutter-startup-domin.md) — 5,144 chars
- [platform-channel-testing--android-s-notinstalled-voice-feature-defeats](verify/platform-channel-testing--android-s-notinstalled-voice-feature-defeats.md) — 4,519 chars
- [platform-channel-testing--android-sends-network-required-as-the-string](verify/platform-channel-testing--android-sends-network-required-as-the-string.md) — 5,103 chars
- [platform-channel-testing--calling-testdefaultbinarymessengerbinding-in](verify/platform-channel-testing--calling-testdefaultbinarymessengerbinding-in.md) — 4,852 chars
- [platform-channel-testing--flutter-tts-s-android-setvoice-returns-succe](verify/platform-channel-testing--flutter-tts-s-android-setvoice-returns-succe.md) — 3,227 chars
- [platform-channel-testing--getvoices-returns-list-object-of-map-object](verify/platform-channel-testing--getvoices-returns-list-object-of-map-object.md) — 3,480 chars
- [platform-channel-testing--pigeon-is-actively-maintained-and-is-the-off](verify/platform-channel-testing--pigeon-is-actively-maintained-and-is-the-off.md) — 3,525 chars
- [platform-channel-testing--the-current-channel-mocking-api-is-testdefau](verify/platform-channel-testing--the-current-channel-mocking-api-is-testdefau.md) — 3,691 chars
- [project-structure--a-domain-layer-with-hand-written-mirror-mode](verify/project-structure--a-domain-layer-with-hand-written-mirror-mode.md) — 5,650 chars
- [project-structure--a-federated-plugin-for-the-native-interop-is](verify/project-structure--a-federated-plugin-for-the-native-interop-is.md) — 6,302 chars
- [project-structure--drift-schemas-and-test-generated-migrations](verify/project-structure--drift-schemas-and-test-generated-migrations.md) — 5,127 chars
- [project-structure--feature-first-is-a-poor-fit-for-this-app-bec](verify/project-structure--feature-first-is-a-poor-fit-for-this-app-bec.md) — 5,329 chars
- [project-structure--local-packages-melos-are-a-net-loss-for-a-so](verify/project-structure--local-packages-melos-are-a-net-loss-for-a-so.md) — 4,207 chars
- [project-structure--the-official-flutter-architecture-case-study](verify/project-structure--the-official-flutter-architecture-case-study.md) — 4,737 chars
- [project-structure--the-real-module-boundary-in-this-codebase-is](verify/project-structure--the-real-module-boundary-in-this-codebase-is.md) — 6,338 chars
- [riverpod--automatic-retry-is-on-by-default-in-riverpod](verify/riverpod--automatic-retry-is-on-by-default-in-riverpod.md) — 5,702 chars
- [riverpod--notifiers-are-now-recreated-on-every-provide](verify/riverpod--notifiers-are-now-recreated-on-every-provide.md) — 4,938 chars
- [riverpod--riverpod-3-is-stable-flutter-riverpod-3-3-2](verify/riverpod--riverpod-3-is-stable-flutter-riverpod-3-3-2.md) — 4,612 chars
- [riverpod--riverpod-3-pauses-providers-whose-only-liste](verify/riverpod--riverpod-3-pauses-providers-whose-only-liste.md) — 5,458 chars
- [riverpod--stateprovider-statenotifierprovider-and-chan](verify/riverpod--stateprovider-statenotifierprovider-and-chan.md) — 4,133 chars
- [riverpod--the-autodispose-modifier-and-all-autodispose](verify/riverpod--the-autodispose-modifier-and-all-autodispose.md) — 5,230 chars
- [riverpod--the-canonical-test-idiom-changed-providercon](verify/riverpod--the-canonical-test-idiom-changed-providercon.md) — 3,271 chars
- [testing-strategy--correct-test-double-taxonomy-meszaros-fowler](verify/testing-strategy--correct-test-double-taxonomy-meszaros-fowler.md) — 4,760 chars
- [testing-strategy--flutter-s-own-docs-rate-unit-tests-low-confi](verify/testing-strategy--flutter-s-own-docs-rate-unit-tests-low-confi.md) — 4,186 chars
- [testing-strategy--flutter-test-coverage-omits-files-that-no-te](verify/testing-strategy--flutter-test-coverage-omits-files-that-no-te.md) — 4,159 chars
- [testing-strategy--for-speechservice-a-hand-written-fake-beats](verify/testing-strategy--for-speechservice-a-hand-written-fake-beats.md) — 6,794 chars
- [testing-strategy--the-widely-cited-70-20-10-or-60-25-10-5-flut](verify/testing-strategy--the-widely-cited-70-20-10-or-60-25-10-5-flut.md) — 4,614 chars
- [testing-strategy--vgv-s-actual-argument-for-100-coverage-is-a](verify/testing-strategy--vgv-s-actual-argument-for-100-coverage-is-a.md) — 3,820 chars
- [testing-strategy--with-zero-animation-pumpandsettle-should-be](verify/testing-strategy--with-zero-animation-pumpandsettle-should-be.md) — 5,685 chars
- [widget-golden-testing--a-renderflex-overflow-fails-a-widget-test-by](verify/widget-golden-testing--a-renderflex-overflow-fails-a-widget-test-by.md) — 3,380 chars
- [widget-golden-testing--alchemist-s-ci-goldens-obscure-text-into-col](verify/widget-golden-testing--alchemist-s-ci-goldens-obscure-text-into-col.md) — 3,821 chars
- [widget-golden-testing--font-loading-in-goldens-is-not-automatic-in](verify/widget-golden-testing--font-loading-in-goldens-is-not-automatic-in.md) — 5,631 chars
- [widget-golden-testing--golden-toolkit-is-discontinued-alchemist-is](verify/widget-golden-testing--golden-toolkit-is-discontinued-alchemist-is.md) — 4,081 chars
- [widget-golden-testing--overflow-is-reported-only-once-per-renderobj](verify/widget-golden-testing--overflow-is-reported-only-once-per-renderobj.md) — 3,856 chars
- [widget-golden-testing--overflow-only-reports-if-the-widget-actually](verify/widget-golden-testing--overflow-only-reports-if-the-widget-actually.md) — 4,296 chars
- [widget-golden-testing--the-default-widget-test-surface-is-800x600-l](verify/widget-golden-testing--the-default-widget-test-surface-is-800x600-l.md) — 4,085 chars

## critique (3)

Cross-cutting critics reading the whole corpus.

- [completeness-critic](critique/completeness-critic.md) — 19,898 chars
- [skeptic-staff-engineer](critique/skeptic-staff-engineer.md) — 11,045 chars
- [test-engineer-review](critique/test-engineer-review.md) — 56,101 chars

## author (4)

Synthesis — the final documents.

- [architecture](author/architecture.md) — 44,809 chars
- [coding-standards](author/coding-standards.md) — 44,403 chars
- [testing](author/testing.md) — 80,030 chars
- [tooling](author/tooling.md) — 26,152 chars
