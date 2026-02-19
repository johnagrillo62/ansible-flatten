(playbook "debops/ansible/roles/owncloud/tasks/theme.yml"
  (tasks
    (task "Combine theme copy dictionaries"
      (ansible.builtin.set_fact 
        (owncloud__theme_copy_files_combined (jinja "{{
                owncloud__theme_copy_files
      | combine(owncloud__theme_copy_files_host_group)
      | combine(owncloud__theme_copy_files_host) }}")))
      (tags (list
          "role::owncloud:theme:copy")))
    (task "Ensure the theme directory is present"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__deploy_path + \"/themes/\" + owncloud__theme_directory_name }}"))
        (state "directory")
        (mode "0755"))
      (when "(owncloud__theme_directory_name | d())")
      (tags (list
          "role::owncloud:theme:common_settings")))
    (task "Apply common theming options using the defaults.php file"
      (ansible.builtin.template 
        (src "srv/www/sites/themes/debops-template/defaults.php.j2")
        (dest (jinja "{{ owncloud__deploy_path + \"/themes/\" + owncloud__theme_directory_name + \"/defaults.php\" }}"))
        (owner "root")
        (group (jinja "{{ owncloud__app_group }}"))
        (mode "0640")
        (validate "php -f %s"))
      (when "(owncloud__theme_directory_name | d())")
      (tags (list
          "role::owncloud:theme:common_settings")))
    (task "Ensure that parent directories exist"
      (ansible.builtin.file 
        (path (jinja "{{ (owncloud__deploy_path + \"/themes/\" + owncloud__theme_directory_name + \"/\" + item.key) | dirname }}"))
        (state "directory")
        (owner (jinja "{{ item.value.base_directory_owner | d(omit) }}"))
        (group (jinja "{{ item.value.base_directory_group | d(omit) }}"))
        (mode (jinja "{{ item.value.base_directory_mode | d(omit) }}")))
      (with_dict (jinja "{{ owncloud__theme_copy_files_combined }}"))
      (when "(owncloud__theme_directory_name | d() and item.value.state | d(\"present\") == \"present\")")
      (tags (list
          "role::owncloud:theme:copy")))
    (task "Copy additional theme files"
      (ansible.builtin.copy 
        (dest (jinja "{{ (owncloud__deploy_path + \"/themes/\" + owncloud__theme_directory_name + \"/\" + item.key)
                        if (not item.key.startswith(\"/\")) else item.key }}"))
        (backup (jinja "{{ item.value.backup | d(omit) }}"))
        (content (jinja "{{ item.value.content | d(omit) }}"))
        (directory_mode (jinja "{{ item.value.directory_mode | d(omit) }}"))
        (follow (jinja "{{ item.value.follow | d(omit) }}"))
        (force (jinja "{{ item.value.force | d(omit) }}"))
        (owner (jinja "{{ item.value.owner | d(omit) }}"))
        (group (jinja "{{ item.value.group | d(omit) }}"))
        (mode (jinja "{{ item.value.mode | d(omit) }}"))
        (selevel (jinja "{{ item.value.selevel | d(omit) }}"))
        (serole (jinja "{{ item.value.serole | d(omit) }}"))
        (setype (jinja "{{ item.value.setype | d(omit) }}"))
        (seuser (jinja "{{ item.value.seuser | d(omit) }}"))
        (src (jinja "{{ item.value.src | d(omit) }}"))
        (validate (jinja "{{ item.value.validate | d(omit) }}")))
      (with_dict (jinja "{{ owncloud__theme_copy_files_combined }}"))
      (when "(owncloud__theme_directory_name | d() and item.value.state | d(\"present\") == \"present\")")
      (tags (list
          "role::owncloud:theme:copy")))
    (task "Activate custom theme"
      (ansible.builtin.template 
        (src "srv/www/sites/config/theme.config.php.j2")
        (dest (jinja "{{ owncloud__deploy_path }}") "/config/theme.config.php")
        (owner "root")
        (group (jinja "{{ owncloud__app_group }}"))
        (mode "0640"))
      (when "(owncloud__theme_active | d())")
      (tags (list
          "role::owncloud:theme:activate")))
    (task "Deactivate custom theme"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__deploy_path }}") "/config/theme.config.php")
        (state "absent"))
      (when "(not owncloud__theme_active | d())")
      (tags (list
          "role::owncloud:theme:activate")))
    (task "Delete additional theme files"
      (ansible.builtin.file 
        (path (jinja "{{ owncloud__deploy_path + \"/themes/\" + owncloud__theme_directory_name + \"/\" + item.key }}"))
        (state "absent"))
      (when "(owncloud__theme_directory_name | d() and item.value.state | d(\"present\") == \"absent\")")
      (with_dict (jinja "{{ owncloud__theme_copy_files_combined }}"))
      (tags (list
          "role::owncloud:theme:copy")))))
