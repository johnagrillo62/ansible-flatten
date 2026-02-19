(playbook "sensu-ansible/tasks/Debian/redis.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "redis"))
    (task "Ensure redis is installed"
      (apt 
        (name (jinja "{{ sensu_redis_pkg_name }}"))
        (state (jinja "{{ sensu_redis_pkg_state }}"))
        (update_cache "true"))
      (tags "redis"))
    (task "Ensure redis binds to accessible IP"
      (lineinfile 
        (dest "/etc/redis/redis.conf")
        (regexp "^bind")
        (line "bind 0.0.0.0"))
      (tags "redis")
      (notify "restart redis service"))
    (task
      (meta "flush_handlers")
      (tags "redis"))))
