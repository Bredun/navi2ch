;;; navi2ch-net.el --- Network module for navi2ch

;; Copyright (C) 2000 by 2$B$A$c$s$M$k(B

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

;;; Code:

(eval-when-compile (require 'cl))
(require 'timezone)
(require 'navi2ch-util)
(require 'navi2ch-vars)
(eval-when-compile
  (provide 'navi2ch-net)
  (require 'navi2ch))

(defvar navi2ch-net-connection-name "navi2ch connection")
(defvar navi2ch-net-user-agent "Navi2ch")
(defvar navi2ch-net-setting-file-name "SETTING.TXT")
(defvar navi2ch-net-last-url nil)

(defun navi2ch-net-send-request (url method &optional other-header content)
  (setq navi2ch-net-last-url url)
  (let ((buf (get-buffer-create (concat " *" navi2ch-net-connection-name)))
        (process-connection-type nil)
	(inherit-process-coding-system
	 navi2ch-net-inherit-process-coding-system)
        host file port host2ch credentials)
    (let ((list (navi2ch-net-split-url url navi2ch-net-http-proxy)))
      (setq host (cdr (assq 'host list))
            file (cdr (assq 'file list))
            port (cdr (assq 'port list))
            host2ch (cdr (assq 'host2ch list))))
    (when navi2ch-net-http-proxy
      (setq credentials (navi2ch-net-http-proxy-basic-credentials
			 navi2ch-net-http-proxy-userid
			 navi2ch-net-http-proxy-password)))
    (save-excursion
        (set-buffer buf)
        (erase-buffer))
    (message "now connecting...")
    (let ((proc (open-network-stream
                 navi2ch-net-connection-name buf host port)))
      (set-process-coding-system proc 'binary 'binary)
      (set-process-sentinel proc 'ignore) ; exited abnormary $B$r=P$5$J$/$9$k(B
      (process-send-string
       proc
       (format (concat
                "%s %s HTTP/1.0\r\n"
                "MIME-Version: 1.0\r\n"
                "Host: %s\r\n"
                "Connection: close\r\n"
                "%s"                    ;other-header
                "%s"                    ;content
                "\r\n")
               method file
               host2ch
	       (or (navi2ch-net-make-request-header
		    (cons (cons "Proxy-Authorization" credentials)
			  other-header))
		   "")
	       (if content
                   (format "Content-length: %d\r\n\r\n%s"
                           (length content) content)
                 "")))
      (message "now connecting...connected")
      proc)))
      
(defun navi2ch-net-split-url (url &optional proxy)
  (let (host file port host2ch)
    (string-match "http://\\([^/]+\\)" url)    
    (setq host2ch (match-string 1 url))
    (if proxy
        (progn
          (string-match "^\\(http://\\)?\\(.*\\):\\([0-9]+\\)" proxy)
          (list
           (cons 'host (match-string 2 proxy))
           (cons 'file url)
           (cons 'port (string-to-number (match-string 3 proxy)))
           (cons 'host2ch host2ch)))
      (string-match "http://\\([^/]+\\)\\(.*\\)" url)
      (list
       (cons 'host (match-string 1 url))
       (cons 'file (match-string 2 url))
       (cons 'port  80)
       (cons 'host2ch host2ch)))))

(defun navi2ch-net-http-proxy-basic-credentials (user pass)
  "USER $B$H(B PASS $B$+$i(B Proxy $BG'>Z$N>ZL@=q(B($B!)(B)$BItJ,$rJV$9!#(B"
  (when (and user pass)
    (concat "Basic "
	    (base64-encode-string
	     (concat user ":" pass)))))

(defun navi2ch-net-make-request-header (header-alist)
  "'((NAME . VALUE)...) $B$J(B HEADER-ALIST $B$+$i%j%/%(%9%H%X%C%@$r:n$k!#(B"
  (let (header)
    (dolist (pair header-alist)
      (when (and pair (cdr pair))
	(setq header (concat header
			     (car pair) ": " (cdr pair) "\r\n"))))
    header))

(defun navi2ch-net-get-status (proc)
  "PROC $B$N@\B3$N%9%F!<%?%9It$rJV$9(B"
  (save-excursion
    (set-buffer (process-buffer proc))
    (while (and (eq (process-status proc) 'open)
                (goto-char (point-min))
                (not (looking-at "HTTP/1\\.[01] \\([0-9]+\\)")))
      (accept-process-output proc))
    (goto-char (point-min))
    (looking-at "HTTP/1\\.[01] \\([0-9]+\\)")
    (match-string 1)))

(defun navi2ch-net-get-header (proc)
  "PROC $B$N@\B3$N%X%C%@It$rJV$9(B"
  (save-excursion
    (set-buffer (process-buffer proc))
    (while (and (eq (process-status proc) 'open)
                (goto-char (point-min))
                (not (re-search-forward "\r\n\r?\n" nil t)))
      (accept-process-output proc))
    (goto-char (point-min))
    (re-search-forward "\r\n\r?\n")
    (let ((end (match-end 0))
          list)
      (goto-char (point-min))
      (while (re-search-forward "^\\([^\r\n:]+\\): \\(.+\\)\r\n" end t)
        (setq list (cons (cons (match-string 1) (match-string 2)) 
                         list)))
      (nreverse list))))

(defun navi2ch-net-get-content-subr-with-temp-file (gzip-p cont)
  (if gzip-p
      (with-temp-buffer
	(insert cont)
	(let* ((tempfn (expand-file-name (make-temp-name "navi2ch") (getenv "TMP")))
	       (tempfngz (concat tempfn ".gz")))
	  (write-file tempfngz nil)
	  (call-process shell-file-name nil nil nil
			shell-command-switch (concat "gzip -d " tempfngz))
	  (set-visited-file-name tempfn nil t)
	  (revert-buffer t t)
	  (delete-file tempfn))
	(buffer-string))
    cont))

(defun navi2ch-net-get-content-subr (gzip-p cont)
  (if gzip-p
      (with-temp-buffer
	(insert cont)
	(apply 'call-process-region
	       (point-min) (point-max)
	       navi2ch-net-gunzip-program t t nil
	       navi2ch-net-gunzip-args)
	(buffer-string))
    cont))

(defvar navi2ch-net-get-content-subr-function nil)

(defun navi2ch-net-get-content (proc)
  "PROC $B$N@\B3$NK\J8$rJV$9(B"
  (if (null navi2ch-net-get-content-subr-function)
      (setq navi2ch-net-get-content-subr-function
	    (if (string-match "windowsce" system-configuration)
		'navi2ch-net-get-content-subr-with-temp-file
	      'navi2ch-net-get-content-subr)))
  (let ((gzip (and navi2ch-net-accept-gzip
		   (string-match "gzip"
				 (or (cdr (assoc "Content-Encoding"
						 (navi2ch-net-get-header proc)))
				     "")))))
    (save-excursion
      (set-buffer (process-buffer proc))
      (while (eq (process-status proc) 'open)
	(accept-process-output proc))
      (goto-char (point-min))
      (re-search-forward "\r\n\r?\n")
      (save-restriction
	(narrow-to-region (point) (point-max))
	(funcall navi2ch-net-get-content-subr-function
		 gzip
		 (buffer-substring (point-min)
				   (point-max)))))))

(defun navi2ch-net-download-file (url
				  &optional time accept-status other-header)
  "URL $B$+$i%@%&%s%m!<%I$r3+;O$9$k!#(B
TIME $B$,(B `non-nil' $B$J$i$P(B TIME $B$h$j?7$7$$;~$@$1%@%&%s%m!<%I$9$k!#(B
$B%j%9%H(B `accept-status' $B$,(B `non-nil' $B$J$i$P%9%F!<%?%9$,(B `accept-status' $B$K4^$^$l(B
$B$F$$$k;~$@$1%@%&%s%m!<%I$9$k!#(B
OTHER-HEADER $B$,(B `non-nil' $B$J$i$P%j%/%(%9%H$K$3$N%X%C%@$rDI2C$9$k!#(B
$B%@%&%s%m!<%I$G$-$l$P$=$N@\B3$rJV$9!#(B"
  (let ((proc
         (navi2ch-net-send-request 
          url "GET"
          (append
           (list (if navi2ch-net-force-update
                     (cons "Pragma" "no-cache")
                   (and time (cons "If-Modified-Since" time)))
		 (and navi2ch-net-accept-gzip
		      '("Accept-Encoding" . "gzip"))
		 (and navi2ch-net-user-agent
		      (cons "User-Agent" navi2ch-net-user-agent)))
           other-header))))
    (message "checking file is updated...")
    (let ((status (navi2ch-net-get-status proc)))
      (cond ((string= status "404")
             (message "file is not found")
             (delete-process proc)
             nil)
	    ((string= status "304")
	     (message "file is not updated")
	     (if (and accept-status
		      (member status accept-status))
		 proc
	       (delete-process proc)
	       nil))
	    (t
	     (message "file is updated")
	     proc)))))

(defun navi2ch-net-download-file-range (url range &optional time other-header)
  "Range $B%X%C%@$r;H$C$F%U%!%$%k$r%@%&%s%m!<%I$9$k!#(B"
  (navi2ch-net-download-file url time '("206" "200" "304") ;; 200 $B$b$"$C$F$b$$$$$N$+$J!)(B
			     (append
			      (list (cons "Range" (concat "bytes=" range)))
			      other-header)))
  
  
(defun navi2ch-net-update-file (url file &optional time func location)
  "FILE $B$r99?7$9$k!#(B
TIME $B$,(B non-nil $B$J$i$P(B TIME $B$h$j?7$7$$;~$@$199?7$9$k!#(B
FUNC $B$,(B non-nil $B$J$i$P99?78e(B FUNC $B$r;H$C$F%U%!%$%k$rJQ49$9$k!#(B
LOCATION $B$,(B non-nil $B$J$i$P(B Location $B%X%C%@$,$"$C$?$i$=$3$K0\F0$9$k$h$&$K$9$k!#(B
$B99?7$G$-$l$P(B header $B$rJV$9(B"
  (let ((dir (file-name-directory file)))
    (unless (file-exists-p dir)
      (make-directory dir t)))
  (let ((proc (navi2ch-net-download-file url time
					 (list "200" "304"
					       (and location "302")))))
    (if proc
        (let ((coding-system-for-write 'binary)
	      (coding-system-for-read 'binary)
	      (status (navi2ch-net-get-status proc))
	      (header (navi2ch-net-get-header proc))
	      cont)
	  (cond ((string= status "200")
		 (message "%s getting new file..." (current-message))
		 (setq cont (navi2ch-net-get-content proc))
		 (with-temp-file file 
		   (insert (funcall (if func (progn (message "translating...")
						    func)
				      'eval)
				    cont)))
		 (message "%sdone" (current-message))
		 (delete-process proc)
		 header)
		((and (string= status "302")
		      (assoc "Location" header))
		 (delete-process proc)
		 (navi2ch-net-update-file (cdr (assoc "Location" header))
					  file time func location))
		((string= status "304")
		 (delete-process proc)
		 header)))
      nil)))

(defun navi2ch-net-file-start (file)
  (max (- (nth 7 (file-attributes file))
          navi2ch-net-check-margin)
       0))

(defun navi2ch-net-get-length-from-header (header)
  "header $B$+$i(B contents $BA4BN$ND9$5$rF@$k(B"
  (let ((range (cdr (assoc "Content-Range" header))))
    (if (and range
	     (string-match "/\\(.+\\)" range))
	(string-to-number (match-string 1 range))
      (string-to-number
       (cdr (assoc "Content-Length" header))))))
  
(defun navi2ch-net-check-aborn (size header)
  "$B$"$\!<$s$5$l$F$J$1$l$P(B t"
  (>= (navi2ch-net-get-length-from-header header)
      (or size 0)))
  
(defun navi2ch-net-update-file-diff (url file &optional time)
  "FILE $B$r:9J,$G99?7$9$k!#(B
TIME $B$,(B `non-nil' $B$J$i$P(B TIME $B$h$j?7$7$$;~$@$199?7$9$k!#(B
$B99?7$G$-$l$P(B (header aborn-p) $B$J(B list $B$rJV$9(B"
  (let ((dir (file-name-directory file)))
    (unless (file-exists-p dir)
      (make-directory dir t)))
  ;; $B%U%!%$%k%5%$%:$HEy$7$$CM$r(B range $B$K$9$k$H%U%!%$%k$rA4ItAw$C$F$/$k(B
  ;; $B$N$G(B 1- $B$9$k!#(B
  (let* ((size (max 0 (1- (nth 7 (file-attributes file)))))
         (proc (navi2ch-net-download-file-range url (format "%d-" size) time)))
    (if proc
	(let ((coding-system-for-write 'binary)
	      (coding-system-for-read 'binary)
	      (status (navi2ch-net-get-status proc))
	      (header (navi2ch-net-get-header proc))
	      cont ret aborn-flag)
	  (cond ((string= status "206")
		 (if (not (navi2ch-net-check-aborn size header))
		     (setq aborn-flag t)
		   (message "%s getting file diff..." (current-message))
		   (with-temp-file file
		     (insert-file-contents file nil nil size)
		     (goto-char (point-max))
		     (insert (navi2ch-net-get-content proc)))
		   (message "%sdone" (current-message))
		   (delete-process proc)
		   (setq ret (list header nil))))
		((string= status "200")
		 (if (not (navi2ch-net-check-aborn size header))
		     (setq aborn-flag t)
		   (message "%s getting whole file..." (current-message))
		   (with-temp-file file
		     (insert (navi2ch-net-get-content proc)))
		   (message "%sdone" (current-message))
		   (delete-process proc)
		   (setq ret (list header nil))))
		((string= status "304")
		 (delete-process proc)
		 (setq ret (list header nil))))
	  (if (not aborn-flag)
	      ret
	    (if (processp proc)
		(delete-process proc))
	    (message "$B$"$\!<$s(B!!!")
	    (when (and navi2ch-net-save-old-file-when-aborn
		       (or (not (eq navi2ch-net-save-old-file-when-aborn
				    'ask))
			   (y-or-n-p "$B$"$\!<$s(B!!! backup old file? ")))
	      (copy-file file (read-file-name "file name: ")))
	    (list (navi2ch-net-update-file url file nil nil) t)))
      nil)))

(defun navi2ch-net-update-file-with-readcgi (url file &optional time diff)
  "FILE $B$r(B URL $B$+$i(B read.cgi $B$r;H$C$F99?7$9$k!#(B
TIME $B$,(B non-nil $B$J$i$P(B TIME $B$h$j?7$7$$;~$@$199?7$9$k!#(B
DIFF $B$,(B non-nil $B$J$i$P:9J,$r<hF@$9$k!#(B
$B99?7$G$-$l$P(B (header aborn-p) $B$J(B list $B$rJV$9(B"
  (let ((dir (file-name-directory file))
	proc header cont)
    (unless (file-exists-p dir)
      (make-directory dir t))
    (setq proc (navi2ch-net-download-file url time))
    (when proc
      (let ((coding-system-for-write 'binary)
	    (coding-system-for-read 'binary))
	(message "%s getting file with read.cgi..." (current-message))
	(setq header (navi2ch-net-get-header proc))
	(setq cont (navi2ch-net-get-content proc))
	(if (or (string= cont "")
		(not cont))
	    (progn (message "%sfailed" (current-message))
		   (signal 'navi2ch-update-failed nil))
	  (message "%sdone" (current-message))
	  (let (state data cont-size)
	    (when (string-match "^\\([^ ]+\\) \\(.+\\)\n" cont)
	      (setq state (match-string 1 cont))
	      (setq data (match-string 2 cont))
	      (setq cont (replace-match "" t nil cont)))
	    (when (and (string-match "\\(OK\\|INCR\\)" state)
		       (string-match "\\(.+\\)/\\(.+\\)K" data))
	      (setq cont-size (string-to-number (match-string 1 data))))
	    (setq cont (navi2ch-string-as-unibyte cont))
	    (cond
	     ((string= "+OK" state)
	      (with-temp-file file
		(navi2ch-set-buffer-multibyte nil)
		(when (and (file-exists-p file) diff)
		  (insert-file-contents file)
		  (goto-char (point-max)))
		(insert (substring cont 0 cont-size)))
	      (list header nil))
	     ((string= "-INCR" state);; $B$"$\!<$s(B
	      (with-temp-file file 
		(navi2ch-set-buffer-multibyte nil)
		(insert (substring cont 0 cont-size))
		(list header 'aborn)))
	     ((string= "-ERR" state)
	      (let ((err-msg (decode-coding-string
			      data navi2ch-coding-system)))
		(message "error! %s" err-msg)
		(when (string-match "$B2a5n%m%0AR8K$GH/8+(B" err-msg)
		  'kako))))))))))

;; from Emacs/W3
(defconst navi2ch-net-url-unreserved-chars
  '(
    ?a ?b ?c ?d ?e ?f ?g ?h ?i ?j ?k ?l ?m ?n ?o ?p ?q ?r ?s ?t ?u ?v ?w ?x ?y ?z
    ?A ?B ?C ?D ?E ?F ?G ?H ?I ?J ?K ?L ?M ?N ?O ?P ?Q ?R ?S ?T ?U ?V ?W ?X ?Y ?Z
    ?0 ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9
    ?$ ?- ?_ ?. ?! ?~ ?* ?' ?\( ?\) ?,)
  "A list of characters that are _NOT_ reserve in the URL spec.
This is taken from draft-fielding-url-syntax-02.txt - check your local
internet drafts directory for a copy.")

;; from Emacs/W3
(defun navi2ch-net-url-hexify-string (str)
  "Escape characters in a string"
  (mapconcat
   (function
    (lambda (char)
      (if (not (memq char navi2ch-net-url-unreserved-chars))
	  (if (< char 16)
	      (upcase (format "%%0%x" char))
	    (upcase (format "%%%x" char)))
	(char-to-string char))))
   (encode-coding-string str navi2ch-coding-system) ""))

(defun navi2ch-net-get-param-string (param-alist)
  (mapconcat
   (function
    (lambda (x)
      (concat (car x) "=" (navi2ch-net-url-hexify-string (cdr x)))))
   param-alist
   "&"))

(defun navi2ch-net-send-message-success-p (proc)
  (string-match "$B=q$-$3$_$^$7$?!#(B"
		(decode-coding-string (navi2ch-net-get-content proc)
				      navi2ch-coding-system)))
(defun navi2ch-net-send-message-error-string (proc)
  (let ((str (decode-coding-string (navi2ch-net-get-content proc)
				   navi2ch-coding-system)))
    (when (string-match "$B#E#R#R#O#R!'(B\\([^<]+\\)" str)
      (match-string 1 str))))
		   
(defun navi2ch-net-send-message (from mail message subject url referer bbs key)
  "$B%a%C%;!<%8$rAw$k!#(B
$BAw?.@.8y$J$i(B t $B$rJV$9(B"
  (let ((param-alist
         (list
          (cons "submit" "$B=q$-9~$`(B")
          (cons "FROM" (or from ""))
          (cons "mail" (or mail ""))
          (cons "bbs" bbs)
          (cons "time"
                (mapconcat 'int-to-string
                           (let ((time (current-time)))
                             (navi2ch-bigint-add
                              (navi2ch-bigint-multiply
                               (nth 0 time) (expt 2 16)) (nth 1 time)))
                           ""))
          (cons "MESSAGE" message)
          (if subject
              (cons "subject" subject)
            (cons "key" key)))))
    (let (proc)
      (setq proc (navi2ch-net-send-request
		  url "POST"
                  (list (cons "Content-Type"
                              "application/x-www-form-urlencoded")
                        (cons "Cookie"
                              (concat "NAME=" from
                                      "; MAIL=" mail))
                        (cons "Referer" referer))
                  (navi2ch-net-get-param-string param-alist)))
      (message "send message...")
      (if (navi2ch-net-send-message-success-p proc)
          (progn
            (message "send message...succeed")
            (delete-process proc) t)
	(let ((err (navi2ch-net-send-message-error-string proc)))
	  (if (stringp err)
	      (message "send message...failed: %s" err)
	    (message "send message...failed")))
        (delete-process proc) nil))))

(defun navi2ch-net-download-logo (board)
  (let* ((coding-system-for-read 'binary)
	 (coding-system-for-write 'binary)
	 (content (navi2ch-net-get-content
		   (navi2ch-net-download-file
		    (navi2ch-board-get-url board
					   navi2ch-net-setting-file-name))))
	 src)
    (when (string-match "BBS_TITLE_PICTURE=\\(.+\\)" content)
      (setq src (match-string 1 content)))
    (let (url file)
      (setq url (if (string-match "http://" src)
		    src
		  (navi2ch-board-get-url board src)))
      (string-match "/\\([^/]+\\)$" url)
      (setq file (match-string 1 url))
      (when file
	(setq file (navi2ch-board-get-file-name board file))
	(when (navi2ch-net-update-file url file nil nil t)
	  file)))))

(provide 'navi2ch-net)
