(playbook "debops/ansible/roles/cron/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install cron packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (cron__base_packages
                              + cron__packages)) }}"))
        (state "present"))
      (register "cron__register_packages")
      (until "cron__register_packages is succeeded")
      (when "cron__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (tags (list
          "role::cron:crontab")))
    (task "Save cron local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/cron.fact.j2")
        (dest "/etc/ansible/facts.d/cron.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts"
          "role::cron:crontab")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers")
      (tags (list
          "role::cron:crontab")))
    (task "Divert the original crontab configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/crontab")
        (state (jinja "{{ cron__crontab_deploy_state }}"))
        (delete "True"))
      (when "cron__enabled | bool and ansible_pkg_mgr == 'apt'")
      (tags (list
          "role::cron:crontab")))
    (task "Generate crontab configuration file"
      (ansible.builtin.template 
        (src "etc/crontab.j2")
        (dest "/etc/crontab")
        (mode "0644"))
      (when "cron__enabled | bool and cron__crontab_deploy_state == 'present'")
      (tags (list
          "role::cron:crontab")))
    (task "Remove custom cron files"
      (ansible.builtin.file 
        (dest (jinja "{{ item.1.dest }}"))
        (state "absent"))
      (with_subelements (list
          (jinja "{{ cron__combined_jobs | selectattr(\"custom_files\", \"defined\") | list }}")
          "custom_files"))
      (when "(cron__enabled | bool and (item.0.state | d('present') == 'absent' or item.1.state | d('present') == 'absent') and (item.1.src | d() or item.1.content | d()) and item.1.dest | d())"))
    (task "Manage custom cron files"
      (ansible.builtin.copy 
        (dest (jinja "{{ item.1.dest }}"))
        (src (jinja "{{ item.1.src | d(omit) }}"))
        (content (jinja "{{ item.1.content | d(omit) }}"))
        (owner (jinja "{{ item.1.owner | d(\"root\") }}"))
        (group (jinja "{{ item.1.group | d(\"root\") }}"))
        (mode (jinja "{{ item.1.mode | d(\"0755\") }}"))
        (force (jinja "{{ item.1.force | d(omit) }}")))
      (with_subelements (list
          (jinja "{{ cron__combined_jobs | selectattr(\"custom_files\", \"defined\") | list }}")
          "custom_files"))
      (when "(cron__enabled | bool and item.0.state | d('present') not in ['absent', 'ignore'] and item.1.state | d('present') != 'absent' and (item.1.src | d() or item.1.content | d()) and item.1.dest | d())"))
    (task "Remove cron job files"
      (ansible.builtin.file 
        (path "/etc/cron.d/" (jinja "{{ item.0.file | d(item.0.cron_file) }}"))
        (state "absent"))
      (with_subelements (list
          (jinja "{{ cron__combined_jobs }}")
          "jobs"))
      (when "cron__enabled | bool and item.0.state | d('present') == 'absent'"))
    (task "Manage cron environment variables"
      (ansible.builtin.cron 
        (cron_file (jinja "{{ item.0.file | d(item.0.cron_file) }}"))
        (name (jinja "{{ item.1.keys() | list | first }}"))
        (value (jinja "{{ item.1.values() | list | first }}"))
        (user (jinja "{{ item.0.user | d(\"root\") }}"))
        (state "present")
        (env "True"))
      (with_subelements (list
          (jinja "{{ cron__combined_jobs | selectattr(\"environment\", \"defined\") | list }}")
          "environment"))
      (when "cron__enabled | bool and item.0.state | d('present') not in ['absent', 'ignore']"))
    (task "Manage cron jobs"
      (ansible.builtin.cron 
        (name (jinja "{{ item.1.name }}"))
        (job (jinja "{{ item.1.job }}"))
        (cron_file (jinja "{{ item.0.file | d(item.0.cron_file) }}"))
        (disabled (jinja "{{ item.1.disabled | d(omit) }}"))
        (minute (jinja "{{ item.1.minute | d(omit) }}"))
        (hour (jinja "{{ item.1.hour | d(omit) }}"))
        (day (jinja "{{ item.1.day | d(omit) }}"))
        (month (jinja "{{ item.1.month | d(omit) }}"))
        (weekday (jinja "{{ item.1.weekday | d(omit) }}"))
        (special_time (jinja "{{ item.1.special_time | d(omit) }}"))
        (backup (jinja "{{ item.0.backup | d(omit) }}"))
        (user (jinja "{{ item.0.user | d(\"root\") }}"))
        (state (jinja "{{ item.1.state | d(\"present\") }}")))
      (with_subelements (list
          (jinja "{{ cron__combined_jobs }}")
          "jobs"))
      (when "cron__enabled | bool and item.0.state | d('present') not in ['absent', 'ignore']"))))
