(playbook "kubespray/tests/files/ubuntu24-calico-etcd-datastore.yml"
  (cloud_image "ubuntu-2404")
  (mode "node-etcd-client")
  (vm_memory "1800")
  (auto_renew_certificates "true")
  (kube_proxy_mode "nftables")
  (enable_nodelocaldns "false")
  (containerd_registries_mirrors (list
      
      (prefix "docker.io")
      (mirrors (list
          
          (host "https://mirror.gcr.io")
          (capabilities (list
              "pull"
              "resolve"))
          (skip_verify "false")))
      
      (prefix "172.19.16.11:5000")
      (mirrors (list
          
          (host "http://172.19.16.11:5000")
          (capabilities (list
              "pull"
              "resolve"
              "push"))
          (skip_verify "true")))))
  (calico_datastore "etcd")
  (kubeadm_patches (list
      
      (target "kube-apiserver")
      (patch 
        (metadata 
          (annotations 
            (example.com/test "true"))
          (labels 
            (example.com/prod_level "prep"))))
      
      (target "kube-controller-manager")
      (patch 
        (metadata 
          (annotations 
            (example.com/test "false"))
          (labels 
            (example.com/prod_level "prep"))))))
  (ntp_enabled "true")
  (ntp_package "ntpsec"))
