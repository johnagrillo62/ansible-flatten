(playbook "ansible-galaxy/tasks/layout.yml"
  (tasks
    (task "Include layout vars"
      (include_vars "layout-" (jinja "{{ galaxy_layout | default('legacy') }}") ".yml"))
    (task "Set any unset variables from layout defaults"
      (set_fact 
        ({{ item }} (jinja "{{ lookup('vars', '__' ~ item) }}")))
      (when "item not in vars")
      (with_items (list
          "galaxy_venv_dir"
          "galaxy_server_dir"
          "galaxy_config_dir"
          "galaxy_mutable_data_dir"
          "galaxy_mutable_config_dir"
          "galaxy_shed_tools_dir"
          "galaxy_cache_dir"
          "galaxy_local_tools_dir"
          "galaxy_tool_data_path")))
    (task "Check that any explicitly set Galaxy config options match the values of explicitly set variables"
      (assert 
        (that (list
            "lookup('vars', 'galaxy_' ~ item) == galaxy_config[galaxy_app_config_section][item]"))
        (msg "Value of '" (jinja "{{ 'galaxy_' ~ item }}") "' does not match value of '" (jinja "{{ item }}") "' in galaxy_config: " (jinja "{{ lookup('vars', 'galaxy_' ~ item) }}") " != " (jinja "{{ galaxy_config[galaxy_app_config_section][item] }}")))
      (when "'galaxy_' ~ item in vars and item in ((galaxy_config | default({}))[galaxy_app_config_section] | default({}))")
      (with_items (list
          "tool_dependency_dir"
          "file_path"
          "job_working_directory"
          "shed_tool_config_file")))
    (task "Set any unset variables corresponding to Galaxy config options from galaxy_config or layout defaults"
      (set_fact 
        ({{ 'galaxy_' ~ item }} (jinja "{{ ((galaxy_config | default({}))[galaxy_app_config_section] | default({}))[item] | default(lookup('vars', '__galaxy_' ~ item)) }}")))
      (when "'galaxy_' ~ item not in vars")
      (with_items (list
          "tool_dependency_dir"
          "file_path"
          "job_working_directory")))))
