/// User-facing strings that are neither type tokens nor colours.
///
/// Authored here as literals — lowercase where the design calls for it — and
/// NEVER produced by a text transform at render time. A `.toLowerCase()` in a
/// widget is a rule about all text, and text includes a user's own sentence; no
/// lint catches the day it lowercases theirs.
library;

/// The show-mode standing line's default, with a real apostrophe (U+2019): a
/// straight quote in a stranger's face is a different character. Editable to
/// anything the user wants, including the empty string.
const String defaultStandingLine = 'I can’t speak right now. I can hear you.';

/// The show-mode exit target's accessibility label. The entire poster is one
/// dismiss button for a switch or TalkBack user; unlabelled, it is a full-bleed
/// surface they cannot find their way out of.
const String showDismissLabel = 'Close';

/// The show-screen polarity control, authored exactly, never transformed.
const String showScreenSettingLabel = 'Show screen: bright · match my theme';

/// The standing-line on/off control.
const String standingLineSettingLabel = 'Standing line';

/// The edit-mode toggle's VISIBLE chrome — lowercase, authored, never a
/// transform. `edit` at rest, `done` while editing.
const String editModeEnterChrome = 'edit';
const String editModeExitChrome = 'done';

/// The edit-mode toggle's SEMANTIC labels — sentence case, because a screen
/// reader speaks a sentence, and naming the mode the button PUTS you in, not the
/// mode you are in, so the announcement is never a lie about what the tap does.
const String editBoardLabel = 'Edit board';
const String doneEditingLabel = 'Done editing';

/// The empty slot's label in edit mode. Never 'plus', never ''.
const String addPhraseLabel = 'Add phrase';

// ── Settings chrome ───────────────────────────────────────────────────────
// Lowercase visible chrome, authored — never a `.toLowerCase()`, which is a
// rule about all text and text includes a user's phrases. Semantic labels are
// sentence case, because a screen reader speaks a sentence.

/// The board's settings entry, and the screen's own title.
const String settingsChrome = 'settings';

/// The theme control's visible names, one per cycle position. Both HC palettes
/// read `high contrast`: polarity is not in the label, which names the position.
const String themePaperChrome = 'paper';
const String themeInkChrome = 'ink';
const String themeHighContrastChrome = 'high contrast';

/// Tile count — both options visible, no dropdown.
const String tilesChrome = 'Tiles: 12 · 6';

/// Output mode — three first-class values, one selected.
const String outputChrome = 'Output: speak · show · both';

/// High-contrast polarity — a set-once preference, dark or light.
const String hcPolarityChrome = 'High contrast: dark · light';

/// Blunt on purpose. A safety control for a user whose adversary may hold their
/// phone account; softening it to "backup preferences" costs them the control.
const String keepOffBackupChrome = 'Keep my board off cloud backup';

/// Restore is a labelled control, never a hidden gesture.
const String restoreBoardChrome = 'Restore previous board';

/// Export and import — the whole backup story once cloud backup is off. Sentence
/// register, like the two rows above. Nothing about where the file goes once the
/// share sheet has it: the export is plaintext and contains phrases like "I am
/// being hurt", and the adversary here often has access to the phone account.
const String exportBoardChrome = 'Export my board';
const String importBoardChrome = 'Import a board';

/// Results and errors: statement, then the next action. No apology, no "we", no
/// exclamation, no ellipsis, no modal. Curly apostrophes. Engine codes, zip entry
/// names and SqliteException text go to the log line, never here.
const String importOkResult =
    'Board imported. The board you had is still here — switch back in settings.';
const String importNotReedResult =
    'That file isn’t a Reed board. Pick another file.';
const String importNeedsNewerResult =
    'That board needs a newer version of Reed. Update Reed, then import again.';
const String importFailedResult =
    'That board didn’t import. Nothing on this phone changed.';
const String exportFailedResult =
    'That export didn’t finish. No file was created.';

/// Haptics and low stimulus — the two a person reaches for mid-episode.
const String hapticsOnChrome = 'haptics: on';
const String hapticsOffChrome = 'haptics: off';
const String lowStimulusOnChrome = 'low stimulus: on';
const String lowStimulusOffChrome = 'low stimulus: off';

// ── Voice picker ──────────────────────────────────────────────────────────

/// The section heading, and the slider names. Names first, prose only where a
/// name is insufficient.
const String voiceSectionChrome = 'Voice';
const String pitchSliderChrome = 'Pitch';
const String rateSliderChrome = 'Rate';

/// The one honest sentence the pitch control exists to say. No "we can't", no
/// "unfortunately", no ellipsis — there is no middle-pitch offline voice to
/// offer, and inventing one is the app guessing at somebody's gender.
const String pitchCaption =
    'Pitch shifts the voice you picked. It can’t make a voice that sits in '
    'the middle.';

/// The preview line — the standing line the app already owns, adult register.
const String voicePreviewText = 'I can’t talk right now but I’m okay.';

/// The no-offline-voices state: a statement, not an error to apologise for.
const String noOfflineVoices =
    'No offline voices on this phone. Reed shows your words on screen instead.';

/// The inline failure lines, one per outcome. State the fact, then the action.
const String voiceNotInstalledError =
    'That voice isn’t installed. Pick another in settings.';
const String voiceUnavailableError = 'That voice isn’t available. Pick another.';
const String voiceEngineError =
    'The speech engine didn’t respond. Your words are on screen.';

/// The editor's two field names — exactly these words, not label/value, not
/// short/long. "What you see" is the tile handle; "What it says" is the spoken
/// sentence, which most users never open.
const String whatYouSeeLabel = 'What you see';
const String whatItSaysLabel = 'What it says';

/// The editor's chrome — lowercase, authored, never a transform.
const String editSaveChrome = 'save';
const String editCancelChrome = 'cancel';

/// "What it says" is collapsed until opened; this is its opener.
const String openWhatItSaysChrome = 'set what it says';

/// The save-failure line: state the fact, then the next action. Inline and
/// non-blocking — never a modal. No apology, no "Sorry", no exclamation.
const String editSaveFailed = 'That tile didn’t save. Tap it to edit and save '
    'again.';
