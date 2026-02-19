(playbook "kubespray/roles/adduser/vars/redhat.yml"
  (addusers (list
      
      (name "etcd")
      (comment "Etcd user")
      (create_home "true")
      (home (jinja "{{ etcd_data_dir }}"))
      (system "true")
      (shell "/sbin/nologin")
      
      (name "kube")
      (comment "Kubernetes user")
      (create_home "false")
      (system "true")
      (shell "/sbin/nologin")
      (group (jinja "{{ kube_cert_group }}")))))
