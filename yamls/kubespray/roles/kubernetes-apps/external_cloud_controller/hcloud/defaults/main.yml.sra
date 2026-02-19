(playbook "kubespray/roles/kubernetes-apps/external_cloud_controller/hcloud/defaults/main.yml"
  (external_hcloud_cloud 
    (hcloud_api_token "")
    (token_secret_name "hcloud")
    (service_account_name "cloud-controller-manager")
    (controller_image_tag "latest")
    (controller_extra_args )))
