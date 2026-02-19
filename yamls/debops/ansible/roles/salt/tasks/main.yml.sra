(playbook "debops/ansible/roles/salt/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install Salt Master packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (salt__base_packages
                              + salt__packages)) }}"))
        (state "present"))
      (register "salt__register_packages")
      (until "salt__register_packages is succeeded"))
    (task "Configure Salt Master using Ansible"
      (ansible.builtin.template 
        (src "etc/salt/master.d/ansible.conf.j2")
        (dest (jinja "{{ salt__configuration_file }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart salt-master"))
      (when "salt__configuration | bool"))
    (task "Remove Salt Master configuration file if disabled"
      (ansible.builtin.file 
        (path (jinja "{{ salt__configuration_file }}"))
        (state "absent"))
      (notify (list
          "Restart salt-master"))
      (when "not salt__configuration | bool"))))
