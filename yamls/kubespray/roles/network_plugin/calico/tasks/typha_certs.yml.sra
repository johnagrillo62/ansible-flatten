(playbook "kubespray/roles/network_plugin/calico/tasks/typha_certs.yml"
  (tasks
    (task "Calico | Check if typha-server exists"
      (command (jinja "{{ kubectl }}") " -n kube-system get secret typha-server")
      (register "typha_server_secret")
      (changed_when "false")
      (failed_when "false"))
    (task "Calico | Ensure calico certs dir"
      (file 
        (path "/etc/calico/certs")
        (state "directory")
        (mode "0755"))
      (when "typha_server_secret.rc != 0"))
    (task "Calico | Copy ssl script for typha certs"
      (template 
        (src "make-ssl-calico.sh.j2")
        (dest (jinja "{{ bin_dir }}") "/make-ssl-typha.sh")
        (mode "0755"))
      (when "typha_server_secret.rc != 0"))
    (task "Calico | Copy ssl config for typha certs"
      (copy 
        (src "openssl.conf")
        (dest "/etc/calico/certs/openssl.conf")
        (mode "0644"))
      (when "typha_server_secret.rc != 0"))
    (task "Calico | Generate typha certs"
      (command (jinja "{{ bin_dir }}") "/make-ssl-typha.sh -f /etc/calico/certs/openssl.conf -c " (jinja "{{ kube_cert_dir }}") " -d /etc/calico/certs -s typha")
      (when "typha_server_secret.rc != 0"))
    (task "Calico | Create typha tls secrets"
      (command (jinja "{{ kubectl }}") " -n kube-system create secret tls " (jinja "{{ item.name }}") " --cert " (jinja "{{ item.cert }}") " --key " (jinja "{{ item.key }}"))
      (with_items (list
          
          (name "typha-server")
          (cert "/etc/calico/certs/typha-server.crt")
          (key "/etc/calico/certs/typha-server.key")
          
          (name "typha-client")
          (cert "/etc/calico/certs/typha-client.crt")
          (key "/etc/calico/certs/typha-client.key")))
      (when "typha_server_secret.rc != 0"))))
