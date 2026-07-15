# data-architecture--obf-adoption-is-real-but-partial-and-specifi

> Phase: **verify** · Agent `aacde733c5f6a594e` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Corrected claim: OBF adoption is real but partial, and absent from the incumbents this product is positioned against. Natively confirmed: CoughDrop (OBF is its native import/export format), Cboard (since 2018), Sensory Boards. Plausible but unverified: PiCom, Talking Buttons (both Sensory App House). REMOVE Grid 3 from the confirmed list — Smartbox documents only .gridset import and never mentions Open Board Format; Grid3 appears in the OBF ecosystem solely as a source format read BY the third-party obf-node converter, which is not native vendor support. No evidence Proloquo2Go/AssistiveWare or TouchChat import OBF; AssistiveWare docs describe only their own backup format moved via cloud storage/iTunes/AirDrop. Proloquo2Go is further absent from the third-party converter ecosystem (obf-node reads TouchChat .ce, Grid3 .gridset, Snap .spb/.sps, but not Proloquo2Go), so "import your Proloquo board" is not deliverable via OBF or any known community tool. Governance is thin as stated: the canonical spec is an unversioned Google Doc linked from openaac.org; the open-aac/openboardformat repo's /spec folder holds RSpec tests for a Rails site, not the specification.

**Evidence:** CORE CLAIM SUBSTANTIATED. (1) CoughDrop native OBF: confirmed — CoughDrop docs state boards export as .obf (single) / .obz (board set), and any .obf/.obz "from CoughDrop or another source" can be imported. The cited Zendesk URL 403s to direct fetch but its content is retrievable via search indexing. (2) Cboard: confirmed via cboard.io's own post describing an adapter accepting an OBF object and rendering it in Cboard — but this dates to 2018-06-30, not a recent (2024-2026) source. (3) Sensory Boards: confirmed via boards.sensoryapphouse.com/guide/, which documents .obf/.obz as "Open Board Format standard for interoperability with other AAC tools" and lists NO proprietary vendor formats. (4) Proloquo2Go/TouchChat absence: SUBSTANTIATED, and by stronger evidence than the researcher offered. The cited AssistiveWare page never mentions OBF/OBZ (describes OneDrive/Dropbox/Google Drive + iTunes File Sharing of its own backup format; AirDrop is on the sibling "Share backups" page, a minor sourcing slip). Decisively: the third-party converter willwade/obf-node reads .sfy, .sgrid, .ce (TouchChat), .spb/.sps (Snap), .gridset (Grid3), .obf/.obz — and Proloquo2Go is absent even from the community converter ecosystem, implying its backups are not community-parseable at all. (5) Governance/Google Doc: confirmed — openaac.org/docs.html links the spec to docs.google.com/document/d/1Bnl5neOf9-y53yOAGjd8BzQ7jvAdLhcB6y9Zw7ITYbA with no version number. I attempted to refute this via the open-aac/openboardformat repo's /spec folder, but it contains controllers/, helpers/, models/ — RSpec tests for a Rails documentation site, not specification text. No versioned spec repo exists.

DEFECT FOUND — GRID 3. The researcher listed Grid 3 as "confirmed OBF import/export." This is not substantiated. Smartbox's own knowledgebase (hub.thinksmartbox.com) describes importing .gridset files and "add from another grid set"; no Smartbox documentation mentions Open Board Format. Grid3 appears in the OBF ecosystem only as a SOURCE format that third-party obf-node converts FROM (.gridset -> OBF/OBZ) — the opposite direction from "Grid 3 imports OBF," via a vendor-independent MIT-licensed tool. This appears to be a misread of third-party converter support as native vendor support.

UNVERIFIED: PiCom and Talking Buttons OBF support could not be independently confirmed. Both are Sensory App House products, so plausible by association with the confirmed Sensory Boards, but this is inference rather than evidence.

NET: The load-bearing conclusion for the product decision holds and is arguably understated — "import your Proloquo board" is not deliverable via OBF, and given Proloquo's absence from even community converters, likely not deliverable at all. The accurate framing is that OBF is a lingua franca among open/web AAC tools and third-party converters, NOT an interop layer premium incumbents participate in. Confidence "high" is defensible on the thesis but was not warranted on the Grid 3 specific.

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

CLAIM: OBF adoption is real but partial — and specifically absent from the incumbents this product is positioned against
THEIR DETAIL: Confirmed OBF import/export in CoughDrop (it is CoughDrop's native format), Cboard, Grid 3, Sensory Boards, PiCom, Talking Buttons. I could NOT find evidence that Proloquo2Go/AssistiveWare or TouchChat import OBF; AssistiveWare docs describe only their own backup formats (.p2g-style backups via AirDrop/Dropbox/iTunes). So 'import your Proloquo board' is NOT deliverable via OBF. Governance is also thin: the canonical spec is a Google Doc linked from openaac.org, not a versioned spec repo.
THEIR CLAIMED SOURCES: https://coughdrop.zendesk.com/hc/en-us/articles/201800485-What-file-format-does-CoughDrop-use-for-import-export, https://boards.sensoryapphouse.com/, https://www.assistiveware.com/support/proloquo2go/protect-share/save-and-restore-selected-backups-using-other-storage-services, https://www.openaac.org/docs.html
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
