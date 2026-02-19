(playbook "debops/ansible/roles/mosquitto/defaults/main.yml"
  (mosquitto__upstream (jinja "{{ True if ansible_distribution_release in [\"trusty\"]
                         else False }}"))
  (mosquitto__upstream_key_id "8277 CCB4 9EC5 B595 F2D2 C713 6161 1AE4 3099 3623")
  (mosquitto__upstream_repository 
    (Debian "deb http://repo.mosquitto.org/debian " (jinja "{{ ansible_distribution_release }}") " main")
    (Raspbian "deb http://repo.mosquitto.org/debian " (jinja "{{ ansible_distribution_release }}") " main")
    (Ubuntu "ppa:mosquitto-dev/mosquitto-ppa"))
  (mosquitto__distribution_release (jinja "{{ ansible_local.core.distribution_release | d(ansible_distribution_release) }}"))
  (mosquitto__base_packages (list
      "mosquitto"
      "mosquitto-clients"))
  (mosquitto__packages (list))
  (mosquitto__version (jinja "{{ mosquitto__register_version.stdout | d(\"0.0.0\") }}"))
  (mosquitto__pip_packages (jinja "{{ [\"paho-mqtt\"]
                             if (mosquitto__distribution_release in
                                 [\"trusty\", \"xenial\"])
                             else [] }}"))
  (mosquitto__user "mosquitto")
  (mosquitto__group "mosquitto")
  (mosquitto__append_groups (jinja "{{ [\"ssl-cert\"] if mosquitto__pki | bool else [] }}"))
  (mosquitto__network "True")
  (mosquitto__allow (list))
  (mosquitto__allow_tls (list))
  (mosquitto__websockets (jinja "{{ mosquitto__register_websockets.stdout | d() }}"))
  (mosquitto__websockets_packages (list
      "libwebsockets8"))
  (mosquitto__websockets_allow (list))
  (mosquitto__fqdn "mqtt." (jinja "{{ mosquitto__domain }}"))
  (mosquitto__domain (jinja "{{ ansible_domain }}"))
  (mosquitto__http_dir_path (jinja "{{ (ansible_local.fhs.data | d(\"/srv\"))
                              + \"/mosquitto/www/public\" }}"))
  (mosquitto__http_dir_owner "root")
  (mosquitto__http_dir_group "www-data")
  (mosquitto__http_dir_mode "0755")
  (mosquitto__default_options 
    (password_file (jinja "{{ mosquitto__password_file if mosquitto__password | bool else \"\" }}"))
    (acl_file (jinja "{{ mosquitto__acl_file if mosquitto__acl | bool else \"\" }}"))
    (allow_anonymous (jinja "{{ mosquitto__allow_anonymous }}")))
  (mosquitto__options )
  (mosquitto__combined_options (jinja "{{ mosquitto__default_options
                                 | combine(mosquitto__options) }}"))
  (mosquitto__default_listeners 
    (1883 
      (comment "The default listener for local clients")
      (listener (jinja "{{ \"1883\" + (\"\" if mosquitto__allow | d() else \" localhost\") }}"))
      (avahi_state (jinja "{{ \"present\" if (mosquitto__network | bool and mosquitto__allow | d()) else \"absent\" }}"))
      (avahi_type "_mqtt._tcp")
      (avahi_port "1883"))
    (1884 
      (comment "The websocket listener behind a webserver")
      (listener "1884 127.0.0.1")
      (protocol "websockets")
      (http_dir (jinja "{{ mosquitto__http_dir_path }}"))
      (state (jinja "{{ \"present\" if mosquitto__websockets | bool else \"absent\" }}")))
    (8883 
      (comment "The default listener for remote clients over TLS")
      (listener (jinja "{{ \"8883\" + (\"\" if mosquitto__network | bool else \" localhost\") }}"))
      (state (jinja "{{ \"present\" if mosquitto__pki | bool else \"absent\" }}"))
      (cafile (jinja "{{ mosquitto__broker_cafile }}"))
      (certfile (jinja "{{ mosquitto__broker_certfile }}"))
      (keyfile (jinja "{{ mosquitto__broker_keyfile }}"))
      (tls_version (jinja "{{ mosquitto__tls_version }}"))
      (ciphers (jinja "{{ mosquitto__ciphers }}"))
      (avahi_state (jinja "{{ \"present\" if (mosquitto__network | bool and mosquitto__pki | bool) else \"absent\" }}"))
      (avahi_type "_secure-mqtt._tcp")
      (avahi_port "8883")
      (avahi_txt "tls-version=" (jinja "{{ mosquitto__tls_version }}"))))
  (mosquitto__listeners )
  (mosquitto__combined_listeners (jinja "{{ mosquitto__default_listeners
                                   | combine(mosquitto__listeners) }}"))
  (mosquitto__bridges )
  (mosquitto__group_bridges )
  (mosquitto__host_bridges )
  (mosquitto__combined_bridges (jinja "{{ mosquitto__bridges
                                 | combine(mosquitto__group_bridges)
                                 | combine(mosquitto__host_bridges) }}"))
  (mosquitto__pki (jinja "{{ ansible_local.pki.enabled | d(False) | bool }}"))
  (mosquitto__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (mosquitto__pki_client_realm "domain")
  (mosquitto__pki_bridge_realm "domain")
  (mosquitto__pki_broker_realm "domain")
  (mosquitto__pki_ca (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (mosquitto__pki_crt (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (mosquitto__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (mosquitto__client_cafile (jinja "{{ mosquitto__pki_path + \"/\" +
                              mosquitto__pki_client_realm + \"/\" +
                              mosquitto__pki_ca }}"))
  (mosquitto__client_certfile (jinja "{{ mosquitto__pki_path + \"/\" +
                                mosquitto__pki_client_realm + \"/\" +
                                mosquitto__pki_crt }}"))
  (mosquitto__client_keyfile (jinja "{{ mosquitto__pki_path + \"/\" +
                               mosquitto__pki_client_realm + \"/\" +
                               mosquitto__pki_key }}"))
  (mosquitto__bridge_cafile (jinja "{{ mosquitto__pki_path + \"/\" +
                              mosquitto__pki_bridge_realm + \"/\" +
                              mosquitto__pki_ca }}"))
  (mosquitto__bridge_certfile (jinja "{{ mosquitto__pki_path + \"/\" +
                                mosquitto__pki_bridge_realm + \"/\" +
                                mosquitto__pki_crt }}"))
  (mosquitto__bridge_keyfile (jinja "{{ mosquitto__pki_path + \"/\" +
                               mosquitto__pki_bridge_realm + \"/\" +
                               mosquitto__pki_key }}"))
  (mosquitto__broker_cafile (jinja "{{ mosquitto__pki_path + \"/\" +
                              mosquitto__pki_broker_realm + \"/\" +
                              mosquitto__pki_ca }}"))
  (mosquitto__broker_certfile (jinja "{{ mosquitto__pki_path + \"/\" +
                                mosquitto__pki_broker_realm + \"/\" +
                                mosquitto__pki_crt }}"))
  (mosquitto__broker_keyfile (jinja "{{ mosquitto__pki_path + \"/\" +
                               mosquitto__pki_broker_realm + \"/\" +
                               mosquitto__pki_key }}"))
  (mosquitto__ciphers "DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-CAMELLIA256-SHA:DHE-RSA-AES256-SHA:DHE-RSA-CAMELLIA128-SHA:DHE-RSA-AES128-SHA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA")
  (mosquitto__tls_version "tlsv1.2")
  (mosquitto__avahi (jinja "{{ ansible_local.avahi.installed | d() | bool }}"))
  (mosquitto__avahi_name "Mosquitto MQTT server on %h")
  (mosquitto__password (jinja "{{ True
                         if (mosquitto__auth_users or
                             mosquitto__auth_group_users or
                             mosquitto__auth_host_users)
                         else False }}"))
  (mosquitto__password_file "/etc/mosquitto/passwd")
  (mosquitto__password_secret_path (jinja "{{ secret + \"/mosquitto/passwd\" }}"))
  (mosquitto__allow_anonymous (jinja "{{ \"false\" if mosquitto__password | bool else \"true\" }}"))
  (mosquitto__acl (jinja "{{ True
                    if (mosquitto__auth_anonymous or
                        mosquitto__auth_users or
                        mosquitto__auth_group_users or
                        mosquitto__auth_host_users or
                        mosquitto__auth_patterns)
                    else False }}"))
  (mosquitto__acl_file "/etc/mosquitto/acl")
  (mosquitto__auth_anonymous (list))
  (mosquitto__auth_users (list))
  (mosquitto__auth_group_users (list))
  (mosquitto__auth_host_users (list))
  (mosquitto__auth_patterns (list))
  (mosquitto__python__dependent_packages3 (list
      (jinja "{{ []
        if (mosquitto__distribution_release in [\"trusty\", \"xenial\"])
        else [\"python3-paho-mqtt\"] }}")))
  (mosquitto__python__dependent_packages2 (list
      (jinja "{{ []
        if (mosquitto__distribution_release in [\"trusty\", \"xenial\"])
        else [\"python-paho-mqtt\"] }}")))
  (mosquitto__etc_services__dependent_list (list
      
      (name "mqtt")
      (port "1883")
      (comment "Message Queuing Telemetry Transport Protocol")
      
      (name "ws-mqtt")
      (port "1884")
      (comment "WebSocket MQTT")
      
      (name "secure-mqtt")
      (port "8883")
      (comment "Secure MQTT")))
  (mosquitto__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ mosquitto__upstream_key_id }}"))
      (repo (jinja "{{ mosquitto__upstream_repository[ansible_distribution] }}"))
      (state (jinja "{{ \"present\" if mosquitto__upstream | bool else \"absent\" }}"))))
  (mosquitto__tcpwrappers__dependent_allow (list
      
      (daemon "mosquitto")
      (client (jinja "{{ mosquitto__allow }}"))
      (accept_any "False")
      (weight "50")
      (filename "mosquitto_dependent_allow")
      (comment "Allow remote connections to Mosquitto server")
      (state (jinja "{{ \"present\"
               if mosquitto__network | bool
               else \"absent\" }}"))
      
      (daemon "mosquitto")
      (client (jinja "{{ mosquitto__allow_tls }}"))
      (accept_any "True")
      (weight "50")
      (filename "mosquitto-tls_dependent_allow")
      (comment "Allow remote connections to Mosquitto server over TLS")
      (state (jinja "{{ \"present\"
               if (mosquitto__network | bool and
                   mosquitto__pki | bool)
               else \"absent\" }}"))))
  (mosquitto__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "mqtt"))
      (weight "40")
      (saddr (jinja "{{ mosquitto__allow }}"))
      (accept_any "False")
      (by_role "debops.mosquitto")
      (rule_state (jinja "{{ \"present\"
                    if mosquitto__network | bool
                    else \"absent\" }}"))
      
      (type "accept")
      (dport (list
          "secure-mqtt"))
      (weight "40")
      (saddr (jinja "{{ mosquitto__allow + mosquitto__allow_tls }}"))
      (accept_any "True")
      (by_role "debops.mosquitto")
      (rule_state (jinja "{{ \"present\"
                    if (mosquitto__network | bool and
                        mosquitto__pki | bool)
                    else \"absent\" }}"))))
  (mosquitto__nginx__dependent_servers (list
      
      (name (jinja "{{ mosquitto__fqdn }}"))
      (filename "mosquitto-websocket")
      (by_role "debops.mosquitto")
      (root (jinja "{{ mosquitto__http_dir_path }}"))
      (webroot_create "False")
      (allow (jinja "{{ mosquitto__websockets_allow }}"))
      (type "proxy")
      (proxy_pass "http://mosquitto_websocket")
      (proxy_redirect "default")
      (proxy_options "proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection \"upgrade\";
")))
  (mosquitto__nginx__dependent_upstreams (list
      
      (name "mosquitto_websocket")
      (server "127.0.0.1:1884"))))
