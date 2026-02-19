(playbook "kubespray/roles/container-engine/kata-containers/molecule/default/molecule.yml"
  (role_name_check "1")
  (platforms (list
      
      (name "ubuntu22")
      (cloud_image "ubuntu-2204")
      (vm_cpu_cores "1")
      (vm_memory "1024")
      (node_groups (list
          "kube_control_plane"))
      
      (name "ubuntu24")
      (cloud_image "ubuntu-2404")
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
    (playbooks 
      (create "../../../../../tests/cloud_playbooks/create-kubevirt.yml")
      (prepare "../../../molecule/prepare.yml")))
  (verifier 
    (name "ansible")))
