(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/vsphere/tasks/vsphere-credentials-check.yml"
  (tasks
    (task "External vSphere Cloud Provider | check external_vsphere_vcenter_ip value"
      (fail 
        (msg "external_vsphere_vcenter_ip is missing"))
      (when "external_vsphere_vcenter_ip is not defined or not external_vsphere_vcenter_ip"))
    (task "External vSphere Cloud Provider | check external_vsphere_vcenter_port value"
      (fail 
        (msg "external_vsphere_vcenter_port is missing"))
      (when "external_vsphere_vcenter_port is not defined or not external_vsphere_vcenter_port"))
    (task "External vSphere Cloud Provider | check external_vsphere_insecure value"
      (fail 
        (msg "external_vsphere_insecure is missing"))
      (when "external_vsphere_insecure is not defined or not external_vsphere_insecure"))
    (task "External vSphere Cloud Provider | check external_vsphere_user value"
      (fail 
        (msg "external_vsphere_user is missing"))
      (when "external_vsphere_user is not defined or not external_vsphere_user"))
    (task "External vSphere Cloud Provider | check external_vsphere_password value"
      (fail 
        (msg "external_vsphere_password is missing"))
      (when (list
          "external_vsphere_password is not defined or not external_vsphere_password")))
    (task "External vSphere Cloud Provider | check external_vsphere_datacenter value"
      (fail 
        (msg "external_vsphere_datacenter is missing"))
      (when (list
          "external_vsphere_datacenter is not defined or not external_vsphere_datacenter")))))
