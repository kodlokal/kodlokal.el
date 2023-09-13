## Kodlokal

Kodlokal; local code completion using LLM AI

## Install

First go, install and run https://github.com/kodlokal/kodlokal

### Git

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
```lisp
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

### straight.el (not tested)

```lisp
(straight-use-package '(kodlokal :type git :host github :repo "alperakgun/kodlokal.el"))
```

### Doom Emacs  (not tested)

In `packages.el` add the following:

```lisp
(package! kodlokal :recipe (:host github :repo "alperakgun/kodlokal.el"))
```
Add the example configuration to your `config.el` file.


## AI Assistant

Hydra can allow multiple prompt libraries to be used for

```lisp
(defhydra hydra-ai (:color yellow
                                   :hint nil)
  "----------------------------Kodlokal AI Assistan --------------------
 i: Complete text
"
  ("i"  kodlokal-ai-completion)
  ("q"   nil "cancel" :color blue))

(define-key projectile-mode-map  (kbd "s-z") 'hydra-ai/body)
```
