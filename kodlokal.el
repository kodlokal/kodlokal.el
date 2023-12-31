;;; kodlokal.el --- Kodlokal AI client for emacs
;;; Commentary:
;;    See https://github.com/kodlokal/kodlokal.el
;;    Server https://github.com/kodlokal/kodlokal
;;    Alper Akgun
;;; Code:

(require 'json)
(require 'url)

(defun kodlokal-build-query ()
  "Return word query."
  (replace-regexp-in-string "\n\\'"
                            ""
                            (thing-at-point 'line t)))

(defun kodlokal-code-content ()
  "Return completion content."

  (replace-regexp-in-string "\n\\'"
                            ""
                            (buffer-substring (point-min) (point))))

(defun kodlokal-build-data (content model)
  "Build data input from CONTENT and MODEL."

  `((prompt . ,content) (model . ,model)))

(defun kodlokal-fetch-suggestions-url (query content model)
  "Fetch suggestions for QUERY, CONTENT and MODEL synchronously."

  (let* (
         (data (kodlokal-build-data content model))
         (url-request-method "POST")
         (url-request-extra-headers '(("Content-Type" . "application/json")))
         (url-request-data (json-encode data))
         (url-show-status nil))
    (with-current-buffer
        (url-retrieve-synchronously "http://localhost:3737/v1/completions" :timeout 7)
      (set-buffer-multibyte t)
      (goto-char (point-min))
      (re-search-forward "\n\n")
      (let* (
             (response (buffer-substring-no-properties (point) (point-max)))
             (json-response (json-read-from-string response))
             (completion-text (cdr (assoc 'text (aref (cdr (assoc 'choices json-response)) 0))))
             (query-completion (if (equal model "code")
                                   (concat query completion-text)
                                 (concat "" completion-text))))
        (list query-completion)))))


(defun kodlokal-fetch-suggestions (query content model)
  "Call fetch suggestions for QUERY and CONTENT for MODEL."

  (ignore-errors
    (unless (and
             (stringp content)
             (stringp query)
             (>= (length content) 3)
             (>= (length query) 3))
      (throw 'exit 1))
    (while-no-input (kodlokal-fetch-suggestions-url query content model))))

(defun kodlokal-completion-at-point ()
  "Complete at point."
  (interactive)

  (let* (
         (start (line-beginning-position))
         (end (line-end-position)))
    (list start end
          (completion-table-with-cache
           (lambda (_)
             (let ((result
                    (kodlokal-fetch-suggestions (kodlokal-build-query) (kodlokal-code-content) "code")))
               (and (consp result) result))))
          :exclusive 'no)))


;;; MODULE TEXT FETCH

(defun kodlokal-text-content ()
  "Get the text of the currently selected region as a string."

  (let (
        (start  (if (use-region-p) (region-beginning) (point-min)))
        (end  (if (use-region-p) (region-end) (point))))
    (encode-coding-string
     (replace-regexp-in-string "\n\\'" ""
                               (buffer-substring-no-properties start end)) 'utf-8)))

(defun kodlokal-fetch-callback (status)
  "Insert the retrieved data with STATUS into the current buffer."

  (unless (plist-get status :error)
    (set-buffer-multibyte t)
    (goto-char (point-min))
    (re-search-forward "\n\n")

    (let*
        ((response (buffer-substring-no-properties (point) (point-max)))
         (json-response (json-read-from-string response))
         (completion-text (cdr (assoc 'text (aref (cdr (assoc 'choices json-response)) 0)))))

      (with-current-buffer (window-buffer (selected-window))
        (insert completion-text)))
    (kill-buffer)
    ))

(defun kodlokal-fetch-suggestions-url-async (content model)
  "Fetch suggestions for CONTENT and MODEL asynchronously."

  (let* (
         (data (kodlokal-build-data content model))
         (url-request-method "POST")
         (url-request-extra-headers '(("Content-Type" . "application/json")))
         (url-request-data (json-encode data))
         (url-show-status nil))

    (url-retrieve "http://localhost:3737/v1/completions" 'kodlokal-fetch-callback)))

(defun kodlokal-fetch-suggestions-async (content model)
  "Call fetch suggestions for CONTENT for MODEL."

  (if (and
       (stringp content)
       (>= (length content) 3))
      (kodlokal-fetch-suggestions-url-async content model)
    (print "No input...")))


(defun kodlokal-ai-completion ()
  "AI completion for the active region or the full buffer."

  (interactive)
  (kodlokal-fetch-suggestions-async (kodlokal-text-content) "text"))

(provide 'kodlokal)
;;; kodlokal.el ends here
