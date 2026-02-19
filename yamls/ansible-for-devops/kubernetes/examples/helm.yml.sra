(playbook "ansible-for-devops/kubernetes/examples/helm.yml"
    (play
    (hosts "k8s-master")
    (become "yes")
    (tasks
      (task "Retrieve helm binary archive."
        (unarchive 
          (src "https://get.helm.sh/helm-v3.2.1-linux-amd64.tar.gz")
          (dest "/tmp")
          (creates "/usr/local/bin/helm")
          (remote_src "yes")))
      (task "Move helm binary into place."
        (command "cp /tmp/linux-amd64/helm /usr/local/bin/helm")
        (args 
          (creates "/usr/local/bin/helm")))
      (task "Add Bitnami's chart repository."
        (community.kubernetes.helm_repository 
          (name "bitnami")
          (repo_url "https://charts.bitnami.com/bitnami")))
      (task "Install phpMyAdmin with Helm."
        (community.kubernetes.helm 
          (name "phpmyadmin")
          (chart_ref "bitnami/phpmyadmin")
          (release_namespace "default")
          (values 
            (service 
              (type "NodePort")))))
      (task "Ensure K8s module dependencies are installed."
        (pip 
          (name "openshift")
          (state "present")))
      (task "Get the details of the phpmyadmin Service."
        (community.kubernetes.k8s 
          (api_version "v1")
          (kind "Service")
          (name "phpmyadmin")
          (namespace "default"))
        (register "phpmyadmin_service"))
      (task "Print the NodePort of the phpmyadmin Service."
        (debug 
          (var "phpmyadmin_service.result.spec.ports[0].nodePort"))))))
