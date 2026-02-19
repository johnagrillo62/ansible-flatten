(playbook "ansible-examples/windows/wamp_haproxy/roles/elb/tasks/main.yml"
  (tasks
    (task "Create the ELB in AWS"
      (ec2_elb_lb 
        (name "ansible-windows-demo-lb")
        (state "present")
        (region "us-east-1")
        (zones (list
            "us-east-1b"
            "us-east-1d"
            "us-east-1e"))
        (listeners (list
            
            (protocol "http")
            (load_balancer_port "80")
            (instance_port "80")))))))
