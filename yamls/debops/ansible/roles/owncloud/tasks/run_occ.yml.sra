(playbook "debops/ansible/roles/owncloud/tasks/run_occ.yml"
  (tasks
    (task "Construct occ command for ownCloud apps configuration"
      (ansible.builtin.set_fact 
        (owncloud__occ_item 
          (command "config:app:set " (jinja "{{ owncloud__apps_item.key | quote }}") " " (jinja "{{ owncloud__apps_setting_item.key | quote }}") " --value=" (jinja "{{ owncloud__apps_setting_item.value | string | quote }}"))))
      (when "(owncloud__apps_setting_item is defined)")
      (tags (list
          "role::owncloud:occ")))
    (task "Construct occ command for ownCloud files:scan configuration"
      (ansible.builtin.set_fact 
        (owncloud__occ_item 
          (command "files:scan --path " (jinja "{{ owncloud__files_scan_item.item.dest | quote }}"))))
      (when "(owncloud__files_scan_item is defined)")
      (tags (list
          "role::owncloud:occ")))
    (task "Run given occ commands"
      (ansible.builtin.command "php --file \"" (jinja "{{ owncloud__app_home }}") "/occ\" " (jinja "{{ owncloud__occ_item.command }}") " " (jinja "{{ \"--output=json_pretty\" if (owncloud__occ_item.get_output | d() | bool) else \"\" }}"))
      (environment (jinja "{{ owncloud__occ_item.env | d({}) }}"))
      (tags (list
          "role::owncloud:occ"))
      (changed_when "False")
      (failed_when "((owncloud__occ_run.rc != 0 and 'already exists' not in owncloud__occ_run.stdout and 'already installed' not in owncloud__occ_run.stdout) or ('An unhandled exception has been thrown:' in owncloud__occ_run.stdout))")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (register "owncloud__occ_run")
      (become "True")
      (become_user (jinja "{{ owncloud__app_user }}"))
      (when "(owncloud__do_autosetup | d() | bool and owncloud__occ_item | d() and owncloud__occ_item.command | d() and (owncloud__occ_item.when | d(True) | bool) and not (ansible_local.owncloud.maintenance | d() | bool and (owncloud__occ_item.command.startswith(\"dav\") or owncloud__occ_item.command.startswith(\"federation\") or owncloud__occ_item.command.startswith(\"files\") or owncloud__occ_item.command.startswith(\"trashbin\") or owncloud__occ_item.command.startswith(\"versions\"))))"))
    (task "Convert occ output into Ansible data structure"
      (ansible.builtin.set_fact 
        (owncloud__occ_run_output (jinja "{{ owncloud__occ_run.stdout_lines
                                  | map(\"regex_replace\", \"^[^{} ].*$\", \"\") | join(\"\") | from_json }}")))
      (when "(owncloud__do_autosetup | d() | bool and owncloud__occ_item | d() and (owncloud__occ_item.get_output | d() | bool) and (not ansible_check_mode))")
      (tags (list
          "role::owncloud:occ_config"
          "role::owncloud:occ")))))
