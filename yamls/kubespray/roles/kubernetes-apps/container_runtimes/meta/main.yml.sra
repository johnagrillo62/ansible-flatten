(playbook "kubespray/roles/kubernetes-apps/container_runtimes/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/container_runtimes/kata_containers")
      (when "kata_containers_enabled")
      (tags (list
          "apps"
          "kata-containers"
          "container-runtimes"))
      
      (role "kubernetes-apps/container_runtimes/gvisor")
      (when "gvisor_enabled")
      (tags (list
          "apps"
          "gvisor"
          "container-runtimes"))
      
      (role "kubernetes-apps/container_runtimes/crun")
      (when "crun_enabled")
      (tags (list
          "apps"
          "crun"
          "container-runtimes"))
      
      (role "kubernetes-apps/container_runtimes/youki")
      (when (list
          "youki_enabled"
          "container_manager == 'crio'"))
      (tags (list
          "apps"
          "youki"
          "container-runtimes")))))
