(playbook "debops/ansible/roles/apt_cacher_ng/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Disable autoconfiguration"
      (ansible.builtin.debconf 
        (name "apt-cacher-ng")
        (question "apt-cacher-ng/gentargetmode")
        (vtype "select")
        (value "No automated setup"))
      (when "apt_cacher_ng__deploy_state == 'present'"))
    (task "Add/remove configuration file diversions"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item.path }}"))
        (state (jinja "{{ \"present\" if apt_cacher_ng__deploy_state == \"present\"
               else \"absent\" }}"))
        (delete "True"))
      (loop (jinja "{{ apt_cacher_ng__configuration_files }}"))
      (when "item.divert | d(True)"))
    (task "Install/remove packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", apt_cacher_ng__base_packages) }}"))
        (state (jinja "{{ \"present\" if apt_cacher_ng__deploy_state == \"present\"
               else \"absent\" }}")))
      (register "apt_cacher_ng__register_packages")
      (until "apt_cacher_ng__register_packages is succeeded"))
    (task "Generate configuration files"
      (ansible.builtin.template 
        (src (jinja "{{ item.src | d(item.path | regex_replace(\"^/\", \"\")) }}") ".j2")
        (dest (jinja "{{ item.path }}"))
        (owner (jinja "{{ item.owner | d(\"root\") }}"))
        (group (jinja "{{ item.group | d(\"root\") }}"))
        (mode (jinja "{{ item.mode | d(\"0640\") }}")))
      (loop (jinja "{{ apt_cacher_ng__configuration_files }}"))
      (notify (list
          "Restart apt-cacher-ng"))
      (when "apt_cacher_ng__deploy_state == 'present'"))
    (task "Create the cache directory"
      (ansible.builtin.file 
        (state "directory")
        (path (jinja "{{ apt_cacher_ng__cache_dir }}"))
        (owner (jinja "{{ apt_cacher_ng__cache_dir_owner }}"))
        (group (jinja "{{ apt_cacher_ng__cache_dir_group }}"))
        (mode (jinja "{{ apt_cacher_ng__dir_perms }}")))
      (when "apt_cacher_ng__deploy_state == 'present'"))
    (task "Lazy check cache directory permissions"
      (ansible.builtin.file 
        (state "file")
        (path (jinja "{{ apt_cacher_ng__cache_dir }}") "/_expending_damaged")
        (owner (jinja "{{ apt_cacher_ng__cache_dir_owner }}"))
        (group (jinja "{{ apt_cacher_ng__cache_dir_group }}"))
        (mode (jinja "{{ apt_cacher_ng__file_perms }}")))
      (failed_when "False")
      (register "apt_cacher_ng__register_cache_perms")
      (when "(apt_cacher_ng__deploy_state == 'present' and apt_cacher_ng__cache_dir_enforce_permissions == 'lazy')"))
    (task "Change cache directory permissions"
      (ansible.builtin.shell "chown --recursive " (jinja "{{ apt_cacher_ng__cache_dir_owner }}") ":" (jinja "{{ apt_cacher_ng__cache_dir_group }}") " .
find . -type d -exec chmod " (jinja "{{ apt_cacher_ng__dir_perms }}") " {} \\;
find . -type f -exec chmod " (jinja "{{ apt_cacher_ng__file_perms }}") " {} \\;
")
      (args 
        (chdir (jinja "{{ apt_cacher_ng__cache_dir }}")))
      (register "apt_cacher_ng__register_chmod")
      (changed_when "apt_cacher_ng__register_chmod.changed | bool")
      (when "(apt_cacher_ng__deploy_state == 'present' and (apt_cacher_ng__cache_dir_enforce_permissions == \"strict\" or (apt_cacher_ng__cache_dir_enforce_permissions == \"lazy\" and apt_cacher_ng__register_cache_perms is changed)))"))
    (task "Enable/disable service"
      (ansible.builtin.service 
        (name "apt-cacher-ng")
        (state (jinja "{{ \"started\" if apt_cacher_ng__enabled | d(True) else \"stopped\" }}"))
        (enabled (jinja "{{ True if apt_cacher_ng__enabled | d(True) else False }}")))
      (when "apt_cacher_ng__deploy_state == 'present'"))
    (task "Remove configuration files"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "absent"))
      (loop (jinja "{{ apt_cacher_ng__configuration_files }}"))
      (when "(apt_cacher_ng__deploy_state in ['absent', 'purge'] and not item.divert | d(True))"))
    (task "Remove the cache directory"
      (ansible.builtin.file 
        (path (jinja "{{ apt_cacher_ng__cache_dir }}"))
        (state "absent"))
      (when "apt_cacher_ng__deploy_state == 'purge'"))))
