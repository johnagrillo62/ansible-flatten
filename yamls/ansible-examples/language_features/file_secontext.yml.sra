(playbook "ansible-examples/language_features/file_secontext.yml"
    (play
    (hosts "test")
    (remote_user "root")
    (tasks
      (task "Change setype of /etc/exports to non-default value"
        (file "path=/etc/exports setype=etc_t"))
      (task "Change seuser of /etc/exports to non-default value"
        (file "path=/etc/exports seuser=unconfined_u"))
      (task "Set selinux context back to default value"
        (file "path=/etc/exports context=default"))
      (task "Create empty file"
        (command "/bin/touch /tmp/foo"))
      (task "Change setype of /tmp/foo"
        (file "path=/tmp/foo setype=default_t"))
      (task "Try to set secontext to default, but this will fail because of the lack of a default in the policy"
        (file "path=/tmp/foo context=default")))))
