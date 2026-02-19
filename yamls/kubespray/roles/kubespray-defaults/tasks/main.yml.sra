(playbook "kubespray/roles/kubespray-defaults/tasks/main.yml"
  (tasks
    (task "Warn for usage of deprecated role"
      (fail 
        (msg "kubespray-defaults is deprecated, switch to kubespray_defaults"))
      (ignore_errors "true")
      (run_once "true"))
    (task "Compat for direct role import"
      (import_role 
        (name "kubespray_defaults")))))
