(playbook "kubespray/roles/kubernetes-apps/snapshots/snapshot-controller/defaults/main.yml"
  (snapshot_controller_replicas "1")
  (snapshot_controller_namespace "kube-system"))
