(playbook "kubespray/roles/helm-apps/vars/main.yml"
  (helm_update "true")
  (helm_defaults 
    (atomic "true")
    (binary_path (jinja "{{ bin_dir }}") "/helm"))
  (helm_repository_defaults 
    (binary_path (jinja "{{ bin_dir }}") "/helm")
    (force_update "true")))
