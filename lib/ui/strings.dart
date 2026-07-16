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
