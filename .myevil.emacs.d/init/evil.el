;;; evil.el -*- lexical-binding: t; -*-

(bind-keys
 :prefix-map my-file-map
 :prefix "<leader>f"
 ;; ("f" . helm-find-files)
 ;; ("r" . helm-recentf)
 )

(bind-keys
 :prefix-map my-search-map
 :prefix "<leader>s"
 ;; ("f" . helm-find-files)
 ;; ("r" . helm-recentf)
 )

(bind-keys
 :prefix-map my-buffer-map
 :prefix "<leader>b"
 ("b" . helm-mini)
 ("k" . kill-buffer)
 ("r" . revert-buffer)
)

;; (bind-keys
;;  :map c-mode-base-mode
;;  :prefix-map my-code-map
;;  :prefix "<leader>c"
;; )

(bind-keys
 :prefix-map my-git-map
 :prefix "<leader>g"
 ("g" . magit-status-here)
 ("s" . magit-status)
 ("l" . magit-log)
 ("f" . magit-log-buffer-file)
 ("b" . magit-blame)
)

(use-package evil
  :load-path (my-packages-directory "evil")
  :demand t
  :bind (
         ;;("C-b" . my-buffer-map)

         :map evil-normal-state-map
         ("<leader>w" . evil-window-map)

         :map evil-window-map
         ;; Lazy fingers: add `C-w C-h` same as `C-w h`
         ("C-h" . evil-window-left)
         ("C-j" . evil-window-down)
         ("C-k" . evil-window-up)
         ("C-l" . evil-window-right)
         ("C-q" . evil-quit)

         ("=" . force-balance-windows) ;; see zoom config

         ("u" . winner-undo)
         ("C-r" . winner-redo)

         ("b" . helm-mini)

         )

  :hook (git-commit-setup . evil-insert-state)

  :init ;; init because some evil variables must be set before load
  (setq
   evil-want-integration t
   evil-want-keybinding nil ;; for evil-collection

   evil-want-C-w-delete nil
   evil-want-Y-yank-to-eol t

   ;; If the cursor can go 1 beyond the last char (like emacs)
   evil-move-beyond-eol t

   ;; If h/l/f/t/... moves to other lines (like emacs)
   evil-cross-lines t

   ;; If j/k moves across wrapped lines, or physical lines
   evil-respect-visual-line-mode nil

   ;; If '$' makes cursor stick to eol
   evil-track-eol t
   ;; If "cursor at eol" makes cursor stick to eol
   track-eol nil


   evil-auto-balance-windows nil ;; leave that to zoom

   )

  :config
  ;; TODO: cursor color

  (evil-mode 1)

  ;; (setq
  ;;  ;; Split left. i.e. split right and switch to it
  ;;  evil-split-window-below t
  ;;  ;; Split above. i.e. split below and switch to it
  ;;  evil-vsplit-window-right t
  ;;  )
  ;; ;; Does not work as expected, because after (split-window 'left) we already
  ;; ;; are focused on the new window
  ;; (advice-add 'split-window :after (lambda (&rest r) (message "split") (zoom--update)))

  (defun evil-window-vsplit-left ()
    "Better window balancing than evil-vsplit-window-right"
    (interactive)
    (evil-window-vsplit)
    (when zoom-mode (zoom--update))
    (other-window 1)
    )
  (defun evil-window-split-above ()
    "Better window balancing than evil-split-window-below"
    (interactive)
    (evil-window-split)
    (when zoom-mode (zoom--update))
    (other-window 1)
    )
  ;; (define-key evil-window-map [remap evil-window-vsplit] 'evil-window-vsplit-left)
  ;; (define-key evil-window-map [remap evil-window-split] 'evil-window-split-above)
  (bind-keys
   :map evil-window-map
   ("s"   . evil-window-split-above)
   ("C-s" . evil-window-split-above)
   ("v"   . evil-window-vsplit-left)
   ("C-v" . evil-window-vsplit-left)
  )

  ;; Used as "<leader>" in key bindings
  (evil-set-leader '(normal visual) (kbd "SPC"))

  (define-key evil-motion-state-map "gd" 'rtags-find-symbol-at-point)

  )

;; Required by evil for `g;`
(use-package goto-chg
  :load-path (my-packages-directory "goto-chg")
  :defer t)

;; evil-compatible bindings for a lot of modes
(use-package evil-collection
  :load-path (my-packages-directory "evil-collection")
  :after evil
  :demand t
  :init
  (setq
   evil-collection-key-blacklist '("SPC")
   )
  :config
  (evil-collection-init)
  )

;; Evil text-objects visual hints
(use-package evil-goggles
  :load-path (my-packages-directory "evil-goggles")
  :after evil
  :demand t
  :config
  (setq evil-goggles-pulse nil)
  (evil-goggles-mode)
  )

;; evil-compatible magit bindings
(use-package evil-magit
  :load-path (my-packages-directory "evil-magit")
  :after (evil magit)
  :demand t
  :bind (:map magit-mode-map
         ("SPC" . evil-send-leader) ;; force leader
         :map magit-diff-mode-map
         ("SPC" . evil-send-leader) ;; force leader
        )
  )

;; Align stuff with 'g l <char>'
(use-package evil-lion
  :load-path (my-packages-directory "evil-lion")
  :after (evil)
  :bind (:map evil-normal-state-map
         ("g l " . evil-lion-left)
         ("g L " . evil-lion-right)
         :map evil-visual-state-map
         ("g l " . evil-lion-left)
         ("g L " . evil-lion-right))
  )

;; Comment sutff with 'g c'
(use-package evil-nerd-commenter
  :load-path (my-packages-directory "evil-nerd-commenter")
  :after evil
  :bind (
         :map evil-normal-state-map
         ("gc" . evilnc-comment-operator)
         :map evil-visual-state-map
         ("gc" . evilnc-comment-operator)
         :map evil-inner-text-objects-map
         ("c" . evilnc-inner-comment)
         :map evil-outer-text-objects-map
         ("c" . evilnc-outer-commenter)
         )
)

;; Change braces with 'c s <old> <new>', add braces 'y s <motion> <brace>'...
(use-package evil-surround
  :load-path (my-packages-directory "evil-surround")
  :after evil
  :bind (
         :map evil-operator-state-map
         ("s" . evil-surround-edit)
         ("S" . evil-Surround-edit)
         :map evil-visual-state-map
         ("s" . evil-surround-region)
         ("S" . evil-Surround-region)
         )
)

;; Arg text motions and inner/outer
(use-package evil-args
  :load-path (my-packages-directory "evil-args")
  :after evil
  :bind (
         :map evil-inner-text-objects-map
         ("a" . evil-inner-arg)
         :map evil-outer-text-objects-map
         ("a" . evil-outer-arg)
         :map evil-normal-state-map
         ("]a" . evil-forward-arg)
         ("[a" . evil-backward-arg)
         ("[A" . evil-jump-out-args)
         :map evil-motion-state-map
         ("]a" . evil-forward-arg)
         ("[a" . evil-backward-arg)
         ("[A" . evil-jump-out-args)
         )
  )

;; text objects for inner and outer indentation levels
(use-package evil-indent-plus
  :load-path (my-packages-directory "evil-surround")
  :after evil
  :bind (
         :map evil-inner-text-objects-map
         ("i" . evil-indent-plus-i-indent)         ;; same level
         ("I" . evil-indent-plus-i-indent-up)      ;; same level + line above
         ("J" . evil-indent-plus-i-indent-up-down) ;; same level + line above and below
         :map evil-outer-text-objects-map
         ("i" . evil-indent-plus-a-indent)         ;; + empty lines arround
         ("I" . evil-indent-plus-a-indent-up)      ;; ditto
         ("J" . evil-indent-plus-a-indent-up-down) ;; ditto
         )
  )

;; TODO see if evil-embrace is worth it ?
;; https://github.com/cute-jumper/evil-embrace.el/blob/master/evil-embrace.el