(playbook "kubespray/roles/bootstrap_os/tasks/openEuler.yml"
  (tasks
    (task "Import Centos boostrap for openEuler"
      (import_tasks "centos.yml"))))
