;;; navi2ch-multibbs.el --- View 2ch like BBS module for Navi2ch.

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
(provide 'navi2ch-multibbs)
(defvar navi2ch-multibbs-ident
  "$Id$")

(require 'navi2ch)

(defvar navi2ch-multibbs-func-alist nil
  "BBS $B$N<oN`$H4X?t72$N(B alist$B!#(B
$B3FMWAG$O(B
\(BBSTYPE . FUNC-ALIST)
BBSTYPE: BBS $B$N<oN`$rI=$9%7%s%\%k!#(B
FUNC-ALIST: $B$=$N(B BBS $B$G$NF0:n$r;XDj$9$k4X?t72!#(B

FUNC-ALIST $B$O0J2<$NDL$j(B
\((bbs-p			. BBS-P-FUNC)
 (subject-callback	. SUBJECT-CALLBACK-FUNC)
 (article-update	. ARTICLE-UPDATE-FUNC)
 (article-to-url	. ARTICLE-TO-URL-FUNC)
 (url-to-board		. URL-TO-BOARD-FUNC)
 (url-to-article	. URL-TO-ARTICLE-FUNC)
 (send-message		. SEND-MESSAGE-FUNC)
 (send-success-p	. SEND-MESSAGE-SUCCESS-P-FUNC)
 (error-string		. ERROR-STRING-FUNC)
 (board-update		. BOARD-UPDATE-FUNC)
 (board-get-file-name	. BOARD-GET-FILE-NAME-FUNC))

BBS-P-FUNC(URI):
    URI $B$,$=$N(B BBS $B$N$b$N$J$i$P(B non-nil $B$rJV$9!#(B

SUBJECT-CALLBACK-FUNC():
    subject.txt $B$r<hF@$9$k$H$-$K(B navi2ch-net-update-file $B$G;H$o$l$k%3!<(B
    $B%k%P%C%/4X?t(B

ARTICLE-UPDATE-FUNC(BOARD ARTICLE):
    BOARD ARTICLE $B$GI=$5$l$k%U%!%$%k$r99?7$9$k!#(B

ARTICLE-TO-URL-FUNC(BOARD ARTICLE
		    &OPTIONAL START END NOFIRST):
    BOARD, ARTICLE $B$+$i(B url $B$KJQ49$9$k!#(B

URL-TO-BOARD-FUNC(URL):
URL $B$+$i(B board $B$KJQ49$9$k!#(B

URL-TO-ARTICLE-FUNC(URL):
URL $B$+$i(B article $B$KJQ49$9$k!#(B

SEND-MESSAGE-FUNC(FROM MAIL MESSAGE
		  SUBJECT BBS KEY TIME BOARD ARTICLE):
    MESSAGE $B$rAw?.$9$k!#(B

SEND-MESSAGE-SUCCESS-P-FUNC(PROC):
    PROC $B$NAw?.%;%C%7%g%s$,@.8y$7$F$$$l$P(B non-nil $B$r!"(B
    $B<:GT$7$?$i(B nil $B$r!":F;n9T2DG=$J<:GT$J$i(B 'retry $B$rJV$9!#(B

ERROR-STRING-FUNC(PROC):
    PROC $B$NAw?.%;%C%7%g%s$,<:GT$7$?$H$-$N%(%i!<%a%C%;!<%8$rJV$9!#(B

BOARD-UPDATE-FUNC(BOARD):
    BOARD $B$GI=$5$l$k%U%!%$%k$r99?7$9$k!#(B

BOARD-GET-FILE-NAME-FUNC(BOARD &optional FILE-NAME)
    BOARD $B$N>pJs$rJ]B8$9$k%G%#%l%/%H%j$r4p=`$H$7$F!"(BFILE-NAME $B$N(B
    $B@dBP%Q%9$rJV$9!#(B
")

(defvar navi2ch-multibbs-variable-alist nil
  "BBS $B$N<oN`$HJQ?t72$N(B alist$B!#(B
$B3FMWAG$O(B
\(BBSTYPE . FUNC-ALIST)
BBSTYPE: BBS $B$N<oN`$rI=$9%7%s%\%k!#(B
VARIABLE-ALIST: $B$=$N(B BBS $B$N@_Dj$r;XDj$9$kJQ?t72!#(B

VARIABLE-ALIST $B$O0J2<$NDL$j(B
\((coding-system		. CODING-SYSTEM-VAR))

CODING-SYSTEM-VAR:
    $B$=$N(B BBS $B$N%U%!%$%k$NJ8;z%3!<%I(B
")


(defun navi2ch-multibbs-get-bbstype-subr (uri list)
  (if list
      (let ((bbstype    (caar list))
	    (func       (cdr (assq 'bbs-p (cdar list)))))
	(if (and func (funcall func uri))
	    bbstype
	  (navi2ch-multibbs-get-bbstype-subr uri (cdr list))))))

(defun navi2ch-multibbs-set-bbstype (board type)
  (when (consp board)
      (setcdr board
	      (cons (cons 'bbstype type) (cdr board)))))

(defun navi2ch-multibbs-get-bbstype (board)
  (let ((type (cdr (assq 'bbstype board))))
    (unless type
      (setq type (navi2ch-multibbs-url-to-bbstype
		  (cdr (assq 'uri board))))
      (navi2ch-multibbs-set-bbstype board type))
    type))

(defun navi2ch-multibbs-subject-callback (board)
  (navi2ch-multibbs-get-func
   (navi2ch-multibbs-get-bbstype board)
   'subject-callback 'navi2ch-2ch-subject-callback))

(defmacro navi2ch-multibbs-defcallback (name spec &rest body)
  "navi2ch-net-update-file $B$KEO$9(B callback $B$rDj5A$9$k!#(B
SPEC $B$O(B (BBSTYPE)$B!#(B
$B<B:]$K$O!"(Bcallback $B$rDj5A$9$k$N$KI,MW$J(B BBSTYPE $B$JHD$N(B coding-system
$B$K$h$k(B decode, encode $B=hM}$r!"(BBODY $B$rI>2A$9$kA08e$K9T$J$&(B NAME $B$H$$$&(B
$B4X?t$,Dj5A$5$l$k!#(B"
  (let ((bbstype (gensym "--bbstype--"))
	(decoding (gensym "--decoding--"))
	docstring)
    (when (stringp (car body))
	  (setq docstring (car body))
	  (setq body (cdr body)))
    `(defun ,name ()
       ,docstring
       (let* ((coding-system-for-read 'binary)
	      (coding-system-for-write 'binary)
	      (,bbstype ',(car spec))
	      (,decoding (navi2ch-multibbs-get-variable
			  ,bbstype 'coding-system
			  navi2ch-coding-system)))
	 (decode-coding-region (point-min) (point-max)
			       ,decoding)
	 ,@body
	 (encode-coding-region (point-min) (point-max)
			       navi2ch-coding-system)))))
(put 'navi2ch-multibbs-defcallback 'lisp-indent-function 2)

(defun navi2ch-multibbs-article-update (board article)
  (let* ((bbstype (navi2ch-multibbs-get-bbstype board))
	 (func    (navi2ch-multibbs-get-func
		   bbstype 'article-update 'navi2ch-2ch-article-update)))
    (funcall func board article)))


(defun navi2ch-multibbs-regist (bbstype func-alist variable-alist)
  (setq navi2ch-multibbs-func-alist
	(cons (cons bbstype func-alist)
	      navi2ch-multibbs-func-alist))
  (setq navi2ch-multibbs-variable-alist
	(cons (cons bbstype variable-alist)
	      navi2ch-multibbs-variable-alist)))

(defsubst navi2ch-multibbs-get-func-from-board
  (board func &optional default-func)
  (navi2ch-multibbs-get-func
   (navi2ch-multibbs-get-bbstype board)
   func default-func))

(defun navi2ch-multibbs-get-func (bbstype func &optional default-func)
  (or (cdr (assq func
		 (cdr (assq bbstype
			    navi2ch-multibbs-func-alist))))
      default-func))

(defun navi2ch-multibbs-get-variable
  (bbstype variable &optional default-value)
  (or (cdr (assq variable
		 (cdr (assq bbstype
			    navi2ch-multibbs-variable-alist))))
      default-value))

(defun navi2ch-multibbs-url-to-bbstype (url)
  (or
   (and url
	(navi2ch-multibbs-get-bbstype-subr url navi2ch-multibbs-func-alist))
   'unknown))

(defun navi2ch-multibbs-url-to-article (url)
  (let* ((bbstype (navi2ch-multibbs-url-to-bbstype url))
	 (func    (navi2ch-multibbs-get-func
		   bbstype 'url-to-article 'navi2ch-2ch-url-to-article)))
    (funcall func url)))

(defun navi2ch-multibbs-url-to-board (url)
  (let* ((bbstype (navi2ch-multibbs-url-to-bbstype url))
	 (func    (navi2ch-multibbs-get-func
		   bbstype 'url-to-board 'navi2ch-2ch-url-to-board)))
    (funcall func url)))

(defun navi2ch-multibbs-article-to-url
  (board article &optional start end nofirst)
  "BOARD, ARTICLE $B$+$i(B url $B$KJQ49!#(B
START, END, NOFIRST $B$GHO0O$r;XDj$9$k(B"
  (let ((func (navi2ch-multibbs-get-func-from-board
	       board 'article-to-url 'navi2ch-2ch-article-to-url)))
    (funcall func board article start end nofirst)))

(defun navi2ch-multibbs-send-message
  (from mail message subject board article)
  (let* ((bbstype      (navi2ch-multibbs-get-bbstype board))
	 (send         (navi2ch-multibbs-get-func
			bbstype 'send-message 'navi2ch-2ch-send-message))
	 (success-p    (navi2ch-multibbs-get-func
			bbstype 'send-success-p
			'navi2ch-2ch-send-message-success-p))
	 (error-string (navi2ch-multibbs-get-func
			bbstype 'error-string
			'navi2ch-2ch-send-message-error-string))
	 (bbs          (let ((uri (navi2ch-board-get-uri board)))
			 (string-match "\\([^/]+\\)/$" uri)
			 (match-string 1 uri)))
	 (key          (cdr (assq 'artid article)))
	 (time         (mapconcat 'int-to-string
				  (let ((time (current-time)))
				    (navi2ch-bigint-add
				     (navi2ch-bigint-multiply
				      (nth 0 time) (expt 2 16)) (nth 1 time)))
				  ""))
	 (navi2ch-net-http-proxy (and navi2ch-net-send-message-use-http-proxy
				      navi2ch-net-http-proxy))
	 (tries 2)	; $BAw?.;n9T$N:GBg2s?t(B
	 (message-str "send message...")
	 (result 'retry))
    (while (eq result 'retry)
      (let ((proc (funcall send from mail message subject bbs key time
			   board article)))
	(message message-str)
	(setq result (funcall success-p proc))
	(if (and result
		 (not (eq result 'retry)))
	    (message (concat message-str "succeed"))
	  (let ((err (funcall error-string proc)))
	    (if (stringp err)
		(message (concat message-str "failed: %s") err)
	      (message (concat message-str "failed"))))
	  (if (eq result 'retry)
	      (if (= tries 1)
		  (setq result nil)
		(setq tries (1- tries))
		(sit-for navi2ch-message-retry-wait-time)
		(setq message-str "re-send message..."))))))
      result))

(defun navi2ch-multibbs-board-update (board)
  (let ((func (navi2ch-multibbs-get-func-from-board
	       board 'board-update 'navi2ch-2ch-board-update)))
    (funcall func board)))

(defun navi2ch-multibbs-board-get-file-name (board &optional file-name)
  (let ((func (navi2ch-multibbs-get-func-from-board
	       board 'board-get-file-name 'navi2ch-2ch-board-get-file-name)))
    (funcall func board file-name)))

;;;-----------------------------------------------

(defun navi2ch-2ch-subject-callback ()
  (when navi2ch-board-use-subback-html
    (navi2ch-board-make-subject-txt)))

(defun navi2ch-2ch-article-update (board article)
  "BOARD, ARTICLE $B$KBP1~$9$k%U%!%$%k$r99?7$9$k!#(B
$BJV$jCM$O(B (header state) $B$N%j%9%H!#(B
state $B$O$"$\!<$s$5$l$F$l$P(B aborn $B$H$$$&%7%s%\%k!#(B
$B2a5n%m%0$r<hF@$7$F$$$l$P(B kako $B$H$$$&%7%s%\%k!#(B"
  (let ((file (navi2ch-article-get-file-name board article))
	(time (cdr (assq 'time article)))
	url)
    (if (and (navi2ch-enable-readcgi-p
	      (navi2ch-board-get-host board)))
	(progn
	  (setq url (navi2ch-article-get-readcgi-raw-url
		     board article))
	  (let ((ret (navi2ch-net-update-file-with-readcgi
		      url file time (file-exists-p file))))
	    (if (eq ret 'kako)
		(progn
		  (setq url (navi2ch-article-get-kako-url
			     board article))
		  (list
		   (navi2ch-net-update-file url file)
		   'kako))
	      ret)))
      (setq url (navi2ch-article-get-url board article))
      (let ((ret
	     (if (and (file-exists-p file)
		      navi2ch-article-enable-diff)
		 (navi2ch-net-update-file-diff url file time)
	       (let ((header (navi2ch-net-update-file url file time)))
		 (and header (list header nil))))))
	(if ret
	    ret
	  (setq url (navi2ch-article-get-kako-url board article))
	  (list (navi2ch-net-update-file url file) 'kako))))))

(defun navi2ch-2ch-url-to-board (url)
  (let (id uri)
    (if (or (string-match
	     "http://\\(.+\\)/test/read\\.cgi.*bbs=\\([^&]+\\)" url)
	    (string-match
	     "http://\\(.+\\)/test/read\\.cgi/\\([^/]+\\)/" url)
	    (string-match
	     "http://\\(.+\\)/\\([^/]+\\)/kako/[0-9]+/" url)
	    (string-match "http://\\(.+\\)/\\([^/]+\\)" url))
	(setq id (match-string 2 url)
	      uri (format "http://%s/%s/" (match-string 1 url) id)))
    (if id (list (cons 'uri uri) (cons 'id id)))))

(defun navi2ch-2ch-url-to-article (url)
  "URL $B$+$i(B article $B$KJQ49!#(B"
  (let (list)
    (cond ((string-match "http://.+/test/read\\.cgi.*&key=\\([0-9]+\\)" url)
           (setq list (list (cons 'artid (match-string 1 url))))
           (when (string-match "&st=\\([0-9]+\\)" url)
             (setq list (cons (cons 'number
                                    (string-to-number (match-string 1 url)))
                              list))))
	  ((string-match "http://.+/test/read\\.cgi/[^/]+/\\([^/]+\\)" url)
           (setq list (list (cons 'artid (match-string 1 url))))
           (when (string-match
		  "http://.+/test/read\\.cgi/[^/]+/[^/]+/[ni.]?\\([0-9]+\\)[^/]*$" url)
             (setq list (cons (cons 'number
                                    (string-to-number (match-string 1 url)))
                              list))))
	  ((string-match
	    "http://.+/kako/[0-9]+/\\([0-9]+\\)\\.\\(dat\\|html\\)" url)
	   (setq list (list (cons 'artid (match-string 1 url))
			    (cons 'kako t))))
          ((string-match "http://.+/\\([0-9]+\\)\\.\\(dat\\|html\\)" url)
           (setq list (list (cons 'artid (match-string 1 url))))))
    list))

(defun navi2ch-2ch-send-message
  (from mail message subject bbs key time board article)
  (let ((url         (navi2ch-board-get-bbscgi-url board))
	(referer     (navi2ch-board-get-uri board))
	(spid        (navi2ch-board-load-spid board))
	(param-alist (list
		      (cons "submit" "$B=q$-9~$`(B")
		      (cons "FROM"   (or from ""))
		      (cons "mail"   (or mail ""))
		      (cons "bbs"    bbs)
		      (cons "time"   time)
		      (cons "MESSAGE" message)
		      (if subject
			  (cons "subject" subject)
			(cons "key"    key)))))
    (let ((proc
	   (navi2ch-net-send-request
	    url "POST"
	    (list (cons "Content-Type" "application/x-www-form-urlencoded")
		  (cons "Cookie" (concat "NAME=" from "; MAIL=" mail
					 (if spid (concat "; SPID=" spid))))
		  (cons "Referer" referer))
	    (navi2ch-net-get-param-string param-alist))))
      (setq spid (navi2ch-net-send-message-get-spid proc))
      (if spid (navi2ch-board-save-spid board spid))
      proc)))

(defun navi2ch-2ch-article-to-url
  (board article &optional start end nofirst)
  "BOARD, ARTICLE $B$+$i(B url $B$KJQ49!#(B
START, END, NOFIRST $B$GHO0O$r;XDj$9$k(B"
  (let ((url (navi2ch-board-get-readcgi-url board)))
    (setq url (concat url (cdr (assq 'artid article)) "/"))
    (if (numberp start)
        (setq start (number-to-string start)))
    (if (numberp end)
        (setq end (number-to-string end)))
    (if (equal start end)
        (concat url start)
      (concat url
              start (and (or start end) "-") end
              (and nofirst "n")))))

(defalias 'navi2ch-2ch-send-message-success-p
  'navi2ch-net-send-message-success-p)
(defalias 'navi2ch-2ch-send-message-error-string
  'navi2ch-net-send-message-error-string)

(defun navi2ch-2ch-board-update (board)
  (let ((file (navi2ch-board-get-file-name board))
	(time (cdr (assq 'time board))))
    (if navi2ch-board-enable-readcgi
	(car (navi2ch-net-update-file-with-readcgi
	      (navi2ch-board-get-readcgi-raw-url board) file time))
      (let ((url (navi2ch-board-get-url
		  board (if navi2ch-board-use-subback-html
			    navi2ch-board-subback-file-name)))
	    (func (navi2ch-multibbs-subject-callback board)))
	(navi2ch-net-update-file url file time func)))))

(defun navi2ch-2ch-board-get-file-name (board &optional file-name)
  (let ((uri (navi2ch-board-get-uri board)))
    (when uri
      (cond ((string-match "http://\\(.+\\)" uri)
	     (navi2ch-expand-file-name
	      (concat (match-string 1 uri)
		      (or file-name navi2ch-board-subject-file-name))))
	    ((string-match "file://\\(.+\\)" uri)
	     (expand-file-name (or file-name
				   navi2ch-board-subject-file-name)
			       (match-string 1 uri)))))))

;;; navi2ch-multibbs.el ends here
