(playbook "kubespray/roles/kubernetes-apps/csi_driver/azuredisk/tasks/azure-credential-check.yml"
  (tasks
    (task "Azure CSI Driver | check azure_csi_tenant_id value"
      (fail 
        (msg "azure_csi_tenant_id is missing"))
      (when "azure_csi_tenant_id is not defined or not azure_csi_tenant_id"))
    (task "Azure CSI Driver | check azure_csi_subscription_id value"
      (fail 
        (msg "azure_csi_subscription_id is missing"))
      (when "azure_csi_subscription_id is not defined or not azure_csi_subscription_id"))
    (task "Azure CSI Driver | check azure_csi_aad_client_id value"
      (fail 
        (msg "azure_csi_aad_client_id is missing"))
      (when "azure_csi_aad_client_id is not defined or not azure_csi_aad_client_id"))
    (task "Azure CSI Driver | check azure_csi_aad_client_secret value"
      (fail 
        (msg "azure_csi_aad_client_secret is missing"))
      (when "azure_csi_aad_client_secret is not defined or not azure_csi_aad_client_secret"))
    (task "Azure CSI Driver | check azure_csi_resource_group value"
      (fail 
        (msg "azure_csi_resource_group is missing"))
      (when "azure_csi_resource_group is not defined or not azure_csi_resource_group"))
    (task "Azure CSI Driver | check azure_csi_location value"
      (fail 
        (msg "azure_csi_location is missing"))
      (when "azure_csi_location is not defined or not azure_csi_location"))
    (task "Azure CSI Driver | check azure_csi_subnet_name value"
      (fail 
        (msg "azure_csi_subnet_name is missing"))
      (when "azure_csi_subnet_name is not defined or not azure_csi_subnet_name"))
    (task "Azure CSI Driver | check azure_csi_security_group_name value"
      (fail 
        (msg "azure_csi_security_group_name is missing"))
      (when "azure_csi_security_group_name is not defined or not azure_csi_security_group_name"))
    (task "Azure CSI Driver | check azure_csi_vnet_name value"
      (fail 
        (msg "azure_csi_vnet_name is missing"))
      (when "azure_csi_vnet_name is not defined or not azure_csi_vnet_name"))
    (task "Azure CSI Driver | check azure_csi_vnet_resource_group value"
      (fail 
        (msg "azure_csi_vnet_resource_group is missing"))
      (when "azure_csi_vnet_resource_group is not defined or not azure_csi_vnet_resource_group"))
    (task "Azure CSI Driver | check azure_csi_use_instance_metadata is a bool"
      (assert 
        (that "azure_csi_use_instance_metadata | type_debug == 'bool'")))))
