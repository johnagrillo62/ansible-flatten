(playbook "debops/ansible/roles/sudo/tasks/main.yml"
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
    (task "Configure access to LDAP directory"
      (ansible.builtin.template 
        (src "etc/sudo-ldap.conf.j2")
        (dest "/etc/sudo-ldap.conf")
        (mode "0440"))
      (when "sudo__enabled | bool and sudo__ldap_enabled | bool"))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (sudo__base_packages
                              + sudo__packages)) }}"))
        (state "present"))
      (environment 
        (SUDO_FORCE_REMOVE "yes"))
      (register "sudo__register_packages")
      (until "sudo__register_packages is succeeded")
      (when "sudo__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save sudo local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/sudo.fact.j2")
        (dest "/etc/ansible/facts.d/sudo.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Ensure that '/etc/sudoers' includes '/etc/sudoers.d'"
      (ansible.builtin.lineinfile 
        (dest "/etc/sudoers")
        (regexp "^(?:@|#)includedir\\s+\\/etc\\/sudoers.d$")
        (line (jinja "{{ (\"#\"
               if ansible_local.sudo.version | d(\"0.0.0\") is version(\"1.9.1\", \"<\")
               else \"@\") + \"includedir /etc/sudoers.d\" }}"))
        (insertafter "EOF")
        (state "present")
        (validate "visudo -cf \"%s\"")
        (mode "0440"))
      (when "sudo__enabled | bool and not ansible_check_mode | bool"))
    (task "Remove sudoers configuration if requested"
      (ansible.builtin.file 
        (path "/etc/sudoers.d/" (jinja "{{ item.filename | d(item.name) }}"))
        (state "absent"))
      (with_items (jinja "{{ sudo__combined_sudoers | flatten | debops.debops.parse_kv_items }}"))
      (notify (list
          "Refresh host facts"))
      (when "sudo__enabled | bool and item.name | d() and item.state | d('present') == 'absent'"))
    (task "Configure sudoers"
      (ansible.builtin.template 
        (src "etc/sudoers.d/config.j2")
        (dest "/etc/sudoers.d/" (jinja "{{ item.filename | d(item.name) }}"))
        (owner "root")
        (group "root")
        (mode "0440")
        (validate "visudo -cf %s"))
      (with_items (jinja "{{ sudo__combined_sudoers | flatten | debops.debops.parse_kv_items }}"))
      (notify (list
          "Refresh host facts"))
      (when "sudo__enabled | bool and item.name | d() and item.state | d('present') not in ['init', 'absent', 'ignore']"))
    (task "Configure workaround for logind sessions via sudo"
      (ansible.builtin.template 
        (src "etc/profile.d/sudo_logind_session.sh.j2")
        (dest "/etc/profile.d/sudo_logind_session.sh")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "sudo__enabled | bool and sudo__logind_session | bool"))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
