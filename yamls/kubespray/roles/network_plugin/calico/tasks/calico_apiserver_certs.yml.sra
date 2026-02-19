(playbook "kubespray/roles/network_plugin/calico/tasks/calico_apiserver_certs.yml"
  (tasks
    (task "Calico | Check if calico apiserver exists"
      (command (jinja "{{ kubectl }}") " -n calico-apiserver get secret calico-apiserver-certs")
      (register "calico_apiserver_secret")
      (changed_when "false")
      (failed_when "false"))
    (task "Calico | Create ns manifests"
      (template 
        (src "calico-apiserver-ns.yml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/calico-apiserver-ns.yml")
        (mode "0644")))
    (task "Calico | Apply ns manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/calico-apiserver-ns.yml")
        (state "latest")))
    (task "Calico | Ensure calico certs dir"
      (file 
        (path "/etc/calico/certs")
        (state "directory")
        (mode "0755"))
      (when "calico_apiserver_secret.rc != 0"))
    (task "Calico | Copy ssl script for apiserver certs"
      (template 
        (src "make-ssl-calico.sh.j2")
        (dest (jinja "{{ bin_dir }}") "/make-ssl-apiserver.sh")
        (mode "0755"))
      (when "calico_apiserver_secret.rc != 0"))
    (task "Calico | Copy ssl config for apiserver certs"
      (copy 
        (src "openssl.conf")
        (dest "/etc/calico/certs/openssl.conf")
        (mode "0644"))
      (when "calico_apiserver_secret.rc != 0"))
    (task "Calico | Generate apiserver certs"
      (command (jinja "{{ bin_dir }}") "/make-ssl-apiserver.sh -f /etc/calico/certs/openssl.conf -c " (jinja "{{ kube_cert_dir }}") " -d /etc/calico/certs -s apiserver")
      (when "calico_apiserver_secret.rc != 0"))
    (task "Calico | Create calico apiserver generic secrets"
      (command (jinja "{{ kubectl }}") " -n calico-apiserver create secret generic " (jinja "{{ item.name }}") " --from-file=" (jinja "{{ item.cert }}") " --from-file=" (jinja "{{ item.key }}"))
      (with_items (list
          
          (name "calico-apiserver-certs")
          (cert "/etc/calico/certs/apiserver.crt")
          (key "/etc/calico/certs/apiserver.key")))
      (when "calico_apiserver_secret.rc != 0"))))
