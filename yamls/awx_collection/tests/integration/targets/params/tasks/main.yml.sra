(playbook "awx_collection/tests/integration/targets/params/tasks/main.yml"
  (tasks
    (task "Perform an action with a different hostname via aap_hostname"
      (inventory 
        (name "Demo Inventory")
        (organization "Default")
        (aap_hostname "https://foohostbar.invalid"))
      (ignore_errors "true")
      (register "result"))
    (task
      (assert 
        (that (list
            "'foohostbar' in result.msg"))))))
