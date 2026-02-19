(playbook "kubespray/roles/bastion-ssh-config/molecule/default/molecule.yml"
  (role_name_check "1")
  (dependency 
    (name "galaxy"))
  (platforms (list
      
      (name "bastion-01")
      (cloud_image "ubuntu-2204")
      (vm_cpu_cores "1")
      (vm_memory "512")))
  (provisioner 
    (name "ansible")
    (env 
      (ANSIBLE_ROLES_PATH "../../../"))
    (config_options 
      (defaults 
        (callbacks_enabled "profile_tasks")
        (timeout "120")))
    (inventory 
      (hosts 
        (all 
          (hosts null)
          (children 
            (bastion 
              (hosts 
                (bastion-01 null)))))))
    (playbooks 
      (create "../../../../tests/cloud_playbooks/create-kubevirt.yml")))
  (verifier 
    (name "testinfra")))
