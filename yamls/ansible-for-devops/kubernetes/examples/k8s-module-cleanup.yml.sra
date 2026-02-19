(playbook "ansible-for-devops/kubernetes/examples/k8s-module-cleanup.yml"
    (play
    (hosts "k8s-master")
    (become "yes")
    (tasks
      (task "Remove resources in Nginx Deployment definition."
        (k8s 
          (state "absent")
          (definition (jinja "{{ lookup('file', 'files/nginx.yml') | from_yaml }}"))))
      (task "Remove the Nginx Service."
        (k8s 
          (state "absent")
          (api_version "v1")
          (kind "Service")
          (namespace "default")
          (name "a4d-nginx"))))))
