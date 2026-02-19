(playbook "kubespray/roles/kubernetes/preinstall/tasks/0050-create_directories.yml"
  (tasks
    (task "Create kubernetes directories"
      (file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ kube_owner }}"))
        (mode "0755"))
      (when "('k8s_cluster' in group_names)")
      (become "true")
      (tags (list
          "kubelet"
          "kube-controller-manager"
          "kube-apiserver"
          "bootstrap_os"
          "apps"
          "network"
          "control-plane"
          "node"))
      (with_items (list
          (jinja "{{ kube_config_dir }}")
          (jinja "{{ kube_manifest_dir }}")
          (jinja "{{ kube_script_dir }}")
          (jinja "{{ kubelet_flexvolumes_plugins_dir }}"))))
    (task "Create other directories of root owner"
      (file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (mode "0755"))
      (when "('k8s_cluster' in group_names)")
      (become "true")
      (tags (list
          "kubelet"
          "kube-controller-manager"
          "kube-apiserver"
          "bootstrap_os"
          "apps"
          "network"
          "control-plane"
          "node"))
      (with_items (list
          (jinja "{{ kube_cert_dir }}")
          (jinja "{{ bin_dir }}"))))
    (task "Check if kubernetes kubeadm compat cert dir exists"
      (stat 
        (path (jinja "{{ kube_cert_compat_dir }}"))
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "kube_cert_compat_dir_check")
      (when (list
          "('k8s_cluster' in group_names)"
          "kube_cert_dir != kube_cert_compat_dir")))
    (task "Create kubernetes kubeadm compat cert dir (kubernetes/kubeadm issue 1498)"
      (file 
        (src (jinja "{{ kube_cert_dir }}"))
        (dest (jinja "{{ kube_cert_compat_dir }}"))
        (state "link")
        (mode "0755"))
      (when (list
          "('k8s_cluster' in group_names)"
          "kube_cert_dir != kube_cert_compat_dir"
          "not kube_cert_compat_dir_check.stat.exists")))
    (task "Create cni directories"
      (file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ kube_owner }}"))
        (mode "0755"))
      (with_items (list
          "/etc/cni/net.d"
          "/opt/cni/bin"))
      (when (list
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\", \"kube-ovn\", \"kube-router\", \"macvlan\"]"
          "('k8s_cluster' in group_names)"))
      (tags (list
          "network"
          "cilium"
          "calico"
          "kube-ovn"
          "kube-router"
          "bootstrap_os")))
    (task "Create calico cni directories"
      (file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ kube_owner }}"))
        (mode "0755"))
      (with_items (list
          "/var/lib/calico"))
      (when (list
          "kube_network_plugin == \"calico\""
          "('k8s_cluster' in group_names)"))
      (tags (list
          "network"
          "calico"
          "bootstrap_os")))
    (task "Create local volume provisioner directories"
      (file 
        (path (jinja "{{ local_volume_provisioner_storage_classes[item].host_dir }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode (jinja "{{ local_volume_provisioner_directory_mode }}")))
      (with_items (jinja "{{ local_volume_provisioner_storage_classes.keys() | list }}"))
      (when (list
          "('k8s_cluster' in group_names)"
          "local_volume_provisioner_enabled"))
      (tags (list
          "persistent_volumes")))))
