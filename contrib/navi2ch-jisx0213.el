;;; navi2ch-jisx0213.el --- Define translate table win charset to jisx2013

;; Copyright (C) 2002 by Free Software Foundation, Inc.

;; Author:
;; Part 7 $B%9%l$N(B 66 $B$NL>L5$7$5$s(B
;; <http://pc.2ch.net/test/read.cgi/unix/1031231315/66>
;; Keywords: 2ch, charset

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

(require 'navi2ch-vars)
(require 'navi2ch-util)

(unless navi2ch-on-xemacs		;$BC/$+(BXEmacs$BBP1~$*4j$$$7$^$9(B
  (defun navi2ch-jisx0213-make-char-list (i js je)
    (let ((j js) list)
      (while (<= j je)
	(setq list (cons (make-char 'japanese-jisx0208 i j) list))
	(setq j (1+ j)))
      (nreverse list)))

  (defvar navi2ch-jisx0213-win-chars-list
    (append
     (navi2ch-jisx0213-make-char-list  45  33  52) ;$B$^$k?t;z(B
     (navi2ch-jisx0213-make-char-list  45  53  62) ;$B%m!<%^?t;z(B($BBgJ8;z(B)
     (navi2ch-jisx0213-make-char-list 124 113 122) ;$B%m!<%^?t;z(B($B>.J8;z(B)
     (navi2ch-jisx0213-make-char-list  45  64  86) ;$BC10L(B
     (navi2ch-jisx0213-make-char-list  45  95 111) ;$B859f$J$I(B
     (navi2ch-jisx0213-make-char-list  45 112 124) ;$B?t3X5-9f(B
     ))

  (defvar navi2ch-jisx0213-jisx0123-chars-list
    '(?$(O-!(B ?$(O-"(B ?$(O-#(B ?$(O-$(B ?$(O-%(B ?$(O-&(B ?$(O-'(B ?$(O-((B ?$(O-)(B ?$(O-*(B
	  ?$(O-+(B ?$(O-,(B ?$(O--(B ?$(O-.(B ?$(O-/(B ?$(O-0(B ?$(O-1(B ?$(O-2(B ?$(O-3(B ?$(O-4(B
	  ?$(O-5(B ?$(O-6(B ?$(O-7(B ?$(O-8(B ?$(O-9(B ?$(O-:(B ?$(O-;(B ?$(O-<(B ?$(O-=(B ?$(O->(B
	  ?$(O,5(B ?$(O,6(B ?$(O,7(B ?$(O,8(B ?$(O,9(B ?$(O,:(B ?$(O,;(B ?$(O,<(B ?$(O,=(B ?$(O,>(B
	  ?$(O-@(B ?$(O-A(B ?$(O-B(B ?$(O-C(B ?$(O-D(B ?$(O-E(B ?$(O-F(B ?$(O-G(B ?$(O-H(B ?$(O-I(B ?$(O-J(B ?$(O-K(B
	  ?$(O-L(B ?$(O-M(B ?$(O-N(B ?$(O-O(B ?$(O-P(B ?$(O-Q(B ?$(O-R(B ?$(O-S(B ?$(O-T(B ?$(O-U(B ?$(O-V(B
	  ?$(O-_(B ?$B!H(B ?$B!I(B ?$(O-b(B ?$(O-c(B ?$(O-d(B ?$(O-e(B ?$(O-f(B ?$(O-g(B ?$(O-h(B ?$(O-i(B ?$(O-j(B ?$(O-k(B ?$(O-l(B ?$(O-m(B ?$(O-n(B ?$(O-o(B
	  ?$B"b(B ?$B"a(B ?$B"i(B ?$(O-s(B ?$B&2(B ?$B"e(B ?$B"](B ?$B"\(B ?$(O-x(B ?$(O-y(B ?$B"h(B ?$B"A(B ?$B"@(B))

  (defvar navi2ch-jisx0213-display-table nil)
  (let ((table (make-display-table))
	(from navi2ch-jisx0213-win-chars-list)
	(to navi2ch-jisx0213-jisx0123-chars-list))
    (while (and from to)
      (aset table (car from) (vector (car to)))
      (setq from (cdr from) to (cdr to)))
    (setq navi2ch-jisx0213-display-table table))

  (defun navi2ch-jisx0213-set-display-table ()
    (setq buffer-display-table
	  (copy-sequence navi2ch-jisx0213-display-table)))

  (add-hook 'navi2ch-bm-mode-hook      'navi2ch-jisx0213-set-display-table)
  (add-hook 'navi2ch-article-mode-hook 'navi2ch-jisx0213-set-display-table)

  ;; $B$J$s$G$3$s$J$N$,I,MW$J$N(B?
  (defadvice string-width (around display-table-hack activate)
    (let ((buffer-display-table nil))
      ad-do-it))
  )

;; $B$H$j$"$($:(B4$B$D(B
(setq navi2ch-replace-html-tag-alist
      (append navi2ch-replace-html-tag-alist
	      '(("&spades;" . "$(O&:(B")
		("&clubs;"  . "$(O&@(B")
		("&hearts;" . "$(O&>(B")
		("&diams;"  . "$(O&<(B"))))

;; $B@55,I=8=$r:n$j$J$*$9(B
(setq navi2ch-replace-html-tag-regexp
  (concat (regexp-opt (mapcar 'car navi2ch-replace-html-tag-alist))
          "\\|"
          (mapconcat 'car navi2ch-replace-html-tag-regexp-alist "\\|")))

(provide 'navi2ch-jisx0213)

;;; navi2ch-jisx0213.el ends here