;;; navi2ch-article.el --- article view module for navi2ch

;; Copyright (C) 2000-2002 by Navi2ch Project

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
(provide 'navi2ch-article)
(defvar navi2ch-article-ident
  "$Id$")

(eval-when-compile (require 'cl))
(require 'base64)

(require 'navi2ch)

(defvar navi2ch-article-mode-map nil)
(unless navi2ch-article-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map navi2ch-global-view-map)
    (define-key map "q" 'navi2ch-article-exit)
    (define-key map "Q" 'navi2ch-article-goto-current-board)
    (define-key map "s" 'navi2ch-article-sync)
    (define-key map "S" 'navi2ch-article-sync-disable-diff)
    (define-key map "r" 'navi2ch-article-redraw-range)
    (define-key map "j" 'navi2ch-article-few-scroll-up)
    (define-key map "k" 'navi2ch-article-few-scroll-down)
    (define-key map " " 'navi2ch-article-scroll-up)
    (define-key map [del] 'navi2ch-article-scroll-down)
    (define-key map [delete] 'navi2ch-article-scroll-down)
    (define-key map [backspace] 'navi2ch-article-scroll-down)
    (define-key map "\177" 'navi2ch-article-scroll-down)
    (define-key map "w" 'navi2ch-article-write-message)
    (define-key map "W" 'navi2ch-article-write-sage-message)
    (define-key map "\r" 'navi2ch-article-select-current-link)
    (navi2ch-define-mouse-key map 2 'navi2ch-article-mouse-select)
    (define-key map "g" 'navi2ch-article-goto-number-or-board)
    ;; (define-key map "g" 'navi2ch-article-goto-number)
    (define-key map "l" 'navi2ch-article-pop-point)
    (define-key map "L" 'navi2ch-article-pop-poped-point)
    (define-key map "m" 'navi2ch-article-push-point)
    (define-key map "R" 'navi2ch-article-rotate-point)
    (define-key map "U" 'navi2ch-article-show-url)
    (define-key map "." 'navi2ch-article-redisplay-current-message)
    (define-key map "p" 'navi2ch-article-previous-message)
    (define-key map "n" 'navi2ch-article-next-message)
    (define-key map "P" 'navi2ch-article-through-previous)
    (define-key map "N" 'navi2ch-article-through-next)
    (define-key map [(shift tab)] 'navi2ch-article-previous-link)
    (define-key map [(shift iso-lefttab)] 'navi2ch-article-previous-link)
    (define-key map "\e\C-i" 'navi2ch-article-previous-link)
    (define-key map "\C-\i" 'navi2ch-article-next-link)
    (define-key map  "i" 'navi2ch-article-fetch-link)
    (define-key map ">" 'navi2ch-article-goto-last-message)
    (define-key map "<" 'navi2ch-article-goto-first-message)
    (define-key map "\eu" 'navi2ch-article-uudecode-message)
    ;; (define-key map "\eb" 'navi2ch-article-base64-decode-message)
    (define-key map "\ed" 'navi2ch-article-decode-message)
    (define-key map "v" 'navi2ch-article-view-aa)
    (define-key map "f" 'navi2ch-article-forward-buffer)
    (define-key map "b" 'navi2ch-article-backward-buffer)
    (define-key map "d" 'navi2ch-article-hide-message)
    (define-key map "a" 'navi2ch-article-add-important-message)
    (define-key map "h" 'navi2ch-article-toggle-hide)
    (define-key map "$" 'navi2ch-article-toggle-important)
    (define-key map "A" 'navi2ch-article-add-global-bookmark)
    (define-key map "\C-c\C-m" 'navi2ch-message-pop-message-buffer)
    (define-key map "G" 'navi2ch-article-goto-board)
    (define-key map "e" 'navi2ch-article-textize-article)
    (define-key map "?" 'navi2ch-article-search)
    (setq navi2ch-article-mode-map map)))

(defvar navi2ch-article-mode-menu-spec
  '("Article"
    ["Toggle offline" navi2ch-toggle-offline]
    ["Sync" navi2ch-article-sync]
    ["Sync (no diff)" navi2ch-article-sync-disable-diff]
    ["Exit" navi2ch-article-exit]
    ["Write message" navi2ch-article-write-message]
    ["Write message (sage)" navi2ch-article-write-sage-message]
    ["Select Range" navi2ch-article-redraw-range]))

(defvar navi2ch-article-view-range nil
  "$BI=<($9$k%9%l%C%I$NHO0O!#(B
$B=q<0$O(B '(first . last) $B$G!"(B
first $B$,:G=i$+$i$$$/$DI=<($9$k$+!"(B
last $B$,:G8e$+$i$$$/$DI=<($9$k$+!#(B
$BNc$($P!"(B(10 . 50) $B$G!":G=i$N(B10$B$H:G8e$N(B50$B$rI=<((B")

(defvar navi2ch-article-buffer-name-prefix "*navi2ch article ")
(defvar navi2ch-article-current-article nil)
(defvar navi2ch-article-current-board nil)
(defvar navi2ch-article-message-list nil)
(defvar navi2ch-article-point-stack nil "$B0LCV$r3P$($H$/(B stack")
(defvar navi2ch-article-poped-point-stack nil)
(defvar navi2ch-article-separator nil)
(defvar navi2ch-article-hide-mode nil)
(defvar navi2ch-article-window-configuretion nil)
(defvar navi2ch-article-through-next-function 'navi2ch-article-through-next)
(defvar navi2ch-article-through-previous-function 'navi2ch-article-through-previous)
(defvar navi2ch-article-save-info-keys
  '(number name time hide importatnt mail kako))

(defvar navi2ch-article-insert-message-separator-function
  (if (and window-system
	   (eq emacs-major-version 20)
	   (not (featurep 'xemacs)))
      'navi2ch-article-insert-message-separator-by-face
    'navi2ch-article-insert-message-separator-by-char)
  "$B%;%Q%l!<%?$rA^F~$9$k4X?t(B")

(defvar navi2ch-article-summary-file-name "article-summary")

;; important mode
(defvar navi2ch-article-important-mode nil)
(defvar navi2ch-article-important-mode-map nil)
(unless navi2ch-article-important-mode-map
  (setq navi2ch-article-important-mode-map (make-sparse-keymap))
  (define-key navi2ch-article-important-mode-map "d" 'navi2ch-article-delete-important-message)
  (define-key navi2ch-article-important-mode-map "a" 'undefined))

;; hide mode
(defvar navi2ch-article-hide-mode nil)
(defvar navi2ch-article-hide-mode-map nil)
(unless navi2ch-article-hide-mode-map
  (setq navi2ch-article-hide-mode-map (make-sparse-keymap))
  (define-key navi2ch-article-hide-mode-map "d" 'navi2ch-article-cancel-hide-message)
  (define-key navi2ch-article-hide-mode-map "a" 'undefined))

;; local variables
(make-variable-buffer-local 'navi2ch-article-current-article)
(make-variable-buffer-local 'navi2ch-article-current-board)
(make-variable-buffer-local 'navi2ch-article-message-list)
(make-variable-buffer-local 'navi2ch-article-point-stack)
(make-variable-buffer-local 'navi2ch-article-poped-point-stack)
(make-variable-buffer-local 'navi2ch-article-view-range)
(make-variable-buffer-local 'navi2ch-article-separator)
(make-variable-buffer-local 'navi2ch-article-through-next-function)
(make-variable-buffer-local 'navi2ch-article-through-previous-function)

;; add hook
(defun navi2ch-article-kill-emacs-hook ()
  (navi2ch-article-expunge-buffers 0))

(add-hook 'navi2ch-kill-emacs-hook 'navi2ch-article-kill-emacs-hook)

;;; navi2ch-article functions
(defun navi2ch-article-get-url (board article &optional no-kako)
  (let ((artid (cdr (assq 'artid article)))
	(url (navi2ch-board-get-uri board)))
    (if (and (not no-kako)
	     (cdr (assq 'kako article)))
	(navi2ch-article-get-kako-url board article)
      (concat url "dat/" artid ".dat"))))

(defun navi2ch-article-get-kako-url (board article)
  (let ((artid (cdr (assq 'artid article)))
	(url (navi2ch-board-get-uri board)))
    (concat url "kako/"
	    (if (= (length artid) 9)
		(substring artid 0 3)
	      (concat (substring artid 0 4) "/" (substring artid 0 5)))
	    "/" artid ".dat.gz")))

(defun navi2ch-article-get-file-name (board article)
  (navi2ch-board-get-file-name board
                               (concat (cdr (assq 'artid article)) ".dat")))

(defun navi2ch-article-get-info-file-name (board article)
  (navi2ch-board-get-file-name board
                               (concat "info/" (cdr (assq 'artid article)))))

(defsubst navi2ch-article-inside-range-p (num range len)
  "NUM $B$,(B RANGE $B$G<($9HO0O$KF~$C$F$k$+(B
LEN $B$O(B RANGE $B$GHO0O$r;XDj$5$l$k(B list $B$ND9$5(B"
  (or (not range)
      (<= num (car range))
      (> num (- len (cdr range)))))

(defsubst navi2ch-article-get-buffer-name (board article)
  (concat navi2ch-article-buffer-name-prefix
	  (navi2ch-article-get-url board article 'no-kako)))

(defsubst navi2ch-article-check-cached (board article)
  "BOARD $B$H(B ARTICLE $B$G;XDj$5$l$k%9%l%C%I$,%-%c%C%7%e$5$l$F$k$+!#(B"
  (cond ((get-buffer (navi2ch-article-get-buffer-name board article))
         'view)
        ((file-exists-p (navi2ch-article-get-file-name board article))
	 ;; ((member (concat (cdr (assq 'artid article)) ".dat") list)
         'cache)))

(defmacro navi2ch-article-summary-element-seen (element)
  `(plist-get ,element :seen))

(defmacro navi2ch-article-summary-element-access-time (element)
  `(plist-get ,element :access-time))

(defmacro navi2ch-article-summary-element-set-seen (element seen)
  `(setq ,element (plist-put ,element :seen ,seen)))

(defmacro navi2ch-article-summary-element-set-access-time (element time)
  `(setq ,element (plist-put ,element :access-time ,time)))

(defun navi2ch-article-url-to-article (url)
  "URL $B$+$i(B article $B$KJQ49!#(B"
  (navi2ch-multibbs-url-to-article url))

(defun navi2ch-article-to-url (board article &optional start end nofirst)
  "BOARD, ARTICLE $B$+$i(B url $B$KJQ49!#(B
START, END, NOFIRST $B$GHO0O$r;XDj$9$k(B"
  (navi2ch-multibbs-article-to-url board article start end nofirst))

(defsubst navi2ch-article-cleanup-message ()
  (let (re str)
    (when navi2ch-article-cleanup-trailing-newline ; $B%l%9KvHx$N6uGr$r<h$j=|$/(B
      (goto-char (point-min))
      (when (re-search-forward "\\(<br> *\\)+<>" nil t)
	(replace-match "<>")))
    (when navi2ch-article-cleanup-white-space-after-old-br
      (goto-char (point-min))
      (while (re-search-forward "<br> *" nil t)
	(setq str (match-string 0))
	(if (or (not re)
		(< (length str) (length re)))
	    (setq re str))))
    (when navi2ch-article-cleanup-trailing-whitespace
      (setq re (concat " *" (or re "<br>"))))
    (unless (or (not re)
		(string= re "<br>"))
      (goto-char (point-min))
      (while (re-search-forward re nil t)
	(replace-match "<br>")))))	; "\n" $B$G$b$$$$$+$b!#(B

(defsubst navi2ch-article-parse-message (str &optional sep)
  (or sep (setq sep navi2ch-article-separator))
  (unless (string= str "")
;;;     (let ((strs (split-string str sep))
;;; 	  (syms '(name mail date data subject))
;;; 	  s)
;;;       (mapcar (lambda (sym)
;;; 		(setq s (or (car strs) "")
;;; 		      strs (cdr strs))
;;; 		(cons sym
;;; 		      (if (eq sym 'data)
;;; 			  (navi2ch-replace-html-tag-with-temp-buffer s)
;;; 			(navi2ch-replace-html-tag s))))
;;; 	      syms))))
    (with-temp-buffer
      (let ((syms '(name mail date data subject))
	    alist max)
	(insert str)
	(navi2ch-article-cleanup-message)
	(setq max (point-max-marker))
	(goto-char (point-min))
	(setq alist (mapcar
		     (lambda (sym)
		       (cons sym
			     (cons (point-marker)
				   (if (re-search-forward sep nil t)
				       (copy-marker (match-beginning 0))
				     (goto-char max)
				     max))))
		     syms))
	(navi2ch-replace-html-tag-with-buffer)
	(dolist (x alist)
	  (setcdr x (buffer-substring-no-properties (cadr x) (cddr x))))
	alist))))

(defun navi2ch-article-get-separator ()
  (save-excursion
    (beginning-of-line)
    (if (looking-at "[^\n]+<>[^\n]*<>")
        " *<> *"
      " *, *")))

(defsubst navi2ch-article-get-first-message ()
  "current-buffer $B$N(B article $B$N:G=i$N(B message $B$rJV$9!#(B"
  (goto-char (point-min))
  (navi2ch-article-parse-message
   (buffer-substring-no-properties (point)
				   (progn (forward-line 1)
					  (1- (point))))
   (navi2ch-article-get-separator)))

(defsubst navi2ch-article-get-first-message-from-file (file)
  "FILE $B$G;XDj$5$l$?(B article $B$N:G=i$N(B message $B$rJV$9!#(B"
  (with-temp-buffer
    (navi2ch-insert-file-contents file)
    (navi2ch-article-get-first-message)))

(defun navi2ch-article-apply-filters (board)
  (dolist (filter navi2ch-article-filter-list)
    (if (stringp (car-safe filter))
	(apply 'navi2ch-call-process-buffer
	       (mapcar (lambda (x)
			 (if (eq x 'board)
			     (cdr (assq 'id board))
			   x))
		       filter))
      (funcall filter))))

(defun navi2ch-article-get-message-list (file &optional begin end)
  "FILE $B$N(B BEGIN $B$+$i(B END $B$^$G$NHO0O$+$i%9%l$N(B list $B$r:n$k(B
$B6u9T$O(B nil"
  (when (file-exists-p file)
    (let ((board navi2ch-article-current-board)
	  sep message-list)
      (with-temp-buffer
        (navi2ch-insert-file-contents file begin end)
        (let ((i 1))
	  (navi2ch-article-apply-filters board)
          (message "splitting current messages...")
          (goto-char (point-min))
          (setq sep (navi2ch-article-get-separator))
          (while (not (eobp))
            (setq message-list
                  (cons (cons i
			      (let ((str (buffer-substring-no-properties
					  (point)
					  (progn (forward-line 1)
						 (1- (point))))))
				(unless (string= str "") str)))
                        message-list))
            (setq i (1+ i)))
          (message "splitting current messages...done")))
      (setq navi2ch-article-separator sep) ; it's a buffer local variable...
      (nreverse message-list))))

(defun navi2ch-article-append-message-list (list1 list2)
  (let ((num (length list1)))
    (append list1
	    (mapcar
	     (lambda (x)
	       (setq num (1+ num))
	       (cons num (cdr x)))
	     list2))))

(defun navi2ch-article-insert-message-separator-by-face ()
  (let ((p (point)))
    (insert "\n")
    (put-text-property p (point) 'face 'underline)))

(defun navi2ch-article-insert-message-separator-by-char ()
  (insert (make-string (eval navi2ch-article-message-separator-width)
		       navi2ch-article-message-separator) "\n"))

(defsubst navi2ch-article-set-link-property-subr (start end type value)
  (let ((face (cond ((eq type 'number) 'navi2ch-article-link-face)
		    ((eq type 'url) 'navi2ch-article-url-face))))
    (add-text-properties start end
			 (list 'face face
			       'help-echo (function navi2ch-article-help-echo)
			       'link t
			       'mouse-face navi2ch-article-mouse-face
			       type value))
    (add-text-properties start (1+ start)
			 (list 'link-head t))))

(defsubst navi2ch-article-set-link-property ()
  ">>1 $B$H$+(B http:// $B$K(B property $B$rIU$1$k(B"
  (goto-char (point-min))
  (while (re-search-forward (concat navi2ch-article-number-prefix-regexp
				    navi2ch-article-number-number-regexp)
			    nil t)
    (navi2ch-article-set-link-property-subr
     (match-beginning 0) (match-end 0)
     'number (navi2ch-match-string-no-properties 1))
    (while (looking-at (concat navi2ch-article-number-separator-regexp
			       navi2ch-article-number-number-regexp))
      (navi2ch-article-set-link-property-subr
       (match-beginning 1) (match-end 1)
       'number (navi2ch-match-string-no-properties 1))
      (goto-char (match-end 0))))
  (goto-char (point-min))
  (while (re-search-forward navi2ch-article-url-regexp nil t)
    (let ((start (match-beginning 0))
	  (end (match-end 0))
	  (url (navi2ch-match-string-no-properties 0)))
      (when (string-match "^ttps?:" url)
	(setq url (concat "h" url)))
      (navi2ch-article-set-link-property-subr start end 'url url))))

(defsubst navi2ch-article-put-cite-face ()
  (goto-char (point-min))
  (while (re-search-forward navi2ch-article-citation-regexp nil t)
    (put-text-property (match-beginning 0)
		       (match-end 0)
		       'face 'navi2ch-article-citation-face)))

(defsubst navi2ch-article-arrange-message ()
  (goto-char (point-min))
  (let ((id (cdr (assq 'id navi2ch-article-current-board))))
    (when (or (member id navi2ch-article-enable-fill-list)
	      (and (not (member id navi2ch-article-disable-fill-list))
		   navi2ch-article-enable-fill))
      (set-hard-newline-properties (point-min) (point-max))
      (let ((fill-column (- (window-width) 5))
	    (use-hard-newlines t))
	(fill-region (point-min) (point-max)))))
  (run-hooks 'navi2ch-article-arrange-message-hook))

(defsubst navi2ch-article-insert-message (num alist)
  (let ((p (point)))
    (insert (funcall navi2ch-article-header-format-function
                     num
                     (cdr (assq 'name alist))
                     (cdr (assq 'mail alist))
                     (cdr (assq 'date alist))))
    (put-text-property p (1+ p) 'current-number num)
    (setq p (point))
    (insert (cdr (assq 'data alist)) "\n")
    (save-excursion
      (save-restriction
	(narrow-to-region p (point))
	;; (navi2ch-article-cleanup-message) ; $B$d$C$QCY$$(B
	(put-text-property (point-min) (point-max) 'face
			   'navi2ch-article-face)
	(navi2ch-article-put-cite-face)
	(navi2ch-article-set-link-property)
        (if navi2ch-article-auto-decode-base64-p
            (navi2ch-article-auto-decode-base64-section))
	(navi2ch-article-arrange-message))))
  (funcall navi2ch-article-insert-message-separator-function)
  (insert "\n"))

(defun navi2ch-article-insert-messages (list range)
  "LIST $B$r@07A$7$FA^F~$9$k(B"
  (message "inserting current messages...")
  (let ((len (length list))
        (hide (cdr (assq 'hide navi2ch-article-current-article)))
        (imp (cdr (assq 'important navi2ch-article-current-article))))
    (dolist (x list)
      (let ((num (car x))
            (alist (cdr x)))
        (when (and alist
		   (cond (navi2ch-article-hide-mode
			  (memq num hide))
			 (navi2ch-article-important-mode
			  (memq num imp))
			 (t
			  (and (navi2ch-article-inside-range-p num range len)
			       (not (memq num hide))))))
          (when (stringp alist)
            (setq alist (navi2ch-article-parse-message alist)))
	  (let (filter-result)
	    (setq filter-result
		  (let ((filtered (navi2ch-article-apply-message-filters alist)))
		    (when filtered
		      (cond ((stringp filtered)
			     (navi2ch-put-alist 'name filtered alist)
			     (navi2ch-put-alist 'data filtered alist)
			     (navi2ch-put-alist 'mail
						(if (string-match "sage"
								  (cdr (assq 'mail alist)))
						    "sage"
						  "")
						alist))
			    ((eq filtered 'hide)
			     'hide)
			    ((eq filtered 'important)
			     'important)))))
	    (if (and (eq filter-result 'hide)
		     (not navi2ch-article-hide-mode))
		(progn
		  (setq hide (cons num hide))
		  (setq navi2ch-article-current-article
			(navi2ch-put-alist 'hide
					   hide
					   navi2ch-article-current-article)))
	      (when (and (eq filter-result 'important)
			 (not navi2ch-article-important-mode))
		    (setq imp (cons num imp))
		    (setq navi2ch-article-current-article
			  (navi2ch-put-alist 'important
					     imp
					     navi2ch-article-current-article)))
	      (setcdr x (navi2ch-put-alist 'point (point-marker) alist))
	      ;; (setcdr x (navi2ch-put-alist 'point (point) alist))
	      (navi2ch-article-insert-message num alist))))))
    (garbage-collect) ; navi2ch-parse-message $B$OBgNL$K%4%_$r;D$9(B
    (message "inserting current messages...done")))

(defun navi2ch-article-apply-message-filters (alist)
  (catch 'loop
    (dolist (filter navi2ch-article-message-filter-list)
      (let ((result (funcall filter alist)))
	(when result
	  (throw 'loop result))))))

(defun navi2ch-article-message-filter-by-name (alist)
  (when navi2ch-article-message-filter-by-name-alist
    (navi2ch-article-message-filter-subr
     navi2ch-article-message-filter-by-name-alist
     (cdr (assq 'name alist)))))

(defun navi2ch-article-message-filter-by-message (alist)
  (when navi2ch-article-message-filter-by-message-alist
    (navi2ch-article-message-filter-subr
     navi2ch-article-message-filter-by-message-alist
     (cdr (assq 'data alist)))))

(defun navi2ch-article-message-filter-by-id (alist)
  (let ((case-fold-search nil))
    (when (and navi2ch-article-message-filter-by-id-alist
	       (string-match " ID:\\([^ ]+\\)"
			     (cdr (assq 'date alist))))
      (navi2ch-article-message-filter-subr
       navi2ch-article-message-filter-by-id-alist
       (match-string 1 (cdr (assq 'date alist)))))))

(defun navi2ch-article-message-filter-subr (rules string)
  (let ((case-fold-search nil))
    (catch 'loop
      (dolist (rule rules)
	(when (string-match (regexp-quote (car rule))
			    string)
	  (throw 'loop (cdr rule)))))))

(defun navi2ch-article-default-header-format-function (number name mail date)
  "$B%G%U%)%k%H$N%X%C%@$r%U%)!<%^%C%H$9$k4X?t(B
  $B%X%C%@$N(Bface $B$rIU$1$k$N$b$3$3$G!#(B"
  (let ((from-header "From: ")
        (from (format "[%d] %s <%s>\n" number name mail))
        (date-header "Date: ")
        str p)
    ;;$BMKF|I=<($9$k!)(B
    (if navi2ch-article-dispweek
	(setq date (navi2ch-article-appendweek date)))
    (setq str (concat from-header from date-header date "\n\n"))
    (setq p (length from-header))
    (put-text-property 0 p
		       'face 'navi2ch-article-header-face str)
    (put-text-property p (1- (setq p (+ p (length from))))
 		       'face 'navi2ch-article-header-contents-face str)
    (put-text-property p (setq p (+ p (length date-header)))
		       'face 'navi2ch-article-header-face str)
    (put-text-property p (setq p (+ p (length date)))
		       'face 'navi2ch-article-header-contents-face str)
    str))

(defun navi2ch-article-appendweek (d)
  "YY/MM/DD$B7A<0$NF|IU$KMKF|$rB-$9!#(B"
  (let ((youbi '("$BF|(B" "$B7n(B" "$B2P(B" "$B?e(B" "$BLZ(B" "$B6b(B" "$BEZ(B"))
	year month day et dt time date)
    ;; "$B$"$\!<$s(B"$B$H$+(BID$B$H$+5l7A<0$NF|IU$K$bBP1~$7$F$$$k$O$:!%(B
    ;; $B@55,I=8=$K9)IW$,I,MW$+$b!D(B
    (if (string-match "^\\([0-9][0-9]/[0-9][0-9]/[0-9][0-9]\\) \\([A-Za-z0-9: +/?]+\\)$" d)
	(progn
	  (setq time (match-string 2 d))
	  (setq date (match-string 1 d))
	  (string-match "\\(.+\\)/\\(.*\\)/\\(.*\\)" date)
	  (setq year (+ (string-to-number (match-string 1 date)) 2000))
	  (setq month (string-to-number (match-string 2 date)))
	  (setq day (string-to-number (match-string 3 date)))
	  (setq et (encode-time 0 0 0 day month year))
	  (setq dt (decode-time et))
	  ;; $BF,$K(B20$B$rB-$7$F(BYYYY$B7A<0$K$9$k(B(2100$BG/LdBj%\%C%Q%DM=Dj(B)
	  (concat "20" date "("  (nth (nth 6 dt) youbi) ") " time ))
      d)))

(defun navi2ch-article-expunge-buffers (&optional num)
  "$B%9%l$N%P%C%U%!$N?t$r(B NUM $B$K@)8B$9$k!#(B
NUM $B$r;XDj$7$J$$>l9g$O(B `navi2ch-article-max-buffers' $B$r;HMQ!#(B"
  (interactive "P")
  (if (not (numberp num)) ; C-u$B$N$_$N;~(B4$B8D$K$7$?$$$o$1$8$c$J$$$H;W$o$l(B
      (setq num navi2ch-article-max-buffers))
  (save-excursion
    (dolist (buf (nthcdr num (navi2ch-article-buffer-list)))
      (kill-buffer buf))))

(defun navi2ch-article-view-article (board
				     article
				     &optional force number max-line dont-display)
  "$B%9%l$r8+$k!#(BFORCE $B$G6/@)FI$_9~$_(B MAX-LINE $B$GFI$_9~$`9T?t$r;XDj!#(B
$B$?$@(B `navi2ch-article-max-line' $B$H$O5U$G(B t $B$GA4ItFI$_9~$_!#(B
DONT-DISPLAY $B$,(B non-nil $B$N$H$-$O%9%l%P%C%U%!$rI=<($;$:$K<B9T!#(B"
  (let ((buf-name (navi2ch-article-get-buffer-name board article))
	(navi2ch-article-max-line (cond ((numberp max-line) max-line)
					(max-line nil)
					(t navi2ch-article-max-line)))
	list)
    (when (and (null (get-buffer buf-name))
	       navi2ch-article-auto-expunge
	       (> navi2ch-article-max-buffers 0))
      (navi2ch-article-expunge-buffers (1- navi2ch-article-max-buffers)))
    (if dont-display
	(set-buffer (get-buffer-create buf-name))
      (switch-to-buffer (get-buffer-create buf-name)))
    (if (eq major-mode 'navi2ch-article-mode)
	(setq list (navi2ch-article-sync force nil))
      (setq navi2ch-article-current-board board
            navi2ch-article-current-article article)
      (when navi2ch-article-auto-range
        (if (file-exists-p (navi2ch-article-get-file-name board article))
            (setq navi2ch-article-view-range
		  navi2ch-article-exist-message-range)
          (setq navi2ch-article-view-range
		navi2ch-article-new-message-range)))
      (setq list (navi2ch-article-sync force 'first))
      (navi2ch-article-mode))
    (when (and number
	       (not (equal (navi2ch-article-get-current-number) number)))
      (navi2ch-article-goto-number number t))
    (navi2ch-history-add navi2ch-article-current-board
			 navi2ch-article-current-article)
    list))

(defun navi2ch-article-view-article-from-file (file)
  "FILE $B$+$i%9%l$r8+$k!#(B"
  (setq file (expand-file-name file))
  (let* ((board (list (cons 'id "navi2ch")
		      (cons 'uri (navi2ch-filename-to-url
				  (file-name-directory file)))
		      (cons 'name navi2ch-board-name-from-file)))
	 (article (list (cons 'artid (file-name-sans-extension
				      (file-name-nondirectory file)))))
         (buf-name (navi2ch-article-get-buffer-name board article)))
    (if (get-buffer buf-name)
        (progn
          (switch-to-buffer buf-name)
	  nil)
      (if (and navi2ch-article-auto-expunge
	       (> navi2ch-article-max-buffers 0))
	  (navi2ch-article-expunge-buffers (1- navi2ch-article-max-buffers)))
      (switch-to-buffer (get-buffer-create buf-name))
      (setq navi2ch-article-current-board board
            navi2ch-article-current-article article)
      (when navi2ch-article-auto-range
        (setq navi2ch-article-view-range
              navi2ch-article-new-message-range))
      (prog1
	  (navi2ch-article-sync-from-file)
	(navi2ch-article-set-mode-line)
	(navi2ch-article-mode)))))

(easy-menu-define navi2ch-article-mode-menu
  navi2ch-article-mode-map
  "Menu used in navi2ch-article"
  navi2ch-article-mode-menu-spec)

(defun navi2ch-article-setup-menu ()
  (easy-menu-add navi2ch-article-mode-menu))

(defun navi2ch-article-mode ()
  "\\{navi2ch-article-mode-map}"
  (interactive)
  (setq major-mode 'navi2ch-article-mode)
  (setq mode-name "Navi2ch Article")
  (setq buffer-read-only t)
  (make-local-variable 'truncate-partial-width-windows)
  (setq truncate-partial-width-windows nil)
  (use-local-map navi2ch-article-mode-map)
  (navi2ch-article-setup-menu)
  (setq navi2ch-article-point-stack nil)
  (make-local-hook 'kill-buffer-hook)
  (add-hook 'kill-buffer-hook 'navi2ch-article-kill-buffer-hook t t)
  (make-local-hook 'post-command-hook)
  (add-hook 'post-command-hook 'navi2ch-article-display-link-minibuffer nil t)
  (run-hooks 'navi2ch-article-mode-hook))

(defun navi2ch-article-kill-buffer-hook ()
  (navi2ch-article-save-info))

(defun navi2ch-article-exit (&optional kill)
  (interactive "P")
  ;; (navi2ch-article-add-number)
  (run-hooks 'navi2ch-article-exit-hook)
  (navi2ch-article-save-info)
  (let ((buf (current-buffer)))
    (if (or kill
	    (null navi2ch-article-message-list))
        (progn
          (delete-windows-on buf)
          (kill-buffer buf))
      (delete-windows-on buf))
    ;;  (bury-buffer navi2ch-article-buffer-name)
    (let ((board-win (get-buffer-window navi2ch-board-buffer-name))
	  (board-buf (get-buffer navi2ch-board-buffer-name)))
      (cond (board-win (select-window board-win))
	    (board-buf (switch-to-buffer board-buf))
	    (t (navi2ch-list))))))

(defun navi2ch-article-goto-current-board (&optional kill)
  "$B%9%l%C%I$HF1$8HD$X0\F0(B"
  (interactive "P")
  (let ((board navi2ch-article-current-board))
    (navi2ch-article-exit kill)
    (navi2ch-board-select-board board)))

(defun navi2ch-article-fix-range (num)
  "navi2ch-article-view-range $B$r(B num $B$,4^$^$l$kHO0O$KJQ99(B"
  (let ((len (length navi2ch-article-message-list))
	(range navi2ch-article-view-range))
    (unless (navi2ch-article-inside-range-p num range len)
      (let ((first (car range))
	    (last (+ navi2ch-article-fix-range-diff (- len num))))
	(setq navi2ch-article-view-range (cons first last))))))

(defun navi2ch-article-sync (&optional force first number)
  "$B%9%l$r99?7$9$k!#(Bforce $B$J$i6/@)!#(B
first $B$,(B nil $B$J$i$P!"%U%!%$%k$,99?7$5$l$F$J$1$l$P2?$b$7$J$$(B"
  (interactive "P")
  (when (not (navi2ch-board-from-file-p navi2ch-article-current-board))
    (run-hooks 'navi2ch-article-before-sync-hook)
    (let* ((list navi2ch-article-message-list)
           (article navi2ch-article-current-article)
           (board navi2ch-article-current-board)
           (navi2ch-net-force-update (or navi2ch-net-force-update
                                         force))
           (file (navi2ch-article-get-file-name board article))
           (old-size (nth 7 (file-attributes file)))
           header)
      (when first
        (setq article (navi2ch-article-load-info)))
      (if (and (cdr (assq 'kako article))
	       (file-exists-p file)
	       (not (and force ; force $B$,;XDj$5$l$J$$8B$j(Bsync$B$7$J$$(B
			 (y-or-n-p "re-sync kako article?"))))
	  (setq navi2ch-article-current-article article)
	(let ((ret (navi2ch-article-update-file board article force)))
	  (setq article (nth 0 ret)
		navi2ch-article-current-article article
		header (nth 1 ret))))
      (prog1
	  ;; $B99?7$G$-$?$i(B
	  (when (or (and first (file-exists-p file))
		    (and header
			 (not (navi2ch-net-get-state 'not-updated header))
			 (not (navi2ch-net-get-state 'error header))))
	    (setq list
		  (if (or first
			  (navi2ch-net-get-state 'aborn header)
			  (navi2ch-net-get-state 'kako header)
			  (not navi2ch-article-enable-diff))
		      (navi2ch-article-get-message-list file)
		    (navi2ch-article-append-message-list
		     list (navi2ch-article-get-message-list
			   file old-size))))
	    (setq navi2ch-article-message-list list)
	    (let ((num (or number (cdr (assq 'number article)))))
	      (when (and navi2ch-article-fix-range-when-sync num)
		(navi2ch-article-fix-range num)))
	    (unless first
	      (navi2ch-article-save-number))
	    (setq navi2ch-article-hide-mode nil
		  navi2ch-article-important-mode nil)
	    (let ((buffer-read-only nil))
	      (erase-buffer)
	      (navi2ch-article-insert-messages list
					       navi2ch-article-view-range))
	    (navi2ch-article-load-number)
	    (navi2ch-article-save-info board article first)
	    (navi2ch-article-set-mode-line)
	    (run-hooks 'navi2ch-article-after-sync-hook)
	    list)
	(when (and navi2ch-article-fix-range-when-sync number)
	  (navi2ch-article-fix-range number)
	  (navi2ch-article-redraw))
	(navi2ch-article-goto-number (or number
					 (navi2ch-article-get-current-number)))
	(navi2ch-article-set-summary-element board article nil)))))

(defun navi2ch-article-fetch-article (board article &optional force)
  (if (get-buffer (navi2ch-article-get-buffer-name board article))
      (save-excursion
	(navi2ch-article-view-article board article force nil nil t))
    (let (ret header file)
      (setq article (navi2ch-article-load-info board article)
	    file (navi2ch-article-get-file-name board article))
      (unless (and (cdr (assq 'kako article))
		   (file-exists-p file)
		   (not (and force      ; force $B$,;XDj$5$l$J$$8B$j(B sync $B$7$J$$(B
			     (y-or-n-p "re-sync kako article?"))))
	(setq ret (navi2ch-article-update-file board article force)
	      article (nth 0 ret)
	      header (nth 1 ret))
	(when (and header
		   (not (navi2ch-net-get-state 'not-updated header))
		   (not (navi2ch-net-get-state 'error header)))
	  (navi2ch-article-save-info board article)
	  (navi2ch-article-set-summary-element board article t)
	  t)))))

(defun navi2ch-article-get-readcgi-raw-url (board article &optional start)
  (let ((url (navi2ch-article-to-url board article))
	(file (navi2ch-article-get-file-name board article))
	size)
    (if start
	(setq size (nth 7 (file-attributes file)))
      (setq start 0
	    size 0))
    (format "%s?raw=%s.%s" url start size)))

(defun navi2ch-article-update-file (board article &optional force)
  "BOARD, ARTICLE $B$KBP1~$9$k%U%!%$%k$r99?7$9$k!#(B
$BJV$jCM$O(B \(article header) $B$N%j%9%H!#(B"
  (let (header)
    (unless navi2ch-offline
      (let ((navi2ch-net-force-update (or navi2ch-net-force-update
					  force))
	    (file (navi2ch-article-get-file-name board article))
	    start)
	(when (and (file-exists-p file)
		   navi2ch-article-enable-diff)
	  (setq start (1+ (navi2ch-count-lines-file file))))
	(setq header (navi2ch-multibbs-article-update board article start))
	(when header
	  (unless (or (navi2ch-net-get-state 'not-updated header)
		      (navi2ch-net-get-state 'error header))
	    (setq article (navi2ch-put-alist 'time
					     (or (cdr (assoc "Last-Modified"
							     header))
						 (cdr (assoc "Date"
							     header)))
					     article)))
	  (when (navi2ch-net-get-state 'kako header)
	    (setq article (navi2ch-put-alist 'kako t article))))))
    (list article header)))

(defun navi2ch-article-sync-from-file ()
  "from-file $B$J%9%l$r99?7$9$k!#(B"
  (let ((file (navi2ch-article-get-file-name navi2ch-article-current-board
					     navi2ch-article-current-article)))
    (when (and (navi2ch-board-from-file-p navi2ch-article-current-board)
	       (file-exists-p file))
      (let ((list (navi2ch-article-get-message-list file))
	    (range navi2ch-article-view-range)
	    (buffer-read-only nil))
	(erase-buffer)
	(navi2ch-article-insert-messages list range)
	(prog1
	    (setq navi2ch-article-message-list list)
	  (navi2ch-article-goto-number 1))))))

(defun navi2ch-article-set-mode-line ()
  (let ((article navi2ch-article-current-article)
        (x (cdr (car navi2ch-article-message-list))))
    (unless (assq 'subject article)
      (setq article (navi2ch-put-alist
                     'subject
                     (cdr (assq 'subject
                                (if (stringp x)
                                    (navi2ch-article-parse-message x)
                                  x)))
                     article)
            navi2ch-article-current-article article))
    (setq navi2ch-mode-line-identification
          (format "%s (%d/%s) [%s]"
                  (or (cdr (assq 'subject article))
		      navi2ch-bm-empty-subject)
                  (length navi2ch-article-message-list)
                  (or (cdr (assq 'response article)) "-")
                  (cdr (assq 'name navi2ch-article-current-board)))))
  (navi2ch-set-mode-line-identification))

(defun navi2ch-article-sync-disable-diff (&optional force)
  (interactive "P")
  (let ((navi2ch-article-enable-diff nil))
    (navi2ch-article-sync force)))

(defun navi2ch-article-redraw ()
  "$B8=:_I=<($7$F$k%9%l$rI=<($7$J$*$9(B"
  (let ((buffer-read-only nil))
    (navi2ch-article-save-number)
    (erase-buffer)
    (navi2ch-article-insert-messages navi2ch-article-message-list
                                     navi2ch-article-view-range)
    (navi2ch-article-load-number)))

(defun navi2ch-article-select-view-range-subr ()
  "$BI=<($9$kHO0O$r%-!<%\!<%I%a%K%e!<$GA*Br$9$k(B"
  (save-window-excursion
    (delete-other-windows)
    (let (buf
          (range navi2ch-article-view-range))
      (unwind-protect
	  (progn
	    (setq buf (get-buffer-create "*select view range*"))
	    (save-excursion
	      (set-buffer buf)
	      (erase-buffer)
	      (insert (format "   %8s %8s\n" "first" "last"))
	      (insert (format "0: %17s\n" "all range"))
	      (let ((i 1))
		(dolist (x navi2ch-article-view-range-list)
		  (insert (format "%d: %8d %8d\n" i (car x) (cdr x)))
		  (setq i (1+ i)))))
	    (display-buffer buf)
	    (let (n)
	      (setq n (navi2ch-read-char "input: "))
	      (when (or (< n ?0) (> n ?9))
		(error "%c is bad key" n))
	      (setq n (- n ?0))
	      (setq range
		    (if (eq n 0) nil
		      (nth (1- n) navi2ch-article-view-range-list)))))
	(if (bufferp buf)
	    (kill-buffer buf)))
      range)))

(defun navi2ch-article-redraw-range ()
  "$BI=<($9$kHO0O$r;XDj$7$?8e(B redraw"
  (interactive)
  (setq navi2ch-article-view-range
        (navi2ch-article-select-view-range-subr))
  (navi2ch-article-redraw))

(defun navi2ch-article-save-number ()
  (unless (or navi2ch-article-hide-mode
              navi2ch-article-important-mode)
    (let ((num (navi2ch-article-get-current-number)))
      (when num
        (setq navi2ch-article-current-article
              (navi2ch-put-alist 'number
                                 num
                                 navi2ch-article-current-article))))))

(defun navi2ch-article-load-number ()
  (unless (or navi2ch-article-hide-mode
              navi2ch-article-important-mode)
    (let ((num (cdr (assq 'number navi2ch-article-current-article))))
      (navi2ch-article-goto-number (or num 1)))))

(defun navi2ch-article-save-info (&optional board article first)
  (let (ignore alist)
    (when (eq major-mode 'navi2ch-article-mode)
      (if (navi2ch-board-from-file-p (or board navi2ch-article-current-board))
	  (setq ignore t)
	(when (and navi2ch-article-message-list (not first))
	  (navi2ch-article-save-number))
	(or board (setq board navi2ch-article-current-board))
	(or article (setq article navi2ch-article-current-article))))
    (when (and (not ignore) board article)
      (let ((article-tmp (if navi2ch-article-save-info-wrapper-func
			     (funcall navi2ch-article-save-info-wrapper-func article)
			   article)))
	(setq alist (mapcar
		     (lambda (x)
		       (assq x article-tmp))
		     navi2ch-article-save-info-keys)))
      (navi2ch-save-info
       (navi2ch-article-get-info-file-name board article)
       alist))))

(defun navi2ch-article-load-info (&optional board article)
  (let (ignore alist)
    (if (navi2ch-board-from-file-p (or board navi2ch-article-current-board))
	(setq ignore t)
      (or board (setq board navi2ch-article-current-board))
      (or article (setq article navi2ch-article-current-article)))
    (when (and (not ignore) board article)
      (setq alist (navi2ch-load-info
		   (navi2ch-article-get-info-file-name board article)))
      (dolist (x alist)
        (setq article (navi2ch-put-alist (car x) (cdr x) article)))
      article)))

(defun navi2ch-article-write-message (&optional sage)
  (interactive)
  (when (not (navi2ch-board-from-file-p navi2ch-article-current-board))
    (navi2ch-article-save-number)
    (navi2ch-message-write-message navi2ch-article-current-board
                                   navi2ch-article-current-article
				   nil sage)))

(defun navi2ch-article-write-sage-message ()
  (interactive)
  (navi2ch-article-write-message 'sage))

(defun navi2ch-article-str-to-num (str)
  "$B%l%9;2>H$NJ8;zNs$r?t;z$+?t;z$N(B list $B$KJQ49(B"
  (cond ((string-match "\\([0-9]+\\)-\\([0-9]+\\)" str)
	 (let* ((n1 (string-to-number (match-string 1 str)))
		(n2 (string-to-number (match-string 2 str)))
		(min (min n1 n2))
		(i (max n1 n2))
		list)
	   (while (>= i min)
	     (push i list)
	     (setq i (1- i)))
	   list))
	((string-match "\\([0-9]+,\\)+[0-9]+" str)
	 (mapcar 'string-to-number (split-string str ",")))
	(t (string-to-number str))))

(defun navi2ch-article-select-current-link (&optional browse-p)
  (interactive "P")
  (let (prop)
    (cond ((setq prop (get-text-property (point) 'number))
           (setq prop (navi2ch-article-str-to-num (japanese-hankaku prop)))
           (if (numberp prop)
               (navi2ch-article-goto-number prop t t)
             (navi2ch-popup-article prop)))
          ((setq prop (get-text-property (point) 'url))
           (let ((2ch-url-p (navi2ch-2ch-url-p prop)))
             (if (and 2ch-url-p
                      (or (navi2ch-board-url-to-board prop)
                          (navi2ch-article-url-to-article prop))
                      (not browse-p))
		 (progn
		   (and (get-text-property (point) 'help-echo)
			(let ((buffer-read-only nil))
			  (navi2ch-article-change-help-echo-property
			   (point) (function navi2ch-article-help-echo))))
		   (navi2ch-goto-url prop))
               (navi2ch-browse-url-internal prop))))
          ((setq prop (get-text-property (point) 'content))
	   (navi2ch-article-save-content)))))

(defun navi2ch-article-mouse-select (e)
  (interactive "e")
  (mouse-set-point e)
  (navi2ch-article-select-current-link))

(defun navi2ch-article-recenter (num)
  "NUM $BHVL\$N%l%9$r2hLL$N0lHV>e$K(B"
  (let ((win (if (eq (window-buffer) (current-buffer))
		 (selected-window)
	       (get-buffer-window (current-buffer)))))
    (if (and win (numberp num))
	(set-window-start
	 win (cdr (assq 'point (navi2ch-article-get-message num)))))))

(defun navi2ch-article-goto-number-or-board ()
  "$BF~NO$5$l$??t;z$N0LCV$K0\F0$9$k$+!"F~NO$5$l$?HD$rI=<($9$k!#(B
$BL>A0$,?t;z$J$i$P%G%U%)%k%H$O$=$NL>A0$N?t;z!#(B"
  (interactive)
  (let (default alist ret)
    (setq default
	  (let* ((msg (navi2ch-article-get-message
		       (navi2ch-article-get-current-number)))
		 (from (cdr (assq 'name msg)))
		 (data (cdr (assq 'data msg))))
	    (or (and from
		     (string-match "[0-9$B#0(B-$B#9(B]+" from)
		     (japanese-hankaku (match-string 0 from)))
		(and data
		     (string-match "[0-9$B#0(B-$B#9(B]+" data)
		     (japanese-hankaku (match-string 0 data)))
		nil)))
    (setq alist (mapcar (lambda (x) (cons (cdr (assq 'id x)) x))
			navi2ch-list-board-name-list))
    (setq ret (completing-read
	       (concat "input number or board"
		       (and default (format "(%s)" default))
		       ": ")
	       alist nil nil))
    (setq ret (if (string= ret "") default ret))
    (if ret
	(let ((num (string-to-number ret)))
	  (if (> num 0)
	      (navi2ch-article-goto-number num t t)
	    (let (board board-id)
	      (setq board-id (try-completion ret alist))
	      (and (eq board-id t) (setq board-id ret))
	      (setq board (cdr (assoc board-id alist)))
	      (if board
		  (progn
		    (when (eq (navi2ch-get-major-mode
			       navi2ch-board-buffer-name)
			      'navi2ch-board-mode)
		      (navi2ch-board-save-info navi2ch-board-current-board))
		    (navi2ch-article-exit)
		    (navi2ch-bm-select-board board))
		(error "don't move")))))
      (error "don't move"))))

(defun navi2ch-article-goto-number (num &optional save pop)
  "NUM $BHVL\$N%l%9$K0\F0(B"
  (interactive "ninput number: ")
  (when (and num (> num 0)
	     navi2ch-article-message-list)
    (when (or (interactive-p) save)
      (navi2ch-article-push-point))
    (catch 'break
      (let ((len (length navi2ch-article-message-list))
	    (range navi2ch-article-view-range)
	    (first (caar navi2ch-article-message-list))
	    (last (caar (last navi2ch-article-message-list))))
	(setq num (max first (min last num)))
	(unless (navi2ch-article-inside-range-p num range len)
	  (if navi2ch-article-redraw-when-goto-number
	      (progn
		(navi2ch-article-fix-range num)
		(navi2ch-article-redraw))
	    (if (or (interactive-p) pop)
		(progn (when (or (interactive-p) save)
			 (navi2ch-article-pop-point))
		       (navi2ch-popup-article (list num))
		       (throw 'break nil))
	      (setq num (1+ (- len (cdr range))))))))
      (condition-case nil
	  (goto-char (cdr (assq 'point (navi2ch-article-get-message num))))
	(error nil))
      (if navi2ch-article-goto-number-recenter
	  (navi2ch-article-recenter (navi2ch-article-get-current-number))))
    (force-mode-line-update t)))

(defun navi2ch-article-goto-board (&optional board)
  (interactive)
  (navi2ch-list-goto-board (or board
			       navi2ch-article-current-board)))

(defun navi2ch-article-get-point (&optional point)
  (save-window-excursion
    (save-excursion
      (if point (goto-char point) (setq point (point)))
      (let ((num (navi2ch-article-get-current-number)))
	(navi2ch-article-goto-number num)
	(cons num (- point (point)))))))

(defun navi2ch-article-pop-point ()
  "stack $B$+$i(B pop $B$7$?0LCV$K0\F0$9$k(B"
  (interactive)
  (let ((point (pop navi2ch-article-point-stack)))
    (if point
        (progn
          (push (navi2ch-article-get-point (point)) navi2ch-article-poped-point-stack)
          (navi2ch-article-goto-number (car point))
	  (forward-char (cdr point)))
      (message "stack is empty"))))

(defun navi2ch-article-push-point (&optional point)
  "$B8=:_0LCV$+(B POINT $B$r(B stack $B$K(B push $B$9$k(B"
  (interactive)
  (setq navi2ch-article-poped-point-stack nil)
  (push (navi2ch-article-get-point point) navi2ch-article-point-stack)
  (message "push current point"))

(defun navi2ch-article-pop-poped-point () ; $BL>A0$@$;$'!"$C$F$+2?$+0c$&!#(B
  (interactive)
  (let ((point (pop navi2ch-article-poped-point-stack)))
    (if point
        (progn
          (push (navi2ch-article-get-point (point)) navi2ch-article-point-stack)
	  (navi2ch-article-goto-number (car point))
	  (forward-char (cdr point)))
      (message "stack is empty"))))

(defun navi2ch-article-rotate-point ()
  "stack $B$X(B push $B$7$?0LCV$r=d2s$9$k!#(B"
  (interactive)
  (let ((cur (navi2ch-article-get-point nil))		; $B8=:_CO(B
	(top (pop navi2ch-article-point-stack)))	; $B%H%C%W(B
    (if top
        (progn
	  (setq navi2ch-article-point-stack
		(append navi2ch-article-point-stack (list cur))) ; $B:G8eHx$XJ]B8(B
          (navi2ch-article-goto-number (car top))	; $B%H%C%W$N(B
          (forward-char (cdr top)))			; $B0JA0$$$?J8;z$X(B
      (message "stack is empty"))))

(defun navi2ch-article-goto-last-message ()
  "$B:G8e$N%l%9$X(B"
  (interactive)
  (navi2ch-article-goto-number
   (save-excursion
     (goto-char (point-max))
     (navi2ch-article-get-current-number)) t))

(defun navi2ch-article-goto-first-message ()
  "$B:G=i$N%l%9$X(B"
  (interactive)
  (navi2ch-article-goto-number
   (save-excursion
     (goto-char (point-min))
     (navi2ch-article-get-current-number)) t))

(defun navi2ch-article-few-scroll-up ()
  (interactive)
  (scroll-up 1))

(defun navi2ch-article-few-scroll-down ()
  (interactive)
  (scroll-down 1))

(defun navi2ch-article-scroll-up ()
  (interactive)
  (condition-case nil
      (scroll-up)
    (end-of-buffer
     (funcall navi2ch-article-through-next-function)))
  (force-mode-line-update t))

(defun navi2ch-article-scroll-down ()
  (interactive)
  (condition-case nil
      (scroll-down)
    (beginning-of-buffer
     (funcall navi2ch-article-through-previous-function)))
  (force-mode-line-update t))

(defun navi2ch-article-through-ask-y-or-n-p (num title)
  "$B<!$N%9%l$K0\F0$9$k$H$-$K(B \"y or n\" $B$G3NG'$9$k!#(B"
  (if title
      (navi2ch-y-or-n-p
       (concat title " --- Through " (if (< num 0) "previous" "next")
	       " article or quit? ")
       'quit)
    (when (navi2ch-y-or-n-p
	   (concat " --- The " (if (< num 0) "first" "last")
		   " article. Quit? ")
	   t)
      'quit)))

(defun navi2ch-article-through-ask-n-or-p-p (num title)
  "$B<!$N%9%l$K0\F0$9$k$H$-$K(B \"n\" $B$+(B \"p\" $B$G3NG'$9$k!#(B"
  (let* ((accept-key (if (< num 0) '(?p ?P ?\177) '(?n ?N ?\ )))
	 (accept-value (if title t 'quit))
	 (prompt (if title 
		     (format "%s --- Through %s article or quit? (%c or q) "
			     title (if (< num 0) "previous" "next")
			     (car accept-key))
		   (format " --- The %s article. Quit? (%c or q) "
			   (if (< num 0) "first" "last")
			   (car accept-key))))
	 (c (navi2ch-read-char prompt)))
    (if (memq c accept-key)
	accept-value
      (push (navi2ch-ifxemacs (character-to-event c) c)
	    unread-command-events)
      nil)))

(defun navi2ch-article-through-ask-last-command-p (num title)
  "$B<!$N%9%l$K0\F0$9$k$H$-$K!"D>A0$N%3%^%s%I$HF1$8$+$G3NG'$9$k!#(B"
  (let* ((accept-value (if title t 'quit))
	 (prompt (if title 
		     (format "Type %s for %s "
			     (single-key-description last-command-event)
			     title)
		   (format "The %s article. Type %s for quit "
			   (if (< num 0) "first" "last")
			   (single-key-description last-command-event))))
	 (e (navi2ch-read-event prompt)))
    (if (equal e last-command-event)
	accept-value
      (push e unread-command-events)
      nil)))

(defun navi2ch-article-through-ask (no-ask num)
  "$B<!$N%9%l$K0\F0$9$k$+J9$/!#(B
$B<!$N%9%l$K0\F0$9$k$J$i(B t $B$rJV$9!#(B
$B0\F0$7$J$$$J$i(B nil $B$rJV$9!#(B
article buffer $B$+$iH4$1$k$J$i(B 'quit $B$rJV$9!#(B"
  (if (or (eq navi2ch-article-enable-through 'ask-always)
	  (and (not no-ask)
	       (eq navi2ch-article-enable-through 'ask)))
      (funcall navi2ch-article-through-ask-function
	       num
	       (save-excursion
		 (set-buffer navi2ch-board-buffer-name)
		 (save-excursion
		   (when (eq (forward-line num) 0)
		     (cdr (assq 'subject
				(navi2ch-bm-get-article-internal
				 (navi2ch-bm-get-property-internal
				  (point)))))))))
    (or no-ask
	navi2ch-article-enable-through)))

(defun navi2ch-article-through-subr (interactive-flag num)
  "$BA08e$N%9%l$K0\F0$9$k!#(B
NUM $B$,(B 1 $B$N$H$-$O<!!"(B-1 $B$N$H$-$OA0$N%9%l$K0\F0!#(B
$B8F$S=P$9:]$O(BINTERACTIVE-FLAG$B$K(B(interactive-p)$B$rF~$l$k!#(B"
  (interactive)
  (or num (setq num 1))
  (if (and (not (eq num 1))
	   (not (eq num -1)))
      (error "arg error"))
  (let ((mode (navi2ch-get-major-mode navi2ch-board-buffer-name)))
    (if (and mode
	     (or (not (eq mode 'navi2ch-board-mode))
		 (and (eq mode 'navi2ch-board-mode)
		      (navi2ch-board-equal navi2ch-article-current-board
					   navi2ch-board-current-board))))
	(let ((ret (navi2ch-article-through-ask interactive-flag num)))
	  (cond ((eq ret 'quit)
		 (navi2ch-article-exit))
		(ret
		 (let ((window (get-buffer-window navi2ch-board-buffer-name)))
		   (if window
		       (progn
			 (delete-window)
			 (select-window window))
		     (switch-to-buffer navi2ch-board-buffer-name)))
		 (if (eq num 1)
		     (navi2ch-bm-next-line)
		   (navi2ch-bm-previous-line))
		 (recenter (/ navi2ch-board-window-height 2))
		 (navi2ch-bm-select-article))
		(t
		 (message "Don't through article"))))
      (message "Don't through article"))))

(defun navi2ch-article-through-next ()
  "$B<!$N%9%l$K0\F0$9$k!#(B"
  (interactive)
  (navi2ch-article-through-subr (interactive-p) 1))

(defun navi2ch-article-through-previous ()
  "$BA0$N%9%l$K0\F0$9$k!#(B"
  (interactive)
  (navi2ch-article-through-subr (interactive-p) -1))

(defun navi2ch-article-get-message (num)
  "NUM $BHVL\$N%l%9$rF@$k(B"
  (cdr (assq num navi2ch-article-message-list)))

(defun navi2ch-article-get-current-number ()
  "$B:#$N0LCV$N%l%9$NHV9f$rF@$k(B"
  (condition-case nil
      (or (get-text-property (point) 'current-number)
          (get-text-property
           (navi2ch-previous-property (point) 'current-number)
           'current-number))
    (error nil)))

(defun navi2ch-article-get-current-name ()
  (cdr (assq 'name (cdr (assq (navi2ch-article-get-current-number)
			      navi2ch-article-message-list)))))

(defun navi2ch-article-get-current-mail ()
  (cdr (assq 'mail (cdr (assq (navi2ch-article-get-current-number)
			      navi2ch-article-message-list)))))

(defun navi2ch-article-get-current-date ()
  (let ((date (cdr (assq 'date (cdr (assq (navi2ch-article-get-current-number)
					  navi2ch-article-message-list))))))
    (if (string-match " ID:.*" date)
	(replace-match "" nil t date)
      date)))

(defun navi2ch-article-get-current-id ()
  (let ((date (cdr (assq 'date (cdr (assq (navi2ch-article-get-current-number)
					  navi2ch-article-message-list))))))
    (if (string-match " ID:\\([^ ]+\\)" date)
	(match-string 1 date)
      nil)))

(defun navi2ch-article-show-url ()
  "url $B$rI=<($7$F!"$=$N(B url $B$r8+$k$+(B kill ring $B$K%3%T!<$9$k(B"
  (interactive)
  (let ((url (navi2ch-article-to-url navi2ch-article-current-board
				     navi2ch-article-current-article)))
    (let ((char (navi2ch-read-char-with-retry
		 (format "c)opy v)iew t)itle? URL: %s: " url)
		 nil '(?c ?v ?t))))
      (if (eq char ?t)
	  (navi2ch-article-copy-title navi2ch-article-current-board
				      navi2ch-article-current-article)
	(funcall (cond ((eq char ?c)
			(lambda (x)
			  (kill-new x)
			  (message "copy: %s" x)))
		       ((eq char ?v)
			(lambda (x)
			  (navi2ch-browse-url-internal x)
			  (message "view: %s" x))))
		 (navi2ch-article-show-url-subr))))))

(defun navi2ch-article-show-url-subr ()
  "$B%a%K%e!<$rI=<($7$F!"(Burl $B$rF@$k(B"
  (let* ((prompt (format "a)ll c)urrent r)egion b)oard l)ast%d: "
			 navi2ch-article-show-url-number))
	 (char (navi2ch-read-char-with-retry prompt
					     nil '(?a ?c ?r ?b ?l))))
    (if (eq char ?b)
	(navi2ch-board-to-url navi2ch-article-current-board)
      (apply 'navi2ch-article-to-url
	     navi2ch-article-current-board navi2ch-article-current-article
	     (cond ((eq char ?a) nil)
		   ((eq char ?l)
		    (let ((l (format "l%d"
				     navi2ch-article-show-url-number)))
		      (list l l nil)))
		   ((eq char ?c) (list (navi2ch-article-get-current-number)
				       (navi2ch-article-get-current-number)
				       t))
		   ((eq char ?r)
		    (let ((rb (region-beginning)) (re (region-end)))
		      (save-excursion
			(list (progn (goto-char rb)
				     (navi2ch-article-get-current-number))
			      (progn (goto-char re)
				     (navi2ch-article-get-current-number))
			      t)))))))))

(defun navi2ch-article-copy-title (board article)
  "$B%a%K%e!<$rI=<($7$F!"%?%$%H%k$rF@$k(B"
  (let* ((char (navi2ch-read-char-with-retry
		"b)oard a)rticle B)oard&url A)rtile&url: "
		nil '(?b ?a ?B ?A)))
	 (title (cond ((eq char ?b)
		       (cdr (assq 'name board)))
		      ((eq char ?a)
		       (cdr (assq 'subject article)))
		      ((eq char ?B)
		       (concat (cdr (assq 'name board))
			       "\n"
			       (navi2ch-board-to-url board)))
		      ((eq char ?A)
		       (concat (cdr (assq 'subject article))
			       "\n"
			       (navi2ch-article-to-url board article))))))
    (kill-new title)
    (message "copy: %s" title)))

(defun navi2ch-article-redisplay-current-message ()
  "$B:#$$$k%l%9$r2hLL$NCf?4(B($B>e!)(B)$B$K(B"
  (interactive)
  (navi2ch-article-recenter
   (navi2ch-article-get-current-number)))

(defun navi2ch-article-next-message ()
  "$B<!$N%a%C%;!<%8$X(B"
  (interactive)
  (condition-case nil
      (progn
        (goto-char (navi2ch-next-property (point) 'current-number))
        (navi2ch-article-goto-number
         (navi2ch-article-get-current-number)))
    (error
     (funcall navi2ch-article-through-next-function))))

(defun navi2ch-article-previous-message ()
  "$BA0$N%a%C%;!<%8$X(B"
  (interactive)
  (condition-case nil
      (progn
        (goto-char (navi2ch-previous-property (point) 'current-number))
        (navi2ch-article-goto-number
         (navi2ch-article-get-current-number)))
    (error
     (funcall navi2ch-article-through-previous-function))))

(defun navi2ch-article-get-message-string (num)
  "num $BHVL\$N%l%9$NJ8>O$rF@$k!#(B"
  (let ((msg (navi2ch-article-get-message num)))
    (when (stringp msg)
      (setq msg (navi2ch-article-parse-message msg)))
    (cdr (assq 'data msg))))

(defun navi2ch-article-cached-subject-minimum-size (file)
  "$B%9%l%?%$%H%k$rF@$k$N$K==J,$J%U%!%$%k%5%$%:$r5a$a$k!#(B"
  (with-temp-buffer
    (let ((beg 0) (end 0) (n 1))
      (while (and (= (point) (point-max))
		  (> n 0))
	(setq beg end)
	(setq end (+ end 1024))
	(setq n (car (cdr (navi2ch-insert-file-contents file beg end))))
	(forward-line))
      end)))

(defun navi2ch-article-cached-subject (board article)
  "$B%-%c%C%7%e$5$l$F$$$k(B dat $B%U%!%$%k$+$i%9%l%?%$%H%k$rF@$k!#(B"
;  "$B%-%c%C%7%e$5$l$F$$$k(B dat $B%U%!%$%k$d%9%l0lMw$+$i%9%l%?%$%H%k$rF@$k!#(B"
  (let ((state (navi2ch-article-check-cached board article))
	subject)
    (if (eq state 'view)
	(save-excursion
	  (set-buffer (navi2ch-article-get-buffer-name board article))
	  (setq subject		; nil $B$K$J$k$3$H$,$"$k(B
		(cdr (assq 'subject
			   navi2ch-article-current-article)))))
    (when (not subject)
      (if (eq state 'cache)
	  (let* ((file (navi2ch-article-get-file-name board article))
		 (msg-list (navi2ch-article-get-message-list
			    file
			    0
			    (navi2ch-article-cached-subject-minimum-size file))))
	    (setq subject
		  (cdr (assq 'subject
			     (navi2ch-article-parse-message (cdar msg-list))))))))
;    (when (not subject)
;      (if (equal (cdr (assq 'name board))
;		 (cdr (assq 'name navi2ch-board-current-board)))
;	  (setq subject-list navi2ch-board-subject-list)
;	(setq subject-list (navi2ch-board-get-subject-list
;			    (navi2ch-board-get-file-name board))))
;      (while (and (not subject)
;		  subject-list)
;	(if (equal artid
;		   (cdr (assq 'artid (car subject-list))))
;	    (setq subject (cdr (assq 'subject (car subject-list)))))
;	(pop subject-list)))
    (when (not subject)
      (setq subject "navi2ch: ???"))	; $BJQ?t$K$7$F(B navi2ch-vars.el $B$KF~$l$k$Y$-(B?
    subject))

(eval-when-compile
  (defvar mark-active)
  (defvar deactivate-mark))

(defun navi2ch-article-get-link-text-subr (&optional point)
  "POINT ($B>JN,;~$O%+%l%s%H%]%$%s%H(B) $B$N%j%s%/@h$rF@$k!#(B"
  (setq point (or point (point)))
  (let (mark-active deactivate-mark)	; transient-mark-mode $B$,@Z$l$J$$$h$&(B
    (catch 'ret
      (when (or (eq major-mode 'navi2ch-article-mode)
		(eq major-mode 'navi2ch-popup-article-mode))
	(let ((num-prop (get-text-property point 'number))
	      (url-prop (get-text-property point 'url))
	      num-list num)
	  (cond
	   (num-prop
	    (setq num-list (navi2ch-article-str-to-num
			    (japanese-hankaku num-prop)))
	    (cond ((numberp num-list)
		   (setq num num-list))
		  (t
		   (setq num (car num-list))))
	    (let ((msg (navi2ch-article-get-message-string num)))
	      (when msg
		(setq msg (navi2ch-replace-string
			   navi2ch-article-citation-regexp "" msg t))
		(setq msg (navi2ch-replace-string
			   "\\(\\cj\\)\n+\\(\\cj\\)" "\\1\\2" msg t))
		(setq msg (navi2ch-replace-string "\n+" " " msg t))
		(throw
		 'ret
		 (format "%s" (truncate-string-to-width
			       (format "[%d]: %s" num msg)
			       (eval navi2ch-article-display-link-width)))))))
	   ((and navi2ch-article-get-url-text
		 url-prop)
	    (if (navi2ch-2ch-url-p url-prop)
		(let ((board (navi2ch-board-url-to-board url-prop))
		      (article (navi2ch-article-url-to-article url-prop)))
		  (throw
		   'ret
		   (format "%s"
			   (truncate-string-to-width
			    (if article
				(format "[%s]: %s"
					(cdr (assq 'name board))
					(navi2ch-article-cached-subject board article))
			      (format "[%s]" (cdr (assq 'name board))))
			    (eval navi2ch-article-display-link-width))))))))))
      nil)))

(defun navi2ch-article-get-link-text (&optional point)
  "POINT ($B>JN,;~$O%+%l%s%H%]%$%s%H(B) $B$N%j%s%/@h$rF@$k!#(B
$B7k2L$r(B help-echo $B%W%m%Q%F%#$K@_Dj$7$F%-%c%C%7%e$9$k!#(B"
  (setq point (or point (point)))
  (let ((help-echo-prop (get-text-property point 'help-echo))
	mark-active deactivate-mark)	; transient-mark-mode $B$,@Z$l$J$$$h$&(B
    (unless (or (null help-echo-prop)
		(stringp help-echo-prop))
      (setq help-echo-prop (navi2ch-article-get-link-text-subr point))
      (let ((buffer-read-only nil))
	(navi2ch-article-change-help-echo-property point help-echo-prop)))
    help-echo-prop))

(defun navi2ch-article-change-help-echo-property (point value)
  (unless (get-text-property point 'help-echo)
    (error "POINT (%d) does not have property help-echo" point))
  (let ((start (if (or (= (point-min) point)
		       (not (eq (get-text-property (1- point) 'help-echo)
				(get-text-property point 'help-echo))))
		   point
		 (or (previous-single-property-change point 'help-echo)
		     point)))
	(end (or (min (next-single-property-change point 'help-echo)
		      (or (navi2ch-next-property point 'link-head)
			  (point-max)))
		 point)))
    (put-text-property start end 'help-echo value)))

(defun navi2ch-article-display-link-minibuffer (&optional point)
  "POINT ($B>JN,;~$O%+%l%s%H%]%$%s%H(B) $B$N%j%s%/@h$r(B minibuffer $B$KI=<(!#(B"
  (save-match-data
    (save-excursion
      (let ((text (navi2ch-article-get-link-text point)))
	(if (stringp text)
	    (message "%s" text))))))

(defun navi2ch-article-help-echo (window-or-extent &optional object position)
  (save-match-data
    (save-excursion
      (navi2ch-ifxemacs
	  (when (extentp window-or-extent)
	    (setq object (extent-object window-or-extent))
	    (setq position (extent-start-position window-or-extent))))
      (when (buffer-live-p object)
	(with-current-buffer object
	  (navi2ch-article-get-link-text position))))))

(defun navi2ch-article-next-link ()
  "$B<!$N%j%s%/$X(B"
  (interactive)
  (let ((point (navi2ch-next-property (point) 'link-head)))
    (if point
	(goto-char point))))

(defun navi2ch-article-previous-link ()
  "$BA0$N%j%s%/$X(B"
  (interactive)
  (let ((point (navi2ch-previous-property (point) 'link-head)))
    (if point
	(goto-char point))))

(defun navi2ch-article-fetch-link (&optional force)
  (interactive)
  (let ((url (get-text-property (point) 'url)))
    (and url
	 (navi2ch-2ch-url-p url)
	 (let ((article (navi2ch-article-url-to-article url))
	       (board (navi2ch-board-url-to-board url)))
	   (when article
	     (and (get-text-property (point) 'help-echo)
		  (let ((buffer-read-only nil))
		    (navi2ch-article-change-help-echo-property (point)
							       (function navi2ch-article-help-echo))))
	     (and (navi2ch-article-fetch-article board article force)
		  (navi2ch-bm-remember-fetched-article board article)))))))

(defun navi2ch-article-uudecode-message ()
  (interactive)
  (with-temp-buffer
    (insert (cdr
             (assq 'data
                   (save-excursion
                     (set-buffer (navi2ch-article-current-buffer))
                     (navi2ch-article-get-message
                      (navi2ch-article-get-current-number))))))
    (goto-char (point-max))
    (beginning-of-line)
    (when (looking-at "end\\([ \t]*\\)")
      (delete-region (match-beginning 1) (match-end 1))
      (end-of-line)
      (insert "\n"))
    (navi2ch-uudecode-region (point-min) (point-max))))

(defun navi2ch-article-base64-decode-message (prefix &optional filename)
  "$B8=:_$N%l%9$r(Bbase64$B%G%3!<%I$7!"(BFILENAME$B$K=q$-=P$9(B
PREFIX$B$r;XDj$7$?>l9g$O!"(Bmark$B$N$"$k%l%9$H8=:_$N%l%9$N4V$NHO0O$,BP>]$K$J$k(B"
  (interactive "P")
  (save-excursion
    (let* ((num (navi2ch-article-get-current-number))
	   (num2 (or (and prefix
			  (car (navi2ch-article-get-point (mark))))
		     num))
	   (begin (or (cdr (assq 'point (navi2ch-article-get-message
					 (min num num2))))
		      (point-min)))
	   (end (or (cdr (assq 'point (navi2ch-article-get-message
				       (1+ (max num num2)))))
		    (point-max))))
      (navi2ch-base64-write-region begin end filename))))

(defun navi2ch-article-decode-message ()
  "$B8=:_$N%l%9$r%G%3!<%I$9$k!#(B
$B$=$N$&$A%G%U%)%k%H$N%G%3!<%@$r?dB,$9$k$h$&$K$7$?$$!#(B"
  (interactive)
  (let ((c (navi2ch-read-char-with-retry
	    "(u)udecode or (b)ase64: "
	    "Please answer u, or b.  (u)udecode or (b)ase64: "
	    '(?u ?U ?b ?B))))
    (call-interactively (cond ((memq c '(?u ?U))
			       'navi2ch-article-uudecode-message)
			      ((memq c '(?b ?B))
			       'navi2ch-article-base64-decode-message)))))

(defun navi2ch-article-auto-decode-base64-section ()
  "$B%+%l%s%H%P%C%U%!$N(B BASE64 $B%;%/%7%g%s$r%G%3!<%I$7$?$b$N$KCV$-49$($k!#(B

BASE64 $B%;%/%7%g%s$H$_$J$5$l$k$N$O!"(B`navi2ch-base64-begin-delimiter-regexp'
$B$K%^%C%A$9$k9T$H(B `navi2ch-base64-end-delimiter-regexp' $B$K%^%C%A$9$k9T$N(B
$B$^$G$N%F%-%9%H!#%;%/%7%g%sFb$N9T$O$9$Y$F(B `navi2ch-base64-line-regexp' $B$K(B
$B%^%C%A$7$J$1$l$P$J$i$J$$!#(B

$B%G%3!<%I$7$?%F%-%9%H$O!"$=$NJ8;z%3!<%I$r(B Emacs $B$,?dB,$G$-$?>l9g$K8B$j(B
$BK\J8$KA^F~$9$k!#?dB,$G$-$J$+$C$?$H$-$O%P%$%J%j%U%!%$%k$H8+$J$7$F%"%s%+!<(B
$B$@$1$rA^F~$9$k!#(B

BASE64 $B%;%/%7%g%s$N%X%C%@$G;XDj$5$l$?%U%!%$%kL>$,(B *.gz $B$J$i$P!"$$$C$?$s(B
gunzip $B$KDL$7$F$+$iJ8;z%3!<%I$N?dB,$r;n$_$k!#(B"
  (goto-char (point-min))
  (catch 'loop
    (while (re-search-forward navi2ch-base64-begin-delimiter-regexp nil t)
      (let* ((begin (match-beginning 0))
             (filename (navi2ch-match-string-no-properties 2))
             (end (and (re-search-forward navi2ch-base64-end-delimiter-regexp nil t)
                       (match-end 0)))
             encoded decoded)
        (unless end (throw 'loop nil))
        (setq encoded (buffer-substring-no-properties
                       (progn (goto-char begin)
			      (navi2ch-line-beginning-position 2))
                       (progn (goto-char end)
			      (navi2ch-line-end-position 0))))
        (with-temp-buffer
          (insert encoded)
          (goto-char (point-min))
          (while (looking-at navi2ch-base64-line-regexp)
            (forward-line))
          (when (eobp)
            (base64-decode-region (point-min) (point-max))
            (setq decoded (let ((buffer-file-coding-system 'binary)
                                (coding-system-for-read 'binary)
                                (coding-system-for-write 'binary)
                                (str (buffer-string))
                                exit-status)
                            (when (and filename (string-match "\\.gz$" filename))
                              (setq exit-status
                                    (apply 'call-process-region (point-min) (point-max)
                                           navi2ch-net-gunzip-program t t nil
                                           navi2ch-net-gunzip-args))
                              (unless (= exit-status 0)
                                (erase-buffer)
                                (insert str)))
                            (let ((charset (coding-system-get
					    (navi2ch-ifxemacs
						(let ((result (detect-coding-region (point-min) (point-max))))
						  (if (listp result)
						      (car result)
						    result))
					      (detect-coding-region (point-min) (point-max) t))
                                            'mime-charset)))
                              (if charset
                                  (cons str (decode-coding-string (buffer-string) charset))
                                (cons str nil)))))))
        (when decoded
          (let ((noconv (car decoded))
                (text (cdr decoded))
                (fname (unless (or (null filename) (equal filename "")) filename))
                part-begin)
            (delete-region begin end)
            (goto-char begin)
            (insert (navi2ch-propertize "> " 'face 'navi2ch-article-base64-face)
                    (navi2ch-propertize (format "%s" (or fname "$BL>L5$7%U%!%$%k$5$s(B"))
					'face '(navi2ch-article-url-face navi2ch-article-base64-face)
					'link t
					'mouse-face navi2ch-article-mouse-face
					'file-name fname
					'content noconv))
	    (add-text-properties (+ 2 begin) (+ 3 begin)
				 (list 'link-head t))
            (setq part-begin (point))
            (insert (format " (%.1fKB)\n" (/ (length noconv) 1024.0)))
            (if text (insert text))
            (add-text-properties part-begin (point)
                                 '(hard t face navi2ch-article-base64-face))))))))

(defun navi2ch-article-save-content ()
  (interactive)
  (let ((prop (get-text-property (point) 'content))
	(default-filename (file-name-nondirectory
			   (get-text-property (point) 'file-name)))
	filename)
    (setq filename (read-file-name
		    (if default-filename
			(format "Save file (default `%s'): "
				default-filename)
		      "Save file: ")
		    nil default-filename))
    (when (and default-filename (file-directory-p filename))
      (setq filename (expand-file-name default-filename filename)))
    (if (not (file-writable-p filename))
	(error "File not writable: %s" filename)
      (with-temp-buffer
	(let ((buffer-file-coding-system 'binary)
	      (coding-system-for-write 'binary)
	      ;; auto-compress-mode $B$r(B disable $B$K$9$k(B
	      (inhibit-file-name-operation 'write-region)
	      (inhibit-file-name-handlers (cons 'jka-compr-handler
						inhibit-file-name-handlers)))
	  (insert prop)
	  (if (or (not (file-exists-p filename))
		  (y-or-n-p (format "File `%s' exists; overwrite? "
				    filename)))
	      (write-region (point-min) (point-max) filename)))))))

(defun navi2ch-article-textize-article (&optional dir-or-file buffer)
  (interactive)
  (let* ((article navi2ch-article-current-article)
	 (board navi2ch-article-current-board)
	 (id (cdr (assq 'id board)))
	 (subject (cdr (assq 'subject article)))
	 (basename (format "%s_%s.txt" id (cdr (assq 'artid article))))
	 dir file)
    (and dir-or-file
	 (file-directory-p dir-or-file)
	 (setq dir dir-or-file))
    (setq file
	  (if (or (not dir-or-file)
		  (and dir (interactive-p)))
	      (expand-file-name
	       (read-file-name "Write thread to file: " dir nil nil basename))
	    (expand-file-name basename dir)))
    (and buffer
	 (save-excursion
	   (set-buffer buffer)
	   (goto-char (point-max))
	   (insert (format "<a href=\"%s\">%s</a><br>\n" file subject))))
    (when navi2ch-article-view-range
      (setq navi2ch-article-view-range nil)
      (navi2ch-article-redraw))
    (let ((coding-system-for-write navi2ch-coding-system))
      (navi2ch-write-region (point-min) (point-max)
			    file))
    (message "Wrote %s" file)))

;; shut up XEmacs warnings
(eval-when-compile
  (defvar w32-start-process-show-window))

(defun navi2ch-article-call-aadisplay (str)
  (let* ((coding-system-for-write navi2ch-article-aadisplay-coding-system)
	 (file (expand-file-name (make-temp-name (navi2ch-temp-directory)))))
    (unwind-protect
	(progn
	  (with-temp-file file
	    (insert str))
	  (let ((w32-start-process-show-window t)) ; for meadow
	    (call-process navi2ch-article-aadisplay-program
			  nil nil nil file)))
      (ignore-errors (delete-file file)))))

(defun navi2ch-article-popup-dialog (str)
  (navi2ch-ifxemacs
      (ignore str)			; $B$H$j$"$($:2?$b$7$J$$(B
    (x-popup-dialog
     t (cons "navi2ch"
	     (mapcar (lambda (x)
		       (cons x t))
		     (split-string str "\n"))))))

(defun navi2ch-article-view-aa ()
  (interactive)
  (funcall navi2ch-article-view-aa-function
           (cdr (assq 'data
                      (navi2ch-article-get-message
                       (navi2ch-article-get-current-number))))))

(defun navi2ch-article-load-article-summary (board)
  (navi2ch-load-info (navi2ch-board-get-file-name
		      board
		      navi2ch-article-summary-file-name)))

(defun navi2ch-article-save-article-summary (board summary)
  (navi2ch-save-info (navi2ch-board-get-file-name
		      board
		      navi2ch-article-summary-file-name)
		     summary))

(defun navi2ch-article-set-summary-element (board article remove-seen)
  "BOARD, ARTICTLE $B$KBP1~$7$?(B $B>pJs$r(B article-summary $B$KJ]B8$9$k(B"
  (let* ((summary (navi2ch-article-load-article-summary board))
	 (artid (cdr (assq 'artid article)))
	 (element (cdr (assoc artid summary))))
    (navi2ch-article-summary-element-set-seen
     element
     (unless remove-seen
       (save-excursion
	 (set-buffer (navi2ch-article-get-buffer-name board article))
	 (length navi2ch-article-message-list))))
    (navi2ch-article-summary-element-set-access-time element (current-time))
    (setq summary (navi2ch-put-alist artid element summary))
    (navi2ch-article-save-article-summary board summary)))

(defun navi2ch-article-add-board-bookmark ()
  (interactive)
  (navi2ch-board-add-bookmark-subr navi2ch-article-current-board
				   navi2ch-article-current-article))

(defun navi2ch-article-add-global-bookmark (bookmark-id)
  (interactive (list (navi2ch-bookmark-read-id "bookmark id: ")))
  (navi2ch-bookmark-add
   bookmark-id
   navi2ch-article-current-board
   navi2ch-article-current-article))

(defun navi2ch-article-buffer-list ()
  "`navi2ch-article-mode' $B$N(B buffer $B$N(B list $B$rJV$9(B"
  (let (list)
    (dolist (x (buffer-list))
      (when (save-excursion
              (set-buffer x)
              (eq major-mode 'navi2ch-article-mode))
        (setq list (cons x list))))
    (nreverse list)))

(defun navi2ch-article-current-buffer ()
  "BUFFER-LIST $B$N0lHV:G=i$N(B `navi2ch-article-mode' $B$N(B buffer $B$rJV$9(B"
  (let ((list (buffer-list)))
    (catch 'loop
      (while list
        (when (save-excursion
                (set-buffer (car list))
                (eq major-mode 'navi2ch-article-mode))
          (throw 'loop (car list)))
        (setq list (cdr list)))
      nil)))

(defun navi2ch-article-forward-buffer ()
  "$B<!$N(B article buffer $B$X(B"
  (interactive)
  (let (buf)
    (dolist (x (buffer-list))
      (when (save-excursion
              (set-buffer x)
              (eq major-mode 'navi2ch-article-mode))
        (setq buf x)))
    (switch-to-buffer buf)))

(defun navi2ch-article-backward-buffer ()
  "$BA0$N(B article buffer $B$X(B"
  (interactive)
  (bury-buffer)
  (switch-to-buffer (navi2ch-article-current-buffer)))

(defun navi2ch-article-delete-message (sym func msg)
  (let* ((article navi2ch-article-current-article)
         (list (cdr (assq sym article)))
         (num (navi2ch-article-get-current-number)))
    (setq list (funcall func num list))
    (setq navi2ch-article-current-article
          (navi2ch-put-alist sym list article))
    (save-excursion
      (let ((buffer-read-only nil))
        (delete-region
         (if (get-text-property (point) 'current-number)
             (point)
           (navi2ch-previous-property (point) 'current-number))
         (or (navi2ch-next-property (point) 'current-number)
             (point-max))))))
  (message msg))

;;; hide mode
(navi2ch-set-minor-mode 'navi2ch-article-hide-mode
                        " Hide"
                        navi2ch-article-hide-mode-map)

(defun navi2ch-article-hide-message ()
  (interactive)
  (navi2ch-article-delete-message
   'hide
   (lambda (num list)
     (if (memq num list)
         list
       (cons num list)))
   "Hide message"))

(defun navi2ch-article-cancel-hide-message ()
  (interactive)
  (navi2ch-article-delete-message 'hide 'delq
                                  "Cancel hide message"))

(defun navi2ch-article-toggle-hide ()
  (interactive)
  (setq navi2ch-article-hide-mode
        (if navi2ch-article-hide-mode
            nil
          (navi2ch-article-save-number)
          t))
  (setq navi2ch-article-important-mode nil)
  (force-mode-line-update)
  (let ((buffer-read-only nil))
    (save-excursion
      (erase-buffer)
      (navi2ch-article-insert-messages
       navi2ch-article-message-list
       navi2ch-article-view-range)))
  (unless navi2ch-article-hide-mode
    (navi2ch-article-load-number)))

;;; important mode
(navi2ch-set-minor-mode 'navi2ch-article-important-mode
                        " Important"
                        navi2ch-article-important-mode-map)

(defun navi2ch-article-add-important-message (&optional prefix)
  (interactive "P")
  (if prefix
      (navi2ch-article-add-board-bookmark)
    (let* ((article navi2ch-article-current-article)
	   (list (cdr (assq 'important article)))
	   (num (navi2ch-article-get-current-number)))
      (unless (memq num list)
	(setq list (cons num list))
	(setq navi2ch-article-current-article
	      (navi2ch-put-alist 'important list article))
	(message "Add important message")))))

(defun navi2ch-article-delete-important-message ()
  (interactive)
  (navi2ch-article-delete-message 'important 'delq
                                  "Delete important message"))

(defun navi2ch-article-toggle-important ()
  (interactive)
  (setq navi2ch-article-important-mode
        (if navi2ch-article-important-mode
            nil
          (navi2ch-article-save-number)
          t))
  (setq navi2ch-article-hide-mode nil)
  (force-mode-line-update)
  (let ((buffer-read-only nil))
    (save-excursion
      (erase-buffer)
      (navi2ch-article-insert-messages
       navi2ch-article-message-list
       navi2ch-article-view-range)))
  (unless navi2ch-article-important-mode
    (navi2ch-article-load-number)))

(defun navi2ch-article-search ()
  "$B%a%C%;!<%8$r8!:w$9$k!#(B
$BL>A0(B (name)$B!"%a!<%k(B (mail)$B!"F|IU(B (date)$B!"(BID (id)$B!"K\J8(B (body) $B$+$i(B
$B8!:w>r7o$rA*$V$3$H$,$G$-$^$9!#(B

$B%Q!<%::Q$_$N%a%C%;!<%8$N$_$r8!:wBP>]$H$9$k$N$G!"$"$i$+$8$a(B
`navi2ch-article-redraw-range' $B$r;H$&$J$I$7$F8!:w$7$?$$%a%C%;!<%8$r(B
$BI=<($7$F$*$/$3$H!#(B"
  (interactive)
  (let ((ch (navi2ch-read-char-with-retry
	     "Search for: n)ame m)ail d)ate i)d b)ody: "
	     nil
	     '(?n ?m ?d ?i ?b)))
	matched num)
    (setq matched (cond
		   ((eq ch ?n) (navi2ch-article-search-name))
		   ((eq ch ?m) (navi2ch-article-search-mail))
		   ((eq ch ?d) (navi2ch-article-search-date))
		   ((eq ch ?i) (navi2ch-article-search-id))
		   ((eq ch ?b) (navi2ch-article-search-body))))
    (setq num (length matched))
    (if (= num 0)
	(message "No message found.")
      (navi2ch-popup-article matched)
      (message (format "%d message%s found."
		       num
		       (if (= num 1) "" "s"))))))

(defun navi2ch-article-search-name ()
  (let ((string (navi2ch-read-string "Name: "
				     (navi2ch-article-get-current-name)
				     'navi2ch-search-history)))
    (navi2ch-article-search-subr 'name (regexp-quote string))))

(defun navi2ch-article-search-mail ()
  (let ((string (navi2ch-read-string "Mail: "
				     (navi2ch-article-get-current-mail)
				     'navi2ch-search-history)))
    (navi2ch-article-search-subr 'mail (regexp-quote string))))

(defun navi2ch-article-search-date ()
  (let ((string (navi2ch-read-string "Date: "
				     (navi2ch-article-get-current-date)
				     'navi2ch-search-history)))
    (navi2ch-article-search-subr 'date
				 (concat (regexp-quote string)
					 (if (navi2ch-article-get-current-id)
					     ".* ID:" "")))))

(defun navi2ch-article-search-id ()
  (let ((string (navi2ch-read-string "ID: "
				     (navi2ch-article-get-current-id)
				     'navi2ch-search-history)))
    (navi2ch-article-search-subr 'date
				 (concat " ID:[^ ]*" (regexp-quote string)))))

(defun navi2ch-article-search-body ()
  (let ((string (navi2ch-read-string "Body: "
				     nil
				     'navi2ch-search-history)))
    (navi2ch-article-search-subr 'data (regexp-quote string))))

(defun navi2ch-article-search-subr (field regexp)
  (let (num-list)
    (dolist (msg navi2ch-article-message-list)
      (when (and (listp (cdr msg))
		 (string-match regexp (or (cdr (assq field (cdr msg))) "")))
	(setq num-list (cons (car msg) num-list))))
    (nreverse num-list)))

(run-hooks 'navi2ch-article-load-hook)
;;; navi2ch-article.el ends here
