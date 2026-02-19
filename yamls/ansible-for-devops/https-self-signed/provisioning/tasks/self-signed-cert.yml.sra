(playbook "ansible-for-devops/https-self-signed/provisioning/tasks/self-signed-cert.yml"
  (tasks
    (task "Ensure directory exists for local self-signed TLS certs."
      (file 
        (path (jinja "{{ certificate_dir }}") "/" (jinja "{{ server_hostname }}"))
        (state "directory")))
    (task "Generate an OpenSSL private key."
      (openssl_privatekey 
        (path (jinja "{{ certificate_dir }}") "/" (jinja "{{ server_hostname }}") "/privkey.pem")))
    (task "Generate an OpenSSL CSR."
      (openssl_csr 
        (path (jinja "{{ certificate_dir }}") "/" (jinja "{{ server_hostname }}") ".csr")
        (privatekey_path (jinja "{{ certificate_dir }}") "/" (jinja "{{ server_hostname }}") "/privkey.pem")
        (common_name (jinja "{{ server_hostname }}"))))
    (task "Generate a Self Signed OpenSSL certificate."
      (openssl_certificate 
        (path (jinja "{{ certificate_dir }}") "/" (jinja "{{ server_hostname }}") "/fullchain.pem")
        (privatekey_path (jinja "{{ certificate_dir }}") "/" (jinja "{{ server_hostname }}") "/privkey.pem")
        (csr_path (jinja "{{ certificate_dir }}") "/" (jinja "{{ server_hostname }}") ".csr")
        (provider "selfsigned")))))
