(playbook "debops/ansible/roles/sssd/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Configure pam-mkhomedir to create home directories"
      (ansible.builtin.template 
        (src "usr/share/pam-configs/mkhomedir.j2")
        (dest "/usr/share/pam-configs/mkhomedir")
        (mode "0644"))
      (register "sssd__register_mkhomedir"))
    (task "Enable mkhomedir PAM module"
      (ansible.builtin.shell "pam-auth-update --package --remove mkhomedir 2>/dev/null && pam-auth-update --package --enable mkhomedir 2>/dev/null")
      (register "sssd__register_pam_update")
      (changed_when "sssd__register_pam_update.changed | bool")
      (when "sssd__register_mkhomedir is changed"))
    (task "Install packages for sssd support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", sssd__base_packages + sssd__packages) }}"))
        (state "present"))
      (register "sssd__register_packages")
      (until "sssd__register_packages is succeeded"))
    (task "Generate sssd configuration"
      (ansible.builtin.template 
        (src "etc/sssd/sssd.conf.j2")
        (dest "/etc/sssd/sssd.conf")
        (mode "0600"))
      (register "sssd__register_config")
      (when "sssd__ldap_base_dn | d()"))
    (task "Restart sssd if its configuration was modified"
      (ansible.builtin.service 
        (name "sssd")
        (state "restarted"))
      (when "sssd__register_config is changed"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save sssd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/sssd.fact.j2")
        (dest "/etc/ansible/facts.d/sssd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
