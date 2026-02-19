(playbook "debops/docs/ansible/roles/redis_server/examples/modify_main_instance.yml"
  (redis_server__instances (list
      
      (name "main")
      (bind (list
          "0.0.0.0"
          "::"))
      (master_host "redis.example.org")
      (master_port "6379"))))
