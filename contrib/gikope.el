;;; gikope.el --- Ascii-Art handling tool

;; Copyright 2002 knok <knok@users.sourceforge.net>
;; License: GPL
;; $Id$

;; related resources
;;; gikope http://go.to/gikope

;;
;; customizable variables
(defvar gikope-aa-file "~/.navi2ch/mojidata.txt"
  "$B%.%3%ZMQ%G!<%?%U%!%$%k(B")
(defvar gikope-aa-file-coding 'shift_jis-dos
  "$B%.%3%ZMQ%G!<%?%U%!%$%k$N%(%s%3!<%G%#%s%0(B")

;;
(defvar gikope-aa-location-alist '()
  "$B%.%3%ZMQ%G!<%?%U%!%$%k$NL>>N$H0LCV$rJ]B8$9$k(B alist")
(defvar gikope-aa-buffer "*gikope*"
  "$B%.%3%ZMQ%G!<%?%U%!%$%k$rFI$_$3$s$@%P%C%U%!(B")
(defvar gikope-aa-history nil
  "gikope-copy-to-killring-aa $BMQ%R%9%H%j(B")
(defvar gikope-aa-begin-regex "^\\[MojieName=\\(.*\\)\\]$"
  "$B%.%3%Z%G!<%?(B $B%(%s%H%j3+;OItJ,$N@55,I=8=(B")
(defvar gikope-aa-end-regex "^\\[END\\]$"
  "$B%.%3%Z%G!<%?(B $B%(%s%H%j=*N;ItJ,$N@55,I=8=(B")

; insert
(defun gikope-copy-to-killring-aa (&optional arg)
  "$B%"%9%-!<%"!<%H$r(B kill-ring $B$KF~$l$k(B"
  (interactive "p")
  (let
      ((oldbuf (current-buffer))
       (aa-location-alist gikope-aa-location-alist)
       aaname
       aamax
       aamin)
    (if (= 4 arg)
	(let (re)
	  (setq re (read-from-minibuffer "Regex: "))
	  (setq aa-location-alist (gikope-get-matched-aa-alist re))))
    (save-excursion
      (setq aaname
	    (completing-read
	     "AA name: "
	     aa-location-alist
	     nil nil nil gikope-aa-history))
      (set-buffer gikope-aa-buffer)
      (setq aamin (car (car (cdr (assoc aaname gikope-aa-location-alist)))))
      (setq aamax (cdr (car (cdr (assoc aaname gikope-aa-location-alist)))))
      (copy-region-as-kill aamin aamax))
    (set-buffer oldbuf)))
; parse
(defun gikope-parse-aa (&optional arg)
  "AA $B%G!<%?$rFI$_$3$_!"(Bparse AA data and build gikope-aa-location-alist"
  (interactive "P")
  (let
      ((oldbuf (current-buffer))
       alistitem
       locitem
       mojiname
       start
       end)
    (save-excursion
      (set-buffer (get-buffer-create gikope-aa-buffer))
      (erase-buffer)
      (let ((coding-system-for-read gikope-aa-file-coding))
	(insert-file-contents gikope-aa-file))
      (beginning-of-buffer)
      (setq buffer-read-only t)
      (while (re-search-forward gikope-aa-begin-regex nil t)
	(setq alistitem (match-string 1))
	(forward-line)
	(setq locitem (point))
	(re-search-forward gikope-aa-end-regex)
	(beginning-of-line)
	(setq locitem (cons locitem (point)))
	(setq alistitem (cons alistitem (list locitem)))
	(setq gikope-aa-location-alist 
	      (cons alistitem gikope-aa-location-alist))))
    (set-buffer oldbuf)))
;
(defun gikope-get-matched-aa-alist (re)
  "gikope-aa-location-alist $B$+$i@55,I=8=$K%^%C%A$7$?$b$N$N$_$r<hF@(B"
  (let
      ((temp-alist gikope-aa-location-alist)
       (ret-alist '())
       temp-car)
    (while (not (eq temp-alist nil))
      (setq temp-car (car temp-alist))
      (setq temp-alist (cdr temp-alist))
      (if (string-match re (car temp-car))
	  (setq ret-alist (cons temp-car ret-alist))))
    (symbol-value 'ret-alist)))
;;
