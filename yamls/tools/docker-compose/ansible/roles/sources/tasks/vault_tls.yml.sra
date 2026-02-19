(playbook "tools/docker-compose/ansible/roles/sources/tasks/vault_tls.yml"
  (tasks
    (task "Create Certificates for HashiCorp Vault"
      (block (list
          
          (name "Create Hashicorp Vault cert directory")
          (file 
            (path (jinja "{{ hashivault_cert_dir }}"))
            (state "directory"))
          
          (name "Generate vault server certificate")
          (command "openssl req -new -newkey rsa:2048 -x509 -days 365 -nodes -out " (jinja "{{ hashivault_server_public_keyfile }}") " -keyout " (jinja "{{ hashivault_server_private_keyfile }}") " -subj \"" (jinja "{{ hashivault_server_cert_subject }}") "\"" (jinja "{% for ext in hashivault_server_cert_extensions %}") " -addext \"" (jinja "{{ ext }}") "\"" (jinja "{% endfor %}"))
          (args 
            (creates (jinja "{{ hashivault_server_public_keyfile }}")))
          
          (name "Generate vault test client certificate")
          (command "openssl req -new -newkey rsa:2048 -x509 -days 365 -nodes -out " (jinja "{{ hashivault_client_public_keyfile }}") " -keyout " (jinja "{{ hashivault_client_private_keyfile }}") " -subj \"" (jinja "{{ hashivault_client_cert_subject }}") "\"" (jinja "{% for ext in hashivault_client_cert_extensions %}") " -addext \"" (jinja "{{ ext }}") "\"" (jinja "{% endfor %}"))
          (args 
            (creates (jinja "{{ hashivault_client_public_keyfile }}")))
          
          (name "Set mode for vault certificates")
          (ansible.builtin.file 
            (path (jinja "{{ hashivault_cert_dir }}"))
            (recurse "true")
            (state "directory")
            (mode "0777"))))
      (when "vault_tls | bool"))
    (task "Delete Certificates for HashiCorp Vault"
      (file 
        (path (jinja "{{ hashivault_cert_dir }}"))
        (state "absent"))
      (when "vault_tls | bool == false"))))
