(playbook "kubespray/roles/download/tasks/download_file.yml"
  (tasks
    (task "Download_file | download " (jinja "{{ download.dest }}")
      (block (list
          
          (name "Prep_download | Set a few facts")
          (set_fact 
            (download_force_cache (jinja "{{ true if download_run_once else download_force_cache }}")))
          
          (name "Download_file | Show url of file to download")
          (when "unsafe_show_logs | bool")
          (debug 
            (msg (jinja "{{ download.url }}")))
          (run_once (jinja "{{ download_run_once }}"))
          
          (name "Download_file | Set pathname of cached file")
          (set_fact 
            (file_path_cached (jinja "{{ download_cache_dir }}") "/" (jinja "{{ download.dest | basename }}")))
          (tags (list
              "facts"))
          
          (name "Download_file | Create dest directory on node")
          (file 
            (path (jinja "{{ download.dest | dirname }}"))
            (owner (jinja "{{ download.owner | default(omit) }}"))
            (mode "0755")
            (state "directory")
            (recurse "true"))
          
          (name "Download_file | Create local cache directory")
          (file 
            (path (jinja "{{ file_path_cached | dirname }}"))
            (state "directory")
            (recurse "true"))
          (delegate_to "localhost")
          (connection "local")
          (delegate_facts "false")
          (run_once "true")
          (become "false")
          (when (list
              "download_force_cache"))
          (tags (list
              "localhost"))
          
          (name "Download_file | Create cache directory on download_delegate host")
          (file 
            (path (jinja "{{ file_path_cached | dirname }}"))
            (state "directory")
            (recurse "true"))
          (delegate_to (jinja "{{ download_delegate }}"))
          (delegate_facts "false")
          (run_once "true")
          (when (list
              "download_force_cache"
              "not download_localhost"))
          
          (name "Download_file | Download item")
          (get_url 
            (url (jinja "{{ download.url }}"))
            (dest (jinja "{{ file_path_cached if download_force_cache else download.dest }}"))
            (owner (jinja "{{ omit if download_localhost else (download.owner | default(omit)) }}"))
            (mode (jinja "{{ omit if download_localhost else (download.mode | default(omit)) }}"))
            (checksum (jinja "{{ download.checksum }}"))
            (validate_certs (jinja "{{ download_validate_certs }}"))
            (url_username (jinja "{{ download.username | default(omit) }}"))
            (url_password (jinja "{{ download.password | default(omit) }}"))
            (force_basic_auth (jinja "{{ download.force_basic_auth | default(omit) }}"))
            (timeout (jinja "{{ download.timeout | default(omit) }}")))
          (delegate_to (jinja "{{ download_delegate if download_force_cache else inventory_hostname }}"))
          (run_once (jinja "{{ download_force_cache }}"))
          (register "get_url_result")
          (become (jinja "{{ not download_localhost }}"))
          (until "'OK' in get_url_result.msg or 'file already exists' in get_url_result.msg or get_url_result.status_code | default() == 304")
          (retries (jinja "{{ download_retries }}"))
          (delay (jinja "{{ retry_stagger | default(5) }}"))
          (environment (jinja "{{ proxy_env }}"))
          (no_log (jinja "{{ not (unsafe_show_logs | bool) }}"))
          
          (name "Download_file | Copy file back to ansible host file cache")
          (ansible.posix.synchronize 
            (src (jinja "{{ file_path_cached }}"))
            (dest (jinja "{{ file_path_cached }}"))
            (use_ssh_args "true")
            (mode "pull"))
          (when (list
              "download_force_cache"
              "not download_localhost"
              "download_delegate == inventory_hostname"))
          
          (name "Download_file | Copy file from cache to nodes, if it is available")
          (ansible.posix.synchronize 
            (src (jinja "{{ file_path_cached }}"))
            (dest (jinja "{{ download.dest }}"))
            (use_ssh_args "true")
            (mode "push"))
          (register "get_task")
          (until "get_task is succeeded")
          (delay (jinja "{{ retry_stagger | random + 3 }}"))
          (retries (jinja "{{ download_retries }}"))
          (when (list
              "download_force_cache"))
          
          (name "Download_file | Set mode and owner")
          (file 
            (path (jinja "{{ download.dest }}"))
            (mode (jinja "{{ download.mode | default(omit) }}"))
            (owner (jinja "{{ download.owner | default(omit) }}")))
          (when (list
              "download_force_cache"))
          
          (name "Download_file | Extract file archives")
          (include_tasks "extract_file.yml")))
      (tags (list
          "download")))))
