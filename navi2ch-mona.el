;;; navi2ch-mona.el --- Mona Font Utils for Navi2ch

;; Copyright (C) 2001 by Navi2ch Project

;; Author: Taiki SUGAWARA <taiki@users.sourceforge.net>
;; 431 ��̵̾������
;; 874 ��̵̾������
;; UEYAMA Rui <rui314159@users.sourceforge.net>
;; part5 ����� 26, 45 ����

;; The part of find-face is originated form apel (poe.el).
;; You can get the original apel from <ftp://ftp.m17n.org/pub/mule/apel>.
;; poe.el's Authors:  MORIOKA Tomohiko <tomo@m17n.org>
;;      Shuhei KOBAYASHI <shuhei@aqua.ocn.ne.jp>
;; apel is also licened under GPL.

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

;; custom ��Ȥä� M-x customize-group navi2ch-mona ����
;; ���ꤹ��ȥ饯����

;;; Code:
(provide 'navi2ch-mona)
(eval-when-compile (require 'cl))
(require 'navi2ch-vars)

(make-face 'navi2ch-mona-face)
(make-face 'navi2ch-mona12-face)
(make-face 'navi2ch-mona14-face)
(make-face 'navi2ch-mona16-face)

;; �������ޥ����ѿ��� defcustom ��ɬ�פʴؿ�
(defun navi2ch-mona-create-fontset-from-family-name (family-name height)
  "navi2ch ��ɬ�פȤ���ե���ȥ��åȤ��ꡢ����̾�����֤���

FAMILY-NAME �� \"foundry-family\" ����ʤ�ʸ����HEIGHT �� pixelsize��

XEmacs �Ǥ�����Ū�˥ե���ȥ��åȤ���ɬ�פ��ʤ��Τǡ�
�ե���ȥ��å�̾�Ȥ��ư�̣�Τ���ʸ����
 \"-<FAMILY-NAME>-medium-r-*--<height>-*-*-*-p-*-*-*\"
���֤�������"
  (let ((fontset-name (format "-%s-medium-r-*--%d-*-*-*-p-*-*-*"
                              family-name height)))
    (cond (navi2ch-on-xemacs
           fontset-name)
          (navi2ch-on-emacs21
           (let* ((fields (x-decompose-font-name fontset-name))
                  (foundry (aref fields 0))
                  (family (aref fields 1))
                  (slant (aref fields 3))
                  (swidth (aref fields 4))
                  (fontset-templ (format
                                  "-%s-%s-%%s-%s-%s--%d-*-*-*-p-*-fontset-mona%d"
                                  foundry family slant swidth height height))
                  (font-templ (progn
                                (string-match "^\\(.*\\)\\(fontset-mona[^-]+\\)$"
                                              fontset-templ)
                                (concat (match-string 1 fontset-templ) "%s")))
                  (fontset (format "-%s-%s-*-*-*--%d-*-*-*-*-*-%s"
                                   foundry family height
                                   (match-string 2 fontset-templ))))
             (setq fontset-name fontset)
             (dolist (weight '("medium" "bold"))
               (let ((fontset (format fontset-templ weight))
                     (font (format font-templ weight "%s")))
                 (unless (query-fontset fontset)
                   (new-fontset fontset
                                (list (cons 'ascii
                                            (format font "iso8859-1"))
                                      (cons 'latin-iso8859-1
                                            (format font "iso8859-1"))
                                      (cons 'katakana-jisx0201
                                            (format font "jisx0201.1976-0"))
                                      (cons 'latin-jisx0201
                                            (format font "jisx0201.1976-0"))
                                      (cons 'japanese-jisx0208
                                            (format font "jisx0208.1990-0"))))))))
           fontset-name))))


;; Customizable variables.
(defcustom navi2ch-mona-enable-board-list nil
  "*��ʡ��ե���Ȥ�ɽ�������ĤΥꥹ�ȡ�"
  :type '(repeat (string :tag "��"))
  :group 'navi2ch-mona)

(defcustom navi2ch-mona-disable-board-list nil
  "*��ʡ��ե���Ȥ�Ȥ�ʤ��ĤΥꥹ�ȡ�"
  :type '(repeat (string :tag "��"))
  :group 'navi2ch-mona)

(defcustom navi2ch-mona-pack-space-p nil
  "*non-nil �ʤ顢Web �֥饦���Τ褦��2�İʾ�ζ����1�ĤˤޤȤ��ɽ�����롣"
  :type 'boolean
  :group 'navi2ch-mona)

(defcustom navi2ch-mona-font-family-name "mona-gothic"
  "*��ʡ��ե���ȤȤ��ƻȤ��ե���Ȥ� family ̾��
XLFD �Ǥ��� \`foundry-family\' ����ꤹ�롣�פ���� X �Ǥ�
�ե����̾�κǽ��2�ե�����ɤ�񤱤Ф����äƤ��ä���

XEmacs �Ǥϡ����ꤵ�줿 family ���Ф��� pixelsize: 12/14/16
�� 3�ĤΥե���ȥ��åȤ��롣

Emacs 21 �Ǥϡ�����˲ä��� medium/bold �ʥե���Ȥ��̡��˺�롣
���Ȥ��а��� \`moga-gothic\' ���錄�����ȡ�

 -mona-gothic-medium-r-*--12-*-*-*-*-*-fontset-mona12
 -mona-gothic-medium-r-*--14-*-*-*-*-*-fontset-mona14
 -mona-gothic-medium-r-*--16-*-*-*-*-*-fontset-mona16
 -mona-gothic-bold-r-*--12-*-*-*-*-*-fontset-mona12
 -mona-gothic-bold-r-*--14-*-*-*-*-*-fontset-mona14
 -mona-gothic-bold-r-*--16-*-*-*-*-*-fontset-mona16

�Ȥ��� 6 �ĤΥե���ȥ��åȤ��뤳�Ȥˤʤ롣

ʸ���Τ����˥ȡ��դ�ɽ��������㤦�Τϡ����֤�ե���Ȥ�
���Ĥ���ʤ��ä������ʤΤǡ�\`xlsfonts\' ��¹Ԥ���

-<���ꤷ��ʸ����>-{medium,bold}-r-*--{12,14,16}-*-*\\
-*-*-*-{iso8859-1,jisx0201.1976-0,jisx0208.(1983|1990)-0}

�����뤫�ɤ����Τ���Ƥ͡�"
  :type '(choice (string :tag "family name")
		 (string :tag "Mona fonts"
			 :value "mona-gothic")
		 (string :tag "MS P Gothic"
			 :value "microsoft-pgothic"))
  :set (function (lambda (symbol value)
		   (condition-case nil
		       (progn
			 (dolist (height '(12 14 16))
			   (let ((fontset (navi2ch-mona-create-fontset-from-family-name
					   value height))
				 (face (intern (format "navi2ch-mona%d-face" height))))
			     (set-face-font face fontset)))
			 (set-default symbol value))
		     (error nil))))
  :initialize 'custom-initialize-reset
  :group 'navi2ch-mona)

(defconst navi2ch-mona-sample-string
  (concat "����ץ�ƥ����ȥ��åȥ����� �Ҥ餬�ʡ��������ʡ�Roman Alphabet��\n"
          (decode-coding-string
           (base64-decode-string
            "gVCBUIFQgVCBUIHJgVCBUIFQgVCBUIFQgVCBUIFAgUAogUyBTAqBQIFAgUCBQCCB
yIHIgUCBQIFAgWqBQIFAgUCBQIFAgUAogUyB3CiBTAqBQIFAgbyBad+ERN+BvIHc
gU2CwoHfgd+B3yiBTIHcOzs7gd+B34HfCoFAgUCBQIFAgUCBQCCBUIFQgUAgKIFM
gdwogUyB3Ds7CoFAgUCBQIFAgUCBQL3eu9673rCwsLCwryK93rveCg==")
	   'shift_jis)))

(defcustom navi2ch-mona-face-variable t
  "*�ǥե���Ȥ� Mona face �����֡�"
  :type `(radio (const :tag "navi2ch-mona16-face"
                       :sample-face navi2ch-mona16-face
                       :doc ,navi2ch-mona-sample-string
                       :format "%t:\n%{%d%}\n"
                       navi2ch-mona16-face)
                (const :tag "navi2ch-mona14-face"
                       :sample-face navi2ch-mona14-face
                       :doc ,navi2ch-mona-sample-string
                       :format "%t:\n%{%d%}\n"
                       navi2ch-mona14-face)
                (const :tag "navi2ch-mona12-face"
                       :sample-face navi2ch-mona12-face
                       :doc ,navi2ch-mona-sample-string
                       :format "%t:\n%{%d%}\n"
                       navi2ch-mona12-face)
                (const :tag "�ǥե���ȤΥե���Ȥ�Ʊ���������� face ��ư���򤹤�"
                       t))
  :set (function (lambda (symbol value)
                   (set-default symbol value)
                   (navi2ch-mona-set-mona-face)))
  :initialize 'custom-initialize-default
  :group 'navi2ch-mona)

;; defun find-face for GNU Emacs
;; the code is originated from apel.
(unless (fboundp 'find-face)
    (defun find-face (face-or-name)
      "Retrieve the face of the given name.
If FACE-OR-NAME is a face object, it is simply returned.
Otherwise, FACE-OR-NAME should be a symbol.  If there is no such face,
nil is returned.  Otherwise the associated face object is returned."
      (car (memq face-or-name (face-list)))))

;; functions
(defun navi2ch-mona-set-mona-face ()
(let ((parent navi2ch-mona-face-variable))
  (when (eq t parent)
    (let* ((height (cond (navi2ch-on-xemacs
                          (font-height (face-font 'default)))
                         (navi2ch-on-emacs21
                          (frame-char-height))))
           (face-name (if height
                          (format "navi2ch-mona%d-face" height)
                        "navi2ch-mona16-face")))
      (setq parent (intern face-name))))
  (when (find-face parent)
    (cond (navi2ch-on-xemacs
           (set-face-parent 'navi2ch-mona-face parent))
          (navi2ch-on-emacs21
           (set-face-attribute 'navi2ch-mona-face nil
                               :inherit parent))))))

(defun navi2ch-mona-put-face ()
"face ���ä˻��ꤵ��Ƥ��ʤ���ʬ�� mona-face �ˤ��롣
`navi2ch-article-face' ����ʬ�� mona-face �ˤ��롣"
(save-excursion
  (goto-char (point-min))
  (let (p face)
    (while (not (eobp))
      (setq p (next-single-property-change (point)
                                           'face nil (point-max)))
      (setq face (get-text-property (point) 'face))
      (if (or (null face)
              (eq face 'navi2ch-article-face))
          (put-text-property (point) (1- p)
                             'face 'navi2ch-mona-face))
      (goto-char p)))))

(defun navi2ch-mona-pack-space ()
"Ϣ³����2�İʾ�ζ����1�ĤˤޤȤ�롣"
(save-excursion
  (goto-char (point-min))
  (while (re-search-forward "^ +" nil t)
    (replace-match ""))
  (goto-char (point-min))
  (while (re-search-forward"  +" nil t)
    (replace-match " "))))

(defun navi2ch-mona-arrange-message ()
"��ʡ��ե���Ȥ�Ȥ��Ĥʤ餽�Τ���δؿ���Ƥ֡�"
(let ((id (cdr (assq 'id navi2ch-article-current-board))))
  (when (or (member id navi2ch-mona-enable-board-list)
            (and (not (member id navi2ch-mona-disable-board-list))
                 navi2ch-mona-enable))
    (navi2ch-mona-put-face))
  (when navi2ch-mona-pack-space-p
    (navi2ch-mona-pack-space))))

(defun navi2ch-mona-setup ()
"*��ʡ��ե���Ȥ�Ȥ�����Υեå����ɲä��롣"
(add-hook 'navi2ch-article-arrange-message-hook
          'navi2ch-mona-arrange-message))

(defun navi2ch-mona-undo-setup ()
(remove-hook 'navi2ch-article-arrange-message-hook
             'navi2ch-mona-arrange-message))

(navi2ch-mona-set-mona-face)
(navi2ch-mona-setup)

(run-hooks 'navi2ch-mona-load-hook)
;;; navi2ch-mona.el ends here
