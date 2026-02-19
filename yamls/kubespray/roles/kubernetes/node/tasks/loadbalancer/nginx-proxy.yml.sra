(playbook "kubespray/roles/kubernetes/node/tasks/loadbalancer/nginx-proxy.yml"
  (tasks
    (task "Haproxy | Cleanup potentially deployed haproxy"
      (file 
        (path (jinja "{{ kube_manifest_dir }}") "/haproxy.yml")
        (state "absent")))
    (task "Nginx-proxy | Make nginx directory"
      (file 
        (path (jinja "{{ nginx_config_dir }}"))
        (state "directory")
        (mode "0700")
        (owner "root")))
    (task "Nginx-proxy | Write nginx-proxy configuration"
      (template 
        (src "loadbalancer/nginx.conf.j2")
        (dest (jinja "{{ nginx_config_dir }}") "/nginx.conf")
        (owner "root")
        (mode "0755")
        (backup "true"))
      (register "nginx_conf"))
    (task "Nginx-proxy | Write static pod"
      (template 
        (src "manifests/nginx-proxy.manifest.j2")
        (dest (jinja "{{ kube_manifest_dir }}") "/nginx-proxy.yml")
        (mode "0640")))))
