(playbook "debops/ansible/roles/tgt/tasks/main.yml"
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
    (task "DebOps pre_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"tgt/pre_main.yml\") }}")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", tgt_packages) }}"))
        (state "present"))
      (register "tgt__register_packages")
      (until "tgt__register_packages is succeeded"))
    (task "Configure tgt global options"
      (ansible.builtin.template 
        (src "etc/tgt/conf.d/00_tgt_options.conf.j2")
        (dest "/etc/tgt/conf.d/00_tgt_options.conf")
        (owner "root")
        (group "root")
        (mode "0600"))
      (notify (list
          "Reload tgt")))
    (task "Remove iSCSI targets if requested"
      (ansible.builtin.file 
        (path "/etc/tgt/conf.d/" (jinja "{{ item.filename | default(item.name) }}") ".conf")
        (state "absent"))
      (with_items (jinja "{{ tgt_targets }}"))
      (notify (list
          "Reload tgt"))
      (when "((item.name is defined and item.name) and (item.delete is defined and item.delete))"))
    (task "Configure iSCSI targets"
      (ansible.builtin.template 
        (src "etc/tgt/conf.d/target.conf.j2")
        (dest "/etc/tgt/conf.d/" (jinja "{{ item.filename | default(item.name) }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0600"))
      (with_items (jinja "{{ tgt_targets }}"))
      (notify (list
          "Reload tgt"))
      (when "((item.name is defined and item.name) and (item.delete is undefined or not item.delete))"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save iSCSI Target facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/tgt.fact.j2")
        (dest "/etc/ansible/facts.d/tgt.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags (list
          "meta::facts")))
    (task "DebOps post_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"tgt/post_main.yml\") }}")))))
