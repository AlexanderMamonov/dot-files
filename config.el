;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "ComicShannsMono Nerd Font" :size 18)
      doom-variable-pitch-font (font-spec :family "ComicShannsMono Nerd Font" :size 18)
      doom-symbol-font (font-spec :family "Symbols Nerd Font Mono"))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-solarized-light)

;; Start Emacs fullscreen
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory (file-truename "~/Documents/Notes/"))
(setq org-roam-directory (file-truename "~/Documents/Notes/pages/"))

(after! org
  ;; Only include org files that contain TODO keywords (much faster with many files)
  (defun my/org-agenda-files-with-todos ()
    "Return list of org files containing TODO keywords, excluding bak/."
    (let ((default-directory org-directory))
      (split-string
       (shell-command-to-string
        "grep -rl --include='*.org' -E '^\\*+.*(TODO|WAIT)' . 2>/dev/null | grep -v '/bak/'")
       "\n" t)))
  (setq org-agenda-files (my/org-agenda-files-with-todos))

  ;; Make sure Org uses variable pitch (proportional) font
  (add-hook 'org-mode-hook 'variable-pitch-mode)

  ;; Set font sizes for each heading level
  (custom-set-faces!
    '(org-level-1 :inherit outline-1 :height 1.4)
    '(org-level-2 :inherit outline-2 :height 1.3)
    '(org-level-3 :inherit outline-3 :height 1.2)
    '(org-level-4 :inherit outline-4 :height 1.1)
    '(org-level-5 :inherit outline-5 :height 1.05)
    '(org-level-6 :inherit outline-6 :height 1.0)
    '(org-document-title :height 1.5 :weight bold)))


(after! org-roam
  (setq org-roam-file-exclude-regexp
        (regexp-opt '("/logseq/" "/assets/" "/bak/")))
  ;; Use slug-only filenames
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)))

  ;; Add :CREATED: property when creating new nodes (only if not already set)
  (add-hook 'org-roam-capture-new-node-hook
            (lambda ()
              (unless (org-entry-get nil "CREATED")
                (org-set-property "CREATED" (format-time-string "%Y%m%d%H%M"))))))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;; it seems for me this command actually replaces existing bindings instead of adding new one
(map! :leader
      "SPC" #'execute-extended-command
      "g h" #'org-roam-dailies-goto-today
      "k" #'org-roam-node-find)

;; Clipboard integration for terminal mode (macOS)
(unless (display-graphic-p)
  (defun my/copy-to-clipboard (text &optional _push)
    (let ((process-connection-type nil))
      (let ((proc (start-process "pbcopy" nil "pbcopy")))
        (process-send-string proc text)
        (process-send-eof proc))))
  (defun my/paste-from-clipboard ()
    (shell-command-to-string "pbpaste"))
  (setq interprogram-cut-function #'my/copy-to-clipboard)
  (setq interprogram-paste-function #'my/paste-from-clipboard))

;; Auto-save org-roam files
(defun my/auto-save-org-roam ()
  "Save current buffer if it's an org-roam file."
  (when (and (buffer-file-name)
             (string-prefix-p (expand-file-name org-directory) (buffer-file-name))
             (derived-mode-p 'org-mode)
             (buffer-modified-p))
    (save-buffer)))

;; Save when exiting insert mode
(add-hook 'evil-insert-state-exit-hook #'my/auto-save-org-roam)
;; Save when switching buffers
(add-hook 'doom-switch-buffer-hook #'my/auto-save-org-roam)
;; Save when Emacs loses focus
(add-hook 'focus-out-hook #'my/auto-save-org-roam)

;; Auto-commit org-roam every 5 minutes
(defun my/auto-commit-org-roam ()
  "Automatically commit changes in org-directory."
  (let ((default-directory org-directory))
    (when (and (file-exists-p (expand-file-name ".git" org-directory))
               (not (string-empty-p (shell-command-to-string "git status --porcelain"))))
      (shell-command "git add -A && git commit -m 'Auto-commit from Emacs'"))))

(run-with-timer 300 300 #'my/auto-commit-org-roam)
