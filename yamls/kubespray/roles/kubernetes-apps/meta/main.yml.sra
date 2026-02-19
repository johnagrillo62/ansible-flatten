(playbook "kubespray/roles/kubernetes-apps/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes-apps/utils")
      
      (role "kubernetes-apps/ansible")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"))
      
      (role "kubernetes-apps/helm")
      (when (list
          "helm_enabled"))
      (tags (list
          "helm"))
      
      (role "kubernetes-apps/registry")
      (when (list
          "registry_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "registry"))
      
      (role "kubernetes-apps/metrics_server")
      (when (list
          "metrics_server_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "metrics_server"))
      
      (role "kubernetes-apps/csi_driver/csi_crd")
      (when (list
          "cinder_csi_enabled or csi_snapshot_controller_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "csi-driver"))
      
      (role "kubernetes-apps/csi_driver/cinder")
      (when (list
          "cinder_csi_enabled"))
      (tags (list
          "cinder-csi-driver"
          "csi-driver"))
      
      (role "kubernetes-apps/csi_driver/aws_ebs")
      (when (list
          "aws_ebs_csi_enabled"))
      (tags (list
          "aws-ebs-csi-driver"
          "csi-driver"))
      
      (role "kubernetes-apps/csi_driver/azuredisk")
      (when (list
          "azure_csi_enabled"))
      (tags (list
          "azure-csi-driver"
          "csi-driver"))
      
      (role "kubernetes-apps/csi_driver/gcp_pd")
      (when (list
          "gcp_pd_csi_enabled"))
      (tags (list
          "gcp-pd-csi-driver"
          "csi-driver"))
      
      (role "kubernetes-apps/csi_driver/upcloud")
      (when (list
          "upcloud_csi_enabled"))
      (tags (list
          "upcloud-csi-driver"
          "csi-driver"))
      
      (role "kubernetes-apps/csi_driver/vsphere")
      (when (list
          "vsphere_csi_enabled"))
      (tags (list
          "vsphere-csi-driver"
          "csi-driver"))
      
      (role "kubernetes-apps/persistent_volumes")
      (when (list
          "persistent_volumes_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "persistent_volumes"))
      
      (role "kubernetes-apps/snapshots")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags (list
          "snapshots"
          "csi-driver"))
      
      (role "kubernetes-apps/container_runtimes")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "container-runtimes"))
      
      (role "kubernetes-apps/container_engine_accelerator")
      (when "nvidia_accelerator_enabled")
      (tags (list
          "container_engine_accelerator"))
      
      (role "kubernetes-apps/kubelet-csr-approver")
      (when (list
          "kubelet_csr_approver_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "kubelet-csr-approver"))
      
      (role "kubernetes-apps/metallb")
      (when (list
          "metallb_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "metallb"))
      
      (role "kubernetes-apps/argocd")
      (when (list
          "argocd_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "argocd"))
      
      (role "kubernetes-apps/scheduler_plugins")
      (when (list
          "scheduler_plugins_enabled"
          "kube_major_version is version('1.29', '<')"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "scheduler_plugins"))
      
      (role "kubernetes-apps/node_feature_discovery")
      (when (list
          "node_feature_discovery_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags (list
          "node_feature_discovery")))))
