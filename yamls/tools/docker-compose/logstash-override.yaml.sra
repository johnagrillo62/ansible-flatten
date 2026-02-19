(playbook "tools/docker-compose/logstash-override.yaml"
  (services 
    (logstash 
      (build 
        (context "../")
        (dockerfile "Dockerfile-logstash"))
      (container_name "tools_logstash_1")
      (hostname "logstash")
      (networks (list
          "awx")))))
