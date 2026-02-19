(playbook "sensu-ansible/tasks/Fedora/redis.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "redis"))
    (task "Ensure jemalloc is installed as a dependency of Redis"
      (dnf 
        (name "jemalloc")
        (state "present"))
      (tags "redis"))
    (task "Ensure redis is installed"
      (dnf 
        (name (jinja "{{ sensu_redis_pkg_name }}"))
        (state (jinja "{{ sensu_redis_pkg_state }}")))
      (tags "redis"))
    (task "Ensure redis binds to accessible IP"
      (lineinfile 
        (dest "/etc/redis.conf")
        (regexp "^bind")
        (line "bind 0.0.0.0"))
      (tags "redis"))))
