# Org-srs Design

## Goal

Add spaced-repetition reviews to the existing Doom Org workflow with no changes to the user's Org files until they explicitly create review items.

## Chosen approach

Install org-srs from MELPA through Doom's package manifest. Leave reviews discoverable through `M-x org-srs-review-start`, and add the upstream F5–F8 review-rating keys to Org buffers only.

## Keybindings

- F5: rate Easy
- F6: rate Good
- F7: rate Hard
- F8: rate Again

## Verification

Run `doom sync`, load org-srs and its four rating commands in batch Emacs, and check the edited configuration for balanced parentheses.
