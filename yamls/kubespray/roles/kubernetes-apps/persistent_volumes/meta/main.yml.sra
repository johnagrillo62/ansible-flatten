(playbook "kubespray/roles/kubernetes-apps/persistent_volumes/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/persistent_volumes/cinder-csi")
      (when (list
          "cinder_csi_enabled"))
      (tags (list
          "persistent_volumes_cinder_csi"
          "cinder-csi-driver"))
      
      (role "kubernetes-apps/persistent_volumes/aws-ebs-csi")
      (when (list
          "aws_ebs_csi_enabled"))
      (tags (list
          "persistent_volumes_aws_ebs_csi"
          "aws-ebs-csi-driver"))
      
      (role "kubernetes-apps/persistent_volumes/azuredisk-csi")
      (when (list
          "azure_csi_enabled"))
      (tags (list
          "persistent_volumes_azure_csi"
          "azure-csi-driver"))
      
      (role "kubernetes-apps/persistent_volumes/gcp-pd-csi")
      (when (list
          "gcp_pd_csi_enabled"))
      (tags (list
          "persistent_volumes_gcp_pd_csi"
          "gcp-pd-csi-driver"))
      
      (role "kubernetes-apps/persistent_volumes/upcloud-csi")
      (when (list
          "upcloud_csi_enabled"))
      (tags (list
          "persistent_volumes_upcloud_csi"
          "upcloud-csi-driver")))))
