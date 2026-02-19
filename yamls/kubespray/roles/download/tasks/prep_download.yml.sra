(playbook "kubespray/roles/download/tasks/prep_download.yml"
  (tasks
    (task "Prep_download | Set a few facts"
      (set_fact 
        (download_force_cache (jinja "{{ true if download_run_once else download_force_cache }}")))
      (tags (list
          "facts")))
    (task "Prep_download | On localhost, check if passwordless root is possible"
      (command "true")
      (connection "local")
      (delegate_to "localhost")
      (run_once "true")
      (register "test_become")
      (changed_when "false")
      (ignore_errors "true")
      (become "true")
      (when (list
          "download_localhost"))
      (tags (list
          "localhost"
          "asserts")))
    (task "Prep_download | On localhost, check if user has access to the container runtime without using sudo"
      (shell (jinja "{{ image_info_command_on_localhost }}"))
      (connection "local")
      (delegate_to "localhost")
      (run_once "true")
      (register "test_docker")
      (changed_when "false")
      (ignore_errors "true")
      (become "false")
      (when (list
          "download_localhost"))
      (tags (list
          "localhost"
          "asserts")))
    (task "Prep_download | Parse the outputs of the previous commands"
      (set_fact 
        (user_in_docker_group (jinja "{{ not test_docker.failed }}"))
        (user_can_become_root (jinja "{{ not test_become.failed }}")))
      (when (list
          "download_localhost"))
      (tags (list
          "localhost"
          "asserts")))
    (task "Prep_download | Check that local user is in group or can become root"
      (assert 
        (that "user_in_docker_group or user_can_become_root")
        (msg "Error: User is not in docker group and cannot become root. When download_localhost is true, at least one of these two conditions must be met."))
      (when (list
          "download_localhost"))
      (tags (list
          "localhost"
          "asserts")))
    (task "Prep_download | Register docker images info"
      (shell (jinja "{{ image_info_command }}"))
      (no_log (jinja "{{ not (unsafe_show_logs | bool) }}"))
      (register "docker_images")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false")
      (when "download_container"))
    (task "Prep_download | Create staging directory on remote node"
      (file 
        (path (jinja "{{ local_release_dir }}") "/images")
        (state "directory")
        (mode "0755")
        (owner (jinja "{{ ansible_ssh_user | default(ansible_user_id) }}")))
      (when (list
          "ansible_os_family not in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]")))
    (task "Prep_download | Create local cache for files and images on control node"
      (file 
        (path (jinja "{{ download_cache_dir }}") "/images")
        (state "directory")
        (mode "0755"))
      (connection "local")
      (delegate_facts "false")
      (delegate_to "localhost")
      (run_once "true")
      (become "false")
      (when "download_force_cache or download_run_once")
      (tags (list
          "localhost")))))
