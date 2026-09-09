;;; test-config-fonts.el --- Tests for font configuration -*- lexical-binding: t; -*-

(require 'ert)

(defconst my/config-fonts-test-config-file
  (expand-file-name "../config.el" (file-name-directory load-file-name)))

(ert-deftest my/config-uses-source-code-pro-for-cyrillic-fallback ()
  "The configured Cyrillic fallback is explicitly monospaced."
  (with-temp-buffer
    (insert-file-contents my/config-fonts-test-config-file)
    (should (string-match-p
             (regexp-quote
              "(set-fontset-font t 'cyrillic (font-spec :family \"Source Code Pro\"))")
             (buffer-string)))))

;;; test-config-fonts.el ends here
