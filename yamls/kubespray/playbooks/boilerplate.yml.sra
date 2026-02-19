(playbook "kubespray/playbooks/boilerplate.yml"
  (tasks
    (task "Check ansible version"
      (import_playbook "ansible_version.yml"))
    (task "Inventory setup and validation"
      (hosts "all")
      (gather_facts "false")
      (roles (list
          "dynamic_groups"
          "validate_inventory"))
      (tags "always"))
    (task "Install bastion ssh config"
      (hosts "bastion[0]")
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          
          (role "bastion-ssh-config")
          (tags (list
              "localhost"
              "bastion"))))
      (environment (jinja "{{ proxy_disable_env }}")))))
