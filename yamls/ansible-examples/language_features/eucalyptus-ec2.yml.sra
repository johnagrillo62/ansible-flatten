(playbook "ansible-examples/language_features/eucalyptus-ec2.yml"
    (play
    (name "Stage instance(s)")
    (hosts "local")
    (connection "local")
    (remote_user "root")
    (gather_facts "false")
    (vars
      (keypair "mykeypair")
      (instance_type "m1.small")
      (security_group "default")
      (image "emi-048B3A37"))
    (tasks
      (task "Launch instance"
        (ec2 "keypair=" (jinja "{{keypair}}") " group=" (jinja "{{security_group}}") " instance_type=" (jinja "{{instance_type}}") " image=" (jinja "{{image}}") " wait=true count=5")
        (register "ec2"))
      (task "Add new instances to host group"
        (add_host "hostname=" (jinja "{{item.public_ip}}") " groupname=deploy")
        (with_items "ec2.instances"))
      (task "Wait for the instances to boot by checking the ssh port"
        (wait_for "host=" (jinja "{{item.public_dns_name}}") " port=22 delay=60 timeout=320 state=started")
        (with_items "ec2.instances"))
      (task "Create a volume and attach"
        (ec2_vol "volume_size=20 instance=" (jinja "{{item.id}}"))
        (with_items "ec2.instances"))))
    (play
    (name "Configure instance")
    (hosts "deploy")
    (remote_user "root")
    (tasks
      (task "Ensure NTP is up and running"
        (service "name=ntpd state=started"))
      (task "Install Apache Web Server"
        (yum "pkg=httpd state=latest")))))
