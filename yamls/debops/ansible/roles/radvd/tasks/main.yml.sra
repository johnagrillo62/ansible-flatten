(playbook "debops/ansible/roles/radvd/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install radvd support"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (radvd__base_packages
                              + radvd__packages)) }}"))
        (state "present"))
      (register "radvd__register_packages")
      (until "radvd__register_packages is succeeded"))
    (task "Generate radvd configuration"
      (ansible.builtin.template 
        (src "etc/radvd.conf.j2")
        (dest "/etc/radvd.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Test radvd and restart")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save radvd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/radvd.fact.j2")
        (dest "/etc/ansible/facts.d/radvd.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
