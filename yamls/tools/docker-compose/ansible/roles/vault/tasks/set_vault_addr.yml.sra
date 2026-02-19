(playbook "tools/docker-compose/ansible/roles/vault/tasks/set_vault_addr.yml"
  (tasks
    (task "Detect if vault cert directory exist"
      (stat 
        (path (jinja "{{ vault_cert_dir }}")))
      (register "vault_cert_dir_stat"))
    (task "Set vault_addr for http"
      (set_fact 
        (vault_addr "http://127.0.0.1:1234")
        (vault_addr_from_host "http://localhost:1234")
        (vault_addr_from_container "http://tools_vault_1:1234"))
      (when "vault_cert_dir_stat.stat.exists == false"))
    (task "Set vault_addr for https"
      (set_fact 
        (vault_addr "https://127.0.0.1:1234")
        (vault_addr_from_host "https://localhost:1234")
        (vault_addr_from_container "https://tools_vault_1:1234"))
      (when "vault_cert_dir_stat.stat.exists == true"))))
