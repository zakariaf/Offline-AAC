/// The four paper stocks a phrase can be dyed with.
///
/// A stock is a categorical identity, not a colour. The data layer stores its
/// [name] in `buttons.background_color`; the UI maps that name to the two hexes
/// (rest and lit) for the current palette. Keeping the type here — not beside
/// the colour tables — is what lets a phrase, a seed, and a repository name a
/// stock without any of them reaching into the UI, and it is why exactly four
/// exist: colourblind separation is achieved by staggering lightness across a
/// narrow window, and that window holds four and no more.
enum Stock { oxblood, slate, tan, fir }
