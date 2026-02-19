(playbook "debops/ansible/roles/keepalived/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (keepalived__base_packages
                              + keepalived__packages)) }}"))
        (state "present"))
      (register "keepalived__register_packages")
      (until "keepalived__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save keepalived local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/keepalived.fact.j2")
        (dest "/etc/ansible/facts.d/keepalived.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Remove custom scripts from remote hosts if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/keepalived/\" + (item.dest | d(item.name)) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", keepalived__scripts
                           + keepalived__group_scripts
                           + keepalived__host_scripts) }}"))
      (when "item.state | d('present') == 'absent'"))
    (task "Copy custom scripts to remote hosts"
      (ansible.builtin.copy 
        (src (jinja "{{ item.src | d(omit) }}"))
        (dest (jinja "{{ \"/etc/keepalived/\" + (item.dest | d(item.name)) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0755\") }}")))
      (loop (jinja "{{ q(\"flattened\", keepalived__scripts
                           + keepalived__group_scripts
                           + keepalived__host_scripts) }}"))
      (when "item.state | d('present') not in ['absent', 'ignore']"))
    (task "Generate keepalive configuration file"
      (ansible.builtin.template 
        (src "etc/keepalived/keepalived.conf.j2")
        (dest "/etc/keepalived/keepalived.conf")
        (mode "0640"))
      (notify (list
          "Check keepalived configuration and reload")))))
