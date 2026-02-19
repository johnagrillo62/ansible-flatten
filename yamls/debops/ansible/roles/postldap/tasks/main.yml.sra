(playbook "debops/ansible/roles/postldap/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Make sure required POSIX group exist"
      (ansible.builtin.group 
        (name (jinja "{{ postldap__vmail_posix_group |
              d(postldap__vmail_posix_user) }}"))
        (state "present")
        (system "True"))
      (tags (list
          "role::postldap:user"
          "role::postldap:group")))
    (task "Make sure required POSIX system account exist"
      (ansible.builtin.user 
        (name (jinja "{{ postldap__vmail_posix_user }}"))
        (state "present")
        (comment "Postfix Virtual Mail user")
        (group (jinja "{{ postldap__vmail_posix_group |
               d(postldap__vmail_posix_user) }}"))
        (home (jinja "{{ postldap__mailbox_base }}"))
        (create_home "True")
        (system "True")
        (shell "/usr/sbin/nologin")
        (skeleton null))
      (tags (list
          "role::postldap:user")))
    (task "Create vmail home directory " (jinja "{{ postldap__mailbox_base }}")
      (ansible.builtin.file 
        (dest (jinja "{{ postldap__mailbox_base }}"))
        (state "directory")
        (owner (jinja "{{ postldap__vmail_posix_user }}"))
        (group (jinja "{{ postldap__vmail_posix_group }}"))
        (mode "0750"))
      (tags (list
          "role::postldap:user")))
    (task "Make sure Ansible local facts directory exists"
      (ansible.builtin.file 
        (dest "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Configure PostLDAP local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/postldap.fact.j2")
        (dest "/etc/ansible/facts.d/postldap.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
