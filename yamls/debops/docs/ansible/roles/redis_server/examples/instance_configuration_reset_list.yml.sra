(playbook "debops/docs/ansible/roles/redis_server/examples/instance_configuration_reset_list.yml"
  (redis_server__configuration (list
      
      (name "main")
      (options (list
          
          (name "save")
          (value "")
          (dynamic "True")
          
          (name "save")
          (value (list
              "1200 1"))
          (dynamic "True"))))))
