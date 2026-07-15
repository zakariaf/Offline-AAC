# Pre-release checklist — PHYSICAL DEVICE, RINGER SWITCH OFF

Run before every tag. Release build, signed as shipped. A cheap real phone
(budget silicon, ~2GB RAM) — **never an emulator**: it has no TTS engine.
Sections 5–7 are destructive; run in order.

Device: ______  OS: ______  Build/tag: ______  Date: ______

## 1. Audio — guards the silent-failure class

- [ ] HARDWARE SILENT SWITCH ON / silent mode ON, tap a tile -> **AUDIO STILL
      PLAYS**. Silent means the audio session is `.ambient`, not `.playback`.
      Top-severity bug: the switch mutes a person's voice.
- [ ] Cold launch, FIRST tap speaks with no dead beat (TTS bind latency reads as
      silence; the engine must be warmed off a post-frame callback, never awaited)
- [ ] Music playing -> tile speech DUCKS it; music resumes after
- [ ] AIRPLANE MODE ON, tap every tile -> all 12 speak (catches a
      `network_required` voice slipping the filter — Android sends the STRING
      "1"/"0", so a naive bool check inverts the safety property)
- [ ] Settings > select EACH offered voice > tap a tile -> each ACTUALLY speaks
      (`setVoice` returns 0 on an unknown name without throwing; a `notInstalled`
      voice returns 1 = success and is silent or substituted)
- [ ] Android: uninstall/disable the TTS engine entirely. Launch, tap a tile ->
      a VISIBLE error appears. Never silence.
- [ ] Bluetooth headphones -> speech routes to them, not the speaker
- [ ] Bluetooth YANKED mid-utterance -> phrase is not lost silently
- [ ] Incoming call during speech -> speech stops; after the call, app STILL
      SPEAKS (a focus request never re-acquired = permanently mute, no error)

## 2. TalkBack (Android) / VoiceOver (iOS)

- [ ] Swipe through the grid: all 12 tiles, row-major, none skipped
- [ ] Each tile announces its DISPLAY label ("Overwhelmed"), NOT the sentence
- [ ] Each tile announces as "button"
- [ ] Double-tap speaks the VOCALIZATION — audio ACTUALLY HEARD
- [ ] Empty slots are not announced as buttons
- [ ] Type-to-speak field is reachable AND exitable
- [ ] Show-text mode: announced; back-out works
- [ ] Edit mode: reachable, exitable, no focus trap
- [ ] iOS: TTS output and VoiceOver do not deadlock each other
- [ ] iOS: Personal Voice permission DENIED -> graceful fallback, never silence
- [ ] Google Accessibility Scanner on the grid screen — no new findings
- [ ] Xcode Accessibility Inspector audit on the grid screen — no new findings

## 3. Switch Access (Android) / Switch Control (iOS) — NO AUTOMATION EXISTS

These boxes are the only verification this path will ever get.

- [ ] Every tile reachable by scanning; order matches the traversal test
- [ ] Scan highlight is VISIBLE against every tile colour, incl. high contrast
      (the palette is flat and opaque — a highlight relying on elevation vanishes)
- [ ] Can exit edit mode using ONLY the switch
- [ ] Can exit the text field using ONLY the switch (no trap)
- [ ] iOS: point scanning can hit every tile

## 4. Scaling

- [ ] System font size at MAX + Display Zoom on: no tile text clipped
- [ ] Bold Text on: layout intact
- [ ] Show-text mode readable at max font size

## 5. Native surfaces — zero Dart coverage BY DESIGN

- [ ] QS tile: add to shade. FORCE-STOP the app. Tap tile -> speaks.
- [ ] QS tile: edit the phrase in-app, force-stop, tap tile -> speaks the NEW
      phrase (catches the Dart<->Kotlin storage-contract break)
- [ ] QS tile, screen LOCKED -> speaks, or prompts unlock predictably
- [ ] iOS ControlWidget: same three checks

## 6. Data — irreplaceable

- [ ] Install the PREVIOUS release, create/edit tiles, upgrade in place
      -> EVERY board intact
- [ ] Settings > "Restore previous board" recovers the pre-migration backup
- [ ] PHONE-MIGRATION REHEARSAL: export via the share sheet on device A, import
      on a wiped device / device B -> board identical, images intact
- [ ] Import a TRUNCATED and a hand-CORRUPTED export -> visible error, existing
      board untouched
- [ ] Add a 12MP photo to every tile on the ~2GB device -> no OOM kill
      (images must be downscaled to <=512px AT IMPORT)

## 7. Crash log — the only field signal

- [ ] Trigger a known crash in a debug build; export the log
- [ ] Stack trace has READABLE Dart function names. Hex offsets mean
      --obfuscate or --split-debug-info crept in and the only field signal this
      app has is dead.
- [ ] The exported log contains NO vocalization text
