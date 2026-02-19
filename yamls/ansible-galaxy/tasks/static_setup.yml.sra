(playbook "ansible-galaxy/tasks/static_setup.yml"
  (tasks
    (task "Static config setup"
      (block (list
          
          (name "Ensure Galaxy version is set")
          (include_tasks "_inc_galaxy_version.yml")
          (when "__galaxy_major_version is undefined")
          
          (name "Install additional Galaxy config files (static)")
          (copy 
            (src (jinja "{{ item.src }}"))
            (dest (jinja "{{ item.dest }}"))
            (backup (jinja "{{ galaxy_backup_configfiles }}"))
            (mode (jinja "{{ galaxy_config_perms }}"))
            (group (jinja "{{ __galaxy_user_group }}")))
          (with_items (jinja "{{ galaxy_config_files }}"))
          (notify (list
              "restart galaxy"))
          
          (name "Install additional Galaxy config files (static, public)")
          (copy 
            (src (jinja "{{ item.src }}"))
            (dest (jinja "{{ item.dest }}"))
            (backup (jinja "{{ galaxy_backup_configfiles }}"))
            (mode (jinja "{{ galaxy_config_perms_public }}"))
            (group (jinja "{{ __galaxy_user_group }}")))
          (with_items (jinja "{{ galaxy_config_files_public }}"))
          (notify (list
              "restart galaxy"))
          
          (name "Install additional Galaxy config files (template)")
          (template 
            (src (jinja "{{ item.src }}"))
            (dest (jinja "{{ item.dest }}"))
            (backup (jinja "{{ galaxy_backup_configfiles }}"))
            (mode (jinja "{{ galaxy_config_perms }}"))
            (group (jinja "{{ __galaxy_user_group }}")))
          (with_items (jinja "{{ galaxy_config_templates }}"))
          (notify (list
              "restart galaxy"))
          
          (name "Install local tools")
          (copy 
            (src (jinja "{{ galaxy_local_tools_src_dir }}") "/" (jinja "{{ item.file | default(item) }}"))
            (dest (jinja "{{ galaxy_local_tools_dir }}") "/" (jinja "{{ item.file | default(item) }}"))
            (mode "preserve"))
          (loop (jinja "{{ galaxy_local_tools | default([]) }}"))
          (when "galaxy_local_tools is defined")
          
          (name "Install local_tool_conf.xml")
          (template 
            (src "local_tool_conf.xml.j2")
            (dest (jinja "{{ galaxy_config_dir }}") "/local_tool_conf.xml")
            (mode (jinja "{{ galaxy_config_perms }}"))
            (group (jinja "{{ __galaxy_user_group }}")))
          (when "galaxy_local_tools is defined")
          
          (name "Append local_tool_conf.xml to tool_config_file Galaxy config option")
          (set_fact 
            (galaxy_tool_config_files (jinja "{{ galaxy_tool_config_files + [galaxy_config_dir ~ '/local_tool_conf.xml'] }}")))
          (when "galaxy_local_tools is defined")
          
          (name "Append shed_tool_conf.xml to tool_config_file Galaxy config option")
          (set_fact 
            (galaxy_tool_config_files (jinja "{{ galaxy_tool_config_files + [galaxy_shed_tool_config_file] }}")))
          (when "__galaxy_major_version is version('19.09', '<') and galaxy_shed_tool_config_file not in galaxy_tool_config_files")
          
          (name "Rebuild galaxy_app_config_default with updated tool_config_files")
          (set_fact 
            (galaxy_app_config_default (jinja "{{ galaxy_app_config_default | combine({'tool_config_file': galaxy_tool_config_files | join(',')}) }}")))
          
          (name "Rebuild galaxy_config_default with updated galaxy_app_config_default")
          (set_fact 
            (galaxy_config_default (jinja "{{ {} | combine({galaxy_app_config_section: galaxy_app_config_default}) }}")))
          
          (name "Rebuild galaxy_config_merged with updated galaxy_config_default")
          (set_fact 
            (galaxy_config_merged (jinja "{{ galaxy_config_default | combine(galaxy_config | default({}), recursive=True) }}")))
          
          (name "Ensure dynamic job rules paths exists")
          (file 
            (path (jinja "{{ galaxy_dynamic_job_rules_dir }}") "/" (jinja "{{ item | dirname }}"))
            (state "directory")
            (mode "0755"))
          (loop_control 
            (label (jinja "{{ galaxy_dynamic_job_rules_dir }}") "/" (jinja "{{ item | dirname }}")))
          (with_items (jinja "{{ galaxy_dynamic_job_rules }}"))
          
          (name "Install dynamic job rules (static)")
          (copy 
            (src (jinja "{{ galaxy_dynamic_job_rules_src_dir }}") "/" (jinja "{{ item }}"))
            (dest (jinja "{{ galaxy_dynamic_job_rules_dir }}") "/" (jinja "{{ item }}"))
            (mode "0644"))
          (with_items (jinja "{{ galaxy_dynamic_job_rules }}"))
          (when "not item.endswith(\".j2\")")
          
          (name "Install dynamic job rules (template)")
          (template 
            (src (jinja "{{ galaxy_dynamic_job_rules_src_dir }}") "/" (jinja "{{ item }}"))
            (dest (jinja "{{ galaxy_dynamic_job_rules_dir }}") "/" (jinja "{{ item | regex_replace(regex) }}"))
            (mode "0644"))
          (vars 
            (regex "\\.j2$"))
          (with_items (jinja "{{ galaxy_dynamic_job_rules }}"))
          (when "item.endswith(\".j2\")")
          
          (name "Ensure dynamic rule __init__.py's exist")
          (copy 
            (content "")
            (dest (jinja "{{ galaxy_dynamic_job_rules_dir }}") "/" (jinja "{{ item | dirname }}") "/__init__.py")
            (force "no")
            (mode "0644"))
          (loop_control 
            (label (jinja "{{ galaxy_dynamic_job_rules_dir }}") "/" (jinja "{{ ((item | dirname) != '') | ternary ((item | dirname) ~ '/', '') }}") "__init__.py"))
          (with_items (jinja "{{ galaxy_dynamic_job_rules }}"))
          
          (name "Create Galaxy job metrics configuration file")
          (copy 
            (dest (jinja "{{ galaxy_config_merged[galaxy_app_config_section].job_metrics_config_file }}"))
            (content "---
## This file is managed by Ansible.  ALL CHANGES WILL BE OVERWRITTEN.
" (jinja "{{ galaxy_job_metrics_plugins | to_nice_yaml }}") "
")
            (mode "0644"))
          (when "galaxy_job_metrics_plugins is defined")
          
          (name "Create Galaxy dependency resolvers configuration file")
          (copy 
            (dest (jinja "{{ galaxy_config_merged[galaxy_app_config_section].dependency_resolvers_config_file }}"))
            (content "---
## This file is managed by Ansible.  ALL CHANGES WILL BE OVERWRITTEN.
" (jinja "{{ galaxy_dependency_resolvers | to_nice_yaml }}") "
")
            (mode "0644"))
          (when "galaxy_dependency_resolvers is defined")
          
          (name "Create Galaxy container resolvers configuration file")
          (copy 
            (dest (jinja "{{ galaxy_config_merged[galaxy_app_config_section].container_resolvers_config_file }}"))
            (content "---
## This file is managed by Ansible.  ALL CHANGES WILL BE OVERWRITTEN.
" (jinja "{{ galaxy_container_resolvers | to_nice_yaml }}") "
")
            (mode "0644"))
          (when "galaxy_container_resolvers is defined")
          
          (name "Create Galaxy configuration file")
          (template 
            (src (jinja "{{ galaxy_config_file_template }}"))
            (dest (jinja "{{ galaxy_config_file }}"))
            (backup (jinja "{{ galaxy_backup_configfiles }}"))
            (mode (jinja "{{ galaxy_config_perms }}"))
            (group (jinja "{{ __galaxy_user_group }}")))
          (notify (list
              "galaxyctl update"
              "restart galaxy"))))
      (remote_user (jinja "{{ galaxy_remote_users.privsep | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.privsep is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.privsep | default(__galaxy_become_user) }}")))))
