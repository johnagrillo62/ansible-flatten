(playbook "debops/ansible/roles/journald/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save journald local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/journald.fact.j2")
        (dest "/etc/ansible/facts.d/journald.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret"))
      (vars 
        (secret__directories (list
            (jinja "{{ (journald__fss_verify_key_path | dirname)
            if journald__fss_enabled | bool
            else [] }}")))))
    (task "Move persistent journal to volatile storage if requested"
      (ansible.builtin.command "journalctl --relinquish-var")
      (register "journald__register_relinquish_var")
      (changed_when "journald__register_relinquish_var.changed | bool")
      (when "(journald__enabled | bool and journald__version is version(\"244\", \">=\") and journald__persistent_state == 'absent' and (ansible_local.journald.persistent | d(False)) | bool)"))
    (task "Remove persistent journal storage if requested"
      (ansible.builtin.file 
        (path "/var/log/journal")
        (state "absent"))
      (when "journald__enabled | bool and journald__storage in ['auto', 'none', 'volatile'] and journald__persistent_state == 'absent'"))
    (task "Create persistent journal storage directory"
      (ansible.builtin.file 
        (path "/var/log/journal/" (jinja "{{ ansible_machine_id }}"))
        (state "directory")
        (group "systemd-journal")
        (mode "2755"))
      (register "journald__register_persistent")
      (when "journald__enabled | bool and journald__storage in ['auto', 'persistent'] and journald__persistent_state != 'absent'"))
    (task "Apply extended permissions in the persistent storage"
      (ansible.builtin.command "systemd-tmpfiles --create --prefix /var/log/journal")
      (changed_when "False")
      (when "journald__enabled | bool and journald__storage in ['auto', 'persistent'] and journald__persistent_state != 'absent'"))
    (task "Create Forward Secure Seal keys when requested"
      (ansible.builtin.command "journalctl --setup-keys --interval=" (jinja "{{ journald__fss_interval }}"))
      (register "journald__register_fss")
      (changed_when "journald__register_fss.stderr_lines | count > 1")
      (when "(journald__enabled | bool and journald__storage in ['auto', 'persistent'] and journald__persistent_state != 'absent' and journald__fss_enabled | bool and (not ansible_local.journald.sealed | d()) | bool)"))
    (task "Save Forward Secure Seal verification key on Ansible Controller"
      (ansible.builtin.copy 
        (content (jinja "{{ journald__register_fss.stdout }}"))
        (dest (jinja "{{ secret + \"/\" + journald__fss_verify_key_path }}"))
        (mode "0600"))
      (delegate_to "localhost")
      (become "False")
      (when "journald__register_fss is changed"))
    (task "Flush journal to persistent storage"
      (ansible.builtin.systemd 
        (name "systemd-journal-flush.service")
        (state "restarted"))
      (when "journald__enabled | bool and journald__persistent_state != 'absent' and journald__register_persistent is changed"))
    (task "Create journald configuration directory"
      (ansible.builtin.file 
        (path "/etc/systemd/journald.conf.d")
        (state "directory")
        (mode "0755"))
      (when "journald__enabled | bool"))
    (task "Generate journald configuration"
      (ansible.builtin.template 
        (src "etc/systemd/journald.conf.d/ansible.conf.j2")
        (dest "/etc/systemd/journald.conf.d/ansible.conf")
        (mode "0644"))
      (register "journald__register_config")
      (when "journald__enabled | bool"))
    (task "Restart journald if its configuration was modified"
      (ansible.builtin.service 
        (name "systemd-journald")
        (state "restarted"))
      (when "journald__enabled | bool and journald__register_config is changed"))
    (task "Verify journal logs using FSS when requested"
      (ansible.builtin.command "journalctl --verify --verify-key=\"" (jinja "{{ journald__fss_verify_key }}") "\"")
      (register "journald__register_fss_verify")
      (when "journald__enabled | bool and journald__persistent_state != 'absent'")
      (changed_when "False")
      (tags (list
          "never"
          "role::journald:fss:verify")))))
