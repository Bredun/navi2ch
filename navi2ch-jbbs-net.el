;;; navi2ch-jbbs-net.el --- View jbbs.net module for Navi2ch.

;; Copyright (C) 2002 by Navi2ch Project

;; Author:
;; Part5 $B%9%l$N(B 509 $B$NL>L5$7$5$s(B
;; <http://pc.2ch.net/test/read.cgi/unix/1013457056/509>

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

;; 

;;; Code:
(provide 'navi2ch-jbbs-net)

(require 'navi2ch-multibbs)

(defvar navi2ch-jbbs-func-alist
  '((bbs-p		. navi2ch-jbbs-p)
    (subject-callback	. navi2ch-jbbs-subject-callback)
    (send-message   	. navi2ch-jbbs-send-message)
    (send-success-p 	. navi2ch-jbbs-send-message-success-p)
    (error-string   	. navi2ch-net-get-content)
    (article-update 	. navi2ch-jbbs-article-update)
    (article-to-url 	. navi2ch-jbbs-article-to-url)))

(navi2ch-multibbs-regist 'jbbs-net navi2ch-jbbs-func-alist)

;;-------------

(defun navi2ch-jbbs-p (uri)
  "URI $B$,(B jbbs.net $B$J$i(B non-nil$B$rJV$9!#(B"
  (string-match "http://[^\\.]+\\.jbbs\\.net/" uri))

(defun navi2ch-jbbs-subject-callback ()
  "subject.txt $B$r<hF@$9$k$H$-(B navi2ch-net-update-file
$B$G;H$o$l$k%3!<%k%P%C%/4X?t(B"
  (while (re-search-forward "\\([0-9]+\\.\\)cgi\\([^\n]+\n\\)" nil t)
    (replace-match "\\1dat\\2")))

(defun navi2ch-jbbs-article-update (board article)
  (let* ((file (navi2ch-article-get-file-name board article))
	 (time (cdr (assq 'time article)))
	 (url  (navi2ch-jbbs-get-offlaw-url board article))
	 (header (navi2ch-net-update-file url file time)))
    (and header (list header nil))))

(defun navi2ch-jbbs-get-offlaw-url (board article)
  (let ((uri (cdr (assq 'uri board))))
    (string-match "\\(http://[^/]+/[^/]+/\\)\\([0-9]+\\)" uri )
    (format "%sbbs/offlaw.cgi?BBS=%s&KEY=%s"
	    (match-string 1  uri) (match-string 2 uri)
	    (cdr (assq 'artid article)))))

(defun navi2ch-jbbs-article-to-url
  (board article &optional start end nofirst)
  "BOARD, ARTICLE $B$+$i(B url $B$KJQ49!#(B
START, END, NOFIRST $B$OL5;k$9$k!#(B(jbbs.net$B$K$=$&$$$&5!G=$,L5$$(B)"
  (let ((uri   (cdr (assq 'uri board)))
	(artid (cdr (assq 'artid article))))
    (string-match "\\(.*\\)\\/\\([^/]*\\)\\/" uri)
    (format "%s/bbs/read.cgi?BBS=%s&KEY=%s"
	    (match-string 1 uri) (match-string 2 uri) artid)))

(defun navi2ch-jbbs-send-message
  (from mail message subject bbs key time board article)
  (let ((url         (navi2ch-js-get-writecgi-url board)) ;jbbs-shitaraba
	(referer     (navi2ch-board-get-uri board))
	(param-alist (list
		      (cons "submit" "$B=q$-9~$`(B")
		      (cons "NAME" (or from ""))
		      (cons "MAIL" (or mail ""))
		      (cons "MESSAGE" message)
		      (cons "BBS" bbs)
		      (cons "KEY" key)
		      (cons "TIME" time)
		      (cons "MESSAGE" message))))
    (navi2ch-net-send-request
     url "POST"
     (list (cons "Content-Type" "application/x-www-form-urlencoded")
	   (cons "Referer" referer))
     (navi2ch-net-get-param-string param-alist))))

(defun navi2ch-jbbs-send-message-success-p (proc)
  (string-match "302 Found" (navi2ch-net-get-content proc)))
;;; navi2ch-jbbs-net.el ends here
