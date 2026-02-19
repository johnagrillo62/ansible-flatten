(playbook "kubespray/roles/bootstrap_os/tasks/almalinux.yml"
  (tasks
    (task "Import Centos boostrap for Alma Linux"
      (import_tasks "centos.yml"))))
