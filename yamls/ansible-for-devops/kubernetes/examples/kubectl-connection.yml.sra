(playbook "ansible-for-devops/kubernetes/examples/kubectl-connection.yml"
    (play
    (hosts "k8s-master")
    (become "yes")
    (tasks
      (task "Retrieve kubectl config file from the master server."
        (fetch 
          (src "/root/.kube/config")
          (dest "files/kubectl-config")
          (flat "yes")))
      (task "Get the phpmyadmin Pod name."
        (command "kubectl --no-headers=true get pod -l app=phpmyadmin -o custom-columns=:metadata.name
")
        (register "phpmyadmin_pod"))
      (task "Add the phpmyadmin Pod to the inventory."
        (add_host 
          (name (jinja "{{ phpmyadmin_pod.stdout }}"))
          (ansible_kubectl_namespace "default")
          (ansible_kubectl_config "files/kubectl-config")
          (ansible_connection "kubectl")))
      (task "Run a command inside the container."
        (raw "date")
        (register "date_output")
        (delegate_to (jinja "{{ phpmyadmin_pod.stdout }}")))
      (task
        (debug "var=date_output.stdout")))))
