;;; navi2ch-popup-article.el --- popup article module for navi2ch

;; Copyright (C) 2001, 2002 by Navi2ch Project

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
(provide 'navi2ch-popup-article)
(defvar navi2ch-popup-article-ident
  "$Id$")

(require 'navi2ch)

(defvar navi2ch-popup-article-buffer-name "*navi2ch popup article*")
(defvar navi2ch-popup-article-window-configuration nil)
(defvar navi2ch-popup-article-mode-map nil)
(unless navi2ch-popup-article-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map navi2ch-global-view-map)
    (define-key map "j" 'navi2ch-article-few-scroll-up)
    (define-key map "k" 'navi2ch-article-few-scroll-down)
    (define-key map " " 'navi2ch-article-scroll-up)
    (define-key map [del] 'navi2ch-article-scroll-down)
    (define-key map [backspace] 'navi2ch-article-scroll-down)
    (define-key map "\177" 'navi2ch-article-scroll-down)
    (define-key map "\r" 'navi2ch-popup-article-select-current-link)
    (navi2ch-define-mouse-key map 2 'navi2ch-popup-article-mouse-select)
    (define-key map "g" 'navi2ch-article-goto-number)
    (define-key map "q" 'navi2ch-popup-article-exit)
    (define-key map "Q" 'navi2ch-popup-article-exit-and-goto-number)
    (define-key map "l" 'navi2ch-popup-article-pop-point-or-exit)
    (define-key map "L" 'navi2ch-article-pop-poped-point)
    (define-key map "m" 'navi2ch-article-push-point)
    (define-key map "R" 'navi2ch-article-rotate-point)
    (define-key map "U" 'navi2ch-popup-article-show-url)
    (define-key map "." 'navi2ch-article-redisplay-current-message)
    (define-key map "p" 'navi2ch-article-previous-message)
    (define-key map "n" 'navi2ch-article-next-message)
    (define-key map [(shift tab)] 'navi2ch-article-previous-link)
    (define-key map "\e\C-i" 'navi2ch-article-previous-link)
    (define-key map "\C-\i" 'navi2ch-article-next-link)
    (define-key map ">" 'navi2ch-article-goto-last-message)
    (define-key map "<" 'navi2ch-article-goto-first-message)
    (define-key map "\eu" 'navi2ch-article-uudecode-message)
    (define-key map "\ed" 'navi2ch-article-base64-decode-message)
    (define-key map "v" 'navi2ch-article-view-aa)
    (define-key map "?" 'navi2ch-article-search)
    (define-key map "d" 'navi2ch-popup-article-exclude-message)
    (define-key map "D" 'navi2ch-popup-article-hide-messages)
    (define-key map "A" 'navi2ch-popup-article-add-important-messages)
    (setq navi2ch-popup-article-mode-map map)))

(defvar navi2ch-popup-article-current-board nil)
(defvar navi2ch-popup-article-current-article nil)
(defvar navi2ch-popup-article-exclude-stack nil)

(defun navi2ch-popup-article-exit ()
  "PopUp Article $B%b!<%I$rH4$1$k!#(B"
  (interactive)
  (run-hooks 'navi2ch-popup-article-exit-hook)
  (bury-buffer)
  (set-window-configuration navi2ch-popup-article-window-configuration)
  (delete-windows-on (get-buffer navi2ch-popup-article-buffer-name))
  (unless (eq navi2ch-article-current-article
	      navi2ch-popup-article-current-article)
    (navi2ch-article-view-article
     navi2ch-popup-article-current-board
     navi2ch-popup-article-current-article)))

(defun navi2ch-popup-article-exit-and-goto-number (&optional num)
  "Article $B%b!<%I$KLa$C$F$+$i:#$N0LCV$N%l%9$NHV9f$K0\F0!#(B
NUM $B$,;XDj$5$l$l$P!"(B NUM $BHVL\$N%l%9$K0\F0!#(B"
  (interactive)
  (setq num (or num (navi2ch-article-get-current-number)))
  (navi2ch-popup-article-exit)
  (if (integerp num)
      (navi2ch-article-goto-number num t t)
    (navi2ch-popup-article num)))

(defun navi2ch-popup-article-pop-point-or-exit ()
  "stack $B$+$i(B pop $B$7$?0LCV$K0\F0$9$k!#(B
stack $B$,6u$J$i!"(BPopUp Article $B%b!<%I$rH4$1$k!#(B"
  (interactive)
  (if navi2ch-article-point-stack
      (navi2ch-article-pop-point)
    (navi2ch-popup-article-exit)))

(defun navi2ch-popup-article-mode ()
  "\\{navi2ch-popup-article-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'navi2ch-popup-article-mode)
  (setq mode-name "Navi2ch PopUp Article")
  (setq buffer-read-only t)
  (make-local-variable 'truncate-partial-width-windows)
  (setq truncate-partial-width-windows nil)
  (use-local-map navi2ch-popup-article-mode-map)
  (setq navi2ch-article-point-stack nil)
  (setq navi2ch-popup-article-exclude-stack nil)
  (make-local-hook 'post-command-hook)
  (add-hook 'post-command-hook 'navi2ch-article-display-link-minibuffer nil t)
  (run-hooks 'navi2ch-popup-article-mode-hook))

(defun navi2ch-popup-article (num-list)
  (let ((mlist navi2ch-article-message-list)
	(sep navi2ch-article-separator)
	(buf (get-buffer-create navi2ch-popup-article-buffer-name)))
    (setq navi2ch-popup-article-window-configuration
	  (current-window-configuration))
    (when (eq major-mode 'navi2ch-article-mode)
      (setq navi2ch-popup-article-current-board
	    navi2ch-article-current-board
	    navi2ch-popup-article-current-article
	    navi2ch-article-current-article))
    (pop-to-buffer buf)
    (navi2ch-popup-article-mode)
    (setq navi2ch-article-message-list mlist)
    (setq navi2ch-article-message-list
	  (mapcar (lambda (x)
		    (let ((msg (navi2ch-article-get-message x)))
		      (cond
		       ((stringp msg) (cons x msg))
		       (msg (cons x (copy-alist msg)))
		       (t nil))))
		  num-list))
    (setq navi2ch-article-message-list
	  (delq nil navi2ch-article-message-list))
    (if (null navi2ch-article-message-list)
	(progn
	  (navi2ch-popup-article-exit)
	  (message "No responses found"))
      (setq navi2ch-article-separator sep)
      (setq navi2ch-article-point-stack nil)
      (setq navi2ch-article-poped-point-stack nil)
      (setq truncate-partial-width-windows nil)
      (setq navi2ch-article-view-range nil)
      (setq navi2ch-article-through-next-function 'navi2ch-popup-article-exit)
      (setq navi2ch-article-through-previous-function
	    'navi2ch-popup-article-exit)
      (let ((buffer-read-only nil))
	(erase-buffer)
	(navi2ch-article-insert-messages
	 navi2ch-article-message-list
	 nil))
      (goto-char (point-min)))))

(defun navi2ch-popup-article-scroll-up ()
  "$B2hLL$r%9%/%m!<%k$9$k!#(B"
  (interactive)
  (condition-case nil
      (scroll-up)
    (end-of-buffer
     (navi2ch-popup-article-exit)))
  (force-mode-line-update t))

(defun navi2ch-popup-article-select-current-link (&optional browse-p)
  ;; $B$[$\(B navi2ch-article-select-current-link $B$HF1$8!#(B
  "$B%+!<%=%k0LCV$K1~$8$F!"%j%s%/@h$NI=<($d%U%!%$%k$X$NJ]B8$r9T$&!#(B"
  (interactive "P")
  (let (prop)
    (cond
     ((setq prop (get-text-property (point) 'number))
      (setq prop (navi2ch-article-str-to-num (japanese-hankaku prop)))
      (if (integerp prop)
	  (progn
	    (unless (assq prop navi2ch-article-message-list)
	      (navi2ch-popup-article-exit))
	    (navi2ch-article-goto-number prop t t))
	(navi2ch-popup-article-exit)
	(navi2ch-popup-article prop)))
     ((setq prop (get-text-property (point) 'url))
      (let ((2ch-url-p (navi2ch-2ch-url-p prop)))
	(if (and 2ch-url-p
		 (or (navi2ch-board-url-to-board prop)
		     (navi2ch-article-url-to-article prop))
		 (not browse-p))
	    (progn
	      (navi2ch-popup-article-exit)
	      (navi2ch-goto-url prop))
	  (navi2ch-browse-url-internal prop))))
     ((setq prop (get-text-property (point) 'content))
      (navi2ch-article-save-content)))))

(defun navi2ch-popup-article-mouse-select (e)
  "$B%^%&%9$N0LCV$K1~$8$F!"%j%s%/@h$NI=<($d%U%!%$%k$X$NJ]B8$r9T$&!#(B"
  (interactive "e")
  (mouse-set-point e)
  (navi2ch-popup-article-select-current-link))

(defun navi2ch-popup-article-show-url ()
  "url $B$rI=<($7$F!"$=$N(B url $B$r8+$k$+(B kill ring $B$K%3%T!<$9$k(B"
  (interactive)
  (let ((navi2ch-article-current-board navi2ch-popup-article-current-board)
	(navi2ch-article-current-article navi2ch-popup-article-current-article))
    (navi2ch-article-show-url)))

(defun navi2ch-popup-article-exclude-message (&optional prefix)
  "$B%l%9$rI=<($+$i=|30$9$k!#(B"
  (interactive "P")
  (if prefix
      (navi2ch-popup-article-undo-exclude-message)
    (let ((buffer-read-only nil)
	  (num (navi2ch-article-get-current-number)))
      (if (null num)
	  (message "No message")
	(push num navi2ch-popup-article-exclude-stack)
	(save-excursion
	  (delete-region
	   (if (get-text-property (point) 'current-number)
	       (point)
	     (navi2ch-previous-property (point) 'current-number))
	   (or (navi2ch-next-property (point) 'current-number)
	       (point-max))))
	(message "Exclude message")))))

(defun navi2ch-popup-article-undo-exclude-message ()
  "$BI=<($+$i=|30$7$?%l%9$rI|3h$5$;$k!#(B"
  (interactive)
  (let ((buffer-read-only nil)
	(num (pop navi2ch-popup-article-exclude-stack)))
    (if (null num)
	(message "No message excluded")
      (save-excursion
	(navi2ch-article-reinsert-partial-messages num num))
      (navi2ch-article-goto-number num t)
      (message "Push point and undo exclude message"))))

(defun navi2ch-popup-article-sift-messages (sym msg)
  (let ((list (navi2ch-article-get-visible-numbers)))
    (if (null list)
	(message "No popup message")
      (navi2ch-popup-article-exit)
      (setq navi2ch-article-current-article
	    (navi2ch-put-alist
	     sym
	     (union (cdr (assq sym navi2ch-article-current-article)) list)
	     navi2ch-article-current-article))
      (let ((buffer-read-only nil))
	(navi2ch-article-save-view
	  (save-excursion
	    (erase-buffer)
	    (navi2ch-article-insert-messages
	     navi2ch-article-message-list
	     navi2ch-article-view-range))))
      (message msg))))

(defun navi2ch-popup-article-hide-messages ()
  "$BI=<(Cf$N%l%9$r$^$H$a$F1#$9!#(B"
  (interactive)
  (if (navi2ch-y-or-n-p "Hide popup messages? ")
      (navi2ch-popup-article-sift-messages 'hide
					   "Hide messages")
    (message "Don't hide messages")))

(defun navi2ch-popup-article-add-important-messages ()
  "$BI=<(Cf$N%l%9$r$^$H$a$F%V%C%/%^!<%/$KEPO?$9$k!#(B"
  (interactive)
  (if (navi2ch-y-or-n-p "Add important popup messages? ")
      (navi2ch-popup-article-sift-messages 'important
					   "Add important messages")
    (message "Don't add important messages")))

(run-hooks 'navi2ch-popup-article-load-hook)
;;; navi2ch-popup-article.el ends here
