(playbook "ansible-galaxy/tasks/gravity.yml"
  (tasks
    (task "Gravity setup (Gravity < 1)"
      (block (list
          
          (name "Register Galaxy config with Gravity (Gravity < 1)")
          (command (jinja "{{ galaxy_gravity_command }}") " register " (jinja "{{ galaxy_config_file }}"))
          (args 
            (creates (jinja "{{ galaxy_gravity_state_dir }}") "/configstate.yaml"))))
      (remote_user (jinja "{{ galaxy_remote_users.galaxy | default(__galaxy_remote_user) }}"))
      (when "__galaxy_major_version is version('23.0', '<')")
      (environment 
        (GRAVITY_STATE_DIR (jinja "{{ galaxy_gravity_state_dir }}")))
      (become (jinja "{{ true if galaxy_become_users.galaxy is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.galaxy | default(__galaxy_become_user) }}")))
    (task "Deploy galaxyctl wrapper script"
      (copy 
        (content "#!/usr/bin/env sh
export GRAVITY_CONFIG_FILE=" (jinja "{{ galaxy_config_file | quote }}") "
exec " (jinja "{{ galaxy_gravity_command | quote }}") " \"$@\"
")
        (dest (jinja "{{ galaxy_gravity_wrapper_path }}"))
        (mode "0755"))
      (remote_user (jinja "{{ galaxy_remote_users.root | default(__galaxy_remote_user) }}"))
      (when "galaxy_gravity_wrapper_path is not none")
      (become (jinja "{{ true if galaxy_become_users.root is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.root | default(__galaxy_become_user) }}")))))
