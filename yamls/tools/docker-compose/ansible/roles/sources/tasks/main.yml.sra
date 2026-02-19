(playbook "tools/docker-compose/ansible/roles/sources/tasks/main.yml"
  (tasks
    (task "Create _sources directories"
      (file 
        (path (jinja "{{ sources_dest }}") "/" (jinja "{{ item }}"))
        (state "directory")
        (mode "0700"))
      (loop (list
          "secrets"
          "receptor")))
    (task "Detect secrets"
      (stat 
        (path (jinja "{{ sources_dest }}") "/secrets/" (jinja "{{ item }}") ".yml"))
      (register "secrets")
      (when "not lookup('vars', item, default='')")
      (loop (list
          "pg_password"
          "secret_key"
          "broadcast_websocket_secret"
          "admin_password")))
    (task "Generate secrets if needed"
      (template 
        (src "secrets.yml.j2")
        (dest (jinja "{{ sources_dest }}") "/secrets/" (jinja "{{ item.item }}") ".yml")
        (mode "0600"))
      (when "not lookup('vars', item.item, default='') and not item.stat.exists")
      (loop (jinja "{{ secrets.results }}"))
      (loop_control 
        (label (jinja "{{ item.item }}"))))
    (task "Include generated secrets unless they are explicitly passed in"
      (include_vars (jinja "{{ sources_dest }}") "/secrets/" (jinja "{{ item.item }}") ".yml")
      (no_log "true")
      (when "not lookup('vars', item.item, default='')")
      (loop (jinja "{{ secrets.results }}")))
    (task "Write out SECRET_KEY"
      (copy 
        (content (jinja "{{ secret_key }}"))
        (dest (jinja "{{ sources_dest }}") "/SECRET_KEY"))
      (no_log "true"))
    (task "Find custom error pages"
      (set_fact 
        (custom_error_pages (jinja "{{ (custom_error_pages | default([])) + [new_error_page] }}")))
      (vars 
        (new_error_page 
          (error_code (jinja "{{ item | basename() | regex_replace('custom_(\\\\d+).html', '\\\\1') }}"))
          (web_path (jinja "{{ item | regex_replace('^.*/static', '/static') }}"))))
      (loop (jinja "{{ lookup('ansible.builtin.fileglob', playbook_dir + '/../../../awx/static/custom_*.html', wantlist=True) }}"))
      (when "(item | basename()) is regex(\"custom_\\d+\\.html\")"))
    (task "Render configuration templates"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ sources_dest }}") "/" (jinja "{{ item }}"))
        (mode "0600"))
      (with_items (list
          "database.py"
          "local_settings.py"
          "websocket_secret.py"
          "haproxy.cfg"
          "nginx.conf"
          "nginx.locations.conf")))
    (task "Get OS info for sdb"
      (shell "docker info 2> /dev/null | awk '/Os:/ { gsub(/Os:/, \"Operating System:\"); }/Operating System/ { print; }'
")
      (register "os_info")
      (changed_when "false"))
    (task "Get user UID"
      (shell "id -u")
      (register "current_user")
      (changed_when "false"))
    (task "Set fact with user UID"
      (set_fact 
        (user_id "'" (jinja "{{ current_user.stdout }}") "'")))
    (task "Set global version if not provided"
      (set_fact 
        (awx_image_tag (jinja "{{ lookup('file', playbook_dir + '/../../../VERSION') }}")))
      (when "awx_image_tag is not defined"))
    (task "Generate Private RSA key for signing work"
      (command "openssl genrsa -out " (jinja "{{ work_sign_private_keyfile }}") " " (jinja "{{ receptor_rsa_bits }}"))
      (args 
        (creates (jinja "{{ work_sign_private_keyfile }}")))
      (when "sign_work | bool"))
    (task "Generate public RSA key for signing work"
      (command "openssl rsa -in " (jinja "{{ work_sign_private_keyfile }}") " -out " (jinja "{{ work_sign_public_keyfile }}") " -outform PEM -pubout")
      (args 
        (creates (jinja "{{ work_sign_public_keyfile }}")))
      (when "sign_work | bool"))
    (task "Include vault TLS tasks if enabled"
      (include_tasks "vault_tls.yml")
      (when "enable_vault | bool"))
    (task "Iterate through ../editable_dependencies and get symlinked directories and register the paths"
      (find 
        (paths (jinja "{{ playbook_dir }}") "/../editable_dependencies")
        (file_type "link")
        (recurse "no"))
      (register "_editable_dependencies_links")
      (when "install_editable_dependencies | bool"))
    (task "Warn about empty editable_dependnecies"
      (fail 
        (msg "[WARNING] No editable_dependencies found in ../editable_dependencies"))
      (when "install_editable_dependencies | bool and not _editable_dependencies_links.files")
      (ignore_errors "true"))
    (task "Set fact with editable_dependencies"
      (set_fact 
        (editable_dependencies (jinja "{{ _editable_dependencies_links.files | map(attribute='path') | list }}")))
      (when "install_editable_dependencies | bool and _editable_dependencies_links.files"))
    (task "Set install_editable_dependnecies to false if no editable_dependencies are found"
      (set_fact 
        (install_editable_dependencies "false"))
      (when "install_editable_dependencies | bool and not _editable_dependencies_links.files"))
    (task "Render Docker-Compose"
      (template 
        (src "docker-compose.yml.j2")
        (dest (jinja "{{ sources_dest }}") "/" (jinja "{{ compose_name }}"))
        (mode "0600")))
    (task "Render Receptor Config(s) for Control Plane"
      (template 
        (src "receptor-awx.conf.j2")
        (dest (jinja "{{ sources_dest }}") "/receptor/receptor-awx-" (jinja "{{ item }}") ".conf")
        (mode "0600"))
      (with_sequence "start=1 end=" (jinja "{{ control_plane_node_count }}")))
    (task "Create Receptor Config Lock File"
      (file 
        (path (jinja "{{ sources_dest }}") "/receptor/receptor-awx-" (jinja "{{ item }}") ".conf.lock")
        (state "touch")
        (mode "0600"))
      (with_sequence "start=1 end=" (jinja "{{ control_plane_node_count }}")))
    (task "Render Receptor Config(s) for Control Plane"
      (template 
        (src "receptor-awx.conf.j2")
        (dest (jinja "{{ sources_dest }}") "/receptor/receptor-awx-" (jinja "{{ item }}") ".conf")
        (mode "0600"))
      (with_sequence "start=1 end=" (jinja "{{ control_plane_node_count }}")))
    (task "Render Receptor Hop Config"
      (template 
        (src "receptor-hop.conf.j2")
        (dest (jinja "{{ sources_dest }}") "/receptor/receptor-hop.conf")
        (mode "0600"))
      (when (list
          "execution_node_count | int > 0")))
    (task "Render Receptor Worker Config(s)"
      (template 
        (src "receptor-worker.conf.j2")
        (dest (jinja "{{ sources_dest }}") "/receptor/receptor-worker-" (jinja "{{ item }}") ".conf")
        (mode "0600"))
      (with_sequence "start=1 end=" (jinja "{{ execution_node_count if execution_node_count | int > 0 else 1}}"))
      (when "execution_node_count | int > 0"))
    (task "Render prometheus config"
      (template 
        (src "prometheus.yml.j2")
        (dest (jinja "{{ sources_dest }}") "/prometheus.yml"))
      (when "enable_prometheus|bool"))))
