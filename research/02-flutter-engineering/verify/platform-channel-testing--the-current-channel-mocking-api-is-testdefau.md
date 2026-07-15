# platform-channel-testing--the-current-channel-mocking-api-is-testdefau

> Phase: **verify** · Agent `a4cf89b082b03e446` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the claim. One optional refinement for the corpus: MethodChannel.checkMockMethodCallHandler did not move under its own name — its replacement is TestDefaultBinaryMessenger.checkMockMessageHandler (Message, not MethodCall). Additionally, the cited breaking-change page still shows the outdated nullable `TestDefaultBinaryMessengerBinding.instance!`; the claim's non-nullable `instance` is the correct current form (`static TestDefaultBinaryMessengerBinding get instance`), so prefer the claim's phrasing over the doc's on that one point.

**Evidence:** Every load-bearing element of the claim was independently substantiated against primary sources. I attempted refutation on five axes and all failed.

1. VERSION ROT — NOT FOUND. This is the obvious hypothesis (the move landed in 2.3.0-17.0.pre.1 / stable 2.5, i.e. 2021) and it fails. The docs.flutter.dev breaking-change page is live, states "Page last updated: 2026-05-05" and "Documentation reflects Flutter version: 3.44.0" — matching today's stable exactly. The claim's own date attribution is correct, not a stale memory.

2. INVENTED API SIGNATURE — NOT FOUND. api.flutter.dev returns a real page for TestDefaultBinaryMessenger.setMockMethodCallHandler with signature:
   void setMockMethodCallHandler(MethodChannel channel, Future<Object?>? Function(MethodCall message)? handler)
   Channel-as-first-argument is exactly as claimed. Not deprecated.

3. "MOVED OUT OF package:flutter" — VERIFIED BY ABSENCE. Fetched the MethodChannel class page in package:flutter services. Its members are invokeMethod, invokeListMethod, invokeMapMethod, setMethodCallHandler, binaryMessenger, codec, name. setMockMethodCallHandler and checkMockMethodCallHandler are NOT class members — they appear only via the TestMethodChannelExtension from flutter_test. The move is real and complete.

4. TestMethodChannelExtension DEPRECATION SUB-CLAIM — CONFIRMED VERBATIM. The extension exists with signature setMockMethodCallHandler(Future<dynamic>? Function(MethodCall call)? handler) and carries: "Use tester.binding.defaultBinaryMessenger.setMockMethodCallHandler or TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler instead. Pass the channel as the first argument. This feature was deprecated after v3.9.0-19.0.pre." The claim's specific and unusual sub-detail is precisely right.

5. MIGRATION SNIPPET — matches the doc verbatim, including the tester.binding form and the "code that does not have access to a WidgetTester" escape hatch.

NOTABLE: the claim is MORE current than its own cited source. The breaking-change doc still writes the legacy nullable `TestDefaultBinaryMessengerBinding.instance!`; the claim writes non-nullable `instance`. I checked the instance property page: it is `static TestDefaultBinaryMessengerBinding get instance` (non-nullable, via BindingBase.checkInstance). The claim is correct and the doc's bang is the stale artifact. This is the opposite of version rot.

TWO CAVEATS, neither material:
(a) The claim says checkMockMethodCallHandler "moved to flutter_test." True, but the doc maps it to TestDefaultBinaryMessenger.checkMockMessageHandler — not a like-named checkMockMethodCallHandler. Anyone grep-migrating on the assumption of a name-preserving move will miss it. Nomenclature nit, not an error in what was asserted.
(b) "Verified working on Flutter 3.41.2 locally" is unverifiable by me (no such SDK here), but it is corroborative, not load-bearing — the API is documented as current on 3.44.0 regardless.

CONFIDENCE ASSESSMENT: the researcher's stated "high" is warranted. A project decision can rest on this.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "platform-channel-testing" made this claim, and a project decision depends on it.

CLAIM: The current channel-mocking API is TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler), and the old MethodChannel.setMockMethodCallHandler was moved out of package:flutter into package:flutter_test.
DETAIL: Flutter's official breaking-change doc (last updated 2026-05-05) confirms BinaryMessenger.setMockMessageHandler, BasicMessageChannel.setMockMessageHandler, MethodChannel.setMockMethodCallHandler and checkMockMethodCallHandler all moved to flutter_test. Migration: `myMethodChannel.setMockMethodCallHandler(...)` -> `tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(myMethodChannel, ...)`. Outside testWidgets, use TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger. The TestMethodChannelExtension.setMockMethodCallHandler variant is itself now deprecated. Verified working on Flutter 3.41.2 locally.
CLAIMED SOURCES: https://docs.flutter.dev/release/breaking-changes/mock-platform-channels, https://api.flutter.dev/flutter/flutter_test/TestDefaultBinaryMessenger/setMockMethodCallHandler.html
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: pub.dev package pages (for real current versions, publisher, and maintenance status), api.flutter.dev (for real API signatures), dart.dev, docs.flutter.dev, and the actual GitHub repos (for whether something is archived/discontinued).

The failure modes you are hunting for, in order of likelihood:
1. **Version rot** — the claim was true in 2023. APIs get deprecated and removed; `setMockMethodCallHandler` moved; `window` was deprecated; formatters changed.
2. **Dead packages presented as alive** — golden_toolkit, dart_code_metrics, isar, hive, mockito-vs-mocktail. CHECK THE REPO: is it archived? When was the last publish? Does pub.dev show it as discontinued?
3. **Invented or misremembered API signatures.** If the claim names a method, class, or parameter, VERIFY IT EXISTS with that exact name on api.flutter.dev or the package docs. LLM-plausible API names are a specific hazard here.
4. **Cargo cult** — presenting a team practice or a large-app practice as universal, when the actual source doesn't say that.
5. **Overstated consensus** — "the community recommends X" when it's one blog post.

Default to refuted=true if you cannot independently substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + a correction if directionally right but wrong in specifics (name the exact right version/API). UNVERIFIABLE if no source settles it — and say that plainly rather than guessing.
````

</details>
