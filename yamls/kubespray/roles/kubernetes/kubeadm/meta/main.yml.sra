(playbook "kubespray/roles/kubernetes/kubeadm/meta/main.yml"
  (dependencies (list
      
      (role "kubernetes/kubeadm_common"))))
