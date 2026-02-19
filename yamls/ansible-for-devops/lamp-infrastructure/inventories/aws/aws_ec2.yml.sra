(playbook "ansible-for-devops/lamp-infrastructure/inventories/aws/aws_ec2.yml"
  (plugin "aws_ec2")
  (regions (list
      "us-east-1"))
  (hostnames (list
      "ip-address"))
  (keyed_groups (list
      
      (key "tags.inventory_group")
      (separator "")
      
      (key "tags.Application")
      (separator ""))))
