;;; navi2ch-util.el --- useful utilities for navi2ch

;; Copyright (C) 2000 by 2$B$A$c$s$M$k(B

;; Author: (not 1)
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
(eval-when-compile (require 'cl))

(require 'navi2ch-vars)
(require 'timezone)

(unless (and (fboundp 'base64-encode-region)
	     (fboundp 'base64-decode-region))
  (cond ((locate-library "mel")
	 (require 'mel))
	((locate-library "base64")
	 (require 'base64))))

(defvar navi2ch-mode-line-identification nil)
(make-variable-buffer-local 'navi2ch-mode-line-identification)

(defvar navi2ch-replace-html-tag-alist
  '(("&gt;" . ">")
    ("&lt;" . "<")
    ("&quot;" . "\"")
    ("&nbsp;" . " ")
    ("&amp;" . "&")
    (" <br> " . "\n")		; $BL5$/$F$bF0$/$1$I!"$"$k$H(B10%$B$/$i$$B.$/$J$k(B
    ("$B!w!.(B" . ","))
  "$BCV49$9$k(B html $B$N%?%0$NO"A[%j%9%H(B($B@55,I=8=$O;H$($J$$(B)")

(defvar navi2ch-replace-html-tag-regexp-alist
  '((" *<br> " . "\n")
    ("<[^<>]+>" . "")
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
(defconst navi2ch-base64-line-regexp
  (concat
   "^\\([+/0-9A-Za-z][+/0-9A-Za-z][+/0-9A-Za-z][+/0-9A-Za-z]\\)*"
   "[+/0-9A-Za-z][+/0-9A-Za-z][+/0-9A-Za-z=][+/0-9A-Za-z=] *$")
  "base64$B%3!<%I$N$_$,4^$^$l$k9T$K%^%C%A$9$k@55,I=8=!#(B")

(defsubst navi2ch-replace-string (rep new str &optional all)
  (if all
      (let (start (len (length new)))
	(while (setq start (string-match rep str start))
	  (setq str (replace-match new nil nil str))
	  (setq start (+ start new))))
    (when (string-match rep str)
      (setq str (replace-match new nil nil str))))
  str)

(defmacro navi2ch-define-mouse-key (map num command)
  (if (featurep 'xemacs)
      `(define-key ,map ',(intern (format "button%d" num)) ,command)
    `(define-key ,map ,(vector (intern (format "mouse-%d" num))) ,command)))

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
    list))

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
  (or (cdr (assoc str navi2ch-replace-html-tag-alist))
      (save-match-data
	(let ((alist navi2ch-replace-html-tag-regexp-alist)
	      elt value)
	  (while alist
	    (setq elt (car alist)
		  alist (cdr alist))
	    (when (string-match (car elt) str)
	      (setq value (cdr elt)
		    alist nil)))
	  value))))

(defsubst navi2ch-replace-html-tag (str)
  (unless (string= str "")
    (let (start new)
      (while (setq start (string-match navi2ch-replace-html-tag-regexp
				       str start))
	(setq new (navi2ch-replace-html-tag-to-string (match-string 0 str)))
	(setq str (replace-match new nil nil str))
	(setq start (+ start (length new))))))
  str)

(defsubst navi2ch-replace-html-tag-with-temp-buffer (str)
  (with-temp-buffer
    (insert str)
    (goto-char (point-min))
    (while (re-search-forward navi2ch-replace-html-tag-regexp nil t)
      (replace-match (navi2ch-replace-html-tag-to-string (match-string 0))))
    (buffer-string)))
      
(defun navi2ch-y-or-n-p (prompt &optional quit-symbol)
  (let ((prompt (concat prompt "(y, n, or q) "))
	(again nil))
    (catch 'exit
      (while t
	(message prompt)
	(let ((c (read-char)))
	  (cond ((memq c '(?q ?Q))
		 (message (concat prompt "q"))
		 (throw 'exit (or quit-symbol nil)))
		((memq c '(?y ?Y ?\ ))
		 (message (concat prompt "y"))
		 (throw 'exit t))
		((memq c '(?n ?N ?\177 ))
		 (message (concat prompt "n"))
		 (throw 'exit nil))
		((eq c 12)
		 (recenter))
		(t
		 (ding)
		 (or again
		     (setq prompt (concat "Please answer y, n, or q.  " prompt)
			   again t)))))))))
  
(defun navi2ch-browse-url (url)
  (cond ((and navi2ch-browse-url-image-program	; images
	      (file-name-extension url)
	      (member (downcase (file-name-extension url))
		      navi2ch-browse-url-image-extentions))
	 (navi2ch-browse-url-image url))
	(t (browse-url				; others
	    url
	    (cond ((boundp 'browse-url-new-window-p) browse-url-new-window-p)
		  ((boundp 'browse-url-new-window-flag) browse-url-new-window-flag))))))

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
(defun navi2ch-put-alist (item value alist)
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

(defsubst navi2ch-alist-list-to-alist (list key1 key2)
  (mapcar
   (lambda (x)
     (cons (cdr (assq key1 x))
	   (cdr (assq key2 x))))
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

(defun navi2ch-get-major-mode (buffer)
  (when (get-buffer buffer)
    (save-excursion
      (set-buffer buffer)
      major-mode)))

(defun navi2ch-set-mode-line-identification ()
  (let ((offline '(navi2ch-offline navi2ch-offline-off navi2ch-offline-on)))
    (unless navi2ch-mode-line-identification
      (setq navi2ch-mode-line-identification "%12b"))
    (setq mode-line-buffer-identification
          (list ""
                offline
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

;;; from Wanderlust (elmo-date.el)
(defmacro navi2ch-make-sortable-date (datevec)
  "Make a sortable string from DATEVEC."
  (` (timezone-make-sortable-date
      (aref (, datevec) 0)
      (aref (, datevec) 1)
      (aref (, datevec) 2)
      (aref (, datevec) 3))))

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
	  (default-filename nil))
      ;; insert$B$7$?8e$K:o$k$N$OL5BL$J$N$G$"$i$+$8$a9J$j9~$s$G$*$/(B
      (goto-char start)
      (when (re-search-forward navi2ch-base64-begin-delimiter-regexp end t)
	(setq default-filename (match-string 2))
	(goto-char (match-end 0)))
      (if (re-search-forward navi2ch-base64-line-regexp end t)
	  (setq start (match-beginning 0))
	(error "No base64 data"))
      (goto-char end)
      (if (re-search-backward navi2ch-base64-end-delimiter-regexp start t)
	  (goto-char (match-beginning 0)))
      (if (re-search-backward navi2ch-base64-line-regexp start t)
	  (setq end (match-end 0)))
      (with-temp-buffer
	(let ((buffer-file-coding-system 'binary)
	      (file-coding-system 'binary)
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
	  (if (or (not (file-exists-p filename))
		  (y-or-n-p (format "File `%s' exists; overwrite? "
				    filename)))
	      (write-region (point-min) (point-max) filename)))))))

(defun navi2ch-base64-insert-file (filename)
  "FILENAME$B$r(Bbase64$B%(%s%3!<%I$7!"8=:_$N%]%$%s%H$KA^F~$9$k!#(B"
  (interactive "fEncode and insert file: ")
  (save-excursion
    (let ((str nil))
      (with-temp-buffer
	(let ((buffer-file-coding-system 'binary)
	      (file-coding-system 'binary))
	  (insert-file-contents-literally filename)
	  (base64-encode-region (point-min) (point-max) t)
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

(provide 'navi2ch-util)


