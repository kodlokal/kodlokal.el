;;; kodlokal.el --- kodlokal client for emacs
;;; Commentary:
;;; Code:

;; (require 'json)
(require 'url)

(defun kodlokal-build-query ()
    "Return word query"
  (replace-regexp-in-string "\n\\'"
                            ""
                            (thing-at-point 'line t)))

(defun kodlokal-build-content ()
    "Return completion content"
    (replace-regexp-in-string "\n\\'"
                              ""
                              (buffer-substring (point-min) (point))))

(defun kodlokal-fetch-suggestions-url (query content)
 "Fetch suggestions for QUERY."
  (let* (
        (data `((q . ,content)))
        (url-request-method "POST")
        (url-request-extra-headers '(("Content-Type" . "application/json")))
        (url-request-data (json-encode data))
        (url-show-status nil))
    (with-current-buffer
        (url-retrieve-synchronously "http://localhost:3737/code/completions" :timeout 7)
      (set-buffer-multibyte t)
      (goto-char (point-min))
      (re-search-forward "\n\n")
      (let* (
             (response (buffer-substring-no-properties (point) (point-max)))
             (query-body (concat query response)))
          (list query-body)))))

(defun kodlokal-fetch-suggestions (query content)
  "Call fetch suggestions for QUERY."
  (ignore-errors
    (unless (and
             (stringp content)
             (stringp query)
             (> (length content) 3)
             (> (length query) 3))
      (throw 'exit))
      (while-no-input (kodlokal-fetch-suggestions-url query content))))

(defun kodlokal-completion-at-point ()
  "AI generated responses."
  (interactive)
  (let* (
         (start (line-beginning-position))
         (end (line-end-position)))
    (list start end
      (completion-table-with-cache
        (lambda (_)
          (let ((result
             (kodlokal-fetch-suggestions (kodlokal-build-query) (kodlokal-build-content))))
          (and (consp result) result))))
      :exclusive 'no)))


(provide 'kodlokal)
;; kodlokal.el ends here
