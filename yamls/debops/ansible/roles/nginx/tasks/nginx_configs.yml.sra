(playbook "debops/ansible/roles/nginx/tasks/nginx_configs.yml"
  (tasks
    (task "Make sure configuration directory exists"
      (ansible.builtin.file 
        (path "/etc/nginx/conf.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "role::nginx:servers")))
    (task "Remove nginx maps if requested"
      (ansible.builtin.file 
        (dest "/etc/nginx/conf.d/map_" (jinja "{{ item.name }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nginx__maps
                           + nginx__default_maps
                           + nginx__dependent_maps
                           + nginx_maps | d([])
                           + nginx_default_maps | d([])
                           + nginx_dependent_maps | d([])) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.name | d() and ((item.state | d() and item.state == 'absent') or (item.delete | d() and item.delete | bool)))")
      (tags (list
          "role::nginx:servers")))
    (task "Configure nginx maps"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/nginx/conf.d/map.conf.j2\") }}"))
        (dest "/etc/nginx/conf.d/map_" (jinja "{{ item.name }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", nginx__maps
                           + nginx__default_maps
                           + nginx__dependent_maps
                           + nginx_maps | d([])
                           + nginx_default_maps | d([])
                           + nginx_dependent_maps | d([])) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.name | d() and item.state | d('present') != 'absent' and (item.delete is undefined or not item.delete | bool))")
      (tags (list
          "role::nginx:servers")))
    (task "Remove nginx upstreams if requested"
      (ansible.builtin.file 
        (dest "/etc/nginx/conf.d/upstream_" (jinja "{{ item.name }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nginx__upstreams
                           + nginx__default_upstreams
                           + nginx__dependent_upstreams
                           + nginx_upstreams | d([])
                           + nginx_default_upstreams | d([])
                           + nginx_dependent_upstreams | d([])) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.name | d() and ((item.state | d('present') == 'absent') or (item.delete | d() and item.delete | bool)))")
      (tags (list
          "role::nginx:servers")))
    (task "Configure nginx upstreams"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/nginx/conf.d/upstream_\" + (item.type | d(\"default\")) + \".conf.j2\") }}"))
        (dest "/etc/nginx/conf.d/upstream_" (jinja "{{ item.name }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", nginx__upstreams
                           + nginx__default_upstreams
                           + nginx__dependent_upstreams
                           + nginx_upstreams | d([])
                           + nginx_default_upstreams | d([])
                           + nginx_dependent_upstreams | d([])) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.name | d() and item.state | d('present') != 'absent' and (item.delete is undefined or not item.delete | bool))")
      (tags (list
          "role::nginx:servers")))
    (task "Remove nginx log_format if requested"
      (ansible.builtin.file 
        (dest "/etc/nginx/conf.d/log_" (jinja "{{ item.name }}") ".conf")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nginx__log_format
                           + nginx__dependent_log_format) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.name | d() and ((item.state | d('present') == 'absent') or (item.delete | d() and item.delete | bool)))")
      (tags (list
          "role::nginx:servers")))
    (task "Configure nginx log_format"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/nginx/conf.d/log_format.conf.j2\") }}"))
        (dest "/etc/nginx/conf.d/log_" (jinja "{{ item.name }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", nginx__log_format
                           + nginx__dependent_log_format) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.name | d() and item.state | d('present') != 'absent' and (item.delete is undefined or not item.delete | bool))")
      (tags (list
          "role::nginx:servers")))
    (task "Remove custom nginx configuration if requested"
      (ansible.builtin.file 
        (dest "/etc/nginx/conf.d/" (jinja "{{ item.filename | d(\"custom_\" + item.name + \".conf\") }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", nginx__custom_config
                           + nginx_custom_config | d([])) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.name | d() and ((item.state | d() and item.state == 'absent') or (item.delete | d() and item.delete | bool)))")
      (tags (list
          "role::nginx:servers")))
    (task "Add custom nginx configuration"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/nginx/conf.d/custom.conf.j2\") }}"))
        (dest "/etc/nginx/conf.d/" (jinja "{{ item.filename | d(\"custom_\" + item.name + \".conf\") }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", nginx__custom_config
                           + nginx_custom_config | d([])) }}"))
      (notify (list
          "Test nginx and reload"))
      (when "(item.name | d() and item.state | d('present') != 'absent' and (item.delete is undefined or not item.delete | bool))")
      (tags (list
          "role::nginx:servers")))))
