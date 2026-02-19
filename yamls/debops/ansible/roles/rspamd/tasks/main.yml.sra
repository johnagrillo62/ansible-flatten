(playbook "debops/ansible/roles/rspamd/tasks/main.yml"
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
    (task "Install rspamd packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (rspamd__base_packages
                              + rspamd__packages)) }}"))
        (state "present"))
      (register "rspamd__register_packages")
      (until "rspamd__register_packages is succeeded")
      (tags (list
          "role::rspamd:pkg")))
    (task "Make sure that the Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save rspamd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/rspamd.fact.j2")
        (dest "/etc/ansible/facts.d/rspamd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Create configuration directories and files"
      (ansible.builtin.include_tasks "main_cfgdir.yml")
      (loop (list
          
          (path "/etc/rspamd/local.d")
          (config (jinja "{{ rspamd__combined_local_configuration
                       | debops.debops.parse_kv_items(name=\"file\") }}"))
          
          (path "/etc/rspamd/override.d")
          (config (jinja "{{ rspamd__combined_override_configuration
                       | debops.debops.parse_kv_items(name=\"file\") }}"))))
      (loop_control 
        (loop_var "cfgdir")
        (label (jinja "{{ cfgdir.path }}"))))
    (task "Handle DKIM configuration"
      (ansible.builtin.include_tasks "main_dkim.yml"))
    (task "Update Ansible facts and restart Rspamd if necessary"
      (ansible.builtin.meta "flush_handlers"))))
