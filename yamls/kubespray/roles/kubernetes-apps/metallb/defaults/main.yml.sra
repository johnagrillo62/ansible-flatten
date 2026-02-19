(playbook "kubespray/roles/kubernetes-apps/metallb/defaults/main.yml"
  (metallb_enabled "false")
  (metallb_log_level "info")
  (metallb_namespace "metallb-system")
  (metallb_port "7472")
  (metallb_memberlist_port "7946")
  (metallb_speaker_enabled (jinja "{{ metallb_enabled }}"))
  (metallb_speaker_nodeselector 
    (kubernetes.io/os "linux"))
  (metallb_controller_nodeselector 
    (kubernetes.io/os "linux"))
  (metallb_speaker_tolerations (list
      
      (effect "NoSchedule")
      (key "node-role.kubernetes.io/control-plane")
      (operator "Exists")))
  (metallb_controller_tolerations (list))
  (metallb_loadbalancer_class ""))
