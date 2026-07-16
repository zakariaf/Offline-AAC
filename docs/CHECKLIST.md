# Pre-release device checklist

Run this on a **physical phone** — a cheap Android one, because that is what
this audience carries and an emulator has no text-to-speech engine — with the
**ringer switch OFF**, before every upload. Nothing here can be automated: the
suite proves the code is correct, this proves the app *works*, and with no
telemetry and users who cannot report a bug, it is the only place these
failures are ever caught before a person hits them.

A green CI badge is not permission to ship. This is.

## 1. Audio — guards the silence class

The one class of bug that automation cannot see, because there is no hook to
capture whether sound actually left the speaker.

- [ ] **Silent switch.** Ringer switch OFF. Tap a tile. Sound comes out of the
  speaker. If it is silent, the audio session is `.ambient` somewhere — the
  worst bug in the product, and one word. (A Dart test can only assert the code
  passed `.playback` to the wrapper, never that the OS applied it.)
- [ ] **Reported success, no sound.** Tap several tiles across a session and
  confirm every one is audible. An engine that returns success and emits nothing
  is the `reportedSuccessButSilent` case the automated suite deliberately
  excludes; this is where it is caught.
- [ ] **Audio focus during a call.** Start a phone call, then tap a tile. Speech
  ducks or waits rather than being lost, and recovers after the call.
- [ ] **Bluetooth yanked mid-utterance.** Tap a tile with earbuds connected, then
  pull them out (or walk out of range) while it speaks. Audio moves to the phone
  speaker rather than vanishing.

<!-- E10 (verification) extends this file: screen readers, switch access, text
     scaling, the native surfaces, data survival, the crash log, airplane mode.
     The Audio section above is owned by the speech work and must stay. -->
