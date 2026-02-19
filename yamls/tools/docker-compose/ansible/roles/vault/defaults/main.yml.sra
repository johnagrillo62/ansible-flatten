(playbook "tools/docker-compose/ansible/roles/vault/defaults/main.yml"
  (vault_file (jinja "{{ sources_dest }}") "/secrets/vault_init.yml")
  (admin_password_file (jinja "{{ sources_dest }}") "/secrets/admin_password.yml")
  (vault_cert_dir (jinja "{{ sources_dest }}") "/vault_certs")
  (vault_server_cert (jinja "{{ vault_cert_dir }}") "/server.crt")
  (vault_client_cert (jinja "{{ vault_cert_dir }}") "/client.crt")
  (vault_client_key (jinja "{{ vault_cert_dir }}") "/client.key")
  (vault_userpass_username "awx_userpass_admin")
  (vault_userpass_password "userpass123"))
