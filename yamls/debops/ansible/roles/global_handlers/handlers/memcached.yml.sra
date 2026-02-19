(playbook "debops/ansible/roles/global_handlers/handlers/memcached.yml"
  (tasks
    (task "Restart memcached"
      (ansible.builtin.service 
        (name "memcached")
        (state "restarted")))))
