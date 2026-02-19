(playbook "sensu-ansible/tasks/SmartOS/main.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "setup"))
    (task "Ensure the Sensu group is present"
      (group "name=" (jinja "{{ sensu_group_name }}") " state=present")
      (tags "setup"))
    (task "Ensure the Sensu user is present"
      (user 
        (name (jinja "{{ sensu_user_name }}"))
        (group (jinja "{{ sensu_group_name }}"))
        (shell "/bin/false")
        (home (jinja "{{ sensu_config_path }}"))
        (createhome "true")
        (state "present"))
      (tags "setup"))
    (task "Ensure Sensu dependencies are installed"
      (pkgin "name=build-essential,ruby21-base state=present")
      (tags "setup"))
    (task "Ensure Sensu is installed"
      (gem "name=sensu state=" (jinja "{{ sensu_gem_state }}") " user_install=no")
      (tags "setup")
      (notify (list
          "restart sensu-client service")))
    (task "Ensure Sensu 'plugins' gem is installed"
      (gem "name=sensu-plugin state=" (jinja "{{ sensu_plugin_gem_state }}") " user_install=no")
      (tags "setup"))))
