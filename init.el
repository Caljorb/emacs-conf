;;; init.el

;; ----------- PACKAGE MANAGEMENT -----------

;; package manager
(setq straight-check-for-modifications nil)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
    (url-retrieve-synchronously
     "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
     'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(defalias 'sup 'straight-use-package)

;; get more packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; --------------- PACKAGES ---------------

;; vertical autocomplete system + files
(sup '(vertico :includes (vertico-directory)))
(vertico-mode)
(define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)

;; add fuzzy autocomplete
(sup 'orderless)
;; completion-category-defaults nil -> use corfu/company defaults
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles partial-completion))))

;; better switch to buffer command
(sup 'consult)
(global-set-key (kbd "C-x b") 'consult-buffer)

;; help menu with C-h
(sup 'which-key)
(which-key-mode)

;; in buffer completion
(sup 'corfu)
(add-hook 'after-init-hook #'global-corfu-mode)

;; enable corfu in terminal
;; press tab to show menu
(sup 'corfu-terminal)
(unless (display-graphic-p) (corfu-terminal-mode +1))
;; (setq corfu-auto t)

;; manual autocompletion w/ orderless
(require 'corfu)
(keymap-set corfu-map "SPC" 'corfu-insert-separator)

;; autocomplete file paths
(sup 'cape)
(add-hook 'completion-at-point-functions #'cape-file)

;; git
;; TODO: learn to use
(sup 'magit)
;; handle diffs in same frame
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; markdown
(sup 'markdown-mode)

;; rust
;; C-c C-c C-k | rust-check | Compile using ‘cargo check‘.
(sup 'rust-mode)

;; color
(sup 'rainbow-mode)
(add-hook 'prog-mode-hook #'rainbow-mode)

;; undo tree
(sup 'undo-tree)
(global-undo-tree-mode)
(setq undo-tree-auto-save-history nil)

;; TODO: setup dashboard w/ agenda
(sup 'dashboard)
(dashboard-setup-startup-hook)
;; (setq dashboard-banner-logo-title "emacs")
(setq dashboard-startup-banner (expand-file-name "bunny.txt" user-emacs-directory))
(setq dashboard-center-content t)
;; (setq dashboard-vertically-center-content t)
(setq dashboard-items '((recents . 5)))
(setq initial-buffer-choice (get-buffer "*dashboard*"))
(setq dashboard-item-names '(("Recent Files:" . "Recent:")))
(setq dashboard-set-footer nil)

;; description of commands
(sup 'marginalia)
(marginalia-mode)

;; more help
(sup 'helpful)

;; highlight todos
(sup 'hl-todo)
(global-hl-todo-mode)

;; syntax checker
(sup 'flycheck)
(global-flycheck-mode +1)

;; flycheck for rust
(sup 'flycheck-rust)
(with-eval-after-load 'rust-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;; required for f
(sup 'dash)

;; package for file handling
(sup 'f)

;; ---------------- THEME ----------------

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;; https://github.com/djcb/dream-theme
;; load theme consistent with pywal colors in terminal
(if (display-graphic-p)
    (load-theme 'dream t)
  (load-theme 'xresources-wal t))

;; ------------ DEFAULT MODES  ------------

;; window layout changes
;; C-c ← to undo, other way to redo
(winner-mode)

;; remember recent commands and files
(savehist-mode)
(save-place-mode)
(recentf-mode)

;; display line numbers
(global-display-line-numbers-mode t)
(column-number-mode t)

;; no tabs, kill whole line
(setq-default kill-whole-line t
              indent-tabs-mode nil)

;; allows indents
;; TODO: does this use tabs or spaces?
(setq tab-always-indent 'complete)

;; add newline at end of file automatically
(setq mode-require-final-newline t)

;; no dialog
(setq use-dialog-box nil)

;; stop b/t capitalization of camelcase
(add-hook 'prog-mode-hook 'subword-mode)
;; TODO: look more into prog-mode

;; match pairs
;; TODO: set conditionally based on mode (bad for elisp)
(electric-pair-mode t)
(setq electric-pair-pairs
      '((?\' . ?\')
        (?\{ . ?\})
        (?\< . ?\>)))

;; start eglot for these modes
(add-hook 'rust-mode-hook 'eglot-ensure)
(add-hook 'python-mode-hook 'eglot-ensure)
(add-hook 'java-mode-hook 'eglot-ensure)
(add-hook 'c-mode-hook 'eglot-ensure)

;; TODO: learn org-mode
;; TODO: look into EWW for emacs web browsing
;; TODO: look into ERC for irc

;; ---------------- MISC ----------------

;; prevent dwm from resizing emacs window
;; https://emacs.stackexchange.com/questions/47639/how-to-make-emacs-work-well-with-tiling-window-managers
(setq frame-resize-pixelwise t)

;; remove tool/menu bars
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(scroll-bar-mode -1)

;; change font for gui mode
(add-to-list 'default-frame-alist
             '(font . "JetBrains Mono-22"))

;; frame title -> expands to buffer name
(setq-default frame-title-format '("emacs: %b"))

;; allows moving windows with Shift-←
(windmove-default-keybindings)

;; move autosave files to tmp
(defconst emacs-tmp-dir
  (expand-file-name (format "emacs-%d" (user-uid)) temporary-file-directory))
(setq backup-directory-alist
      `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,emacs-tmp-dir t)))
(setq auto-save-list-file-prefix
      emacs-tmp-dir)

;; make dir if doesnt exist
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir t)))))

;; balance windows when creating new
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))

(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

;; get local scripts
(add-to-list 'exec-path (concat (getenv "HOME") "~/.local/bin"))

;; shorten yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; -------------- FEATURES --------------

;; M-x ispell: spellcheck
;; Magit
;; C-h for keybind help

;; ---------------- MEOW ----------------

(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; SPC j/k will run the original command in MOTION state.
   '("j" . "H-j")
   '("k" . "H-k")
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(require 'meow)
(meow-setup)
(meow-global-mode 1)
