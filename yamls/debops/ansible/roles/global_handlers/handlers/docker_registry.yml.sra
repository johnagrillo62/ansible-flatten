(playbook "debops/ansible/roles/global_handlers/handlers/docker_registry.yml"
  (tasks
    (task "Restart docker-registry"
      (ansible.builtin.service 
        (name "docker-registry")
        (state "restarted")))))
