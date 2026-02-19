(playbook "kubespray/tests/files/debian11-custom-cni.yml"
  (cloud_image "debian-11")
  (kube_owner "root")
  (kube_network_plugin "custom_cni")
  (custom_cni_manifests (list
      (jinja "{{ playbook_dir }}") "/../tests/files/custom_cni/cilium.yaml"))
  (containerd_static_binary "true"))
