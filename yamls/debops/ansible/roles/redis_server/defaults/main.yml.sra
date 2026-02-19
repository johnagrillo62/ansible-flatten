(playbook "debops/ansible/roles/redis_server/defaults/main.yml"
  (redis_server__base_packages (list
      "redis-server"
      "redis-tools"))
  (redis_server__packages (list))
  (redis_server__version (jinja "{{ ansible_local.redis_server.version | d(\"0.0.0\") }}"))
  (redis_server__user "redis")
  (redis_server__group "redis")
  (redis_server__auth_group "redis-auth")
  (redis_server__domain (jinja "{{ ansible_domain }}"))
  (redis_server__auth_password (jinja "{{ ansible_local.redis_server.password
                                 if (ansible_local.redis_server.password | d())
                                 else (lookup(\"password\", secret +
                                       \"/redis/clusters/\" + redis_server__domain +
                                       \"/password length=\" + redis_server__password_length +
                                       \" chars=ascii_letters,digits,-_.\")) }}"))
  (redis_server__password_length "256")
  (redis_server__maxmemory_multiplier "0.5")
  (redis_server__maxmemory_total (jinja "{{ (((ansible_memtotal_mb | int * 1024 * 1024)
                                     * redis_server__maxmemory_multiplier | float) | round | int) }}"))
  (redis_server__maxmemory_instances (jinja "{{ redis_server__combined_instances
                                       | debops.debops.parse_kv_items
                                       | selectattr(\"state\", \"equalto\", \"present\")
                                       | list | count | int }}"))
  (redis_server__maxmemory_shared (jinja "{{ (redis_server__maxmemory_total | int
                                     / redis_server__maxmemory_instances | int)
                                    | round | int }}"))
  (redis_server__bind (list
      "127.0.0.1"
      "::1"))
  (redis_server__allow (list))
  (redis_server__group_allow (list))
  (redis_server__host_allow (list))
  (redis_server__default_base_options (list
      
      (name "masterauth")
      (value (jinja "{{ redis_server__auth_password }}"))
      (state (jinja "{{ \"present\" if redis_server__auth_password | d() else \"ignore\" }}"))
      
      (name "requirepass")
      (value (jinja "{{ redis_server__auth_password }}"))
      (state (jinja "{{ \"present\" if redis_server__auth_password | d() else \"ignore\" }}"))
      
      (name "always-show-logo")
      (value "False")
      (state (jinja "{{ \"present\"
               if (redis_server__version is version_compare(\"4.0.0\", \">=\"))
               else \"ignore\" }}"))
      
      (name "syslog-enabled")
      (value "True")
      
      (name "syslog-facility")
      (value "local0")
      
      (name "loglevel")
      (value "notice")
      (dynamic "True")
      
      (name "slave-read-only")
      (value "True")
      (dynamic "True")
      
      (name "slave-serve-stale-date")
      (value "True")
      (dynamic "True")
      
      (name "min-slaves-to-write")
      (value "0")
      (dynamic "True")
      
      (name "maxmemory")
      (value (jinja "{{ redis_server__maxmemory_shared }}"))
      (dynamic "True")
      
      (name "maxmemory-policy")
      (value "volatile-lru")
      (dynamic "True")
      
      (name "maxmemory-samples")
      (value "3")
      (dynamic "True")
      
      (name "save")
      (value (list
          "900 1"
          "300 10"
          "60 10000"))
      (dynamic "True")
      
      (name "tcp-backlog")
      (value "128")))
  (redis_server__base_options (list))
  (redis_server__default_instances (list
      
      (name "main")
      (port "6379")
      (pidfile "/var/run/redis/redis-server.pid")
      (unixsocket "/var/run/redis/redis-server.sock")
      (systemd_override "[Service]
PIDFile=/var/run/redis/redis-server.pid
RuntimeDirectory=redis
ReadWriteDirectories=-/var/run/redis
")
      (state "present")))
  (redis_server__instances (list))
  (redis_server__group_instances (list))
  (redis_server__host_instances (list))
  (redis_server__combined_instances (jinja "{{ redis_server__default_instances
                                      + redis_server__instances
                                      + redis_server__group_instances
                                      + redis_server__host_instances }}"))
  (redis_server__default_configuration (jinja "{{ lookup(\"template\", \"lookup/redis_server__filtered_instances.j2\")
                                         | from_yaml }}"))
  (redis_server__configuration (list))
  (redis_server__group_configuration (list))
  (redis_server__host_configuration (list))
  (redis_server__combined_configuration (jinja "{{ redis_server__default_configuration
                                          + redis_server__configuration
                                          + redis_server__group_configuration
                                          + redis_server__host_configuration }}"))
  (redis_server__apt_preferences__dependent_list (list
      
      (packages (list
          "redis"
          "redis-*"))
      (backports (list
          "stretch"))
      (by_role "debops.redis_server")
      (reason "Support for multiple Redis instances, compatibility with newer Debian releases")))
  (redis_server__etc_services__dependent_list (list
      
      (name "redis-server")
      (port "6379")
      (comment "Redis Server")))
  (redis_server__python__dependent_packages3 (list
      "python3-redis"))
  (redis_server__python__dependent_packages2 (list
      "python-redis"))
  (redis_server__ferm__dependent_rules (list
      
      (name "redis_server")
      (type "accept")
      (dport (jinja "{{ redis_server__env_ports }}"))
      (saddr (jinja "{{ redis_server__allow + redis_server__group_allow + redis_server__host_allow }}"))
      (weight "40")
      (accept_any "False")
      (multiport "True")
      (by_role "debops.redis_server")))
  (redis_server__sysctl__dependent_parameters (list
      
      (name "redis-server")
      (weight "80")
      (options (list
          
          (name "vm.overcommit_memory")
          (comment "Required to allow background saving of the Redis database without
issues. Ref: https://redis.io/topics/faq
")
          (value "1")))))
  (redis_server__sysfs__dependent_attributes (list
      
      (role "redis_server")
      (config (list
          
          (name "transparent_hugepages")
          (state "present"))))))
