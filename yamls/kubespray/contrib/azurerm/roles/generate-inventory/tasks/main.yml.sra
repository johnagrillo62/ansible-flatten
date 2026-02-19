(playbook "kubespray/contrib/azurerm/roles/generate-inventory/tasks/main.yml"
  (tasks
    (task "Query Azure VMs"
      (command "azure vm list-ip-address --json " (jinja "{{ azure_resource_group }}"))
      (register "vm_list_cmd"))
    (task "Set vm_list"
      (set_fact 
        (vm_list (jinja "{{ vm_list_cmd.stdout }}"))))
    (task "Generate inventory"
      (template 
        (src "inventory.j2")
        (dest (jinja "{{ playbook_dir }}") "/inventory")
        (mode "0644")))))
