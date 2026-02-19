(playbook "kubespray/roles/kubernetes-apps/external_provisioner/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/external_provisioner/local_volume_provisioner")
      (when (list
          "local_volume_provisioner_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "apps"
          "local-volume-provisioner"
          "external-provisioner"))
      
      (role "kubernetes-apps/external_provisioner/local_path_provisioner")
      (when "local_path_provisioner_enabled")
      (tags (list
          "apps"
          "local-path-provisioner"
          "external-provisioner")))))
