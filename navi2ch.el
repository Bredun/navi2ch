;;; navi2ch.el --- Navigator for 2ch for Emacsen

;; Copyright (C) 2000 by Navi2ch Project

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
(provide 'navi2ch)

(eval-when-compile (require 'cl))

;; BEWARE: order is important.
(require 'navi2ch-vars)
(require 'navi2ch-face)
(require 'navi2ch-util)
(require 'navi2ch-net)
(require 'navi2ch-list)
(require 'navi2ch-article)
(require 'navi2ch-popup-article)
(require 'navi2ch-board-misc)
(require 'navi2ch-board)
(require 'navi2ch-articles)
(require 'navi2ch-bookmark)
(require 'navi2ch-history)
(require 'navi2ch-search)
(require 'navi2ch-directory)
(require 'navi2ch-message)
(and navi2ch-on-emacs21
     (require 'navi2ch-e21))
(require 'navi2ch-splash)
(require 'navi2ch-version)
(require 'navi2ch-jbbs-net)
(require 'navi2ch-jbbs-shitaraba)
(require 'navi2ch-machibbs)
(require 'navi2ch-multibbs)

(defgroup navi2ch nil
  "Navigator for 2ch."
  :group 'hypermedia)

(defvar navi2ch-ask-when-exit t)

(defvar navi2ch-init nil)

;; hook $BMQ4X?t!#(B
(defun navi2ch-kill-emacs-hook ()
  (run-hooks 'navi2ch-kill-emacs-hook)
  (navi2ch-save-status)
  (if navi2ch-use-lock
      (navi2ch-unlock)))

;;;###autoload
(defun navi2ch (&optional arg)
  "Navigator for 2ch for Emacs"
  (interactive "P")
  (run-hooks 'navi2ch-before-startup-hook)
  (unless navi2ch-init
    (if arg (setq navi2ch-offline (not navi2ch-offline)))
    (when (file-exists-p navi2ch-update-file)
      (load-file navi2ch-update-file))
    (load navi2ch-init-file t)
    (if navi2ch-use-lock
	(navi2ch-lock))
    (if navi2ch-auto-update
	(navi2ch-update))
    (add-hook 'kill-emacs-hook 'navi2ch-kill-emacs-hook)
    (run-hooks 'navi2ch-load-status-hook)
    (run-hooks 'navi2ch-hook)
    (let ((splash-buffer (and navi2ch-display-splash-screen
			      (navi2ch-splash))))
      (unwind-protect
	  (navi2ch-list)
	(when (buffer-live-p splash-buffer)
	  (kill-buffer splash-buffer))))
    (setq navi2ch-init t))
  (when navi2ch-mona-enable
    (require 'navi2ch-mona))
  (navi2ch-list)
  (run-hooks 'navi2ch-after-startup-hook))

(defun navi2ch-version ()
  (interactive)
  (message "Navigator for 2ch %s" navi2ch-version))

(defun navi2ch-save-status ()
  "list, board, article $B$N>uBV$rJ]B8$9$k(B"
  (interactive)
  (message "save status...")
  (run-hooks 'navi2ch-save-status-hook)
  (message "save status...done"))

(defun navi2ch-exit (&optional suspend)
  "navi2ch $B$r=*N;$9$k(B
SUSPEND $B$,(B non-nil $B$J$i(B buffer $B$r>C$5$J$$(B"
  (interactive)
  (when (or suspend
            (not navi2ch-ask-when-exit)
            (if (functionp navi2ch-ask-when-exit)
		(funcall navi2ch-ask-when-exit "really exit navi2ch?")
	      (y-or-n-p "really exit navi2ch?")))
    (run-hooks 'navi2ch-exit-hook)
    (navi2ch-save-status)
    (dolist (x (append
                (list
                 (get-buffer navi2ch-list-buffer-name)
                 (get-buffer navi2ch-board-buffer-name)
		 (get-buffer navi2ch-popup-article-buffer-name)
		 (get-buffer navi2ch-message-backup-buffer-name))
                (navi2ch-article-buffer-list)))
      (when x
        (delete-windows-on x)
        (if suspend
            (bury-buffer x)
          (kill-buffer x))))
    (unless suspend
      (setq navi2ch-init nil)
      (if navi2ch-use-lock
	  (navi2ch-unlock))
      (remove-hook 'kill-emacs-hook 'navi2ch-kill-emacs-hook))))

(defun navi2ch-suspend ()
  "navi2ch $B$r0l;~E*$K=*N;$9$k(B"
  (interactive)
  (navi2ch-exit 'suspend))

(defun navi2ch-three-pane ()
  (interactive)
  (let ((list-buf (get-buffer navi2ch-list-buffer-name))
	(board-buf (get-buffer navi2ch-board-buffer-name))
	(art-buf (navi2ch-article-current-buffer))
	(buf (current-buffer))
	(start (window-start)))
    (delete-other-windows)
    (if (not (and list-buf board-buf art-buf))
	(navi2ch-two-pane)
      (if (not (memq buf (list list-buf board-buf art-buf)))
	  (setq buf list-buf
		start nil))
      (switch-to-buffer list-buf)
      (select-window (split-window-horizontally navi2ch-list-window-width))
      (switch-to-buffer board-buf)
      (select-window (split-window-vertically navi2ch-board-window-height))
      (switch-to-buffer art-buf)
      (select-window (get-buffer-window buf))
      (if start
	  (set-window-start (selected-window) start)))))

(defun navi2ch-one-pane ()
  (interactive)
  (let ((list-buf (get-buffer navi2ch-list-buffer-name))
        (board-buf (get-buffer navi2ch-board-buffer-name))
        (art-buf (navi2ch-article-current-buffer))
	(buf (current-buffer)))
    (if (> (count-windows) 1)
	(let ((start (window-start)))
	  (delete-other-windows)
	  (set-window-start (selected-window) start))
      (delete-other-windows)
      (switch-to-buffer
       (cond ((eq buf list-buf)
              (or board-buf art-buf list-buf))
             ((eq buf board-buf)
              (or art-buf list-buf board-buf))
             ((eq buf art-buf)
              (or list-buf board-buf art-buf))
             (t
              (or list-buf board-buf art-buf buf)))))))

(defun navi2ch-two-pane-horizontally (buf-left buf-right)
  "$B2hLL$r:81&$KJ,3d$7$F(B BUF-LEFT$B!"(BBUF-RIGHT $B$r3d$jEv$F$k!#(B
\(win-left win-right) $B$N%j%9%H$rJV$9(B"
  (delete-other-windows)
  (let ((win-left (selected-window))
	(win-right (split-window-horizontally navi2ch-list-window-width)))
    (set-window-buffer win-left buf-left)
    (set-window-buffer win-right buf-right)
    (list win-left win-right)))

(defun navi2ch-two-pane-vertically (buf-top buf-bottom)
  "$B2hLL$r>e2<$KJ,3d$7$F(B BUF-TOP$B!"(BBUF-BOTTOM $B$r3d$jEv$F$k!#(B
\(win-top win-bottom) $B$N%j%9%H$rJV$9(B"
  (delete-other-windows)
  (let ((win-top (selected-window))
	(win-bottom (split-window-vertically navi2ch-board-window-height)))
    (set-window-buffer win-top buf-top)
    (set-window-buffer win-bottom buf-bottom)
    (list win-top win-bottom)))

(defun navi2ch-two-pane ()
  (interactive)
  (let* ((list-buf (get-buffer navi2ch-list-buffer-name))
	 (board-buf (get-buffer navi2ch-board-buffer-name))
	 (art-buf (navi2ch-article-current-buffer))
	 (list-win (get-buffer-window (or list-buf "")))
	 (board-win (get-buffer-window (or board-buf "")))
	 (art-win (get-buffer-window (or art-buf "")))
	 (buf (current-buffer))
	 (start (window-start)))
    (when (not (memq buf (list list-buf board-buf art-buf)))
      (setq buf (or list-buf board-buf art-buf))
      (unless buf
	(error "No navi2ch buffer"))
      (switch-to-buffer buf)
      (setq start (window-start)))
    (cond ((and (eq buf list-buf)
		(or board-buf art-buf))
	   (navi2ch-two-pane-horizontally buf
					  (if art-win
					      (or board-buf art-buf)
					    (or art-buf board-buf))))
	  ((and (eq buf board-buf)
		list-buf
		(or art-win
		    (null art-buf)))
	   (navi2ch-two-pane-horizontally list-buf buf))
	  ((and (eq buf board-buf)
		art-buf)
	   (navi2ch-two-pane-vertically buf art-buf))
	  ((and (eq buf art-buf)
		list-buf
		(or board-win
		    (null board-buf)))
	   (navi2ch-two-pane-horizontally list-buf buf))
	  ((and (eq buf art-buf)
		board-buf)
	   (navi2ch-two-pane-vertically board-buf buf)))
    (select-window (get-buffer-window buf))
    (set-window-start (selected-window) start)))

(defun navi2ch-make-backup-file-name (file)
  "FILE $B$G;XDj$5$l$k%U%!%$%k$+$i%P%C%/%"%C%W%U%!%$%k$NL>A0$rJV$9!#(B"
  ;; $B$H$j$"$($:$O!"(BOS $B$4$H$N%P%C%/%"%C%WL>$N0c$$$O(B Emacs $B$K$^$+$;$k!#(B
  ;; $B8e!9JQ$($?$/$J$C$?;~$KJQ99$7K:$l$k$N$rKI$0$?$a!#(B
  (make-backup-file-name file))

;; make-temp-file $B$NJ}$,0BA4$@$1$I!"B8:_$7$J$$4D6-$G$O(B make-temp-name $B$r;H$&!#(B
(defun navi2ch-make-temp-file (file)
  "$B%F%s%]%i%j%U%!%$%k$r:n$k!#(B"
  (funcall (if (fboundp 'make-temp-file)
	       'make-temp-file
	     'make-temp-name) file))

(defun navi2ch-save-info (file info &optional backup)
  "lisp-object INFO $B$r(B FILE $B$KJ]B8$9$k!#(B
BACKUP $B$,(B non-nil $B$N>l9g$O85$N%U%!%$%k$r%P%C%/%"%C%W$9$k!#(B"
  (setq info (navi2ch-strip-properties info)
	file (expand-file-name file))	; $B@dBP%Q%9$K$7$F$*$/(B
  (let ((dir (file-name-directory file)))
    (unless (file-exists-p dir)
      (make-directory dir t)))
  (when (or (file-regular-p file)
	    (not (file-exists-p file)))
    (let ((coding-system-for-write navi2ch-coding-system)
	  (backup-file (navi2ch-make-backup-file-name file))
	  temp-file)
      (unwind-protect
	  (progn
	    ;; $B%U%!%$%k$,3N<B$K>C$($k$h$&!"2<$N(B setq $B$O>e$N(B let $B$K0\F0(B
	    ;; $B$7$F$O%@%a(B
	    (setq temp-file (navi2ch-make-temp-file
			     (file-name-directory file)))
	    (with-temp-file temp-file
	      (let ((standard-output (current-buffer)))
		(prin1 info)))
	    (if (and backup (file-exists-p file))
		(rename-file file backup-file t))
	    ;; $B>e$N(B rename $B$,@.8y$7$F2<$,<:GT$7$F$b!"(Bnavi2ch-load-info
	    ;; $B$,%P%C%/%"%C%W%U%!%$%k$+$iFI$s$G$/$l$k!#(B
	    (rename-file temp-file file t))
	(if (and temp-file (file-exists-p temp-file))
	    (delete-file temp-file))))))

(defun navi2ch-load-info (file)
  "FILE $B$+$i(B lisp-object $B$rFI$_9~$_!"$=$l$rJV$9!#(B"
  (setq file (expand-file-name file))	; $B@dBP%Q%9$K$7$F$*$/(B
  (let ((backup-file (navi2ch-make-backup-file-name file)))
    (when (and (file-exists-p backup-file)
	       (file-regular-p backup-file)
	       (or (not (file-exists-p file))
		   (not (file-regular-p file))
		   (file-newer-than-file-p backup-file file))
	       (yes-or-no-p
		"$BLdBjH/@8!#%P%C%/%"%C%W%U%!%$%k$+$iFI$_9~$_$^$9$+(B? "))
      (setq file backup-file)))
  (when (file-regular-p file)
    (let ((coding-system-for-read navi2ch-coding-system))
      (with-temp-buffer
	(insert-file-contents file)
	(let ((standard-input (current-buffer)))
	  (read))))))

(defun navi2ch-split-window (display)
  "window $B$rJ,3d$9$k!#(B
DISPLAY $B$,(B `board' $B$N$H$-$O(B board $B$rI=<($9$kMQ$KJ,3d$9$k!#(B
DISPLAY $B$,(B `article' $B$N$H$-$O(B article $B$rI=<($9$kMQ$KJ,3d$9$k!#(B"
  (let ((list-win (get-buffer-window navi2ch-list-buffer-name))
        (board-win (get-buffer-window navi2ch-board-buffer-name))
        (art-win (and (navi2ch-article-current-buffer)
                      (get-buffer-window (navi2ch-article-current-buffer)))))
    (cond (art-win
	   (select-window art-win)
	   (when (eq display 'board)
	     (navi2ch-article-exit)))
          (board-win
	   (select-window board-win)
	   (when (and (eq display 'article)
		      navi2ch-bm-stay-board-window)
	     (condition-case nil
		 (enlarge-window (frame-height))
	       (error nil))
	     (split-window-vertically navi2ch-board-window-height)
	     (other-window 1)))
          (list-win
           (select-window list-win)
	   (when navi2ch-list-stay-list-window
	     (split-window-horizontally navi2ch-list-window-width)
	     (other-window 1))))))

(defun navi2ch-goto-url (url &optional force)
  "URL $B$+$i%9%l$^$?$OHD$rA*$V(B"
  (interactive "sURL: ")
  (let ((list-win (get-buffer-window navi2ch-list-buffer-name))
        (board-win (get-buffer-window navi2ch-board-buffer-name))
        (art-win (and (navi2ch-article-current-buffer)
                      (get-buffer-window (navi2ch-article-current-buffer))))
	(article (navi2ch-article-url-to-article url))
	(board (navi2ch-board-url-to-board url)))
    (cond (article
	   (navi2ch-split-window 'article)
	   (navi2ch-article-view-article board
					 article
					 force
					 (cdr (assq 'number article))))
	  (board
	   (navi2ch-split-window 'board)
	   (navi2ch-board-select-board board force)))))

(defun navi2ch-find-file (file)
  "FILE $B$+$i%9%l$^$?$OHD$rA*$V(B"
  (interactive "fFind article file or board directory: ")
  (let ((list-win (get-buffer-window navi2ch-list-buffer-name))
        (board-win (get-buffer-window navi2ch-board-buffer-name))
        (art-win (and (navi2ch-article-current-buffer)
                      (get-buffer-window (navi2ch-article-current-buffer))))
	(article-p (file-regular-p file))
	(board-p (file-directory-p file)))
    (cond (article-p
	   (navi2ch-split-window 'article)
	   (navi2ch-article-view-article-from-file file))
	  (board-p
	   (navi2ch-split-window 'board)
	   (navi2ch-directory-find-directory file)))))

(defun navi2ch-2ch-url-p (url)
  "URL $B$,(B 2ch $BFb$N(B url $B$+$rJV$9!#(B"
  (let ((host (navi2ch-url-to-host url)))
    (or (member host navi2ch-2ch-host-list)
	(let (list)
	  (setq list
		(mapcar
		 (lambda (x)
		   (navi2ch-url-to-host (cdr (assq 'uri x))))
		 (navi2ch-list-get-board-name-list
		  navi2ch-list-category-list)))
	  (member host list)))))

(defun navi2ch-change-log-directory (changed-list)
  "$BJQ99$5$l$?HD$N%m%0$rJ]B8$9$k%G%#%l%/%H%j$r=$@5$9$k!#(B
CHANGED-LIST $B$K$D$$$F$O(B `navi2ch-list-get-changed-status' $B$r;2>H!#(B"
  (dolist (node changed-list)
    (let ((old-dir (navi2ch-board-get-file-name (cadr node) ""))
	  (new-dir (navi2ch-board-get-file-name (caddr node) ""))
	  tmp-dir)
      (when (file-exists-p old-dir)
	(when (file-exists-p new-dir)
	  (catch 'loop
	    (while t
	      (setq tmp-dir (expand-file-name
			     (make-temp-name (concat "navi2ch-" (car node)))
			     (navi2ch-temp-directory)))
	      (unless (file-exists-p tmp-dir)
		(throw 'loop nil))))
	  (navi2ch-rename-file new-dir tmp-dir))
	(make-directory (expand-file-name ".." new-dir) t)
	(navi2ch-rename-file old-dir new-dir)))))

(defun navi2ch-update ()
  "navi2ch-update.el $B$r%@%&%s%m!<%I$7$F<B9T$9$k!#(B"
  (interactive)
  (let ((new (concat navi2ch-update-file ".new")))
    (when (and navi2ch-update-url
	       (not (string= navi2ch-update-url ""))
	       (not navi2ch-offline)
	       (navi2ch-net-update-file navi2ch-update-url new)
	       (file-exists-p new)
	       (or (not (file-exists-p navi2ch-update-file))
		   (not (= (nth 7 (file-attributes navi2ch-update-file))
			   (nth 7 (file-attributes new))))
		   (not (string=
			 (with-temp-buffer
			   (insert-file-contents-literally navi2ch-update-file)
			   (buffer-string))
			 (with-temp-buffer
			   (insert-file-contents-literally new)
			   (buffer-string)))))
	       (yes-or-no-p
		"navi2ch-update.el$B$,99?7$5$l$^$7$?!#J]B8$7$F<B9T$7$^$9$+(B? "))
      (navi2ch-rename-file new navi2ch-update-file t)
      (load navi2ch-update-file))
    (if (file-exists-p new)
	(delete-file new))))

(defun navi2ch-toggle-offline ()
  (interactive)
  (navi2ch-net-cleanup)
  (setq navi2ch-offline (not navi2ch-offline))
  (message (if navi2ch-offline
               "offline"
             "online"))
  (navi2ch-set-mode-line-identification))

(defun navi2ch-unload ()
  "Unload all navi2ch features."
  (interactive)
  (if (and (symbolp 'navi2ch-init)
	   navi2ch-init)
      (navi2ch-exit))
  (dolist (feature features)
    (if (or (save-match-data (string-match "\\`navi2ch-"
					   (symbol-name feature)))
	    (equal feature 'navi2ch))
	(unload-feature feature 'force))))

;;; $B%m%C%/(B
;; $B:G$bHFMQE*$J(B mkdir $B%m%C%/$r<BAu$7$F$_$?!#(B
;; ~/.navi2ch/lockdir $B$H$$$&%G%#%l%/%H%j$,$"$k>l9g$O$=$N%G%#%l%/%H%j$O(B
;; $B%m%C%/$5$l$F$$$k$H$$$&$3$H$K$J$k!#(B
;; $B%7%'%k%9%/%j%W%H$GF1$8<jK!$r;H$$!"(Bcron $B$G(B wget $B$G$bF0$+$;$P!"(B
;; ~/.navi2ch/ $B0J2<$r>o$K?7A/$KJ]$F$k$+$b!#(B(w

(defun navi2ch-lock ()
  "`navi2ch-directory' $B$r%m%C%/$9$k!#(B"
  (let* ((lockdir (navi2ch-chop-/ (expand-file-name navi2ch-lock-directory)))
	 (basedir (file-name-directory navi2ch-lock-directory))
	 ;; make-directory-internal $B$O(B mkdir(2) $B$r8F$S=P$9$N$G!"%"%H%_%C(B
	 ;; $B%/$J%m%C%/$,4|BT$G$-$k!#(B
	 (make-directory-function (if (fboundp 'make-directory-internal)
				      'make-directory-internal
				    'make-directory))
	 (redo t)
	 error-message)
    ;; $B$^$:!"2<$G%(%i!<$,5/$-$J$$$h$&!"?F%G%#%l%/%H%j$r:n$C$F$*$/(B
    (unless (file-exists-p basedir)
      (ignore-errors
	(make-directory basedir t)))
    (while redo
      (setq redo nil)
      (if (file-exists-p lockdir)	; lockdir $B$,$9$G$K$"$k$H<:GT(B
	  (setq error-message "$B%m%C%/%G%#%l%/%H%j$,$9$G$K$"$j$^$9!#(B")
	;; file-name-handler-alist $B$,$"$k$H(B mkdir $B$,D>@\8F$P$l$J(B
	;; $B$$2DG=@-$,$"$k!#(B
	(condition-case error
	    (let ((file-name-handler-alist nil))
	      (funcall make-directory-function lockdir))
	  (error
	   (message "%s" (error-message-string error))
	   (sit-for 3)
	   (discard-input)
	   (setq error-message "$B%m%C%/%G%#%l%/%H%j$N:n@.$K<:GT$7$^$7$?!#(B"))))
      (unless (file-exists-p lockdir)	; $BG0$N$?$a!"3NG'$7$F$*$/(B
	(setq error-message "$B%m%C%/%G%#%l%/%H%j$r:n@.$G$-$^$;$s$G$7$?!#(B"))
      (if (and error-message
	       (y-or-n-p (format "%s$B$b$&0lEY;n$7$^$9$+(B? "
				 error-message)))
	  (setq redo t)))
    (if (and error-message
	     (not (yes-or-no-p (format "%s$B4m81$r>5CN$GB3$1$^$9$+(B? "
				       error-message))))
	(error "lock failed: %s" lockdir))))

(defun navi2ch-unlock ()
  "`navi2ch-directory' $B$N%m%C%/$r2r=|$9$k!#(B"
  (ignore-errors
    (delete-directory navi2ch-lock-directory)))

(run-hooks 'navi2ch-load-hook)
;;; navi2ch.el ends here
