(playbook "debops/ansible/roles/apparmor/tasks/handle_locals.yml"
  (tasks
    (task "Create base directory for local modification " (jinja "{{ item.name }}")
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/apparmor.d/local/\" + item.name | dirname }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when (list
          "item.state | d(\"present\") == \"present\""
          "item.name | dirname != \"\""))
      (tags (list
          "role::apparmor:locals")))
    (task "Create local modification " (jinja "{{ item.name }}")
      (ansible.builtin.template 
        (src "etc/apparmor.d/snippet.j2")
        (dest (jinja "{{ \"/etc/apparmor.d/local/\" + item.name }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "item.state | d(\"present\") == \"present\"")
      (vars 
        (apparmor__var_template_title "AppArmor local modification")
        (apparmor__var_template_suffix ",")
        (apparmor__var_template_operator " "))
      (notify (list
          "Reload all AppArmor profiles"))
      (tags (list
          "role::apparmor:locals")))
    (task "Check the presence of profile " (jinja "{{ item.name }}")
      (ansible.builtin.stat 
        (path (jinja "{{ \"/etc/apparmor.d/\" + item.name }}")))
      (register "apparmor__register_local_profile")
      (when "item.state | d(\"present\") == \"absent\"")
      (tags (list
          "role::apparmor:locals")))
    (task "Truncate local modification " (jinja "{{ item.name }}")
      (ansible.builtin.copy 
        (dest (jinja "{{ \"/etc/apparmor.d/local/\" + item.name }}"))
        (content "")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when (list
          "item.state | d(\"present\") == \"absent\""
          "apparmor__register_local_profile.stat.exists | d(False)"))
      (notify (list
          "Reload all AppArmor profiles"))
      (tags (list
          "role::apparmor:locals")))
    (task "Remove local modification " (jinja "{{ item.name }}")
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/apparmor.d/local/\" + item.name }}"))
        (state "absent"))
      (when (list
          "item.state | d(\"present\") == \"absent\""
          "not apparmor__register_local_profile.stat.exists | d(False)"))
      (notify (list
          "Reload all AppArmor profiles"))
      (tags (list
          "role::apparmor:locals")))))
