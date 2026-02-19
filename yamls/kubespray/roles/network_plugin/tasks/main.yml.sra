(playbook "kubespray/roles/network_plugin/tasks/main.yml"
  (tasks
    (task "Container Network Interface plugin"
      (include_role 
        (name "network_plugin/cni"))
      (when "kube_network_plugin != 'none'"))
    (task "Network plugin"
      (include_role 
        (name "network_plugin/" (jinja "{{ kube_network_plugin }}"))
        (apply 
          (tags (list
              (jinja "{{ kube_network_plugin }}")
              "network"))))
      (when (list
          "kube_network_plugin != 'none'"))
      (tags (list
          "cilium"
          "calico"
          "flannel"
          "macvlan"
          "kube-ovn"
          "kube-router"
          "custom_cni")))
    (task "Cilium additional"
      (include_role 
        (name "network_plugin/cilium")
        (apply 
          (tags (list
              "cilium"
              "network"))))
      (when (list
          "kube_network_plugin != 'cilium'"
          "cilium_deploy_additionally"))
      (tags (list
          "cilium")))
    (task "Multus"
      (include_role 
        (name "network_plugin/multus")
        (apply 
          (tags (list
              "multus"
              "network"))))
      (when "kube_network_plugin_multus")
      (tags (list
          "multus")))))
