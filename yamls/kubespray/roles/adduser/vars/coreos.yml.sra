(playbook "kubespray/roles/adduser/vars/coreos.yml"
  (addusers (list
      
      (name "kube")
      (comment "Kubernetes user")
      (shell "/sbin/nologin")
      (system "true")
      (group (jinja "{{ kube_cert_group }}"))
      (create_home "false"))))
