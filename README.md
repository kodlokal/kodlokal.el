## Kodlokal

Kodlokal; local code completion using LLM AI

## Install

### straight.el

```elisp
(straight-use-package '(kodlokal :type git :host github :repo "alperakgun/kodlokal.el"))
```

### Doom Emacs
In `packages.el` add the following:
```elisp
(package! kodlokal :recipe (:host github :repo "alperakgun/kodlokal.el"))
```
Add the example configuration to your `config.el` file.


### Install

Run the following.

```bash
git clone https://github.com/kodlokal/kodlokal.el.git ~/.emacs.d/kodlokal.el
```

Add the following to your `~/.emacs.d/init.el` file.

```lisp
(add-to-list 'load-path "~/.emacs.d/kodlokal.el")

(use-package kodlokal
  :init
  (add-to-list 'completion-at-point-functions #'kodlokal-completion-at-point)
  :config
  (setq use-dialog-box nil))
```

That will be a nice company mode configuration.
```
(use-package company
  :defer 0.1
  :config
  (global-company-mode t)
  (setq-default
   company-idle-delay 0.900
   company-require-match nil
   company-minimum-prefix-length 3
   company-frontends '(company-preview-frontend)
   ))
;; init.el ends here
```

Company mode allows you to cycle
```
(global-set-key (kbd "s-/") 'company-complete-common-or-cycle)
```
