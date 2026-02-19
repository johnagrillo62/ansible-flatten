(playbook "sensu-ansible/tasks/Amazon/redis.yml"
  (tasks
    (task "Include ansible_distribution vars"
      (include_vars 
        (file (jinja "{{ ansible_distribution }}") ".yml"))
      (tags "redis"))
    (task "Install EPEL repo"
      (yum 
        (name (jinja "{{ epel_repo_rpm }}"))
        (state "present"))
      (tags "redis")
      (when "enable_epel_repo"))
    (task "Ensure redis is installed"
      (yum 
        (name (jinja "{{ sensu_redis_pkg_name }}"))
        (state (jinja "{{ sensu_redis_pkg_state }}"))
        (enablerepo "epel"))
      (tags "redis"))
    (task "Ensure redis binds to accessible IP"
      (lineinfile 
        (dest "/etc/redis.conf")
        (regexp "^bind")
        (line "bind 0.0.0.0"))
      (tags "redis"))))
