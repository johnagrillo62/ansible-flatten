(playbook "ansible-examples/lamp_haproxy/provision.yml"
    (play
    (hosts "localhost")
    (connection "local")
    (gather_facts "False")
    (vars_files (list
        "group_vars/all"))
    (tasks
      (task "Launch webserver instances"
        (ec2 "access_key=\"" (jinja "{{ ec2_access_key }}") "\" secret_key=\"" (jinja "{{ ec2_secret_key }}") "\" keypair=\"" (jinja "{{ ec2_keypair }}") "\" group=\"" (jinja "{{ ec2_security_group }}") "\" type=\"" (jinja "{{ ec2_instance_type }}") "\" image=\"" (jinja "{{ ec2_image }}") "\" region=\"" (jinja "{{ ec2_region }}") "\" instance_tags=\"{'ansible_group':'" (jinja "{{ ec2_tag_webservers }}") "', 'type':'" (jinja "{{ ec2_instance_type }}") "', 'group':'" (jinja "{{ ec2_security_group }}") "', 'Name':'demo_''" (jinja "{{ tower_user_name }}") "'}\" count=\"" (jinja "{{ ec2_instance_count }}") "\"
")
        (register "ec2"))
      (task "Launch database instance"
        (ec2 "access_key=\"" (jinja "{{ ec2_access_key }}") "\" secret_key=\"" (jinja "{{ ec2_secret_key }}") "\" keypair=\"" (jinja "{{ ec2_keypair }}") "\" group=\"" (jinja "{{ ec2_security_group }}") "\" type=\"" (jinja "{{ ec2_instance_type }}") "\" image=\"" (jinja "{{ ec2_image }}") "\" region=\"" (jinja "{{ ec2_region }}") "\" instance_tags=\"{'ansible_group':'" (jinja "{{ ec2_tag_dbservers }}") "', 'type':'" (jinja "{{ ec2_instance_type }}") "', 'group':'" (jinja "{{ ec2_security_group }}") "', 'Name':'demo_''" (jinja "{{ tower_user_name }}") "'}\" count=\"1\"
")
        (register "ec2"))
      (task "Launch load balancing instance"
        (ec2 "access_key=\"" (jinja "{{ ec2_access_key }}") "\" secret_key=\"" (jinja "{{ ec2_secret_key }}") "\" keypair=\"" (jinja "{{ ec2_keypair }}") "\" group=\"" (jinja "{{ ec2_security_group }}") "\" type=\"" (jinja "{{ ec2_instance_type }}") "\" image=\"" (jinja "{{ ec2_image }}") "\" region=\"" (jinja "{{ ec2_region }}") "\" instance_tags=\"{'ansible_group':'" (jinja "{{ ec2_tag_lbservers }}") "', 'type':'" (jinja "{{ ec2_instance_type }}") "', 'group':'" (jinja "{{ ec2_security_group }}") "', 'Name':'demo_''" (jinja "{{ tower_user_name }}") "'}\" count=\"1\"
")
        (register "ec2"))
      (task "Launch monitoring instance"
        (ec2 "access_key=\"" (jinja "{{ ec2_access_key }}") "\" secret_key=\"" (jinja "{{ ec2_secret_key }}") "\" keypair=\"" (jinja "{{ ec2_keypair }}") "\" group=\"" (jinja "{{ ec2_security_group }}") "\" type=\"" (jinja "{{ ec2_instance_type }}") "\" image=\"" (jinja "{{ ec2_image }}") "\" region=\"" (jinja "{{ ec2_region }}") "\" instance_tags=\"{'ansible_group':'" (jinja "{{ ec2_tag_monitoring }}") "', 'type':'" (jinja "{{ ec2_instance_type }}") "', 'group':'" (jinja "{{ ec2_security_group }}") "', 'Name':'demo_''" (jinja "{{ tower_user_name }}") "'}\" count=\"1\"
")
        (register "ec2"))
      (task "Wait for SSH to come up"
        (local_action "wait_for host=" (jinja "{{ item.public_dns_name }}") " port=22 delay=60 timeout=320 state=started")
        (with_items (jinja "{{ ec2.instances }}"))))))
