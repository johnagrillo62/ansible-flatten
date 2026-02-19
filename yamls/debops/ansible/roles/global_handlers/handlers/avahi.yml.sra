(playbook "debops/ansible/roles/global_handlers/handlers/avahi.yml"
  (tasks
    (task "Restart avahi-daemon"
      (ansible.builtin.service 
        (name "avahi-daemon")
        (state "restarted"))
      (when "(ansible_local.avahi.installed | d()) | bool"))))
