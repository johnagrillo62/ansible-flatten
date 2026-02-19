(playbook "debops/ansible/roles/apt/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "debops.debops.global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "debops.debops.secret")))
    (task "Validate configuration of APT repositories"
      (ansible.builtin.assert 
        (that (list
            "item.filename is defined"
            "item.repo is defined or item.uris is defined or item.state in [\"divert\", \"absent\"]"))
        (fail_msg "You need to specify \"filename\" and either \"repo\" or \"uris\" as parameters")
        (quiet "True"))
      (loop (jinja "{{ apt__combined_repositories | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ item.name }}"))))
    (task "Configure custom APT keys"
      (ansible.builtin.apt_key 
        (data (jinja "{{ item.data | d(omit) }}"))
        (file (jinja "{{ item.file | d(omit) }}"))
        (id (jinja "{{ item.id | d(omit) }}"))
        (keyring (jinja "{{ item.keyring | d(omit) }}"))
        (keyserver (jinja "{{ item.keyserver | d(omit) }}"))
        (url (jinja "{{ item.url | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ q(\"flattened\", apt__keys
                           + apt__group_keys
                           + apt__host_keys) }}"))
      (register "apt__register_apt_key")
      (until "apt__register_apt_key is succeeded")
      (when "apt__enabled | bool and (item.url | d() or item.data | d() or item.id | d() or item.file | d())")
      (tags (list
          "role::apt:keys")))
    (task "Add/remove diversion of repository sources"
      (debops.debops.dpkg_divert 
        (path "/etc/apt/sources.list.d/" (jinja "{{ item.filename }}"))
        (state (jinja "{{ \"present\"
               if (item.state | d(\"present\") == \"divert\")
               else \"absent\" }}"))
        (delete "True"))
      (loop (jinja "{{ apt__combined_repositories | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (register "apt__register_divert_repositories")
      (when "(apt__enabled | bool and item.filename and item.repo is undefined and item.uris is undefined and (item.state | d(\"present\")) in [ \"divert\", \"absent\" ])"))
    (task "Configure custom APT repositories"
      (ansible.builtin.apt_repository 
        (update_cache "False")
        (repo (jinja "{{ item.repo }}"))
        (codename (jinja "{{ item.codename | d(omit) }}"))
        (filename (jinja "{{ item.filename | regex_replace(\".list$\", \"\") | regex_replace(\".sources$\", \"\") }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ apt__combined_repositories | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (register "apt__register_apt_repositories")
      (when "(apt__enabled | bool and item.repo | d() and item.uris is undefined and (item.state | d(\"present\")) not in [ \"divert\", \"ignore\", \"init\" ])"))
    (task "Configure custom APT Deb822 repositories"
      (ansible.builtin.deb822_repository 
        (uris (jinja "{{ item.uris }}"))
        (name (jinja "{{ item.filename | regex_replace(\".sources$\", \"\") | regex_replace(\".list$\", \"\") }}"))
        (allow_downgrade_to_insecure (jinja "{{ item.allow_downgrade_to_insecure | d(omit) }}"))
        (allow_insecure (jinja "{{ item.allow_insecure | d(omit) }}"))
        (allow_weak (jinja "{{ item.allow_weak | d(omit) }}"))
        (architectures (jinja "{{ item.architectures | d(omit) }}"))
        (by_hash (jinja "{{ item.by_hash | d(omit) }}"))
        (check_date (jinja "{{ item.check_date | d(omit) }}"))
        (check_valid_until (jinja "{{ item.check_valid_until | d(omit) }}"))
        (components (jinja "{{ item.components | d(omit) }}"))
        (data_max_future (jinja "{{ item.date_max_future | d(omit) }}"))
        (enabled (jinja "{{ item.enabled | d(omit) }}"))
        (inrelease_path (jinja "{{ item.inrelease_path | d(omit) }}"))
        (languages (jinja "{{ item.languages | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (pdiffs (jinja "{{ item.pdiffs | d(omit) }}"))
        (signed_by (jinja "{{ item.signed_by | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (suites (jinja "{{ item.suites | d(omit) }}"))
        (targets (jinja "{{ item.targets | d(omit) }}"))
        (trusted (jinja "{{ item.trusted | d(omit) }}"))
        (types (jinja "{{ item.types | d(\"deb\") }}")))
      (loop (jinja "{{ apt__combined_repositories | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (register "apt__register_deb822_repositories")
      (when "(apt__enabled|bool and item.uris | d() and item.repo is undefined and (item.state | d(\"present\")) not in [ \"divert\", \"ignore\", \"init\" ])"))
    (task "Remove APT auth configuration if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/apt/auth.conf.d/\" + (item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", (apt__auth_files + apt__group_auth_files + apt__host_auth_files)) }}"))
      (when "apt__enabled | bool and item.state | d('present') == 'absent'")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate APT auth configuration"
      (ansible.builtin.template 
        (src "etc/apt/auth.conf.d/template.conf.j2")
        (dest (jinja "{{ \"/etc/apt/auth.conf.d/\" + (item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) }}"))
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", (apt__auth_files + apt__group_auth_files + apt__host_auth_files)) }}"))
      (when "apt__enabled | bool and item.machine | d() and item.login | d() and item.password | d() and item.state | d('present') not in ['absent', 'ignore']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Update APT cache on first run"
      (ansible.builtin.apt 
        (update_cache "True")
        (cache_valid_time (jinja "{{ apt__cache_valid_time }}")))
      (register "apt__register_apt_first_update")
      (until "apt__register_apt_first_update is succeeded")
      (when "(apt__enabled | bool and not (ansible_local.apt.configured | d()) | bool)"))
    (task "Install required packages"
      (ansible.builtin.apt 
        (name (jinja "{{ (apt__base_packages + apt__packages) | flatten }}"))
        (state "present")
        (install_recommends "False"))
      (register "apt__register_packages")
      (until "apt__register_packages is succeeded")
      (when "apt__enabled | bool"))
    (task "Enable extra architectures"
      (ansible.builtin.command "dpkg --add-architecture " (jinja "{{ item }}"))
      (loop (jinja "{{ q(\"flattened\", apt__extra_architectures
                           + apt__group_extra_architectures
                           + apt__host_extra_architectures) }}"))
      (register "apt__register_add_architecture")
      (changed_when "apt__register_add_architecture.changed | bool")
      (when "apt__enabled | bool and item not in ansible_facts.ansible_local.apt.foreign_architectures | d()")
      (notify (list
          "Refresh host facts")))
    (task "Add/remove diversion of APT configuration files"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ \"/etc/apt/apt.conf.d/\" + (item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) }}"))
        (state (jinja "{{ \"present\"
               if (item.state | d(\"present\") == \"divert\")
               else \"absent\" }}"))
        (delete "True"))
      (loop (jinja "{{ apt__combined_configuration | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "apt__enabled | bool and item.state | d(\"present\") in [ \"divert\", \"absent\" ]"))
    (task "Delete APT configuration files on remote hosts"
      (ansible.builtin.file 
        (path (jinja "{{ \"/etc/apt/apt.conf.d/\" + (item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) }}"))
        (state "absent"))
      (loop (jinja "{{ apt__combined_configuration | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "apt__enabled | bool and item.raw | d() and item.state | d('present') == 'absent'"))
    (task "Generate APT configuration files"
      (ansible.builtin.template 
        (src "etc/apt/apt.conf.d/template.conf.j2")
        (dest (jinja "{{ \"/etc/apt/apt.conf.d/\" + (item.filename | d(item.name | regex_replace(\".conf$\", \"\") + \".conf\")) }}"))
        (mode "0644"))
      (loop (jinja "{{ apt__combined_configuration | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state | d(\"present\")} }}")))
      (when "apt__enabled | bool and item.raw | d() and item.state | d('present') not in [ 'divert', 'absent', 'ignore', 'init' ]"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (tags (list
          "meta::facts")))
    (task "Save APT local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/apt.fact.j2")
        (dest "/etc/ansible/facts.d/apt.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Add/remove diversion of /etc/apt/sources.list"
      (debops.debops.dpkg_divert 
        (path "/etc/apt/sources.list")
        (state (jinja "{{ apt__deploy_state }}"))
        (delete "True"))
      (register "apt__register_sources_diversion")
      (when "(apt__enabled | bool and apt__deploy_state in ['absent', 'present'])"))
    (task "Configure operating system sources.list"
      (ansible.builtin.template 
        (src "etc/apt/sources.list.j2")
        (dest "/etc/apt/sources.list")
        (mode "0644"))
      (register "apt__register_sources_template")
      (when "(apt__enabled | bool and apt__deploy_state == 'present')"))
    (task "Update APT cache"
      (ansible.builtin.apt 
        (update_cache "True")
        (cache_valid_time (jinja "{{ omit
                         if (apt__register_sources_template is changed or
                             apt__register_sources_diversion is changed or
                             apt__register_apt_repositories is changed)
                         else apt__cache_valid_time }}")))
      (register "apt__register_apt_update")
      (until "apt__register_apt_update is succeeded")
      (when "apt__enabled | bool"))
    (task "Purge APT packages if requested"
      (ansible.builtin.apt 
        (name (jinja "{{ (apt__purge_packages
               + apt__purge_group_packages
               + apt__purge_host_packages) | flatten }}"))
        (state "absent")
        (purge "True")
        (autoremove "True"))
      (register "apt__register_purge_packages")
      (until "apt__register_purge_packages is succeeded")
      (when "apt__enabled | bool"))))
