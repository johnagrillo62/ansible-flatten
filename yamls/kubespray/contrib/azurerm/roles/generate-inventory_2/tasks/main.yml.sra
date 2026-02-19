(playbook "kubespray/contrib/azurerm/roles/generate-inventory_2/tasks/main.yml"
  (tasks
    (task "Query Azure VMs IPs"
      (command "az vm list-ip-addresses -o json --resource-group " (jinja "{{ azure_resource_group }}"))
      (register "vm_ip_list_cmd"))
    (task "Query Azure VMs Roles"
      (command "az vm list -o json --resource-group " (jinja "{{ azure_resource_group }}"))
      (register "vm_list_cmd"))
    (task "Query Azure Load Balancer Public IP"
      (command "az network public-ip show -o json -g " (jinja "{{ azure_resource_group }}") " -n kubernetes-api-pubip")
      (register "lb_pubip_cmd"))
    (task "Set VM IP, roles lists and load balancer public IP"
      (set_fact 
        (vm_ip_list (jinja "{{ vm_ip_list_cmd.stdout }}"))
        (vm_roles_list (jinja "{{ vm_list_cmd.stdout }}"))
        (lb_pubip (jinja "{{ lb_pubip_cmd.stdout }}"))))
    (task "Generate inventory"
      (template 
        (src "inventory.j2")
        (dest (jinja "{{ playbook_dir }}") "/inventory")
        (mode "0644")))
    (task "Generate Load Balancer variables"
      (template 
        (src "loadbalancer_vars.j2")
        (dest (jinja "{{ playbook_dir }}") "/loadbalancer_vars.yml")
        (mode "0644")))))
