(playbook "debops/ansible/roles/global_handlers/handlers/apparmor.yml"
  (tasks
    (task "Reload all AppArmor profiles"
      (ansible.builtin.service 
        (name "apparmor")
        (state "reloaded"))
      (when "ansible_local.apparmor.installed | d(False) | bool"))))
