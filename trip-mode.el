;;; trip-mode.el --- Add relative timestamps to every paragraph

;; Idea: 2013, V. Pavlenko
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(defcustom trip-timestamp-format
  "T+%.2h:%.2m:%.2s "
  "Specifies the format of timestamp. Refer to format-seconds documentation.")

(defcustom trip-start-date-format
  "%F %T%:::z"
  "Specifies the format of timestamp for the greeting.")

(defcustom trip-greeting-format
  "Triplog: starting new trip at %s"
  "Format of the first line where '%s' is a trip-start-date-format'd timestamp.")

(setq trip-survey "\nDose:\nAge:\nBody weight:\n")

(setq trip-highlights
      '(("^T\\+[^ ]*" . font-lock-variable-name-face)
	("^.*$:" . font-lock-keyword-face)))

(make-variable-buffer-local 'trip-start)

(defun trip-insert-timestamp ()
  (interactive)
  (let ((time-delta (time-subtract (current-time)
				   trip-start)))
    (insert (format-seconds trip-timestamp-format
			    time-delta))))
(defun trip-block-p ()
  (and (bolp)
       (eq (char-before (- (point) 1))
	     10)))

(defun trip-newline ()
  (interactive)
  (let ((trip-mode nil))
    (call-interactively (key-binding (kbd "RET"))))
  (if (trip-block-p)
      (trip-insert-timestamp)))

(defun trip-greet ()
  (message "Happy cycling!")
  (let* ((start-date (format-time-string trip-start-date-format trip-start))
	 (trip-greeting (format trip-greeting-format start-date)))
    (insert trip-greeting trip-survey)))

(defun trip-into-trip ()
  (interactive)
  (switch-to-buffer (generate-new-buffer "*Trip*"))
  (text-mode) (trip-mode))

(define-minor-mode trip-mode
  "Add relative timestamps to every paragraph"
  :lighter "Trip"
  :keymap (let ((map (make-sparse-keymap)))
	    (define-key map (kbd "RET") 'trip-newline)
	    map)
  (if (bobp) (trip-greet))

  (setq trip-start
	(let* ((first-line
		(save-excursion
		  (goto-line 1)
		  (buffer-substring-no-properties(line-beginning-position)
						 (line-end-position))))
	       (parsed-time (parse-time-string first-line)))
	  (if (car parsed-time)
	      (if (last parsed-time) parsed-time)
	    (current-time))))

  (prin1 trip-start)
  
  (font-lock-add-keywords nil trip-highlights)
  (if (fboundp 'font-lock-flush)
      (font-lock-flush)
    (when font-lock-mode
      (with-no-warnings (font-lock-fontify-buffer)))))

(provide 'trip-mode)

;; trip-mode.el ends here
