(defun find-file-in-git (file-name)
  "Looks for a file in the current Git repository.

FILE-NAME - the search criteria: a part of the file name.

If only one file meets the criteria, it will be opened. If there
are several such files, a list with them will be displayed."
  (interactive (find-file-in-git/prompt-file-name-at-point "Find file"))
  (let ((git-root (find-file-in-git/get-git-root default-directory))
        files-buf num-of-files)
    (set 'files-buf (find-file-in-git/find file-name git-root))
    (set-buffer files-buf)
    (set 'num-of-files (count-lines (point-min) (point-max)))
    (cond
     ((= num-of-files 1)
      (find-file (buffer-substring (point-min) (- (point-max) 1)))
      (kill-buffer files-buf))
     ((> num-of-files 1)
      (set-window-buffer (selected-window) files-buf)
      (goto-char (point-min)))
     ((= num-of-files 0)
      (kill-buffer files-buf)
      (message "The file \"%s\" was not found in the \"%s\" repository."
               file-name git-root)))))


(defun find-file-in-git/find (file-name git-root)
  "Looks for a file with name FILE-NAME in the Git repository
with the root directory in GIT-ROOT.

Returns a buffer with list of files."
  (let ((files-buf (get-buffer-create "find-file-in-git: Files")))
    (save-excursion
      (set-buffer files-buf)
      (erase-buffer)
      (set 'default-directory git-root)
      (call-process "git" nil files-buf nil
                    "ls-files"
                    (concat "*" file-name "*")))
    files-buf))


(defun find-file-in-git/get-git-root (dir)
  "Returns the root directory of a Git repository (the directory
that contains '.git' directory) the directory DIR belongs to."
  (if (file-exists-p (expand-file-name ".git" dir))
      dir
    (find-file-in-git/get-git-root (expand-file-name "../" dir))))


(defun find-file-in-git/prompt-file-name-at-point (prompt)
  "Extracts a short file name from a context.

This function must be used by interactive functions.

PROMPT is a string to prompt with. It is shown to the user before
the input field in the minibuffer."
  (let ((template "[^A-aZ-z0-9_.-]")
        start end file-name)
    (save-excursion
      (if (re-search-backward template nil t)
          (forward-char)
        (goto-char (point-min)))
      (set 'start (point))
      (if (re-search-forward template nil t)
          (backward-char)
        (goto-char (point-max)))
      (set 'end (point)))
    (set 'file-name (buffer-substring start end))
    (set 'prompt (concat prompt
                         (unless (string= file-name "")
                           (concat " (" file-name ")"))
                         ": "))
    (list (completing-read prompt nil nil nil nil nil file-name))))


;; Customization
(defun find-file-in-git/set-customization (option value)
  "Customizes find-file-in-git package behaviour.

OPTION - the name of an option (a symbol) that was changed by
  means of the customization interface.
VALUE - the value to be set for this option."
  (cond
   ((eq option 'find-file-in-git/key-binding/find)
    (if (boundp 'find-file-in-git/key-binding/find)
        (define-key global-map find-file-in-git/key-binding/find nil))
    (set 'find-file-in-git/key-binding/find value)
    (define-key global-map find-file-in-git/key-binding/find 'find-file-in-git))))


(defcustom find-file-in-git/key-binding/find "\C-x\M-a"
  "Key sequence that is used to find a file in the current git
repository (executes function `find-file-in-git`).

The current repository is the one that contains the directory
from the buffer local variable `default-directory`."
  :tag "Find File in Git Key Binding"
  :type 'key-sequence
  :set 'find-file-in-git/set-customization)


(provide 'find-file-in-git)
