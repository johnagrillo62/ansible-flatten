(playbook "debops/ansible/roles/owncloud/tasks/run_occ_app_set.yml"
  (tasks
    (task "Run occ commands for each app setting"
      (ansible.builtin.include_tasks "run_occ.yml")
      (loop_control 
        (loop_var "owncloud__apps_setting_item"))
      (when "(\"apps\" in owncloud__occ_config_current and owncloud__apps_item.key in owncloud__occ_config_current.apps and owncloud__occ_config_current.apps[owncloud__apps_item.key][owncloud__apps_setting_item.key] | d(omit) != owncloud__apps_setting_item.value)")
      (with_dict (jinja "{{ owncloud__apps_item.value }}")))))
