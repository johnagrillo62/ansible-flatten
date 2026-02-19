(playbook "debops/docs/ansible/roles/unbound/examples/enable-dig-trace.yml"
  (unbound__server (list
      
      (name "access-control")
      (value (list
          
          (name "127.0.0.0/8")
          (args "allow_snoop")
          
          (name "::1/128")
          (args "allow_snoop"))))))
