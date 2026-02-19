(playbook "kubespray/roles/win_nodes/kubernetes_patch/defaults/main.yml"
  (kubernetes_user_manifests_path (jinja "{{ ansible_env.HOME }}") "/kube-manifests")
  (kube_proxy_nodeselector "kubernetes.io/os"))
