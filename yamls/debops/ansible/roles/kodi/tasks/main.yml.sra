(playbook "debops/ansible/roles/kodi/tasks/main.yml"
  (tasks
    (task "Ensure specified packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", kodi__base_packages) }}"))
        (state (jinja "{{ \"present\" if (kodi__deploy_state == \"present\") else \"absent\" }}")))
      (register "kodi__register_packages")
      (until "kodi__register_packages is succeeded")
      (tags (list
          "role::kodi:pkgs")))
    (task "Create Kodi system group"
      (ansible.builtin.group 
        (name (jinja "{{ kodi__group }}"))
        (state (jinja "{{ \"present\" if (kodi__deploy_state == \"present\") else \"absent\" }}"))
        (system "True")))
    (task "Create Kodi system user"
      (ansible.builtin.user 
        (name (jinja "{{ kodi__user }}"))
        (group (jinja "{{ kodi__group }}"))
        (groups (jinja "{{ kodi__groups | join(\",\") | default(omit) }}"))
        (append "False")
        (home (jinja "{{ kodi__home_path }}"))
        (comment (jinja "{{ kodi__gecos }}"))
        (shell (jinja "{{ kodi__shell }}"))
        (state (jinja "{{ \"present\" if (kodi__deploy_state == \"present\") else \"absent\" }}"))
        (system "True")))
    (task "Create polkit configuration"
      (ansible.builtin.template 
        (src "etc/polkit-1/localauthority/50-local.d/kodi-actions.pkla.j2")
        (dest "/etc/polkit-1/localauthority/50-local.d/kodi-actions.pkla")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "kodi__polkit_action | d()"))
    (task "Remove polkit configuration"
      (ansible.builtin.file 
        (path "/etc/polkit-1/localauthority/50-local.d/kodi-actions.pkla")
        (state "absent"))
      (when "not kodi__polkit_action | d()"))))
