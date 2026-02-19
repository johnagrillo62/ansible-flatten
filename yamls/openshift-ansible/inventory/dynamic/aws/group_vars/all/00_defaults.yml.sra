(playbook "openshift-ansible/inventory/dynamic/aws/group_vars/all/00_defaults.yml"
  (ansible_become "yes")
  (openshift_deployment_type "origin"))
