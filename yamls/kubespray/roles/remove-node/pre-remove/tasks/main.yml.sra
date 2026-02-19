(playbook "kubespray/roles/remove-node/pre-remove/tasks/main.yml"
  (tasks
    (task "Warn for usage of deprecated role"
      (fail 
        (msg "remove-node/pre-remove is deprecated, switch to remove_node/pre_remove"))
      (ignore_errors "true")
      (run_once "true"))
    (task "Compat for direct role import"
      (import_role 
        (name "remove_node/pre_remove")))))
