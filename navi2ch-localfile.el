;;; navi2ch-localfile.el --- View localfile for Navi2ch.

;; Copyright (C) 2002 by Navi2ch Project

;; Author:
;; Part6 $B%9%l$N(B 427 $B$NL>L5$7$5$s(B
;; <http://pc.2ch.net/test/read.cgi/unix/1023884490/427>

;; Keywords: 2ch, network

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

;; etc.txt $B$K(B
;; ====
;; $B%m!<%+%k%U%!%$%k%F%9%H(B
;; x-localbbs:///tmp/localfile
;; localfile
;; ====
;; $B$N$h$&$K@_Dj$7$F$d$k$H!"%G%#%l%/%H%j(B /tmp/localfile $B$K=q$-9~$_$^$9!#(B

;;; Code:
(provide 'navi2ch-localfile)

(defvar navi2ch-localfile-ident
  "$Id$")

(eval-when-compile (require 'cl))

(require 'navi2ch-http-date)
(require 'navi2ch-multibbs)

(defcustom navi2ch-localfile-cache-name "localfile"
  "*$B%m!<%+%k(B BBS $B$N>pJs$rJ]B8$9$k%G%#%l%/%H%j$NL>A0!#(B
`navi2ch-directory' $B$+$i$NAjBP%Q%9$r;XDj$9$k!#(B"
  :type 'string
  :group 'navi2ch-localfile)

(defvar navi2ch-localfile-regexp "\\`x-localbbs://")
(defvar navi2ch-localfile-use-lock t)
(defvar navi2ch-localfile-lock-name "lockdir_localfile")

(defvar navi2ch-localfile-func-alist
  '((bbs-p		. navi2ch-localfile-p)
    (article-update 	. navi2ch-localfile-article-update)
    (send-message   	. navi2ch-localfile-send-message)
    (send-success-p 	. navi2ch-localfile-send-message-success-p)
    (error-string   	. navi2ch-localfile-navi2ch-net-get-content)
    (board-update	. navi2ch-localfile-board-update)
    (board-get-file-name . navi2ch-localfile-board-get-file-name)))

(defvar navi2ch-localfile-variable-alist
  '((coding-system	. shift_jis)))

(navi2ch-multibbs-regist 'localfile
			 navi2ch-localfile-func-alist
			 navi2ch-localfile-variable-alist)

;;-------------

;; internal functions like bbs.cgi
(defconst navi2ch-localfile-coding-system 'shift_jis-unix)

(defvar navi2ch-localfile-encode-html-tag-alist
  '(("<" . "&gt;")
    (">" . "&lt;")
    ("\n" . "<br>")))

(defvar navi2ch-localfile-subject-file-name "subject.txt")

(defun navi2ch-localfile-lock (dir)
  "`navi2ch-directory' $B$r%m%C%/$9$k!#(B"
  (when navi2ch-localfile-use-lock
    (let ((redo t)
	  error-message)
      (while redo
	(setq redo nil)
	(unless (navi2ch-lock-directory dir navi2ch-localfile-lock-name)
	  (setq error-message "$B%G%#%l%/%H%j$N%m%C%/$K<:GT$7$^$7$?!#(B")
	  (cond ((y-or-n-p (format "%s$B$b$&0lEY;n$7$^$9$+(B? "
				   error-message))
		 (setq redo t))
		((yes-or-no-p (format "%s$B4m81$r>5CN$GB3$1$^$9$+(B? "
				      error-message))
		 nil)
		(t
		 (error "lock failed"))))))))

(defun navi2ch-localfile-unlock (dir)
  "`dir' $B$N%m%C%/$r2r=|$9$k!#(B"
  (when navi2ch-localfile-use-lock
    (navi2ch-unlock-directory dir navi2ch-localfile-lock-name)))

(defun navi2ch-localfile-encode-string (string)
  (let* ((alist navi2ch-localfile-encode-html-tag-alist)
	 (regexp (regexp-opt (mapcar 'car alist))))
    (navi2ch-replace-string regexp (lambda (key)
				     (cdr (assoc key alist)))
			    string t)))

(defun navi2ch-localfile-encode-message (from mail time message
					      &optional subject)
  (format "%s<>%s<>%s<>%s<>%s\n"
	  (navi2ch-localfile-encode-string from)
	  (navi2ch-localfile-encode-string mail)
	  (format-time-string "%y/%m/%d %R" time)
	  (navi2ch-localfile-encode-string message)
	  (navi2ch-localfile-encode-string (or subject ""))))

(defun navi2ch-localfile-update-subject-file (directory
					      &optional article-id sage-flag)
  "DIRECTORY $B0J2<$N(B `navi2ch-localfile-subject-file-name' $B$r99?7$9$k!#(B
ARTICLE-ID $B$,;XDj$5$l$F$$$l$P$=$N%"!<%F%#%/%k$N$_$r99?7$9$k!#(B
`navi2ch-localfile-subject-file-name' $B$K;XDj$5$l$?%"!<%F%#%/%k$,L5$$>l(B
$B9g$O(B SUBJECT $B$r;HMQ$9$k!#(BDIRECTORY $B$O8F$S=P$785$G%m%C%/$7$F$*$/$3$H!#(B"
  (if (not article-id)
      (dolist (file (directory-files (expand-file-name "dat" directory)
				     nil "\\`[0-9]+\\.dat\\'"))
	(navi2ch-localfile-update-subject-file
	 directory (file-name-sans-extension file)))
    (let* ((coding-system-for-read navi2ch-localfile-coding-system)
	   (coding-system-for-write navi2ch-localfile-coding-system)
	   (dat-directory (expand-file-name "dat" directory))
	   (article-file (expand-file-name (concat article-id ".dat")
					   dat-directory))
	   (subject-file (expand-file-name navi2ch-localfile-subject-file-name
					   directory))
	   (temp-file (navi2ch-make-temp-file subject-file))
	   subject lines new-line)
      (unwind-protect
	  (progn
	    (with-temp-buffer
	      (insert-file-contents article-file)
	      (setq lines (count-lines (point-min) (point-max)))
	      (goto-char (point-min))
	      (let ((list (split-string (buffer-substring (point-min)
							  (progn
							    (end-of-line)
							    (point)))
					"<>")))
		(setq subject (or (nth 4 list) ""))))
	    (setq new-line
		  (format "%s.dat<>%s (%d)\n" article-id subject lines))
	    (with-temp-file temp-file
	      (if (file-exists-p subject-file)
		  (insert-file-contents subject-file))
	      (goto-char (point-min))
	      (if (re-search-forward (format "^%s\\.dat<>[^\n]+\n"
					     article-id) nil t)
		  (replace-match "")
		(goto-char (point-max))
		(if (and (char-before)
			 (not (= (char-before) ?\n))) ; $BG0$N$?$a(B
		    (insert "\n")))
	      (unless sage-flag
		(goto-char (point-min)))
	      (insert new-line))
	    (rename-file temp-file subject-file t))
	(if (file-exists-p temp-file)
	    (delete-file temp-file))))))

(defun navi2ch-localfile-create-thread (directory from mail message subject)
  "DIRECTORY $B0J2<$K%9%l$r:n$k!#(B"
  (navi2ch-localfile-lock directory)
  (unwind-protect
      (let ((coding-system-for-read navi2ch-localfile-coding-system)
	    (coding-system-for-write navi2ch-localfile-coding-system)
	    (redo t)
	    (dat-directory (expand-file-name "dat" directory))
	    now article-id file)
	(unless (file-exists-p dat-directory)
	  (make-directory dat-directory t))
	(while (progn
		 (setq now (current-time)
		       article-id (format-time-string "%s" now)
		       file (expand-file-name (concat article-id ".dat")
					      dat-directory))
		 ;; $B$3$3$G%U%!%$%k$r%"%H%_%C%/$K:n$j$?$$$H$3$@$1$I!"(B
		 ;; write-region $B$K(B mustbenew $B0z?t$NL5$$(B XEmacs $B$G$I$&(B
		 ;; $B$d$l$P$$$$$s$@$m$&!#!#!#(B
		 (file-exists-p file))
	  (sleep-for 1))		; $B$A$g$C$HBT$C$F$_$k!#(B
	(with-temp-file file
	  (insert (navi2ch-localfile-encode-message
		   from mail now message subject)))
	(navi2ch-localfile-update-subject-file directory article-id
					       (string-match "sage" mail)))
    (navi2ch-localfile-unlock directory)))

(defun navi2ch-localfile-append-message (directory article-id
						   from mail message)
  "DIRECTORY $B$N(B ARTICLE-ID $B%9%l$K%l%9$rIU$1$k!#(B"
  (navi2ch-localfile-lock directory)
  (unwind-protect
      (let* ((coding-system-for-read navi2ch-localfile-coding-system)
	     (coding-system-for-write navi2ch-localfile-coding-system)
	     (dat-directory (expand-file-name "dat" directory))
	     (file (expand-file-name (concat article-id ".dat")
				     dat-directory))
	     (temp-file (navi2ch-make-temp-file file)))
	(unwind-protect
	    (when (file-readable-p file)
	      (with-temp-file temp-file
		(insert-file-contents file)
		(goto-char (point-max))
		(if (not (= (char-before) ?\n)) ; $BG0$N$?$a(B
		    (insert "\n"))
		(insert (navi2ch-localfile-encode-message
			 from mail (current-time) message)))
	      (rename-file temp-file file t))
	  (if (file-exists-p temp-file)
	      (delete-file temp-file)))
	(navi2ch-localfile-update-subject-file directory article-id
					       (string-match "sage" mail)))
    (navi2ch-localfile-unlock directory)))

;; interface functions for multibbs
(defun navi2ch-localfile-p (uri)
  "URI $B$,(B localfile $B$J$i(B non-nil$B$rJV$9!#(B"
  (string-match navi2ch-localfile-regexp uri))

(defun navi2ch-localfile-article-update (board article)
  "BOARD ARTICLE$B$N5-;v$r99?7$9$k!#(B"
  (let ((url (navi2ch-article-get-url board article))
	(file (navi2ch-article-get-file-name board article)))
    (list (navi2ch-localfile-update-file url file) nil)))

(defun navi2ch-localfile-send-message
  (from mail message subject bbs key time board article)

  (when (= (length message) 0)
    (error "$BK\J8$,=q$+$l$F$$$^$;$s!#(B"))
  (when (and subject
	     (= (length subject) 0))
    (error "Subject $B$,=q$+$l$F$$$^$;$s!#(B"))

  (save-match-data
    (let* ((url (navi2ch-board-get-url board))
	   directory)
      (if (string-match (concat navi2ch-localfile-regexp "\\(.+\\)")
			url)
	  (setq directory (file-name-directory (match-string 1 url)))
	(error "$B2?$+JQ$G$9!#(B"))
      (if subject
	  ;; $B%9%lN)$F(B
	  (navi2ch-localfile-create-thread directory from mail message subject)
	;; $B%l%9=q$-(B
	(navi2ch-localfile-append-message directory key
					  from mail message)))))

(defun navi2ch-localfile-send-message-success-p (proc)
;  (string-match "302 Found" (navi2ch-net-get-content proc)))
  t)

(defun navi2ch-localfile-board-update (board)
  (let ((file (navi2ch-board-get-file-name board))
	(url (navi2ch-board-get-url board)))
    (navi2ch-localfile-update-file url file)))

(defun navi2ch-localfile-board-get-file-name (board &optional file-name)
  (let ((uri (navi2ch-board-get-uri board))
	(cache-dir (navi2ch-expand-file-name navi2ch-localfile-cache-name)))
    (when (and uri
	       (string-match (concat navi2ch-localfile-regexp "/*\\(.+\\)")
			     uri))
      (expand-file-name (or file-name
			    navi2ch-board-subject-file-name)
			(expand-file-name (match-string 1 uri)
					  cache-dir)))))

(defun navi2ch-localfile-update-file (url file &rest args)
  (let ((directory (file-name-directory file)))
    (unless (file-exists-p directory)
      (make-directory directory t)))
  (let (source-file)
    (save-match-data
      (if (string-match (concat navi2ch-localfile-regexp "\\(.+\\)")
			url)
	  (setq source-file (match-string 1 url))))
    (if (and source-file
	     (file-readable-p source-file))
	(let* ((coding-system-for-write 'binary)
	       (coding-system-for-read 'binary)
	       (time (nth 5 (file-attributes source-file)))
	       (time-string (navi2ch-http-date-encode time)))
	  (with-temp-file file
	    (insert-file-contents source-file))
	  (list (cons "Date" time-string)
		(cons "Server" "localfile")
		(cons "Last-Modified" time-string))))))

;;; navi2ch-localfile.el ends here
