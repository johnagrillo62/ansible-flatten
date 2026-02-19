(playbook "tools/docker-compose/ansible/roles/vault/tasks/unseal.yml"
  (tasks
    (task "Set vault_addr"
      (include_tasks "set_vault_addr.yml"))
    (task "Load vault keys"
      (include_vars 
        (file (jinja "{{ vault_file }}"))))
    (task "Unseal the vault"
      (flowerysong.hvault.seal 
        (vault_addr (jinja "{{ vault_addr_from_host }}"))
        (validate_certs "false")
        (state "unsealed")
        (key (jinja "{{ item }}")))
      (loop (list
          (jinja "{{ Unseal_Key_1 }}")
          (jinja "{{ Unseal_Key_2 }}")
          (jinja "{{ Unseal_Key_3 }}")))
      (register "unseal_result")
      (until "unseal_result is succeeded or unseal_result is failed and 'Connection refused' not in unseal_result.msg")
      (retries "5")
      (delay "1"))))
