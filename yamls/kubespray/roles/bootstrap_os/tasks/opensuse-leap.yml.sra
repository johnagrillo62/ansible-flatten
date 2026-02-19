(playbook "kubespray/roles/bootstrap_os/tasks/opensuse-leap.yml"
  (tasks
    (task "Import Opensuse bootstrap"
      (import_tasks "opensuse.yml"))))
