;;; navi2ch-util.el --- useful utilities for navi2ch

;; Copyright (C) 2000-2002 by Navi2ch Project
;; Copyright (C) 1993-2000 Free Software Foundation, Inc.

;; Author: Taiki SUGAWARA <taiki@users.sourceforge.net>
;; Keywords: network, 2ch

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

;;; Code:
(provide 'navi2ch-util)
(defvar navi2ch-util-ident
  "$Id$")

(eval-when-compile (require 'cl))
(require 'timezone)
(require 'browse-url)
(require 'base64)

(require 'navi2ch-vars)

(defvar navi2ch-mode-line-identification nil)
(make-variable-buffer-local 'navi2ch-mode-line-identification)

(defvar navi2ch-replace-html-tag-alist
  '(("&gt;" . ">")
    ("&lt;" . "<")
    ("&quot;" . "\"")
    ("&nbsp;" . " ")
    ("&amp;" . "&")
    ("<br>" . "\n")
    ("$B!w!.(B" . ","))
  "$BCV49$9$k(B html $B$N%?%0$NO"A[%j%9%H(B($B@55,I=8=$O;H$($J$$(B)")

(defvar navi2ch-replace-html-tag-regexp-alist
  '(("<[^<>]+>" . "")
    ("&#[0-9]+;" . "$B".(B"))
  "$BCV49$9$k(B html $B$N%?%0$NO"A[%j%9%H(B($B@55,I=8=(B)
$B@55,I=8=$,I,MW$J$$>l9g$O(B `navi2ch-replace-html-tag-alist' $B$KF~$l$k(B")

(defvar navi2ch-replace-html-tag-regexp
  (concat (regexp-opt (mapcar 'car navi2ch-replace-html-tag-alist))
	  "\\|"
	  (mapconcat 'car navi2ch-replace-html-tag-regexp-alist "\\|"))
  "$BCV49$9$k(B html $B$N%?%0$N@55,I=8=(B
`navi2ch-replace-html-tag-alist' $B$+$i@8@.$5$l$k(B")

(defconst navi2ch-base64-begin-delimiter "----BEGIN BASE64----"
  "base64$B%3!<%I$NA0$KA^F~$9$k%G%j%_%?!#(B")
(defconst navi2ch-base64-end-delimiter "----END BASE64----"
  "base64$B%3!<%I$N8e$KA^F~$9$k%G%j%_%?!#(B")

(defconst navi2ch-base64-begin-delimiter-regexp
  (format "^%s\\((\\([^\)]+\\))\\)?.*$"
          (regexp-quote navi2ch-base64-begin-delimiter))
  "base64$B%3!<%I$NA0$N%G%j%_%?$K%^%C%A$9$k@55,I=8=!#(B")
(defconst navi2ch-base64-end-delimiter-regexp
  (format "^%s.*$" (regexp-quote navi2ch-base64-end-delimiter))
  "base64$B%3!<%I$N8e$N%G%j%_%?$K%^%C%A$9$k@55,I=8=!#(B")
(defconst navi2ch-base64-susv3-begin-delimiter-regexp
  "^begin-base64 \\([0-7]+\\) \\([^ \n]+\\)$"
  "SUSv3$B$N(Buuencode$B$G:n@.$5$l$k(Bbase64$B%3!<%I$NA0$N%G%j%_%?$K%^%C%A$9$k@55,I=8=(B")
(defconst navi2ch-base64-susv3-end-delimiter-regexp
  "^====$"
  "SUSv3$B$N(Buuencode$B$G:n@.$5$l$k(Bbase64$B%3!<%I$N8e$N%G%j%_%?$K%^%C%A$9$k@55,I=8=(B")

(defconst navi2ch-base64-line-regexp
  (concat
   "^\\([+/0-9A-Za-z][+/0-9A-Za-z][+/0-9A-Za-z][+/0-9A-Za-z]\\)*"
   "[+/0-9A-Za-z][+/0-9A-Za-z][+/0-9A-Za-z=][+/0-9A-Za-z=] *$")
  "base64$B%3!<%I$N$_$,4^$^$l$k9T$K%^%C%A$9$k@55,I=8=!#(B")

(defvar navi2ch-coding-system 'shift_jis)

(defvar navi2ch-offline nil "$B%*%U%i%$%s%b!<%I$+$I$&$+(B")
(defvar navi2ch-online-indicator  "[ON] ")
(put 'navi2ch-online-indicator 'risky-local-variable t)
(defvar navi2ch-offline-indicator "[--] ")
(put 'navi2ch-offline-indicator 'risky-local-variable t)
(defvar navi2ch-modeline-online navi2ch-online-indicator)
(defvar navi2ch-modeline-offline navi2ch-offline-indicator)

;; shut up XEmacs warnings
(eval-when-compile
  (defvar message-log-max)
  (defvar minibuffer-allow-text-properties))

;;;; macros
(defmacro navi2ch-ifxemacs (then &rest else)
  "If on XEmacs, do THEN, else do ELSE.
Like \"(if (featurep 'xemacs) THEN ELSE)\", but expanded at
compilation time.  Because byte-code of XEmacs is not compatible with
GNU Emacs's one, this macro is very useful."
  (if (featurep 'xemacs)
      then
    (cons 'progn else)))
;; Navi2ch$B$N%3!<%I$r%O%/$9$k?M$O"-$r(B~/.emacs$B$K$bF~$l$H$-$^$7$g$&!#(B
(put 'navi2ch-ifxemacs 'lisp-indent-function 1)

(defmacro navi2ch-define-mouse-key (map num command)
  (if (featurep 'xemacs)
      `(define-key ,map ',(intern (format "button%d" num)) ,command)
    `(define-key ,map ,(vector (intern (format "mouse-%d" num))) ,command)))

;; from apel
(defmacro navi2ch-defalias-maybe (symbol definition)
  "Define SYMBOL as an alias for DEFINITION if SYMBOL is not defined.
See also the function `defalias'."
  (setq symbol (eval symbol))
  (or (and (fboundp symbol)
           (not (get symbol 'defalias-maybe)))
      (` (or (fboundp (quote (, symbol)))
             (prog1
                 (defalias (quote (, symbol)) (, definition))
               ;; `defalias' updates `load-history' internally.
               (put (quote (, symbol)) 'defalias-maybe t))))))

;; from apel
(defmacro navi2ch-set-buffer-multibyte (flag)
  (if (featurep 'xemacs)
      flag
    `(set-buffer-multibyte ,flag)))

;; from apel
(defmacro navi2ch-string-as-unibyte (string)
  (if (featurep 'xemacs)
      string
    `(string-as-unibyte ,string)))

(defmacro navi2ch-string-as-multibyte (string)
  (if (featurep 'xemacs)
      string
    `(string-as-multibyte ,string)))

;;; from Wanderlust (elmo-date.el)
(defmacro navi2ch-make-sortable-date (datevec)
  "Make a sortable string from DATEVEC."
  (` (timezone-make-sortable-date
      (aref (, datevec) 0)
      (aref (, datevec) 1)
      (aref (, datevec) 2)
      (aref (, datevec) 3))))

(defmacro navi2ch-match-string-no-properties (num &optional string)
  (if (featurep 'xemacs)
      `(match-string ,num ,string)
    `(match-string-no-properties ,num ,string)))

(defmacro navi2ch-with-default-file-modes (mode &rest body)
  "default-file-modes $B$r(B MODE $B$K$7$F(B BODY $B$r<B9T$9$k!#(B"
  (let ((temp (make-symbol "--file-modes-temp--")))
    `(let ((,temp (default-file-modes)))
       (unwind-protect
	   (progn
	     (set-default-file-modes ,mode)
	     ,@body)
	 (set-default-file-modes ,temp)))))

(put 'navi2ch-with-default-file-modes 'lisp-indent-function 1)


;;;; other misc stuff
(defsubst navi2ch-replace-string (regexp rep string
					 &optional all fixedcase literal)
  "STRING $B$K4^$^$l$k(B REGEXP $B$r(B REP $B$GCV49$9$k!#(B
REP $B$,4X?t$N>l9g$O!"%^%C%A$7$?J8;zNs$r0z?t$K$7$F$=$N4X?t$r8F$S=P$9!#(B

FIXEDCASE$B!"(BLITERAL $B$O(B `replace-match' $B$K$=$N$^$^EO$5$l$k!#(B

ALL $B$,(B non-nil $B$J$i$P!"%^%C%A$7$?%F%-%9%H$r$9$Y$FCV49$9$k!#(Bnil $B$J$i(B
$B:G=i$N(B1$B$D$@$1$rCV49$9$k!#(B

REGEXP $B$,8+$D$+$i$J$$>l9g!"(BSTRING $B$r$=$N$^$^JV$9!#(B"
  (save-match-data
    (if all
	;; Emacs 21 $B$N(B replace-regexp-in-string $B$N%Q%/$j!#(B
	(let ((start 0)
	      (l (length string))
	      mb me str matches)
	  (while (and (< start l)
		      (string-match regexp string start))
	    (setq mb (match-beginning 0)
		  me (match-end 0))
	    (if (= mb me)
		(setq me (min l (1+ mb))))
	    (string-match regexp (setq str (substring string mb me)))
	    (setq matches
		  (cons (replace-match (if (stringp rep)
					   rep
					 (funcall rep (match-string 0 str)))
				       fixedcase literal str)
			(cons (substring string start mb)
			      matches)))
	    (setq start me))
	  (apply #'concat (nreverse (cons (substring string start l)
					  matches))))
      (when (string-match regexp string)
	(setq string (replace-match (if (stringp rep)
					rep
				      (funcall rep (match-string 0 string)))
				    fixedcase literal string)))
      string)))

(defun navi2ch-bigint-int-to-list (i)
  (if (listp i)
      i
    (mapcar (lambda (x)
              (- x 48))
            (string-to-list (int-to-string i)))))

(defun navi2ch-bigint-multiply (a b)
  (setq a (reverse (navi2ch-bigint-int-to-list a))
        b (reverse (navi2ch-bigint-int-to-list b)))
  (let (list c)
    (dolist (y b)
      (let ((z 0))
        (setq list (cons
                    (append c (mapcar
                               (lambda (x)
                                 (let (w)
                                   (setq w (+ (* x y) z))
                                   (setq z (/ w 10))
                                   (mod w 10))) a)
                            (if (> z 0) (list z)))
                    list)))
      (setq c (cons 0 c)))
    (let (list2)
      (dolist (x list)
        (setq list2 (navi2ch-bigint-add list2 (reverse x))))
      list2)))

(defun navi2ch-bigint-add (a b)
  (setq a (reverse (navi2ch-bigint-int-to-list a))
        b (reverse (navi2ch-bigint-int-to-list b)))
  (let ((x 0) list)
    (while (or a b)
      (let (y)
        (setq y (+ (or (car a) 0) (or (car b) 0) x))
        (setq x (/ y 10))
        (setq list (cons (mod y 10) list))
        (setq a (cdr a)
              b (cdr b))))
    (if (> x 0) (setq list (cons x list)))
    list))

(defun navi2ch-insert-file-contents (file &optional begin end)
  (let ((coding-system-for-read navi2ch-coding-system)
        (coding-system-for-write navi2ch-coding-system))
    (insert-file-contents file nil begin end)))

(defun navi2ch-expand-file-name (file)
  (expand-file-name file navi2ch-directory))

(defun navi2ch-uudecode-region (start end)
  (interactive "r")
  (let (dir)
    (save-window-excursion
      (delete-other-windows)
      (setq dir (read-file-name "directory name: ")))
    (unless (file-directory-p dir)
      (error "%s is not directory" dir))

    (let ((default-directory dir)
          (coding-system-for-read 'binary)
          (coding-system-for-write 'binary)
          rc)
      (setq rc (apply
                'call-process-region
                start end
                navi2ch-uudecode-program
                nil nil nil
                navi2ch-uudecode-args))
      (when (not (= rc 0))
        (error "uudecode error")))))

;; (defun navi2ch-read-number (prompt)
;;   "$B?t;z$r(B minibuffer $B$+$iFI$_9~$`(B"
;;   (catch 'loop
;;     (while t
;;       (let (elt)
;;         (setq elt (read-string prompt init history default))
;;         (cond ((string= elt "")
;;                (throw 'loop nil))
;;               ((string-match "^[ \t]*0+[ \t]*$" elt)
;;                (throw 'loop 0))
;;               ((not (eq (string-to-number elt) 0))
;;                (throw 'loop (string-to-int elt)))))
;;       (message "Please enter a number.")
;;       (sit-for 1))))

(defsubst navi2ch-replace-html-tag-to-string (str)
  (or (cdr (if case-fold-search
	       (assoc-ignore-case str navi2ch-replace-html-tag-alist)
	     (assoc str navi2ch-replace-html-tag-alist)))
      (save-match-data
	(let ((alist navi2ch-replace-html-tag-regexp-alist)
	      elt value)
	  (while alist
	    (setq elt (car alist)
		  alist (cdr alist))
	    (when (string-match (car elt) str)
	      (setq value (cdr elt)
		    alist nil)))
	  value))
      ""))

(defsubst navi2ch-replace-html-tag (str)
  (let ((case-fold-search t))
    (navi2ch-replace-string navi2ch-replace-html-tag-regexp
			    'navi2ch-replace-html-tag-to-string
			    str t)))

(defsubst navi2ch-replace-html-tag-with-buffer ()
  (goto-char (point-min))
  (let ((case-fold-search t))
    (while (re-search-forward navi2ch-replace-html-tag-regexp nil t)
      (replace-match (navi2ch-replace-html-tag-to-string (match-string 0))))))

(defsubst navi2ch-replace-html-tag-with-temp-buffer (str)
  (with-temp-buffer
    (insert str)
    (navi2ch-replace-html-tag-with-buffer)
    (buffer-string)))

(defun navi2ch-read-char (&optional prompt)
  "PROMPT (non-nil $B$N>l9g(B) $B$rI=<($7$F(B `read-char' $B$r8F$S=P$9!#(B"
  (let ((cursor-in-echo-area t)
	(message-log-max nil)
	c)
    (if prompt
	(message "%s" prompt))
    (setq c (read-char))
    (if prompt
	(message "%s%c" prompt c))
    c))

(defun navi2ch-read-char-with-retry (prompt retry-prompt list)
  "PROMPT $B$rI=<((B (non-nil $B$N>l9g(B) $B$7$F(B `read-char' $B$r8F$S=P$9!#(B
$BF~NO$5$l$?J8;z$,(B LIST $B$K4^$^$l$J$$>l9g!"(BRETRY-PROMPT (nil $B$N>l9g$O(B
PROMPT) $B$rI=<($7$F:FEY(B `read-char' $B$r8F$V!#(B"
  (let ((retry t) c)
    (while retry
      (setq c (navi2ch-read-char prompt))
      (cond ((memq c list)
	     (setq retry nil))
	    ((eq c 12)
	     (recenter))
	    (t
	     (ding)
	     (setq prompt (or retry-prompt prompt)))))
    c))

(defun navi2ch-y-or-n-p (prompt &optional quit-symbol)
  (let* ((prompt (concat prompt "(y, n, or q) "))
	 (c (navi2ch-read-char-with-retry
	     prompt
	     (concat "Please answer y, n, or q.  " prompt)
	     '(?q ?Q ?y ?Y ?\  ?n ?N ?\177))))
    (cond ((memq c '(?q ?Q))
	   (or quit-symbol nil))
	  ((memq c '(?y ?Y ?\ ))
	   t)
	  ((memq c '(?n ?N ?\177))
	   nil))))

(defsubst navi2ch-boundp (symbol)
  "SYMBOL $B$,%P%$%s%I$5$l$F$$$J$$;~$O(B nil $B$rJV$9!#(B
bnoundp $B$H0c$$!"(BSYMBOL $B$,%P%$%s%I$5$l$F$$$k;~$O(B t $B$G$O$J$/%7%s%\%k$rJV$9!#(B"
  (and (boundp symbol) symbol))

(defsubst navi2ch-fboundp (symbol)
  "SYMBOL $B$,%P%$%s%I$5$l$F$$$J$$;~$O(B nil $B$rJV$9!#(B
fbnoundp $B$H0c$$!"(BSYMBOL $B$,%P%$%s%I$5$l$F$$$k;~$O(B t $B$G$O$J$/%7%s%\%k$rJV$9!#(B"
  (and (fboundp symbol) symbol))

(defun navi2ch-browse-url-internal (url &rest args)
  (let ((browse-url-browser-function (or navi2ch-browse-url-browser-function
					 browse-url-browser-function))
	(new-window-flag (symbol-value (or (navi2ch-boundp
					    'browse-url-new-window-flag)
					   (navi2ch-boundp
					    'browse-url-new-window-p)))))
    (if (eq browse-url-browser-function 'navi2ch-browse-url)
	(error "Set navi2ch-browse-url-browser-function correctly."))
    (cond ((and navi2ch-browse-url-image-program ; images
		(file-name-extension url)
		(member (downcase (file-name-extension url))
			navi2ch-browse-url-image-extentions))
	   (navi2ch-browse-url-image url))
	  (t				; others
	   (setq args (or args (list new-window-flag)))
	   (apply 'browse-url url args)))))

(defun navi2ch-browse-url-image (url &optional new-window)
  ;; new-window ignored
  "Ask the WWW browser defined by `browse-url-image-program' to load URL.
Default to the URL around or before point.  A fresh copy of the
browser is started up in a new process with possible additional arguments
`navi2ch-browse-url-image-args'.  This is appropriate for browsers which
don't offer a form of remote control."
  (interactive (browse-url-interactive-arg "URL: "))
  (if (not navi2ch-browse-url-image-program)
    (error "No browser defined (`navi2ch-browse-url-image-program')"))
  (apply 'start-process (concat navi2ch-browse-url-image-program url) nil
         navi2ch-browse-url-image-program
         (append navi2ch-browse-url-image-args (list url))))

;; from apel
(defsubst navi2ch-put-alist (item value alist)
  "Modify ALIST to set VALUE to ITEM.
If there is a pair whose car is ITEM, replace its cdr by VALUE.
If there is not such pair, create new pair (ITEM . VALUE) and
return new alist whose car is the new pair and cdr is ALIST.
\[tomo's ELIS like function]"
  (let ((pair (assoc item alist)))
    (if pair
        (progn
          (setcdr pair value)
          alist)
      (cons (cons item value) alist))))

(defun navi2ch-next-property (point prop)
  (when (get-text-property point prop)
    (setq point (next-single-property-change point prop)))
  (when point
    (setq point (next-single-property-change point prop)))
  point)

(defun navi2ch-previous-property (point prop)
  (when (get-text-property point prop)
    (setq point (previous-single-property-change point prop)))
  (when point
    (unless (get-text-property (1- point) prop)
      (setq point (previous-single-property-change point prop)))
    (when point
      (1- point))))

(defun navi2ch-set-minor-mode (mode name map)
  (make-variable-buffer-local mode)
  (unless (assq mode minor-mode-alist)
    (setq minor-mode-alist
          (cons (list mode name) minor-mode-alist)))
  (unless (assq mode minor-mode-map-alist)
    (setq minor-mode-map-alist
          (cons (cons mode map) minor-mode-map-alist))))

(defun navi2ch-call-process-buffer (program &rest args)
  "$B:#$N(B buffer $B$G(B PROGRAM $B$r8F$s$GJQ99$9$k(B"
  (apply 'call-process-region (point-min) (point-max) program t t nil args))

(defun navi2ch-alist-list-to-alist (list key1 &optional key2)
  (mapcar
   (lambda (x)
     (cons (cdr (assq key1 x))
	   (if key2
	       (cdr (assq key2 x))
	     x)))
   list))

(defun navi2ch-write-region (begin end filename)
  (write-region begin end filename nil 'no-msg))

(defun navi2ch-enable-readcgi-p (host)
  "HOST $B$,(B read.cgi $B$r;H$&%[%9%H$+$I$&$+$rJV$9!#(B"
  (if navi2ch-enable-readcgi
      (not (member host
		   navi2ch-disable-readcgi-host-list))
    (member host
	    navi2ch-enable-readcgi-host-list)))

(defun navi2ch-get-major-mode (buffer)
  (when (get-buffer buffer)
    (save-excursion
      (set-buffer buffer)
      major-mode)))

(defun navi2ch-set-mode-line-identification ()
  (let ((offline '(navi2ch-offline navi2ch-modeline-offline navi2ch-modeline-online)))
    (unless navi2ch-mode-line-identification
      (setq navi2ch-mode-line-identification
	    (default-value 'mode-line-buffer-identification)))
    (setq mode-line-buffer-identification
          (list offline
                navi2ch-mode-line-identification)))
  (force-mode-line-update t))

(defun navi2ch-make-datevec (time)
  (timezone-fix-time
   (let ((dtime (decode-time time)))
     (apply 'timezone-make-arpa-date
            (mapcar (lambda (x) (nth x dtime)) '(5 4 3 2))))
   nil nil))

;;; from Wanderlust (elmo-date.el)
(defun navi2ch-get-offset-datevec (datevec offset &optional time)
  (let ((year  (aref datevec 0))
        (month (aref datevec 1))
        (day   (aref datevec 2))
        (hour     (aref datevec 3))
        (minute   (aref datevec 4))
        (second   (aref datevec 5))
        (timezone (aref datevec 6))
        day-number p
        day-of-month)
    (setq p 1)
    (setq day-number (- (timezone-day-number month day year)
                        offset))
    (while (<= day-number 0)
      (setq year (1- year)
            day-number (+ (timezone-day-number 12 31 year)
                          day-number)))
    (while (> day-number (setq day-of-month
                               (timezone-last-day-of-month p year)))
      (setq day-number (- day-number day-of-month))
      (setq p (1+ p)))
    (setq month p)
    (setq day day-number)
    (timezone-fix-time
     (format "%d %s %d %s %s"
             day
             (car (rassq month timezone-months-assoc))
             year
             (if time
                 (format "%d:%d:%d" hour minute second)
               "0:00")
             (cadr timezone)) nil nil)))

(defun navi2ch-end-of-buffer ()
  (interactive)
  (goto-char (point-max))
  (forward-line -1))

(defun navi2ch-base64-write-region (start end &optional filename)
  "START$B$H(BEND$B$N4V$N%j!<%8%g%s$r(Bbase64$B%G%3!<%I$7!"(BFILENAME$B$K=q$-=P$9!#(B

$B%j!<%8%g%sFb$K(B`navi2ch-base64-begin-delimiter'$B$,$"$k>l9g$O$=$l0JA0$rL5(B
$B;k$7!"(B`navi2ch-base64-end-delimiter'$B$,$"$k>l9g$O$=$l0J9_$N(B
`navi2ch-base64-begin-delimiter'$B$^$G!"$b$7$/$O%j!<%8%g%s$N:G8e$^$G$rL5(B
$B;k$9$k!#$5$i$K!":G=i$K(B`navi2ch-base64-line-regexp'$B$K%^%C%A$9$kD>A0$^$G(B
$B$H!":G8e$K(B`navi2ch-base64-line-regexp'$B$K%^%C%A$9$kD>8e$^$G$bL5;k$9$k!#(B

base64$B%G%3!<%I$9$Y$-FbMF$,$J$$>l9g$O%(%i!<$K$J$k!#(B"
  (interactive "r")
  (save-excursion
    (let ((buf (current-buffer))
	  (default-filename nil)
	  (mode nil)
	  (susv3 nil))
      ;; insert$B$7$?8e$K:o$k$N$OL5BL$J$N$G$"$i$+$8$a9J$j9~$s$G$*$/(B
      (goto-char start)
      (cond
       ((re-search-forward navi2ch-base64-begin-delimiter-regexp end t)
	(setq default-filename (match-string 2))
	(goto-char (match-end 0)))
       ((re-search-forward navi2ch-base64-susv3-begin-delimiter-regexp end t)
	(setq default-filename (match-string 2)
	      mode (string-to-number (match-string 1) 8)
	      susv3 t)
	(goto-char (match-end 0))))
      (if (re-search-forward navi2ch-base64-line-regexp end t)
	  (setq start (match-beginning 0))
	(error "No base64 data"))
      (goto-char end)
      (if (or (and susv3 (re-search-backward
			  navi2ch-base64-susv3-end-delimiter-regexp start t))
	      (re-search-backward navi2ch-base64-end-delimiter-regexp start t))
	  (goto-char (match-beginning 0)))
      (if (re-search-backward navi2ch-base64-line-regexp start t)
	  (setq end (match-end 0)))
      (with-temp-buffer
	(let ((buffer-file-coding-system 'binary)
	      (coding-system-for-write 'binary)
	      ;; auto-compress-mode$B$r(Bdisable$B$K$9$k(B
	      (inhibit-file-name-operation 'write-region)
	      (inhibit-file-name-handlers (cons 'jka-compr-handler
						inhibit-file-name-handlers))
	      cur-point)
	  (insert-buffer-substring buf start end)
	  (goto-char (point-min))
	  (while (re-search-forward navi2ch-base64-end-delimiter-regexp
				    nil t)
	    (setq cur-point (match-beginning 0))
	    (if (re-search-forward navi2ch-base64-begin-delimiter-regexp
				   nil t)
		(delete-region cur-point (match-end 0))
	      (delete-region cur-point (point-max)))
	    (goto-char cur-point))
	  (base64-decode-region (point-min) (point-max))
	  (if (not filename)
	      (setq filename (read-file-name
			      (if default-filename
				  (format "Decode to file (default `%s'): "
					  default-filename)
				"Decode to file: ")
			      nil default-filename)))
	  (when (file-directory-p filename)
	    (setq filename (expand-file-name default-filename filename)))
	  (when (or (not (file-exists-p filename))
		    (y-or-n-p (format "File `%s' exists; overwrite? "
				      filename)))
	    (write-region (point-min) (point-max) filename)
	    (if (and susv3 mode)
		(condition-case nil
		    (set-file-modes filename mode)
		  (error nil)))))))))

(defun navi2ch-base64-insert-file (filename)
  "FILENAME$B$r(Bbase64$B%(%s%3!<%I$7!"8=:_$N%]%$%s%H$KA^F~$9$k!#(B"
  (interactive "fEncode and insert file: ")
  (save-excursion
    (let ((str nil))
      (with-temp-buffer
	(let ((buffer-file-coding-system 'binary))
	  (insert-file-contents-literally filename)
	  (base64-encode-region (point-min) (point-max))
	  (goto-char (point-min))
	  (while (search-forward "\n" nil t)
	    (replace-match ""))
	  (goto-char (point-min))
	  (insert (format "%s(%s)\n" navi2ch-base64-begin-delimiter
			  (file-name-nondirectory filename)))
	  (while (= (move-to-column navi2ch-base64-fill-column)
		    navi2ch-base64-fill-column)
	    (insert "\n"))
	  (goto-char (point-max))
	  (insert (format "\n%s\n" navi2ch-base64-end-delimiter))
	  (setq str (buffer-string))))
      (insert str))))

(defun navi2ch-url-to-host (url)
  (when (and url (string-match "http://\\([^/]+\\)" url))
    (match-string 1 url)))

(defun navi2ch-read-string (prompt &optional initial-input history)
  (let ((minibuffer-allow-text-properties nil))
    (read-string prompt initial-input history)))

(defun navi2ch-temp-directory ()
  (let ((dir (expand-file-name "tmp" navi2ch-directory)))
    (or (file-directory-p dir)
	(make-directory dir))
    dir))

(defun navi2ch-strip-properties (obj)
  "OBJ $BCf$NJ8;zNs$r:F5"E*$KC5$7!"%F%-%9%HB0@-$r30$7$?%*%V%8%'%/%H$rJV$9!#(B
$B85$N(B OBJ $B$OJQ99$7$J$$!#(B"
  (cond
   ((consp obj)
    (let* ((ret (cons (car obj) (cdr obj)))
	   (seq ret))
      ;; $BD9$$%j%9%H$r%3%T!<$9$k:]$K%9%?%C%/%*!<%P!<%U%m!<$K$J$k$N$G(B
      ;; $B:F5"$r%k!<%W$KE83+!#(B
      (while (consp seq)
	(setcar seq (navi2ch-strip-properties (car seq)))
	(if (consp (cdr seq))
	    (setcdr seq (cons (cadr seq) (cddr seq)))
	  (setcdr seq (navi2ch-strip-properties (cdr seq))))
	(setq seq (cdr seq)))
      ret))
   ((stringp obj)
    (let ((str (copy-sequence obj)))
      (set-text-properties 0 (length str) nil str)
      str))
   ((vectorp obj)
    (vconcat (mapcar 'navi2ch-strip-properties obj)))
   (t obj)))

(defun navi2ch-add-replace-html-tag (tag value)
  "TAG $B$rI=<($9$k:]$K(B VALUE $B$GCV$-49$($k!#(B
$B$N$N$?$s$N(BAA$B$rI=<($9$k$J$i(B ~/.navi2ch/init.el $B$K(B
\(navi2ch-add-replace-html-tag (navi2ch-string-as-multibyte \"\\372D\")
                              \"$B#v(B\")
$B$H=q$/!#(B"
  ;; $B$N$N$?$s$N8}$r(B navi2ch-replace-html-tag-alist $B$KF~$l$k$H(B
  ;; regexp-opt $B$,L58B:F5"$K$J$C$A$c$&$N$l$9!#(B
  (add-to-list 'navi2ch-replace-html-tag-regexp-alist
	       (cons (regexp-quote tag) value))
  (setq navi2ch-replace-html-tag-regexp
	(concat (regexp-opt (mapcar 'car navi2ch-replace-html-tag-alist))
		"\\|"
		(mapconcat 'car
			   navi2ch-replace-html-tag-regexp-alist "\\|"))))

(defun navi2ch-add-replace-html-tag-regexp (tag value)
  "TAG $B$rI=<($9$k:]$K(B VALUE $B$GCV$-49$($k!#(B
TAG $B$O@55,I=8=!#(B"
  (add-to-list 'navi2ch-replace-html-tag-regexp-alist
	       (cons tag value))
  (setq navi2ch-replace-html-tag-regexp
	(concat (regexp-opt (mapcar 'car navi2ch-replace-html-tag-alist))
		"\\|"
		(mapconcat 'car
			   navi2ch-replace-html-tag-regexp-alist "\\|"))))

(defun navi2ch-filename-to-url (filename)
  (concat "file://" (expand-file-name filename)))

(defun navi2ch-chop-/ (dirname)
  (save-match-data
    (if (string-match "/\\'" dirname)
	(replace-match "" nil t dirname)
      dirname)))

(defun navi2ch-rename-file (file newname &optional ok-if-already-exists)
  (rename-file (navi2ch-chop-/ file)
	       (navi2ch-chop-/ newname) ok-if-already-exists))

(defsubst navi2ch-propertize (string &rest properties)
  "Return a copy of STRING with text properties added.
First argument is the string to copy.
Remaining arguments form a sequence of PROPERTY VALUE pairs for text
properties to add to the result"
  ;; $B%I%-%e%a%s%H$O(B Emacs 21 $B$+$i%3%T%Z(B
  (prog1
      (setq string (copy-sequence string))
    (add-text-properties 0 (length string) properties string)))

(defun navi2ch-set-keymap-default-binding (map command)
  "$B%-!<%^%C%W$N%G%U%)%k%H%P%$%s%I$r@_Dj$9$k!#(B"
  (funcall (if (fboundp 'set-keymap-default-binding)
	       'set-keymap-default-binding
	     (lambda (map command)
	       (setcdr map (cons (cons t command) (cdr map)))
	       command))
	   map command))

(defun navi2ch-char-valid-p (obj)
  "$B%*%V%8%'%/%H$,%-%c%i%/%?$+$I$&$+D4$Y$k!#(B"
  (navi2ch-ifxemacs
      (characterp obj)
    (char-valid-p obj)))

;;; $B%m%C%/(B
;; $B:G$bHFMQE*$J(B mkdir $B%m%C%/$r<BAu$7$F$_$?!#(B
;; DIRECTORY $B$K(B LOCKNAME $B$H$$$&%G%#%l%/%H%j$,$"$k>l9g$O$=$N%G%#%l%/%H%j$O(B
;; $B%m%C%/$5$l$F$$$k$H$$$&$3$H$K$J$k!#(B
(defun navi2ch-lock-directory (directory &optional lockname)
  "LOCKNAME $B$r;H$$!"(BDIRECTORY $B$r%m%C%/$9$k!#(B
LOCKNAME $B$,>JN,$5$l$?>l9g$O(B \"lockdir\" $B$r;HMQ$9$k!#(B
LOCKNAME $B$,@dBP%Q%9$G$O$J$$>l9g!"(BDIRECTORY $B$+$i$NAjBP%Q%9$H$7$F07$&!#(B
$B%m%C%/$K@.8y$7$?$i(B non-nil $B$r!"<:GT$7$?$i(B nil $B$rJV$9!#(B"
  (setq lockname (navi2ch-chop-/ (expand-file-name (or lockname "lockdir")
						   directory))
	directory (file-name-directory lockname))
  (let ((make-directory-function (or (navi2ch-fboundp 'make-directory-internal)
				     'make-directory)))
    (if (not (file-exists-p lockname))	; lockdir $B$,$9$G$K$"$k$H<:GT(B
	(condition-case error
	    (and (progn
		   ;; $B$^$:!"?F%G%#%l%/%H%j$r:n$C$F$*$/!#(B
		   (unless (file-directory-p directory)
		     (make-directory directory t))
		   (file-directory-p directory))
		 (progn
		   ;; file-name-handler-alist $B$,$"$k$H(B mkdir $B$,D>@\8F(B
		   ;; $B$P$l$J$$2DG=@-$,$"$k!#(B
		   (let ((file-name-handler-alist nil))
		     (funcall make-directory-function lockname))
		   (file-exists-p lockname))) ; $BG0$N$?$a!"3NG'$7$F$*$/(B
	  (error
	   (message "%s" (error-message-string error))
	   (sit-for 3)
	   (discard-input)
	   nil)))))

(defun navi2ch-unlock-directory (directory &optional lockname)
  "LOCKNAME $B$r;H$$!"(BDIRECTORY $B$N%m%C%/$r2r=|$9$k!#(B
LOCKNAME $B$,>JN,$5$l$?>l9g$O(B \"lockdir\" $B$r;HMQ$9$k!#(B
LOCKNAME $B$,@dBP%Q%9$G$O$J$$>l9g!"(BDIRECTORY $B$+$i$NAjBP%Q%9$H$7$F07$&!#(B
$B%m%C%/$N2r=|$K@.8y$7$?$i(B non-nil $B$r!"<:GT$7$?$i(B nil $B$rJV$9!#(B"
  (setq lockname (navi2ch-chop-/ (expand-file-name (or lockname "lockdir")
						   directory)))
  (ignore-errors
    (delete-directory lockname))
  (not (file-exists-p lockname)))

(defun navi2ch-line-beginning-position (&optional n)
  "N - 1 $B9T@h$N9TF,$N>l=j$rJV$9!#(B"
  (save-excursion
    (beginning-of-line n)
    (point)))

;; line-beginning-position $B$,;H$($k$J$i$=$C$A$r;H$&(B
(if (fboundp 'line-beginning-position)
    (defalias 'navi2ch-line-beginning-position 'line-beginning-position))

(defun navi2ch-line-end-position (&optional n)
  "N - 1 $B9T@h$N9TKv$N>l=j$rJV$9!#(B"
  (save-excursion
    (end-of-line n)
    (point)))

;; line-end-position $B$,;H$($k$J$i$=$C$A$r;H$&(B
(if (fboundp 'line-end-position)
    (defalias 'navi2ch-line-end-position 'line-end-position))

(run-hooks 'navi2ch-util-load-hook)
;;; navi2ch-util.el ends here
