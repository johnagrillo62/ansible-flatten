(playbook "debops/ansible/roles/redis_server/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install Redis Server packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (redis_server__base_packages
                              + redis_server__packages)) }}"))
        (state "present"))
      (register "redis_server__register_packages")
      (until "redis_server__register_packages is succeeded"))
    (task "Ensure that standalone Redis Server is stopped on install"
      (ansible.builtin.systemd 
        (name "redis-server.service")
        (state "stopped"))
      (when "((ansible_local is undefined or ansible_local.redis_server is undefined) and ansible_service_mgr == 'systemd')"))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Setup Redis local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/redis_server.fact.j2")
        (dest "/etc/ansible/facts.d/redis_server.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Install custom Redis scripts"
      (ansible.builtin.copy 
        (src "usr/local/bin/")
        (dest "/usr/local/bin/")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create Redis auth UNIX group"
      (ansible.builtin.group 
        (name (jinja "{{ redis_server__auth_group }}"))
        (state "present")
        (system "True")))
    (task "Create Redis instance directories"
      (ansible.builtin.file 
        (path "/etc/redis/" (jinja "{{ item.name }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'init', 'ignore']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Install the original Redis config file to instance"
      (ansible.builtin.command "install -o " (jinja "{{ redis_server__user }}") " -g " (jinja "{{ redis_server__auth_group }}") " -m 0640 /etc/redis/redis.conf /etc/redis/" (jinja "{{ item.name }}") "/redis.conf")
      (args 
        (creates "/etc/redis/" (jinja "{{ item.name }}") "/redis.conf"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'init', 'ignore']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate dynamic Redis configuration scripts"
      (ansible.builtin.template 
        (src "etc/redis/instance/ansible-redis-dynamic.conf.j2")
        (dest "/etc/redis/" (jinja "{{ item.name }}") "/ansible-redis-dynamic.conf")
        (owner "root")
        (group (jinja "{{ redis_server__group }}"))
        (mode "0750"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'init', 'ignore']")
      (register "redis_server__register_config_dynamic")
      (notify (list
          "Refresh host facts"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate static Redis configuration files"
      (ansible.builtin.template 
        (src "etc/redis/instance/ansible-redis-static.conf.j2")
        (dest "/etc/redis/" (jinja "{{ item.name }}") "/ansible-redis-static.conf")
        (owner "root")
        (group (jinja "{{ redis_server__group }}"))
        (mode "0640"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'init', 'ignore']")
      (register "redis_server__register_config_static")
      (notify (list
          "Refresh host facts"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove include line from redis.conf"
      (ansible.builtin.lineinfile 
        (dest "/etc/redis/" (jinja "{{ item.item.name }}") "/redis.conf")
        (regexp "^include\\s+/etc/redis/" (jinja "{{ item.item.name }}") "/ansible-redis-static.conf")
        (state "absent"))
      (with_items (jinja "{{ redis_server__register_config_static.results }}"))
      (when "item is changed")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Add include line into redis.conf"
      (ansible.builtin.lineinfile 
        (dest "/etc/redis/" (jinja "{{ item.item.name }}") "/redis.conf")
        (regexp "^include\\s+/etc/redis/" (jinja "{{ item.item.name }}") "/ansible-redis-static.conf")
        (line "include /etc/redis/" (jinja "{{ item.item.name }}") "/ansible-redis-static.conf")
        (insertafter "EOF")
        (state "present")
        (mode "0640"))
      (with_items (jinja "{{ redis_server__register_config_static.results }}"))
      (when "not ansible_check_mode | bool and item is changed")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Install custom systemd unit files"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "etc/systemd/system/redis-server@.service"
          "etc/systemd/system/redis-server.service"))
      (notify (list
          "Reload service manager")))
    (task "Create systemd override directories for instances"
      (ansible.builtin.file 
        (path "/etc/systemd/system/redis-server@" (jinja "{{ item.name }}") ".service.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'init', 'ignore'] and item.systemd_override | d()")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Generate systemd instance override files"
      (ansible.builtin.template 
        (src "etc/systemd/system/redis-server@.service.d/ansible-override.conf.j2")
        (dest "/etc/systemd/system/redis-server@" (jinja "{{ item.name }}") ".service.d/ansible-override.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') not in ['absent', 'init', 'ignore'] and item.systemd_override | d()")
      (notify (list
          "Reload service manager"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Stop Redis instances if requested"
      (ansible.builtin.systemd 
        (name "redis-server@" (jinja "{{ item.name }}") ".service")
        (state "stopped")
        (enabled "False"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') == 'absent'")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove Redis instance systemd override if requested"
      (ansible.builtin.file 
        (path "/etc/systemd/system/redis-server@" (jinja "{{ item.name }}") ".service.d")
        (state "absent"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (notify (list
          "Reload service manager"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') == 'absent'")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Remove Redis instance configuration if requested"
      (ansible.builtin.file 
        (path "/etc/redis/" (jinja "{{ item.name }}"))
        (state "absent"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') == 'absent'")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Reload systemd configuration when needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Ensure that Redis instances are started"
      (ansible.builtin.systemd 
        (name "redis-server@" (jinja "{{ item.name }}") ".service")
        (state "started")
        (enabled "True"))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') not in ['absent', 'init', 'ignore']")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Restart Redis instances if their configuration changed"
      (ansible.builtin.systemd 
        (name "redis-server@" (jinja "{{ item.item.name }}") ".service")
        (state "restarted"))
      (with_items (jinja "{{ redis_server__register_config_static.results }}"))
      (when "item is changed")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Apply dynamic configuration to Redis instances"
      (ansible.builtin.command "/etc/redis/" (jinja "{{ item.item.name }}") "/ansible-redis-dynamic.conf config")
      (with_items (jinja "{{ redis_server__register_config_dynamic.results }}"))
      (register "redis_server__register_config_apply")
      (changed_when "redis_server__register_config_apply.changed | bool")
      (when "item is changed")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Set Redis Server slave status on first install"
      (community.general.redis 
        (command "slave")
        (master_host (jinja "{{ item.master_host }}"))
        (master_port (jinja "{{ item.master_port }}"))
        (login_port (jinja "{{ item.port }}"))
        (login_password (jinja "{{ item.requirepass | d(omit) }}")))
      (with_items (jinja "{{ redis_server__combined_configuration | debops.debops.parse_kv_items }}"))
      (when "((ansible_local is undefined or (ansible_local.redis_server is undefined or (ansible_local.redis_server.instances is undefined or (item.name not in (ansible_local.redis_server.instances | selectattr('name', 'defined') | list | map(attribute='name') | list))))) and item.state | d('present') not in ['absent', 'ignore', 'init'] and item.master_host | d() and item.master_port | d())")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
