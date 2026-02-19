(playbook "kubespray/tests/files/ubuntu24-cilium-sep.yml"
  (cloud_image "ubuntu-2404")
  (mode "separate")
  (kube_network_plugin "cilium")
  (enable_network_policy "true")
  (auto_renew_certificates "true")
  (kube_owner "root"))
