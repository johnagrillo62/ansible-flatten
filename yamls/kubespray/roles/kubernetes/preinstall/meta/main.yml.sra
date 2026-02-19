(playbook "kubespray/roles/kubernetes/preinstall/meta/main.yml"
  (dependencies (list
      
      (role "adduser")
      (user (jinja "{{ addusers.kube }}"))
      (when (list
          "not is_fedora_coreos"))
      (tags (list
          "kubelet")))))
