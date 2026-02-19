(playbook "kubespray/roles/network_plugin/cilium/tasks/main.yml"
  (tasks
    (task "Cilium check"
      (import_tasks "check.yml"))
    (task "Cilium install"
      (include_tasks "install.yml"))
    (task "Cilium apply"
      (include_tasks "apply.yml"))))
