;;; my-org-srs-grep-prefilter.el --- Narrow Org-SRS searches with grep -*- lexical-binding: t; -*-

;;; Commentary:

;; Org-SRS normally parses every Org file in a directory.  For the Org-roam
;; directory, use grep to find files that contain an Org-SRS item first.

;;; Code:

(defvar org-roam-directory nil)

(defconst my/org-srs--item-marker-regexp
  "^[[:space:]]*#\\+NAME:[[:space:]]*srsitem:"
  "Extended regular expression matching an Org-SRS item marker.")

(defun my/org-srs--grep-supports-include-p ()
  "Return non-nil when grep supports its recursive `--include' option."
  (with-temp-buffer
    (and (zerop (process-file "grep" nil t nil "--help"))
         (string-match-p "--include" (buffer-string)))))

(defun my/org-srs-grep-candidate-files (directory)
  "Return sorted absolute Org files under DIRECTORY containing an SRS item.

The search is recursive and case-insensitive.  A grep exit status of 1 means
that no file matched; every other nonzero status is reported as an error."
  (let* ((directory (expand-file-name directory))
         (grep-supports-include (my/org-srs--grep-supports-include-p))
         (grep-arguments
          (if grep-supports-include
              (list "-r" "-l" "-i" "--include=*.org" "-E"
                    my/org-srs--item-marker-regexp directory)
            ;; BSD grep has no --include.  Give it only recursively
            ;; discovered Org files so it still never scans note assets.
            (append (list "-l" "-i" "-E" my/org-srs--item-marker-regexp)
                    (directory-files-recursively directory "\\.org\\'")))))
    (if (and (not grep-supports-include)
             (= (length grep-arguments) 4))
        nil
      (with-temp-buffer
        (let ((status (apply #'process-file "grep" nil t nil grep-arguments)))
          (cond
           ((zerop status)
            (sort
             (delete-dups
              (mapcar #'expand-file-name
                      (split-string (buffer-string) "\n" t)))
             #'string-lessp))
           ((= status 1) nil)
           (t (error "grep failed while searching Org-SRS candidates (exit %s)"
                     status))))))))

(defun my/org-srs-query-directory-with-grep-prefilter
    (original-function query-predicate &optional directory &rest args)
  "Use grep candidates for DIRECTORY when it is `org-roam-directory'."
  (if (and (boundp 'org-roam-directory)
           org-roam-directory
           (file-equal-p directory org-roam-directory))
      (apply #'append
             (mapcar (lambda (file)
                       (org-srs-query-file query-predicate file))
                     (my/org-srs-grep-candidate-files directory)))
    (apply original-function query-predicate directory args)))

(when (fboundp 'org-srs-query-directory)
  (advice-add 'org-srs-query-directory :around
              #'my/org-srs-query-directory-with-grep-prefilter))

(provide 'my-org-srs-grep-prefilter)
;;; my-org-srs-grep-prefilter.el ends here
