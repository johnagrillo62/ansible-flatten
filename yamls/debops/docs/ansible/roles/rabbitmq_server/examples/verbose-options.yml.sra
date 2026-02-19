(playbook "debops/docs/ansible/roles/rabbitmq_server/examples/verbose-options.yml"
  (rabbitmq_server__config (list
      
      (name "rabbit")
      (options (list
          
          (name "example_option")
          (value "value")
          (type "string")
          
          (name "tcp_listeners")
          (value (list
              "5672"))
          (type "list")
          
          (name "reverse_dns_lookups")
          (value "True")
          
          (name "vm_memroy_high_watermark")
          (value "0.4")
          
          (name "bit_option")
          (value "bit-value")
          (type "bit-string")
          
          (name "default_permissions")
          (value (list
              ".*"
              ".*"
              ".*"))
          (type "bit-list")
          
          (name "tcp_listeners")
          (value "[{\"127.0.0.1\", 5672},
 {\"::1\",       5672}]
")
          (type "raw"))))))
