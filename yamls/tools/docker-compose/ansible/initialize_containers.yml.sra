(playbook "tools/docker-compose/ansible/initialize_containers.yml"
    (play
    (name "Run any pre-hooks for other container")
    (hosts "localhost")
    (gather_facts "false")
    (tasks
      (task "Initialize vault"
        (include_role 
          (name "vault")
          (tasks_from "initialize"))
        (when "enable_vault | bool")))))
