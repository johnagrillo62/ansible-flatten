(playbook "debops/docs/ansible/roles/redis_sentinel/examples/multiple_instances.yml"
  (redis_sentinel__bind (list
      "0.0.0.0"
      "::"))
  (redis_sentinel__allow (list
      "192.0.2.0/24"
      "2001:db8::/32"))
  (redis_sentinel__instances (list
      
      (name "second")
      (port "6380")
      
      (name "third")
      (port "6381"))))
