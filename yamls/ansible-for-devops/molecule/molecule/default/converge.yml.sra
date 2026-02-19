(playbook "ansible-for-devops/molecule/molecule/default/converge.yml"
  (tasks
    (task "Converge"
      (hosts "all")
      (tasks (list
          
          (name "Update apt cache (on Debian).")
          (ansible.builtin.apt 
            (update_cache "true")
            (cache_valid_time "3600"))
          (when "ansible_os_family == 'Debian'"))))
    (task "Import playbook"
      (ansible.builtin.import_playbook "../../main.yml"))))
