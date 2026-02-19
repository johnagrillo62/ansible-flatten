(playbook "debops/docs/ansible/roles/redis_server/examples/instance_configuration_remove_list_item.yml"
  (redis_server__configuration (list
      
      (name "main")
      (options (list
          
          (name "save")
          (value (list
              "90 1000"
              
              (name "60 10000")
              (state "absent")))
          (dynamic "True"))))))
