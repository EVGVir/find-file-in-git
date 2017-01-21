(defun find-file-in-git (file-name)
  "Looks for a file in the current Git repository.

FILE-NAME - the search criteria: a part of the file name.

A list with files that met criteria is displayed."
  (interactive "MFind file: ")
  (let ((git-root (find-file-in-git/get-git-root default-directory))
        files-buf)
    (set 'files-buf (find-file-in-git/find file-name git-root))
    (set-window-buffer (selected-window) files-buf)))


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
