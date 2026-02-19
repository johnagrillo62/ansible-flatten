(playbook "tools/docker-compose/ansible/roles/vault/tasks/initialize.yml"
  (tasks
    (task "Set vault_addr"
      (include_tasks "set_vault_addr.yml"))
    (task
      (block (list
          
          (name "Start the vault")
          (community.docker.docker_compose_v2 
            (state "present")
            (services "vault")
            (project_src (jinja "{{ sources_dest }}")))
          (register "vault_start")
          
          (name "Run the initialization")
          (community.docker.docker_container_exec 
            (command "vault operator init")
            (container "tools_vault_1")
            (env 
              (VAULT_ADDR (jinja "{{ vault_addr }}"))
              (VAULT_SKIP_VERIFY "true")))
          (register "vault_initialization")
          (failed_when (list
              "vault_initialization.rc != 0"
              "vault_initialization.stderr.find(\"Vault is already initialized\") == -1"))
          (changed_when (list
              "vault_initialization.rc == 0"))
          (retries "5")
          (delay "5")
          
          (name "Write out initialization file")
          (copy 
            (content (jinja "{{ vault_initialization.stdout_lines[0] | regex_replace('Unseal Key ', 'Unseal_Key_') }}") "
" (jinja "{{ vault_initialization.stdout_lines[1] | regex_replace('Unseal Key ', 'Unseal_Key_') }}") "
" (jinja "{{ vault_initialization.stdout_lines[2] | regex_replace('Unseal Key ', 'Unseal_Key_') }}") "
" (jinja "{{ vault_initialization.stdout_lines[3] | regex_replace('Unseal Key ', 'Unseal_Key_') }}") "
" (jinja "{{ vault_initialization.stdout_lines[4] | regex_replace('Unseal Key ', 'Unseal_Key_') }}") "
" (jinja "{{ vault_initialization.stdout_lines[6] | regex_replace('Initial Root Token', 'Initial_Root_Token') }}") "
")
            (dest (jinja "{{ vault_file }}")))
          (when "(vault_initialization.stdout_lines | length) > 0")
          
          (name "Unlock the vault")
          (include_role 
            (name "vault")
            (tasks_from "unseal.yml"))
          
          (name "Configure the vault with cert auth")
          (block (list
              
              (name "Create a cert auth mount")
              (flowerysong.hvault.write 
                (path "sys/auth/cert")
                (vault_addr (jinja "{{ vault_addr_from_host }}"))
                (validate_certs "false")
                (token (jinja "{{ Initial_Root_Token }}"))
                (data 
                  (type "cert")))
              (register "vault_auth_cert")
              (failed_when (list
                  "vault_auth_cert.result.errors | default([]) | length > 0"
                  "'path is already in use at cert/' not in vault_auth_cert.result.errors | default([])"))
              (changed_when (list
                  "vault_auth_cert.result.errors | default([]) | length == 0"))
              
              (name "Configure client certificate")
              (flowerysong.hvault.write 
                (path "auth/cert/certs/awx-client")
                (vault_addr (jinja "{{ vault_addr_from_host }}"))
                (validate_certs "false")
                (token (jinja "{{ Initial_Root_Token }}"))
                (data 
                  (name "awx-client")
                  (certificate (jinja "{{ lookup('ansible.builtin.file', '{{ vault_client_cert }}') }}"))
                  (policies (list
                      "root"))))))
          (when "vault_tls | bool")
          
          (name "Create an engine")
          (flowerysong.hvault.engine 
            (path "my_engine")
            (type "kv")
            (vault_addr (jinja "{{ vault_addr_from_host }}"))
            (validate_certs "false")
            (token (jinja "{{ Initial_Root_Token }}")))
          
          (name "Create a demo secret")
          (flowerysong.hvault.kv 
            (mount_point "my_engine/my_root")
            (key "my_folder")
            (value 
              (my_key "this_is_the_secret_value"))
            (vault_addr (jinja "{{ vault_addr_from_host }}"))
            (validate_certs "false")
            (token (jinja "{{ Initial_Root_Token }}")))
          
          (name "Create userpass engine")
          (flowerysong.hvault.engine 
            (path "userpass_engine")
            (type "kv")
            (vault_addr (jinja "{{ vault_addr_from_host }}"))
            (validate_certs "false")
            (token (jinja "{{ Initial_Root_Token }}")))
          
          (name "Create a userpass secret")
          (flowerysong.hvault.kv 
            (mount_point "userpass_engine/userpass_root")
            (key "userpass_secret")
            (value 
              (my_key "this_is_the_userpass_secret_value"))
            (vault_addr (jinja "{{ vault_addr_from_host }}"))
            (validate_certs "false")
            (token (jinja "{{ Initial_Root_Token }}")))
          
          (name "Create userpass access policy")
          (flowerysong.hvault.policy 
            (vault_addr (jinja "{{ vault_addr_from_host }}"))
            (validate_certs "false")
            (token (jinja "{{ Initial_Root_Token }}"))
            (name "userpass_engine")
            (policy 
              (userpass_engine/* (list
                  "create"
                  "read"
                  "update"
                  "delete"
                  "list"))
              (sys/mounts:/* (list
                  "create"
                  "read"
                  "update"
                  "delete"
                  "list"))
              (sys/mounts (list
                  "read"))))
          
          (name "Create userpass auth mount")
          (flowerysong.hvault.write 
            (path "sys/auth/userpass")
            (vault_addr (jinja "{{ vault_addr_from_host }}"))
            (validate_certs "false")
            (token (jinja "{{ Initial_Root_Token }}"))
            (data 
              (type "userpass")))
          (register "vault_auth_userpass")
          (changed_when "vault_auth_userpass.result.errors | default([]) | length == 0")
          (failed_when (list
              "vault_auth_userpass.result.errors | default([]) | length > 0"
              "'path is already in use at userpass/' not in vault_auth_userpass.result.errors | default([])"))
          
          (name "Add awx_userpass_admin user to auth_method")
          (flowerysong.hvault.write 
            (vault_addr (jinja "{{ vault_addr_from_host }}"))
            (validate_certs "false")
            (token (jinja "{{ Initial_Root_Token }}"))
            (path "auth/userpass/users/" (jinja "{{ vault_userpass_username }}"))
            (data 
              (password (jinja "{{ vault_userpass_password }}"))
              (policies (list
                  "userpass_engine"))))))
      (always (list
          
          (name "Stop the vault")
          (community.docker.docker_compose_v2 
            (state "absent")
            (project_src (jinja "{{ sources_dest }}")))
          (when "vault_start is defined and vault_start.changed"))))))
