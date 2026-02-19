(playbook "kubespray/roles/adduser/defaults/main.yml"
  (kube_owner "kube")
  (kube_cert_group "kube-cert")
  (etcd_data_dir "/var/lib/etcd")
  (addusers 
    (etcd 
      (name "etcd")
      (comment "Etcd user")
      (create_home "false")
      (system "true")
      (shell "/sbin/nologin"))
    (kube 
      (name "kube")
      (comment "Kubernetes user")
      (create_home "false")
      (system "true")
      (shell "/sbin/nologin")
      (group (jinja "{{ kube_cert_group }}"))))
  (adduser 
    (name (jinja "{{ user.name }}"))
    (group (jinja "{{ user.name | default(None) }}"))
    (comment (jinja "{{ user.comment | default(None) }}"))
    (shell (jinja "{{ user.shell | default(None) }}"))
    (system (jinja "{{ user.system | default(None) }}"))
    (create_home (jinja "{{ user.create_home | default(None) }}"))))
