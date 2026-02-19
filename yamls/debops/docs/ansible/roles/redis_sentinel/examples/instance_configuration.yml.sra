(playbook "debops/docs/ansible/roles/redis_sentinel/examples/instance_configuration.yml"
  (redis_sentinel__configuration (list
      
      (name "main")
      (options (list
          
          (deny-scripts-reconfig "False")
          
          (name "syslog-ident")
          (value "sentinel-main-instance")
          (prefix "")
          
          (name "client-reconfig-script redis-ha")
          (value "/tmp/sentinel-reconfig.sh"))))))
