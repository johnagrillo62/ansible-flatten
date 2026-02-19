(playbook "sensu-ansible/tasks/SmartOS/redis.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "redis"))
    (task "Ensure redis is installed"
      (pkgin "name=redis state=" (jinja "{{ sensu_redis_pkg_state }}"))
      (tags "redis"))))
