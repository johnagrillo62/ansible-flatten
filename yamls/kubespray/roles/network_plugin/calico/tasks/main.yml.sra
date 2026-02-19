(playbook "kubespray/roles/network_plugin/calico/tasks/main.yml"
  (tasks
    (task "Calico Pre tasks"
      (import_tasks "pre.yml"))
    (task "Calico repos"
      (import_tasks "repos.yml"))
    (task "Calico install"
      (include_tasks "install.yml"))))
