;;; test-config-fonts.el --- Tests for font configuration -*- lexical-binding: t; -*-

(require 'ert)

(defconst my/config-fonts-test-config-file
  (expand-file-name "../config.el" (file-name-directory load-file-name)))

(ert-deftest my/config-uses-comic-code-for-text ()
  "Comic Code is configured for fixed-width and variable-pitch text."
  (with-temp-buffer
    (insert-file-contents my/config-fonts-test-config-file)
    (let ((config (buffer-string)))
      (should (string-match-p
               (regexp-quote
                "doom-font (font-spec :family \"Comic Code\" :size 18)")
               config))
      (should (string-match-p
               (regexp-quote
                "doom-variable-pitch-font (font-spec :family \"Comic Code\" :size 18)")
               config))
      (should (string-match-p
               (regexp-quote
                "doom-symbol-font (font-spec :family \"Symbols Nerd Font Mono\")")
               config))
      (should-not (string-match-p
                   (regexp-quote "(set-fontset-font t 'cyrillic") config)))))

;;; test-config-fonts.el ends here
