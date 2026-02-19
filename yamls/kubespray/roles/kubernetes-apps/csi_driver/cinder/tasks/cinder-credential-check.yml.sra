(playbook "kubespray/roles/kubernetes-apps/csi_driver/cinder/tasks/cinder-credential-check.yml"
  (tasks
    (task "Cinder CSI Driver | check cinder_auth_url value"
      (fail 
        (msg "cinder_auth_url is missing"))
      (when "cinder_auth_url is not defined or not cinder_auth_url"))
    (task "Cinder CSI Driver | check cinder_username value cinder_application_credential_name value"
      (fail 
        (msg "you must either set cinder_username or cinder_application_credential_name"))
      (when (list
          "cinder_username is not defined or not cinder_username"
          "cinder_application_credential_name is not defined or not cinder_application_credential_name")))
    (task "Cinder CSI Driver | check cinder_application_credential_id value"
      (fail 
        (msg "cinder_application_credential_id is missing"))
      (when (list
          "cinder_application_credential_name is defined"
          "cinder_application_credential_name | length > 0"
          "cinder_application_credential_id is not defined or not cinder_application_credential_id")))
    (task "Cinder CSI Driver | check cinder_application_credential_secret value"
      (fail 
        (msg "cinder_application_credential_secret is missing"))
      (when (list
          "cinder_application_credential_name is defined"
          "cinder_application_credential_name | length > 0"
          "cinder_application_credential_secret is not defined or not cinder_application_credential_secret")))
    (task "Cinder CSI Driver | check cinder_password value"
      (fail 
        (msg "cinder_password is missing"))
      (when (list
          "cinder_username is defined"
          "cinder_username | length > 0"
          "cinder_application_credential_name is not defined or not cinder_application_credential_name"
          "cinder_application_credential_secret is not defined or not cinder_application_credential_secret"
          "cinder_password is not defined or not cinder_password")))
    (task "Cinder CSI Driver | check cinder_region value"
      (fail 
        (msg "cinder_region is missing"))
      (when "cinder_region is not defined or not cinder_region"))
    (task "Cinder CSI Driver | check cinder_tenant_id value"
      (fail 
        (msg "one of cinder_tenant_id or cinder_tenant_name must be specified"))
      (when (list
          "cinder_tenant_id is not defined or not cinder_tenant_id"
          "cinder_tenant_name is not defined or not cinder_tenant_name"
          "cinder_application_credential_name is not defined or not cinder_application_credential_name")))
    (task "Cinder CSI Driver | check cinder_domain_id value"
      (fail 
        (msg "one of cinder_domain_id or cinder_domain_name must be specified"))
      (when (list
          "cinder_domain_id is not defined or not cinder_domain_id"
          "cinder_domain_name is not defined or not cinder_domain_name"
          "cinder_application_credential_name is not defined or not cinder_application_credential_name")))))
