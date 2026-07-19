;; change garbage collector defaults
(setq gc-cons-threshold 63000000
      gc-cons-percentage 0.6)

;; remove tool/menu bars
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(scroll-bar-mode -1)
