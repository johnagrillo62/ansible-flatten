(playbook "debops/docs/ansible/roles/rabbitmq_server/examples/simple-options.yml"
  (rabbitmq_server__config (list
      
      (name "rabbit")
      (options (list
          
          (example_option "value")
          
          (tcp_listeners (list
              "5672"))
          
          (reverse_dns_lookups "True")
          
          (vm_memory_high_watermark "0.4")
          
          (tcp_listeners "[{\"127.0.0.1\", 5672},
 {\"::1\",       5672}]"))))))
