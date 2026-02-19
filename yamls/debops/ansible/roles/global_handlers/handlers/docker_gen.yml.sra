(playbook "debops/ansible/roles/global_handlers/handlers/docker_gen.yml"
  (tasks
    (task "Restart docker-gen"
      (ansible.builtin.service 
        (name "docker-gen")
        (state "restarted")))))
