/// The four palettes Reed can render in.
///
/// `paper` and `ink` are the light and dark everyday surfaces; `hcInk` and
/// `hcPaper` are the two polarities of the high-contrast accommodation. The
/// switcher cycles three positions — paper, ink, high contrast — and the HC
/// polarity is a set-once preference, so someone mid-shutdown produces one
/// predictable next state per tap.
///
/// This lives in the model layer, not beside the colour tables, so the data
/// layer can persist and restore the chosen palette by [name] without importing
/// the UI. The colour values that each palette resolves to are a UI concern; the
/// identity of the palette is not.
enum AacPalette { paper, ink, hcInk, hcPaper }
