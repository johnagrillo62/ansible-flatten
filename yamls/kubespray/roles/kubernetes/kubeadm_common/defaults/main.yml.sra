(playbook "kubespray/roles/kubernetes/kubeadm_common/defaults/main.yml"
  (kubeadm_patches_dir (jinja "{{ kube_config_dir }}") "/patches")
  (kubeadm_patches (list))
  (kubeadm_ignore_preflight_errors (list)))
