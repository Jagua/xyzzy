; -*- Mode: Lisp; Package: EDITOR -*-
;
; thdnh-mode.l - �����e�����X�N���v�g���[�h
;

#| The MIT License : http://opensource.org/licenses/mit-license.php
Copyright (c) 2011 Jagua

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|#


; ��Author
;   Jagua
;
; ��Manifest
;   ���e���͈ȉ��̂Ƃ���D
;
;   thdnh-mode.l --- ����
;   ThDnh        --- �L�[���[�h�t�@�C��
;
; ��Install
;   thdnh-mode.l �� $XYZZY/site-lisp/ �ɃR�s�[����
;   ThDnh �� $XYZZY/etc/ �ɃR�s�[����
;
;   .xyzzy �܂��� siteinit.l �Ɉȉ���ǋL
;   (require "thdnh-mode")
;
;   �t�@�C����ǂݍ��ނƎ����œ����e�������[�h�Ɉڍs�����邽�߂�
;   �ȉ��́i���@�P�j�܂��́i���@�Q�j�̂����ꂩ�� (require "thdnh-mode") ��
;   ���̍s�ɑ����ď������Ƃ𐄏�����D
;
;�i���@�P�j
;;��s�ڂ��u#�����e�����v�������玩���œ����e�������[�h�Ɉڍs����
;;Magic Comment�𗘗p���� major-mode ��ݒ肷��
;(defvar *set-mode-from-magic-comment-alist* nil)
;
;(setq *set-mode-from-magic-comment-alist*
;      `(
;        ;("goruby" . ruby-mode)
;        ("^#�����e����$" . thdnh-mode)
;        ,@*set-mode-from-magic-comment-alist*))
;
;(defun set-mode-from-magic-comment ()
;  (interactive)
;  (let (
;        (thismode)
;        (firstline)
;        )
;    (save-excursion
;      (setq firstline (buffer-substring
;                       (point-min)
;                       (progn (goto-char (point-min))(goto-eol)(point))))
;      (setq thismode (cdr (assoc-if #'(lambda (a)
;                                        (string-match a firstline))
;                                    *set-mode-from-magic-comment-alist*)))
;      (and thismode (funcall thismode))
;      )))
;(add-hook '*find-file-hooks* 'set-mode-from-magic-comment)
;
;
;�i���@�Q�j
;;�w��t�H���_�ȉ��̃t�@�C����ǂݍ��񂾂玩���I�ɓ����e�������[�h�Ɉڍs����
;;��*thdnh-dir* �ɂ͓����e�������C���X�g�[�������t�H���_���ɏ��������邱��
;(setq *thdnh-dir* "C:/path/to/th_dnh")
;(defun thdnh-script-hook ()
;  (let* ((file (get-buffer-file-name))
;         (path (directory-namestring file)))
;    (when (string-match *thdnh-dir* path)
;      (thdnh-mode))))
;(add-hook '*find-file-hooks* 'thdnh-script-hook);
;
; ��ChageLog
;   Mon Oct 10 23:23:54 2011
;     Initial version
;
;
(provide "ThDnh-mode")

(defvar *thdnh-keyword*
  (compile-regexp-keyword-list
   '(
     ;("@[a-zA-Z]*"
     ("^#.*?$"     nil (:color  11))
     ("@[a-zA-Z]+" nil (:color  4))
     )))

(defvar *thdnh-mode-hook* nil)
(defvar *thdnh-mode-map* nil)
(unless *thdnh-mode-map*
  (setq *thdnh-mode-map* (make-sparse-keymap))
  (define-key *thdnh-mode-map* #\RET 'c-newline-and-indent)
  (define-key *thdnh-mode-map* #\TAB 'c-indent-line)
  (define-key *thdnh-mode-map* #\{ 'c-electric-insert)
  (define-key *thdnh-mode-map* #\} 'c-electric-close)
  (define-key *thdnh-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *thdnh-mode-map* #\C-M-q 'indent-sexp)
  (define-key *thdnh-mode-map* #\C-. 'thdnh-completion)

  )


(defvar *thdnh-mode-abbrev-table* nil)
(unless *thdnh-mode-abbrev-table*
  (define-abbrev-table '*thdnh-mode-abbrev-table*))



(defvar *thdnh-tab-always-indent* nil)
(defvar *thdnh-indent-tabs-mode* nil)
(defvar *thdnh-indent-column* 2)
(defvar *thdnh-continued-line-offset* 2)
(defvar *thdnh-brace-offset* -2)
(defvar *thdnh-brace-imaginary-offset* 0)
(defvar *thdnh-argdecl-indent* 0)
(defvar *thdnh-label-offset* 0)

(defvar *thdnh-keyword-hash-table* nil)
(defvar *thdnh-keyword-file* "ThDnh")
(defvar *thdnh-completion-list* nil)

(defvar *thdnh-mode-syntax-table* nil)
(unless *thdnh-mode-syntax-table*
  (setq *thdnh-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))
      ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
        (set-syntax-punctuation *thdnh-mode-syntax-table* c))))
  (set-syntax-string *thdnh-mode-syntax-table* #\")
  (set-syntax-start-c++-comment *thdnh-mode-syntax-table* #\/ t)
  (set-syntax-end-c++-comment *thdnh-mode-syntax-table* #\LFD)
  (set-syntax-match *thdnh-mode-syntax-table* #\( #\))
  (set-syntax-match *thdnh-mode-syntax-table* #\{ #\})
  (set-syntax-start-multi-comment *thdnh-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *thdnh-mode-syntax-table* "*/")
  )
 

(defun thdnh-completion ()
  "complete with keyword"
  (interactive)
  (or *thdnh-completion-list*
      (setq *thdnh-completion-list*
            (make-list-from-keyword-table *thdnh-keyword-hash-table*))
      (return-from thdnh-completion nil))
  (let ((opoint (point)))
    (when (skip-syntax-spec-backward "w_.")
      (let ((from (point)))
        (goto-char opoint)
        (do-completion from opoint :list *thdnh-completion-list*)))))

(defun thdnh-mode ()
  "�����e�����X�N���v�g�x�����[�h"
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'thdnh-mode)
  (setq mode-name "ThDnh")
  (and *thdnh-keyword-file*
       (null *thdnh-keyword-hash-table*)
       (setq *thdnh-keyword-hash-table*
             (load-keyword-file *thdnh-keyword-file* t)))
  (when *thdnh-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *thdnh-keyword-hash-table*))

  (use-keymap *thdnh-mode-map*)
  (setq *local-abbrev-table* *thdnh-mode-abbrev-table*)
  (use-syntax-table *thdnh-mode-syntax-table*)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *thdnh-keyword*)

  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *thdnh-indent-tabs-mode*)

  (make-local-variable 'mode-specific-indent-command)
  (make-local-variable 'c-comment-indent-variable)
  (setq mode-specific-indent-command 'c-indent-line)
  (setq c-comment-indent-variable 'c-comment-indent)

  (make-local-variable 'c-indent-level)
  (make-local-variable 'c-continued-statement-offset)
  (make-local-variable 'c-brace-offset)
  (make-local-variable 'c-brace-imaginary-offset)
  (make-local-variable 'c-argdecl-indent)
  (make-local-variable 'c-label-offset)

  (setq c-indent-level *thdnh-indent-column*)
  (setq c-continued-statement-offset *thdnh-continued-line-offset*)
  (setq c-brace-offset *thdnh-brace-offset*)
  (setq c-brace-imaginary-offset *thdnh-brace-imaginary-offset*)
  (setq c-argdecl-indent *thdnh-argdecl-indent*)
  (setq c-label-offset *thdnh-label-offset*)

  (run-hooks '*thdnh-mode-hook*))