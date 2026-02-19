(playbook "kubespray/roles/kubernetes/control-plane/tasks/kubeadm-etcd.yml"
  (tasks
    (task "Calculate etcd cert serial"
      (command "openssl x509 -in " (jinja "{{ kube_cert_dir }}") "/apiserver-etcd-client.crt -noout -serial")
      (register "etcd_client_cert_serial_result")
      (changed_when "false")
      (tags (list
          "network")))
    (task "Set etcd_client_cert_serial"
      (set_fact 
        (etcd_client_cert_serial (jinja "{{ etcd_client_cert_serial_result.stdout.split('=')[1] }}")))
      (tags (list
          "network")))
    (task "Ensure etcdctl and etcdutl script is installed"
      (import_role 
        (name "etcdctl_etcdutl"))
      (when "etcd_deployment_type == \"kubeadm\"")
      (tags (list
          "etcdctl"
          "etcdutl")))
    (task "Set ownership for etcd data directory"
      (file 
        (path (jinja "{{ etcd_data_dir }}"))
        (owner (jinja "{{ etcd_owner }}"))
        (group (jinja "{{ etcd_owner }}"))
        (mode "0700"))
      (when "etcd_deployment_type == \"kubeadm\""))))
