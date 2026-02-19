(playbook "debops/ansible/roles/nslcd/tasks/main.yml"
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
    (task "Configure pam-mkhomedir to create home directories"
      (ansible.builtin.template 
        (src "usr/share/pam-configs/mkhomedir.j2")
        (dest "/usr/share/pam-configs/mkhomedir")
        (mode "0644"))
      (register "nslcd__register_mkhomedir"))
    (task "Enable mkhomedir PAM module"
      (ansible.builtin.shell "pam-auth-update --package --remove mkhomedir 2>/dev/null && pam-auth-update --package --enable mkhomedir 2>/dev/null")
      (register "nslcd__register_pam_update")
      (changed_when "nslcd__register_pam_update.changed | bool")
      (when "nslcd__register_mkhomedir is changed"))
    (task "Install packages for nslcd support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", nslcd__base_packages + nslcd__packages) }}"))
        (state "present"))
      (register "nslcd__register_packages")
      (until "nslcd__register_packages is succeeded"))
    (task "Generate nslcd configuration"
      (ansible.builtin.template 
        (src "etc/nslcd.conf.j2")
        (dest "/etc/nslcd.conf")
        (group (jinja "{{ nslcd__group }}"))
        (mode "0640"))
      (register "nslcd__register_config")
      (when "nslcd__ldap_base_dn | d()"))
    (task "Restart nslcd if its configuration was modified"
      (ansible.builtin.service 
        (name "nslcd")
        (state "restarted"))
      (when "nslcd__register_config is changed"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save nslcd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/nslcd.fact.j2")
        (dest "/etc/ansible/facts.d/nslcd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
