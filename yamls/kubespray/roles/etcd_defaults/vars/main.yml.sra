(playbook "kubespray/roles/etcd_defaults/vars/main.yml"
  (cert_files 
    (master (list
        (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ inventory_hostname }}") ".pem"
        (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ inventory_hostname }}") "-key.pem"
        (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem"
        (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem"))
    (node (list
        (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ inventory_hostname }}") ".pem"
        (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ inventory_hostname }}") "-key.pem"))))
