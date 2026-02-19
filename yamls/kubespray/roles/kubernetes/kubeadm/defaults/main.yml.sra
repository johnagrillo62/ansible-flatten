(playbook "kubespray/roles/kubernetes/kubeadm/defaults/main.yml"
  (discovery_timeout "60s")
  (kubeadm_join_timeout "120s")
  (kubeadm_use_file_discovery (jinja "{{ remove_anonymous_access }}")))
