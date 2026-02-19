(playbook "ansible-galaxy/tasks/main.yml"
  (tasks
    (task "Ensure that mutually exclusive options are not set"
      (assert 
        (that (list
            "(galaxy_manage_clone + galaxy_manage_download + galaxy_manage_existing) <= 1"))
        (fail_msg "\"Only one of variables galaxy_manage_clone, galaxy_manage_download and galaxy_manage_existing can be true.\"
"))
      (tags "always"))
    (task "Set privilege separation default variables"
      (set_fact 
        (__galaxy_remote_user (jinja "{{ ansible_user_id | default(omit) }}"))
        (__galaxy_become (jinja "{{ ansible_env.SUDO_USER is defined }}"))
        (__galaxy_become_user (jinja "{{ ansible_user_id | default(omit) }}")))
      (tags "always"))
    (task "Import layout variable tasks"
      (import_tasks "layout.yml")
      (tags "always"))
    (task "Build config facts for *_by_host variables"
      (import_tasks "config-facts.yml")
      (tags "always"))
    (task "Include user creation tasks"
      (include_tasks 
        (file "user.yml")
        (apply 
          (tags "galaxy_create_user")))
      (when "galaxy_create_user or galaxy_create_privsep_user")
      (tags (list
          "galaxy_create_user")))
    (task "Collect Galaxy user facts"
      (import_tasks "user-facts.yml")
      (tags "always"))
    (task "Include path management tasks"
      (include_tasks 
        (file "paths.yml")
        (apply 
          (tags "galaxy_manage_paths")))
      (when "galaxy_manage_paths")
      (tags (list
          "galaxy_manage_paths")))
    (task "Include clone tasks"
      (include_tasks 
        (file "clone.yml")
        (apply 
          (tags "galaxy_manage_clone")))
      (when "galaxy_manage_clone")
      (tags "galaxy_manage_clone"))
    (task "Include download tasks"
      (include_tasks 
        (file "download.yml")
        (apply 
          (tags "galaxy_manage_download")))
      (when "galaxy_manage_download")
      (tags "galaxy_manage_download"))
    (task "Include manage existing galaxy tasks"
      (include_tasks 
        (file "existing.yml")
        (apply 
          (tags "galaxy_manage_existing")))
      (when "galaxy_manage_existing")
      (tags "galaxy_manage_existing"))
    (task "Include static config setup tasks"
      (include_tasks 
        (file "static_setup.yml")
        (apply 
          (tags "galaxy_config_files")))
      (when "galaxy_manage_static_setup")
      (tags "galaxy_config_files"))
    (task "Include dependency setup tasks"
      (include_tasks 
        (file "dependencies.yml")
        (apply 
          (tags "galaxy_fetch_dependencies")))
      (when "galaxy_fetch_dependencies")
      (tags (list
          "galaxy_fetch_dependencies")))
    (task "Include mutable config setup tasks"
      (include_tasks 
        (file "mutable_setup.yml")
        (apply 
          (tags "galaxy_manage_mutable_setup")))
      (when "galaxy_manage_mutable_setup")
      (tags (list
          "galaxy_manage_mutable_setup")))
    (task "Include database management tasks"
      (include_tasks 
        (file "database.yml")
        (apply 
          (tags "galaxy_manage_database")))
      (when "galaxy_manage_database")
      (tags (list
          "galaxy_manage_database")))
    (task "Include client build tasks"
      (include_tasks 
        (file "client.yml")
        (apply 
          (tags "galaxy_build_client")))
      (when "galaxy_build_client")
      (tags (list
          "galaxy_build_client")))
    (task "Include error document setup tasks"
      (include_tasks 
        (file "errordocs.yml")
        (apply 
          (tags "galaxy_manage_errordocs")))
      (when "galaxy_manage_errordocs")
      (tags (list
          "galaxy_manage_errordocs")))
    (task "Include Gravity setup tasks"
      (include_tasks 
        (file "gravity.yml")
        (apply 
          (tags "galaxy_manage_gravity")))
      (when "galaxy_manage_gravity")
      (tags (list
          "galaxy_manage_gravity")))
    (task "Include systemd unit setup tasks (Galaxy)"
      (include_tasks 
        (file "systemd-galaxy.yml")
        (apply 
          (tags "galaxy_manage_systemd")))
      (when "galaxy_manage_systemd and galaxy_systemd_mode in [\"mule\", \"gravity\"]")
      (tags (list
          "galaxy_manage_systemd")))
    (task "Include systemd unit setup tasks (Reports)"
      (include_tasks 
        (file "systemd-reports.yml")
        (apply 
          (tags "galaxy_manage_systemd_reports")))
      (when "galaxy_manage_systemd_reports")
      (tags (list
          "galaxy_manage_systemd_reports")))
    (task "Include cleanup scheduling tasks"
      (include_tasks 
        (file "cleanup.yml")
        (apply 
          (tags "galaxy_manage_cleanup")))
      (when "galaxy_manage_cleanup")
      (tags (list
          "galaxy_manage_cleanup")))
    (task "Include static directory setup"
      (ansible.builtin.include_tasks "static_dirs.yml")
      (when "galaxy_manage_subdomain_static")
      (tags (list
          "galaxy_manage_subdomain_static")))
    (task "Include copy themes files"
      (ansible.builtin.include_tasks "themes.yml")
      (loop (jinja "{{ galaxy_themes_subdomains if galaxy_themes_subdomains|length or \\
    galaxy_manage_themes else [] }}"))
      (loop_control 
        (loop_var "subdomain"))
      (when "galaxy_manage_themes")
      (tags (list
          "galaxy_manage_themes")))
    (task "Set global host filters"
      (ansible.builtin.template 
        (src "global_host_filters.py.j2")
        (dest (jinja "{{ galaxy_themes_global_host_filters_path }}"))
        (mode "0644"))
      (when "galaxy_manage_host_filters"))))
