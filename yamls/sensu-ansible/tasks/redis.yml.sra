(playbook "sensu-ansible/tasks/redis.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_tasks (jinja "{{ role_path }}") "/tasks/" (jinja "{{ ansible_distribution }}") "/redis.yml")
      (tags "redis"))
    (task "Ensure redis is running"
      (service 
        (name (jinja "{{ sensu_redis_service_name }}"))
        (pattern "/usr/bin/redis-server")
        (state "started")
        (enabled "true"))
      (tags "redis"))))
