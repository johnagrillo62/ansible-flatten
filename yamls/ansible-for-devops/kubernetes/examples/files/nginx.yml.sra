(playbook "ansible-for-devops/kubernetes/examples/files/nginx.yml"
  (apiVersion "apps/v1")
  (kind "Deployment")
  (metadata 
    (name "a4d-nginx")
    (namespace "default")
    (labels 
      (app "nginx")))
  (spec 
    (replicas "3")
    (selector 
      (matchLabels 
        (app "nginx")))
    (template 
      (metadata 
        (labels 
          (app "nginx")))
      (spec 
        (containers (list
            
            (name "nginx")
            (image "nginx:1.7.9")
            (ports (list
                
                (containerPort "80")))))))))
