;;; navi2ch-net.el --- Network module for navi2ch

;; Copyright (C) 2000-2004 by Navi2ch Project

;; Author: Taiki SUGAWARA <taiki@users.sourceforge.net>
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

;;; Commentary:

;;

;;; Code:
(provide 'navi2ch-net)
(defconst navi2ch-net-ident
  "$Id$")

(eval-when-compile (require 'cl))
(require 'timezone)
(require 'base64)

(require 'navi2ch)

(defvar navi2ch-net-connection-name "navi2ch connection")
(defvar navi2ch-net-user-agent "Monazilla/1.00 Navi2ch")
(defvar navi2ch-net-setting-file-name "SETTING.TXT")
(defvar navi2ch-net-last-date nil)
(defvar navi2ch-net-last-url nil)
(defvar navi2ch-net-process nil)
(defvar navi2ch-net-last-host nil)
(defvar navi2ch-net-last-port nil)
(defvar navi2ch-net-status nil)
(defvar navi2ch-net-header nil)
(defvar navi2ch-net-content nil)
(defvar navi2ch-net-state-header-alist
  '((aborn . "X-Navi2ch-Aborn")		; $B$"$\!<$s$5$l$F$k(B
    (kako . "X-Navi2ch-Kako")		; $B2a5n%m%0$K$J$C$F$k(B
    (not-updated . "X-Navi2ch-Not-Updated") ; $B99?7$5$l$F$$$J$$(B
    (error . "X-Navi2ch-Error"))  ; $B%(%i!<(B($B%U%!%$%k$,<hF@$G$-$J$$$H$+(B)

  "STATE $B$N%7%s%\%k$H<B:]$K%X%C%@$K=q$+$l$kJ8;zNs$N(B alist$B!#(B")

(add-hook 'navi2ch-exit-hook 'navi2ch-net-cleanup)

;; shut up XEmacs warnings
(eval-when-compile
  (defvar inherit-process-coding-system))

(defmacro navi2ch-net-ignore-errors (&rest body)
  "BODY $B$rI>2A$7!"$=$NCM$rJV$9!#(B
BODY $B$NI>2ACf$K%(%i!<$,5/$3$k$H(B nil $B$rJV$9!#(B"
  (let ((done (make-symbol "--done-temp--"))
	(err (make-symbol "--err-temp--")))
    `(let ((,done nil))
       (unwind-protect
	   (condition-case ,err
	       (prog1
		   ,(cons 'progn body)
		 (setq ,done t))
	     (error
	      (ding)
	      (if ,err
		  (message "Error: %s" (error-message-string ,err))
		(message "Error"))
	      (sleep-for 1)
	      nil))
	 (unless ,done
	   (ignore-errors
	     (navi2ch-net-cleanup-process)))))))

(defun navi2ch-net-cleanup ()
  (let (buf)
    (if (processp navi2ch-net-process)
	(setq buf (process-buffer navi2ch-net-process)))
    (unwind-protect
	(navi2ch-net-cleanup-process)
      (if buf
	  (kill-buffer buf)))))

(defun navi2ch-net-cleanup-process ()
  (unwind-protect
      (if (processp navi2ch-net-process)
	  (delete-process navi2ch-net-process))
    (setq navi2ch-net-process nil)
    (navi2ch-net-cleanup-vars)))

(defun navi2ch-net-cleanup-vars ()
  (setq navi2ch-net-status nil
	navi2ch-net-header nil
	navi2ch-net-content nil))

(defun navi2ch-open-network-stream-with-retry (name buffer host service)
  (let ((retry t) proc)
    (while retry
      (condition-case err
	  (setq proc (open-network-stream name buffer host service)
		retry nil)
	(file-error
	 (save-match-data
	   (if (string-match "in progress" ; EINPROGRESS or EALREADY
			     (nth 2 err))
	       (progn
		 (setq retry t)
		 (sleep-for 1))
	     (signal (car err) (cdr err)))))))
    proc))

(defun navi2ch-open-network-stream-via-command (name buffer host service)
  (let ((command (cond ((stringp navi2ch-open-network-stream-command)
			(format navi2ch-open-network-stream-command
				host service))
		       ((functionp navi2ch-open-network-stream-command)
			(funcall navi2ch-open-network-stream-command
				 host service)))))
    (apply #'start-process name buffer
	   (if (stringp command)
	       (list shell-file-name shell-command-switch command)
	     command))))

(defun navi2ch-net-send-request (url method &optional other-header content)
  (setq navi2ch-net-last-url url)
  (unless navi2ch-net-enable-http11
    (navi2ch-net-cleanup-process))
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
    (let ((proc navi2ch-net-process))
      (condition-case nil
	  (if (and navi2ch-net-enable-http11
		   (equal host navi2ch-net-last-host)
		   (equal port navi2ch-net-last-port)
		   (processp proc)
		   (memq (process-status proc) '(open run)))
	      (progn
		(message "Reusing connection...")
		(process-send-string proc "") ; ping
		(navi2ch-net-get-content proc))	; $BA02s$N%4%_$rFI$_Ht$P$7$F$*$/(B
	    (if (processp proc)
		(delete-process proc))
	    (setq proc nil))
	(error (setq proc nil)))
      (when (or (not proc)
		(not (processp proc))
		(not (memq (process-status proc) '(open run))))
	(message "Now connecting...")
	(setq proc (funcall navi2ch-open-network-stream-function
			    navi2ch-net-connection-name buf host port)))
      (save-excursion
	(set-buffer buf)
	(navi2ch-set-buffer-multibyte nil)
	(erase-buffer))
      (setq navi2ch-net-last-host host)
      (setq navi2ch-net-last-port port)
      (message "%ssending request..." (current-message))
      (set-process-coding-system proc 'binary 'binary)
      (set-process-sentinel proc 'ignore) ; exited abnormary $B$r=P$5$J$/$9$k(B
      (process-send-string
       proc
       (format (concat
                "%s %s %s\r\n"
                "MIME-Version: 1.0\r\n"
                "Host: %s\r\n"
                "%s"			;connection
                "%s"                    ;other-header
                "%s"                    ;content
                "\r\n")
               method file
	       (if navi2ch-net-enable-http11
		   "HTTP/1.1"
		 "HTTP/1.0")
               host2ch
	       (if navi2ch-net-enable-http11
		   ""
		 "Connection: close\r\n")
	       (or (navi2ch-net-make-request-header
		    (cons (cons "Proxy-Authorization" credentials)
			  other-header))
		   "")
	       (if content
                   (format "Content-length: %d\r\n\r\n%s"
                           (length content) content)
                 "")))
      (message "%sdone" (current-message))
      (navi2ch-net-cleanup-vars)
      (setq navi2ch-net-process proc))))

(defun navi2ch-net-split-url (url &optional proxy)
  (let (host2ch)
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
      (string-match "http://\\([^/:]+\\):?\\([0-9]+\\)?\\(.*\\)" url)
      (list
       (cons 'host (match-string 1 url))
       (cons 'port (string-to-number (or (match-string 2 url)
					 "80")))
       (cons 'file (match-string 3 url))
       (cons 'host2ch host2ch)))))

(defun navi2ch-net-http-proxy-basic-credentials (user pass)
  "USER $B$H(B PASS $B$+$i(B Proxy $BG'>Z$N>ZL@=q(B (?) $BItJ,$rJV$9!#(B"
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
  "PROC $B$N@\B3$N%9%F!<%?%9It$rJV$9!#(B"
  (navi2ch-net-ignore-errors
   (or navi2ch-net-status
       (save-excursion
	 (set-buffer (process-buffer proc))
	 (while (and (memq (process-status proc) '(open run))
		     (goto-char (point-min))
		     (not (looking-at "HTTP/1\\.[01] \\([0-9]+\\)")))
	   (accept-process-output proc))
	 (goto-char (point-min))
	 (if (looking-at "HTTP/1\\.[01] \\([0-9]+\\)")
	     (setq navi2ch-net-status (match-string 1)))))))

(defun navi2ch-net-get-protocol (proc)
  (when (navi2ch-net-get-status proc)
    (with-current-buffer (process-buffer proc)
      (goto-char (point-min))
      (if (looking-at "\\(HTTP/1\\.[01]\\) [0-9]+")
	  (match-string 1)))))

(defun navi2ch-net-get-header (proc)
  "PROC $B$N@\B3$N%X%C%@It$rJV$9!#(B"
  (when (navi2ch-net-get-status proc)
    (navi2ch-net-ignore-errors
     (or navi2ch-net-header
	 (save-excursion
	   (set-buffer (process-buffer proc))
	   (while (and (memq (process-status proc) '(open run))
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
	     (let ((date (assoc-ignore-case "Date" list)))
	       (when (and date (stringp (cdr date)))
		 (setq navi2ch-net-last-date (cdr date))))
	     (setq navi2ch-net-header (nreverse list))))))))

(defun navi2ch-net-get-content-subr-with-temp-file (gzip-p start end)
  (if gzip-p
      (let* ((tempfn (make-temp-name (navi2ch-temp-directory)))
	     (tempfngz (concat tempfn ".gz")))
	(let ((coding-system-for-write 'binary)
	      ;; auto-compress-mode$B$r(Bdisable$B$K$9$k(B
	      (inhibit-file-name-operation 'write-region)
	      (inhibit-file-name-handlers (cons 'jka-compr-handler
						inhibit-file-name-handlers)))
	  (navi2ch-write-region start end tempfngz))
	(let ((status (call-process shell-file-name nil nil nil
				    shell-command-switch
				    (concat "gzip -d " tempfngz))))
	  (unless (and (numberp status) (zerop status))
	    (error "Failed to execute gzip")))
	(delete-region start end)
	(goto-char start)
	(goto-char (+ start
		      (nth 1 (insert-file-contents-literally tempfn))))
	(delete-file tempfn))))

(defun navi2ch-net-get-content-subr-region (gzip-p start end)
  (if gzip-p
      (let ((status (apply 'call-process-region
			   start end
			   navi2ch-net-gunzip-program t t nil
			   navi2ch-net-gunzip-args)))
	(unless (and (numberp status) (zerop status))
	  (error "Failed to execute gzip")))))

(defalias 'navi2ch-net-get-content-subr
  (navi2ch-ifemacsce
      'navi2ch-net-get-content-subr-with-temp-file
    'navi2ch-net-get-content-subr-region))

(defun navi2ch-net-get-chunk (proc)
  "$B%+%l%s%H%P%C%U%!$N(B PROC $B$N(B point $B0J9_$r(B chunk $B$H$_$J$7$F(B chunk $B$rF@$k!#(B
chunk $B$N%5%$%:$rJV$9!#(Bpoint $B$O(B chunk $B$ND>8e$K0\F0!#(B"
  (catch 'ret
    (let ((p (point))
	  size end)
      (while (and (not (looking-at "\\([0-9a-fA-F]+\\)[^\r\n]*\r\n"))
		  (memq (process-status proc) '(open run)))
	(accept-process-output proc)
	(goto-char p))
      (when (not (match-string 1))
	(message "No chunk-size line")
	(throw 'ret 0))
      (goto-char (match-end 0))
      (setq size (string-to-number (match-string 1) 16)
	    end (+ p size 2))		; chunk-data CRLF
      (delete-region p (point))		; chunk size $B9T$r>C$9(B
      (if (= size 0)
	  (throw 'ret 0))
      (while (and (memq (process-status proc) '(open run))
		  (goto-char end)
		  (not (= (point) end)))
	(accept-process-output proc))
      (goto-char end)
      (when (not (= (point) end))
	(message "Unable goto chunk end (size: %d, end: %d, point: %d)"
		 size end (point))
	(throw 'ret 0))
      (when (not (string= (buffer-substring (- (point) 2) (point))
			  "\r\n"))
	(message "Invalid chunk body")
	(throw 'ret 0))		   ; chunk-data $B$NKvHx$,(B CRLF $B$8$c$J$$(B
      (delete-region (- (point) 2) (point))
      size)))

(defun navi2ch-net-get-content (proc)
  "PROC $B$N@\B3$NK\J8$rJV$9!#(B"
  (when (and (navi2ch-net-get-status proc) (navi2ch-net-get-header proc))
    (navi2ch-net-ignore-errors
     (or navi2ch-net-content
	 (let* ((header (navi2ch-net-get-header proc))
		(gzip (and navi2ch-net-accept-gzip
			   (string-match "gzip"
					 (or (cdr (assoc "Content-Encoding"
							 header))
					     ""))))
		p)
	   (save-excursion
	     (set-buffer (process-buffer proc))
	     (goto-char (point-min))
	     (re-search-forward "\r\n\r?\n") ; header $B$N8e$J$N$G<h$l$F$k$O$:(B
	     (setq p (point))
	     (cond ((equal (cdr (assoc "Transfer-Encoding" header))
			   "chunked")
		    (while (> (navi2ch-net-get-chunk proc) 0)
		      nil))
		   ((assoc "Content-Length" header)
		    (let ((size (string-to-number (cdr (assoc "Content-Length"
							      header)))))
		      (while (and (memq (process-status proc) '(open run))
				  (goto-char (+ p size))
				  (not (= (point) (+ p size))))
			(accept-process-output proc))
		      (goto-char (+ p size))))
		   ((or (string= (navi2ch-net-get-protocol proc)
				 "HTTP/1.0")
			(not navi2ch-net-enable-http11)
			(and (stringp (cdr (assoc "Connection" header)))
			     (string= (cdr (assoc "Connection" header))
				      "close")))
		    (while (memq (process-status proc) '(open run))
		      (accept-process-output proc))
		    (goto-char (point-max))))
	     (when (and (stringp (cdr (assoc "Connection" header)))
			(string= (cdr (assoc "Connection" header))
				 "close"))
	       (delete-process proc))
	     (navi2ch-net-get-content-subr gzip p (point))
	     (setq navi2ch-net-content
		   (buffer-substring-no-properties p (point)))))))))

(defun navi2ch-net-download-file (url
				  &optional time accept-status other-header)
  "URL $B$+$i%@%&%s%m!<%I$r3+;O$9$k!#(B
TIME $B$,(B `non-nil' $B$J$i$P(B TIME $B$h$j?7$7$$;~$@$1%@%&%s%m!<%I$9$k!#(B
$B%j%9%H(B ACCEPT-STATUS $B$,(B `non-nil' $B$J$i$P%9%F!<%?%9$,(B ACCEPT-STATUS $B$K4^$^$l(B
$B$F$$$k;~$@$1%@%&%s%m!<%I$9$k!#(B
OTHER-HEADER $B$,(B `non-nil' $B$J$i$P%j%/%(%9%H$K$3$N%X%C%@$rDI2C$9$k!#(B
$B%@%&%s%m!<%I$G$-$l$P$=$N@\B3$rJV$9!#(B"
  (navi2ch-net-ignore-errors
   (let ((time (if (or (null time) (stringp time)) time
		 (navi2ch-http-date-encode time)))
	 proc status)
     (while (not status)
       (setq proc
	     (navi2ch-net-send-request
	      url "GET"
	      (append
	       (list (if navi2ch-net-force-update
			 (cons "Pragma" "no-cache")
		       (and time (cons "If-Modified-Since" time)))
		     (and navi2ch-net-accept-gzip
			  ;; regexp $B$OJQ?t$K$7$?J}$,$$$$$N$+$J!#$$$$JQ?tL>$,;W$$$D$+$J$$!#(B
			  (not (string-match "\\.gz$" url))
			  (not (assoc "Range" other-header))
			  '("Accept-Encoding" . "gzip"))
		     (and navi2ch-net-user-agent
			  (cons "User-Agent" navi2ch-net-user-agent)))
	       other-header)))
       (message "Checking file...")
       (setq status (navi2ch-net-get-status proc))
       (when (and (string= status "416")
		  (assoc "Range" other-header))
	 (let ((elt (assoc "Range" other-header)))
	   (setq other-header (delq elt other-header)
		 status nil)))
       (unless status
	 (message "Retrying...")
	 (sit-for 3)))			; $B%j%H%i%$$9$kA0$K$A$g$C$HBT$D(B
     (cond ((not (stringp status))
	    (message "%serror" (current-message))
	    (setq proc nil))
	   ((string= status "404")
	    (message "%snot found" (current-message))
	    (setq proc nil))
	   ((string= status "304")
	    (message "%snot updated" (current-message)))
	   ((string= status "302")
	    (message "%smoved" (current-message)))
	   ((string-match "\\`2[0-9][0-9]\\'" status)
	    (message "%supdated" (current-message)))
	   (t
	    (message "%serror" (current-message))
	    (setq proc nil)))
     (if (or (not accept-status)
	     (member status accept-status))
	 proc))))

(defun navi2ch-net-download-file-range (url range &optional time other-header)
  "Range $B%X%C%@$r;H$C$F%U%!%$%k$r%@%&%s%m!<%I$9$k!#(B"
  (navi2ch-net-download-file url time '("206" "200" "304") ;; 200 $B$b$"$C$F$b$$$$$N$+$J!)(B
			     (append
			      (list (cons "Range" (concat "bytes=" range)))
			      other-header)))


(defun navi2ch-net-update-file (url file &optional time func location diff)
  "FILE $B$r99?7$9$k!#(B
TIME $B$,(B non-nil $B$J$i$P(B TIME $B$h$j?7$7$$;~$@$199?7$9$k!#(B
TIME $B$,(B 'file $B$J$i$P%U%!%$%k$N99?7F|;~$r(B TIME $B$H$9$k!#(B
FUNC $B$,(B non-nil $B$J$i$P99?78e(B FUNC $B$r;H$C$F%U%!%$%k$rJQ49$9$k!#(B
FUNC $B$O(B current-buffer $B$rA`:n$9$k4X?t$G$"$k;v!#(B
LOCATION $B$,(B non-nil $B$J$i$P(B Location $B%X%C%@$,$"$C$?$i$=$3$K0\F0$9$k$h$&(B
$B$K$9$k!#(B
DIFF $B$,(B non-nil $B$J$i$P(B $B:9J,$H$7$F(B FILE $B$r>e=q$-$;$:$KDI2C$9$k!#(B
$B99?7$G$-$l$P(B header $B$rJV$9(B"
  (when (eq time 'file)
    (setq time (and (file-exists-p file)
		    (nth 5 (file-attributes file)))))
  (let ((dir (file-name-directory file)))
    (unless (file-exists-p dir)
      (make-directory dir t)))
  (let ((coding-system-for-write 'binary)
	(coding-system-for-read 'binary)
	(redo t)
	proc status header cont)
    (while redo
      (setq redo nil
	    proc (navi2ch-net-download-file url time
					    (list "200" "304"
						  (and location "302")))
	    status (and proc
			(navi2ch-net-get-status proc))
	    header (and proc
			(navi2ch-net-get-header proc)))
      (cond ((or (not proc)
		 (not status)
		 (not header))
	     ;; $BG0$N$?$a(B
	     (setq header (navi2ch-net-add-state 'error header)))
	    ((string= status "200")
	     (message (if diff
			  "%s: Getting file diff..."
			"%s: Getting new file...")
		      (current-message))
	     (setq cont (navi2ch-net-get-content proc))
	     (when (and cont func)
	       (message "%stranslating..." (current-message))
	       (setq cont (with-temp-buffer
			    (navi2ch-set-buffer-multibyte nil)
			    (insert cont)
			    (goto-char (point-min))
			    (funcall func)
			    (buffer-string))))
	     (if (and cont (not (string= cont "")))
		 (with-temp-file file
		   (navi2ch-set-buffer-multibyte nil)
		   (when diff
		     (insert-file-contents file)
		     (goto-char (point-max)))
		   (insert cont)
		   (message "%sdone" (current-message)))
	       (setq header (navi2ch-net-add-state 'not-updated header))
	       (message "%snot updated" (current-message))))
	    ((and location
		  (string= status "302")
		  (assoc "Location" header))
	     (setq url (cdr (assoc "Location" header))
		   redo t)
	     (message "%s: Redirecting..." (current-message)))
	    ((string= status "304")
	     (setq header (navi2ch-net-add-state 'not-updated header)))
	    (t
	     ;; $B$3$3$KMh$k$O$:$J$$$1$I0l1~(B
	     (setq header (navi2ch-net-add-state 'error header)))))
    header))

(defun navi2ch-net-get-length-from-header (header)
  "header $B$+$i(B contents $BA4BN$ND9$5$rF@$k!#(B
header $B$KD9$5$,4^$^$l$F$$$J$$>l9g$O(B nil $B$rJV$9!#(B"
  (let ((range (cdr (assoc "Content-Range" header)))
	(length (cdr (assoc "Content-Length" header))))
    (cond ((and range
		(string-match "/\\(.+\\)" range))
	   (string-to-number (match-string 1 range)))
	  (length
	   (string-to-number length)))))

(defun navi2ch-net-check-aborn (size header)
  "$B$"$\!<$s$5$l$F$J$1$l$P(B t $B$rJV$9!#(B"
  (let ((len (navi2ch-net-get-length-from-header header)))
    (if len
	(>= len (or size 0))
      t)))				; $B%[%s%H$K$3$l$G$$$$$+$J(B?

(defconst navi2ch-net-update-file-diff-size 16
  "$B:9J,<hF@$9$k:]$K%*!<%P!<%i%C%W$5$;$kI}!#(B")

(defun navi2ch-net-update-file-diff (url file &optional time)
  "FILE $B$r:9J,$G99?7$9$k!#(B
TIME $B$,(B `non-nil' $B$J$i$P(B TIME $B$h$j?7$7$$;~$@$199?7$9$k!#(B
$B99?7$G$-$l$P(B HEADER $B$rJV$9!#(B"
  (let ((dir (file-name-directory file)))
    (unless (file-exists-p dir)
      (make-directory dir t)))
  (let* ((coding-system-for-write 'binary)
	 (coding-system-for-read 'binary)
	 ;; $B%U%!%$%k%5%$%:$HEy$7$$CM$r(B range $B$K$9$k$H%U%!%$%k$rA4ItAw$C(B
	 ;; $B$F$/$k$N$G0z$$$F$*$/!#(B
	 (size (max 0 (- (nth 7 (file-attributes file))
			 navi2ch-net-update-file-diff-size)))
	 (last (and (> size 0)
		    (with-temp-buffer
		      (navi2ch-set-buffer-multibyte nil)
		      (insert-file-contents file nil size)
		      (buffer-string))))
	 proc header status aborn-p)
    (setq proc (navi2ch-net-download-file-range url (format "%d-" size) time))
    (setq header (and proc
		      (navi2ch-net-get-header proc)))
    (setq status (and proc
		      (navi2ch-net-get-status proc)))
    (cond ((or (not proc)
	       (not header)
	       (not status))
	   (setq header (navi2ch-net-add-state 'error header)))
	  ((string= status "304")
	   (setq header (navi2ch-net-add-state 'not-updated header)))
	  ((string= status "206")
	   (if (not (navi2ch-net-check-aborn size header))
	       (setq aborn-p t)
	     (message "%s: Getting file diff..." (current-message))
	     (let ((cont (navi2ch-net-get-content proc)))
	       (cond ((and (> size 0) last
			   (or (> (length last) (length cont))
			       (not (string= (substring cont 0 (length last))
					     last))))
		      (setq aborn-p t))	; $BA02s$H0lCW$7$J$$>l9g$O$"$\!<$s(B
		     ((string= cont last)
		      (message "%snot updated" (current-message))
		      (setq header
			    (navi2ch-net-add-state 'not-updated header)))
		     (t
		      (with-temp-file file
			(navi2ch-set-buffer-multibyte nil)
			(insert-file-contents file nil nil size)
			(goto-char (point-max))
			(insert cont))
		      (message "%sdone" (current-message)))))))
	  ((string= status "200")
	   (if (not (navi2ch-net-check-aborn size header))
	       (setq aborn-p t)
	     (message "%s: Getting whole file..." (current-message))
	     (let ((cont (navi2ch-net-get-content proc)))
	       (with-temp-file file
		 (navi2ch-set-buffer-multibyte nil)
		 (insert cont)))
	     (message "%sdone" (current-message))))
	  ((string= status "304")
	   (setq header (navi2ch-net-add-state 'not-updated header)))
	  (t
	   (setq header (navi2ch-net-add-state 'error header))))
    (if (not aborn-p)
	header
      (message "$B$"$\!<$s(B!!!")
      (navi2ch-net-save-aborn-file file)
      (navi2ch-net-add-state
       'aborn
       (navi2ch-net-update-file url file)))))

(defun navi2ch-net-save-aborn-file (file)
  (when (and navi2ch-net-save-old-file-when-aborn
	     (or (not (eq navi2ch-net-save-old-file-when-aborn
			  'ask))
		 (y-or-n-p "$B$"$\!<$s(B!!! Backup old file? ")))
    (copy-file file (read-file-name "file name: "))))

(defun navi2ch-net-update-file-with-readcgi (url file &optional time diff)
  "FILE $B$r(B URL $B$+$i(B read.cgi $B$r;H$C$F99?7$9$k!#(B
TIME $B$,(B non-nil $B$J$i$P(B TIME $B$h$j?7$7$$;~$@$199?7$9$k!#(B
DIFF $B$,(B non-nil $B$J$i$P:9J,$r<hF@$9$k!#(B
$B99?7$G$-$l$P(B HEADER $B$rJV$9!#(B"
  (let ((dir (file-name-directory file))
	proc header status)
    (unless (file-exists-p dir)
      (make-directory dir t))
    (setq proc (navi2ch-net-download-file url time))
    (setq header (and proc
		      (navi2ch-net-get-header proc)))
    (setq status (and proc
		      (navi2ch-net-get-status proc)))
    (cond ((or (not proc)
	       (not header)
	       (not status))
	   (setq header (navi2ch-net-add-state 'error header)))
	  ((string= status "304")
	   (setq header (navi2ch-net-add-state 'not-updated header)))
	  ((string= status "200")
	   (let ((coding-system-for-write 'binary)
		 (coding-system-for-read 'binary)
		 cont)
	     (message (if diff
			  "%s: Getting file diff with read.cgi..."
			"%s: Getting new file with read.cgi...")
		      (current-message))
	     (setq cont (navi2ch-net-get-content proc))
	     (if (or (not cont)
		     (string= cont ""))
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
		 (cond
		  ((string= "+OK" state)
		   (with-temp-file file
		     (navi2ch-set-buffer-multibyte nil)
		     (when (and (file-exists-p file) diff)
		       (insert-file-contents file)
		       (goto-char (point-max)))
		     (insert (substring cont 0 cont-size))))
		  ((string= "-INCR" state) ;; $B$"$\!<$s(B
		   (with-temp-file file
		     (navi2ch-set-buffer-multibyte nil)
		     (insert (substring cont 0 cont-size)))
		   (setq header (navi2ch-net-add-state 'aborn header)))
		  ((string= "-ERR" state)
		   (let ((err-msg (decode-coding-string
				   data navi2ch-coding-system)))
		     (message "Error! %s" err-msg)
		     (cond
		      ((string-match "$B2a5n%m%0AR8K$GH/8+(B" err-msg)
		       (setq header (navi2ch-net-add-state 'kako header)))
;;; 		      ((and (string-match "html$B2=BT$A(B" err-msg)
;;; 			    (string-match "/read\\.cgi/" url))
;;; 		       (setq url (replace-match "/offlaw.cgi/" t nil url))
;;; 		       (navi2ch-net-update-file-with-readcgi
;;; 			url file time diff))
		      (t
		       (setq header
			     (navi2ch-net-add-state 'error header)))))))))))
	  (t
	   ;; $B$3$3$KMh$k$O$:$J$$$1$I0l1~(B
	   (setq header (navi2ch-net-add-state 'error header))))
    header))

;; <http://www.ietf.org/rfc/rfc2396.txt>
;; 2.3. Unreserved Characters
;; unreserved  = alphanum | mark
;; mark        = "-" | "_" | "." | "!" | "~" | "*" | "'" | "(" | ")"

;; from Emacs/W3
(defconst navi2ch-net-url-unreserved-chars
  '(
    ?a ?b ?c ?d ?e ?f ?g ?h ?i ?j ?k ?l ?m ?n ?o ?p ?q ?r ?s ?t ?u ?v ?w ?x ?y ?z
    ?A ?B ?C ?D ?E ?F ?G ?H ?I ?J ?K ?L ?M ?N ?O ?P ?Q ?R ?S ?T ?U ?V ?W ?X ?Y ?Z
    ?0 ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9
    ?- ?_ ?. ?! ?~ ?* ?' ?\( ?\))
  "A list of characters that are _NOT_ reserve in the URL spec.
This is taken from RFC 2396.")

;; from Emacs/W3
(defun navi2ch-net-url-hexify-string (str &optional coding-system)
  "Escape characters in a string."
  (mapconcat (lambda (char)
	       (if (not (memq char navi2ch-net-url-unreserved-chars))
		   (format "%%%02X" char)
		 (char-to-string char)))
	     (encode-coding-string str (or coding-system navi2ch-coding-system)) ""))

(defun navi2ch-net-get-param-string (param-alist &optional coding-system)
  (mapconcat (lambda (x)
	       (concat (navi2ch-net-url-hexify-string (car x) coding-system) "="
		       (navi2ch-net-url-hexify-string (cdr x) coding-system)))
	     param-alist "&"))

(defun navi2ch-net-send-message-success-p (proc coding-system)
  (let ((str (decode-coding-string (navi2ch-net-get-content proc)
				   coding-system)))
    (cond ((or (string-match "$B=q$-$3$_$^$7$?!#(B" str)
	       (string-match "$B=q$-$3$_$,=*$o$j$^$7$?!#(B" str))
	   t)
	  ((or (string-match "<b>$B%/%C%-!<$,$J$$$+4|8B@Z$l$G$9!*(B</b>" str)
	       (string-match "<b>$B=q$-$3$_!u%/%C%-!<3NG'(B</b>" str))
	   'retry)
	  (t
	   nil))))

(defun navi2ch-net-send-message-error-string (proc coding-system)
  (let ((str (decode-coding-string (navi2ch-net-get-content proc)
				   coding-system)))
    (cond ((string-match "$B#E#R#R#O#R!'(B\\([^<]+\\)" str)
	   (match-string 1 str))
	  ;; Samba24 http://age.s22.xrea.com/talk2ch/new.txt
	  ((string-match "$B#E#R#R#O#R(B - \\([^<\n]+\\)" str)
	   (match-string 1 str))
	  ((string-match "\\($B%m%0%$%s%(%i!<(B[^<]*\\)<br>" str)
	   (match-string 1 str))
	  ((string-match "<b>\\([^<]+\\)" str)
	   (match-string 1 str))
	  ((string-match "\\([^<>\n]+\\)<br>\\([^<>]+\\)<hr>"  str)
	   (concat (match-string 1 str) (match-string 2 str))))))

;; Set-Cookie: SPID=6w9HFhEM; expires=Tuesday, 23-Apr-2002 00:00:00 GMT; path=/
(defun navi2ch-net-send-message-get-spid (proc)
  (dolist (pair (navi2ch-net-get-header proc))
    (if (string-equal "Set-Cookie" (car pair))
	(let* ((str (cdr pair))
	       (date (when (string-match "expires=\\([^;]+\\);" str)
		       (navi2ch-http-date-decode (match-string 1 str)))))
	  (cond ((string-match "^SPID=\\([^;]+\\);" str)
		 (return (cons (match-string 1 str) date)))
		((string-match "^PON=\\([^;]+\\);" str)
		 (return (cons (match-string 1 str) date))))))))

(defun navi2ch-net-download-logo (board)
  (let ((coding-system-for-read 'binary)
	(coding-system-for-write 'binary)
	(setting-file (navi2ch-board-get-file-name
		       board navi2ch-net-setting-file-name))
	(setting-url (navi2ch-board-get-url
		      board navi2ch-net-setting-file-name))
	content src)
    (when (and (navi2ch-net-update-file setting-url setting-file 'file)
	       (file-exists-p setting-file))
      (setq content (with-temp-buffer
		      (insert-file-contents setting-file)
		      (buffer-string))))
    (when (and content
	       (string-match
		"BBS_\\(TITLE_PICTURE\\|FIGUREHEAD\\)=\\(.+\\)" content))
      (setq src (match-string 2 content))
      (let (url file)
	(setq url (if (string-match "http://" src)
		      src
		    (navi2ch-board-get-url board src)))
	(string-match "/\\([^/]+\\)$" url)
	(setq file (match-string 1 url))
	(when file
	  (setq file (navi2ch-board-get-file-name board file))
	  (when (navi2ch-net-update-file url file 'file nil t)
	    file))))))

(defun navi2ch-net-add-state (state header)
  "HEADER $B$K(B STATE $B$rDI2C$9$k!#(B"
  (navi2ch-put-alist (cdr (assq state navi2ch-net-state-header-alist))
		     "yes"
		     header))

(defun navi2ch-net-get-state (state header)
  "HEADER $B$+$i(B STATE $B$r<hF@$9$k!#(B"
  (cdr (assoc (cdr (assq state navi2ch-net-state-header-alist))
	      header)))

(run-hooks 'navi2ch-net-load-hook)
;;; navi2ch-net.el ends here
