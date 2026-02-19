(playbook "tools/docker-compose/ansible/unseal_vault.yml"
    (play
    (name "Run tasks post startup")
    (hosts "localhost")
    (gather_facts "False")
    (tasks
      (task "Unseal the vault"
        (ansible.builtin.include_role 
          (name "vault")
          (tasks_from "unseal")))
      (task "Display root token"
        (ansible.builtin.debug 
          (var "Initial_Root_Token"))))))
