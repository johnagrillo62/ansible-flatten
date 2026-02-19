(playbook "kubespray/roles/download/tasks/download_container.yml"
  (tasks
    (task
      (block (list
          
          (name "Set default values for flag variables")
          (set_fact 
            (image_is_cached "false")
            (image_changed "false")
            (pull_required (jinja "{{ download_always_pull }}")))
          (tags (list
              "facts"))
          
          (name "Download_container | Set a few facts")
          (import_tasks "set_container_facts.yml")
          (tags (list
              "facts"))
          
          (name "Download_container | Prepare container download")
          (include_tasks "check_pull_required.yml")
          (when (list
              "not download_always_pull"))
          
          (debug 
            (msg "Pull " (jinja "{{ image_reponame }}") " required is: " (jinja "{{ pull_required }}")))
          
          (name "Download_container | Determine if image is in cache")
          (stat 
            (path (jinja "{{ image_path_cached }}"))
            (get_attributes "false")
            (get_checksum "false")
            (get_mime "false"))
          (delegate_to "localhost")
          (connection "local")
          (delegate_facts "false")
          (register "cache_image")
          (changed_when "false")
          (become "false")
          (when (list
              "download_force_cache"))
          
          (name "Download_container | Set fact indicating if image is in cache")
          (set_fact 
            (image_is_cached (jinja "{{ cache_image.stat.exists }}")))
          (tags (list
              "facts"))
          (when (list
              "download_force_cache"))
          
          (name "Stop if image not in cache on ansible host when download_force_cache=true")
          (assert 
            (that "image_is_cached")
            (msg "Image cache file " (jinja "{{ image_path_cached }}") " not found for " (jinja "{{ image_reponame }}") " on localhost"))
          (when (list
              "download_force_cache"
              "not download_run_once"))
          
          (name "Download_container | Download image if required")
          (command (jinja "{{ image_pull_command_on_localhost if download_localhost else image_pull_command }}") " " (jinja "{{ image_reponame }}"))
          (delegate_to (jinja "{{ download_delegate if download_run_once else inventory_hostname }}"))
          (delegate_facts "true")
          (run_once (jinja "{{ download_run_once }}"))
          (register "pull_task_result")
          (until "pull_task_result is succeeded")
          (delay (jinja "{{ retry_stagger | random + 3 }}"))
          (retries (jinja "{{ download_retries }}"))
          (become (jinja "{{ user_can_become_root | default(false) or not download_localhost }}"))
          (environment (jinja "{{ proxy_env if container_manager == 'containerd' else omit }}"))
          (when (list
              "pull_required or download_run_once"
              "not image_is_cached"))
          
          (name "Download_container | Save and compress image")
          (shell (jinja "{{ image_save_command_on_localhost if download_localhost else image_save_command }}"))
          (delegate_to (jinja "{{ download_delegate }}"))
          (delegate_facts "false")
          (register "container_save_status")
          (failed_when "container_save_status.stderr")
          (run_once "true")
          (become (jinja "{{ user_can_become_root | default(false) or not download_localhost }}"))
          (when (list
              "not image_is_cached"
              "download_run_once"))
          
          (name "Download_container | Copy image to ansible host cache")
          (ansible.posix.synchronize 
            (src (jinja "{{ image_path_final }}"))
            (dest (jinja "{{ image_path_cached }}"))
            (use_ssh_args "true")
            (mode "pull"))
          (when (list
              "not image_is_cached"
              "download_run_once"
              "not download_localhost"
              "download_delegate == inventory_hostname"))
          
          (name "Download_container | Upload image to node if it is cached")
          (ansible.posix.synchronize 
            (src (jinja "{{ image_path_cached }}"))
            (dest (jinja "{{ image_path_final }}"))
            (use_ssh_args "true")
            (mode "push"))
          (delegate_facts "false")
          (register "upload_image")
          (failed_when "not upload_image")
          (until "upload_image is succeeded")
          (retries (jinja "{{ download_retries }}"))
          (delay (jinja "{{ retry_stagger | random + 3 }}"))
          (when (list
              "pull_required"
              "download_force_cache"))
          
          (name "Download_container | Load image into the local container registry")
          (shell (jinja "{{ image_load_command }}"))
          (register "container_load_status")
          (failed_when "container_load_status is failed")
          (when (list
              "pull_required"
              "download_force_cache"))
          
          (name "Download_container | Remove container image from cache")
          (file 
            (state "absent")
            (path (jinja "{{ image_path_final }}")))
          (when (list
              "not download_keep_remote_cache"))))
      (tags (list
          "download")))))
