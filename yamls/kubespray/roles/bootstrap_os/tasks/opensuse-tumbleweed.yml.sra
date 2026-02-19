(playbook "kubespray/roles/bootstrap_os/tasks/opensuse-tumbleweed.yml"
  (tasks
    (task "Import Opensuse bootstrap"
      (import_tasks "opensuse.yml"))))
