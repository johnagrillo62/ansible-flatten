(playbook "ansible-galaxy/handlers/main.yml"
  (tasks
    (task "systemd daemon reload"
      (systemd 
        (daemon_reload "yes")
        (scope (jinja "{{ galaxy_systemd_root | ternary(omit, 'user') }}"))))
    (task "galaxy systemd start"
      (systemd 
        (name "galaxy.service")
        (state "started")
        (scope (jinja "{{ galaxy_systemd_root | ternary(omit, 'user') }}")))
      (listen "start galaxy")
      (when "galaxy_systemd_mode == 'gravity' and galaxy_manage_systemd"))
    (task "galaxy mule restart"
      (systemd 
        (name "galaxy.service")
        (state "restarted")
        (scope (jinja "{{ galaxy_systemd_root | ternary(omit, 'user') }}")))
      (listen "restart galaxy")
      (when "galaxy_systemd_mode == 'mule' and galaxy_manage_systemd"))
    (task "galaxy gravity restart (22.05)"
      (command (jinja "{{ galaxy_gravity_command }}") " graceful")
      (listen "restart galaxy")
      (environment 
        (GRAVITY_STATE_DIR (jinja "{{ galaxy_gravity_state_dir }}")))
      (when "galaxy_systemd_mode == 'gravity' and galaxy_manage_systemd and __galaxy_major_version is version('23.0', '<')")
      (become "yes")
      (become_user (jinja "{{ __galaxy_user_name }}")))
    (task "galaxyctl update (22.05)"
      (command (jinja "{{ galaxy_gravity_command }}") " update")
      (listen "galaxyctl update")
      (environment 
        (GRAVITY_STATE_DIR (jinja "{{ galaxy_gravity_state_dir }}")))
      (when "galaxy_systemd_mode == 'gravity' and galaxy_manage_systemd and __galaxy_major_version is version('23.0', '<')")
      (become "yes")
      (become_user (jinja "{{ __galaxy_user_name }}")))
    (task "galaxyctl update (23.0+)"
      (command (jinja "{{ galaxy_gravity_command }}") " -c " (jinja "{{ galaxy_config_file }}") " update")
      (listen "galaxyctl update")
      (when "galaxy_systemd_mode == 'gravity' and __galaxy_major_version is version('23.0', '>=')")
      (become "yes")
      (become_user (jinja "{{ (__galaxy_gravity_pm == 'systemd' and galaxy_systemd_root) | ternary('root', __galaxy_user_name) }}")))
    (task "galaxy gravity restart (23.0+)"
      (command (jinja "{{ galaxy_gravity_command }}") " -c " (jinja "{{ galaxy_config_file }}") " graceful")
      (listen "restart galaxy")
      (when "galaxy_systemd_mode == 'gravity' and __galaxy_major_version is version('23.0', '>=')")
      (become "yes")
      (become_user (jinja "{{ (__galaxy_gravity_pm == 'systemd' and galaxy_systemd_root) | ternary('root', __galaxy_user_name) }}")))))
