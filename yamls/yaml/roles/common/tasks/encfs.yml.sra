(playbook "yaml/roles/common/tasks/encfs.yml"
  (tasks
    (task "Install encfs & fuse"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "encfs"
          "fuse"
          "libfuse-dev"))
      (tags (list
          "dependencies")))
    (task "Create encrypted directory"
      (file "state=directory path=/encrypted"))
    (task "Check if the /encrypted directory is empty"
      (shell "ls /encrypted/*")
      (ignore_errors "True")
      (changed_when "False")
      (register "encfs_check"))
    (task "If /encrypted is empty, create the encfs there"
      (shell "printf \"p\\n" (jinja "{{ encfs_password }}") "\" | encfs /encrypted /decrypted --public --stdinpass && touch /decrypted/test")
      (when "encfs_check.rc > 0"))
    (task "If /encrypted isn't empty, mount it (but only if /decrypted/test doesn't exist)"
      (shell "printf '" (jinja "{{ encfs_password }}") "' | encfs /encrypted /decrypted --public --stdinpass creates=/decrypted/test")
      (when "encfs_check.rc == 0"))
    (task "Set decrypted directory permissions"
      (file "state=directory path=/decrypted group=mail mode=0775"))))
