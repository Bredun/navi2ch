;;; navi2ch-vars.el --- User variables for navi2ch.

;; Copyright (C) 2001 by Navi2ch Project

;; Author: Taiki SUGAWARA <taiki@users.sourceforge.net>
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

(defconst navi2ch-on-xemacs (featurep 'xemacs))
(defconst navi2ch-on-emacs21 (and (not navi2ch-on-xemacs)
                                  (>= emacs-major-version 21)))
(defconst navi2ch-on-emacs20 (and (not navi2ch-on-xemacs)
                                  (= emacs-major-version 20)))

(defgroup navi2ch nil
  "*Navigator for 2ch."
  :prefix "navi2ch-"
  :link '(url-link :tag "Navi2ch Project$B%[!<%`%Z!<%8(B" "http://navi2ch.sourceforge.net/")
  :link '(custom-manual :tag "$B%^%K%e%"%k(B (Info)" "(navi2ch)top")
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
(defcustom navi2ch-ask-when-exit 'y-or-n-p
  "*non-nil $B$J$i!"(Bnavi2ch $B=*N;$N3NG'%a%C%;!<%8$rI=<($9$k!#(B"
  :type '(choice (const :tag "yes-or-no-p $B$G3NG'(B" yes-or-no-p)
                 (const :tag "y-or-n-p $B$G3NG'(B" y-or-n-p)
                 (const :tag "$BJ9$+$:$K=*N;(B" nil))
  :group 'navi2ch)

(defcustom navi2ch-directory "~/.navi2ch"
  "*$B%-%c%C%7%e%U%!%$%k$J$I$rJ]B8$9$k%G%#%l%/%H%j!#(B

$B$3$N%G%#%l%/%H%j$O!"%-%c%C%7%e$NNL$K$h$C$F(B 100MB $B0J>e$KKD$i$`(B
$B$3$H$b$"$k!#%-%c%C%7%e$N@)8B$K$D$$$F$O(B `navi2ch-board-expire-date'
$B$r;2>H!#(B"
  :type 'directory
  :group 'navi2ch)

(defcustom navi2ch-uudecode-program "uudecode"
  "*uudecode $B$9$k$N$K;H$&%W%m%0%i%`!#(B"
  :type 'string
  :group 'navi2ch)

(defcustom navi2ch-uudecode-args nil
  "*uudecode $B$r<B9T$9$k$H$-$N0z?t!#(B"
  :type '(repeat :tag "$B0z?t(B" string)
  :group 'navi2ch)

(defcustom navi2ch-init-file (concat
                              (file-name-as-directory navi2ch-directory)
                              "init")
  "*navi2ch $B$N=i4|2=%U%!%$%k!#(B"
  :type 'file
  :group 'navi2ch)

(defcustom navi2ch-enable-readcgi nil
  "*non-nil $B$J$i!"%U%!%$%k<hF@$K(B read.cgi $B$N(B raw mode $B$rMxMQ$9$k!#(B"
  :type 'boolean
  :group 'navi2ch)

(defcustom navi2ch-enable-readcgi-host-list nil
  "*read.cgi $B$N(B raw mode $B$r;H$C$F%U%!%$%k$r<h$C$F$/$k%[%9%H$N%j%9%H!#(B
`navi2ch-enable-readcgi' $B$,(B nil $B$N;~$KM-8z!#(B"
  :type '(repeat (string :tag "$B%[%9%H(B"))
  :group 'navi2ch)

(defcustom navi2ch-disable-readcgi-host-list nil
  "*read.cgi $B$N(B raw mode $B$r;H$o$J$$$G%U%!%$%k$r<h$C$F$/$k%[%9%H$N%j%9%H!#(B
`navi2ch-enable-readcgi' $B$,(B t $B$N;~$KM-8z(B"
  :type '(repeat (string :tag "$B%[%9%H(B"))
  :group 'navi2ch)

(defcustom navi2ch-browse-url-image-program nil
  "*`navi2ch-browse-url-image' $B$K;H$&%W%m%0%i%`!#(B"
  :type '(choice string (const :tag "None" nil))
  :group 'navi2ch)

(defcustom navi2ch-browse-url-image-args nil
  "*`navi2ch-browse-url-image-program' $B$KM?$($k0z?t!#(B"
  :type '(repeat (string :tag "Argument"))
  :group 'navi2ch)

(defcustom navi2ch-browse-url-image-extentions '("jpg" "jpeg" "gif" "png")
  "*`navi2ch-browse-url-image' $B$GI=<($9$k2hA|$N3HD%;R!#(B"
  :type '(repeat (string :tag "$B3HD%;R(B"))
  :group 'navi2ch)

(defcustom navi2ch-base64-fill-column 64
  "*base64 $B$G%(%s%3!<%I$5$l$?J8;zNs$r(B fill $B$9$kJ8;z?t!#(B"
  :type 'integer
  :group 'navi2ch)

(defcustom navi2ch-2ch-host-list
  '("cocoa.2ch.net")
  "*2$B$A$c$s$M$k$H$_$J$9(B host $B$N%j%9%H!#(B"
  :type '(repeat (string :tag "$B%[%9%H(B"))
  :group 'navi2ch)

;;; list variables
(defcustom navi2ch-list-window-width 20
  "*$BHD0lMw%&%#%s%I%&$N2#I}!#(B"
  :type 'integer
  :group 'navi2ch-list)

(defcustom navi2ch-list-etc-file-name "etc.txt"
  "*$B!V$=$NB>!W%+%F%4%j$KF~$l$kHD$r=q$$$F$*$/%U%!%$%k!#(B"
  :type 'file
  :group 'navi2ch-list)

(defcustom navi2ch-list-stay-list-window nil
  "* non-nil $B$J$i!"HD$rA*$s$@$"$HHD0lMw%P%C%U%!$rI=<($7$?$^$^$K$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-list)

(defcustom navi2ch-list-bbstable-url "http://www6.ocn.ne.jp/~mirv/2chmenu.html"
  "*bbstable $B$N(B URL$B!#(B"
  :type 'string
  :group 'navi2ch-list)

(defcustom navi2ch-list-init-open-category nil
  "*non-nil $B$J$i!"HD0lMw$N%+%F%4%j$r%G%U%)%k%H$G$9$Y$F3+$$$FI=<($9$k!#(B"
  :type 'boolean
  :group 'navi2ch-list)

(defcustom navi2ch-list-indent-width 2
  "*$BHD0lMw%P%C%U%!$G$NHDL>$N%$%s%G%s%HI}!#(B"
  :type 'integer
  :group 'navi2ch-list)

(defcustom navi2ch-list-etc-category-name "$B$=$NB>(B"
  "*$B!V$=$NB>!W%+%F%4%j$NL>A0!#(B"
  :type 'string
  :group 'navi2ch-list)

(defcustom navi2ch-list-global-bookmark-category-name "$B%V%C%/%^!<%/(B"
  "*$B!V%V%C%/%^!<%/!W%+%F%4%j$NL>A0!#(B"
  :type 'string
  :group 'navi2ch-list)

(defcustom navi2ch-list-sync-update-on-boot t
  "*non-nil $B$J$i!"(Bnavi2ch $B5/F0;~$K>o$KHD0lMw$r<h$j$K$$$/!#(B
nil $B$J$i$P<jF0$G99?7$7$J$$$+$.$j<h$j$K$$$+$J$$!#(B"
  :type 'boolean
  :group 'navi2ch-list)

(defcustom navi2ch-list-load-category-list t
  "*non-nil $B$J$i!"A02s$N=*N;;~$K3+$$$F$$$?%+%F%4%j$r5/F0;~$K:F$S3+$/!#(B"
  :type 'boolean
  :group 'navi2ch-list)

;;; board variables
(defcustom navi2ch-board-max-line nil
  "*$B%@%&%s%m!<%I$9$k(B subject.txt $B$N9T?t!#(Bnil $B$J$iA4It%@%&%s%m!<%I$9$k!#(B"
  :type '(choice (integer :tag "$B9T?t$r;XDj(B")
		 (const :tag "$BA4$F(B" nil))
  :group 'navi2ch-board)

(defcustom navi2ch-board-expire-date 30
  "*$B:G8e$KJQ99$5$l$F$+$i$3$NF|?t0J>e$?$C$?%U%!%$%k$O(B expire ($B:o=|(B)$B$5$l$k!#(B
nil $B$J$i(B expire $B$7$J$$!#(B"
  :type '(choice (integer :tag "$BF|?t$r;XDj(B")
		 (const :tag "expire $B$7$J$$(B" nil))
  :group 'navi2ch-board)

(defcustom navi2ch-board-window-height 10
  "*$B%9%l$N0lMw$rI=<($9$k(B board window $B$N9b$5!#(B"
  :type 'integer
  :group 'navi2ch-board)

(defcustom navi2ch-board-check-updated-article-p t
  "*non-nil $B$J$i!"?7$7$$%l%9$,$"$C$?$+%A%'%C%/$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-board)

(defcustom navi2ch-board-view-logo-program
  (if (eq window-system 'w32)
      "fiber"
    "xv")
  "*$B%m%4$r8+$k$N$K;H$&%W%m%0%i%`!#(B"
  :type 'file
  :group 'navi2ch-board)

(defcustom navi2ch-board-view-logo-args nil
  "*$B%m%4$r8+$k$N$K;H$&%W%m%0%i%`$N0z?t!#(B"
  :type '(repeat (string :tag "$B0z?t(B"))
  :group 'navi2ch-board)

(defcustom navi2ch-board-delete-old-logo t
  "*non-nil $B$J$i!"?7$7$$%m%4$r%@%&%s%m!<%I$7$?$H$-$K8E$$%m%4$r>C$9!#(B"
  :type 'boolean
  :group 'navi2ch-board)

(defcustom navi2ch-board-hide-updated-article nil
  "*non-nil $B$J$i!"(Bnavi2ch-board-updated-mode $B$G(B hide $B$5$l$?%9%l%C%I$rI=<($7$J$$!#(B"
  :type 'boolean
  :group 'navi2ch-board)

(defcustom navi2ch-bm-subject-width 50
  "*$B3F%9%l$NBjL>$NI}!#(B"
  :type 'integer
  :group 'navi2ch-board)

(defcustom navi2ch-bm-mark-and-move t
  "*$B%^!<%/$7$?$"$H$N%]%$%s%?$NF0:n!#(B
nil $B$J$i0\F0$7$J$$(B
non-nil $B$J$i2<$K0\F0$9$k(B
'follow $B$J$i0JA00\F0$7$?J}8~$K0\F0$9$k(B"
  :type '(choice (const :tag "$B0\F0$7$J$$(B" nil)
		 (const :tag "$B2<$K0\F0(B" t)
		 (const :tag "$B0JA00\F0$7$?J}8~$K0\F0(B" follow))
  :group 'navi2ch-board)

(defcustom navi2ch-bm-empty-subject "navi2ch: no subject"
  "*subject $B$,L5$$$H$-$KBe$jI=<($9$k(B subject$B!#(B"
  :type 'string
  :group 'navi2ch-board)

(defcustom navi2ch-history-max-line 100
  "*$B%R%9%H%j$N9T?t$N@)8B8B!#(Bnil $B$J$i$P@)8B$7$J$$!#(B"
  :type '(choice (integer :tag "$B:GBg$N9T?t$r;XDj(B")
		 (const :tag "$B@)8B$7$J$$(B" nil))
  :group 'navi2ch-board)

(defcustom navi2ch-bm-stay-board-window t
  "*non-nil $B$J$i!"%9%l$rA*$s$@$H$-$K%9%l0lMw$rI=<($7$?$^$^$K$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-board)

(defcustom navi2ch-bm-fetched-info-file (concat
                                         (file-name-as-directory navi2ch-directory)
                                         "fetched.txt")
  "*$B4{FI%9%l$N%j%9%H$rJ]B8$7$F$*$/%U%!%$%k!#(B"
  :type 'file
  :group 'navi2ch-board)

(defcustom navi2ch-bookmark-file (concat
                                  (file-name-as-directory navi2ch-directory)
                                  "bookmark2.txt")
  "*$B%0%m!<%P%k%V%C%/%^!<%/$rJ]B8$7$F$*$/%U%!%$%k!#(B"
  :type 'file
  :group 'navi2ch-board)

(defcustom navi2ch-history-file (concat
                                 (file-name-as-directory navi2ch-directory)
                                 "history.txt")
  "*$B%R%9%H%j$rJ]B8$7$F$*$/%U%!%$%k!#(B"
  :type 'file
  :group 'navi2ch-board)

(defcustom navi2ch-board-expire-bookmark-p nil
  "*expire $B$9$k$H$-$K(B bookarmk $B$5$l$F$$$k%9%l$b(B expire $B$9$k$+$I$&$+!#(B
non-nil $B$J$i$P(B expire $B$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-board)
  
(defcustom navi2ch-bm-board-name-from-file "From File"
  "*$B%U%!%$%k$+$iFI$_9~$s$@%9%l$rI=$o$9HDL>!#(B"
  :type 'string
  :group 'navi2ch-board)

;;; article variables
(defcustom navi2ch-article-aadisplay-program
  (if (eq window-system 'w32)
      "notepad"
    "aadisplay")
  "*AA $B$rI=<($9$k$?$a$K;H$&%W%m%0%i%`!#(B"
  :type 'string
  :group 'navi2ch-article)

(defcustom navi2ch-article-aadisplay-coding-system
  (if (eq window-system 'w32)
      'shift_jis-dos
    'euc-jp-unix)
  "*AA $B$rI=<($9$k%W%m%0%i%`$K$o$?$90l;~%U%!%$%k$N(B `coding-system'"
  :type 'coding-system
  :group 'navi2ch-article)

(defcustom navi2ch-article-view-aa-function
  (if (eq window-system 'w32)
      'navi2ch-article-popup-dialog
    'navi2ch-article-call-aadisplay)
  "*AA $B$rI=<($9$k$?$a$K;H$&4X?t!#(B"
  :type 'function
  :group 'navi2ch-article)

(defcustom navi2ch-article-enable-diff t
  "*non-nil $B$J$i%U%!%$%k$N:9J,<hF@$,M-8z$K$J$k!#(B
nil $B$K$9$k$H>o$K%U%!%$%kA4BN$rE>Aw$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-max-line nil
  "*$B%@%&%s%m!<%I$9$k5-;v$N9T?t!#(Bnil $B$J$i;D$j$r$9$Y$F%@%&%s%m!<%I$9$k!#(B"
  :type '(choice (integer :tag "$B7o?t$r;XDj(B")
		 (const :tag "$BA4$F(B" nil))
  :group 'navi2ch-article)

(defcustom navi2ch-article-enable-fill nil
  "*non-nil $B$J$i!"%9%l$N%a%C%;!<%8$r(B fill-region $B$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-enable-fill-list nil
  "*fill-region $B$9$kHD$N%j%9%H!#(B"
  :type '(repeat string)
  :group 'navi2ch-article)

(defcustom navi2ch-article-disable-fill-list nil
  "*fill-region $B$7$J$$HD$N%j%9%H!#(B"
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
  "*$B%a%C%;!<%8$N%U%#!<%k%I$N$&$A!"%Q!<%:BP>]$K$9$k$b$N$N%j%9%H!#(B
$BCY$/$F$b$$$$$s$J$i(B '(data mail name) $B$H$+$9$k$H$$$$$+$b(B"
  :type '(set (const :tag "$B5-;v(B" data)
              (const :tag "$B%a!<%k(B" mail)
              (const :tag "$BL>A0(B" name))
  :group 'navi2ch-article)

(defcustom navi2ch-article-goto-number-recenter t
  "*non-nil $B$J$i!"(Bgoto-number $B$7$?$"$H(B recenter $B$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-new-message-range '(100 . 1)
  "*$B%9%l$N%G%U%)%k%H$NI=<(HO0O!#=i$a$FFI$`%9%l$KE,MQ$9$k!#(B

$B$?$H$($P(B '(100 5) $B$r;XDj$9$k$H!"(Bnavi2ch $B$O%9%l$N@hF,$+$i(B100$B8D!"(B
$BKvHx$+$i(B5$B8D$N%a%C%;!<%8$@$1$r%P%C%U%!$KA^F~$7!"$=$N$"$$$@$N(B
$B%a%C%;!<%8$K$D$$$F$O=hM}$rHt$P$9!#(B"
  :type '(cons integer integer)
  :group 'navi2ch-article)

(defcustom navi2ch-article-exist-message-range '(1 . 100)
  "*$B%9%l$N%G%U%)%k%H$NI=<(HO0O!#4{FI%9%l$KE,MQ$9$k!#(B"
  :type '(cons integer integer)
  :group 'navi2ch-article)

(defcustom navi2ch-article-auto-range t
  "*non-nil $B$J$i!"$^$?I=<($7$F$J$$%9%l%C%I$NI=<(HO0O$r>!<j$K69$a$k!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-view-range-list
  '((1 . 50)
    (50 . 50)
    (1 . 100)
    (100 . 100))
  "*$B%9%l$NI=<(HO0O$rJQ$($k$H$-A*Br8uJd$H$7$F;H$&%j%9%H!#(B"
  :type '(repeat (cons integer integer))
  :group 'navi2ch-article)

(defcustom navi2ch-article-header-format-function
  'navi2ch-article-default-header-format-function
  "*NUMBER NAME MAIL DATE $B$r0z?t$K<h$j!"%l%9$N%X%C%@$rJV$94X?t!#(B"
  :type 'function
  :group 'navi2ch-article)

(defcustom navi2ch-article-citation-regexp
  "^[>$B!d(B]\\($\\|[^$>$B!d(B0-9$B#0(B-$B#9(B].*\\)"
  "*$B%l%9$N0zMQItJ,$N@55,I=8=!#(B"
  :type 'regexp
  :group 'navi2ch-article)

(defcustom navi2ch-article-number-regexp
  "[>$B!d(B<$B!c(B][>$B!d(B<$B!c(B ]*\\(\\([0-9$B#0(B-$B#9(B]+,\\)*[0-9$B#0(B-$B#9(B]+\\(-[0-9$B#0(B-$B#9(B]+\\)?\\)"
  "*$BF1$8%9%lFb$X$N%j%s%/$rI=$o$9@55,I=8=!#(B"
  :type 'regexp
  :group 'navi2ch-article)

(defcustom navi2ch-article-url-regexp
  "h?ttps?://\\([-a-zA-Z0-9_=?#$@~`%&*+|\\/.,:]+\\)"
  "*$B%l%9$N%F%-%9%H$N$&$A(B URL $B$H$_$J$9ItJ,$N@55,I=8=!#(B"
  :type 'regexp
  :group 'navi2ch-article)

(defcustom navi2ch-article-filter-list nil
  "*$B%9%l%C%I$N5-;v$r$$$8$k%U%#%k%?!<$N%j%9%H!#(B
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
  "*non-nil $B$J$i!"(B`navi2ch-article-goto-number' $B$7$?$H$3$m$,HO0O30$N$H$-(B
$B<+F0$G(B redraw $B$7$J$*$9!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-fix-range-diff 10
  "*`navi2ch-article-fix-range' $B$7$?$H$-$KLa$k%l%9$N?t!#(B"
  :type 'integer
  :group 'navi2ch-article)

(defcustom navi2ch-article-fix-range-when-sync t
  "*non-nil $B$J$i!"(B`navi2ch-article-sync' $B$GHO0O30$N$H$-(B
$B<+F0E*$K(B `navi2ch-article-view-range' $B$rJQ99$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-message-separator ?_
  "*$B%l%9$H%l%9$N6h@Z$j$K;H$&J8;z!#(B"
  :type 'character
  :group 'navi2ch-article)

(defcustom navi2ch-article-message-separator-width '(/ (window-width) 2)
  "*$B%l%9$H%l%9$r6h@Z$k%F%-%9%H$N2#I}!#(B
$BI}$r(B 80 $BJ8;z$K$7$?$$$J$i(B
\(setq navi2ch-article-message-separator-width 80)
window $B$NI}$$$C$Q$$$K$7$?$$$J$i(B
\(setq navi2ch-article-message-separator-width '(window-width))
$BEy;XDj$9$k!#(B"
  :type 'sexp
  :group 'navi2ch-article)

(defcustom navi2ch-article-auto-expunge nil
  "*non-nil $B$J$i!"%P%C%U%!$H$7$FJ];}$9$k%9%l$N?t$r(B
`navi2ch-article-max-buffers' $B0J2<$KJ]$D!#$3$N@)8BCM$rD6$($?$H$-$K$O!"(B
$B$$$A$P$s8E$$%P%C%U%!$r<+F0E*$K>C$9!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-max-buffers 20
  "*$B%P%C%U%!$H$7$FJ];}$9$k%9%l$N:GBg?t!#(B0 $B$J$i$PL5@)8B!#(B"
  :type '(choice (const :tag "$BL5@)8B(B" 0)
                 (integer :tag "$B@)8BCM(B"))
  :group 'navi2ch-article)

(defcustom navi2ch-article-cleanup-white-space-after-old-br t
  "*non-nil $B$J$i!"8E$$7A<0$N(B <br> $B$KBP1~$7$F9TF,$+$i6uGr$r<h$j=|$/!#(B
$B$?$@$7!"$9$Y$F$N(B <br> $B$ND>8e$K6uGr$,$"$k>l9g$K8B$k!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-cleanup-trailing-whitespace t
  "*non-nil $B$J$i!"%9%l$N3F9T$+$iKvHx$N6uGr$r<h$j=|$/!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-cleanup-trailing-newline t
  "*non-nil $B$J$i!"%9%l$N3F%l%9$+$iKvHx$N6u9T$r<h$j=|$/!#(B"
  :type 'boolean
  :group 'navi2ch-article)

(defcustom navi2ch-article-display-link-width '(1- (window-width))
  "*$B%9%l$N%j%s%/@h$J$I$r(B minibuffer $B$KI=<($9$k$H$-$NJ8;zNs$N:GBgD9!#(B
$B$3$l$h$jD9$$%F%-%9%H$O@Z$j5M$a$i$l$k!#(B
$B?tCM$N$[$+!"(Beval $B$G?tCM$rJV$9G$0U$N(B S $B<0$r;XDj$G$-$k!#(B"
  :type '(choice (integer :tag "$B?tCM$G;XDj(B")
                 (sexp :tag "$B4X?t$H$+(B"))
  :group 'navi2ch-article)

(defcustom navi2ch-article-auto-decode-base64-p nil
  "*non-nil $B$J$i!"%9%l$N(B BASE64 $B$G%(%s%3!<%I$5$l$?%F%-%9%H$r<+F0E83+$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-article)

;;; message variables
(defcustom navi2ch-message-user-name
  (cond ((featurep 'xemacs) "$BL>L5$7$5$s!w#X#E#m#a#c#s(B")
	((featurep 'meadow) "$BL>L5$7$5$s!w#M#e#a#d#o#w(B")
	(t "$BL>L5$7$5$s!w#E#m#a#c#s(B"))
  "*$B%G%U%)%k%H$NL>A0!#(B"
  :type 'string
  :group 'navi2ch-message)

(defcustom navi2ch-message-user-name-alist nil
  "*$BHD$4$H$N%G%U%)%k%H$NL>A0$N(B alist$B!#(B

$B$?$H$($P<!$N$h$&$K@_Dj$7$F$*$/$H!"%M%C%H%o!<%/HD$G$O(B \"anonymous\"$B!"(B
$B%F%l%SHVAHHD$G$O(B \"$BL>L5$7$5$s(B\" $B$,%G%U%)%k%H$NL>A0$K$J$k!#(B
  '((\"network\" . \"anonymous\")
    (\"tv\" . \"$BL>L5$7$5$s(B\"))"
  :type '(repeat (cons (string :tag "$BHD(B  ") (string :tag "$BL>A0(B")))
  :group 'navi2ch-message)

(defcustom navi2ch-message-mail-address nil
  "*$B%G%U%)%k%H$N%a!<%k%"%I%l%9!#(B"
  :type 'string
  :group 'navi2ch-message)

(defcustom navi2ch-message-ask-before-send t
  "*non-nil $B$J$i!"=q$-9~$_Aw?.$N3NG'%a%C%;!<%8$rI=<($9$k!#(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-ask-before-kill t
  "*non-nil $B$J$i!"=q$-$3$_%-%c%s%;%k$N3NG'%a%C%;!<%8$rI=<($9$k!#(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-always-pop-message nil
  "*non-nil $B$J$i!"?75,%a%C%;!<%8$r:n$k%3%^%s%I$O=q$-$+$1$N%l%9$r>o$KI|85$9$k!#(B
nil $B$J$i!"=q$-$+$1$rGK4~$7$F$$$$$+Ld$$9g$o$;$k!#(B
$B=q$-$+$1$N%a%C%;!<%8$N%P%C%U%!$,;D$C$F$$$k>l9g$K$@$1M-8z!#(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-wait-time 1
  "*$B%l%9$rAw$C$?$"$H%9%l$r%j%m!<%I$9$k$^$G$NBT$A;~4V(B($BIC(B)$B!#(B"
  :type 'integer
  :group 'navi2ch-message)

(defcustom navi2ch-message-remember-user-name t
  "*non-nil$B$J$i!"Aw$C$?%l%9$N%a!<%k%"%I%l%9Mw$r3P$($F$*$/!#(B
$BF1$8%9%l$G<!$K%l%9$9$k$H$-$O!"$=$l$,%G%U%)%k%H$N%a!<%k%"%I%l%9$K$J$k!#(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-cite-prefix "> "
  "*$B0zMQ$9$k$H$-$N@\F,<-!#(B"
  :type 'string
  :group 'navi2ch-message)

(defcustom navi2ch-message-trip nil
  "*trip $BMQ$NJ8;zNs!#=q$-$3$_;~$K(B From $B$N8e$m$KIU2C$5$l$k!#(B"
  :type '(choice (string :tag "trip $B$r;XDj(B")
		 (const :tag "trip $B$r;XDj$7$J$$(B" nil))
  :group 'navi2ch-message)

(defcustom navi2ch-message-aa-prefix-key "\C-c\C-a"
  "*AA $B$rF~NO$9$k0Y$N(B prefix-key$B!#(B"
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
  "*AA $B$rF~NO$9$k$H$-$N%-!<%P%$%s%I$H(B AA $B$N(B alist$B!#(B
message mode $B$G(B prefix-key key $B$HF~NO$9$k;v$G(B AA $B$rF~NO$G$-$k!#(B"
  :type '(repeat (cons string string))
  :group 'navi2ch-message)

(defcustom navi2ch-message-cleanup-trailing-whitespace nil
  "*non-nil $B$J$i!"Aw?.$9$k%l%9$+$i9TKv$N6uGr$r<h$j=|$/!#(B"
  :type 'boolean
  :group 'navi2ch-message)

(defcustom navi2ch-message-cleanup-trailing-newline nil
  "*non-nil $B$J$i!"Aw?.$9$k%l%9$+$iKvHx$N6u9T$r<h$j=|$/!#(B"
  :type 'boolean
  :group 'navi2ch-message)

;; net variables
(defcustom navi2ch-net-http-proxy
  (if (string= (getenv "HTTP_PROXY") "")
      nil
    (getenv "HTTP_PROXY"))
  "*HTTP $B%W%m%-%7$N(B URL$B!#(B"
  :type '(choice (string :tag "$B%W%m%-%7$r;XDj(B")
		 (const :tag "$B%W%m%-%7$r;H$o$J$$(B" nil))
  :group 'navi2ch-net)

(defcustom navi2ch-net-http-proxy-userid nil
  "$B%W%m%-%7G'>Z$K;H$&%f!<%6L>!#(B"
  :type '(choice (string :tag "$B%f!<%6L>$r;XDj(B")
		 (const :tag "$B%f!<%6L>$r;H$o$J$$(B" nil))
  :group 'navi2ch-net)

(defcustom navi2ch-net-http-proxy-password nil
  "$B%W%m%-%7G'>Z$K;H$&%Q%9%o!<%I!#(B"
  :type '(choice (string :tag "$B%Q%9%o!<%I$r;XDj(B")
		 (const :tag "$B%Q%9%o!<%I$r;H$o$J$$(B" nil))
  :group 'navi2ch-net)

(defcustom navi2ch-net-send-message-use-http-proxy t
  "*non-nil $B$J$i!"%l%9$rAw$k>l9g$J$I$G$b%W%m%-%7$r7PM3$9$k!#(B
$B$3$N%*%W%7%g%s$rM-8z$K$9$k$K$O!"(B`navi2ch-net-http-proxy' $B$r(B non-nil
$B$K@_Dj$9$k$3$H!#(B"
  :type 'boolean
  :group 'navi2ch-net)

(defcustom navi2ch-net-force-update nil
  "*non-nil $B$J$i!"%U%!%$%k$r<hF@$9$k$^$($K99?7$NM-L5$r3NG'$7$J$/$J$k!#(B
nil $B$J$i!"99?7$5$l$F$$$J$$%U%!%$%k$NITI,MW$JE>Aw$O$7$J$$!#(B"
  :type 'boolean
  :group 'navi2ch-net)

(defcustom navi2ch-net-check-margin 100
  "*$B$"$\!<$s$,$"$C$?$+3NG'$9$k0Y$N%P%$%H?t!#(B"
  :type 'integer
  :group 'navi2ch-net)

(defcustom navi2ch-net-turn-back-step 1000
  "*$B$"$\!<$s$,$"$C$?$H$-$KESCf$+$iFI$_D>$90Y$N%P%$%H?t!#F|K\8lJQ$@$J(B($B4@(B)$B!#(B"
  :type 'integer
  :group 'navi2ch-net)

(defcustom navi2ch-net-turn-back-when-aborn t
  "*non-nil $B$J$i!"$"$\!<$s$,$"$C$?$H$-%9%l$rESCf$+$iFI$_D>$9!#(B"
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
  "*`inherit-process-coding-system' $B$N(B navi2ch $B$G$NB+G{CM!#(B"
  :type 'boolean
  :group 'navi2ch-net)

(defcustom navi2ch-net-accept-gzip t
  "*non-nil $B$J$i!"%U%!%$%k<u?.$K(B GZIP $B%(%s%3!<%G%#%s%0$r;H$&!#(B"
  :type 'boolean
  :group 'navi2ch-net)

(defcustom navi2ch-net-gunzip-program "gzip"
  "*gunzip $B$K;H$&%W%m%0%i%`!#(B"
  :type 'file
  :group 'navi2ch-net)

(defcustom navi2ch-net-gunzip-args '("-d" "-c" "-q")
  "*gunzip $B$r8F$S=P$9$H$-$N0z?t!#(B"
  :type '(repeat :tag "$B0z?t(B" string)
  :group 'navi2ch-net)

(defcustom navi2ch-net-enable-http11 nil
  "*non-nil $B$J$i!"(BHTTP/1.1 $B$r;HMQ$9$k!#(B"
  :type 'boolean
  :group 'navi2ch-net)

;;; update variables
(defcustom navi2ch-update-file (concat
                                (file-name-as-directory navi2ch-directory)
                                "navi2ch-update.el")
  "*Navi2ch $B$N<+F099?7$KMxMQ$9$k%U%!%$%k$N%m!<%+%k%U%!%$%kL>!#(B"
  :type 'string
  :group 'navi2ch)

(defcustom navi2ch-update-base-url
  "http://navi2ch.sourceforge.net/autoupdate/"
  "*$B<+F099?7$9$k%U%!%$%k$,$"$k>l=j$N(B BASE URL$B!#(B"
  :type 'string
  :group 'navi2ch)

(defcustom navi2ch-update-url (concat navi2ch-update-base-url
				      (file-name-nondirectory
				       navi2ch-update-file))
  "*$B<+F099?7$KMxMQ$9$k%U%!%$%k$N(B URL$B!#(B"
  :type 'string
  :group 'navi2ch)

(defcustom navi2ch-auto-update t
  "*non-nil $B$J$i!"5/F0;~$K(B `navi2ch-update-file' $B$r99?7$7$F<B9T$9$k!#(B
$B%U%!%$%k$,<B9T$5$l$k$N$O!"(B
 - `navi2ch-update-file' $B$,99?7$5$l$F$$$F!"(B
 - $B$=$3$GI=<($5$l$k3NG'$9$k%a%C%;!<%8$K(B yes $B$HEz$($?$H$-(B
$B$N$_!#(B

$B%d%P$$%3!<%I$,F~$C$F$$$k$H$^$:$$$N$G!"<B9T$9$kA0$K$^$:(B navi2ch $B$N(B
$B%9%l$J$I$r3NG'$7$?$[$&$,$$$$!#(B"
  :type 'boolean
  :group 'navi2ch)

(defcustom navi2ch-icon-directory
  (cond ((fboundp 'locate-data-directory)
	 (locate-data-directory "navi2ch"))
	((let ((icons (expand-file-name "navi2ch/icons/"
					data-directory)))
	   (if (file-directory-p icons)
	       icons)))
	((let ((icons (expand-file-name "icons/"
					(file-name-directory
					 (locate-library "navi2ch")))))
	   (if (file-directory-p icons)
	       icons))))
  "* $B%"%$%3%s%U%!%$%k$,CV$+$l$?%G%#%l%/%H%j!#(Bnil $B$J$i%"%$%3%s$r;H$o$J$$!#(B"
  :type '(choice (directory :tag "directory") (const :tag "nil" nil))
  :group 'navi2ch)


;; Splash screen.
(defcustom navi2ch-splash-display-logo (when (or (featurep 'xemacs)
                                                 (featurep 'image)
                                                 (featurep 'bitmap))
                                         t)
  "If it is T, show graphic logo in the startup screen.  You can set it to
a symbol `bitmap', `xbm' or `xpm' in order to force the image format."
  :type '(radio (const :tag "Off" nil)
                (const :tag "On (any format)" t)
                (const xpm)
                (const xbm)
                (const :tag "bitmap (using BITMAP-MULE)" bitmap))
  :group 'navi2ch)

(defcustom navi2ch-display-splash-screen t
  "*Display splash screen at start time."
  :type 'boolean
  :group 'navi2ch)

;; Mona fonts.
(when (or navi2ch-on-xemacs navi2ch-on-emacs21)
  (defgroup navi2ch-mona nil
    "*Navi2ch, $B%b%J!<%U%)%s%H(B

Mona fonts ($B%b%J!<%U%)%s%H(B) $B$O(B 2$B$A$c$s$M$k$N%"%9%-!<%"!<%H(B ($B0J2<(B AA) $B$r(B
X11 $B>e$G8+$k$?$a$K:n$i$l$?%U%j!<$N%U%)%s%H$G$9!#(B

2$B$A$c$s$M$k$N%"%9%-!<%"!<%H$O$=$NB?$/$,(B MS P $B%4%7%C%/(B 12pt $B$r(B
$BA[Dj$7$F$D$/$i$l$F$*$j!"(B X $B$N8GDjI}%U%)%s%H$r;H$C$?(B Netscape $BEy$G8+$k$H(B
$B$:$l$F$7$^$$$^$9!#(B $B%b%J!<%U%)%s%H$O%U%j!<$GG[I[$5$l$F$$$k(B
$BEl1@(B ($B$7$N$N$a(B) $B%U%)%s%H$NJ8;zI}$r(B MS P $B%4%7%C%/$K9g$o$;$?$b$N$G!"(B
$B$3$l$r;H$&$H(B Windows $B%f!<%68~$1$K:n$i$l$?(B AA $B$r@5$7$/8+$k$3$H$,$G$-$^$9!#(B

                   (http://members.tripod.co.jp/s42335/mona/ $B$h$j(B)"
    :prefix "navi2ch-"
    :link '(url-link :tag "$B%b%J!<%U%)%s%H(B $B%[!<%`%Z!<%8(B"
                     "http://members.tripod.co.jp/s42335/mona/")
    :group 'navi2ch
    :load 'navi2ch-mona)

  (defcustom navi2ch-mona-enable nil
    "*non-nil $B$J$i!"%b%J!<%U%)%s%H$r;H$C$F%9%l$rI=<($9$k!#(B"
    :set (function (lambda (symbol value)
                     (if value
                         (navi2ch-mona-setup)
                       (navi2ch-mona-undo-setup))
                     (set-default symbol value)))
    :initialize 'custom-initialize-default
    :type 'boolean
    :group 'navi2ch-mona)

  (when navi2ch-mona-enable
    (add-hook 'navi2ch-load-hook
              (lambda () (load "navi2ch-mona")))))

;; folder icons. filename relative to navi2ch-icon-directory
(defvar navi2ch-online-icon "plugged.xpm"
  "*Icon file for online state.")
(defvar navi2ch-offline-icon "unplugged.xpm"
  "*Icon file for offline state.")

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
(defvar navi2ch-bm-select-board-hook nil)
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
    ;; (define-key map "\C-c\C-g" 'navi2ch-list-goto-board)
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
    (define-key map "2" 'navi2ch-two-pane)
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
