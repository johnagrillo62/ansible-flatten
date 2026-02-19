(playbook "debops/ansible/roles/global_handlers/handlers/docker_server.yml"
  (tasks
    (task "Restart docker"
      (ansible.builtin.service 
        (name "docker")
        (state "restarted")))))
