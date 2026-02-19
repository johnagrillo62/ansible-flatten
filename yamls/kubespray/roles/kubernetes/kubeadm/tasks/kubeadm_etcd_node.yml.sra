(playbook "kubespray/roles/kubernetes/kubeadm/tasks/kubeadm_etcd_node.yml"
  (tasks
    (task "Parse certificate key if not set"
      (set_fact 
        (kubeadm_certificate_key (jinja "{{ hostvars[groups['kube_control_plane'][0]]['kubeadm_certificate_key'] }}")))
      (when "kubeadm_certificate_key is undefined"))
    (task "Create kubeadm cert controlplane config"
      (template 
        (src "kubeadm-client.conf.j2")
        (dest (jinja "{{ kube_config_dir }}") "/kubeadm-cert-controlplane.conf")
        (mode "0640")
        (validate (jinja "{{ kubeadm_config_validate_enabled | ternary(bin_dir + '/kubeadm config validate --config %s', omit) }}")))
      (vars 
        (kubeadm_cert_controlplane "true")))
    (task "Pull control plane certs down"
      (shell (jinja "{{ bin_dir }}") "/kubeadm join phase control-plane-prepare download-certs --config " (jinja "{{ kube_config_dir }}") "/kubeadm-cert-controlplane.conf && " (jinja "{{ bin_dir }}") "/kubeadm join phase control-plane-prepare certs --config " (jinja "{{ kube_config_dir }}") "/kubeadm-cert-controlplane.conf")
      (args 
        (creates (jinja "{{ kube_cert_dir }}") "/apiserver-etcd-client.key")))
    (task "Delete unneeded certificates"
      (file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          (jinja "{{ kube_cert_dir }}") "/apiserver.crt"
          (jinja "{{ kube_cert_dir }}") "/apiserver.key"
          (jinja "{{ kube_cert_dir }}") "/ca.key"
          (jinja "{{ kube_cert_dir }}") "/etcd/ca.key"
          (jinja "{{ kube_cert_dir }}") "/etcd/healthcheck-client.crt"
          (jinja "{{ kube_cert_dir }}") "/etcd/healthcheck-client.key"
          (jinja "{{ kube_cert_dir }}") "/etcd/peer.crt"
          (jinja "{{ kube_cert_dir }}") "/etcd/peer.key"
          (jinja "{{ kube_cert_dir }}") "/etcd/server.crt"
          (jinja "{{ kube_cert_dir }}") "/etcd/server.key"
          (jinja "{{ kube_cert_dir }}") "/front-proxy-ca.crt"
          (jinja "{{ kube_cert_dir }}") "/front-proxy-ca.key"
          (jinja "{{ kube_cert_dir }}") "/front-proxy-client.crt"
          (jinja "{{ kube_cert_dir }}") "/front-proxy-client.key"
          (jinja "{{ kube_cert_dir }}") "/sa.key"
          (jinja "{{ kube_cert_dir }}") "/sa.pub")))
    (task "Calculate etcd cert serial"
      (command "openssl x509 -in " (jinja "{{ kube_cert_dir }}") "/apiserver-etcd-client.crt -noout -serial")
      (register "etcd_client_cert_serial_result")
      (changed_when "false")
      (when (list
          "group_names | intersect(['k8s_cluster', 'calico_rr']) | length > 0"))
      (tags (list
          "network")))
    (task "Set etcd_client_cert_serial"
      (set_fact 
        (etcd_client_cert_serial (jinja "{{ etcd_client_cert_serial_result.stdout.split('=')[1] }}")))
      (tags (list
          "network")))))
