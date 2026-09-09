;;; my-org-srs-grep-prefilter.el --- Narrow Org-SRS searches with grep -*- lexical-binding: t; -*-

;;; Commentary:

;; Org-SRS normally parses every Org file in a directory.  For the Org-roam
;; directory, use grep to find files that contain an Org-SRS item first.

;;; Code:

(require 'seq)

(defvar org-roam-directory nil)

(defconst my/org-srs--item-marker-regexp "^#\\+NAME: srsitem:"
  "Extended regular expression matching an Org-SRS item marker.")

(defun my/org-srs-grep-candidate-files (directory)
  "Return sorted absolute Org files under DIRECTORY containing an SRS item.

The search is recursive and case-insensitive.  A grep exit status of 1 means
that no file matched; every other nonzero status is reported as an error."
  (let ((directory (expand-file-name directory)))
    (with-temp-buffer
      (let ((status (process-file "grep" nil t nil
                                  "-r" "-l" "-i" "-E"
                                  my/org-srs--item-marker-regexp directory)))
        (cond
         ((zerop status)
          (sort
           (delete-dups
            (mapcar #'expand-file-name
                    (seq-filter
                     (lambda (file) (string= (file-name-extension file) "org"))
                     (split-string (buffer-string) "\n" t))))
           #'string-lessp))
         ((= status 1) nil)
         (t (error "grep failed while searching Org-SRS candidates (exit %s)"
                   status)))))))

(defun my/org-srs-query-directory-with-grep-prefilter
    (original-function directory query-predicate &rest args)
  "Use grep candidates for DIRECTORY when it is `org-roam-directory'."
  (if (and (boundp 'org-roam-directory)
           org-roam-directory
           (file-equal-p directory org-roam-directory))
      (apply #'append
             (mapcar (lambda (file)
                       (org-srs-query-file file query-predicate))
                     (my/org-srs-grep-candidate-files directory)))
    (apply original-function directory query-predicate args)))

(when (fboundp 'org-srs-query-directory)
  (advice-add 'org-srs-query-directory :around
              #'my/org-srs-query-directory-with-grep-prefilter))

(provide 'my-org-srs-grep-prefilter)
;;; my-org-srs-grep-prefilter.el ends here
