(playbook "ansible-for-devops/kubernetes/examples/k8s-module.yml"
    (play
    (hosts "k8s-master")
    (become "yes")
    (pre_tasks
      (task "Ensure Pip is installed."
        (package 
          (name "python-pip")
          (state "present")))
      (task "Ensure OpenShift client is installed."
        (pip 
          (name "openshift")
          (state "present"))))
    (tasks
      (task "Apply Nginx definition from Ansible controller file system."
        (k8s 
          (state "present")
          (definition (jinja "{{ lookup('file', 'files/nginx.yml') | from_yaml }}"))))
      (task "Expose the Nginx service with an inline Service definition."
        (k8s 
          (state "present")
          (definition 
            (apiVersion "v1")
            (kind "Service")
            (metadata 
              (labels 
                (app "nginx"))
              (name "a4d-nginx")
              (namespace "default"))
            (spec 
              (type "NodePort")
              (ports (list
                  
                  (port "80")
                  (protocol "TCP")
                  (targetPort "80")))
              (selector 
                (app "nginx"))))))
      (task "Get the details of the a4d-nginx Service."
        (k8s_info 
          (api_version "v1")
          (kind "Service")
          (name "a4d-nginx")
          (namespace "default"))
        (register "a4d_nginx_service"))
      (task "Print the NodePort of the a4d-nginx Service."
        (debug 
          (var "a4d_nginx_service.resources[0].spec.ports[0].nodePort"))))))
