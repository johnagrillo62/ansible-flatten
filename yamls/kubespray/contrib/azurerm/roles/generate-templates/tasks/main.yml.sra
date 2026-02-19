(playbook "kubespray/contrib/azurerm/roles/generate-templates/tasks/main.yml"
  (tasks
    (task "Set base_dir"
      (set_fact 
        (base_dir (jinja "{{ playbook_dir }}") "/.generated/")))
    (task "Create base_dir"
      (file 
        (path (jinja "{{ base_dir }}"))
        (state "directory")
        (recurse "true")
        (mode "0755")))
    (task "Store json files in base_dir"
      (template 
        (src (jinja "{{ item }}"))
        (dest (jinja "{{ base_dir }}") "/" (jinja "{{ item }}"))
        (mode "0644"))
      (with_items (list
          "network.json"
          "storage.json"
          "availability-sets.json"
          "bastion.json"
          "masters.json"
          "minions.json"
          "clear-rg.json")))))
