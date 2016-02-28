(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(load-theme 'wombat 1)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(require 'glsl-mode)

;C/C++ AutoCompletion
;===============================================================
(require 'irony)
(require 'company)
(require 'company-irony)
(add-hook 'after-init-hook 'global-company-mode)
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))

(defun twiebs-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))

(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'irony-mode-hook 'twiebs-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
;================================================================

(require 'grizzl)
(require 'projectile)
(projectile-global-mode)
(setq projectile-completion-system 'grizzl)

(load "/usr/share/clang/clang-format.el")

(require 'evil)
(evil-mode 1)
(setq evil-shift-width 4)

(define-key evil-insert-state-map (kbd "S-SPC") 'evil-normal-state)
(define-key evil-normal-state-map (kbd "C-p") 'projectile-find-file)
(define-key evil-normal-state-map (kbd "S-f") 'clang-format-region)
(define-key evil-visual-state-map (kbd "S-f") 'clang-format-region)
