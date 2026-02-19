(playbook "debops/docs/ansible/roles/redis_server/examples/multiple_instances.yml"
  (redis_server__bind (list
      "0.0.0.0"
      "::"))
  (redis_server__allow (list
      "192.0.2.0/24"
      "2001:db8::/32"))
  (redis_server__instances (list
      
      (name "second")
      (port "6380")
      
      (name "third")
      (port "6381"))))
