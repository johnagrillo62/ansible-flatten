(playbook "kubespray/roles/bootstrap_os/tasks/rocky.yml"
  (tasks
    (task "Import Centos boostrap for Rocky Linux"
      (import_tasks "centos.yml"))))
