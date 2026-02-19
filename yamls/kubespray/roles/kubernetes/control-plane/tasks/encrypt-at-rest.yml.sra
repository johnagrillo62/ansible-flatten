(playbook "kubespray/roles/kubernetes/control-plane/tasks/encrypt-at-rest.yml"
  (tasks
    (task "Check if secret for encrypting data at rest already exist"
      (stat 
        (path (jinja "{{ kube_cert_dir }}") "/secrets_encryption.yaml")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "secrets_encryption_file"))
    (task "Slurp secrets_encryption file if it exists"
      (slurp 
        (src (jinja "{{ kube_cert_dir }}") "/secrets_encryption.yaml"))
      (register "secret_file_encoded")
      (when "secrets_encryption_file.stat.exists"))
    (task "Base 64 Decode slurped secrets_encryption.yaml file"
      (set_fact 
        (secret_file_decoded (jinja "{{ secret_file_encoded['content'] | b64decode | from_yaml }}")))
      (when "secrets_encryption_file.stat.exists"))
    (task "Extract secret value from secrets_encryption.yaml"
      (set_fact 
        (kube_encrypt_token_extracted (jinja "{{ secret_file_decoded | json_query(secrets_encryption_query) | first | b64decode }}")))
      (when "secrets_encryption_file.stat.exists"))
    (task "Set kube_encrypt_token across control plane nodes"
      (set_fact 
        (kube_encrypt_token (jinja "{{ kube_encrypt_token_extracted }}")))
      (delegate_facts "true")
      (with_inventory_hostnames "kube_control_plane")
      (delegate_to (jinja "{{ item }}"))
      (when "kube_encrypt_token_extracted is defined"))
    (task "Write secrets for encrypting secret data at rest"
      (template 
        (src "secrets_encryption.yaml.j2")
        (dest (jinja "{{ kube_cert_dir }}") "/secrets_encryption.yaml")
        (owner "root")
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640")))))
