;GUI Config
;========================================
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(load-theme 'wombat 1)


;Not fucked up indentation
(setq c-default-style "linux"
      c-basic-offset 4)
(setq c++-tab-always-indent t)
(setq c-basic-offset 4)
(setq c-indent-level 4)
(setq tab-stop-list (number-sequence 4 120 4))
(setq tab-width 4)
(setq-default indent-tabs-mode nil)

;(require 'aggressive-indent)
(add-hook 'c++-mode-hook #'aggressive-indent-mode)

;(add-to-list
; 'aggressive-indent-dont-indent-if
; '(and (derived-mode-p 'c++-mode)
;       (null (string-match "\\([;{}]\\|\\b\\(if\\|for\\|while\\)\\b\\)"
;                           (thing-at-point 'line)))))

(setq make-backup-files nil)
(setq backup-inhibited 1)
(setq-default truncate-lines t)
(global-auto-revert-mode t)
;=======================================

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(require 'glsl-mode)

;C/C++ AutoCompletion, Compilation
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

(setq company-idle-delay 0)
;================================================================

(require 'grizzl)
(require 'projectile)
(projectile-global-mode)
(setq projectile-completion-system 'grizzl)
(setq projectile-indexing-method 'native)
(setq projectile-require-project-root nil)
(setq projectile-enable-caching 1)

(load "/usr/share/clang/clang-format.el")

(require 'compile)
(setq compile-command "sh build.sh")

(defun twiebs-compile-project ()
  (interactive)
  (compile "sh build.sh"))

(defun twiebs-compile-mode-hook ()
  (make-local-variable 'truncate-lines)
  (setq truncate-lines nil))

(add-hook 'compilation-mode-hook 'twiebs-compile-mode-hook)
(global-set-key (kbd "C-p") 'projectile-find-file)


;Vim Evil Mode
;===============================================
(require 'evil)
(evil-mode 1)

(setq evil-shift-width 4)


(define-key evil-insert-state-map (kbd "S-SPC") 'evil-normal-state)
(define-key evil-normal-state-map (kbd "C-p") 'projectile-find-file)
(define-key evil-normal-state-map (kbd "S-f") 'clang-format-region)
(define-key evil-visual-state-map (kbd "S-f") 'clang-format-region)

(define-key evil-normal-state-map (kbd "<f5>") 'twiebs-compile-project)

(defvar gud-overlay
(let* ((ov (make-overlay (point-min) (point-min))))
(overlay-put ov 'face 'secondary-selection)
ov)
"Overlay variable for GUD highlighting.")

(defadvice gud-display-line (after my-gud-highlight act)
"Highlight current line."
(let* ((ov gud-overlay)
(bf (gud-find-file true-file)))
(save-excursion
  (set-buffer bf)
  (move-overlay ov (line-beginning-position) (line-end-position)
  (current-buffer)))))

(defun gud-kill-buffer ()
(if (eq major-mode 'gud-mode)
	(delete-overlay gud-overlay)))

  

(add-hook 'kill-buffer-hook 'gud-kill-buffer)

;Extra Syntax Highlighting
;=============================================================================

(setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-study-face)
(make-face 'font-lock-important-face)
(make-face 'font-lock-note-face)
(mapc (lambda (mode)
(font-lock-add-keywords
	mode
	'(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
	("\\<\\(STUDY\\)" 1 'font-lock-study-face t)
	("\\<\\(IMPORTANT\\)" 1 'font-lock-important-face t)
		("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))
fixme-modes)
(modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
(modify-face 'font-lock-study-face "Yellow" nil nil t nil t nil nil)
(modify-face 'font-lock-important-face "Yellow" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)


(defun my-c-mode-font-lock-if0 (limit)
(save-restriction
(widen)
(save-excursion
(goto-char (point-min))
(let ((depth 0) str start start-depth)
(while (re-search-forward "^\\s-*#\\s-*\\(if\\|else\\|endif\\)" limit 'move)
(setq str (match-string 1))
(if (string= str "if")
	(progn
	(setq depth (1+ depth))
	(when (and (null start) (looking-at "\\s-+0"))
		(setq start (match-end 0)
			start-depth depth)))
(when (and start (= depth start-depth))
	(c-put-font-lock-face start (match-beginning 0) 'font-lock-comment-face)
	(setq start nil))
	(when (string= str "endif")
		(setq depth (1- depth)))))
(when (and start (> depth 0))
	(c-put-font-lock-face start (point) 'font-lock-comment-face)))))
nil)

(defun my-c-mode-common-hook ()
(font-lock-add-keywords
nil
'((my-c-mode-font-lock-if0 (0 font-lock-comment-face prepend))) 'add-to-end))

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
;==================================================================
;GDB
(define-key evil-normal-state-map (kbd "<f6>") 'gud-break)
(define-key evil-normal-state-map (kbd "<f7>") 'gud-until)
(define-key evil-normal-state-map (kbd "<f9>") 'gud-watch)
;(define-key evil-normal-state-map (kbd "<f10>") 'gud-next)
(define-key evil-normal-state-map (kbd "<f11>") 'gud-step)

; Twiebs GDB Mode
(defvar twiebs-gdb-active nil)

(defun twiebs-gdb-next ()
  (interactive)
  (gud-call "next"))

(defun twiebs-gdb-start ()
  (interactive)
  (setq twiebs-gdb-active t)
  (gdb))
  
(defun twiebs-gdb-execute-to-here ()
  (interactive)
  (if (not twiebs-gdb-active)
	(twiebs-gdb-start)	
	;(gud-call "break main")	
										;(gud-call "run")))
	)
  )
	  
 
  

(global-set-key (kbd "<f10>") 'twiebs-gdb-next)
(global-set-key (kbd "C-<f6>") 'twiebs-gdb-execute-to-here)

(setq gud-tooltip-mode t)
(setq tooltip-delay 0)
(setq tooltip-short-delay 0)

(custom-set-faces
;; custom-set-faces was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.
'(company-tooltip ((t (:background "dim gray" :foreground "orange red")))))
