(playbook "kubespray/tests/files/debian11-calico-collection.yml"
  (cloud_image "debian-11")
  (containerd_static_binary "true"))
