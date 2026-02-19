(playbook "debops/docs/ansible/roles/redis_sentinel/examples/modify_main_instance.yml"
  (redis_sentinel__instances (list
      
      (name "main")
      (bind (list
          "0.0.0.0"
          "::"))))
  (redis_sentinel__monitors (list
      
      (name "redis-ha")
      (host (jinja "{{ ansible_fqdn }}")))))
