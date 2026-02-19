(playbook "debops/ansible/roles/persistent_paths/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Configure QubesOS environment"
      (block (list
          
          (name "Ensure the qubes-bind-dirs.d directory does exist")
          (ansible.builtin.file 
            (path (jinja "{{ persistent_paths__qubes_os_config_dir }}"))
            (state "directory")
            (owner "root")
            (group "root")
            (mode "0750"))
          
          (name "Configuration persistent paths on Qubes OS")
          (ansible.builtin.template 
            (src "rw/config/qubes-bind-dirs.d/default.conf.j2")
            (dest (jinja "{{ persistent_paths__qubes_os_config_dir + \"/\" + item.key + \".conf\" }}"))
            (owner "root")
            (group "root")
            (mode "0644"))
          (when "(item.value.state | d(\"present\") == \"present\")")
          (with_dict (jinja "{{ persistent_paths__combined_paths }}"))
          (notify (list
              "Run bind-dirs"))
          
          (name "Remove configuration of persistent paths on Qubes OS")
          (ansible.builtin.file 
            (path (jinja "{{ persistent_paths__qubes_os_config_dir + \"/\" + item.key + \".conf\" }}"))
            (state "absent"))
          (when "(item.value.state | d(\"present\") == \"absent\")")
          (with_dict (jinja "{{ persistent_paths__combined_paths }}"))
          (notify (list
              "Run bind-dirs"))))
      (when "persistent_paths__qubes_os_enabled | bool")
      (tags (list
          "role::persistent_paths:qubes_os")))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create local facts of persistent_paths"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/persistent_paths.fact.j2")
        (dest "/etc/ansible/facts.d/persistent_paths.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
