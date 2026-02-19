(playbook "kubespray/roles/reset/defaults/main.yml"
  (flush_iptables "true")
  (reset_restart_network "true")
  (cri_stop_containers_grace_period "0"))
