(playbook "kubespray/roles/bootstrap-os/tasks/main.yml"
  (tasks
    (task "Warn for usage of deprecated role"
      (fail 
        (msg "bootstrap-os is deprecated, switch to bootstrap_os"))
      (ignore_errors "true")
      (run_once "true"))
    (task "Compat for direct role import"
      (import_role 
        (name "bootstrap_os")))))
