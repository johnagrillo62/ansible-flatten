(playbook "debops/ansible/roles/global_handlers/handlers/apt_cacher_ng.yml"
  (tasks
    (task "Restart apt-cacher-ng"
      (ansible.builtin.service 
        (name "apt-cacher-ng")
        (state "restarted")))))
