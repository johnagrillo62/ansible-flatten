(playbook "kubespray/roles/kubernetes-apps/persistent_volumes/aws-ebs-csi/defaults/main.yml"
  (restrict_az_provisioning "false")
  (aws_ebs_availability_zones (list
      "eu-west-3c")))
