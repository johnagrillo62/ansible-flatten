(playbook "debops/ansible/roles/influxdb_server/defaults/main.yml"
  (influxdb_server__base_packages (list
      "influxdb"))
  (influxdb_server__packages (list))
  (influxdb_server__allow (list))
  (influxdb_server__bind "")
  (influxdb_server__port "8086")
  (influxdb_server__rpc_allow (list))
  (influxdb_server__rpc_bind "127.0.0.1")
  (influxdb_server__rpc_port "8088")
  (influxdb_server__default_directory "/var/lib/influxdb")
  (influxdb_server__directory (jinja "{{ influxdb_server__default_directory }}"))
  (influxdb_server__delegate_to (jinja "{{ inventory_hostname }}"))
  (influxdb_server__default_configuration (list
      
      (name "global")
      (options (list
          
          (reporting-disabled "true")
          
          (bind-address "\"" (jinja "{{ influxdb_server__rpc_bind }}") ":" (jinja "{{ influxdb_server__rpc_port }}") "\"")))
      
      (name "meta")
      (options (list
          
          (dir "\"" (jinja "{{ influxdb_server__directory }}") "/meta\"")))
      
      (name "data")
      (options (list
          
          (dir "\"" (jinja "{{ influxdb_server__directory }}") "/data\"")
          
          (wal-dir "\"" (jinja "{{ influxdb_server__directory }}") "/wal\"")))
      
      (name "coordinator")
      (options (list))
      
      (name "retention")
      (options (list))
      
      (name "shard-precreation")
      (options (list))
      
      (name "monitor")
      (options (list))
      
      (name "http")
      (options (list
          
          (bind-address "\"" (jinja "{{ influxdb_server__bind }}") ":" (jinja "{{ influxdb_server__port }}") "\"")
          
          (https-enabled (jinja "{{ \"true\" if influxdb_server__pki else \"false\" }}"))
          
          (auth-enabled "true")))
      
      (name "logging")
      (options (list))
      
      (name "subscriber")
      (options (list))
      
      (name "graphite")
      (options (list))
      
      (name "collectd")
      (options (list))
      
      (name "opentsdb")
      (options (list))
      
      (name "udp")
      (options (list))
      
      (name "continuous_queries")
      (options (list))
      
      (name "tls")
      (options (list
          
          (min-version "\"tls1.2\"")))))
  (influxdb_server__configuration (list))
  (influxdb_server__combined_configuration (jinja "{{ influxdb_server__default_configuration +
                                             influxdb_server__configuration +
                                             influxdb_server__pki_options }}"))
  (influxdb_server__append_groups (list
      "ssl-cert"))
  (influxdb_server__pki_options (list
      
      (name "http")
      (state (jinja "{{ \"present\" if influxdb_server__pki | bool else \"absent\" }}"))
      (options (list
          
          (https-certificate "\"" (jinja "{{ influxdb_server__pki_path + \"/\" + influxdb_server__pki_realm +
                                \"/\" + influxdb_server__pki_crt }}") "\"")
          
          (https-private-key "\"" (jinja "{{ influxdb_server__pki_path + \"/\" + influxdb_server__pki_realm +
                                \"/\" + influxdb_server__pki_key }}") "\"")))
      
      (name "subscriber")
      (state (jinja "{{ \"present\" if influxdb_server__pki | bool else \"absent\" }}"))
      (options (list
          
          (ca-certs "\"" (jinja "{{ influxdb_server__pki_path + \"/\" + influxdb_server__pki_realm +
                       \"/\" + influxdb_server__pki_ca }}") "\"")))))
  (influxdb_server__pki (jinja "{{ True
                          if (ansible_local.pki.enabled | d() | bool and
                              influxdb_server__pki_realm in ansible_local.pki.known_realms)
                          else False }}"))
  (influxdb_server__pki_path (jinja "{{ ansible_local.pki.base_path | d(\"/etc/pki\") }}"))
  (influxdb_server__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (influxdb_server__pki_ca "CA.crt")
  (influxdb_server__pki_crt "default.crt")
  (influxdb_server__pki_key "default.key")
  (influxdb_server__password_length "48")
  (influxdb_server__root_password (jinja "{{ lookup(\"password\", secret + \"/influxdb/\" + ansible_fqdn +
                                    \"/credentials/root/password \" +
                                    \"length=\" + influxdb_server__password_length) }}"))
  (influxdb_server__backup "True")
  (influxdb_server__backup_mailaddr "backup@" (jinja "{{ ansible_domain }}"))
  (influxdb_server__backup_doweekly "6")
  (influxdb_server__backup_latest "no")
  (influxdb_server__backup_directory "/var/lib/autoinfluxdbbackup")
  (influxdb_server__influxdata__dependent_packages (list
      (jinja "{{ influxdb_server__base_packages }}")
      (jinja "{{ influxdb_server__packages }}")))
  (influxdb_server__ferm__dependent_rules (list
      
      (name "influxdb_http")
      (type "accept")
      (saddr (jinja "{{ influxdb_server__allow }}"))
      (dport (list
          "influxdb-http"))
      (accept_any "False")
      (role "influxdb_server")
      
      (name "influxdb_rpc")
      (type "accept")
      (saddr (jinja "{{ influxdb_server__rpc_allow }}"))
      (dport (list
          "influxdb-rpc"))
      (accept_any "False")
      (role "influxdb_server")
      (state (jinja "{{ \"absent\" if influxdb_server__rpc_bind == \"127.0.0.1\" else \"present\" }}"))))
  (influxdb_server__etc_services__dependent_list (list
      
      (name "influxdb-http")
      (port (jinja "{{ influxdb_server__port }}"))
      
      (name "influxdb-rpc")
      (port (jinja "{{ influxdb_server__rpc_port }}"))
      (state (jinja "{{ \"absent\" if influxdb_server__rpc_bind == \"127.0.0.1\" else \"present\" }}"))))
  (influxdb_server__python__dependent_packages3 (list
      "python3-influxdb"))
  (influxdb_server__python__dependent_packages2 (list
      "python-influxdb")))
