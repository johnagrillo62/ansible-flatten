(playbook "tools/docker-compose/ansible/roles/vault/tasks/plumb.yml"
  (tasks
    (task "Set vault_addr"
      (include_tasks "set_vault_addr.yml"))
    (task "Load vault keys"
      (include_vars 
        (file (jinja "{{ vault_file }}"))))
    (task "Get AWX admin password"
      (include_vars 
        (file (jinja "{{ admin_password_file }}"))))
    (task "Create a HashiCorp Vault Credential"
      (awx.awx.credential 
        (credential_type "HashiCorp Vault Secret Lookup")
        (name "Vault Lookup Cred")
        (organization "Default")
        (controller_host (jinja "{{ awx_host }}"))
        (controller_username "admin")
        (controller_password (jinja "{{ admin_password }}"))
        (validate_certs "false")
        (inputs 
          (api_version "v1")
          (cacert (jinja "{{ lookup('ansible.builtin.file', '{{ vault_server_cert }}', errors='ignore') }}"))
          (default_auth_path "cert")
          (kubernetes_role "")
          (namespace "")
          (client_cert_public (jinja "{{ lookup('ansible.builtin.file', '{{ vault_client_cert }}', errors='ignore') }}"))
          (client_cert_private (jinja "{{ lookup('ansible.builtin.file', '{{ vault_client_key }}', errors='ignore') }}"))
          (token (jinja "{{ Initial_Root_Token }}"))
          (url (jinja "{{ vault_addr_from_container }}"))))
      (register "vault_cred"))
    (task "Create a custom credential type"
      (awx.awx.credential_type 
        (name "Vault Custom Cred Type")
        (kind "cloud")
        (controller_host (jinja "{{ awx_host }}"))
        (controller_username "admin")
        (controller_password (jinja "{{ admin_password }}"))
        (validate_certs "false")
        (injectors 
          (extra_vars 
            (the_secret_from_vault (jinja "{{ '{{' }}") " password " (jinja "{{ '}}' }}"))))
        (inputs 
          (fields (list
              
              (type "string")
              (id "password")
              (label "Password")
              (secret "true")))))
      (register "custom_vault_cred_type"))
    (task "Create a credential of the custom type for token auth"
      (awx.awx.credential 
        (credential_type (jinja "{{ custom_vault_cred_type.id }}"))
        (controller_host (jinja "{{ awx_host }}"))
        (controller_username "admin")
        (controller_password (jinja "{{ admin_password }}"))
        (validate_certs "false")
        (name "Credential From HashiCorp Vault via Token Auth")
        (inputs )
        (organization "Default"))
      (register "custom_credential_via_token"))
    (task "Use the Token Vault Credential For the new credential"
      (awx.awx.credential_input_source 
        (input_field_name "password")
        (target_credential (jinja "{{ custom_credential_via_token.id }}"))
        (source_credential (jinja "{{ vault_cred.id }}"))
        (controller_host (jinja "{{ awx_host }}"))
        (controller_username "admin")
        (controller_password (jinja "{{ admin_password }}"))
        (validate_certs "false")
        (metadata 
          (auth_path "")
          (secret_backend "my_engine")
          (secret_key "my_key")
          (secret_path "/my_root/my_folder")
          (secret_version ""))))
    (task "Create a HashiCorp Vault Credential for UserPass"
      (awx.awx.credential 
        (credential_type "HashiCorp Vault Secret Lookup")
        (name "Vault UserPass Lookup Cred")
        (organization "Default")
        (controller_host (jinja "{{ awx_host }}"))
        (controller_username "admin")
        (controller_password (jinja "{{ admin_password }}"))
        (validate_certs "false")
        (inputs 
          (api_version "v1")
          (default_auth_path "userpass")
          (kubernetes_role "")
          (namespace "")
          (url (jinja "{{ vault_addr_from_container }}"))
          (username (jinja "{{ vault_userpass_username }}"))
          (password (jinja "{{ vault_userpass_password }}"))))
      (register "vault_userpass_cred"))
    (task "Create a credential from the Vault UserPass Custom Cred Type"
      (awx.awx.credential 
        (credential_type (jinja "{{ custom_vault_cred_type.id }}"))
        (controller_host (jinja "{{ awx_host }}"))
        (controller_username "admin")
        (controller_password (jinja "{{ admin_password }}"))
        (validate_certs "false")
        (name "Credential From HashiCorp Vault via UserPass Auth")
        (inputs )
        (organization "Default"))
      (register "custom_credential_via_userpass"))
    (task "Use the Vault UserPass Credential  the new credential"
      (awx.awx.credential_input_source 
        (input_field_name "password")
        (target_credential (jinja "{{ custom_credential_via_userpass.id }}"))
        (source_credential (jinja "{{ vault_userpass_cred.id }}"))
        (controller_host (jinja "{{ awx_host }}"))
        (controller_username "admin")
        (controller_password (jinja "{{ admin_password }}"))
        (validate_certs "false")
        (metadata 
          (auth_path "")
          (secret_backend "userpass_engine")
          (secret_key "my_key")
          (secret_path "userpass_root/userpass_secret")
          (secret_version ""))))))
