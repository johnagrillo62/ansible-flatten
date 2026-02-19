(playbook "debops/ansible/roles/global_handlers/handlers/sysfs.yml"
  (tasks
    (task "Restart sysfsutils"
      (ansible.builtin.service 
        (name "sysfsutils")
        (state "restarted"))
      (when "(ansible_local.sysfs.enabled | d()) | bool"))))
