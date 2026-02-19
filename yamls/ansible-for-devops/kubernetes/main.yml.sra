(playbook "ansible-for-devops/kubernetes/main.yml"
    (play
    (hosts "k8s")
    (become "yes")
    (vars_files (list
        "vars/main.yml"))
    (pre_tasks
      (task "Copy Flannel manifest tailored for Vagrant."
        (copy 
          (src "files/manifests/kube-system/kube-flannel-vagrant.yml")
          (dest "~/kube-flannel-vagrant.yml"))))
    (roles
      
        (role "geerlingguy.swap")
        (tags (list
            "swap"
            "kubernetes"))
      
        (role "geerlingguy.docker")
        (tags (list
            "docker"))
      
        (role "geerlingguy.kubernetes")
        (tags (list
            "kubernetes")))))
