(playbook "ansible-galaxy/tasks/themes.yml"
  (tasks
    (task "Themes setup"
      (block (list
          
          (name "Default themes block")
          (when "galaxy_themes is not defined")
          (block (list
              
              (name "Load default themes if unset")
              (ansible.builtin.slurp 
                (src (jinja "{{ (galaxy_server_dir, 'lib/galaxy/config/sample/themes_conf.yml.sample') | path_join }}")))
              (register "__galaxy_themes_config_slurp")
              
              (name "Set galaxy_themes")
              (ansible.builtin.set_fact 
                (galaxy_themes (jinja "{{ __galaxy_themes_config_slurp.content | b64decode | from_yaml }}")))))
          
          (name "Write base themes config")
          (ansible.builtin.copy 
            (content (jinja "{{ galaxy_themes | to_yaml(sort_keys=False) }}"))
            (dest (jinja "{{ galaxy_config_merged.galaxy.themes_config_file | default((galaxy_config_dir, 'themes_conf.yml') | path_join) }}"))
            (mode "0644"))
          
          (name "Write subdomain themes configs")
          (ansible.builtin.copy 
            (content (jinja "{{ item.theme | to_yaml(sort_keys=False) }}") "
" (jinja "{{ galaxy_themes | to_yaml(sort_keys=False) }}") "
")
            (dest (jinja "{{ galaxy_config_dir }}") "/themes_conf-" (jinja "{{ item.name }}") ".yml")
            (mode "0644"))
          (when "item.theme is defined")
          (loop (jinja "{{ galaxy_themes_subdomains }}"))))
      (remote_user (jinja "{{ galaxy_remote_users.privsep | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.privsep is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.privsep | default(__galaxy_become_user) }}")))))
