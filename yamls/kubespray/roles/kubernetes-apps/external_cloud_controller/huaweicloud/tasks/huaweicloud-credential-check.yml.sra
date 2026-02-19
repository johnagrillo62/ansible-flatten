(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/huaweicloud/tasks/huaweicloud-credential-check.yml"
  (tasks
    (task "External Huawei Cloud Controller | check external_huaweicloud_auth_url value"
      (fail 
        (msg "external_huaweicloud_auth_url is missing"))
      (when "external_huaweicloud_auth_url is not defined or not external_huaweicloud_auth_url"))
    (task "External Huawei Cloud Controller | check external_huaweicloud_access_key value"
      (fail 
        (msg "you must set external_huaweicloud_access_key"))
      (when (list
          "external_huaweicloud_access_key is not defined or not external_huaweicloud_access_key")))
    (task "External Huawei Cloud Controller | check external_huaweicloud_secret_key value"
      (fail 
        (msg "external_huaweicloud_secret_key is missing"))
      (when (list
          "external_huaweicloud_access_key is defined"
          "external_huaweicloud_access_key|length > 0"
          "external_huaweicloud_secret_key is not defined or not external_huaweicloud_secret_key")))
    (task "External Huawei Cloud Controller | check external_huaweicloud_region value"
      (fail 
        (msg "external_huaweicloud_region is missing"))
      (when "external_huaweicloud_region is not defined or not external_huaweicloud_region"))
    (task "External Huawei Cloud Controller | check external_huaweicloud_project_id value"
      (fail 
        (msg "one of external_huaweicloud_project_id must be specified"))
      (when (list
          "external_huaweicloud_project_id is not defined or not external_huaweicloud_project_id")))))
