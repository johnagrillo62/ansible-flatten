(playbook "debops/ansible/roles/libuser/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install Libuser requested packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", libuser__base_packages
                             + libuser__packages) }}"))
        (state "present"))
      (register "libuser__register_packages")
      (until "libuser__register_packages is succeeded")
      (when "libuser__enabled | bool"))
    (task "Divert the original libuser configuration file"
      (debops.debops.dpkg_divert 
        (path "/etc/libuser.conf"))
      (when "libuser__enabled | bool"))
    (task "Configure main libuser config file"
      (ansible.builtin.template 
        (src "etc/libuser.conf.j2")
        (dest "/etc/libuser.conf")
        (mode "0644"))
      (when "libuser__enabled | bool"))
    (task "Make sure that local fact directory exists"
      (ansible.builtin.file 
        (dest "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Libuser local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/libuser.fact.j2")
        (dest "/etc/ansible/facts.d/libuser.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
