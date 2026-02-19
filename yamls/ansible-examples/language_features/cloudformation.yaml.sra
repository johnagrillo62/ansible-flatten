(playbook "ansible-examples/language_features/cloudformation.yaml"
    (play
    (name "provision stack")
    (hosts "localhost")
    (connection "local")
    (gather_facts "false")
    (tasks
      (task "launch ansible cloudformation example"
        (cloudformation "stack_name=\"ansible-cloudformation\" state=present region=us-east-1 disable_rollback=true template=files/cloudformation-example.json
")
        (args 
          (template_parameters 
            (KeyName "jmartin")
            (DiskType "ephemeral")
            (InstanceType "m1.small")
            (ClusterSize "3")))
        (register "stack"))
      (task "show stack outputs"
        (debug "msg=\"My stack outputs are " (jinja "{{stack.stack_outputs}}") "\"")))))
