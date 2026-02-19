(playbook "debops/docs/ansible/roles/redis_server/examples/instance_configuration.yml"
  (redis_server__configuration (list
      
      (name "main")
      (options (list
          
          (appendonly "False")
          
          (auto-aof-rewrite-percentage "100")
          
          (auto-aof-rewrite-min-size "64mb")
          
          (name "rename-command")
          (value (list
              "FLUSHDB \"\""
              "FLUSHALL \"\""
              "KEYS \"\""
              "CONFIG \"\""
              "PEXPIRE \"\""
              "DEL \"\""
              "CONFIG \"\""
              "SHUTDOWN \"\""
              "BGREWRITEAOF \"\""
              "BGSAVE \"\""
              "SAVE \"\""
              "SPOP \"\""
              "SREM \"\""
              "RENAME \"\""
              "DEBUG \"\"")))))))
