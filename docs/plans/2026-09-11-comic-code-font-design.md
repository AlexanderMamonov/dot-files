# Comic Code Font Design

## Goal

Use Comic Code for all Doom Emacs text faces where its glyphs are available,
including Latin and Cyrillic characters.

## Design

Set both `doom-font` and `doom-variable-pitch-font` to the locally installed
`Comic Code` family at the existing size of 18 points.  Retain `Symbols Nerd
Font Mono` as `doom-symbol-font` so Nerd Font icons remain available.

Remove the explicit `Source Code Pro` Cyrillic fontset override.  This lets
Emacs render every character supported by Comic Code with that family and use
its usual fallback mechanism only for glyphs Comic Code does not provide.

## Verification

Check the configuration's Lisp syntax, confirm that `Comic Code` is installed,
and load the font declarations in Emacs to assert the fixed-width and
variable-pitch font family settings both name Comic Code.
