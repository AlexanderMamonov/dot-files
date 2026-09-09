# Org-srs Grep Prefilter Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Avoid opening every Org-roam file when an Org-srs review searches the Org-roam directory.

**Architecture:** Add two Doom-local helpers: one invokes `grep` to find Org files containing an Org-srs item marker, and the other delegates only those candidate files to Org-srs's existing file query.  Attach the helper as narrow advice around `org-srs-query-directory`; it activates only when the queried directory is exactly `org-roam-directory`, preserving all upstream parsing and scheduling behavior elsewhere.

**Tech Stack:** Doom Emacs, Emacs Lisp, Org-srs, POSIX `grep`, ERT, batch Emacs.

---

### Task 1: Add focused tests for candidate discovery and scope handling

**Files:**
- Create: `tests/test-org-srs-grep-prefilter.el`
- Modify: `config.el:101-108`

**Step 1: Write the failing candidate-discovery test**

Create an ERT fixture tree containing `has-card.org` with a `#+NAME: srsitem:`
line, `no-card.org` with ordinary Org content, and `asset.txt` containing the
same marker.  Write an ERT test asserting that
`my/org-srs-grep-candidate-files` returns only the absolute path of
`has-card.org`.

```emacs-lisp
(ert-deftest my/org-srs-grep-candidate-files-finds-only-org-srs-files ()
  (let ((directory (make-temp-file "org-srs-prefilter-" t)))
    (unwind-protect
        (progn
          ;; Write the three fixture files.
          (should (equal (my/org-srs-grep-candidate-files directory)
                         (list (expand-file-name "has-card.org" directory)))))
      (delete-directory directory t))))
```

**Step 2: Write the failing scope-preservation test**

Stub `org-srs-query-file` and the original directory-query function.  Assert
that the advised query calls the file query for the candidate list when the
directory is `org-roam-directory`, but delegates unchanged for another
directory.

**Step 3: Run the tests to verify they fail**

Run:

```bash
emacs --batch -Q -l tests/test-org-srs-grep-prefilter.el -f ert-run-tests-batch-and-exit
```

Expected: failure because the candidate and advised-query helpers do not exist.

### Task 2: Implement candidate discovery and the narrow Org-srs query override

**Files:**
- Modify: `config.el:101-108`
- Test: `tests/test-org-srs-grep-prefilter.el`

**Step 1: Implement portable, argument-safe grep invocation**

In an `(after! org-srs ...)` block, define
`my/org-srs-grep-candidate-files`.  Use `process-file` rather than a shell
string, invoke `grep` recursively and case-insensitively for the line-start
marker `#+NAME: srsitem:`, and return newline-separated matching `*.org`
filenames.  Treat exit status 1 as no candidates; signal an error for any other
nonzero status.

**Step 2: Implement candidate-only delegation**

Define an around-advice for `org-srs-query-directory` that compares
`file-truename` values.  If the requested directory equals
`org-roam-directory`, map the original `org-srs-query-file` over the helper's
candidate list and concatenate the results.  Otherwise call the original
directory-query function with its untouched arguments.

Do not alter `org-srs-review-start`, its source-selection logic, or its
scheduling strategy: the normal Org-srs query predicate must be passed through
unchanged.

**Step 3: Run the focused tests to verify they pass**

Run:

```bash
emacs --batch -Q -l tests/test-org-srs-grep-prefilter.el -f ert-run-tests-batch-and-exit
```

Expected: all candidate-discovery and scope-preservation tests pass.

### Task 3: Verify integration in the Doom configuration

**Files:**
- Modify: `config.el:101-108`
- Test: `tests/test-org-srs-grep-prefilter.el`

**Step 1: Byte-compile/load the relevant configuration**

Run Doom's batch Emacs with the Org-srs package available, load the new helper,
and verify that `org-srs-query-directory` has the local advice installed.

```bash
doom env && emacs --batch -l config.el --eval '(require (quote org-srs))' --eval '(message "org-srs grep prefilter loaded")'
```

Expected: exit status 0 and the confirmation message, with no invalid-function
or malformed-regexp errors.

**Step 2: Run the complete focused test suite**

Run:

```bash
emacs --batch -Q -l tests/test-org-srs-grep-prefilter.el -f ert-run-tests-batch-and-exit
```

Expected: all tests pass.

**Step 3: Commit the implementation**

```bash
git add config.el tests/test-org-srs-grep-prefilter.el
git commit -m "perf: prefilter org-srs roam reviews with grep"
```
