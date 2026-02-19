(playbook "debops/ansible/roles/nscd/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", nscd__base_packages + nscd__packages) }}"))
        (state "present"))
      (register "nscd__register_packages")
      (until "nscd__register_packages is succeeded"))
    (task "Divert the nscd configuration file"
      (debops.debops.dpkg_divert 
        (path "/etc/nscd.conf")))
    (task "Generate nscd configuration"
      (ansible.builtin.template 
        (src "etc/nscd.conf.j2")
        (dest "/etc/nscd.conf")
        (mode "0644"))
      (register "nscd__register_config"))
    (task "Restart nscd if its configuration was modified"
      (ansible.builtin.service 
        (name (jinja "{{ nscd__flavor }}"))
        (state "restarted"))
      (when "nscd__register_config is changed"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save nscd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/nscd.fact.j2")
        (dest "/etc/ansible/facts.d/nscd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
