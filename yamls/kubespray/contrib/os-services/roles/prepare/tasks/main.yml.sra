(playbook "kubespray/contrib/os-services/roles/prepare/tasks/main.yml"
  (tasks
    (task "Disable firewalld and ufw"
      (block (list
          
          (name "List services")
          (service_facts null)
          
          (name "Disable service firewalld")
          (systemd_service 
            (name "firewalld")
            (state "stopped")
            (enabled "false"))
          (when "'firewalld.service' in services and services['firewalld.service'].status != 'not-found'")
          
          (name "Disable service ufw")
          (systemd_service 
            (name "ufw")
            (state "stopped")
            (enabled "false"))
          (when "'ufw.service' in services and services['ufw.service'].status != 'not-found'")))
      (when (list
          "disable_service_firewall is defined and disable_service_firewall")))))
