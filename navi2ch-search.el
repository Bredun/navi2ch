;;; navi2ch-search.el --- Search Module for Navi2ch

;; Copyright (C) 2001, 2002 by Navi2ch Project

;; Author: Taiki SUGAWARA <taiki@users.sourceforge.net>
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

;; namazu($BBg@h@8$N8!:w(B) $B$r;H$&$K$O(B
;; (navi2ch-net-send-request
;; (format "http://64.124.197.202/cgi-bin/search/namazu.cgi?%s"
;;         (navi2ch-net-get-param-string
;;          '(("query" . "navi2ch")
;;            ("submit" . "$B8!:w(B")
;;            ("whence" . "0")
;;            ("idxname" . "2chpc")
;;            ("max" . "10")
;;            ("result" . "normal")
;;            ("sort" . "score"))))
;; "GET")
;; $B$J46$8$G!#(B




;;; Code:
(provide 'navi2ch-search)
(defvar navi2ch-search-ident
  "$Id$")

(eval-when-compile (require 'cl))

(require 'navi2ch)

(defvar navi2ch-search-mode-map nil)
(unless navi2ch-search-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map navi2ch-bm-mode-map)
    (define-key map "Q" 'navi2ch-search-return-previous-board-maybe)
    (define-key map "s" 'navi2ch-search-sync)
    (setq navi2ch-search-mode-map map)))

(defvar navi2ch-search-mode-menu-spec
  (navi2ch-bm-make-menu-spec
   "Search"
   nil))

(defvar navi2ch-search-searched-subject-list nil)
(defvar navi2ch-search-board
  '((name . "$B8!:w0lMw(B")
    (type . search)
    (id . "search")))

(defvar navi2ch-search-history nil)

;;; navi2ch-bm callbacks
(defun navi2ch-search-set-property (begin end item)
  (put-text-property begin end 'item item))

(defun navi2ch-search-get-property (point)
  (get-text-property (save-excursion (goto-char point)
				     (beginning-of-line)
				     (point))
		     'item))

(defun navi2ch-search-get-board (item)
  (car item))

(defun navi2ch-search-get-article (item)
  (cdr item))

(defun navi2ch-search-exit ()
  (run-hooks 'navi2ch-search-exit-hook))

;; regist board
(navi2ch-bm-regist-board 'search 'navi2ch-search
			 navi2ch-search-board)

;;; navi2ch-search functions
(defun navi2ch-search-insert-subjects ()
  (let ((i 1))
    (dolist (x navi2ch-search-searched-subject-list)
      (let ((article (navi2ch-search-get-article x))
            (board (navi2ch-search-get-board x)))
        (navi2ch-bm-insert-subject
         x i
         (cdr (assq 'subject article))
         (format "[%s]" (cdr (assq 'name board))))
        (setq i (1+ i))))))

(defun navi2ch-search-board-subject-regexp (board-list regexp)
  (let (alist)
    (dolist (board board-list)
      (message "searching subject in %s..." (cdr (assq 'name board)))
      (let ((file (navi2ch-board-get-file-name board)))
        (when (and file (file-exists-p file))
          (let (rep)
            (with-temp-buffer
              (navi2ch-insert-file-contents file)
              (while (re-search-forward "  +" nil t) (replace-match " "))
              (navi2ch-replace-html-tag-with-buffer)
              (goto-char (point-min))
              (setq rep (navi2ch-board-regexp-test))
              (while (re-search-forward regexp nil t)
                (beginning-of-line)
                (looking-at rep)
                (setq alist (cons (cons board
                                       (navi2ch-board-get-matched-article))
                                 alist))
                (forward-line)))))))
    (message "searching subject...%s" (if alist "done" "not found"))
    (nreverse alist)))

(defun navi2ch-search-article-regexp (board-list regexp)
  (let (alist)
    (dolist (board board-list)
      (message "searching article in %s..." (cdr (assq 'name board)))
      (let ((default-directory (navi2ch-board-get-file-name board "")))
        (dolist (file (and (file-directory-p default-directory)
                           (directory-files default-directory
					    nil "[0-9]+\\.dat")))
          (with-temp-buffer
            (navi2ch-insert-file-contents file)
            (goto-char (point-min))
            (when (re-search-forward regexp nil t)
              (let ((subject
                     (cdr (assq 'subject
                                (navi2ch-article-get-first-message)))))
                (setq alist
		      (cons
		       (cons board
			     (list (cons 'subject subject)
				   (cons 'artid
					 (file-name-sans-extension file))))
		       alist))))))))
    (message "searching article...%s" (if alist "done" "not found"))
    (nreverse alist)))

(easy-menu-define navi2ch-search-mode-menu
  navi2ch-search-mode-map
  "Menu used in navi2ch-search"
  navi2ch-search-mode-menu-spec)

(defun navi2ch-search-setup-menu ()
  (easy-menu-add navi2ch-search-mode-menu))

(defun navi2ch-search-mode ()
  "\\{navi2ch-search-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'navi2ch-search-mode)
  (setq mode-name "Navi2ch Search")
  (setq buffer-read-only t)
  (use-local-map navi2ch-search-mode-map)
  (navi2ch-search-setup-menu)
  (run-hooks 'navi2ch-bm-mode-hook 'navi2ch-search-mode-hook))

(defun navi2ch-search (&rest args)
  (navi2ch-search-mode)
  (navi2ch-bm-setup 'navi2ch-search)
  (navi2ch-search-sync))

(defun navi2ch-search-sync ()
  (interactive)
  (let ((buffer-read-only nil))
    (erase-buffer)
    (save-excursion
      (navi2ch-search-insert-subjects))))

(defun navi2ch-search-return-previous-board-maybe ()
  (interactive)
  (if navi2ch-board-current-board
      (navi2ch-board-select-board	; $B1x$M$'!&!&!&(B
       (prog1
	   navi2ch-board-current-board
	 (setq navi2ch-board-current-board nil)))
    (navi2ch-bm-exit)))

(defun navi2ch-search-subject-subr (board-list)
  (setq navi2ch-search-searched-subject-list
        (navi2ch-search-board-subject-regexp
         board-list (navi2ch-read-string "Subject regexp: " nil
				 'navi2ch-search-history)))
  (navi2ch-bm-select-board navi2ch-search-board))

(defun navi2ch-search-all-subject ()
  (interactive)
  (navi2ch-search-subject-subr
   (navi2ch-list-get-board-name-list
    (navi2ch-list-get-normal-category-list
     navi2ch-list-category-list))))

(defun navi2ch-search-article-subr (board-list)
  (setq navi2ch-search-searched-subject-list
        (navi2ch-search-article-regexp
         board-list (navi2ch-read-string "Search regexp: " nil
				 'navi2ch-search-history)))
  (navi2ch-bm-select-board navi2ch-search-board))

(defun navi2ch-search-all-article ()
  (interactive)
  (navi2ch-search-article-subr
   (navi2ch-list-get-board-name-list
    (navi2ch-list-get-normal-category-list
     navi2ch-list-category-list))))

(defun navi2ch-search-cache-subr (board-list)
  (let (alist node)
    (dolist (board board-list)
      (message "searching cache in %s..." (cdr (assq 'name board)))
      (let ((default-directory (navi2ch-board-get-file-name board ""))
	    (subject-alist (mapcar
			    (lambda (x)
			      (cons (concat (cdr (assq 'artid x))
					    ".dat")
				    x))
			    (navi2ch-board-get-subject-list
			     (navi2ch-board-get-file-name board)))))
        (dolist (file (and (file-directory-p default-directory)
                           (directory-files default-directory
					    nil "[0-9]+\\.dat")))
	  (setq node
		(or (cdr (assoc file subject-alist))
		    (let ((subject (assq 'subject
					 (navi2ch-article-get-first-message-from-file file))))
		      (list subject
			    (cons 'artid (file-name-sans-extension file))))))
	  (setq alist (cons (cons board node) alist)))))
    (message "searching cache...%s" (if alist "done" "not found"))
    (setq navi2ch-search-searched-subject-list (nreverse alist))
    (navi2ch-bm-select-board navi2ch-search-board)))

(defun navi2ch-search-all-cache ()
  (interactive)
  (navi2ch-search-cache-subr
   (navi2ch-list-get-board-name-list
    (navi2ch-list-get-normal-category-list
     navi2ch-list-category-list))))

(run-hooks 'navi2ch-search-load-hook)
;;; navi2ch-search.el ends here
