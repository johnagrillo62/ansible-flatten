(playbook "debops/ansible/roles/etesync/handlers/main.yml"
  (tasks
    (task "Restart gunicorn for etesync"
      (ansible.builtin.service 
        (name "gunicorn@etesync")
        (state "restarted"))
      (when "(ansible_local | d() and ansible_local.gunicorn | d() and ansible_local.gunicorn.installed | bool)"))))
