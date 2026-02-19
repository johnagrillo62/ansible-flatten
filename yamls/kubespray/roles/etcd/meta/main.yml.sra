(playbook "kubespray/roles/etcd/meta/main.yml"
  (dependencies (list
      
      (role "adduser")
      (user (jinja "{{ addusers.etcd }}"))
      (when "not (ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\", \"ClearLinux\"] or is_fedora_coreos)")
      
      (role "adduser")
      (user (jinja "{{ addusers.kube }}"))
      (when "not (ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\", \"ClearLinux\"] or is_fedora_coreos)")
      
      (role "etcd_defaults"))))
