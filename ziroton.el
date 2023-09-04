;;; ziroton.el --- ziroton client for emacs
;;; Commentary:
;;; Code:

(require 'json)
(require 'url)

(defun ziroton-build-query ()
    "Return word query"
  (replace-regexp-in-string "\n\\'"
                            ""
                            (thing-at-point 'line t)))

(defun ziroton-build-content ()
    "Return completion content"
    (replace-regexp-in-string "\n\\'"
                              ""
                              (buffer-substring (point-min) (point))))

(defun ziroton-fetch-suggestions-url (query content)
 "Fetch suggestions for QUERY."

  (let* (
        (data `((prompt . ,content)))
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
             (query-completion (concat query completion-text)))
          (list query-completion)))))

(defun ziroton-fetch-suggestions (query content)
  "Call fetch suggestions for QUERY."

  (ignore-errors
    (unless (and
             (stringp content)
             (stringp query)
             (> (length content) 3)
             (> (length query) 3))
      (throw 'exit))
      (while-no-input (ziroton-fetch-suggestions-url query content))))

(defun ziroton-completion-at-point ()
  "AI generated responses."

  (interactive)
  (let* (
         (start (line-beginning-position))
         (end (line-end-position)))
    (list start end
      (completion-table-with-cache
        (lambda (_)
          (let ((result
             (ziroton-fetch-suggestions (ziroton-build-query) (ziroton-build-content))))
          (and (consp result) result))))
      :exclusive 'no)))


(provide 'ziroton)
;; ziroton.el ends here
