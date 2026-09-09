;;; test-org-srs-grep-prefilter.el --- Tests for Org-SRS grep prefilter -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defmacro my/org-srs-test-with-fixture-tree (&rest body)
  "Run BODY with a temporary Org-roam-like fixture tree."
  (declare (indent 0) (debug t))
  `(let ((fixture-directory (make-temp-file "org-srs-grep-prefilter-" t)))
     (unwind-protect
         (let ((has-card (expand-file-name "has-card.org" fixture-directory))
               (no-card (expand-file-name "no-card.org" fixture-directory))
               (asset (expand-file-name "asset.txt" fixture-directory)))
           (with-temp-file has-card
             (insert "#+title: Card note\n#+NAME: srsitem:example\n"))
           (with-temp-file no-card
             (insert "#+title: Ordinary note\n"))
           (with-temp-file asset
             (insert "#+NAME: srsitem:not-an-org-card\n"))
           ,@body)
       (delete-directory fixture-directory t))))

(ert-deftest my/org-srs-grep-candidate-files-finds-only-org-files-with-cards ()
  "The grep prefilter returns only Org files containing an Org-SRS marker."
  (my/org-srs-test-with-fixture-tree
    (should (equal (my/org-srs-grep-candidate-files fixture-directory)
                   (list has-card)))))

(ert-deftest my/org-srs-directory-query-prefilters-only-org-roam-directory ()
  "The directory advice narrows Org-roam queries and preserves other scopes."
  (my/org-srs-test-with-fixture-tree
    (let ((org-roam-directory fixture-directory)
          (file-calls nil)
          (original-calls nil))
      (cl-letf (((symbol-function 'org-srs-query-file)
                 (lambda (file &rest _args)
                   (push file file-calls)
                   (list file))))
        (let ((original-directory-query
               (lambda (&rest args)
                 (push args original-calls)
                 'original-result)))
          (should (equal
                   (my/org-srs-query-directory-with-grep-prefilter
                    original-directory-query fixture-directory)
                   (list has-card)))
          (should (equal file-calls (list has-card)))
          (should-not original-calls)
          (setq file-calls nil)
          (let ((outside-directory (make-temp-file "org-srs-outside-" t)))
            (unwind-protect
                (progn
                  (should (eq
                           (my/org-srs-query-directory-with-grep-prefilter
                            original-directory-query outside-directory 'extra)
                           'original-result))
                  (should-not file-calls)
                  (should (equal original-calls
                                 (list (list outside-directory 'extra)))))
              (delete-directory outside-directory t))))))))

;;; test-org-srs-grep-prefilter.el ends here
