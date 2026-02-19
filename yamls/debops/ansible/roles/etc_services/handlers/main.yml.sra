(playbook "debops/ansible/roles/etc_services/handlers/main.yml"
  (tasks
    (task "Assemble services.d"
      (ansible.builtin.assemble 
        (src "/etc/services.d")
        (dest "/etc/services")
        (backup "False")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "etc_services__enabled | bool"))))
