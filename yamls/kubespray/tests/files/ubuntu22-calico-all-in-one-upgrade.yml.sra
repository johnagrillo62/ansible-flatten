(playbook "kubespray/tests/files/ubuntu22-calico-all-in-one-upgrade.yml"
  (cloud_image "ubuntu-2204")
  (mode "all-in-one")
  (vm_memory "1800")
  (auto_renew_certificates "true")
  (kube_proxy_mode "iptables")
  (enable_nodelocaldns "false")
  (enable_dns_autoscaler "false")
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
          (skip_verify "true"))))))
