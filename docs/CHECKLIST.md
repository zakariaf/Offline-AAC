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

## 2. Edit mode — guards the "someone else configures their voice" class

The editor is where a user configures their own voice. Automation covers a small
minority of real accessibility issues here, and Switch Access cannot be simulated
at all — Flutter publishes no API for scanning, group selection, or point
scanning. These passes are the only place a focus trap or an unreachable control
is ever caught, and each guards a top-severity failure: an editor only a sighted
touch user can drive means a caregiver picks the words that come out of someone's
mouth.

- [ ] **Switch Access, whole loop.** Using ONLY a switch: enter edit mode, reach
  an empty slot, add a phrase, dictate into "What you see" and "What it says"
  with the keyboard's own mic key, save, and exit. Focus traps in the form and in
  edit mode are verified here or not at all.
- [ ] **TalkBack, whole loop.** Same run with TalkBack: every control announces
  what it does and to which phrase ("Move Overwhelmed up", not "button");
  nothing announces twice; an empty slot is a button in edit mode and silent on
  the speak screen; a hidden tile is silent in speak mode and offers Unhide in
  edit mode.
- [ ] **Accessibility Scanner over edit mode.** Google's Accessibility Scanner
  (an `AccessibilityService` reading Flutter's virtual node tree) across the
  editor and the edit-mode board. Human-driven, on-device, pre-release.
- [ ] **The cap refuses, dictation included.** Dictate a phrase longer than 16
  characters into "What you see". The field stops at 16 and the counter says so;
  it never silently swallows the tail mid-word.

<!-- E10 (verification) extends this file: screen readers, switch access, text
     scaling, the native surfaces, data survival, the crash log, airplane mode.
     The Audio section above is owned by the speech work and must stay. -->
