(playbook "ansible-for-devops/kubernetes/examples/helm-cleanup.yml"
    (play
    (hosts "k8s-master")
    (become "yes")
    (tasks
      (task "Remove phpMyAdmin with Helm."
        (community.kubernetes.helm 
          (name "phpmyadmin")
          (chart_ref "bitnami/phpmyadmin")
          (release_namespace "default")
          (state "absent")))
      (task "Delete helm binary."
        (file 
          (path "/usr/local/bin/helm")
          (state "absent"))))))
