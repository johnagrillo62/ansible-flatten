(playbook "debops/ansible/roles/global_handlers/handlers/ferm.yml"
  (tasks
    (task "Restart ferm"
      (ansible.builtin.service 
        (name "ferm")
        (state "restarted"))
      (when "(ansible_local.ferm.enabled | d()) | bool and not ansible_check_mode"))))
