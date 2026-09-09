# Cyrillic Font Fallback Design

## Goal

Render Cyrillic characters in a monospaced font while retaining
ComicShannsMono Nerd Font for Latin text and icons.

## Design

Configure Emacs's default fontset to use Source Code Pro for the `cyrillic`
script.  Source Code Pro is installed locally and includes Cyrillic glyphs.
The setting will be placed alongside the existing Doom font declarations in
`config.el` and will not change the primary or variable-pitch font families.

## Verification

Load the font configuration in Emacs and inspect the default fontset's
Cyrillic-script mapping for Source Code Pro.
