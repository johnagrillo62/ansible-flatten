(playbook "kubespray/roles/kubernetes-apps/policy_controller/meta/main.yml"
  (dependencies (list
      
      (role "policy_controller/calico")
      (when (list
          "kube_network_plugin in ['calico']"
          "enable_network_policy"))
      (tags (list
          "policy-controller")))))
