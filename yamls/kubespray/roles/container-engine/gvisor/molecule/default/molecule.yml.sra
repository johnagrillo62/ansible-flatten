(playbook "kubespray/roles/container-engine/gvisor/molecule/default/molecule.yml"
  (role_name_check "1")
  (platforms (list
      
      (cloud_image "ubuntu-2404")
      (name "ubuntu24")
      (vm_cpu_cores "1")
      (vm_memory "1024")
      (node_groups (list
          "kube_control_plane"))
      
      (name "almalinux9")
      (cloud_image "almalinux-9")
      (vm_cpu_cores "1")
      (vm_memory "1024")
      (node_groups (list
          "kube_control_plane"))))
  (provisioner 
    (name "ansible")
    (env 
      (ANSIBLE_ROLES_PATH "../../../../"))
    (config_options 
      (defaults 
        (callbacks_enabled "profile_tasks")
        (timeout "120")))
    (inventory 
      (group_vars 
        (k8s_cluster 
          (gvisor_enabled "true")
          (container_manager "containerd"))))
    (playbooks 
      (create "../../../../../tests/cloud_playbooks/create-kubevirt.yml")
      (prepare "../../../molecule/prepare.yml")))
  (verifier 
    (name "ansible")))
