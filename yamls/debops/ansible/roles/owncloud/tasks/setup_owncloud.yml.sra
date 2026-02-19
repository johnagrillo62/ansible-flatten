(playbook "debops/ansible/roles/owncloud/tasks/setup_owncloud.yml"
  (tasks
    (task "Enable required Apache modules"
      (community.general.apache2_module 
        (name "php5")
        (state "present"))
      (when "owncloud__webserver == \"apache\"")
      (loop (jinja "{{ q(\"flattened\", owncloud__apache_modules) }}")))
    (task "Ensure restrictive permissions are set for the data directory"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__data_path }}"))
        (state "directory")
        (owner (jinja "{{ owncloud__app_user }}"))
        (group (jinja "{{ owncloud__app_group }}"))
        (mode "0770")))
    (task "Install ownCloud config file"
      (ansible.builtin.template 
        (src "srv/www/sites/config/debops.config.php.j2")
        (dest (jinja "{{ owncloud__deploy_path }}") "/config/debops.config.php")
        (owner (jinja "{{ owncloud__app_user }}"))
        (group (jinja "{{ owncloud__app_group }}"))
        (mode "0640")
        (validate "php -f %s")))
    (task "Install ownCloud mail config file"
      (ansible.builtin.template 
        (src "srv/www/sites/config/mail.config.php.j2")
        (dest (jinja "{{ owncloud__deploy_path }}") "/config/mail.config.php")
        (owner (jinja "{{ owncloud__app_user }}"))
        (group (jinja "{{ owncloud__app_group }}"))
        (mode "0640")
        (validate "php -f %s"))
      (when "((owncloud__mail_conf_map.keys() | length) >= 1)")
      (tags (list
          "role::owncloud:mail")))
    (task "Ensure the ownCloud mail config file is absent"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__deploy_path }}") "/config/mail.config.php")
        (state "absent"))
      (when "((owncloud__mail_conf_map.keys() | length) == 0)"))
    (task "Ensure deprecated configuration files are absent"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (loop (list
          (jinja "{{ owncloud__deploy_path }}") "/config/custom.config.php")))
    (task "Remove legacy files"
      (ansible.builtin.file 
        (state "absent")
        (path (jinja "{{ ansible_local.php.etc_base | d(\"/etc/php\") + \"/cli/conf.d/enable_apc.ini\" }}")))
      (tags (list
          "role::owncloud:occ")))
    (task "Setup shortcut for the occ command"
      (ansible.builtin.template 
        (src "usr/local/bin/occ.j2")
        (dest (jinja "{{ owncloud__occ_bin_file_path }}"))
        (owner "root")
        (group (jinja "{{ owncloud__app_group }}"))
        (mode "0755"))
      (tags (list
          "role::owncloud:occ")))
    (task "Get ownCloud setup status"
      (ansible.builtin.command (jinja "{{ owncloud__occ_bin_file_path | quote }}") " check")
      (register "owncloud__register_occ_check")
      (changed_when "False"))
    (task "Determine if ownCloud autosetup should be done"
      (ansible.builtin.set_fact 
        (owncloud__do_autosetup (jinja "{{ (owncloud__autosetup and
                                 owncloud__admin_username | d() and
                                 (owncloud__register_occ_check is not skipped) and
                                 ((\"is not installed\" in owncloud__register_occ_check.stdout) or
                                  (\"is not installed\" in owncloud__register_occ_check.stderr))) }}"))))
    (task "Automatically finish setup via the occ tool"
      (ansible.builtin.command (jinja "{{ owncloud__occ_bin_file_path | quote }}") " maintenance:install
'--data-dir=" (jinja "{{ owncloud__data_path }}") "'
'--database=" (jinja "{{ owncloud__database_map[owncloud__database].dbtype }}") "'
'--database-name=" (jinja "{{ owncloud__database_map[owncloud__database].dbname }}") "'
'--database-host=" (jinja "{{ owncloud__database_map[owncloud__database].dbhost }}") "'
'--database-user=" (jinja "{{ owncloud__database_map[owncloud__database].dbuser }}") "'
'--database-pass=" (jinja "{{ owncloud__database_map[owncloud__database].dbpass }}") "'
" (jinja "{% if owncloud__admin_username %}") "
'--admin-user=" (jinja "{{ owncloud__admin_username }}") "'
'--admin-pass=" (jinja "{{ owncloud__admin_password }}") "'
" (jinja "{% endif %}") "
")
      (register "owncloud__register_occ_install")
      (changed_when "owncloud__register_occ_install.changed | bool")
      (when "owncloud__do_autosetup | bool"))
    (task "Get current ownCloud configuration via occ config:list"
      (ansible.builtin.include_tasks "run_occ.yml")
      (loop_control 
        (loop_var "owncloud__occ_item"))
      (tags (list
          "role::owncloud:occ_config"))
      (when "(owncloud__apps_config_combined is mapping and owncloud__apps_config_combined.keys() | length)")
      (loop (list
          
          (command "config:list")
          (get_output "True"))))
    (task "Capture occ output in variable"
      (ansible.builtin.set_fact 
        (owncloud__occ_config_current (jinja "{{ owncloud__occ_run_output }}")))
      (when "(owncloud__do_autosetup | bool and owncloud__apps_config_combined is mapping and owncloud__apps_config_combined.keys() | length and (not ansible_check_mode))")
      (tags (list
          "role::owncloud:occ_config")))
    (task "Set ownCloud apps configuration for each app"
      (ansible.builtin.include_tasks "run_occ_app_set.yml")
      (loop_control 
        (loop_var "owncloud__apps_item"))
      (with_dict (jinja "{{ owncloud__apps_config_combined | d({}) }}"))
      (when "(owncloud__do_autosetup | d() | bool and not ansible_check_mode)")
      (tags (list
          "role::owncloud:occ_config")))
    (task "Run occ commands as specified in the inventory"
      (ansible.builtin.include_tasks "run_occ.yml")
      (loop_control 
        (loop_var "owncloud__occ_item"))
      (tags (list
          "role::owncloud:occ"))
      (loop (jinja "{{ q(\"flattened\", owncloud__role_occ_cmd_list
                           + owncloud__occ_cmd_list
                           + owncloud__group_occ_cmd_list
                           + owncloud__host_occ_cmd_list
                           + owncloud__dependent_occ_cmd_list) }}")))
    (task "Setup cron service (nextcloud)"
      (ansible.builtin.cron 
        (name "ownCloud Background Jobs")
        (minute (jinja "{{ owncloud__cron_minute }}"))
        (user (jinja "{{ owncloud__app_user }}"))
        (job "test -x /usr/bin/php && test -e " (jinja "{{ (owncloud__deploy_path + \"/cron.php\") | quote }}") " && /usr/bin/php -f " (jinja "{{ (owncloud__deploy_path + \"/cron.php\") | quote }}"))
        (cron_file "owncloud"))
      (when "owncloud__variant == \"nextcloud\""))
    (task "Setup cron service (owncloud)"
      (ansible.builtin.cron 
        (name "ownCloud Background Jobs")
        (minute (jinja "{{ owncloud__cron_minute }}"))
        (user (jinja "{{ owncloud__app_user }}"))
        (job "test -x /usr/bin/php && test -e " (jinja "{{ (owncloud__deploy_path + \"/occ\") | quote }}") " && /usr/bin/php " (jinja "{{ (owncloud__deploy_path + \"/occ\") | quote }}") " system:cron")
        (cron_file "owncloud"))
      (when "owncloud__variant == \"owncloud\""))
    (task "Disable the package manager hook script for ownCloud"
      (ansible.builtin.file 
        (path "/etc/apt/apt.conf.d/80owncloud-dpkg-hook")
        (state "absent")))
    (task "Check ownCloud core integrity"
      (ansible.builtin.command (jinja "{{ owncloud__occ_bin_file_path | quote }}") " integrity:check-core")
      (register "owncloud__register_occ_integrity_check_core")
      (failed_when "(owncloud__register_occ_integrity_check_core.rc != 0 or owncloud__register_occ_integrity_check_core.stdout_lines | length != 0)")
      (changed_when "False")
      (when "owncloud__do_autosetup | bool"))))
