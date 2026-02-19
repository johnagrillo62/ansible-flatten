(playbook "debops/ansible/roles/rabbitmq_server/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Make sure that required UNIX group exists"
      (ansible.builtin.group 
        (name (jinja "{{ rabbitmq_server__group }}"))
        (state "present")
        (system "True")))
    (task "Make sure that required UNIX account exists"
      (ansible.builtin.user 
        (name (jinja "{{ rabbitmq_server__user }}"))
        (group (jinja "{{ rabbitmq_server__group }}"))
        (groups (jinja "{{ rabbitmq_server__append_groups | join(\",\") }}"))
        (home (jinja "{{ rabbitmq_server__home }}"))
        (comment "RabbitMQ messaging server")
        (shell "/bin/false")
        (state "present")
        (system "True")
        (append "True")))
    (task "Initialize Erlang cookie on the Ansible Controller"
      (ansible.builtin.set_fact 
        (rabbitmq_server__fact_erlang_cookie (jinja "{{ rabbitmq_server__erlang_cookie_password }}")))
      (delegate_to "localhost")
      (become "False")
      (run_once "True")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Configure Erlang cookie"
      (ansible.builtin.copy 
        (content (jinja "{{ rabbitmq_server__erlang_cookie_password }}"))
        (dest (jinja "{{ rabbitmq_server__erlang_cookie_path }}"))
        (owner (jinja "{{ rabbitmq_server__user }}"))
        (group (jinja "{{ rabbitmq_server__group }}"))
        (mode "0400"))
      (notify (list
          "Restart rabbitmq-server"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Ensure that configuration directory exists"
      (ansible.builtin.file 
        (path "/etc/rabbitmq")
        (state "directory")
        (owner (jinja "{{ rabbitmq_server__user }}"))
        (group (jinja "{{ rabbitmq_server__group }}"))
        (mode "0755")))
    (task "Generate RabbitMQ environment file"
      (ansible.builtin.template 
        (src "etc/rabbitmq/rabbitmq-env.conf.j2")
        (dest "/etc/rabbitmq/rabbitmq-env.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart rabbitmq-server"))
      (tags (list
          "role::rabbitmq_server:config")))
    (task "Install RabbitMQ packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (rabbitmq_server__base_packages
                              + rabbitmq_server__packages)) }}"))
        (state "present"))
      (register "rabbitmq_server__register_packages")
      (until "rabbitmq_server__register_packages is succeeded"))
    (task "Check if the dependent config file exists"
      (ansible.builtin.stat 
        (path (jinja "{{ secret + \"/rabbitmq_server/dependent_config/\" + inventory_hostname + \"/config.json\" }}")))
      (register "rabbitmq_server__register_dependent_config_file")
      (become "False")
      (delegate_to "localhost")
      (when "(ansible_local | d() and ansible_local.rabbitmq_server | d() and ansible_local.rabbitmq_server.installed is defined and ansible_local.rabbitmq_server.installed | bool)")
      (tags (list
          "role::rabbitmq_server:config")))
    (task "Load the dependent configuration from Ansible Controller"
      (ansible.builtin.slurp 
        (src (jinja "{{ secret + \"/rabbitmq_server/dependent_config/\" + inventory_hostname + \"/config.json\" }}")))
      (register "rabbitmq_server__register_dependent_config")
      (become "False")
      (delegate_to "localhost")
      (when "(ansible_local | d() and ansible_local.rabbitmq_server | d() and ansible_local.rabbitmq_server.installed is defined and ansible_local.rabbitmq_server.installed | bool and rabbitmq_server__register_dependent_config_file.stat.exists | bool)")
      (tags (list
          "role::rabbitmq_server:config")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save RabbitMQ local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/rabbitmq_server.fact.j2")
        (dest "/etc/ansible/facts.d/rabbitmq_server.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Generate RabbitMQ configuration"
      (ansible.builtin.template 
        (src "etc/rabbitmq/rabbitmq.config.j2")
        (dest "/etc/rabbitmq/rabbitmq.config")
        (owner (jinja "{{ rabbitmq_server__user }}"))
        (group (jinja "{{ rabbitmq_server__group }}"))
        (mode "0600"))
      (notify (list
          "Restart rabbitmq-server"))
      (tags (list
          "role::rabbitmq_server:config")))
    (task "Manage RabbitMQ plugins"
      (community.rabbitmq.rabbitmq_plugin 
        (names (jinja "{{ item.name | d(item) }}"))
        (state (jinja "{{ \"enabled\" if item.state | d(\"present\") != \"absent\" else \"disabled\" }}"))
        (prefix (jinja "{{ item.prefix | d(omit) }}"))
        (new_only "True"))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_plugins) }}"))
      (notify (list
          "Restart rabbitmq-server"))
      (tags (list
          "role::rabbitmq_server:config")))
    (task "Manage RabbitMQ virtual hosts"
      (community.rabbitmq.rabbitmq_vhost 
        (name (jinja "{{ item.name | d(item) }}"))
        (node (jinja "{{ item.node | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (tracing (jinja "{{ item.tracing | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_vhosts) }}"))
      (tags (list
          "role::rabbitmq_server:vhost"
          "role::rabbitmq_server:parameter"
          "role::rabbitmq_server:policy"
          "role::rabbitmq_server:user")))
    (task "Manage RabbitMQ virtual host limits"
      (community.rabbitmq.rabbitmq_vhost_limits 
        (vhost (jinja "{{ item.vhost }}"))
        (node (jinja "{{ item.node | d(omit) }}"))
        (max_connections (jinja "{{ item.max_connections | d(omit) }}"))
        (max_queues (jinja "{{ item.max_queues | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_vhost_limits) }}"))
      (tags (list
          "role::rabbitmq_server:vhost")))
    (task "Manage RabbitMQ feature flags"
      (community.rabbitmq.rabbitmq_feature_flag 
        (name (jinja "{{ item.name }}"))
        (node (jinja "{{ item.node | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_feature_flags) }}")))
    (task "Manage RabbitMQ global parameters"
      (community.rabbitmq.rabbitmq_global_parameter 
        (name (jinja "{{ item.name }}"))
        (node (jinja "{{ item.node | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (value (jinja "{{ item.value | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_global_parameters) }}"))
      (tags (list
          "role::rabbitmq_server:parameter")))
    (task "Manage RabbitMQ parameters"
      (community.rabbitmq.rabbitmq_parameter 
        (component (jinja "{{ item.component }}"))
        (name (jinja "{{ item.name }}"))
        (node (jinja "{{ item.node | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (value (jinja "{{ item.value | d(omit) }}"))
        (vhost (jinja "{{ item.vhost | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_parameters) }}"))
      (when "(item.name | d() and item.component | d())")
      (tags (list
          "role::rabbitmq_server:parameter")))
    (task "Manage RabbitMQ policies"
      (community.rabbitmq.rabbitmq_policy 
        (name (jinja "{{ item.name }}"))
        (pattern (jinja "{{ item.pattern }}"))
        (tags (jinja "{{ item.tags }}"))
        (apply_to (jinja "{{ item.apply_to | d(omit) }}"))
        (node (jinja "{{ item.node | d(omit) }}"))
        (priority (jinja "{{ item.priority | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (vhost (jinja "{{ item.vhost | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_policies) }}"))
      (when "(item.name | d() and item.pattern | d() and item.tags | d())")
      (tags (list
          "role::rabbitmq_server:policy")))
    (task "Manage RabbitMQ user accounts"
      (community.rabbitmq.rabbitmq_user 
        (user (jinja "{{ item.user | d(item.name) | d(item) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (node (jinja "{{ item.node | d(omit) }}"))
        (permissions (jinja "{{ item.permissions | d(omit) }}"))
        (configure_priv (jinja "{{ item.configure_priv | d(omit) }}"))
        (read_priv (jinja "{{ item.read_priv | d(omit) }}"))
        (write_priv (jinja "{{ item.write_priv | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (vhost (jinja "{{ item.vhost | d(omit) }}"))
        (password (jinja "{{ item.password | d(lookup(\"password\",
                        secret + \"/rabbitmq_server/accounts/\"
                        + (item.user | d(item.name | d(item)))
                        + \"/password length=\"
                        + rabbitmq_server__account_password_length)) }}"))
        (tags (jinja "{{ (((item.tags.split(\",\") | list)
                          if (item.tags | d() and item.tags is string)
                          else item.tags) | join(\",\"))
                        if item.tags | d() else omit }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_accounts) }}"))
      (tags (list
          "role::rabbitmq_server:user"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Manage RabbitMQ user limits"
      (community.rabbitmq.rabbitmq_user_limits 
        (user (jinja "{{ item.user }}"))
        (node (jinja "{{ item.node | d(omit) }}"))
        (max_connections (jinja "{{ item.max_connections | d(omit) }}"))
        (max_channels (jinja "{{ item.max_channels | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_user_limits) }}"))
      (tags (list
          "role::rabbitmq_server:user")))
    (task "Manage RabbitMQ exchanges"
      (community.rabbitmq.rabbitmq_exchange 
        (name (jinja "{{ item.name }}"))
        (arguments (jinja "{{ item.arguments | d(omit) }}"))
        (auto_delete (jinja "{{ item.auto_delete | d(omit) }}"))
        (ca_cert (jinja "{{ item.ca_cert | d(omit) }}"))
        (client_cert (jinja "{{ item.client_cert | d(omit) }}"))
        (client_key (jinja "{{ item.client_key | d(omit) }}"))
        (durable (jinja "{{ item.durable | d(omit) }}"))
        (exchange_type (jinja "{{ item.exchange_type | d(omit) }}"))
        (internal (jinja "{{ item.internal | d(omit) }}"))
        (login_host (jinja "{{ item.login_host | d(omit) }}"))
        (login_password (jinja "{{ item.login_password | d(omit) }}"))
        (login_port (jinja "{{ item.login_port | d(omit) }}"))
        (login_protocol (jinja "{{ item.login_protocol | d(omit) }}"))
        (login_user (jinja "{{ item.login_user | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (vhost (jinja "{{ item.vhost | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_exchanges) }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Manage RabbitMQ queues"
      (community.rabbitmq.rabbitmq_queue 
        (name (jinja "{{ item.name }}"))
        (arguments (jinja "{{ item.arguments | d(omit) }}"))
        (auto_delete (jinja "{{ item.auto_delete | d(omit) }}"))
        (auto_expires (jinja "{{ item.auto_expires | d(omit) }}"))
        (ca_cert (jinja "{{ item.ca_cert | d(omit) }}"))
        (client_cert (jinja "{{ item.client_cert | d(omit) }}"))
        (client_key (jinja "{{ item.client_key | d(omit) }}"))
        (dead_letter_exchange (jinja "{{ item.dead_letter_exchange | d(omit) }}"))
        (dead_letter_routing_key (jinja "{{ item.dead_letter_routing_key | d(omit) }}"))
        (durable (jinja "{{ item.durable | d(omit) }}"))
        (login_host (jinja "{{ item.login_host | d(omit) }}"))
        (login_password (jinja "{{ item.login_password | d(omit) }}"))
        (login_port (jinja "{{ item.login_port | d(omit) }}"))
        (login_protocol (jinja "{{ item.login_protocol | d(omit) }}"))
        (login_user (jinja "{{ item.login_user | d(omit) }}"))
        (max_length (jinja "{{ item.max_length | d(omit) }}"))
        (max_priority (jinja "{{ item.max_priority | d(omit) }}"))
        (message_ttl (jinja "{{ item.message_ttl | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (vhost (jinja "{{ item.vhost | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_queues) }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (tags (list
          "role::rabbitmq_server:queue")))
    (task "Manage RabbitMQ bindings"
      (community.rabbitmq.rabbitmq_binding 
        (name (jinja "{{ item.name }}"))
        (ca_cert (jinja "{{ item.ca_cert | d(omit) }}"))
        (client_cert (jinja "{{ item.client_cert | d(omit) }}"))
        (client_key (jinja "{{ item.client_key | d(omit) }}"))
        (destination (jinja "{{ item.destination }}"))
        (destination_type (jinja "{{ item.destination_type }}"))
        (login_host (jinja "{{ item.login_host | d(omit) }}"))
        (login_password (jinja "{{ item.login_password | d(omit) }}"))
        (login_port (jinja "{{ item.login_port | d(omit) }}"))
        (login_protocol (jinja "{{ item.login_protocol | d(omit) }}"))
        (login_user (jinja "{{ item.login_user | d(omit) }}"))
        (arguments (jinja "{{ item.arguments | d(omit) }}"))
        (routing_key (jinja "{{ item.routing_key | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (vhost (jinja "{{ item.vhost | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", rabbitmq_server__combined_bindings) }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Save RabbitMQ dependent configuration on Ansible Controller"
      (ansible.builtin.template 
        (src "secret/rabbitmq_server/dependent_config/inventory_hostname/config.json.j2")
        (dest (jinja "{{ secret + \"/rabbitmq_server/dependent_config/\" + inventory_hostname + \"/config.json\" }}"))
        (mode "0644"))
      (become "False")
      (delegate_to "localhost")
      (tags (list
          "role::rabbitmq_server:config")))))
