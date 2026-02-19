(playbook "kubespray/roles/kubernetes-apps/container_engine_accelerator/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/container_engine_accelerator/nvidia_gpu")
      (when "nvidia_accelerator_enabled")
      (tags (list
          "apps"
          "nvidia_gpu"
          "container_engine_accelerator")))))
