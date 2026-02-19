(playbook "debops/ansible/roles/rabbitmq_server/defaults/main.yml"
  (rabbitmq_server__base_packages (list
      "rabbitmq-server"))
  (rabbitmq_server__packages (list))
  (rabbitmq_server__user "rabbitmq")
  (rabbitmq_server__group "rabbitmq")
  (rabbitmq_server__append_groups (jinja "{{ [\"ssl-cert\"] if rabbitmq_server__pki | bool else [] }}"))
  (rabbitmq_server__home "/var/lib/rabbitmq")
  (rabbitmq_server__relative_disk_free_limit "2.0")
  (rabbitmq_server__erlang_cookie_path (jinja "{{ rabbitmq_server__home + \"/.erlang.cookie\" }}"))
  (rabbitmq_server__erlang_cookie_password (jinja "{{ lookup(\"password\", secret
                                             + \"/rabbitmq_server/cluster/erlang_cookie \"
                                             + \"length=64\") }}"))
  (rabbitmq_server__amqp_allow (list))
  (rabbitmq_server__amqps_allow (list))
  (rabbitmq_server__environment )
  (rabbitmq_server__group_environment )
  (rabbitmq_server__host_environment )
  (rabbitmq_server__combined_environment (jinja "{{ rabbitmq_server__environment
                                           | combine(rabbitmq_server__group_environment,
                                                     rabbitmq_server__host_environment) }}"))
  (rabbitmq_server__default_config (list
      
      (name "ssl")
      (state (jinja "{{ \"present\" if rabbitmq_server__pki | bool else \"ignore\" }}"))
      (options (list
          
          (name "versions")
          (value (list
              "tlsv1.2"
              "tlsv1.1"))
          (type "atom")
          
          (name "ciphers")
          (value "[
  " (jinja "{{ rabbitmq_server__ssl_ciphers | indent(2) }}") "
]
")
          (type "raw")
          (state (jinja "{{ \"present\"
                   if rabbitmq_server__ssl_ciphers
                   else \"ignore\" }}"))
          
          (client_renegotiation "False")
          
          (secure_renegotiate "True")
          
          (reuse_sessions "True")
          
          (honor_cipher_order "True")
          
          (honor_ecc_order "True")))
      
      (name "rabbit")
      (state (jinja "{{ \"present\" if rabbitmq_server__pki | bool else \"ignore\" }}"))
      (options (list
          
          (name "tcp_listeners")
          (comment "Listen for TCP connections only on the 'localhost' interface
when the TLS support is enabled
")
          (value "[{\"127.0.0.1\", 5672},
 {\"::1\",       5672}]
")
          (type "raw")
          (state (jinja "{{ \"ignore\" if rabbitmq_server__amqp_allow else \"present\" }}"))
          
          (ssl_listeners (list
              "5671"))
          
          (name "ssl_options")
          (value "[{cacertfile,           \"" (jinja "{{ rabbitmq_server__cacertfile }}") "\"},
 {certfile,             \"" (jinja "{{ rabbitmq_server__certfile }}") "\"},
 {keyfile,              \"" (jinja "{{ rabbitmq_server__keyfile }}") "\"},
 " (jinja "{% if rabbitmq_server__ssl_dhparam %}") "
{dhfile,               \"" (jinja "{{ rabbitmq_server__ssl_dhparam }}") "\"},
 " (jinja "{% endif -%}") "
 {versions,             ['tlsv1.2', 'tlsv1.1']},
 {depth,                2},
 " (jinja "{% if rabbitmq_server__ssl_ciphers %}") "
{ciphers,              [
                          " (jinja "{{ rabbitmq_server__ssl_ciphers | indent(26) }}") "
                        ]},
 " (jinja "{% endif -%}") "
 {honor_cipher_order,   true},
 {honor_ecc_order,      true},
 {client_renegotiation, false},
 {secure_renegotiate,   true},
 {reuse_sessions,       true},
 {verify,               verify_peer},
 {fail_if_no_peer_cert, false}]
")
          (type "raw")))
      
      (name "rabbit")
      (options (list
          
          (name "disk_free_limit")
          (value "{mem_relative, " (jinja "{{ rabbitmq_server__relative_disk_free_limit }}") (jinja "{{ \"}\" }}"))
          (type "raw")))))
  (rabbitmq_server__config (list))
  (rabbitmq_server__group_config (list))
  (rabbitmq_server__host_config (list))
  (rabbitmq_server__dependent_role "")
  (rabbitmq_server__dependent_state "present")
  (rabbitmq_server__dependent_config (list))
  (rabbitmq_server__dependent_config_filter (jinja "{{ lookup(\"template\",
                                              \"lookup/rabbitmq_server__dependent_config_filter.j2\")
                                              | from_yaml }}"))
  (rabbitmq_server__combined_config (jinja "{{ rabbitmq_server__default_config
                                      + rabbitmq_server__dependent_config_filter
                                      + rabbitmq_server__config
                                      + rabbitmq_server__group_config
                                      + rabbitmq_server__host_config }}"))
  (rabbitmq_server__default_plugins (list
      
      (name "rabbitmq_management_agent")))
  (rabbitmq_server__plugins (list))
  (rabbitmq_server__group_plugins (list))
  (rabbitmq_server__host_plugins (list))
  (rabbitmq_server__combined_plugins (jinja "{{ rabbitmq_server__default_plugins
                                       + rabbitmq_server__plugins
                                       + rabbitmq_server__group_plugins
                                       + rabbitmq_server__host_plugins }}"))
  (rabbitmq_server__vhosts (list))
  (rabbitmq_server__group_vhosts (list))
  (rabbitmq_server__host_vhosts (list))
  (rabbitmq_server__parameters_vhosts (jinja "{{ lookup(\"template\",
                                        \"lookup/rabbitmq_server__parameters_vhosts.j2\") }}"))
  (rabbitmq_server__policies_vhosts (jinja "{{ lookup(\"template\",
                                      \"lookup/rabbitmq_server__policies_vhosts.j2\") }}"))
  (rabbitmq_server__accounts_vhosts (jinja "{{ lookup(\"template\",
                                      \"lookup/rabbitmq_server__accounts_vhosts.j2\") }}"))
  (rabbitmq_server__combined_vhosts (jinja "{{ rabbitmq_server__vhosts
                                      + rabbitmq_server__group_vhosts
                                      + rabbitmq_server__host_vhosts
                                      + rabbitmq_server__parameters_vhosts
                                      + rabbitmq_server__policies_vhosts
                                      + rabbitmq_server__accounts_vhosts }}"))
  (rabbitmq_server__vhost_limits (list))
  (rabbitmq_server__group_vhost_limits (list))
  (rabbitmq_server__host_vhost_limits (list))
  (rabbitmq_server__combined_vhost_limits (jinja "{{ rabbitmq_server__vhost_limits
                                          + rabbitmq_server__group_vhost_limits
                                          + rabbitmq_server__host_vhost_limits }}"))
  (rabbitmq_server__parameters (list))
  (rabbitmq_server__group_parameters (list))
  (rabbitmq_server__host_parameters (list))
  (rabbitmq_server__combined_parameters (jinja "{{ rabbitmq_server__parameters
                                          + rabbitmq_server__group_parameters
                                          + rabbitmq_server__host_parameters }}"))
  (rabbitmq_server__policies (list))
  (rabbitmq_server__group_policies (list))
  (rabbitmq_server__host_policies (list))
  (rabbitmq_server__combined_policies (jinja "{{ rabbitmq_server__policies
                                        + rabbitmq_server__group_policies
                                        + rabbitmq_server__host_policies }}"))
  (rabbitmq_server__admin_accounts (jinja "{{ lookup(\"template\",
                                     \"lookup/rabbitmq_server__admin_accounts.j2\") }}"))
  (rabbitmq_server__default_accounts (list
      
      (name "guest")
      (state "absent")))
  (rabbitmq_server__accounts (list))
  (rabbitmq_server__group_accounts (list))
  (rabbitmq_server__host_accounts (list))
  (rabbitmq_server__combined_accounts (jinja "{{ rabbitmq_server__admin_accounts
                                        + rabbitmq_server__default_accounts
                                        + rabbitmq_server__accounts
                                        + rabbitmq_server__group_accounts
                                        + rabbitmq_server__host_accounts }}"))
  (rabbitmq_server__admin_default_vhost "/")
  (rabbitmq_server__account_password_length "32")
  (rabbitmq_server__user_limits (list))
  (rabbitmq_server__group_user_limits (list))
  (rabbitmq_server__host_user_limits (list))
  (rabbitmq_server__combined_user_limits (jinja "{{ rabbitmq_server__user_limits
                                           + rabbitmq_server__group_user_limits
                                           + rabbitmq_server__host_user_limits }}"))
  (rabbitmq_server__exchanges (list))
  (rabbitmq_server__group_exchanges (list))
  (rabbitmq_server__host_exchanges (list))
  (rabbitmq_server__combined_exchanges (jinja "{{ rabbitmq_server__exchanges
                                         + rabbitmq_server__group_exchanges
                                         + rabbitmq_server__host_exchanges }}"))
  (rabbitmq_server__queues (list))
  (rabbitmq_server__group_queues (list))
  (rabbitmq_server__host_queues (list))
  (rabbitmq_server__combined_queues (jinja "{{ rabbitmq_server__queues
                                      + rabbitmq_server__group_queues
                                      + rabbitmq_server__host_queues }}"))
  (rabbitmq_server__bindings (list))
  (rabbitmq_server__group_bindings (list))
  (rabbitmq_server__host_bindings (list))
  (rabbitmq_server__combined_bindings (jinja "{{ rabbitmq_server__bindings
                                        + rabbitmq_server__group_bindings
                                        + rabbitmq_server__host_bindings }}"))
  (rabbitmq_server__feature_flags (list))
  (rabbitmq_server__group_feature_flags (list))
  (rabbitmq_server__host_feature_flags (list))
  (rabbitmq_server__combined_feature_flags (jinja "{{ rabbitmq_server__feature_flags
                                             + rabbitmq_server__group_feature_flags
                                             + rabbitmq_server__host_feature_flags }}"))
  (rabbitmq_server__global_parameters (list))
  (rabbitmq_server__group_global_parameters (list))
  (rabbitmq_server__host_global_parameters (list))
  (rabbitmq_server__combined_global_parameters (jinja "{{ rabbitmq_server__global_parameters
                                                 + rabbitmq_server__group_global_parameters
                                                 + rabbitmq_server__host_global_parameters }}"))
  (rabbitmq_server__cluster_allow (list))
  (rabbitmq_server__pki (jinja "{{ True
                          if (ansible_local.pki.enabled | d() and
                              ansible_local.pki.enabled | bool) else False }}"))
  (rabbitmq_server__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (rabbitmq_server__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (rabbitmq_server__pki_ca (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (rabbitmq_server__pki_crt (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (rabbitmq_server__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (rabbitmq_server__cacertfile (jinja "{{ rabbitmq_server__pki_path
                                 + \"/\" + rabbitmq_server__pki_realm
                                 + \"/\" + rabbitmq_server__pki_ca }}"))
  (rabbitmq_server__certfile (jinja "{{ rabbitmq_server__pki_path
                               + \"/\" + rabbitmq_server__pki_realm
                               + \"/\" + rabbitmq_server__pki_crt }}"))
  (rabbitmq_server__keyfile (jinja "{{ rabbitmq_server__pki_path
                              + \"/\" + rabbitmq_server__pki_realm
                              + \"/\" + rabbitmq_server__pki_key }}"))
  (rabbitmq_server__ssl_versions (list
      "tlsv1.2"
      "tlsv1.1"))
  (rabbitmq_server__ssl_ciphers (jinja "{{ ansible_local.rabbitmq_server.raw_erlang_ssl_ciphers | d(\"\") }}"))
  (rabbitmq_server__ssl_dhparam (jinja "{{ (ansible_local.dhparam[rabbitmq_server__ssl_dhparam_set]
                                   if (ansible_local | d() and ansible_local.dhparam | d() and
                                       ansible_local.dhparam[rabbitmq_server__ssl_dhparam_set] | d())
                                   else \"\") }}"))
  (rabbitmq_server__ssl_dhparam_set "default")
  (rabbitmq_server__etc_services__dependent_list (list
      
      (name "einc")
      (port "25672")
      (comment "Erlang Inter-Node Communication (RabbitMQ)")))
  (rabbitmq_server__ferm__dependent_rules (list
      
      (name "rabbitmq-amqp")
      (type "accept")
      (saddr (jinja "{{ rabbitmq_server__amqp_allow }}"))
      (dport (list
          "amqp"))
      (accept_any (jinja "{{ False if rabbitmq_server__pki | bool else True }}"))
      
      (name "rabbitmq-amqps")
      (type "accept")
      (saddr (jinja "{{ rabbitmq_server__amqps_allow }}"))
      (dport (list
          "amqps"))
      (accept_any "True")
      (rule_state (jinja "{{ \"present\" if rabbitmq_server__pki | bool else \"absent\" }}"))
      
      (name "rabbitmq-cluster")
      (type "accept")
      (saddr (jinja "{{ rabbitmq_server__cluster_allow }}"))
      (dport (list
          "epmd"
          "einc"))
      (accept_any "False"))))
