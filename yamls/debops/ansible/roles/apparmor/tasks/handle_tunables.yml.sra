(playbook "debops/ansible/roles/apparmor/tasks/handle_tunables.yml"
  (tasks
    (task "Remove tunable " (jinja "{{ item.name }}")
      (debops.debops.dpkg_divert 
        (path (jinja "{{ \"/etc/apparmor.d/tunables/\" + item.name }}"))
        (state "absent")
        (delete "True"))
      (when "item.state | d(\"present\") == \"absent\"")
      (notify (list
          "Reload all AppArmor profiles"))
      (tags (list
          "role::apparmor:tunables")))
    (task "Divert tunable " (jinja "{{ item.name }}")
      (debops.debops.dpkg_divert 
        (path (jinja "{{ \"/etc/apparmor.d/tunables/\" + item.name }}"))
        (state "present")
        (delete "True"))
      (when "item.state | d(\"present\") == \"present\"")
      (notify (list
          "Reload all AppArmor profiles"))
      (tags (list
          "role::apparmor:tunables")))
    (task "Create base directory for tunable " (jinja "{{ item.name }}")
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/apparmor.d/tunables/\" + item.name | dirname }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when (list
          "item.state | d(\"present\") == \"present\""
          "item.name | dirname != \"\""))
      (tags (list
          "role::apparmor:tunables")))
    (task "Create tunable " (jinja "{{ item.name }}")
      (ansible.builtin.template 
        (src "etc/apparmor.d/snippet.j2")
        (dest (jinja "{{ \"/etc/apparmor.d/tunables/\" + item.name }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (vars 
        (apparmor__var_template_title "AppArmor tunable")
        (apparmor__var_template_suffix "")
        (apparmor__var_template_operator "="))
      (when "item.state | d(\"present\") == \"present\"")
      (notify (list
          "Reload all AppArmor profiles"))
      (tags (list
          "role::apparmor:tunables")))))
