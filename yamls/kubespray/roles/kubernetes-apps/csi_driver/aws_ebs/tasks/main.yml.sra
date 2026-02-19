(playbook "kubespray/roles/kubernetes-apps/csi_driver/aws_ebs/tasks/main.yml"
  (tasks
    (task "AWS CSI Driver | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "aws-ebs-csi-driver")
          (file "aws-ebs-csi-driver.yml")
          
          (name "aws-ebs-csi-controllerservice")
          (file "aws-ebs-csi-controllerservice-rbac.yml")
          
          (name "aws-ebs-csi-controllerservice")
          (file "aws-ebs-csi-controllerservice.yml")
          
          (name "aws-ebs-csi-nodeservice")
          (file "aws-ebs-csi-nodeservice.yml")))
      (register "aws_csi_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "AWS CSI Driver | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ aws_csi_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))))
