(playbook "kubespray/inventory/sample/group_vars/k8s_cluster/k8s-net-macvlan.yml"
  (macvlan_interface "eth1")
  (enable_nat_default_gateway "true"))
