(playbook "debops/ansible/roles/redis_sentinel/defaults/main.yml"
  (redis_sentinel__base_packages (list
      "redis-sentinel"
      "redis-tools"))
  (redis_sentinel__packages (list))
  (redis_sentinel__version (jinja "{{ ansible_local.redis_sentinel.version | d(\"0.0.0\") }}"))
  (redis_sentinel__user "redis")
  (redis_sentinel__group "redis")
  (redis_sentinel__auth_group "redis-auth")
  (redis_sentinel__domain (jinja "{{ ansible_domain }}"))
  (redis_sentinel__auth_password (jinja "{{ ansible_local.redis_sentinel.password
                                   if (ansible_local.redis_sentinel.password | d())
                                   else (lookup(\"password\", secret +
                                         \"/redis/clusters/\" + redis_sentinel__domain +
                                         \"/password length=\" + redis_sentinel__password_length +
                                         \" chars=ascii_letters,digits,-_.\")) }}"))
  (redis_sentinel__password_length "256")
  (redis_sentinel__bind "localhost")
  (redis_sentinel__allow (list))
  (redis_sentinel__group_allow (list))
  (redis_sentinel__host_allow (list))
  (redis_sentinel__default_base_options (list
      
      (name "syslog-enabled")
      (value "True")
      
      (name "syslog-facility")
      (value "local0")
      
      (name "loglevel")
      (value "notice")
      
      (name "daemonize")
      (value "True")))
  (redis_sentinel__base_options (list))
  (redis_sentinel__default_instances (list
      
      (name "main")
      (port "26379")
      (pidfile "/var/run/sentinel/redis-sentinel.pid")
      (unixsocket "/var/run/sentinel/redis-sentinel.sock")
      (systemd_override "[Service]
PIDFile=/var/run/sentinel/redis-sentinel.pid
RuntimeDirectory=sentinel
ReadWriteDirectories=-/var/run/sentinel
")
      (state "present")))
  (redis_sentinel__instances (list))
  (redis_sentinel__group_instances (list))
  (redis_sentinel__host_instances (list))
  (redis_sentinel__combined_instances (jinja "{{ redis_sentinel__default_instances
                                        + redis_sentinel__instances
                                        + redis_sentinel__group_instances
                                        + redis_sentinel__host_instances }}"))
  (redis_sentinel__default_monitors (list
      
      (name "redis-ha")
      (host "localhost")
      (port "6379")
      (quorum "2")))
  (redis_sentinel__monitors (list))
  (redis_sentinel__group_monitors (list))
  (redis_sentinel__host_monitors (list))
  (redis_sentinel__combined_monitors (jinja "{{ redis_sentinel__default_monitors
                                       + redis_sentinel__monitors
                                       + redis_sentinel__group_monitors
                                       + redis_sentinel__host_monitors }}"))
  (redis_sentinel__default_configuration (jinja "{{ lookup(\"template\", \"lookup/redis_sentinel__filtered_instances.j2\")
                                           | from_yaml }}"))
  (redis_sentinel__configuration (list))
  (redis_sentinel__group_configuration (list))
  (redis_sentinel__host_configuration (list))
  (redis_sentinel__combined_configuration (jinja "{{ redis_sentinel__default_configuration
                                            + redis_sentinel__configuration
                                            + redis_sentinel__group_configuration
                                            + redis_sentinel__host_configuration }}"))
  (redis_sentinel__apt_preferences__dependent_list (list
      
      (packages (list
          "redis"
          "redis-*"))
      (backports (list
          "stretch"))
      (by_role "debops.redis_sentinel")
      (reason "Support for multiple Redis instances, compatibility with newer Debian releases")))
  (redis_sentinel__etc_services__dependent_list (list
      
      (name "redis-sentinel")
      (port "26379")
      (comment "Redis Sentinel")))
  (redis_sentinel__python__dependent_packages3 (list
      "python3-redis"))
  (redis_sentinel__python__dependent_packages2 (list
      "python-redis"))
  (redis_sentinel__ferm__dependent_rules (list
      
      (name "redis_sentinel")
      (type "accept")
      (dport (jinja "{{ redis_sentinel__env_ports }}"))
      (saddr (jinja "{{ redis_sentinel__allow + redis_sentinel__group_allow + redis_sentinel__host_allow }}"))
      (weight "40")
      (accept_any "False")
      (multiport "True")
      (by_role "debops.redis_sentinel"))))
