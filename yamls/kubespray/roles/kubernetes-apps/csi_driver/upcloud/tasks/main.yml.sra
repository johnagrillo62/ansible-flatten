(playbook "kubespray/roles/kubernetes-apps/csi_driver/upcloud/tasks/main.yml"
  (tasks
    (task "UpCloud CSI Driver | Check if UPCLOUD_USERNAME exists"
      (fail 
        (msg "UpCloud username is missing. Env UPCLOUD_USERNAME is mandatory"))
      (when "upcloud_username is not defined or not upcloud_username"))
    (task "UpCloud CSI Driver | Check if UPCLOUD_PASSWORD exists"
      (fail 
        (msg "UpCloud password is missing. Env UPCLOUD_PASSWORD is mandatory"))
      (when (list
          "upcloud_username is defined"
          "upcloud_username | length > 0"
          "upcloud_password is not defined or not upcloud_password")))
    (task "UpCloud CSI Driver | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "upcloud-csi-cred-secret")
          (file "upcloud-csi-cred-secret.yml")
          
          (name "upcloud-csi-setup")
          (file "upcloud-csi-setup.yml")
          
          (name "upcloud-csi-controller")
          (file "upcloud-csi-controller.yml")
          
          (name "upcloud-csi-node")
          (file "upcloud-csi-node.yml")
          
          (name "upcloud-csi-driver")
          (file "upcloud-csi-driver.yml")))
      (register "upcloud_csi_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "UpCloud CSI Driver | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ upcloud_csi_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))))
