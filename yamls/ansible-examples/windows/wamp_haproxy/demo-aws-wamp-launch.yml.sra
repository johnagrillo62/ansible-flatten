(playbook "ansible-examples/windows/wamp_haproxy/demo-aws-wamp-launch.yml"
    (play
    (hosts "localhost")
    (connection "local")
    (gather_facts "False")
    (vars_files (list
        "group_vars/all"))
    (tasks
      (task "Launch webserver instances"
        (ec2 "access_key=\"" (jinja "{{ ec2_access_key }}") "\" secret_key=\"" (jinja "{{ ec2_secret_key }}") "\" keypair=\"" (jinja "{{ ec2_keypair }}") "\" group=\"" (jinja "{{ ec2_security_group }}") "\" type=\"" (jinja "{{ ec2_instance_type }}") "\" image=\"ami-0d789266\" region=\"" (jinja "{{ ec2_region }}") "\" instance_tags=\"{'ansible_group':'windows_webservers', 'type':'" (jinja "{{ ec2_instance_type }}") "', 'group':'" (jinja "{{ ec2_security_group }}") "', 'Name':'demo_''" (jinja "{{ tower_user_name }}") "'}\" count=\"" (jinja "{{ ec2_instance_count }}") "\" wait=true
")
        (register "ec2")
        (tags (list
            "web")))
      (task "Launch database instance"
        (ec2 "access_key=\"" (jinja "{{ ec2_access_key }}") "\" secret_key=\"" (jinja "{{ ec2_secret_key }}") "\" keypair=\"" (jinja "{{ ec2_keypair }}") "\" group=\"" (jinja "{{ ec2_security_group }}") "\" type=\"" (jinja "{{ ec2_instance_type }}") "\" image=\"ami-17d66f7c\" region=\"" (jinja "{{ ec2_region }}") "\" instance_tags=\"{'ansible_group':'windows_dbservers', 'type':'" (jinja "{{ ec2_instance_type }}") "', 'group':'" (jinja "{{ ec2_security_group }}") "', 'Name':'demo_''" (jinja "{{ tower_user_name }}") "'}\" count=\"1\" wait=true
")
        (register "ec2")
        (tags (list
            "db")))
      (task "Wait for WinRM to come up"
        (local_action "wait_for host=" (jinja "{{ item.public_dns_name }}") " port=5986 delay=60 timeout=320 state=started")
        (with_items "ec2.instances")
        (tags (list
            "web"
            "db"))))))
