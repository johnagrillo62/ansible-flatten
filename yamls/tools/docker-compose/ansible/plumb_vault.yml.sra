(playbook "tools/docker-compose/ansible/plumb_vault.yml"
    (play
    (name "Plumb AWX for Vault")
    (hosts "localhost")
    (gather_facts "False")
    (vars
      (awx_host "https://127.0.0.1:8043"))
    (tasks
      (task
        (include_role 
          (name "vault")
          (tasks_from "plumb"))))))
