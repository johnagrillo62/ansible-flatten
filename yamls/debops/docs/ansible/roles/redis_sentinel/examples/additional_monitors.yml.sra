(playbook "debops/docs/ansible/roles/redis_sentinel/examples/additional_monitors.yml"
  (redis_sentinel__monitors (list
      
      (name "redis-ha-second")
      (host "redis.example.org")
      (port "6380")
      (quorum "2")
      (failover-timeout "180000")
      (down-after-miliseconds "30000")
      
      (name "redis-ha-third")
      (host "redis.example.org")
      (port "6381")
      (quorum "2"))))
