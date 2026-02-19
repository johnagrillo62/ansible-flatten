(playbook "ansible-examples/windows/wamp_haproxy/site.yml"
    (play
    (hosts "tag_ansible_group_windows_dbservers")
    (connection "winrm")
    (vars
      (ansible_ssh_port "5986"))
    (roles
      "mssql")
    (tags (list
        "db")))
    (play
    (hosts "tag_ansible_group_windows_webservers")
    (connection "winrm")
    (vars
      (ansible_ssh_port "5986"))
    (roles
      "iis"
      "web")
    (tags (list
        "web")))
    (play
    (hosts "localhost")
    (connection "local")
    (gather_facts "False")
    (roles
      "elb")
    (tags (list
        "lb")))
    (play
    (hosts "tag_ansible_group_windows_webservers")
    (connection "winrm")
    (gather_facts "False")
    (vars
      (ansible_ssh_port "5986"))
    (tasks
      (task "Wait for webserver to come up"
        (local_action "wait_for host=" (jinja "{{ inventory_hostname }}") " port=80 state=started timeout=80"))
      (task "Add host to load balancing pool"
        (local_action 
          (module "ec2_elb")
          (region "us-east-1")
          (instance_id (jinja "{{ ec2_id }}"))
          (ec2_elbs "ansible-windows-demo-lb")
          (wait_timeout "330")
          (state "present"))))
    (tags (list
        "lb"))))
