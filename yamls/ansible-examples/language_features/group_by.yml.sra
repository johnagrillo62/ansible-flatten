(playbook "ansible-examples/language_features/group_by.yml"
    (play
    (hosts "all")
    (tasks
      (task "Create a group of all hosts by operating system"
        (group_by "key=" (jinja "{{ansible_distribution}}") "-" (jinja "{{ansible_distribution_version}}")))))
    (play
    (hosts "CentOS-6.2")
    (tasks
      (task "ping all CentOS 6.2 hosts"
        (ping null))))
    (play
    (hosts "CentOS-6.3")
    (tasks
      (task "ping all CentOS 6.3 hosts"
        (ping null)))))
