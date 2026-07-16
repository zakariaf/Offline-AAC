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
