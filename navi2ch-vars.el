;;; navi2ch-vars.el --- User variables for navi2ch.

;; Copyright (C) 2001 by 2$B$A$c$s$M$k(B

;; Author: (not 1)
;; Keywords: www 2ch

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
(provide 'navi2ch-vars)

(defgroup navi2ch nil
  "*Navigator for 2ch."
  :prefix "navi2ch-"
  :group 'hypermedia
  :group '2ch)

(defgroup navi2ch-list nil
  "*Navi2ch, list buffer."
  :prefix "navi2ch-"
  :group 'navi2ch)

(defgroup navi2ch-board nil
  "*Navi2ch, board buffer."
  :prefix "navi2ch-"
  :group 'navi2ch)

(defgroup navi2ch-article nil
  "*Navi2ch, article buffer."
  :prefix "navi2ch-"
  :group 'navi2ch)

(defgroup navi2ch-message nil
  "*Navi2ch, article buffer."
  :prefix "navi2ch-"
  :group 'navi2ch)

(defgroup navi2ch-net nil
  "*Navi2ch, article buffer."
  :prefix "navi2ch-"
  :group 'navi2ch)


;;; navi2ch variables
(defcustom navi2ch-ask-when-exit t
  "*$B=*N;;~$KK\Ev$K=*$o$k$+J9$/$+$I$&$+!#(B
`non-nil' $B$J$iJ9$/(B"
  :type 'boolean
  :group 'navi2ch)

(defcustom navi2ch-directory "~/.navi2ch"
  "*navi2ch $B$N%-%c%C%7%e$J$I$rCV$/%G%#%l%/%H%j(B"
  :type 'directory
  :group 'navi2ch)

(defcustom navi2ch-uudecode-program "uudecode"
  "*uudecode $B$N%W%m%0%i%`L>(B"
  :type 'string
  :group 'navi2ch)

(defcustom navi2ch-uudecode-args nil
  "*uudecode $B$r<B9T$9$k$H$-$N0z?t(B"
  :type '(repeat :tag "$B0z?t(B" string)
  :group 'navi2ch)

(defcustom navi2ch-init-file (expand-file-name "init.el"
					       navi2ch-directory)
  "*navi2ch $B$N=i4|2=%U%!%$%k(B"
  :type 'file
  :group 'navi2ch)

(defcustom navi2ch-enable-readcgi t
  "*read.cgi $B$N(B raw mode $B$r;H$C$F%U%!%$%k$r<h$C$F$/$k$+$I$&$+!#(B
non-nil $B$J$i(B read.cgi $B$r;H$&(B"
  :type 'boolean
  :group 'navi2ch)

(defcustom navi2ch-enable-readcgi-host-list nil
  "*read.cgi $B$N(B raw mode $B$r;H$C$F%U%!%$%k$r<h$C$F$/$k%[%9%H$N%j%9%H!#(B
`navi2ch-enable-readcgi' $B$,(B nil $B$N;~$KM-8z(B"
  :type '(repeat (string :tag "$B%[%9%H(B"))
  :group 'navi2ch)

(defcustom navi2ch-disable-readcgi-host-list nil
  "*read.cgi $B$N(B raw mode $B$r;H$o$J$$$G%U%!%$%k$r<h$C$F$/$k%[%9%H$N%j%9%H!#(B
`navi2ch-enable-readcgi' $B$,(B nil $B$N;~$KM-8z(B"
  :type '(repeat (string :tag "$B%[%9%H(B"))
  :group 'navi2ch)

(defcustom navi2ch-browse-url-image-program nil
  "*`navi2ch-browse-url-image'$B$G;H$o$l$k%W%m%0%i%`L>(B"
  :type '(choice string (const :tag "None" nil))
  :group 'navi2ch)

(defcustom navi2ch-browse-url-image-args nil
  "*`navi2ch-browse-url-image-program'$B$N0z?t!#(B"
  :type '(repeat (string :tag "Argument"))
  :group 'navi2ch)

(defcustom navi2ch-browse-url-image-extentions '("jpg" "jpeg" "gif" "png")
  "*`navi2ch-browse-url-image'$B$r;H$&3HD%;R(B"
  :type '(repeat (string :tag "$B3HD%;R(B"))
  :group 'navi2ch)

(defcustom navi2ch-base64-fill-column 64
  "*base64$B$G%(%s%3!<%I$5$l$?J8;zNs$r2?J8;z$G(Bfill$B$9$k$+!#(B"
  :type 'integer
  :group 'navi2ch)

(defcustom navi2ch-2ch-host-list
  '("cocoa.2ch.net")
  "*2ch $B$H$_$J$9(B host $B$N%j%9%H!#(B"
  :type '(repeat (string :tag "$B%[%9%H(B"))
  :group 'navi2ch)

;;; list variables
(defcustom navi2ch-list-window-width 20
  "*list window $B$NI}(B"
  :type 'integer
  :group 'navi2ch-list)

(defcustom navi2ch-list-etc-file-name "etc.txt"
  "*$B$=$NB>%+%F%4%j$KF~$l$kHD$r=q$$$F$*$/%U%!%$%k(B!"
  :type 'file
  :group 'navi2ch-list)

(defcustom navi2ch-list-stay-list-window nil
  "*$BHD$rA*$s$@$H$-$K(B list window $B$rI=<($7$?$^$^$K$9$k$+!#(B
`non-nil' $B$J$iI=<($7$?$^$^$K$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-list)

(defcustom navi2ch-list-bbstable-url "http://www.2ch.net/newbbsmenu.html"
  "*bbstable $B$N(B url"
  :type 'string
  :group 'navi2ch-list)

(defcustom navi2ch-list-init-open-category nil
  "*$B:G=i$+$iA4$F$N%+%F%4%j$r3+$/$+$I$&$+!#(B
`non-nil' $B$GA4$F3+$/!#(B"
  :type 'boolean
  :group 'navi2ch-list)

(defcustom navi2ch-list-indent-width 2
  "*$BHDL>$N%$%s%G%s%HI}(B"
  :type 'integer
  :group 'navi2ch-list)

(defcustom navi2ch-list-etc-category-name "$B$=$NB>(B"
  "*$B$=$NB>%+%F%4%j$NL>A0(B"
  :type 'string
  :group 'navi2ch-list)

(defcustom navi2ch-list-global-bookmark-category-name "$B%V%C%/%^!<%/(B"
  "*$B%V%C%/%^!<%/%+%F%4%j$NL>A0(B"
  :type 'string
  :group 'navi2ch-list)

(defcustom navi2ch-list-sync-update-on-boot t
  "*navi2ch $B5/F0;~$KHD0lMw$r<h$j$K9T$/$+!#(B
`nil' $B$K$9$k$H(B s $B$7$J$$$+$.$j<h$j$K9T$+$J$$!#(B"
  :type 'boolean
  :group 'navi2ch-list)

;;; board variables
(defcustom navi2ch-board-max-line nil
  "*$B%@%&%s%m!<%I$9$k(B subject.txt $B$N9T?t!#(B
nil $B$J$iA4It%@%&%s%m!<%I$9$k(B"
  :type '(choice (integer :tag "$B9T?t$r;XDj(B")
		 (const :tag "$BA4$F(B" nil))
  :group 'navi2ch-board)

(defcustom navi2ch-board-expire-date 30
  "*$B:G8e$KJQ99$5$l$F$+$i$3$NF|?t0J>e$?$C$?%U%!%$%k$O(B expire $B$9$k(B
nil $B$J$i(B expire $B$7$J$$(B"
  :type '(choice (integer :tag "$BF|?t$r;XDj(B")
		 (const :tag "expire $B$7$J$$(B" nil))
  :group 'navi2ch-board)

(defcustom navi2ch-board-window-height 10
  "*board window $B$N9b$5(B"
  :type 'integer
  :group 'navi2ch-board)

(defcustom navi2ch-board-check-updated-article-p t
  "*$B?7$7$$%l%9$,$"$C$?$+%A%'%C%/$9$k$+$I$&$+(B"
  :type 'boolean
  :group 'navi2ch-board)

(defcustom navi2ch-board-view-logo-program
  (if (eq window-system 'w32)
      "fiber"
    "xv")
  "*$B%m%4$r8+$k$N$K;H$&%W%m%0%i%`(B"
  :type 'file
  :group 'navi2ch-board)

(defcustom navi2ch-board-view-logo-args nil
  "*$B%m%4$r8+$k$N$K;H$&%W%m%0%i%`$N0z?t(B"
  :type '(repeat (string :tag "$B0z?t(B"))
  :group 'navi2ch-board)

(defcustom navi2ch-board-delete-old-logo t
  "*$B?7$7$$%m%4$r%@%&%s%m!<%I$7$?$H$-$K8E$$%m%4$r>C$9$+$I$&$+(B"
  :type 'boolean
  :group 'navi2ch-board)

(defcustom navi2ch-bm-subject-width 50
  "*$B3F%9%l$NBjL>$NI}(B"
  :type 'integer
  :group 'navi2ch-board)

(defcustom navi2ch-bm-mark-and-move t
  "*$B%^!<%/$7$?8e$K0\F0$9$k$+$I$&$+(B
nil $B$J$i0\F0$7$J$$(B
non-nil $B$J$i2<$K0\F0$9$k(B
'follow $B$J$i0JA00\F0$7$?J}8~$K0\F0$9$k(B"
  :type '(choice (const :tag "$B0\F0$7$J$$(B" nil)
		 (const :tag "$B2<$K0\F0(B" t)
		 (const :tag "$B0JA00\F0$7$?J}8~$K0\F0(B" follow))
  :group 'navi2ch-board)

(defcustom navi2ch-bm-empty-subject "navi2ch: no subject"
  "*subject $B$,L5$$$H$-$KBe$jI=<($9$k(B subject"
  :type 'string
  :group 'navi2ch-board)

(defcustom navi2ch-history-max-line 100
  "*$B%R%9%H%j$N:GBg$N9T?t(B
nil $B$J$i$P@)8B$7$J$$(B"
  :type '(choice (integer :tag "$B:GBg$N9T?t$r;XDj(B")
		 (const :tag "$B@)8B$7$J$$(B" nil))
  :group 'navi2ch-board)

(defcustom navi2ch-bm-stay-board-window t
  "*$B%9%l$rA*$s$@$H$-$K(B board window $B$rI=<($7$?$^$^$K$9$k$+!#(B
`non-nil' $B$J$iI=<($7$?$^$^$K$9$k(B"
  :type 'boolean
  :group 'navi2ch-board)

(defcustom navi2ch-bm-fetched-info-file (expand-file-name "fetched.txt"
							  navi2ch-directory)
  "*$B$9$G$KFI$s$@%9%l$rJ]B8$9$k%U%!%$%k(B"
  :type 'string
  :group 'navi2ch-board)

(defcustom navi2ch-bookmark-file (expand-file-name "bookmark2.txt"
						   navi2ch-directory)
  "*$B%0%m!<%P%k%V%C%/%^!<%/$rJ]B8$9$k%U%!%$%k(B"
  :type 'string
  :group 'navi2ch-board)

(defcustom navi2ch-history-file (expand-file-name "history.txt"
						  navi2ch-directory)
  "*$B%R%9%H%j$rJ]B8$9$k%U%!%$%k(B"
  :type 'string
  :group 'navi2ch-board)


;;; article variables
(defcustom navi2ch-article-aadisplay-program
  (if (eq window-system 'w32)
      "notepad"
    "aadisplay")
  "*aa $B$r8+$k$N$K;H$&%W%m%0%i%`L>(B"
  :type 'string
  :group 'navi2ch-article)

(defcustom navi2ch-article-aadisplay-coding-system
  (if (eq window-system 'w32)
      'shift_jis-dos
    'euc-jp-unix)
  "*navi2ch-article-aadisplay-program $BMQ$N0l;~%U%!%$%k$N(B coding-system"
  :type 'symbol
  :group 'navi2ch-article)
  
(defcustom navi2ch-article-view-aa-function
  (if (eq window-system 'w32)
      'navi2ch-article-popup-dialog
    'navi2ch-article-call-aadisplay)
  "*aa $B$r8+$k$N$K;H$&4X?tL>(B"
  :type 'function
  :group 'navi2ch-article)

(defcustom navi2ch-article-enable-diff t
  "*$B:9J,$r<h$C$F$/$k$+$I$&$+!#(Bnil $B$J$i>o$K:9J,$r<h$C$F$3$J$$(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-max-line nil
  "*$B%@%&%s%m!<%I$9$k5-;v$N9T?t!#(B
nil $B$J$i:9J,A4$F$r%@%&%s%m!<%I$9$k!#(B"
  :type '(choice (integer :tag "$B7o?t$r;XDj(B")
		 (const :tag "$BA4$F(B" nil))
  :group 'navi2ch-article)

(defcustom navi2ch-article-enable-fill nil
  "*fill-region $B$9$k$+$I$&$+(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-enable-fill-list nil
  "*fill-region $B$9$k(B $BHD$N%j%9%H(B"
  :type '(repeat string)
  :group 'navi2ch-article)

(defcustom navi2ch-article-disable-fill-list nil
  "*fill-region $B$7$J$$HD$N%j%9%H(B"
  :type '(repeat string)
  :group 'navi2ch-article)

(defcustom navi2ch-article-enable-through 'ask-always
  "*$B%9%l%C%I$N:G8e$G%9%Z!<%9$r2!$7$?$H$-$K<!$N%9%l%C%I$K0\F0$9$k$+!#(B
nil $B$J$i0\F0$7$J$$(B
ask-always $B$J$i0\F0$9$kA0$KI,$:<ALd$9$k(B
ask $B$J$iL@<(E*$K0\F0$9$k;~0J30$J$i<ALd$9$k(B
$B$=$l0J30$N(B non-nil $B$JCM$J$i2?$bJ9$+$:$K0\F0$9$k!#(B"
  :type '(choice (const :tag "$B$$$D$G$b<ALd$9$k(B" ask-always)
		 (const :tag "$BL@<(E*$K0\F0$9$k$H$-0J30$O<ALd$9$k(B" ask)
		 (const :tag "$BJ9$+$:$K0\F0(B" t)
		 (const :tag "$B0\F0$7$J$$(B" nil))
  :group 'navi2ch-article)

(defcustom navi2ch-article-parse-field-list '(data name mail)
  "*parse $B$9$k%U%#!<%k%I$N%j%9%H!#(B
$BCY$/$F$b$$$$$s$J$i(B '(data mail name) $B$H$+$9$k$H$$$$$+$b(B"
  :type '(set (const :tag "$B5-;v(B" data)
	       (const :tag "$B%a!<%k(B" mail)
	       (const :tag "$BL>A0(B" name))
  :group 'navi2ch-article)

(defcustom navi2ch-article-goto-number-recenter t
  "*goto-number $B$7$?$H$-$K(B recenter $B$9$k$+$I$&$+(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-new-message-range '(100 . 1)
  "*$B?7$7$$(B $B%9%l%C%I$r<h$C$F$-$?$H$-$NI=<($9$kHO0O(B"
  :type '(cons integer integer)
  :group 'navi2ch-article)

(defcustom navi2ch-article-exist-message-range '(1 . 100)
  "*$B$9$G$K$"$k%9%l%C%I$r<h$C$F$-$?$H$-$NI=<($9$kHO0O(B"
  :type '(cons integer integer)
  :group 'navi2ch-article)

(defcustom navi2ch-article-auto-range t
  "*$B$^$?I=<($7$F$J$$%9%l%C%I$r<h$C$F$-$?$H$-$K>!<j$KHO0O$r69$a$k$+!#(B
non-nil $B$G69$a$k(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-view-range-list
  '((1 . 50)
    (50 . 50)
    (1 . 100)
    (100 . 100))
  "*$BI=<($9$k%9%l%C%I$NHO0O$rA*Br$9$k$H$-$K;H$&%j%9%H(B"
  :type '(repeat (cons integer integer))
  :group 'navi2ch-article)
  
(defcustom navi2ch-article-header-format-function
  'navi2ch-article-default-header-format-function
  "*NUMBER NAME MAIL DATE $B$r0z?t$K<h$j!"%l%9$N%X%C%@$rJV$94X?t(B"
  :type 'function
  :group 'navi2ch-article)

(defcustom navi2ch-article-citation-regexp
  "^[>$B!d(B]\\($\\|[^$>$B!d(B0-9$B#0(B-$B#9(B].*\\)"
  "*$B0zMQItJ,$N@55,I=8=(B"
  :type 'regexp
  :group 'navi2ch-article)

(defcustom navi2ch-article-number-regexp
  "[>$B!d(B][>$B!d(B]?\\(\\([0-9$B#0(B-$B#9(B]+,\\)*[0-9$B#0(B-$B#9(B]+\\(-[0-9$B#0(B-$B#9(B]+\\)?\\)"
  "*$BF1$8%9%lFb$X$N%j%s%/$rI=$o$9@55,I=8=(B"
  :type 'regexp
  :group 'navi2ch-article)

(defcustom navi2ch-article-url-regexp
  "h?ttps?://\\([-a-zA-Z0-9_=?#$@~`%&*+|\\/.,:]+\\)"
  "*url $B$rI=$o$9@55,I=8=(B"
  :type 'regexp
  :group 'navi2ch-article)

(defcustom navi2ch-article-filter-list nil
  "*$B%9%l%C%I$N5-;v$r$$$8$k%U%#%k%?!<$N(B list$B!#(B
$B$=$l$>$l$N%U%#%k%?!<$O(B elisp $B$N4X?t$J$i$P(B $B$=$N(B symbol$B!"(B
$B30It%W%m%0%i%`$r8F$V$J$i(B
'(\"perl\" \"2ch.pl\")
$B$H$$$C$?46$8$N(B list $B$r@_Dj$9$k!#(B
$BHD(BID$B$r0z?t$G;XDj$9$k$J$i(B board $B$H$$$&%7%s%\%k$rHDL>$rEO$7$?$$>l=j$K=q$/!#(B
$BNc$($P$3$s$J46$8!#(B
\(setq navi2ch-article-filter-list
      '(navi2ch-filter
        (\"perl\" \"2ch.pl\")
        (\"perl\" \"filter-with-board.pl\" \"-b\" board)
        ))"
  :type '(repeat sexp)
  :group 'navi2ch-article)

(defcustom navi2ch-article-redraw-when-goto-number t
  "*`navi2ch-article-goto-number' $B$G!"HO0O30$J$i$P!"(Bredraw $B$7$J$*$9$+$I$&$+!#(B
non-nil $B$J$i(B redraw $B$7$J$*$9!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-fix-range-diff 10
  "*`navi2ch-article-fix-range' $B$7$?$H$-$KLa$kNL(B"
  :type 'integer
  :group 'navi2ch-article)

(defcustom navi2ch-article-fix-range-when-sync t
  "*`navi2ch-article-sync' $B$GHO0O30$J$i$P(B `navi2ch-article-view-range' $B$rJQ99$9$k$+!#(B
non-nil $B$J$iHO0OFb$KJQ99$9$k(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-message-separator ?_
  "*$B%l%9$H%l%9$N6h@Z$j$K;H$&J8;z!#(B"
  :type 'character
  :group 'navi2ch-article)

(defcustom navi2ch-article-message-separator-width '(/ (window-width) 2)
  "*$B%l%9$H%l%9$N6h@Z$jJ8;z$NI}!#(B
$BI}$r(B 80 $BJ8;zJ,$K$7$?$$$J$i(B
\(setq navi2ch-article-message-separator-width 80)
window $B$NI}$HF1$8$K$7$?$$$J$i(B
\(setq navi2ch-article-message-separator-width '(window-width))
$BEy;XDj$9$k!#(B"
  :type 'sexp
  :group 'navi2ch-article)

(defcustom navi2ch-article-auto-expunge nil
  "*$B%9%l$r3+$$$?;~$K<+F0E*$K8E$$%P%C%U%!$r>C$9$+!#(B
`non-nil' $B$J$i(B navi2ch-article-max-buffers $B0J>e$K$J$i$J$$$h$&$K$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-max-buffers 20
  "*$B%P%C%U%!$H$7$FJ];}$9$k%9%l$N:GBg?t!#(B
0 $B$J$i$PL5@)8B!#(B"
  :type 'integer
  :group 'navi2ch-article)

(defcustom navi2ch-article-cleanup-white-space-after-old-br t
  "*`non-nil' $B$N>l9g!"(B<br> $B$N8e$K$"$k6uGr$r<h$j=|$/!#(B
$B$?$@$7!"$9$Y$F$N(B <br> $B$ND>8e$K6uGr$,$"$k>l9g$N$_!#(B"
  :type 'integer
  :group 'navi2ch-article)

(defcustom navi2ch-article-cleanup-trailing-whitespace t
  "*`non-nil' $B$N>l9g!"3F9T$NKvHx$N6uGr$r<h$j=|$/!#(B"
  :type 'integer
  :group 'navi2ch-article)

(defcustom navi2ch-article-cleanup-trailing-blankline t
  "*`non-nil' $B$N>l9g!"3F%l%9$NKvHx$N6u9T$r<h$j=|$/!#(B"
  :type 'interger
  :group 'navi2ch-article)

;;; message variables
(defcustom navi2ch-message-user-name
  (if (featurep 'xemacs)
      "$BL>L5$7$5$s!w#X#E#m#a#c#s(B"
    "$BL>L5$7$5$s!w#E#m#a#c#s(B")
  "*$BL>A0(B"
  :type 'string
  :group 'navi2ch-message)

(defcustom navi2ch-message-user-name-alist
  '(("network" . "anonymous")
    ("tv" . "$BL>L5$7$5$s(B"))
  "*$BHD$4$H$N%G%U%)%k%H$NL>A0$N(B alist"
  :type '(repeat (cons string string))
  :group 'navi2ch-message)

(defcustom navi2ch-message-mail-address nil
  "*$B%G%U%)%k%H$N%a!<%k%"%I%l%9(B"
  :type 'string
  :group 'navi2ch-message)

(defcustom navi2ch-message-ask-before-send t
  "*$BAw?.$9$kA0$K3NG'$9$k$+!#(B
`non-nil' $B$J$i3NG'$9$k(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-ask-before-kill t
  "*$B=q$-$3$_$r%-%c%s%;%k$9$kA0$K3NG'$9$k$+(B
`non-nil' $B$J$i3NG'$9$k(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-always-pop-message nil
  "*$B=q$-$+$1$N(B message $B$r>o$KI|85$9$k$+$I$&$+(B
`non-nil' $B$J$iI|85$9$k(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-wait-time 1
  "*$BAw$C$?8e(B sync $B$9$kA0$KBT$D;~4V(B($BIC(B)"
  :type 'integer
  :group 'navi2ch-message)

(defcustom navi2ch-message-remember-user-name t
  "*$BAw$C$?8e(B `navi2ch-message-user-name' $B$rAw$C$?%a!<%k%"%I%l%9$KJQ99$9$k$+!#(B
`non-nil' $B$J$iJQ99$9$k(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-cite-prefix "> "
  "*$B0zMQ$9$k$H$-$N@\F,<-(B"
  :type 'string
  :group 'navi2ch-message)

(defcustom navi2ch-message-trip nil
  "*trip $BMQ$NJ8;zNs!#(B
$B=q$-$3$_;~$K(B From $B$N8e$m$KIU2C$5$l$k!#(B"
  :type '(choice (string :tag "trip $B$r;XDj(B")
		 (const :tag "trip $B$r;XDj$7$J$$(B" nil))
  :group 'navi2ch-message)

(defcustom navi2ch-message-aa-prefix-key "\C-c\C-a"
  "*aa $B$rF~NO$9$k0Y$N(B prefix-key$B!#(B"
  :type 'string
  :group 'navi2ch-message)

(defcustom navi2ch-message-aa-alist
  '(("a" . "($B!-'%!.(B)")
    ("b" . "$B!3(B(`$B'%!-(B)(II(B")
    ("f" . "( $B!-(B_$B!5(B`)(IL0](B")
    ("F" . "($B!-!<!.(B)")
    ("g" . "((I_$B'%(I_(B)(I:^Y'(B")
    ("G" . "(I6^$B(,(,(B((I_$B'%(I_(B;)$B(,(,(I?(B!")
    ("h" . "((I_$B'%(I_(B)(IJ'(B?")
    ("H" . "(;$B!-'%!.(B)(IJ'J'(B")
    ("i" . "((I%$B"O(I%(B)(I22(B!!")
    ("j" . "((I%$B"O(I%(B)(I<^;8<^4]C^<@(B")
    ("k" . "(I7@$B(,(,(,(,(,(,(B((I_$B"O(I_(B)$B(,(,(,(,(,(,(B !!!!!")
    ("m" . "($B!-"O!.(B)")
    ("M" . "$B!3(B($B!-"&!.(B)(II(B")
    ("n" . "($B!1!<!1(B)$B%K%d%j%C(B")
    ("N" . "($B!-(B-`).(I!$B#o#O(B($B$J$s$G$@$m$&!)(B)")
    ("p" . "$B!J!!(I_$B'U(I_$B!K(IN_60](B")
    ("s" . "$B&2!J(I_$B'U(I_(Blll$B!K(I6^0](B")
    ("u" . "((I_$B'U(I_(B)(I3O0(B")
    ("U" . "(-$B!2(B-)(I3B@^(B"))
  "*aa $B$rF~NO$9$k$H$-$N(B key$B$H(B aa $B$N(B alist$B!#(B
message mode $B$G(B prefix-key key $B$HF~NO$9$k;v$G(B aa $B$rF~NO$G$-$k!#(B"
  :type '(repeat (cons string string))
  :group 'navi2ch-message)

;; net variables
(defcustom navi2ch-net-http-proxy
  (if (string= (getenv "HTTP_PROXY") "")
      nil
    (getenv "HTTP_PROXY"))
  "*Proxy Server $B$N(B url"
  :type '(choice (string :tag "proxy $B$r;XDj(B")
		 (const :tag "proxy $B$r;H$o$J$$(B" nil))
  :group 'navi2ch-net)

(defcustom navi2ch-net-http-proxy-userid nil
  "Proxy $BG'>Z$K;H$&%f!<%6L>!#(B"
  :type '(choice (string :tag "$B%f!<%6L>$r;XDj(B")
		 (const :tag "$B%f!<%6L>$r;H$o$J$$(B" nil))
  :group 'navi2ch-net)

(defcustom navi2ch-net-http-proxy-password nil
  "Proxy $BG'>Z$K;H$&%Q%9%o!<%I!#(B"
  :type '(choice (string :tag "$B%Q%9%o!<%I$r;XDj(B")
		 (const :tag "$B%Q%9%o!<%I$r;H$o$J$$(B" nil))
  :group 'navi2ch-net)

(defcustom navi2ch-net-force-update nil
  "*$B99?7$,$"$C$?$+$r3NG'$;$:$K99?7$9$k$+!#(B
`non-nil' $B$J$i$P3NG'$7$J$$(B"
  :type 'boolean
  :group 'navi2ch-net)

(defcustom navi2ch-net-check-margin 100
  "*$B$"$\!<$s$,$"$C$?$+3NG'$9$k0Y$N%P%$%H?t(B"
  :type 'integer
  :group 'navi2ch-net)

(defcustom navi2ch-net-turn-back-step 1000
  "*$B$"$\!<$s$,$"$C$?$H$-$KESCf$+$iFI$_D>$90Y$N%P%$%H?t!#(B
$BF|K\8lJQ$@$J(B($B4@(B)$B!#(B"
  :type 'integer
  :group 'navi2ch-net)

(defcustom navi2ch-net-turn-back-when-aborn t
  "*$B$"$\!<$s$,$"$C$?$H$-ESCf$+$iFI$_D>$9$+!#(B
`non-nil'$B$J$iFI$_D>$9(B"
  :type 'boolean
  :group 'navi2ch-net)

(defcustom navi2ch-net-save-old-file-when-aborn 'ask
  "*$B$"$\!<$s$,$"$C$?$H$-85$N%U%!%$%k$rJ]B8$9$k$+!#(B
nil $B$J$iJ]B8$7$J$$(B
ask $B$J$iJ]B8$9$kA0$K<ALd$9$k(B
$B$=$l0J30$N(B non-nil $B$JCM$J$i2?$bJ9$+$:$KJ]B8$9$k!#(B"
  :type '(choice (const :tag "$B<ALd$9$k(B" ask)
		 (const :tag "$BJ9$+$:$KJ]B8(B" t)
		 (const :tag "$BJ]B8$7$J$$(B" nil))
  :group 'navi2ch-net)

(defcustom navi2ch-net-inherit-process-coding-system nil
  "*`inherit-process-coding-system' $B$N(B navi2ch $B$G$NB+G{CM(B"
  :type 'boolean
  :group 'navi2ch-net)

(defcustom navi2ch-net-accept-gzip t
  "*Accept-Encoding: gzip $B$rIU2C$9$k$+$I$&$+!#(B
non-nil $B$J$iIU2C$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-net)

(defcustom navi2ch-net-gunzip-program "gzip"
  "*gunzip $B$N%W%m%0%i%`L>!#(B"
  :type 'file
  :group 'navi2ch-net)

(defcustom navi2ch-net-gunzip-args '("-d" "-c")
  "*gunzip $B$r8F=P$9$H$-$N0z?t!#(B"
  :type '(repeat :tag "$B0z?t(B" string)
  :group 'navi2ch-net)

;;; hooks
(defvar navi2ch-hook nil)
(defvar navi2ch-exit-hook nil)
(defvar navi2ch-save-status-hook nil)
(defvar navi2ch-load-status-hook nil)
(defvar navi2ch-before-startup-hook nil)
(defvar navi2ch-after-startup-hook nil)
(defvar navi2ch-list-mode-hook nil)
(defvar navi2ch-list-exit-hook nil)
(defvar navi2ch-list-after-sync-hook nil)
(defvar navi2ch-board-mode-hook nil)
(defvar navi2ch-board-exit-hook nil)
(defvar navi2ch-board-before-sync-hook nil)
(defvar navi2ch-board-after-sync-hook nil)
(defvar navi2ch-board-select-board-hook nil)
(defvar navi2ch-article-mode-hook nil)
(defvar navi2ch-article-exit-hook nil)
(defvar navi2ch-article-before-sync-hook nil)
(defvar navi2ch-article-after-sync-hook nil)
(defvar navi2ch-article-arrange-message-hook nil)
(defvar navi2ch-bookmark-mode-hook nil)
(defvar navi2ch-bookmark-exit-hook nil)
(defvar navi2ch-articles-mode-hook nil)
(defvar navi2ch-articles-exit-hook nil)
(defvar navi2ch-history-mode-hook nil)
(defvar navi2ch-history-exit-hook nil)
(defvar navi2ch-search-mode-hook nil)
(defvar navi2ch-search-exit-hook nil)
(defvar navi2ch-message-mode-hook nil)
(defvar navi2ch-message-exit-hook nil)
(defvar navi2ch-message-before-send-hook nil)
(defvar navi2ch-message-after-send-hook nil)
(defvar navi2ch-message-setup-message-hook nil)
(defvar navi2ch-message-setup-sage-message-hook nil)
(defvar navi2ch-bm-mode-hook nil)
(defvar navi2ch-bm-exit-hook nil)
(defvar navi2ch-popup-article-mode-hook nil)
(defvar navi2ch-popup-article-exit-hook nil)
(defvar navi2ch-head-mode-hook nil)
(defvar navi2ch-head-exit-hook nil)
;; load hooks
(defvar navi2ch-article-load-hook nil)
(defvar navi2ch-articles-load-hook nil)
(defvar navi2ch-board-misc-load-hook nil)
(defvar navi2ch-board-load-hook nil)
(defvar navi2ch-bookmark-load-hook nil)
(defvar navi2ch-face-load-hook nil)
(defvar navi2ch-head-load-hook nil)
(defvar navi2ch-history-load-hook nil)
(defvar navi2ch-list-load-hook nil)
(defvar navi2ch-message-load-hook nil)
(defvar navi2ch-mona-load-hook nil)
(defvar navi2ch-net-load-hook nil)
(defvar navi2ch-popup-article-load-hook nil)
(defvar navi2ch-search-load-hook nil)
(defvar navi2ch-util-load-hook nil)
(defvar navi2ch-vars-load-hook nil)
(defvar navi2ch-load-hook nil)

;;; errors symbols
(put 'navi2ch-update-failed 'error-conditions '(error navi2ch-errors navi2ch-update-failed))

;;; global keybindings
;; $BJL$N>l=j$NJ}$,$$$$$s$+$J!#(B
(defvar navi2ch-global-map nil
  "navi2ch $B$N$I$N%b!<%I$G$b;H$($k(B keymap$B!#(B")
(unless navi2ch-global-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-f" 'navi2ch-article-find-file)
    (define-key map "\C-c\C-g" 'navi2ch-list-goto-board)
    (define-key map "\C-c\C-t" 'navi2ch-toggle-offline)
    (define-key map "\C-c\C-u" 'navi2ch-goto-url)
    (define-key map "\C-c\C-v" 'navi2ch-version)
    ;; (define-key map "\C-c1" 'navi2ch-one-pane)
    ;; (define-key map "\C-c2" 'navi2ch-two-pane)
    ;; (define-key map "\C-c3" 'navi2ch-three-pane)
    (setq navi2ch-global-map map)))

(defvar navi2ch-global-view-map nil
  "navi2ch $B$N(B message $B%b!<%I0J30$G;H$($k(B keymap$B!#(B")
(unless navi2ch-global-view-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map navi2ch-global-map)
    (define-key map "1" 'navi2ch-one-pane)
    ;; (define-key map "2" 'navi2ch-two-pane)
    (define-key map "3" 'navi2ch-three-pane)
    (define-key map "<" 'beginning-of-buffer)
    (define-key map ">" 'navi2ch-end-of-buffer)
    (define-key map "B" 'navi2ch-bookmark-goto-bookmark)
    (define-key map "g" 'navi2ch-list-goto-board)
    (define-key map "G" 'navi2ch-list-goto-board)
    (define-key map "n" 'next-line)
    (define-key map "p" 'previous-line)
    (define-key map "t" 'navi2ch-toggle-offline)
    (define-key map "V" 'navi2ch-version)
    (setq navi2ch-global-view-map map)))

(run-hooks 'navi2ch-vars-load-hook)
;;; navi2ch-vars.el ends here
