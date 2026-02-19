(playbook "kubespray/roles/network_plugin/cni/defaults/main.yml"
  (cni_bin_owner (jinja "{{ kube_owner }}")))
