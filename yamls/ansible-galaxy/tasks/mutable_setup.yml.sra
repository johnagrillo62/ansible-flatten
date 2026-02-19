(playbook "ansible-galaxy/tasks/mutable_setup.yml"
  (tasks
    (task "Mutable config setup"
      (block (list
          
          (name "Ensure Galaxy version is set")
          (include_tasks "_inc_galaxy_version.yml")
          (when "__galaxy_major_version is undefined")
          
          (name "Create directories for config files")
          (ansible.builtin.file 
            (state "directory")
            (path (jinja "{{ item }}"))
            (mode (jinja "{{ __galaxy_dir_perms }}"))
            (group (jinja "{{ __galaxy_user_group }}")))
          (loop (jinja "{{ (galaxy_mutable_config_files + galaxy_mutable_config_templates) | map(attribute='dest') | map('dirname') | unique }}"))
          
          (name "Instantiate mutable configuration files")
          (copy 
            (src (jinja "{{ item.src }}"))
            (dest (jinja "{{ item.dest }}"))
            (force "no")
            (mode (jinja "{{ galaxy_config_perms }}")))
          (with_items (jinja "{{ galaxy_mutable_config_files }}"))
          
          (name "Instantiate mutable configuration templates")
          (template 
            (src (jinja "{{ item.src }}"))
            (dest (jinja "{{ item.dest }}"))
            (force "no")
            (mode (jinja "{{ galaxy_config_perms }}")))
          (with_items (jinja "{{ galaxy_mutable_config_templates }}"))))
      (remote_user (jinja "{{ galaxy_remote_users.galaxy | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.galaxy is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.galaxy | default(__galaxy_become_user) }}")))))
