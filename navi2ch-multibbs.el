;;; navi2ch-multibbs.el --- View 2ch like BBS module for Navi2ch.

;; Copyright (C) 2002 by Navi2ch Project

;; Author:
;; Part5 ����� 509 ��̵̾������
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

(require 'navi2ch)

(defvar navi2ch-multibbs-func-alist nil
  "BBS �μ���ȴؿ����� alist��
�����Ǥ�
(BBSTYPE . FUNC-ALIST)
BBSTYPE: BBS �μ����ɽ������ܥ롣
FUNC-ALIST: ���� BBS �Ǥ�ư�����ꤹ��ؿ�����

FUNC-ALIST �ϰʲ����̤�
((bbs-p			. BBS-P-FUNC)
 (subject-callback	. SUBJECT-CALLBACK-FUNC)
 (article-update	. ARTICLE-UPDATE-FUNC)
 (article-to-url	. ARTICLE-TO-URL-FUNC)
 (url-to-board		. URL-TO-BOARD-FUNC)
 (url-to-article	. URL-TO-ARTICLE-FUNC)
 (send-message		. SEND-MESSAGE-FUNC)
 (send-success-p	. SEND-MESSAGE-SUCCESS-P-FUNC)
 (error-string		. ERROR-STRING-FUNC)

BBS-P-FUNC(URI): 
    URI ������ BBS �Τ�Τʤ�� non-nil ���֤���

SUBJECT-CALLBACK-FUNC(): 
    subject.txt ���������Ȥ���navi2ch-net-update-file �ǻȤ��륳��
    ��Хå��ؿ�

ARTICLE-UPDATE-FUNC(BOARD ARTICLE):
    BOARD ARTICLE ��ɽ�����ե�����򹹿����롣
    
ARTICLE-TO-URL-FUNC(BOARD ARTICLE
		    &OPTIONAL START END NOFIRST):
    BOARD, ARTICLE ���� url ���Ѵ����롣

URL-TO-BOARD-FUNC(URL):
URL ���� board ���Ѵ����롣

URL-TO-ARTICLE-FUNC(URL):
URL ���� article ���Ѵ����롣

SEND-MESSAGE-FUNC(FROM MAIL MESSAGE 
		  SUBJECT BBS KEY TIME BOARD ARTICLE):
    MESSAGE ���������롣

SEND-MESSAGE-SUCCESS-P-FUNC(PROC):
    PROC ���������å�����������Ƥ���� non-nil ���֤���

ERROR-STRING-FUNC(PROC):
    PROC ���������å���󤬼��Ԥ����Ȥ��Υ��顼��å��������֤���

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

(defun navi2ch-multibbs-article-update (board article)
  (let* ((bbstype (navi2ch-multibbs-get-bbstype board))
	 (func    (navi2ch-multibbs-get-func
		   bbstype 'article-update 'navi2ch-2ch-article-update)))
    (funcall func board article)))


(defun navi2ch-multibbs-regist (bbstype func-alist)
  (setq navi2ch-multibbs-func-alist
	(cons (cons bbstype func-alist) navi2ch-multibbs-func-alist)))

(defsubst navi2ch-multibbs-get-func-from-board
  (board func &optional default-func)
  (navi2ch-multibbs-get-func
   (navi2ch-multibbs-get-bbstype board)
   func default-func))

(defun navi2ch-multibbs-get-func (bbstype func &optional default-func)
  (or (cdr (assq func (cdr (assq bbstype navi2ch-multibbs-func-alist))))
      default-func))

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
  "BOARD, ARTICLE ���� url ���Ѵ���
START, END, NOFIRST ���ϰϤ���ꤹ��"
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
			bbstype 'send-error-string
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
	 (proc      (funcall send from mail message subject bbs key time
			     board article)))
    (message "send message...")
    (if (funcall success-p proc)
	(progn
	  (message "send message...succeed")
	  t)
      (let ((err (funcall error-string proc)))
	(if (stringp err)
	    (message "send message...failed: %s" err)
	  (message "send message...failed")))
      nil)))

;;;-----------------------------------------------

(defun navi2ch-2ch-subject-callback ()
  (when navi2ch-board-use-subback-html 
    (navi2ch-board-make-subject-txt)))

(defun navi2ch-2ch-article-update (board article)
  "BOARD, ARTICLE ���б�����ե�����򹹿����롣
�֤��ͤ� (header state) �Υꥹ�ȡ�
state �Ϥ��ܡ��󤵤�Ƥ�� aborn �Ȥ�������ܥ롣
������������Ƥ���� kako �Ȥ�������ܥ롣"
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
    (cond ((string-match
            "http://\\(.+\\)/test/read\\.cgi.*bbs=\\([^&]+\\)" url)
           (setq id (match-string 2 url)
                 uri (format "http://%s/%s/" (match-string 1 url) id)))
	  ((string-match
            "http://\\(.+\\)/test/read\\.cgi/\\([^/]+\\)/" url)
           (setq id (match-string 2 url)
                 uri (format "http://%s/%s/" (match-string 1 url) id)))
          ((string-match
            "http://\\(.+\\)/\\([^/]+\\)/kako/[0-9]+/" url)
           (setq id (match-string 2 url)
                 uri (format "http://%s/%s/" (match-string 1 url) id)))
          ((string-match "http://\\(.+\\)/\\([^/]+\\)" url)
           (setq id (match-string 2 url)
                 uri (format "http://%s/%s/" (match-string 1 url) id))))
    (if id (list (cons 'uri uri) (cons 'id id)))))

(defun navi2ch-2ch-url-to-article (url)
  "URL ���� article ���Ѵ���"
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
		      (cons "submit" "�񤭹���")
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
  "BOARD, ARTICLE ���� url ���Ѵ���
START, END, NOFIRST ���ϰϤ���ꤹ��"
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
;;; navi2ch-multibbs.el ends here
