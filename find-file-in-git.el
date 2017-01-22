(defun find-file-in-git (file-name)
  "Looks for a file in the current Git repository.

FILE-NAME - the search criteria: a part of the file name.

If only one file meets the criteria, it will be opened. If there
are several such files, a list with them will be displayed."
  (interactive "MFind file: ")
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
