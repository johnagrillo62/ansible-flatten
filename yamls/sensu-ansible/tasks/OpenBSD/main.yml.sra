(playbook "sensu-ansible/tasks/OpenBSD/main.yml"
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
    (task "Install prerequisite packages"
      (openbsd_pkg 
        (name (jinja "{{ item }}"))
        (state "present"))
      (tags "setup")
      (loop (list
          "bash"
          "ruby%2.3")))
    (task "Get the current version of rubygems"
      (command "/usr/local/bin/gem23 --version")
      (tags "setup")
      (check_mode "no")
      (register "gem23_version")
      (changed_when "False"))
    (task "Update rubygems to work around rubygems/rubygems/issues/1448"
      (command "/usr/local/bin/gem23 update --system")
      (tags "setup")
      (when "gem23_version.stdout is version('2.5.3', '<')"))
    (task "Install sensu gem and all of its dependencies"
      (gem 
        (name "sensu")
        (repository (jinja "{{ sensu_gem_repository | default('https://api.rubygems.org/') }}"))
        (user_install "no")
        (version (jinja "{{ sensu_gem_version }}"))
        (executable "/usr/local/bin/gem23"))
      (tags "setup"))
    (task "Create the sensu log folder"
      (file 
        (path "/var/log/sensu")
        (owner "root")
        (group "wheel")
        (state "directory"))
      (tags "setup"))
    (task "Deploy OpenBSD rc script"
      (template 
        (src "sensuclient_openbsd.j2")
        (dest "/etc/rc.d/sensuclient")
        (owner "root")
        (group "wheel")
        (mode "0755"))
      (tags "setup"))))
