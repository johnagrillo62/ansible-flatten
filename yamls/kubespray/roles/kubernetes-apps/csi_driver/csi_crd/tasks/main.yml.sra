(playbook "kubespray/roles/kubernetes-apps/csi_driver/csi_crd/tasks/main.yml"
  (tasks
    (task "CSI CRD | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "volumegroupsnapshotclasses")
          (file "volumegroupsnapshotclasses.yml")
          
          (name "volumegroupsnapshotcontents")
          (file "volumegroupsnapshotcontents.yml")
          
          (name "volumegroupsnapshots")
          (file "volumegroupsnapshots.yml")
          
          (name "volumesnapshotclasses")
          (file "volumesnapshotclasses.yml")
          
          (name "volumesnapshotcontents")
          (file "volumesnapshotcontents.yml")
          
          (name "volumesnapshots")
          (file "volumesnapshots.yml")))
      (register "csi_crd_manifests")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "CSI CRD | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest")
        (wait "true"))
      (with_items (list
          (jinja "{{ csi_crd_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}"))))))
