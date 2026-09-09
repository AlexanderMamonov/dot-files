# Org-srs Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add org-srs to the Doom Emacs configuration with keyboard shortcuts for review ratings.

**Architecture:** Declare org-srs in Doom's package manifest so `doom sync` installs it from MELPA. Configure the package lazily in `config.el` and add the upstream F5–F8 rating mappings only to `org-mode-map`, preserving the existing leader-key setup and avoiding a global binding.

**Tech Stack:** Doom Emacs, Emacs Lisp, MELPA, org-srs.

---

### Task 1: Declare and configure org-srs

**Files:**
- Modify: `packages.el`
- Modify: `config.el`
- Test: Doom package synchronization and Emacs Lisp batch loading through Doom

**Step 1: Add the package declaration**

Add the following declaration after the existing package declarations in `packages.el`:

```emacs-lisp
(package! org-srs)
```

**Step 2: Configure the rating mappings**

Add a deferred `use-package!` block to `config.el`:

```emacs-lisp
(use-package! org-srs
  :defer t
  :bind (:map org-mode-map
         ("<f5>" . org-srs-review-rate-easy)
         ("<f6>" . org-srs-review-rate-good)
         ("<f7>" . org-srs-review-rate-hard)
         ("<f8>" . org-srs-review-rate-again)))
```

**Step 3: Synchronize and verify the package**

Run: `doom sync`

Expected: exit status 0 and output showing org-srs is installed or synchronized without errors.

**Step 4: Verify the saved configuration**

Run an Emacs batch command using Doom's environment that requires `org-srs` and checks the four `org-mode-map` bindings.

Expected: exit status 0 and confirmation that each key resolves to its corresponding org-srs rating command.

**Step 5: Commit**

```bash
git add packages.el config.el docs/plans/2026-09-09-org-srs-implementation.md
git commit -m "feat: add org-srs review bindings"
```
