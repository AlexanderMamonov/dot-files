# Org-srs Grep Prefilter Design

## Goal

Make directory-wide reviews of the Org-roam collection practical by discovering
candidate files with `grep` before Org-srs opens and parses them.

## Chosen approach

Keep Org-srs as the authority for item parsing, scheduling, limits, ordering,
and review UI.  When its review source is exactly `org-roam-directory`,
intercept only the directory query:

1. Run `grep -rli` in `org-roam-directory` for the case-insensitive Org-srs
   item marker, `#+NAME: srsitem:`, limited to `*.org` files.
2. Pass each matching filename to Org-srs's normal per-file query.
3. Concatenate the resulting item lists and allow the normal Org-srs review
   strategy to select and order the session's cards.

The initial filesystem scan remains cheap text search; only candidate files are
opened and parsed as Org buffers.

## Scope

The optimization applies only to an explicit review of `org-roam-directory`.
Selected regions, buffers, files, other directories, and projects retain
upstream Org-srs behavior.

Encrypted `*.org.gpg` files are deliberately outside the optimized scope:
`grep` cannot inspect them.  They remain reviewable with an explicit file
source.

## Error handling

An exit status indicating no grep matches produces an empty candidate list and
therefore a normal completed review.  Other grep failures raise an error rather
than silently hiding review material.

## Verification

Test the candidate finder with a temporary fixture tree, including a matching
file, a nonmatching Org file, and a non-Org file.  Verify that the Org-roam
directory query delegates only matching files to Org-srs, and that other
directory queries retain the original implementation.
