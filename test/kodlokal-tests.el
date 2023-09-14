(load "kodlokal")

(ert-deftest test-kodlokal-build-query ()
  "Test the kodlokal-build-query function."
  (with-temp-buffer
    (insert "This is a test query.\n")
    (goto-char (point-min))
    (should (equal (kodlokal-build-query) "This is a test query.")))

  (with-temp-buffer
    (insert "Another query without a newline.")
    (goto-char (point-min))
    (should (equal (kodlokal-build-query) "Another query without a newline."))))

(ert-deftest test-kodlokal-code-content ()
  "Test the kodlokal-code-content function."
  (with-temp-buffer
    (insert "This is some sample content.")
    (goto-char (point-max))
    (should (equal (kodlokal-code-content) "This is some sample content.")))

  (with-temp-buffer
    (insert "Another line of content.\nLine 2.\nLine 3.")
    (goto-char (point-max))
    (should (equal (kodlokal-code-content) "Another line of content.\nLine 2.\nLine 3.")))

  (with-temp-buffer
    (insert "Single line content without a newline.")
    (goto-char (point-max))
    (should (equal (kodlokal-code-content) "Single line content without a newline."))))

(ert-deftest test-kodlokal-build-data ()
  "Test the kodlokal-build-data function."
  (should (equal (kodlokal-build-data "Sample prompt" "Sample model")
                 '((prompt . "Sample prompt") (model . "Sample model"))))

  (should (equal (kodlokal-build-data "Another prompt" "Another model")
                 '((prompt . "Another prompt") (model . "Another model"))))

  (should (equal (kodlokal-build-data "Prompt with\nnewlines" "Model with\nnewlines")
                 '((prompt . "Prompt with\nnewlines") (model . "Model with\nnewlines")))))



(ert-deftest test-kodlokal-text-content ()
  "Test the kodlokal-text-content function."
  (with-temp-buffer
    (insert "This is some selected text.")
    (goto-char (point-min))
    (set-mark (point-min))
    (goto-char (point-max))
    (setq mark-active t)
    (should (equal (kodlokal-text-content) "This is some selected text.")))

  (with-temp-buffer
    (insert "Selected text without a newline.")
    (goto-char (point-min))
    (set-mark (point-min))
    (goto-char (point-max))
    (setq mark-active t)
    (should (equal (kodlokal-text-content) "Selected text without a newline."))))


(ert-deftest test-kodlokal-ai-completion ()
  "Test the kodlokal-ai-completion function."
  (with-temp-buffer
    (insert "This is some sample text.")
    (goto-char (point-min))
    (set-mark (point-min))
    (goto-char (point-max))
    (setq mark-active t)
    (should (equal (buffer-string) "This is some sample text."))

    ;; Mock kodlokal-fetch-suggestions to return suggestions
    (cl-letf (((symbol-function 'kodlokal-fetch-suggestions)
                (lambda (prompt content model)
                  (list "Suggestion 1" "Suggestion 2"))))
      (kodlokal-ai-completion)
      (should (equal (buffer-string) "This is some sample text.Suggestion 1")))))
