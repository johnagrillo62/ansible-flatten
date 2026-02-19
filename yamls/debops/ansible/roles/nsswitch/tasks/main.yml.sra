(playbook "debops/ansible/roles/nsswitch/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save nsswitch local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/nsswitch.fact.j2")
        (dest "/etc/ansible/facts.d/nsswitch.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Generate Name Service Switch configuration"
      (ansible.builtin.template 
        (src "etc/nsswitch.conf.j2")
        (dest "/etc/nsswitch.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (register "nsswitch__register_config")
      (when "nsswitch__enabled | bool"))
    (task "Restart systemd-logind to fix NSS lookups"
      (ansible.builtin.service 
        (name "systemd-logind")
        (state "restarted"))
      (when "ansible_service_mgr == 'systemd' and nsswitch__register_config is changed and ansible_connection != 'local'"))))
