;;; navi2ch-board-misc.el --- Miscellaneous Functions for Navi2ch Board Mode 

;; Copyright (C) 2001 by 2$B$A$c$s$M$k(B

;; Author: (not 1)
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

;;; Code:

(require 'cl)
(require 'navi2ch-article)
(require 'navi2ch-message)
(require 'navi2ch-face)
(require 'navi2ch-vars)

(defvar navi2ch-bm-mode-map nil)
(unless navi2ch-bm-mode-map
  (setq navi2ch-bm-mode-map (make-sparse-keymap))
  (define-key navi2ch-bm-mode-map "\r" 'navi2ch-bm-select-article)
  (navi2ch-define-mouse-key navi2ch-bm-mode-map 2 'navi2ch-bm-mouse-select)
  (define-key navi2ch-bm-mode-map " "
    'navi2ch-bm-select-article-or-scroll-up)
  (define-key navi2ch-bm-mode-map "." 'navi2ch-bm-display-article)
  (define-key navi2ch-bm-mode-map "i" 'navi2ch-bm-fetch-article)
  (define-key navi2ch-bm-mode-map "e" 'navi2ch-bm-textize-article)
  (define-key navi2ch-bm-mode-map [del]
    'navi2ch-bm-select-article-or-scroll-down)
  (define-key navi2ch-bm-mode-map [backspace]
    'navi2ch-bm-select-article-or-scroll-down)
  (define-key navi2ch-bm-mode-map "n" 'navi2ch-bm-next-line)
  (define-key navi2ch-bm-mode-map "p" 'navi2ch-bm-previous-line)
  (define-key navi2ch-bm-mode-map "U" 'navi2ch-bm-show-url)
  (define-key navi2ch-bm-mode-map "l" 'navi2ch-bm-view-logo)
  (define-key navi2ch-bm-mode-map "g" 'navi2ch-bm-goto-board)
  (define-key navi2ch-bm-mode-map "B" 'navi2ch-bookmark-goto-bookmark)
  (define-key navi2ch-bm-mode-map "A" 'navi2ch-bm-add-global-bookmark)
  (define-key navi2ch-bm-mode-map "q" 'navi2ch-bm-exit)
  (define-key navi2ch-bm-mode-map "S" 'navi2ch-bm-sort)
  (define-key navi2ch-bm-mode-map ">" 'navi2ch-end-of-buffer)
  (define-key navi2ch-bm-mode-map "<" 'beginning-of-buffer)
  (define-key navi2ch-bm-mode-map "t" 'navi2ch-toggle-offline)
  (define-key navi2ch-bm-mode-map "1" 'navi2ch-one-pain)
  (define-key navi2ch-bm-mode-map "3" 'navi2ch-three-pain)
  (define-key navi2ch-bm-mode-map "?" 'navi2ch-bm-search)
  (define-key navi2ch-bm-mode-map "\C-c\C-f" 'navi2ch-article-find-file)
  (define-key navi2ch-bm-mode-map "\C-c\C-u" 'navi2ch-goto-url)
  (define-key navi2ch-bm-mode-map "\C-c\C-m" 'navi2ch-message-pop-message-buffer)

  ;; mark command
  (define-key navi2ch-bm-mode-map "*" 'navi2ch-bm-mark)
  (define-key navi2ch-bm-mode-map "u" 'navi2ch-bm-unmark)
  (define-key navi2ch-bm-mode-map "mr" 'navi2ch-bm-mark-region)
  (define-key navi2ch-bm-mode-map "ma" 'navi2ch-bm-mark-all)
  (define-key navi2ch-bm-mode-map "mA" 'navi2ch-bm-add-global-bookmark-mark-article)
  (define-key navi2ch-bm-mode-map "mo" 'navi2ch-bm-display-mark-article)
  (define-key navi2ch-bm-mode-map "mi" 'navi2ch-bm-fetch-mark-article)
  (define-key navi2ch-bm-mode-map "me" 'navi2ch-bm-textize-mark-article)
  (define-key navi2ch-bm-mode-map "mm" 'navi2ch-bm-mark-marks))


(defvar navi2ch-bm-mode-menu-spec
  '(["Toggle offline" navi2ch-toggle-offline]
    ["Exit" navi2ch-bm-exit]
    ["Sort" navi2ch-bm-sort]
    ["Search" navi2ch-bm-search])
  "Menu $B$N85(B")

(defvar navi2ch-board-buffer-name "*navi2ch board*")

(defvar navi2ch-bm-get-property-function nil
  "$B$=$N0LCV$N(B text-property $B$rF@$k4X?t!#0z?t$O(B POINT")
(defvar navi2ch-bm-set-property-function nil
  "text-property $B$r@_Dj$9$k4X?t!#0z?t$O(B BEGIN END ITEM")
(defvar navi2ch-bm-get-board-function nil
  "$BHD$rF@$k4X?t!#0z?t$O(B ITEM")
(defvar navi2ch-bm-get-article-function nil
  "$B%9%l$rF@$k4X?t!#0z?t$O(B ITEM")
(defvar navi2ch-bm-exit-function nil)
(defvar navi2ch-bm-fetched-article-list nil)
(defvar navi2ch-bm-fetched-info-file (navi2ch-expand-file-name "fetched.txt"))

(defvar navi2ch-bm-state-alist
  '((view "V" navi2ch-bm-view-face navi2ch-bm-updated-view-face navi2ch-bm-seen-view-face)
    (cache "C" navi2ch-bm-cache-face navi2ch-bm-updated-cache-face navi2ch-bm-seen-cache-face)
    (update "U" navi2ch-bm-update-face navi2ch-bm-updated-update-face navi2ch-bm-seen-update-face)
    (nil " " navi2ch-bm-unread-face navi2ch-bm-updated-unread-face navi2ch-bm-seen-unread-face)
    (mark " " navi2ch-bm-mark-face navi2ch-bm-updated-mark-face navi2ch-bm-seen-mark-face)))

(defvar navi2ch-bm-updated-mark-alist
  '((updated . "+")
    (seen . "=")
    (nil . " ")))

(defvar navi2ch-bm-move-downward t)

(defmacro navi2ch-bm-set-func (sym val)
  `(let ((val-str (symbol-name ',val))
         (sym-str (symbol-name ,sym))
         func-str)
     (when (string-match "navi2ch-bm-\\(.+\\)-function" val-str)
       (setq func-str (format "%s-%s" sym-str (match-string 1 val-str)))
       (setq ,val (intern func-str)))))
  
(defun navi2ch-bm-setup (prefix)
  (navi2ch-bm-set-func prefix navi2ch-bm-get-property-function)
  (navi2ch-bm-set-func prefix navi2ch-bm-set-property-function)
  (navi2ch-bm-set-func prefix navi2ch-bm-get-board-function)
  (navi2ch-bm-set-func prefix navi2ch-bm-get-article-function)
  ;; (navi2ch-bm-set-func prefix navi2ch-bm-get-subject-function)
  (navi2ch-bm-set-func prefix navi2ch-bm-exit-function)
  (setq navi2ch-bm-move-downward t))

(defun navi2ch-bm-make-menu-spec (title menu-spec)
  "$B%?%$%H%k$,(B TITLE $B$G(B $BFbMF$,(B `navi2ch-bm-mode-menu-spec' $B$H(B MENU-SPEC $B$r7R$2(B
$B$?%a%K%e!<$r:n$k!#(B"
  (append (list title)
	  navi2ch-bm-mode-menu-spec
	  '("----")
	  menu-spec))

(defun navi2ch-bm-select-board (board &optional force)
  (switch-to-buffer (get-buffer-create navi2ch-board-buffer-name))
  (let ((type (cdr (assq 'type board))))
    (cond ((eq type 'articles)
           (navi2ch-articles))
 	  ((eq type 'bookmark)
	   (navi2ch-bookmark (cdr (assq 'id board))))
          ((eq type 'search)
           (navi2ch-search))
	  ((eq type 'history)
	   (navi2ch-history))
          (t
           (navi2ch-board-select-board board force))))
  (navi2ch-set-mode-line-identification))

(defsubst navi2ch-bm-set-property (begin end item state &optional updated)
  (funcall navi2ch-bm-set-property-function begin end item)
  (setq updated (or updated (get-text-property (1+ begin) 'updated)))
  (put-text-property begin end 'updated updated)
  (put-text-property begin end 'mouse-face 'highlight)
  (put-text-property begin end 'face (nth (cond ((eq updated 'updated) 3)
						((eq updated 'seen) 4)
						((eq updated nil) 2))
					  (assq state
						navi2ch-bm-state-alist))))

(defsubst navi2ch-bm-insert-subject (item number subject other &optional updated)
  (let* ((article (funcall navi2ch-bm-get-article-function item))
	 (board (funcall navi2ch-bm-get-board-function item))
	 (point (point))
	 (state (if (navi2ch-bm-fetched-article-p board article)
		    'update
		  (navi2ch-article-check-cached board article))))
    (unless subject (setq subject navi2ch-bm-empty-subject))
    (insert (format "%3d %s%s %s%s%s\n"
                    number
		    (cdr (assq updated navi2ch-bm-updated-mark-alist))
                    (cadr (assq state navi2ch-bm-state-alist))
                    subject
                    (make-string (max (- navi2ch-bm-subject-width
                                         (string-width subject))
                                      1)
                                 ? )
                    other))
    (navi2ch-bm-set-property point (1- (point)) item state updated)))

(defun navi2ch-bm-exit ()
  (interactive)
  (dolist (x (navi2ch-article-buffer-list))
    (when x
      (delete-windows-on x)))
  (funcall navi2ch-bm-exit-function)
  (when (get-buffer navi2ch-board-buffer-name)
    (delete-windows-on navi2ch-board-buffer-name)
    (bury-buffer navi2ch-board-buffer-name))
  (when navi2ch-list-buffer-name
    (let ((win (get-buffer-window navi2ch-list-buffer-name)))
      (if win
	  (select-window win)
	(switch-to-buffer navi2ch-list-buffer-name)))))

(defun navi2ch-bm-goto-state-column ()
  (beginning-of-line)
  (forward-char 5))

(defun navi2ch-bm-insert-state (item state &optional updated)
  ;; (setq article (navi2ch-put-alist 'cache 'view article))
  (navi2ch-bm-goto-state-column)
  (backward-char 1)
  (delete-char 2)
  (insert (cdr (assq updated navi2ch-bm-updated-mark-alist)))
  (insert (cadr (assq state navi2ch-bm-state-alist)))
  (navi2ch-bm-set-property (save-excursion (beginning-of-line) (point))
			   (save-excursion (end-of-line) (point))
			   item state updated))
  
(defun navi2ch-bm-get-state (&optional point)
  "$B$=$N0LCV$N(B state $B$rD4$Y$k(B"
  (save-excursion
    (and point (goto-char point))
    (navi2ch-bm-goto-state-column)
    (cdr (assoc (char-to-string (char-after))
		(mapcar (lambda (x)
			  (cons (cadr x) (car x)))
			navi2ch-bm-state-alist)))))

(defun navi2ch-bm-select-article (&optional max-line)
  (interactive "P")
  (let* ((item (funcall navi2ch-bm-get-property-function (point)))
         (article (funcall navi2ch-bm-get-article-function item))
         (board (funcall navi2ch-bm-get-board-function item))
         (buf (current-buffer)))
    (if article
        (progn
	  (navi2ch-history-add board article)
          (dolist (x (navi2ch-article-buffer-list))
            (when x
              (delete-windows-on x)))
	  (when navi2ch-bm-stay-board-window
	    (split-window-vertically navi2ch-board-window-height)
	    (other-window 1))
          (let (state)
            (setq state (navi2ch-article-view-article
                         board article nil nil max-line))
            (save-excursion
              (set-buffer buf)
              (let ((buffer-read-only nil))
                (when (or state
			  (navi2ch-bm-fetched-article-p board article)
			  (eq (navi2ch-bm-get-state) 'view))
		  (navi2ch-bm-remove-fetched-article board article)
		  (if (eq major-mode 'navi2ch-board-mode)
		      (navi2ch-bm-insert-state item 'view 'seen)
		    (navi2ch-bm-insert-state item 'view)))))))
      (message "can't select this line!"))))

(defun navi2ch-bm-show-url ()
  "$BHD$N(Burl $B$rI=<($7$F!"$=$N(B url $B$r8+$k$+(B kill ring $B$K%3%T!<$9$k(B"
  (interactive)
  (let* ((board (funcall navi2ch-bm-get-board-function
			 (funcall navi2ch-bm-get-property-function (point))))
	 (url (navi2ch-board-to-url board)))
    (message "c)opy v)iew t)itle? URL: %s" url)
    (let ((char (read-char)))
      (if (eq char ?t) (navi2ch-bm-copy-title board)
	(funcall (cond ((eq char ?c) '(lambda (x) (message "copy: %s" (kill-new x))))
		       ((eq char ?v) 'navi2ch-browse-url))
		 (navi2ch-bm-show-url-subr board))))))

(defun navi2ch-bm-show-url-subr (board)
  "$B%a%K%e!<$rI=<($7$F!"(Burl $B$rF@$k(B"
  (message "b)oard a)rticle")
  (let ((char (read-char)))
    (cond ((eq char ?b) (navi2ch-board-to-url board))
	  ((eq char ?a)
	   (navi2ch-article-to-url
	    board
	    (funcall navi2ch-bm-get-article-function
		     (funcall navi2ch-bm-get-property-function
			      (point))))))))

(defun navi2ch-bm-copy-title (board)
  "$B%a%K%e!<$rI=<($7$F!"%?%$%H%k$rF@$k(B"
  (message "b)oard a)rticle")
  (let ((char (read-char)))
    (message "copy: %s"
	     (kill-new
	      (cond ((eq char ?b) (cdr (assq 'name board)))
		    ((eq char ?a)
		     (cdr (assq 'subject
				(funcall navi2ch-bm-get-article-function
					 (funcall navi2ch-bm-get-property-function
						  (point)))))))))))

(defun navi2ch-bm-display-article (&optional max-line)
  (interactive "P")
  (let ((win (selected-window)))
    (navi2ch-bm-select-article max-line)
    (select-window win)))

(defun navi2ch-bm-remember-fetched-article (board article)
  (let* ((uri (navi2ch-board-get-uri board))
	 (list (assoc uri navi2ch-bm-fetched-article-list))
	 (artid (cdr (assq 'artid article))))
    (if list
	(unless (member artid (cdr list))
	  (push artid (cdr list)))
      (push (list uri artid) navi2ch-bm-fetched-article-list))))

(defun navi2ch-bm-fetched-article-p (board article)
  (member (cdr (assq 'artid article))
	  (cdr (assoc (navi2ch-board-get-uri board)
		      navi2ch-bm-fetched-article-list))))

(defun navi2ch-bm-remove-fetched-article (board article)
  (let* ((uri (navi2ch-board-get-uri board))
	 (list (assoc uri navi2ch-bm-fetched-article-list))
	 (artid (cdr (assq 'artid article))))
    (when (member artid list)
      (setcdr list (delete artid (cdr list)))
      (unless (cdr list)
	(setq navi2ch-bm-fetched-article-list
	      (delq list navi2ch-bm-fetched-article-list))))))
  
      
(defun navi2ch-bm-fetch-article (&optional max-line)
  (interactive "P")
  (let* ((item (funcall navi2ch-bm-get-property-function (point)))
         (board (funcall navi2ch-bm-get-board-function item))
         (article (funcall navi2ch-bm-get-article-function item))
         state)
    (if article
	(progn
	  (setq state (navi2ch-article-fetch-article board article))
	  (when state
	    (navi2ch-bm-remember-fetched-article board article)
	    (let ((buffer-read-only nil))
	      (save-excursion
		(navi2ch-bm-insert-state item 'update)))))
      (message "can't select this line!"))))

(defun navi2ch-bm-textize-article (directory &optional buffer)
  (interactive "Ddirectory: ")
  (let* ((navi2ch-article-view-range nil)
	 (navi2ch-article-auto-range nil)
	 window)
    (setq window (selected-window))
    (navi2ch-bm-display-article)
    (select-window (get-buffer-window (navi2ch-article-current-buffer)))
    (when navi2ch-article-view-range
      (setq navi2ch-article-view-range nil)
      (navi2ch-article-redraw))
    (let* ((article navi2ch-article-current-article)
	   (board navi2ch-article-current-board)
	   (id (cdr (assq 'id board)))
	   (file (format "%s_%s.txt" id (cdr (assq 'artid article))))
	   (subject (cdr (assq 'subject article))))
      (and buffer
	   (save-excursion
	     (set-buffer buffer)
	     (goto-char (point-max))
	     (insert (format "<a href=\"%s\">%s</a><br>\n" file subject))))
      (let ((coding-system-for-write navi2ch-net-coding-system))
	(navi2ch-write-region (point-min) (point-max)
			      (expand-file-name file directory))))
    (select-window window)))


(defun navi2ch-bm-select-article-or-scroll (way &optional max-line)
  (let ((article (funcall navi2ch-bm-get-article-function
                          (funcall navi2ch-bm-get-property-function
                                   (point)))))
    (if (and (navi2ch-article-current-buffer)
             (string= (cdr (assq 'artid article))
                      (save-excursion
                        (set-buffer (navi2ch-article-current-buffer))
                        (cdr (assq 'artid navi2ch-article-current-article))))
             (get-buffer-window (navi2ch-article-current-buffer)))
        (let ((win (selected-window)))
          (select-window
           (get-buffer-window (navi2ch-article-current-buffer)))
          (condition-case nil
              (cond
               ((eq way 'up)
                (navi2ch-article-scroll-up))
               ((eq way 'down)
                (navi2ch-article-scroll-down)))
            (error nil))
          (select-window win))
      (navi2ch-bm-select-article max-line))))

(defun navi2ch-bm-select-article-or-scroll-up (&optional max-line)
  (interactive "P")
  (navi2ch-bm-select-article-or-scroll 'up max-line))

(defun navi2ch-bm-select-article-or-scroll-down (&optional max-line)
  (interactive "P")
  (navi2ch-bm-select-article-or-scroll 'down max-line))

(defun navi2ch-bm-mouse-select (e)
  (interactive "e")
  (mouse-set-point e)
  (save-excursion
    (beginning-of-line)
    (navi2ch-bm-select-article)))

(defun navi2ch-bm-goto-board ()
  (interactive)
  (navi2ch-list-goto-board
   (funcall navi2ch-bm-get-board-function
            (funcall navi2ch-bm-get-property-function
                     (point)))))

(defun navi2ch-bm-renumber ()
  (save-excursion
    (goto-char (point-min))
    (let ((buffer-read-only nil)
          (i 1))
      (while (not (eobp))
        (let ((props (text-properties-at (point))))
          (delete-char 3)
          (insert (format "%3d" i))
	  (set-text-properties (- (point) 3) (point) props)
          (forward-line 1)
          (setq i (1+ i)))))))

(defun navi2ch-bm-view-logo ()
  "$B$=$NHD$N%m%4$r8+$k(B"
  (interactive)
  (let ((board (funcall navi2ch-bm-get-board-function
			(funcall navi2ch-bm-get-property-function (point))))
	(board-mode-p (eq major-mode 'navi2ch-board-mode))
	file old-file)
    (unless board-mode-p
      (setq board (navi2ch-board-load-info board)))
    (setq old-file (cdr (assq 'logo board)))
    (if navi2ch-offline
	(setq file old-file)
      (setq file (file-name-nondirectory (navi2ch-net-download-logo board)))
      (when file
	(when (and old-file navi2ch-board-delete-old-logo
		   (not (string-equal file old-file)))
	  (delete-file (navi2ch-board-get-file-name board old-file)))
	(if board-mode-p
	    (setq navi2ch-board-current-board board)
	  (navi2ch-board-save-info board))))
    (if file
	(apply 'start-process "navi2ch view logo"
	       nil navi2ch-board-view-logo-program
	       (append navi2ch-board-view-logo-args
		       (list (navi2ch-board-get-file-name board file))))
      (message "Can't find logo file"))))

(defun navi2ch-bm-add-global-bookmark (&optional bookmark-id)
  (interactive (list (navi2ch-bookmark-read-id "bookmark id: ")))
  (let* ((item (funcall navi2ch-bm-get-property-function (point)))
	 (board (funcall navi2ch-bm-get-board-function item))
	 (article (funcall navi2ch-bm-get-article-function item)))
    (if item
	(navi2ch-bookmark-add
	 bookmark-id
	 board
	 article)
      (message "Can't select this line!"))))

;;; move
(defun navi2ch-bm-next-line ()
  (interactive)
  (forward-line 1)
  (setq navi2ch-bm-move-downward t))

(defun navi2ch-bm-previous-line ()
  (interactive)
  (forward-line -1)
  (setq navi2ch-bm-move-downward nil))

;;; mark
(defun navi2ch-bm-goto-mark-column ()
  (navi2ch-bm-goto-state-column)
  (forward-char 1))

(defun navi2ch-bm-mark-subr (mark &optional arg interactive)
  "mark $B$9$k!#(B
INTERACTIVE $B$,(B non-nil $B$J$i(B mark $B$7$?$"$H0\F0$9$k!#(B
ARG $B$,(B non-nil $B$J$i0\F0J}8~$r5U$K$9$k!#(B"
  (let ((item (funcall navi2ch-bm-get-property-function (point)))
	(state 'mark)
	(alist (mapcar
		(lambda (x)
		  (cons (cadr x) (car x)))
		navi2ch-bm-state-alist)))
    (when item
      (save-excursion
        (let ((buffer-read-only nil))
	  (when (string= mark " ")
	    (navi2ch-bm-goto-state-column)
	    (setq state (cdr (assoc (char-to-string (char-after (point)))
				    alist))))
          (navi2ch-bm-goto-mark-column)
          (delete-char 1)
          (insert mark)
          (navi2ch-bm-set-property (progn (beginning-of-line) (point))
				   (progn (end-of-line) (point))
				   item state))))
    (when (and navi2ch-bm-mark-and-move interactive)
      (let (downward)
	(cond ((eq navi2ch-bm-mark-and-move 'follow)
	       (setq downward
		     (if arg
			 (not navi2ch-bm-move-downward)
		       navi2ch-bm-move-downward)))
	      ((eq navi2ch-bm-mark-and-move t)
	       (setq downward (not arg))))
	(if downward
	    (navi2ch-bm-next-line)
	  (navi2ch-bm-previous-line))))))

(defun navi2ch-bm-mark (&optional arg)
  (interactive "P")
  (navi2ch-bm-mark-subr "*" arg (interactive-p)))

(defun navi2ch-bm-unmark (&optional arg)
  (interactive "P")
  (navi2ch-bm-mark-subr " " arg (interactive-p)))

(defun navi2ch-bm-exec-subr (func &rest args)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (navi2ch-bm-goto-mark-column)
      (when (looking-at "\\*")
	(condition-case nil
	    (progn
	      (apply func args)
	      (navi2ch-bm-unmark))
	  (navi2ch-update-failed nil))
	(sit-for 0))
      (forward-line))))

(defun navi2ch-bm-display-mark-article ()
  (interactive)
  (navi2ch-bm-exec-subr 'navi2ch-bm-display-article))

(defun navi2ch-bm-fetch-mark-article ()
  (interactive)
  (navi2ch-bm-exec-subr 'navi2ch-bm-fetch-article))

(defun navi2ch-bm-textize-mark-article (directory &optional file)
  (interactive "Ddirectory: \nFlist file: ")
  (let ((buffer (get-buffer-create (make-temp-name "*navi2ch "))))
    (navi2ch-bm-exec-subr 'navi2ch-bm-textize-article directory buffer)
    (save-excursion
      (set-buffer buffer)
      (when file
	(navi2ch-write-region (point-min) (point-max) file)))
    (kill-buffer buffer)))

(defun navi2ch-bm-add-global-bookmark-mark-article (bookmark-id)
  (interactive (list (navi2ch-bookmark-read-id "bookmark id: ")))
  (navi2ch-bm-exec-subr 'navi2ch-bm-add-global-bookmark bookmark-id))
   
(defun navi2ch-bm-mark-region-subr (begin end mark)
  (save-excursion
    (save-restriction
      (narrow-to-region begin end)
      (goto-char (point-min))
      (while (not (eobp))
        (navi2ch-bm-mark-subr mark)
        (forward-line)))))

(defun navi2ch-bm-mark-region (begin end &optional arg)
  (interactive "r\nP")
  (navi2ch-bm-mark-region-subr begin end (if arg " " "*")))

(defun navi2ch-bm-mark-all (&optional arg)
  (interactive "P")
  (navi2ch-bm-mark-region (point-min) (point-max) arg))

(defun navi2ch-bm-mark-marks (mark &optional arg)
  (interactive "cinput mark: \nP")
  (save-excursion
    (goto-char (point-min))
    (let ((rep (format "%c" (upcase mark))))
      (while (not (eobp))
        (navi2ch-bm-goto-state-column)
        (when (looking-at rep)
          (navi2ch-bm-mark-subr (if arg " " "*")))
        (forward-line)))))

;;; sort
(defun navi2ch-bm-sort-subr (rev start-key-fun end-key-fun)
  (let ((buffer-read-only nil))
    (save-excursion
      (goto-char (point-min))
      (sort-subr rev 'forward-line 'end-of-line
                 start-key-fun end-key-fun))))

(defun navi2ch-bm-sort-by-number (rev)
  (interactive "P")
  (navi2ch-bm-sort-subr
   rev
   'beginning-of-line
   'navi2ch-bm-goto-state-column))

(defun navi2ch-bm-sort-by-state (rev)
  (interactive "P")
  (navi2ch-bm-sort-subr
   (not rev)
   'navi2ch-bm-goto-state-column
   'forward-char))

(defun navi2ch-bm-goto-other-column ()
  (let ((sbj (cdr
              (assq 'subject
                    (funcall
                     navi2ch-bm-get-article-function
                     (funcall navi2ch-bm-get-property-function (point)))))))
    (navi2ch-bm-goto-mark-column)
    (forward-char 1)
    (when (and (not (string= sbj ""))
               (search-forward sbj nil t))
      (goto-char (match-end 0)))
    (skip-chars-forward " ")))

(defun navi2ch-bm-sort-by-subject (rev)
  (interactive "P")
  (navi2ch-bm-sort-subr
   rev
   (lambda ()
     (navi2ch-bm-goto-mark-column)
     (forward-char 1))
   'navi2ch-bm-goto-other-column))

(defun navi2ch-bm-sort-by-other (rev)
  (interactive "P")
  (navi2ch-bm-sort-subr
   rev
   (lambda ()
     (navi2ch-bm-goto-other-column)
     nil) ; end-key-fun $B$r8F$P$;$k$K$O(B nil $B$,M_$7$$$i$7$$!#$O$^$C$?(B($B5c(B)$B!#(B
   'end-of-line))

(defun navi2ch-bm-sort (&optional arg)
  (interactive "P")
  (message "Sort by n)umber s)tate t)itle o)ther?")
  (let ((ch (read-char)))
    (funcall
     (cond ((eq ch ?n) 'navi2ch-bm-sort-by-number)
           ((eq ch ?s) 'navi2ch-bm-sort-by-state)
           ((eq ch ?t) 'navi2ch-bm-sort-by-subject)
           ((eq ch ?o) 'navi2ch-bm-sort-by-other))
     arg)))

;;; search
(defun navi2ch-bm-search-current-board-subject ()
  (interactive)
  (navi2ch-search-subject-subr
   (list (funcall navi2ch-bm-get-board-function
                  (funcall navi2ch-bm-get-property-function (point))))))

(defun navi2ch-bm-search-current-board-article ()
  (interactive)
  (navi2ch-search-article-subr
   (list (funcall navi2ch-bm-get-board-function
                  (funcall navi2ch-bm-get-property-function (point))))))

(defun navi2ch-bm-search ()
  (interactive)
  (let (ch)
    (message "Search for: s)ubject a)rticle")
    (setq ch (read-char))
    (cond ((eq ch ?s)
           (message "Search from: b)oard a)ll")
           (setq ch (read-char))
           (cond ((eq ch ?b) (navi2ch-bm-search-current-board-subject))
                 ((eq ch ?a) (navi2ch-search-all-subject))))
          ((eq ch ?a)
           (message "Search from: b)oard a)ll")
           (setq ch (read-char))
           (cond ((eq ch ?b) (navi2ch-bm-search-current-board-article))
                 ((eq ch ?a) (navi2ch-search-all-article)))))))
  
;;; save and load info
(defun navi2ch-bm-save-info ()
  (navi2ch-save-info
   navi2ch-bm-fetched-info-file
   navi2ch-bm-fetched-article-list))

(defun navi2ch-bm-load-info ()
  (setq navi2ch-bm-fetched-article-list
	(navi2ch-load-info navi2ch-bm-fetched-info-file)))
   
(provide 'navi2ch-board-misc)

;;; navi2ch-board-misc.el ends here