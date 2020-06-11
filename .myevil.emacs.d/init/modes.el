;;; modes.el -*- lexical-binding: t; -*-
;;

;;
;; help mode
;;

(use-package help-mode
  :pin manual
  :defer t

  ;; Fix a bug where use-package tries to find help-mode in melpa even with :pin manual !?
  :ensure nil

  :bind (:map help-mode-map
              ("j" . help-go-back)
              ("l" . help-go-forward)
              ("C-c j" . help-go-back)
              ("C-c l" . help-go-forward)
              )
  )

;;
;; recentf
;;

(use-package recentf
  :pin manual
  :demand t
  :hook (dired-mode . recentf-add-dired-directory)
  :config

  ;; ;; elp-results
  ;; (elp-instrument-package "recentf")
  ;; (elp-instrument-function 'abbreviate-file-name)

  (setq-default
   ;; Max recent files entries
   recentf-max-saved-items 1000

   ;; Stat all files to remove deleted ones (recentf-cleanup)
   ;;recentf-auto-cleanup 60 ;; after N seconds
   recentf-auto-cleanup 'never

   ;; Fix slow recentf-mode startup (0.60s to 0.06s):
   ;; Initializing `file-name-history` is slow only when there are tramp files
   ;; (eg "/sudo:") (seems to come from abbreviate-file-name !?).
   recentf-initialize-file-name-history nil

   recentf-save-file (concat user-emacs-directory "recentf")

   )

  ;; Recentf prints "Loading ... recentf...", which triggers the
  ;; window/modeline/etc... drawing etc before we have the chance to setup
  ;; theme, which make everything flicker at startup. So we use
  ;; window-setup-hook to defer it.
  ;;
  ;; Note: `emacs -q -l /.../init.el' makes modeline flicker too.
  ;;
  (add-hook 'window-setup-hook (lambda () (recentf-mode 1)))

  ;; https://www.emacswiki.org/emacs/recentf-ext.el
  (defun recentf-add-dired-directory ()
    (when (and (stringp dired-directory)
               (equal "" (file-name-nondirectory dired-directory)))
      (recentf-add-file dired-directory)))
)

(use-package sync-recentf
  :load-path (my-packages-directory "sync-recentf")
  :demand t
  )

;;
;; undo-tree
;;

(use-package undo-tree
  :load-path (my-packages-directory "undo-tree")
  :demand t
  :config
  (global-undo-tree-mode)
  )

;;
;; isearch
;;

;; https://emacs.stackexchange.com/questions/525/delete-some-matches-of-an-incremental-search
(defun isearch-kill-current ()
  (interactive)
  (delete-region isearch-other-end (point))
  (isearch-exit)
  )

(bind-keys
 :map isearch-mode-map
 ("<backspace>" . isearch-kill-current)
 ("C-<backspace>" . isearch-del-char)
 )

;; FIXME:
;;(use-package isearch
;;  :bind-keymap
;;  (:map isearch-mode-map
;;        ("C-<backspace>" . isearch-del-char))
;;  )

;;
;; history (per-window location history stack)
;;   https://github.com/boyw165/history
;;   https://www.emacswiki.org/emacs/MarkCommands
;;
;; @TODO: duplicate history's window-parameters on split-window etc...
;;

(use-package history
  :load-path (my-packages-directory "history")
  :disabled t ;; replaced by better-jumper ?
  :demand t
  :bind (("C-c j" . history-prev-history)
         ("C-c M-j" . history-goto-history)
         ("C-c l" . history-next-history)
         )
  :config
  ;;(require 'history)

  (defun add-to-history-advised (funclist)
    (dolist (f funclist)
      (add-to-list 'history-advised-before-functions f)
      (add-to-list 'history-advised-after-functions f)
    ))

  (add-to-history-advised
   '(
     rtags-find-symbol-at-point     ;; rtags
     godef-jump                     ;; go-mode
     racer-find-definition          ;; racer-mode (rust-mode)
     ace-jump-line-mode             ;; ace-jump
     ))

  ;; helm
  (add-hook 'helm-goto-line-before-hook (lambda () (history-add-history)))
  (add-to-list 'history-advised-after-functions 'helm-occur t)

  ;; isearch
  (add-to-list 'history-advised-before-functions 'isearch-forward)
  (add-to-list 'history-advised-before-functions 'isearch-backward)

  (setq-default history-window-local-history t)
  (history-mode 1)
)

;;
;; better-jumper
;;

(use-package better-jumper
  :load-path (my-packages-directory "better-jumper")
  ;; :disabled t
  :after evil
  :demand t
  :bind (
         :map evil-normal-state-map
         ("C-o" . better-jumper-jump-backward)
         ("C-i" . better-jumper-jump-forward)
         )
  :config
  (setq
   better-jumper-use-evil-jump-advice t

   ;; Save history per window
   better-jumper-context 'window
   better-jumper-new-window-behavior 'copy
   )
  (better-jumper-mode 1)
)

;;
;; savehist
;;   save minibuffer history
;;

(use-package savehist
  :pin manual
  :demand t
  :config
  ;; Save minibuffer history for compile
  ;;(setq-default savehist-additional-variables '(compile-command))
  (savehist-mode 1)
  )

;;
;; ido
;;

(use-package ido
  :pin manual
  :disabled
  ;;:demand t
  :defer t
  :bind (("C-x C-f" . ido-find-file))
  :hook (ido-minibuffer-setup . (lambda ()
                                  (unbind-key "C-<backspace>" ido-completion-map)
                                  (unbind-key "M-<backspace>" ido-completion-map)
                                  (unbind-key "C-<delete>" ido-completion-map)
                                  (unbind-key "M-<delete>" ido-completion-map)
                                  ))
  :config
  (setq-default
   ido-enable-flex-matching t
   ido-auto-merge-work-directories-length -1
   ido-create-new-buffer 'always
   ido-default-buffer-method 'selected-window
   ido-max-prospects 32
   ;;ido-case-fold nil ; case sensitive
   ido-case-fold t ; case sensitive
   ;; ido-use-filename-at-point 'guess
   )

  (setq-default ido-everywhere t)
  (ido-mode 1)
  )

;;
;; TEST: complete with dabbrev
;;
(defun dabbrev-complation-at-point ()
  (require 'dabbrev)
  (dabbrev--reset-global-variables)
  (let* ((abbrev (dabbrev--abbrev-at-point))
         (candidates (dabbrev--find-all-expansions abbrev t))
         (bnd (bounds-of-thing-at-point 'symbol)))
    (list (car bnd) (cdr bnd) candidates)))
(add-hook 'prog-mode-hook
          (lambda ()
            (add-to-list 'completion-at-point-functions 'dabbrev-complation-at-point)
            ))

;;
;; expand region
;;

(use-package expand-region
  :load-path (my-packages-directory "expand-region")
  :bind* ("C-=" . er/expand-region)
  )

;;
;; grep and wgrep
;;   write in grep buffers C-c C-p
;;

(use-package grep
  :pin manual
  :defer t
  :config
  (setq-default
   grep-command "grep --color --exclude-dir=\".[^.]*\" -IHnr -e "
   grep-find-command '("find . -type f -name \"**\" -exec grep --color -IHn -e  \\{\\} +" . 54)
   )
  )

;; @FIXME why wgrep gets loaded when helm is loaded (eg on M-x)

(use-package wgrep
  :load-path (my-packages-directory "wgrep")
  :commands (wgrep-change-to-wgrep-mode)
  )

(use-package wgrep-helm
  :load-path (my-packages-directory "wgrep")
  :if my--helm-or-ivy
  :commands (wgrep-change-to-wgrep-mode)
  )

;;
;; dired and dired-k
;;   https://github.com/hlissner/doom-emacs/blob/master/modules/tools/dired/config.el
;;

(setq-default
   ;; Auto refresh dired, but be quiet about it
   global-auto-revert-non-file-buffers t
   ;; Add human
   dired-listing-switches "-alh"
   dired-k-human-readable t
   dired-k-style 'git
   )

;; https://www.emacswiki.org/emacs/dired-sort.el
(defun dired-sort-size ()
  "Dired sort by size."
  (interactive)
  (dired-sort-other (concat dired-listing-switches "S")))
(defun dired-sort-extension ()
  "Dired sort by extension."
  (interactive)
  (dired-sort-other (concat dired-listing-switches "X")))
(defun dired-sort-ctime ()
  "Dired sort by create time."
  (interactive)
  (dired-sort-other (concat dired-listing-switches "ct")))
(defun dired-sort-time ()
  "Dired sort by time."
  (interactive)
  (dired-sort-other (concat dired-listing-switches "t")))
(defun dired-sort-name ()
  "Dired sort by name."
  (interactive)
  (dired-sort-other (concat dired-listing-switches "")))

(use-package dired-k
  :load-path (my-packages-directory "dired-k")
  :disabled
  :hook ((dired-initial-position . dired-k)
         (dired-after-readin . dired-k-no-revert))
  :config
  (defun +dired*dired-k-highlight (orig-fn &rest args)
    "Butt out if the requested directory is remote (i.e. through tramp)."
    (unless (file-remote-p default-directory)
      (apply orig-fn args)))
  (advice-add #'dired-k--highlight :around #'+dired*dired-k-highlight)
  )

(use-package projectile
  :load-path (my-packages-directory "projectile")
  
)

;;
;; auto highlight symbol
;;

(use-package auto-highlight-symbol
  :load-path (my-packages-directory "auto-highlight-symbol")
  :hook (prog-mode . auto-highlight-symbol-mode)
  ;; :bind (:map auto-highlight-symbol-mode-map
  ;;             ("M-<up>" . ahs-backward-whole-buffer)
  ;;             ("M-<down>" . ahs-forward-whole-buffer)
  ;;             )
  :config
  (setq-default
   ahs-idle-interval 0.07

   ;; Case sensitive
   ahs-case-fold-search nil

   ;; Highlight even inside comments
   ahs-inhibit-face-list '()
   ;;ahs-inhibit-face-list '(font-lock-comment-delimiter-face font-lock-comment-face font-lock-doc-face font-lock-doc-string-face font-lock-string-face)

   )

  (defun ahs-select-range (pred range &optional reverse onlydef)
    "Select highlighted symbol."
    (interactive)
    (let ((old-range ahs-current-range))
      (ahs-clear nil)
      (ahs-change-range-internal range)
      (ahs-idle-function)
      (ahs-set-lighter)

      (ahs-select pred reverse onlydef)

      (ahs-clear nil)
      (ahs-change-range-internal 'old-range)
      (ahs-idle-function)
      (ahs-set-lighter)
      )
    )

  (defun ahs-forward-whole-buffer ()
    "Select highlighted symbols forwardly whole buf."
    (interactive)
    (ahs-select-range 'ahs-forward-p 'ahs-range-whole-buffer t))

  (defun ahs-backward-whole-buffer ()
    "Select highlighted symbols bac."
    (interactive)
    (ahs-select-range 'ahs-backward-p 'ahs-range-whole-buffer))

  ;(add-to-list 'ahs-unhighlight-allowed-commands 'ahs-forward-whole-buffer)
  ;(add-to-list 'ahs-unhighlight-allowed-commands 'ahs-backward-whole-buffer)

)

;;
;; visual-fill-column
;; https://github.com/joostkremers/visual-fill-column
;;
;; Make lines wrap before the end of the window
;;

(use-package visual-fill-column
  :load-path (my-packages-directory "visual-fill-column")
  ;; :disabled t
  ;; :if window-system
  :demand t
  :config
  )

;;
;; centered-cursor-mode
;; https://github.com/andre-r/centered-cursor-mode.el
;;
;; Keep cursor at the center of the window (at a fixed position).
;;
;; M-X centered-cursor-mode
;; then,
;; up: C-M--
;; down :C-M-=
;;

(use-package centered-cursor-mode
  :load-path (my-packages-directory "centered-cursor-mode")
  :commands (centered-cursor-mode global-centered-cursor-mode))

;;
;; yasnippet
;;

(use-package yasnippet
  :load-path (my-packages-directory "yasnippet")
  :hook (c-mode-common . yas-minor-mode) ;; NOTE: cc-mode-hook does not work, c-mode-common-hook do.
  :config
  (setq-default yas-snippet-dirs `(,(concat user-emacs-directory "snippets")))
  (yas-reload-all)
  )

;;
;; flyspell
;;

(use-package flyspell
  :pin manual
  :defer t
  :hook ((prog-mode . (lambda () (flyspell-mode -1) (flyspell-prog-mode)))
         (text-mode . (lambda () (flyspell-mode 1))))
  )

;;
;; flycheck
;; https://www.flycheck.org/en/latest/
;;

(use-package flycheck
  :load-path (my-packages-directory "flycheck")
  :commands (flycheck-mode)
)

;;
;; flycheck-grammalecte
;;   https://git.deparis.io/flycheck-grammalecte/about/
;;

(use-package flycheck-grammalecte
  :load-path (my-packages-directory "flycheck-grammalecte")
  :after flycheck
  :commands (my--flycheck-grammalecte)
  :config
  (setq-default
   ; don't report typographical apostrophes error
   flycheck-grammalecte-report-apos nil
   ; don't report non-breakable spaces error
   flycheck-grammalecte-report-nbsp nil
   )
  ;;(add-to-list 'flycheck-grammalecte-enabled-modes 'markdown-mode)

  (defun my--flycheck-grammalecte ()
    (interactive)
    (require 'flycheck-grammalecte)
    (flyspell-mode 1)
    (ispell-change-dictionary "francais")
    ;;(flycheck-select-checker 'francais-grammalecte)
    (flycheck-mode 0)
    (flycheck-grammalecte-setup)
    (flycheck-mode 1)
    ;(flycheck-grammalecte-setup)
    )

  )

;;
;; gdb
;;

;;
;; #!sh
;; function gge() {
;;    \emacs --eval "(progn (my--prepare-gdb) (gdb \"gdb -i=mi $1\"))" &
;; }
;;

(defun my--prepare-gdb ()
  (interactive)
  ;;(global-visual-fill-column-mode 0)
  (zoom-mode 0)
  (add-hook 'prog-mode-hook (lambda () (linum-mode t)))
  )

;;(setq-default gdb-many-windows t)
(setq-default gdb-create-source-file-list nil)

;;
;; rainbow-mode
;;

(use-package rainbow-mode
  :load-path (my-packages-directory "rainbow-mode")
  :commands (rainbow-mode)
  :config
  (add-to-list 'rainbow-hexadecimal-colors-font-lock-keywords
               '("QColor(\s*\\([0-9]\\{1,3\\}\\(?:\s*%\\)?\\)\s*,\s*\\([0-9]\\{1,3\\}\\(?:\s*%\\)?\\)\s*,\s*\\([0-9]\\{1,3\\}\\(?:\s*%\\)?\\)\s*)"
                 (0 (rainbow-colorize-rgb))))
  (add-to-list 'rainbow-hexadecimal-colors-font-lock-keywords
               '("QRgb[0-9]*(\s*0x\\(\\(?:[0-9a-fA-F]\\{3\\}\\)+\\{1,4\\}\\)\s*)"
                 (0 (rainbow-colorize-hexadecimal-without-sharp))))
  )

;;
;; other
;;

(defun my-file-to-clipboard-plus ()
  "Copy current file path and linenum, or dired file at point, to clipboard"
  (interactive)
  (save-restriction
    (widen)
    (save-excursion
      (beginning-of-line)
      (let ((location
             (if-let* ((dir dired-directory)
                       (fname (dired-get-filename nil t)))
                 (abbreviate-file-name fname)
               (format "%s:%d" (abbreviate-file-name (or buffer-file-name dired-directory))
                       (1+ (count-lines 1 (point))))
               )))
        (message location)
        (gui-set-selection nil location)))))

(defun my-file-to-clipboard ()
  "Copy current file path to clipboard"
  (interactive)
  (save-restriction
    (widen)
    (save-excursion
      (beginning-of-line)
      (let* ((fname (or buffer-file-name
                        dired-directory))
             (location (abbreviate-file-name fname)))
        (message location)
        (gui-set-selection nil location)))))

(defun insert-from-primary ()
  "Insert the text from the current x-selection."
  (interactive)
  (insert (gui-get-selection nil)))

(defun my-hide-crlf-M ()
  "Hides the disturbing '^M' showing up in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

(defun my-encode-dos ()
  (interactive)
  (revert-buffer-with-coding-system 'utf-8-dos)
  )

;; https://www.emacswiki.org/emacs/RevertBuffer#toc2
(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      ;; (when (and (buffer-file-name) (file-exists-p (buffer-file-name)) (not (buffer-modified-p)))
      ;; PATCH: revert even if modified !
      (when (and (buffer-file-name) (file-exists-p (buffer-file-name)))
        (revert-buffer t t t) )))
  (message "Refreshed open files.") )