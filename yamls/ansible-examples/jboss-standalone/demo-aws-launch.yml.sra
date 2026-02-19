(playbook "ansible-examples/jboss-standalone/demo-aws-launch.yml"
    (play
    (name "Provision instances")
    (hosts "localhost")
    (connection "local")
    (gather_facts "False")
    (vars_files (list
        "group_vars/all"))
    (tasks
      (task "Launch instances"
        (ec2 
          (access_key (jinja "{{ ec2_access_key }}"))
          (secret_key (jinja "{{ ec2_secret_key }}"))
          (keypair (jinja "{{ ec2_keypair }}"))
          (group (jinja "{{ ec2_security_group }}"))
          (type (jinja "{{ ec2_instance_type }}"))
          (image (jinja "{{ ec2_image }}"))
          (region (jinja "{{ ec2_region }}"))
          (instance_tags "{'ansible_group':'jboss', 'type':'" (jinja "{{ ec2_instance_type }}") "', 'group':'" (jinja "{{ ec2_security_group }}") "', 'Name':'demo_''" (jinja "{{ tower_user_name }}") "'}")
          (count (jinja "{{ ec2_instance_count }}"))
          (wait "true"))
        (register "ec2"))
      (task "Wait for SSH to come up"
        (wait_for 
          (host (jinja "{{ item.public_dns_name }}"))
          (port "22")
          (delay "60")
          (timeout "320")
          (state "started"))
        (with_items (jinja "{{ ec2.instances }}"))))))
