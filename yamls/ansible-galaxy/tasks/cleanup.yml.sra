(playbook "ansible-galaxy/tasks/cleanup.yml"
  (tasks
    (task "Schedule tmpclean cron job (root)"
      (ansible.builtin.cron 
        (name "galaxy_tmpclean")
        (job (jinja "{{ galaxy_tmpclean_command }}") " " (jinja "{{ galaxy_tmpclean_age | quote }}") " " (jinja "{{ galaxy_tmpclean_dirs | map('quote') | join(' ') }}") " " (jinja "{{ galaxy_tmpclean_log_statement }}"))
        (cron_file (jinja "{{ galaxy_tmpclean_cron_file }}"))
        (user (jinja "{{ galaxy_user.name }}"))
        (hour (jinja "{{ galaxy_tmpclean_time.hour | default(omit) }}"))
        (minute (jinja "{{ galaxy_tmpclean_time.minute | default(omit) }}"))
        (day (jinja "{{ galaxy_tmpclean_time.day | default(omit) }}"))
        (month (jinja "{{ galaxy_tmpclean_time.month | default(omit) }}"))
        (weekday (jinja "{{ galaxy_tmpclean_time.weekday | default(omit) }}"))
        (special_time (jinja "{{ galaxy_tmpclean_time.special_time | default(omit) }}")))
      (remote_user (jinja "{{ galaxy_remote_users.root | default(__galaxy_remote_user) }}"))
      (when "galaxy_tmpclean_cron_file is not none")
      (become (jinja "{{ true if galaxy_become_users.root is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.root | default(__galaxy_become_user) }}")))
    (task "Schedule tmpclean cron job (user)"
      (ansible.builtin.cron 
        (name "galaxy_tmpclean")
        (job (jinja "{{ galaxy_tmpclean_command }}") " " (jinja "{{ galaxy_tmpclean_age | quote }}") " " (jinja "{{ galaxy_tmpclean_dirs | map('quote') | join(' ') }}") " " (jinja "{{ galaxy_tmpclean_log_statement }}"))
        (hour (jinja "{{ galaxy_tmpclean_time.hour | default(omit) }}"))
        (minute (jinja "{{ galaxy_tmpclean_time.minute | default(omit) }}"))
        (day (jinja "{{ galaxy_tmpclean_time.day | default(omit) }}"))
        (month (jinja "{{ galaxy_tmpclean_time.month | default(omit) }}"))
        (weekday (jinja "{{ galaxy_tmpclean_time.weekday | default(omit) }}"))
        (special_time (jinja "{{ galaxy_tmpclean_time.special_time | default(omit) }}")))
      (remote_user (jinja "{{ galaxy_remote_users.galaxy | default(__galaxy_remote_user) }}"))
      (when "galaxy_tmpclean_cron_file is none")
      (become (jinja "{{ true if galaxy_become_users.galaxy is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.galaxy | default(__galaxy_become_user) }}")))))
