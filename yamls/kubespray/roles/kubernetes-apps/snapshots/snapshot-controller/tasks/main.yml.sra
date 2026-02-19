(playbook "kubespray/roles/kubernetes-apps/snapshots/snapshot-controller/tasks/main.yml"
  (tasks
    (task "Check if snapshot namespace exists"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (name (jinja "{{ snapshot_controller_namespace }}"))
        (resource "namespace")
        (state "exists"))
      (register "snapshot_namespace_exists")
      (when "inventory_hostname == groups['kube_control_plane'][0]")
      (tags "snapshot-controller"))
    (task "Snapshot Controller | Generate Manifests"
      (template 
        (src (jinja "{{ item.file }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.file }}"))
        (mode "0644"))
      (with_items (list
          
          (name "snapshot-ns")
          (file "snapshot-ns.yml")
          (apply "not snapshot_namespace_exists")
          
          (name "rbac-snapshot-controller")
          (file "rbac-snapshot-controller.yml")
          
          (name "snapshot-controller")
          (file "snapshot-controller.yml")))
      (register "snapshot_controller_manifests")
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "item.apply | default(True) | bool"))
      (tags "snapshot-controller"))
    (task "Snapshot Controller | Apply Manifests"
      (kube 
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item.item.file }}"))
        (state "latest"))
      (with_items (list
          (jinja "{{ snapshot_controller_manifests.results }}")))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]"
          "not item is skipped"))
      (loop_control 
        (label (jinja "{{ item.item.file }}")))
      (tags "snapshot-controller"))))
