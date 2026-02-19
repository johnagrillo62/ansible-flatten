(playbook "ansible-for-devops/lamp-infrastructure/provisioners/aws.yml"
    (play
    (hosts "localhost")
    (connection "local")
    (gather_facts "false")
    (vars
      (aws_profile "default")
      (aws_region "us-east-1")
      (aws_ec2_ami "ami-06cf02a98a61f9f5e")
      (instances (list
          
          (name "a4d.lamp.varnish")
          (group "lamp_varnish")
          (security_group (list
              "default"
              "a4d_lamp_http"))
          
          (name "a4d.lamp.www.1")
          (group "lamp_www")
          (security_group (list
              "default"
              "a4d_lamp_http"))
          
          (name "a4d.lamp.www.2")
          (group "lamp_www")
          (security_group (list
              "default"
              "a4d_lamp_http"))
          
          (name "a4d.lamp.db.1")
          (group "lamp_db")
          (security_group (list
              "default"
              "a4d_lamp_db"))
          
          (name "a4d.lamp.db.2")
          (group "lamp_db")
          (security_group (list
              "default"
              "a4d_lamp_db"))
          
          (name "a4d.lamp.memcached")
          (group "lamp_memcached")
          (security_group (list
              "default"
              "a4d_lamp_memcached"))))
      (security_groups (list
          
          (name "a4d_lamp_http")
          (rules (list
              
              (proto "tcp")
              (from_port "80")
              (to_port "80")
              (cidr_ip "0.0.0.0/0")
              
              (proto "tcp")
              (from_port "22")
              (to_port "22")
              (cidr_ip "0.0.0.0/0")))
          (rules_egress (list))
          
          (name "a4d_lamp_db")
          (rules (list
              
              (proto "tcp")
              (from_port "3306")
              (to_port "3306")
              (cidr_ip "0.0.0.0/0")
              
              (proto "tcp")
              (from_port "22")
              (to_port "22")
              (cidr_ip "0.0.0.0/0")))
          (rules_egress (list))
          
          (name "a4d_lamp_memcached")
          (rules (list
              
              (proto "tcp")
              (from_port "11211")
              (to_port "11211")
              (cidr_ip "0.0.0.0/0")
              
              (proto "tcp")
              (from_port "22")
              (to_port "22")
              (cidr_ip "0.0.0.0/0")))
          (rules_egress (list)))))
    (tasks
      (task "Configure EC2 Security Groups."
        (ec2_group 
          (name (jinja "{{ item.name }}"))
          (description "Example EC2 security group for A4D.")
          (state "present")
          (rules (jinja "{{ item.rules }}"))
          (rules_egress (jinja "{{ item.rules_egress }}"))
          (profile (jinja "{{ aws_profile }}"))
          (region (jinja "{{ aws_region }}")))
        (with_items (jinja "{{ security_groups }}")))
      (task "Provision EC2 instances."
        (ec2 
          (key_name (jinja "{{ item.ssh_key | default('lamp_aws') }}"))
          (instance_tags 
            (Name (jinja "{{ item.name | default('') }}"))
            (Application "lamp_aws")
            (inventory_group (jinja "{{ item.group | default('') }}"))
            (inventory_host (jinja "{{ item.name | default('') }}")))
          (group (jinja "{{ item.security_group | default('') }}"))
          (instance_type (jinja "{{ item.type | default('t2.micro')}}"))
          (image (jinja "{{ aws_ec2_ami }}"))
          (wait "yes")
          (wait_timeout "500")
          (exact_count "1")
          (count_tag 
            (inventory_host (jinja "{{ item.name | default('') }}")))
          (profile (jinja "{{ aws_profile }}"))
          (region (jinja "{{ aws_region }}")))
        (register "created_instances")
        (with_items (jinja "{{ instances }}")))
      (task "Add EC2 instances to inventory groups."
        (add_host 
          (name (jinja "{{ item.1.tagged_instances.0.public_ip }}"))
          (groups "aws," (jinja "{{ item.1.item.group }}") "," (jinja "{{ item.1.item.name }}"))
          (ansible_user "centos")
          (host_key_checking "false")
          (mysql_replication_role (jinja "{{ 'master' if (item.1.item.name == 'a4d.lamp.db.1') else 'slave' }}"))
          (mysql_server_id (jinja "{{ item.0 }}")))
        (with_indexed_items (jinja "{{ created_instances.results }}"))
        (when "item.1.instances is defined"))))
    (play
    (hosts "aws")
    (gather_facts "false")
    (tasks
      (task "Wait for hosts to become available."
        (wait_for_connection null)))))
