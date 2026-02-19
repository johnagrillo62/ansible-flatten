(playbook "kubespray/roles/kubernetes/control-plane/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes/kubeadm_common")
      
      (role "adduser")
      (user (jinja "{{ addusers.etcd }}"))
      (when (list
          "etcd_deployment_type == \"kubeadm\""
          "not (ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\", \"ClearLinux\"] or is_fedora_coreos)"))
      
      (role "network_plugin/calico_defaults")
      
      (role "etcd_defaults"))))
