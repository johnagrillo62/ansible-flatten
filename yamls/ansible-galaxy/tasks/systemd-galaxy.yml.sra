(playbook "ansible-galaxy/tasks/systemd-galaxy.yml"
  (tasks
    (task "Manage Paths"
      (block (list
          
          (name "Ensure Galaxy version is set")
          (include_tasks "_inc_galaxy_version.yml")
          (when "__galaxy_major_version is undefined")
          
          (name "Deploy Galaxy Unit")
          (template 
            (owner (jinja "{{ galaxy_systemd_root | ternary('root', omit) }}"))
            (group (jinja "{{ galaxy_systemd_root | ternary('root', omit) }}"))
            (mode "0644")
            (src "systemd/galaxy.service.j2")
            (dest (jinja "{{ galaxy_systemd_root | ternary('/etc/systemd/system/', ('~' ~ __galaxy_user_name ~ '/.config/systemd/user') | expanduser) }}") "/galaxy.service"))
          (notify (list
              "systemd daemon reload"
              "start galaxy"
              "restart galaxy"))
          
          (name "Enable Galaxy service unit")
          (systemd 
            (name "galaxy.service")
            (enabled "yes")
            (scope (jinja "{{ galaxy_systemd_root | ternary(omit, 'user') }}")))))
      (remote_user (jinja "{{ galaxy_remote_users.root | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.root is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.root | default(__galaxy_become_user) }}")))))
