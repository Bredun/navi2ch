;;; navi2ch-face.el --- face definitions for navi2ch

;; Copyright (C) 2001 by 2$B$A$c$s$M$k(B

;; Author: (not 1)
;; Keywords: network 2ch

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; 

;;; Code:
(provide 'navi2ch-face)

(defgroup navi2ch-face nil
  "Navi2ch, FAces."
  :prefix "navi2ch-"
  :group 'navi2ch)

(defface navi2ch-list-category-face
  '((((class color) (background light)) (:foreground "Gray30" :bold t))
    (((class color) (background dark)) (:foreground "SkyBlue" :bold t)))
  "$B%+%F%4%j$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-list-board-name-face
  '((((class color) (background light)) (:foreground "Navy"))
    (((class color) (background dark)) (:foreground "SkyBlue")))
  "$BHDL>$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-unread-face
  '((((class color) (background light)) (:foreground "DarkOliveGreen"))
    (((class color) (background dark)) (:foreground "GreenYellow")))
  "$BFI$s$G$J$$%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-view-face
  '((((class color) (background light)) (:foreground "FireBrick"))
    (((class color) (background dark)) (:foreground "cyan")))
  "$BI=<($7$F$$$k%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-cache-face
  '((((class color) (background light)) (:foreground "Navy"))
    (((class color) (background dark)) (:foreground "SkyBlue")))
  "$BFI$s$@;v$,$"$k%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-update-face
  '((((class color) (background light)) (:foreground "SaddleBrown"))
    (((class color) (background dark)) (:foreground "LightSkyBlue")))
  "$B99?7$7$?%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-mark-face
  '((((class color) (background light)) (:foreground "Tomato3"))
    (((class color) (background dark)) (:foreground "tomato")))
  "$B%^!<%/$7$?%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-updated-unread-face
  '((((class color) (background light)) (:foreground "DarkOliveGreen" :bold t))
    (((class color) (background dark)) (:foreground "GreenYellow" :bold t)))
  "$B%l%9$,$"$C$?FI$s$G$J$$%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-updated-view-face
  '((((class color) (background light)) (:foreground "FireBrick" :bold t))
    (((class color) (background dark)) (:foreground "PaleGreen" :bold t)))
  "$B%l%9$,$"$C$?I=<($7$F$$$k%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-updated-cache-face
  '((((class color) (background light)) (:foreground "Navy" :bold t))
    (((class color) (background dark)) (:foreground "SkyBlue" :bold t)))
  "$B%l%9$,$"$C$?FI$s$@;v$,$"$k%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-updated-update-face
  '((((class color) (background light)) (:foreground "SaddleBrown" :bold t))
    (((class color) (background dark)) (:foreground "LightSkyBlue" :bold t)))
  "$B%l%9$,$"$C$?99?7$7$?%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-updated-mark-face
  '((((class color) (background light)) (:foreground "Tomato3" :bold t))
    (((class color) (background dark)) (:foreground "tomato" :bold t)))
  "$B%l%9$,$"$C$?%^!<%/$7$?%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-seen-unread-face
  '((((class color) (background light)) (:foreground "DarkOliveGreen" :underline t))
    (((class color) (background dark)) (:foreground "GreenYellow" :underline t)))
  "$B$9$G$K8+$?FI$s$G$J$$%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-seen-view-face
  '((((class color) (background light)) (:foreground "FireBrick" :underline t))
    (((class color) (background dark)) (:foreground "PaleGreen" :underline t)))
  "$B$9$G$K8+$?I=<($7$F$$$k%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-seen-cache-face
  '((((class color) (background light)) (:foreground "Navy" :underline t))
    (((class color) (background dark)) (:foreground "SkyBlue" :underline t)))
  "$B$9$G$K8+$?FI$s$@;v$,$"$k%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-seen-update-face
  '((((class color) (background light)) (:foreground "SaddleBrown" :underline t))
    (((class color) (background dark)) (:foreground "LightSkyBlue" :underline t)))
  "$B$9$G$K8+$?99?7$7$?%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-bm-seen-mark-face
  '((((class color) (background light)) (:foreground "Tomato3" :underline t))
    (((class color) (background dark)) (:foreground "tomato" :underline t)))
  "$B$9$G$K8+$?%^!<%/$7$?%9%l$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-article-header-face
  '((((class color) (background light)) (:foreground "Gray30" :bold t))
    (((class color) (background dark)) (:foreground "gray" :bold t)))
  "$B%X%C%@$N(B From $B$H$+$NItJ,$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-article-header-contents-face
  '((((class color) (background light)) (:foreground "Navy"))
    (((class color) (background dark)) (:foreground "yellow")))
  "$B%X%C%@$NFbMF$NJ}$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-article-link-face
  '((((class color) (background light)) (:bold t))
    (((class color) (background dark)) (:bold t)))
  "$BF1$8%9%lCf$X$N%j%s%/$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-article-url-face
  '((((class color) (background light)) (:bold t))
    (((class color) (background dark)) (:bold t)))
  "url $B$N(B face"
  :group 'navi2ch-face)

(defface navi2ch-article-citation-face
  '((((class color) (background light)) (:foreground "FireBrick"))
    (((class color) (background dark)) (:foreground "HotPink1")))
  "$B0zMQ$N(B face"
  :group 'navi2ch-face)

(run-hooks 'navi2ch-face-load-hook)
;;; navi2ch-face.el ends here
