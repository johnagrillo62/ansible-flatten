(playbook "debops/docs/ansible/roles/rails_deploy/examples/ansible/inventory/host_vars/ansible_controller.yml"
  (lxc_containers (list
      
      (name "somehost")
      (state "started")
      (network "nat")
      (config "True")
      
      (name "somedbhost")
      (state "started")
      (network "nat")
      (config "True")
      
      (name "aptcachehost")
      (state "started")
      (network "nat")
      (config "True"))))
