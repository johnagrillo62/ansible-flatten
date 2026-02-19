(playbook "sensu-ansible/tasks/Ubuntu/redis.yml"
  (list
    
    (name "Include ansible_distribution vars")
    (include_vars 
      (file (jinja "{{ ansible_distribution }}") ".yml"))
    
    (name "Ensure redis is installed")
    (apt 
      (name (jinja "{{ sensu_redis_pkg_name }}"))
      (state (jinja "{{ sensu_redis_pkg_state }}"))
      (update_cache "true"))
    (register "sensu_ubuntu_redis_install")
    
    (name "Stop redis manually")
    (shell "kill $(pgrep redis-server)")
    (when (list
        "sensu_ubuntu_redis_install is changed"
        "ansible_distribution_version == '14.04'"))
    
    (name "Ensure redis binds to accessible IP")
    (lineinfile 
      (dest "/etc/redis/redis.conf")
      (regexp "^bind")
      (line "bind 0.0.0.0"))
    (notify "restart redis service")
    
    (meta "flush_handlers")))
