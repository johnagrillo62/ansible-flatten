(playbook "ansible-examples/windows/wamp_haproxy/rolling_update.yml"
    (play
    (hosts "tag_ansible_group_windows_webservers")
    (serial "1")
    (gather_facts "False")
    (connection "winrm")
    (vars
      (ansible_ssh_port "5986"))
    (pre_tasks
      (task "Remove host from load balancing pool"
        (local_action 
          (module "ec2_elb")
          (region "us-east-1")
          (instance_id (jinja "{{ ec2_id }}"))
          (ec2_elbs "ansible-windows-demo-lb")
          (wait_timeout "330")
          (state "absent"))))
    (roles
      "web")
    (post_tasks
      (task "Wait for webserver to come up"
        (local_action "wait_for host=" (jinja "{{ inventory_hostname }}") " port=80 state=started timeout=80"))
      (task "Add host to load balancing pool"
        (local_action 
          (module "ec2_elb")
          (region "us-east-1")
          (instance_id (jinja "{{ ec2_id }}"))
          (ec2_elbs "ansible-windows-demo-lb")
          (wait_timeout "330")
          (state "present"))))))
