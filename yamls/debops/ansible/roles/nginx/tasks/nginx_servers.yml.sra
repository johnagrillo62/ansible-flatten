(playbook "debops/ansible/roles/nginx/tasks/nginx_servers.yml"
  (tasks
    (task "Create global webroot directories if allowed"
      (ansible.builtin.file 
        (path (jinja "{{ item.root | d(\"{}/sites/{}/{}\".format(nginx_www + (\"/\" + item.owner if item.owner | d() else \"\"),
                                                    (item.name if item.name is string else item.name[0]) | d(\"default\"),
                                                    item.public_dir_name | d(nginx_public_dir_name))) }}"))
        (state "directory")
        (owner (jinja "{{ item.owner | d(nginx_webroot_owner) }}"))
        (group (jinja "{{ item.group | d(item.owner | d(nginx_webroot_group)) }}"))
        (mode (jinja "{{ item.mode | d(nginx_webroot_mode) }}")))
      (loop (jinja "{{ q(\"flattened\", nginx__servers
                           + nginx__default_servers
                           + nginx__internal_servers
                           + nginx__dependent_servers
                           + nginx_servers | d([])
                           + nginx_default_servers | d([])
                           + nginx_internal_servers | d([])
                           + nginx_dependent_servers | d([])) }}"))
      (when "((item.webroot_create | d(nginx_webroot_create) | bool) and item.state | d('present') != 'absent')")
      (tags (list
          "role::nginx:servers")))
    (task "Create default welcome page if enabled"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", (item.welcome_template | d(nginx_welcome_template))) }}"))
        (dest (jinja "{{ item.root + \"/index.html\"
              if item.root | d()
              else (\"{}/sites/{}/{}/index.html\".format(nginx_www + (\"/\" + item.owner if item.owner | d() else \"\"),
                                                       (item.name if item.name is string else item.name[0]) | d(\"default\"),
                                                       item.public_dir_name | d(nginx_public_dir_name))) }}"))
        (owner (jinja "{{ item.owner | d(nginx_webroot_owner) }}"))
        (group (jinja "{{ item.group | d(item.owner | d(nginx_webroot_group)) }}"))
        (mode "0644")
        (force (jinja "{{ item.welcome_force | d() | bool }}")))
      (loop (jinja "{{ q(\"flattened\", nginx__servers
                           + nginx__default_servers
                           + nginx__internal_servers
                           + nginx__dependent_servers
                           + nginx_servers | d([])
                           + nginx_default_servers | d([])
                           + nginx_internal_servers | d([])
                           + nginx_dependent_servers | d([])) }}"))
      (when "((item.webroot_create | d(nginx_webroot_create) | bool) and item.state | d('present') != 'absent' and (item.delete is undefined or not item.delete | bool) and (item.welcome | d() | bool))")
      (tags (list
          "role::nginx:servers")))
    (task "Copy 'normalize.css' CSS file for welcome page"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"srv/www/sites/welcome/public/normalize.css\") }}"))
        (dest (jinja "{{ item.root + \"/normalize.css\"
              if item.root | d()
              else (\"{}/sites/{}/{}/normalize.css\".format(nginx_www + (\"/\" + item.owner if item.owner | d() else \"\"),
                                                          (item.name if item.name is string else item.name[0]) | d(\"default\"),
                                                          item.public_dir_name | d(nginx_public_dir_name))) }}"))
        (owner (jinja "{{ item.owner | d(nginx_webroot_owner) }}"))
        (group (jinja "{{ item.group | d(item.owner | d(nginx_webroot_group)) }}"))
        (mode "0644")
        (force (jinja "{{ item.welcome_force | d() | bool }}")))
      (loop (jinja "{{ q(\"flattened\", nginx__servers
                           + nginx__default_servers
                           + nginx__internal_servers
                           + nginx__dependent_servers
                           + nginx_servers | d([])
                           + nginx_default_servers | d([])
                           + nginx_internal_servers | d([])
                           + nginx_dependent_servers | d([])) }}"))
      (when "((item.webroot_create | d(nginx_webroot_create) | bool) and item.state | d('present') != 'absent' and (item.delete is undefined or not item.delete | bool) and (item.welcome | d() | bool))")
      (tags (list
          "role::nginx:servers")))
    (task "Remove nginx server configuration if requested"
      (ansible.builtin.file 
        (path "/etc/nginx/sites-available/" (jinja "{{ item.filename | d(item.name
                                                           if item.name is string
                                                           else item.name[0] | d(\"default\")) }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nginx__servers
                           + nginx__default_servers
                           + nginx__internal_servers
                           + nginx__dependent_servers
                           + nginx_servers | d([])
                           + nginx_default_servers | d([])
                           + nginx_internal_servers | d([])
                           + nginx_dependent_servers | d([])) }}"))
      (when "(item.name is defined and ((item.state | d(\"present\") == 'absent') or (item.delete | d() | bool)))")
      (tags (list
          "role::nginx:servers")))
    (task "Get last used HTTP default_server for default_server roulette"
      (ansible.builtin.set_fact 
        (nginx_register_default_server_saved (jinja "{{ ansible_local.nginx.default_server }}")))
      (when "(ansible_local is defined and ansible_local.nginx is defined and ansible_local.nginx.default_server is defined)")
      (tags (list
          "role::nginx:servers")))
    (task "Get last used HTTPS default_server for default_server roulette"
      (ansible.builtin.set_fact 
        (nginx_register_default_server_ssl_saved (jinja "{{ ansible_local.nginx.default_server_ssl }}")))
      (when "(ansible_local is defined and ansible_local.nginx is defined and ansible_local.nginx.default_server_ssl is defined)")
      (tags (list
          "role::nginx:servers")))
    (task "Get HTTP server from nginx defaults for default_server roulette"
      (ansible.builtin.set_fact 
        (nginx_register_default_server_name (jinja "{{ nginx_default_name }}")))
      (when "nginx_default_name is defined and nginx_default_name")
      (tags (list
          "role::nginx:servers")))
    (task "Get HTTPS server from nginx defaults for default_server roulette"
      (ansible.builtin.set_fact 
        (nginx_register_default_server_ssl_name (jinja "{{ nginx_default_ssl_name }}")))
      (when "nginx_default_ssl_name is defined and nginx_default_ssl_name")
      (tags (list
          "role::nginx:servers")))
    (task "Get first server that listens on http port for default_server roulette"
      (ansible.builtin.set_fact 
        (nginx_register_default_server_http (jinja "{{ item.name if item.name is string else item.name[0] | d(\"default\") }}")))
      (loop (jinja "{{ q(\"flattened\", (nginx__servers + nginx__default_servers + nginx__internal_servers + nginx__dependent_servers
                            + nginx_servers | d([]) + nginx_default_servers | d([])
                            + nginx_internal_servers | d([]) + nginx_dependent_servers | d([]))[::-1]) }}"))
      (when "(item.state | d('present') != 'absent' and (item.enabled | d(True) | bool) and (item.listen | d(True)) and ((item.ssl is undefined or not item.ssl | bool) or not nginx_pki | bool))")
      (tags (list
          "role::nginx:servers")))
    (task "Get first server that listens on https port for default_server roulette"
      (ansible.builtin.set_fact 
        (nginx_register_default_server_https (jinja "{{ item.name if item.name is string else item.name[0] | d(\"default\") }}")))
      (loop (jinja "{{ q(\"flattened\", (nginx__servers + nginx__default_servers + nginx__internal_servers + nginx__dependent_servers
                            + nginx_servers | d([]) + nginx_default_servers | d([])
                            + nginx_internal_servers | d([]) + nginx_dependent_servers | d([]))[::-1]) }}"))
      (when "(item.state | d('present') != 'absent' and (item.enabled is undefined or item.enabled | bool) and (item.listen_ssl is undefined or item.listen_ssl | d()) and ((item.ssl | d() and item.ssl | bool) or (item.ssl is undefined and nginx_pki | bool)))")
      (tags (list
          "role::nginx:servers")))
    (task "Spin the HTTP default_server roulette!"
      (ansible.builtin.set_fact 
        (nginx_register_default_server (jinja "{{ nginx_register_default_server_saved |
                                         default(nginx_register_default_server_name |
                                           default(nginx_register_default_server_http |
                                             default(\"\"))) }}")))
      (tags (list
          "role::nginx:servers")))
    (task "Spin the HTTPS default_server roulette!"
      (ansible.builtin.set_fact 
        (nginx_register_default_server_ssl (jinja "{{ nginx_register_default_server_ssl_saved |
                                             default(nginx_register_default_server_ssl_name |
                                               default(nginx_register_default_server_https |
                                                 default(\"\"))) }}")))
      (tags (list
          "role::nginx:servers")))
    (task "Generate nginx server configuration"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/nginx/sites-available/\" + (item.type | d(nginx_default_type)) + \".conf.j2\") }}"))
        (dest "/etc/nginx/sites-available/" (jinja "{{ item.filename | d(item.name
                                                           if item.name is string
                                                           else item.name[0] | d(\"default\")) }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", nginx__servers
                           + nginx__default_servers
                           + nginx__internal_servers
                           + nginx__dependent_servers
                           + nginx_servers | d([])
                           + nginx_default_servers | d([])
                           + nginx_internal_servers | d([])
                           + nginx_dependent_servers | d([])) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.state | d('present') != 'absent' and (item.delete is undefined or not item.delete | bool))")
      (tags (list
          "role::nginx:servers")))
    (task "Disable nginx server configuration"
      (ansible.builtin.file 
        (path "/etc/nginx/sites-enabled/" (jinja "{{ item.filename
                                       | d(item.name if item.name is string else item.name[0] | d(\"default\")) }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nginx__servers
                           + nginx__default_servers
                           + nginx__internal_servers
                           + nginx__dependent_servers
                           + nginx_servers | d([])
                           + nginx_default_servers | d([])
                           + nginx_internal_servers | d([])
                           + nginx_dependent_servers | d([])) }}"))
      (notify (list
          "Test nginx and restart"))
      (when "(item.name is defined and ((item.state | d(\"present\") == 'absent') or (item.enabled | d() and not item.enabled | bool) or (item.delete | d() | bool)))")
      (tags (list
          "role::nginx:servers")))
    (task "Test if Ansible is running in check mode"
      (ansible.builtin.command "/bin/true")
      (changed_when "False")
      (register "nginx__register_check_mode")
      (tags (list
          "role::nginx:servers")))
    (task "Save fact if Ansible is running in check mode in variable"
      (ansible.builtin.set_fact 
        (nginx__fact_check_mode (jinja "{{ nginx__register_check_mode is skipped }}")))
      (tags (list
          "role::nginx:servers")))
    (task "Enable nginx server configuration"
      (ansible.builtin.file 
        (path "/etc/nginx/sites-enabled/" (jinja "{{ item.filename
                                       | d(item.name if item.name is string else item.name[0] | d(\"default\")) }}") ".conf")
        (src "/etc/nginx/sites-available/" (jinja "{{ item.filename
                                        | d(item.name if item.name is string else item.name[0] | d(\"default\")) }}") ".conf")
        (state "link")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", nginx__servers
                           + nginx__default_servers
                           + nginx__internal_servers
                           + nginx__dependent_servers
                           + nginx_servers | d([])
                           + nginx_default_servers | d([])
                           + nginx_internal_servers | d([])
                           + nginx_dependent_servers | d([])) }}"))
      (notify (list
          "Test nginx and restart"))
      (when "(item.state | d('present') != 'absent' and (item.enabled | d(True) | bool) and (item.delete is undefined or not item.delete | bool) and not nginx__fact_check_mode | bool)")
      (tags (list
          "role::nginx:servers")))))
